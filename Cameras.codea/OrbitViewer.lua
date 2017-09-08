-------------------------------------------------------------------------------
-- OrbitViewer
-- Written by John Millard
-------------------------------------------------------------------------------
-- Description:
-- A basic viewer that orbits a target via rotating, panning and zooming.
-- A particular point in space is used as the target. 
-- Single touch rotates while pinching is used for zooming in and out.
-- Two finger drag is used for panning.
-- Attach to a camera's entity for basic first person controls:
-- i.e. scene.camera:add(OrbitViewer)
-------------------------------------------------------------------------------

OrbitViewer = class()

function OrbitViewer:init(entity, target, zoom, minZoom, maxZoom)
    self.entity = entity
    self.camera = entity:get(craft.camera)

    -- The camera's current target
    self.target = target or vec3(0,0,0)
    self.origin = self.target

    self.zoom = zoom or 5
    self.minZoom = minZoom or 1
    self.maxZoom = maxZoom or 20

    self.touches = {}
    self.prev = {}

    -- Camera rotation
    self.rx = 0
    self.ry = 0

    -- Angular momentum
    self.mx = 0
    self.my = 0

    self.sensitivity = 0.25

    touches.addHandler(self, 0, true) 
end

-- Project a 2D point z units from the camera
function OrbitViewer:project(p,z)
    local origin, dir = self.camera:screenToRay(p)   
    return origin + dir * z
end

-- Calculate overscroll curve for zooming
function scroll(x,s)
    return s * math.log(x + s) - s * math.log(s)
end

function OrbitViewer:update()
    if #self.touches == 0 then
        -- Apply momentum from previous swipe
        self.rx = self.rx + self.mx * DeltaTime
        self.ry = self.ry + self.my * DeltaTime
        self.mx = self.mx * 0.9
        self.my = self.my * 0.9 
        
        -- If zooming past min or max interpolate back to limits
        if self.zoom > self.maxZoom then
            local overshoot = self.zoom - self.maxZoom
            overshoot = overshoot * 0.9
            self.zoom = self.maxZoom + overshoot
        elseif self.zoom < self.minZoom then
            local overshoot = self.minZoom - self.zoom
            overshoot = overshoot * 0.9
            self.zoom = self.minZoom - overshoot
        end
        
    elseif #self.touches == 2 then
        self.entity.position = self.prev.target - self.entity.forward * self.zoom
        
        local mid = self:pinchMid()  
        local dist = self:pinchDist()
        
        local p1 = self:project(self.prev.mid, self.zoom)  
        local p2 = self:project(mid,self.zoom)
        
        self.target = self.prev.target + (p1-p2)  
        self.zoom = self.prev.zoom * (self.prev.dist / dist)     
        
        
        if self.zoom > self.maxZoom then
            local overshoot = self.zoom - self.maxZoom
            overshoot = scroll(overshoot, 10.0)
            self.zoom = self.maxZoom + overshoot
        elseif self.zoom < self.minZoom then
            local overshoot = self.minZoom - self.zoom
            overshoot = scroll(overshoot, 10.0)
            self.zoom = self.minZoom - overshoot
        end
        
    end  
    
    -- Clamp vertical rotation between -90 and 90 degrees (no upside down view)
    self.rx = math.min(math.max(self.rx, -90), 90)

    -- Calculate the camera's position and rotation
    local rotation = quat.eulerAngles(self.rx,  self.ry, 0)
    self.entity.rotation = rotation
    local t = vec3(self.target.x, self.target.y, self.target.z)
    self.entity.position = t + self.entity.forward * -self.zoom
end

-- Calculate the distance between the current two touches
function OrbitViewer:pinchDist()
    local p1 = vec2(self.touches[1].x, self.touches[1].y)
    local p2 = vec2(self.touches[2].x, self.touches[2].y)
    return p1:dist(p2)
end

-- Calculate the mid point between the current two touches
function OrbitViewer:pinchMid()
    local p1 = vec2(self.touches[1].x, self.touches[1].y)
    local p2 = vec2(self.touches[2].x, self.touches[2].y)
    return (p1 + p2) * 0.5
end

function OrbitViewer:touched(touch)
    if touch.tapCount == 2 then
        self.target = self.origin
    end
    
    -- Allow a maximum of 2 touches
    if touch.state == BEGAN and #self.touches < 2 then
        table.insert(self.touches, touch)
        if #self.touches == 2 then
            self.prev.target = vec3(self.target:unpack())
            self.prev.mid = self:pinchMid()
            self.prev.dist = self:pinchDist()
            self.prev.zoom = self.zoom
            self.mx = 0
            self.my = 0
        end        
        return true
    -- Cache updated touches
    elseif touch.state == MOVING then
        for i = 1,#self.touches do
            if self.touches[i].id == touch.id then
                self.touches[i] = touch
            end
        end
    -- Remove old touches
    elseif touch.state == ENDED or touch.state == CANCELLED then
        for i = #self.touches,1,-1 do
            if self.touches[i].id == touch.id then
                table.remove(self.touches, i)
                break
            end
        end
        
        if #self.touches == 1 then
            self.mx = 0
            self.my = 0
        end
    end
    
    -- When all touches are finished apply momentum if moving fast enough
    if #self.touches == 0 then
        self.mx = -touch.deltaY / DeltaTime * self.sensitivity
        self.my = -touch.deltaX / DeltaTime * self.sensitivity
        if math.abs(self.mx) < 70 then 
            self.mx = 0
        end
        if math.abs(self.my) < 70 then 
            self.my = 0
        end
    -- When only one touch is active simply rotate the camera
    elseif #self.touches == 1 then
        self.rx = self.rx - touch.deltaY * self.sensitivity
        self.ry = self.ry - touch.deltaX * self.sensitivity        
    end
    
    return false
end

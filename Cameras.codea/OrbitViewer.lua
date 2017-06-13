-- ** OrbitViewer **
-- A basic viewer that orbits a target via rotating, panning and zooming
-- A particular point in space is used as the target. 
-- Single touch rotates while pinching is used for zoom.
-- Two finger drag is used for panning.

OrbitViewer = class()

local IDLE = 1
local PIVOT = 2
local PINCHORPAN = 3
local PINCH = 4
local PAN = 5

function OrbitViewer:init(camera, target, zoom, minZoom, maxZoom)
    self.camera = camera
    self.target = target or vec3(0,0,0)
    self.origin = self.target
    self.zoom = zoom or 5
    self.minZoom = minZoom or 1
    self.maxZoom = maxZoom or 20
    self.touches = {}
    self.points = {}
    self.rx = 0
    self.ry = 0
    self.mx = 0
    self.my = 0
    self.state = IDLE
    touches.addHandler(self, 0, true) 
end

function OrbitViewer:isActive()
    return self.state ~= IDLE
end

function OrbitViewer:update()
    
    -- Apply momentum from previous swipe
    if self.state == IDLE then
        self.rx = self.rx + self.mx * DeltaTime
        self.ry = self.ry + self.my * DeltaTime
        self.mx = self.mx * 0.9
        self.my = self.my * 0.9   
    end   
    
    -- clamp vertical rotation between -90 and 90 degrees (no upside down view)
    self.rx = math.min(math.max(self.rx, -90), 90)
    local rotation = quat.eulerAngles(self.rx, 0, self.ry)
    self.camera.rotation = rotation
    local t = vec3(self.target.x, self.target.y, self.target.z)
    self.camera.position = t + self.camera.forward * -self.zoom
end

function OrbitViewer:pinchDist()
    local p1 = vec2(self.touches[1].x, self.touches[1].y)
    local p2 = vec2(self.touches[2].x, self.touches[2].y)
    return p1:dist(p2)
end

function OrbitViewer:pinchMid()
    local p1 = vec2(self.touches[1].x, self.touches[1].y)
    local p2 = vec2(self.touches[2].x, self.touches[2].y)
    return (p1 + p2) * 0.5
end

function OrbitViewer:cancel(resetMomentum)
    self.state = IDLE
    self.touches = {}
    self.points = {}
    if resetMomentum then
        self.mx = 0
        self.my = 0
    end
end

function OrbitViewer:allEnded()
    return #self.touches == 0
end

function OrbitViewer:touched(touch)
    if touch.tapCount == 2 then
        self.target = self.origin
    end
    
    if touch.state == BEGAN and #self.touches < 2 then
        table.insert(self.touches, touch)        
        table.insert(self.points, vec2(touch.x, touch.y)) 
    elseif touch.state == MOVING then
        for i = 1,#self.touches do
            if self.touches[i].id == touch.id then
                self.touches[i] = touch
            end
        end
    elseif touch.state == ENDED then
        for i = #self.touches,1,-1 do
            if self.touches[i].id == touch.id then
                table.remove(self.touches, i)
                break
            end
        end
    end
    
    if self.state == IDLE then
        if touch.state == BEGAN then
            self.mx = 0
            self.my = 0         
                       
            if #self.touches == 2 then
                self.state = PINCHORPAN
                self.pinch = {dist = self:pinchDist(), mid = self:pinchMid()}   
            end
        elseif touch.state == MOVING then
            local d = self.points[1] - vec2(self.touches[1].x, self.touches[1].y)            
            if d:len() > 3 then
                self.state = PIVOT
            end
        end
    end
        
    if self.state == PINCHORPAN then
        if touch.state == MOVING and #self.touches == 2 then
            local d1 = self.points[1] - vec2(self.touches[1].x, self.touches[1].y)
            local d2 = self.points[2] - vec2(self.touches[2].x, self.touches[2].y)
            
            if d1:len() > 5 and d2:len() > 5 then
                d1 = d1:normalize()
                d2 = d2:normalize()
                if d1:dot(d2) > 0.75 then
                    self.state = PAN
                else
                    self.state = PINCH
                end
                self.pinch = {dist = self:pinchDist(), mid = self:pinchMid()}   
            end
            
        elseif self:allEnded() then
            self:cancel()
        end
    end
    
    if self.state == PINCH then
        if touch.state == MOVING and #self.touches == 2 then           
            local dist = self:pinchDist() 
            local delta = (self.pinch.dist - dist) * 0.0015 * self.zoom * self.zoom
            self.zoom = math.min(math.max( self.zoom + delta, self.minZoom), self.maxZoom)
            self.pinch.dist = dist
        elseif self:allEnded() then
            self:cancel()
        end
    elseif self.state == PAN then
        if touch.state == MOVING and #self.touches == 2 then
            local mid = self:pinchMid() 
            local delta = (self.pinch.mid - mid) * 0.0025 * self.zoom            
            self.target = self.target + (self.camera.right * -delta.x + self.camera.up * delta.y)
            self.pinch.mid = mid
        elseif self:allEnded() then
            self:cancel(true)
        end
    elseif self.state == PIVOT then
        if touch.state == MOVING and touch.id == self.touches[1].id then
            self.rx = self.rx - touch.deltaY * 0.5
            self.ry = self.ry - touch.deltaX * 0.5
        elseif self:allEnded() then
            self.mx = -touch.deltaY / DeltaTime * 0.5
            self.my = -touch.deltaX / DeltaTime * 0.5
            if math.abs(self.mx) < 50 then 
                self.mx = 0
            end
            if math.abs(self.my) < 50 then 
                self.my = 0
            end
            self:cancel()
        end
    end
    
    return true
end

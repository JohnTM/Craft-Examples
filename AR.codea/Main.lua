-----------------------------------------
-- AR
-- Written by John Millard
-----------------------------------------
-- Description:
-- A basic Augmented Reality demo using ARKit internally.
-- Use scene.ar to setup and pause AR* mode.
--
-- * Please note that only devices with an A9 processor or above support AR.
--   This is an iOS 11 only feature.
-----------------------------------------
 

displayMode(FULLSCREEN)

function setup()
    -- Create a new craft scene
    scene = craft.scene()
    scene.sun:get(craft.light).intensity = 0.7

    if craft.ar.isSupported then
        -- Enable AR session
        scene.ar:run()

        -- Keep a list of detected planes
        planes = {}
        
        -- Option to turn plane detection on and off
        parameter.boolean("PlaneDetection", true, function(b)
            scene.ar.planeDetection = b
        end)
        
        -- Option to draw any detected planes using camera rendering mask
        parameter.boolean("DrawPlanes", true, function(b)
            local c = scene.camera:get(craft.camera)
            if b then
                c.mask = ~0
            else
                c.mask = 1
            end
        end)
        
        parameter.boolean("DrawPointCloud", true)

        local grid = readImage("Project:GridWhite")
        
        scene.ar.didAddAnchors = function(anchors)
            for k,v in pairs(anchors) do
                local p = scene:entity():add(Plane, v, grid)
                planes[v.identifier] = p
            end
        end
        
        scene.ar.didUpdateAnchors = function(anchors)
            for k,v in pairs(anchors) do
                local p = planes[v.identifier]
                p:updateWithAnchor(v)
            end
        end
        
        scene.ar.didRemoveAnchors = function(anchors)
            for k,v in pairs(anchors) do
                local p = planes[v.identifier]
                p.entity:destroy()
                planes[v.identifier] = nil
            end
        end   

        trackingState =
        {
            [AR_NOT_AVAILABLE] = "Not Available",
            [AR_LIMITED] = "Limited",
            [AR_NORMAL] = "Normal"
        }

        cross = image(16,16)
        setContext(cross)
        pushStyle()
        fill(255, 198, 0, 255)
        noStroke()
        rectMode(CENTER)
        rect(cross.width/2, cross.height/2, 3, cross.height)
        rect(cross.width/2, cross.height/2, cross.width, 3)
        popStyle()
        setContext()

    end

end

function update(dt)
    scene:update(dt)   
end

-- Called automatically by codea 
function draw()
    update(DeltaTime)

    -- Draw the scene
    scene:draw()	
    
    local status = nil
    if craft.ar.isSupported then
        status = trackingState[scene.ar.trackingState]
        
        if DrawPointCloud then
            local c = scene.camera:get(craft.camera)
            for k,v in pairs(scene.ar.points) do
                local p = c:worldToScreen(v)
                sprite(cross, p.x, p.y)
            end
        end
    else
        status = "AR Not Supported"
    end
    fill(255, 255, 255, 255)
    text(status, WIDTH/2, HEIGHT - 50)
    
end

function touched(touch)
    if craft.ar.isSupported and touch.state == BEGAN then
        local results = scene.ar:hitTest(
            vec2(touch.x, touch.y),
            AR_EXISTING_PLANE_CLIPPED)
        
        for k,v in pairs(results) do
            local e = scene:entity()
            local cube = e:add(Cube, v.position + vec3(0,0.5,0), 0.1)
            break
        end
    end
end

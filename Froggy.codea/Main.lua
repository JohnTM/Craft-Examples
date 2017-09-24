-----------------------------------------
-- Crosser
-- Written by John Millard
-----------------------------------------
-- Description:
-- A frogger style game that uses volumes made in the Voxel Editor project for 
-- models.
-----------------------------------------

-- Constants
TILE_SIZE = 1
ROAD_WIDTH = 25
ROAD_MIN_X = -12
ROAD_MAX_X = 12

-- Use this function to perform your initial setup
function setup()
    -- Use this to control which level to create
    --math.randomseed(1)
    
    scene = craft.scene()

    player = scene:entity():add(Player, vec3(0,0,6))
    
    -- Setup the camera for a 3/4 orthographic view
    camera = scene.camera:get(craft.camera)
    camera.ortho = true 
    camera.orthoSize = 5
    camera.entity.rotation = quat.eulerAngles(45, 25, 0)    
    scene.sun.rotation = quat.eulerAngles(-45, 65, 0)
    
    sections = {}

end

-- Adds a new road section generated at random
function addRoadSection(t)
    local e = scene:entity()
    
    if #sections > 0 then
        e.z = sections[#sections].entity.z + TILE_SIZE
    end
    
    local s = e:add(RoadSection, t)
    table.insert(sections, s)
    return s
end

-- Gets the road section that intersects with the provided bounds
function getSection(z)
    for k,v in pairs(sections) do
        if v.entity.z == math.floor(z) then
            return v
        end
    end
    return nil
end

-- Gets the tile that intersects with the provided bounds
function getTile(p)
    local s = getSection(p.z)
    if s then 
        return s:getTile(p.x)
    end
    return nil
end

-- Gets the car that intersects with the provided bounds
function getCar(bounds)
    local z = bounds.center.z
    for k,v in pairs(sections) do
        if v.cars and (v.entity.z == math.floor(z) or v.entity.z == math.ceil(z)) then
            for i,j in pairs(v.cars) do
                if bounds:intersects(j.bounds) then
                    return j
                end
            end
        end
    end
    return nil
end

-- Gets the log that intersects with the provided bounds
function getLog(bounds)
    local z = bounds.center.z
    for k,v in pairs(sections) do
        if v.logs and (v.entity.z == math.floor(z) or v.entity.z == math.ceil(z)) then
            for i,j in pairs(v.logs) do
                if bounds:intersects(j.bounds) then
                    return j
                end
            end
        end
    end
    return nil
end

-- Generates road sections in the visible area around the player, while destroying ones that are no longer visible
function generateRoadSections()
    local minRange = scene.camera.z - 5
    local maxRange = scene.camera.z + 30
    
    if #sections > 0 then
        if sections[#sections].entity.z < maxRange then
            local p = math.random()
            if p < 0.35 and p > 0.25 then
                addRoadSection(ROAD_GRASS)   
                for i=1,math.random(1,6) do         
                    addRoadSection(ROAD_RIVER)
                end
                addRoadSection(ROAD_GRASS)                   
            elseif p < 0.25 then
                addRoadSection(ROAD_HIGHWAY)
                addRoadSection(ROAD_HIGHWAY)
            else
                addRoadSection(ROAD_GRASS)
            end
        end
        
        if sections[1].entity.z < minRange then
            sections[1].entity:destroy()
            table.remove(sections, 1) 
        end
    else
        
        for i=1,10 do
            addRoadSection(ROAD_GRASS)            
        end
        addRoadSection(ROAD_HIGHWAY)            

    end    
end

function update(dt)
    scene:update(dt)

    generateRoadSections()
    
    -- Smoothly update the camera position as the player moves
    local pos = player.entity.worldPosition
    local cx = math.min( math.max( pos.x, ROAD_MIN_X + 4), ROAD_MAX_X - 14)
    
    scene.camera.z = scene.camera.z * 0.9 + (pos.z-5) * 0.1
    scene.camera.y = 10       
    scene.camera.x = scene.camera.x * 0.9 + cx * 0.1    

end

function draw()
    update(DeltaTime)
    scene:draw()
end

function touched(touch)
    player:touched(touch)
end

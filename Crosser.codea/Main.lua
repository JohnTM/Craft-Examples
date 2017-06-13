-- Crossey

-- Constants
TILE_SIZE = 1
ROAD_WIDTH = 25
ROAD_MIN_X = -12
ROAD_MAX_X = 12

-- Use this function to perform your initial setup
function setup()
    -- Use this to control which level to create
    --math.randomseed(1)
    
    player = craft.entity():add(Player, vec3(0,0,6))
    
    craft.camera.main.ortho = true 
    craft.camera.main.orthoSize = 5
    craft.scene.camera.rotation = quat.eulerAngles(45,0,25)    
    craft.scene.sun.rotation = quat.eulerAngles(-45,0,65)
    
    sections = {}

end

function addRoadSection(t)
    local e = craft.entity()
    
    if #sections > 0 then
        e.z = sections[#sections].entity.z + TILE_SIZE
    end
    
    local s = e:add(RoadSection, t)
    table.insert(sections, s)
    return s
end

function getSection(z)
    for k,v in pairs(sections) do
        if v.entity.z == math.floor(z) then
            return v
        end
    end
    return nil
end

function getTile(p)
    local s = getSection(p.z)
    if s then 
        return s:getTile(p.x)
    end
    return nil
end

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

function generateRoadSections()
    local minRange = craft.scene.camera.z - 5
    local maxRange = craft.scene.camera.z + 30
    
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

function update()
    generateRoadSections()
    
    local pos = player.entity.worldPosition
    local cx = math.min( math.max( pos.x, ROAD_MIN_X + 4), ROAD_MAX_X - 14)
    
    craft.scene.camera.z = craft.scene.camera.z * 0.9 + (pos.z-5) * 0.1
    craft.scene.camera.y = 10       
    craft.scene.camera.x = craft.scene.camera.x * 0.9 + cx * 0.1    

end

function draw()
 
end

function touched(touch)
    player:touched(touch)
end

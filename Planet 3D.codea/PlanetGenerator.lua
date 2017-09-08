-------------------------------------------------------------------------------
-- Planet Generator
-- Written by John Millard
-------------------------------------------------------------------------------
-- Description:
-- Generates a simple polygonal 3D planet and populates with some models from 
-- the Nature asset pack by Kenney.
-------------------------------------------------------------------------------
 
function setup()
    scene = craft.scene()
    scene.sky.material.sky = color(20, 19, 29, 255)
    scene.sky.material.horizon = color(22, 21, 28, 255)

    scene.sun:get(craft.light).intensity = 0.8
    scene.sun.parent = scene.camera
    scene.ambientColor = color(152, 152, 152, 255)
    
    local keyLight = scene:entity():add(craft.light, DIRECTIONAL)
    keyLight.entity.parent = scene.camera
    keyLight.entity.eulerAngles = vec3(-230,100,0)
    keyLight.intensity = 1.0
    keyLight.color = color(211, 203, 112, 255)

    modelStacks = 
    {
        {
            craft.model("CastleKit:towerSquareBase"),
            craft.model("CastleKit:towerSquareArch"), 
            craft.model("CastleKit:towerSquareRoof")       
        },
        {
            craft.model("CastleKit:towerBase"),
            craft.model("CastleKit:towerBase"),
            craft.model("CastleKit:towerTop"), 
        },
        {
            craft.model("CastleKit:towerBase"),
            craft.model("CastleKit:towerBase"),
            craft.model("CastleKit:towerTopRoof"), 
        },
        {
            craft.model("CastleKit:siegeCatapult"),    
        },
        {
            craft.model("CastleKit:siegeTower"),    
        },
        {
            craft.model("CastleKit:knightRed"),    
        }, 
        {
            craft.model("CastleKit:knightBlue"),    
        },
        {
            craft.model("CastleKit:sword"),    
        } 
    }
    
    -- Paramters that save between project runs
    parameter.color("Color",readProjectColor("Color") or color(27, 149, 46, 255), function(c)
        saveProjectColor("Color", c)
    end)
    saved(parameter.integer, "Seed", 0, 1000000, 0)
    saved(parameter.integer, "Detail", 1, 5, 3)
    saved(parameter.number, "Frequency", 0.1, 3.0, 1.0)
    saved(parameter.number, "Height", 0.0, 4.0, 0.4)
    saved(parameter.number, "Density", 0.0, 100.0, 10.0)
    saved(parameter.number, "ModelScale", 0.1, 1.0, 0.2)
    saved(parameter.number, "Spacing", 0.1, 10.0, 1)
    saved(parameter.number, "Force", 0.0, 200.0, 1.0)
    
    math.randomseed(Seed)
    
    viewer = scene.camera:add(OrbitViewer, vec3(0,0,0), 16, 2, 30)

    bodies = {}
    planet = makePlanet()
        
    for i = 1,90 do
        local s = makeStar()
        s.eulerAngles = vec3(math.random(0,360), math.random(0,360), math.random(0,360))
        s.position = -s.forward * 30
    end
    
    cloudAnchor = scene:entity()
    cloudRotation = 0
    
    clouds = {}
    
    local spawnShip = true
    
    for i = 1,10 do
                
        local c = scene:entity()
        c.parent = cloudAnchor
        
        for j = 1,40 do
            c.eulerAngles = vec3(math.random(0,360), math.random(0,360), math.random(0,360))
            c.position = c.up * 5
            
            local dist = 0
            local done = true
            
            for k,v in pairs(clouds) do
                local d1 = c.position:normalize()
                local d2 = v.position:normalize()
                local angle = math.acos(d1:dot(d2))
                if angle < math.pi / 4 then
                    done = false 
                    break
                end
            end
            
            if done then
                break
            end
        end
        
        table.insert(clouds, c)
        
        if spawnShip then
            spawnShip = false
            
            c.eulerAngles = vec3(150,45,0)
            c.position = c.up * 5
            local ship = scene:entity()
            ship.parent = c
            ship.position = vec3(0,0,0)
            ship.model = craft.model("Watercraft:watercraftPack_007")
            ship.eulerAngles = vec3(180,220,180)
            ship.scale = vec3(0.2, 0.2, 0.2)
            
        else      
            local r1 = math.random() * 0.3 + 0.2
            
            local p1 = makeCloud(r1)
            local p2 = makeCloud(math.random() * 0.2 + 0.15)
            local p3 = makeCloud(math.random() * 0.2 + 0.15)
            
            p1.parent = c
            p1.position = vec3(0,0,0)
            p2.parent = c
            p2.position = vec3(r1, -r1*0.25, 0)
            p3.parent = c 
            p3.position = vec3(-r1, -r1*0.25, 0)   
        end
    end

    printExplanation()
end

function checkClear(objects, p, r)
    for k,v in pairs(objects) do
        local dist = p:dist(v)
        if dist < r then
            return false
        end
    end
    return true
end

function makeCloud(radius)
    local cloud = scene:entity()
    cloud.model = craft.model.icosphere(radius, 1, true)
    
    local noise = craft.noise.rigidMulti()
    noise.frequency = 1.5
    noise.seed = Seed + math.random(1,100)
    
    local p = vec3()
    local r = vec3()
    local m = cloud.model
    
    for i = 1, m.vertexCount do        
        p:set(m:position(i))
        
        local n = noise:getValue(p.x, p.y, p.z)
        
        r:set(p:unpack()):mul(n * radius * 0.125 / r:len())
        p:add(r)
        --p.z = p.z * 0.5 
        m:position(i, p)
   end     
    
    cloud.material = craft.material("Materials:Standard")
    cloud.material.roughness = 0.7

    return cloud
end

function makeStar()
    local star = scene:entity()
    star.model = craft.model.icosphere(math.random() * 0.1 + 0.1, 0, true)
    star.material = craft.material("Materials:Basic")
    return star
end

-- Generate a 3D planet
function makePlanet()

    local planet = scene:entity()
    local model = craft.model.icosphere(3, Detail, true)
    local chance = 1.0 / model.vertexCount
    
    local points = {}
    
    local noise = craft.noise.rigidMulti()
    noise.frequency = Frequency
    noise.seed = Seed
    
    local p = vec3()
    local r = vec3()
    for i = 1, model.vertexCount do        
        p:set(model:position(i))
        
        local n = noise:getValue(p.x, p.y, p.z)
        
        r:set(p:unpack()):mul(n * Height / r:len())
        p:add(r)
        
        model:position(i, p)
        
        if (i-1) % 3 == 0 then
            local c = 255 * (0.8 + math.abs(n) * 0.2)
            c = color(c,c,c,1.0)
            model:color(i, c)
            model:color(i+1, c)
            model:color(i+2, c)
        end
        
        if Density > 0 then
            if math.random() < chance * Density and checkClear(points, p, Spacing)  then      
                local detail = addDetailModel(p, 
                                              p:normalize(),                  
                                              modelStacks[math.random(1, #modelStacks)])   
                if detail then
                    table.insert(points, detail.t.position)
                    table.insert(bodies, detail)
                end
            end
        end
    end
    
    planet.model = model
    planet.material = craft.material("Materials:Standard")
    planet.material.diffuse = Color
    planet.material.roughness = 0.75
    
    planet:add(craft.rigidbody, STATIC)
    
    return planet
end

function calcTangent(n)
    local c1 = vec3(0,0,1):cross(n)
    local c2 = vec3(0,1,0):cross(n)
    if c1:len() > c2:len() then
        return c1
    else
        return c2
    end
end

function addDetailModel(position, normal, parts)
    local pivot = scene:entity()
    pivot.position = position - normal * 0.05

    -- align with surface
    pivot.rotation = quat.fromToRotation(vec3(0,1,0), normal)
    
    if math.random() < 0.1 then
        local object = createCastle()
        object.parent = pivot
        object.scale = vec3(0.03, 0.03, 0.03)
    else    
        local y = 0
        for k,v in pairs(parts) do
            local object = scene:entity()
            object.model = v
            
            local s = 0.03
            local bounds = object.model.bounds
            object.parent = pivot
            object.position = vec3(-bounds.center.x * s, y, -bounds.center.z * s)
            object.scale = vec3(s, s, s) 
            y = y + bounds.size.y*s       
        end        
    end

    return {t = pivot}
end

function update(dt)
    scene:update(dt)
    
    cloudRotation = cloudRotation + DeltaTime * 5
    cloudAnchor.eulerAngles = vec3(cloudRotation, 0, 0) 
end

function draw()
    update(DeltaTime)

    scene:draw()
end

function printExplanation()
    output.clear()
    print("Here we generate a planet using noise and an IcoSphere mesh.")
    print("Ico-spheres are made entirely out of equal sized triangles.")
    print("We use noise.rigidMulti() to displace each vertex based on density.")
    print("We also color triangles based on density to vary surface colors.")
    print("Models are placed on the surface and orientated based on normals.")
end



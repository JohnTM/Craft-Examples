-- Planet Generator
 
function setup()
    scene = craft.scene()

    scene.sun:get(craft.light).intensity = 0.6
    
    exclude = readText("Project:exclude") and json.decode(readText("Project:exclude")) or {}
    
    parameter.color("Color",readProjectColor("Color") or color(27, 149, 46, 255), function(c)
        saveProjectColor("Color", c)
    end)
    saved(parameter.integer, "Seed", 0, 1000000, 0)
    saved(parameter.integer, "Detail", 1, 5, 3)
    saved(parameter.number, "Frequency", 0.1, 3.0, 1.0)
    saved(parameter.number, "Height", 0.0, 4.0, 0.4)
    saved(parameter.number, "Density", 0.0, 1000.0, 10.0)
    saved(parameter.number, "ModelScale", 0.1, 1.0, 0.2)
    saved(parameter.number, "Spacing", 0.1, 10.0, 1)
    saved(parameter.number, "Force", 0.0, 200.0, 1.0)
    
    math.randomseed(Seed)
    
    models = assetList("Nature", "models")
    
    viewer = scene.camera:add(OrbitViewer, vec3(0,0,0), 10, 2, 20)

    bodies = {}
    planet = makePlanet()
    
    parameter.boolean("fog", scene.fogEnabled, function(b) scene.fogEnabled = b end)
    parameter.color("fogColor", scene.fogColor, function(c) scene.fogColor = c end)
    parameter.number("fogNear", 0, 100, scene.fogNear, function(n) scene.fogNear = n end)    
    parameter.number("fogFar", 0, 100, scene.fogFar, function(n) scene.fogFar = n end)    
end

function cleanup()
    touches.removeHandler(viewer)
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

function makePlanet()

    local planet = scene:entity()
    local mr = planet:add(craft.renderer, craft.mesh.icosphere(3, Detail, true))
    local chance = 1.0 / mr.mesh.vertexCount
    
    local points = {}
    
    local noise = craft.noise.rigidMulti()
    noise.frequency = Frequency
    noise.seed = Seed
    
    local p = vec3()
    local r = vec3()
    for i = 1, mr.mesh.vertexCount do        
        p:set(mr.mesh:position(i))
        
        local n = noise:getValue(p.x, p.y, p.z)
        
        r:set(p:unpack()):mul(n * Height / r:len())
        p:add(r)
        
        mr.mesh:position(i, p)
        
        if (i-1) % 3 == 0 then
            local c = 255 * (0.60 + math.abs(n) * 0.4)
            c = color(c,c,c,1.0)
            mr.mesh:color(i, c)
            mr.mesh:color(i+1, c)
            mr.mesh:color(i+2, c)
        end
        
        if Density > 0 then
            if math.random() < chance * Density and checkClear(points, p, Spacing)  then      
                local detail = addRandomDetailModel(p,r)   
                table.insert(points, detail.t.position)
                table.insert(bodies, detail)
            end
        end
    end
    
    mr.material = craft.material("Materials:Specular")
    mr.material.diffuse = Color
    mr.material.specular = color(127, 127, 127, 255)
    mr.material.shininess = 10
    
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

function addRandomDetailModel(position, normal)
    local pivot = scene:entity()
    pivot.position = position - normal * 0.05
    
    -- calculate tangent from normal
    local tangent = calcTangent(normal)

    -- align with surface
    pivot.rotation = quat.fromToRotation(vec3(0,1,0), normal)
    
    local model = scene:entity()
    
    local mnum = 1
    while true do
        mnum = math.random(1,#models) 
        if not exclude[models[mnum]] then
            break
        end
    end  
     
    local mr = model:add(craft.renderer, craft.mesh("Nature:"..models[mnum]))
    local bounds = mr.mesh.bounds
    local s = ModelScale
    model.parent = pivot
    model.position = vec3(-bounds.center.x * s, 0, -bounds.center.z * s)
    model.scale = vec3(s, s, s)
   
    local bs = bounds.size * s
    --pivot:add(craft.rigidbody, DYNAMIC)
    --pivot:add(craft.shape.box, bs, vec3(0, bs.y * 0.5, 0))
    
    return {t = pivot, rb = pivot:get(Rigidbody)}
end

function update(dt)
    scene:update(dt)

    scene.sky:get(craft.renderer).material.skyColor = scene.fogColor
    scene.sky:get(craft.renderer).material.horizonColor = scene.fogColor
end

function draw()
    update(DeltaTime)

    scene:draw()
end

function PrintExplanation()
    output.clear()
    print("Here we generate a planet using noise and an IcoSphere mesh.")
    print("Ico-spheres are made entirely out of equal sized triangles.")
    print("We use noise.rigidMulti() to displace each vertex based on density.")
    print("We also color triangles based on density to vary surface colors.")
    print("Models are placed on the surface and orientated based on normals.")
end



-- Models

-- Use this function to perform your initial setup
function setup()
    PrintExplanation()
    
    scene = craft.scene()
    
    AssetPack = "RacingKit"
    
    assets = assetList(AssetPack, "models")
    
    -- Setup camera and lighting
    viewer = scene.camera:add(OrbitViewer, vec3(0,0,0), 30, 20, 100)
    scene.ambientColor = color(61, 61, 61, 255)
    scene.sun:get(craft.light).intensity = 0.75
    scene.sun.rotation = quat.eulerAngles(25,0,125)
    
     
    models = {}
    
    local x, z = 0,0
    for k,v in pairs(assets) do    
        local model = scene:entity()
        local mr = model:add(craft.renderer)  

        mr.mesh = craft.mesh(AssetPack..":"..v)
        local bounds = mr.mesh.bounds
        
        model.x = x - bounds.offset.x
        model.z = z
        x = x + bounds.size.x + 1
        
        table.insert(models, model)
    end

    parameter.integer("ModelNumber", 1, #models, 1, function(n)
    end)
    
    parameter.action("Next",function()
        ModelNumber = math.min(ModelNumber + 1, #models)
    end)
    
    parameter.boolean("ShowBounds", false)
    
    parameter.watch("assets[ModelNumber]")
    
end

function update(dt)
    scene:update(dt)

    if ShowBounds then
        for k,v in pairs(models) do    
            local b = v:get(craft.renderer).mesh.bounds
            b2 = craft.bounds(b.min, b.max)
            b2:translate(v.position)
            debug:bounds(b2, color(255,255,255,255))
        end
    end
    
    local m = models[ModelNumber]
    local b = m:get(craft.renderer).mesh.bounds
    viewer.target = m.position + b.center
end
    

-- This function gets called once every frame
function draw()
    update(DeltaTime)
    
    scene:draw()
end

function PrintExplanation()
    output.clear()
    print("Loading models is easy, simply create an entity and add a renderer component.")
    print("Set the mesh using craft.mesh(asset)")
    print("In this example we have used assetList to get all models from the nature pack")
    print("Models will try to load a material if there is one, otherwise a blank material will be used.")
end




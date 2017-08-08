-------------------------------------------------------------------------------
-- Models
-- Written by John Millard
-------------------------------------------------------------------------------
-- Description:
-- Domonstrates model loading in Craft.
-------------------------------------------------------------------------------

Tag = class()

function Tag:init(entity, name)
    self.entity = entity
    self.name = name
end

-- Use this function to perform your initial setup
function setup()
    PrintExplanation()
    
    scene = craft.scene()
    
    AssetPack = "RacingKit"
    
    assets = assetList(AssetPack, "models")
    
    -- Setup camera and lighting
    viewer = scene.camera:add(OrbitViewer, vec3(0,0,0), 30, 20, 200)
    scene.ambientColor = color(61, 61, 61, 255)
    scene.sun:get(craft.light).intensity = 0.75
    scene.sun.rotation = quat.eulerAngles(25,0,125)
    scene.sky.active = false
    
     
    models = {}   
    for k,v in pairs(assets) do    
        local model = scene:entity()
        
        local mr = model:add(craft.renderer)  
        mr.mesh = craft.mesh(AssetPack..":"..v)

        -- Tag the model for later
        model:add(Tag, AssetPack..":"..v)
        
        table.insert(models, model)
    end
    
    local x, z = 0,0
    local maxRowDepth = 0
    
    for k,model in pairs(models) do    
        local mr = model:get(craft.renderer)  

        local bounds = mr.mesh.bounds
        
        model.x = x - bounds.max.x
        model.z = z - bounds.offset.z
        x = x - bounds.size.x - 2
        
        maxRowDepth = math.max(maxRowDepth, bounds.size.z)
        
        if x < -120 then
            x = 0
            z = z + maxRowDepth + 2
            maxRowDepth = 0
        end
    end

    parameter.integer("ModelNumber", 1, #models, 1, function(n)
        updateViewer()
    end)
    
    parameter.action("Next",function()
        ModelNumber = math.min(ModelNumber + 1, #models)
        updateViewer()
    end)
    
    parameter.boolean("ShowBounds", false)
    
    parameter.watch("assets[ModelNumber]")
    
end

function updateViewer()
    local m = models[ModelNumber]
    local b = m:get(craft.renderer).mesh.bounds
    viewer.target = m.position + b.center
end

function update(dt)
    scene:update(dt)

    if ShowBounds then
        for k,v in pairs(models) do    
            local b = v:get(craft.renderer).mesh.bounds
            b2 = bounds(b.min, b.max)
            b2:translate(v.position)
            scene.debug:bounds(b2, color(255,255,255,255))
        end
    end
    
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




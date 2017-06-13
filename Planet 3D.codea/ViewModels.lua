-- Use this function to perform your initial setup
function setup()
    models = assetList("Nature", "models")
    
    viewer = craft.scene.camera:add(OrbitViewer)
    
    model = craft.entity()
    mr = model:add(craft.renderer)  
    
    saved(parameter.integer,"ModelNumber", 1, #models, 1, function(n)
        loadModel(n)
    end)
    
    parameter.action("Next",function()
        ModelNumber = math.min(ModelNumber + 1, #models)
        loadModel(ModelNumber)
    end)
    
    exclude = readText("Project:exclude")
    if exclude then
        exclude = json.decode(exclude)
    else
        exclude = {}
    end
    
    parameter.action("Exclude", function()
        exclude[models[ModelNumber]] = not (exclude[models[ModelNumber]] or false)
        saveText("Project:exclude", json.encode(exclude))
    end)
    
    parameter.watch("models[ModelNumber]")
    parameter.watch("exclude[models[ModelNumber]] and 'Yes' or 'No'")
end

function loadModel(modelNumber)
    mr.mesh = craft.mesh("Nature:"..models[modelNumber])
    local bounds = mr.mesh.bounds
    model.position = vec3(-bounds.center.x,0,-bounds.center.z) 
end

function update() 
end

-- This function gets called once every frame
function draw()
end

function PrintExplanation()
    output.clear()
    print("Loading models is easy, simply create an entity and add a MeshRenderer.")
    print("Set the mesh using Mesh.Model(asset)")
    print("In this example we have used assetList to get all models from the nature pack")
    print("Models will try to load a material if there is one, otherwise a blank material will be used.")
end



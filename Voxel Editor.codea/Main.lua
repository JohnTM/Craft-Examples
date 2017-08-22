-- Voxel Test
displayMode(FULLSCREEN)

-- Use this function to perform your initial setup
function setup()
    scene = craft.scene()
    
    -- Generate icon for solid block type (using Block Library:BlockPreview)
    solid = scene.voxels.blocks.Solid
    solid.static.icon = generateBlockPreview(solid)

    scene.ambientColor = color(77, 77, 77, 255)
    scene.sky.active = false

    -- Create a volume for rendering our voxel model
    volumeEntity = scene:entity()
    volume = volumeEntity:add(craft.volume, 5, 5, 5)
    sx, sy, sz = volume:size()

    -- Setup camera and lighting
    scene.sun.rotation = quat.eulerAngles(  25,  0, )
    
    -- Helper class for interactive camera
    viewer = scene.camera:add(OrbitViewer, vec3(sx/2 + 0.5, sy/2 + 0.5, sz/2 + 0.5), 20, 5, 40)
    viewer.rx = 45
    viewer.ry = -45

    -- Tool handles editing the voxel volume
    tool = Tool()  
        
    toolMode = TOOL_ADD
    toolType = TOOL_TYPE_BOX
    toolColor = color(255,255,255,255)
    mirror = {x = false, y = false, z = false}
    snapshots = {}

    touches.addHandler(tool, -1, false)

    grids = 
    {
        bottom = Grid(vec3(0,1,0), vec3(0,0,0), 1, vec3(sx,sy,sz), true),
        top = Grid(vec3(0,-1,0), vec3(0,sy,0), 1, vec3(sx,sy,sz), false),
        left = Grid(vec3(1,0,0), vec3(0,0,0), 1, vec3(sx,sy,sz), false),
        right = Grid(vec3(-1,0,0), vec3(sx,0,0), 1, vec3(sx,sy,sz), false),
        front = Grid(vec3(0,0,1), vec3(0,0,0), 1, vec3(sx,sy,sz), false),
        back = Grid(vec3(0,0,-1), vec3(0,0,sz), 1, vec3(sx,sy,sz), false)
    }
    
    toolPanel = UI.Panel(0,HEIGHT-40,WIDTH,40)
    toolPanel.fill = color(55, 56, 56, 255)

    toolButtons = {}
    swatches = {}
    
    for k,v in pairs(COLORS) do
        addSwatch(v)        
    end
    
    shelf = Shelf()

    addSaveParameters()
    
    saveSnapshot()
end

function addSaveParameters()
    parameter.color("Color", color(255,255,255), function(c)
        toolColor = c
    end)
    
    parameter.text("Filename", readProjectData("filename") or "untitled",
    function(t)
        saveProjectData("filename", Filename)
    end)

    parameter.integer("SizeX", 5, 50, 12, function(s)
        shouldResize = true
    end)

    parameter.integer("SizeY", 5, 50, 12, function(s)
        shouldResize = true
    end)

    parameter.integer("SizeZ", 5, 50, 12, function(s)
        shouldResize = true
    end)
        
    parameter.action("Load", function()
        volume:load("Documents:"..Filename)
        sx, sy, sz = volume:size()
        SizeX = sx
        SizeY = sy
        SizeZ = sz
        viewer.target = vec3(sx/2 + 0.5, sy/2 + 0.5, sz/2 + 0.5)
        updateGrid()
        saveSnapshot()
    end)
    
    parameter.action("Save", function() 
        volume:save("Documents:"..Filename)
    end)
    
end

function updateGrid()
    grids.right.origin.x = sx
    grids.back.origin.z = sz
    grids.top.origin.y = sy
    for k,v in pairs(grids) do
        v.size.x = sx
        v.size.y = sy
        v.size.z = sz
        v:modified()
    end
end

function resizeVolume()
    if volume and SizeX and SizeY and SizeZ then
        volume:resize(SizeX, SizeY, SizeZ)

        sx, sy, sz = volume:size()
        updateGrid()
        
        viewer.target = vec3(sx/2 + 0.5, sy/2 + 0.5, sz/2 + 0.5)
        viewer.origin = viewer.target

        shouldResize = false
        saveSnapshot()
    end
end

function addSwatch(c)
    local spacing = 10
    local rightX = 35

    if #swatches > 0 then
        rightX = swatches[#swatches].frame.x + swatches[#swatches].frame.w + spacing
    end

    local swatch = UI.Swatch(rightX, 5, 30, 30, c)    

    if c == toolColor then
        swatch.selected = true
    end

    swatch.action = function(s) 
        for k,v in pairs(swatches) do
            v.selected = false
        end

        s.selected = true
        toolColor = s.color
        Color = toolColor        
    end

    toolPanel:addChild(swatch)
    table.insert(swatches, swatch)
end

function update(dt) 
    scene:update(dt)
       
    for k,v in pairs(grids) do
        v:update()
    end

    if shouldResize then
        resizeVolume()
    end
    
    local r = shelf:right() / WIDTH
    scene.camera:get(craft.camera):viewport(r,0,1.0-r,1)
end

-- Perform 2D drawing (UI)
function draw()
    update(DeltaTime)
    
    scene:draw()
    
    toolPanel:update()
    toolPanel:draw()
    
    shelf:update()
    shelf:draw()
end

-- Helper function for voxel raycasts
function raycast(x,y, sides)
    local origin, dir = scene.camera:get(craft.camera):screenToRay(vec2(x, y))
    
    local blockID = nil
    local blockCoord = nil
    local blockFace = nil

    -- The raycast function will go through all voxels in a line starting at a given origin
    -- heading in the specified direction. The traversed voxels are passed to a callback
    -- function which is given the coordinate, id and surface normal (face).
    -- Once true is returned, the raycast will stop
    volume:raycast(origin, dir, 128, function(coord, id, face)
        if id and id ~= 0 then
            blockID = id
            blockCoord = coord
            blockFace = face
            return true
        elseif id == nil then
            
            if coord.x >= -1 and coord.x <= sx and 
               coord.y >= -1 and coord.y <= sy and
               coord.z >= -1 and coord.z <= sz then
                
                for k,v in pairs(grids) do
                    if v.enabled and v:isVisible() then
                        local d = math.abs(v.normal:dot(coord + face - v.origin))
                        if d == 0 then
                            blockID = 0
                            blockCoord = coord
                            blockFace = face  
                            return true   
                        end
                    end
                end
            end
            
        end
        return false
    end)

    return blockCoord, blockID, blockFace
end

-- Restore the previous snapshot (i.e. undo)
function undo()
    if #snapshots > 1 then
        table.remove(snapshots, #snapshots)
        volume:loadSnapshot(snapshots[#snapshots])
    end
end

-- TODO
function redo()
    
end

-- Save a snapshot of the current voxel volume (for editing and undo)
function saveSnapshot()
    table.insert(snapshots, volume:saveSnapshot())      
end




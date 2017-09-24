------------------------------------------
-- Planet Generator
-- Written by John Millard
------------------------------------------
-- Description:
-- This is a highly advanced example showing how to generate an entire planet 
-- using grayscale brushes to splat simple shapes together into a spherical
-- landscape.
--
-- Step 1: Generate random splats on the surface of a small sphere (flat textures)
-- Step 2: Orient splats to face the center of the sphere
-- Step 3: Setup a camera with a 90 degree fov* 
-- Step 4: Render all 6 faces of a cubemap with the camera into separate images for height map
-- Step 5: Use a ramp texture to generate surface colors based on elevation in height map
-- Step 6: Generate a normal map by using the height map pixel gradient
-- Step 7: Load separate images into cubemaps for height, color and normals
-- Step 8: Generate a subdivided cube and apply the cubemaps using a custom material
--
-- Notes:
-- A slightly greater than 90 degree fov is used for cubemap generation.
-- This allows some padding used in normal map generation, which is then stripped off later.
--
-- There are several custom shaders used by this example
-- Atmosphere and StandardSphere are modifications of the normal Basic and Standard shaders. 
-- StandardSphere uses cubemaps instead of standard textures for all texture inputs.
-- Displacement maps are used to purturb the surface so the underlying mesh is a simple sphere
-- 
-- The water and atmosphere meshes are icospheres
--
-- The pixelation (banding) on the normal maps is caused by issues with limited floating point
-- precision in the height map. This may be fixed in future if we add support for 16 bit floating
-- point images.
--
-- Surface textures have limited detail. You cannot simply increase the size of the textures for
-- close up (i.e. on the surface) rendering as you will quickly run out of GPU memory.
-- In order to support travelling to the surface of the planet an intellegent caching and terrain
-- generation system would need to be created (think quad-trees). This may be added in the future.
------------------------------------------

-- The radius of the main planet
PLANET_RADIUS = 200

function setup()   
    -- Create the craft scene
    scene = craft.scene()
    camera = scene.camera:get(craft.camera)

    -- Get the sky material and adjust color to black
    skyMat = scene.sky.material
    skyMat.sky = color(0, 0, 0, 255)
    skyMat.horizon = color(0, 0, 0, 255)
    
    -- Create the generators for the planet and moon
    -- These are attached to an entity for rendering purposes
    gen = scene:entity():add(PlanetGenerator, PLANET_RADIUS, 514)
    moonGen = scene:entity():add(PlanetGenerator, PLANET_RADIUS, 128)
    
    -- Use the OrbitViewer for basic camera control
    viewer = scene.camera:add(OrbitViewer, vec3(0,0,0), 800, 300, 1000)
    
    -- CubeMapViewer is used for visually inspecting the generated normal maps
    cmv = CubeMapViewer(gen)
    
    -- Manual Regeneration
    parameter.integer("Seed", 0, 1000, 121)
    parameter.action("Generate", function() 
        planet:generate(gen, planets.earth)
        moon:generate(moonGen, planets.moon)
    end)
    parameter.boolean("ShowCubeMap", false)
    parameter.integer("Map", 1,3,1)
    parameter.number("Displacement", 0, 50/200.0, 35/200.0)

    -- The planet entity
    planet = scene:entity():add(Planet, PLANET_RADIUS, 64, 4, true)  

    -- The moon entity
    moon = scene:entity():add(Planet, PLANET_RADIUS / 6, 32, 4)  
    
    -- A frog for some reason :O
    frog = createFrog()
end

-- Create and load a simple frog voxel model
function createFrog()
    local frog = scene:entity()
    frog.parent = moon.entity
    frog.x = PLANET_RADIUS / 6 + 15
    frog.scale = vec3(1,1,1)
    
    local model = scene:entity()
    model.parent = frog

    local vm = model:add(craft.volume, 1,1,1)
    vm:load("Documents:Frog")
    local sx, sy, sz = vm:size()
    model.x = -sx/2
    model.y = -sy/2
    model.z = -sz/2

    return frog;
end

-- Update the scene
function update()
    scene:update(DeltaTime)

    -- For now the generator may override the basic scene lighting so we set it again here
    scene.ambientColor = color(80, 55, 84, 255)
    scene.sun:get(craft.light).intensity = 0.9
    scene.sun.rotation = quat.eulerAngles(25, 95, 0)

    camera.nearPlane = 10
    camera.farPlane = 4000        
    
    local orbit = ElapsedTime * 12
    moon.entity.rotation = quat.eulerAngles(0,  orbit, 0)    
    moon.entity.position = moon.entity.forward * PLANET_RADIUS * 2.0
    
    frog.rotation = quat.eulerAngles(0,  ElapsedTime * 180/2, 0)
    frog.position = frog.forward * (PLANET_RADIUS / 6 + 15)
end

-- This function gets called once every frame
function draw()    
    -- Handle craft scene updates
    update();

    -- Draw the craft scene (no need to call background())
    scene:draw()

    -- Optionally display the generated cubemap
    if cmv and ShowCubeMap then
        cmv:draw() 
    end
end
    


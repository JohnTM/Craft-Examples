-------------------------------------------------------------------------------
-- Stacker
-- Written by John Millard
-------------------------------------------------------------------------------
-- Description:
-- A basic 3D stacking game.
-- Learn about basic shapes, physics and camera usage.
-------------------------------------------------------------------------------

displayMode(FULLSCREEN)

STATE_MENU = 1
STATE_PLAYING = 2
STATE_OVER = 3
X = 1
Z = 3

PERFECT_THRESHOLD = 0.25 -- how close a drop needs to be to be considered perfect
PLATFORM_SIZE = {10,1,10} -- initial size of the stack

function setup()
    scene = craft.scene()
    
    -- Setup lighting and camera
    scene.ambientColor = color(127, 127, 127, 255)
    scene.sun.rotation = quat.eulerAngles(  25,  0, )
    scene.sun:get(craft.light).intensity = 0.75
    
    -- Adjust the skybox
    local skyMat = scene.sky:get(craft.renderer).material
    skyMat.horizonColor = color(0, 0, 0, 255)
    
    -- Use a fixed angle and orthographic view
    camera = scene.camera:get(craft.camera)
    camera.ortho = true
    camera.orthoSize = 14
    camera.entity.rotation = quat.eulerAngles(  45,  0, )

    -- Game state
    state = STATE_MENU
    prevDirection = Z
    direction = X -- direction the current platform is moving in
    axes = {vec3(1,0,0), vec3(0,1,0), vec3(0,0,1)} -- mapping from direction to axis
    size = vec3(table.unpack( PLATFORM_SIZE ))  -- current size of platform
    score = 0 -- initial score
    perfectCombo = 0
    stack = {} -- list of platforms
    
    -- Use perlin noise for block colors (with randomised start color)
    seed = math.random(0,1000000000)
    colorNoise = noiseFunc(seed)
    
    -- Generate stack base (fade from black)
    local baseHeight = 20
    local baseColor = color(0, 0, 0, 255)
    local baseColor2 = getColor(baseHeight-1)
    for i = 1,baseHeight do
        local c = baseColor:mix(baseColor2, 1.0 - (i-1.0)/(baseHeight-1))
        local base = scene:entity():add(Platform, vec3(0,i-1,0), size, c, false, direction)
        table.insert(stack, base)
    end
    
    height = baseHeight
    
    comboEffectMaterial = craft.material("Materials:Specular")
    comboEffectMaterial.blendMode = ADDITIVE
    comboEffectMaterial.emissive = color(255, 255, 255, 255)         
end

function update(dt)
    scene:update(dt)
    
    local target = vec3(0,height,0) - camera.entity.forward * 30
    
    if state == STATE_MENU then
        --target.y = target.y + 10 
    elseif state == STATE_OVER then
        target.y = height/2 + 20
        camera.orthoSize = camera.orthoSize * 0.95 + math.max(height * 0.5, 14) * 0.05
    end
    
    camera.entity.position = camera.entity.position * 0.95 + target * 0.05
end

function draw()  
    update(DeltaTime)
    
    scene:draw()
    
    if state == STATE_MENU then
        pushStyle()
        font("SourceSansPro-Bold")
        fontSize(60)
        textAlign(CENTER)
        fill(255, 255, 255, 255)
        text("STACKER", WIDTH/2, HEIGHT * 0.75)
        popStyle()
    elseif state == STATE_PLAYING then
        pushStyle()
        font("SourceSansPro-Bold")
        fontSize(60)
        textAlign(CENTER)
        fill(255, 255, 255, 255)
        text(score, WIDTH/2, HEIGHT * 0.75)
        popStyle()        
    end

end

function getColor(y)
    local r, g, b = hsvToRgb(colorNoise(y), 0.6, 0.8)
    return color(r,g,b)
end

function applyCurrentPlatform()
    local current = stack[#stack]
    local success, perfect = current:drop(stack[#stack-1])
      
    if perfect then
        current:spawnComboEffect()
    end
      
    height = height + 1 
    prevDirection = direction
    direction = (direction == X) and Z or X
    size[prevDirection] = current.size[prevDirection]
    
    return success, perfect
end

function spawnNextPlatform()
    local nextColor = getColor(height)
    
    local spawnPos = axes[direction] * -10 + vec3(0,1,0) * height
    spawnPos[prevDirection] = stack[#stack].entity.position[prevDirection]
    
    local base = scene:entity():add(Platform,
                                    spawnPos, 
                                    size, 
                                    nextColor,
                                    true,
                                    direction, 
                                    20)
    table.insert(stack, base)
end

function touched(touch)
    if state == STATE_MENU then
        if touch.state == BEGAN then
            state = STATE_PLAYING
            spawnNextPlatform()
        end        
    elseif state == STATE_PLAYING then
        if touch.state == BEGAN then
            local success, perfect = applyCurrentPlatform()
            if success then
                if perfect then
                    perfectCombo = perfectCombo + 1
                else
                    perfectCombo = 0
                end
                
                score = score + 1
                spawnNextPlatform()
            else
                state = STATE_OVER
            end
        end        
    end
end


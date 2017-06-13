function generateTerrain(chunk)
    cx, cy, cz = chunk:size()
    
    chunkGlobal = chunk
    
    SEA_LEVEL = 40
    
    -- block types as noise sources
    air = craft.noise.const(0)
    dirt = craft.noise.const(chunk:blockID("Dirt"))    
    stone = craft.noise.const(chunk:blockID("Stone"))    
    grass = craft.noise.const(chunk:blockID("Grass"))       
    water = craft.noise.const(chunk:blockID("Water"))       
    sand = craft.noise.const(chunk:blockID("Sand"))           
    
    rmap = riverMap()
    
    local n = split(air, riverEdge(grass, sand), SEA_LEVEL)
    n = split(n, dirt, SEA_LEVEL-1)   
    n = split(n, stone, SEA_LEVEL-4)   
    
    local b1 = blend2D(rollingPlains(),plains(),0.25,0.5, 0.2)
    local b2 = blend2D(b1,cliffs(),0.15,0.5, 0.2)  
    local flat = craft.noise.const(-0.2)  
    n = warp(n,cache2D(riverBed(b1)))
    --n = liths(n)
    n = river(n)
    
    chunk:setWithNoise(n)
end

function liths(input)
    local n = craft.noise.perlin()
    n.frequency = 0.1
    n.octaves = 3
    
    local n2 = craft.noise.scale(5,25,5)
    n2:setSource(0, n)
    
    local invGrad = craft.noise.invert()
    invGrad:setSource(0, craft.noise.gradient())
    local invGrad2 = craft.noise.add()
    invGrad2:setSource(0, craft.noise.const(1))
    invGrad2:setSource(1, invGrad)
    
    local n3 = craft.noise.multiply()
    n3:setSource(0, n2)
    n3:setSource(1, invGrad2)    
    
    local n4 = craft.noise.scaleOffset()
    n4:setSource(0, n3)
    n4.scale = 1
    n4.offset = 0.6
    
    local s = craft.noise.select()
    s:setSource(0, input)
    s:setSource(1, air)   
    s:setSource(2, n4) 
    s:setBounds(0.85, 10)
    
    return s
end

function riverMap()
    local r = craft.noise.rigidMulti()
    r.frequency = 0.1
    r.octaves = 1
    r.seed = seed
    
    local t = craft.noise.turbulence()
    t:setSource(0, r)
    t.frequency = 0.5
    --t.power = 0.5
    --t.roughness = 3
    t.seed = seed
        
    return cache2D(flatten(t))
end

function riverEdge(input, riverbed)
    local s = craft.noise.select()
    s:setSource(0, input)
    s:setSource(1, riverbed)
    s:setSource(2, rmap)
    s:setBounds(-0.2, 10)
    
    local s2 = craft.noise.select()
    s2:setSource(0, s)
    s2:setSource(1, stone)
    s2:setSource(2, rmap)
    s2:setBounds(-0.5, 0)
    
    return s
end

function riverBed(input)
    -- blend height at river edges

    local s3 = craft.noise.select()
    s3:setSource(0, input)
    s3:setSource(1, craft.noise.const(0))
    s3:setSource(2, rmap)
    s3:setBounds(-0.5, 10)  
    s3.falloff = 0.15
    
    local s2 = craft.noise.select()
    s2:setSource(0, s3)
    s2:setSource(1, craft.noise.const(0.1))
    s2:setSource(2, rmap)
    s2:setBounds(0.0,10)
    s2.falloff = 0.25
    
    return s2
end

-- carve rivers out and fill with water
function river(input)
    
    local s = craft.noise.select()
    s:setSource(0, air)
    s:setSource(1, split(air, water, SEA_LEVEL-7))
    s:setSource(2, rmap)
    s:setBounds(-0.1, 10)
    
    s = split(s, air, SEA_LEVEL-20)
    
    local m = craft.noise.merge()
    m:setSource(0, input)
    m:setSource(1, s)

    return m
end

function flatten(input)
    local n2D = craft.noise.scale(1,0,1)
    n2D:setSource(0, input)
    return n2D
end

function cache2D(input)
    local cache = craft.noise.chunkCache2D(chunkGlobal)
    cache:setSource(0, input)
    return cache
end

function blend2D(a,b,frequency,roughness,falloff)
    local n = craft.noise.perlin()
    n.octaves = 1
    n.frequency = frequency
    n.seed = seed
    
    local s = craft.noise.select()
    s:setSource(0, a)
    s:setSource(1, b)
    s:setSource(2, flatten(n))
    s:setBounds(0,10)
    if falloff then
        s.falloff = falloff
    end
    
    if roughness > 0 then
        local t = craft.noise.turbulence()
        t:setSource(0, s)
        t.frequency = 0.5
        t.power = roughness
        --t.roughness = 3
        t.seed = seed
        
        s = t
    end
    return s
    --return cache2D(s)
end

-- Smoothly blend different terrain types
function terrain()
    local p = plains()
    local m = mountains()
    
    local n = craft.noise.perlin()
    n.octaves = 3
    n.frequency = 0.05
    n.seed = seed
    
    local s = craft.noise.select()
    s:setSource(0, p)
    s:setSource(1, m)
    s:setSource(2, n)
    s:setBounds(0,2)
    s.falloff = 0.05
    
    -- blend height at river edges
    local s2 = craft.noise.select()
    s2:setSource(0, s)
    s2:setSource(1, craft.noise.const(0.1))
    s2:setSource(2, rmap)
    s2:setBounds(0.1,10)
    s2.falloff = 0.2
    
    return cache2D(s2)
end

-- Basic terrain presets
function plains()
    return hills(2, 0, 0.25, 3)
end

function cliffs()
    return hills(5, 0, 0.75, 5)
end

function rollingPlains()
    return hills(10, 0, 0.25, 3)
end

-- take two noise functions and split based on elevation
function split(a,b,depth)
    depth = depth or 64
    
    local s = craft.noise.select()
    s:setSource(0, a)
    s:setSource(1, b)   
    s:setSource(2, craft.noise.gradient()) 
    s:setBounds(1.0 - depth / (cy + 0.0), 1.0)
    
    return s
end

-- warp one noise function using others
function warp(input, d1, d2, d3)

	if d1 and d2 and d3 then
		local zero = craft.noise.const()
	    
	    local displace = craft.noise.displace()
	    displace:setSource(0, input)
	    displace:setSource(1, d1) -- x
	    displace:setSource(2, d2) -- y
	    displace:setSource(3, d3) -- z

        return displace
	else
		local zero = craft.noise.const()
	    
	    local displace = craft.noise.displace()
	    displace:setSource(0, input)
	    displace:setSource(1, zero) -- x
	    displace:setSource(2, d1) -- y
	    displace:setSource(3, zero) -- z

	   return displace
	end
end

-- generic hills (height map style)
function hills(height, offset, frequency, octaves)

	height = height or 10
    offset = offset or 0
	octaves = octaves or 5
	frequency = frequency or 0.25

	local heightNorm = height / (cy + 0.0)

	local shape = craft.noise.perlin()
    shape.octaves = octaves
    shape.frequency = frequency
    shape.seed = seed
    
    local shape2D = craft.noise.scale(1,0,1)
    shape2D:setSource(0, shape)

    local shapeFinal = craft.noise.scaleOffset()
    shapeFinal:setSource(0, shape2D)
    shapeFinal.scale = -heightNorm * 0.5
    shapeFinal.offset = -heightNorm - offset/cy ---heightNorm*2   
    --[[
    return shapeFinal
    --]]
    
    return shapeFinal
end

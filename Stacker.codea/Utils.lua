-- https://codea.io/talk/discussion/7588/hsv-color-picker-and-sprite-creator
function hsvToRgb(h,s,v)
    local r,g,b
    
    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);
    
    i = i % 6
    
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    
    return r * 255, g * 255, b * 255
end

function noiseFunc(seed)
    local n = craft.noise.perlin()
    n.frequency = 0.1
    n.octaves = 2
    n.seed = seed
    return function (x) return n:getValue(0,x * 0.15,0) end
end

function lerp(a,b,t)
    return a * (1.0-t) + b * t
end
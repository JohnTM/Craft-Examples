GradientRamp = class()

function GradientRamp:init(w,h,data)
    self.img = image(w, h)
    self.points = {}
    if data then
        for k,v in pairs(data) do
            if #v == 2 then
                self:addPoint(v[1], v[2])  
            elseif #v == 3 then
                self:addPoint(v[1], v[3])
                self:addPoint(v[2], v[3])  
            end
        end
        self:update()
    end
end

function GradientRamp:addPoint(p, c)
    local point = {pos = p, color = c}
    table.insert(self.points, point)
end

function GradientRamp:getPoints(p)
    if #self.points < 2 then
        return nil, nil
    end
    
    local index = nil
    for k,v in pairs(self.points) do
        if p <= v.pos then
            index = k
            break
        end
    end
    
    if index == 1 then
        return self.points[index], self.points[index]
    elseif index == nil then
        return self.points[#self.points], self.points[#self.points]
    else
        return self.points[index-1], self.points[index]        
    end
end

function GradientRamp:update()
    table.sort(self.points, function(a,b)
        return a.pos < b.pos
    end)
     
    for x = 1, self.img.width do
        local p = (x-1.0) / (self.img.width-1)
        
        local a,b = self:getPoints(p)
        local c = nil
        
        if a == b then
            c = a.color
        else
            local mix = (p - a.pos) / (b.pos - a.pos)
            c = a.color:mix(b.color, 1-mix)
        end
        
        for y = 1, self.img.height do
            self.img:set(x-1, y, c)
        end        
    end

end

function GradientRamp:draw()
    sprite(self.img,WIDTH/2,HEIGHT/2)
end

function GradientRamp:touched(touch)

end

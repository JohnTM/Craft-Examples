Player = class()

-- Player state constants
PLAYER_IDLE = 1
PLAYER_DRAG = 2
PLAYER_JUMP = 3
PLAYER_DEAD = 4
PLAYER_DROWNED = 5

-- Player models to pick from
Player.models = 
{
    "Project:Player",
    "Project:Wolf"
}

function Player:init(e, p)
    self.entity = e
    self.size = vec3(0.4,0.6,0.4)
    self.bounds = craft.bounds(vec3(0,0,0), vec3(0,0,0))
    
    self.model = craft.entity()
    self.vm = self.model:add(craft.volume, 1,1,1)
    self.vm:load(Player.models[math.random(1,#Player.models)])
    
    -- Use a pivot so we can rotate the model around the center
    self.pivot = craft.entity()
    self.pivot.parent = self.entity
    self.model.parent = self.pivot
    self.entity.position = p
    
    local sx, sy, sz = self.vm:size()
    self.pivot.y = 0
    self.model.x = -sx * 0.5
    self.model.z = -sz * 0.5
    self.model.y = 0
    
    self.state = PLAYER_IDLE

    self.touchStart = vec2(0,0)
    self.touchEnd = vec2(0,0)
    
    self.squash = 0
    self.rotation = 180 
    self.jump = 0 
    
    self.x = p.x
    self.z = p.z
    
    self.pos = p
    self.nextPos = p
    
    self.directions = 
    {
        vec2(0,1),
        vec2(1,0),
        vec2(0,-1),
        vec2(-1,0)
    }
end

function Player:update()

    if self.state == PLAYER_DEAD then
        self.pivot.scale = vec3(1 + self.squash * 0.0025, 1 + self.squash * 0.0025, 1 - self.squash * 0.0025) * 0.05
        self.pivot.rotation = quat.eulerAngles(45,45,45)
    elseif self.state == PLAYER_DROWNED then
        self.entity.y = self.entity.y - 5 * DeltaTime 
    else
        self.entity.position = self.pos * (1-self.jump) + self.nextPos * self.jump
        self.pivot.y = math.sin(self.jump * math.pi) * 0.75 -- self.squash * 0.0015
        self.pivot.scale = vec3(1 + self.squash * 0.0025, 1 - self.squash * 0.0025, 1 + self.squash * 0.0025) * 0.05
        self.pivot.rotation = quat.eulerAngles(0,0,-self.rotation)
        self.bounds:set(self.size, self.entity.worldPosition - self.size * 0.5)
        
        -- Check for car collisions
        local car = getCar(self.bounds)
        if car then
            self:killed(car)
        end
    
    end
end

function Player:killed(car)
    self.state = PLAYER_DEAD
    if self.tid2 then
        tween.stop(self.tid2)
    end     
    self.entity.parent = car.entity    
    tween(1.0, self, {squash = 200.0}, tween.easing.cubicOut)      
end

function Player:jumpEnded()
    
    local s = getSection(self.nextPos.z)
    if s and s.type == ROAD_RIVER and self.log == nil then       
        self.state = PLAYER_DROWNED
        return
    end
    
    self.pos = self.nextPos
    if self.touchID then
        self.state = PLAYER_DRAG
    else
        self.state = PLAYER_IDLE
    end
end

function Player:worldPos()
    local pos = self.pos
    if self.log then
        pos = pos + self.log.entity.worldPosition
    end
    return pos
end

function Player:worldNextPos()
    local nextPos = self.nextPos
    if self.log then
        nextPos = nextPos + self.log.entity.worldPosition
    end
    return nextPos
end

function Player:touched(touch)
    
    if self.state == PLAYER_DEAD or self.state == PLAYER_DROWNED then
        if touch.state == ENDED then
            restart()
        end
    end
    
    if self.state == PLAYER_JUMP then
        
        if touch.state == BEGAN and self.touchID == nil then
            self.touchID = touch.id 
            self.touchStart.x = touch.x
            self.touchStart.y = touch.y   
        elseif touch.state == ENDED and self.touchID == touch.id then
            self.touchID = nil
        end
                 
    elseif self.state == PLAYER_IDLE then
        
        if touch.state == BEGAN then
            self.touchID = touch.id 
            self.touchStart.x = touch.x
            self.touchStart.y = touch.y    
           
            self.state = PLAYER_DRAG  
             
            if self.tid then
                tween.stop(self.tid)
            end
            
            self.tid = tween(1.0, self, {squash = 100.0}, tween.easing.cubicOut)      
        end
        
    elseif self.state == PLAYER_DRAG and self.touchID == touch.id then
        self.touchEnd.x = touch.x
        self.touchEnd.y = touch.y  
        
        local touchDir = (self.touchEnd - self.touchStart):normalize()
        local touchDist = self.touchStart:dist(self.touchEnd)
        
        local mindot = 0
        local mindir = nil
        local r = 0
        
        for k,v in pairs(self.directions) do
            local dot = v:dot(touchDir)
            if mindir == nil or dot < mindot then
                mindot = dot
                mindir = v
                r = (k-1) * 90
            end
        end 
                     
        if touch.state == MOVING then
            
        elseif touch.state == ENDED then
            self.touchID = nil

            if touchDist < 20 and touch.tapCount == 0 then
                self.state = PLAYER_IDLE
                tween.stop(self.tid)
                self.tid = tween(0.5, self, {squash = 0}, tween.easing.backOut)  
            else
                -- Always move forward on tap
                if touch.tapCount > 0 then
                    mindir = vec2(0,-1)
                    r = 180
                end
                
                self.nextPos = self.pos + vec3(mindir.x, 0, -mindir.y)  
                                    
                local tile = getTile(self:worldNextPos())
                
                local newBounds = craft.bounds(self:worldNextPos() - self.size*0.5, 
                                               self:worldNextPos() + self.size*0.5)
                local log = getLog(newBounds)
                
                if log then
                    -- non-log to log
                    if log ~= self.log then
                        self.entity.parent = log.entity
                        self.pos = self.entity.position
                        self.nextPos = vec3(math.floor(self.pos.x+0.5),0.3,0)
                        self.nextPos.x = math.max(math.min(self.nextPos.x,log.length-1), 0)
                        self.log = log
                    end
                    tile = 0
                elseif log == nil and self.log then
                    tile = getTile(self:worldNextPos())
                    
                    if tile == 0 then
                        -- log to non-log
                        self.entity.parent = nil
                        self.pos = self:worldPos()
                        self.nextPos = self:worldNextPos()
                        -- clamp to tile grid
                        self.nextPos.x = math.floor(self.nextPos.x)
                        self.nextPos.y = 0
                        self.nextPos.z = math.floor(self.nextPos.z)
                        self.log = nil                       
                    end
                end
                
                if tile == 0 then
                    self.state = PLAYER_JUMP
                    self.jump = 0
                    tween.stop(self.tid)
                    
                    if self.tid2 then
                        tween.stop(self.tid2)
                    end         
                    
                    self.tid = tween(0.15, self, {squash = 0}, tween.easing.backOut)
                    
                    self.tid2 = tween(0.3, self, {jump = 1}, tween.easing.linear, function()
                        self:jumpEnded()
                    end)
                    
                    tween(0.25, self, {rotation = r})
                    
                    sound(SOUND_JUMP, 38926, math.random()*0.3 + 0.3)
                else
                    self.nextPos = self.pos
                    
                    if self.tid then
                        tween.stop(self.tid)
                    end
            
                    self.tid = tween(0.5, self, {squash = 0.0}, tween.easing.backOut)  
                    self.state = PLAYER_IDLE
                end
                
            end
        end

    end
end

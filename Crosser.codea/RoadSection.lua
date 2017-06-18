RoadSection = class()

ROAD_GRASS = 1
ROAD_HIGHWAY = 2
ROAD_RIVER = 3
ROAD_RAILWAY = 4

DIRECTION_LEFT = -1
DIRECTION_RIGHT = 1

function RoadSection:init(e, t)
    -- you can accept and set parameters here
    self.entity = e
    
    self.height = 0.1
    self.offset = 0
    
    self.tiles = {}
    for i = 1, ROAD_WIDTH do
        table.insert(self.tiles, 0)
    end
    
    local c = color(255, 0, 161, 255)
    
    if t == ROAD_GRASS then
        c = color(157, 216, 60, 255)
        if e.z % 2 == 0 then
            c = color(148, 208, 52, 255)
        end
        
        for k,v in pairs(self.tiles) do
            local p = math.random()
            if p < 0.125 then
                local tree = scene:entity()
                tree:add(Tree)
                tree.parent = self.entity
                tree.z = 0
                tree.y = 0
                tree.x = ROAD_MIN_X - 1 + k
                self.tiles[k] = tree
            end
        end
        
    elseif t == ROAD_HIGHWAY then
        c = color(65, 65, 65, 255)
        self.offset = -0.05
        self.direction = (math.random() < 0.5) and DIRECTION_LEFT or DIRECTION_RIGHT
        self.speed = 0.75 + math.random() * 0.5
        self.cars = {}
        self:spawnCar()
    elseif t == ROAD_RIVER then
        c = color(93, 149, 230, 255)
        self.offset = -0.1
        self.direction = (math.random() < 0.5) and DIRECTION_LEFT or DIRECTION_RIGHT
        self.speed = 0.75 + math.random() * 0.5   
        if prevRiver then
            if self.direction == prevRiver.direction then 
                self.direction = (math.random() < 0.5) and DIRECTION_LEFT or DIRECTION_RIGHT
                self.speed = (math.random() < 0.5) and (prevRiver.speed * 2) or (prevRiver.speed / 2)
            end
        else

        end

        self.logs = {}
        
        local logCount = math.random(2,5)
        local x = math.random(ROAD_MIN_X,ROAD_MAX_X)
        for i = 1,logCount do
            local log = self:spawnLog(x)
            x = x + log.length + 2 + math.random(0,5)
        end

        prevRiver = self
    end
    
    self.entity.y = -self.height * 0.5 + self.offset
       
    self.type = t
    
    local mr = self.entity:add(craft.renderer, craft.mesh.cube(vec3(ROAD_WIDTH * TILE_SIZE, self.height, TILE_SIZE)))
    mr.material = craft.material("Materials:Standard")
    mr.material.diffuse = c  
    
end

function RoadSection:getTile(x)
    if x >= ROAD_MIN_X and x <= ROAD_MAX_X then
        return self.tiles[math.floor(x) + ROAD_MAX_X + 1]
    end
    return nil
end

function RoadSection:spawnCar()
    local car = scene:entity()
    local c = car:add(Car, self, self.direction, self.speed)
    car.parent = self.entity
    
    if self.direction == DIRECTION_LEFT then
        car.x = ROAD_MAX_X
    else
        car.x = ROAD_MIN_X
    end  
    
    car.y = self.height/2
    
    table.insert(self.cars, c)
    
    return car
end

function RoadSection:spawnLog(x)
    local log = scene:entity()
    local c = log:add(Log, math.floor(math.random(1,4)), self.direction, self.speed)
    log.parent = self.entity
    
    log.x = x
    log.y = -0.1
    
    table.insert(self.logs, c)
    
    return c
end

function RoadSection:update()
    
end

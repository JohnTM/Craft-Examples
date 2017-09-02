function createCastle()
    if castleModels == nil then
        castleModels = 
        {
            corner = craft.model("CastleKit:wallCornerHalfTower"),
            wall = craft.model("CastleKit:wall"),
            tower = craft.model("CastleKit:towerBase"),
            towerTop = craft.model("CastleKit:towerTop"),
        }
    end
    
    local size = 3
    local root = scene:entity()
    local bounds = castleModels.wall.bounds
    
    local parts = 
    {
        {
            model = castleModels.corner,
            x = 0, y = 0, z = 2, r = 0
        },
        {
            model = castleModels.wall,
            x = 0, y = 0, z = 2, r = 0
        },
        {
            model = castleModels.wall,
            x = 0, y = 0, z = 1, r = 0
        },
        {
            model = castleModels.corner,
            x = 0, y = 0, z = 0, r = 90
        },
        {
            model = castleModels.corner,
            x = -2, y = 0, z = 0, r = 180
        },
        {
            model = castleModels.corner,
            x = -2, y = 0, z = 2, r = 270
        },
        {
            model = castleModels.wall,
            x = -3, y = 0, z = 2, r = 0
        },
        {
            model = castleModels.wall,
            x = -3, y = 0, z = 1, r = 0
        },
        {
            model = castleModels.wall,
            x = -1, y = 0, z = 3, r = 90
        },
        {
            model = castleModels.wall,
            x = 0, y = 0, z = 3, r = 90
        },
        {
            model = castleModels.wall,
            x = -1, y = 0, z = 0, r = 90
        },
        {
            model = castleModels.wall,
            x = 0, y = 0, z = 0, r = 90
        },
        {
            model = castleModels.tower,
            x = 1.5, y = 1, z = -1.5, r = 0
        },
        {
            model = castleModels.tower,
            x = -2.5, y = 1, z = -1.5, r = 0
        },
        {
            model = castleModels.tower,
            x = 1.5, y = 1, z = 2.5, r = 0
        },
        {
            model = castleModels.tower,
            x = -2.5, y = 1, z = 2.5, r = 0
        },
        {
            model = castleModels.towerTop,
            x = 1.5, y = 2, z = -1.5, r = 0
        },
        {
            model = castleModels.towerTop,
            x = -2.5, y = 2, z = -1.5, r = 0
        },
        {
            model = castleModels.towerTop,
            x = 1.5, y = 2, z = 2.5, r = 0
        },
        {
            model = castleModels.towerTop,
            x = -2.5, y = 2, z = 2.5, r = 0
        },
    }
    
    for k,v in pairs(parts) do
        local object = scene:entity()
        object.parent = root
        object.model = v.model
        object.x = bounds.size.x * v.x
        object.y = bounds.size.y * v.y     
        object.z = bounds.size.z * v.z
        object.eulerAngles = vec3(0,v.r,0)
    end
        
    return root
end

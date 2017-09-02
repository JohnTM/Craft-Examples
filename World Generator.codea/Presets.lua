planets = {}

planets.earth = 
{
    ocean =
    {
        active = true,
        color = color(23, 132, 171, 255),
        opacity = 0.8,
        depth = 10
    },
    
    terrainRamp =
    {
        {0.0, 0.22, color(30, 47, 70, 255)},
        {0.25, color(220, 209, 172, 255)},
        {0.3, 0.5, color(27, 85, 33, 255)} ,
        {0.8, color(156, 93, 62, 255)},
        {0.9, color(129, 149, 126, 255)},
        {0.99, 1.0, color(255, 255, 255, 255)},
    },
    
    brushes =
    {
        {
            image = readImage("Project:SandStoneBrush"),
            count = {3,5},
            size = {2.0, 5.0},
            opacity = {0.25, 0.35}
        },
        {
            image = readImage("Project:RockBrush2"),
            count = {8,12},
            size = {1.0, 3.0},
            opacity = {0.4, 0.5}
        }
    }    
}

planets.mars = 
{
    ocean =
    {
        active = false,
        color = color(23, 132, 171, 255),
        opacity = 0.8,
        depth = 10
    },
    
    terrainRamp =
    {
        {0.0, 0.22, color(70, 30, 32, 255)},
        {0.3, 0.5, color(84, 26, 32, 255)} ,
        {0.8, color(156, 60, 68, 255)},
        {0.9, color(234, 32, 36, 255)},
        {0.99, 1.0, color(219, 23, 23, 255)},
    },
    
    brushes =
    {
        {
            image = readImage("Project:SandStoneBrush"),
            count = {3,5},
            size = {2.0, 5.0},
            opacity = {0.25, 0.35}
        },
        {
            image = readImage("Project:RockBrush2"),
            count = {8,12},
            size = {1.0, 3.0},
            opacity = {0.4, 0.5}
        }
    }    
}

planets.moon = 
{
    ocean =
    {
        active = false
    },
    
    terrainRamp =
    {
        {0.0, 1.0, color(197, 197, 197, 255)},
    },
    
    brushes =
    {
        {
            image = readImage("Project:RockBrush2"),
            count = {20,25},
            size = {0.5, 10.0},
            opacity = {0.125, 0.2}
        },
        {
            image = readImage("Project:CraterBrush"),
            count = {34,40},
            size = {0.1, 0.5},
            opacity = {0.15, 0.3}
        }
    }    
}
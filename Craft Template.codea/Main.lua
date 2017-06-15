-- Craft Template

function setup()
	-- Create a new craft scene
	scene = craft.scene()
	
	-- Create a new entity
	local e = scene:entity()
end

function update(dt)
	-- Update the scene (physics, transforms etc)
	scene:update(dt)
end

-- Called automatically by codea 
function draw()
	update(DelatTime)
	
	-- Draw the scene
	scene:draw()	
end
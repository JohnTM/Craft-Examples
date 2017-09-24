-----------------------------------------
-- Learn Craft
-- Written by John Millard
-- Special thanks to Ignatz for the MultiStep project template
-----------------------------------------
-- Description:
-----------------------------------------

-- MultiStep
function setup()
    steps = listProjectTabs()
    if steps[1]=="Notes" then table.remove(steps,1) end --remove first tab if named Notes
    table.remove(steps) --remove the last tab
    startStep()
    global = "select a step"
end

function showList()
    output.clear()
    for i=1,#steps do print(i,steps[i]) end
end

function drawStepName()
    fill(255, 255, 255, 255)
    font("Inconsolata")
    fontSize(40)
    textAlign(LEFT)
    textMode(CORNER)
    
    local name = string.gsub(steps[lastStep], "([A-Z])", " %1")    
    text(name, 10, HEIGHT - 60)
end

function startStep()
    if cleanup then cleanup() end
    lastStep=Step or  readLocalData("lastStep") or 1
    lastStep=math.min(lastStep,#steps)
    saveLocalData("lastStep",lastStep) 
    parameter.clear()
    parameter.integer("Step", 1, #steps, lastStep)
    parameter.watch("steps[Step]")
    parameter.action("Run", startStep)
    parameter.action("Next", function()
        Step = math.min(Step + 1, #steps)
        startStep()
    end)
    loadstring(readProjectTab(steps[Step]))()
    if PrintExplanation then PrintExplanation() end
    setup()
end

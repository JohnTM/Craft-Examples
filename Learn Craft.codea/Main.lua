-------------------------------------------------------------------------------
-- Learn Craft
-- Written by John Millard
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------

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
    
    local name = string.gsub(steps[Step], "([A-Z])", " %1")    
    text(name, 10, HEIGHT - 60)
end

function startStep()
    if cleanup then cleanup() end
    lastStep=Step or  readProjectData("lastStep") or 1
    lastStep=math.min(lastStep,#steps)
    saveProjectData("lastStep",lastStep) 
    parameter.clear()
    parameter.integer("Step", 1, #steps, lastStep, showList)
    parameter.action("Run", startStep)
    parameter.action("Next", function()
        Step = math.min(Step + 1, #steps)
        startStep()
    end)
    loadstring(readProjectTab(steps[Step]))()
    if PrintExplanation then PrintExplanation() end
    setup()
end

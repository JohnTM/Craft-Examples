
-- Use this function to perform your initial setup
function saved(func, name, min, max, initial, callback)
    func(name, min, max, readProjectData(name) or initial, function(i)
        saveProjectData(name, i)
        if callback then callback(i) end
    end)
end

function savedb(func, name, initial, callback)
    func(name, readProjectData(name) or initial, function(i)
        saveProjectData(name, i)
        if callback then callback(i) end
    end)
end

function saveProjectColor(key,c)
    saveProjectData(key,json.encode({c.r,c.g,c.b,c.a}))
end

function readProjectColor(key)
    if readProjectData(key) then
        local c = json.decode(readProjectData(key))
        return color(c[1], c[2], c[3], c[4])
    end
    return nil
end

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

function startStep()
    if cleanup then cleanup() end
    lastStep=Step or  readProjectData("lastStep") or 1
    lastStep=math.min(lastStep,#steps)
    saveProjectData("lastStep",lastStep) 
    parameter.clear()
    parameter.integer("Step", 1, #steps, lastStep, showList)
    parameter.action("Run", startStep)
    loadstring(readProjectTab(steps[Step]))()
    if PrintExplanation then PrintExplanation() end
    setup()
end


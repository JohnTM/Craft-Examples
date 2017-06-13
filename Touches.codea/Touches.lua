local TouchHandler = class()

function TouchHandler:init(target, priority, multiTouch)
    assert(target ~= nil)

    self.target = target
    self.priority = priority or 0
    self.multiTouch = multiTouch or false
    self.captured = {}
    self.count = 0
end

function TouchHandler:touched(touch)
    if touch.state == BEGAN then
        if self.multiTouch or self.count == 0 then
            if self.target:touched(touch) then
                self.captured[touch.id] = true
                self.count = self.count + 1
                return true
            end
        end
    elseif touch.state == MOVING then
        if self.captured[touch.id] then
            self.target:touched(touch)
            return true
        end
    elseif touch.state == ENDED or touch.state == CANCELLED then
        if self.captured[touch.id] then
            self.target:touched(touch)
            self.captured[touch.id] = nil
            self.count = self.count - 1
            return true
        end
    end    

    return false
end

touches = {}
touches.handlers = {}
touches.shared = {}

function touches.share(target, touch, priority)
    local fakeTouch = 
    {
        x = touch.x,
        y = touch.y,
        id = touch.id,
        state = BEGAN,
        tapCount = touch.tapCount,
        deltaX = touch.deltaX,
        deltaY = touch.deltaY       
    }
    
    for k,v in pairs(touches.handlers) do
        if v.target ~= target and v.priority == priority then
            v:touched(fakeTouch) 
        end
    end
end

function touches.addHandler(target, priority, multiTouch)
    table.insert(touches.handlers, TouchHandler(target, priority, multiTouch))

    table.sort(touches.handlers, function(a,b)
        return a.priority < b.priority
    end)
end

function touches.removeHandler(target)
    local i = nil

    for k,v in pairs(touches.handlers) do
        if v.target == target then
            i = k
        end
    end

    table.remove(touches.handlers, i)
end

function touches.touched(touch)
    local captured = false
    for k,v in pairs(touches.handlers) do
        if v:touched(touch) then captured = true end
        if touch.state == BEGAN and captured then
            return true
        end
    end

    return captured
end

function touched(touch)
    touches.touched(touch)
end


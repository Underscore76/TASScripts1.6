local utils = require('logic.utils')
local Gamepad = require('gamepad')

-- zoom out - 837,162
-- zoom in - 858,162
local ZOOM_OUT_X = 837
local ZOOM_IN_X = 858
local ZOOM_Y = 162
local ZOOM_THRESHOLD = 5

local function _mouse_to_target(p, target_x, target_y)
    local cursorSpeed = Reflector.GetStaticVar(p.index, "Game1__cursorSpeed")
    local speed = cursorSpeed / 720 * Reflector.GetStaticVar(p.index, "Game1_viewport").Height *
        Game1.currentGameTime.ElapsedGameTime.TotalSeconds
    local m = GetValue(Reflector.GetStaticVar(p.index, "Game1_input"), "_simulatedMousePosition")
    local x = m.X
    local y = m.Y
    local dx = 0
    local dy = 0
    if y < target_y - ZOOM_THRESHOLD then
        -- the y fraction gets multiplied by speed to get the number of pixels traversed
        dy = (target_y - ZOOM_THRESHOLD - y)
        dy = -math.min(dy / speed, 1)
    elseif y > target_y + ZOOM_THRESHOLD then
        dy = y - (target_y + ZOOM_THRESHOLD)
        dy = math.min(dy / speed, 1)
    end
    if x < target_x - ZOOM_THRESHOLD then
        dx = (target_x - ZOOM_THRESHOLD - x)
        dx = math.min(dx / speed, 1)
    elseif x > target_x + ZOOM_THRESHOLD then
        dx = x - (target_x + ZOOM_THRESHOLD)
        dx = -math.min(dx / speed, 1)
    end
    if dx == 0 and dy == 0 then
        p:analog(0, 0)
        p:push()
        return false
    end
    -- printf("mouse_to_zoom_out: cursor=(%d,%d) dx=%.2f dy=%.2f speed=%.2f", x, y, dx or 0, dy or 0, speed)
    p:analog(dx, dy)
    p:push()
    return true
end

local function zoom_level(index)
    return GameRunner.instance.gameInstances[index].instanceOptions.localCoopBaseZoomLevel
end

local function zoom_out(index)
    local p = Gamepad.new(index)
    if zoom_level(index) == 1 then
        return
    end

    local flag = true
    repeat
        flag = _mouse_to_target(p, ZOOM_OUT_X, ZOOM_Y)
        coroutine.yield()
    until not flag

    while zoom_level(index) > 1 do
        p:a()
        p:push()
        coroutine.yield()
        p:push()
        coroutine.yield()
    end
end

local function zoom_in(index)
    local p = Gamepad.new(index)
    if zoom_level(index) == 2 then
        return
    end

    local flag = true
    repeat
        flag = _mouse_to_target(p, ZOOM_IN_X, ZOOM_Y)
        coroutine.yield()
    until not flag

    while zoom_level(index) < 2 do
        p:a()
        p:push()
        coroutine.yield()
        p:push()
        coroutine.yield()
    end
end

return function(v)
    if v then
        for n = 1, 3 do
            GamePadInputQueue.SetManualFrameFunction(n, zoom_out, "zoom_out", "zoom out to 1")
        end
        return
    end
    for n = 1, 3 do
        GamePadInputQueue.SetManualFrameFunction(n, zoom_in, "zoom_in", "zoom in to 2")
    end
end

-- TODO: swap to coroutine.yield
local utils = require('logic.utils')
local Gamepad = require('core.input.gamepad')
local wait_swing = require('logic.wait_swing').helpers.wait_swing

local facingDirection = {
    [0] = "up",
    [1] = "right",
    [2] = "down",
    [3] = "left",
}

---@param p Gamepad
---@param dir integer
local function _swing_dir(p, dir)
    local player = InstanceCurrentPlayer.Get(p.index)
    if player == nil or player.CurrentTool == nil or player.UsingTool then
        wait_swing(p.index)
        return
    end
    if player.FacingDirection ~= dir then
        p[facingDirection[dir]](p)
        p:push()
        coroutine.yield()
    end
    p:x()
    p:push()
    coroutine.yield()
    wait_swing(p.index)
end

local function swing_up(index)
    local p = Gamepad.new(index)
    return _swing_dir(p, 0)
end

local function swing_right(index)
    local p = Gamepad.new(index)
    return _swing_dir(p, 1)
end

local function swing_down(index)
    local p = Gamepad.new(index)
    return _swing_dir(p, 2)
end

local function swing_left(index)
    local p = Gamepad.new(index)
    return _swing_dir(p, 3)
end

local function _break_tree(p)
    local player = utils.current_player(p.index)
    if player == nil or player.CurrentTool == nil or player.CurrentTool.Name ~= "Axe" then
        error("Player does not have an axe equipped")
    end
    if player.UsingTool then
        wait_swing(p.index)
        return
    end

    local x = player.CurrentTile.X
    local y = player.CurrentTile.Y
    local dir = player.FacingDirection
    if dir == 0 then
        y = y - 1
    elseif dir == 1 then
        x = x + 1
    elseif dir == 2 then
        y = y + 1
    elseif dir == 3 then
        x = x - 1
    end
    local tile = Vector2(x, y)
    local loc = utils.current_location(p.index)
    if loc == nil then
        error("Could not get current location")
    end
    local found = loc.terrainFeatures:ContainsKey(tile)
    if not found then
        return
    end
    p:x()
    p:push()
    coroutine.yield()
    wait_swing(p.index)
end

local function break_tree(index)
    local p = Gamepad.new(index)
    return _break_tree(p)
end

return {
    helpers = {
        swing = _swing_dir,
    },
    funcs = {
        { func = swing_up,    name = "swing_up",    desc = "swing tool up" },
        { func = swing_right, name = "swing_right", desc = "swing tool right" },
        { func = swing_down,  name = "swing_down",  desc = "swing tool down" },
        { func = swing_left,  name = "swing_left",  desc = "swing tool left" },
        { func = break_tree,  name = "break_tree",  desc = "break tree in front of player" },
    }
}

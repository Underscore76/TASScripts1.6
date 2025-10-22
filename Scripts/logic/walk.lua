local utils = require('logic.utils')
local Gamepad = require('gamepad')
local screen_fade = require('logic.screen_fade').helpers.screen_fade

local function within_tile_x(box, x_tile)
    if box.Right > x_tile + 64 then
        return -1
    end
    if box.Left < x_tile then
        return 1
    end
    return 0
end
local function within_tile_y(box, y_tile)
    if box.Bottom > y_tile + 64 then
        return -1
    end
    if box.Top < y_tile then
        return 1
    end
    return 0
end

local function _walk_to_tile(p, target_tile)
    while true do
        local player = utils.current_player(p.index)

        if player == nil then
            return
        end

        local dx = within_tile_x(player.BoundingBox, target_tile.X * 64)
        local dy = within_tile_y(player.BoundingBox, target_tile.Y * 64)

        if dx == 0 and dy == 0 then
            return
        end

        if dx < 0 then
            p:left()
        elseif dx > 0 then
            p:right()
        end
        if dy < 0 then
            p:up()
        elseif dy > 0 then
            p:down()
        end

        p:push()
        coroutine.yield()
    end
end

local function walk_to_tile(target_tile)
    return function(index)
        local p = Gamepad.new(index)
        _walk_to_tile(p, target_tile)
        p:push()
    end
end

local function walk_tile_sequence(tile_sequence)
    return function(index)
        local p = Gamepad.new(index)
        for _, tile in ipairs(tile_sequence) do
            _walk_to_tile(p, tile)
        end
        p:push()
    end
end

local function leave_house(index)
    local p = Gamepad.new(index)
    local loc = utils.current_location(p.index)
    if loc == nil then
        error("Could not get current location")
    end
    if loc.Name ~= "FarmHouse" and loc.Name ~= "Cabin" then
        return
    end
    _walk_to_tile(p, Vector2(3, 9))
    while loc.Name == "FarmHouse" or loc.Name == "Cabin" do
        p:down()
        p:push()
        coroutine.yield()
        loc = utils.current_location(p.index)
    end
    p:push()
    screen_fade(p.index)
end

return {
    walk = function(index, ...)
        local args = { ... }
        if #args == 1 then
            GamePadInputQueue.SetManualFrameFunction(
                index,
                walk_to_tile(args[1]),
                "walk_to_tile",
                "walk to tile (" .. args[1].X .. "," .. args[1].Y .. ")"
            )
        else
            GamePadInputQueue.SetManualFrameFunction(
                index,
                walk_tile_sequence(args),
                "walk_tile_sequence",
                "walk tile sequence"
            )
        end
    end,
    funcs = {
        { func = leave_house, name = "leave_house", desc = "walk to house exit" },
    }
}

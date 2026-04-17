local Gamepad = require('core.input.gamepad')
local utils = require('logic.utils')
local walk = require('logic.walk').helpers

local function V(x, y)
    return Vector2(x, y)
end

local function skip_cutscene(index)
    local p = Gamepad.new(index)
    local loc = utils.current_location(p.index)
    while loc.currentEvent == nil do
        coroutine.yield()
        loc = utils.current_location(p.index)
    end
    p:push()
    p:push()
    coroutine.yield()
    while loc.currentEvent ~= nil do
        p:select()
        p:push()
        p:push()
        coroutine.yield()
        loc = utils.current_location(p.index)
    end
end

-- player 1 - 6th man award winning role player
-- it's going to feel very silly to have to pass index for each thing but oh well
local function p1(index)
    walk.leave_house(index)
    -- walks from door to just below the backwoods exit
    walk.walk_tile_sequence({ V(48, 24), V(48, 21), V(49, 20), V(49, 18), V(44, 13),
        V(44, 9), V(41, 9), V(41, 4) })(index)
    walk.walk_to_transition("up")(index)
    -- walk to mountain
    walk.walk_tile_sequence({ V(15, 21), V(22, 14), V(32, 14) })(index)
    walk.walk_to_transition("right")(index)
    -- walk to mines
    walk.walk_tile_sequence({ V(7, 13), V(22, 15), V(23, 19), V(25, 21), V(36, 21), V(42, 15), V(42, 10), V(45, 7), V(50,
        7), V(54, 6) })(index)
    walk.walk_to_transition("up", false)(index)
    -- entering the mines and triggering the cutscene
    skip_cutscene(index)
    walk.walk_tile_sequence({ V(18, 12), V(22, 9) })(index)
end
GamePadInputQueue.SetManualFrameFunction(
    1,
    p1,
    "role_player",
    "6th man"
)

-- player 2 - forager
local function p2(index)
    walk.leave_house(index)
    while true do
        coroutine.yield()
    end
end
GamePadInputQueue.SetManualFrameFunction(
    2,
    p2,
    "forager",
    "forager extraordinaire"
)

-- player 3 - fisher
local function p3(index)
    walk.leave_house(index)
    while true do
        coroutine.yield()
    end
end
GamePadInputQueue.SetManualFrameFunction(
    3,
    p3,
    "fisher",
    "catch the fish"
)

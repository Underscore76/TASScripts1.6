local utils = require('logic.utils')
local Gamepad = require('core.input.gamepad')

local function _wait_nibble(p)
    local rod = InstanceCurrentPlayer.Get(p.index).CurrentTool
    return not rod.isNibbling
end

local function wait_nibble(index)
    local p = Gamepad.new(index)
    while _wait_nibble(p) do
        coroutine.yield()
    end
end

local function _hover(p)
    local menu = InstanceCurrentMenu.Get(p.index).Menu
    local pressedLastFrame = TASInputState.GetTASGamePadState(p.index).ButtonX
    local speed = menu.bobberBarSpeed
    -- I want the speed to be captured in the range [-0.15, 0.15]
    p:push() -- fall
    p:x()
    p:push() -- raise the next frame
    p:x()
    p:push()
    p:push()
    return true
    --[[
    frame 1 speed -.15 -> no
    frame 2 speed -1e-7 -> yes
    frame 3 speed .15 -> yes
    frame 4 speed -1e-7 -> no
    --]]
end
local function hover(index)
    local p = Gamepad.new(index)
    while _hover(p) do
        coroutine.yield()
    end
end

return {
    helpers = {
        wait_nibble = wait_nibble,
        hover = hover,
    },
    funcs = {
        { func = wait_nibble, name = "wait_nibble", desc = "wait for fish to nibble" },
        { func = hover,       name = "hover",       desc = "hover the bar in a zone" },
    }
}

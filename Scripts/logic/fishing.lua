local utils = require('logic.utils')
local Gamepad = require('gamepad')

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

return {
    helpers = {
        wait_nibble = wait_nibble,
    },
    funcs = {
        { func = wait_nibble, name = "wait_nibble", desc = "wait for fish to nibble" },
    }
}

local utils = require('logic.utils')
local Gamepad = require('core.input.gamepad')


local function _wait_swing(p)
    local player = InstanceCurrentPlayer.Get(p.index)
    if player == nil or player.CurrentSingleAnimation == nil or player.CurrentTool == nil or not player.UsingTool then
        return
    end

    local anim = player.CurrentSingleAnimation
    while player ~= nil and anim == player.CurrentSingleAnimation do
        p:push()
        coroutine.yield()
        player = InstanceCurrentPlayer.Get(p.index)
    end
end

local function wait_swing(index)
    local p = Gamepad.new(index)
    return _wait_swing(p)
end

return {
    helpers = {
        wait_swing = wait_swing
    },
    funcs = {
        { func = wait_swing, name = "wait_swing", desc = "wait for tool swing to finish" },
    }
}

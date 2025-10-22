local utils = require('logic.utils')
local Gamepad = require('gamepad')

local swing_indexes = {
    tool = {
        [66] = 4, -- axe/pickaxe/hoe down
        [48] = 4, -- axe/pickaxe/hoe left/right
        [36] = 4, -- axe/pickaxe/hoe down
        [54] = 4, -- watering can down
        [58] = 4, -- watering can left/right
        [62] = 4, -- watering can up
    },
    weapon = {
        [30] = 5, -- sword swipe up
        [36] = 5, -- sword swipe left/right
        [24] = 5, -- sword swipe down
    }
}

local function _wait_swing(p)
    local player = utils.current_player(p.index)
    if player == nil or player.CurrentSingleAnimation == nil or player.CurrentTool == nil or not player.UsingTool then
        return
    end

    local index = nil
    if PlayerInfo.IsSwingingSword then
        index = swing_indexes.weapon[player.CurrentSingleAnimation]
    else
        index = swing_indexes.tool[player.CurrentSingleAnimation]
    end

    while player ~= nil and player.CurrentAnimationIndex < index do
        coroutine.yield()
        player = utils.current_player(p.index)
    end
    p:push()
    player = utils.current_player(p.index)
    while player ~= nil and player.CurrentAnimationElapsed + 1 < player.CurrentAnimationLength do
        coroutine.yield()
        player = utils.current_player(p.index)
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

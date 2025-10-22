local utils = require('logic.utils')
local Gamepad = require('gamepad')

local function _screen_fade(p)
    local screenFade = Reflector.GetStaticVar(p.index, "Game1_screenFade")
    local player = Reflector.GetStaticVar(p.index, "Game1__player")
    if screenFade.globalFade or
        (screenFade.fadeIn and screenFade.fadeToBlackAlpha < 1 and screenFade.fadeToBlackAlpha ~= 0) or
        (screenFade.fadeToBlack and screenFade.fadeToBlackAlpha > 0 and not player.CanMove)
    then
        return true
    end
    return false
end

local function screen_fade(index)
    local p = Gamepad.new(index)
    while _screen_fade(p) do
        coroutine.yield()
    end
end

return {
    helpers = {
        screen_fade = screen_fade,
    },
    funcs = {
        { func = screen_fade, name = "screen_fade", desc = "wait for screen fade to finish" },
    }
}

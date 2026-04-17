local utils = require('logic.utils')
local Gamepad = require('core.input.gamepad')
local wait_swing = require('logic.wait_swing').helpers.wait_swing

local function _cut_weed(p)
    while true do
        local hit = CutWeed.Estimate(p.index)
        if hit.NumMixedSeeds > 0 then
            break
        end
        coroutine.yield()
    end
    p:x()
    p:push()
    wait_swing(p.index)
end

local function cut_weeds(index)
    local p = Gamepad.new(index)
    return _cut_weed(p)
end

return {
    funcs = {
        { func = cut_weeds, name = "cut_weeds", desc = "wait until a mixed seed would spawn" },
    }
}

interface.SimulateRealAdvance = true

local keybinds = require("core.keybinds")
local badapple = {}
-- function badapple.reset()
--     reset(1100)
--     halt(1105)
--     Game1.player:increaseBackpackSize(12)
--     Game1.player:increaseBackpackSize(12)
-- end

function badapple.step(i)
    if i == nil then
        i = 0
    end
    advance({ keyboard = { Keys.X } })
    advance({ keyboard = { Keys.Escape } })
    for j = 1, i do
        advance()
    end
    -- advance({ mouse = { X = 1435, Y = 680, left = true } })
    advance({ mouse = { X = 1670, Y = 928, left = true } })
end

function badapple.setup(n)
    -- OverlayManager.Get("BadApple").StartFrame = 1100
    -- if interface.KeyBinds:ContainsKey(Keys.I) then
    --     keybinds.remove(Keys.I)
    -- end
    keybinds.add(Keys.I,
        function()
            badapple.reset()
            -- while Game1.player.mailbox.Count > 0 do
            --     badapple.step(n)
            -- end
        end
    )
end

return badapple

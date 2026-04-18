local nav = require('core.coroutines.nav')
local input = require("core.input")
local keybinds = require("core.keybinds")

keybinds.remove(Keys.J)
keybinds.add(Keys.J,
    function()
        local m = Mouse.GetState()
        local t = input.get_tile_from_local(Vector2(m.X, m.Y))
        KeyboardMouseInputQueue.PushFunction(nav.walk_to_tile(t), "walk_to_tile")
    end
)

-- local keybinds = require('core.keybinds')
-- view = require('core.view')
-- weeds = require('weeds')

-- -- cm = require('chair_move')
-- MapView.Instance.MapOverlays:Add(MouseData())
-- MapView.Instance.MapOverlays:Add(OverlayManager.Get("tiletext"))
-- -- run some additional configuration to make things how you want on boot

-- exec("loadengine tmp") -- can swap to whatever engine state you like
-- m = require('mines')
-- s = require('scratch')
-- require('bobber')

-- require('create_char')

-- -- Controller.Console.DebugMode = true
-- Controller.Console.ShowWarnings = false

-- SkullCavernsSolver.SetMaxLookAhead(200)

-- function cr()
--     Controller.PushStackTrace = true
--     RandomExtensions.StackTraces:Clear()
-- end

-- function dr()
--     exec('dump_random')
--     Controller.PushStackTrace = false
-- end

-- function ff()
--     Controller.Console.ShowWarnings = true
--     Controller.Console.ShowErrors = true
-- end

-- function gg()
--     Controller.Console.ShowWarnings = false
--     Controller.Console.ShowErrors = false
-- end

-- function hh()
--     Controller.Console:WriteToRandomFile()
-- end

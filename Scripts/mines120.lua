local keybinds = require('core.keybinds')
local console = require('core.console')
local mines120 = {}

function mines120.setup()
    console.exec("overlay off all")
    console.exec("overlay on TimerPanel")
    console.exec('logic off all')

    keybinds.add(Keys.I,
        function()
            bfreset(-1)
        end
    )

    local last_frame = 18140
    Controller.Overlays["TimerPanel"]:Clear()
    Controller.Overlays["TimerPanel"]:RegisterTimer(0, 0, last_frame, true)
    Controller.Overlays["TimerPanel"].MaxFrame = last_frame
    fload("mines120_18140")
end

function mines120.blank()
    console.exec("blankscreen")
    Controller.Overlays["TimerPanel"].CurrentFrame = 0
    Controller.Overlays['TimerPanel'].Timers[0].Item2.Span = TimeSpan()
end

return mines120

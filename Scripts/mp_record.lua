local keybinds = require('core.keybinds')
local console = require('core.console')
local mpr = {}

function mpr.setup()
    console.exec("overlay off all")
    console.exec("overlay on TimerPanel")
    console.exec('logic off all')

    if interface.KeyBinds:ContainsKey(Keys.I) then
        keybinds.remove(Keys.I)
    end
    keybinds.add(Keys.I,
        function()
            load('mp_FINISH_POSE')
        end
    )

    local last_frame = 178704
    TASDateTime.CurrentFrame = 1100000
    OverlayManager.Get('timerpanel'):Clear()
    OverlayManager.Get('timerpanel'):RegisterTimer(0, 0, last_frame, true)
    OverlayManager.Get('timerpanel').MaxFrame = last_frame
end

function mpr.blank()
    console.exec("blankscreen")
    OverlayManager.Get('timerpanel').CurrentFrame = 0
    OverlayManager.Get('timerpanel').Timers[0].Item2.Span = TimeSpan()
    Game1.currentSong:Stop(AudioStopOptions.Immediate)
end

return mpr

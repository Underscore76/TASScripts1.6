local keybinds = require('core.keybinds')
local console = require('core.console')
local mpr = {}

function mpr.setup()
    console.exec("overlay off all")
    console.exec('logic off all')

    if interface.KeyBinds:ContainsKey(Keys.I) then
        keybinds.remove(Keys.I)
    end
    keybinds.add(Keys.I,
        function()
            load('d2_complete')
        end
    )
end

function mpr.blank()
    console.exec("blankscreen")
    if Game1.currentSong ~= nil then
        Game1.currentSong:Stop(AudioStopOptions.Immediate)
    end
end

return mpr

function forage()
    print("")
    print(string.format("%s %d", Game1.currentSeason, Game1.dayOfMonth))
    exec('forage all')
    advance()
end

function sleep()
    while Game1.activeClickableMenu == nil do
        advance({ keyboard = { Keys.D } })
    end
end

function loop()
    while true do
        forage()
        sleep()
        advance()
        if Game1.activeClickableMenu ~= nil then
            advance({ mouse = { left = true } })
        end
    end
end

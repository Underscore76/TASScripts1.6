local books = {}

-- things that are updating
-- the artifactSpots have a shakeTimer

function books.test()
    -- farmer.updateCommon
    local r = game1_random()
    local blinkTimer = Game1.player.blinkTimer
    local objVec = Vector2(25, 18)
    local shakeTimer = Game1.currentLocation.Objects[objVec].shakeTimer
    for i = 1, 10 do
        blinkTimer = blinkTimer + 16
        if blinkTimer > 2200 and r:NextDouble() < 0.01 then
            blinkTimer = -150
        end
        -- GameLocation.UpdateWhenCurrentLocation
        -- critters update
        -- butterfly calls update

        -- chunks update
        --
        -- testing shake on the artifact spot
        if shakeTimer > 0 then
            shakeTimer = shakeTimer - 16
            if shakeTimer <= 0 then
                -- health = 10
            end
        end
        if r:NextDouble() < 0.01 then
            shakeTimer = 100
        end
    end

    -- now test the swing
    for i = 1, 10 do
        advance()
    end
    printf("blink: %d\t%s", blinkTimer, Game1.player.blinkTimer)
    printf("shake: %d\t%s", shakeTimer, Game1.currentLocation.Objects[objVec].shakeTimer)
end

function books.run()
end

return books

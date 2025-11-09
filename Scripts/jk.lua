local jk = {
    x = nil
}
function jk.start()
    interface:StartMinecart()

    for _ = 1, 100 do
        advance()
    end
    advance({ mouse = { left = true } })

    for _ = 1, 100 do
        advance()
    end
end

function jk.stash()
    jk.x = interface:GetMinecart()
    printf("stashed - %s - %s", tostring(Game1.currentMinigame.random), tostring(current_frame()))
end

function jk.pop()
    ---@diagnostic disable-next-line: undefined-field
    printf("before  - %s - %s", tostring(Game1.currentMinigame.random), tostring(current_frame()))
    interface:SetMinecart(jk.x)
    printf("after   - %s - %s", tostring(Game1.currentMinigame.random), tostring(current_frame()))
end

function jk.reset()
    printf("before  - %s - %s", tostring(Game1.currentMinigame.random), tostring(current_frame()))
    interface:SetMinecart(jk.x)
    Controller.State:Reset(current_frame())
    printf("after   - %s - %s", tostring(Game1.currentMinigame.random), tostring(current_frame()))
end

function jk.poll()
    printf("poll    - %s - %s", tostring(Game1.currentMinigame.random), tostring(current_frame()))
    GetValue(Game1.currentMinigame, "_lastGenerator")
end

function jk.run(n)
    if n == nil then
        n = 100
    end
    for _ = 1, n do
        advance()
    end
end

function jk.lookahead()
    local n = 0
    local minecart = interface:GetMinecart()
    minecart.shouldPlaySound = false
    minecart.shouldDraw = false
    local t = TASDateTime.CurrentGameTime
    local player = GetValue(minecart, "player")
    while player:IsGrounded() and GetValue(minecart, "respawnCounter") <= 0 do
        local track = player:GetTrack()
        if track ~= nil then
            printf("%s [%s %s] [%s %s]",
                player.position,
                track.position,
                track.trackType,
                track:GetYAtPoint(track.position.X), player:GetTrack():GetYAtPoint(track.position.X + minecart.tileSize))
        end
        minecart:Simulate(false)
        n = n + 1
        if n > 500 then
            break
        end
    end
    printf("%s %s %s %d",
        n,
        tostring(player.position),
        tostring(player:IsGrounded()),
        tostring(GetValue(minecart, "respawnCounter"))
    )
end

function jk.sim(n)
    if n == nil then
        n = 100
    end
    for _ = 1, n do
        local mouse = JunimoKartSimulator.GetInput()
        advance({ mouse = { left = mouse } })
    end
    -- local state = Controller.Overlays["JunimoKart"].BestState
    -- while state ~= nil and (not Game1.currentMinigame.gameOver) and (not Game1.currentMinigame.reachedFinish) do
    --     if state.Game.buttonPresses.Count == 0 then
    --         advance()
    --     else
    --         local mouse = state.Game.buttonPresses[0]
    --         advance({ mouse = { left = mouse } })
    --     end
    --     state = Controller.Overlays["JunimoKart"].BestState
    -- end
end

return jk

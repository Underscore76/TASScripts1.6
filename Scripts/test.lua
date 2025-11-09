-- local Queue = require('queue')

-- local function ff(max_depth, max_evals)
--     if max_depth == nil then
--         max_depth = 4
--     end
--     if max_evals == nil then
--         max_evals = 200
--     end
--     local function state_hash(track_state)
--         return string.format("%s:%s:%s", track_state.position.X, track_state.position.Y, track_state.state.Score)
--     end
--     local game = JunimoKartState(interface:GetMinecart())
--     local track_states = JunimoKartSimulator.GetTracks(game)

--     local visited = {}
--     local queue = Queue()
--     for _, track_state in list_items(track_states) do
--         queue.pushright({
--             depth = 0,
--             score = track_state.state.Score,
--             state = track_state.state,
--             position = track_state.position,
--             hash = state_hash(track_state)
--         })
--     end
--     local evals = 0

--     local bestSolution = nil
--     while not queue.empty() do
--         local current = queue.popleft()
--         local hash = current.hash
--         local depth = current.depth
--         printf("POP depth %d, current %s (len %d)", depth, hash, queue.size())

--         evals = evals + 1
--         if evals >= max_evals then
--             printf("EVALS: %d", evals)
--             print("max evals reached")
--             if bestSolution == nil or current.score > bestSolution.score then
--                 bestSolution = current
--             end
--             goto continue
--         end
--         if current.state.Game.gameOver then
--             visited[hash] = true
--             print("\tgame over")
--             goto continue
--         end

--         if current.depth >= max_depth or current.state.Game.reachedFinish then
--             print("depth limit reached")
--             printf("score: %d", current.score)
--             if bestSolution == nil or current.score > bestSolution.score then
--                 bestSolution = current
--             end
--             visited[hash] = true
--             goto continue
--         end

--         if visited[hash] then
--             print("\tskipping visited state")
--             goto continue
--         end

--         printf('searching neighbors: %s', current.state)

--         printf("current.state: %s", current.state.Game.player:IsGrounded())
--         local newStates = JunimoKartSimulator.GetTracks(current.state)
--         printf('newStates: %s (%d)', newStates, newStates.Count)
--         if newStates.Count == 0 then
--             goto continue
--         end
--         for i, track_state in list_items(newStates) do
--             local new_hash = state_hash(track_state)
--             if not visited[new_hash] then
--                 printf("depth: %d %s\tpushing new state %s", depth, hash, new_hash)
--                 queue.pushright({
--                     depth = depth + 1,
--                     score = track_state.state.Score,
--                     state = track_state.state,
--                     position = track_state.position,
--                     hash = new_hash
--                 })
--             else
--                 printf("depth: %d %s\tskipping state %s", depth, hash, new_hash)
--             end
--         end
--         current = nil
--         ::continue::
--     end

--     if bestSolution ~= nil then
--         -- printf("best solution: %s", bestSolution.hash)
--         local buttonPresses = bestSolution.state.Game.buttonPresses
--         for i = 0, buttonPresses.Count - 1 do
--             if i >= 30 and buttonPresses[i] == false then
--                 break
--             end
--             local press = buttonPresses[i]
--             -- printf("press: %s", press)
--             advance({ mouse = { left = press } })
--         end
--         while not Game1.currentMinigame.player:IsGrounded() and not Game1.currentMinigame.gameOver do
--             advance()
--         end
--         -- for i, press in list_items(bestSolution.state.Game.buttonPresses) do
--         --     -- printf("press: %s", press)
--         --     advance({ mouse = { left = press } })
--         -- end
--     else
--         print("no solution found")
--         if not Game1.currentMinigame.gameOver then
--             error("no solution found")
--         end
--     end
-- end

-- local function yy()
--     while Game1.currentMinigame.gameOver == false do
--         if Game1.currentMinigame.reachedFinish then
--             print("reached finish")
--             while Game1.currentMinigame.reachedFinish do
--                 advance()
--             end
--             while Game1.currentMinigame.gameState ~= SMineCart.GameStates.Ingame do
--                 advance()
--             end
--             advance()
--             advance()
--         else
--             ff()
--         end
--     end
-- end

function yy()
    while Game1.currentMinigame.gameOver == false do
        -- for i, enty in list_items(Game1.currentMinigame._entities) do
        --     if enty:GetType().Name == "BalanceTrack" then
        --         print("found balance track")
        --         return
        --     end
        -- end
        if Game1.currentMinigame.reachedFinish then
            while Game1.currentMinigame.reachedFinish do
                advance()
            end
            while Game1.currentMinigame.gameState ~= SMineCart.GameStates.Ingame do
                advance()
            end
            advance()
            advance()
        else
            local levelsPlayed = GetValue(Game1.currentMinigame, "levelsBeat")
            local lookahead = math.min(levelsPlayed * 10, 500)
            local playout = 30
            if Game1.currentMinigame.currentTheme == 9 then
                lookahead = math.min(levelsPlayed * 10, 1000)
                playout = 5
            end
            local r = Game1.currentMinigame.random:Copy()
            local solution = BestFirstSearch.Search(Game1.currentMinigame, lookahead)
            local r2 = Game1.currentMinigame.random:Copy()
            if r:get_Index() ~= r2:get_Index() then
                print("random state changed")
                return
            end
            if solution == nil then
                print("no solution found")
                return
            end
            if solution.Game.gameOver then
                print('about to die')
                gcf()
            end
            if solution.Game.buttonPresses.Count == 0 then
                print('no defined button presses')
                return
            end
            local n = solution.Game.buttonPresses.Count
            for i = 0, n - 1 do
                local press = solution.Game.buttonPresses[i]
                advance({ mouse = { left = press } })
                if Game1.currentMinigame.reachedFinish then
                    break
                end
                if i >= playout and Game1.currentMinigame.player:IsGrounded() then
                    break
                end
            end
        end
    end
end

-- yy()
function pp()
    printf("%s %s", Game1.currentMinigame._entities.Count, Game1.currentMinigame.random)
end

function zz(frame)
    if frame == nil then
        frame = 1057
    end
    bfreset(frame)
    local state = JunimoKartState(interface:GetMinecart())
    state.Game:Simulate(false)
    advance()
    pp()
    bfreset(frame)
    advance()
    pp()
end

function aa(n)
    if n == nil then
        n = 10000
    end
    local t0 = Controller.Overlays["TimerPanel"].GlobalTimer.ElapsedMilliseconds
    BestFirstSearch.TestClone(n)
    local t1 = Controller.Overlays["TimerPanel"].GlobalTimer.ElapsedMilliseconds
    printf("time: %f\trate: %f/s (clone) [clones: %d, simulates: %d]", (t1 - t0), n / (t1 - t0) * 1000,
        JunimoKartState.Clones, JunimoKartState.Simulates)
end

function bb(n)
    if n == nil then
        n = 100
    end
    local t0 = Controller.Overlays["TimerPanel"].GlobalTimer.ElapsedMilliseconds
    BestFirstSearch.TestNeighbors(n)
    local t1 = Controller.Overlays["TimerPanel"].GlobalTimer.ElapsedMilliseconds
    printf("time: %f\trate: %f/s (neighbors) [clones: %d, simulates: %d]", (t1 - t0), n / (t1 - t0) * 1000,
        JunimoKartState.Clones, JunimoKartState.Simulates)
end

function cc(n, f)
    if n == nil then
        n = 100
    end
    if f == nil then
        f = 60
    end
    local t0 = Controller.Overlays["TimerPanel"].GlobalTimer.ElapsedMilliseconds
    BestFirstSearch.TestSimulate(n, f)
    local t1 = Controller.Overlays["TimerPanel"].GlobalTimer.ElapsedMilliseconds
    printf("time: %f\trate: %f/s (simulate) [clones: %d, simulates: %d]", (t1 - t0), n * f / (t1 - t0) * 1000,
        JunimoKartState.Clones, JunimoKartState.Simulates)
end

function dd(n, md)
    if n == nil then
        n = 100
    end
    if md == nil then
        md = Game1.currentMinigame.distanceToTravel + 8
    end
    -- public static List<JunimoKartState> FindPath(JunimoKartState start, int max_evals)
    local t0 = Controller.Overlays["TimerPanel"].GlobalTimer.ElapsedMilliseconds
    JunimoKartState.Clones = 0
    JunimoKartState.Simulates = 0
    KartBot.MaxDistance = md
    local path = KartBot.FindPath(JunimoKartState(Game1.currentMinigame), n)
    if path == nil then
        print("no path found")
    else
        local sol = path[path.Count - 1]
        for i = 0, sol.Game.buttonPresses.Count - 1 do
            advance({ mouse = { left = sol.Game.buttonPresses[i] } })
        end
        printf("path: %s (%d)", path, path.Count)
        -- while path ~= nil and path.Count > 1 do
        --     local sol = path[1]
        --     if Game1.currentMinigame.gameOver or Game1.currentMinigame.reachedFinish then
        --         break
        --     end
        --     for i, press in list_items(sol.Game.buttonPresses) do
        --         advance({ mouse = { left = press } })
        --     end
        --     path = KartBot.FindPath(JunimoKartState(Game1.currentMinigame), n)
        -- end
        -- printf("solution: %s (gameOver:%s) (finished:%s) (pos%s)", sol.Game.buttonPresses.Count, sol.Game.gameOver,
        --     sol.Game.reachedFinish, sol.Game.player.position)
        -- printf("solution")
    end


    -- local neighbors = KartBot.GetNeighbors(JunimoKartState(Game1.currentMinigame))
    -- printf("neighbors: %s (%d)", neighbors, neighbors.Count)
    -- for i, neighbor in list_items(neighbors) do
    --     printf("neighbor: %s", neighbor)
    -- end
    local t1 = Controller.Overlays["TimerPanel"].GlobalTimer.ElapsedMilliseconds
    printf("time: %f\trate: %f/s (simulate) [clones: %d, simulates: %d]", (t1 - t0), n / (t1 - t0) * 1000,
        JunimoKartState.Clones, JunimoKartState.Simulates)
end

function tt(n)
    if n == nil then
        n = 100
    end
    local playerTile = Game1.currentMinigame.player.position.X // Game1.currentMinigame.tileSize
    local maxTile = Game1.currentMinigame.distanceToTravel + 8
    printf("playerTile: %d maxTile: %d", playerTile, maxTile)
    while playerTile < maxTile do
        KartBot.MaxDistance = math.min(playerTile + 5, maxTile)
        local path = KartBot.FindPath(JunimoKartState(Game1.currentMinigame), n)
        if path == nil then
            print("no path found")
            break
        end
        local sol = path[path.Count - 1]
        for i = 0, sol.Game.buttonPresses.Count - 1 do
            advance({ mouse = { left = sol.Game.buttonPresses[i] } })
        end
        playerTile = Game1.currentMinigame.player.position.X // Game1.currentMinigame.tileSize
    end
end

-- aa()

-- zz()re

-- for i, entity in list_items(Game1.currentMinigame._entities) do
--     if entity:GetType().Name == "BalanceTrack" then


--     end
-- end

-- for i, entity in list_items(Game1.currentMinigame._entities) do
--     if entity:GetType().Name == "BalanceTrack" then
--         printf("found balance track %s", entity.position)
--         for j, track in list_items(entity.connectedTracks) do
--             printf("\tconnected track %s}", track.position)
--         end
--     end
-- end
-- for (int i = 0; i < balanceTrackIndices.Count; i++)
-- {
--     BalanceTrack cloneTrack = (BalanceTrack)clone._entities[balanceTrackIndices[i]];
--     BalanceTrack origTrack = (BalanceTrack)_entities[balanceTrackIndices[i]];
--     foreach (var track in origTrack.connectedTracks)
--     {
--         cloneTrack.connectedTracks.Add(
--             clone._entities[_entities.IndexOf(track)] as BalanceTrack
--         );
--     }
--     foreach (var track in origTrack.counterBalancedTracks)
--     {
--         cloneTrack.counterBalancedTracks.Add(
--             clone._entities[_entities.IndexOf(track)] as BalanceTrack
--         );
--     }
-- }

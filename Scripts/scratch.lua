local scratch = {}

function scratch._spawn()
    local level = -1
    if Game1.currentLocation:GetType().Name == "MineShaft" then
        level = Game1.currentLocation.mineLevel
    end
    return interface:SpawnMineShaft(level + 1)
end

function scratch._test()
    local loc = scratch._spawn()
    local flag = false
    local player = InstanceCurrentPlayer.Get(0).Player
    for k, v in dict_items(loc.Objects) do
        if v.ItemId == "44" then
            local hit = GemNode.EstimateNext(loc)
            print(tostring(current_frame()) .. " => " .. tostring(hit))
            flag = true
        end
    end
    return flag
end

function scratch.gem_node(n, force)
    if n == nil then
        n = 10
    end
    if scratch._test() and force == nil then
        return
    end
    for i = 1, n do
        advance()
        if scratch._test() then
            return
        end
    end
end

-- LuaOverlay.AddData("Book RNG",
--     function()
--         return tostring(scratch.sim_book())
--     end
-- )
-- LuaOverlay.AddData("Curr RNG",
--     function()
--         return tostring(game1_random():get_Index())
--     end
-- )
-- LuaOverlay.AddData("Diff",
--     function()
--         return tostring(scratch.sim_book() - game1_random():get_Index())
--     end
-- )
LuaOverlay.AddData("Prev Frames",
    function()
        local f = Controller.State.FrameStates.Count
        local results = {}
        for i = 1, 10 do
            local s0 = f - i
            local s1 = f - i - 1
            local diff = (
                Controller.State.FrameStates[s0].randomState.index
                - Controller.State.FrameStates[s1].randomState.index
            )
            table.insert(results, tostring(diff))
        end
        return table.concat(results, ", ")
    end
)

-- LuaOverlay.AddData("Hit - BookVoid",
--     function()
--         local r = game1_random()
--         while r:PeekDouble() > 0.0005 do
--             r:NextDouble()
--         end
--         return tostring(r:get_Index())
--     end
-- )

-- LuaOverlay.AddData("Hit - Book",
--     function()
--         local hit = EnemyKill.Estimate()
--         return hit.RareItem
--     end
-- )
-- LuaOverlay.AddData("Hit - Index",
--     function()
--         local hit = EnemyKill.Estimate()
--         return hit.IndexAtSpawnRare
--     end
-- )
-- LuaOverlay.AddData("Hit - Compendium",
--     function()
--         local hit = EnemyKill.Estimate()
--         return hit.VoidBook
--     end
-- )
-- LuaOverlay.AddData("Book RNG",
--     function()
--         return tostring(scratch.sim_book())
--     end
-- )
-- LuaOverlay.AddData("Hit - Ladder",
--     function()
--         local hit = EnemyKill.Estimate()
--         return tostring(hit.Ladder)
--     end
-- )

function scratch.sim_book()
    local r = game1_random()
    local r2 = game1_random()
    r:NextDouble()
    local b = r:NextDouble()
    local threshold = 0.0009
    while b > threshold do
        b = r:NextDouble()
        r2:NextDouble()
    end
    return r2:get_Index()
end

local function _estimate_gem_node(shaft, vec)
    local r = Utility.CreateDaySaveRandom(vec.X * 1000, vec.Y, shaft.mineLevel);
    r:NextDouble()
    local chanceForLadderDown = 0.02
        + 1.0 / shaft.stonesLeftOnThisLevel
        + Game1.player.DailyLuck / 5.0
    if not shaft.ladderHasSpawned and r:NextDouble() < chanceForLadderDown then
        -- spawn ladder
    end
    local item = OverlayManager.Get("MinesRocks"):BreakStone("44", vec.X, vec.Y, Game1.player, r)[0]
    return item
end

function scratch._next_mines()
    local r = game1_random()
    local s = RandomExtensions.SharedRandom:Copy()
    local mineLevel = Game1.currentLocation.mineLevel + 1
    local shaft = SMineShaft(mineLevel, Game1.currentLocation.loadedMapNumber, s)
    shaft.map = SMineShaft.GetMap("Maps\\Mines\\" .. tostring(mineLevel))
    shaft:populateLevel(r)
    return shaft
end

function scratch._estimate_mines()
    local shaft = scratch._next_mines()
    for k, v in dict_items(shaft.Objects) do
        -- print(tostring(k) .. " => " .. tostring(v))
        if v == "GemStone" then
            local item = _estimate_gem_node(shaft, k)
            print(tostring(current_frame()) .. " Rock spawned at: " .. tostring(k) .. " =>  " .. tostring(item))
            return true
        end
    end
    return false
end

function scratch.sim_mines()
    for i = 1, 100 do
        advance()
        if scratch._estimate_mines() then
            return
        end
    end
end

function scratch.spawn()
    local r = game1_random()
    local shaft = interface:SpawnMineShaft(Game1.currentLocation.mineLevel + 1)
    -- GameRunner.instance.gameInstances[ActiveInstance.InstanceIndex].staticVarHolder.Game1_random = r
end

function scratch.sim_swing()
    local hit = EnemyKill.Estimate()
    while hit.Damage > 0 do
        if hit.VoidBook then
            print("Hit with book!")
            return
        end
        advance()
        hit = EnemyKill.Estimate()
    end
end

function scratch.chest_frame(index)
    if index == nil then
        index = ActiveInstance.InstanceIndex
    end
    local loc = InstanceCurrentLocation.Get(index).Location
    if loc.Objects:ContainsKey(V(9, 13)) then
        local chest = loc.Objects[V(9, 13)]
        return chest.frameCounter
    end
    return
end

function scratch.hitfish(index)
    if index == nil then
        index = ActiveInstance.InstanceIndex
    end
    local target = Reflector.GetStaticVar(3, "Game1_screenOverlayTempSprites")[1].endFunction.Target
    local field = target:GetType():GetFields()[1]
    return field:GetValue(target).Name
end

function scratch.ss(l, m)
    if l == nil then
        l = scratch._spawn()
        if m == nil then
            local level = -1
            if Game1.currentLocation:GetType().Name == "MineShaft" then
                level = Game1.currentLocation.mineLevel
            end
            m = string.format("p0fl%d", level + 1)
        end
        interface:ScreenshotLocation(l, m)
    elseif type(l) == 'number' then
        local loc = InstanceCurrentLocation.Get(l).Location
        local name = string.format("p%d%s", l, m or loc.Name)
        interface:ScreenshotLocation(loc, name)
    else
        interface:ScreenshotLocation(l, m or l.Name)
    end
end

function scratch.num_hoedirt()
    local loc = Game1.getLocationFromName("Farm")
    local count = 0
    for k, v in dict_items(loc.terrainFeatures) do
        if v:GetType().Name == "HoeDirt" then
            count = count + 1
        end
    end
    return count
end

function scratch.farm_tiles()
    local tiles = {
        V(63, 26), V(59, 19), V(61, 19), V(62, 24), V(63, 24), V(69, 22),
    }
    for i, v in ipairs(tiles) do
        TileHighlight.Add(v)
    end
end

function scratch.fish()
    local bar = SBobberBar(InstanceCurrentMenu.Get(3).Menu)
    printf("%d\tFish:(%f->%f @ %f)\tBar:(%f @ %f)",
        current_frame(),
        bar.bobberPosition,
        bar.bobberTargetPosition,
        bar.bobberSpeed,
        bar.bobberBarPos,
        bar.bobberBarSpeed
    )
end

return scratch

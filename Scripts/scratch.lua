local scratch = {}

function scratch.p()
    -- Controller.DebugMode = true
    local player = InstanceCurrentPlayer.Get(0).Player
    printf('Frame: %d\tStepsTaken: %d', current_frame(), player.stats.StepsTaken)
    print_dict(FarmCaveSpawns.GetSpawns())
end

function scratch.leave(n, offset)
    if n == nil then
        n = 1000
    end
    if offset == nil then
        offset = 5 + 1
    end
    local r = game1_random()
    for i = 1, n do
        local v = r:NextDouble()
        if v < 0.002 then
            printf("%03d\t%d", i, r:get_Index() - offset)
        end
    end
end

function scratch.pig()
    for k, v in dict_items(InstanceCurrentLocation.Get(0).Location.animals) do
        if v.type.Value == "Pig" then
            return v
        end
    end
end

function scratch.walk_down(n, offset)
    if n == nil then
        n = 100
    end
    if offset == nil then
        offset = 5 + 1
    end
    local r = game1_random()
    local v0 = r:NextDouble()
    local v1 = r:NextDouble()
    for i = 1, n do
        if v0 < 0.007 and v1 < 0.0002 then
            printf("%03d\t%d", i, r:get_Index() - offset)
        end
        v0 = v1
        v1 = r:NextDouble()
    end
end

function scratch.behavior(n, offset)
    if n == nil then
        n = 1000
    end
    if offset == nil then
        offset = 5 + 2
    end
    local r = game1_random()
    local v0 = r:NextDouble()
    local v1 = r:NextDouble()
    for i = 1, n do
        if v0 >= 0.002 and v1 < 0.0002 then
            printf("%03d\t%d", i, r:get_Index() - offset)
        end
        v0 = v1
        v1 = r:NextDouble()
    end
end

function scratch.pet()
    local function n(x)
        return string.format('[%s][Baby:%s]->[f:%d,h:%d]', x.type.Value, x:isBaby(), x.friendshipTowardFarmer.Value,
            x.happiness.Value)
    end
    local function t(x)
        return x.Name
    end
    print(current_frame())
    print_dict(InstanceCurrentLocation.Get(3).Location.animals, n)
    print_list(InstanceCurrentLocation.Get(3).Location.objects[V(3, 8)].heldObject.Value.Items, t)
    -- print_dict(InstanceCurrentLocation.Get(1).Location.animals, n)
    -- print_list(InstanceCurrentLocation.Get(1).Location.objects[V(10, 13)].heldObject.Value.Items, t)
end

function scratch.t(n)
    local rod = fish.get_rod(1)
    local res = {}
    table.insert(res, string.format("Frame: %d", current_frame()))
    if rod.isNibbling then
        table.insert(res, string.format("Nibble: %f", rod.fishingNibbleAccumulator))
        table.insert(res, string.format("FishType: %s", NextFrameFish.Estimate(1).FishType))
    else
        -- advance(),current_frame(),fish.get_rod().timeUntilFishingBite-fish.get_rod().fishingBiteAccumulator
        table.insert(res, "Waiting:" .. tostring(rod.timeUntilFishingBite - rod.fishingBiteAccumulator))
    end
    if InstanceCurrentLocation.Get(0).Location.objects:ContainsKey(V(9, 9)) then
        local chest = InstanceCurrentLocation.Get(0).Location.objects[V(9, 9)]
        local items = chest.Items
        if items.Count > 0 then
            for i, v in list_items(items) do
                table.insert(res, string.format("Item %d: %s x%d", i, v.Name, v.Stack))
            end
            table.insert(res, string.format("Chest Frame: %d", chest.frameCounter.Value))
        end
    end
    print(table.concat(res, "\t"))
    if n then
        scratch._next_monsters()
    end
end

function scratch.animal_id(index)
    if index == nil then
        index = ActiveInstance.InstanceIndex
    end
    --[[
    public virtual long getNewID()
        {
            ulong seqNum = ((this.latestID & 0xFF) + 1) & 0xFF;
            ulong nodeID = (ulong)Game1.player.UniqueMultiplayerID;
            nodeID = (nodeID >> 32) ^ (nodeID & 0xFFFFFFFFu);
            nodeID = ((nodeID >> 16) ^ (nodeID & 0xFFFF)) & 0xFFFF;
            ulong timestamp = (ulong)(DateTime.UtcNow.Ticks / 10000);
            this.latestID = (timestamp << 24) | (nodeID << 8) | seqNum;
            return (long)this.latestID;
        }
    --]]
    local nodeID = InstanceCurrentPlayer.Get(index).Player.UniqueMultiplayerID
    local latestID = Reflector.GetStaticVar(index, "Game1_multiplayer").latestID
    local seqNum = ((latestID & 0xFF) + 1) & 0xFF
    nodeID = (nodeID >> 32) ^ (nodeID & 0xFFFFFFFF)
    nodeID = ((nodeID >> 16) ^ (nodeID & 0xFFFF)) & 0xFFFF
    local timestamp = TASDateTime.UtcNow.Ticks // 10000
    latestID = (timestamp << 24) | (nodeID << 8) | seqNum
    return latestID
end

function scratch.chicken(index)
    if index == nil then
        index = ActiveInstance.InstanceIndex
    end
    local random = InstanceData.Get(index).random;
    random:Next()
    print(random:NextDouble())
end

function scratch.s()
    scratch.ss(Game1.getLocationFromName("FarmCave"), "test_d" .. tostring(Game1.stats.DaysPlayed))
end

local function _steps_taken()
    local player = InstanceCurrentPlayer.Get(0).Player
    return player.stats.StepsTaken
end
local function _dict_diff(curr, new)
    for k, v in dict_items(new) do
        if not curr:ContainsKey(k) then
            print("+ " .. tostring(k) .. " => " .. tostring(v))
        end
    end
end
function scratch.not_watered()
    TileHighlight.Clear()
    for k, v in dict_items(Game1.getLocationFromName("Farm").terrainFeatures) do
        if v:GetType().Name == "HoeDirt" then
            print(tostring(k) .. " watered: " .. tostring(v.state.Value))
            if v.state.Value == 0 then
                TileHighlight.Add(k)
            end
        end
    end
end

function scratch.greenrain()
    --[[
    Layer pathsLayer = this.map.GetLayer("Paths");
            if (pathsLayer != null)
            {
                for (int x = 0; x < pathsLayer.LayerWidth; x++)
                {
                    for (int y = 0; y < pathsLayer.LayerHeight; y++)
                    {
                        Tile tile = pathsLayer.Tiles[x, y];
                        if (tile != null && tile.TileIndexProperties.ContainsKey("GreenRain"))
                        {
                            Vector2 tilePos = new Vector2(x, y);
                            if (!this.IsTileOccupiedBy(tilePos))
                            {
                                this.terrainFeatures.Add(tilePos, (this is Forest) ? new Tree("12", 5, isGreenRainTemporaryTree: true) : new Tree((10 + (Game1.random.NextBool(0.1) ? 2 : Game1.random.Choose(1, 0))).ToString(), 5, isGreenRainTemporaryTree: true));
                            }
                        }
                    }
                }
            }
    --]]
    local loc = Game1.getFarm()
    local pathsLayer = loc.map:GetLayer("Paths")
    if pathsLayer ~= nil then
        for x = 0, pathsLayer.LayerWidth - 1 do
            for y = 0, pathsLayer.LayerHeight - 1 do
                local tile = pathsLayer.Tiles[Location(x, y)]
                if tile ~= nil and tile.TileIndexProperties:ContainsKey("GreenRain") then
                    local tilePos = V(x, y)
                    print(tostring(tilePos))
                end
            end
        end
    end
end

function scratch.step_cave(n)
    if n == nil then
        n = 0
    end
    local steps = -1
    local maxSteps = _steps_taken() + n
    local init_spawns = Game1.getLocationFromName("FarmCave").objects
    printf('Frame: %d\tCURRENT', current_frame())
    print_dict(init_spawns, function(v) return v.Name end)

    while steps < maxSteps do
        if steps == _steps_taken() then
            advance({ keyboard = { Keys.W } })
        else
            steps = _steps_taken()
            print("")
            printf('Frame: %d\tStepsTaken: %d', current_frame(), steps)
            local spawns = FarmCaveSpawns.GetSpawns()
            _dict_diff(init_spawns, spawns)
        end
    end
end

function scratch._spawn(level)
    if level == nil then
        level = -1
        if Game1.currentLocation:GetType().Name == "MineShaft" then
            level = Game1.currentLocation.mineLevel
        end
        level = level + 1
    end
    return interface:SpawnMineShaft(level)
end

function scratch._next_treasure(n)
    if n == nil then
        n = 1
    end
    local r = game1_random()
    local i = 0
    while i < n do
        if r:PeekDouble() < 0.02 then
            printf("%03d\t%d", i, r:get_Index())
            i = i + 1
        end
        r:NextDouble()
    end
end

function scratch.apply(s)
    GamePadInputQueue.SetPlayerCoroutine(1, s)
    GamePadInputQueue.SetPlayerCoroutine(2, s)
    GamePadInputQueue.SetPlayerCoroutine(3, s)
end

function scratch.sleep()
    scratch.apply("sleep")
    printf("%d\t%d", current_frame(), Game1.getFarm().terrainFeatures[V(52, 26)].growthStage.Value)
    scratch.ss(Game1.getFarm(), string.format("d%d_farm", Game1.stats.DaysPlayed))
end

function scratch._next_monsters(level)
    local loc = scratch._spawn(level)
    scratch.ss(loc)
    for i, v in list_items(loc.characters) do
        if v.IsMonster then
            local drops = {}
            for j, item in list_items(v.objectsToDrop) do
                if Game1.objectData:ContainsKey(tostring(item)) then
                    table.insert(drops, Game1.objectData[tostring(item)].Name)
                else
                    table.insert(drops, tostring(item))
                end
            end
            print(tostring(current_frame()) ..
                " Monster spawned: " ..
                tostring(v.Name) .. "[" .. tostring(v.Tile) .. "] with items: " .. table.concat(drops, ", "))
        end
    end
    if loc.mineLevel > 120 then
        -- printf("SC Shaft: %s", tostring(loc.mineRandom:NextDouble() < 0.2))
        local isTreasureRoom = GetValue(loc, "netIsTreasureRoom").Value
        if isTreasureRoom then
            printf("%d\tSC Treasure: %s", current_frame(), tostring(GetValue(loc, "netIsTreasureRoom").Value))
            -- printf("SC Item: %s", tostring(loc.objects[V(9, 9)].Items[0].Name))
        end
    end
end

function scratch._test(loc)
    if loc == nil then
        loc = scratch._spawn()
    end
    local flag = false
    for k, v in dict_items(loc.Objects) do
        if v.ItemId == "44" then
            local hit = GemNode.EstimateNext(loc)
            print(tostring(current_frame()) .. "[" .. loc.Name .. "] => " .. tostring(hit))
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
    local target = Reflector.GetStaticVar(index, "Game1_screenOverlayTempSprites")[1].endFunction.Target
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

function scratch.shake_trees(index)
    if index == nil then
        index = 2
    end
    for k, v in dict_items(InstanceCurrentLocation.Get(index).Location.terrainFeatures) do
        if v:GetType().Name == "Tree" then
            if v.hasSeed.Value then
                printf("Tree at %s has seed", tostring(k))
            end
        end
    end
end

function scratch.farm_chest(index)
    if index == nil then
        index = 2
    end
    local chest = Game1.getFarm().objects[V(56, 24)]
    for k, v in list_items(chest.Items) do
        printf("%s x%d", v.Name, v.Stack)
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

function scratch.setup(index)
    if index == nil then
        index = 3
    end
    LuaOverlay.AddData("fishPos",
        function()
            local menu = InstanceCurrentMenu.Get(index).Menu
            if menu == nil then
                return "nil"
            end
            if menu:GetType().Name ~= 'BobberBar' then
                return "nil"
            end
            return tostring(menu.bobberPosition)
        end
    )
    LuaOverlay.AddData("fishTarget",
        function()
            local menu = InstanceCurrentMenu.Get(index).Menu
            if menu == nil then
                return "nil"
            end
            if menu:GetType().Name ~= 'BobberBar' then
                return "nil"
            end
            return tostring(menu.bobberTargetPosition)
        end
    )
    LuaOverlay.AddData("fishSpeed",
        function()
            local menu = InstanceCurrentMenu.Get(index).Menu
            if menu == nil then
                return "nil"
            end
            if menu:GetType().Name ~= 'BobberBar' then
                return "nil"
            end
            return tostring(menu.bobberSpeed)
        end
    )
    LuaOverlay.AddData("barPos",
        function()
            local menu = InstanceCurrentMenu.Get(index).Menu
            if menu == nil then
                return "nil"
            end
            if menu:GetType().Name ~= 'BobberBar' then
                return "nil"
            end
            return tostring(menu.bobberBarPos)
        end
    )
    LuaOverlay.AddData("barSpeed",
        function()
            local menu = InstanceCurrentMenu.Get(index).Menu
            if menu == nil then
                return "nil"
            end
            if menu:GetType().Name ~= 'BobberBar' then
                return "nil"
            end
            return tostring(menu.bobberBarSpeed)
        end
    )
end

return scratch

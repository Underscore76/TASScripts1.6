local nav = require('navigate')
local frame_funcs = require('frame_funcs')
local input = require('core.input')
local view = require('core.view')

local mines = {
    startFrame = 0,
}

function mines.view()
    local level = 0
    if CurrentLocation.IsMines then
        level = Game1.currentLocation.mineLevel
    end
    view.location(interface:SpawnMineShaft(level + 1))
    if mines.startFrame == 0 then
        mines.startFrame = current_frame()
        print("Entering mine level " .. level + 1 .. " on frame " .. mines.startFrame)
    end
end

function mines.next()
    view.reset()
    advance()
    mines.view()
    print("Frame " .. current_frame() .. " waited " .. (current_frame() - mines.startFrame) .. " frames")
end

function mines.exit()
    view.reset()
    mines.startFrame = 0
end

function mines.wait()
    while Game1.fadeToBlack do
        advance()
    end
end

function mines.save()
    gcf()
    save()
end

local function IsTreasure(loc)
    return GetValue(loc, "netIsTreasureRoom").Value
end
function mines.chest_floor(do_advance)
    if do_advance ~= nil and do_advance ~= 0 then
        advance()
    end
    local level = Game1.currentLocation.mineLevel
    local loc = interface:SpawnMineShaft(level + 1)
    local frames = current_frame()
    while not IsTreasure(loc) do
        advance()
        loc = interface:SpawnMineShaft(level + 1)
    end
    local item = loc.Objects[Vector2(9, 9)].Items[0]
    print(string.format("(%d)\t%s\t%d", current_frame() - frames, item.Name, item.Stack))
end

function mines.chest()
    local item = Game1.currentLocation.Objects[Vector2(9, 9)].Items[0]
    print(string.format("(%d)\t%s\t%d", current_frame(), item.Name, item.Stack))
end

function mines.simulate_ladder_fade()
    local blinkTimer = Game1.player.blinkTimer
    local shouldDrip = RunCS(
        'Game1.isMusicContextActiveButNotPlaying() || Game1.getMusicTrackName().Contains("Ambient")')
    view.location(interface:SpawnMineShaft(Game1.currentLocation.mineLevel + 1))
    for i = 1, 37 do
        blinkTimer = blinkTimer + 16
        if blinkTimer > 2200 and Game1.random:NextDouble() < 0.01 then
            blinkTimer = -150
        end
        if shouldDrip then
            Game1.random:NextDouble()
        end
    end
end

function mines.search(n)
    if n == nil then
        n = 100
    end
    local index = Game1.random:get_Index()
    for i = 0, n do
        local item = interface:TrySpawnChestFloorItem(i)
        if item ~= nil then
            print(string.format("%d\t%s", index + i, item.Name))
        end
    end
end

function mines.estimate(n)
    if n == nil then
        n = 30
    end
    local index = Game1.random:get_Index()
    local blinkTimer = Game1.player.blinkTimer
    local shouldDrip = RunCS(
        'Game1.isMusicContextActiveButNotPlaying() || Game1.getMusicTrackName().Contains("Ambient")')
    if blinkTimer > 2200 then
        index = index + 1
    end
    if shouldDrip then
        index = index + 1
    end
    advance()
    local diff = Game1.random:get_Index() - index
    print(diff)
    for i = 1, n do
        local item = interface:TrySpawnChestFloorItem(i, diff, false)
        if item ~= nil then
            printf("%d\t%s\t%s", current_frame() + i, false, item.Name)
            -- return
        end
        item = interface:TrySpawnChestFloorItem(i, diff, true)
        if item ~= nil then
            printf("%d\t%s\t%s", current_frame() + i, true, item.Name)
            -- return
        end
    end
end

function mines.estimate_diff(diff, n)
    if n == nil then
        n = 30
    end
    if diff == nil then
        error("diff is required")
    end
    for i = 1, n do
        local item = interface:TrySpawnChestFloorItem(i, diff, false)
        if item ~= nil then
            printf("%d\t%s\t%s", current_frame() + i, false, item.Name)
            -- return
        end
        item = interface:TrySpawnChestFloorItem(i, diff, true)
        if item ~= nil then
            printf("%d\t%s\t%s", current_frame() + i, true, item.Name)
            -- return
        end
    end
end

function mines.time()
    local t0 = os.time()
    -- mines.estimate(200)
    for i = 1, 20000 do
        SkullCavernsChests.Evaluate()
    end
    local t1 = os.time()
    print(t1 - t0)
end

function mines.test()
    local n = 1
    local x = SkullCavernsSimulator(n)
    x.State.CurrentFrame = current_frame()
    x.State.PreviousMapNumber = Game1.currentLocation.loadedMapNumber
    x.State.CurrentMineLevel = Game1.currentLocation.mineLevel
    -- valid to here
    -- x:Pause()
    -- x:CreateBigCraftable()
    -- while x.State.CurrentFrame < 6589 do
    --     x:Pause()
    -- end
    x:Unpause()
    printf("%d,%d", game1_random():get_Index(), RandomExtensions.SharedRandom:get_Index())
    print(x.ChestItems[0].Name)
    -- for i = 1, n do
    --     x.State.Game1_random:NextDouble()
    -- end
    -- x.State.blinkTimer = x.State.blinkTimer + 16
    -- if x.State.blinkTimer > 2200 and x.State.Game1_random:NextDouble() < 0.01 then
    --     x.State.blinkTimer = -150
    -- end
    -- if x.State.doDrip then
    --     x.State.Game1_random:NextDouble()
    -- end
    -- x.State.SharedRandom:Next();
    -- x.State.CurrentFrame = x.State.CurrentFrame + 1

    -- x.State.Shaft = SMineShaft(x.State.CurrentMineLevel + 1, x.State.PreviousMapNumber, x.State.SharedRandom)
    -- x.State.Shaft:generateContents(x.State.Game1_random);
    -- if not x.State.Shaft.isTreasureRoom then
    --     return x
    -- end

    -- for i = 1, 38 do
    --     x.State.blinkTimer = x.State.blinkTimer + 16
    --     if x.State.blinkTimer > 2200 and x.State.Game1_random:NextDouble() < 0.01 then
    --         x.State.blinkTimer = -150
    --     end
    --     if x.State.doDrip then
    --         x.State.Game1_random:NextDouble()
    --     end
    --     x.State.SharedRandom:Next()
    --     x.State.CurrentFrame = x.State.CurrentFrame + 1
    -- end

    -- x.State.Shaft:addLevelChests(x.State.Game1_random);

    return x
end

function mines.test2()
    printf("%d,%d", game1_random():get_Index(), RandomExtensions.SharedRandom:get_Index())
    local blinkTimer = Game1.player.blinkTimer
    local shouldDrip = RunCS(
        'Game1.isMusicContextActiveButNotPlaying() || Game1.getMusicTrackName().Contains("Ambient")')
    print(shouldDrip)
    local r = game1_random()
    local s = RandomExtensions.SharedRandom:Copy()

    local shaft = SMineShaft(Game1.currentLocation.mineLevel + 1, Game1.currentLocation.loadedMapNumber, s)
    shaft:generateContents(r)
    printf("%d,%d", r:get_Index(), shaft.mineRandom:get_Index())
    for i = 1, 38 do
        blinkTimer = blinkTimer + 16
        if blinkTimer > 2200 and r:NextDouble() < 0.01 then
            blinkTimer = -150
        end
        if shouldDrip then
            r:NextDouble()
        end
        s:Next()
    end
    -- print(SMineShaft.getTreasureRoomItem(r).Name)
    shaft:addLevelChests(r)
    -- import('TASMod.Simulators.SkullCaverns')
    return shaft
end

function mines.find(index_lookahead)
    if index_lookahead == nil then
        index_lookahead = 200
    end
    local function diff()
        local index = Game1.random:get_Index()
        local blinkTimer = Game1.player.blinkTimer
        local shouldDrip = RunCS(
            'Game1.isMusicContextActiveButNotPlaying() || Game1.getMusicTrackName().Contains("Ambient")')
        if blinkTimer > 2200 then
            index = index + 1
        end
        if shouldDrip then
            index = index + 1
        end
        advance()
        return Game1.random:get_Index() - index
    end
    local unpause_calls = diff()
    print(unpause_calls)
    local desiredItems = {
        "(BC)21", -- larium
        "(O)645", -- iridium sprinkler
        "(BC)25", -- seed maker
    }

    local indexes = SkullCavernsSolver.GetItemIndexes(desiredItems[1], index_lookahead)
    for i, item in ipairs(desiredItems) do
        if i == 1 then goto continue end
        indexes:AddRange(SkullCavernsSolver.GetItemIndexes(item, index_lookahead))
        ::continue::
    end
    printf("Searching across %d indexes", indexes.Count)
    local x = SkullCavernsSolver.SolveMany(unpause_calls, indexes)
    if x == nil then
        print("No solution found")
        return
    end
    print_list(x.FrameData)
    local flag = false
    if Game1.activeClickableMenu == nil then
        -- need to pause
        flag = true
        advance({ keyboard = { Keys.E } })
    end
    local craft_icon = Game1.activeClickableMenu.tabs[4].bounds.Center
    local objects = {}
    local big_crafts = {}
    for k, v in dict_items(Game1.activeClickableMenu.pages[4].pagesOfCraftingRecipes[0]) do
        if v.bigCraftable and #big_crafts < 2 then
            table.insert(big_crafts, k.bounds.Center)
        elseif #objects < 2 then
            table.insert(objects, k.bounds.Center)
        end
    end
    local obj_index = 1
    local big_index = 1
    -- run the solution
    for i, step in list_items(x.FrameData) do
        if flag then
            -- first frame already run
            flag = false
            goto continue
        end
        local elements = string.split(step, "\t")
        local command = elements[#elements]
        if command == "noop" then
            advance()
        elseif command == "click_craft" then
            advance({ mouse = { X = craft_icon.X, Y = craft_icon.Y, left = true } })
        elseif command == "mouse_object" then
            local object = objects[obj_index]
            obj_index = (obj_index % 2) + 1
            advance({ mouse = { X = object.X, Y = object.Y } })
        elseif command == "mouse_big" then
            local object = big_crafts[big_index]
            big_index = (big_index % 2) + 1
            advance({ mouse = { X = object.X, Y = object.Y } })
        elseif command == "unpause" then
            -- need to assert that we don't mouse over any items in the crafting page
            local m = input.get_mouse_tile_from_global(15, 11)
            advance({ mouse = { X = math.floor(m.X), Y = math.floor(m.Y) }, keyboard = { Keys.Escape } })
        end
        ::continue::
    end

    local threshold = Game1.player.DailyLuck / 10.0 + Game1.player.LuckLevel / 100.0
    if game1_random():NextDouble() >= threshold then
        print('attempt failed')
    end
    return x
end

function mines.walk(n)
    if n == nil then
        n = 200
    end
    local click_chest = frame_funcs.click_chest(Vector2(9, 9))
    local frame_func = function()
        local chest = Game1.currentLocation.Objects[Vector2(9, 9)]
        if chest == nil or chest.Items.Count == 0 then
            if Game1.activeClickableMenu ~= nil then
                return { override_keyboard = true, keyboard = { Keys.Escape } }
            end
            return {}
        end
        return click_chest()
    end
    -- nav.generate_path(Vector2(10, 8))
    nav.walk_to_tile(Vector2(10, 8), frame_func, nil, false, false)
    nav.walk_to_tile(Vector2(14, 10), frame_func, nil, true)
    mines.find(n)
end

function mines.pause_chest()
    local chest = Game1.currentLocation.Objects[Vector2(9, 9)]
    local maxId = chest:getLastLidFrame()
    while GetValue(chest, "currentLidFrame") ~= maxId do
        advance()
    end
    while chest.frameCounter.Value > 1 do
        advance()
    end
    advance({ keyboard = { Keys.E } })
    advance({ keyboard = { Keys.Escape } })
end

return mines

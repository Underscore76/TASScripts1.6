--[[
basic time benchmark:

cloning can do about 100-120 actions per ms
clone + step can do about 80-100 actions per ms

X = 1/110
Y + X = 1/90
=> Y ~= 1/500 or 500 actions per ms
]]

-- local b = {}
-- function b.benchmark(steps, do_step)
--     if steps == nil then
--         steps = 1000
--     end
--     if do_step == nil then
--         do_step = false
--     end
--     local f = SFishingGame()
--     local t0 = OverlayManager.Get('timerpanel').GlobalTimer.Elapsed
--     for i = 1, steps do
--         -- local x = f:Copy()
--         if do_step then
--             f:Step(false)
--         end
--     end
--     local t1 = OverlayManager.Get('timerpanel').GlobalTimer.Elapsed
--     local ms = (t1 - t0).TotalMilliseconds
--     printf("%d->%f->%f", steps, ms, steps / ms)
-- end

-- function b.manip(n, pause)
--     if n == nil then
--         n = 20
--     end
--     if pause == nil then
--         pause = 0
--     end
--     -- fish.manip_catch({"267","708"},20)
--     -- fish.manip_nibble(60,30,58)
--     -- fish.manip_catch_treasure(30)
--     local f = SFishingGame()
--     local t = f.bobberBar.bobberTargetPosition
--     for i = 1, pause do
--         f:Step(false)
--     end
--     local flag = true
--     for i = 1, n do
--         f:Step(flag)
--         flag = not flag
--     end
--     printf("%f->%f", t, f.bobberBar.bobberTargetPosition)
-- end

-- function b.treasure()
--     local f = SFishingGame()
--     local d = {
--         true,
--         true,
--         false,
--         true,
--         true,
--         false,
--         true,
--         false,
--         false,
--     }
--     for i, v in ipairs(d) do
--         f:Step(v)
--         printf("%03d:\t(%s)\tC:%f\tT:%f\tF:%f",
--             i,
--             f.bobberBar.bobberInBar,
--             f.bobberBar.distanceFromCatching,
--             f.bobberBar.treasurePosition,
--             f.bobberBar.bobberTargetPosition
--         )
--     end
-- end

-- function b.t()
--     local f = SFishingGame()
--     -- local flag = true
--     -- f:updateActiveMenu(flag)
--     -- local t0 = f.Game1_random:get_Index()
--     -- f:UpdateCharacters(flag)
--     -- local t1 = f.Game1_random:get_Index()
--     -- print(t1-t0)
--     return f
-- end

-- function b.sim(t)
--     if t == nil then
--         error("t cannot be nil")
--     end
--     local f = SFishingGame()
--     for i = 1, string.len(t) do
--         local c = string.sub(t, i, i)
--         if c == 'T' then
--             f:Step(true)
--         else
--             f:Step(false)
--         end
--         printf("%03d:\tClick:%s\tS:(%s)\tC:%f\tT:%f\tF:%f->%f\tB:%f->%f\t%d",
--             i + current_frame(),
--             c,
--             f.bobberBar.bobberInBar,
--             f.bobberBar.distanceFromCatching,
--             f.bobberBar.treasurePosition,
--             f.bobberBar.bobberPosition,
--             f.bobberBar.bobberTargetPosition,
--             f.bobberBar.bobberBarPos - 20,
--             f.bobberBar.bobberBarPos + f.bobberBar.bobberBarHeight - 48,
--             f.Game1_random:get_Index()
--         )
--     end
--     print(f.Game1_random)
-- end

-- function b.run(t)
--     if t == nil then
--         error("t cannot be nil")
--     end
--     local flag = true
--     for i = 1, string.len(t) do
--         local c = string.sub(t, i, i)
--         if c == 'T' then
--             if flag then
--                 advance({ mouse = { left = true } })
--             else
--                 advance({ keyboard = { Keys.C } })
--             end
--             flag = not flag
--         else
--             advance()
--         end
--     end
-- end
fish = require('fishing')
local cache = {}

local function eval(steps)
    if type(steps) ~= "table" then
        error("steps must be a table")
    end
    local x = SGame1()
    for k, v in ipairs(steps) do
        if v == 1 then
            x:Press()
        else
            x:Release()
        end
    end
    return x
end

local function find_best_sequence(n)
    if type(n) ~= "number" or n < 1 then
        error("n must be a positive integer")
    end
    local best_seq = nil
    local best_dist = math.huge
    local function search(seq, depth)
        if depth > n then
            local g = eval(seq)
            local x = g.bobberBar.bobberTargetPosition
            local treasure_pos = g.bobberBar.treasurePosition
            local dist = math.abs(x - treasure_pos)
            if dist < best_dist then
                best_dist = dist
                best_seq = { table.unpack(seq) }
            end
            return
        end
        seq[depth] = 0
        search(seq, depth + 1)
        seq[depth] = 1
        search(seq, depth + 1)
    end
    search({}, 1)
    return best_seq, best_dist
end

local function scan_low_spawn_treasure(n)
    if type(n) ~= "number" or n < 1 then
        error("n must be a positive integer")
    end
    local best_seq = nil
    local best_height = 0
    local function search(seq, depth)
        if depth > n then
            local x = eval(seq) -- side effect to update treasureAppearTimer and treasureCatchLevel
            if x.bobberBar.treasurePosition ~= 0 then
                if x.bobberBar.treasurePosition > best_height then
                    best_height = x.bobberBar.treasurePosition
                    best_seq = { table.unpack(seq) }
                end
            end
            return
        end
        seq[depth] = 0
        search(seq, depth + 1)
        seq[depth] = 1
        search(seq, depth + 1)
    end
    search({}, 1)
    return best_seq, best_height
end

LuaOverlay.AddData("AlignToTreasure",
    function()
        if Game1.activeClickableMenu == nil then
            return "nil"
        end
        if Game1.activeClickableMenu:GetType().Name ~= 'BobberBar' then
            return "nil"
        end
        if Controller.State.Count ~= current_frame() then
            return "nil"
        end
        return tostring(eval({ 1, 1 }).bobberBar.bobberTargetPosition)
    end
)

LuaOverlay.AddData("Press2Target",
    function()
        if Game1.activeClickableMenu == nil then
            return "nil"
        end
        if Game1.activeClickableMenu:GetType().Name ~= 'BobberBar' then
            return "nil"
        end
        if Controller.State.Count ~= current_frame() then
            return "nil"
        end
        return tostring(eval({ 1, 1 }).bobberBar.bobberTargetPosition)
    end
)
LuaOverlay.AddData("PressTarget",
    function()
        if Game1.activeClickableMenu == nil then
            return "nil"
        end
        if Game1.activeClickableMenu:GetType().Name ~= 'BobberBar' then
            return "nil"
        end
        if Controller.State.Count ~= current_frame() then
            return "nil"
        end
        return tostring(eval({ 1 }).bobberBar.bobberTargetPosition)
    end
)
LuaOverlay.AddData("ReleaseTarget",
    function()
        if Game1.activeClickableMenu == nil then
            return "nil"
        end
        if Game1.activeClickableMenu:GetType().Name ~= 'BobberBar' then
            return "nil"
        end
        if Controller.State.Count ~= current_frame() then
            return "nil"
        end
        return tostring(eval({ 0 }).bobberBar.bobberTargetPosition)
    end
)
LuaOverlay.AddData("Release2Target",
    function()
        if Game1.activeClickableMenu == nil then
            return "nil"
        end
        if Game1.activeClickableMenu:GetType().Name ~= 'BobberBar' then
            return "nil"
        end
        if Controller.State.Count ~= current_frame() then
            return "nil"
        end
        return tostring(eval({ 0, 0 }).bobberBar.bobberTargetPosition)
    end
)

LuaOverlay.AddData("bobberTargetPosition",
    function()
        if Game1.activeClickableMenu == nil then
            return "nil"
        end
        if Game1.activeClickableMenu:GetType().Name ~= 'BobberBar' then
            return "nil"
        end
        return tostring(Game1.activeClickableMenu.bobberTargetPosition)
    end
)

LuaOverlay.AddData("treasureAppearTimer",
    function()
        if Game1.activeClickableMenu == nil then
            return "nil"
        end
        if Game1.activeClickableMenu:GetType().Name ~= 'BobberBar' then
            return "nil"
        end
        if not Game1.activeClickableMenu.treasure or Game1.activeClickableMenu.treasureAppearTimer <= 0 then
            return "nil"
        end
        return tostring(Game1.activeClickableMenu.treasureAppearTimer)
    end
)

LuaOverlay.AddData("treasureCatchLevel",
    function()
        if Game1.activeClickableMenu == nil then
            return "nil"
        end
        if Game1.activeClickableMenu:GetType().Name ~= 'BobberBar' then
            return "nil"
        end
        if not Game1.activeClickableMenu.treasure or Game1.activeClickableMenu.treasureCaught then
            return "nil"
        end
        return tostring(Game1.activeClickableMenu.treasureCatchLevel)
    end
)

LuaOverlay.AddData("fishCatchLevel",
    function()
        if Game1.activeClickableMenu == nil then
            return "nil"
        end
        if Game1.activeClickableMenu:GetType().Name ~= 'BobberBar' then
            return "nil"
        end

        return tostring(Game1.activeClickableMenu.distanceFromCatching)
    end
)

LuaOverlay.AddData("FishingLevel",
    function()
        if Game1.player == nil then
            return "nil"
        end
        local level = Game1.player.FishingLevel
        local xp = Game1.player.experiencePoints[1]
        return string.format("%d,%d", level, xp)
    end
)

local function _run_command(cmd)
    Controller.Console:RunOnNextUpdate(cmd)
end
-- local _fish = require('fishing')

LuaOverlay.AddButton("ManipNibble",
    function()
        _run_command("fish.manip_nibble_depth_5(100,30)")
    end
)

LuaOverlay.AddButton("WaitNibble",
    function()
        _run_command("fish.wait_nibble()")
    end
)

LuaOverlay.AddButton("CatchTreasure",
    function()
        _run_command("fish.manip_catch_treasure(30)")
    end
)

LuaOverlay.AddButton("GetToScan",
    function()
        _run_command("fish.get_to_scan()")
    end
)

LuaOverlay.AddButton("ScanTreasure",
    function()
        _run_command("fish.scan_treasure(30)")
    end
)

LuaOverlay.AddButton("CollectTreasure",
    function()
        _run_command("fish.collect()")
    end
)

LuaOverlay.AddData("BestSequenceToTreasure", function()
    if Game1.activeClickableMenu == nil then
        return "nil"
    end
    if Game1.activeClickableMenu:GetType().Name ~= 'BobberBar' then
        return "nil"
    end
    if Controller.State.Count ~= current_frame() then
        return "nil"
    end
    local n = 5 -- You can change this value or make it dynamic
    local seq, dist = find_best_sequence(n)
    if not seq then
        return "nil"
    end
    return string.format("[%s] dist=%.4f", seq[1], dist)
end)

LuaOverlay.AddData("LowSpawnTreasure", function()
    if Game1.activeClickableMenu == nil then
        return "nil"
    end
    if Game1.activeClickableMenu:GetType().Name ~= 'BobberBar' then
        return "nil"
    end
    if Controller.State.Count ~= current_frame() then
        return "nil"
    end
    if Game1.activeClickableMenu.treasurePosition ~= 0 then
        return tostring(Game1.activeClickableMenu.treasurePosition)
    end
    local n = 10
    if Game1.activeClickableMenu.treasureAppearTimer > n * 16 or Game1.activeClickableMenu.treasureAppearTimer < 0 then
        return "nil"
    end
    local seq, height = scan_low_spawn_treasure(n)
    if not seq then
        return "nil"
    end
    return string.format("[%s] dist=%.4f", seq[1], height)
end)

--[[
basic time benchmark:

cloning can do about 100-120 actions per ms
clone + step can do about 80-100 actions per ms

X = 1/110
Y + X = 1/90
=> Y ~= 1/500 or 500 actions per ms
]]

local b = {}
function b.benchmark(steps, do_step)
    if steps == nil then
        steps = 1000
    end
    if do_step == nil then
        do_step = false
    end
    local f = SFishingGame()
    local t0 = OverlayManager.Get('timerpanel').GlobalTimer.Elapsed
    for i=1,steps do
        -- local x = f:Copy()
        if do_step then
            f:Step(false)
        end
    end
    local t1 = OverlayManager.Get('timerpanel').GlobalTimer.Elapsed
    local ms = (t1-t0).TotalMilliseconds
    printf("%d->%f->%f", steps, ms, steps/ms)
end

function b.manip(n,pause)
    if n == nil then
        n = 20
    end
    if pause == nil then
        pause = 0
    end
    -- fish.manip_catch({"267","708"},20)
    -- fish.manip_nibble(60,30,58)
    -- fish.manip_catch_treasure(30)
    local f = SFishingGame()
    local t = f.bobberBar.bobberTargetPosition
    for i=1,pause do
        f:Step(false)
    end
    local flag = true
    for i=1,n do
        f:Step(flag)
        flag = not flag
    end
    printf("%f->%f",t, f.bobberBar.bobberTargetPosition)
end

function b.treasure()
    local f = SFishingGame()
    local d = {
        true,
        true,
        false,
        true,
        true,
        false,
        true,
        false,
        false,
    }
    for i,v in ipairs(d) do
        f:Step(v)
        printf("%03d:\t(%s)\tC:%f\tT:%f\tF:%f",
            i,
            f.bobberBar.bobberInBar,
            f.bobberBar.distanceFromCatching,
            f.bobberBar.treasurePosition,
            f.bobberBar.bobberTargetPosition
        )
    end
end

function b.t()
    local f = SFishingGame()
    -- local flag = true
    -- f:updateActiveMenu(flag)
    -- local t0 = f.Game1_random:get_Index()
    -- f:UpdateCharacters(flag)
    -- local t1 = f.Game1_random:get_Index()
    -- print(t1-t0)
    return f
end

function b.sim(t)
    if t == nil then
        error("t cannot be nil")
    end
    local f = SFishingGame()
    for i = 1, string.len(t) do
        local c = string.sub(t, i, i)
        if c == 'T' then
            f:Step(true)
        else
            f:Step(false)
        end
        printf("%03d:\tClick:%s\tS:(%s)\tC:%f\tT:%f\tF:%f->%f\tB:%f->%f\t%d",
            i+current_frame(),
            c,
            f.bobberBar.bobberInBar,
            f.bobberBar.distanceFromCatching,
            f.bobberBar.treasurePosition,
            f.bobberBar.bobberPosition,
            f.bobberBar.bobberTargetPosition,
            f.bobberBar.bobberBarPos-20,
            f.bobberBar.bobberBarPos+f.bobberBar.bobberBarHeight-48,
            f.Game1_random:get_Index()
       )
    end
    print(f.Game1_random)
end

function b.run(t)
    if t == nil then
        error("t cannot be nil")
    end
    local flag = true
    for i = 1, string.len(t) do
        local c = string.sub(t, i, i)
        if c == 'T' then
            if flag then
                advance({mouse={left=true}})
            else
                advance({keyboard={Keys.C}})
            end
            flag = not flag
        else
            advance()
        end
    end
end

LuaOverlay.AddData("treasureAppearTimer",
    function ()
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
    function ()
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
    function ()
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
    function ()
        if Game1.player == nil then
            return "nil"
        end
        local level = Game1.player.FishingLevel
        local xp = Game1.player.experiencePoints[1]
        return string.format("%d,%d", level, xp)
    end
)

-- local _fish = require('fishing')
LuaOverlay.AddButton("ManipNibble",
    function()
        Controller.Console.entryText = "fish.manip_nibble(80,30)"
    end
)

LuaOverlay.AddButton("WaitNibble",
    function()
        Controller.Console.entryText = "fish.wait_nibble()"
    end
)

LuaOverlay.AddButton("CatchTreasure",
    function()
        Controller.Console.entryText = "fish.manip_catch_treasure(30)"
    end
)

LuaOverlay.AddButton("ScanTreasure",
    function()
        Controller.Console.entryText = "fish.scan_treasure(30)"
    end
)

return b

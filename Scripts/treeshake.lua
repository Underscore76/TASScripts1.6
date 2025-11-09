local treeshake = {}

local function mouseTile(m)
    if m == nil then
        m = Mouse.GetState()
    end
    local coords = Vector2(m.X / Game1.options.zoomLevel + Game1.viewport.X,
        m.Y / Game1.options.zoomLevel + Game1.viewport.Y)
    local mTile = Vector2(coords.X // Game1.tileSize, coords.Y // Game1.tileSize)
    return mTile
end

local function getTree(m)
    local tile = mouseTile(m)
    if not Game1.currentLocation.terrainFeatures:ContainsKey(tile) then
        return nil
    end
    local tf = Game1.currentLocation.terrainFeatures[tile]
    if tf:GetType().Name ~= "Tree" then
        return nil
    end
    return tf
end

function treeshake.try()
    local tree = getTree()
    if tree == nil or tree.maxShake ~= 0 then
        return 0
    end
    local r = Game1.random:Copy()
    if r:NextDouble() < 0.66 then
        local numLeaves = r:Next(1, 6)
        for i = 1, numLeaves do
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
        end
    end
    if r:NextDouble() < 0.01 then
        local n = 0
        while r:NextDouble() < 0.8 do
            r:NextDouble()
            r:NextDouble()
            n = n + 1
        end
        if n > 0 then
            print(string.format('%d butterfly', n))
        end
    end
    return r:get_Index() - Game1.random:get_Index()
end

function treeshake.shake(m)
    if m == nil then
        m = Mouse.GetState()
    end
    local tree = getTree(m)
    if tree == nil or tree.maxShake ~= 0 then
        return
    end
    print(string.format("%d:\t%d\t%f", TASDateTime.CurrentFrame, Game1.random:get_Index(), tree.maxShake))
    advance({ mouse = { right = true, X = m.X, Y = m.Y } })
    while tree.maxShake ~= 0 do
        print(string.format("%d:\t%d\t%f", TASDateTime.CurrentFrame, Game1.random:get_Index(), tree.maxShake))
        advance({ mouse = { X = m.X, Y = m.Y } })
    end
    print(string.format("%d:\t%d\t%f", TASDateTime.CurrentFrame, Game1.random:get_Index(), tree.maxShake))
end

function treeshake.butterfly(m)
    local tree = getTree(m)
    if tree == nil or tree.maxShake ~= 0 then
        return 0
    end
    local r = Game1.random:Copy()
    if r:NextDouble() < 0.66 then
        local numLeaves = r:Next(1, 6)
        for i = 1, numLeaves do
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
        end
    end
    if r:NextDouble() < 0.01 then
        local n = 0
        while r:NextDouble() < 0.8 do
            r:NextDouble()
            r:NextDouble()
            n = n + 1
        end
        return n
    end
    return 0
end

function treeshake.wait(n, k)
    local m1 = { X = 888, Y = 489 }
    local m2 = { X = 950, Y = 617 }
    local flag = true
    if n == nil then
        n = 1
    end
    if k == nil then
        k = 5
    end
    advance({ mouse = { X = m1.X, Y = m1.Y } })
    for i = 1, n do
        if flag then
            while treeshake.butterfly(m1) < k do
                advance({ mouse = { X = m1.X, Y = m1.Y } })
            end
            advance({ mouse = { X = m1.X, Y = m1.Y, right = true } })
            advance({ mouse = { X = m2.X, Y = m2.Y } })
        else
            while treeshake.butterfly(m2) < k do
                advance({ mouse = { X = m2.X, Y = m2.Y } })
            end
            advance({ mouse = { X = m2.X, Y = m2.Y, right = true } })
            advance({ mouse = { X = m1.X, Y = m1.Y } })
        end
        flag = not flag
    end
end

function treeshake.min_butterfly(n)
    if n == nil then
        n = 10
    end
    while treeshake.butterfly() < n do
        advance()
    end
    treeshake.shake()
end

function treeshake.clear()
    RandomExtensions.StackTraces:Clear()
end

function treeshake.dump()
    exec('dump_random')
end

local function count(random)
    local r = nil
    if random == nil then
        r = Game1.random:Copy()
    else
        r = random:Copy()
    end
    if r:NextDouble() < 0.66 then
        local numLeaves = r:Next(1, 6)
        for i = 1, numLeaves do
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
        end
    end
    if r:NextDouble() < 0.01 then
        local n = 0
        while r:NextDouble() < 0.8 do
            -- init call
            r:NextDouble()
            r:NextDouble()
            -- spawn butterfly
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
            r:NextDouble()
            n = n + 1
        end
        return n
    end
    return 0
end
function treeshake.max_butterfly(n, f)
    if n == nil then
        n = 100
    end
    if f == nil then
        f = 10000
    end
    local r = Game1.random:Copy()
    local c = count(r)
    local t = nil
    print(string.format("%d\t%d", r:get_Index(), c))
    local max = 0
    local i = 0
    while c < n do
        r:NextDouble()
        c = count(r)
        if c > max then
            print(string.format("%d\t%d", r:get_Index(), c))
            max = c
            t = r:Copy()
        end
        i = i + 1
        if i > f then
            break
        end
    end
    return t
end

return treeshake

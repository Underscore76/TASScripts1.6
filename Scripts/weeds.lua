local weeds = { hasHat = false, verbose = false }

function weeds.get_drop(random)
    if random == nil then
        random = Game1.random:Copy()
    end
    -- print(random)
    local toDrop = nil
    if random:NextDouble() < 0.5 then
        toDrop = "Fiber"
    elseif random:NextDouble() < 0.05 then
        toDrop = "Mixed Seeds"
    end
    for i = 1, 6 do
        random:NextDouble() -- sprites
    end
    weeds.hasHat = (random:NextDouble() < 1e-5) or weeds.hasHat
    random:NextDouble() -- qi beans
    if toDrop ~= nil then
        -- print(Runner.gamePtr.game1.objectInformation[toDrop])
        random:NextDouble() -- object.Flipped
        random:NextDouble() -- Debris::InitializeChunk causes sinkTimer to be set
    end
    random:NextDouble()     -- frog
    return toDrop
end

function weeds.get_drops(num_weeds, random)
    if random == nil then
        random = Game1.random:Copy()
    end
    if num_weeds == nil then
        num_weeds = 1
    end
    random:NextDouble()
    random:NextDouble()
    weeds.hasHat = false
    local drops = {
        ["Fiber"] = 0,      -- fiber
        ["Mixed Seeds"] = 0 -- mixed seeds
    }
    for i = 1, num_weeds do
        local d = weeds.get_drop(random)
        if d ~= nil then
            drops[d] = drops[d] + 1
        end
    end
    drops['hat'] = weeds.hasHat
    return drops
end

function weeds.invert(num_weeds, num_fiber, num_mixed, max_scan)
    if num_weeds == nil then
        num_weeds = 1
    end
    if num_fiber == nil then
        num_fiber = 0
    end
    if num_mixed == nil then
        num_mixed = 1
    end
    if max_scan == nil then
        max_scan = 50
    end
    local r = Game1.random:Copy()
    for i = 0, max_scan do
        local d = weeds.get_drops(num_weeds, copy_random(r))
        if d['Fiber'] >= num_fiber and d['Mixed Seeds'] >= num_mixed then
            printf('offset: %d', i)
            return
        end
        r:NextDouble()
    end
    print('unknown offset')
end

function weeds.search_hat_offset(num_weeds, max_scan)
    if num_weeds == nil then
        num_weeds = 1
    end
    if max_scan == nil then
        max_scan = 10000
    end
    local r = Game1.random:Copy()
    for i = 0, max_scan do
        local drops = weeds.get_drops(num_weeds, copy_random(r))
        if drops['hat'] then
            printf('FOUND HAT: offset %d', i)
            return
        end
        r:NextDouble()
    end
    printf('not within %d checks', max_scan)
end

function weeds.wait(num_weeds, num_mixed, max_scan)
    function _print(f, t)
        print(f)
        print(t)
    end

    if num_weeds == nil then
        num_weeds = 1
    end
    if num_mixed == nil or num_mixed > num_weeds then
        num_mixed = num_weeds
    end
    if max_scan == nil then
        max_scan = 20
    end

    local drops = {}
    for i = 1, max_scan do
        drops = weeds.get_drops(num_weeds)
        if len(drops) > 0 then
            _print(current_frame(), drops)
        end
        if drops['Mixed Seeds'] == num_mixed then
            print("success")
            return
        end
        advance()
    end
    drops = weeds.get_drops(num_weeds)
    if len(drops) > 0 then
        _print(current_frame(), drops)
    end
end

-- function weeds.get_hat(num_weeds, max_frames)
--     if num_weeds == nil then
--         num_weeds = 1
--     end
--     if max_frames == nil then
--         max_frames = 100
--     end
--     for i = 1, max_frames do
--         weeds.estimate(num_weeds)
--         if weeds.hasHat then
--             print("FOUND HAT")
--             return
--         end
--         advance()
--     end
-- end

-- function weeds.debris()
--     local x = Inspect("Game1.currentLocation.debris")
--     for v in list_items(x) do
--         if v.debrisType:ToString() == "OBJECT" then
--             print(string.format("%s\t%s", v.Chunks[0].position.Value:ToString(), v.chunksMoveTowardPlayer))
--         end
--     end
-- end

return weeds

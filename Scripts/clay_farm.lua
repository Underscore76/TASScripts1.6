local movement = require('movement')
local nav = require('navigate')
local function IsTilled(tile)
    return Game1.currentLocation.terrainFeatures:ContainsKey(tile)
end

local c = {}
function c.dist(a, b)
    return (a - b):Length() * 64 / 5.28
end

function c.select_next()
    local tile = Game1.player.Tile
    local clay = interface:GetClay()
    local min_tile = Vector2(0, 0)
    local min_dist = nil
    for i, v in list_items(clay) do
        local is_tilled = IsTilled(v)
        for i, b in list_items(Game1.currentLocation.buildings) do
            if b:occupiesTile(tile) then
                goto continue
            end
        end
        local dist = c.dist(tile, v)
        if is_tilled then
            dist = dist + 12
        end
        if min_dist == nil then
            min_tile = v
            min_dist = dist
        else
            if dist < min_dist then
                min_tile = v
                min_dist = dist
            end
        end
        ::continue::
    end
    if min_dist == nil then
        return nil
    end
    return { tile = min_tile, dist = min_dist }
end

function c.run()
    if Game1.player.Stamina <= 4 then
        return
    end
    local tile = Game1.player.Tile
    local clay_tile = c.select_next()
    if clay_tile == nil then
        return
    end
    if clay_tile.dist > 400 then
        ::start_over::
        -- swing at an empty tilled tile
        for i = -1, 1 do
            for j = -1, 1 do
                if i == j then goto continue end
                local t = tile + Vector2(i, j)
                if TileInfo.IsTillable(Game1.currentLocation, t) and not IsTilled(t) then
                    movement.UseToolOnTile("Hoe", t)
                    return
                end
                ::continue::
            end
        end
        for i = -1, 1 do
            for j = -1, 1 do
                if i == j then goto continue end
                local t = tile + Vector2(i, j)
                if TileInfo.IsTillable(Game1.currentLocation, t) and IsTilled(tile + Vector2(i, j)) then
                    movement.UseToolOnTile("Pickaxe", tile + Vector2(i, j))
                    goto start_over
                end
                ::continue::
            end
        end
        return
    end
    clay_tile = clay_tile.tile
    -- TODO: how do we find which
    local walk_tile = tile
    local min_walk = nil
    for i = -1, 1 do
        for j = -1, 1 do
            if i == j then goto continue end
            local t = clay_tile + Vector2(i, j)
            nav.generate_path(t, false)
            if Controller.PathFinder.path == nil then
                goto continue
            end
            if min_walk == nil or Controller.PathFinder.cost < min_walk then
                walk_tile = t
                min_walk = Controller.PathFinder.cost
            end
            ::continue::
        end
    end
    print(walk_tile)

    local function frame_func()
        local is_tilled = IsTilled(clay_tile)
        if is_tilled then
            movement.UseToolOnTile("Pickaxe", clay_tile)
        end
        movement.UseToolOnTile("Hoe", clay_tile)
    end
    nav.walk_to_tile(walk_tile, nil, nil, false)
    frame_func()
end

return c

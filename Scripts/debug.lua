local function test(x, y)
    local tile = Vector2(x, y)
    local p1 = os.clock()
    OverlayManager.Get("regionmap"):GeneratePath(Game1.player.Tile, tile)
    local p2 = os.clock()
    if OverlayManager.Get("regionmap").path.Count == 0 then
        print("No path found")
    else
        print("Path found: " .. OverlayManager.Get("regionmap").path.Count .. " steps")
    end

    local r1 = os.clock()
    Controller.PathFinder:Reset()
    Controller.PathFinder:Update(0, tile.X, tile.Y, true)
    local r2 = os.clock()
    if Controller.PathFinder.path == nil then
        print("No path found")
    else
        print("Path found: " .. Controller.PathFinder.path.Count .. " steps")
    end
    print("PathMap time: " .. (p2 - p1) .. " seconds")
    print("Pathfinder time: " .. (r2 - r1) .. " seconds")
end
return test

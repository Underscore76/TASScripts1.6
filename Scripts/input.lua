local input = {}

function input.GetMouseTileFromGlobal(tileX, tileY)
    local tileSize = RunCS("Game1.tileSize")
    local viewport = RunCS("Game1.viewport")
    local zoomLevel = RunCS("Game1.options.zoomLevel")
    local tile = { X = (tileX + 0.5) * tileSize, Y = (tileY + 0.5) * tileSize }
    local localX = (tile.X - viewport.X) * zoomLevel
    local localY = (tile.Y - viewport.Y) * zoomLevel
    return { X = localX, Y = localY }
end

return input

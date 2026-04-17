local modules = {
    require('logic.sleep').funcs,
    require('logic.screen_fade').funcs,
    require('logic.wait_swing').funcs,
    require('logic.swing_tool').funcs,
    require('logic.swap_to_item').funcs,
    require('logic.walk').funcs,
    require('logic.weeds').funcs,
    require('logic.fishing').funcs,
}
require('logic.tasks')
local walk_tile_sequence = require('logic.walk').helpers.walk_tile_sequence

LuaFunctionRegistry.Clear()
for _, module in ipairs(modules) do
    if type(module) == "table" and module[1] then -- check if it's an array of functions
        for _, v in ipairs(module) do
            LuaFunctionRegistry.RegisterFunction(v.name, v.func, v.desc)
        end
    end
end

LuaFunctionRegistry.RegisterFunction("pause", function(index)
    while true do
        coroutine.yield()
    end
end, "pause")

function V(x, y)
    return Vector2(x, y)
end

function walk_highlights(index)
    local tiles = {}
    for _, tile in list_items(TileHighlight.States) do
        table.insert(tiles, tile.Tile)
    end
    GamePadInputQueue.SetManualFrameFunction(
        index,
        walk_tile_sequence(table),
        "walk_tile_sequence",
        "walk tile sequence"
    )
end

local inventory = require('core.inventory')
local input = require('core.input')

local movement = {}

function movement.SwapToItem(itemName)
    if not inventory.HaveItems(itemName) then
        error("Could not find item: " .. itemName)
    end
    while Game1.player.CurrentItem == nil or Game1.player.CurrentItem.Name ~= itemName do
        local keys = inventory.GetInventoryKey(itemName)
        advance({ keyboard = keys })
        advance()
    end
end

function movement.UseToolOnTile(toolName, tile)
    local p = Game1.player.Tile
    for x = -1, 1 do
        for y = -1, 1 do
            local t = Vector2(p.X + x, p.Y + y)
            if t.X == tile.X and t.Y == tile.Y then
                movement.SwapToItem(toolName)
                local mouse = input.get_mouse_for_tile(tile.X, tile.Y)
                advance({ mouse = mouse })
                mouse = { X = mouse.X, Y = mouse.Y, left = true }
                advance({ mouse = mouse })
                advance({ keyboard = { Keys.RightShift, Keys.R, Keys.Delete } })
                return
            end
        end
    end
end

return movement

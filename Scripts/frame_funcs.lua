local input = require('input')
local frame_funcs = {}

function frame_funcs.MouseTile(tile)
    return function()
        return {
            override_keyboard = false,
            mouse = input.GetMouseTileFromGlobal(tile.X, tile.Y)
        }
    end
end

function frame_funcs.click_chest(chestTile)
    return function()
        -- mouse over the chest until we can click it
        local mouse = input.GetMouseTileFromGlobal(chestTile.X, chestTile.Y)
        if Game1.fadeToBlack then
            return {
                override_keyboard = false,
                mouse = mouse
            }
        end

        if Game1.activeClickableMenu ~= nil then
            return {
                override_keyboard = true,
                keyboard = { Keys.Escape }
            }
        end

        local chest = Game1.currentLocation.Objects[chestTile]
        -- is there a chest?
        if (chest == nil) then
            return {
                override_keyboard = false,
                mouse = mouse
            }
        end

        -- does the chest have an item?
        if chest.Items.Count == 0 then
            return {}
        end

        -- is the chest closed?
        if chest.frameCounter.Value <= 0 then
            -- are we outside there range of the chest?
            if math.max(math.abs(Game1.player.Tile.X - chestTile.X), math.abs(Game1.player.Tile.Y - chestTile.Y)) > 1 then
                -- printf("%d\t%s", current_frame(), 'not within range')
                return {
                    override_keyboard = false,
                    mouse = mouse
                }
            end
            -- printf("%d\t%s", current_frame(), 'trying to open')
            mouse['right'] = true
            return {
                override_keyboard = false,
                mouse = mouse
            }
        end
        local maxId = chest:getLastLidFrame()
        local currentId = GetValue(chest, "currentLidFrame")
        if currentId ~= maxId then
            return {}
        end
        if chest.frameCounter.Value > 1 then
            return {}
        end

        return {
            override_keyboard = true,
            keyboard = { Keys.E }
        }
    end
end

return frame_funcs

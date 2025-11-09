-- local xMin = 70
-- local xMax = 120 - 10
-- local yMin = 68
-- local yMax = 120 - 15

-- for x = xMin, xMax do
--     for y = yMin, yMax do
--         local placeable = Game1.currentLocation:CanItemBePlacedHere(Vector2(x, y))
--         if placeable then
--             placeable = 1
--         else
--             placeable = 0
--         end
--         local hoeable = Game1.currentLocation:doesTileHaveProperty(x, y, "Diggable", "Back") ~= nil
--         if hoeable then
--             hoeable = 1
--         else
--             hoeable = 0
--         end
--         printf("%d,%d,%d,%d", x, y, placeable, hoeable)
--     end
-- end

-- for offset = 3000, 4000 do
--     Game1.random = Random(-1038737295)
--     for o = 1, offset do
--         Game1.random:Next()
--     end
--     Game1.locations[21]:DayUpdate(1)
--     local c = count()
--     printf("%d,%d", offset, c)
-- end

Game1.random = Random(-1038737295)
for offset = 1, 3364 do
    Game1.random:Next()
end
Game1.locations[21]:DayUpdate(1)
print(count())
-- for offset = 3000, 4000 do
--     for o = 1, offset do
--         Game1.random:Next()
--     end
--     local c = count()
--     printf("%d,%d", offset, c)
-- end

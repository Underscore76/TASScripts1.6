local game1 = {}

function game1.menuActive()
    return Game1.activeClickableMenu ~= nil
end

function game1.objectName(id)
    -- convert id to a string
    if type(id) == "number" then
        id = tostring(id)
    end
    return Game1.objectData[id].Name;
end

return game1

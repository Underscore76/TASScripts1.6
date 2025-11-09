local function s()
    local v = Vector2(65, 19)
    local dirs = {
        Vector2(0, -1),
        Vector2(1, 0),
        Vector2(0, 1),
        Vector2(-1, 0)
    }
    for i, dir in ipairs(dirs) do
        local t = v + dir
        print(t)
    end
end

s()
-- fload('tstv')
-- Controller.Overlays['MapWeights']

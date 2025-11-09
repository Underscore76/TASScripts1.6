local tileFuncs = {}
function tileFuncs.ContainedRect(rect, tile)
    local x = rect.X
    local y = rect.Y
    local w = rect.Width
    local h = rect.Height
    local tx = tile.X * 64
    local ty = tile.Y * 64
    return x > tx and x + w < tx + 64 and y > ty and y + h < ty + 64
end

function tileFuncs.ContainedCenter(rect, tile)
    local x = rect.Center.X
    local y = rect.Center.Y
    local tx = tile.X * 64
    local ty = tile.Y * 64
    return x > tx and x < tx + 63 and y > ty and y < ty + 63
end

function tileFuncs.ContainedRectCentered(rect, tile)
    local x = rect.X
    local y = rect.Y
    local w = rect.Width
    local h = rect.Height
    local tx = tile.X * 64
    local ty = tile.Y * 64
    return x + 4 > tx and x + w + 12 < tx + 64 and y - 12 > ty and y + h + 12 < ty + 64
end

function tileFuncs.HalfHeight(vec, tile)
    local ttop = tile.Y * 64
    local tbottom = (tile.Y + 1) * 64
    local vtop = vec.Y + 14
    local vbottom = vec.Y + 32 - 14
    if vtop < ttop then
        return 1
    end
    if vbottom > tbottom then
        return -1
    end
    return 0
end

function tileFuncs.CenteredTileHeight(vec, tile)
    local ttop = tile.Y * 64
    local tbottom = (tile.Y + 1) * 64
    local vtop = vec.Y - 12
    local vbottom = vec.Y + 32 + 12
    if vtop < ttop then
        return 1
    end
    if vbottom > tbottom then
        return -1
    end
    return 0
end

function tileFuncs.BottomSided(vec, tile)
    local ttop = tile.Y * 64
    local tbottom = (tile.Y + 1) * 64
    local vtop = vec.Y - 24
    local vbottom = vec.Y + 32
    if vtop < ttop then
        return 1
    end
    if vbottom > tbottom then
        return -1
    end
    return 0
end

function tileFuncs.TopSided(vec, tile)
    local ttop = tile.Y * 64
    local tbottom = (tile.Y + 1) * 64
    local vtop = vec.Y
    local vbottom = vec.Y + 32 + 24
    if vtop < ttop then
        return 1
    end
    if vbottom > tbottom then
        return -1
    end
    return 0
end

function tileFuncs.CenteredTileWidth(vec, tile)
    local tleft = tile.X * 64
    local tright = (tile.X + 1) * 64
    local vleft = vec.X + 8 - 4
    local vright = vec.X + 48 + 8 + 4
    if vleft < tleft then
        return 1
    end
    if vright > tright then
        return -1
    end
    return 0
end

function tileFuncs.CompareTileHeight(vec, tile)
    local ttop = tile.Y * 64
    local tbottom = (tile.Y + 1) * 64
    local vtop = vec.Y
    local vbottom = vec.Y + 32
    if vtop < ttop then
        return 1
    end
    if vbottom > tbottom then
        return -1
    end
    return 0
end

function tileFuncs.CompareTileWidth(vec, tile)
    -- |----| vl, vr
    --   |==============| tl, tr
    -- if vl < tl we are below the lower bound and need to go right
    -- if vr > tr we are above the upper bound and need to go left
    local tleft = tile.X * 64
    local tright = (tile.X + 1) * 64
    local vleft = vec.X + 8
    local vright = vec.X + 48 + 8
    if vleft < tleft then
        return 1
    end
    if vright > tright then
        return -1
    end
    return 0
end

function tileFuncs.VecInTileWidth(vec, tile)
    -- |----| vl, vr
    --   |==============| tl, tr
    -- if vl < tl we are below the lower bound and need to go right
    -- if vr > tr we are above the upper bound and need to go left
    local tleft = tile.X * 64
    local tright = (tile.X + 1) * 64 - 1
    if vec.X < tleft then
        return 1
    end
    if vec.X > tright then
        return -1
    end
    return 0
end

function tileFuncs.VecInTileHeight(vec, tile)
    -- |----| vl, vr
    --   |==============| tl, tr
    -- if vl < tl we are below the lower bound and need to go right
    -- if vr > tr we are above the upper bound and need to go left
    local ttop = tile.Y * 64
    local tbottom = (tile.Y + 1) * 64 - 1
    if vec.Y < ttop then
        return 1
    end
    if vec.Y > tbottom then
        return -1
    end
    return 0
end

return tileFuncs

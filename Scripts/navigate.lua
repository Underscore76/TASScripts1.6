Deque = require("core.collections.deque")
local tile_funcs = require("tile_funcs")

local navigate = {}
navigate.DIR = {
    UP = Vector2(0, -1),
    UPRIGHT = Vector2(0.707, -0.707),
    RIGHT = Vector2(1, 0),
    DOWNRIGHT = Vector2(0.707, 0.707),
    DOWN = Vector2(0, 1),
    DOWNLEFT = Vector2(-0.707, 0.707),
    LEFT = Vector2(-1, 0),
    UPLEFT = Vector2(-0.707, -0.707)
}

function navigate.generate_path(tile, use_tool)
    if tile == nil then
        return
    end
    if use_tool == nil then
        use_tool = false
    end
    Controller.PathFinder:Reset()
    Controller.PathFinder:Update(0, tile.X, tile.Y, false)
end

local function step(vec, dir, speed)
    return vec + dir * speed
end

function navigate.walk_to_tile(tile, frame_func, use_tool, contained, centered)
    if tile == nil then
        error("tile is nil")
    end
    if use_tool == nil then
        use_tool = false
    end
    if contained == nil then
        contained = false
    end
    if centered == nil then
        centered = false
    end
    local function playerBBoxCenter()
        local c = Game1.player:GetBoundingBox().Center
        return Vector2(c.X, c.Y)
    end
    local function playerPosition()
        return Game1.player.Position
    end
    -- printf("walking to tile %d,%d", tile.X, tile.Y)
    navigate.generate_path(tile, use_tool)
    local counter = 0
    local xfunc = tile_funcs.CompareTileWidth
    local yfunc = tile_funcs.CompareTileHeight
    local cfunc = tile_funcs.ContainedRect
    local pfunc = playerPosition
    if contained then
        xfunc = tile_funcs.VecInTileWidth
        yfunc = tile_funcs.VecInTileHeight
        cfunc = tile_funcs.ContainedCenter
        pfunc = playerBBoxCenter
    end
    if centered then
        xfunc = tile_funcs.CenteredTileWidth
        yfunc = tile_funcs.CenteredTileHeight
        cfunc = tile_funcs.ContainedRectCentered
    end


    while Controller.PathFinder.path.Count > 0 do
        -- print("walking")
        counter = counter + 1
        if counter > 5000 then
            printf("failed to walk to tile %d,%d", tile.X, tile.Y)
            return counter
        end
        local loc = Controller.PathFinder:PeekFront()
        local next = nil
        if Controller.PathFinder.path.Count > 1 then
            next = Controller.PathFinder.path[1]
        end
        if loc == nil then
            break
        end
        local moveTile = loc:toVector2()
        if cfunc(Game1.player:GetBoundingBox(), moveTile) then
            Controller.PathFinder:PopFront()
            goto continue
        end

        local speed = Game1.player:getMovementSpeed()
        local keyboard = {}
        local xdir = xfunc(pfunc(), moveTile)
        if xdir > 0 then
            table.insert(keyboard, Keys.D)
        elseif xdir < 0 then
            table.insert(keyboard, Keys.A)
        end


        local ydir = yfunc(pfunc(), moveTile)
        if ydir > 0 then
            table.insert(keyboard, Keys.S)
        elseif ydir < 0 then
            table.insert(keyboard, Keys.W)
        elseif next ~= nil then
            local nydir = yfunc(pfunc(), next:toVector2())
            if xdir > 0 then
                if nydir > 0 then
                    local p = step(pfunc(), navigate.DIR.DOWNRIGHT, speed)
                    if yfunc(p, moveTile) == 0 then
                        table.insert(keyboard, Keys.S)
                    end
                elseif nydir < 0 then
                    local p = step(pfunc(), navigate.DIR.UPRIGHT, speed)
                    if yfunc(p, moveTile) == 0 then
                        table.insert(keyboard, Keys.W)
                    end
                end
            elseif xdir < 0 then
                if nydir > 0 then
                    local p = step(pfunc(), navigate.DIR.DOWNLEFT, speed)
                    if yfunc(p, moveTile) == 0 then
                        table.insert(keyboard, Keys.S)
                    end
                elseif nydir < 0 then
                    local p = step(pfunc(), navigate.DIR.UPLEFT, speed)
                    if yfunc(p, moveTile) == 0 then
                        table.insert(keyboard, Keys.W)
                    end
                end
            end
        end
        if xdir == 0 and ydir == 0 then
            Controller.PathFinder:PopFront()
            goto continue
        end
        if frame_func then
            local res = frame_func()
            if res.kill then
                return
            end
            if res.keyboard ~= nil then
                if res.override_keyboard then
                    keyboard = res.keyboard
                else
                    for _, v in ipairs(res.keyboard) do
                        table.insert(keyboard, v)
                    end
                end
            end
            if res.mouse ~= nil then
                advance({ keyboard = keyboard, mouse = res.mouse })
            else
                advance({ keyboard = keyboard })
            end
        else
            advance({ keyboard = keyboard })
        end
        halt()
        ::continue::
    end
    return counter
end

return navigate

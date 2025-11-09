local utils = require('logic.utils')
local Gamepad = require('gamepad')
local keybinds = require('core.keybinds')
local walk_to_tile = require('logic.walk').helpers.walk_to_tile
local swing = require('logic.swing_tool').helpers.swing
local nav = require('logic.nav')

local function _get_mouse_tile(index)
    local m = Mouse.GetState()
    local viewport = InstanceViewport.Get(index)
    local options = InstanceOptions.Get(index)
    local coords = Vector2(m.X - viewport.Window.X, m.Y - viewport.Window.Y)
    local zoomedCoords = coords * (1.0 / options.zoomLevel)
    local mouseTileX = math.floor((zoomedCoords.X + viewport.X) / Game1.tileSize)
    local mouseTileY = math.floor((zoomedCoords.Y + viewport.Y) / Game1.tileSize)
    return Vector2(mouseTileX, mouseTileY)
end

local function _register_walk_tile()
    if ActiveInstance.InstanceIndex == 0 then
        return
    end
    local tile = _get_mouse_tile(ActiveInstance.InstanceIndex)
    FrameTasks.Push(ActiveInstance.InstanceIndex, "Walk", tile)
end

local function _register_nav_tiles(mesh)
    if ActiveInstance.InstanceIndex == 0 then
        return
    end
    for i, v in ipairs(mesh) do
        FrameTasks.Push(ActiveInstance.InstanceIndex, "Walk", v)
    end
end

local function _register_tool_tile()
    if ActiveInstance.InstanceIndex == 0 then
        return
    end
    local tile = _get_mouse_tile(ActiveInstance.InstanceIndex)
    FrameTasks.Push(ActiveInstance.InstanceIndex, "Tool", tile)
end

local function _swing_tool(p, needed_tool, tool_tile)
    utils.swap_to_item(p, needed_tool)
    local player = InstanceCurrentPlayer.Get(p.index)
    local currTile = player.CurrentTile
    if currTile.X < tool_tile.X then
        swing(p, 1)
    elseif currTile.X > tool_tile.X then
        swing(p, 3)
    elseif currTile.Y < tool_tile.Y then
        swing(p, 2)
    elseif currTile.Y > tool_tile.Y then
        swing(p, 0)
    end
end

local function _get_tool_details(index, task)
    if task == nil or task.Tile == nil then
        return {}
    end
    local loc = InstanceCurrentLocation.Get(index).Location
    if loc.terrainFeatures:ContainsKey(task.Tile) then
        local tf = loc.terrainFeatures[task.Tile]
        local name = tf:GetType().Name
        local needed_tool = name
        if name == "Tree" then
            needed_tool = "Axe"
        elseif name == "Grass" then
            needed_tool = "Scythe"
        elseif name == "HoeDirt" then
            needed_tool = "Watering Can"
        end
        return {
            needed_tool = needed_tool,
            obj_name = name,
        }
    end
    if loc.objects:ContainsKey(task.Tile) then
        local obj = loc.objects[task.Tile]
        local needed_tool = obj.Name
        if obj.Name == "Weeds" then
            needed_tool = "Scythe"
        elseif obj.Name == "Stone" then
            needed_tool = "Pickaxe"
        elseif obj.Name == "Twig" then
            needed_tool = "Axe"
        else
            needed_tool = obj.Name
        end
        return {
            needed_tool = needed_tool,
            obj_name = obj.Name,
        }
    end
    -- printf("Tile at (%d, %d) is neither terrain feature nor object", task.Tile.X, task.Tile.Y)
    if TileInfo.IsTillable(loc, task.Tile) then
        return {
            needed_tool = "Hoe",
            obj_name = "TillableTile",
        }
    end
    -- printf("Tile at (%d, %d) is not tillable", task.Tile.X, task.Tile.Y)
    return {}
end

local function _try_run()
    if ActiveInstance.InstanceIndex == 0 then
        return
    end
    local count = FrameTasks.Count(ActiveInstance.InstanceIndex)
    if count == 0 then
        return
    end

    GamePadInputQueue.SetManualFrameFunction(
        ActiveInstance.InstanceIndex,
        function(index)
            local p = Gamepad.new(index)
            while FrameTasks.Count(index) > 0 do
                local task = FrameTasks.Peek(index)
                if task.Type == "Walk" then
                    local nextTask = FrameTasks.Peek(index)
                    if nextTask ~= nil and nextTask.Type == "Tool" then
                        local details = _get_tool_details(index, nextTask)
                        walk_to_tile(task.Tile, utils.swap_to_item_frame(details.needed_tool))(index)
                    else
                        walk_to_tile(task.Tile, nil)(index)
                    end
                elseif task.Type == "Tool" then
                    local details = _get_tool_details(index, task)
                    _swing_tool(p, details.needed_tool, task.Tile)
                end
                FrameTasks.Pop(index)
            end
        end,
        "use tool",
        "walk to tile and use tool"
    )
end

keybinds.clear()
keybinds.add(Keys.O, _register_walk_tile)
keybinds.add(Keys.P, _register_tool_tile)
keybinds.add(Keys.L, _try_run)
keybinds.add(Keys.J, function()
    FrameTasks.Pop(ActiveInstance.InstanceIndex)
end)
keybinds.add(Keys.K, function()
    FrameTasks.RemoveAt(ActiveInstance.InstanceIndex, FrameTasks.Count(ActiveInstance.InstanceIndex) - 1)
end)

function walk_nav_mesh(index, from, to)
    if index == nil then
        index = ActiveInstance.InstanceIndex
    end
    if index == 0 then
        return
    end
    print(nav.nav_mesh)
    local path = nav.nav_mesh[from][to]
    if path == nil then
        error("No nav mesh path from " .. from .. " to " .. to)
    end
    _register_nav_tiles(path)
end

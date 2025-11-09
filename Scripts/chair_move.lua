local keybinds = require("core.keybinds")

local chair_move = {
    chair_name = "Oak Chair",
    reverse_frames = 500,
}

local function player_get_tile_location()
    return Game1.player.Tile
end

local function _GetMouseTileRelativeToPlayer(tileX, tileY)
    local tileSize = RunCS("Game1.tileSize")
    local viewport = RunCS("Game1.viewport")
    local zoomLevel = RunCS("Game1.options.zoomLevel")
    local player = player_get_tile_location() * 64
    local offsetX = where(tileX <= 0, tileX + 0.5, tileX + 0.2)
    local offsetY = where(tileY <= 0, tileY + 0.5, tileY + 0.2)
    local localX = (player.X - viewport.X + tileSize * offsetX) * zoomLevel
    local localY = (player.Y - viewport.Y + tileSize * offsetY) * zoomLevel
    return { X = localX, Y = localY }
end

local function _GetMouseTileFromGlobal(tileX, tileY)
    local tileSize = RunCS("Game1.tileSize")
    local viewport = RunCS("Game1.viewport")
    local zoomLevel = RunCS("Game1.options.zoomLevel")
    local tile = { X = (tileX + 0.5) * tileSize, Y = (tileY + 0.5) * tileSize }
    local localX = (tile.X - viewport.X) * zoomLevel
    local localY = (tile.Y - viewport.Y) * zoomLevel
    return { X = localX, Y = localY }
end

function chair_move.find_chair()
    local furniture = RunCS("Game1.currentLocation").furniture
    for i, f in list_items(furniture) do
        if f.name == chair_move.chair_name then
            return f
        end
    end
end

local function mouse_up(left, right)
    local mouse = _GetMouseTileRelativeToPlayer(0, -1)
    if left then
        mouse.left = left
    end
    if right then
        mouse.right = right
    end
    return mouse
end

local function mouse_down(left, right)
    local mouse = _GetMouseTileRelativeToPlayer(0, 1)
    if left then
        mouse.left = left
    end
    if right then
        mouse.right = right
    end
    return mouse
end

local function while_cant_move(mouse_func, key_func)
    local c = 0
    while RunCS("Game1.player").CanMove == false do
        local input = {}
        if key_func then
            input.keyboard = key_func()
        end
        if mouse_func then
            input.mouse = mouse_func()
        end
        advance(input)
        c = c + 1
        if c > 100 then
            break
        end
    end
end

local function mouse_right(left, right)
    local mouse = _GetMouseTileRelativeToPlayer(1, 0)
    if left then
        mouse.left = left
    end
    if right then
        mouse.right = right
    end
    return mouse
end

local function mouse_left(left, right)
    local mouse = _GetMouseTileRelativeToPlayer(-1, 0)
    if left then
        mouse.left = left
    end
    if right then
        mouse.right = right
    end
    return mouse
end

local function mouse_down_left(left, right)
    local mouse = _GetMouseTileRelativeToPlayer(-1, 1)
    if left then
        mouse.left = left
    end
    if right then
        mouse.right = right
    end
    return mouse
end

local function mouse_down_right(left, right)
    local mouse = _GetMouseTileRelativeToPlayer(1, 1)
    if left then
        mouse.left = left
    end
    if right then
        mouse.right = right
    end
    return mouse
end

local function mouse_up_left(left, right)
    local mouse = _GetMouseTileRelativeToPlayer(-1, -1)
    if left then
        mouse.left = left
    end
    if right then
        mouse.right = right
    end
    return mouse
end

local function mouse_up_right(left, right)
    local mouse = _GetMouseTileRelativeToPlayer(1, -1)
    if left then
        mouse.left = left
    end
    if right then
        mouse.right = right
    end
    return mouse
end

local function _prefix()
    exec("saveengine tmp")
    for i, v in list_items(Controller.Automation.Items) do
        if v.Toggleable then
            v.Active = false
        end
    end
end
local function _postfix()
    exec("loadengine tmp")
end

local function _mouse_func(left, right)
    local f = chair_move.find_chair().TileLocation
    local mouse = _GetMouseTileFromGlobal(f.X, f.Y)
    if left ~= nil then
        mouse.left = left
    end
    if right ~= nil then
        mouse.right = right
    end
    return mouse
end

local function diag_move(key, mouse_func)
    _prefix()
    advance({ keyboard = { key, Keys.X }, mouse = _mouse_func(true) })
    while_cant_move(_mouse_func, function() return { key } end)
    advance({ keyboard = { key, Keys.C }, mouse = _mouse_func() })
    advance({ keyboard = { key }, mouse = mouse_func() })
    advance({ keyboard = { key, Keys.C }, mouse = mouse_func() })
    advance({ keyboard = { Keys.X }, mouse = mouse_func() })
    advance({ mouse = mouse_func() })
    _postfix()
end

function chair_move.lu()
    diag_move(Keys.A, mouse_up_left)
end

function chair_move.ru()
    diag_move(Keys.D, mouse_up_right)
end

function chair_move.ul()
    diag_move(Keys.W, mouse_up_left)
end

function chair_move.ur()
    diag_move(Keys.W, mouse_up_right)
end

function chair_move.rd()
    diag_move(Keys.D, mouse_down_right)
end

function chair_move.ld()
    diag_move(Keys.S, mouse_down_left)
end

function chair_move.dl()
    diag_move(Keys.S, mouse_down_left)
end

function chair_move.dr()
    diag_move(Keys.S, mouse_down_right)
end

function chair_move.stall_right()
    -- starts with chair in hand over tile to the right
    local right = _GetMouseTileRelativeToPlayer(1, 0)
    local current = player_get_tile_location()
    local function f()
        return _GetMouseTileFromGlobal(current.X, current.Y)
    end
    local tile = player_get_tile_location()
    _prefix()
    advance({ keyboard = { Keys.C }, mouse = right })
    right.left = true
    advance({ keyboard = {}, mouse = right })
    right.left = false
    advance({ keyboard = { Keys.X }, mouse = right })
    while_cant_move(f)
    _postfix()
end

function chair_move.stall_left()
    -- starts with chair in hand over tile to the left
    local left = _GetMouseTileRelativeToPlayer(-1, 0)
    local current = player_get_tile_location()
    local function f()
        return _GetMouseTileFromGlobal(current.X, current.Y)
    end
    local tile = player_get_tile_location()
    _prefix()
    advance({ keyboard = { Keys.C }, mouse = left })
    left.left = true
    advance({ keyboard = {}, mouse = left })
    left.left = false
    advance({ keyboard = { Keys.X }, mouse = left })
    while_cant_move(f)
    _postfix()
end

keybinds.clear()
keybinds.add(Keys.I,
    function()
        _prefix()
        advance({ keyboard = { Keys.X, Keys.W }, mouse = mouse_down(true) })
        while_cant_move(mouse_down)
        advance({ keyboard = { Keys.C }, mouse = mouse_up() })
        advance({ mouse_up() })
        advance({ keyboard = { Keys.C }, mouse = mouse_up() })
        advance({ keyboard = { Keys.X }, mouse = mouse_up() })
        advance({ mouse = mouse_up() })
        _postfix()
    end
)

keybinds.add(Keys.K,
    function()
        _prefix()
        advance({ keyboard = { Keys.X, Keys.D }, mouse = mouse_up(true) })
        while_cant_move(mouse_up)
        advance({ keyboard = { Keys.C }, mouse = mouse_down() })
        advance({ mouse_down() })
        advance({ keyboard = { Keys.C }, mouse = mouse_down() })
        advance({ keyboard = { Keys.X }, mouse = mouse_down() })
        advance({ mouse = mouse_down() })
        _postfix()
    end
)

keybinds.add(Keys.J,
    function()
        _prefix()
        advance({ keyboard = { Keys.X, Keys.A }, mouse = mouse_right(true) })
        while_cant_move(mouse_right)
        advance({ keyboard = { Keys.C }, mouse = mouse_left() })
        advance({ mouse_left() })
        advance({ keyboard = { Keys.C }, mouse = mouse_left() })
        advance({ keyboard = { Keys.X }, mouse = mouse_left() })
        advance({ mouse = mouse_left() })
        _postfix()
    end
)

keybinds.add(Keys.L,
    function()
        _prefix()
        advance({ keyboard = { Keys.X, Keys.D }, mouse = mouse_left(true) })
        while_cant_move(mouse_left)
        advance({ keyboard = { Keys.C }, mouse = mouse_right() })
        advance({ mouse_right() })
        advance({ keyboard = { Keys.C }, mouse = mouse_right() })
        advance({ keyboard = { Keys.X }, mouse = mouse_right() })
        advance({ mouse = mouse_right() })
        _postfix()
    end
)

keybinds.add(Keys.P,
    function()
        AutomationManager.Get('AdvanceFrozen').Active = not AutomationManager.Get('AdvanceFrozen').Active
    end
)

keybinds.add(Keys.O,
    function()
        while RunCS("Game1.activeClickableMenu").safetyTimer > 0 do
            advance()
        end
    end
)

function chair_move.reverse(k)
    if k == nil then
        k = Keys.Y
    end
    for i = 1, chair_move.reverse_frames do
        local keyboard = Controller.State.FrameStates[TASDateTime.CurrentFrame - i].keyboardState
        if keyboard:Contains(k) then
            printf("%d", TASDateTime.CurrentFrame - i)
        end
    end
end

keybinds.add(Keys.U,
    function()
        while not Game1.player.CanMove do
            advance()
        end
    end
)

function chair_move.reset(d)
    if d ~= nil then
        OverlayManager.Get("ClayMap").Depth = d
    end
    OverlayManager.Get("ClayMap"):Reset()
    if Controller.ViewController.mapView.MapOverlays.Count < 7 then
        Controller.ViewController.mapView.MapOverlays:Add(ClayTileMap())
    end
    Controller.ViewController.mapView.MapOverlays[6].Depth = OverlayManager.Get("ClayMap").Depth
    Controller.ViewController.mapView.MapOverlays[6]:Reset()
end

local function alpha_col(col, alpha)
    if alpha == nil then
        alpha = 16
    end
    return Color(col.R / 255, col.G / 255, col.B / 255, alpha / 255)
end

function chair_move.b(alpha)
    TileHighlight.Clear()
    local o = OverlayManager.Get("ClayMap")
    local t = GetValue(o, "TileData")
    local colors = {
        alpha_col(Color.Red, 128),
        alpha_col(Color.Orange, 192),
        alpha_col(Color.Yellow, 128),
        alpha_col(Color.Green, 128),
        alpha_col(Color.Indigo, 128),
        alpha_col(Color.Blue, 128),
    }
    for k, v in dict_items(t) do
        if v[0] <= #colors then
            TileHighlight.Add(k, colors[v[0]])
        end
    end
end

keybinds.add(Keys.N,
    function()
        chair_move.reset()
    end
)

function chair_move.test()
    while Game1.player.stamina > 4 do
        advance({ keyboard = { Keys.C } })
        advance({ keyboard = { Keys.RightShift, Keys.R, Keys.Delete } })
    end
end

function chair_move.auto(n)
    if n == nil then
        n = 10
    end
    local p = ClayPattern.GetPathIgnore(n, true, false)
    TileText.Clear()
    TileText.DrawOrder = true
    for i, v in list_items(p) do
        local vv = Vector2(v.X, v.Y)
        if TileText.Contains(vv) then
            TileText.Add(vv, alpha_col(Color.Red, 128), tostring(i + 1))
        else
            TileText.Add(vv, tostring(i + 1))
        end
        printf("%d\t%d\t%d", i, v.X, v.Y)
    end
end

function chair_move.advance(...)
    local t = { Keys.RightShift, Keys.R, Keys.Delete }
    local arg = { ... }
    for i, v in ipairs(arg) do
        table.insert(t, v)
    end
    advance({ keyboard = t })
end

function chair_move.clear()
    TileHighlight.Clear()
    for k, tf in dict_items(Game1.currentLocation.terrainFeatures) do
        if tf:GetType().Name == "HoeDirt" then
            printf("%d\t%d", k.X, k.Y)
            TileHighlight.Add(k)
        end
    end
end

return chair_move

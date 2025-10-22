local utils = {}
function utils.try_load(index)
    if (Game1.game1.instanceIndex == index) then
        return
    end
    interface:LoadGameByIndex(index)
end

function utils.player(index)
    return Reflector.GetStaticVar(index, "Game1__player")
end

function utils.current_location(index)
    local loc = GameRunner.instance.gameInstances[index].instanceGameLocation
    if loc == nil then
        return nil
    end
    local name = loc.Name
    if string.sub(name, 1, 15) ~= "UndergroundMine" then
        return loc
    end

    -- mines are different, they pull from the static active mines
    for _, mine in list_items(MineShaft.activeMines) do
        if mine.Name == name then
            return mine
        end
    end
    return loc
end

function utils.current_player(index)
    local player = utils.player(index)
    if player == nil then
        return nil
    end

    local player_data = {}
    player_data.CanMove = player.CanMove
    player_data.FreezePause = player.freezePause > 0
    player_data.IsEmoting = player.isEmoting
    player_data.UsingTool = player.UsingTool
    player_data.CurrentTool = player.CurrentTool
    player_data.CurrentTile = player.Tile
    player_data.FacingDirection = player.FacingDirection
    player_data.BoundingBox = player:GetBoundingBox()
    player_data.ToolLocation = player:GetToolLocation()
    player_data.Friendships = player.friendshipData
    local interval = math.floor(
        player.FarmerSprite.interval * player.FarmerSprite.intervalModifier + 0.5
    )
    player_data.CurrentAnimationLength = math.ceil(interval / 16)
    player_data.CurrentAnimationElapsed = math.floor(
        player.FarmerSprite.timer / 16
    )
    player_data.CurrentSingleAnimation = player.FarmerSprite.CurrentSingleAnimation
    player_data.CurrentAnimationIndex = player.FarmerSprite.currentAnimationIndex

    player_data.IsSwingingSword = false
    if player.FarmerSprite.currentSingleAnimation ~= nil then
        local swing_animations = { FarmerSprite.swordswipeDown, FarmerSprite.swordswipeUp,
            FarmerSprite.swordswipeLeft, FarmerSprite.swordswipeRight }
        for _, v in ipairs(swing_animations) do
            if player.FarmerSprite.currentSingleAnimation == v then
                player_data.IsSwingingSword = true
                break
            end
        end
    end

    player_data.IsHarvestingItem = false
    if player.FarmerSprite.currentSingleAnimation ~= nil then
        local harvest_animations = { FarmerSprite.harvestItemUp, FarmerSprite.harvestItemDown,
            FarmerSprite.harvestItemLeft, FarmerSprite.harvestItemRight }
        for _, v in ipairs(harvest_animations) do
            if player.FarmerSprite.currentSingleAnimation == v then
                player_data.IsHarvestingItem = true
                break
            end
        end
    end

    return player_data
end

local function _get_inventory_index(player, item)
    for i = 0, player.MaxItems - 1 do
        if player.Items[i] ~= nil and player.Items[i].Name == item then
            return i
        end
    end
    return -1
end

function utils.menu(index)
    return Reflector.GetStaticVar(index, "Game1__activeClickableMenu")
end

function utils.current_menu(index)
    local menu = utils.menu(index)
    if menu == nil then
        return nil
    end
    local menu_data = {}
    menu_data.Type = menu:GetType().Name
    menu_data.IsDialogue = menu_data.Type == "DialogueBox"
    if menu_data.IsDialogue then
        menu_data.Transitioning = menu.transitioning
        menu_data.IsQuestion = menu.isQuestion
        menu_data.CharacterIndexInDialogue = menu.characterIndexInDialogue
        menu_data.SafetyTimer = menu.safetyTimer
        menu_data.CurrentString = menu:getCurrentString()
        menu_data.SelectedResponseIndex = menu.selectedResponse
        if menu_data.SelectedResponseIndex ~= -1 and menu.responses ~= nil and menu.responses.Length > 0 then
            menu_data.SelectedResponse = menu.responses[menu_data.SelectedResponseIndex].responseText
        else
            menu_data.SelectedResponse = nil
        end
    end

    return menu_data
end

function utils.swap_to_item(p, item)
    local player = utils.player(p.index)
    local target = _get_inventory_index(player, item)
    if target == -1 then
        error("Could not find item: " .. item)
    end
    local index = player.CurrentToolIndex
    while index ~= target do
        local diff = nil
        if target >= 24 then
            -- shift page back
            p:lt()
            p:push()
            goto continue
        end
        if target >= 12 then
            -- shift page forward
            p:rt()
            p:push()
            goto continue
        end
        if target > index then
            p:zr()
            p:push()
            p:push()
            diff = target - index
            goto continue
        elseif target < index then
            p:zl()
            p:push()
            p:push()
            diff = index - target
            goto continue
        end
        ::continue::
        if diff == 1 then
            break
        end
        coroutine.yield()
        index = player.CurrentToolIndex
    end
end

return utils

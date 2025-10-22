local utils = require('logic.utils')
local Gamepad = require('gamepad')

local function swap_to_axe(index)
    local p = Gamepad.new(index)
    return utils.swap_to_item(p, "Axe")
end

local function swap_to_pick(index)
    local p = Gamepad.new(index)
    return utils.swap_to_item(p, "Pickaxe")
end

local function swap_to_watering(index)
    local p = Gamepad.new(index)
    return utils.swap_to_item(p, "Watering Can")
end

local function swap_to_hoe(index)
    local p = Gamepad.new(index)
    return utils.swap_to_item(p, "Hoe")
end

local function swap_to_scythe(index)
    local p = Gamepad.new(index)
    return utils.swap_to_item(p, "Scythe")
end

return {
    funcs = {
        { func = swap_to_axe,      name = "swap_to_axe",      desc = "swap to axe in inventory" },
        { func = swap_to_pick,     name = "swap_to_pick",     desc = "swap to pickaxe in inventory" },
        { func = swap_to_watering, name = "swap_to_watering", desc = "swap to watering can in inventory" },
        { func = swap_to_hoe,      name = "swap_to_hoe",      desc = "swap to hoe in inventory" },
        { func = swap_to_scythe,   name = "swap_to_scythe",   desc = "swap to scythe in inventory" },
    }
}

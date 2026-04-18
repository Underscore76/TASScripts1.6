local inventory = require("core.inventory")
local input = require("core.input")
local function run(x)
    local keys = inventory.get_tool_key(x)
    if keys == nil then
        return
    end
    print(keys)
end

return run

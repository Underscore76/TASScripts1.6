local modules = {
    require('logic.sleep').funcs,
    require('logic.screen_fade').funcs,
    require('logic.wait_swing').funcs,
    require('logic.swing_tool').funcs,
    require('logic.swap_to_item').funcs,
    require('logic.walk').funcs,
    require('logic.weeds').funcs,
}

GamePadInputQueue.Clear()
for _, module in ipairs(modules) do
    if type(module) == "table" and module[1] then -- check if it's an array of functions
        for _, v in ipairs(module) do
            GamePadInputQueue.RegisterFunction(v.name, v.func, v.desc)
        end
    end
end

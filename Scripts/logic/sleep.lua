local utils = require('logic.utils')
local Gamepad = require('core.input.gamepad')



local function _sleep(p)
    local menu = utils.current_menu(p.index)
    while menu == nil do
        p:right()
        p:push()
        coroutine.yield()
        menu = utils.current_menu(p.index)
    end

    while menu ~= nil and menu.IsDialogue do
        if menu.Transitioning then
            goto continue
        end
        if menu.SelectedResponse == "Yes" then
            coroutine.yield()
            break
        end
        ::continue::
        p:push()
        coroutine.yield()
        menu = utils.current_menu(p.index)
    end
    -- advance the safety timer to zero with one click
    p:a()
    p:push()
    p:push()
    -- actually click
    p:a()
    p:push()
    coroutine.yield()

    while menu ~= nil and menu.Type ~= "ReadyCheckDialog" do
        p:push()
        menu = utils.current_menu(p.index)
        coroutine.yield()
    end
end

local function sleep(index)
    local p = Gamepad.new(index)
    return _sleep(p)
end

return {
    funcs = {
        { func = sleep, name = "sleep", desc = "walk into bed/accept menu" },
    }
}

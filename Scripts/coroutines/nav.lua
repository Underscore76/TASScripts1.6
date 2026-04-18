local nav = require('core.coroutines.nav')

local function run(x)
    KeyboardMouseInputQueue.PushFunction(nav.walk_to_tile(x), "nav")
end

return run

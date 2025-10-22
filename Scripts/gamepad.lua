local Gamepad = {}
Gamepad.__index = Gamepad

function Gamepad.new(index)
    local self = setmetatable({}, Gamepad)
    self.buttons = {}
    self.index = index or 1
    return self
end

function Gamepad:num_staged()
    return GamePadInputQueue.Queues[self.index].Count
end

function Gamepad:clear()
    self.buttons = {}
end

function Gamepad:up()
    self.buttons.up = true
end

function Gamepad:down()
    self.buttons.down = true
end

function Gamepad:left()
    self.buttons.left = true
end

function Gamepad:right()
    self.buttons.right = true
end

function Gamepad:a()
    self.buttons.a = true
end

function Gamepad:b()
    self.buttons.b = true
end

function Gamepad:x()
    self.buttons.x = true
end

function Gamepad:y()
    self.buttons.y = true
end

function Gamepad:start()
    self.buttons.start = true
end

function Gamepad:select()
    self.buttons.select = true
end

function Gamepad:lt()
    self.buttons.lt = true
end

function Gamepad:rt()
    self.buttons.rt = true
end

function Gamepad:zl()
    self.buttons.zl = true
end

function Gamepad:zr()
    self.buttons.zr = true
end

function Gamepad:analog(x, y)
    self.buttons.rx = x
    self.buttons.ry = y
end

function Gamepad:push()
    interface:AddGamePadInput(self.index, self.buttons)
    self:clear()
end

return Gamepad

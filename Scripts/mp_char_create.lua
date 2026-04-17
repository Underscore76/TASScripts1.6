--[[
because the best excuse is that you just freaking did it
    - Tom7, Harder Drives
--]]

local p2_name = "Two"
local p2_fav = "Committing"

local p3_name = "Three"
local p3_fav = "To"

local p4_name = "Four"
local p4_fav = "The Bit"



-- GamePadInputQueue.Clear()
-- buttons for players to handle their character creation
local Gamepad = require('core.input.gamepad')
local p2 = Gamepad.new(1)
local p3 = Gamepad.new(2)
local p4 = Gamepad.new(3)

local function queue_to_name(p)
    p:right()
    p:push()
    p:push()

    p:up()
    p:push()
    p:push()

    p:up()
    p:push()

    p:up()
    p:a()
    p:push()
    p:push()
end

local function name_to_favorite(p)
    p:down()
    p:push()
    p:push()

    p:down()
    p:push()
    p:a()
    p:down()
    p:push()
    p:push()
end

local function favorite_to_female(p)
    p:left()
    p:push()
    p:push()
    p:down()
    p:push()
    p:a()
    p:push()
end

local function female_to_random(p)
    p:up()
    p:push()
    p:push()

    p:up()
    p:left()
    p:push()
end

local function random_to_ok(p)
    for i = 1, 8 do
        p:down()
        p:push()
        p:push()
    end
end

local function back(p, buffer)
    p:b()
    p:push()
    if buffer then
        p:push()
    end
end

local function click(p, buffer)
    p:a()
    p:push()
    if buffer then
        p:push()
    end
end

local function wait(p, n)
    for i = 1, n do
        p:push()
    end
end

local function text_entry(gamepad, text)
    --[[
* keyboard layout reference
    1234567890
    qwertyuiop
    asdfghjkl'
    zxcvbnm,.?
* starting point is on q
* controller can move in 8 directions
* press a to select the character
* stage each sequence of buttons for the next move followed by a push command
--]]

    -- Define the keyboard layout as a 2D grid
    local keyboard = {
        { '1',        '2',   '3', '4', '5', '6', '7', '8', '9', '0' },
        { 'q',        'w',   'e', 'r', 't', 'y', 'u', 'i', 'o', 'p' },
        { 'a',        's',   'd', 'f', 'g', 'h', 'j', 'k', 'l', "'" },
        { 'z',        'x',   'c', 'v', 'b', 'n', 'm', ',', '.', '?' },
        { 'CapsLock', '...', ' ', ' ', ' ', ' ', ' ', '_', '_', '_' }
    }

    -- Create a lookup table for character positions
    local char_positions = {}
    for row = 1, #keyboard do
        for col = 1, #keyboard[row] do
            local char = keyboard[row][col]
            -- For space character, use the first occurrence and skip duplicates
            if char == ' ' and not char_positions[' '] then
                char_positions[char] = { row = row, col = col } -- Use actual first position
            elseif char ~= ' ' then
                char_positions[char] = { row = row, col = col }
            end
        end
    end

    -- Starting position (q is at row 2, col 1)
    local current_pos = { row = 2, col = 1 }
    local caps_lock_on = false -- Track CapsLock state (starts off)

    -- Function to move from current position to target position
    local function move_to_position(target_pos)
        local row_diff = target_pos.row - current_pos.row
        local col_diff = target_pos.col - current_pos.col
        if row_diff == 0 and col_diff == 0 then
            return false
        end

        -- Move vertically first
        for i = 1, math.abs(row_diff) do
            if row_diff > 0 then
                gamepad:down()
            else
                gamepad:up()
            end
            gamepad:push()
            gamepad:push()
        end

        -- Move horizontally
        for i = 1, math.abs(col_diff) do
            if col_diff > 0 then
                gamepad:right()
            else
                gamepad:left()
            end
            gamepad:push()
            gamepad:push()
        end

        -- Update current position
        current_pos.row = target_pos.row
        current_pos.col = target_pos.col
        return true
    end

    -- Function to toggle CapsLock if needed
    local function toggle_caps_lock_if_needed(is_uppercase, is_letter)
        if is_uppercase and not caps_lock_on then
            -- Need to turn CapsLock on
            local caps_pos = char_positions['CapsLock']
            move_to_position(caps_pos)
            gamepad:a()
            gamepad:push()
            gamepad:push()
            caps_lock_on = true
        elseif not is_uppercase and caps_lock_on and is_letter then
            -- Need to turn CapsLock off for lowercase letters
            local caps_pos = char_positions['CapsLock']
            move_to_position(caps_pos)
            gamepad:a()
            gamepad:push()
            gamepad:push()
            caps_lock_on = false
        end
    end

    -- Process each character in the text
    for i = 1, #text do
        local original_char = text:sub(i, i)
        local char = original_char:lower()
        local is_uppercase = original_char ~= char
        local is_letter = char:match('[a-z]') ~= nil
        local target_pos = char_positions[char]

        if target_pos then
            -- Handle CapsLock for letters only
            if is_letter then
                toggle_caps_lock_if_needed(is_uppercase, is_letter)
            end

            -- Move to the character position
            local moved = move_to_position(target_pos)
            if not moved and i > 1 then
                -- If already at the position and not the first character, add a slight delay
                gamepad:push()
            end
            -- Select the character
            gamepad:a()
            gamepad:push()
            gamepad:push()
        else
            -- Handle unsupported characters (skip or add error handling)
            print("Warning: Character '" .. original_char .. "' not found in keyboard layout")
        end
    end
end

-- p2 join
-- queue_to_name(p2)
-- text_entry(p2, p2_name)
-- back(p2)
-- name_to_favorite(p2)
-- text_entry(p2, p2_fav)
-- back(p2)
-- favorite_to_female(p2)
-- female_to_random(p2)
-- click(p2)
-- random_to_ok(p2)

-- p3 join
-- wait(p3, 3)
-- queue_to_name(p3)
-- text_entry(p3, p3_name)
-- back(p3)
-- name_to_favorite(p3)
-- text_entry(p3, p3_fav)
-- back(p3)
-- favorite_to_female(p3)
-- female_to_random(p3)
-- click(p3)
-- random_to_ok(p3)

-- p4 join
wait(p4, 6)
queue_to_name(p4)
text_entry(p4, p4_name)
back(p4)
name_to_favorite(p4)
text_entry(p4, p4_fav)
back(p4)
favorite_to_female(p4)
female_to_random(p4)
click(p4)
random_to_ok(p4)

-- for i = 1, 3 do
--     printf("P%d\t%d", i, GamePadInputQueue.Queues[i].Count)
-- end

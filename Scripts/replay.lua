---clone frame inputs and play them back at a later time
---useful for things like replaying non-rng dependent inputs

local replay = {
    frames = nil,
}

local function state_to_table(frame_state)
    -- copy the keyboardState
    local keyboard = {}
    for k, v in list_items(frame_state.keyboardState) do
        table.insert(keyboard, v)
    end
    -- copy the mouseState
    local mouse = {
        left = frame_state.mouseState.LeftMouseClicked,
        right = frame_state.mouseState.RightMouseClicked,
        X = frame_state.mouseState.MouseX,
        Y = frame_state.mouseState.MouseY,
    }

    -- copy the text
    local text = frame_state.InjectText
    return {
        keyboard = keyboard,
        mouse = mouse,
        text = text,
    }
end

function replay.clone(f_start, f_end)
    if f_start == nil then
        error("Need to specify frames to clone")
    end
    if f_end == nil then
        f_end = f_start
        f_start = 0
    end
    replay.frames = {}
    for i = f_start, f_end - 1 do
        local frame = Controller.State.FrameStates[i]
        table.insert(replay.frames, state_to_table(frame))
    end
end

function replay.playback()
    if replay.frames == nil then
        error("No frames to playback")
        return
    end

    for i, frame in ipairs(replay.frames) do
        advance(frame)
    end
end

return replay

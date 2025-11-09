for i = 400, TASDateTime.CurrentFrame - 1 do
    if Controller.State.FrameStates[i].keyboardState.Count > 0 then
        print(i)
        break
    end
end

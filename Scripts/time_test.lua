local function time_movement()
    local c = 0
    local t0 = os.time()
    local t1 = os.time()
    while t1 == t0 do
        t1 = os.time()
    end
    t0 = t1
    while (t1 - t0) < 10 do
        advance({ keyboard = { Keys.W } })
        c = c + 1
        t1 = os.time()
    end
    print(c, t1 - t0)
end

time_movement()

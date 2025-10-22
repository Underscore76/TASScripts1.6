local function launch()
    local startup = require("core.scripts.startup")

    -- farm startup params
    startup.set_name('Underscore')
    startup.set_farm_name('Casual')
    startup.set_favorite('Going Fast')

    startup.set_skip(true)
    startup.set_sex('male')
    startup.set_farm('Standard')
    -- NOTE: these numbers can be wonky due to issues with how SDV actually numbers them
    -- there may be gaps in the numbers, some numbers might be negative indexed
    -- its confusing... Generally it's the number shown in the menu - 1.
    -- if you try and number that doesn't work, it will just attempt to spin for a while before giving up and moving on
    startup.set_hair(8)                   -- there are missing hair styles
    startup.set_shirt("1105")             -- just a mess of indexing, best to just scan and when you find one you want use Game1.player.shirt and treat that as a string
    startup.set_acc(0)                    -- 0 is the beard in this case, -1 is no accessory...
    startup.set_skin(2)                   -- 0 indexed and as expected indexing
    startup.set_pant("0")                 -- it used to be numeric but became a string in 1.6

    startup.set_eye_color(nil, nil, 89)   -- these are the hsv sliders, 0-100% on each
    startup.set_hair_color(nil, nil, 24)  -- these are the hsv sliders, 0-100% on each
    startup.set_pants_color(nil, nil, 21) -- these are the hsv sliders, 0-100% on each

    -- this is an example startup script that will launch you into the start of day 1
    startup.run()
    -- startup.click_ok()

    -- advance() -- get past the initial launch
    -- halt()    -- waits until past the save (generally shouldn't need to manually halt outside this case of overnight load)

    -- advance() -- push into the day1 load
    -- the game will be paused at this point, so you can do whatever you want
end

launch()

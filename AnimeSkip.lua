local mp = require 'mp'

-- skipped chapters names (case-insensitive substring match)
local skip_patterns = { "opening", "intro", "op" }

local function should_skip(title)
    if not title then
        return false
    end
    local t = title:lower()
    for _, p in ipairs(skip_patterns) do
        if t:find(p, 1, true) then
            return true
        end
    end
    return false
end

local function auto_skip()
    local ch   = mp.get_property_number("chapter", 0)
    local list = mp.get_property_native("chapter-list")
    local pos  = mp.get_property_number("time-pos", 0)

    if not list or #list == 0 or ch >= #list then
        return
    end

    -- try to not skip chapter named intro that isnt song 
    if ch == 0 and list[1].time == 0 and list[2] and (list[2].time - list[1].time) > 110 then
        return
    end

    local title = list[ch + 1].title
    if not should_skip(title) then
        return
    end

    local n = ch + 1
    while n < #list and should_skip(list[n + 1].title) do
        n = n + 1
    end

    if n < #list and list[n + 1] and list[n + 1].time then
        local next_time = list[n + 1].time
        local skip      = next_time - pos

        -- Jump to next chapter if it's 70–100 seconds away, otherwise skip 90s
        if skip >= 70 and skip <= 110 then
            mp.commandv("seek", next_time, "absolute")
        else
            mp.command("seek", 90)
        end
    else
        mp.command("seek", 90)
    end
end

local function manual_forward()
    local pos = mp.get_property_number("time-pos", 0)
    local list = mp.get_property_native("chapter-list")
    local ch = mp.get_property_number("chapter", 0)

    if list and #list > 0 and ch < #list - 1 then
        local next_start = list[ch + 2].time
        local skip = next_start - pos

        if skip > 0 and skip <= 110 then
            mp.commandv("seek", next_start, "absolute")
        else

            mp.command("seek 90")
        end
    else

    end
end

mp.observe_property("chapter", "number", auto_skip)
-- here you can change your keybind for manual skip
mp.add_key_binding("Ctrl+RIGHT", "manual_forward", manual_forward)

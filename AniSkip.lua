local mp = require 'mp'

-- skipped chapters names (case-insensitive)
local skip_patterns = { "opening", "intro", "op" }

local function should_skip(title)
    if not title then return false end
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

    local first  = list[1]
    local second = list[2]
    if ch == 0
       and first and first.time == 0
       and second and second.time
       and (second.time - first.time) > 100
    then
        return
    end

    local chapter_entry = list[ch + 1]
    local title = chapter_entry and chapter_entry.title or ""
    local t = title:lower()

    -- do not skip the intro if chapter is "intro" and next chapter is an "op",
    local next_ch = list[ch + 2] or {}
    local next_title = (next_ch.title or ""):lower()
    if t:find("intro", 1, true) and next_title:find("op", 1, true) then
        return
    end

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

        -- If next non-skip chapter is 70–100s away, jump to it; otherwise skip 90s
        if skip >= 70 and skip <= 100 then
            mp.commandv("seek", next_time, "absolute")
        else
            mp.commandv("seek", 90, "relative+exact")
        end
    else
        mp.commandv("seek", 90, "relative+exact")
    end
end

local function manual_forward()
    local pos  = mp.get_property_number("time-pos", 0)
    local list = mp.get_property_native("chapter-list")
    local ch   = mp.get_property_number("chapter", 0)

    if list and #list > 0 and ch < #list - 1 then
        local next_start = list[ch + 2].time
        local skip       = next_start - pos

        -- If next chapter is within 0–100s, jump to its start; otherwise skip 90s
        if skip > 0 and skip <= 100 then
            mp.commandv("seek", next_start, "absolute")
        else
            mp.commandv("seek", 90, "relative+exact")
        end
    else
        mp.commandv("seek", 90, "relative+exact")
    end
end

mp.observe_property("chapter", "number", auto_skip)
mp.add_key_binding("Ctrl+RIGHT", "manual_forward", manual_forward)

local mp = require 'mp'

local skip_patterns = { "opening", "intro", "op" }

local function should_skip(title)
    if not title then return false end
    local t = title:lower()
    for _, p in ipairs(skip_patterns) do
        if t:find(p, 1, true) then return true end
    end
    return false
end

local function auto_skip()
    local ch = mp.get_property_number("chapter", 0)
    local list = mp.get_property_native("chapter-list")
    if not list or ch >= #list then return end
    local title = list[ch+1].title
    if should_skip(title) then
        local n = ch + 1
        while n < #list and should_skip(list[n+1].title) do n = n + 1 end
        if n < #list then
            mp.set_property_number("chapter", n)
        else
            mp.command("seek 90")
        end
    end
end

mp.observe_property("chapter", "number", function() auto_skip() end)

local function manual_forward()
    local pos = mp.get_property_number("time-pos", 0)
    local list = mp.get_property_native("chapter-list")
    local ch = mp.get_property_number("chapter", 0)
    if list and ch < #list-1 then
        local next_start = list[ch+2].time
        local skip = next_start - pos
        if skip > 0 and skip <= 180 then
            mp.commandv("seek", skip, "exact")
        else
            mp.command("seek 90")
        end
    else
        mp.command("seek 90")
    end
end

mp.add_key_binding("Ctrl+RIGHT", "manual_forward", manual_forward)

local mp = require 'mp'

function skip_chapter_or_seek_forward()
    local chapter_list = mp.get_property_native("chapter-list")
    local chapter = mp.get_property_number("chapter", 0)
    if chapter_list and #chapter_list > 0 and chapter < #chapter_list - 1 then
        mp.command("add chapter 1")
    else
        mp.command("seek 90")
    end
end

function skip_chapter_or_seek_backward()
    local chapter_list = mp.get_property_native("chapter-list")
    local chapter = mp.get_property_number("chapter", 0)
    if chapter_list and #chapter_list > 0 and chapter > 0 then
        mp.command("add chapter -1")
    else
        mp.command("seek -90")
    end
end

mp.add_key_binding("Ctrl+RIGHT", "chapter_or_seek_forward", skip_chapter_or_seek_forward)
mp.add_key_binding("Ctrl+LEFT", "chapter_or_seek_backward", skip_chapter_or_seek_backward)

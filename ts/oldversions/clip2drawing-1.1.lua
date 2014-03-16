-- Draw a vectorial clip with the inbuild tool. Run this script to convert it to a vector drawing.
-- If there are other tags, make sure the clip is the last one. I'm too lazy to write more code right now.

script_name = "Convert clip to drawing"
script_description = "Converts clip to drawing"
script_author = "unanimated"
script_version = "1.1"

function convertclip(subs, sel)
    for z, i in ipairs(sel) do
	local l = subs[i]
	l.text = l.text:gsub("\\clip%(m(.-)%)}","\\p1}m%1")
	subs[i] = l
    end
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, convertclip)
local tr = aegisub.gettext

script_name = tr"Add fade"
script_description = tr"Adds fad tag"
script_author = "unanimated"
script_version = "1.1"


function add_fade(subtitles, selected_lines, active_line)
	for z, i in ipairs(selected_lines) do
		local l = subtitles[i]
		l.text = "{\\fad(0,0)}" .. l.text
		l.text = l.text:gsub("{\\fad(0,0)}{\\","{\\fad(0,0)\\")
		subtitles[i] = l
	end
	aegisub.set_undo_point(script_name)
	return selected_lines
end

aegisub.register_macro(script_name, tr"Adds \\fad(0,0) tags to all selected lines", add_fade)

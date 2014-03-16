local tr = aegisub.gettext

script_name = tr"Add alpha"
script_description = tr"Adds alpha&H00&"
script_author = "unanimated"
script_version = "1.1"


function add_alpha(subtitles, selected_lines, active_line)
	for z, i in ipairs(selected_lines) do
		local l = subtitles[i]
		l.text = "{\\alpha&H00&}" .. l.text
		l.text = l.text:gsub("{\\alpha&H00&}{\\","{\\alpha&H00&\\")
		subtitles[i] = l
	end
	aegisub.set_undo_point(script_name)
	return selected_lines
end

aegisub.register_macro(script_name, tr"Adds \\alpha&H00& tags to all selected lines", add_alpha)

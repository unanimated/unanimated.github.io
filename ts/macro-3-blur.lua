local tr = aegisub.gettext

script_name = tr"Add blur"
script_description = tr"Adds blur"
script_author = "unanimated"
script_version = "1.1"


function add_blur(subtitles, selected_lines, active_line)
	for z, i in ipairs(selected_lines) do
		local l = subtitles[i]
		l.text = "{\\blur0.6}" .. l.text
		l.text = l.text:gsub("{\\blur0.6}{\\","{\\blur0.6\\")
		subtitles[i] = l
	end
	aegisub.set_undo_point(script_name)
	return selected_lines
end

aegisub.register_macro(script_name, tr"Adds \\blur0.6 tags to all selected lines", add_blur)

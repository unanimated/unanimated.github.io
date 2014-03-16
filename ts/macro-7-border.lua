local tr = aegisub.gettext

script_name = tr"Add border0"
script_description = tr"Adds border0"
script_author = "unanimated"
script_version = "1.1"


function add_bord0(subtitles, selected_lines, active_line)
	for z, i in ipairs(selected_lines) do
		local l = subtitles[i]
		l.text = "{\\bord0}" .. l.text
		l.text = l.text:gsub("{\\bord0}{\\","{\\bord0\\")
		subtitles[i] = l
	end
	aegisub.set_undo_point(script_name)
	return selected_lines
end

aegisub.register_macro(script_name, tr"Adds \\bord0 tags to all selected lines", add_bord0)

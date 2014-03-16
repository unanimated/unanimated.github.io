-- adds \an8 tag. if there is one, it changes to \an5, then cycles through 1, 2, 3, 4, 6, 7, 9
script_name = "Add an8"
script_description = "Adds an8 tags"
script_author = "unanimated"
script_version = "1.2"

function add_an8(subs, sel, act)
	for z, i in ipairs(sel) do
		local line = subs[i]
		local text = subs[i].text
		if line.text:match("\\an8") then
		text = text:gsub("\\an8","\\an5")
		elseif line.text:match("\\an5") then
		text = text:gsub("\\an5","\\an1")
		elseif line.text:match("\\an1") then
		text = text:gsub("\\an1","\\an2")
		elseif line.text:match("\\an2") then
		text = text:gsub("\\an2","\\an3")
		elseif line.text:match("\\an3") then
		text = text:gsub("\\an3","\\an4")
		elseif line.text:match("\\an4") then
		text = text:gsub("\\an4","\\an6")
		elseif line.text:match("\\an6") then
		text = text:gsub("\\an6","\\an7")
		elseif line.text:match("\\an7") then
		text = text:gsub("\\an7","\\an9")
		elseif line.text:match("\\an9") then
		text = text:gsub("\\an9","")
		text = text:gsub("{}","")
		else
		text = "{\\an8}" .. text
		text = text:gsub("{\\an8}{\\","{\\an8\\")
		end
		line.text = text
		subs[i] = line		end
	aegisub.set_undo_point(script_name)
	return selected_lines
end

aegisub.register_macro(script_name, script_description, add_an8)
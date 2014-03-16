--This is a modification of Youka's add tags

script_name = "Add fade"
script_description = "Add fade tags to selected lines."
script_author = "Youka"
script_version = "1.1"
script_modified = "2012-06-14"

--Collect style names
function collect_styles(subs)
	local n, styles = 0, {}
	for i=1, #subs do
		local sub = subs[i]
		if sub.class == "style" then
			n = n + 1
			styles[n] = sub.name
		end
	end
	return styles
end

--Configuration
function create_confi(subs)
	local styles = collect_styles(subs)
	local conf = {
		{
			class = "checkbox", name = "check",
			label = "Add to all tag fields in line?",
			x = 0, y = 0, width = 5, height = 1,
			value = false
		},
		{
			class = "label",
			x = 0, y = 1, width = 1, height = 1,
			label = "Margin:"
		},
		{
			class = "dropdown", name = "margin",
			x = 1, y = 1, width = 5, height = 1,
			items = {"{...", "...}"}, value = "{...", hint = "Add to start or end of tag field?"
		},
		{
			class = "label",
			x = 0, y = 2, width = 1, height = 1,
			label = "Select:"
		},
		{
			class = "dropdown", name = "chosen",
			x = 1, y = 2, width = 5, height = 1,
			items = {"Selected Lines"}, value = "Selected Lines", hint = "Selected lines or specific style?"
		},
		{
			class = "label",
			x = 0, y = 3, width = 1, height = 1,
			label = ""
		},
		{
			class = "textbox", name = "txt",
			x = 1, y = 3, width = 12, height = 3,
			hint = "Modify fade value", text = "\\fad(0,0)"
		}
	}
	for i,w in pairs(styles) do
		table.insert(conf[5].items,"Style: " .. w)
	end
	return conf
end

--Add tags to line text
function change_tag(subs,index,config)
	local a = subs[index]
	if a.text:find("{\\") and a.text:find("}") then
		if config.check then
			if config.margin == "{..." then
				a.text = a.text:gsub("{", string.format("{%s",config.txt))
			else
				a.text = a.text:gsub("}", string.format("%s}",config.txt))
			end
		else
			if config.margin == "{..." then
				a.text = a.text:gsub("{", string.format("{%s",config.txt),1)
			else
				a.text = a.text:gsub("}", string.format("%s}",config.txt),1)
			end
		end
	else
		a.text = "{" .. config.txt .. "}" .. a.text
	end
	subs[index] = a
end

--Through chosen lines
function add_tags(subs,sel,config)
	if config.chosen == "Selected Lines" then
		for x, i in ipairs(sel) do
			change_tag(subs,i,config)
		end
	else
		for i=1, #subs do
			if subs[i].style == config.chosen:sub(8) then change_tag(subs,i,config) end
		end
	end
end

--Initialisation + GUI
function load_macro_add(subs,sel)
	local config
	repeat
		ok, config = aegisub.dialog.display(create_confi(subs),{"Add","Cancel"})
	until config.txt:sub(1,1) == "\\" or ok ~= "Add"
	if ok == "Add" then
		add_tags(subs,sel,config)
		aegisub.set_undo_point("\""..script_name.."\"")
	end
end

--Register macro in aegisub
aegisub.register_macro(script_name,script_description,load_macro_add)

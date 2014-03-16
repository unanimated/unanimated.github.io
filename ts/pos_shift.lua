script_name = "Position shifter"
script_description = "Shifting positions."
script_author = "Youka"
script_version = "1.31"

--Configuration
function create_config()
	local conf = {
		{
			class = "label",
			x = 0, y = 0, width = 1, height = 1,
			label = "\pos("
		},
		{
			class = "floatedit", name = "pos_x",
			x = 1, y = 0, width = 1, height = 1,
			value = 0.00, hint = "Shift x coordinate of \pos"
		},
		{
			class = "label",
			x = 2, y = 0, width = 1, height = 1,
			label = ","
		},
		{
			class = "floatedit", name = "pos_y",
			x = 3, y = 0, width = 1, height = 1,
			value = 0.00, hint = "Shift y coordinate of \pos"
		},
		{
			class = "label",
			x = 4, y = 0, width = 1, height = 1,
			label = ")"
		},
		{
			class = "label",
			x = 0, y = 1, width = 1, height = 1,
			label = "\move("
		},
		{
			class = "floatedit", name = "move_x1",
			x = 1, y = 1, width = 1, height = 1,
			value = 0.00, hint = "Shift first x coordinate of \move"
		},
		{
			class = "label",
			x = 2, y = 1, width = 1, height = 1,
			label = ","
		},
		{
			class = "floatedit", name = "move_y1",
			x = 3, y = 1, width = 1, height = 1,
			value = 0.00, hint = "Shift first y coordinate of \move"
		},
		{
			class = "label",
			x = 4, y = 1, width = 1, height = 1,
			label = ","
		},
		{
			class = "floatedit", name = "move_x2",
			x = 5, y = 1, width = 1, height = 1,
			value = 0.00, hint = "Shift second x coordinate of \move"
		},
		{
			class = "label",
			x = 6, y = 1, width = 1, height = 1,
			label = ","
		},
		{
			class = "floatedit", name = "move_y2",
			x = 7, y = 1, width = 1, height = 1,
			value = 0.00, hint = "Shift second y coordinate of \move"
		},
		{
			class = "label",
			x = 8, y = 1, width = 1, height = 1,
			label = "(, ?, ?) )"
		},
		{
			class = "label",
			x = 0, y = 2, width = 1, height = 1,
			label = "\org("
		},
		{
			class = "floatedit", name = "org_x",
			x = 1, y = 2, width = 1, height = 1,
			value = 0.00, hint = "Shift x coordinate of \org"
		},
		{
			class = "label",
			x = 2, y = 2, width = 1, height = 1,
			label = ","
		},
		{
			class = "floatedit", name = "org_y",
			x = 3, y = 2, width = 1, height = 1,
			value = 0.00, hint = "Shift y coordinate of \org"
		},
		{
			class = "label",
			x = 4, y = 2, width = 1, height = 1,
			label = ")"
		},
		{
			class = "label",
			x = 0, y = 3, width = 1, height = 1,
			label = "Clips:  x:"
		},
		{
			class = "floatedit", name = "clip_x",
			x = 1, y = 3, width = 1, height = 1,
			value = 0.00, hint = "Shift x coordinate of \pos"
		},
		{
			class = "label",
			x = 2, y = 3, width = 1, height = 1,
			label = " y:"
		},
		{
			class = "floatedit", name = "clip_y",
			x = 3, y = 3, width = 1, height = 1,
			value = 0.00, hint = "Shift y coordinate of \pos"
		}
	}
	return conf
end

--Shift positions of selected lines
function pos_shift(subs,sel,config)
	for x, i in ipairs(sel) do
		local a = subs[i]
		--\pos
		local function pos_repl(x,y)
			x, y = tonumber(x), tonumber(y)
			x = x + config.pos_x
			y = y + config.pos_y
			return string.format("\\pos(%.3f,%.3f)",x,y)
		end
		a.text = a.text:gsub("\\pos%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*)%)",pos_repl,1)
		--\move
		local function move_repl(x, y, x2, y2, t)
			t = t or ""
			x, y, x2, y2 = tonumber(x), tonumber(y), tonumber(x2), tonumber(y2)
			x = x + config.move_x1
			y = y + config.move_y1
			x2 = x2 + config.move_x2
			y2 = y2 + config.move_y2
			return string.format("\\move(%.3f,%.3f,%.3f,%.3f%s)",x,y,x2,y2,t)
		end
		a.text = a.text:gsub("\\move%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*)([%d%,%s]-)%)",move_repl,1)
		--\org
		local function org_repl(x,y)
			x, y = tonumber(x), tonumber(y)
			x = x + config.pos_x
			y = y + config.pos_y
			return string.format("\\org(%.3f,%.3f)",x,y)
		end
		a.text = a.text:gsub("\\org%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*)%)",org_repl,1)
		--\(i)clip (rectangle)
		local function rec_clip_repl(i, x1, y1, x2, y2)
			if not y2 then
				y2 = x2
				x2 = y1
				y1 = x1
				x1 = i
				i = ""
			end
			x1, y1, x2, y2 = tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
			x1 = x1 + config.clip_x
			y1 = y1 + config.clip_y
			x2 = x2 + config.clip_x
			y2 = y2 + config.clip_y
			return string.format("\\%sclip(%.3f,%.3f,%.3f,%.3f)", i, x1, y1, x2, y2)
		end
		a.text = a.text:gsub("\\(%i?)clip%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*)%)",rec_clip_repl,1)
		--\(i)clip (vectors)
		local function vec_clip_repl(i, acc, shape)
			if not shape then
				if not acc then
					shape = i
					i = ""
					acc = ""
				else
					shape = acc
					if i ~= "i" then
						acc = i
						i = ""
					else
						acc = ""
					end
				end
			end
			local function x_y_adder(x,y)
				x = x + config.clip_x
				y = y + config.clip_y
				return string.format("%d %d", x, y)
			end
			shape = shape:gsub("(%d+)%s*(%d+)", x_y_adder)
			return string.format("\\%sclip(%s%s)", i, acc, shape)
		end
		a.text = a.text:gsub("\\(%i?)clip%((%s*%d*%s*%,?)([mlbsc%s%d%-]+)%)",vec_clip_repl,1)
	--	a.text = a.text:gsub("(%([%d%,%.]*)%.000([%d%,%.]*))","%1%2")
		--Return changed line
		subs[i] = a
	end
end

--Initialisation + GUI
function load_macro_pos(subs,sel)
	local shift = {"Shift","Cancel"}
	local sh, config = aegisub.dialog.display(create_config(subs,meta),shift)
	if sh=="Shift" then
		pos_shift(subs,sel,config)
		aegisub.set_undo_point("\""..script_name.."\"")
		return sel
	end
end

--Test for activation (something to change?)
function test_pos(text)
	--\pos?
	local p1, p2 = text:match("\\pos%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*)%)")
	local tp = tonumber(p1) and tonumber(p2)
	--\move (without times)?
	local m1, m2, m3, m4 = text:match("\\move%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*)%)")
	local tm = tonumber(m1) and tonumber(m2) and tonumber(m3) and tonumber(m4)
	--\move (with times)?
	local mm1, mm2, mm3, mm4, mm5, mm6 = text:match("\\move%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%d+%s*),(%s*%d+%s*)%)")
	local tmm = tonumber(mm1) and tonumber(mm2) and tonumber(mm3) and tonumber(mm4) and tonumber(mm5) and tonumber(mm6)
	--\org?
	local o1, o2 = text:match("\\org%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*)%)")
	local to = tonumber(o1) and tonumber(o2)
	--Something in line?
	if tp or tm or tmm or to then return true end
	return nil
end

function activate_macro_pos(subs, sel)
	for x, i in ipairs(sel) do
		if not test_pos(subs[i].text) then
			return false
		end
	end
	return true
end

--Register macro in aegisub
aegisub.register_macro(script_name,script_description, load_macro_pos, activate_macro_pos)

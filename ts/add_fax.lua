-- add \fax tag, possibly \fay [not recommended, as it tends to break stuff under some circumstances]

script_name = "Add fax"
script_description = "Add fax tag"
script_author = "unanimated"
script_version = "1.0"

function fucks(subs, sel)
	for z, i in ipairs(sel) do
	    local l = subs[i]
	    if results["fay"]==false then
		l.text=l.text:gsub("\\fax[%d%.%-]-([\\}])","%1")
		if results["right"]==false then
		l.text="{\\fax" .. results["fax"] .. "}".. l.text
		else
		l.text="{\\fax" .. "-" .. results["fax"] .. "}".. l.text
		end
		l.text=l.text:gsub("^({\\[^}]-)}{\\","%1\\")
	    else
		l.text=l.text:gsub("\\fay[%d%.%-]-([\\}])","%1")
		if results["right"]==false then
		l.text="{\\fay" .. results["fax"] .. "}".. l.text
		else
		l.text="{\\fay" .. "-" .. results["fax"] .. "}".. l.text
		end
		l.text=l.text:gsub("^({\\[^}]-)}{\\","%1\\")
	    end	
	    subs[i] = l
	end
end

function faxconfig(subs, sel)
	dialog_config=
	{
	    {
		class="label",
		x=0,y=0,width=3,height=1,
		label="0.05 = 3 degrees; 1 = 45 degrees",
	    },
	    {
		class="edit",name="fax",
		x=1,y=1,width=1,height=1,
		value="0.05"
	    },
    	    {
		class="label",
		x=0,y=1,width=1,height=1,
		label="\\fax",
	    },
	    {
		class="checkbox",name="right",
		x=0,y=2,width=2,height=1,
		label=" Lean to the right (like italics)",
		value=false
	    },
	    {
		class="checkbox",name="fay",
		x=0,y=4,width=2,height=1,
		label="Use \\fay instead of \\fax",
		value=false
	    },
       	    {
		class="label",
		x=1,y=3,width=2,height=1,
		label="(...or upward for \\fay)",
	    },
	    {
		class="label",
		x=1,y=5,width=2,height=1,
		label="(not recommended)",
	    },
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,{"GO","Leave"})
	if pressed=="Leave" then aegisub.cancel() end
	if pressed=="GO" then fucks(subs, sel) end
end

function fax(subs, sel)
    faxconfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, fax)
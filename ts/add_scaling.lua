-- change font size, \fscx and \fscy for smoother scaling with Mocha

script_name = "Add scaling for Mocha"
script_description = "Add scaling tags for mocha tracking."
script_author = "unanimated"
script_version = "1.0"

function scale(subs, sel)
	for z, i in ipairs(sel) do
	    local l = subs[i]
		l.text=l.text:gsub("\\fs[%d%.]-([\\}])","%1")
		l.text=l.text:gsub("\\fscx[%d%.]-([\\}])","%1")
		l.text=l.text:gsub("\\fscy[%d%.]-([\\}])","%1")
		l.text=l.text:gsub("{}","")
		l.text="{\\fs" .. results["fs"] .. "\\fscx" .. results["fscx"] .. "\\fscy" .. results["fscy"] .. "}" .. l.text
		if results["tag"]=="{Start of tag block" then
		l.text=l.text:gsub("^({\\[^}]-)}{\\","%1\\")
		else
		l.text=l.text:gsub("^{(\\[^}]-)}{(\\[^}]-)}","{%2%1}")
		end
	    subs[i] = l
	end
	aegisub.set_undo_point(script_name)
	return sel
end

function scaleconfig(subs, sel)	
	dialog_config=
	{
	    {
		class="label",
		x=0,y=0,width=3,height=1,
		label="Select font size, fscx, and fscy",
	    },
    	    {
		class="label",
		x=0,y=1,width=1,height=1,
		label="\\fs",
	    },
	    {
		class="label",
		x=0,y=2,width=1,height=1,
		label="\\fscx",
	    },
	    {
		class="label",
		x=0,y=3,width=1,height=1,
		label="\\fscy",
	    },
	    {
		class="dropdown",name="fs",
		x=1,y=1,width=1,height=1,
		items={"1","2","3","4","5","6","7","8","9","10"},
		value="2"
	    },
	    {
		class="edit",name="fscx",
		x=1,y=2,width=1,height=1,
		value="2000"
	    },
	    {
		class="edit",name="fscy",
		x=1,y=3,width=1,height=1,
		value="2000"
	    },
	    {
		class="dropdown",name="tag",
		x=1,y=4,width=1,height=1,
		items={"{Start of tag block","End of tag block}"},
		value="{Start of tag block"
	    },
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,{"hai","iie"})
	if pressed=="iie" then aegisub.cancel() end
	if pressed=="hai" then scale(subs, sel) end
end

function mocha_scaling(subs, sel)
    scaleconfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, mocha_scaling)
-- Version 1.1 
-- Additional running of the script places the new transform at the end.

script_name = "Transform alpha"
script_description = "Creates transform tags for alpha"
script_author = "unanimated"
script_version = "1.1"

function talpha(subs, sel)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
		if line.text:match("\\alpha") and line.text:match("\\t")==nil then
		text = text:gsub("\\alpha&H..&","")
		text = text:gsub("{}","")
		line.text = text
		end
	    text = "{transforrrm}" .. text
	    text = text:gsub("{transforrrm}({\\[^}]*)}","%1transforrrm}")
		if line.text:match("\\t(.-alpha.-)") then
			if results["tcheck"]==true then
			    text = text:gsub("transforrrm",
			    "\\t(" .. results["start"] .. "," .. results["end"] .. "," .. results["accel"] .. "," .. 
			    "\\alpha&H" .. results["alphaout"] .. "&)")
			else
			    text = text:gsub("transforrrm","\\t(" .. "\\alpha&H" .. results["alphaout"] .. "&)")
			end
		else
			if results["tcheck"]==true then
			    text = text:gsub("transforrrm","\\alpha&H" .. results["alphain"] .. 
			    "&\\t(" .. results["start"] .. "," .. results["end"] .. "," .. results["accel"] .. "," .. 
			    "\\alpha&H" .. results["alphaout"] .. "&)")
			else
			    text = text:gsub("transforrrm","\\alpha&H" .. results["alphain"] .. 
			    "&\\t(" .. "\\alpha&H" .. results["alphaout"] .. "&)")
			end
		end
	    line.text = text
	    subs[i] = line
	end
end

function talphaconfig(subs, sel)
	dialog_config=
	{
	    {
		class="label",
		x=0,y=1,width=1,height=1,
		label="Alpha in:",
	    },
	    {
		class="label",
		x=0,y=2,width=1,height=1,
		label="Alpha out:",
	    },
	    {
		class="checkbox",name="tcheck",
		x=4,y=0,width=2,height=1,
		label="Enable times/acceleration",
		value=true
	    },
	    {
		class="dropdown",name="alphain",
		x=1,y=1,width=2,height=1,
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},
		value="00"
	    },
	    {
		class="dropdown",name="alphaout",
		x=1,y=2,width=2,height=1,
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},
		value="FF"
	    },
	    {
		class="floatedit",name="start",
		x=5,y=1,width=1,height=1,
		value="0"
	    },
	    {
		class="floatedit",name="end",
		x=5,y=2,width=1,height=1,
		value="0"
	    },
   	    {
		class="floatedit",name="accel",
		x=5,y=3,width=1,height=1,
		value="1"
	    },	
	    {
		class="label",
		x=0,y=0,width=3,height=1,
		label="Alpha before and after transform",
	    },
	    {
		class="label",
		x=4,y=1,width=1,height=1,
		label="\\t start",
	    },	
    	    {
		class="label",
		x=4,y=2,width=1,height=1,
		label="\\t end",
	    },
	    {
		class="label",
		x=4,y=3,width=1,height=1,
		label="accel",
	    },
	    {
		class="label",
		x=0,y=3,width=3,height=1,
		label="\\in\\t(start,end,accel,\\out)",
	    },
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,{"Transform","Cancel"})
	if pressed=="Cancel" then aegisub.cancel() end
	
	if pressed=="Transform" then talpha(subs, sel) end
end

function transform_alpha(subs, sel)
    talphaconfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, transform_alpha)
-- Creates transform tags for alpha. 
-- GUI lets you select alpha before and after transform, as well as start/end time and acceleration for the \t tag.
-- Additional running of the script places the new transform at the end.
-- If there already is an alpha tag, "Alpha in" will be ignored.

script_name = "Transform alpha"
script_description = "Creates transform tags for alpha"
script_author = "unanimated"
script_version = "1.2"

function talpha(subs, sel)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
	    text = "{transforrrm}" .. text
	    text = text:gsub("{transforrrm}({\\[^}]*)}","%1transforrrm}")
		if line.text:match("^{.-\\alpha.-}") then
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
	    {x=0,y=0,width=3,height=1,class="label",label="Alpha before and after transform", },
	    {x=0,y=1,width=1,height=1,class="label",label="Alpha in:",},
	    {x=0,y=2,width=1,height=1,class="label",label="Alpha out:",},
	    {x=1,y=1,width=2,height=1,class="dropdown",name="alphain", 
	    items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="00"},
	    {x=1,y=2,width=2,height=1,class="dropdown",name="alphaout", 
	    items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="FF"},
	    {x=0,y=3,width=3,height=1,class="label",label="\\in\\t(start,end,accel,\\out)",},
	    {x=4,y=0,width=2,height=1,class="checkbox",name="tcheck",label="Enable times/acceleration",value=true},
	    {x=4,y=1,width=1,height=1,class="label",label="\\t start",},
    	    {x=4,y=2,width=1,height=1,class="label",label="\\t end",},
	    {x=4,y=3,width=1,height=1,class="label",label="accel",},
	    {x=5,y=1,width=1,height=1,class="floatedit",name="start", value="0"},
	    {x=5,y=2,width=1,height=1,class="floatedit",name="end", value="0"},
   	    {x=5,y=3,width=1,height=1,class="floatedit",name="accel", value="1"},
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
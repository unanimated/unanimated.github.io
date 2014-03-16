-- Applies fade to selected lines. GUI lets you select or type fade-in / fade-out values.

script_name = "Apply fade"
script_description = "Applies fade to selected lines"
script_author = "unanimated"
script_version = "1.0"

function fade(subs, sel)
	for z, i in ipairs(sel) do
		local line = subs[i]
		local text = subs[i].text
			if line.text:match("\\fad%(") then
			text = text:gsub("\\fad%([%d%.%,]-%)","")
			line.text = text
			end
		text = "{\\fad(" .. results["fadein"] .. "," .. results["fadeout"] .. ")}" .. text
		text = text:gsub("%)}{",")")
		line.text = text
		subs[i] = line
	end
end

function txtfade(subs, sel)
	for z, i in ipairs(sel) do
		local line = subs[i]
		local text = subs[i].text
			if line.text:match("\\fad%(") then
			text = text:gsub("\\fad%([%d%.%,]-%)","")
			line.text = text
			end
		text = "{\\fad(" .. results["txtfadein"] .. "," .. results["txtfadeout"] .. ")}" .. text
		text = text:gsub("%)}{",")")
		line.text = text
		subs[i] = line
	end
end

function fadeconfig(subs, sel)	
	dialog_config=
	{
	    {x=0,y=1,width=1,height=1,class="label",label="Fade in:", },
	    {x=0,y=2,width=1,height=1,class="label",label="Fade out:",	 },
	    {x=5,y=1,width=1,height=1,class="floatedit",name="txtfadein",value="0" },
	    {x=5,y=2,width=1,height=1,class="floatedit",name="txtfadeout",value="0" },
	    {x=2,y=1,width=2,height=1,class="dropdown",name="fadein",
	items={"0","100","150","200","250","300","350","400","450","500","750","1000","1500","2000","3000","5000","10000"},value="500" },
	    {x=2,y=2,width=2,height=1,class="dropdown",name="fadeout",
	items={"0","100","150","200","250","300","350","400","450","500","750","1000","1500","2000","3000","5000","10000"},value="500" },
	    {x=0,y=0,width=3,height=1,class="label",label="Select fade to apply...", },
	    {x=5,y=0,width=1,height=1,class="label",label="or type values:", },
    	    {x=0,y=3,width=4,height=1,class="label",label="'Fade selected' applies this ^", },
	    {x=5,y=3,width=1,height=1,class="label",label=" ^ 'Fade custom' applies this", },
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,{"Fade selected", "<--- ? --->","Fade custom", "Cancel"})
	if pressed=="Fade selected" then fade(subs, sel) end
	if pressed=="Fade custom" then txtfade(subs, sel) end
end

function apply_fade(subs, sel)
    fadeconfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, apply_fade)
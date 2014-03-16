-- This turns your \fad tag into \t\alpha, letting you add accel for the fade in and fade out.
-- Supports present alpha tags. Supports multiple alpha tags in line (at least it should).
-- If there already is an alpha transform, expect things to break.
-- Added option to fade to/from black/white.

script_name = "Turn fade into transform"
script_description = "Turn fade into alpha transform"
script_author = "unanimated"
script_version = "1.4"

include("karaskel.lua")

function fadalpha(subs, sel)
	local meta,styles=karaskel.collect_head(subs,false)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
	    karaskel.preproc_line(sub,meta,styles,line)
		if line.text:match("\\fad%(") then
		fadin,fadout = line.text:match("\\fad%((%d+)%,(%d+)")
		primary=line.styleref.color1		primary=primary:gsub("H%x%x","H")
		pri=text:match("\\c(&H%x+&)")		if pri~=nil then primary=pri end
		outline=line.styleref.color3		outline=outline:gsub("H%x%x","H")
		out=text:match("\\3c(&H%x+&)")		if out~=nil then outline=out end
		border=line.styleref.outline
		bord=text:match("\\bord([%d%.]+)")	if bord~=nil then border=bord end
	-- with alpha in line
		if line.text:match("\\alpha&H%x%x&") then
		arfa=line.text:match("\\alpha&H(%x%x)")
		    if fadin~="0" then
				-- fade from colour
			    if results["crl"]==true then
			text = text:gsub("\\1?c&H%x+&","")
			text = text:gsub("\\3c&H%x+&","")
					if results["kolora"]=="Fade from Black" then
			text = text:gsub("^({\\[^}]-)}",
			"%1\\c&H000000&\\3c&H000000&\\t(0," .. fadin .."," .. results["inn"] .. ",\\c"..primary.."\\3c"..outline..")}") end
					if results["kolora"]=="Fade from White" then
			text = text:gsub("^({\\[^}]-)}",
			"%1\\c&HFFFFFF&\\3c&HFFFFFF&\\t(0," .. fadin .."," .. results["inn"] .. ",\\c"..primary.."\\3c"..outline..")}") end
				-- fade from alpha
			    else
			text = text:gsub("{([^}]-)(\\alpha&H%x%x&)([^}]-)}","{%1%3\\alpha&HFF&\\t(0," ..fadin.."," ..results["inn"].. ",%2)}")
			    end
		    end
		    if fadout~="0" then
				-- fade to colour
			    if results["clr"]==true then
				if results["kolorb"]=="Fade to Black" then
		text = text:gsub("({\\[^}]-)}","%1\\t(" ..line.duration-fadout..",0," ..results["ut"].. ",\\c&H000000&\\3c&H000000&)}") end
				if results["kolorb"]=="Fade to White" then
		text = text:gsub("({\\[^}]-)}","%1\\t(" ..line.duration-fadout..",0," ..results["ut"].. ",\\c&HFFFFFF&\\3c&HFFFFFF&)}") end
				-- fade to alpha
			    else
			text = text:gsub("({\\[^}]-)}","%1\\t(" ..line.duration-fadout..",0," ..results["ut"].. ",\\alpha&HFF&)}")
			    end
		    end
	-- without alpha
		else
		    if fadin~="0" then
				-- fade from colour
			    if results["crl"]==true then
			text = text:gsub("\\1?c&H%x+&","")
			text = text:gsub("\\3c&H%x+&","")
					if results["kolora"]=="Fade from Black" then
			text = text:gsub("^({\\[^}]-)}",
			"%1\\c&H000000&\\3c&H000000&\\t(0," .. fadin .."," .. results["inn"] .. ",\\c"..primary.."\\3c"..outline..")}") end
					if results["kolora"]=="Fade from White" then
			text = text:gsub("^({\\[^}]-)}",
			"%1\\c&HFFFFFF&\\3c&HFFFFFF&\\t(0," .. fadin .."," .. results["inn"] .. ",\\c"..primary.."\\3c"..outline..")}") end
				-- fade from alpha
			    else
			text = text:gsub("^({\\[^}]-)}","%1\\alpha&HFF&\\t(0," .. fadin .."," .. results["inn"] .. ",\\alpha&H00&)}")
			    end
		    end
		    if fadout~="0" then
				-- fade to colour
			    if results["clr"]==true then
				if results["kolorb"]=="Fade to Black" then
		text = text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout ..",0," .. results["ut"] .. ",\\c&H000000&\\3c&H000000&)}") end
				if results["kolorb"]=="Fade to White" then
		text = text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout ..",0," .. results["ut"] .. ",\\c&HFFFFFF&\\3c&HFFFFFF&)}") end
				-- fade to alpha
			    else
			text = text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout ..",0," .. results["ut"] .. ",\\alpha&HFF&)}")
			    end
		    end
		end
		if border=="0" then text=text:gsub("\\3c&H%d+&","") end
		if line.text:match("\\fad%(0,0%)")==nil then text = text:gsub("\\fad%(%d+%,%d+%)","") end	-- nuke the fade
		  if fadin=="0" and fadout=="0" then aegisub.dialog.display(
		  {{class="label",label="Some lines were skipped \nbecause they contain \\fad(0,0)",x=0,y=0,width=1,height=2}},{"OK"})
		  end
		end
	    line.text = text
	    subs[i] = line
	end
end

function konfig(subs, sel)
	dialog_config=
	{
	    {x=0,y=1,width=1,height=1,class="label",label="Fade in accel:",},
	    {x=0,y=2,width=1,height=1,class="label",label="Fade out accel:",},
	    {x=1,y=1,width=1,height=1,class="floatedit",name="inn",value="1"},
	    {x=1,y=2,width=1,height=1,class="floatedit",name="ut",value="1"},
	    {x=0,y=0,width=2,height=1,class="label",label="This will turn \\fad into \\t\\alpha with accel",},
	    {x=0,y=3,width=2,height=1,class="label",label="accel <1 starts fast, ends slow",},
	    {x=0,y=4,width=2,height=1,class="label",label="accel >1 starts slow, ends fast",},
	    {x=0,y=5,width=2,height=1,class="checkbox",name="clr",label="fade to colour",value=false},
	    {x=0,y=6,width=2,height=1,class="dropdown",name="kolorb",items={"Fade to Black","Fade to White"},value="Fade to Black"},
	    {x=0,y=7,width=2,height=1,class="checkbox",name="crl",label="fade from colour",value=false},
	    {x=0,y=8,width=2,height=1,class="dropdown",name="kolora",items={"Fade from Black","Fade from White"},value="Fade from White"},
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,{"Transform","Cancel"})
	if pressed=="Cancel" then aegisub.cancel() end
	if pressed=="Transform" then fadalpha(subs, sel) end
end

function fade2alpha(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, fade2alpha)
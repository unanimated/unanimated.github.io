-- This turns your \fad tag into \t\alpha, letting you add accel for the fade-in and fade-out.
-- Supports present alpha tags. Supports multiple alpha tags in line (at least it should).
-- If there already is an alpha transform, expect things to break.

script_name = "Turn fade into transform"
script_description = "Turn fade into alpha transform"
script_author = "unanimated"
script_version = "1.0"

include("karaskel.lua")

function fadalpha(subs, sel)
	local meta,styles=karaskel.collect_head(subs,false)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
	    karaskel.preproc_line_text(meta, styles, line)
		if line.text:match("\\fad%(") then
		fadin,fadout = line.text:match("\\fad%((%d+)%,(%d+)")
		-- with alpha in line
		if line.text:match("\\alpha&H%x%x&") then
		arfa=line.text:match("\\alpha&H(%x%x)")
--		text = text:gsub("\\alpha&H%x%x&","")
		    if fadin~="0" then
			text = text:gsub("{([^}]-)(\\alpha&H%x%x&)([^}]-)}","{%1%3\\alpha&HFF&\\t(0," ..fadin.."," ..results["inn"].. ",%2)}")
		    end		    
		    if fadout~="0" then
			text = text:gsub("({\\[^}]-)}","%1\\t(" ..line.duration-fadout..",0," ..results["ut"].. ",\\alpha&HFF&)}")
--			if fadin~="0" then text = text:gsub("\\alpha&H"..arfa.."&\\t","\\t") end
		    end		    
		-- without alpha
		else
		    if fadin~="0" then
			text = text:gsub("^({\\[^}]-)}","%1\\alpha&HFF&\\t(0," .. fadin .."," .. results["inn"] .. ",\\alpha&H00&)}")
		    end		    
		    if fadout~="0" then
			text = text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout ..",0," .. results["ut"] .. ",\\alpha&HFF&)}")
		    end		    
		end
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
	    {
		class="label",
		x=0,y=1,width=1,height=1,
		label="Fade in accel:",
	    },
	    {
		class="label",
		x=0,y=2,width=1,height=1,
		label="Fade out accel:",
	    },
	    {
		class="floatedit",name="inn",
		x=1,y=1,width=1,height=1,
		value="1"
	    },
	    {
		class="floatedit",name="ut",
		x=1,y=2,width=1,height=1,
		value="1"
	    },
	    {
		class="label",
		x=0,y=0,width=2,height=1,
		label="This will turn \\fad into \\t\\alpha with accel",
	    },
	    {
		class="label",
		x=0,y=3,width=2,height=1,
		label="accel <1 starts fast, ends slow",
	    },	
    	    {
		class="label",
		x=0,y=4,width=2,height=1,
		label="accel >1 starts slow, ends fast",
	    },
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
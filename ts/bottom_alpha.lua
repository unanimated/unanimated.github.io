-- This is for signs with border and fade, after you've used "Duplicate and Blur"
-- It makes the bottom layer's primary colour transparent during the fade.

script_name = "Bottom alpha"
script_description = "sets alpha for bottom layer of a 2-layer sign"
script_author = "unanimated"
script_version = "1.1"

include("karaskel.lua")

function blpha(subs, sel)
	local meta,styles=karaskel.collect_head(subs,false)
	zerocheck=0
	fadecheck=0
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
	    karaskel.preproc_line(sub,meta,styles,line)
		if line.text:match("\\fad%(") then
		fadin,fadout = line.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-results["inn"] .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout .."," .. line.duration-fadout+results["ut"] .. ",\\1a&HFF&)}")
		    end
		  if fadin=="0" and fadout=="0" then zerocheck=1 end
		else
		fadecheck=1
		end
	    line.text = text
	    subs[i] = line
	end
	if zerocheck==1 then aegisub.log("Some lines were skipped because they contain \\fad(0,0)")  end
	if fadecheck==1 then aegisub.log("Some lines were skipped because they don't contain \\fad")  end
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=1,width=1,height=1,class="label",label="ms to fade in:", },
	    {	x=0,y=2,width=1,height=1,class="label",label="ms to fade out:", },
	    {	x=0,y=0,width=2,height=1,class="label",label="fade for bottom layer of a 2-layer sign",},
	    {	x=0,y=3,width=2,height=1,class="label",label="run this after 'Duplicate and Blur'", },
	    {	x=0,y=4,width=2,height=1,class="label",label="line must contain a \\fad tag", },
	    {	x=1,y=1,width=2,height=1,class="dropdown",name="inn",items={"0","45","80","120"},value="45" },
	    {	x=1,y=2,width=2,height=1,class="dropdown",name="ut",items={"0","45","80","120"},value="45" },
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,{"Transform","Go away, please"})
	if pressed=="Go away, please" then aegisub.cancel() end
	if pressed=="Transform" then blpha(subs, sel) end
end

function bottomalpha(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, bottomalpha)
-- Creates a new layer with more blur and some alpha. The original line's layer is raised by 1,
-- so if you want to combine this with Duplicate and Blur, run this one first, otherwise you mess up the layers.
-- If you already ran Duplicate and Blur or just need to fix layers for multiple lines, there's another function for that here.
-- The two functions are independent - you either run one or the other.

script_name = "Add glow / Raise layer"
script_description = "Add glow to signs or raise layer for all selected lines"
script_author = "unanimated"
script_version = "1.0"

function glow(subs, sel)
    for i=#sel,1,-1 do
	line = subs[sel[i]]
	text = subs[sel[i]].text
	    if text:match("\\blur") then
	    line2=line
	    line2.layer=line2.layer+1
	    subs.insert(sel[i]+1,line2)
	    text=text:gsub("(\\blur)[%d%.]*([\\}])","%1"..res["blur"].."\\alpha&H"..res["alfa"].."&%2")
	    line.layer=line.layer-1
	    line.text = text
	    else
	    aegisub.dialog.display({{class="label",
		    label="What are you doing? Where is your blur?",x=0,y=0,width=1,height=2}},{"OK"})
	    end
	subs[sel[i]] = line
    end
end

function layeraise(subs, sel)
    for i=#sel,1,-1 do
	line = subs[sel[i]]
	text = subs[sel[i]].text
	    if res["raise"]=="raise by:" then
	    line.layer=line.layer+res["layer"]
	    else
		    if line.layer-res["layer"]>=0 then
		line.layer=line.layer-res["layer"] else
		    aegisub.dialog.display({{class="label",
		    label="You're dumb. Layers can't go below 0.",x=0,y=0,width=1,height=2}},{"OK"})
		    end
	    end
	subs[sel[i]] = line
    end
    return sel
end
	    
function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=0,width=2,height=1,class="label",label="Add glow to signs", },
	    
	    {	x=0,y=1,width=1,height=1,class="label",label="Glow blur:" },
	    {	x=0,y=2,width=1,height=1,class="label",label="Glow alpha:" },
	    
	    {	x=1,y=1,width=1,height=1,class="floatedit",name="blur",value="3" },
	    {	x=1,y=2,width=1,height=1,class="dropdown",name="alfa",
	    items={"20","30","40","50","60","70","80","90","A0","B0","C0","D0"},value="80" },
	    
	    {	x=3,y=0,width=1,height=1,class="label",label="Layer:", },
	    {	x=3,y=1,width=1,height=1,class="dropdown",name="raise",items={"raise by:","lower by:"},value="raise by:" },
	    {	x=3,y=2,width=1,height=1,class="dropdown",name="layer",items={"1","2","3","4","5"},value="1" },
	    
	} 	
	buttons={"Apply glow","-        cancel        -","Change layer"}
	pressed, res = aegisub.dialog.display(dialog_config,buttons)
	if pressed=="Apply glow" then glow(subs, sel) end
	if pressed=="Change layer" then layeraise(subs, sel) end
end

function addglow(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, addglow)
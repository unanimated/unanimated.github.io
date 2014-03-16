script_name = "Teleporter"
script_description = "Teleporter aka position/move/org/clip shifter"
script_author = "unanimated"
script_version = "1.3"		-- added support for vectorial clips

function teleport(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	xx=res.eks
	yy=res.wai

	if res.pos then
	    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)",
	    function(a,b) return "\\pos(".. a+xx.. "," ..b+yy..")" end)
	end

	if res.org then
	    text=text:gsub("\\org%(([%d%.%-]+)%,([%d%.%-]+)%)",
	    function(a,b) return "\\org(".. a+xx.. "," ..b+yy..")" end)
	end

	if res.mov then
	    text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
	    function(a,b,c,d) return "\\move("..a+xx.. "," ..b+yy.. "," ..c+xx.. "," ..d+yy end)
	end

	if res.clip then
	    text=text:gsub("clip%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
	    function(a,b,c,d) return "clip("..a+xx.. "," ..b+yy.. "," ..c+xx.. "," ..d+yy end)
	    
	    if text:match("clip%(m [%d%a%s%-]+%)") then
	    ctext=text:match("clip%(m ([%d%a%s%-]+)%)")
	    ctext2=ctext:gsub("([%d%-]+)%s([%d%-]+)",function(a,b) return a+xx.." "..b+yy end)
	    ctext=ctext:gsub("%-","%%-")
	    text=text:gsub(ctext,ctext2)
	    end
	end

	line.text = text
	subs[i] = line
    end
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=0,width=1,height=1,class="label",label="Shift X by:"},
	    {	x=0,y=1,width=1,height=1,class="label",label="Shift Y by:"},
	    {	x=1,y=0,width=2,height=1,class="floatedit",name="eks"},
	    {	x=1,y=1,width=2,height=1,class="floatedit",name="wai"},

	    {	x=0,y=2,width=1,height=1,class="checkbox",name="pos",label="\\pos",value=true },
	    {	x=0,y=3,width=1,height=1,class="checkbox",name="mov",label="\\move",value=true },
	    {	x=1,y=2,width=1,height=1,class="checkbox",name="clip",label="\\[i]clip",value=true },
	    {	x=1,y=3,width=1,height=1,class="checkbox",name="org",label="\\org",value=true },
	} 	
	buttons={"Teleport","Stay here"}
	pressed, res = aegisub.dialog.display(dialog_config,buttons)
	if pressed=="Teleport" then teleport(subs, sel) end
end

function teleporter(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, teleporter)
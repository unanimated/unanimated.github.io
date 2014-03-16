-- Unlike with Teleporter, you set target position, not position difference, but all your lines must have the same position.

script_name = "Gradient Shifter"
script_description = "Gradient Shifter"
script_author = "unanimated"
script_version = "1.0"

function shift(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	xx=res.eks
	yy=res.wai
	p1,p2=text:match("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)")
	if p1==nil then p1,p2=text:match("\\move%(([%d%.%-]+)%,([%d%.%-]+)") end
	xxx=xx-p1
	yyy=yy-p2

	if res.pos then
	    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\pos("..xx.."," ..yy..")" )
	end

	if res.org then
	    text=text:gsub("\\org%(([%d%.%-]+)%,([%d%.%-]+)%)",
	    function(a,b) return "\\org(".. a+xxx.. "," ..b+yyy..")" end)
	end

	if res.mov then
	    text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
	    function(a,b,c,d) return "\\move("..a+xxx.. "," ..b+yyy.. "," ..c+xxx.. "," ..d+yyy end)
	end

	if res.clip then
	    text=text:gsub("clip%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
	    function(a,b,c,d) return "clip("..a+xxx.. "," ..b+yyy.. "," ..c+xxx.. "," ..d+yyy end)
	end

	line.text = text
	subs[i] = line
    end
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=0,width=1,height=1,class="label",label="Target X:"},
	    {	x=0,y=1,width=1,height=1,class="label",label="Target Y:"},
	    {	x=1,y=0,width=2,height=1,class="floatedit",name="eks"},
	    {	x=1,y=1,width=2,height=1,class="floatedit",name="wai"},

	    {	x=0,y=2,width=1,height=1,class="checkbox",name="pos",label="\\pos",value=true },
	    {	x=0,y=3,width=1,height=1,class="checkbox",name="mov",label="\\move",value=true },
	    {	x=1,y=2,width=1,height=1,class="checkbox",name="clip",label="\\[i]clip",value=true },
	    {	x=1,y=3,width=1,height=1,class="checkbox",name="org",label="\\org",value=true },
	} 	
	buttons={"Shift","Nope"}
	pressed, res = aegisub.dialog.display(dialog_config,buttons)
	if pressed=="Shift" then shift(subs, sel) end
end

function gradshift(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, gradshift)
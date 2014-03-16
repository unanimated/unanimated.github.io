-- creates a 3D effect using layers of shadow (unfortunatelly, vsfilter fucks this up pretty bad with rotations)

script_name="Shadow 3D Effect"
script_description="Creates 3D Effect from Shadow"
script_author="unanimated"
script_version="1.0"

function threedee(subs, sel)
    for i=#sel,1,-1 do
        local line=subs[sel[i]]
        local text=subs[sel[i]].text
	local layer=line.layer
	
	xshad=text:match("^{[^}]-\\xshad([%d%.%-]+)")	if xshad==nil then xshad=0 end 	ax=math.abs(xshad)
	yshad=text:match("^{[^}]-\\yshad([%d%.%-]+)")	if yshad==nil then yshad=0 end 	ay=math.abs(yshad)
	if ax>ay then lay=math.floor(ax) else lay=math.floor(ay) end
	
	text2=text:gsub("^({\\[^}]-)}","%1\\3a&HFF&}")	:gsub("\\3a&H%x%x&([^}]-)(\\3a&H%x%x&)","%1%2")
	
	for l=lay,1,-1 do
	    line2=line	    f=l/lay
	    txt=text2	    if l==1 then txt=text end
	    line2.text=txt
	    :gsub("\\xshad([%d%.%-]+)",function(a) xx=tostring(f*a) xx=xx:gsub("([%d%-]+%.%d%d)%d+","%1") return "\\xshad"..xx end)   
	    :gsub("\\yshad([%d%.%-]+)",function(a) yy=tostring(f*a) yy=yy:gsub("([%d%-]+%.%d%d)%d+","%1") return "\\yshad"..yy end)
	    line2.layer=layer+(lay-l)
	    subs.insert(sel[i]+1,line2)
	end

	if not xshad==0 and not yshad==0 then subs.delete(sel[i]) end
    end
end

function shad3d(subs, sel, act)
    threedee(subs, sel, act)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, shad3d)
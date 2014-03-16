-- Go from \clip(x1,y1,x2,y2) to \clip(x1,y1,x2,y2)\t(\clip(x3,y3,x4,y4)). 
-- Coordinates are read from the line. You can set by how much x and y should change, and new coordinates will be calculated.
-- "use next line's clip" allows you to use clip from the next line. 
--	Create a line after your current one (or just duplicate), set the clip you want to transform to on it, check "use next line's clip".
--	The clip from the next line will be used for the transform, and the line will be deleted.

script_name="Transform clip"
script_description="Transform clip"
script_author="unanimated"
script_version="1.3"

function transclip(subs,sel,act)
line=subs[act]
text=line.text
if not text:match("\\i?clip%([%d%.%-]+,") then aegisub.dialog.display({{class="label",
	label="Error: rectangular clip required on active line.",x=0,y=0,width=1,height=2}},{"OK"},{close='OK'}) aegisub.cancel() end

ctype,cc1,cc2,cc3,cc4=text:match("(\\i?clip)%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)%)")

clipconfig={
    {x=0,y=0,width=2,height=1,class="label",label="   \\clip(", },
    {x=2,y=0,width=3,height=1,class="edit",name="orclip",value=cc1..","..cc2..","..cc3..","..cc4 },
    {x=5,y=0,width=1,height=1,class="label",label=")", },
    {x=0,y=1,width=2,height=1,class="label",label="\\t(\\clip(", },
    {x=2,y=1,width=3,height=1,class="edit",name="klip",value=cc1..","..cc2..","..cc3..","..cc4 },
    {x=5,y=1,width=1,height=1,class="label",label=")", },
    {x=0,y=2,width=5,height=1,class="label",label="Move x and y for new coordinates by:", },
    {x=0,y=3,width=1,height=1,class="label",label="x:", },
    {x=3,y=3,width=1,height=1,class="label",label="y:", },
    {x=1,y=3,width=2,height=1,class="floatedit",name="eks"},
    {x=4,y=3,width=1,height=1,class="floatedit",name="wai"},
    {x=0,y=4,width=5,height=1,class="label",label="Start / end / accel:", },
    {x=1,y=5,width=2,height=1,class="edit",name="accel",value="0,0,1," },
    {x=4,y=5,width=1,height=1,class="checkbox",name="two",label="use next line's clip",value=false,hint="use clip from the next line (line will be deleted)"},
}
	buttons={"Transform","Calculate coordinates","Cancel"}
	pressed,res=aegisub.dialog.display(clipconfig,buttons,{ok='Transform',close='Cancel'})
	if pressed=="Cancel" then aegisub.cancel() end

	repeat
	    if pressed=="Calculate coordinates" then
		xx=res.eks	yy=res.wai
		for key,val in ipairs(clipconfig) do
		    if val.name=="klip" then val.value=cc1+xx..","..cc2+yy..","..cc3+xx..","..cc4+yy end
		    if val.name=="accel" then val.value=res.accel end
		end	
	pressed,res=aegisub.dialog.display(clipconfig,buttons,{ok='Transform',close='Cancel'})
	    end
	until pressed~="Calculate coordinates"
	if pressed=="Transform" then newcoord=res.klip end
	
    if res.two then
	nextline=subs[act+1]
	nextext=nextline.text
      if not nextext:match("\\i?clip%([%d%.%-]+,") then aegisub.dialog.display({{class="label",
	label="Error: second line must contain a rectangular clip.",x=0,y=0,width=1,height=2}},{"OK"},{close='OK'}) aegisub.cancel()
	else
	nextclip=nextext:match("\\i?clip%(([%d%.%-,]+)%)")
	text=text:gsub("^({\\[^}]*)}","%1\\t("..res.accel..ctype.."("..nextclip..")}")
      end
    else
	text=text:gsub("^({\\[^}]*)}","%1\\t("..res.accel..ctype.."("..newcoord..")}")
    end	
    
text=text:gsub("0,0,1,\\","\\")
line.text=text
subs[act]=line
if res.two then subs.delete(act+1) end
aegisub.set_undo_point(script_name)
return sel
end

aegisub.register_macro(script_name, script_description, transclip)
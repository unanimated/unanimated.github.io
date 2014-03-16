-- Go from \clip(x1,y1,x2,y2) to \clip(x1,y1,x2,y2)\t(\clip(x3,y3,x4,y4)). 
-- Coordinates are read from the line. You can set by how much x and y should change and it will calculate new coordinates.
-- Works for \iclip too. You can only select one line, otherwise it wouldn't make sense.
-- "use next line's clip" allows you to use clip from the next line. 
--	Create a line after your current one (or just duplicate), set the clip you want to transform to on it, check "use next line's clip".
--	The clip from the next line will be used for the transform, and the line will be deleted.

script_name = "Transform clip"
script_description = "Transform clip"
script_author = "unanimated"
script_version = "1.2"

function transclip(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	derp=0
	if x==1 and text:match("\\i?clip")==nil then derp=1 else
	if #sel==1 and text:match("clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)%)") then
	cc1,cc2,cc3,cc4=text:match("clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)%)")
	
	konfig(subs, sel)
	end
	selcheck=0 if #sel>1 then selcheck=1 end
	
	  if #sel==1 then
	    if res.two then
		nextline=subs[i+1]
		nextext=nextline.text
		nextfail=0
	      if nextext:match("\\i?clip")==nil then nextfail=1 else
		nextclip=nextext:match("\\i?clip%(([%d%.%-,]+)%)")
		if text:match("\\iclip") then
		text=text:gsub("^({\\[^}]*)}","%1\\t("..res["accel"].."\\iclip("..nextclip..")}")
		else
		text=text:gsub("^({\\[^}]*)}","%1\\t("..res["accel"].."\\clip("..nextclip..")}")
		end
		
	      end	
	    else
		if text:match("\\iclip") then
		text=text:gsub("^({\\[^}]*)}","%1\\t("..res["accel"].."\\iclip("..newcoord..")}")
		else
		text=text:gsub("^({\\[^}]*)}","%1\\t("..res["accel"].."\\clip("..newcoord..")}")
		end
	    end	
	  end
	text=text:gsub("0,0,1,\\","\\")
	line.text = text
	subs[i] = line
	if #sel==1 and res.two then subs.delete(i+1) end
	end
    end
    if derp==1 then aegisub.dialog.display({{class="label",
		label="Error: clip where?",x=0,y=0,width=1,height=2}},{"OK"}) end
    if nextfail==1 then aegisub.dialog.display({{class="label",
		label="Error: second line must contain a clip.",x=0,y=0,width=1,height=2}},{"OK"}) end
    if selcheck==1 then aegisub.dialog.display({{class="label",
		label="Select only one line.",x=0,y=0,width=1,height=2}},{"OK"}) end
		
    aegisub.set_undo_point(script_name)
    return sel
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=0,width=4,height=1,class="label",label="Transform clip [first selected line only]", },
	    {	x=2,y=1,width=1,height=1,class="label",label=")\\t(\\clip(", },
	    
	    {	x=0,y=1,width=1,height=1,class="label",label="\\clip(", },
	    {	x=4,y=1,width=1,height=1,class="label",label=")", },
	    
	    {	x=3,y=1,width=1,height=1,class="edit",name="klip",value=cc1..","..cc2..","..cc3..","..cc4 },
	    {	x=1,y=1,width=1,height=1,class="edit",name="orclip",value=cc1..","..cc2..","..cc3..","..cc4 },
	    
	    {	x=0,y=2,width=4,height=1,class="label",label="Move x and y for new coordinates by:", },
	    {	x=0,y=3,width=1,height=1,class="label",label="x:", },
	    {	x=2,y=3,width=1,height=1,class="label",label="y:", },
	    
	    {	x=1,y=3,width=1,height=1,class="floatedit",name="eks"},
	    {	x=3,y=3,width=1,height=1,class="floatedit",name="wai"},
	    
	    {	x=0,y=4,width=4,height=1,class="label",label="Start time, end time, accel for transform:", },
	    {	x=1,y=5,width=1,height=1,class="edit",name="accel",value="0,0,1," },
	    
	    {	x=3,y=5,width=1,height=1,class="checkbox",name="two",label="use next line's clip",value=false,hint="use clip from the next line (line will be deleted)"},
	    
	} 	
	buttons={"Transform","Calculate new coordinates","Cancel"}
	pressed, res = aegisub.dialog.display(dialog_config,buttons)
	if pressed=="Cancel" then aegisub.cancel() end

	repeat
	    if pressed=="Calculate new coordinates" then
		xx=res["eks"]	yy=res["wai"]
		nc1=cc1+xx	nc2=cc2+yy
		nc3=cc3+xx	nc4=cc4+yy
	    
		for key,val in ipairs(dialog_config) do
		    if val.name=="klip" then
			val.value=nc1..","..nc2..","..nc3..","..nc4
		    end
		    if val.name=="accel" then
			val.value=res.accel
		    end
		end	
	pressed,res=aegisub.dialog.display(dialog_config,buttons)
	    end
	until pressed~="Calculate new coordinates"

	if pressed=="Transform" then newcoord=res.klip end

end

aegisub.register_macro(script_name, script_description, transclip)
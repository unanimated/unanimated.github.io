-- Example: Set to 120%, check fscx and fscy, and all values for fscx/y will be increased by 20% for selected lines.

script_name="Recalculator"
script_description="recalculates sizes of things"
script_author="unanimated"
script_version="1.4"

include("karaskel.lua")

function calc(num)
    c=res.pc/100
    if pressed=="Multiply" then num=math.floor((num*c*100)+0.5)/100 end
    if pressed=="Add" then num=num+res.add end
    return num
end

function multiply(subs, sel)
local meta,styles=karaskel.collect_head(subs,false)
    for x, i in ipairs(sel) do
        local line=subs[i]
	local text=line.text
	karaskel.preproc_line(sub,meta,styles,line)
	if not text:match("^{\\") then text="{\\}"..text end
	
		scx=line.styleref.scale_x
	if res.fscx and not text:match("\\fscx") then text=text:gsub("^({\\[^}]*)}","%1\\fscx"..scx.."}") end
		scy=line.styleref.scale_y
	if res.fscy and not text:match("\\fscy") then text=text:gsub("^({\\[^}]*)}","%1\\fscy"..scy.."}") end
		fsize=line.styleref.fontsize
	if res.fs and not text:match("\\fs%d") then text=text:gsub("^({\\[^}]*)}","%1\\fs"..fsize.."}") end 
		brdr=line.styleref.outline
	if res.bord and not text:match("\\bord") and brdr~=0 then text=text:gsub("^({\\[^}]*)}","%1\\bord"..brdr.."}") end
		shdw=line.styleref.shadow
	if res.shad and not text:match("\\shad") and shdw~=0 then text=text:gsub("^({\\[^}]*)}","%1\\shad"..shdw.."}") end
		spac=line.styleref.spacing
	if res.fsp and not text:match("\\fsp") and spac~=0 then text=text:gsub("^({\\[^}]*)}","%1\\fsp"..spac.."}") end
	
	    if res.fscx then text=text:gsub("\\fscx([%d%.]+)",function(a) return "\\fscx"..calc(tonumber(a)) end) end
	    if res.fscy then text=text:gsub("\\fscy([%d%.]+)",function(a) return "\\fscy"..calc(tonumber(a)) end) end
	    if res.fs then text=text:gsub("\\fs([%d%.]+)",function(a) return "\\fs"..calc(tonumber(a)) end) end
	    if res.fsp then text=text:gsub("\\fsp([%d%.%-]+)",function(a) return "\\fsp"..calc(tonumber(a)) end) end
	    if res.bord then text=text:gsub("\\bord([%d%.]+)",function(a) return "\\bord"..calc(tonumber(a)) end) end
	    if res.shad then text=text:gsub("\\shad([%d%.]+)",function(a) return "\\shad"..calc(tonumber(a)) end) end
	    if res.blur then text=text:gsub("\\blur([%d%.]+)",function(a) return "\\blur"..calc(tonumber(a)) end) end
	    if res.be then text=text:gsub("\\be([%d%.]+)",function(a) return "\\be"..calc(tonumber(a)) end) end
	    if res.xbord then text=text:gsub("\\xbord([%d%.]+)",function(a) return "\\xbord"..calc(tonumber(a)) end) end
	    if res.ybord then text=text:gsub("\\ybord([%d%.]+)",function(a) return "\\ybord"..calc(tonumber(a)) end) end
	    if res.xshad then text=text:gsub("\\xshad([%d%.%-]+)",function(a) return "\\xshad"..calc(tonumber(a)) end) end
	    if res.yshad then text=text:gsub("\\yshad([%d%.%-]+)",function(a) return "\\yshad"..calc(tonumber(a)) end) end
	    if res.frx then text=text:gsub("\\frx([%d%.%-]+)",function(a) return "\\frx"..calc(tonumber(a)) end) end
	    if res.fry then text=text:gsub("\\fry([%d%.%-]+)",function(a) return "\\fry"..calc(tonumber(a)) end) end
	    if res.frz then text=text:gsub("\\frz([%d%.%-]+)",function(a) return "\\frz"..calc(tonumber(a)) end) end
	    if res.fax then text=text:gsub("\\fax([%d%.%-]+)",function(a) return "\\fax"..calc(tonumber(a)) end) end
	    if res.pos then text=text:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)",function(a,b) 
	    return "\\pos("..calc(tonumber(a))..","..calc(tonumber(b))..")" end) end
	    if res.move then text=text:gsub("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",function(a,b,c,d) 
	    return "\\move("..calc(tonumber(a))..","..calc(tonumber(b))..","..calc(tonumber(c))..","..calc(tonumber(d))..")" end) end
	    if res.org then text=text:gsub("\\org%(([%d%.%-]+),([%d%.%-]+)%)",function(a,b) 
	    return "\\org("..calc(tonumber(a))..","..calc(tonumber(b))..")" end) end
	    if res.clip then text=text:gsub("\\clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)%)",function(a,b,c,d) 
	    return "\\clip("..calc(tonumber(a))..","..calc(tonumber(b))..","..calc(tonumber(c))..","..calc(tonumber(d))..")" end) 
	      if text:match("clip%(m [%d%a%s%-%.]+%)") then
	      ctext=text:match("clip%(m ([%d%a%s%-%.]+)%)")
	      ctext2=ctext:gsub("([%d%-%.]+)%s([%d%-%.]+)",function(a,b) return calc(tonumber(a)).." "..calc(tonumber(b)) end)
	      ctext=ctext:gsub("%-","%%-")
	      text=text:gsub(ctext,ctext2)
	      end
	    end
	    
	text=text:gsub("\\\\","\\")
	text=text:gsub("\\}","}")
	text=text:gsub("{}","")
	line.text=text
        subs[i]=line
    end
end

function recalculator(subs, sel)
	dialog_config=
	{
	    {x=0,y=0,width=2,height=1,class="label",label="Change values to:",},
	    {x=2,y=0,width=2,height=1,class="floatedit",name="pc",value=100,min=0,hint="Multiply"},
	    {x=4,y=0,width=1,height=1,class="label",label="%",},
	    
	    {x=0,y=1,width=2,height=1,class="label",label="Increase values by:",},
	    {x=2,y=1,width=2,height=1,class="floatedit",name="add",value=0,hint="Add (use negative to subtract)"},
	    
	    {x=0,y=2,width=1,height=1,class="checkbox",name="fscx",label="fscx",value=true,},
	    {x=1,y=2,width=1,height=1,class="checkbox",name="fscy",label="fscy",value=true,},
	    {x=2,y=2,width=1,height=1,class="checkbox",name="fs",label="fs",value=false,},
	    {x=3,y=2,width=1,height=1,class="checkbox",name="fsp",label="fsp",value=false,},
	    
	    {x=0,y=3,width=1,height=1,class="checkbox",name="bord",label="bord",value=false,},
	    {x=1,y=3,width=1,height=1,class="checkbox",name="shad",label="shad",value=false,},
	    {x=2,y=3,width=1,height=1,class="checkbox",name="blur",label="blur",value=false,},
	    {x=3,y=3,width=1,height=1,class="checkbox",name="be",label="be",value=false,},
	    
	    {x=0,y=4,width=1,height=1,class="checkbox",name="xbord",label="xbord",value=false,},
	    {x=1,y=4,width=1,height=1,class="checkbox",name="ybord",label="ybord",value=false,},
	    {x=2,y=4,width=1,height=1,class="checkbox",name="xshad",label="xshad",value=false,},
	    {x=3,y=4,width=1,height=1,class="checkbox",name="yshad",label="yshad",value=false,},
	    
	    {x=0,y=5,width=1,height=1,class="checkbox",name="frx",label="frx",value=false,},
	    {x=1,y=5,width=1,height=1,class="checkbox",name="fry",label="fry",value=false,},
	    {x=2,y=5,width=1,height=1,class="checkbox",name="frz",label="frz",value=false,},
	    {x=3,y=5,width=1,height=1,class="checkbox",name="fax",label="fax",value=false,},
	    
	    {x=0,y=6,width=1,height=1,class="checkbox",name="pos",label="pos",value=false,},
	    {x=1,y=6,width=1,height=1,class="checkbox",name="move",label="move",value=false,},
	    {x=2,y=6,width=1,height=1,class="checkbox",name="org",label="org",value=false,},
	    {x=3,y=6,width=1,height=1,class="checkbox",name="clip",label="clip",value=false,},
	} 	
	pressed, res=aegisub.dialog.display(dialog_config,
		{"Multiply","Add","Cancel"},{ok='Multiply',cancel='Cancel'})
	if pressed=="Cancel" then    aegisub.cancel() end
	if pressed=="Multiply" then    multiply(subs, sel) end
	if pressed=="Add" then    multiply(subs, sel) end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, recalculator)
script_name = "Alignment"
script_description = "aligns text"	-- \an8 and the like
script_author = "unanimated"
script_version = "1.0"

function align(subs, sel)
chk=0
if ana["an1"]==true then num=1 chk=chk+1 end
if ana["an2"]==true then num=2 chk=chk+1 end
if ana["an3"]==true then num=3 chk=chk+1 end
if ana["an4"]==true then num=4 chk=chk+1 end
if ana["an5"]==true then num=5 chk=chk+1 end
if ana["an6"]==true then num=6 chk=chk+1 end
if ana["an7"]==true then num=7 chk=chk+1 end
if ana["an8"]==true then num=8 chk=chk+1 end
if ana["an9"]==true then num=9 chk=chk+1 end
if chk>1 then aegisub.dialog.display({{class="label",
	label="Are you dumb or something? \nYou can only choose one.",x=0,y=0,width=1,height=2}},{"OK"}) end
  for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	if chk==1 then
	    if text:match("\\an%d") then
		text = text:gsub("\\an%d","\\an"..num)
	    else
		text = text:gsub("^","{\\an"..num.."}")
		text = text:gsub("({\\an%d)}{","%1")
	    end
	end
	line.text = text
        subs[i] = line
  end
    aegisub.set_undo_point(script_name)
    return sel
end

function alignment(subs, sel)	
	dialog_config=	{
	{x=1,y=1,width=1,height=1,class="checkbox",name="an7",label="an7",value=false    },
	{x=3,y=1,width=1,height=1,class="checkbox",name="an8",label="an8",value=false    },
	{x=5,y=1,width=1,height=1,class="checkbox",name="an9",label="an9",value=false    },
        {x=1,y=3,width=1,height=1,class="checkbox",name="an4",label="an4",value=false    },
	{x=3,y=3,width=1,height=1,class="checkbox",name="an5",label="an5",value=false    },
	{x=5,y=3,width=1,height=1,class="checkbox",name="an6",label="an6",value=false    },
	{x=1,y=5,width=1,height=1,class="checkbox",name="an1",label="an1",value=false    },
	{x=3,y=5,width=1,height=1,class="checkbox",name="an2",label="an2",value=false    },
	{x=5,y=5,width=1,height=1,class="checkbox",name="an3",label="an3",value=false    },
	{x=0,y=6,width=7,height=1,class="label",    },		} 
	
	pressed, ana = aegisub.dialog.display(dialog_config,{"Align","Cancel"})
	
	if pressed=="Align" then align(subs, sel) end
	return sel
end

aegisub.register_macro(script_name, script_description, alignment)
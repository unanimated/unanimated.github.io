-- Create \t transforms. Type start/end time, acceleration, and tags you want to transform.

script_name = "Add Animated Transform"
script_description = "Adds Animated Transform(s)"
script_author = "unanimated"
script_version = "1.0"

function trnsf(subs, sel)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
	    text = "{transforrrm}" .. text
	    text = text:gsub("{transforrrm}({\\[^}]*)}","%1transforrrm}")
		if results["tcheck"]==true then
		    text = text:gsub("transforrrm",
		    "\\t(" .. results["start"] .. "," .. results["end"] .. "," .. results["accel"] .. "," .. results["tags"] .. ")")
		else
		    text = text:gsub("transforrrm","\\t(" .. results["tags"] .. ")")
		end
	    line.text = text
	    subs[i] = line
	end
end

function transconfig(subs, sel)
	dialog_config=
	{
	    {x=0,y=5,width=1,height=1,class="label",label="Tags to put inside \\t():",   },
	    {x=0,y=6,width=3,height=1,class="edit",name="tags",value="\\"   },
	    {x=0,y=2,width=3,height=1,class="checkbox",name="tcheck",label="Enable times/acceleration (otherwise only \\t(\\tags))",value=true},
	    {x=0,y=4,width=1,height=1,class="floatedit",name="start",value="0"   },
	    {x=1,y=4,width=1,height=1,class="floatedit",name="end",value="0"   },
   	    {x=2,y=4,width=1,height=1,class="floatedit",name="accel",value="1"   },	
	    {x=0,y=0,width=3,height=1,class="label",label="Set times and acceleration if you need them (or you can disable them)",},
	    {x=0,y=1,width=3,height=1,class="label",label="Type out tags in this form: \\bord5\\shad5\\frz90 etc.", },
    	    {x=0,y=7,width=3,height=1,class="label",label="New transforms are always placed at the end of the first block of tags",  },
	    {x=0,y=3,width=1,height=1,class="label",label="\\t start",  },	
    	    {x=1,y=3,width=1,height=1,class="label",label="\\t end",  },
	    {x=2,y=3,width=1,height=1,class="label",label="accel",  },
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,{"Transform","Cancel"})
	if pressed=="Cancel" then aegisub.cancel() end
	
	if pressed=="Transform" then trnsf(subs, sel) end
end

function transform(subs, sel)
    transconfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, transform)
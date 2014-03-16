-- a bunch of things that usually help me with song styling
-- transforms include counting time from the end, like doing a transform for the last 500ms of the line
-- inserting tags before last character is preparing the line for "gradiant by character"
-- splitting line into 3 parts is useful when you want to apply different effects to the start and end,
-- since long lines with \t tend to lag even if the actual transform covers only a short part of it

script_name = "Song Styler"
script_description = "Song Styler"
script_author = "unanimated"
script_version = "1.1"

function tf(subs, sel)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
	    
	-- get colours from input
	    col1=res["c1"]
	    col1=col1:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col3=res["c3"]
	    col3=col3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col4=res["c4"]
	    col4=col4:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col2=res["c2"]
	    col2=col2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    
	if text:match("^{\\")==nil then text="{\\}"..text end		-- add {\} if line has no tags
	
	-- transforms

	dura=line.end_time-line.start_time
	
	tstart=res.start
	tend=res.endd
	if res.tinend then tstart=dura-res.start end
	if res.toutend then tend=dura-res.endd end
	
	text=text:gsub("^({\\[^}]*)}","%1".."\\t("..tstart..","..tend..","..res.accel..",alltagsgohere)}") 
	transform=""
	
	if res["bord1"] then transform=transform.."\\bord"..res["bord2"] end
	if res["shad1"] then transform=transform.."\\shad"..res["shad2"] end
	if res["blur1"] then transform=transform.."\\blur"..res["blur2"] end
	if res["k1"] then transform=transform.."\\c"..col1 end
	if res["k2"] then transform=transform.."\\2c"..col2 end
	if res["k3"] then transform=transform.."\\3c"..col3 end
	if res["k4"] then transform=transform.."\\4c"..col4 end
	if res.moretags~="\\" then transform=transform..res["moretags"] end
	text=text:gsub("alltagsgohere",transform)
	text=text:gsub("\\t%(0,0,1,","\\t(")

	text=text:gsub("\\\\","\\")
	text=text:gsub("\\}","}")
	text=text:gsub("{}","")
	    line.text = text
	    subs[i] = line
	end
end

function grad(subs, sel)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
	    
	-- get colours from input
	    col1=res["c1"]
	    col1=col1:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col3=res["c3"]
	    col3=col3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col4=res["c4"]
	    col4=col4:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col2=res["c2"]
	    col2=col2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	
	-- tags before last character
	
	endtags=""
	if res["bord1"] then endtags=endtags.."\\bord"..res["bord2"] end
	if res["shad1"] then endtags=endtags.."\\shad"..res["shad2"] end
	if res["blur1"] then endtags=endtags.."\\blur"..res["blur2"] end
	if res["k1"] then endtags=endtags.."\\c"..col1 end
	if res["k2"] then endtags=endtags.."\\2c"..col2 end
	if res["k3"] then endtags=endtags.."\\3c"..col3 end
	if res["k4"] then endtags=endtags.."\\4c"..col4 end
	if res.moretags~="\\" then endtags=endtags..res["moretags"] end
	if text:match("}$") then text=text:gsub("([^}]{[^}]-})$","{"..endtags.."}%1") else
	text=text:gsub("([^}])$","{"..endtags.."}%1") end

	text=text:gsub("\\\\","\\")
	text=text:gsub("\\}","}")
	text=text:gsub("{}","")
	    line.text = text
	    subs[i] = line
	end
end

function split(subs, sel)
	for i=#sel,1,-1 do
	  line = subs[sel[i]]
		start=line.start_time		-- start time
		endt=line.end_time		-- end time
		effect=line.effect
		
		-- line 3
		line3=line
		line3.start_time=endt-res.split2
		line3.effect=effect.." pt.3"
		if line3.start_time~=line3.end_time then
		subs.insert(sel[i]+1,line3) end
		
		-- line 2
		line2=line
		line2.start_time=start+res.split1
		line2.end_time=endt-res.split2
		line2.effect=effect.." pt.2"
		subs.insert(sel[i]+1,line2)

		-- line 1
		line.start_time=start
		line.end_time=start+res.split1
		line.effect=effect.." pt.1"
		
	    subs[sel[i]] = line
	    if line.start_time==line.end_time then subs.delete(sel[i]) end
	end
end

function sonconfig(subs, sel)
	dialog_config=
	{
	    {x=0,y=0,width=1,height=1,class="label",label="",   },
	    
	    {x=0,y=1,width=1,height=1,class="checkbox",name="bord1",label="\\bord",value=false },
	    {x=0,y=2,width=1,height=1,class="checkbox",name="shad1",label="\\shad",value=false },
	    {x=0,y=3,width=1,height=1,class="checkbox",name="blur1",label="\\blur",value=false },
	    
	    {x=1,y=1,width=1,height=1,class="floatedit",name="bord2",min=0 },
	    {x=1,y=2,width=1,height=1,class="floatedit",name="shad2",min=0 },
	    {x=1,y=3,width=1,height=1,class="floatedit",name="blur2",value=0.6,min=0 },
	    
	    {x=2,y=1,width=1,height=1,class="checkbox",name="k1",label="Primary:",value=false },
	    {x=2,y=2,width=1,height=1,class="checkbox",name="k3",label="Border:",value=false },
	    {x=2,y=3,width=1,height=1,class="checkbox",name="k4",label="Shadow:",value=false },
	    {x=2,y=4,width=1,height=1,class="checkbox",name="k2",label="Secondary:",value=false },
	    
	    {x=3,y=1,width=1,height=1,class="color",name="c1" },
	    {x=3,y=2,width=1,height=1,class="color",name="c3" },
	    {x=3,y=3,width=1,height=1,class="color",name="c4" },
	    {x=3,y=4,width=1,height=1,class="color",name="c2" },
	    
	    {x=0,y=4,width=1,height=1,class="label",label="Transform:",   },
	    {x=0,y=5,width=1,height=1,class="label",label="\\t start"},
	    {x=0,y=6,width=1,height=1,class="label",label="\\t end"},
	    {x=0,y=7,width=1,height=1,class="label",label="accel"},
	    {x=1,y=5,width=1,height=1,class="floatedit",name="start",value="0"   },
	    {x=1,y=6,width=1,height=1,class="floatedit",name="endd",value="0"   },
   	    {x=1,y=7,width=1,height=1,class="floatedit",name="accel",value="1"   },
	    
	    {x=2,y=5,width=2,height=1,class="checkbox",name="tinend",label="count from end",
		hint="if a line is 3000ms and you set 500, transform wil start at 2500",value=false },
	    {x=2,y=6,width=2,height=1,class="checkbox",name="toutend",label="count from end",
		hint="if a line is 3000ms and you set 500, transform wil end at 2500",value=false },
	    {x=2,y=7,width=1,height=1,class="label",label="<1 starts fast, ends slow"},
		
	    
    	    {x=0,y=8,width=1,height=1,class="label",label="more tags:",value=false},
	    {x=1,y=8,width=3,height=1,class="edit",name="moretags",value="\\" },
	    
	    {x=0,y=9,width=1,height=1,class="label",label="Split line"},
	    {x=1,y=9,width=1,height=1,class="label",label="first part [ms]:"},
	    {x=1,y=10,width=1,height=1,class="label",label="third part [ms]:"},
	    {x=2,y=9,width=2,height=1,class="floatedit",name="split1",value="0"},
	    {x=2,y=10,width=2,height=1,class="floatedit",name="split2",value="0"},
	    
	    {x=0,y=11,width=4,height=1,class="label",label="[Transform] applies selected tags to a transform",},
	    {x=0,y=12,width=4,height=1,class="label",label="[Insert before last] inserts tags before last letter in the line",},
    	    {x=0,y=13,width=4,height=1,class="label",label="[Split] splits the line into 3 parts",  },
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,{"Transform","Insert before last","Split","Cancel"},{cancel='Cancel'})
	if pressed=="Cancel" then aegisub.cancel() end
	if pressed=="Transform" then tf(subs, sel) end
	if pressed=="Insert before last" then grad(subs, sel) end
	if pressed=="Split" then split(subs, sel) end
end

function songs(subs, sel)
    sonconfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, songs)
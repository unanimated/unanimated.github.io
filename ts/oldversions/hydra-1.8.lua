script_name = "HYDRA"						-- The most versatile typesetting tool out there [probably]
script_description = "A multi-headed typesetting tool"		-- applies a bunch of stuff to all selected lines
script_author = "unanimated"
script_version = "1.8"

-- SETTINGS - feel free to change these

default_blur=0.5
default_border=0
default_shadow=0
default_fontsize=50
default_spacing=1
default_fax=0.05
default_fay=0.05

-- END of SETTINGS

function hh9(subs, sel)
	for z, i in ipairs(sel) do
	    line = subs[i]
	    text = subs[i].text
	    
	-- get colours from input
	    col1=res.c1:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col3=res.c3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col4=res.c4:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col2=res.c2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    
	if text:match("^{\\")==nil then text="{\\}"..text end		-- add {\} if line has no tags
	
	-- transforms
	if trans==1 then
	
	tin=res.trin tout=res.trout
	if res.tend then
	tin=line.end_time-line.start_time-res.trin
	tout=line.end_time-line.start_time-res.trout
	end
		-- clean up existing transforms
		if text:match("^{[^}]*\\t") then
		text=text:gsub("^({\\[^}]-})",function(tg) return cleantr(tg) end)
		end
		
		--aegisub.log("\n\n"..text)
		
	if text:match("\\t%(\\") and tin==0 and tout==0 and res.accel==1 then
	text=text:gsub("^({[^}]*\\t%()\\","%1\\alltagsgohere\\")
	else
	text=text:gsub("^({\\[^}]*)}","%1".."\\t("..tin..","..tout..","..res.accel..",\\alltagsgohere)}") 
	end
	transform=""
	
	if res["shad1"] then transform=transform.."\\shad"..res["shad2"] end
	if res["bord1"] then transform=transform.."\\bord"..res["bord2"] end
	if res["blur1"] then transform=transform.."\\blur"..res["blur2"] end
	if res["fs1"] then transform=transform.."\\fs"..res["fs2"] end
	if res["spac1"] then transform=transform.."\\fsp"..res["spac2"] end
	if res["fscx1"] then transform=transform.."\\fscx"..res["fscx2"] end
	if res["fscy1"] then transform=transform.."\\fscy"..res["fscy2"] end
	if res["xbord1"] then transform=transform.."\\xbord"..res["xbord2"] end
	if res["ybord1"] then transform=transform.."\\ybord"..res["ybord2"] end
	if res["xshad1"] then transform=transform.."\\xshad"..res["xshad2"] end
	if res["yshad1"] then transform=transform.."\\yshad"..res["yshad2"] end
	if res["frz1"] then transform=transform.."\\frz"..res["frz2"] end
	if res["frx1"] then transform=transform.."\\frx"..res["frx2"] end
	if res["fry1"] then transform=transform.."\\fry"..res["fry2"] end
	if res["fax1"] then transform=transform.."\\fax"..res["fax2"] end
	if res["fay1"] then transform=transform.."\\fay"..res["fay2"] end
	if res["k1"] then transform=transform.."\\c"..col1 end
	if res["k2"] then transform=transform.."\\2c"..col2 end
	if res["k3"] then transform=transform.."\\3c"..col3 end
	if res["k4"] then transform=transform.."\\4c"..col4 end
	if res["arfa"] then transform=transform.."\\alpha&H"..res["alpha"].."&" end
	if res["arf1"] then transform=transform.."\\1a&H"..res["alph1"].."&" end
	if res["arf2"] then transform=transform.."\\2a&H"..res["alph2"].."&" end
	if res["arf3"] then transform=transform.."\\3a&H"..res["alph3"].."&" end
	if res["arf4"] then transform=transform.."\\4a&H"..res["alph4"].."&" end
	if res["moretags"]~="\\" then transform=transform..res["moretags"] end
	text=text:gsub("alltagsgohere",transform)
	text=text:gsub("\\t%(0,0,1,","\\t(")
	
	-- non transform, ie the regular stuff
	else
		-- temporarily remove transforms
		if text:match("\\t") then
		--aegisub.log("\n\n"..text)
		text=text:gsub("^({\\[^}]-})",function(tg) return trem(tg) end)
		if text:match("^{}") then text=text:gsub("^{}","{\\}")  end
		--aegisub.log("\n\n"..text)
		end
	
	-- \shad
	if res["shad1"] then
	    if text:match("^{[^}]*\\shad") then
	    text=text:gsub("^({[^}]*\\shad)([%d%.]+)","%1"..res.shad2) 
	    else
	    text=text:gsub("^{(\\)","{\\shad"..res.shad2.."%1") 
	    end
	end
	-- \bord
	if res["bord1"] then
	    if text:match("^{[^}]*\\bord") then
	    text=text:gsub("^({[^}]*\\bord)([%d%.]+)","%1"..res.bord2) 
	    else
	    text=text:gsub("^{(\\)","{\\bord"..res.bord2.."%1") 
	    end
	end
	-- \fsp									
	if res["spac1"] then
	    if text:match("^{[^}]*\\fsp") then
	    text=text:gsub("^({[^}]*\\fsp)([%d%.%-]+)","%1"..res["spac2"])
	    else
	    text=text:gsub("^{(\\)","{\\fsp"..res["spac2"].."%1")
	    end
	end
	-- \fs
	if res["fs1"] then
	    if text:match("^{[^}]*\\fs%d") then
	    text=text:gsub("^({[^}]*\\fs)([%d%.]+)","%1"..res["fs2"]) 
	    else
	    text=text:gsub("^{(\\)","{\\fs"..res["fs2"].."%1") 
	    end
	end
	-- \fscx
	if res["fscx1"] then
	    if text:match("^{[^}]*\\fscx%d") then
	    text=text:gsub("^({[^}]*\\fscx)([%d%.]+)","%1"..res["fscx2"]) 
	    else
	    text=text:gsub("^{(\\)","{\\fscx"..res["fscx2"].."%1") 
	    end
	end
	-- \fscy
	if res["fscy1"] then
	    if text:match("^{[^}]*\\fscy%d") then
	    text=text:gsub("^({[^}]*\\fscy)([%d%.]+)","%1"..res["fscy2"]) 
	    else
	    text=text:gsub("^{(\\)","{\\fscy"..res["fscy2"].."%1") 
	    end
	end
	-- \blur
	if res["blur1"] then
	    if text:match("^{[^}]*\\blur") then
	    text=text:gsub("^({[^}]*\\blur)([%d%.]+)","%1"..res["blur2"])
	    else
	    text=text:gsub("^{(\\)","{\\blur"..res["blur2"].."%1") 
	    end
	end
	-- \be
	if res["be1"] then
	    if text:match("^{[^}]*\\be") then
	    text=text:gsub("^({[^}]*\\be)([%d%.]+)","%1"..res["be2"])
	    else
	    text=text:gsub("^{(\\)","{\\be"..res["be2"].."%1") 
	    end
	end

	-- \xbord
	if res["xbord1"] then
	    if text:match("^{[^}]*\\xbord") then
	    text=text:gsub("^({[^}]*\\xbord)([%d%.]+)","%1"..res["xbord2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\xbord"..res["xbord2"].."}") 
	    end
	end
	-- \ybord
	if res["ybord1"] then
	    if text:match("^{[^}]*\\ybord") then
	    text=text:gsub("^({[^}]*\\ybord)([%d%.]+)","%1"..res["ybord2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\ybord"..res["ybord2"].."}") 
	    end
	end
	-- \xshad
	if res["xshad1"] then
	    if text:match("^{[^}]*\\xshad") then
	    text=text:gsub("^({[^}]*\\xshad)([%d%.%-]+)","%1"..res["xshad2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\xshad"..res["xshad2"].."}") 
	    end
	end
	-- \yshad
	if res["yshad1"] then
	    if text:match("^{[^}]*\\yshad") then
	    text=text:gsub("^({[^}]*\\yshad)([%d%.%-]+)","%1"..res["yshad2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\yshad"..res["yshad2"].."}") 
	    end
	end
	-- \fax
	if res["fax1"] then
	    if text:match("^{[^}]*\\fax") then
	    text=text:gsub("^({[^}]*\\fax)([%d%.%-]+)","%1"..res["fax2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\fax"..res["fax2"].."}") 
	    end
	end
	-- \fay
	if res["fay1"] then
	    if text:match("^{[^}]*\\fay") then
	    text=text:gsub("^({[^}]*\\fay)([%d%.%-]+)","%1"..res["fay2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\fay"..res["fay2"].."}") 
	    end
	end
	-- \frz
	if res["frz1"] then
	    if text:match("^{[^}]*\\frz") then
	    text=text:gsub("^({[^}]*\\frz)([%d%.%-]+)","%1"..res["frz2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\frz"..res["frz2"].."}") 
	    end
	end
	-- \frx
	if res["frx1"] then
	    if text:match("^{[^}]*\\frx") then
	    text=text:gsub("^({[^}]*\\frx)([%d%.%-]+)","%1"..res["frx2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\frx"..res["frx2"].."}") 
	    end
	end
	-- \fry
	if res["fry1"] then
	    if text:match("^{[^}]*\\fry") then
	    text=text:gsub("^({[^}]*\\fry)([%d%.%-]+)","%1"..res["fry2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\fry"..res["fry2"].."}") 
	    end
	end

	-- set selected colours
	if res["k1"] then
	    if text:match("^{[^}]*\\c&") or text:match("^{[^}]*\\1c&") then
	    text=text:gsub("^({[^}]*\\c)(&H%x+&)","%1"..col1) 
	    text=text:gsub("^({[^}]*\\1c)(&H%x+&)","%1"..col1)
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\c"..col1.."}")
	    end 
	end
	if res["k2"] then
	    if text:match("^{[^}]*\\2c&") then
	    text=text:gsub("^({[^}]*\\2c)(&H%x+&)","%1"..col2) 
	    else	    
	    text=text:gsub("^({\\[^}]*)}","%1\\2c"..col2.."}") 
	    end
	end
	if res["k3"] then
	    if text:match("^{[^}]*\\3c&") then
	    text=text:gsub("^({[^}]*\\3c)(&H%x+&)","%1"..col3) 
	    else	    
	    text=text:gsub("^({\\[^}]*)}","%1\\3c"..col3.."}") 
	    end
	end
	if res["k4"] then
	    if text:match("^{[^}]*\\4c&") then
	    text=text:gsub("^({[^}]*\\4c)(&H%x+&)","%1"..col4) 
	    else	    
	    text=text:gsub("^({\\[^}]*)}","%1\\4c"..col4.."}") 
	    end
	end
	-- \alpha
	if res["arfa"] then
	    if text:match("^{[^}]-\\alpha&") then
	    text=text:gsub("^({[^}]-\\alpha&H)(%x%x)","%1"..res["alpha"]) 
	    else
	    text=text:gsub("^({\\[^}]-)}","%1\\alpha&H"..res["alpha"].."&}")
	    end 
	end
	if res["arf1"] then
	    if text:match("^{[^}]-\\1a&") then
	    text=text:gsub("^({[^}]-\\1a&H)(%x%x)","%1"..res["alph1"]) 
	    else
	    text=text:gsub("^({\\[^}]-)}","%1\\1a&H"..res["alph1"].."&}")
	    end 
	end
	if res["arf2"] then
	    if text:match("^{[^}]-\\2a&") then
	    text=text:gsub("^({[^}]-\\2a&H)(%x%x)","%1"..res["alph2"]) 
	    else
	    text=text:gsub("^({\\[^}]-)}","%1\\2a&H"..res["alph2"].."&}")
	    end 
	end
	if res["arf3"] then
	    if text:match("^{[^}]-\\3a&") then
	    text=text:gsub("^({[^}]-\\3a&H)(%x%x)","%1"..res["alph3"]) 
	    else
	    text=text:gsub("^({\\[^}]-)}","%1\\3a&H"..res["alph3"].."&}")
	    end 
	end
	if res["arf4"] then
	    if text:match("^{[^}]-\\4a&") then
	    text=text:gsub("^({[^}]-\\4a&H)(%x%x)","%1"..res["alph4"]) 
	    else
	    text=text:gsub("^({\\[^}]-)}","%1\\4a&H"..res["alph4"].."&}")
	    end 
	end

	-- moretags
	if res["moretags"]~="\\" then 
	    text=text:gsub("^({\\[^}]*)}","%1"..res["moretags"].."}")
	end

	-- \fad
	if res.fade then
	    if line.text:match("\\fad%(") then
		text = text:gsub("\\fad%([%d%.%,]-%)","")
		line.text = text
	    end
	    text = text:gsub("^{\\","{\\fad(" .. res.fadin .. "," .. res.fadout .. ")\\")
	end
	-- \q2
	if res["q2"] then
	    if text:match("^{[^}]-\\q2") then
	    text=text:gsub("\\q2","") 
	    else
	    text=text:gsub("^{\\","{\\q2\\") 
	    end
	end
	-- \an
	if res["an1"] then
	    if text:match("^{[^}]-\\an%d") then
	    text=text:gsub("^({[^}]-\\an)(%d)","%1"..res["an2"]) 
	    else
	    text=text:gsub("^{(\\)","{\\an"..res["an2"].."%1") 
	    end
	end
	-- raise layer
	if res["layer"] then
	if line.layer+res["layers"]<0 then aegisub.dialog.display({{class="label",
		    label="Layers can't be negative.",x=0,y=0,width=1,height=2}},{"OK"}) else
	line.layer=line.layer+res["layers"] end
	end	
	
	-- put transform back
	if trnsfrm~=nil then text=text:gsub("^({\\[^}]*)}","%1"..trnsfrm.."}") trnsfrm=nil end
	
	end
	-- the end
	
	text=text:gsub("\\\\","\\")	text=text:gsub("\\}","}")	text=text:gsub("{}","")	-- clean up \\ and \}
	    line.text=text
	    subs[i] = line
	end
end

function trem(tags)
	trnsfrm=""
	for t in tags:gmatch("(\\t%([^%(%)]-%))") do trnsfrm=trnsfrm..t end
	for t in tags:gmatch("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))") do trnsfrm=trnsfrm..t end
	tags=tags:gsub("(\\t%([^%(%)]+%))","")
	tags=tags:gsub("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","")
	return tags
end

function cleantr(tags)
	cleant=""
	for ct in tags:gmatch("\\t%((\\[^%(%)]-)%)") do cleant=cleant..ct end
	for ct in tags:gmatch("\\t%((\\[^%(%)]-%([^%)]-%)[^%)]-)%)") do cleant=cleant..ct end
	tags=tags:gsub("(\\t%(\\[^%(%)]+%))","")
	tags=tags:gsub("(\\t%(\\[^%(%)]-%([^%)]-%)[^%)]-%))","")
	if cleant~="" then tags=tags:gsub("^({\\[^}]*)}","%1\\t("..cleant..")}") end
	return tags
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=0,width=6,height=1,class="label",
	    label="A multi-headed typesetting tool.       Only checked tags get used. Applies to all selected lines.", },
	    {	x=0,y=1,width=1,height=1,class="checkbox",name="k1",label="Primary:",value=false },
	    {	x=0,y=2,width=1,height=1,class="checkbox",name="k3",label="Border:",value=false },
	    {	x=0,y=3,width=1,height=1,class="checkbox",name="k4",label="Shadow:",value=false },
	    {	x=0,y=5,width=1,height=1,class="checkbox",name="k2",label="useless... (2c):",value=false },
	    {	x=0,y=7,width=1,height=1,class="checkbox",name="an1",label="\\an",value=false },
	    
	    {	x=0,y=9,width=5,height=1,class="label",label="transform mode [all applicable selected tags go after \\t]"},
	    {	x=0,y=10,width=1,height=1,class="label",label="Transform t1,t2:"},
	    {	x=1,y=10,width=2,height=1,class="floatedit",name="trin" },
	    {	x=3,y=10,width=1,height=1,class="floatedit",name="trout" },
	    {	x=3,y=11,width=2,height=1,class="checkbox",name="tend",label="Count times from end",value=false},
	    {	x=0,y=11,width=1,height=1,class="label",label="              Accel:"},
	    {	x=1,y=11,width=2,height=1,class="floatedit",name="accel",value=1 },
	    {	x=0,y=12,width=1,height=1,class="label",name="transtags",label="Additional tags:"},
	    {	x=1,y=12,width=3,height=1,class="edit",name="moretags",value="\\" },
	    
	    
	    {	x=1,y=1,width=1,height=1,class="color",name="c1" },
	    {	x=1,y=2,width=1,height=1,class="color",name="c3" },
	    {	x=1,y=3,width=1,height=1,class="color",name="c4" },
	    {	x=1,y=5,width=1,height=1,class="color",name="c2" },
	    {	x=1,y=7,width=1,height=1,class="dropdown",name="an2",items={"1","2","3","4","5","6","7","8","9"},value="5"},
	    
	    {	x=2,y=1,width=1,height=1,class="checkbox",name="bord1",label="\\bord",value=false },
	    {	x=2,y=2,width=1,height=1,class="checkbox",name="shad1",label="\\shad",value=false },
	    {	x=2,y=3,width=1,height=1,class="checkbox",name="fs1",label="\\fs",value=false },
	    {	x=2,y=4,width=1,height=1,class="checkbox",name="spac1",label="\\fsp",value=false },
	    {	x=2,y=5,width=1,height=1,class="checkbox",name="blur1",label="\\blur",value=false },
	    {	x=2,y=6,width=1,height=1,class="checkbox",name="be1",label="\\be",value=false },
	    
	    {	x=3,y=1,width=1,height=1,class="floatedit",name="bord2",value=default_border,min=0 },
	    {	x=3,y=2,width=1,height=1,class="floatedit",name="shad2",value=default_shadow,min=0 },
	    {	x=3,y=3,width=1,height=1,class="floatedit",name="fs2",value=default_fontsize,min=1 },
	    {	x=3,y=4,width=1,height=1,class="floatedit",name="spac2",value=default_spacing },
	    {	x=3,y=5,width=1,height=1,class="floatedit",name="blur2",value=default_blur,min=0.4 },
	    {	x=3,y=6,width=1,height=1,class="floatedit",name="be2",value=1,min=1 },
	    
	    {	x=2,y=7,width=1,height=1,class="checkbox",name="fade",label="\\fad",value=false },
	    {	x=3,y=7,width=1,height=1,class="floatedit",name="fadin",min=0 },
	    {	x=4,y=7,width=1,height=1,class="label",label="<-- in,out -->", },
	    {	x=5,y=7,width=2,height=1,class="floatedit",name="fadout",min=0 },
	    
    	    {	x=4,y=1,width=1,height=1,class="checkbox",name="xbord1",label="\\xbord",value=false },
	    {	x=4,y=2,width=1,height=1,class="checkbox",name="ybord1",label="\\ybord",value=false },
	    {	x=4,y=3,width=1,height=1,class="checkbox",name="xshad1",label="\\xshad",value=false },
	    {	x=4,y=4,width=1,height=1,class="checkbox",name="yshad1",label="\\yshad",value=false },
	    {	x=4,y=5,width=1,height=1,class="checkbox",name="fax1",label="\\fax",value=false },
	    {	x=4,y=6,width=1,height=1,class="checkbox",name="fay1",label="\\fay",value=false },
	    
	    {	x=5,y=1,width=2,height=1,class="floatedit",name="xbord2",value="",min=0 },
	    {	x=5,y=2,width=2,height=1,class="floatedit",name="ybord2",value="",min=0 },
	    {	x=5,y=3,width=2,height=1,class="floatedit",name="xshad2",value="" },
	    {	x=5,y=4,width=2,height=1,class="floatedit",name="yshad2",value="" },
	    {	x=5,y=5,width=2,height=1,class="floatedit",name="fax2",value=default_fax },
	    {	x=5,y=6,width=2,height=1,class="floatedit",name="fay2",value=default_fay },
	    
	    {	x=5,y=8,width=1,height=1,class="checkbox",name="frz1",label="\\frz",value=false },
	    {	x=5,y=9,width=1,height=1,class="checkbox",name="frx1",label="\\frx",value=false },
	    {	x=5,y=10,width=1,height=1,class="checkbox",name="fry1",label="\\fry",value=false },
	    {	x=5,y=11,width=1,height=1,class="checkbox",name="fscx1",label="\\fscx",value=false },
	    {	x=5,y=12,width=1,height=1,class="checkbox",name="fscy1",label="\\fscy",value=false },
	    
	    {	x=6,y=8,width=2,height=1,class="floatedit",name="frz2",value="" },
	    {	x=6,y=9,width=2,height=1,class="floatedit",name="frx2",value="" },
	    {	x=6,y=10,width=2,height=1,class="floatedit",name="fry2",value="" },
	    {	x=6,y=11,width=2,height=1,class="floatedit",name="fscx2",value="",min=0 },
	    {	x=6,y=12,width=2,height=1,class="floatedit",name="fscy2",value="",min=0 },
	    
	    {	x=7,y=1,width=1,height=1,class="checkbox",name="layer",label="layer",value=false},
	    {	x=7,y=7,width=1,height=1,class="checkbox",name="q2",label="\\q2",value=false },
	    {	x=7,y=2,width=1,height=1,class="checkbox",name="arfa",label="\\alpha",value=false },
	    
	    {	x=7,y=3,width=1,height=1,class="checkbox",name="arf1",label="\\1a",value=false },
	    {	x=7,y=4,width=1,height=1,class="checkbox",name="arf2",label="\\2a",value=false },
	    {	x=7,y=5,width=1,height=1,class="checkbox",name="arf3",label="\\3a",value=false },
	    {	x=7,y=6,width=1,height=1,class="checkbox",name="arf4",label="\\4a",value=false },
	    
	    {	x=8,y=1,width=1,height=1,class="dropdown",name="layers",
		items={"-5","-4","-3","-2","-1","+1","+2","+3","+4","+5"},value="+1" },
	    {	x=8,y=2,width=1,height=1,class="dropdown",name="alpha",
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="00" },
	    
	    {	x=8,y=3,width=1,height=1,class="dropdown",name="alph1",
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="00" },
	    {	x=8,y=4,width=1,height=1,class="dropdown",name="alph2",
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="00" },
	    {	x=8,y=5,width=1,height=1,class="dropdown",name="alph3",
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="00" },
	    {	x=8,y=6,width=1,height=1,class="dropdown",name="alph4",
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="00" },
	    
	} 
	
	pressed, res = aegisub.dialog.display(dialog_config,{"Apply","Transform","Cancel"},{ok='Apply',cancel='Cancel'})
	if pressed=="Apply" then trans=0 hh9(subs, sel) end
	if pressed=="Transform" then trans=1 hh9(subs, sel) end
end

function hydra(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, hydra)
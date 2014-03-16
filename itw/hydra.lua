script_name="HYDRA"						-- The most versatile typesetting tool out there [probably]
script_description="A multi-headed typesetting tool"		-- applies a bunch of stuff to all selected lines
script_author="unanimated"
script_version="3.0 beta"

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
	    line=subs[i]
	    text=subs[i].text
	    
	-- get colours from input
	    col1=res.c1:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col3=res.c3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col4=res.c4:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col2=res.c2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    
	if text:match("^{\\")==nil then text="{\\}"..text end		-- add {\} if line has no tags
	
	-- tag position
	place=res.linetext
	if place:match("*") then pl1,pl2,pl3=place:match("(.*)(%*)(.*)") pla=1 else pla=0 end
	
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
		
	if text:match("\\t%(\\") and tin==0 and tout==0 and res.accel==1 then
	text=text:gsub("^({[^}]*\\t%()\\","%1\\alltagsgohere\\")
	else
	text=text:gsub("^({\\[^}]*)}","%1".."\\t("..tin..","..tout..","..res.accel..",\\alltagsgohere)}") 
	end
	transform=""
	
	if res["shad1"] then transform=transform.."\\shad"..res["shad2"] end
	if res["bord1"] then transform=transform.."\\bord"..res["bord2"] end
	if res["blur1"] then transform=transform.."\\blur"..res["blur2"] end
	if res["be1"] then transform=transform.."\\be"..res["be2"] end
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
		text=text:gsub("^({\\[^}]-})",function(tg) return trem(tg) end)
		if text:match("^{}") then text=text:gsub("^{}","{\\}")  end
		end
		
	tags=""
	if res["shad1"] then tags=tags.."\\shad"..res["shad2"] end
	if res["bord1"] then tags=tags.."\\bord"..res["bord2"] end
	if res["blur1"] then tags=tags.."\\blur"..res["blur2"] end
	if res["be1"] then tags=tags.."\\be"..res["be2"] end
	if res["fs1"] then tags=tags.."\\fs"..res["fs2"] end
	if res["spac1"] then tags=tags.."\\fsp"..res["spac2"] end
	if res["fscx1"] then tags=tags.."\\fscx"..res["fscx2"] end
	if res["fscy1"] then tags=tags.."\\fscy"..res["fscy2"] end
	if res["xbord1"] then tags=tags.."\\xbord"..res["xbord2"] end
	if res["ybord1"] then tags=tags.."\\ybord"..res["ybord2"] end
	if res["xshad1"] then tags=tags.."\\xshad"..res["xshad2"] end
	if res["yshad1"] then tags=tags.."\\yshad"..res["yshad2"] end
	if res["frz1"] then tags=tags.."\\frz"..res["frz2"] end
	if res["frx1"] then tags=tags.."\\frx"..res["frx2"] end
	if res["fry1"] then tags=tags.."\\fry"..res["fry2"] end
	if res["fax1"] then tags=tags.."\\fax"..res["fax2"] end
	if res["fay1"] then tags=tags.."\\fay"..res["fay2"] end
	if res["k1"] then tags=tags.."\\c"..col1 end
	if res["k2"] then tags=tags.."\\2c"..col2 end
	if res["k3"] then tags=tags.."\\3c"..col3 end
	if res["k4"] then tags=tags.."\\4c"..col4 end
	if res["arfa"] then tags=tags.."\\alpha&H"..res["alpha"].."&" end
	if res["arf1"] then tags=tags.."\\1a&H"..res["alph1"].."&" end
	if res["arf2"] then tags=tags.."\\2a&H"..res["alph2"].."&" end
	if res["arf3"] then tags=tags.."\\3a&H"..res["alph3"].."&" end
	if res["arf4"] then tags=tags.."\\4a&H"..res["alph4"].."&" end
	if res["moretags"]~="\\" then tags=tags..res["moretags"] end

	if pla==1 then 
	pl1=esc(pl1)	pl3=esc(pl3)
	text=text:gsub(pl1.."({\\[^}]-)}"..pl3,pl1.."%1"..tags.."}"..pl3)
	text=text:gsub(pl1..pl3,pl1.."{"..tags.."}"..pl3)
	else
	text=text:gsub("^({\\[^}]-)}","%1"..tags.."}")
	end
	text=duplikill(text)
	
	
	-- bold
	if res["bolt"] then
	    if text:match("^{[^}]*\\b[01]") then
	    text=text:gsub("\\b([01])",function (a) return "\\b"..(1-a) end )
	    else
	    if text:match("\\b([01])") then bolt=text:match("\\b([01])") else bolt="1" end
	    text=text:gsub("\\b([01])",function (a) return "\\b"..(1-a) end )
	    text=text:gsub("^({\\[^}]*)}","%1\\b"..bolt.."}")
	    end
	end
	-- italics
	if res["italix"] then
	    if text:match("^{[^}]*\\i[01]") then
	    text=text:gsub("\\i([01])",function (a) return "\\i"..(1-a) end )
	    else
	    if text:match("\\i([01])") then italix=text:match("\\i([01])") else italix="1" end
	    text=text:gsub("\\i([01])",function (a) return "\\i"..(1-a) end )
	    text=text:gsub("^({\\[^}]*)}","%1\\i"..italix.."}")
	    end
	end
	-- \fad
	if res.fade then
	    if line.text:match("\\fad%(") then
	    text=text:gsub("\\fad%([%d%.%,]-%)","")
	    end
	    text=text:gsub("^{\\","{\\fad(" .. res.fadin .. "," .. res.fadout .. ")\\")
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
	    subs[i]=line
	end
end

function special(subs, sel)
    for i=#sel,1,-1 do
        local line=subs[sel[i]]
        local text=subs[sel[i]].text
	local layer=line.layer
	
	if text:match("\\fscx") and text:match("\\fscy") then
	scalx=text:match("\\fscx([%d%.]+)")
	scaly=text:match("\\fscy([%d%.]+)")
	  if res.spec=="fscx -> fscy" then text=text:gsub("\\fscy[%d%.]+","\\fscy"..scalx) end
	  if res.spec=="fscy -> fscx" then text=text:gsub("\\fscx[%d%.]+","\\fscx"..scaly) end
	end
	
	if res.spec=="move colour tag to the first block" then
	    text=text:gsub("^({\\[^}]-})([^{]+)({\\[1234]?c&H%x+&[^}]-})","%1%3%2")
	    text=text:gsub("^([^{]+)({\\[1234]?c&H%x+&[^}]-})","%2%1")
	    text=text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
	    if not text:match("\\t") then text=duplikill(text) end
	end
	
	if res.spec=="convert clip <-> iclip" then
	if text:match("\\clip") then text=text:gsub("\\clip","\\iclip")
	elseif text:match("\\iclip") then text=text:gsub("\\iclip","\\clip") end
	end
	
	if res.spec=="clean up tags" then
  	    text=text:gsub("\\\\","\\")
	    text=text:gsub("\\}","}")
	    text=text:gsub("(%.%d%d)%d+","%1")
	    text=text:gsub("(%.%d)0","%1")
	    text=text:gsub("%.0([^%d])","%1")
		repeat
		text=text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
		until text:match("{(\\[^}]-)}{(\\[^}]-)}")==nil
	    text=text:gsub("^{(\\[^}]-)\\frx0\\fry0([\\}])","{%1%2")
	    if not text:match("\\t") then text=duplikill(text) end
	end
	
	if res.spec=="clean up and sort transforms" then
	text=text:gsub("^({\\[^}]-})",function(tg) return cleantr(tg) end)
	end
	
	if res.spec=="convert clip to drawing" then
	  if not text:match("\\clip") then aegisub.cancel() end
	  text=text:gsub("^({\\[^}]-}).*","%1")
	  text=text:gsub("^({[^}]*)\\clip%(m(.-)%)([^}]*)}","%1%3\\p1}m%2")
	  if text:match("\\pos") then
	    local xx,yy=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
	    xx=round(xx) yy=round(yy)
	    ctext=text:match("}m ([%d%a%s%-]+)")
	    ctext2=ctext:gsub("([%d%-]+)%s([%d%-]+)",function(a,b) return a-xx.." "..b-yy end)
	    ctext=ctext:gsub("%-","%%-")
	    text=text:gsub(ctext,ctext2)
	  end
	  if not text:match("\\pos") then text=text:gsub("^{","{\\pos(0,0)") end
	  if text:match("\\an") then text=text:gsub("\\an%d","\\an7") else text=text:gsub("^{","{\\an7") end
	  if text:match("\\fscx") then text=text:gsub("\\fscx[%d%.]+","\\fscx100") else text=text:gsub("\\p1","\\fscx100\\p1") end
	  if text:match("\\fscy") then text=text:gsub("\\fscy[%d%.]+","\\fscy100") else text=text:gsub("\\p1","\\fscy100\\p1") end
	end
	
	if res.spec=="create 3D effect from shadow" then
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
	
	if res.spec~="create 3D effect from shadow" then
	line.text=text	subs[sel[i]]=line
	end
    end
end

function round(num)
	if num-math.floor(num)>=0.5 then num=math.ceil(num) else num=math.floor(num) end
	return num
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
	trnsfrm=""
	for t in tags:gmatch("(\\t%([^%(%)]-%))") do trnsfrm=trnsfrm..t end
	for t in tags:gmatch("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))") do trnsfrm=trnsfrm..t end
	tags=tags:gsub("(\\t%([^%(%)]+%))","")
	tags=tags:gsub("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","")
	tags=tags:gsub("^({\\[^}]*)}","%1"..trnsfrm.."}")

	cleant=""
	for ct in tags:gmatch("\\t%((\\[^%(%)]-)%)") do cleant=cleant..ct end
	for ct in tags:gmatch("\\t%((\\[^%(%)]-%([^%)]-%)[^%)]-)%)") do cleant=cleant..ct end
	tags=tags:gsub("(\\t%(\\[^%(%)]+%))","")
	tags=tags:gsub("(\\t%(\\[^%(%)]-%([^%)]-%)[^%)]-%))","")
	if cleant~="" then tags=tags:gsub("^({\\[^}]*)}","%1\\t("..cleant..")}") end
	return tags
end

function duplikill(text)
	tags1={"blur","be","bord","shad","xbord","xshad","ybord","yshad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay"}
	for i=1,#tags1 do
	    tag=tags1[i]
	    text=text:gsub("(\\"..tag.."[%d%.%-]+)([^}]-)(\\"..tag.."[%d%.%-]+)","%3%2")
	end
	text=text:gsub("\\1c&","\\c&")
	tags2={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}
	for i=1,#tags2 do
	    tag=tags2[i]
	    text=text:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%1%2")
	end	
	return text
end

function esc(str)
str=str
:gsub("%%","%%%%")
:gsub("%(","%%%(")
:gsub("%)","%%%)")
:gsub("%[","%%%[")
:gsub("%]","%%%]")
:gsub("%.","%%%.")
:gsub("%*","%%%*")
:gsub("%-","%%%-")
:gsub("%+","%%%+")
:gsub("%?","%%%?")
return str
end

function konfig(subs, sel)
oneline=subs[sel[1]]
linetext=oneline.text:gsub("{\\[^}]-}","")
	dialog_config=
	{
	    {x=0,y=0,width=6,height=1,class="label",
	    label="A multi-headed typesetting tool.       Only checked tags get used. Applies to all selected lines.", },
	    {x=0,y=1,width=1,height=1,class="checkbox",name="k1",label="Primary:",value=false },
	    {x=0,y=2,width=1,height=1,class="checkbox",name="k3",label="Border:",value=false },
	    {x=0,y=3,width=1,height=1,class="checkbox",name="k4",label="Shadow:",value=false },
	    {x=0,y=4,width=1,height=1,class="checkbox",name="k2",label="useless... (2c):",value=false },
	    {x=0,y=5,width=1,height=1,class="checkbox",name="bolt",label="Bold",value=false },
	    {x=0,y=6,width=1,height=1,class="checkbox",name="italix",label="Italics",value=false },
	    
	    {x=0,y=7,width=1,height=1,class="checkbox",name="an1",label="\\an",value=false },
	    
	    {x=0,y=9,width=5,height=1,class="label",label="transform mode [all applicable selected tags go after \\t]"},
	    {x=0,y=10,width=1,height=1,class="label",label="Transform t1,t2:"},
	    {x=1,y=10,width=2,height=1,class="floatedit",name="trin" },
	    {x=3,y=10,width=1,height=1,class="floatedit",name="trout" },
	    {x=3,y=11,width=2,height=1,class="checkbox",name="tend",label="Count times from end",value=false},
	    {x=0,y=11,width=1,height=1,class="label",label="              Accel:"},
	    {x=1,y=11,width=2,height=1,class="floatedit",name="accel",value=1 },
	    {x=0,y=8,width=1,height=1,class="label",label="Additional tags:"},
	    {x=1,y=8,width=3,height=1,class="edit",name="moretags",value="\\" },
	    
	    {x=6,y=0,width=3,height=1,class="edit",name="info",value=" Selected lines: "..#sel },
	    
	    {x=1,y=1,width=1,height=1,class="color",name="c1" },
	    {x=1,y=2,width=1,height=1,class="color",name="c3" },
	    {x=1,y=3,width=1,height=1,class="color",name="c4" },
	    {x=1,y=4,width=1,height=1,class="color",name="c2" },
	    {x=1,y=7,width=1,height=1,class="dropdown",name="an2",items={"1","2","3","4","5","6","7","8","9"},value="5"},
	    
	    {x=2,y=1,width=1,height=1,class="checkbox",name="bord1",label="\\bord",value=false },
	    {x=2,y=2,width=1,height=1,class="checkbox",name="shad1",label="\\shad",value=false },
	    {x=2,y=3,width=1,height=1,class="checkbox",name="fs1",label="\\fs",value=false },
	    {x=2,y=4,width=1,height=1,class="checkbox",name="spac1",label="\\fsp",value=false },
	    {x=2,y=5,width=1,height=1,class="checkbox",name="blur1",label="\\blur",value=false },
	    {x=2,y=6,width=1,height=1,class="checkbox",name="be1",label="\\be",value=false },
	    
	    {x=3,y=1,width=1,height=1,class="floatedit",name="bord2",value=default_border,min=0 },
	    {x=3,y=2,width=1,height=1,class="floatedit",name="shad2",value=default_shadow,min=0 },
	    {x=3,y=3,width=1,height=1,class="floatedit",name="fs2",value=default_fontsize,min=1 },
	    {x=3,y=4,width=1,height=1,class="floatedit",name="spac2",value=default_spacing },
	    {x=3,y=5,width=1,height=1,class="floatedit",name="blur2",value=default_blur,min=0 },
	    {x=3,y=6,width=1,height=1,class="floatedit",name="be2",value=1,min=1 },
	    
	    {x=2,y=7,width=1,height=1,class="checkbox",name="fade",label="\\fad",value=false },
	    {x=3,y=7,width=1,height=1,class="floatedit",name="fadin",min=0 },
	    {x=4,y=7,width=1,height=1,class="label",label="<-- in,out -->", },
	    {x=5,y=7,width=2,height=1,class="floatedit",name="fadout",min=0 },
	    
    	    {x=4,y=1,width=1,height=1,class="checkbox",name="xbord1",label="\\xbord",value=false },
	    {x=4,y=2,width=1,height=1,class="checkbox",name="ybord1",label="\\ybord",value=false },
	    {x=4,y=3,width=1,height=1,class="checkbox",name="xshad1",label="\\xshad",value=false },
	    {x=4,y=4,width=1,height=1,class="checkbox",name="yshad1",label="\\yshad",value=false },
	    {x=4,y=5,width=1,height=1,class="checkbox",name="fax1",label="\\fax",value=false },
	    {x=4,y=6,width=1,height=1,class="checkbox",name="fay1",label="\\fay",value=false },
	    
	    {x=5,y=1,width=2,height=1,class="floatedit",name="xbord2",value="",min=0 },
	    {x=5,y=2,width=2,height=1,class="floatedit",name="ybord2",value="",min=0 },
	    {x=5,y=3,width=2,height=1,class="floatedit",name="xshad2",value="" },
	    {x=5,y=4,width=2,height=1,class="floatedit",name="yshad2",value="" },
	    {x=5,y=5,width=2,height=1,class="floatedit",name="fax2",value=default_fax },
	    {x=5,y=6,width=2,height=1,class="floatedit",name="fay2",value=default_fay },
	    
	    {x=5,y=8,width=1,height=1,class="checkbox",name="frz1",label="\\frz",value=false },
	    {x=5,y=9,width=1,height=1,class="checkbox",name="frx1",label="\\frx",value=false },
	    {x=5,y=10,width=1,height=1,class="checkbox",name="fry1",label="\\fry",value=false },
	    {x=5,y=11,width=1,height=1,class="checkbox",name="fscx1",label="\\fscx",value=false },
	    {x=5,y=12,width=1,height=1,class="checkbox",name="fscy1",label="\\fscy",value=false },
	    
	    {x=6,y=8,width=2,height=1,class="floatedit",name="frz2",value="" },
	    {x=6,y=9,width=2,height=1,class="floatedit",name="frx2",value="" },
	    {x=6,y=10,width=2,height=1,class="floatedit",name="fry2",value="" },
	    {x=6,y=11,width=2,height=1,class="floatedit",name="fscx2",value=100,min=0 },
	    {x=6,y=12,width=2,height=1,class="floatedit",name="fscy2",value=100,min=0 },
	    
	    {x=7,y=1,width=1,height=1,class="checkbox",name="layer",label="layer",value=false},
	    {x=7,y=7,width=1,height=1,class="checkbox",name="q2",label="\\q2",value=false },
	    {x=7,y=2,width=1,height=1,class="checkbox",name="arfa",label="\\alpha",value=false },
	    
	    {x=7,y=3,width=1,height=1,class="checkbox",name="arf1",label="\\1a",value=false },
	    {x=7,y=4,width=1,height=1,class="checkbox",name="arf2",label="\\2a",value=false },
	    {x=7,y=5,width=1,height=1,class="checkbox",name="arf3",label="\\3a",value=false },
	    {x=7,y=6,width=1,height=1,class="checkbox",name="arf4",label="\\4a",value=false },
	    
	    {x=8,y=1,width=1,height=1,class="dropdown",name="layers",
		items={"-5","-4","-3","-2","-1","+1","+2","+3","+4","+5"},value="+1" },
	    {x=8,y=2,width=1,height=1,class="dropdown",name="alpha",
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="00" },
	    
	    {x=8,y=3,width=1,height=1,class="dropdown",name="alph1",
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="00" },
	    {x=8,y=4,width=1,height=1,class="dropdown",name="alph2",
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="00" },
	    {x=8,y=5,width=1,height=1,class="dropdown",name="alph3",
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="00" },
	    {x=8,y=6,width=1,height=1,class="dropdown",name="alph4",
		items={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","FF"},value="00" },
		
	    {x=0,y=12,width=1,height=1,class="label",label="Special functions:"},
	    {x=1,y=12,width=3,height=1,class="dropdown",name="spec",items={"fscx -> fscy","fscy -> fscx","move colour tag to the first block","convert clip <-> iclip","clean up tags","clean up and sort transforms","convert clip to drawing","create 3D effect from shadow"},value="convert clip <-> iclip"},
	    
	    {x=0,y=13,width=1,height=1,class="label",label="Tag position*:"},
	    {x=1,y=13,width=7,height=1,class="edit",name="linetext",value=linetext,hint="Place asterisk where you want the tags"},
	    
	} 
	
	pressed, res=aegisub.dialog.display(dialog_config,{"Apply","Transform","Repeat Last","Special","Cancel"},{ok='Apply',cancel='Cancel'})
	
	if pressed=="Apply" then trans=0 hh9(subs, sel) end
	if pressed=="Transform" then trans=1 hh9(subs, sel) end
	if pressed=="Special" then special(subs, sel) end
	
	if pressed~="Repeat Last" then
	    last_set={}
	    for key,val in ipairs(dialog_config) do
		if val.name==nil then name="" result="n/a" else
		local name=val.name
		result=res[name]
		if result==nil then result="n/a" end
		if result==true then result="true" end
		if result==false then result="false" end
		end
		table.insert(last_set,result)
	    end
	end
	if pressed=="Repeat Last" then
	    for key,val in ipairs(dialog_config) do
		local name=val.name
		if last_set[key]=="true" then res[name]=true
		elseif last_set[key]=="false" then res[name]=false
		elseif last_set[key]~="n/a" then res[name]=last_set[key]
		else
		end
	    end
	    hh9(subs, sel)
	end
end

function hydra(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, hydra)
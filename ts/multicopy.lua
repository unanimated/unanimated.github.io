script_name="MultiCopy"
script_description="Copy tags or text from multiple lines and paste to others"
script_author="unanimated"
script_version="1.83"

require "clipboard"

-- COPY PART

function copy(subs, sel)	-- tags
	copytags=""
    for x, i in ipairs(sel) do
	text=subs[i].text
	if text:match("^({\\[^}]*})") then tags=text:match("^({\\[^}]*})") copytags=copytags..tags.."\n" end
	if x==#sel then copytags=copytags:gsub("\n$","") end
    end
    copydialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=copytags},}
    pressed,res=aegisub.dialog.display(copydialog,{"OK","Copy to clipboard"},{close='OK'})
    if pressed=="Copy to clipboard" then    clipboard.set(copytags) end
end

function copyt(subs, sel)	-- text
	copytekst=""
    for x, i in ipairs(sel) do
	text=subs[i].text
	text=text:gsub("^{\\[^}]-}","")
	copytekst=copytekst..text.."\n"
	if x==#sel then copytekst=copytekst:gsub("\n$","") end
    end
    copydialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=copytekst},}
    pressed,res=aegisub.dialog.display(copydialog,{"OK","Copy to clipboard"},{close='OK'})
    if pressed=="Copy to clipboard" then    clipboard.set(copytekst) end
end

function copyc(subs, sel)	-- clip etc
	copyclip=""
    for x, i in ipairs(sel) do
	line=subs[i]
	text=subs[i].text
	
	if CM=="clip" and text:match("^{[^}]-\\i?clip") then
	klip=text:match("^{[^}]-\\i?clip%(([^%)]+)%)")
	copyclip=copyclip..klip.."\n"
	end
	
	if CM=="position" and text:match("^{[^}]-\\pos") then
	posi=text:match("^{[^}]-\\pos%(([^%)]+)%)")
	copyclip=copyclip..posi.."\n"
	end
	
	if CM=="blur" and text:match("^{[^}]-\\blur") then
	blurr=text:match("^{[^}]-\\blur([%d%.]+)")
	copyclip=copyclip..blurr.."\n"
	end
	
	if CM=="border" and text:match("^{[^}]-\\bord") then
	bordd=text:match("^{[^}]-\\bord([%d%.]+)")
	copyclip=copyclip..bordd.."\n"
	end
	
	if CM=="\\1c" and text:match("^{[^}]-\\1?c&") then
	kolor1=text:match("^{[^}]-\\1?c(&H%w+&)")
	copyclip=copyclip..kolor1.."\n"
	end

	if CM=="\\3c" and text:match("^{[^}]-\\3c") then
	kolor3=text:match("^{[^}]-\\3c(&H%w+&)")
	copyclip=copyclip..kolor3.."\n"
	end

	if CM=="\\4c" and text:match("^{[^}]-\\4c") then
	kolor4=text:match("^{[^}]-\\4c(&H%w+&)")
	copyclip=copyclip..kolor4.."\n"
	end
	
	if CM=="alpha" and text:match("^{[^}]-\\alpha") then
	alphaa=text:match("^{[^}]-\\alpha(&H%w+&)")
	copyclip=copyclip..alphaa.."\n"
	end
	
	if CM=="\\fscx" and text:match("^{[^}]-\\fscx") then
	fscxx=text:match("^{[^}]-\\fscx([%d%.]+)")
	copyclip=copyclip..fscxx.."\n"
	end
	
	if CM=="\\fscy" and text:match("^{[^}]-\\fscy") then
	fscyy=text:match("^{[^}]-\\fscy([%d%.]+)")
	copyclip=copyclip..fscyy.."\n"
	end
	
	if CM=="layer" then copyclip=copyclip..line.layer.."\n" end
	if CM=="actor" then copyclip=copyclip..line.actor.."\n" end
	if CM=="effect" then copyclip=copyclip..line.effect.."\n" end
	if CM=="duration" then copyclip=copyclip..line.end_time-line.start_time.."\n" end
	
	if x==#sel then copyclip=copyclip:gsub("\n$","") end
    end
    copydialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Data to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=copyclip},}
    pressed,res=aegisub.dialog.display(copydialog,{"OK","Copy to clipboard"},{close='OK'})
    if pressed=="Copy to clipboard" then    clipboard.set(copyclip) end
end

function copyall(subs, sel)	-- all
	copylines=""
    for x, i in ipairs(sel) do
	text=subs[i].text
	if x~=#sel then copylines=copylines..text.."\n" end
	if x==#sel then copylines=copylines..text end
    end
    copydialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=copylines},}
    pressed,res=aegisub.dialog.display(copydialog,{"OK","Copy to clipboard"},{cancel='OK'})
    if pressed=="Copy to clipboard" then    clipboard.set(copylines) end
end

-- CR Export for Pad

function crmod(subs)
    for i=1, #subs do
        if subs[i].class=="dialogue" then
        line=subs[i]
        text=subs[i].text
	style=line.style
	text=text
	:gsub("^%s*","")
	:gsub("%s%s+"," ")
	:gsub("{\\i0}$","")
	
	-- change main style to Default
	style=style:gsub("[Ii]nternal","Italics")
	if style:match("[Ii]talics") and not style:match("[Ff]lashback") and not text:match("\\i1") then text="{\\i1}"..text end
	if style:match("[Mm]ain") or style:match("[Oo]verlap")  or style:match("[Ii]talics") 
	or style:match("[Ii]nternal")  or style:match("[Ff]lashback")  or style:match("[Nn]arrat") 
	then style="Default" end

	-- nuke tags from signs, set actor to "Sign", add timecode
	if not style:match("Defa") then
	text=text:gsub("{[^\\}]*}","")
	actor="Sign"
	timecode=math.floor(line.start_time/1000)
	tc1=math.floor(timecode/60)
	tc2=timecode%60+1
	if tc2==60 then tc2=0 tc1=tc1+1 end
	if tc1<10 then tc1="0"..tc1 end
	if tc2<10 then tc2="0"..tc2 end
	text="{TS "..tc1..":"..tc2.."}"..text
	if style:match("[Tt]itle") then text=text:gsub("({TS %d%d:%d%d)}","%1 Title}") end

	else
	text=text:gsub("%s?\\[Nn]%s?"," ") :gsub("\\a6","\\an8")
	line.text=text
	end
	line.actor=""
	line.style=style
	line.text=text
        subs[i]=line
        end
    end
end    

-- move signs to the top of the script
function crsort(subs)
	i=1	moved=0
	while i<=(#subs-moved) do
	    line=subs[i]
	    if line.class=="dialogue" and line.style=="Default" then
		subs.delete(i)
		moved=moved+1
		subs.append(line)
	    else
		i=i+1
	    end
	end
end

-- copy text from all lines
function crcopy(subs, sel)
	copylines=""
    for i=1, #subs do
        if subs[i].class == "dialogue" then
        local line=subs[i]
	local text=subs[i].text
	if x~=#subs then copylines=copylines..text.."\n" end
	if x==#subs then copylines=copylines..text end
	subs[i]=line
	end
    end
    copydialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=copylines},}
    pressed,res=aegisub.dialog.display(copydialog,{"OK","Copy to clipboard"},{close='OK'})
    if pressed=="Copy to clipboard" then    clipboard.set(copylines) end
end


-- PASTE PART

function paste(subs, sel)	-- tags
raw=res.dat	raw=raw:gsub("\n","")
    fail=0    
  if res.oneline==true then 
	for x, i in ipairs(sel) do
        local line=subs[i]
	local text=subs[i].text
	text=text:gsub("^({\\[^}]*})","")
	text=raw..text
	line.text=text
	subs[i]=line
	end
  else
    data={}
    for dataline in raw:gmatch("({[^}]-})") do table.insert(data,dataline) end
    if #sel~=#data then fail=1 else
	for x, i in ipairs(sel) do
        local line=subs[i]
	local text=subs[i].text
	text=text:gsub("^({\\[^}]*})","")
	text=data[x]..text
	line.text=text
	subs[i]=line
	end
    end
  end
    if fail==1 then aegisub.dialog.display({{class="label",
	    label="Line count of the selection \ndoesn't match pasted data.",x=0,y=0,width=1,height=2}},{"OK"},{close='OK'})  end
end

function pastet(subs, sel)	-- text
raw=res.dat	raw=raw:gsub("\n","")
    failt=0    
  if res.oneline==true then 
	for x, i in ipairs(sel) do
        local line=subs[i]
	local text=subs[i].text
	tags=text:match("^({\\[^}]*})")
	if tags==nil then tags="" end
	text=tags..raw
	line.text=text
	subs[i]=line
	end
  else
    data={}	raw=res.dat.."\n"
    for dataline in raw:gmatch("(.-)\n") do table.insert(data,dataline) end
    if #sel~=#data then failt=1 else
	for x, i in ipairs(sel) do
        local line=subs[i]
	local text=subs[i].text
	tags=text:match("^({\\[^}]*})")
	if tags==nil then tags="" end
	text=tags..data[x]
	line.text=text
	subs[i]=line
	end
      end
    end
    if failt==1 then aegisub.dialog.display({{class="label",
	    label="Line count of the selection \ndoesn't match pasted data.",x=0,y=0,width=1,height=2}},{"OK"},{close='OK'})  end
end

function pastec(subs, sel)	-- clip and stuff
raw=res.dat	raw=raw:gsub("\n","")
    failc=0    	pasteover=0    podetails=""
  if res.oneline==true then
	for x, i in ipairs(sel) do
        line=subs[i]
	text=line.text
	if not text:match("^{\\") then text="{\\mc}"..text end
	if PM=="clip" and text:match("^{[^}]-\\clip") then text=text:gsub("^({[^}]-\\i?clip%()[^%)]+(%))","%1"..raw.."%2") end
	if PM=="clip" and not text:match("^{[^}]-\\clip") then text=text:gsub("^({\\[^}]*)}","%1\\clip%("..raw.."%)}") end
	if PM=="position" and text:match("\\pos") then text=text:gsub("(\\pos%()[^%)]+(%))","%1"..raw.."%2") end
	if PM=="position" and not text:match("\\pos") then text=text:gsub("^({\\[^}]*)}","%1\\pos%("..raw.."%)}") end
	if PM=="blur" then text=addtag("\\blur"..raw,text) end
	if PM=="border" then text=addtag("\\bord"..raw,text) end
	if PM=="\\1c" then text=addtag("\\c"..raw,text) end
	if PM=="\\3c" then text=addtag("\\3c"..raw,text) end
	if PM=="\\4c" then text=addtag("\\4c"..raw,text) end
	if PM=="alpha" then text=addtag("\\alpha"..raw,text) end
	if PM=="\\fscx" or PM=="\\fscx\\fscy" then text=addtag("\\fscx"..raw,text) end
	if PM=="\\fscy" or PM=="\\fscx\\fscy" then text=addtag("\\fscy"..raw,text) end
	if PM=="any tag" then text=text:gsub("^({\\[^}]*)}","%1"..raw.."}") end
	if PM=="layer" then line.layer=raw end
	if PM=="actor" then line.actor=raw end
	if PM=="effect" then line.effect=raw end
	if PM=="duration" then line.end_time=line.start_time+raw end
	if PM=="text mod." then text=textmod(raw) end
	if PM=="gbc text" then
	    stags=text:match("^({\\[^}]-})")
	    if stags==nil then stags="" end
	    lastag=text:match("({\\[^}]-}).$")
	    text=stags..raw:gsub("(.)$",lastag.."%1")
	end
	text=text:gsub("({\\[^}]-})",function(tg) return duplikill(tg) end)
	text=text:gsub("\\mc","")
	text=text:gsub("{}","")
	line.text=text
	subs[i]=line
	end
  else
    data={}	raw=res.dat.."\n" raw=raw:gsub("\n\n$","\n")
    for dataline in raw:gmatch("(.-)\n") do table.insert(data,dataline) end
    
    -- paste over with check
    if PM=="all" then pasteover=1 pasterep="" pnum=""	m100=0 m0=0 mtotal=0 om=0 omtotal=0 alter="Default"
    for i=1,#subs do 
        if subs[i].class=="style" and subs[i].name:match("Alt") then alter=subs[i].name end
	if subs[i].class=="dialogue" then z=i-1 break end 
    end
    susp=""	suspL=0	suspT=0	sustab={}
      for x, i in ipairs(sel) do
	line=subs[i]
	T1l=subs[i].text				T2l=data[x]	if T2l==nil then T2l="" end T2l=T2l:gsub("^%w+:([^%s])","%1")
	T1=T1l:gsub("{[^}]-}","") :gsub("\\N"," ")	T2=T2l:gsub("{[^}]-}","") :gsub("\\N"," ")
	L1=T1:len()					L2=T2:len()
	ln=i-z	if ln<10 then ln="00"..ln elseif ln<100 then ln="0"..ln end
	
	-- comparing words between current and pasted
	TC=T1:gsub("[%.,%?!\"—]","") TD=T2:gsub("[%.,%?!\"—]","")	ml=""
	for c in TC:gmatch("[%w']+") do
	    for d in TD:gmatch("[%w']+") do
		if c:lower()==d:lower() then
		    TD=TD:gsub("^.-"..d,"")
		    ml=ml..c.." "
		    break
		end
	    end
	end
	ml=ml:gsub(" $","")
	M1=ml:len()
	M2=TC:len()	if M2==0 then M2=1 end
	match1=math.floor((M1*100/M2+0.5))
	
	-- other direction
	TC=T1:gsub("[%.,%?!\"—]","") TD=T2:gsub("[%.,%?!\"—]","")	mr=""
	for c in TD:gmatch("[%w']+") do
	    for d in TC:gmatch("[%w']+") do
		if c:lower()==d:lower() then
		    TC=TC:gsub("^.-"..d,"")
		    mr=mr..c.." "
		    break
		end
	    end
	end
	mr=mr:gsub(" $","")
	M1=mr:len()
	M2=TD:len()	if M2==0 then M2=1 end
	match2=math.floor((M1*100/M2+0.5))
	
	if match1>match2 then match=match1 othermatch=match2 ma=ml else match=match2 othermatch=match1 ma=mr end
	pasterep=pasterep..ln.."	"..match.."%	"..ma.."\n"
	if match==100 then m100=m100+1 if othermatch==100 then om=om+1 end end
	if match==0 then m0=m0+1 end
	mtotal=mtotal+match
	omtotal=omtotal+othermatch
	line.effect=othermatch
	line.text=T2l
	if T2l:match("{%*ALT%*}") then line.style=alter end
	if T2l:match("^%#") then line.comment=true end
	subs[i]=line
      end
	
	if #sel~=#data then
		for s=1,#sustab do susp=susp..sustab[s] ..", " end
		susp=susp:gsub(", $","")
		ldiff=#sel-#data
		if math.abs(ldiff)==1 then es="" else es="s" end
		if ldiff>0 then LD="The pasted data is "..ldiff.." line"..es.." shorter than your selection" else
		LD="The pasted data is ".. 0-ldiff.." line"..es.." longer than your selection" end
		podetails="Line count of the selection doesn't match pasted data.\n"..LD.."\nIf you're pasting over edited text from a pad,\nwhere you start getting too many 0% is where it's probably a line off."
	else
		fullm=math.floor(m100*100/#sel+0.5)	zerom=math.floor(m0*100/#sel+0.5)	totalm=math.floor(mtotal*10/#sel+0.5)/10
		otherm=math.floor(om*100/#sel+0.5)	totalom=math.floor(omtotal*10/#sel+0.5)/10
		podetails="Line count of the selection matched pasted data. ("..#sel.." lines)\nFull match: "..m100.."/"..#sel.." ("..fullm.."%)   Both ways: "..om.."/"..#sel.." ("..otherm.."%, ie. "..#sel-om.." lines changed - ".. 100-otherm.."%)\nZero match: "..m0.."/"..#sel.." ("..zerom.."%)\nOverall match: "..totalm.."% (".. 100-totalm.."% change / ".. 100-totalom.."% both ways)"
	end
	
    end
      
    if #sel~=#data and pasteover==0 then failc=1
    else
	for x, i in ipairs(sel) do
        line=subs[i]
	text=line.text
	text2=data[x]
	if not text:match("^{\\") then text="{\\mc}"..text end
	if PM=="clip" and text:match("^{[^}]-\\clip") then text=text:gsub("^({[^}]-\\i?clip%()[^%)]+(%))","%1"..text2.."%2") end
	if PM=="clip" and not text:match("^{[^}]-\\clip") then text=text:gsub("^({\\[^}]*)}","%1\\clip%("..text2.."%)}") end
	if PM=="position" and text:match("\\pos") then text=text:gsub("(\\pos%()[^%)]+(%))","%1"..text2.."%2") end
	if PM=="position" and not text:match("\\pos") then text=text:gsub("^({\\[^}]*)}","%1\\pos%("..text2.."%)}") end
	if PM=="blur" then text=addtag("\\blur"..text2,text) end
	if PM=="border" then text=addtag("\\bord"..text2,text) end
	if PM=="\\1c" then text=addtag("\\c"..text2,text) end
	if PM=="\\3c" then text=addtag("\\3c"..text2,text) end
	if PM=="\\4c" then text=addtag("\\4c"..text2,text) end
	if PM=="alpha" then text=addtag("\\alpha"..text2,text) end
	if PM=="\\fscx" or PM=="\\fscx\\fscy" then text=addtag("\\fscx"..text2,text) end
	if PM=="\\fscy" or PM=="\\fscx\\fscy" then text=addtag("\\fscy"..text2,text) end
	if PM=="any tag" then text=text:gsub("^({\\[^}]*)}","%1"..text2.."}") end
	if PM=="layer" then line.layer=text2 end
	if PM=="actor" then line.actor=text2 end
	if PM=="effect" then line.effect=text2 end
	if PM=="duration" then line.end_time=line.start_time+text2 end
	if PM=="text mod." then text=textmod(text2) end
	if PM=="gbc text" then
	    stags=text:match("^({\\[^}]-})")
	    if stags==nil then stags="" end
	    lastag=text:match("({\\[^}]-}).$")
	    text=stags..text2:gsub("(.)$",lastag.."%1")
	end
	if PM=="de-irc" then
	    line=string2line(text2)
	    text=line.text
	end
	
	text=text:gsub("({\\[^}]-})",function(tg) return duplikill(tg) end)
	text=text:gsub("\\mc","")
	text=text:gsub("{}","")
	line.text=text
	subs[i]=line
	end
      end
    end
    if failc==1 then aegisub.dialog.display({{class="label",
    label="Line count of the selection \ndoesn't match pasted data.\nSelection: "..#sel.."\nPasted data: "..#data,x=0,y=0,width=1,height=2}},
    {"OK"},{close='OK'})
    end
	
    if pasteover==1 then pr,rs=aegisub.dialog.display({
    {x=0,y=0,width=40,height=1,class="label",name="ch1",label="line       % matched    matched words"},
    {x=0,y=1,width=40,height=18,class="textbox",name="ch2",value=pasterep},
    {x=0,y=19,width=40,height=4,class="textbox",name="ch3",value=podetails},
    {x=0,y=23,width=40,height=1,class="checkbox",name="ef",label="% in effect",value=false},
    },{"OK"},{close='OK'})
    	if not rs.ef then
	  for x, i in ipairs(sel) do l=subs[i] l.effect="" subs[i]=l end
	end
    end
end

-- paste text over while keeping tags
function textmod(text2)
    tk={}
    tg={}
	text=text:gsub("{\\\\k0}","")
	repeat text=text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
	    until not text:match("{(\\[^}]-)}{(\\[^}]-)}")
	vis=text:gsub("{[^}]-}","")
	  for c in text2:gmatch(".") do
	    table.insert(tk,c)
	  end
	stags=text:match("^{(\\[^}]-)}")
	if stags==nil then stags="" end
	text=text:gsub("^{\\[^}]-}","") :gsub("{[^\\}]-}","")
	count=0
	for seq in text:gmatch("[^{]-{%*?\\[^}]-}") do
	    chars,as,tak=seq:match("([^{]-){(%*?)(\\[^}]-)}")
	    pos=chars:len()+count
	    tgl={p=pos,t=tak,a=as}
	    table.insert(tg,tgl)
	    count=pos
	end
    newline=""
    for i=1,#tk do
	newline=newline..tk[i]
	newt=""
	for n, t in ipairs(tg) do
	    if t.p==i then newt=newt..t.t as=t.a end
	end
	if newt~="" then newline=newline.."{"..as..newt.."}" end
    end
    newtext="{"..stags.."}"..newline
    text=newtext
    return text
end

function string2line(str)
	local ltype,layer,s_time,e_time,style,actor,margl,margr,margv,eff,txt=str:match("(%a+): (%d+),([^,]-),([^,]-),([^,]-),([^,]-),([^,]-),([^,]-),([^,]-),([^,]-),(.*)")
	l2={}
	l2.class="dialogue"
	if ltype=="Comment" then l2.comment=true else l2.comment=false end
	l2.layer=layer
	l2.start_time=string2time(s_time)
	l2.end_time=string2time(e_time)
	l2.style=style
	l2.actor=actor
	l2.margin_l=margl
	l2.margin_r=margr
	l2.margin_t=margv
	l2.effect=eff
	l2.text=txt
	return l2
end

function string2time(timecode)
	timecode=timecode:gsub("(%d):(%d%d):(%d%d)%.(%d%d)",function(a,b,c,d) return d*10+c*1000+b*60000+a*3600000 end)
	return timecode
end

function addtag(tag,text) text=text:gsub("^({\\[^}]-)}","%1"..tag.."}") return text end

tags1={"blur","be","bord","shad","xbord","xshad","ybord","yshad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay"}
tags2={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}

function duplikill(tagz)
	tf=""
	if tagz:match("\\t") then 
	    for t in tagz:gmatch("(\\t%([^%(%)]-%))") do tf=tf..t end
	    for t in tagz:gmatch("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","") do tf=tf..t end
	    tagz=tagz:gsub("\\t%([^%(%)]+%)","")
	    tagz=tagz:gsub("\\t%([^%(%)]-%([^%)]-%)[^%)]-%)","")
	end
	for i=1,#tags1 do
	    tag=tags1[i]
	    tagz=tagz:gsub("\\"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%2%1")
	end
	tagz=tagz:gsub("\\1c&","\\c&")
	for i=1,#tags2 do
	    tag=tags2[i]
	    tagz=tagz:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%2%1")
	end
	tagz=tagz:gsub("({\\[^}]-)}","%1"..tf.."}")
	return tagz
end

-- GUI PART

function multicopy(subs, sel)
	gui={
	{x=1,y=18,width=3,height=1,class="dropdown",name="copymode",value="tags",
	items={"tags","text","all","------","export CR for pad","------","clip","position","blur","border","\\1c","\\3c","\\4c","alpha","\\fscx","\\fscy","------","layer","duration","actor","effect"}},
	{x=0,y=17,width=10,height=1,class="label",label="Copy stuff from selected lines, select new lines [same number of them], run script again to paste stored data to new lines"},
	{x=0,y=0,width=10,height=17,class="textbox",name="dat"},
	{x=0,y=18,width=1,height=1,class="label",label="Copy:"},
	{x=4,y=18,width=1,height=1,class="label",label="Paste specific:"},
	{x=5,y=18,width=1,height=1,class="dropdown",name="pastemode",value="all",
	items={"all","text mod.","gbc text","de-irc","clip","position","blur","border","\\1c","\\3c","\\4c","alpha","\\fscx","\\fscy","\\fscx\\fscy","any tag","------","layer","duration","actor","effect"}},
	{x=6,y=18,width=5,height=1,class="checkbox",name="oneline",label="Paste one line to all selected lines",value=false},
	}
	buttons={"Copy","Paste tags","Paste text","Paste spec.","Paste from clipboard","Help","Cancel"}
	repeat
	if pressed=="Paste from clipboard" then
		klipboard=clipboard.get()
		for key,val in ipairs(gui) do
		    if val.name=="dat" then val.value=klipboard
		    else val.value=res[val.name] end
		end
	end
	if pressed=="Help" then
	herp="COPY part copies specified things line by line. PASTE part pastes these things line by line.\nThe idea is to copy something from for example 6 lines and paste it to another 6 lines.\nFor text you can just get the text from outside Aegisub and paste it to the appropriate number of lines.\n\ntags = initial tags\ntext = text AFTER initial tags (will include inline tags)\nall = tags+text, ie. everything in the Text field\n\nexport CR for pad: signs go to top with {TS} timecodes, nukes linebreaks and other CR garbage, fixes styles, etc.\n\nClip and the other tags should be obvious.\n\nPaste part:\nall: this is like regular paste over from a pad, but with checks to help identify where stuff breaks if the line count is different or shifted somewhere. if you're pasting over a script that has different line splitting than it should, this will show you pretty reliably where the discrepancies are.\n\ntext mod.: this pastes over text while keeping inline tags. If your line is {\\t1}a{\\t2}b{\\t3}c and you paste \"def\", you will get {\\t1}d{\\t2}e{\\t3}f. This simply counts characters, so if you paste \"defgh\", you get {\\t1}d{\\t2}e{\\t3}fgh, and if you paste \"d\", you get {\\t1}d. Comments get nuked.\n\ngbc text: this is pretty much only useful for updating lyrics when your song styling has rainbows, or any gradient by character. You get this:\n[initial tags][pasted text without last character][tag that was before last character][last character of pasted text]\n\nde-irc: paste straight from irc with timecodes and nicknames, and stuff gets parsed correctly.\n\n'Paste one line to all selected lines'\nApplies the same line, in any mode, to all selected lines. Make sure you paste only one line to the textbox."
		for key,val in ipairs(gui) do
		    if val.name=="dat" then val.value=herp
		    else val.value=res[val.name] end
		end
	end
	pressed,res=aegisub.dialog.display(gui,buttons,{close='Cancel'})
	until pressed~="Paste from clipboard" and pressed~="Help"
	CM=res.copymode	PM=res.pastemode

	if pressed=="Cancel" then aegisub.cancel() end
	if pressed=="Copy" then
	    if res.copymode=="tags" then copy(subs, sel)
	    elseif res.copymode=="text" then copyt(subs, sel)
	    elseif res.copymode=="all" then copyall(subs, sel)
	    elseif res.copymode=="export CR for pad" then crmod(subs)  crsort(subs)  crcopy(subs)
	    else copyc(subs, sel) end
	end
	if pressed=="Paste tags" then paste(subs, sel) end
	if pressed=="Paste text" then pastet(subs, sel) end
	if pressed=="Paste spec." then pastec(subs, sel) end

	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, multicopy)
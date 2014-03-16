script_name="Masquerade"
script_description="Masquerade"
script_author="unanimated"
script_version="1.6"

function addmask(subs, sel)
	for i=#sel,1,-1 do
	    local l=subs[sel[i]]
	    text=l.text
	    l1=l
	    l1.layer=l1.layer+1
	    if res.masknew then
		if res.mask=="from clip" then
		if not text:match("\\clip") then
		  aegisub.dialog.display({{class="label",label="No clip...",x=1,y=0,width=5,height=2}},{"OK"},{close='OK'}) aegisub.cancel()
		end
		l1.text=l1.text:gsub("\\clip%(([^%)]-)%)","") end
		subs.insert(sel[i]+1,l1) 
	    end
	    l.layer=l.layer-1
		
		if res.mask=="from clip" then
		  text=text:gsub("\\clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\clip(m %1 %2 l %3 %2 %3 %4 %1 %4)")
		  maskcol="\\c"..text:match("\\2c(&H%x+&)")
		  if maskcol==nil then maskcol="" end
		  if text:match("\\move") then text=text:gsub("\\move","\\pos") mp="\\move" else mp="\\pos" end
		  if text:match("\\pos") then
		    pos=text:match("\\pos(%([^%)]+%))")
		    local xx,yy=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)")
		    xx=round(xx) yy=round(yy)
		    ctext=text:match("clip%(m ([%d%a%s%-]+)")
		    ctext2=ctext:gsub("([%d%-]+)%s([%d%-]+)",function(a,b) return a-xx.." "..b-yy end)
		  else pos="\\pos(0,0)"
		  end
		  l.text="{\\an7\\blur1\\bord0\\shad0\\fscx100\\fscy100"..maskcol..mp..pos.."\\p1}m "..ctext2
		  
		else
		atags=""
		org=l.text:match("\\org%([%d%,%.%-]-%)")	if org~=nil then atags=atags..org end
		frz=l.text:match("\\frz[%d%.%-]+")	if frz~=nil then atags=atags..frz end
		frx=l.text:match("\\frx[%d%.%-]+")	if frx~=nil then atags=atags..frx end
		fry=l.text:match("\\fry[%d%.%-]+")	if fry~=nil then atags=atags..fry end
		
		l.text=l.text:gsub(".*(\\pos%([%d%,%.%-]-%)).*","%1")
		if l.text:match("\\pos")==nil then l.text="" end
		
		if res["mask"]=="square" then
		  l.text="{\\an5\\bord0\\blur1"..l.text.."\\p1}m 0 0 l 100 0 100 100 0 100"
		end
		if res["mask"]=="rounded square" then
		  l.text="{\\an7\\bord0\\blur1"..l.text.."\\p1}m -100 -25 b -100 -92 -92 -100 -25 -100 l 25 -100 b 92 -100 100 -92 100 -25 l 100 25 b 100 92 92 100 25 100 l -25 100 b -92 100 -100 92 -100 25 l -100 -25"
		end
		if res["mask"]=="circle" then
		  l.text="{\\an7\\bord0\\blur1"..l.text.."\\p1}m -100 -100 b -45 -155 45 -155 100 -100 b 155 -45 155 45 100 100 b 46 155 -45 155 -100 100 b -155 45 -155 -45 -100 -100"
		end
		if res["mask"]=="equilateral triangle" then
		  l.text="{\\an7\\bord0\\blur1"..l.text.."\\p1}m -122 70 l 122 70 l 0 -141"
		end
		if res["mask"]=="right-angled triangle" then
		  l.text="{\\an7\\bord0\\blur1"..l.text.."\\p1}m -70 50 l 180 50 l -70 -100"
		end
		if res["mask"]=="alignment grid" then
		  l.text="{\\an7\\bord0\\shad0\\blur0.6"..l.text..atags.."\\p1\\c&H000000&\\alpha&H80&}m -500 -199 l 500 -199 l 500 -201 l -500 -201 m -701 1 l 700 1 l 700 -1 l -701 -1 m -500 201 l 500 201 l 500 199 l -500 199 m -1 -500 l 1 -500 l 1 500 l -1 500 m -201 -500 l -199 -500 l -199 500 l -201 500 m 201 500 l 199 500 l 199 -500 l 201 -500 m -150 -25 l 150 -25 l 150 25 l -150 25"
		end
		if res["mask"]=="alignment grid 2" then
		  l.text="{\\an7\\bord0\\shad0\\blur0.6"..l.text..atags.."\\p1\\c&H000000&\\alpha&H80&}m -500 -199 l 500 -199 l 500 -201 l -500 -201 m -701 1 l 700 1 l 700 -1 l -701 -1 m -500 201 l 500 201 l 500 199 l -500 199 m -1 -500 l 1 -500 l 1 500 l -1 500 m -201 -500 l -199 -500 l -199 500 l -201 500 m 201 500 l 199 500 l 199 -500 l 201 -500 m -150 -25 l 150 -25 l 150 25 l -150 25 m -401 -401 l 401 -401 l 401 401 l -401 401 m -399 -399 l -399 399 l 399 399 l 399 -399"
		end
		if l.text:match("\\pos")==nil then l.text=l.text:gsub("\\p1","\\pos(640,360)\\p1") end
		end
		
	    subs[sel[i]]=l
	end
end

function add_an8(subs, sel, act)
	for z, i in ipairs(sel) do
		local line=subs[i]
		local text=subs[i].text
		if line.text:match("\\an%d") and res.an8~="q2" then
		text=text:gsub("\\(an%d)","\\"..res.an8)
		end
		if line.text:match("\\an%d")==nil and res.an8~="q2" then
		text="{\\"..res.an8.."}" .. text
		text=text:gsub("{\\(an%d)}{\\","{\\%1\\")
		end
		if res.an8=="q2" then
		    if text:match("\\q2") then text=text:gsub("\\q2","")	text=text:gsub("{}","") else
		    text="{\\q2}" .. text	text=text:gsub("{\\q2}{\\","{\\q2\\")
		    end
		end
		line.text=text
		subs[i]=line
		end
end

function koko_da(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	tekst1=text:match("^([^{]*)")
	    if res.word==false then
	--letter
		for text2 in text:gmatch("}([^{]*)") do
		text2m=text2:gsub("([%w%s%.,%?%!])","{\\ko"..res.ko.."}%1")
		text2=esc(text2)
		text=text:gsub(text2,text2m)
		end
		if tekst1~=nil then
		tekst1m=tekst1:gsub("([%w%s%.,%?%!])","{\\ko"..res.ko.."}%1")
		tekst1=esc(tekst1)
		text=text:gsub(tekst1,tekst1m)
		end
	    else
	--word
		for text2 in text:gmatch("}([^{]*)") do
		text2m=text2:gsub("([%w\']+)","{\\ko"..res.ko.."}%1")
		text2=esc(text2)
		text=text:gsub(text2,text2m)
		end
		if tekst1~=nil then
		tekst1m=tekst1:gsub("([%w\']+)","{\\ko"..res.ko.."}%1")
		tekst1=esc(tekst1)
		text=text:gsub(tekst1,tekst1m)
		end
	    end
	if text:match("^{")==nil then text=text:gsub("^","{\\ko"..res.ko.."}") end
	if not text:match("\\2a&HFF&") then text=text:gsub("^{","{\\2a&HFF&") end
	text=text:gsub("\\({\\ko[%d]+})N","\\N%1")
	text=text:gsub("\\ko[%d]+(\\ko[%d]+)","%1")
	line.text=text
        subs[i]=line
    end
end

function esc(str)
	str=str:gsub("%%","%%%%")
	str=str:gsub("%(","%%%(")
	str=str:gsub("%)","%%%)")
	str=str:gsub("%[","%%%[")
	str=str:gsub("%]","%%%]")
	str=str:gsub("%.","%%%.")
	str=str:gsub("%*","%%%*")
	str=str:gsub("%-","%%%-")
	str=str:gsub("%+","%%%+")
	str=str:gsub("%?","%%%?")
	return str
end

function strikealpha(subs, sel)
    for x, i in ipairs(sel) do
        local l=subs[i]
	l.text=l.text:gsub("\\s1","\\alpha&H00&")
	l.text=l.text:gsub("\\s0","\\alpha&HFF&")
	l.text=l.text:gsub("\\u1","\\alpha&HFF&")
	l.text=l.text:gsub("\\u0","\\alpha&H00&")
	subs[i]=l
    end
end

function scale(subs, sel)
	for z, i in ipairs(sel) do
	    local l=subs[i]
		l.text=l.text:gsub("\\fs[%d%.]-([\\}])","%1")
		l.text=l.text:gsub("\\fscx[%d%.]-([\\}])","%1")
		l.text=l.text:gsub("\\fscy[%d%.]-([\\}])","%1")
		l.text=l.text:gsub("{}","")
		l.text="{\\fs"..res.fs.."\\fscx"..res.fscxy.."\\fscy"..res.fscxy.."}"..l.text
		if res.tag=="start" then
		  l.text=l.text:gsub("^({\\[^}]-)}{\\","%1\\")
		else
		  l.text=l.text:gsub("^{(\\[^}]-)}{(\\[^}]-)}","{%2%1}")
		end
	    subs[i]=l
	end
end

function shadbord(subs, sel)
    for x, i in ipairs(sel) do
        local l=subs[i]
	styleref=stylechk(subs,l.style)
	border=styleref.outline
	shadow=styleref.shadow
	l.text=l.text:gsub("\\bord([%d%.]+)","\\xbord%1\\ybord%1")
	l.text=l.text:gsub("\\shad([%d%.%-]+)","\\xshad%1\\yshad%1")
	if not l.text:match("\\[xy]?shad") then l.text="{\\xshad"..shadow.."\\yshad"..shadow.."}"..l.text
		l.text=l.text:gsub("({\\xshad[%d%.]+\\yshad[%d%.]+)}{\\","%1\\") end
	if not l.text:match("\\[xy]?bord") then l.text="{\\xbord"..border.."\\ybord"..border.."}"..l.text
		l.text=l.text:gsub("({\\xbord[%d%.]+\\ybord[%d%.]+)}{\\","%1\\") end
	subs[i]=l
    end
end

function alfatime(subs,sel)
    -- collect / check text
    for x, i in ipairs(sel) do
	text=subs[i].text
	if x==1 then alfatext=text:gsub("^{\\[^}]-}","") end
	if x~=1 then alfatext2=text:gsub("^{\\[^}]-}","") 
	  if alfatext2~=alfatext then 
	    aegisub.dialog.display({{class="label",label="Text must be the same for all selected lines",x=0,y=0,width=1,height=2}},{"OK"})
	    aegisub.cancel()
	  end
	end
    end
    
    if not alfatext:match("@") then
	-- GUI
	dialog_config={{x=0,y=0,width=5,height=8,class="textbox",name="alfa",value=alfatext },
	{x=0,y=8,width=1,height=1,class="label",
		label="Break the text with 'Enter' the way it should be alpha-timed. (lines selected: "..#sel..")"},}
	pressed,res=aegisub.dialog.display(dialog_config,{"Alpha Text","Alpha Time","Cancel"},{ok='Alpha Text',close='Cancel'})
	if pressed=="Cancel" then aegisub.cancel() end
	data=res.alfa
    else
	data=alfatext:gsub("@","\n")
	pressed="Alpha Time"
    end
	-- sort data into a table
	altab={}	data=data.."\n"
	for a in data:gmatch("(.-)\n") do if a~="" then table.insert(altab,a) end end
	
    -- apply alpha text
    if pressed=="Alpha Text" then
      for x, i in ipairs(sel) do
        altxt=""
	for a=1,x do altxt=altxt..altab[a] end
	line=subs[i]
	text=line.text
	if altab[x]~=nil then
	  tags=text:match("^{\\[^}]-}")
	  text=text
	  :gsub("^{\\[^}]-}","")
	  :gsub(altxt,altxt.."{\\alpha&HFF&}")
	  :gsub("({\\alpha&HFF&}.-){\\alpha&HFF&}","%1")
	  :gsub("{\\alpha&HFF&}$","")
	  :gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
	  if tags~=nil then text=tags..text end
	end
	line.text=text
	subs[i]=line
      end
    end
    
    -- apply alpha etxt + split line
    if pressed=="Alpha Time" then
	line=subs[sel[1]]
	start=line.start_time
	endt=line.end_time
	dur=endt-start
	f=dur/#altab
	for a=#altab,1,-1 do
          altxt=""
	  altxt=altxt..altab[a]
	  line.text=line.text:gsub("@","")
	  line2=line
	  tags=line2.text:match("^{\\[^}]-}")
	  line2.text=line2.text
	  :gsub("^{\\[^}]-}","")
	  :gsub(altxt,altxt.."{\\alpha&HFF&}")
	  :gsub("({\\alpha&HFF&}.-){\\alpha&HFF&}","%1")
	  :gsub("{\\alpha&HFF&}$","")
	  :gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
	  if tags~=nil then line2.text=tags..line2.text end
	  line2.start_time=start+f*(a-1)
	  line2.end_time=start+f+f*(a-1)
	  subs.insert(sel[1]+1,line2)
	end
	subs.delete(sel[1])
    end
end

function addtag2(tag,text) -- mask version
	tg=tag:match("\\%d?%a+")
	text=text:gsub("^{(\\[^}]-)}","{"..tag.."%1}")
	:gsub("("..tg.."[^\\}]+)([^}]-)("..tg.."[^\\}]+)","%2%1")
	--aegisub.log("\n text "..text)
	return text 
end

function round(num)
	num=math.floor(num+0.5)
	return num
end

function stylechk(subs,stylename)
    for i=1, #subs do
        if subs[i].class=="style" then
	    local st=subs[i]
	    if stylename==st.name then
		styleref=st
		break
	    end
	end
    end
    return styleref
end

function konfig(subs, sel)
	dialog_config=
	{
	    {x=0,y=0,width=1,height=1,class="label",label="Mask:",},
	    {x=1,y=0,width=1,height=1,class="dropdown",name="mask",
		items={"from clip","square","rounded square","circle","equilateral triangle","right-angled triangle","alignment grid","alignment grid 2"},value="square"},
	    {x=0,y=1,width=2,height=1,class="checkbox",name="masknew",label="create mask on a new line",value=true},

	    {x=3,y=0,width=1,height=1,class="dropdown",name="an8",
		items={"q2","an1","an2","an3","an4","an5","an6","an7","an8","an9"},value="an8"},
		
	    {x=5,y=0,width=1,height=1,class="label",label="\\ko:",},
	    {x=6,y=0,width=1,height=1,class="floatedit",name="ko",value="8",},
	    {x=5,y=1,width=2,height=1,class="checkbox",name="word",label="word by word",value=false},
	    
	    {x=7,y=0,width=1,height=2,class="label",label=":\n:\n:",},
	    
	    {x=8,y=0,width=1,height=1,class="label",label="scaling",},
	    {x=9,y=0,width=1,height=1,class="label",label="\\fs:",},
	    {x=10,y=0,width=1,height=1,class="dropdown",name="fs",items={"1","2","3","4","5","6","7","8","9","10"},value="2"},
	    {x=11,y=0,width=1,height=1,class="dropdown",name="tag",items={"start","end"},value="start"},
	    {x=8,y=1,width=1,height=1,class="label",label="\\fscx/y:",},
	    {x=9,y=1,width=3,height=1,class="floatedit",name="fscxy",value="2000"},
	    
	    {x=2,y=0,width=1,height=2,class="label",label=":\n:\n:",},
	    {x=4,y=0,width=1,height=2,class="label",label=":\n:\n:",},
	} 	
	pressed, res=aegisub.dialog.display(dialog_config,
	{"create mask","strikealpha","an8 / q2","\\ko","alpha time","mocha scale","xybordshad","cancel"},{cancel='cancel'})
	if pressed=="cancel" then aegisub.cancel() end
	if pressed=="create mask" then addmask(subs, sel) end
	if pressed=="strikealpha" then strikealpha(subs, sel) end
	if pressed=="an8 / q2" then add_an8(subs, sel) end
	if pressed=="\\ko" then koko_da(subs, sel) end
	if pressed=="alpha time" then alfatime(subs, sel) end	
	if pressed=="mocha scale" then scale(subs, sel) end
	if pressed=="xybordshad" then shadbord(subs, sel) end
end

function masquerade(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, masquerade)
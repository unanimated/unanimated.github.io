script_name = "Masquerade"
script_description = "Masquerade"
script_author = "unanimated"
script_version = "1.43"

function addmask(subs, sel)
	for i=#sel,1,-1 do
	    local l = subs[sel[i]]
	    text=l.text
	    l1=l
	    l1.layer=l1.layer+1
	    if res.masknew then subs.insert(sel[i]+1,l1) end
	    l.layer=l.layer-1
	    
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
		
	    subs[sel[i]] = l
	end
end

function add_an8(subs, sel, act)
	for z, i in ipairs(sel) do
		local line = subs[i]
		local text = subs[i].text
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
		line.text = text
		subs[i] = line
		end
end

function koko_da(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	tekst1 = text:match("^([^{]*)")
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
	line.text = text
        subs[i] = line
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
	    local l = subs[i]
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
	    subs[i] = l
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

function stylechk(subs,stylename)
    for i=1, #subs do
        if subs[i].class=="style" then
	    local st=subs[i]
	    if stylename==st.name then
		styleref=st	    
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
		items={"square","rounded square","circle","equilateral triangle","right-angled triangle","alignment grid","alignment grid 2"},value="square"},
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
	pressed, res = aegisub.dialog.display(dialog_config,
	{"Create Mask","strikealpha","an8 / q2","\\ko","mocha scaling","xybordshad","cancel"},{cancel='cancel'})
	if pressed=="cancel" then aegisub.cancel() end
	if pressed=="Create Mask" then addmask(subs, sel) end
	if pressed=="strikealpha" then strikealpha(subs, sel) end
	if pressed=="an8 / q2" then add_an8(subs, sel) end
	if pressed=="\\ko" then koko_da(subs, sel) end
	if pressed=="mocha scaling" then scale(subs, sel) end
	if pressed=="xybordshad" then shadbord(subs, sel) end
end

function masquerade(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, masquerade)
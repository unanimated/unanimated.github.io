script_name = "Masquerade"
script_description = "Masquerade"
script_author = "unanimated"
script_version = "1.2"

include("karaskel.lua")

function addmask(subs, sel)
	for i=#sel,1,-1 do
	    local l = subs[sel[i]]
	    text=l.text
	    l1=l
	    l1.layer=l1.layer+1
	    if res.masknew then subs.insert(sel[i]+1,l1) end
	    l.layer=l.layer-1
	    
		l.text=l.text:gsub(".*(\\pos%([%d%,%.]-%)).*","%1")
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
		text2=escape_string(text2)
		text=text:gsub(text2,text2m)
		end
		if tekst1~=nil then
		tekst1m=tekst1:gsub("([%w%s%.,%?%!])","{\\ko"..res.ko.."}%1")
		tekst1=escape_string(tekst1)
		text=text:gsub(tekst1,tekst1m)
		end
	    else
	--word
		for text2 in text:gmatch("}([^{]*)") do
		text2m=text2:gsub("([%w\']+)","{\\ko"..res.ko.."}%1")
		text2=escape_string(text2)
		text=text:gsub(text2,text2m)
		end
		if tekst1~=nil then
		tekst1m=tekst1:gsub("([%w\']+)","{\\ko"..res.ko.."}%1")
		tekst1=escape_string(tekst1)
		text=text:gsub(tekst1,tekst1m)
		end
	    end
	if text:match("^{")==nil then text=text:gsub("^","{\\ko"..res.ko.."}") end
	text=text:gsub("^{","{\\2a&HFF&")
	text=text:gsub("\\({\\ko[%d]+})N","\\N%1")
	text=text:gsub("\\ko[%d]+(\\ko[%d]+)","%1")
	line.text = text
        subs[i] = line
    end
end

function escape_string(str)
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

function shadbord(subs, sel)
local meta,styles=karaskel.collect_head(subs,false)
    for x, i in ipairs(sel) do
        local l=subs[i]
	karaskel.preproc_line(subs,meta,styles,l)
	border=l.styleref.outline
	shadow=l.styleref.shadow
	l.text=l.text:gsub("\\bord([%d%.]+)","\\xbord%1\\ybord%1")
	l.text=l.text:gsub("\\shad([%d%.%-]+)","\\xshad%1\\yshad%1")
	if not l.text:match("\\[xy]?shad") then l.text="{\\xshad"..shadow.."\\yshad"..shadow.."}"..l.text
		l.text=l.text:gsub("({\\xshad[%d%.]+\\yshad[%d%.]+)}{\\","%1\\") end
	if not l.text:match("\\[xy]?bord") then l.text="{\\xbord"..border.."\\ybord"..border.."}"..l.text
		l.text=l.text:gsub("({\\xbord[%d%.]+\\ybord[%d%.]+)}{\\","%1\\") end
	subs[i]=l
    end
end

function konfig(subs, sel)
	dialog_config=
	{
	    {x=0,y=0,width=1,height=1,class="label",label="MASK:",},
	    {x=1,y=0,width=1,height=1,class="dropdown",name="mask",
		items={"square","rounded square","circle","equilateral triangle","right-angled triangle"},value="square"},
	    {x=0,y=1,width=2,height=1,class="checkbox",name="masknew",label="create mask on a new line",value=true},

	    {x=3,y=0,width=1,height=1,class="dropdown",name="an8",
		items={"q2","an1","an2","an3","an4","an5","an6","an7","an8","an9"},value="an8"},
		
	    {x=5,y=0,width=1,height=1,class="label",label="\\ko:",},
	    {x=6,y=0,width=1,height=1,class="floatedit",name="ko",value="8",},
	    {x=7,y=0,width=2,height=1,class="checkbox",name="word",label="word by word",value=false},
	    
	    {x=2,y=0,width=1,height=1,class="label",label="~",},
	    {x=4,y=0,width=1,height=1,class="label",label="~",},
	    {x=0,y=1,width=1,height=1,class="label",label="",},
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,{"Create Mask","strikealpha","an8 / q2","\\ko","xybordshad","cancel"})
	if pressed=="cancel" then aegisub.cancel() end
	if pressed=="Create Mask" then addmask(subs, sel) end
	if pressed=="strikealpha" then strikealpha(subs, sel) end
	if pressed=="an8 / q2" then add_an8(subs, sel) end
	if pressed=="\\ko" then koko_da(subs, sel) end
	if pressed=="xybordshad" then shadbord(subs, sel) end
end

function masquerade(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, masquerade)
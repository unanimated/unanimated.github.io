--[[
	Aladin's Lamp
	
	Description:
	
	This script tries to solve 4 problems when dealing with Arabic text in Aegisub.
	1. Inline tags that mess up the order of the text
	2. Line breaks that mess up the order of the text when there are inline tags
	3. Punctuation that ends up on the wrong end of the line
	4. English text that messes up the order of Arabic text
	
	1 - Inline tags - 
	{tags1}text1{tags2}text2{tags3}text3
	The script sorts the line in 3-2-1 order and fills in tags as required, including getting values from styles.
	You should be able to input any number of inline tags, run the script, and get back the correct sentence order.
	You must set all tags first and then run the script, not after each tag!
	Running the script twice should revert the line to the original state.
	So if you want to add another tag to an already fixed line, run the script (this will revert the order),
	add the new tag(s), and run the script again.
	
	2 - Line breaks -
	The script switches the top and bottom parts of the line and sorts out the tags.
	This doesn't use styles, so if some tags like colours are only defined for the part after the line break,
	you should set them for the first part as well (though you can do it just as easily after).
	It may or may not work correctly with transforms.
	
	3 - Fix punctuation -
	This moves a punctuation mark from the right end of the line to the left, or if there's a line break, after the line break.
	This way the punctuation -should- always end up at the end of the sentence.
	
	4 - English Text -
	If you put English text in the middle of Arabic text, the order of the parts before and after it gets switched.
	This should, again, switch the parts back correctly.
	This detects only ordinary Latin characters and won't work with things like "ä".
	
	Regarding editing issues, Multi-Line Editor might work better than Aegisub's Edit Box,
	since the lua interface seems to have some right-to-left support. http://unanimated.xtreemhost.com/ts/multiedit.lua
	
	Note: I don't know any Arabic, so this may have any number of bugs I'm not aware of.
	Working with right-to-left text that I don't understand is rather confusing.

--]]

script_name="Aladin's Lamp"
script_description="Attempts to deal with Arabic text"
script_author="unanimated"
script_version="1.1"

function fixnline(subs,sel)
styleget(subs)
    for z,i in ipairs(sel) do
	line=subs[i]
	text=line.text
	sr=stylechk(line.style)
	if text:match(".{%*?\\") then text=rvrs(text) end
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

stags={"\\fsize","\\fscx","\\fscy","\\fsp","\\1c","\\2c","\\3c","\\4c","\\1a","\\2a","\\3a","\\4a","\\bord","\\shad","\\bold","\\ita","\\u","\\str","\\frz","\\fn"}
sty={"fontsize","scale_x","scale_y","spacing","color1","color2","color3","color4","color1","color2","color3","color4","outline","shadow","bold","italic","underline","strikeout","angle","fontname"}
mtags={"\\blur","\\be","\\frx","\\fry","\\fax","\\fay","\\xbord","\\xshad","\\ybord","\\yshad","\\alpha"}

function rvrs(text)
	txtab={}
	text=text:gsub("\\t%b()",function(t) return t:gsub("\\","|") end)
	:gsub("\\fs(%d)","\\fsize%1"):gsub("\\c&","\\1c&"):gsub("\\b(%d)","\\bold%1"):gsub("\\i(%d)","\\ita%1"):gsub("\\s(%d)","\\str%1")
	:gsub("( +)({\\[^}]-})","%2%1")
	tags=text:match("^{\\[^}]-}") or ""
	if not text:match("^{\\[^}]-}") then text="{\\tags} "..text else text=text:gsub("^{\\[^}]-}","{\\tags} ") end
	punct=text:match("{\\tags} ([%.,%?!:;—])") or text:match("{\\tags} (—)") or text:match("{\\tags} (،)") or ""
	text=text:gsub("({\\tags} )"..punct,"%1")
	intags=""
	for tg in text:gmatch(".{(\\[^}]-)}") do
		intags=intags..tg
	end
	for s=1,#stags do
		tag=stags[s]
		if intags:match(tag) then
			if tags:match(tag) then styletag=tags:match(tag.."[^\\}]+")
			else
				styletag=sr[sty[s]]
				if tag:match("\\%dc") then styletag=styletag:gsub("H%x%x","H") end
				if tag:match("\\%da") then styletag=styletag:match("H%x%x") end
				if styletag==true then styletag=1 end
				if styletag==false then styletag=0 end
				styletag=tag..styletag
			end
			text=addtag(styletag,text)
		end
	end
	for m=1,#mtags do
		tag=mtags[m]
		if intags:match(tag) then
			if tags:match(tag) then styletag=tags:match(tag.."[^\\}]+")
			else
				styletag="0"
				if tag:match("\\alpha") then styletag="&H00&" end
				styletag=tag..styletag
			end
			text=addtag(styletag,text)
		end
	end
	for g,x in text:gmatch("({\\[^}]-})([^{]+)") do
		table.insert(txtab,g..x)
	end
	nt=""
	for t=#txtab,1,-1 do
		nt=nt..txtab[t]
	end
	nt=tags..nt
	nt=nt:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
	:gsub("\\tags",""):gsub("\\fsize","\\fs"):gsub("\\1c","\\c"):gsub("\\bold","\\b"):gsub("\\ita","\\i"):gsub("\\str","\\s"):gsub(" *$","")
	:gsub("({%*?\\[^}]-})",function(tg) return duplikill(tg) end)
	:gsub("^({\\[^}]-}) +","%1")
	:gsub("^({\\[^}]-})","%1"..punct)
	:gsub("|t%b()",function(t) return t:gsub("|","\\") end)
	return nt
end

function fixbreak(subs,sel)
styleget(subs)
    for z,i in ipairs(sel) do
	line=subs[i]
	text=line.text
	sr=stylechk(line.style)
	if text:match("\\N") and text:match(".{\\") then
		text=text:gsub("\\t(%b())",function(t) return "\\t"..t:gsub("\\","/") end)
		tags=text:match("^{\\[^}]-}") or ""
		text=text:gsub("({\\[^}]-}) *\\N","\\N%1") :gsub("({\\[^}]-}) *([^{]+%S)%s*\\N *([^{]+)","%1 %2\\N%1 %3")
		T1,T2=text:match("^(.-)\\N(.*)$")
		T1=T1:gsub("\\%a%a+%b()",""):gsub("\\an%d",""):gsub("{}","")
		tagsT1=T1:match("^{\\[^}]-}") or ""
		for tg in tagsT1:gmatch("(\\%a+)[%d%.%-]+") do
			if not T2:match(tg) then tagsT1=tagsT1:gsub(tg.."[%d%.%-]+","") end
		end
		for tg in tagsT1:gmatch("(\\%d?%a+)&H%x+&") do
			if not T2:match(tg) then tagsT1=tagsT1:gsub(tg.."&H%x+&","") end
		end
		T1=T1:gsub("^{\\[^}]-}","")
		tagsT1=tagsT1:gsub("{}","")
		T1=tagsT1..T1
		text=tags..T2.."\\N"..T1
		
		text=text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
		:gsub("({%*?\\[^}]-})",function(tg) return duplikill(tg) end)
		:gsub("\\t%b()",function(t) return t:gsub("/","\\") end)
	end
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function fixeng(subs,sel)
    for z,i in ipairs(sel) do
	line=subs[i]
	text=line.text
	:gsub("^([^{]*)",function(t) return engswitch(t) end)
	:gsub("}([^{]*)",function(t) return "}"..engswitch(t) end)
	:gsub("^({\\[^}]-}) ","%1")
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function engswitch(t)
	ttab={}
	sp,efirst=t:match("^( ?)(%a[%w%s]+%a)")
	if efirst then table.insert(ttab,efirst) t=t:gsub("^ ?%a[%w%s]+%a","") end
	for ar,en in t:gmatch(" ?(.-) (%a[%w%s]+%a)") do
		ar=ar:gsub("(.*)%.%.%.","...%1"):gsub("(.*)([%.,%?!:;])","%2%1"):gsub("(.*)،","،%1")
		table.insert(ttab,ar)
		table.insert(ttab,en)
	end
	alast=t:match(".*%a[%w%s]+%a (%A-)$")
	if alast then
		alast=alast:gsub("(.*)%.%.%.","...%1"):gsub("(.*)([%.,%?!:;])","%2%1"):gsub("(.*)،","،%1")
		table.insert(ttab,alast)
	end
	if #ttab==0 then return t end
	nt=""
	for a=1,#ttab do nt=" "..ttab[a]..nt end
	t=nt
	return t
end

tags1={"blur","be","bord","shad","xbord","xshad","ybord","yshad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay"}
tags2={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}
tags3={"pos","move","org","fad"}

function duplikill(tagz)
	tagz=tagz:gsub("\\t%b()",function(t) return t:gsub("\\","|") end)
	for i=1,#tags1 do
	    tag=tags1[i]
	    repeat tagz,c=tagz:gsub("|"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%2%1") until c==0
	    repeat tagz,c=tagz:gsub("\\"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%2%1") until c==0
	end
	tagz=tagz:gsub("\\1c&","\\c&")
	for i=1,#tags2 do
	    tag=tags2[i]
	    repeat tagz,c=tagz:gsub("|"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%2%1") until c==0
	    repeat tagz,c=tagz:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%2%1") until c==0
	end
	repeat tagz,c=tagz:gsub("\\fn[^\\}]+([^}]-)(\\fn[^\\}]+)","%2%1") until c==0
	repeat tagz,c=tagz:gsub("(\\i?clip%b())(.-)(\\i?clip%b())",
	  function(a,b,c) if a:match("m") and c:match("m") or not a:match("m") and not c:match("m") then
	  return b..c else return a..b..c end end) until c==0
	tagz=tagz:gsub("|","\\"):gsub("\\t%([^\\/%)]-%)","")
	return tagz
end


function styleget(subs)
    styles={}
    for i=1,#subs do
        if subs[i].class=="style" then
	    table.insert(styles,subs[i])
	end
	if subs[i].class=="dialogue" then break end
    end
end

function stylechk(stylename)
    for i=1,#styles do
	if stylename==styles[i].name then
	    styleref=styles[i]
	    if styles[i].name=="Default" then defaref=styles[i] end
	    break
	end
    end
    return styleref
end

function addtag(tag,text) text=text:gsub("^({\\[^}]-)}","%1"..tag.."}") return text end
function logg(m) aegisub.log("\n "..m) end

function fixpunct(subs,sel)
    for z,i in ipairs(sel) do
	line=subs[i]
	text=line.text
	tags=text:match("^{\\[^}]-}") or ""
	text=text:gsub("^{\\[^}]-}","")
	:gsub("^(.*)(%.%.%.)$","%2%1") :gsub("^(%.%.%.)(.-)\\N","%2\\N%1")
	:gsub("^(.*)([%.,%?!:;])$","%2%1") :gsub("^([%.,%?!:;])(.-)\\N","%2\\N%1")
	:gsub("^(.*)—$","—%1") :gsub("^—(.-)\\N","%1\\N—")
	:gsub("^(.*)،$","،%1") :gsub("^،(.-)\\N","%1\\N،")
	text=tags..text
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro("Aladin's Lamp/Make Djinn fix inline tags",script_description,fixnline)
aegisub.register_macro("Aladin's Lamp/Make Djinn fix line breaks",script_description,fixbreak)
aegisub.register_macro("Aladin's Lamp/Make Djinn fix punctuation",script_description,fixpunct)
aegisub.register_macro("Aladin's Lamp/Make Djinn fix English text",script_description,fixeng)
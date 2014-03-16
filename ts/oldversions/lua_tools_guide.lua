-- add tag to the end of the initial block of tags	tag should be backslash+type+value, eg "\\blur0.6"
-- use:   text=addtag("\\blur0.6",text)

function addtag(tag,text) text=text:gsub("^({\\[^}]-)}","%1"..tag.."}") return text end


-- escape string for use in gsub (by lyger)	use:   string=esc(string)

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


-- select all lines	useful when you want the "selected lines/all lines" option
-- use it something like this:	if res.selection=="all" then sel=selectall(subs, sel) mainfunction(subs, sel) end

function selectall(subs, sel)
sel={}
    for i = 1, #subs do
	if subs[i].class=="dialogue" then table.insert(sel,i) end
    end
    return sel
end


-- round a number	
-- use:   number=round(number)

function round(num)
	num=math.floor(num+0.5)
	return num
end


-- flip text	rot can be "frz" "frx" "fry"	
-- use:   text=flip("frz",text)

function flip(rot,text)
    for rotation in text:gmatch("\\"..rot.."([%d%.%-]+)") do
	rotation=tonumber(rotation)
	if rotation<180 then newrot=rotation+180 end
	if rotation>180 then newrot=rotation-180 end
	text=text:gsub(rot..rotation,rot..newrot)
    end
    return text
end


-- clean transforms
-- use:   text=text:gsub("^({\\[^}]-})",function(tags) return cleantr(tags) end)
-- (the longer ones with more %( %) are for transforms with clips)

function cleantr(tags)
	-- this puts transforms at the end of the block of tags
	trnsfrm=""
	for t in tags:gmatch("(\\t%([^%(%)]-%))") do trnsfrm=trnsfrm..t end
	for t in tags:gmatch("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))") do trnsfrm=trnsfrm..t end
	tags=tags:gsub("(\\t%([^%(%)]+%))","")
	tags=tags:gsub("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","")
	tags=tags:gsub("^({\\[^}]*)}","%1"..trnsfrm.."}")

	-- this joins transforms with no timecodes together into one - \t(\bord5)\t(\shad5)  -->  \t(\bord5\shad5)
	cleant=""
	for ct in tags:gmatch("\\t%((\\[^%(%)]-)%)") do cleant=cleant..ct end
	for ct in tags:gmatch("\\t%((\\[^%(%)]-%([^%)]-%)[^%)]-)%)") do cleant=cleant..ct end
	tags=tags:gsub("(\\t%(\\[^%(%)]+%))","")
	tags=tags:gsub("(\\t%(\\[^%(%)]-%([^%)]-%)[^%)]-%))","")
	if cleant~="" then tags=tags:gsub("^({\\[^}]*)}","%1\\t("..cleant..")}") end
	return tags
end


-- clean duplicate tags		
-- use:   text=duplikill(text)	
-- don't use with \t !
		
function duplikill(text)
	tags1={"blur","be","bord","shad","xbord","xshad","ybord","yshad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay"}
	for i=1,#tags1 do
	    tag=tags1[i]
	    text=text:gsub("\\"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%1%2")
	end
	text=text:gsub("\\1c&","\\c&")
	tags2={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}
	for i=1,#tags2 do
	    tag=tags2[i]
	    text=text:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%1%2")
	end
	--text=text:gsub("\\i?clip%([^%)]-%)([^}]-)(\\i?clip%([^%)]-%))","%1%2")	-- depending whether you wanna allow 2 clips on a line
	return text
end

-- this works with \t, but has to be used on tags, not text (and requires esc)
	--[[ use:
	    for tagz in text:gmatch("{\\[^}]-}") do
  	      tagz2=duplikill(tagz)
	      tagz=esc(tagz)
	      text=text:gsub(tagz,tagz2)
	    end
	--]]
	
function duplikill(tagz)
	tf=""
	if tagz:match("\\t") then 
	    for t in tagz:gmatch("(\\t%([^%(%)]-%))") do tf=tf..t end
	    for t in tagz:gmatch("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","") do tf=tf..t end
	    tagz=tagz:gsub("\\t%([^%(%)]+%)","")
	    tagz=tagz:gsub("\\t%([^%(%)]-%([^%)]-%)[^%)]-%)","")
	end
	tags1={"blur","be","bord","shad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay"}
	for i=1,#tags1 do
	    tag=tags1[i]
	    tagz=tagz:gsub("\\"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%1%2")
	end
	tagz=tagz:gsub("\\1c&","\\c&")
	tags2={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}
	for i=1,#tags2 do
	    tag=tags2[i]
	    tagz=tagz:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%1%2")
	end	
	tagz=tagz:gsub("({\\[^}]-)}","%1"..tf.."}")
	return tagz
end


-- convert a "Dialogue: 0,0:00..." string to a "line" table	(uses string2time below)

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


-- convert a line to a "Dialogue: 0,0:00..." string	(uses time2string below)	(apparently useless because: line.raw)

function line2string(lain)
	if lain.comment==false then ltype="Dialogue: " else ltype="Comment: " end
	layer=lain.layer..","
	s_time=lain.start_time
	e_time=lain.end_time
	s_time=time2string(s_time)
	e_time=time2string(e_time)
	style=lain.style..","
	actor=lain.actor..","
	margl=lain.margin_l..","
	margr=lain.margin_r..","
	margv=lain.margin_t..","
	effect=lain.effect..","
	txt=lain.text
	linetext=ltype..layer..s_time..","..e_time..","..style..actor..margl..margr..margv..effect..txt
	return linetext
end


-- convert string timecode to time in ms (and vice versa)

function string2time(timecode)
	timecode=timecode:gsub("(%d):(%d%d):(%d%d)%.(%d%d)",function(a,b,c,d) return d*10+c*1000+b*60000+a*3600000 end)
	return timecode
end

function time2string(num)
	timecode=math.floor(num/1000)
	tc0=math.floor(timecode/3600)
	tc1=math.floor(timecode/60)
	tc2=timecode%60+1
	numstr="00"..num
	tc3=numstr:match("(%d%d)%d$")
	if tc1==60 then tc1=0 tc0=tc0+1 end
	if tc2==60 then tc2=0 tc1=tc1+1 end
	if tc1<10 then tc1="0"..tc1 end
	if tc2<10 then tc2="0"..tc2 end
	tc0=tostring(tc0)
	tc1=tostring(tc1)
	tc2=tostring(tc2)
	timestring=tc0..":"..tc1..":"..tc2.."."..tc3
	return timestring
end


-- check style values (instead of using karaskel)	
-- use: styleref=stylechk(subs,line.style)

function stylechk(subs,stylename)
  for i=1, #subs do
    if subs[i].class=="style" then
      local st=subs[i]
      if stylename==st.name then styleref=st end
    end
  end
  return styleref
end


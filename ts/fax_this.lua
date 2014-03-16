script_name="Copyfax This"
script_description="Copyfax This"
script_author="unanimated"
script_version="2.22"

-- all the "copy" things copy things from first selected line and paste them to the other lines
-- clip shift coordinates will shift the clip by that amount each line

--[[

	Fax It
		Adds a \fax tag. "to the right" just adds a "-". (Yes, that's pretty useless.)
		"from clip" calculates the fax value from the first two points of a vector clip.
	
	Copy Stuff
		This lets you copy almost anything from one line to others.
		The primary use is to copy from the first line of your selection to the others.
		If you need to copy to a line that's above the source like in the grid, just click Copy with the selected things
		and then use Paste Saved on the line(s) you want to copy to.
		You can copy inline tags too, but they will only be pasted to the first tag block.
	
	Copy Tags
		Copies the first block of tags in its entirety from first selected line to the others.
	
	Copy Text
		Copies what's after the first block of tags from first selected line to the others (including inline tags).
	
	Copy Clip
		Copies clip from first selected line to the others.
		Clip shift coordinates will shift the clip by that amount each line.
	
	Copy Colours
		Copies checked colours from first selected line to the others.
		Unlike Copy Stuff, this can read the colours from the style when tags are missing.
		You can also include alpha for the checked colours.
	
	Split by \N
		Splits a line at each linebreak.
		If there's no linebreak, you can split by tags or spaces.
		Splitting by linebreak will try to keep the position of each part, but it only supports \fs, \fscy, and \an.

--]]

copy_style=true

function fucks(subs, sel)
	if res.right then res.fax=0-res.fax end
	for z, i in ipairs(sel) do
	    local l=subs[i]
	    local t=l.text
	    if not res.clax then
		t=t:gsub("^({[^}]-\\fax)[%d%.%-]+","%1"..res.fax)
		if not t:match("^{[^}]-\\fax") then 
		t="{\\fax"..res.fax.."}"..t
		t=t:gsub("^({\\[^}]-)}{\\","%1\\")
		end
	    else
		if not t:match("\\clip") then
		  aegisub.dialog.display({{class="label",label="Missing \\clip.",width=1,height=2}},{"OK"},{close='OK'}) aegisub.cancel()
		end
		cx1,cy1,cx2,cy2=t:match("\\clip%(m ([%d%-]+) ([%d%-]+) l ([%d%-]+) ([%d%-]+)")
		rota=t:match("\\frz([%d%.%-]+)")
		if rota==nil then rota=0 end
		ad=cx1-cx2
		op=cy1-cy2
		tang=(ad/op)
		ang1=math.deg(math.atan(tang))
		ang2=ang1-rota
		tangf=math.tan(math.rad(ang2))
		
		faks=round(tangf*100)/100
		t=addtag("\\fax"..faks,t)
		t=t:gsub("\\clip%([^%)]+%)","")
		t=duplikill(t)
	    end	
	    l.text=t
	    subs[i]=l
	end
end

function round(num)  num=math.floor(num+0.5)  return num  end

function copystuff(subs, sel)
    -- get stuff from line 1
    rine=subs[sel[1]]
    ftags=rine.text:match("^{(\\[^}]-)}")
    cstext=rine.text:gsub("^{(\\[^}]-)}","")
    csstyle=rine.style
    csst=rine.start_time
    cset=rine.end_time
    if ftags==nil then ftags="" end
    -- detect / save / remove transforms
    ftra1="" ftra2=""
    if ftags:match("\\t") then
	for t in ftags:gmatch("(\\t%([^%(%)]-%))") do ftra1=ftra1..t end
	ftags=ftags:gsub("\\t%([^%(%)]+%)","")
	for t in ftags:gmatch("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))") do ftra2=ftra2..t end
	ftags=ftags:gsub("\\t%([^%(%)]-%([^%)]-%)[^%)]-%)","")
    end
    rept={"drept"}
    -- build GUI
    copyshit={
	{x=0,y=0,width=1,height=1,class="checkbox",name="chks",label="[   Start Time   ]   ",value=false},
	{x=0,y=1,width=1,height=1,class="checkbox",name="chke",label="[   End Tim   ]",value=false},
	{x=1,y=0,width=1,height=1,class="checkbox",name="css",label="[   Style   ]   ",value=false},
	{x=1,y=1,width=1,height=1,class="checkbox",name="tkst",label="[   Text   ]",value=false},
	    }
    ftw=2
    -- regular tags -> GUI
    for f in ftags:gmatch("\\[^\\]+") do lab=f
	if f:match("\\i?clip%(m") then lab=f:match("\\i?clip%(m [%d%.%-]+ [%d%.%-]+ %a [%d%.%-]+ [%d%.%-]+ ").."..." end
	if f:match("\\move") then lab=f:gsub("%.%d+","") end
	  cb={x=0,y=ftw,width=2,height=1,class="checkbox",name="chk"..ftw,label=lab,value=false,realname=f}
	  drept=0 for r=1,#rept do if f==rept[r] then drept=1 end end
	  if drept==0 then
	  table.insert(copyshit,cb)	ftw=ftw+1
	  table.insert(rept,f)
	  end
    end
    -- transform tags
    for f in ftra1:gmatch("\\t%([^%(%)]-%)") do
	cb={x=0,y=ftw,width=2,height=1,class="checkbox",name="chk"..ftw,label=f,value=false}
	  drept=0 for r=1,#rept do if f==rept[r] then drept=1 end end
	  if drept==0 then
	  table.insert(copyshit,cb)	ftw=ftw+1
	  table.insert(rept,f)
	  end
    end
    -- transform with clip
    for f in ftra2:gmatch("\\t%([^%(%)]-%([^%)]-%)[^%)]-%)") do
	cb={x=0,y=ftw,width=2,height=1,class="checkbox",name="chk"..ftw,label=f,value=false}
	table.insert(copyshit,cb)	ftw=ftw+1
    end
    itw=2
    -- inline tags
    if cstext:match("{[^}]-\\[^Ntrk]") then
      cb={x=2,y=0,width=1,height=2,class="label",label="inline tags...\n(will only be added to first block)"} table.insert(copyshit,cb)
      for f in cstext:gmatch("\\[^tNhrk][^\\}%)]+") do lab=f
	if itw==22 then lab="(that's enough...)" f="" end
	if itw==23 then break end
	  cb={x=2,y=itw,width=1,height=1,class="checkbox",name="chk2"..itw,label=lab,value=false,realname=f}
	  drept=0 for r=1,#rept do if f==rept[r] then drept=1 end end
	  if drept==0 then
	  table.insert(copyshit,cb)	itw=itw+1
	  table.insert(rept,f)
	  end
      end
    end
	repeat
	    if press=="Check All Tags" then
		for key,val in ipairs(copyshit) do
		    if val.class=="checkbox" and not val.label:match("%[ ") and val.x==0 then val.value=true end
		end
	    end
	press,rez=aegisub.dialog.display(copyshit,{"Copy","Check All Tags","Paste Saved","Cancel"},{ok='Copy',close='Cancel'})
	until press~="Check All Tags"
	if press=="Cancel" then aegisub.cancel() end
	-- save checked tags
	kopytags=""
	copytfs=""
	for key,val in ipairs(copyshit) do
	    if rez[val.name]==true and not val.label:match("%[ ") then 
		if not val.label:match("\\t") then kopytags=kopytags..val.realname else copytfs=copytfs..val.label end
	    end
	end
	if press=="Paste Saved" then kopytags=savedkopytags copytfs=savedcopytfs sn=1
	csstyle=savedstyle csst=savedt1 cset=savedt2 cstext=savedtext
	rez.css=savedcss rez.chks=savedchks rez.chke=savedchke rez.tkst=savedtkst
	else sn=2 
	savedkopytags=kopytags
	savedcopytfs=copytfs
	savedt1=csst savedt2=cset savedstyle=csstyle
	savedcss=rez.css savedchks=rez.chks savedchke=rez.chke
	savedtext=cstext savedtkst=rez.tkst
	end

    -- lines 2+
    for i=sn,#sel do
        local line=subs[sel[i]]
        local text=subs[sel[i]].text
	text=text:gsub("\\1c","\\c")

	    if not text:match("^{\\") then text="{\\stuff}"..text end
	    ctags=text:match("^{\\[^}]-}")
	    -- handle existing transforms
	    if ctags:match("\\t") then
		ctags=trem(ctags)
		if text:match("^{}") then text=text:gsub("^{}","{\\stuff}") end
		text=text:gsub("^{\\[^}]-}",ctags)
		trnsfrm=trnsfrm..copytfs
	    elseif copytfs~="" then trnsfrm=copytfs
	    end
	    -- add + clean tags
	    text=text:gsub("^({\\[^}]-)}","%1"..kopytags.."}")
	    text=duplikill(text)
	    text=extrakill(text)
	    -- add transforms
	    if trnsfrm~=nil then text=text:gsub("^({\\[^}]*)}","%1"..trnsfrm.."}") end
	    trnsfrm=nil
	    text=text:gsub("^({\\[^}]-})",function(tags) return cleantr(tags) end)
	    text=text:gsub("\\stuff","") :gsub("{}","")
	
	if rez.css then line.style=csstyle end
	if rez.chks then line.start_time=csst end
	if rez.chke then line.end_time=cset end
	if rez.tkst then text=text:gsub("^({\\[^}]-}).*","%1"..cstext) end
	line.text=text
	subs[sel[i]]=line
    end
    trnsfrm=nil
end

function copytags(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	    if x==1  then
	      tags=text:match("^({\\[^}]*})")
	      if res.cpstyle then style=line.style end
	    end
	    if x~=1 then
	      if text:match("^({\\[^}]*})") then
	      text=text:gsub("^{\\[^}]*}",tags) else
	      text=tags..text
	      end
	      if res.cpstyle then line.style=style end
	    end
	    line.text=text
	    subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function copytext(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	    if x==1  then
	      tekst=text:gsub("^{\\[^}]*}","")
	    end
	    if x~=1 then
	      if text:match("^{\\[^}]*}") then
	      text=text:gsub("^({\\[^}]*}).*","%1"..tekst) else
	      text=tekst
	      end
	    end
	    line.text=text
	    subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function copyclip(subs, sel)
	xc=res.xlip
	yc=res.ylip
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	    if x==1  then
	      if text:match("\\i?clip") then -- read clip
	      klipstart=text:match("\\i?clip%(([^%)]+)%)")
	      klip=klipstart
	      end
	    end
	    
	    if x~=1 then
	      if not text:match("^{\\") then text="{\\}"..text end
	      if not text:match("\\i?clip") then text=addtag("\\clip()",text) end
	      
		-- calculations
		if xc~=0 and yc~=0 then factor=x-1
		    klip=klipstart:gsub("([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",
		    function(a,b,c,d) return a+xc*factor.. "," ..b+yc*factor.. "," ..c+xc*factor.. "," ..d+yc*factor end)
		    
		    if klipstart:match("m [%d%a%s%-]+") then
		    klip=klipstart:match("m ([%d%a%s%-]+)")
		    klip2=klip:gsub("([%d%-]+)%s([%d%-]+)",function(a,b) return a+xc*factor.." "..b+yc*factor end)
		    klip=klip:gsub("%-","%%-")
		    klip=klip:gsub(klip,klip2)
		    klip="m "..klip
		    end
		end
	      -- set clip
	      text=text:gsub("(\\i?clip)%([^%)]-%)","%1("..klip..")")
	      text=text:gsub("\\\\","\\")
	    end
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function copycolours(subs, sel)
if not res.c1 and not res.c2 and not res.c3 and not res.c4 then aegisub.cancel() end
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	styleref=stylechk(subs,line.style)
	sr=styleref
	text=text:gsub("\\1c","\\c")
	
	    -- copy from line 1
	    if x==1  then
	      if res.c1 then
	        if text:match("\\c&") then col1=text:match("\\c(&H%x+&)") else col1=sr.color1:gsub("H%x%x","H") end
	        if text:match("\\1a&") then alf1=text:match("\\a(&H%x+&)") else alf1=sr.color1:match("H%x%x") end
	      end
	      if res.c3 then
	        if text:match("\\3c&") then col3=text:match("\\3c(&H%x+&)") else col3=sr.color3:gsub("H%x%x","H") end
	        if text:match("\\3a&") then alf3=text:match("\\3a(&H%x+&)") else alf3=sr.color3:match("H%x%x") end
	      end
	      if res.c4 then
	        if text:match("\\4c&") then col4=text:match("\\4c(&H%x+&)") else col4=sr.color4:gsub("H%x%x","H") end
	        if text:match("\\4a&") then alf4=text:match("\\4a(&H%x+&)") else alf4=sr.color4:match("H%x%x") end
	      end
	      if res.c2 then
	        if text:match("\\2c&") then col2=text:match("\\2c(&H%x+&)") else col2=sr.color2:gsub("H%x%x","H") end
	        if text:match("\\2a&") then alf2=text:match("\\2a(&H%x+&)") else alf2=sr.color2:match("H%x%x") end
	      end
	    end

	    -- paste to other lines
	    if x~=1 then if not text:match("^{\\") then text=text:gsub("^","{\\}") end
	      if res.c1 then
	        if text:match("\\c&") then text=text:gsub("\\c(&H%x+&)","\\c"..col1) else text=addtag("\\c"..col1,text) end
	      end
	      if res.c3 then
	        if text:match("\\3c&") then text=text:gsub("\\3c(&H%x+&)","\\3c"..col3) else text=addtag("\\3c"..col3,text) end
	      end
	      if res.c4 then
	        if text:match("\\4c&") then text=text:gsub("\\4c(&H%x+&)","\\4c"..col4) else text=addtag("\\4c"..col4,text) end
	      end
	      if res.c2 then
	        if text:match("\\2c&") then text=text:gsub("\\2c(&H%x+&)","\\2c"..col2) else text=addtag("\\2c"..col2,text) end
	      end
	     -- alpha
	     if res.alfa then
	      if res.c1 then
	        if text:match("\\1a&") then text=text:gsub("\\1a(&H%x+&)","\\1a"..alf1) else text=addtag("\\1a"..alf1,text) end
	      end
	      if res.c3 then
	        if text:match("\\3a&") then text=text:gsub("\\3a(&H%x+&)","\\3a"..alf3) else text=addtag("\\3a"..alf3,text) end
	      end
	      if res.c4 then
	        if text:match("\\4a&") then text=text:gsub("\\4a(&H%x+&)","\\4a"..alf4) else text=addtag("\\4a"..alf4,text) end
	      end
	      if res.c2 then
	        if text:match("\\2a&") then text=text:gsub("\\2a(&H%x+&)","\\2a"..alf2) else text=addtag("\\2a"..alf2,text) end
	      end
	     end
	    end
	    
	text=text:gsub("\\\\","\\")
	text=text:gsub("\\}","}")
	text=text:gsub("{}","")
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function addtag(tag,text) text=text:gsub("^({\\[^}]-)}","%1"..tag.."}") return text end
function despace(txt) txt=txt:gsub("%s","_sp_") return txt end
function debreak(txt) txt=txt:gsub("\\N","_break_") return txt end

function splitbreak(subs, sel)		-- 1.6
	for i=#sel,1,-1 do
	  line=subs[sel[i]]
	  text=subs[sel[i]].text
	    text=text:gsub("({[^}]-})",function (a) return debreak(a) end)
	    
	    if not text:match("\\N") then
	    pressed=aegisub.dialog.display({{class="label",
	    label="Selection line "..i.." has no \\N. \nYou can split by spaces or by tags.",x=0,y=0,width=1,height=2}},{"Spaces","Tags","Skip","Cancel"})
	      if pressed=="Cancel" then aegisub.cancel() end
	      if pressed=="Spaces" then text=text:gsub(" "," \\N") end
	      if pressed=="Tags" then text=text:gsub("(.)({\\[^}]-})","%1\\N%2") end
	    end
	  
	    -- split by \N
	    if text:match("\\N")then
	    -- positioning (only considers \fs, \fscy, and \an)
	    poses=1 for en in text:gmatch("\\N") do poses=poses+1 end
	    posY=text:match("\\pos%([%d%.%-]+,([%d%.%-]+)%)")
	    if posY~=nil then
		styleref=stylechk(subs,line.style)
		fos=styleref.fontsize
		l_fos=text:match("\\fs(%d+)")		if l_fos~=nil then fos=l_fos end
		scy=styleref.scale_y
		l_scy=text:match("\\fscy([%d%.]+)")		if l_scy~=nil then scy=l_scy end
		siz=fos*scy/100
		align=tostring(styleref.align)
		l_align=text:match("\\an(%d)")		if l_align~=nil then align=l_align end
		if align:match("[123]") then posbase="low"
		elseif align:match("[456]") then posbase="mid"
		else posbase="high" end
		postab={}
		if posbase=="high" then
		    for p=1,poses do table.insert(postab,posY+(p-1)*siz) end
		end
		if posbase=="low" then
		    for p=poses,1,-1 do table.insert(postab,posY-(p-1)*siz) end
		    text=text:gsub("(\\pos%([%d%.%-]+,)[%d%.%-]+","%1"..postab[1])
		end
		if posbase=="mid" then
		    posYm=posY-(poses-1)*siz/2
		    for p=1,poses do table.insert(postab,posYm+(p-1)*siz) end
		    text=text:gsub("(\\pos%([%d%.%-]+,)[%d%.%-]+","%1"..postab[1])
		end
	    end
	    
	    --aegisub.log("\n text "..text)
	    
	    line2=line
		if text:match("%*")then text=text:gsub("%*","_asterisk_") end
		if text:match("^{\\") then				-- lines 2+, with initial tags
		    tags=text:match("^({\\[^}]*})")			-- initial tags
		    tags2=""
		    count=0	poscount=2
		    text=text:gsub("\\N","*")				-- switch \N for *
		    for aftern in text:gmatch("%*%s*([^%*]*)") do	-- part after \N [*]
		      aftern=aftern:gsub("_break_","\\N")	:gsub("%s*$","")	:gsub("_asterisk_","*")
		        line2.text=tags..aftern				-- every new line=initial tags + part after one \N
			if posY~=nil then
			    line2.text=line2.text:gsub("(\\pos%([%d%.%-]+,)[%d%.%-]+","%1"..postab[poscount])
			end
			poscount=poscount+1
		      if aftern~="" then
		        count=count+1
		        --line2.effect=count+1
		        line2.text=line2.text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
		        line2.text=duplikill(line2.text)
		        tags=line2.text:match("^({\\[^}]*})")
		        subs.insert(sel[i]+count,line2)		-- insert each match one line further 
		      end
		    end
		else							-- lines 2+, without initial tags
		    count=0
		    text=text:gsub("\\N","*")
		    for aftern in text:gmatch("%*%s*([^%*]*)") do
		      aftern=aftern:gsub("_break_","\\N")	:gsub("%s*$","")	:gsub("_asterisk_","*")
		      if aftern~="" then
		        count=count+1
		        line2.text=aftern
		        subs.insert(sel[i]+count,line2)
		      end
		    end
		end
		if text:match("^{\\") then				-- line 1, with initial tags
		    text=text:gsub("^({\\[^}]-})(.-)%*(.*)","%1%2")
		    text=text:gsub("_break_","\\N")	:gsub("%s*$","")
		    --line.effect=1
		else							-- line 1, without initial tags
		    text=text:gsub("^(.-)%*(.*)","%1")
		    text=text:gsub("_break_","\\N")	:gsub("%s*$","")
		end
		text=text:gsub("_asterisk_","*")
		
	    line.text=text
	    subs[sel[i]]=line
	    end
	end
	aegisub.set_undo_point(script_name)
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
	tags=tags:gsub("(\\clip%([^%)]+%))([^%(%)]-)(\\c&H%x+&)","%2%3%1")
	return tags
end

function duplikill(text)
	tags1={"blur","be","bord","shad","xbord","xshad","ybord","yshad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay","an","b","i"}
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

function extrakill(text)
	tags3={"pos","move","org","clip","iclip","fad"}
	for i=1,#tags3 do
	    tag=tags3[i]
	    text=text:gsub("(\\"..tag.."[^\\}]+)([^}]-)(\\"..tag.."[^\\}]+)","%3%2")
	end
	text=text:gsub("(\\pos[^\\}]+)([^}]-)(\\move[^\\}]+)","%3%2")
	text=text:gsub("(\\move[^\\}]+)([^}]-)(\\pos[^\\}]+)","%3%2")
	return text
end

function stylechk(subs,stylename)
  for i=1, #subs do
    if subs[i].class=="style" then
      local st=subs[i]
      if stylename==st.name then styleref=st break end
      
    end
  end
  return styleref
end

function konfig(subs, sel)
	if lastfax==nil then lastfax=0.05 end
	if lastxlip==nil then lastxlip=0 end
	if lastylip==nil then lastylip=0 end
	dialog_config=
	{
	    {x=0,y=0,width=1,height=1,class="label",label="\\fax ",},
	    {x=1,y=0,width=2,height=1,class="floatedit",name="fax",value=lastfax},
	    {x=0,y=1,width=2,height=1,class="checkbox",name="clax",label="from clip   ",value=true},
	    {x=2,y=1,width=1,height=1,class="checkbox",name="right",label="to the right   ",value=false},
	    
	    {x=3,y=0,width=2,height=1,class="checkbox",name="cpstyle",label="copy style with tags",value=copy_style},
	    
	    {x=5,y=0,width=1,height=1,class="label",label="  copy colours:  ",},
	    {x=6,y=0,width=1,height=1,class="checkbox",name="c1",label="c",value=false},
	    {x=7,y=0,width=1,height=1,class="checkbox",name="c3",label="3c ",value=false},
	    {x=8,y=0,width=1,height=1,class="checkbox",name="c4",label="4c  ",value=false},
	    {x=9,y=0,width=1,height=1,class="checkbox",name="c2",label="2c",value=false},
	    {x=10,y=0,width=2,height=1,class="checkbox",name="alfa",label="include alpha",value=false},
	    
	    {x=3,y=1,width=1,height=1,class="label",label="shift clip every frame by:",},
	    {x=5,y=1,width=2,height=1,class="floatedit",name="xlip",value=lastxlip},
	    {x=7,y=1,width=3,height=1,class="floatedit",name="ylip",value=lastylip},
	    
	    {x=10,y=1,width=2,height=1,class="label",label="   Copyfax This v"..script_version},
	} 	
	pressed, res=aegisub.dialog.display(dialog_config,
	{"fax it","copy stuff","copy tags","copy text","copy clip","copy colours","split by \\N","cancel"},{cancel='cancel'})
	
	if pressed=="cancel" then aegisub.cancel() end
	if pressed=="fax it" then fucks(subs, sel) end
	if pressed=="copy stuff" then copystuff(subs, sel) end
	if pressed=="copy tags" then copytags(subs, sel) end
	if pressed=="copy text" then copytext(subs, sel) end
	if pressed=="copy clip" then copyclip(subs, sel) end
	if pressed=="copy colours" then copycolours(subs, sel) end
	if pressed=="split by \\N" then splitbreak(subs, sel) end
	lastfax=res.fax
	lastxlip=res.xlip
	lastylip=res.ylip
end

function fax_this(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, fax_this)
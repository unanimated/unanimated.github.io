script_name = "MultiCopy"
script_description = "Copy tags or text from multiple lines and paste to others"	-- open and click on Help for more info
script_author = "unanimated"
script_version = "1.4"

require "clipboard"

-- COPY PART

function copy(subs, sel)	-- tags
	copytags=""
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	      if x~=#sel and text:match("^({\\[^}]*})") then
	      tags=text:match("^({\\[^}]*})")
	      copytags=copytags..tags.."\n"
	      end
	      if x==#sel and text:match("^({\\[^}]*})") then
	      tags=text:match("^({\\[^}]*})")
	      copytags=copytags..tags
	      end
	subs[i] = line
    end
    copydialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=copytags},}
    pressed,res=aegisub.dialog.display(copydialog,{"OK","Copy to clipboard"})
    if pressed=="Copy to clipboard" then    clipboard.set(copytags) end
end

function copyt(subs, sel)	-- text
	copytekst=""
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	if x~=#sel then
	      if text:match("^{\\[^}]*}") then
	      tekst=text:match("^{\\[^}]*}(.*)")
	      copytekst=copytekst..tekst.."\n"
	      else
	      copytekst=copytekst..text.."\n"
	      end
	end
	if x==#sel then
      	      if text:match("^{\\[^}]*}") then
	      tekst=text:match("^{\\[^}]*}(.*)")
	      copytekst=copytekst..tekst
	      else
	      copytekst=copytekst..text
	      end
	end
	subs[i] = line
    end
    copydialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=copytekst},}
    pressed,res=aegisub.dialog.display(copydialog,{"OK","Copy to clipboard"})
    if pressed=="Copy to clipboard" then    clipboard.set(copytekst) end
end

function copyc(subs, sel)	-- clip etc
	copyclip=""
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	
	      if x~=#sel and res.copymode=="clip" and text:match("\\i?clip") then
	      klip=text:match("\\i?clip%(([^%)]+)%)")
	      copyclip=copyclip..klip.."\n"
	      end
	      if x==#sel and res.copymode=="clip" and text:match("\\i?clip") then
	      klip=text:match("\\i?clip%(([^%)]+)%)")
	      copyclip=copyclip..klip
	      end
	      
	      if x~=#sel and res.copymode=="position" and text:match("\\pos") then
	      posi=text:match("\\pos%(([^%)]+)%)")
	      copyclip=copyclip..posi.."\n"
	      end
	      if x==#sel and res.copymode=="position" and text:match("\\pos") then
	      posi=text:match("\\pos%(([^%)]+)%)")
	      copyclip=copyclip..posi
	      end
	      
	      if x~=#sel and res.copymode=="blur" and text:match("\\blur") then
	      blurr=text:match("\\blur([%d%.]+)")
	      copyclip=copyclip..blurr.."\n"
	      end
	      if x==#sel and res.copymode=="blur" and text:match("\\blur") then
	      blurr=text:match("\\blur([%d%.]+)")
	      copyclip=copyclip..blurr
	      end
	      
	      if x~=#sel and res.copymode=="border" and text:match("\\bord") then
	      bordd=text:match("\\bord([%d%.]+)")
	      copyclip=copyclip..bordd.."\n"
	      end
	      if x==#sel and res.copymode=="border" and text:match("\\bord") then
	      bordd=text:match("\\bord([%d%.]+)")
	      copyclip=copyclip..bordd
	      end
	      
	      if x~=#sel and res.copymode=="\\1c" and text:match("\\1?c&") then
	      kolor1=text:match("\\1?c(&H%w+&)")
	      copyclip=copyclip..kolor1.."\n"
	      end
	      if x==#sel and res.copymode=="\\1c" and text:match("\\1?c&") then
	      kolor1=text:match("\\1?c(&H%w+&)")
	      copyclip=copyclip..kolor1
	      end

	      if x~=#sel and res.copymode=="\\3c" and text:match("\\3c") then
	      kolor3=text:match("\\3c(&H%w+&)")
	      copyclip=copyclip..kolor3.."\n"
	      end
	      if x==#sel and res.copymode=="\\3c" and text:match("\\3c") then
	      kolor3=text:match("\\3c(&H%w+&)")
	      copyclip=copyclip..kolor3
	      end

	      if x~=#sel and res.copymode=="\\4c" and text:match("\\4c") then
	      kolor4=text:match("\\4c(&H%w+&)")
	      copyclip=copyclip..kolor4.."\n"
	      end
	      if x==#sel and res.copymode=="\\4c" and text:match("\\4c") then
	      kolor4=text:match("\\4c(&H%w+&)")
	      copyclip=copyclip..kolor4
	      end
	      
	      if x~=#sel and res.copymode=="alpha" and text:match("\\alpha") then
	      alphaa=text:match("\\alpha(&H%w+&)")
	      copyclip=copyclip..alphaa.."\n"
	      end
	      if x==#sel and res.copymode=="alpha" and text:match("\\alpha") then
	      alphaa=text:match("\\alpha(&H%w+&)")
	      copyclip=copyclip..alphaa
	      end	      
	      
	      if x~=#sel and res.copymode=="\\fscx" and text:match("\\fscx") then
	      fscxx=text:match("\\fscx([%d%.]+)")
	      copyclip=copyclip..fscxx.."\n"
	      end
	      if x==#sel and res.copymode=="\\fscx" and text:match("\\fscx") then
	      fscxx=text:match("\\fscx([%d%.]+)")
	      copyclip=copyclip..fscxx
	      end
	      
	      if x~=#sel and res.copymode=="\\fscy" and text:match("\\fscy") then
	      fscyy=text:match("\\fscy([%d%.]+)")
	      copyclip=copyclip..fscyy.."\n"
	      end
	      if x==#sel and res.copymode=="\\fscy" and text:match("\\fscy") then
	      fscyy=text:match("\\fscy([%d%.]+)")
	      copyclip=copyclip..fscyy
	      end
	      
      	      if x~=#sel and res.copymode=="layer" then
	      copyclip=copyclip..line.layer.."\n"
	      end
	      if x==#sel and res.copymode=="layer" then
	      fscyy=text:match("\\fscy([%d%.]+)")
	      copyclip=copyclip..line.layer
	      end
	      
      	      if x~=#sel and res.copymode=="duration" then
	      copyclip=copyclip..line.end_time-line.start_time.."\n"
	      end
	      if x==#sel and res.copymode=="duration" then
	      fscyy=text:match("\\fscy([%d%.]+)")
	      copyclip=copyclip..line.end_time-line.start_time
	      end
	      
	      
	subs[i] = line
    end
    copydialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Data to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=copyclip},}
    pressed,res=aegisub.dialog.display(copydialog,{"OK","Copy to clipboard"})
    if pressed=="Copy to clipboard" then    clipboard.set(copyclip) end
end

function copyall(subs, sel)	-- all
	copylines=""
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	      if x~=#sel then copylines=copylines..text.."\n" end
	      if x==#sel then copylines=copylines..text end
	subs[i] = line
    end
    copydialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=copylines},}
    pressed,res=aegisub.dialog.display(copydialog,{"OK","Copy to clipboard"},{cancel='OK'})
    if pressed=="Copy to clipboard" then    clipboard.set(copylines) end
end

-- CR Export for Pad

function crmod(subs)
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
            local line = subs[i]
            local text = subs[i].text

		-- change main style to Default
		if line.style:match("Defa") or line.style:match("[Mm]ain") or line.style:match("[Oo]verlap") 
		or line.style:match("[Ii]nternal")  or line.style:match("[Ff]lashback") 
		then line.style="Default" 
		text=text:gsub("\\N"," ")
		text = text:gsub("%s%s"," ")
		text=text:gsub("\\a6","\\an8")
		end

		-- nuke tags from signs, set actor to "Sign", add timecode
		if line.style:match("Defa")==nil then
		text = text:gsub("{[^\}]*}","")
		text = text:gsub("^%s*","")
		timecode=math.floor(line.start_time/1000)
		tc1=math.floor(timecode/60)
		tc2=timecode%60+1
		if tc2==60 then tc2=0 tc1=tc1+1 end
		if tc1<10 then tc1="0"..tc1 end
		if tc2<10 then tc2="0"..tc2 end
		text="{TS "..tc1..":"..tc2.."}"..text
		if line.style:match("[Tt]itle") then text=text:gsub("({TS %d%d:%d%d)}","%1 Title}")  end
		end

	    line.actor=""
	    line.text = text
            subs[i] = line
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

-- copy text from selected lines
function crcopy(subs, sel)
	copylines=""
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
        local line = subs[i]
	local text=subs[i].text
	      if x~=#subs then copylines=copylines..text.."\n" end
	      if x==#subs then copylines=copylines..text end
	subs[i] = line
	end
    end
    copydialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=copylines},}
    pressed,res=aegisub.dialog.display(copydialog,{"OK","Copy to clipboard"})
    if pressed=="Copy to clipboard" then    clipboard.set(copylines) end
end

-- PASTE PART

function paste(subs, sel)	-- tags
raw=res.dat	raw=raw:gsub("\n","")
    fail=0    
  if res.oneline==true then 
	for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	if not text:match("^{") then text="{\\}"..text end
	text=text:gsub("^({\\[^}]*})",raw)
	text=text:gsub("\\\\","\\")
	line.text=text
	subs[i] = line
	end
    else

    local data={}
    for dataline in raw:gmatch("({[^}]-})") do table.insert(data,dataline) end
    if #sel~=#data then fail=1 else
	for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	if not text:match("^{") then text="{\\}"..text end
	text=text:gsub("^({\\[^}]*})",data[x])
	text=text:gsub("\\\\","\\")
	line.text=text
	subs[i] = line
	end
    end
  end
    if fail==1 then aegisub.dialog.display({{class="label",
		    label="Line count of the selection \ndoesn't match pasted data.",x=0,y=0,width=1,height=2}},{"OK"})  end
end

function pastet(subs, sel)	-- text
raw=res.dat	raw=raw:gsub("\n","")
    failt=0    
  if res.oneline==true then 
	for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	if not text:match("^{") then text="{\\}"..text end
	text=text:gsub("^({\\[^}]*})(.*)","%1"..raw)
	text=text:gsub("\\\\","\\")
	text=text:gsub("{\\}","")
	line.text=text
	subs[i] = line
	end
    else
    
    local data={}	raw=res.dat.."\n"	--aegisub.log("raw\n"..raw)
    for dataline in raw:gmatch("(.-)\n") do table.insert(data,dataline) end
    if #sel~=#data then failt=1 else
	for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	if text:match("^{\\") then
	text=text:gsub("^({\\[^}]*}).*","%1"..data[x])
	else
	text=data[x]
	end
	line.text=text
	subs[i] = line
	end
      end
    end
    if failt==1 then aegisub.dialog.display({{class="label",
		    label="Line count of the selection \ndoesn't match pasted data.",x=0,y=0,width=1,height=2}},{"OK"})  end
end

function pastec(subs, sel)	-- clip and stuff
raw=res.dat	raw=raw:gsub("\n","")
    failc=0    
  if res.oneline==true then
	for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	
	if not text:match("^{\\") then text=text:gsub("^","{\\}") end
	
	if res.pastemode=="clip" and text:match("\\clip") then text=text:gsub("(\\i?clip%()[^%)]+(%))","%1"..raw.."%2") end
	if res.pastemode=="clip" and not text:match("\\clip") then text=text:gsub("^({\\[^}]*)}","%1\\clip%("..raw.."%)}") end
	
	if res.pastemode=="position" and text:match("\\pos") then text=text:gsub("(\\pos%()[^%)]+(%))","%1"..raw.."%2") end
	if res.pastemode=="position" and not text:match("\\pos") then text=text:gsub("^({\\[^}]*)}","%1\\pos%("..raw.."%)}") end
	
	if res.pastemode=="blur" and text:match("\\blur") then text=text:gsub("(\\blur)[%d%.]+","%1"..raw) end
	if res.pastemode=="blur" and not text:match("\\blur") then text=text:gsub("^{\\","{\\blur"..raw.."\\") end
	
	if res.pastemode=="border" and text:match("\\bord") then text=text:gsub("(\\bord)[%d%.]+","%1"..raw) end
	if res.pastemode=="border" and not text:match("\\bord") then text=text:gsub("^{\\","{\\bord"..raw.."\\") end
	
	if res.pastemode=="\\1c" and text:match("\\1?c") then text=text:gsub("(\\1?c)&H%w+&","%1"..raw) end
	if res.pastemode=="\\1c" and not text:match("\\1?c") then text=text:gsub("^({\\[^}]*)}","%1\\c"..raw.."}") end
	
	if res.pastemode=="\\3c" and text:match("\\3c") then text=text:gsub("(\\3c)&H%w+&","%1"..raw) end
	if res.pastemode=="\\3c" and not text:match("\\3c") then text=text:gsub("^({\\[^}]*)}","%1\\3c"..raw.."}") end
	
	if res.pastemode=="\\4c" and text:match("\\4c") then text=text:gsub("(\\4c)&H%w+&","%1"..raw) end
	if res.pastemode=="\\4c" and not text:match("\\4c") then text=text:gsub("^({\\[^}]*)}","%1\\4c"..raw.."}") end
	
	if res.pastemode=="alpha" and text:match("\\alpha") then text=text:gsub("(\\alpha)&H%w+&","%1"..raw) end
	if res.pastemode=="alpha" and not text:match("\\alpha") then text=text:gsub("^({\\[^}]*)}","%1\\alpha"..raw.."}") end
	
	if res.pastemode=="\\fscx" or res.pastemode=="\\fscx\\fscy" then
	if text:match("\\fscx") then text=text:gsub("(\\fscx)[%d%.]+","%1"..raw) end
	if not text:match("\\fscx") then text=text:gsub("^({\\[^}]*)}","%1\\fscx"..raw.."}") end
	end
	
	if res.pastemode=="\\fscy" or res.pastemode=="\\fscx\\fscy" then
	if text:match("\\fscy") then text=text:gsub("(\\fscy)[%d%.]+","%1"..raw) end
	if not text:match("\\fscy") then text=text:gsub("^({\\[^}]*)}","%1\\fscy"..raw.."}") end
	end
	
	if res.pastemode=="any tag" then text=text:gsub("^({\\[^}]*)}","%1"..raw.."}") end
	
	if res.pastemode=="layer" then line.layer=raw end
	
	if res.pastemode=="duration" then line.end_time=line.start_time+raw end
	
	text=text:gsub("\\\\","\\")
	text=text:gsub("\\}","}")
	text=text:gsub("{}","")
	line.text=text
	subs[i] = line
	end
    else

    local data={}	raw=res.dat.."\n"
    for dataline in raw:gmatch("(.-)\n") do table.insert(data,dataline) end
    if #sel~=#data then failc=1 else
	for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	
	if not text:match("^{\\") then text=text:gsub("^","{\\}") end
	
	if res.pastemode=="clip" and text:match("\\clip") then text=text:gsub("(\\i?clip%()[^%)]+(%))","%1"..data[x].."%2") end
	if res.pastemode=="clip" and not text:match("\\clip") then text=text:gsub("^({\\[^}]*)}","%1\\clip%("..data[x].."%)}") end
	
	if res.pastemode=="position" and text:match("\\pos") then text=text:gsub("(\\pos%()[^%)]+(%))","%1"..data[x].."%2") end
	if res.pastemode=="position" and not text:match("\\pos") then text=text:gsub("^({\\[^}]*)}","%1\\pos%("..data[x].."%)}") end
	
	if res.pastemode=="blur" and text:match("\\blur") then text=text:gsub("(\\blur)[%d%.]+","%1"..data[x]) end
	if res.pastemode=="blur" and not text:match("\\blur") then text=text:gsub("^{\\","{\\blur"..data[x].."\\") end
	
	if res.pastemode=="border" and text:match("\\bord") then text=text:gsub("(\\bord)[%d%.]+","%1"..data[x]) end
	if res.pastemode=="border" and not text:match("\\bord") then text=text:gsub("^{\\","{\\bord"..data[x].."\\") end
	
	if res.pastemode=="\\1c" and text:match("\\1?c") then text=text:gsub("(\\1?c)&H%w+&","%1"..data[x]) end
	if res.pastemode=="\\1c" and not text:match("\\1?c") then text=text:gsub("^({\\[^}]*)}","%1\\c"..data[x].."}") end
	
	if res.pastemode=="\\3c" and text:match("\\3c") then text=text:gsub("(\\3c)&H%w+&","%1"..data[x]) end
	if res.pastemode=="\\3c" and not text:match("\\3c") then text=text:gsub("^({\\[^}]*)}","%1\\3c"..data[x].."}") end
	
	if res.pastemode=="\\4c" and text:match("\\4c") then text=text:gsub("(\\4c)&H%w+&","%1"..data[x]) end
	if res.pastemode=="\\4c" and not text:match("\\4c") then text=text:gsub("^({\\[^}]*)}","%1\\4c"..data[x].."}") end
	
	if res.pastemode=="alpha" and text:match("\\alpha") then text=text:gsub("(\\alpha)&H%w+&","%1"..data[x]) end
	if res.pastemode=="alpha" and not text:match("\\alpha") then text=text:gsub("^({\\[^}]*)}","%1\\alpha"..data[x].."}") end
	
	if res.pastemode=="\\fscx" or res.pastemode=="\\fscx\\fscy" then
	if text:match("\\fscx") then text=text:gsub("(\\fscx)[%d%.]+","%1"..data[x]) end
	if not text:match("\\fscx") then text=text:gsub("^({\\[^}]*)}","%1\\fscx"..data[x].."}") end
	end
	
	if res.pastemode=="\\fscy" or res.pastemode=="\\fscx\\fscy" then
	if text:match("\\fscy") then text=text:gsub("(\\fscy)[%d%.]+","%1"..data[x]) end
	if not text:match("\\fscy") then text=text:gsub("^({\\[^}]*)}","%1\\fscy"..data[x].."}") end
	end
	
	if res.pastemode=="any tag" then text=text:gsub("^({\\[^}]*)}","%1"..data[x].."}") end
	
	if res.pastemode=="layer" then line.layer=data[x] end
	
	if res.pastemode=="duration" then line.end_time=line.start_time+data[x] end
	
	text=text:gsub("\\\\","\\")
	text=text:gsub("\\}","}")
	text=text:gsub("{}","")
	line.text=text
	subs[i] = line
	end
      end
    end
    if failc==1 then aegisub.dialog.display({{class="label",
		    label="Line count of the selection \ndoesn't match pasted data.",x=0,y=0,width=1,height=2}},{"OK"})  end
end

-- GUI PART

function multicopy(subs, sel)
	dialog_config=
	{
	    {x=1,y=18,width=3,height=1,class="dropdown",name="copymode",value="tags",
	items={"tags","text","all","------","export CR for pad","------","clip","position","blur","border","\\1c","\\3c","\\4c","alpha","\\fscx","\\fscy","------","layer","duration"}},
	    {x=0,y=17,width=10,height=1,class="label",label="Copy stuff from selected lines, select new lines [same number of them], run script again to paste stored data to new lines"},
	    {x=0,y=0,width=10,height=17,class="textbox",name="dat"},
	    {x=0,y=18,width=1,height=1,class="label",label="Copy:"},
	    {x=4,y=18,width=1,height=1,class="label",label="Paste specific:"},
	    {x=5,y=18,width=1,height=1,class="dropdown",name="pastemode",value="clip",
	items={"clip","position","blur","border","\\1c","\\3c","\\4c","alpha","\\fscx","\\fscy","\\fscx\\fscy","any tag","------","layer","duration"}},
	    
	    {x=6,y=18,width=5,height=1,class="checkbox",name="oneline",label="Paste one line to all selected lines",value=false},
	} 	
	buttons={"Copy","Paste tags","Paste text","Paste spec.","Paste from clipboard","Help","Cancel"}
	repeat
	if pressed=="Paste from clipboard" then    
		klipboard=clipboard.get()
		for key,val in ipairs(dialog_config) do
		    if val.name=="dat" then val.value=klipboard end
		    if val.name=="copymode" then val.value=res.copymode end
		    if val.name=="pastemode" then val.value=res.pastemode end
		    if val.name=="oneline" then val.value=res.oneline end
		end
	end
	pressed, res = aegisub.dialog.display(dialog_config,buttons,{cancel='Cancel'})
	until pressed~="Paste from clipboard"

	if pressed=="Cancel" then    aegisub.cancel() end
	if pressed=="Copy" then    
	    if res.copymode=="tags" then copy(subs, sel) end
	    if res.copymode=="text" then copyt(subs, sel) end
	    if res.copymode=="all" then copyall(subs, sel) end
	    if res.copymode=="export CR for pad" then crmod(subs)  crsort(subs)  crcopy(subs) end
	    if res.copymode=="clip" or res.copymode=="position" or res.copymode=="blur" or res.copymode=="border" or res.copymode=="alpha"
	    or res.copymode=="\\1c" or res.copymode=="\\3c" or res.copymode=="\\4c" or res.copymode=="\\fscx" or res.copymode=="\\fscy"
	    or res.copymode=="layer" or res.copymode=="duration" then copyc(subs, sel) end	
	    
	end
	if pressed=="Paste tags" then    paste(subs, sel) end
	if pressed=="Paste text" then    pastet(subs, sel) end
	if pressed=="Paste spec." then    pastec(subs, sel) end

	if pressed=="Help" then    aegisub.dialog.display({{x=0,y=0,width=2,height=10,class="label",
		label="There are 4 modes for copying/pasting: tags, text, all, and clip.\n\nTags: Select lines with tags, click 'Copy tags.' Copy to clipboard.\nSelect lines to which you want to paste the data [same number of lines].\nRun script again. Paste from clipboard. Click on 'Paste tags.'\nThe tags will be pasted to the new lines without changing the text.\n\nText: Works the same, except for using text, not tags.\nTo be more precise, it skips the first block of tags but keeps inline tags like italics etc.\n\nAll: Copies the whole line, tags and text. \nThis is like 'exporting' text, but you get to keep the tags.\nThis is especially useful when you want to paste the script on a pad.\nNote: There is no 'Paste All' button since you can just use Aegisub's 'Paste Over.'\n\nSpecific tags: Copies/pastes values of a specific selected tag.\nYou could also paste values that you type manually.\nAnother thing that's possible is for example copying \\fscx data \nand pasting it as \\fscy data.\n\n'Paste one line to all selected lines'\nApplies the same line, whether tags or text or clip, to all selected lines.\nMake sure you paste only one line to the textbox."}},
	{"TL;DR"})	end
	
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, multicopy)
	--[[
	
	FUNCTIONS: Import OP/ED/signs, update lyrics, make chapters, number lines.
	
	
	INSTRUCTIONS
	
	This script is pretty complicated, so you'd better read this.
	
	
	- IMPORT -
	
	This allows you to import OP/ED or signs (or whatever) from an external .ass file.
	OP/ED must be saved as OP.ass and ED.ass; signs can have any name.
	The .ass file may contain headers, or it can be just the dialogue lines.
	The imported stuff will be shifted to your currently selected line (or the first one in your selection).
	The first line of the saved file works as a reference point, so use a "First frame of OP" line etc.	
	(You can save your OP/ED shifted to 0 or you can just leave it as is; the times will be recalculated to start at the current line.)
	"keep line" will keep your current line and comment it, otherwise the line gets deleted (you can change it in settings).
	
	SIGNS work similarly, except you need to input the sign's/file's name, for example "eptitle"[.ass]
	in the dialog you get after clicking "Import". Import OP/ED are basically just convenient presets for "import sign".
	While stuff is normally imported including timing, if you want to import episode titles 
	and match the timing to your current line, check "match times to current line". (All imported lines will have the same time.)
	There are 2 more presets in the signs dialog - title and eptitle, which will load title.ass/eptitle.ass.
	"custom" will load whatever you type in the field below it. This way you can import any kind of Dialogue lines.
	
	UPDATE LYRICS
	
	This is probably the most complicated part, but if your songs have some massive styling with layers and mocha tracking,
	this will make updating lyrics, which would otherwise be a pain in the ass, really easy.
	The only styling that will prevent this from working is inline tags - gradient by character etc.
	
	The prerequisite here is that your OP/ED MUST have NUMBERED lines! (See NUMBERS section - might be good to read that first.)
	The numbers must correspond to the verses, not to lines in the script.
	If line 1 of the SONG is mocha-tracked over 200 frames, all of those frames must be numbered 01.
	It is thus most convenient to number the lines before you start styling, when it's still simple.
	
	How this works:
	Paste your updated lyrics into the large, top-left area of the GUI.
	Use the Left and Right fields to set the markers to detect the right lines. 
	Without markers it will just look for numbers. 
	If your OP lines are numbered with "OP01eng", you must set "OP" under Left and "eng" under Right.
	For now, everything is case-sensitive (I might change that later if it gets really annoying and pointless).
	You must also correctly set the actor/effect choice in the bottom-right part of the GUI.
	If you pasted lyrics, selected "update lyrics", and set markers and actor/effect, then hit Import, and lyrics wil be updated.
	
	How it works - example: The lyrics you pasted in the data box get their lines assigned with numbers from 1 to whatever.
	Let's say your markers are "OP01eng" and you're using the effect field.
	The script looks for lines with that pattern in the effect field.
	When it finds one, it reads the number (for example "01" from "OP01eng")
	and replaces the line's text (skipping tags) with line 1 from the pasted lyrics.
	For every line marked "OP##eng" it replaces the current lyrics with line ## from your pasted updated lyrics.
	
	To make sure this doesn't fuck up tremendously, it shows you a log with all replacements at the end.
	
	That's pretty much all you really need to know for updating lyrics, but there are a few more things.
	
	If the script doesn't find any lines that match the markers, it gives you a message like this:
		"The effect field of selected lines doesn't match given pattern..."
	This means the lines either don't exist in your selection, or you probably forgot to set the markers.
	
	"style restriction" is an extra option that lets you limit the replacing to lines whose style contains given pattern.
	Let's give some examples:
	You check the restriction and type "OP" in the field below.
	You can now select the whole script instead of selecting only the OP lines, and only lines with "OP" in style will be updated.
	You may have the ED numbered the same way, but the "OP" restriction will ignore it.
	This can be also useful if you have lines numbered just 01, 02 etc., and you have english and romaji, all mixed together.
	If your styles are OP-jap and OP-eng, you can type "jap" in the restriction field if you're updating romaji
	to make sure the script doesn't update the english lines as well (replacing them with romaji).
	It is, however, recommended to just use different markers, like j01 / e01.
	
	
	- CHAPTERS -
	
	This will generate chapters from the .ass file
	MARKER: For a line to be used for chapters, it has to be marked with "chapter"/"chptr"/"chap" 
		in actor/effect field (depending on settings) or the same 3 options as a separate comment, ie. {chapter} etc.
	CHAPTER NAME: What will be used as chapter name. It's either the content of the effect field, or the line's FIRST comment.
		If the comment is {OP first frame} or {ED start}, the script will remove " first frame" or " start", so you can keep those.
	If you use default settings, just put "chapter" in actor field and make comments like {OP} or {Part A}.
	Subchapters: You can make subchapters like this {Part A::Scene 5}. This will be a subchapter of "Part A" called "Scene 5".
	
	
	- NUMBERS - 
	
	This is a tool to number lines and add various markers to actor/effect fields.
	The dropdown with "01" lets you choose how many leading zeros you want.
	The Left and Right fields will add stuff to the numbers. If Left is "x" and Right is "yz", the first marker will be "x01yz".
	What makes this function much more versatile is the "Mod" field.
	If you put in one number, then that's the number from which the numbering will start, so "5" -> 5, 6, 7, etc.
	You can, however, use a comma or slash to modify the numbering some more.
	"8,3" or "8/3" will start numbering from 8, repeating each number 3 times, so 8, 8, 8, 9, 9, 9, 10, 10, 10, etc.
	This allows you to easily number lines that are typeset in layers etc.
	
	"add marker" uses the Left and Right fields to add stuff to the current content of actor/effect.
	If you number lines for the OP, you can set "OP-" in Left and "-eng" in Right, and numbering will be "OP-01-eng".
	(Mod does nothing when adding markers.)

	--]]
	
script_name = "Unimportant"
script_description = "Import stuff, number stuff, do other stuff."
script_author = "unanimated"
script_version = "1.0"

require "clipboard"

--	SETTINGS	--

-- IMPORT --
import="import sign"			-- options: "import OP","import ED","import sign","update lyrics"
keep_line=true				-- options: true / false
style_restriction=false		-- options: true / false
import_path=""				-- relative to where your script is -> "..\\OPED\\" = one folder up and then OPED folder
					-- backslashes must be double and must be included at the end. default "" is the script folder.

-- CHAPTERS --
default_marker="actor"			-- options: "actor","effect","comment"
default_chapter_name="comment"		-- options: "comment","effect"
default_save_name="script"		-- options: "script","video"
autogenerate_intro=true			-- options: true / false

-- NUMBERS --
actor_effect="effect"			-- options: "actor","effect"
numbering="01"				-- options: "1","01","001","0001"

--	--	--	--

function important(subs, sel)
	sdata={}
	if res.mega=="update lyrics" and res.dat=="" then aegisub.dialog.display({{x=0,y=0,width=1,height=1,class="label",label="No lyrics given."}},{"ok"},{cancel='ok'}) aegisub.cancel()
	else
	res.dat=res.dat.."\n"
	  for dataline in res.dat:gmatch("(.-)\n") do
	    if dataline~="" then table.insert(sdata,dataline) end
	  end
	end
	songcheck=0
	
	if res.mega=="import sign" then
		press,reslt=aegisub.dialog.display({
		{x=0,y=0,width=1,height=1,class="label",label="File name:"},
		{x=0,y=1,width=2,height=1,class="edit",name="signame"},
		{x=1,y=0,width=2,height=1,class="dropdown",name="signs",items={"title","eptitle","custom","eyecatch"},value="custom"},
		{x=2,y=1,width=1,height=1,class="label",label=".ass"},
		{x=0,y=2,width=3,height=1,class="checkbox",name="matchtime",label="match times to current line",value=false,},
		{x=0,y=3,width=3,height=1,class="checkbox",name="keeptext",label="keep current text",value=false,},
		},{"OK"},{ok='OK'})
		if reslt.signs=="custom" then signame=reslt.signame else signame=reslt.signs end
	end
	
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	
	sub1=res.rep1
	sub2=res.rep2
	sub3=res.rep3
	zer=res.zeros
	rest=res.rest
	
	-- Import 
	if res.mega:match("import") and x==1 then
	    songtype=res.mega:match("import (%a+)")
	    scriptpath=aegisub.decode_path("?script")
	    if songtype=="sign" then songtype=signame end
	    file=io.open(scriptpath.."\\"..import_path..songtype..".ass")
	    if file==nil then aegisub.dialog.display({{x=0,y=0,width=1,height=1,class="label",label=scriptpath.."\\"..import_path..songtype..".ass\nNo such file."}},{"ok"},{cancel='ok'}) aegisub.cancel() end
	    song=file:read("*all")
	    io.close(file)
	    song=song:gsub("^.-(Dialogue:)","%1")
	    song=song.."\n"
	    song=song:gsub("\n\n$","\n")
	    slines={}
	    for sline in song:gmatch("(.-)\n") do
		if sline~="" then table.insert(slines,sline) end
	    end
	    btext=text
	    songstarttime=slines[1]:match("%a+: %d+,([^,]+)")
	    songstarttime=string2time(songstarttime)
	    if songstarttime~=0 then shiftime=songstarttime else shiftime=0 end
	    basetime=line.start_time
	    basend=line.end_time
	    basestyle=line.style
	    for x=#slines,1,-1 do
		local ltype,layer,s_time,e_time,style,actor,margl,margr,margv,eff,txt=slines[x]:match("(%a+): (%d+),([^,]-),([^,]-),([^,]-),([^,]-),([^,]-),([^,]-),([^,]-),([^,]-),(.*)")
		l2=line
		if ltype=="Comment" then l2.comment=true else l2.comment=false end
		l2.layer=layer
		if res.mega=="import sign" and reslt.matchtime then l2.start_time=basetime l2.end_time=basend else
		s_time=string2time(s_time)
		e_time=string2time(e_time)
		l2.start_time=s_time-shiftime+basetime
		l2.end_time=e_time-shiftime+basetime
		end
		l2.style=style
		l2.actor=actor
		l2.margin_l=margl
		l2.margin_r=margr
		l2.margin_t=margv
		l2.effect=eff
		l2.text=txt
		text=txt 
		if reslt.keeptext then
		l2.text=l2.text:gsub("^({\\[^}]-}).*","%1"..btext) text=btext end
		subs.insert(i+1,l2)
	    end
	    if not res.keep then subs.delete(i) else 
	    text=btext line.comment=true line.end_time=basend line.style=basestyle end
	end
	
	-- Update Lyrics
	if res.mega=="update lyrics" then
		songlyr=sdata
		if line.style:match(rest) then stylecheck=1 else stylecheck=0 end
		if res.restr and stylecheck==0 then pass=0 else pass=1 end
		if res.field=="actor" then marker=line.actor
		elseif res.field=="effect" then marker=line.effect end
		denumber=marker:gsub("%d","")
		-- marked lines
		if marker:match(sub1.."%d+"..sub2) and denumber==sub1..sub2 and pass==1 then
		    index=tonumber(marker:match(sub1.."(%d+)"..sub2))
		    puretext=text:gsub("^{\\[^}]-}","")
		    if songlyr[index]~=nil then
		    text=text:gsub("^({\\[^}]-}).*","%1"..songlyr[index])
		    if not text:match("^{\\[^}]-}") then text=songlyr[index] end
		    end
		    songcheck=1
		end
	end
	
	
	line.text = text
	subs[i]=line
    end
    if res.mega=="update lyrics" and songcheck==0 then press,reslt=aegisub.dialog.display({{x=0,y=0,width=1,height=1,class="label",label="The "..res.field.." field of selected lines doesn't match given pattern \""..sub1.."#"..sub2.."\".\n(Or style pattern wasn't matched if restriction enabled.)\n# = number sequence"}},{"ok"},{cancel='ok'}) end
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

function numbers(subs, sel)
    for i=#sel,1,-1 do
        local line=subs[sel[i]]
        local text=subs[sel[i]].text
	
	sub1=res.rep1
	sub2=res.rep2
	sub3=res.rep3
	zer=res.zeros
	
	if res.modzero=="number lines" then
		if sub3:match("[,/;]") then startn,int=sub3:match("(%d+)[,/;](%d+)") else startn=sub3 int=1 end
		if sub3=="" then startn=1 end
		index=i
		count=math.ceil(index/int)+(startn-1)
		if zer=="01" and count<10 then count="0"..count end
		if zer=="001" and count<10 then count="00"..count
		elseif zer=="001" and count>9 and count<100 then count="0"..count end
		if zer=="0001" and count<10 then count="000"..count
		elseif zer=="0001" and count>9 and count<100 then count="00"..count
		elseif zer=="0001" and count>99 and count<1000 then count="0"..count end
		number=sub1..count..sub2
		
		if res.field=="actor" then line.actor=number end 
		if res.field=="effect" then line.effect=number end
	end
	
	if res.modzero=="add marker" then
		if res.field=="actor" then line.actor=sub1..line.actor..sub2
		elseif res.field=="effect" then line.effect=sub1..line.effect..sub2 end
	end

	line.text=text
	subs[sel[i]]=line
    end
end

--	CHAPTERS	--
function chopters(subs, sel)
	euid=2013
	chptrs={}
	subchptrs={}
    for i = 1, #subs do
      if subs[i].class == "info" then
	if subs[i].key=="Video File" then videoname=subs[i].value  videoname=videoname:gsub("%.mkv","") end
      end
      
      if subs[i].class == "dialogue" then
        local line = subs[i]
	local text=subs[i].text
	local actor=line.actor
	local effect=line.effect
	local start=line.start_time
	if text:match("{[Cc]hapter}") or text:match("{[Cc]hptr}") or text:match("{[Cc]hap}") then comment="chapter" else comment="" end
	if res.marker=="actor" then marker=actor:lower() end
	if res.marker=="effect" then marker=effect:lower() end
	if res.marker=="comment" then marker=comment:lower() end
	
	    if marker=="chapter" or marker=="chptr" or marker=="chap" then
		if res.nam=="comment" then
		name=text:match("^{([^}]*)}")
		name=name:gsub(" [Ff]irst [Ff]rame","")
		name=name:gsub(" [Ss]tart","")
		name=name:gsub("part a","Part A")
		name=name:gsub("part b","Part B")
		name=name:gsub("preview","Preview")
		else
		name=effect
		end
		
		if name:match("::") then main,subname=name:match("(.+)::(.+)") sub=1
		else sub=0
		end
		
		lineid=start+2013
		
		timecode=math.floor(start/1000)
		tc1=math.floor(timecode/60)
		tc2=timecode%60
		tc3=start%1000
		tc4="00"
		if tc2==60 then tc2=0 tc1=tc1+1 end
		if tc1>119 then tc1=tc1-120 tc4="02" end
		if tc1>59 then tc1=tc1-60 tc4="01" end
		if tc1<10 then tc1="0"..tc1 end
		if tc2<10 then tc2="0"..tc2 end
		if tc3<100 then tc3="0"..tc3 end
		linetime=tc4..":"..tc1..":"..tc2.."."..tc3
		
		if sub==0 then
		cur_chptr={id=lineid,name=name,tim=linetime}
		table.insert(chptrs,cur_chptr)
		else
		cur_chptr={id=lineid,subname=subname,tim=linetime,main=main}
		table.insert(subchptrs,cur_chptr)
		end
	    
	    end
	if line.style=="Default" then euid=euid+text:len() end
      end
    end

	-- subchapters
	subchapters={}
    for c=1,#subchptrs do
	local ch=subchptrs[c]
	
	ch_main=ch.main
	ch_uid=ch.id
	ch_name=ch.subname
	ch_time=ch.tim
	
	schapter="      <ChapterAtom>\n        <ChapterDisplay>\n          <ChapterString>"..ch_name.."</ChapterString>\n          <ChapterLanguage>eng</ChapterLanguage>\n        </ChapterDisplay>\n        <ChapterUID>"..ch_uid.."</ChapterUID>\n        <ChapterTimeStart>"..ch_time.."</ChapterTimeStart>\n        <ChapterFlagHidden>0</ChapterFlagHidden>\n        <ChapterFlagEnabled>1</ChapterFlagEnabled>\n      </ChapterAtom>\n"
	
	subchapter={main=ch_main,chap=schapter}
	table.insert(subchapters,subchapter)
    end
    
	-- chapters
	insert_chapters=""
	
	if res.intro then
	insert_chapters="    <ChapterAtom>\n      <ChapterUID>"..#subs.."</ChapterUID>\n      <ChapterFlagHidden>0</ChapterFlagHidden>\n      <ChapterFlagEnabled>1</ChapterFlagEnabled>\n      <ChapterDisplay>\n        <ChapterString>Intro</ChapterString>\n        <ChapterLanguage>eng</ChapterLanguage>\n      </ChapterDisplay>\n      <ChapterTimeStart>00:00:00.033</ChapterTimeStart>\n    </ChapterAtom>\n"
	
	end
	
    for c=1,#chptrs do
	local ch=chptrs[c]
	
	ch_uid=ch.id
	ch_name=ch.name
	ch_time=ch.tim
	
	local subchaps=""
	for c=1,#subchapters do 
	local subc=subchapters[c]
	if subc.main==ch_name then subchaps=subchaps..subc.chap end
	end
	
	chapter="    <ChapterAtom>\n      <ChapterUID>"..ch_uid.."</ChapterUID>\n      <ChapterFlagHidden>0</ChapterFlagHidden>\n      <ChapterFlagEnabled>1</ChapterFlagEnabled>\n      <ChapterDisplay>\n        <ChapterString>"..ch_name.."</ChapterString>\n        <ChapterLanguage>eng</ChapterLanguage>\n      </ChapterDisplay>\n"..subchaps.."      <ChapterTimeStart>"..ch_time.."</ChapterTimeStart>\n    </ChapterAtom>\n"

	insert_chapters=insert_chapters..chapter
    end
	
	chapters="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<Chapters>\n  <EditionEntry>\n    <EditionFlagHidden>0</EditionFlagHidden>\n    <EditionFlagDefault>0</EditionFlagDefault>\n    <EditionUID>"..euid.."</EditionUID>\n"..insert_chapters.."  </EditionEntry>\n</Chapters>"
   
    chdialog=
	{{x=0,y=0,width=35,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=35,height=20,class="textbox",name="copytext",value=chapters},
	{x=0,y=21,width=35,height=1,class="label",label="File will be saved in the same folder as the .ass file."},}
	
    pressed,reslt=aegisub.dialog.display(chdialog,{"Save xml file","Cancel","Copy to clipboard",},{cancel='Cancel'})
    if pressed=="Copy to clipboard" then    clipboard.set(chapters) end
    if pressed=="Save xml file" then    
	scriptpath=aegisub.decode_path("?script")
	scriptname=aegisub.file_name()
	scriptname=scriptname:gsub("%.ass","")
	if res.sav=="script" then filename=scriptname else filename=videoname end
	local file = io.open(scriptpath.."\\"..filename..".xml", "w")
	file:write(chapters)
	file:close()
    end
end

function gui(subs, sel, act)
aline=subs[act]
active=aline.text:gsub("^{\\[^}]*}","")
anocom=aline.text:gsub("{[^}]-}","")
actime=(aline.end_time-aline.start_time)/1000
if datata==nil then data="" else data=datata end
	if sub1==nil then sub1="" end
	if sub2==nil then sub2="" end
	if sub3==nil then sub3=1 end
	dialog_config=
	{
	    -- Sub --
	    {x=0,y=15,width=3,height=1,class="label",label="Left                                                    "},
	    {x=3,y=15,width=3,height=1,class="label",label="Right                                                   "},
	    {x=6,y=15,width=1,height=1,class="label",label="Mod"},
	    {x=0,y=16,width=3,height=1,class="edit",name="rep1",value=sub1},
	    {x=3,y=16,width=3,height=1,class="edit",name="rep2",value=sub2},
	    {x=6,y=16,width=3,height=1,class="edit",name="rep3",value=sub3},
	    
	    -- import
	    {x=6,y=4,width=2,height=1,class="label",label="Import"},
	    {x=6,y=5,width=2,height=1,class="dropdown",name="mega",
	    items={"import OP","import ED","import sign","update lyrics"},value=import},
	    {x=8,y=5,width=1,height=1,class="checkbox",name="keep",label="keep line",value=keep_line,},
	    {x=6,y=6,width=3,height=1,class="checkbox",name="restr",label="style restriction (lyrics)",value=style_restriction,},
	    {x=6,y=7,width=3,height=1,class="edit",name="rest"},
	    
	    -- chapters
	{x=6,y=8,width=1,height=1,class="label",label="Chapters"},
	{x=7,y=8,width=2,height=1,class="checkbox",name="intro",label="autogenerate \"Intro\"",value=autogenerate_intro,},
	{x=6,y=9,width=2,height=1,class="label",label="marker:"},
	{x=8,y=9,width=1,height=1,class="dropdown",name="marker",items={"actor","effect","comment"},value=default_marker},
	{x=6,y=10,width=2,height=1,class="label",label="chapter name:"},
	{x=8,y=10,width=1,height=1,class="dropdown",name="nam",items={"comment","effect"},value=default_chapter_name},
	{x=6,y=11,width=2,height=1,class="label",label="filename:     "},
	{x=8,y=11,width=1,height=1,class="dropdown",name="sav",items={"script","video"},value=default_save_name},
	    {x=6,y=12,width=3,height=1,class="edit",name="blank2"},
	    
	    -- numbers
	    {x=6,y=13,width=2,height=1,class="label",label="Numbers"},
	    {x=8,y=13,width=1,height=1,class="dropdown",name="field",items={"actor","effect"},value=actor_effect},
	    {x=6,y=14,width=2,height=1,class="dropdown",name="modzero",items={"number lines","add marker"},value="number lines"},
	    {x=8,y=14,width=1,height=1,class="dropdown",name="zeros",items={"1","01","001","0001"},value=numbering},
	    
	    -- textboxes
	    {x=0,y=0,width=6,height=15,class="textbox",name="dat",value=data},
	    {x=6,y=0,width=3,height=4,class="textbox",name="datrite",value="Selected Lines: "..#sel.."\n\nActive line: \n"..anocom:len().." characters\nDuration: "..actime.." s"},

	    
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,
		{"Import","Numbers","Chapters","Cancel"},{ok='Import',cancel='Cancel'})
	if pressed=="Cancel" then    aegisub.cancel() end
	
	if pressed=="Import" then    important(subs, sel) end
	if pressed=="Numbers" then    numbers(subs, sel) end
	if pressed=="Chapters" then    chopters(subs, sel) end
    
end

function unimportant(subs, sel, act)
    gui(subs, sel, act)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, unimportant)
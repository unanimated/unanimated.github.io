-- This will generate chapters from the .ass file
-- MARKER: For a line to be used for chapters, it has to be marked with "chapter"/"chptr"/"chap" in actor/effect field (depending on settings) 
--	or the same 3 options as a separate comment, ie. {chapter} etc.
-- CHAPTER NAME: What will be used as chapter name. It's either the content of the effect field, or the FIRST comment.
--	If the comment is {OP first frame} or {ED start}, the script will remove " first frame" or " start", so you can keep those.
-- If you use default settings, just put "chapter" in actor field and make comments like {OP} or {Part A}.

script_name = "Make Chapters"
script_description = "Makes chapters from marked lines"
script_author = "unanimated"
script_version = "1.02"

--	SETTINGS	--

default_marker="actor"			-- options: "actor","effect","comment"
default_chapter_name="comment"		-- options: "comment","effect"
default_save_name="script"		-- options: "script","video"
autogenerate_intro=true			-- options: true / false

--	--	--	--

require "clipboard"

function chopters(subs, sel)
	euid=0
	chptrs={}
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
		
		lineid=start+20
		
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
		
		cur_chptr={id=lineid,name=name,tim=linetime}
		table.insert(chptrs,cur_chptr)
	    
	    end
	if line.style=="Default" then euid=euid+text:len() end
      end
    end

	insert_chapters=""
	
	if res.intro then
	insert_chapters="    <ChapterAtom>\n      <ChapterUID>"..#subs.."</ChapterUID>\n      <ChapterFlagHidden>0</ChapterFlagHidden>\n      <ChapterFlagEnabled>1</ChapterFlagEnabled>\n      <ChapterDisplay>\n        <ChapterString>Intro</ChapterString>\n        <ChapterLanguage>eng</ChapterLanguage>\n      </ChapterDisplay>\n      <ChapterTimeStart>00:00:00.033</ChapterTimeStart>\n    </ChapterAtom>\n"
	
	end
	
    for c=1,#chptrs do
	local ch=chptrs[c]
	--aegisub.log("\nid "..ch.id)
	
	ch_uid=ch.id
	ch_name=ch.name
	ch_time=ch.tim
	
	chapter="    <ChapterAtom>\n      <ChapterUID>"..ch_uid.."</ChapterUID>\n      <ChapterFlagHidden>0</ChapterFlagHidden>\n      <ChapterFlagEnabled>1</ChapterFlagEnabled>\n      <ChapterDisplay>\n        <ChapterString>"..ch_name.."</ChapterString>\n        <ChapterLanguage>eng</ChapterLanguage>\n      </ChapterDisplay>\n      <ChapterTimeStart>"..ch_time.."</ChapterTimeStart>\n    </ChapterAtom>\n"
	
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

function gui(subs, sel)
	dialog_config=
	{
	{x=0,y=0,width=1,height=1,class="label",label="Use as chapter marker:"},
	{x=1,y=0,width=1,height=1,class="dropdown",name="marker",items={"actor","effect","comment"},value=default_marker},
	{x=0,y=1,width=1,height=1,class="label",label="Get chapter name from:"},
	{x=1,y=1,width=1,height=1,class="dropdown",name="nam",items={"comment","effect"},value=default_chapter_name},
	{x=0,y=2,width=1,height=1,class="label",label="Get filename for saving from:     "},
	{x=1,y=2,width=1,height=1,class="dropdown",name="sav",items={"script","video"},value=default_save_name},
	
	{x=0,y=3,width=2,height=1,class="checkbox",name="intro",label="autogenerate \"Intro\" chapter",value=autogenerate_intro,},
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,
		{"Generate","Help","Cancel"},{ok='Generate',cancel='Cancel'})
	if pressed=="Cancel" then    aegisub.cancel() end
	if pressed=="Generate" then    chopters(subs, sel) end
	if pressed=="Help" then aegisub.dialog.display({
		{x=0,y=0,width=1,height=1,class="label",label="Chapter marker:  "},
		{x=0,y=3,width=1,height=1,class="label",label="Chapter name:"},
		{x=0,y=6,width=1,height=1,class="label",label="Save name:"},
		{x=1,y=0,width=1,height=3,class="label",label="actor - actor field must be exact match for one of these: \"chapter\", \"chptr\", \"chap\"\neffect - effect field must be exact match for one of these: \"chapter\", \"chptr\", \"chap\"  \ncomment - text must contain one of these comments: \"{chapter}\", \"{chptr}\", \"{chap}\"\n(no quotation marks)"},
		{x=1,y=3,width=1,height=3,class="label",label="comment - the FIRST comment in text field will be used. {OP}, {Part A}, etc.\nThe script will remove \" first frame\" or \" start\", so you can use {OP first frame} or {ED start}.\neffect - the content of the effect field will be used\n"},
		{x=1,y=6,width=1,height=3,class="label",label="The name of either the .ass file or the video file will be used with .xml extension. \nFile gets saved in the same folder as the .ass.\n"},
		},{"Wakatta"},{cancel='Wakatta'})		
		end
end

function makechapters(subs, sel)
    gui(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, makechapters)
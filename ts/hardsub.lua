-- Script for hardsubbing.
-- You can use vsfilter or vsfiltermod, encode the whole video or just a selection, encode to mp4 or mkv, and use 2 subtitle files.

script_name="Hardsub"
script_description="Hardsubbing"
script_author="unanimated"
script_version="1.0 beta"

function hardsub(subs,sel)
    enconfig=aegisub.decode_path("?user").."\\hardsub-config.conf"
    defsett="--crf 18 --ref 10 --bframes 10 --merange 32 --me umh --subme 10 --trellis 2 --direct auto --b-adapt 2 --partitions all"
    scriptpath=aegisub.decode_path("?script").."\\"
    scriptname=aegisub.file_name()
    vpath=aegisub.decode_path("?video").."\\"
    ms2fr=aegisub.frame_from_ms
    fr2ms=aegisub.ms_from_frame
    sframe=999999
    eframe=0
    videoname=nil

    -- read settings
    file=io.open(enconfig)
    if file~=nil then
	konf=file:read("*all")
	io.close(file)
	xpath=konf:match("xpath:(.-)\n")
	sett=konf:match("settings:(.-)\n")
	vsfpath=konf:match("vsfpath:(.-)\n")
	vsfmpath=konf:match("vsfmpath:(.-)\n")
	vtype=konf:match("vtype:(.-)\n")
	vsf1=konf:match("filter1:(.-)\n")
	vsf2=konf:match("filter2:(.-)\n")
	settlist=konf:match("(settings1:.*\n)$") or ""
    else
	xpath=""
	vsfpath=""
	vsfmpath=""
	vtype=".mkv"
	vsf1="vsfilter"
	vsf2="vsfilter"
	sett=defsett
	settlist=""
    end

    -- get video name
    for i=1,#subs do
	if subs[i].class == "info" then
	  if subs[i].key=="Video File" then videoname=subs[i].value end
	end
    end
    if videoname==nil then videoname=aegisub.project_properties().video_file:gsub("^.*\\","") end
    -- name for final encode
    vid2=videoname:gsub("%.[^%.]+","") :gsub("_?premux","") :gsub("_?workraw","")
    vid2=vid2.."_hardsub"
    
    -- get start/end frame
    for x,i in ipairs(sel) do
	line=subs[i]
        start=line.start_time
	endt=line.end_time
	sfr=aegisub.frame_from_ms(start)
	efr=aegisub.frame_from_ms(endt)
	if sfr<sframe then sframe=sfr end
	if efr>eframe then eframe=efr end
    end
    
    GUI={
	{x=0,y=0,class="label",label="x264.exe:"},
	{x=1,y=0,width=6,class="edit",name="xpath",value=xpath or ""},
	{x=0,y=1,class="label",label="vsfilter.dll:"},
	{x=1,y=1,width=6,class="edit",name="vsf",value=vsfpath or ""},
	{x=0,y=2,class="label",label="vsfiltermod.dll:"},
	{x=1,y=2,width=6,class="edit",name="vsfm",value=vsfmpath or "",hint="only needed if you're using it"},
	{x=0,y=3,class="label",label="Source video:"},
	{x=1,y=3,width=6,class="edit",name="vid",value=videoname},
	
	{x=0,y=4,class="label",label="Encode name:"},
	{x=1,y=4,class="dropdown",name="vtype",value=vtype,items={".mkv",".mp4"}},
	{x=2,y=4,width=5,class="edit",name="vid2",value=vid2},
	
	{x=0,y=5,class="label",label="Primary subs:"},
	{x=1,y=5,class="dropdown",name="filter1",value=vsf1,items={"vsfilter","vsfiltermod"}},
	{x=2,y=5,width=5,class="edit",name="first",value=scriptpath..scriptname},
	{x=0,y=6,class="checkbox",name="sec",label="Secondary:"},
	{x=1,y=6,class="dropdown",name="filter2",value=vsf2,items={"vsfilter","vsfiltermod"}},
	{x=2,y=6,width=5,class="edit",name="second",value=secondary or ""},
	{x=0,y=7,class="label",label="Encoder settings:"},
	{x=1,y=7,width=6,class="edit",name="encset",value=sett},
	
	{x=0,y=8,class="checkbox",name="trim",label="Trim from:",hint="Encodes only current selection"},
	{x=1,y=8,width=2,class="intedit",name="sf",value=sframe},
	{x=3,y=8,class="label",label="to: "},
	{x=4,y=8,class="intedit",name="ef",value=eframe},
	{x=5,y=8,width=2,class="label",label=" If checked, frames are added to Encode name"},
	
	{x=0,y=9,width=3,class="checkbox",name="delbat",label="Delete batch file after encoding",value=true},
	{x=3,y=9,width=3,class="checkbox",name="delavs",label="Delete avisynth script after encoding",value=true},
    }
    repeat
    if pressed=="Default enc. settings" then
	for k,v in ipairs(GUI) do
	    if v.name=="encset" then v.value=defsett else v.value=res[v.name] end
	end
    end
    if pressed=="x264" then
	x264_path=aegisub.dialog.open("x264","",scriptpath,"",false,true)
	for k,v in ipairs(GUI) do
	    if v.name=="xpath" then v.value=x264_path else v.value=res[v.name] end
	end
    end
    if pressed=="vsfilter" then
	vsf_path=aegisub.dialog.open("vsfilter","",scriptpath,"",false,true)
	for k,v in ipairs(GUI) do
	    if v.name=="vsf" then v.value=vsf_path else v.value=res[v.name] end
	end
    end
    if pressed=="vsfiltermod" then
	vsfm_path=aegisub.dialog.open("vsfiltermod","",scriptpath,"",false,true)
	for k,v in ipairs(GUI) do
	    if v.name=="vsfm" then v.value=vsfm_path else v.value=res[v.name] end
	end
    end
    if pressed=="Secondary" then
	sec_path=aegisub.dialog.open("Secondary subs","",scriptpath,"*.ass",false,true)
	for k,v in ipairs(GUI) do
	    if v.name=="second" then v.value=sec_path else v.value=res[v.name] end
	end
    end
    if pressed=="Enc. set." then
	enclist={defsett}
	for set in settlist:gmatch("settings%d:(.-)\n") do
	  table.insert(enclist,set)
	end
	encodings={{class="dropdown",name="enko",items=enclist,value=defsett}}
	press,rez=aegisub.dialog.display(encodings,{"OK","Cancel"},{ok='OK',close='Cancel'})
	for k,v in ipairs(GUI) do
	    if v.name=="encset" then v.value=rez.enko else v.value=res[v.name] end
	end
    end
    if pressed=="Save" then
	-- save config
	konf="xpath:"..res.xpath.."\nvsfpath:"..res.vsf.."\nvsfmpath:"..res.vsfm.."\nvtype:"..res.vtype.."\nfilter1:"..res.filter1.."\nfilter2:"..res.filter2.."\nsettings:"..res.encset.."\n"
	
	-- x264 settings history
	if res.encset~=sett then
	    settlist=settlist:gsub("settings9:.-\n","")
	    set1=esc(sett)
	    if not settlist:match(set1) then
	      for i=8,1,-1 do
		settlist=settlist:gsub("(settings)"..i,"%1"..i+1)
	      end
	      settlist="settings1:"..sett.."\n"..settlist
	    end
	end
	
	konf=konf..settlist
	file=io.open(enconfig,"w")
	file:write(konf)
	file:close()
	for k,v in ipairs(GUI) do v.value=res[v.name] end
	aegisub.dialog.display({{class="label",label="Settings saved to:\n"..enconfig}},{"OK"},{close='OK'})
    end
    pressed,res=aegisub.dialog.display(GUI,
    {"Encode","x264","vsfilter","vsfiltermod","Secondary","Enc. set.","Save","Cancel"},{ok='Encode',close='Cancel'})
    until pressed=="Encode" or pressed=="Cancel"
    if pressed=="Cancel" then aegisub.cancel() end
    
    -- encode name
    encodename=res.vid2
    if res.trim then encodename=encodename.."_"..res.sf.."-"..res.ef end
    
    -- batch script
    encode="\""..res.xpath.."\" "..res.encset.." -o \""..vpath..encodename..res.vtype.."\" \""..scriptpath.."hardsub.avs\""
    batch=scriptpath.."hardsub.bat"
    if res.delavs then encode=encode.."\ndel \""..scriptpath.."hardsub.avs\"" end
    if res.delbat then encode=encode.."\ndel \""..batch.."\"" end
    
    local xfile=io.open(batch,"w")
    xfile:write(encode)
    xfile:close()
    
    -- avisynth script
    if res.filter1=="vsfilter" then filth1=res.vsf ts1="textsub" else filth1=res.vsfm ts1="textsubmod" end
    if res.filter2=="vsfilter" then filth2=res.vsf ts2="textsub" else filth2=res.vsfm ts2="textsubmod" end
    
    plug1="loadplugin(\""..filth1.."\")\n"
    if res.sec and filth1~=filth2 then plug2="loadplugin(\""..filth2.."\")\n" else plug2="" end
    
    text1=ts1.."(\""..res.first.."\")\n"
    if res.sec then text2=ts2.."(\""..res.second.."\")\n" else text2="" end
    
    if res.trim then trim="Trim("..res.sf..", "..res.ef-1 ..")" else trim="" end
    
    avs=plug1..plug2.."ffvideosource(\""..vpath..videoname.."\")\n"..text1..text2..trim
    
    local avsfile=io.open(scriptpath.."hardsub.avs", "w")
    avsfile:write(avs)
    avsfile:close()
    
    -- encode now or later
    P=aegisub.dialog.display({{class="label",label="Batch file:\n"..batch.."\nYou can encode now or run this batch file later.\nIf encoding from Aegisub doesn't work,\njust run the batch file.\n\nEncode now?"}},
    {"Yes","No"},{ok='Yes',close='No'})
    if P=="Yes" then
	batch=batch:gsub("%=","^=")
	os.execute(batch)
    end
end

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

aegisub.register_macro(script_name,script_description,hardsub)
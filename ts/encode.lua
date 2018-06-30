-- Encodes a clip for mocha, or tries to give you an error message if it fails to encode
-- Try this if torque's encoding script fails and you don't know why

script_name="Encode"
script_description="Encodes a clip for mocha"
script_author="unanimated"
script_version="1.0 beta"

function encode(subs,sel,act)
enconfig=aegisub.decode_path("?user").."\\encode-config.conf"
defsett="--profile baseline --level 1.0 --crf 16 --fps 24000/1001"
file=io.open(enconfig)
    -- read settings
    if file~=nil then
	konf=file:read("*all")
	io.close(file)
	xpath=konf:match("xpath:(.-)\n")
	sett=konf:match("settings:(.-)\n")
	mpath=konf:match("mpath:(.-)\n")
    else
	xpath="D:\\typesetting\\x264.exe"
	sett=defsett
	mpath="D:\\typesetting"
    end

    sframe=999999
    eframe=0
    video=nil

    -- get video stuff
    for i=1,#subs do
	if subs[i].class=="info" then
	    local k=subs[i].key
	    local v=subs[i].value
	    if k=="Video File" then video=v break end
	end
    end
    if video==nil then video=aegisub.project_properties().video_file:gsub("^.*\\","") end
    vpath=aegisub.decode_path("?video")

    -- script video check
    if video==nil or video=="" or aegisub.frame_from_ms(10)==nil then t_error("ERROR: No video detected.\nTry saving the script.",true) end

    -- get start/end frame
    for x, i in ipairs(sel) do
	line=subs[i]
        start=line.start_time
	endt=line.end_time
	sfr=aegisub.frame_from_ms(start)
	efr=aegisub.frame_from_ms(endt)
	if sfr<sframe then sframe=sfr end
	if efr>eframe then eframe=efr end
    end

    GUI={
	{x=0,y=0,class="label",label="x264.exe path:"},
	{x=1,y=0,width=3,class="edit",name="xpath",value=xpath},
	{x=0,y=1,class="label",label="Encodes folder:"},
	{x=1,y=1,width=3,class="edit",name="mpath",value=mpath},
	{x=0,y=2,class="label",label="Start frame: "},
	{x=1,y=2,class="intedit",name="sf",value=sframe},
	{x=2,y=2,class="label",label="End frame: "},
	{x=3,y=2,class="intedit",name="ef",value=eframe},
	{x=0,y=3,class="label",label="Video file:"},
	{x=1,y=3,width=3,class="edit",name="vid",value=video},
	{x=0,y=4,class="label",label="Encoder settings:"},
	{x=1,y=4,width=4,class="edit",name="encset",value=sett},
    }
    repeat
    if pressed=="Default enc. settings" then
	for k,v in ipairs(GUI) do
	    if v.name=="encset" then v.value=defsett else v.value=res[v.name] end
	end
    end
    pressed,res=aegisub.dialog.display(GUI,{"Encode","Default enc. settings","Cancel"},{ok='Encode',close='Cancel'})
    until pressed~="Default enc. settings"
    if pressed=="Cancel" then aegisub.cancel() end

    video=res.vid    xpath=res.xpath    sett=res.encset    mpath=res.mpath    sf=res.sf    ef=res.ef    vfull=vpath.."\\"..video

    -- x264 check
    file=io.open(xpath)    if file==nil then t_error(xpath.."\nERROR: File does not exist.",true) else file:close() end
    -- video file check
    file=io.open(vfull)    if file==nil then t_error(vfull.."\nERROR: File does not exist.",true) else file:close() end

    x264="\""..xpath.."\""
    mp4=mpath.."\\"..video:gsub("%.mkv","").."["..sf.."-"..ef.."].mp4"
    encbatch=" "..sett.." --seek "..sf.." --frames "..ef-sf.." -o \""..mp4.."\" \""..vfull.."\"  >\""..mpath.."\\encode_log.txt\" 2>&1"

    -- save batch file
    file=io.open(mpath.."\\mochaencode.bat","w")
    if file then
	file:write(x264..encbatch)
	file:close()
	aegisub.progress.title("Encoding...")
	-- run encoding
	exd,err=os.execute(mpath.."\\mochaencode.bat")
	-- error report
	if exd==nil then
	aegisub.progress.title("Error")
	  file=io.open(mpath.."\\encode_log.txt")
	  msg=file:read("*all")
	  io.close(file)
	  aegisub.dialog.display({{class="label",label="Encoding failed:"},
	  {x=0,y=1,width=40,height=6,class="textbox",value=msg}},{"OK"},{close='OK'})
	  aegisub.cancel()
	end
    else t_error(mpath.."\nERROR: folder doesn't exist.")
    end

    -- save config
    konf="xpath:"..xpath.."\nmpath:"..mpath.."\nsettings:"..sett.."\n"
    file=io.open(enconfig,"w")
    file:write(konf)
    file:close()
end

function t_error(message,cancel)
  aegisub.dialog.display({{class="label",label=message}},{"OK"},{close='OK'})
  if cancel then aegisub.cancel() end
end

aegisub.register_macro(script_name,script_description,encode)
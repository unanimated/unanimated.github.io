script_name = "Convert Framerate"
script_description = "does what you'd expect it to do"
script_author = "unanimated"
script_version = "1.0"

function framerate(subs)
    f1=res.fps1
    f2=res.fps2
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
            local line = subs[i]
	    line.start_time=line.start_time/f2*f1
	    line.end_time=line.end_time/f2*f1
            subs[i] = line
        end
    end
end

function shiift(subs, sel)
shift=res.ms
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
            local line = subs[i]
		start=line.start_time
		endt=line.end_time
		if res.shift=="shift back" then
		start=start-shift
		endt=endt-shift
		else
		start=start+shift
		endt=endt+shift
		end
	    line.start_time=start
	    line.end_time=endt
	    subs[i] = line
	end
    end
end

function convertfps(subs, sel)
	dialog_config=
	{
	    {x=0,y=0,width=2,height=1,class="label",label="Convert framerate",},
	    {x=0,y=1,width=1,height=1,class="label",label="from:",},
	    {x=0,y=2,width=1,height=1,class="label",label="to:",},
	    {x=1,y=1,width=1,height=1,class="dropdown",name="fps1",items={23.976,24,25,29.970,30},value=23.976},
	    {x=1,y=2,width=1,height=1,class="dropdown",name="fps2",items={23.976,24,25,29.970,30},value=25},
	    
	    {x=3,y=0,width=2,height=1,class="checkbox",name="custom",label="custom framerates",value=false,},
	    {x=3,y=1,width=1,height=1,class="floatedit",name="fps1c",value=0,},
	    {x=3,y=2,width=1,height=1,class="floatedit",name="fps2c",value=0,},
	    
	    {x=0,y=4,width=2,height=1,class="label",label="Shift subtitles",},
	    {x=3,y=4,width=2,height=1,class="label",label="in milliseconds:",},
	    {x=0,y=5,width=2,height=1,class="dropdown",name="shift",items={"shift back","shift forward"},value="shift back"},
	    {x=3,y=5,width=1,height=1,class="floatedit",name="ms",value=0,},
	    
	    {x=0,y=6,width=2,height=1,class="label",},
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,{"Convert","Shift","Cancel"},{cancel='Cancel'})
	if pressed=="Cancel" then    aegisub.cancel() end
	if pressed=="Convert" then    framerate(subs, sel) end
	if pressed=="Shift" then    shiift(subs, sel) end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, convertfps)
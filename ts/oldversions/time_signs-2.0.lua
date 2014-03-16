-- Times a sign with {TS 3:24} to 3:24-3:25. Can convert and use a few other formats, like {3:24}, {TS,3:24}, {3,24} etc.

script_name = "Time signs from timecodes"
script_description = "Rough-times signs from TS timecodes"
script_author = "unanimated"
script_version = "2.0"

function signtime(subs, sel)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
		tid=nil
	-- supported timecodes: {TS 1:23}; {TS 1:23 words}; {TS words 1:23}; {TS,1:23}; {1:23}; {1;23}; {1,23}; {1.23}; [1:23] and variations
		-- format timecodes
		text=text:gsub("^{(%d%d?:%d%d)","{TS %1")
		text=text:gsub("^%[(%d%d?:%d%d)%]%s*","{TS %1}")
		text=text:gsub("({[^\\}]*)(%d)%;(%d%d)","%1%2:%3")
		text=text:gsub("({[^\\}]*)(%d)%.(%d%d)","%1%2:%3")
		text=text:gsub("({[^\\}]*)(%d)%,(%d%d)","%1%2:%3")
		text=text:gsub("{TS (%d%d)(%d%d)","{TS %1:%2")
		text=text:gsub("{TS%s([^%d\\}]+)(%d%d?:%d%d)","{TS %2 %1")
		text=text:gsub("{TS,(%d)","{TS %1")
		-- convert to start time
		tstid1,tstid2=text:match("{TS (%d%d?):(%d%d)")
		if tstid1~=nil then
		tid=(tstid1*60000+tstid2*1000-500) end
			-- shifting times
		if tid~=nil then	
			if res.shift then  
				if res.late=="late [shift backwards]" then 
				tid=tid-res.secs*1000 else
				tid=tid+res.secs*1000
				end
			end
			-- set start and end time [500ms before and after the timecode]
			line.start_time=tid line.end_time=(tid+1000) 
		end
		
		
		if res.snap then
		
			-- snapping to keyframes
			
			start=line.start_time		-- start time
			endt=line.end_time		-- end time
			ms2fr=aegisub.frame_from_ms
			fr2ms=aegisub.ms_from_frame
			
			keyframes = aegisub.keyframes()	-- keyframes table
			startf=ms2fr(start)		-- startframe
			endf=ms2fr(endt)		-- endframe
			
			diff=250
			diffe=250
			startkf=keyframes[1]
			endkf=keyframes[#keyframes]

			-- check for nearby keyframes
			for k,kf in ipairs(keyframes) do
			
				-- startframe snap up to 24 frames back [scroll down to change default] and 5 frames forward
				if kf>=startf-res.kfs and kf<startf+5 then 
				tdiff=math.abs(startf-kf)
				if tdiff<=diff then diff=tdiff startkf=kf end
				start=fr2ms(startkf)
				line.start_time=start
				end
				
				-- endframe snap up to 24 frames forward [scroll down to change default] and 10 frames back
				if kf>=endf-10 and kf<=endf+res.kfe then 
				tdiff=math.abs(endf-kf)
				if tdiff<diffe then diffe=tdiff endkf=kf end
				endt=fr2ms(endkf)
				line.end_time=endt
				end
			
			end
		
		end

	    line.text = text
	    subs[i] = line
	end
    aegisub.set_undo_point(script_name)
    return sel
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=0,width=4,height=1,class="label",label="Check this if all your timecodes are too late or early:", },
	    
	    {	x=0,y=1,width=1,height=1,class="checkbox",name="shift",label="Timecodes are ",value=false },
	    {	x=1,y=1,width=1,height=1,class="dropdown",name="secs",
	    items={"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30"},value="1" },
	    
	    {	x=2,y=1,width=1,height=1,class="label",label="seconds", },
	    {	x=3,y=1,width=1,height=1,class="dropdown",name="late",
	    items={"late [shift backwards]","early [shift forwards]"},value="late [shift backwards]" },
	    
	    {	x=0,y=2,width=3,height=1,class="checkbox",name="snap",label="Snapping to keyframes:",value=true },
	    {	x=0,y=3,width=3,height=1,class="label",label="Number of frames to search back", },
	    {	x=0,y=4,width=3,height=1,class="label",label="Number of frames to search forward", },
	    
	    {	x=3,y=3,width=1,height=1,class="intedit",name="kfs",value="24",step=1,min=1,max=250 },	-- default search back [24]
	    {	x=3,y=4,width=1,height=1,class="intedit",name="kfe",value="24",step=1,min=1,max=250 },	-- default search forward [24]
	} 	
	buttons={"No more suffering with SHAFT signs!","Exit"}
	pressed, res = aegisub.dialog.display(dialog_config,buttons)
	if pressed=="Exit" then aegisub.cancel() end
	if pressed=="No more SHAFT suffering!" then signtime(subs,sel) end
end

function timesigns(subs,sel)
    konfig(subs,sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, timesigns)
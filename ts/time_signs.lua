-- Times a sign with {TS 3:24} to 3:24-3:25. Can convert and use a few other formats, like {3:24}, {TS,3:24}, {3,24} etc.

script_name = "Time signs from timecodes"
script_description = "Rough-times signs from TS timecodes"
script_author = "unanimated"
script_version = "1.3"

function timesigns(subs, sel)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
		tid=nil
		text=text:gsub("^{(%d%d?:%d%d)","{TS %1")
		text=text:gsub("^%[(%d%d?:%d%d)%]%s*","{TS %1}")
		text=text:gsub("({[^\\}]*)(%d)%;(%d%d)","%1%2:%3")
		text=text:gsub("({[^\\}]*)(%d)%.(%d%d)","%1%2:%3")
		text=text:gsub("({[^\\}]*)(%d)%,(%d%d)","%1%2:%3")
		text=text:gsub("{TS (%d%d)(%d%d)","{TS %1:%2")
		text=text:gsub("{TS%s([^%d\\}]+)(%d%d?:%d%d)","{TS %2 %1")
		text=text:gsub("{TS,(%d)","{TS %1")
		tstid1,tstid2=text:match("{TS (%d%d?):(%d%d)")
		if tstid1~=nil then
		tid=(tstid1*60000+tstid2*1000-500) end
		if tid~=nil then line.start_time=tid line.end_time=(tid+1000) end
		
		-- snap to keyframes
		
		start=line.start_time		-- start time
		endt=line.end_time		-- end time
		ms2fr=aegisub.frame_from_ms
		fr2ms=aegisub.ms_from_frame
		
		keyframes = aegisub.keyframes()
		startf=ms2fr(start)		-- startframe
		endf=ms2fr(endt)		-- endframe
		
		diff=100
		diffe=100
		startkf=keyframes[1]
		endkf=keyframes[#keyframes]

		-- check for nearby keyframes
		for k,kf in ipairs(keyframes) do
		
		-- startframe snap up to 24 frames back
		if kf>startf-25 and kf<startf then 
		tdiff=math.abs(startf-kf)
		if tdiff<=diff then diff=tdiff startkf=kf end
		start=fr2ms(startkf)
		line.start_time=start
		end
		
		-- endframe snap up to 24 frames forward and 10 frames back
		if kf>=endf-10 and kf<endf+25 then 
		tdiff=math.abs(endf-kf)
		if tdiff<diffe then diffe=tdiff endkf=kf end
		endt=fr2ms(endkf)
		line.end_time=endt
		end
		
		end

		
		
		
		
	    line.text = text
	    subs[i] = line
	end
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, timesigns)
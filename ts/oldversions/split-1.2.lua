-- splits a line at linebreak (use together with Line Breaker with simple hotkeys under Subtitle Grid)
-- it's similar to "Split at cursor (estimate times)", but uses \N as "cursor
-- compared to the inbuilt tool, the times estimation works better, you keep tags for both resulting lines, and it snaps to keyframes (6-frame range)

script_name="split"
script_description="split"
script_author="unanimated"
script_version="1.2"

function split(subs, sel)
	for i=#sel,1,-1 do
	  line=subs[sel[i]]
	  text=subs[sel[i]].text
	    if text:match("\\N")then
	    line2=line
		start=line.start_time		-- start time
		endt=line.end_time		-- end time
		dur=endt-start
		ms2fr=aegisub.frame_from_ms
		fr2ms=aegisub.ms_from_frame
		
		keyframes=aegisub.keyframes()	-- keyframes table
		startf=ms2fr(start)		-- startframe
		endf=ms2fr(endt)		-- endframe
		
		diff=250
		diffe=250
		startkf=keyframes[1]
		endkf=keyframes[#keyframes]
		
		txt=text:gsub("{[^}]-}","")
		one,two=txt:match("^(.-)\\N(.*)")
		c1=one:len()
		c2=two:len()
		f=c1/(c1+c2)
		if dur<3200 then f=(f+0.5)/2 end
		if dur<2000 then f=0.5 end
		if f<0.2 then f=0.2 end
		if f>0.8 then f=0.8 end
		
		-- line 2
		aftern=text:match("\\N%s*(.*)")
		tags=text:match("^{\\[^}]-}") if tags~=nil then aftern=tags..aftern end
		line2.text=aftern
		line2.start_time=start+dur*f
		start2f=ms2fr(line2.start_time)
		
		for k,kf in ipairs(keyframes) do
			if kf>=start2f-6 and kf<=start2f+6 then 
			tdiff=math.abs(start2f-kf)
			if tdiff<=diff then diff=tdiff startkf=kf end
			start2=fr2ms(startkf)
			line2.start_time=start2
			end		
		end
		subs.insert(sel[i]+1,line2)

		-- line 1
		text=text:gsub("^(.-)\\N(.*)","%1")
		line.start_time=start
		line.end_time=start+dur*f
		end1f=ms2fr(line.end_time)
		
		for k,kf in ipairs(keyframes) do
			if kf>=end1f-12 and kf<=end1f+6 then 
			tdiff=math.abs(end1f-kf)
			if tdiff<diffe then diffe=tdiff endkf=kf end
			endt=fr2ms(endkf)
			if endt-start>500 then line.end_time=endt end
			end
		end
		    
	    line.text=text
	    subs[sel[i]]=line
	    end
	end
	aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, split)
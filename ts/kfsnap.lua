-- This is a quick snap-to-keyframe script for timers who would like to have this hotkeyed for whatever reason. Works on selected lines.

script_name="Snap"
script_description="Snaps to nearby keyframes"
script_author="unanimated"
script_version="1.0"

-- SETTINGS

kfsb=6		-- starts before
kfeb=10		-- ends before
kfsa=8		-- starts after
kfea=12		-- ends after

-- END OF SETTINGS

function keyframesnap(subs, sel)
    keyframes=aegisub.keyframes()
    ms2fr=aegisub.frame_from_ms
    fr2ms=aegisub.ms_from_frame
    for z, i in ipairs(sel) do
	line=subs[i]
	start=line.start_time
	endt=line.end_time
	startn=start
	endtn=endt
	startf=ms2fr(start)
	endf=ms2fr(endt)
	diff=250
	diffe=250
	startkf=keyframes[1]
	endkf=keyframes[#keyframes]
	
	for k,kf in ipairs(keyframes) do
	    if kf>=startf-kfsa and kf<=startf+kfsb then
		sdiff=math.abs(startf-kf)
		if sdiff<=diff then diff=sdiff startkf=kf startn=fr2ms(startkf) end
	    end
	    if kf>=endf-kfea and kf<=endf+kfeb then
		ediff=math.abs(endf-kf)
		if ediff<diffe then diffe=ediff endkf=kf endtn=fr2ms(endkf) end
	    end
	end
	
	if startn==nil then startn=start end
	if endtn==nil then endtn=endt end
	line.start_time=startn
	line.end_time=endtn
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, keyframesnap)
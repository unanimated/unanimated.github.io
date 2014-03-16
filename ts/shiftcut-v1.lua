-- The original purpose was to cut lead out for multiple lines, since TPP can't do that.
-- While I was at it, I added a few other logical options. It's like a custom mini-TPP.
-- Leads should never overlap with previous/next line after running this [aside from shifting].

script_name = "ShiftCut"
script_description = "Shift/Cut/Add start/end times."
script_author = "unanimated"
script_version = "1.0"

function cutout(subs, sel)
	for z, i in ipairs(sel) do
	    line = subs[i]
	    text = subs[i].text
		ut=results["ut"]
		start=line.start_time
		endt=line.end_time
		nextline=subs[i+1]
		nextart=nextline.start_time
		if results["addout"]==false then
			if (endt-ut) > start then
		endt=(endt-ut)
			else
			aegisub.dialog.display(
		  {{class="label",label="Line would have negative duration",x=0,y=0,width=1,height=2}},{"OK"})
			end
		else
		endt=(endt+ut)		if i<#subs and endt>nextart then endt=nextart end
		end
	    line.end_time=endt
	    line.text = text
	    subs[i] = line
	end
end

function cutin(subs, sel)
	for z, i in ipairs(sel) do
	    line = subs[i]
	    text = subs[i].text
		inn=results["inn"]
		start=line.start_time
		endt=line.end_time
		prevline=subs[i-1]
		prevend=prevline.end_time
		if results["addin"]==false then
			if (start+inn) < endt then
		start=(start+inn)
			else
			aegisub.dialog.display(
		  {{class="label",label="Line would have negative duration",x=0,y=0,width=1,height=2}},{"OK"})
			end
		else
		start=(start-inn)	if prevline.class=="dialogue" and start<prevend then start=prevend end
		end
	    line.start_time=start
	    line.text = text
	    subs[i] = line
	end
end

function shiift(subs, sel)
	for z, i in ipairs(sel) do
	    line = subs[i]
	    text = subs[i].text
		shift=results["shifft"]
		start=line.start_time
		endt=line.end_time
		if results["shit"]==false then
		start=(start-shift)
		endt=(endt-shift)
		else
		start=(start+shift)
		endt=(endt+shift)
		end
	    line.start_time=start
	    line.end_time=endt
	    line.text = text
	    subs[i] = line
	end
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=0,width=6,height=1,class="label",label="Applies to all selected lines. Times in milliseconds.", },
	    {	x=0,y=1,width=1,height=1,class="label",name="01",label="cut leadin [or", },
	    {	x=1,y=1,width=1,height=1,class="checkbox",name="addin",label="add]",value=false },
	    {	x=0,y=2,width=2,height=1,class="edit",name="inn",value="" },
	    
	    {	x=2,y=1,width=1,height=1,class="label",name="02",label="cut leadout [or", },
	    {	x=3,y=1,width=1,height=1,class="checkbox",name="addout",label="add]",value=false },
	    {	x=2,y=2,width=2,height=1,class="edit",name="ut",value="" },
	    
	    {	x=4,y=1,width=1,height=1,class="label",name="03",label="shift left [or", },
	    {	x=5,y=1,width=1,height=1,class="checkbox",name="shit",label="right]",value=false },
	    {	x=4,y=2,width=2,height=1,class="edit",name="shifft",value="" },
	    
	    {	x=0,y=3,width=1,height=1,class="label",label="", },
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,{"[ cut or add lead in ]","[ cut or add lead out ]","shift times","cancel"})
	if pressed=="[ cut or add lead in ]" then cutin(subs, sel) end
	if pressed=="[ cut or add lead out ]" then cutout(subs, sel) end
	if pressed=="shift times" then shiift(subs, sel) end
	if pressed=="cancel" then aegisub.cancel() end
end

function shiftcut(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, shiftcut)
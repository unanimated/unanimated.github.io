--[[
README:

Refactor Font Size for Motion Tracking (simple)

Because vsfilter does not support non-whole-number scaling, motion-tracked scaling often
looks jerky. One solution is to decrease the font size and increase the scaling, so that
the text appears the same size, but the scaling can be more precise.

For example, \fs50 would become \fs5\fscx1000\fscy1000. The text appears the same size,
but the scale statements have four digits of precision, instead of three.

This script provides a limited solution to automating this process. It will only work on
lines that contain an \fs tag in the line itself but do not contain any \fscx or \fscy
tags. The line must also have an override block at the beginning. A full solution that
properly handles exceptional cases will be provided in the advanced examples section.

]]

--Script properties
script_name="Refactor font size (simple)"
script_description="Increases scaling precision by decreasing font size"
script_author="lyger"
script_version="1.0"

--Main processing function
function refont(sub, sel)
	
	--Go through all the lines in the selection
	for si,li in ipairs(sel) do
		
		--Read in the line
		local line=sub[li]
		
		--Use gsub to replace "\fs" tags with a set of recalculated tags
		line.text=line.text:gsub("\\fs(%d+)",
			--The second argument to gsub is this anonymous function
			--See the gsub example script if you are confused
			function(size)
			
				--Convert to number
				size=tonumber(size)
				
				--Divide by ten and truncate to get the new font size
				newsize=math.floor(size/10)
				
				--The percent by which to scale the text up, to correct for the decreased font size
				newscale=math.floor( 100 * (size / newsize) )
				
				--Use a format string to neatly generate a new set of tags
				newtags=string.format("\\fs%d\\fscx%d\\fscy%d",newsize,newscale,newscale)
				
				--Return these new tags
				--gsub will replace the old tags with these
				return newtags
				
			end)
		
		--Put the line back into the subtitles
		sub[li]=line
		
	end
	
	--Set undo point and maintain selection
	aegisub.set_undo_point(script_name)
	return sel
	
end

--Validation function for the script
function refont_validate(sub,sel)
	--Check every line in the selection
	for si,li in ipairs(sel) do
		
		--If one of them does not have a "\fs" tag in it, then this script cannot run, so return false
		if sub[li].text:match("\\fs") == nil then
			return false
		end
		
	end
	
	--Otherwise, return true
	return true
end

--Register macro
aegisub.register_macro(script_name,script_description,refont,refont_validate)
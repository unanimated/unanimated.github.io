--[[
README:

Refactor Font Size for Motion Tracking (advanced)

Because vsfilter does not support non-whole-number scaling, motion-tracked scaling often
looks jerky. One solution is to decrease the font size and increase the scaling, so that
the text appears the same size, but the scaling can be more precise.

For example, \fs50 would become \fs5\fscx1000\fscy1000. The text appears the same size,
but the scale statements have four digits of precision, instead of three.

This script provides a robust solution that handles most cases, including lines that do
not define font size in-line, varied \fscx and \fscy tags, and lines without tags at the
beginning.

]]

--Script properties
script_name="Refactor font size (advanced)"
script_description="Increases scaling precision by decreasing font size"
script_author="lyger"
script_version="1.0"

include("karaskel.lua")

--Main processing function
function refont(sub, sel)

	--Collect metadata
	local meta,styles=karaskel.collect_head(sub,false)
	
	--Go through all the lines in the selection
	for si,li in ipairs(sel) do
		
		--Read in the line
		local line=sub[li]
		
		--Preprocess
		karaskel.preproc_line(sub,meta,styles,line)
		
		--The next few steps will break the line up into tag-text pairs
		
		--First ensures that the line begins with an override tag block
		--x = A and B or C means if A, then x = B, else x = C
		ltext=(line.text:match("^{")==nil) and "{}"..line.text or line.text
		
		--Then ensure that the first tag includes an \fs tag
		if ltext:match("^{[^}]*\\fs%d+[^}]*}")==nil then
			ltext=ltext:gsub("^{",string.format("{\\fs%d",line.styleref.fontsize))
		end
		
		--To ensure that the gmatch works, temporarily insert a \t character after
		--each closed curly brace, otherwise adjacent override blocks with no text
		--in between won't match
		--Yes, this is kind of hacky
		ltext=ltext:gsub("}","}\t")
		
		--Match for pairs of tags followed by text using the pattern "({[^}]*})([^{]*)"
		--Store these pairs in a new data structure
		tt_table={}
		for tg,tx in ltext:gmatch("({[^}]*})([^{]*)") do
			table.insert(tt_table,{tag=tg,text=tx:gsub("^\t","")})--Remove the \t we inserted
		end
		
		--See tutorial for a visual of what this new data structure looks like
		
		--These store the current values of the three parameters at the part of the line
		--we are looking at
		--Since we have not started looking at the line yet, these are set to the style defaults
		cur_fs=line.styleref.fontsize
		cur_fscx=line.styleref.scale_x
		cur_fscy=line.styleref.scale_y
		
		--This is where the new text will be stored
		rebuilt_text=""
		
		--Now rebuild the line piece-by-piece using the tag-text pairs stored in tt_table
		for _,tt in ipairs(tt_table) do
			--Set the current values to the tag overrides if they exist, otherwise keep values
			--x = A or B means x = A if A is not nil, otherwise x = B
			cur_fs=tonumber(tt.tag:match("\\fs([%d%.]+)")) or cur_fs
			cur_fscx=tonumber(tt.tag:match("\\fscx([%d%.]+)")) or cur_fscx
			cur_fscy=tonumber(tt.tag:match("\\fscy([%d%.]+)")) or cur_fscy
			
			--Use similar math as we did in the "simple" script to recalculate values
			--If the font size is less than 10, we cannot divide by 10 and floor or we'll
			--get a font size of zero, so use this to limit font size to at least 1
			new_fs=(cur_fs>10) and math.floor(cur_fs/10) or 1
			
			--Scale factor
			factor=cur_fs/new_fs
			
			--New scales
			new_fscx=math.floor(cur_fscx*factor)
			new_fscy=math.floor(cur_fscy*factor)
			
			--If an \fs tag is present
			if tt.tag:match("\\fs[%d%.]+")~=nil then
				
				--Remove any \fscx and \fscy tags
				tt.tag=tt.tag:gsub("\\fscx[%d%.]+","")
				tt.tag=tt.tag:gsub("\\fscx[%d%.]+","")
				
				--Sub in the new font size and scale tags
				tt.tag=tt.tag:gsub("\\fs[%d%.]+",
					string.format("\\fs%d\\fscx%d\\fscy%d",new_fs,new_fscx,new_fscy))
			
			else
				--If \fs is not present, then substitute and \fscx and \fscy that are there
				tt.tag=tt.tag:gsub("\\fscx[%d%.]+","\\fscx"..new_fscx)
				tt.tag=tt.tag:gsub("\\fscy[%d%.]+","\\fscy"..new_fscy)
			end
			
			--Rebuild line
			rebuilt_text=rebuilt_text..tt.tag..tt.text
		end
		
		--Replace the old line text with the rebuilt text
		line.text=rebuilt_text
		
		--Put the line back into the subtitles
		sub[li]=line
		
	end
	
	--Set undo point and maintain selection
	aegisub.set_undo_point(script_name)
	return sel
	
end

--Register macro
aegisub.register_macro(script_name,script_description,refont)
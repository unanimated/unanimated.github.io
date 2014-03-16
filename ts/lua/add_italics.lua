--[[
README:

Add Italics

Makes all lines in the selection italic.
]]

--Script properties
script_name="Make italic"
script_description="Italicizes selected lines"
script_author="lyger"
script_version="1.0"

--Main processing function
function italicize(sub, sel)
	
	--Go through all the lines in the selection
	for si,li in ipairs(sel) do
		
		--Read in the line
		local line=sub[li]
		
		--Add the italics. Don't forget to escape the slash
		line.text="{\\i1}"..line.text
		
		--Put the line back into the subtitles
		sub[li]=line
		
	end
	
	--Set undo point and maintain selection
	aegisub.set_undo_point(script_name)
	return sel
end

--Register macro (no validation function required)
aegisub.register_macro(script_name,script_description,italicize)
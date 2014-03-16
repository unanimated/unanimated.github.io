-- Adds blur 0.6, then cycles through 0.8, 1, 1.2, 1.5, 2, 3, 4, 5, 0.4, back to 0.6
-- Bind to a hotkey for better efficiency.

script_name="Blur Cycle"
script_description="Adds blur"
script_author="unanimated"
script_version="1.4"

function blur(subs, sel, act)
	for z, i in ipairs(sel) do
	   local line=subs[i]
	   local text=subs[i].text
		if text:match("\\t") then tf=text:match("(\\t%([^%)]-%))") 
		text=text:gsub("\\t%([^%)]+%)","\\_transform_") end
		
		if text:match("\\blur") and not text:match("\\blur0.[468][\\}]") and
			not text:match("\\blur[12345][\\}]") and not text:match("\\blur1.[25][\\}]")
		then
		text=text:gsub("^({[^}]-)\\blur[%d%.]*([\\}])","%1\\blur0.6%2")
		elseif text:match("^{[^}]-\\blur0%.6[\\}]") then
		text=text:gsub("^({[^}]-)\\blur0%.6","%1\\blur0.8")
		elseif text:match("^{[^}]-\\blur0%.8[\\}]") then
		text=text:gsub("^({[^}]-)\\blur0%.8","%1\\blur1")
		elseif text:match("^{[^}]-\\blur1[\\}]") then
		text=text:gsub("^({[^}]-)\\blur1","%1\\blur1.2")
		elseif text:match("^{[^}]-\\blur1%.2[\\}]") then
		text=text:gsub("^({[^}]-)\\blur1%.2","%1\\blur1.5")
		elseif text:match("^{[^}]-\\blur1%.5[\\}]") then
		text=text:gsub("^({[^}]-)\\blur1%.5","%1\\blur2")
		elseif text:match("^{[^}]-\\blur2[\\}]") then
		text=text:gsub("^({[^}]-)\\blur2","%1\\blur3")
		elseif text:match("^{[^}]-\\blur3[\\}]") then
		text=text:gsub("^({[^}]-)\\blur3","%1\\blur4")
		elseif text:match("^{[^}]-\\blur4[\\}]") then
		text=text:gsub("^({[^}]-)\\blur4","%1\\blur5")
		elseif text:match("^{[^}]-\\blur5[\\}]") then
		text=text:gsub("^({[^}]-)\\blur5","%1\\blur0.4")
		elseif text:match("^{[^}]-\\blur0%.4[\\}]") then
		text=text:gsub("^({[^}]-)\\blur0%.4","%1\\blur0.6")
		else
		text="{\\blur0.6}" .. text
		text=text:gsub("{\\blur0%.6}{\\","{\\blur0.6\\")
		end
		if tf~=nil then text=text:gsub("\\_transform_",tf) end
	   line.text=text
	   subs[i]=line
	end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, blur)
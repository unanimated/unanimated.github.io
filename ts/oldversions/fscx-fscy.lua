script_name = "Match fscy to fscx"
script_description = "Matches fscy to fscx"
script_author = "unanimated"
script_version = "one"

function fscxfscy(subs, sel)
    for i=#sel,1,-1 do
        local line=subs[sel[i]]
        local text=subs[sel[i]].text
	if text:match("\\fscx") and text:match("\\fscy") then
	scalx=text:match("\\fscx([%d%.]+)")
	text=text:gsub("\\fscy[%d%.]+","\\fscy"..scalx)
	end
	line.text=text
	subs[sel[i]]=line
    end
end

aegisub.register_macro(script_name, script_description, fscxfscy)
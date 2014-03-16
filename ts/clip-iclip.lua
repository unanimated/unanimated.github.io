script_name = "Clip to iclip"
script_description = "Converts clip to iclip and vice versa"
script_author = "unanimated"
script_version = "one"

function clipiclip(subs, sel)
    for i=#sel,1,-1 do
        local line=subs[sel[i]]
        local text=subs[sel[i]].text
	if text:match("\\clip") then text=text:gsub("\\clip","\\iclip")
	elseif text:match("\\iclip") then text=text:gsub("\\iclip","\\clip") end
	line.text=text
	subs[sel[i]]=line
    end
end

aegisub.register_macro(script_name, script_description, clipiclip)
script_name="Hide Clip"
script_description="Quickly hides/unhides clips"
script_author="unanimated"
script_version="1.0"

function hide_clip(subs,sel)
    for x,i in ipairs(sel) do
        line=subs[i]
	text=line.text
		stags=text:match("^{\\[^}]-}") or ""
		stags=trem(stags)
		if stags:match "\\i?clip" then
			for klip in stags:gmatch("\\i?clip%b()") do
				k2=klip:gsub("\\","//")
				stags=stags:gsub(esc(klip),"")
				text=text.."{"..k2.."}"
			end
		elseif text:match "//i?clip" then
			for klip in text:gmatch("//i?clip%b()") do
				k2=klip:gsub("//","\\")
				text=text:gsub(esc(klip),"")
				stags=stags.."{"..k2.."}"
			end
		end		
		stags=stags.."{"..trnsfrm.."}"
		stags=stags:gsub("}{","")
		text=stags:gsub("{}","")..text:gsub("^{\\[^}]-}",""):gsub("{}","")
	if line.text~=text then line.text=text subs[i]=line end
    end
    return sel
end

function trem(tags)
	trnsfrm=""
	for t in tags:gmatch("\\t%b()") do trnsfrm=trnsfrm..t end
	tags=tags:gsub("\\t%b()","")
	return tags
end

function esc(str) str=str:gsub("[%%%(%)%[%]%.%-%+%*%?%^%$]","%%%1") return str end

aegisub.register_macro(script_name,script_description,hide_clip)
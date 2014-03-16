script_name = "Nuke Linebreaks"
script_description = "Nukes Linebreaks"
script_author = "unanimated"
script_version = "1.3"

function nobreak(subs, sel)
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
            local line = subs[i]
            local text = subs[i].text
	    if line.style:match("Defa") or line.style:match("Alt") or line.style:match("Main") then
	    text = text:gsub("%s?\\[Nn]%s?"," ")
	    text = text:gsub("^%s*","")
	    text = text:gsub("%s$","")
	    line.text = text
            subs[i] = line
	    end
	end
    end
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, nobreak)
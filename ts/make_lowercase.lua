local tr = aegisub.gettext

script_name = tr"Make text lowercase"
script_description = tr"Makes text lowercase"
script_author = "unknown"
script_version = "1.01"

function lower(subs, sel)
    for x, i in ipairs(sel) do
            local line = subs[i]
	    line.text = line.text:lower ()
	    subs[i] = line
	    end
end

function nn(subs, sel)
    for x, i in ipairs(sel) do
            local line = subs[i]
            local text = subs[i].text
	    text = text:gsub("\\n","\\N")
	    line.text = text
            subs[i] = line
    end
end

function lower_macro(subs, sel)
    lower(subs, sel)
    nn(subs, sel)
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, lower_macro)
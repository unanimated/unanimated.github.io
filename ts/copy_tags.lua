-- Copies tags from first selected line to the rest of selected lines.

script_name = "Copy Tags"
script_description = "Copy tags from first line to others"
script_author = "unanimated"
script_version = "1.0"

function copytags(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	    if x==1  then
	      tags=text:match("^({\\[^}]*})")
	    end
	    if x~=1 then
	      if text:match("^({\\[^}]*})") then
	      text=text:gsub("^{\\[^}]*}",tags) else
	      text=tags..text
	      end
	    end
	    line.text = text
	    subs[i] = line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, copytags)
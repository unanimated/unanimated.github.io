--[[ This script is for removing some unneeded stuff like comments
Currently there are 5 functions
1. Remove TS timecodes like {TS 12:36}
2. Remove comments from lines
3. Delete commented lines
4. Clear Actor and Effect fields
5. All of the above + set dialogue layer to 3
Everything now works for selected lines.			]]

script_name = "Remove TS timecodes"
script_description = "Removes TS timecodes."
script_author = "unanimated"
script_version = "1.09"

function nots(subs, sel)			-- remove {TS} comments from selected lines - lets you keep other comments
    for x, i in ipairs(sel) do
            local line = subs[i]
            local text = subs[i].text
            text = text:gsub("{TS[^}]*}%s*","")
	    text = text:gsub("^%s*","")
	    line.text = text
            subs[i] = line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function nocom(subs, sel)			-- remove all {comments} from selected lines
    for x, i in ipairs(sel) do
            local line = subs[i]
            local text = subs[i].text
	    text = text:gsub("^({[^}]*})%s*","%1")
	    text = text:gsub("{[^\\}]*}","")
	    text = text:gsub("{[^\\}]*\\N[^\\}]*}","")
	    text = text:gsub("^%s*","")
	    line.text = text
            subs[i] = line
    end
    return sel
end

function nocom_line(subs, sel)			-- delete commented lines from selected lines
	count=#sel
	i=sel[1]
	while i<sel[1]+count do
		line=subs[i]
		if line.comment == true then
			subs.delete(i)
			count=count-1
		else
			i=i+1
		end
	end
end

function clear_ae(subs, sel)			-- clear actor and effect fields in selected lines
    for x, i in ipairs(sel) do
            local line = subs[i]
	    line.actor=""
	    line.effect=""
            subs[i] = line
    end
    return sel
end

function clear_all(subs, sel)			-- remove comments, delete commented lines, clear actor + effect, set dialogue layer to 3
    clear_ae(subs, sel)
    nocom(subs, sel)
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
		local line = subs[i]
		if line.style:match("Defa") or line.style:match("Alt") then line.layer=3 end
		subs[i] = line	
	end
    end
    nocom_line(subs, sel)
    aegisub.set_undo_point("Clear all")
    return sel
end

aegisub.register_macro(script_name, script_description, nots)
aegisub.register_macro("Remove comments from lines", "Removes comments from selected lines", nocom)
aegisub.register_macro("Delete commented lines", "Deletes commented lines", nocom_line)
aegisub.register_macro("Clear Actor and Effect fields", "Clears Actor and Effect fields", clear_ae)
aegisub.register_macro("Clear All - Comments, Actor, Effect", "Deletes comments, Actor, and Effect", clear_all)
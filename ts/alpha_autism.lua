-- Alpha Autism v 1.4
-- adds variations of {\alpha&HFF&\fscx60}.{\r} after linebreaks based on punctuation
-- if you're not alpha-autistic, you don't need to understand any of this

script_name = "Alpha Autism"
script_description = "If you're alpha-autistic, you know what this does"
script_author = "unanimated"
script_version = "1.4"


function aa(subs, sel)
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
            local line = subs[i]
	    local text = subs[i].text
		if line.style:match("Default") or line.style:match("Alt") then	-- apply only to Default or Alt* styles
		    if line.text:match("\\N") then					-- look only at lines with \N
			text = text:gsub("%s*\\N%s*","\\N")				-- nuke spaces around \N
			text = text:gsub("{\\i0}$","")					-- nuke {\i0} at the end of line
			line.text = text
			if line.text:match("%.%.%.$") and line.text:match("%.%.%.\\N")==nil then	-- bottom ends with ... and top doesn't
			    if line.text:match("[%.%,]\\N") then
			    text = text:gsub("\\N","\\N{\\alpha&HFF&\\fscx60}%.%.{\\r}")		-- 2 periods if top has . or ,
			    else
			    text = text:gsub("\\N","\\N{\\alpha&HFF&\\fscx60}%.%.%.{\\r}")		-- 3 if not
			    end
			else
			    if line.text:match("[%.%,]$") then
				if line.text:match("[%.%,]\\N")==nil then			-- if top line doesn't have . or ,
				text = text:gsub("\\N","\\N{\\alpha&HFF&\\fscx60}%.{\\r}")	-- do alpha autism
				text = text:gsub("\\r}{","\\r")				-- merge \r with possible other tags
				end
			    end
			end
				non=text:gsub("\\N.*","")	itl=""
				if non:match("\\i1") then						-- if there's \i1 before \N
				for it in non:gmatch("\\i([01])") do itl=itl..it end
				if itl:match("1$") then text = text:gsub("\\r","\\r\\i1") end		-- add it after \r
				end
		    end
		end
	    line.text = text
            subs[i] = line
	end
    end
end

function aa_macro(subs, sel)
    aa(subs, sel)
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, aa_macro)
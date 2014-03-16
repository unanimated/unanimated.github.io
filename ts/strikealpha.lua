--	Replaces strikeout or underline tags with \alpha&H00& or \alpha&HFF&. Also @.
--	@	->	{\alpha&HFF&}
--	@0	->	{\alpha&H00&}
--	{\u1}	->	{\alpha&HFF&}
--	{\u0}	->	{\alpha&H00&}
--	{\s0}	->	{\alpha&HFF&}
--	{\s1}	->	{\alpha&H00&}
--	@E3@	->	{\alpha&HE3&}

script_name = "StrikeAlpha"
script_description = "StrikeAlpha"
script_author = "unanimated"
script_version = "1.1"

function strikealpha(subs, sel)
    for x, i in ipairs(sel) do
        local l=subs[i]
	l.text=l.text
	:gsub("\\s1","\\alpha&H00&")
	:gsub("\\s0","\\alpha&HFF&")
	:gsub("\\u1","\\alpha&HFF&")
	:gsub("\\u0","\\alpha&H00&")
	:gsub("@(%x%x)@","{\\alpha&H%1&}")
	:gsub("@0","{\\alpha&H00&}")
	:gsub("@","{\\alpha&HFF&}")
	subs[i]=l
    end
end

aegisub.register_macro(script_name, script_description, strikealpha)
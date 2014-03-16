script_name = "ShadowyBorderx"
script_description = "Convert bord to xbord+ybord and shad to xshad+yshad."
script_author = "unanimated"
script_version = "1.1"			-- reads also from style

include("karaskel.lua")

function shadbord(subs, sel)
local meta,styles=karaskel.collect_head(subs,false)
    for x, i in ipairs(sel) do
        local l=subs[i]
	karaskel.preproc_line(subs,meta,styles,l)
	border=l.styleref.outline
	shadow=l.styleref.shadow
	l.text=l.text:gsub("\\bord([%d%.]+)","\\xbord%1\\ybord%1")
	l.text=l.text:gsub("\\shad([%d%.%-]+)","\\xshad%1\\yshad%1")
	if not l.text:match("\\[xy]?shad") then l.text="{\\xshad"..shadow.."\\yshad"..shadow.."}"..l.text
		l.text=l.text:gsub("({\\xshad[%d%.]+\\yshad[%d%.]+)}{\\","%1\\") end
	if not l.text:match("\\[xy]?bord") then l.text="{\\xbord"..border.."\\ybord"..border.."}"..l.text
		l.text=l.text:gsub("({\\xbord[%d%.]+\\ybord[%d%.]+)}{\\","%1\\") end
	subs[i]=l
    end
end

aegisub.register_macro(script_name, script_description, shadbord)
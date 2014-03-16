-- Draw a vectorial clip with the inbuild tool. Run this script to convert it to a vector drawing.
-- If you had \pos, the drawing _should_ now be in the exact place the clip was. It also keeps the tags in the first block.

script_name = "Convert clip to drawing"
script_description = "Converts clip to drawing"
script_author = "unanimated"
script_version = "1.2"

function convertclip(subs, sel)
    for z, i in ipairs(sel) do
	local l = subs[i]
	text=l.text
	if not text:match("\\clip") then aegisub.cancel() end
	text=text:gsub("^({\\[^}]-}).*","%1")
	text=text:gsub("^({[^}]*)\\clip%(m(.-)%)([^}]*)}","%1%3\\p1}m%2")
	if text:match("\\pos") then
	    local xx,yy=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
	    xx=round(xx) yy=round(yy)
	    ctext=text:match("}m ([%d%a%s%-]+)")
	    ctext2=ctext:gsub("([%d%-]+)%s([%d%-]+)",function(a,b) return a-xx.." "..b-yy end)
	    ctext=ctext:gsub("%-","%%-")
	    text=text:gsub(ctext,ctext2)
	end
	if not text:match("\\pos") then text=text:gsub("^{","{\\pos(0,0)") end
	if text:match("\\an") then text=text:gsub("\\an%d","\\an7") else text=text:gsub("^{","{\\an7") end
	if text:match("\\fscx") then text=text:gsub("\\fscx[%d%.]+","\\fscx100") else text=text:gsub("\\p1","\\fscx100\\p1") end
	if text:match("\\fscy") then text=text:gsub("\\fscy[%d%.]+","\\fscy100") else text=text:gsub("\\p1","\\fscy100\\p1") end
	l.text=text
	subs[i] = l
    end
    aegisub.set_undo_point(script_name)
end

function round(num)
	if num-math.floor(num)>=0.5 then num=math.ceil(num) else num=math.floor(num) end
	return num
end

aegisub.register_macro(script_name, script_description, convertclip)
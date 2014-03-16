-- Makes text appear letter by letter or word by word in specified intervals.
-- Might be buggy under various circumstances...

script_name = "Show text letter by letter"
script_description = "Inserts \ko tags before letters or words to make them appear one by one"
script_author = "unanimated, lyger"
script_version = "1.1"


function koko_da(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	tekst1 = text:match("^([^{]*)")
	    if res.word==false then
	--letter
		for text2 in text:gmatch("}([^{]*)") do
		text2m=text2:gsub("([%w%s%.,%?%!])","{\\ko"..res.ko.."}%1")
		text2=escape_string(text2)
		text=text:gsub(text2,text2m)
		end
		if tekst1~=nil then
		tekst1m=tekst1:gsub("([%w%s%.,%?%!])","{\\ko"..res.ko.."}%1")
		tekst1=escape_string(tekst1)
		text=text:gsub(tekst1,tekst1m)
		end
	    else
	--word
		for text2 in text:gmatch("}([^{]*)") do
		text2m=text2:gsub("([%w\']+)","{\\ko"..res.ko.."}%1")
		text2=escape_string(text2)
		text=text:gsub(text2,text2m)
		end
		if tekst1~=nil then
		tekst1m=tekst1:gsub("([%w\']+)","{\\ko"..res.ko.."}%1")
		tekst1=escape_string(tekst1)
		text=text:gsub(tekst1,tekst1m)
		end
	    end
	if text:match("^{")==nil then text=text:gsub("^","{\\ko"..res.ko.."}") end
	text=text:gsub("^{","{\\2a&HFF&")
	text=text:gsub("\\({\\ko[%d]+})N","\\N%1")
	text=text:gsub("\\ko[%d]+(\\ko[%d]+)","%1")
	line.text = text
        subs[i] = line
    end
end

function escape_string(str)
	str=str:gsub("%%","%%%%")
	str=str:gsub("%(","%%%(")
	str=str:gsub("%)","%%%)")
	str=str:gsub("%[","%%%[")
	str=str:gsub("%]","%%%]")
	str=str:gsub("%.","%%%.")
	str=str:gsub("%*","%%%*")
	str=str:gsub("%-","%%%-")
	str=str:gsub("%+","%%%+")
	str=str:gsub("%?","%%%?")
	return str
end
function konfig(subs, sel)
	dialog_config=
	{
	    {x=0,y=0,width=2,height=1,class="label",label="Make text appear over time...",},	
	    {x=0,y=1,width=1,height=1,class="label",label="Letter by letter or:",},
	    {x=1,y=1,width=1,height=1,class="checkbox",name="word",label="word by word",value=false},
	    {x=0,y=2,width=1,height=1,class="label",label="Interval for \\ko:",},
	    {x=1,y=2,width=1,height=1,class="floatedit",name="ko",value="8",},
    	    {x=0,y=3,width=2,height=1,class="label",label="[Doesn't work with \\shad. '10' = 100ms.]",},
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,{"KO","Cancel"})
	if pressed=="Cancel" then aegisub.cancel() end
	if pressed=="KO" then koko_da(subs, sel) end
end

function ko(subs, sel)
    konfig(subs, sel) 
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, ko)
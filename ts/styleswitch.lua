script_name="Style Switch"
script_description="Style Switch"
script_author="unanimated"
script_version="1.0"

function sswitch(subs,sel)
    styles={}
    for i=1,#subs do
        if subs[i].class=="style" then
	    table.insert(styles,subs[i])
	end
	if subs[i].class=="dialogue" then break end
    end
    for x, i in ipairs(sel) do
	line=subs[i]
	style=line.style
	for a,st in ipairs(styles) do
	  if st.name==style then
	    if styles[a+1] then newstyle=styles[a+1].name else newstyle=styles[1].name end
	    style=newstyle
	  break end
	end
	if style==line.style then style=styles[1].name end
	line.style=style
	subs[i]=line
    end
end

aegisub.register_macro(script_name,script_description,sswitch)
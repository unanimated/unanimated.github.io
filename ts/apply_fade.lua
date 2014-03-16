-- For regular fade, type only fade in / fade out.
-- checking alpha will use alpha transform instead, with the fade in/out values and accel.
-- checking colours will do colour transforms (with accel). if only one checked, the other will be alpha transform.
-- checking blur will do a blur transform with given start and end blur (and accel), using the current blur as the middle value.
-- in case of user stupidity, ie. blur missing, 0.6 is used as default.
-- for letter by letter, the dropdown is for each letter, while fade in/out are for the overall fades.

script_name="Apply fade"
script_description="Applies fade to selected lines"
script_author="unanimated"
script_version="3.0"

--	SETTINGS	--

default_in=0
default_out=0
default_lbl="120"
default_accel_in=1
default_accel_out=1
default_blur_in=3
default_blur_out=3
default_rtl=false
remember_last_settings=false	-- [true/false] if set to "true", settings will be remembered from last session

--	--	--	--

re=require'aegisub.re'

function fade(subs, sel)
    fadein=res.fadein 
    fadeout=res.fadeout 

    for z, i in ipairs(sel) do
	local line=subs[i]
	local text=subs[i].text
	    -- remove existing fade
	    if line.text:match("\\fad%(") then
	    text=text:gsub("\\fad%([%d%.%,]-%)","")
	    end

		-- standard fade
		if pressed=="Apply Fade" then
		text="{\\fad("..fadein..","..fadeout..")}"..text
		text=text:gsub("%)}{\\",")\\")
		text=text:gsub("{}","")
		end

	    -- letter by letter
	    if pressed=="Letter by Letter" then
		
	    -- delete old letter-by-letter if present
		if text:match("\\t%([%d,]+\\alpha[^%(%)]+%)}[%w%p]$") then
		    text=text:gsub("\\t%([^%(%)]-%)","")
		    text=text:gsub("\\alpha&H%x+&","")
		    text=text:gsub("{}","")
		end

	    if not res.del then
		
		-- fail if letter fade is larger than total fade
		lf=tonumber(res.letterfade)
		if fadein>0 and fadein<=lf or fadeout>0 and fadeout<=lf then aegisub.dialog.display({{class="label",
		    label="The fade for each letter must be smaller than overall fade.",x=0,y=0,width=1,height=2}},
			{"Fuck! Sorry, I'm stupid. Won't happen again."}) 
		aegisub.cancel() end
		-- mode: in, out, both
		if fadeout==0 then mode=1 
		elseif fadein==0 then mode=2
		else mode=3 end

		-- save initial tags; remove other tags/comments
		tags=""
		if text:match("^{\\[^}]*}") then tags=text:match("^({\\[^}]*})") end
		text=text:gsub("{[^}]*}","")
		text=text:gsub("%s*$","")
		text=text:gsub("\\N","*")

		-- define variables
		dur=line.end_time-line.start_time
		outfade=dur-fadeout

		--aegisub.log("fadein: "..fadein.."   lf: "..lf.."   length: "..length.."   ftime1: "..ftime1)

		    -- letter-by-letter fade happens here
		    count=0
		    text3=""
		    al=tags:match("^{[^}]-\\alpha&H(%x%x)&")
		    if al==nil then al="00" end

		    matches=re.find(text,"[\\w[:punct:]][\\s\\\\*]*")
		    length=#matches
		    ftime1=((fadein-lf)/(length-1))
		    ftime2=((fadeout-lf)/(length-1))

		    for _,match in ipairs(matches) do
		    ch=match.str
		    if res.rtl then fin1=math.floor(ftime1*(#matches-count-1)) else fin1=math.floor(ftime1*count) end
		    fin2=fin1+lf
		    if res.rtl then fout1=math.floor(ftime2*(#matches-count-1)+outfade) else fout1=math.floor(ftime2*count+outfade) end
		    fout2=fout1+lf
		    if mode==1 then text2m="{\\alpha&HFF&\\t("..fin1..","..fin2..",\\alpha&H"..al.."&)}"..ch end
		    if mode==2 then text2m="{\\alpha&H"..al.."&\\t("..fout1..","..fout2..",\\alpha&HFF&)}"..ch end
		    if mode==3 then 
		    text2m="{\\alpha&HFF&\\t("..fin1..","..fin2..",\\alpha&H"..al.."&)\\t("..fout1..","..fout2..",\\alpha&HFF&)}"..ch end
		    text3=text3..text2m
		    count=count+1
		    end
		    

		-- join saved tags + new text with transforms
		text=tags..text3
		text=text:gsub("}{","")
		text=text:gsub("%*","\\N")
		end

	    end -- not del

	line.text=text
	subs[i]=line
    end
end

function fadalpha(subs, sel)
	if res.clr or res.crl then res.alf=true end
	for z, i in ipairs(sel) do
	    local line=subs[i]
	    local text=subs[i].text
	    styleref=stylechk(subs,line.style)
	    dur=line.end_time-line.start_time

	    col1=res.c1:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col2=res.c2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")

		text=text:gsub("\\1c","\\c")
		fadin=res.fadein	fadout=res.fadeout
		blin="\\blur"..res.bli	blout="\\blur"..res.blu
		primary=styleref.color1:gsub("H%x%x","H")
		pri=text:match("^{\\[^}]-\\c(&H%x+&)")		if pri~=nil then primary=pri end
		outline=styleref.color3:gsub("H%x%x","H")
		out=text:match("^{\\[^}]-\\3c(&H%x+&)")		if out~=nil then outline=out end
		border=styleref.outline
		bord=text:match("^{[^}]-\\bord([%d%.]+)")	if bord~=nil then border=tonumber(bord) end

		kolora1="\\c"..col1	kolora3="\\3c"..col1	kolora="\\c"..col1.."\\3c"..col1
		kolorb1="\\c"..col2	kolorb3="\\3c"..col2	kolorb="\\c"..col2.."\\3c"..col2
		a00="\\alpha&H00&"	aff="\\alpha&HFF&"	lb=""
		
		-- blur w/o alpha
		if res.blur then lineblur=text:match("^{\\[^}]-(\\blur[%d%.]+)")
		    if lineblur==nil then lineblur="\\blur0.6" end
		    text=text:gsub("^({[^}]-)\\blur[%d%.]+","%1")
		    text=text:gsub("^{}","{\\}")
		    if fadin==0 then lb=lineblur else lb="" end
		    if not res.alf then 
		    if fadin~=0 then text=text:gsub("^({\\[^}]-)}","%1"..blin.."\\t(0,"..fadin..","..res.inn..","..lineblur..")}") end
		    if fadout~=0 then text=text:gsub("^({\\[^}]-)}","%1"..lb.."\\t("..dur-fadout..",0,"..res.ut..","..blout..")}") end
		    end
		end
		if not res.blur then lineblur="" blin="" blout="" end

	-- with alpha in line
	    if res.alf then
		if text:match("\\alpha&H%x%x&") then

		    if fadin~=0 then
		-- fade from colour
			    if res.crl then
			text=text:gsub("^({\\[^}]-)\\c&H%x+&","%1")
			text=text:gsub("^({\\[^}]-)\\3c&H%x+&","%1")
			text=text:gsub("^({\\[^}]-)}",
			"%1"..kolora..blin.."\\t(0,"..fadin..","..res.inn..",\\c"..primary.."\\3c"..outline..lineblur..")}")
		-- inline colour tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\[13]?c") then
					col1="" col3=""
					if t:match("\\c&") then col1=t:match("(\\c&H%x+&)") end
					if t:match("\\3c") then col3=t:match("(\\3c&H%x+&)") end
			t2=t:gsub("\\c&H%x+&",kolora1)	
			t2=t2:gsub("\\3c&H%x+&",kolora3)	
			t2=t2:gsub("({[^}]-)}","%1\\t(0,"..fadin..","..res.inn..","..col1..col3..")}")
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
		-- fade from alpha
			    else
			if text:match("^{\\[^}]-\\alpha&H%x%x&") then
			text=text:gsub("^{(\\[^}]-)(\\alpha&H%x%x&)([^}]-)}","{%1%3"..blin.."\\alpha&HFF&\\t(0,"..fadin..","..res.inn..",%2"..lineblur..")}")
			else 
			text=text:gsub("^{(\\[^}]-)}","{%1"..blin..aff.."\\t(0,"..fadin..","..res.inn..","..lineblur..a00..")}")
			end
		-- inline alpha tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\alpha") then
				arfa=t:match("(\\alpha&H%x+&)")
			t2=t:gsub("\\alpha&H%x+&",aff)	
			t2=t2:gsub("({[^}]-)}","%1\\t(0,"..fadin..","..res.inn..","..arfa..")}")
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
			    end
		    end

		    if fadout~=0 then
		-- fade to colour
			    if res.clr then
			text=text:gsub("^({\\[^}]-)}","%1"..lb.."\\t("..dur-fadout..",0,"..res.ut..","..kolorb..blout..")}")
		-- inline colour tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\[13]?c") 
				or t~=text:match("^{\\[^}]-}") and t:match("\\alpha") then
			t2=t:gsub("({\\[^}]-)}","%1\\t("..dur-fadout..",0,"..res.ut..","..kolorb..")}")
			if not t:match("\\c&") and not t:match("\\alpha") then t2=t2:gsub("\\c&H%x+&","") end
			if not t:match("\\3c") and not t:match("\\alpha") then t2=t2:gsub("\\3c&H%x+&","") end
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
		-- fade to alpha
			    else
			text=text:gsub("^({\\[^}]-)}","%1"..lb.."\\t("..dur-fadout..",0,"..res.ut..","..blout..aff..")}")
		-- inline alpha tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\alpha") then
				
			t2=t:gsub("({\\[^}]-)}","%1\\t("..dur-fadout..",0,"..res.ut..","..aff..")}")
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
			    end
		    end
	-- without alpha
		else

		    if fadin~=0 then
		-- fade from colour
			    if res.crl then
			text=text:gsub("^({\\[^}]-)\\c&H%x+&","%1")
			text=text:gsub("^({\\[^}]-)\\3c&H%x+&","%1")
			text=text:gsub("^({\\[^}]-)}",
			"%1"..kolora..blin.."\\t(0,"..fadin..","..res.inn..",\\c"..primary.."\\3c"..outline..lineblur..")}")
		-- inline colour tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\[13]?c") then
				col1="" col3=""
				if t:match("\\c&") then col1=t:match("(\\c&H%x+&)") end
				if t:match("\\3c") then col3=t:match("(\\3c&H%x+&)") end
			t2=t:gsub("\\c&H%x+&",kolora1)	
			t2=t2:gsub("\\3c&H%x+&",kolora3)
			t2=t2:gsub("({[^}]-)}","%1\\t(0,"..fadin..","..res.inn..","..col1..col3..")}")
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
		-- fade from alpha
			    else
			text=text:gsub("^({\\[^}]-)}","%1"..blin..aff.."\\t(0,"..fadin..","..res.inn..","..lineblur..a00..")}")
			    end
		    end

		    if fadout~=0 then
		-- fade to colour
			    if res.clr then
			text=text:gsub("^({\\[^}]-)}","%1"..lb.."\\t("..dur-fadout..",0,"..res.ut..","..kolorb..blout..")}") 
		-- inline colour tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\[13]?c") then
			t2=t:gsub("({\\[^}]-)}","%1\\t("..dur-fadout..",0,"..res.ut..","..kolorb..")}")
			if not t:match("\\c&") then t2=t2:gsub("\\c&H%x+&","") end
			if not t:match("\\3c") then t2=t2:gsub("\\3c&H%x+&","") end
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
		-- fade to alpha
			    else
			text=text:gsub("^({\\[^}]-)}","%1"..lb.."\\t("..dur-fadout..",0,".. res.ut..","..blout..aff..")}")
			    end
		    end
		end
		if border==0 then  text=text:gsub("\\3c&H%x+&","") end
		if not text:match("\\fad%(0,0%)") then text=text:gsub("\\fad%(%d+,%d+%)","") end	-- nuke fade
		text=text:gsub("\\\\","\\")
	    end
	    line.text=text
	    subs[i]=line
	end
end

function esc(str)
str=str
:gsub("%%","%%%%")
:gsub("%(","%%%(")
:gsub("%)","%%%)")
:gsub("%[","%%%[")
:gsub("%]","%%%]")
:gsub("%.","%%%.")
:gsub("%*","%%%*")
:gsub("%-","%%%-")
:gsub("%+","%%%+")
:gsub("%?","%%%?")
return str
end

function stylechk(subs,stylename)
  for i=1, #subs do
    if subs[i].class=="style" then
      local st=subs[i]
      if stylename==st.name then styleref=st end
    end
  end
  return styleref
end

function fadeconfig(subs, sel)
    rls=remember_last_settings
    if lastin==nil or rls==false then lastin=default_in end
    if lastout==nil or rls==false then lastout=default_out end
    if lastlbl==nil or rls==false then lastlbl=default_lbl end
    if lastrtl==nil or rls==false then lastrtl=default_lbl end
    if lastaccin==nil or rls==false then lastaccin=default_accel_in end
    if lastaccout==nil or rls==false then lastaccout=default_accel_out end
    if lastblin==nil or rls==false then lastblin=default_blur_in end
    if lastblout==nil or rls==false then lastblout=default_blur_out end
    if lastalf==nil or rls==false then lastalf=false end
    if lastblur==nil or rls==false then lastblur=false end
    if lastfrom==nil or rls==false then lastfrom=false end
    if lastto==nil or rls==false then lastto=false end
    if lastc1==nil or rls==false then lastc1=nil end
    if lastc2==nil or rls==false then lastc2=nil end
	dialog_config=
	{
	    {x=0,y=0,width=4,height=1,class="label",label="fade  /  alpha/c/blur transform", },
	    {x=0,y=1,width=1,height=1,class="label",label="Fade in:"},
	    {x=0,y=2,width=1,height=1,class="label",label="Fade out:"},
	    {x=1,y=1,width=3,height=1,class="floatedit",name="fadein",min=0,value=lastin},
	    {x=1,y=2,width=3,height=1,class="floatedit",name="fadeout",min=0,value=lastout},
	    {x=4,y=0,width=1,height=1,class="checkbox",name="alf",label="alpha",value=lastalf},
	    {x=5,y=0,width=1,height=1,class="checkbox",name="blur",label="blur",value=lastblur},
	    {x=4,y=1,width=1,height=1,class="checkbox",name="crl",label="from:",value=lastfrom},
	    {x=4,y=2,width=1,height=1,class="checkbox",name="clr",label="to:",value=lastto},
	    {x=5,y=1,width=1,height=1,class="color",name="c1",value=lastc1},
	    {x=5,y=2,width=1,height=1,class="color",name="c2",value=lastc2},
	    {x=0,y=3,width=1,height=1,class="label",label="accel:",},
	    {x=1,y=3,width=3,height=1,class="floatedit",name="inn",value=lastaccin,hint="accel in - <1 starts fast, >1 starts slow"},
	    {x=4,y=3,width=2,height=1,class="floatedit",name="ut",value=lastaccout,hint="accel out - <1 starts fast, >1 starts slow"},
	    {x=0,y=4,width=1,height=1,class="label",label="blur:",},
	    {x=1,y=4,width=3,height=1,class="floatedit",name="bli",value=lastblin,min=0,hint="start blur"},
	    {x=4,y=4,width=2,height=1,class="floatedit",name="blu",value=lastblout,min=0,hint="end blur"},
	    
	    {x=0,y=5,width=1,height=1,class="label",label="By letter:"},
	    {x=1,y=5,width=1,height=1,class="dropdown",name="letterfade",
		items={"40","80","120","160","200","250","300","350","400","450","500","1000"},value=lastlbl},
	    {x=2,y=5,width=2,height=1,class="label",label="ms/letter", },
	    {x=4,y=5,width=1,height=1,class="checkbox",name="rtl",label="rtl",value=false,hint="right to left"},
	    {x=5,y=5,width=1,height=1,class="checkbox",name="del",label="X",value=false,hint="delete letter-by-letter"},
	} 	
	pressed, res=aegisub.dialog.display(dialog_config,{"Apply Fade", "Letter by Letter","Cancel"},{ok='Apply Fade',cancel='Cancel'})
	if pressed=="Apply Fade" then if res.alf or res.blur or res.clr or res.crl then fadalpha(subs, sel) else fade(subs, sel) end end
	if pressed=="Letter by Letter" then fade(subs, sel) end
	lastin=res.fadein		lastout=res.fadeout
	lastaccin=res.inn		lastaccout=res.ut
	lastblin=res.bli		lastblout=res.blu
	lastalf=res.alf			lastblur=res.blur
	lastfrom=res.crl		lastto=res.clr
	lastc1=res.c1			lastc2=res.c2
	lastlbl=res.letterfade		lastrtl=res.rtl
end

function apply_fade(subs, sel)
    fadeconfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, apply_fade)
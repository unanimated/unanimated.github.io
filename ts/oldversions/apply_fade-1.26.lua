-- Applies fade to selected lines. GUI lets you select or type fade-in / fade-out values.

script_name="Apply fade"
script_description="Applies fade to selected lines"
script_author="unanimated"
script_version="1.26"

--	SETTINGS	--

default_in="500"
default_out="500"
defaultype_in=0
defaultype_out=0
default_lbl="120"
remember_last_settings=false	-- [true/false] if set to "true", the lead-ins and lead-outs will be remembered from last session

--	--	--	--

function fade(subs, sel)
    fadein=res.txtfadein 
    fadeout=res.txtfadeout 
    if fadein==0 and fadeout==0 then
    fadein=tonumber(res.fadein)
    fadeout=tonumber(res.fadeout)
    end

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
		nospace=text:gsub(" ","")
		length=nospace:len()
		ftime1=math.floor((fadein-lf)/(length-1))
		ftime2=math.floor((fadeout-lf)/(length-1))

		--aegisub.log("fadein: "..fadein.."   lf: "..lf.."   length: "..length.."   ftime1: "..ftime1)

		    -- letter-by-letter fade happens here
		    count=0
		    text3=""
		    al=tags:match("^{[^}]-\\alpha&H(%x%x)&")
		    if al==nil then al="00" end
		    for text2 in text:gmatch("([%w%p][%s%*]?)") do
		    fin1=ftime1*count
		    fin2=fin1+lf
		    fout1=ftime2*count+outfade
		    fout2=fout1+lf
		    if mode==1 then text2m="{\\alpha&HFF&\\t("..fin1..","..fin2..",\\alpha&H"..al.."&)}"..text2 end
		    if mode==2 then text2m="{\\alpha&H"..al.."&\\t("..fout1..","..fout2..",\\alpha&HFF&)}"..text2 end
		    if mode==3 then 
		    text2m="{\\alpha&HFF&\\t("..fin1..","..fin2..",\\alpha&H"..al.."&)\\t("..fout1..","..fout2..",\\alpha&HFF&)}"..text2 end
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

function fadeconfig(subs, sel)
    rls=remember_last_settings
    if lastin==nil or rls==false then lastin=default_in end
    if lastout==nil or rls==false then lastout=default_out end
    if lastxtin==nil or rls==false then lastxtin=defaultype_in end
    if lastxtout==nil or rls==false then lastxtout=defaultype_out end
    if lastlbl==nil or rls==false then lastlbl=default_lbl end
	dialog_config=
	{
	    {x=0,y=1,width=1,height=1,class="label",label="Fade in:"},
	    {x=0,y=2,width=1,height=1,class="label",label="Fade out:"},
	    {x=5,y=1,width=2,height=1,class="floatedit",name="txtfadein",min=0,value=lastxtin},
	    {x=5,y=2,width=2,height=1,class="floatedit",name="txtfadeout",min=0,value=lastxtout},
	    {x=2,y=1,width=2,height=1,class="dropdown",name="fadein",
	items={"0","100","150","200","250","300","350","400","450","500","750","1000","1500","2000","3000","5000"},value=lastin },
	    {x=2,y=2,width=2,height=1,class="dropdown",name="fadeout",
	items={"0","100","150","200","250","300","350","400","450","500","750","1000","1500","2000","3000","5000"},value=lastout },
	    {x=0,y=0,width=3,height=1,class="label",label="Select fade to apply...", },
	    {x=5,y=0,width=2,height=1,class="label",label="or type values:", },
    	    {x=0,y=3,width=7,height=1,class="label",label="Typed values apply if not 0, otherwise selected.", },
	    {x=4,y=2,width=1,height=1,class="label",label=" ",},
	    
	    {x=0,y=4,width=2,height=1,class="label",label="Letter by letter:"},
	    {x=2,y=4,width=2,height=1,class="dropdown",name="letterfade",
		items={"40","80","120","160","200","250","300","350","400","450","500"},value=lastlbl },
	    {x=4,y=4,width=2,height=1,class="label",label="ms for each letter", },
	    
	    {x=6,y=4,width=1,height=1,class="checkbox",name="del",label="X",value=false,hint="delete letter-by-letter"},
	} 	
	pressed, res=aegisub.dialog.display(dialog_config,{"Apply Fade", "Letter by Letter","Cancel"},{ok='Apply Fade',cancel='Cancel'})
	if pressed=="Apply Fade" or pressed=="Letter by Letter" then fade(subs, sel) end
	lastin=res.fadein
	lastout=res.fadeout
	lastxtin=res.txtfadein
	lastxtout=res.txtfadeout
	lastlbl=res.letterfade
end

function apply_fade(subs, sel)
    fadeconfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

function apply_fade2(subs, sel)
    fade(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, apply_fade)
--aegisub.register_macro("Apply fade with last settings", script_description, apply_fade2)
script_name = "CrunchyRoll script mod"
script_description = "modifies CR scripts"
script_author = "unanimated"
script_version = "summer 2013"

require "clipboard"

function crmod(subs)
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
            local line = subs[i]
            local text = subs[i].text

		-- change main style to Default
		if line.style:match("[Mm]ain") or line.style:match("[Oo]verlap") 
		or line.style:match("[Ii]nternal")  or line.style:match("[Ff]lashback") 
		then line.style="Default" end

		-- nuke tags from signs, set actor to "Sign", add timecode
		if line.style:match("Defa")==nil then
		text = text:gsub("{[^\}]*}","")
		line.actor="Sign"
		timecode=math.floor(line.start_time/1000)
		tc1=math.floor(timecode/60)
		tc2=timecode%60+1
		if tc1<10 then tc1="0"..tc1 end
		if tc2<10 then tc2="0"..tc2 end
		text="{TS "..tc1..":"..tc2.."}"..text
		if line.style:match("[Tt]itle") then text=text:gsub("({TS %d%d:%d%d)}","%1 Title}") end

		else
		text=text:gsub("\\N"," ")
		text=text:gsub("\\a6","\\an8")
		line.style="Default"
		line.text = text
		end

		-- some general replacements
		text = text:gsub("^%s*","")
		text = text:gsub("%s%s"," ")
		text = text:gsub("{\\i0}$","")

	    	-- fill in blank actor lines
		if res.actors then
		  if line.actor=="" then
			local prevline = subs[i-1]
			    if prevline.class=="dialogue" and prevline.actor~="Sign" then
				line.actor = prevline.actor
			    end
		  end	
		else
		  line.actor=""
		end
		
		-- Kami Nomi
		if res.kaminomi then
		text=text:gsub("Goido([^u])","Goidou%1")
		text=text:gsub("Kujo([^u])","Kujou%1")
		text=text:gsub("Goido$","Goidou")
		text=text:gsub("Kujo$","Kujou")
		end
		
	    line.text = text
            subs[i] = line
        end
    end
end    

-- move signs to the top of the script

function crsort(subs)
	i=1	moved=0
	while i<=(#subs-moved) do
	    line=subs[i]
	    if line.class=="dialogue" and line.style=="Default" then
		subs.delete(i)
		moved=moved+1
		subs.append(line)
	    else
		i=i+1
	    end
	end
end

-- copy text from selected lines
function copyall(subs, sel)
	copylines=""
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
        local line = subs[i]
	local text=subs[i].text
	      if x~=#subs then copylines=copylines..text.."\n" end
	      if x==#subs then copylines=copylines..text end
	subs[i] = line
	end
    end
    copydialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=copylines},}
    pressed,res=aegisub.dialog.display(copydialog,{"OK","Copy to clipboard"})
    if pressed=="Copy to clipboard" then    clipboard.set(copylines) end
end

function crunch(subs, sel)
	dialog_config=
	{
	    {x=0,y=5,width=1,height=1,class="checkbox",name="export",label="export for pad",value=true,},
	    {x=0,y=6,width=1,height=1,class="checkbox",name="actors",label="keep actors",value=false,},
	    {x=2,y=5,width=1,height=1,class="checkbox",name="kaminomi",label="twgok",value=false,},
	    {x=0,y=0,width=15,height=5,class="textbox",name="dat"},
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,
		{"CR","Cancel"})
	if pressed=="Cancel" then    aegisub.cancel() end
	
	if pressed=="CR" then crmod(subs) crsort(subs)  if res.export then copyall(subs) end  end
    
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, crunch)
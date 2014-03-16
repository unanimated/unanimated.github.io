script_name = "Quality Check"
script_description = "Quality Check"
script_author = "unanimated"
script_version = "1.8"

require "clipboard"

function qc(subs, sel)

sorted=0	mblur=0		layer=0		malf=0		inside=0	comment=0	dialog=0	bloped=0
dis=0		over=0		gap=0		dspace=0	outside=0	op=0		ed=0		sign=0
italics=0	lbreak=0	hororifix=0	zeroes=0	badita=0	dotdot=0	comfail=0
report=""

  if results["raiselayer"] or results["clear"] or results["clearqc"] then
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
            local line = subs[i]
		-- raise layer for dialogue
		if results["raiselayer"]==true then
		if line.style:match("Defa") or line.style:match("Alt") then line.layer=line.layer+5 end
		end
		-- clear actor/effect
		if results["clear"]==true then
		line.actor=""
		line.effect=""
		end
		-- clear qc notes
		if results["clearqc"]==true then
		line.actor=line.actor:gsub(" %[time gap %d+ms%]","")
		line.actor=line.actor:gsub(" %.%.%.timer pls","")
		line.effect=line.effect:gsub(" %[malformed tags%]","")
		line.effect=line.effect:gsub(" %[disjointed tags%]","")
		line.effect=line.effect:gsub(" %.%.%.sort by time pls","")
		line.effect=line.effect:gsub(" %[doublespace%]","")
		line.effect=line.effect:gsub(" -MISSING BLUR-","")
		line.effect=line.effect:gsub(" %[%.%.%]","")
		end
            subs[i] = line
        end
    end
  end

  if results["clear"]==false and results["clearqc"]==false then
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	nocomment=text:gsub("{[^}]-}","")
	start=line.start_time
	endt=line.end_time
	if i<#subs then nextline=subs[i+1] end
	prevline=subs[i-1]
	prevstart=prevline.start_time
	prevend=prevline.end_time

	-- check for blur
	if results["blur"]==true then
	if line.comment==false and line.style:match("Defa")==nil and line.style:match("Alt")==nil and text~=""
	and text:match("\\blur")==nil and endt>0 and text:match("^{[^}]*}$")==nil and text:match("^{first")==nil then
		if results["blurfix"]==true then
		text=text:gsub("^","{\\blur"..results["addblur"].."}")	text=text:gsub("({\\blur[%d%.]*)}{\\","%1\\")
		
		else
		line.effect=line.effect.." -MISSING BLUR-"
		mblur=mblur+1
		if line.style:match("^OP") or line.style:match("^ED") then bloped=bloped+1 end
		end
		
	end	end
	
	
	-- check for malformed tags
	if results["malformed"]==true and line.comment==false then
	if text:match("\\\\")
	or text:match("\\}") 
	or text:match("}}") 
	or text:match("{{") 
	or text:match("\\blur%.") 
	or text:match("\\bord%.") 
	or text:match("\\shad%.")
	or text:match("\\alpha[^&]")
	or text:match("\\alpha&[^H]")
	or text:match("\\alpha&H%x&")
	or text:match("\\alpha&H%x%x[^&]")
	or text:match("\\[1234]a[^&]")
	or text:match("\\[1234]a&[^H]")
	or text:match("\\[1234]c[^&]")
	or text:match("\\[1234]?c&[^H]")
	then line.effect=line.effect.." [malformed tags]" malf=malf+1 end
	clrfail=0
	for clr in text:gmatch("c&H(%x+)&") do
	if clr:len()~=6 then clrfail=1 end	end
	if clrfail==1 then line.effect=line.effect.." [malformed tags]" malf=malf+1 end
	end
	
	
	-- check for disjointed tags
	if results["disjointed"]==true and line.comment==false then
	if text:match("{\\[^}]*}{\\[^}]*}")
	then line.effect=line.effect.." [disjointed tags]" dis=dis+1 end
	end

	
	-- check if sorted by time
	if results["sorted"]==true then
	if prevline.class=="dialogue" and line.comment==false and start<prevstart then
		line.effect=line.effect.." ...sort by time pls"
		sorted=1
	end	end
	
	
	-- check for overlaps and gaps
	if results["overlap"]==true and line.comment==false then
	if prevline.class=="dialogue" and line.style:match("Defa") and prevline.style:match("Defa") 
	and text:match("\\an8")==nil and prevline.text:match("\\an8")==nil then
		if start<prevend and prevend-start<500 and endt-prevend~=0 then 
		line.actor=line.actor.." [overlap "..prevend-start.."ms]" over=over+1 
			if prevend-start<100 then line.actor=line.actor.." ...timer pls" end
		end
		if start>prevend and start-prevend<200 then 
		line.actor=line.actor.." [time gap "..start-prevend.."ms]" gap=gap+1 
			if start-prevend<100 then line.actor=line.actor.." ...timer pls" end
		end
	end	end
	
	
	-- check dialogue layer
	if results["dlayer"]==true then
	if line.style:match("Defa") and line.layer==0 or line.style:match("Alt") and line.layer==0 then layer=layer+1 
	end	end
	
	
	-- check for double spaces in dialogue
	if results["doublespace"]==true then
	if line.style:match("Defa") or line.style:match("Alt") then
		if nocomment:match("%s%s") then line.effect=line.effect.." [doublespace]" dspace=dspace+1 end
	end	end
	
	-- check for fucked up comments
	if nocomment:match("[{}]") then comfail=comfail+1 line.effect=line.effect.." [comment fail]" end
	
	-- check for bad italics - {\i1}   {\i1}
	itafail=0
	itl=""
	for it in text:gmatch("\\i([01])") do itl=itl..it end
	if itl:match("11") or itl:match("00") then itafail=1 end
	if itafail==1 then line.effect=line.effect.." italics fail" badita=badita+1 end
	
	-- check for double periods
	if line.style:match("Defa") or line.style:match("Alt") then
	if nocomment:match("[^%.]%.%.[^%.]") or nocomment:match("[^%.]%.%.$") then line.effect=line.effect.." [..]" dotdot=dotdot+1 end
	end
	
	-- check for periods/commas inside/outside quotation marks
	if line.comment==false and nocomment:match("[%.%,]\"") then inside=inside+1 end
	if line.comment==false and nocomment:match("\"[%.%,][^%.]") then outside=outside+1 end
	
	-- Hdr request against jdpsetting
	if text:match("{\\an8\\bord[%d%.]+\\pos%([%d%.%,]*%)}") then line.actor=" What are you doing..." end
	
	-- count commented lines
	if line.comment==true then comment=comment+1 end
	
	-- count dialogue lines
	if line.style:match("Defa") or line.style:match("Alt") then dialog=dialog+1 end
	
	-- count OP lines
	if line.style:match("^OP") then op=op+1 end
	
	-- count ED lines
	if line.style:match("^ED") then ed=ed+1 end
	
	-- count what's probably signs
	if line.style:match("Defa")==nil and line.style:match("Alt")==nil 
	and line.style:match("^OP")==nil and line.style:match("^ED")==nil then sign=sign+1 end 
	
	-- count linebreaks in dialogue
	if results["lbreax"]==true then
	if line.style:match("Defa") or line.style:match("Alt") then
		if nocomment:match("\\N") then lbreak=lbreak+1 end
	end	end
	
	-- count lines with italics
	if results["italix"]==true then
	if line.style:match("Defa") or line.style:match("Alt") then
		if text:match("\\i1") then italics=italics+1 end
	end	end
	
	-- count honorifics
	if results["honorifix"]==true and line.comment==false then
	if line.style:match("Defa") or line.style:match("Alt") then
		if nocomment:match("%a%-san") then hororifix=hororifix+1 line.actor=line.actor.."honorofix" end
		if nocomment:match("%a%-kun") then hororifix=hororifix+1 line.actor=line.actor.."honorofix" end
		if nocomment:match("%a%-chan") then hororifix=hororifix+1 line.actor=line.actor.."honorofix" end
		if nocomment:match("%a%-sama") then hororifix=hororifix+1 line.actor=line.actor.."honorofix" end
		if nocomment:match("%a%-senpai") then hororifix=hororifix+1 line.actor=line.actor.."honorofix" end
		if nocomment:match("%a%-sensei") then hororifix=hororifix+1 line.actor=line.actor.."honorofix" end
	end	end
	
	-- count lines with 0 time
	if results["zero"]==true then
	if endt==start then zeroes=zeroes+1 line.actor=line.actor.." 0 time" end
	end
	
	line.text = text
        subs[i] = line
    end
    if #sel==1 then  report=report.."Selection: "..#sel.." line,   "
    else report=report.."Selection: "..#sel.." lines,   " end
    report=report.."Commented: "..comment.."\n"
    report=report.."Dialogue: "..dialog..",   OP: "..op..",   ED: "..ed..",   TS: "..sign.."\n"
    if results["lbreax"]==true then report=report.."Dialogue lines with linebreaks... "..lbreak.."\n" end
    if results["italix"]==true then report=report.."Dialogue lines with italics tag... "..italics.."\n" end
    if results["honorifix"]==true then report=report.."Honorifics found... "..hororifix.."\n" end
    if results["zero"]==true then report=report.."Lines with zero time... "..zeroes.."\n" end
    if sorted==1 then report=report.."NOT SORTED BY TIME.\n" end
    if mblur~=0 then report=report.."Non-dialogue lines with missing blur... "..mblur.."\n" end
    if bloped~=0 then report=report.."Out of those OP/ED... "..bloped.."\n" end
    if malf~=0 then report=report.."Lines with malformed tags... "..malf.."\n" end
    if dis~=0 then report=report.."Lines with disjointed tags... "..dis.."\n" end
    if over~=0 then report=report.."Suspicious timing overlaps... "..over.."\n" end
    if gap~=0 then report=report.."Suspicious gaps in timing (under 200ms)... "..gap.."\n" end
    if dspace~=0 then report=report.."Dialogue lines with double spaces... "..dspace.."\n" end
    if dotdot~=0 then report=report.."Dialogue lines with double periods... "..dotdot.."\n" end
    if badita~=0 then report=report.."Lines with bad italics... "..badita.."\n" end
    if comfail~=0 then report=report.."Fucked up comments... "..comfail.."\n" end
    if inside~=0 and outside~=0 then 
    report=report.."Comma/period inside quotation marks... "..inside.."\n"
    report=report.."Comma/period outside quotation marks... "..outside.."\n" end
    if layer~=0 then report=report.."Dialogue may overlap with TS. Set to higher layer to avoid.\n" end
    if sorted==0 and mblur==0 and malf==0 and dis==0 and over==0 and gap==0 and dspace==0 and dotdot==0 and badita==0 and comfail==0 then
    report=report.."Congratulations. No serious problems found.\n" end
    
        reportdialog=
	{{x=0,y=0,width=40,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=40,height=15,class="textbox",name="copytext",value=report},}
    pressed,res=aegisub.dialog.display(reportdialog,{"OK","Copy to clipboard","Cancel"},{ok='OK',cancel='Cancel'})
    if pressed=="Copy to clipboard" then clipboard.set(report) end	if pressed=="Cancel" then aegisub.cancel() end
  end
end

function konfig(subs, sel)
	dialog_config=
	{
	{x=1,y=0,width=3,height=1,class="label",label="Note: Only styles matching 'Defa' or 'Alt' are considered dialogue"},
	{x=1,y=1,width=1,height=1,class="label",label="Analysis [for SELECTED lines]:"   },
        {x=1,y=2,width=1,height=1,class="checkbox",name="sorted",label="Check if sorted by time",value=true},
	{x=1,y=3,width=1,height=1,class="checkbox",name="blur",label="Check for missing blur in signs",value=true},
	{x=1,y=4,width=1,height=1,class="checkbox",name="overlap",label="Check for overlaps and gaps",value=true},
	{x=1,y=5,width=1,height=1,class="checkbox",name="malformed",label="Check for malformed tags - \\blur.5, \\alphaFF, \\\\",value=true},
	{x=1,y=6,width=1,height=1,class="checkbox",name="disjointed",label="Check for disjointed tags - {\\tags...}{\\tags...}",value=true},
	{x=1,y=7,width=1,height=1,class="checkbox",name="doublespace",label="Check for double spaces in dialogue",value=true},
	{x=1,y=8,width=1,height=1,class="checkbox",name="dlayer",label="Check dialogue layer",value=true},
	
	{x=2,y=1,width=2,height=1,class="label",label="More useless statistics..."},
	{x=2,y=2,width=2,height=1,class="checkbox",name="italix",label="Count dialogue lines with italics tag",value=false},
	{x=2,y=3,width=2,height=1,class="checkbox",name="lbreax",label="Count dialogue lines with linebreaks",value=false},
	{x=2,y=4,width=2,height=1,class="checkbox",name="honorifix",label="Count honorifics (-san, -kun, -chan)",value=false},
	{x=2,y=5,width=2,height=1,class="checkbox",name="zero",label="Count lines with 0 time",value=false},
	
	{x=1,y=10,width=3,height=1,class="label",label="Modifications [for ALL lines]:"},
	{x=1,y=11,width=1,height=1,class="checkbox",name="raiselayer",label="Raise dialogue layer by 5 [for the whole script]",value=false},
	{x=1,y=12,width=1,height=1,class="checkbox",name="clear",label="Clear Actor and Effect [will NOT run analysis]",value=false},
	{x=1,y=13,width=1,height=1,class="checkbox",name="clearqc",label="Clear only QC notes from Actor / Effect",value=false},
	{x=1,y=14,width=1,height=1,class="checkbox",name="blurfix",label="Add blur to signs (and OP/ED) that don't have it:",value=false},
	{x=2,y=14,width=1,height=1,class="floatedit",name="addblur",value=0.6,min=0.4,step=0.1},
	{x=1,y=15,width=1,height=1,class="label",label=""},
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,{">QC","Nope, I changed my mind. Fuck this fansubbing business."},
	{cancel='Nope, I changed my mind. Fuck this fansubbing business.'})  
	-- ^ comment this line if you enable the 3 below
	
	-- pressed, results = aegisub.dialog.display(dialog_config,{"QC","Nope, I changed my mind","Script Cleanup"})
	-- include("script_cleanup.lua")
	-- if pressed=="Script Cleanup" then cleanup(subs, sel) end
	
	if pressed==">QC" then qc(subs, sel) end
end

function kyuusii(subs, sel)
    konfig(subs, sel) 
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, kyuusii)
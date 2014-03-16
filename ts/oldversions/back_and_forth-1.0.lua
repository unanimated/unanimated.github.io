-- Transforms a sign back and forth between two states in specified intervals,
-- for example making the sign grow larger and smaller repeatedly each 600ms.

script_name = "Back and Forth Transform"
script_description = "Transforms between two sets of tags in specified intervals"
script_author = "unanimated"
script_version = "1.0"

include("karaskel.lua")

function tra(subs, sel)
local meta,styles=karaskel.collect_head(subs,false)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
	karaskel.preproc_line(sub,meta,styles,line)
	    int=results["int"]		-- get results from user input
	    tags1=results["intag"]
	    tags2=results["outag"]
	    dur=line.duration
	    count=math.ceil(dur/int)
	    t=1
	    tin=0
	    tout=tin+int
	    if text:match("^{")==nil then text="{\\}"..text end	-- add {\} if line has no tags
	    text=text:gsub("^({\\[^}]*)}","%1"..tags1.."}")		-- write initial tags
	    -- main function
	    while t<=math.ceil(count/2) do
		text=text:gsub("^({\\[^}]*)}","%1\\t("..tin..","..tout..","..tags2..")}")
		if tin+int<dur then
		text=text:gsub("^({\\[^}]*)}","%1\\t("..tin+int..","..tout+int..","..tags1..")}")	end
		tin=tin+int+int
		tout=tin+int
		t=t+1	    
	    end
	    text=text:gsub("{\\\\","{\\")	-- clean up \\
	    line.text = text
	    subs[i] = line
	end
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=0,width=3,height=1,class="label",label="Input two sets of tags to alternate between. and \\t interval.", },
	    {	x=0,y=1,width=1,height=1,class="label",label="Initial set of tags:", },
	    {	x=0,y=2,width=1,height=1,class="label",label="Alternating set of tags:", },
	    {	x=0,y=3,width=1,height=1,class="label",label="Interval in milliseconds:", },
	    {	x=0,y=4,width=3,height=1,class="label",label="NOTE: Initial set of tags should not already be in the line.", },
	    {	x=0,y=5,width=3,height=1,class="label",label="If it is, it will be duplicated. You can copy the tags from line,", },
	    {	x=0,y=6,width=3,height=1,class="label",label="delete them, then paste them here.", },
	    {	x=1,y=1,width=2,height=1,class="edit",name="intag",value="\\" },
	    {	x=1,y=2,width=2,height=1,class="edit",name="outag",value="\\" },
	    {	x=1,y=3,width=1,height=1,class="floatedit",name="int",value="0" },
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,{"Transform","Cancel"})
	if pressed=="Cancel" then aegisub.cancel() end
	if pressed=="Transform" then tra(subs, sel) end
end

function baf(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, baf)
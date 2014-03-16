-- deletes current content of the line and adds a mask with blur and no border
-- keeps only \pos tag, if present
-- you can choose from 5 shapes for the mask: square, rounded square, circle, equilateral triangle, right-angled triangle

script_name = "Add mask"
script_description = "Adds a mask"
script_author = "unanimated"
script_version = "1.5"

function addmask(subs, sel)
	for i=#sel,1,-1 do
	    local l = subs[sel[i]]
	    text=l.text
	    l1=l
	    l1.layer=l1.layer+1
	    if res.masknew then subs.insert(sel[i]+1,l1) end
	    l.layer=l.layer-1
	    
		l.text=l.text:gsub(".*(\\pos%([%d%,%.]-%)).*","%1")
		if l.text:match("\\pos")==nil then l.text="" end
		if res["mask"]=="square" then
		l.text="{\\an5\\bord0\\blur1"..l.text.."\\p1}m 0 0 l 100 0 100 100 0 100"
		end
		if res["mask"]=="rounded square" then
		l.text="{\\an7\\bord0\\blur1"..l.text.."\\p1}m -100 -25 b -100 -92 -92 -100 -25 -100 l 25 -100 b 92 -100 100 -92 100 -25 l 100 25 b 100 92 92 100 25 100 l -25 100 b -92 100 -100 92 -100 25 l -100 -25"
		end
		if res["mask"]=="circle" then
		l.text="{\\an7\\bord0\\blur1"..l.text.."\\p1}m -100 -100 b -45 -155 45 -155 100 -100 b 155 -45 155 45 100 100 b 46 155 -45 155 -100 100 b -155 45 -155 -45 -100 -100"
		end
		if res["mask"]=="equilateral triangle" then
		l.text="{\\an7\\bord0\\blur1"..l.text.."\\p1}m -122 70 l 122 70 l 0 -141"
		end
		if res["mask"]=="right-angled triangle" then
		l.text="{\\an7\\bord0\\blur1"..l.text.."\\p1}m -70 50 l 180 50 l -70 -100"
		end
		if l.text:match("\\pos")==nil then l.text=l.text:gsub("\\p1","\\pos(640,360)\\p1") end
		
	    subs[sel[i]] = l
	end
end

function maskonfig(subs, sel)	
	dialog_config=
	{
	    {x=0,y=0,width=1,height=1,class="label",label="Select the shape you want",},
	    {x=0,y=1,width=1,height=1,class="dropdown",name="mask",
	    items={"square","rounded square","circle","equilateral triangle","right-angled triangle"},value="square"},
	    {x=0,y=3,width=1,height=1,class="checkbox",name="masknew",label="create mask on a new line",value=true},
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,{"Create Mask","Cancel"})
	if pressed=="Cancel" then aegisub.cancel() end
	if pressed=="Create Mask" then addmask(subs, sel) end
end

function mask(subs, sel)
    maskonfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, mask)
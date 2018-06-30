script_name="Origami"
script_description="Moves origin point"
script_author="unanimated"
script_version="1.0"

function origami(subs,sel)
	ADD=aegisub.dialog.display
	ak=aegisub.cancel
	local G={
	{x=0,y=0,width=3,class="label",label="Move \\org by a given step in a given direction"},
	{x=0,y=1,class="label",label="Step: "},
	{x=1,y=1,class="floatedit",name="step",value=st or 10},
	{x=2,y=1,class="dropdown",name="xy",items={"X","Y"},value=dir or 'X'},
	}
	B={"-","+","esc"}
	P,res=ADD(G,B,{close='esc'})
	if P=='esc' then ak() end
	dir=res.xy	
	st=res.step
	S=st
	if P=="-" then S=0-S end
	
	for z,i in ipairs(sel) do
		line=subs[i]
		t=line.text
		t=t:gsub("\\org%(([^,]+),([^,]+)%)",function(x,y)
			if dir=='X' then x=x+S else y=y+S end
			return "\\org("..x..","..y..")"
			end)
		line.text=t
		subs[i]=line
	end
end

aegisub.register_macro("Origami",script_description,origami)
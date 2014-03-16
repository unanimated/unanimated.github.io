-- Opens a menu with styles for a line with an empty \\r tag and sets the selected name.

script_name="Reset Style"
script_description="Dropdown menu for choosing a style after \\r"
script_author="unanimated"
script_version="1.0"

function reset(subs,sel,act)
styles={}
for i=1,#subs do
    if subs[i].class=="style" then
	table.insert(styles,subs[i].name)
    end
    if subs[i].class=="dialogue" then break end
end
line=subs[act]
text=line.text
if text:match("\\r[\\}]") then
    dial={{x=0,y=0,width=8,height=1,class="dropdown",name="st",items=styles,value=styles[1]}}
    pressed,res=aegisub.dialog.display(dial,{"Yes","No"},{ok='Yes',close='No'})
    if pressed=="No" then aegisub.cancel() end
    text=text:gsub("\\r([\\}])","\\r"..res.st.."%1")
end
line.text=text
subs[act]=line
aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, reset)
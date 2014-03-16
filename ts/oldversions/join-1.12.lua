script_name = "Join lines"
script_description = "Join lines"
script_author = "unanimated"
script_version = "1.12"

function join(subs, sel, act)
	if act==#subs then aegisub.log("Nothing to join with.") aegisub.cancel() end
        l=subs[act]
        t=l.text
	l2=subs[act+1]
	t2=l2.text
	ct=t:gsub("{[^}]-}","")
	ct2=t2:gsub("{[^}]-}","")
	if ct~=ct2 then 
	  tt=t:match("{\\[^}]-}")
	  tt2=t2:match("{\\[^}]-}")
	  if tt~=nil and tt2~=nil then 
	    tt=tt:gsub("\\pos%([^%)]-%)","")
	    tt2=tt2:gsub("\\pos%([^%)]-%)","")
	  end
	  if tt==tt2 then t=t.." "..ct2 else t=t.." "..t2 end
	end
	if l2.end_time>l.end_time then l.end_time=l2.end_time end
	subs.delete(act+1)
	l.text=t
        subs[act]=l
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, join)
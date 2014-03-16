script_name="Rotated Shadow"
script_description="Rotates shadow along with frz"
script_author="unanimated"
script_version="1.0"

function shadowrot(subs, sel)
    for z, i in ipairs(sel) do
      local line=subs[i]
      local text=subs[i].text
      if text:match("\\frz") then
	stylechk(subs,line.style)
	lshad=text:match("^{[^}]-\\shad([%d%.]+)")
	shad=tonumber(lshad)
	if shad==nil then shad=styleref.shadow end
	rot=tonumber(text:match("\\frz([%d%.%-]+)"))
	if rot<0 then rot=rot+360 end
	if rot==0 then  x=1 				y=1 end
	if rot>0 then   x=(rot/45)*0.3+1 		y=1-(rot/45) end
	if rot>45 then  x=((90-rot)/45)*0.3+1 	y=1-(rot/45) end
	if rot>90 then  x=(135/rot)*2-2 		y=((90-rot)/45)*0.3-1 end
	if rot>135 then x=(180/rot)*3-4 		y=((180-rot)/45)*-0.3-1 end
	if rot>180 then x=((180-rot)/45)*0.3-1	y=(rot/45)-5 end
	if rot>225 then x=((270-rot)/45)*-0.3-1	y=(rot/45)-5 end
	if rot>270 then x=0-((315-rot)/45)		y=((rot-270)/45)*0.3+1 end
	if rot>315 then x=1-((360-rot)/45)		y=((360-rot)/45)*0.3+1 end
	
	x=tostring(x)	x=x:gsub("(%d%.%d%d)%d+","%1")
	y=tostring(y)	y=y:gsub("(%d%.%d%d)%d+","%1")
	
	if lshad==nil then text=text:gsub("^({\\[^}]-)}","%1\\xshad"..x*shad.."\\yshad"..y*shad.."}") end
	text=text:gsub("(\\shad)([%d%.]+)",function(a,b) return "\\xshad"..x*b.."\\yshad"..y*b end)

      end
      line.text=text
      subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
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

aegisub.register_macro(script_name, script_description, shadowrot)
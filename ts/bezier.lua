--Script Usage: Make a Bezier curve in aeigsub using the clip drawing function.
--The Curve can not consist of more than one line.
--{\k0} must be added before every letter, or the script will not work.
--For example: "Hello World" has to be "{\k0}H{\k0}e{\k0}l{\k0}l{\k0}o {\k0}W{\k0}o{\k0}r{\k0}l{\k0}d"
--Example Line: "{\clip(m 0 300 b 0 0 300 0 300 300)}{\k0}I{\k0}t {\k0}r{\k0}e{\k0}a{\k0}l{\k0}l{\k0}y {\k0}w{\k0}o{\k0}r{\k0}k{\k0}s{\k0}!"

include("karaskel.lua")

script_name = "Bezier Curve Imposition"
script_description = "An effect to impose text onto a Bezier curve"
script_author = "an eer?"
script_version = "0.92"

    function Bezier_impose(subs,sel)
            aegisub.progress.task("Getting header data...")
            local meta, styles = karaskel.collect_head(subs)
           
            aegisub.progress.task("Applying effect...")
            local i, ai, maxi, maxai = 1, 1, #sel, #sel
            while i <= maxi do
                    aegisub.progress.task(string.format("Applying effect (%d/%d)...", ai, maxai))
                    aegisub.progress.set((ai-1)/maxai*100)
                    local l = subs[sel[i]]
                    if l.class == "dialogue" and
                                    not l.comment then
                            karaskel.preproc_line(subs, meta, styles, l)
                            do_fx(subs, meta, l)
                            maxi = maxi - 1
                            subs.delete(sel[i])
                    else
                            i = i + 1
                    end
                    ai = ai + 1
            end
            aegisub.progress.task("Finished!")
            aegisub.progress.set(100)
    end



line_n,t,p = 0,{},{}
function do_fx(subs, meta, line)
for i = 1, line.kara.n do
local syl = line.kara[i]
local x=syl.center
local y=line.margin_v + 40

if i == 1 then
syl_n,arc,g,u =0,0,1,1
	for v in line.text:gmatch("%d+") do --Gets the Bezier points from the script. 
		p[u] = v
		u = u + 1
	end
end

--dt is the small steps from one point to another, must be a small number. 
dt = .0001;

--Define vars.
n,w,x_c,y_c = 0,1,{},{}

--Creates a set of t to evaluate, 0 to 1 in steps of dt. 
for w = 1,1/dt do
	t[w]=dt*w
end

--Finds the points of the Bezier curve for ever t.
for ii = 1,#(t) do 
    x_c[ii] = (1-t[ii])^3*p[1] + 3*t[ii]*p[3]*(1-t[ii])^2+3*t[ii]^2*p[5]*(1-t[ii])+p[7]*t[ii]^3;
    y_c[ii] = (1-t[ii])^3*p[2] + 3*t[ii]*p[4]*(1-t[ii])^2+3*t[ii]^2*p[6]*(1-t[ii])+p[8]*t[ii]^3;
end
 
--sums the arc lenght of the Bezier curve untill it reaches a letter.
while n == 0 do
    g = g + 1
    arc = ((x_c[g]-x_c[g-1])^2+(y_c[g]-y_c[g-1])^2)^.5 + arc
    if x < arc then
    n = 1
    end
end


--The derivative of the Bezier cruve, used to find the slope of the Bezier curve.
dx = 3*(-t[g]^2+2*t[g]-1)*p[1]+3*(3*t[g]^2-4*t[g]+1)*p[3]+3*(-3*t[g]^2+2*t[g])*p[5]+3*t[g]^2*p[7]
dy = 3*(-t[g]^2+2*t[g]-1)*p[2]+3*(3*t[g]^2-4*t[g]+1)*p[4]+3*(-3*t[g]^2+2*t[g])*p[6]+3*t[g]^2*p[8]

--Finds the angle of the slope.
if dx < 0 then
	theta = math.pi+math.atan(dy/dx)
	else
	theta = math.atan(dy/dx)
end

--Creates lines.
l = table.copy(line)
	l.text = string.format("{\\pos(%.2f,%.2f)\\frz%.2f}{%d}%s", x_c[g], y_c[g], -theta*(180/math.pi), #p, syl.text_stripped)
	l.start_time=line.start_time
    l.end_time=line.end_time
    l.layer = 1
subs.append(l)

line_n=line_n+1
syl_n=syl_n+(1000/line.kara.n)
	end

end

aegisub.register_macro("Bezier", "Impose test onto a Bezier curve", Bezier_impose)

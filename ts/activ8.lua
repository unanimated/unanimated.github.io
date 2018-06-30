script_name="Activ8"
script_description="Paranormal Activity"
script_author="unanimated"
script_version="1.0"

re=require'aegisub.re'

function substitution()
ADD=aegisub.dialog.display
ADP=aegisub.decode_path
ak=aegisub.cancel
ms2fr=aegisub.frame_from_ms
fr2ms=aegisub.ms_from_frame
ATAG="{[*>]?\\[^}]-}"
STAG="^{>?\\[^}]-}"
COMM="{[^\\}]-}"
end

function activ8(subs,sel,act)
	substitution()
	local P,res
	l=subs[act]
	t=l.text
	t=tagmerge(t)
	stag=t:match(STAG) or ""
	after=t:gsub(STAG,"")
	vis=t:gsub("%b{}","")
	nobreak=vis:gsub("\\[Nh]","")
	lay=l.layer MB=l.margin_t
	sty=l.style eff=l.effect ast=l.start_time aet=l.end_time

	data=""	
	styleref=stylechk(subs,sty) heather(subs)
	aligntop="789" alignbot="123" aligncent="456"
	alignleft="147" alignright="369" alignmid="258"
	stylereport=""
	if styleref==nil then styleref=defaref stylereport=stylereport.."Missing style. Using Default.\n" end
	if aligntop:match(styleref.align) then vert=styleref.margin_t
	elseif alignbot:match(styleref.align) then vert=resy-styleref.margin_t
	elseif aligncent:match(styleref.align) then vert=resy/2 end
	if alignleft:match(styleref.align) then horz=styleref.margin_l
	elseif alignright:match(styleref.align) then horz=resx-styleref.margin_r
	elseif alignmid:match(styleref.align) then horz=resx/2 end
	
	if styleref.bold then abold="Bold" else abold="Regular" end
	stylereport=stylereport.."Fontname: "..styleref.fontname.."\nFontsize: "..styleref.fontsize.."\nWeight: "..abold.."\nBorder: "..styleref.outline.."\nShadow: "..styleref.shadow.."\nAlignment: "..styleref.align.."\nDefault pos.: "..horz..","..vert

	if ms2fr(1) then afr=ms2fr(aet)-ms2fr(ast) else afr='?' end
	nfo='dur: '..(l.end_time-ast)/1000 ..' s ('..afr..' frames)'
	nfo=nfo:gsub("(%(1 frame)s","%1")
	chars=re.find(nobreak,'.')
	_,sp=nobreak:gsub(" ","")
	if chars then nfo=nfo..'\n\ncharacters: '..#chars..' ('..sp..' spaces)' end
	pos=stag:match('\\pos%(([^%)]+)%)')
	org=stag:match('\\org%(([^%)]+)%)')
	mov=stag:match('\\move%(([^%)]+)%)')
	klip=stag:match('\\clip%(([^%)m]+)%)')
	if pos and org then
		px,py=pos:match('([^,]+),([^,]+)')
		ox,oy=org:match('([^,]+),([^,]+)')
		pox=ox-px
		poy=oy-py
		tang=poy/pox
		ang1=math.deg(math.atan(tang))
		logg(ang1)
		podist=round(math.sqrt(pox^2+poy^2),2)
		nfo=nfo..'\n\npos-org dist: '..podist
	end
	if mov then
		x1,y1,x2,y2=mov:match('([^,]+),([^,]+),([^,]+),([^,)]+)')
		mov1=round(x2-x1,2)
		mov2=round(y2-y1,2)
		nfo=nfo..'\n\nmove: '..mov1..','..mov2
	end
	if klip then
		x1,y1,x2,y2=klip:match('([^,]+),([^,]+),([^,]+),([^,)]+)')
		k1=round(x2-x1,2)
		k2=round(y2-y1,2)
		nfo=nfo..'\n\nclip w/h: '..k1..','..k2
	end
	if stag:match('\\t%([^)]*\\fscx') then
		sc2=stag:match'\\t%([^)]*\\fscx([%d.]+)'
		notr=stag:gsub('\\t%b()','')
		sc1=notr:match'\\fscx([%d.]+)' or 100
		scrat=round(sc2/sc1,2)
		nfo=nfo..'\n\nscale x: '..scrat
	end
	
	data=stylereport..'\n\n'..nfo
	margins=l.margin_l..','..l.margin_r..','..l.margin_t
	
	-- start tags
	dissectag=stag:gsub("[{}]",""):gsub("\\","\n\\"):gsub("(\\t%b())","\n%1\n"):gsub("^\n",""):gsub("\n\n\n","\n\n")
	-- inline tags
	iTags=inline_pos(after:gsub("(\\[Nh])","{%1}"))
	itags='inline tags/comments/linebreaks:\n\n'
	if #iTags>0 then
		for k,v in ipairs(iTags) do
			itags=itags..v.n..': '..v.t..'\n'
		end
	end
	
	hbox=13
	GUI={
	-- replacer
	{x=0,y=hbox+2,width=2,class="label",label="ʀePlαcϵ:"},	
	{x=0,y=hbox+3,width=2,class="label",label="With:"},
	{x=2,y=hbox+2,width=14,class="edit",name="rep1"},
	{x=2,y=hbox+3,width=14,class="edit",name="rep2"},
	
	-- start tags
	{x=0,y=0,width=16,height=hbox,class="textbox",name="stags",value=dissectag},
	-- inline tags
	{x=20,y=0,width=18,height=hbox+7,class="textbox",name="itags",value=itags},
	-- text
	{x=0,y=hbox,width=20,class="edit",name="clean",value=nobreak,hint="clean text - edit this"},
	{x=0,y=hbox+1,width=20,class="edit",name="visible",value=vis,hint="includes linebreaks - don't edit"},

	-- style, effect, etc.
	{x=16,y=hbox+2,width=4,class="edit",name="sty",value=l.style,hint="style"},
	{x=16,y=hbox+3,width=4,class="edit",name="act",value=l.actor,hint="actor"},
	{x=16,y=hbox+4,width=4,class="edit",name="eff",value=eff,hint="effect"},
	{x=16,y=hbox+5,width=4,class="edit",name="marg",value=margins,hint="margins"},
	{x=8,y=hbox+5,width=8,class="floatedit",name="lay",value=lay,hint="layer"},
	{x=16,y=0,width=4,height=hbox-2,class="textbox",name="dat",value=data},		-- style info
	{x=16,y=hbox-2,class="label",label="✼፨❉"},
	{x=17,y=hbox-2,width=3,class="color"},
	{x=16,y=hbox-1,width=2,class="label",label="R๏ᘮᘯðᛧიg:"},
	{x=18,y=hbox-1,width=2,class="intedit",name="round",value=1,min=0,hint="decimal points"},
	{x=8,y=hbox+6,width=8,class="edit",name="calc",value=0,hint=""},
	
	-- modifiers
	{x=0,y=hbox+5,width=3,class="label",label="Start tags:"},
	{x=3,y=hbox+5,width=5,class="dropdown",name="start",value="round",items={"round","sort"}},
	{x=0,y=hbox+6,width=3,class="label",label="Inline:"},
	{x=3,y=hbox+6,width=5,class="dropdown",name="inline",value="round",items={"round"}},
	{x=16,y=hbox+6,width=2,class="label",label="  ҂  Shift:"},
	{x=18,y=hbox+6,width=2,class="intedit",name="shift",value=1,hint="shift inline tags by..."},
	
	-- checkboxes
	{x=0,y=hbox+4,width=4,class="checkbox",name="restart",label="start tags"},
	{x=4,y=hbox+4,width=4,class="checkbox",name="rein",label="inline tags"},
	{x=8,y=hbox+4,width=4,class="checkbox",name="retext",label="text"},
	{x=12,y=hbox+4,width=4,class="checkbox",name="regexp",label="regexp"},
	}
	repeat
		-- Operations
		if P=="ʀePlαcϵ" then
			r1=esc(res.rep1) r2=res.rep2
			if res.restart then
				if res.regexp then res.stags=re.sub(res.stags,res.rep1,r2)
				else res.stags=res.stags:gsub(r1,r2) end
			end
			if res.rein then
				if res.regexp then res.itags=res.itags:gsub(ATAG,function(a) return re.sub(a,res.rep1,r2) end)
				else res.itags=res.itags:gsub(ATAG,function(a) return a:gsub(r1,r2) end) end
			end
			if res.retext then
				if res.regexp then res.clean=re.sub(res.clean,res.rep1,r2)
				else res.clean=res.clean:gsub(r1,r2) end
			end
		end
		if P=="Start ※" then
			if res.start=="round" then
				res.stags=res.stags:gsub("(%d%.%d+)",function(n) return round(n,res.round) end)
			end
			if res.start=="sort" then res.stags=tagsort(res.stags,order) end
		end
		if P=="Inline ※" then
			if res.inline=="round" then
				res.itags=res.itags:gsub("(%d%.%d+)",function(n) return round(n,res.round) end)
			end
		end
		if P=="Shift inline" then
			inl=res.itags
			sh=res.shift
			inl=inl:gsub("(%d+):",function(n) return n+sh..":" end)
			res.itags=inl
		end
		if P=="田" then
			klp=makeclip(styleref,t)
			if klp then res.stags=res.stags:gsub("\\i?clip%b()\n?","").."\n"..klp end
		end
		if P=="⁕‡⁜" then
			local k=res.calc
			repeat
				k=k
				:gsub("%((%-?%d+%.?%d*)%+(%-?%d+%.?%d*)%)",function(a,b) return tostring(a+b) end)
				:gsub("%((%-?%d+%.?%d*)%-(%-?%d+%.?%d*)%)",function(a,b) return tostring(a-b) end)
				:gsub("%((%d+%.?%d*)%)","%1")
				:gsub("(%d+%.?%d*)%*(%-?%d+%.?%d*)",function(a,b) return tostring(a*b) end)
				:gsub("(%d+%.?%d*)%/(%-?%d+%.?%d*)",function(a,b) return tostring(a/b) end)
				:gsub("%((%d+%.?%d*)%)","%1")
				logg(k)
			until not k:match("[*/]")
			repeat
				k=k
				:gsub("(%-?%d+%.?%d*)([+-])(%-?%d+%.?%d*)",function(a,s,b)
				if s=='+' then return tostring(a+b) else return tostring(a-b) end
				end)
				logg(k)
			until not k:match(".[+-]")
			k=round(k,5)
			res.calc=k
		end
		if P=="Valid8" then
			stags=res.stags:gsub("\n","")
			inl=res.itags:gsub("%*\\","\\")
			itags=''
			for it in inl:gmatch('{[*>]?(\\.-)}') do itags=itags..it end
			valid8ion='\n\n>> Tags that look incorrect:\n'
			b1=valid8(stags)
			b2=valid8(itags)
			if b1~='' then valid8ion=valid8ion..b1 end
			if b2~='' then valid8ion=valid8ion..b2 end
			if b1~='' or b2~='' then res.dat=res.dat..valid8ion end
		end
		for k,v in ipairs(GUI) do
			if not res or res=={} then break end
			if v.name then v.value=res[v.name] end
		end
		P,res=ADD(GUI,{"☲☷☵☴","ʀePlαcϵ","Start ※","Inline ※","Shift inline","Valid8","⁕‡⁜","田","Deactiv8"},{ok='☲☷☵☴',close='Deactiv8'})
	until P=="☲☷☵☴" or P=="Deactiv8"
	
	if P=="Deactiv8" then    ak() end
	
	-- Saving	--	--	--
	if P=="☲☷☵☴" then
		amod=0
		
		-- start tags
		stag2=res.stags
		stag2=stag2:gsub("^ *",""):gsub(" *$","")
		stag2="{"..stag2:gsub(" *\n","").."}"
		stag2=stag2:gsub("{}","")
		
		-- inline
		inlines=res.itags:gsub(".*inline/comments/linebreaks:\n","")
		iTags2={}
		i=1
		for num,inl in inlines:gmatch("(%-?%d+): ({[^}]*})") do
			if tonumber(num)>0 then table.insert(iTags2,{n=num,t=inl,i=i}) i=i+1 end
		end
		table.sort(iTags2,function(a,b) return tonumber(a.n)<tonumber(b.n) or a.n==b.n and a.i<b.i end)
		nobreak2=res.clean
		local c=0
		repeat
			after2=inline_ret(nobreak2,iTags2)
			repeat after2,r=after2:gsub("{([^}]-)(\\[Nh])([^}]-)}","%2{%1%3}") until r==0
			after2=after2:gsub("{%**}",""):gsub("{>?\\[^}]+}$","")
			clean2=nobrea(after2):gsub("\\h","")
			if c>0 then logg(nobreak2) logg(clean2) end
			c=c+1
		until clean2==nobreak2 or c==666
		
		t2=stag..after
		if stag2:match("^{>?\\") and stag2~=stag then
			t2=stag2..after
			amod=1
		end
		if after2~=after then t2=stag2..after2 amod=1 end
		if math.floor(res.lay)~=l.layer then l.layer=math.floor(res.lay) amod=1 end
		if res.sty~=l.style then l.style=res.sty amod=1 end
		if res.act~=l.actor then l.actor=res.act amod=1 end
		if res.eff~=l.effect then l.effect=res.eff amod=1 end		
		if res.marg~=margins then
			m1,m2,m3=res.marg:match("^(%d+)[, ](%d+)[, ](%d+)$")
			if m1 then l.margin_l=tonumber(m1) l.margin_r=tonumber(m2) l.margin_t=tonumber(m3) amod=1 end
		end
		l.text=t2	
		if amod==1 then subs[act]=l end
	end
end

order="\\r\\fad\\fade\\an\\q\\blur\\be\\bord\\xbord\\ybord\\shad\\xshad\\yshad\\fn\\fs\\fsp\\fscx\\fscy\\frx\\fry\\frz\\fax\\fay\\c\\2c\\3c\\4c\\alpha\\1a\\2a\\3a\\4a\\pos\\move\\org\\clip\\iclip\\b\\i\\u\\s\\p"

function tagsort(tags,order)
	tags=tags:gsub("\\a6","\\an8"):gsub("\\1c","\\c"):gsub("^.-\\r","\\r")
	local trnsfrm=""
	for t in tags:gmatch("\\t%b()") do trnsfrm=trnsfrm..t:gsub("\n","") end
	tags=tags:gsub("\\t%b()","")
	local ord=""
	for tg in order:gmatch("\\[%w]+") do
		tag=tags:match("("..tg.."[^\\\n]*)")
		if tg=="\\fs" then tag=tags:match("(\\fs%d[^\\\n]*)") end
		if tg=="\\fad" then tag=tags:match("(\\fad%([^\\\n]*)") end
		if tg=="\\c" then tag=tags:match("(\\c&[^\\\n]*)") end
		if tg=="\\i" then tag=tags:match("(\\i%d)") end
		if tg=="\\s" then tag=tags:match("(\\s%d)") end
		if tg=="\\p" then tag=tags:match("(\\p%d)") end
		if tag then ord=ord..tag tags=tags:gsub(esc(tag),"") end
	end
	tags=tags:gsub("[\n ]","")
	if tags~="" then ord=ord..tags end
	ordered=ord..trnsfrm
	ordered=ordered:gsub("\\","\n\\"):gsub("(\\t%b())","\n%1\n"):gsub("^\n",""):gsub("\n\n\n","\n\n")
	return ordered
end

function makeclip(styleref,t)
	local SR,stag,vis,B,I,fsp,scx,scy,shx,shy,border,border2,fsize,posx,posy,an,anh,anv,X,XX,Y,YY,klp
	SR={}
	for k,v in pairs(styleref) do SR[k]=v end
	stag=t:match(STAG)
	vis=t:gsub("%b{}","")
	B=stag:match("\\b(%d)")
	I=stag:match("\\i(%d)")
	fsp=stag:match("\\fsp([%d.-]+)")
	if B=='1' then SR.bold=true elseif B=='0' then SR.bold=false end
	if I=='1' then SR.italic=true elseif I=='0' then SR.italic=false end
	if fsp then SR.spacing=tonumber(fsp) else fsp=0 end
	local w,h=aegisub.text_extents(SR,nobreak)
	if vis:match'\\N' then
		vis=vis:gsub("\\N","\n")
		seg={}
		for s in vis:gmatch("[^\n]+") do s=s:gsub("^ *(.-) *$","%1") table.insert(seg,s) end
		h=#seg*h
		w=0
		for s=1,#seg do
			w1=aegisub.text_extents(SR,seg[s])
			if w1>w then w=w1 end
		end
	end
	scx=stag:match("\\fscx([%d.]+)") or SR.scale_x
	scy=stag:match("\\fscy([%d.]+)") or SR.scale_y
	shx=stag:match("\\xshad([%d.-]+)") or stag:match("\\shad([%d.]+)") or SR.shadow
	shy=stag:match("\\yshad([%d.-]+)") or stag:match("\\shad([%d.]+)") or SR.shadow
	shx=tonumber(shx) shy=tonumber(shy)
	border=tonumber(stag:match("\\bord([%d.]+)")) or SR.outline
	border2=tonumber(t:match(".*\\bord([%d.]+)")) or SR.outline
	if border2>border then hbord= border2 else hbord=border end
	fsize=stag:match("\\fs([%d.]+)")
	if fsize then w=w*(fsize/SR.fontsize) h=h*(fsize/SR.fontsize) end
	w=round(w*(scx/100),1)
	h=round(h*(scy/100),1)
	posx,posy=stag:match('\\pos%(([^,]-),([^,]-)%)')
	if not posx then t_error("You need a \\pos tag for this.") return nil end
	an=tonumber(stag:match('\\an(%d)')) or SR.align
	local X,Y,XX,YY
	anh=an%3
	if anh==1 then X=posx
	elseif anh==2 then X=posx-w/2
	else X=posx-w end
	anv=math.ceil(an/3)
	if anv==1 then Y=posy-h
	elseif anv==2 then Y=posy-h/2
	else Y=posy end
	XX=X+w-(fsp/2)+border2+1
	YY=Y+h+border+1
	X=X-border-1
	Y=Y-border
	if shx<0 then X=X+shx elseif shx>0 then XX=XX+shx end
	if shy<0 then Y=Y+shy elseif shy>0 then YY=YY+shy end
	klp="\\clip("..math.floor(X)..","..math.floor(Y)..","..math.ceil(XX)..","..math.ceil(YY)..")"
	return klp
end

function valid8(tags)
	local one,num,neg,ac,par,bad
	one='\\i\\b\\u\\s'
	num='\\q\\a\\an\\p'
	dec='\\be\\blur\\bord\\fs\\fscx\\fscy\\K\\k\\kf\\ko\\xbord\\ybord\\shad'
	neg='\\frx\\fry\\frz\\fsp\\fax\\fay\\pbo\\xshad\\yshad'
	alf='\\alpha\\1a\\2a\\3a\\4a'
	col='\\c\\1c\\2c\\3c\\4c'
	par='\\fade?\\pos\\move\\org'
	klip='\\clip\\iclip'
	bad=''
	for tg in one:gmatch('\\%a') do
		for tag in tags:gmatch(tg..'(%d[^\\]*)') do
			if not tag:match("^[01]?$") then bad=bad..tg..tag..'\n' end
		end
	end
	for tg in num:gmatch('\\%a+') do
		for tag in tags:gmatch(tg..'(%d[^\\)]*)') do
			if not tag:match("^%d*$") then bad=bad..tg..tag..'\n' end
		end
	end
	for tg in dec:gmatch('\\%a+') do
		for tag in tags:gmatch(tg..'(%d[^\\)]*)') do
			if not tag:match("^%d+%.?%d*$") and not tag:match('') then bad=bad..tg..tag..'\n' end
		end
	end
	for tg in neg:gmatch('\\%a+') do
		for tag in tags:gmatch(tg..'([^\\)]*)') do
			if not tag:match("^%-?%d+%.?%d*$") and not tag:match('') then bad=bad..tg..tag..'\n' end
		end
	end
	for tg in alf:gmatch('\\[^\\]+') do
		for tag in tags:gmatch(tg..'([^\\)]*)') do
			if not tag:match("^&H%x%x&$") and not tag:match('') then bad=bad..tg..tag..'\n' end
		end
	end
	for tg in col:gmatch('\\[^\\]+') do
		for tag in tags:gmatch(tg..'([^\\)]*)') do
			if not tag:match("^&H%x%x%x%x%x%x&$") and not tag:match('') and not tag:match('^lip') then bad=bad..tg..tag..'\n' end
		end
	end
	for tg in par:gmatch('\\[^\\]+') do
		for tag in tags:gmatch(tg..'([^\\]*)') do
			if not tag:match("^%([%d.,-]+%)$") then bad=bad..tg..tag..'\n' end
		end
	end
	for tg in klip:gmatch('\\[^\\]+') do
		for tag in tags:gmatch(tg..'([^\\]*)') do
			if not tag:match("^%([%d.,mlb -]+%)$") then bad=bad..tg..tag..'\n' end
		end
	end
	if tags:match'\\\\' then bad=bad..'[double backslash]\n' end
	return bad
end

--	reanimatools	------------------------------------------
function esc(str) str=str:gsub("[%%%(%)%[%]%.%-%+%*%?%^%$]","%%%1") return str end
function addtag(tag,text) text=text:gsub("^({\\[^}]-)}","%1"..tag.."}") return text end
function round(n,dec) dec=dec or 0 n=math.floor(n*10^dec+0.5)/10^dec return n end
function quo(x) return "\""..x.."\"" end
function nobrea(t) return t:gsub("%b{}",""):gsub("\\N","") end
function nobrea1(t) return t:gsub("%b{}",""):gsub(" *\\[Nh] *"," ") end
function wrap(str) return "{"..str.."}" end
function tagmerge(t) repeat t,r=t:gsub("({\\[^}]-)}{(\\[^}]-})","%1%2") until r==0 return t end
function progress(msg) if aegisub.progress.is_cancelled() then ak() end aegisub.progress.title(msg) end
function logg(m) m=tf(m) or "nil" aegisub.log("\n "..m) end
function logg2(m)
	local lt=type(m)
	aegisub.log("\n >> "..lt)
	if lt=='table' then
		aegisub.log(" (#"..#m..")")
		if not m[1] then
			for k,v in pairs(m) do
				if type(v)=='table' then vvv='[table]' elseif type(v)=='number' then vvv=v..' (n)' elseif type(v)=='boolean' then vvv=tf(v) else vvv=v end
				aegisub.log("\n	"..k..': '..vvv)
			end
		elseif type(m[1])=='table' then aegisub.log("\n nested table")
		else aegisub.log("\n {"..table.concat(m,', ').."}") end
	else
		m=tf(m) or "nil" aegisub.log("\n "..m)
	end
end
function loggtab(m) m=tf(m) or "nil" aegisub.log("\n {"..table.concat(m,';').."}") end

function duplikill(tagz)
	local tags1={"blur","be","bord","shad","xbord","xshad","ybord","yshad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay"}
	local tags2={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}
	tagz=tagz:gsub("\\t%b()",function(t) return t:gsub("\\","|") end)
	for i=1,#tags1 do
	    tag=tags1[i]
	    repeat tagz,c=tagz:gsub("|"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%1%2") until c==0
	    repeat tagz,c=tagz:gsub("\\"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%2%1") until c==0
	end
	tagz=tagz:gsub("\\1c&","\\c&")
	for i=1,#tags2 do
	    tag=tags2[i]
	    repeat tagz,c=tagz:gsub("|"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%1%2") until c==0
	    repeat tagz,c=tagz:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%2%1") until c==0
	end
	repeat tagz,c=tagz:gsub("\\fn[^\\}]+([^}]-)(\\fn[^\\}]+)","%2%1") until c==0
	repeat tagz,c=tagz:gsub("(\\[ibusq])%d(.-)(%1%d)","%2%3") until c==0
	repeat tagz,c=tagz:gsub("(\\an)%d(.-)(%1%d)","%3%2") until c==0
	tagz=tagz:gsub("(|i?clip%(%A-%))(.-)(\\i?clip%(%A-%))","%2%3")
	:gsub("(\\i?clip%b())(.-)(\\i?clip%b())",function(a,b,c)
	    if a:match("m") and c:match("m") or not a:match("m") and not c:match("m") then return b..c else return a..b..c end end)
	tagz=tagz:gsub("|","\\"):gsub("\\t%([^\\%)]-%)","")
	return tagz
end

function extrakill(text,o)
	local tags3={"pos","move","org","fad"}
	for i=1,#tags3 do
	    tag=tags3[i]
	    if o==2 then
	    repeat text,c=text:gsub("(\\"..tag.."[^\\}]+)([^}]-)(\\"..tag.."[^\\}]+)","%3%2") until c==0
	    else
	    repeat text,c=text:gsub("(\\"..tag.."[^\\}]+)([^}]-)(\\"..tag.."[^\\}]+)","%1%2") until c==0
	    end
	end
	repeat text,c=text:gsub("(\\pos[^\\}]+)([^}]-)(\\move[^\\}]+)","%1%2") until c==0
	repeat text,c=text:gsub("(\\move[^\\}]+)([^}]-)(\\pos[^\\}]+)","%1%2") until c==0
	return text
end

function cleantr(tags)
	trnsfrm=""
	zerotf=""
	for t in tags:gmatch("\\t%b()") do
		if t:match("\\t%(\\") then
			zerotf=zerotf..t:match("\\t%((.*)%)$")
		else
			trnsfrm=trnsfrm..t
		end
	end
	zerotf="\\t("..zerotf..")"
	tags=tags:gsub("\\t%b()",""):gsub("^({[^}]*)}","%1"..zerotf..trnsfrm.."}"):gsub("\\t%(%)","")
	return tags
end


function tf(val)
	if val==true then ret="true"
	elseif val==false then ret="false"
	else ret=val end
	return ret
end

-- save inline tags
function inline_pos(t)
	inTags={}
	tl=t:len()
	if tl==0 then return {} end
	p=0
	t1=''
	repeat
		seg=t:match("^(%b{})") -- try to match tags/comments
		if seg then
			table.insert(inTags,{n=p,t=seg})
		else
			seg=t:match("^([^{]+)") -- or match text
			if not seg then t_error("Error: There appears to be a problem with the brackets here...\n"..t1..t,1) end
			SL=re.find(seg,".")
			p=p+#SL -- position of next '{' [or end]
		end
		t1=t1..seg
		t=t:gsub("^"..esc(seg),"")
		tl=t:len()
	until tl==0
	return inTags
end

-- rebuild inline tags
function inline_ret(t,tab)
	tl=t:len()
	nt=''
	kill='_Z#W_' -- this is supposed to never match
	for k,v in ipairs(tab) do
		N=tonumber(v.n)
		if N==0 then nt=nt..v.t
		else
			m='.'
			-- match how many chars at the start
			m=m:rep(N)
			RS=re.find(t,m)
			if RS then
				seg=RS[1].str
				seg=re.sub(seg,'^'..kill,'')
				nt=nt..seg..v.t
				kill=m -- how many matched in the last round
			end
		end
	end
	-- the rest
	seg=re.sub(t,'^'..kill,'')
	nt=nt..seg
	return nt
end

function stylechk(subs,sn)
	for i=1,#subs do
		if subs[i].class=="style" then
			local st=subs[i]
			if sn==st.name then sr=st end
			if st.name=="Default" then defaref=st end
		end
		if subs[i].class=="dialogue" then break end
	end
	if sr==nil then t_error("Style '"..sn.."' doesn't exist.") end
	return sr
end

function heather(subs)
	stitle,video,colorspace,resx,resy=nil
	for i=1, #subs do
		if subs[i].class=="info" then
			local k=subs[i].key
			local v=subs[i].value
			if k=="Title" then stitle=v end
			if k=="Video File" then video=v end
			if k=="YCbCr Matrix" then colorspace=v end
			if k=="PlayResX" then resx=v end
			if k=="PlayResY" then resy=v end
		end
		if video==nil then prop=aegisub.project_properties() video=prop.video_file end
	end
end

function tohex(num)
	n1=math.floor(num/16)
	n2=math.floor(num%16)
	num=tohex1(n1)..tohex1(n2)
	return num
end

function tohex1(num)
	HEX={"1","2","3","4","5","6","7","8","9","A","B","C","D","E"}
	if num<1 then num="0" elseif num>14 then num="F" else num=HEX[num] end
	return num
end

function t_error(message,cancel)
	ADD({{class="label",label=message}},{"OK"},{close='OK'})
	if cancel then aegisub.cancel() end
end



function modifire(subs,sel)
	substitution()
	TG={}
	ITG={}
	PTG={}
	tgc='|'
	tgc2='|'
	for z,i in ipairs(sel) do
		progress("Reading line "..z.."/"..#sel)
		l=subs[i]
		t=l.text
		t=tagmerge(t)
		t=t:gsub("\\t%b()",function(tr) return tr:gsub("\\t%([^\\]*(.*)%)","%1") end)
		stags=t:match(STAG) or ""
		for tags in t:gmatch(ATAG) do
			for tag in tags:gmatch("\\[^\\}]+") do
				if tag:match'\\i?clip' or tag:match'\\%d?c&' or tag:match'\\%da' or tag:match'\\alpha' then
				elseif tags==stags and not tgc:match("|"..esc(tag).."|") then
					if tag:match"\\%a+%b()" then table.insert(PTG,tag)
					else table.insert(TG,tag) end
					tgc=tgc..tag.."|"
				elseif tags~=stags and not tgc2:match("|"..esc(tag).."|") then
					table.insert(ITG,tag)
					tgc2=tgc2..tag.."|"
				end
			end
		end
	end
	progress("ModiFire")
	table.sort(TG,function(a,b) return a<b end)
	table.sort(ITG,function(a,b) return a<b end)
	table.sort(PTG,function(a,b) return a<b end)
	T=table.concat(TG,'\n')
	IT=table.concat(ITG,'\n')
	PT=table.concat(PTG,'\n')
	res=res or {}
	tot=#TG
	if #ITG>tot then tot=#ITG end
	if #PTG>tot then tot=#PTG end

	hbox=round(tot*0.55)+2
	if hbox<6 then hbox=6 end
	if hbox>18 then hbox=18 end
	GUI={
	{x=0,y=0,class="label",label="Start tags"},
	{x=1,y=0,width=2,class="label",label="Inline tags"},
	{x=3,y=0,width=5,class="label",label="Parenthesis tags"},
	{x=0,y=1,height=hbox,class="textbox",name="t1",value=T},
	{x=1,y=1,width=2,height=hbox,class="textbox",name="t2",value=IT},
	{x=3,y=1,width=6,height=hbox,class="textbox",name="t3",value=PT},
	{x=0,y=hbox+1,width=4,class="label",label="ModiFire: Modify tags above && they will be replaced in selected lines."},
	{x=0,y=hbox+2,class="label",label="CodiFire: Change the value of"},
	{x=1,y=hbox+2,class="dropdown",name="tag",value=res.tag or "blur",
	items={"blur","be","bord","shad","xshad","yshad","fscx","fscy","fsc","fs","fsp","frx","fry","frz","fax","fay","fad in","fad out","pos x","pos y","org x","org y","move x1","move y1","move x2","move y2"}},
	{x=2,y=hbox+2,class="label",label=" tags to: "},
	{x=3,y=hbox+2,class="floatedit",name="pure",value=pval},
	{x=4,y=hbox+2,class="label",label=" in selected lines."},
	{x=5,y=hbox+2,width=2,class="dropdown",name="mode1",items={"R","T","B"},value=res.mode1 or "R",hint="R - regular tags\nT - in transforms\nB - both"},
	{x=7,y=hbox+2,width=2,class="dropdown",name="mode2",items={"S","I","B"},value=res.mode2 or "S",hint="S - start tags\nT - inline tags\nB - both"},
	}
	P,res=ADD(GUI,{"ModiFire","CodiFire","PuriFire","Negator","Accelerator","Isolator","▽"},{ok='ModiFire',close='▽'})
	if P=="▽" then ak() end
	
	if P=="Accelerator" then
		AP,rez=ADD({{class="label",label="\\t Accel: "},{x=1,class="floatedit",name="acc",value=acc or 1,min=0}},{"Accelerate","Evacuate"},{ok='Accelerate',close='Evacuate'})
		acc=rez.acc
		if AP=="Evacuate" then ak() end
	end
	if P=="Isolator" then
		O=re.split(order,[[\\]])
		table.remove(O,1)
		table.remove(O,#O)
		AP,rez=ADD({{class="label",label="Tag to go first: "},{x=1,class="dropdown",name="ord",value=ord or 'r',items=O}},{"Isolate","Evaporate"},{ok='Isolate',close='Evaporate'})
		ord=rez.ord
		if AP=="Evaporate" then ak() end
		isorder=order:gsub("^\\r(.-)(\\"..ord..")(\\.*)","\\r%2%1%3")
	end
	if P=="ModiFire" then
		TG2={}
		ITG2={}
		PTG2={}
		if res.t1~=T then
			for tg in res.t1:gmatch('\\[^\\\n]*') do table.insert(TG2,tg) end
		end
		if res.t2~=IT then
			for tg in res.t2:gmatch('\\[^\\\n]*') do table.insert(ITG2,tg) end
		end
		if res.t3~=PT then
			for tg in res.t3:gmatch('\\[^\\\n]*') do table.insert(PTG2,tg) end
		end
		if #TG2==0 and #ITG2==0 and #PTG2==0 then ak() end
	end
	
	ptag='\\'..res.tag:gsub("fsc$","fsc[xy]"):gsub("fs$","fsz")
	ptug=ptag:gsub("\\","/")
	pval=res.pure
	pfm=res.mode1
	local start,inline
	if res.mode2=="S" or res.mode2=="B" then start=true end
	if res.mode2=="I" or res.mode2=="B" then inline=true end
	local neg='\\frx\\fry\\frz\\fsp\\fax\\fay\\xshad\\yshad'
	
	for z,i in ipairs(sel) do
		progress("Modifying line "..z.."/"..#sel)
		l=subs[i]
		t=l.text
		t=t:gsub("\\fs([%d\\})])","\\fsz%1")
		st=t:match(STAG) or ""
		t2=t:gsub(STAG,"")
		if P=="ModiFire" then
			if #TG2>0 then
				for x=1,#TG do
					if not TG2[x] then break end
					st=st:gsub(esc(TG[x]).."([\\})])",TG2[x].."%1")
				end
			end
			if #ITG2>0 then
				for x=1,#ITG do
					if not ITG2[x] then break end
					t2=t2:gsub(esc(ITG[x]).."([\\})])",ITG2[x].."%1")
				end
			end
			if #PTG2>0 then
				for x=1,#PTG do
					if not PTG2[x] then break end
					st=st:gsub(esc(PTG[x]).."([\\})])",PTG2[x].."%1")
				end
			end
		end
		if P=="CodiFire" then
			st=st:gsub("\\t(%b())",function(t) return "\\tra"..t:gsub("\\","/") end)
			t2=t2:gsub("\\t(%b())",function(t) return "\\tra"..t:gsub("\\","/") end)
			if ptag=='\\move x1' then
				st=st:gsub("(\\move%()([^,]+)",function(a,v) return a..pval end)
			elseif ptag=='\\move y1' then
				st=st:gsub("(\\move%([^,]+,)([^,]+)",function(a,v) return a..pval end)
			elseif ptag=='\\move x2' then
				st=st:gsub("(\\move%([^,]+,[^,]+,)([^,]+)",function(a,v) return a..pval end)
			elseif ptag=='\\move y2' then
				st=st:gsub("(\\move%([^,]+,[^,]+,[^,]+,)([^,)]+)",function(a,v) return a..pval end)
			elseif ptag=='\\pos x' then
				st=st:gsub("(\\pos%()([^,]+)",function(a,v) return a..pval end)
			elseif ptag=='\\pos y' then
				st=st:gsub("(\\pos%([^,]+,)([^,)]+)",function(a,v) return a..pval end)
			elseif ptag=='\\org x' then
				st=st:gsub("(\\org%()([^,]+)",function(a,v) return a..pval end)
			elseif ptag=='\\org y' then
				st=st:gsub("(\\org%([^,]+,)([^,)]+)",function(a,v) return a..pval end)
			elseif ptag=='\\fad in' then
				st=st:gsub("(\\fad%()([^,]+)",function(a,v) return a..pval end)
			elseif ptag=='\\fad out' then
				st=st:gsub("(\\fad%([^,]+,)([^,)]+)",function(a,v) return a..pval end)
			else
				if pfm=="R" or pfm=="B" then
					if start then st=st:gsub("("..ptag..")([-%d.]*)",function(a,v) return a..pval end) end
					if inline then t2=t2:gsub("("..ptag..")([-%d.]*)",function(a,v) return a..pval end) end
				end
				if pfm=="T" or pfm=="B" then
					if start then st=st:gsub("("..ptug..")([-%d.]*)",function(a,v) return a..pval end) end
					if inline then t2=t2:gsub("("..ptug..")([-%d.]*)",function(a,v) return a..pval end) end
				end
			end
			st=st:gsub("\\tra(%b())",function(t) return "\\t"..t:gsub("/","\\") end)
			t2=t2:gsub("\\tra(%b())",function(t) return "\\t"..t:gsub("/","\\") end)
		end
		t=st..t2
		t=t:gsub("\\fsz","\\fs")
		if P=="PuriFire" then
			t=t:gsub(ATAG,function(a)
				a=a:gsub("(%a*)(%-?%d+%.%d+)",function(g,n)
					if g:match'fa[xy]' then return g..round(n,2)
					else return g..round(n,1) end
					end)
				return a
				end)
		end
		if P=="Negator" then
			t=t:gsub("\\t(%b())",function(t) return "\\tra"..t:gsub("\\","/") end)
			if neg:match(ptag) then
				if pfm=="R" or pfm=="B" then
					t=t:gsub(ptag.."(-?)(%d)",function(m,n) if m=='' then m='-' else m='' end  return ptag..m..n end)
				end
				if pfm=="T" or pfm=="B" then
					t=t:gsub(ptug.."(-?)(%d)",function(m,n) if m=='' then m='-' else m='' end  return ptug..m..n end)
				end
			end
			t=t:gsub("\\tra(%b())",function(t) return "\\t"..t:gsub("/","\\") end)
		end
		if P=="Accelerator" then
			t=t:gsub("(\\t%([^,]+,[^,]+,)[^,]+,\\","%1"..acc..",\\")
			t=t:gsub("(\\t%([^,]+,[^,]+,)\\","%1"..acc..",\\")
			t=t:gsub("(\\t%()[^,]+,\\","%1"..acc..",\\")
			t=t:gsub("(\\t%()\\","%1"..acc..",\\")
		end
		if P=="Isolator" then
			t=t:gsub(ATAG,function(a)
				a=a:gsub("[{}]","")
				a=wrap(tagsort(a,isorder)):gsub('\n','')
				return a end)
		end
		l.text=t
		subs[i]=l
	end
end

aegisub.register_macro(script_name,script_description,activ8)
aegisub.register_macro("ModiFire","Modification of existing tags",modifire)
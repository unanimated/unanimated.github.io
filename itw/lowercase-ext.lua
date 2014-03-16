os.execute("dir /A:-D /b>list.txt")
file=io.open("list.txt")

list=file:read("*all")
list=list:gsub("[^\n]-%.%l%l%l\n","")
list=list:gsub("list%.txt\n","")
list=list:gsub("lowercase%-ext%.lua\n","")
io.close(file)


filetable={}
for line in list:gmatch("(.-)\n") do table.insert(filetable,line) end

list2=list:gsub("(.-)%.(%w-)\n",function(a,b) return a..".".. b:lower().."\n" end)

filetable2={}
for line2 in list2:gmatch("(.-)\n") do table.insert(filetable2,line2) end

ren=""
for i=1,#filetable do
	ren=ren.."rename \""..filetable[i].."\" \""..filetable2[i].."\"\n"
end

local file = io.open("rename.bat", "w")
file:write(ren)
file:close()

os.execute("rename.bat")
os.execute("del rename.bat")
os.execute("del list.txt")
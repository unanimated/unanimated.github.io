script_name="Honorificslaughterhouse"
script_description="Slaughters Honorifics"
script_author="unknown"
script_version="six"

function honorifix(subs, sel)
    for i=#subs,1,-1 do
      if subs[i].class=="dialogue" then
        local line=subs[i]
        local text=subs[i].text
		text=text
		:gsub("%-san","{-san}")
		:gsub("%-chan","{-chan}")
		:gsub("%-kun","{-kun}")
		:gsub("%-sama","{-sama}")
		:gsub("%-niisan","{-niisan}")
		:gsub("%-oniisan","{-oniisan}")
		:gsub("%-oniichan","{-oniichan}")
		:gsub("%-oneesan","{-oneesan}")
		:gsub("%-oneechan","{-oneechan}")
		:gsub("%-neesama","{-neesama}")
		:gsub("%-sensei","{-sensei}")
		:gsub("%-se[mn]pai","{-senpai}")
		:gsub("%-dono","{-dono}")
		:gsub("Onii{%-chan}","Brother{Onii-chan}")
		:gsub("Onii{%-san}","Brother{Onii-san}")
		:gsub("Onee{%-chan}","Sister{Onee-chan}")
		:gsub("Onee{%-san}","Sister{Onee-san}")
		:gsub("Onee{%-sama}","Sister{Onee-sama}")
		:gsub("onii{%-chan}","brother{onii-chan}")
		:gsub("onii{%-san}","brother{onii-san}")
		:gsub("onee{%-chan}","sister{onee-chan}")
		:gsub("onee{%-san}","sister{onee-san}")
		:gsub("onee{%-sama}","sister{onee-sama}")
	line.text=text
        subs[i]=line
      end
    end
end

aegisub.register_macro(script_name, script_description, honorifix)
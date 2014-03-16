--[[
README:

Put some explanation about your script at the top! People should know what it does and how to use it.
]]

--Define some properties about your script
script_name="Name of script"
script_description="What it does"
script_author="You"
script_version="1.0" --To make sure you and your users know which version is newest

--This is the main processing function that modifies the subtitles
function macro_function(subtitle, selected, active)
	--Code your function here
	aegisub.set_undo_point(script_name) --Automatic in 3.0 and above, but do it anyway
	return selected --This will preserve your selection (explanation below)
end

--This optional function lets you prevent the user from running the macro on bad input
function macro_validation(subtitle, selected, active)
	--Check if the user has selected valid lines
	--If so, return true. Otherwise, return false
	return true
end

--This is what puts your automation in Aegisub's automation list
aegisub.register_macro(script_name,script_description,macro_function,macro_validation)
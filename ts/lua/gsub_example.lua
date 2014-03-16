--A string of mixed letters and numbers
my_string="a1b2c3d4e5f6g7"

--%a matches letters only, %d matches digits only, so we'll see what we can make gsub do
--using those.

--First, a straightforward substitution of text. This turns all letters to exclamation points
new_string1=my_string:gsub("%a","!")

print(new_string1)

--Now let's use captures to show how we can save data from the original line and use it
--This surrounds the letters in brackets, while preserving what the letters were
new_string2=my_string:gsub("(%a)","[%1]")

print(new_string2)

--Now we can use multiple captures and rearrange them
--This will capture a letter-number-letter-number sequence, and swap the letters
new_string3=my_string:gsub("(%a)(%d)(%a)(%d)","%3%2%1%4")

print(new_string3)

--Finally, we can send these captures to a function
--This function will take four arguments. It uppercases the first and third arguments,
--swaps the second and fourth arguments, and returns a string with them put together in that order
function switcheroo(arg1,arg2,arg3,arg4)
	return arg1:upper()..arg4..arg3:upper()..arg2
end

--Now when we use that function in gsub, it receives whatever arguments are passed to it from the
--pattern. The pattern matches and captures a letter, a digit, a letter, a digit. On our test string,
--it will capture a, 1, b, and 2. So gsub will run switcheroo("a","1","b","2"). gsub doesn't know what
--switcheroo does, or what the arguments are named. It just knows to give the results of the capture
--to the function. The function switcheroo then interprets those results as its arg1, arg2, arg3, and arg4.
--The result of switcheroo is given to gsub, and gsub replaces "a1b2" with "A2B1"
new_string4=my_string:gsub("(%a)(%d)(%a)(%d)",switcheroo)

print(new_string4)

--You can also define the switcheroo function anonymously, like this:
new_string5=my_string:gsub("(%a)(%d)(%a)(%d)",
	function(letter1, number1, letter2, number2)
		--Uppercase the letters, swap the numbers
		return letter1:upper()..number2..letter2:upper()..number1
	end)

print(new_string5)
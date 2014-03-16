function do_for_selected(sub, sel, act)
	--Keep in mind that si is the index in sel, while li is the line number in sub
	for si,li in ipairs(sel) do
		--Read in the line
		line = sub[li]

		--Do stuff to line here

		--Put the line back in the subtitles
		sub[li] = line
	end
	aegisub.set_undo_point(script_name)
	return sel
end
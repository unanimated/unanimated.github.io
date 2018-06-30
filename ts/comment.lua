function comment(subs,sel)
    for x,i in ipairs(sel) do
        line=subs[i]
        line.comment=not line.comment
	subs[i]=line
    end
    return sel
end

aegisub.register_macro("Comment","Comments lines",comment)
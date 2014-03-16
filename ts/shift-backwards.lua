local tr = aegisub.gettext
script_name = tr('Duplicate and shift by 1 Frame backwards')
script_description = tr('Duplicte selected lines and shift them to the frame before the original start frame')
script_author = 'Thomas Goyne'
script_version = '1'
local contiguous_chunks
contiguous_chunks = function(arr)
  local ret = {
    { }
  }
  local last = ret[1]
  local _list_0 = arr
  for _index_0 = 1, #_list_0 do
    local value = _list_0[_index_0]
    if not last[#last] or last[#last] + 1 == value then
      last[#last + 1] = value
    else
      last = {
        value
      }
      ret[#ret + 1] = last
    end
  end
  return ret
end
return aegisub.register_macro(script_name, script_description, function(subs, selection, active)
  local new_lines = { }
  local _list_0 = contiguous_chunks(selection)
  for _index_0 = 1, #_list_0 do
    local _continue_0 = false
    repeat
      local chunk = _list_0[_index_0]
      if not (#chunk > 0) then
        _continue_0 = true
        break
      end
      local start = chunk[1]
      local _list_1 = chunk
      for _index_1 = 1, #_list_1 do
        local sel = _list_1[_index_1]
        local line = subs[sel]
        local frame = aegisub.frame_from_ms(line.start_time)
        line.start_time = aegisub.ms_from_frame(frame - 1)
        line.end_time = aegisub.ms_from_frame(frame)
        if not new_lines[start] then
          new_lines[start] = { }
        end
        table.insert(new_lines[start], line)
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  local offset = 0
  local new_selection = { }
  for line, chunk in pairs(new_lines) do
    subs.insert(line + offset, unpack(chunk))
    for i = 1, #chunk do
      new_selection[#new_selection + 1] = line + offset + i - 1
    end
    offset = offset + #chunk
  end
  aegisub.set_undo_point(tr('duplicate lines'))
  return new_selection, new_selection[1]
end)

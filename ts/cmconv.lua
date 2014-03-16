include("utils.lua")

script_name = "BT.601 -> BT.709 Color Fixer"
script_description = "Change colors from BT.601 to BT.709."
script_name_2 = "BT.601 -> BT.709 Global Color Fixer"
script_description_2 = "Globally change colors from BT.601 to BT.709."
script_author = "Daiz"
script_version = "1.0.1"

local Rec601 = {
  Kr = 0.299,
  Kg = 0.587,
  Kb = 0.114
}

local Rec709 = {
  Kr = 0.2126,
  Kg = 0.7152,
  Kb = 0.0722
}

function RGBtoYUV(r, g, b, matrix)
  local Kr = matrix.Kr
  local Kg = matrix.Kg
  local Kb = matrix.Kb
  local y = (Kr*219/255)*r + (Kg*219/255)*g + (Kb*219/255)*b
  local v = 112/255*r - Kg*112/255*g/(1-Kr) - Kb*112/255*b/(1-Kr)
  local u = - Kr*112/255*r/(1-Kb) - Kg*112/255*g/(1-Kb) + 112/255*b

  return y+16, u+128, v+128
end

function YUVtoRGB(y, u, v, matrix)
  local Kr = matrix.Kr
  local Kg = matrix.Kg
  local Kb = matrix.Kb

  local r = (255/219)*y + (255/112)*v*(1-Kr) - (255*16/219 + 255*128/112*(1-Kr))
  local g = (255/219)*y - (255/112)*u*(1-Kb)*Kb/Kg - (255/112)*v*(1-Kr)*Kr/Kg - (255*16/219 - 255/112*128*(1-Kb)*Kb/Kg - 255/112*128*(1-Kr)*Kr/Kg)
  local b = (255/219)*y + (255/112)*u*(1-Kb) - (255*16/219 + 255*128/112*(1-Kb))

  r = clamp(math.floor(r + 0.5), 0, 255)
  g = clamp(math.floor(g + 0.5), 0, 255)
  b = clamp(math.floor(b + 0.5), 0, 255)

  return r, g, b
end

function cm_conv(r, g, b, m1, m2)
  local y, u, v = RGBtoYUV(r, g, b, m1)
  local r, g, b = YUVtoRGB(y, u, v, m2)
  return r, g, b
end

function replace(colorstring)
  local r, g, b, a = extract_color(colorstring)
  nr, ng, nb = cm_conv(r, g, b, Rec601, Rec709)
  return ass_color(nr, ng, nb)
end

function correct(subs, sel, active)

  for _, i in pairs(sel) do

    local l = subs[i]
    local t = l.text
    l.text = t:gsub("&H%x%x%x%x%x%x&", replace)
    subs[i] = l

  end

  aegisub.set_undo_point("BT.601->BT.709 Color Fix")

end

function correct_global(subs, sel, active)

  for i = 1, #subs do
    local l = subs[i]

    if l.class == "info" then
      if l.key == "YCbCr Matrix" then
        if l.value == "TV.601" then
          l.value = "TV.709"
        end
      end
    end

    if l.class == "style" then

      local r, g, b, a = extract_color(l.color1)
      local nr, ng, nb = cm_conv(r, g, b, Rec601, Rec709)
      l.color1 = ass_style_color(nr, ng, nb, a)

      r, g, b, a = extract_color(l.color2)
      nr, ng, nb = cm_conv(r, g, b, Rec601, Rec709)
      l.color2 = ass_style_color(nr, ng, nb, a)

      r, g, b, a = extract_color(l.color3)
      nr, ng, nb = cm_conv(r, g, b, Rec601, Rec709)
      l.color3 = ass_style_color(nr, ng, nb, a)

      r, g, b, a = extract_color(l.color4)
      nr, ng, nb = cm_conv(r, g, b, Rec601, Rec709)
      l.color4 = ass_style_color(nr, ng, nb, a)
    end

    if l.class == "dialogue" then
      local t = l.text
      l.text = t:gsub("&H%x%x%x%x%x%x&", replace)
    end

    subs[i] = l

  end

  aegisub.set_undo_point("BT.601->BT.709 Global Color Fix")

end

aegisub.register_macro(
  script_name,
  script_description,
  correct
)

aegisub.register_macro(
  script_name_2,
  script_description_2,
  correct_global
)
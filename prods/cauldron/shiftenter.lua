--setBufferName("shiftenter.lua")

codelog = {}

do
 setKeyHandlerProgram(keymap, stdkeyids.enter,     1,
  [[
    local sCode = edGetLuaBlock()
    local p1,p2 = edGetLuaBlockPosition()
    if sCode == "" then
      sCode = getEditorLineText()
      p2 = getEditorLineEnd()
    end
    edSetPosition(p2)
    edInsertNewline()
    luaCall(sCode)
    table.insert(codelog, sCode)
    setClearColor(200,0,0)
  ]])
end

do
 setKeyHandlerProgram(keymap, stdkeyids.enter,     2,
  [[
    local sCode = edGetLuaBlock()
    if sCode == "" then
      sCode = getEditorLineText()
    end
    luaCall(sCode)
    table.insert(codelog, sCode)
    setClearColor(200,0,0)
  ]])
end

do
 setKeyHandlerProgram(keymap, stdkeyids["s"], 2,
  [[
    saveBuffer()
    setClearColor(0,200,0)
    print(getBufferName() .. " saved.")
  ]])
end

--print2(codelog[#codelog])

function makeCodeLogBuffer()
  parentBufferName = getBufferName()
  local sText = ""
  for i=1,#codelog,1 do
    sText = sText .. "Entry " .. i .. "\n"
    sText = sText .. codelog[i] .. "\n\n"
  end
  newBuffer("codelog.txt")
  setBufferText(sText)
  edSetPosition(#sText - 1)
end

showTrace()
print("codelogger logging")
--clearTrace()


do
  local clamp = function (x)
    if x < 0 then x = 0 end
    return x
  end

 function update()
  WidgetLib.callAll("update")

  for i=1,#skythings,1 do
    local thing = skythings[i]
    local planepos = vec3d(transform.getTranslation(airplane.lspace))
    local tween = thing.p - planepos
    local dist = Vector3D.magnitude(tween)
    tween = Vector3D.normalize(tween)
    if dist < (30 + thing.r) then
      thing.p = planepos + (tween * (30+thing.r))
    end
  end

  local r,g,b = getClearColor()
  r = clamp(r - 20)
  g = clamp(g - 20)
  
  setClearColor(r,g,b)
 end
end

-- passing a number by reference???

require("Scripts._Common.Common")
CanvasAuthoringSize = Vector2(1920, 1080)
local functionTable = {
  fontFamily = "SetFont",
  fontSize = "SetFontSize",
  fontColor = "SetColor",
  fontEffect = "SetFontEffectByName",
  characterSpacing = "SetCharacterSpacing",
  lineSpacing = "SetLineSpacing",
  textCasing = "SetTextCase",
  textWrapping = "SetWrapText",
  hAlignment = "SetHorizontalTextAlignment",
  vAlignment = "SetVerticalTextAlignment",
  overflowMode = "SetOverflowMode",
  shrinkToFit = "SetShrinkToFit"
}
function SetTextStyle(textfield, styleTable)
  for key, value in pairs(styleTable) do
    if functionTable[key] ~= nil then
      UiTextBus.Event[functionTable[key]](textfield, value)
    else
      Log("Common.lua SetFontStyle() - Key doesn't exist in functionTable: " .. key)
      Debug.Log(debug.traceback())
    end
  end
end
local numberArray = {
  1000,
  900,
  500,
  400,
  100,
  90,
  50,
  40,
  10,
  9,
  5,
  4,
  1
}
local romanArray = {
  "M",
  "CM",
  "D",
  "CD",
  "C",
  "XC",
  "L",
  "XL",
  "X",
  "IX",
  "V",
  "IV",
  "I"
}
local valueToRomanCache = {
  [0] = "",
  [1] = "I",
  [2] = "II",
  [3] = "III",
  [4] = "IV",
  [5] = "V"
}
function GetRomanFromNumber(value)
  value = value or 0
  if valueToRomanCache[value] then
    return valueToRomanCache[value]
  end
  local convertedValue = ""
  local remainingValue = value
  for i = 1, #numberArray do
    while remainingValue > remainingValue % numberArray[i] do
      convertedValue = convertedValue .. romanArray[i]
      remainingValue = remainingValue - numberArray[i]
    end
  end
  valueToRomanCache[value] = convertedValue
  return convertedValue
end
function ColorRgbaToHexString(value)
  local convertedValue = string.format("\"#%2x%2x%2x\"", value.r * 255, value.g * 255, value.b * 255)
  return convertedValue
end
function GetRoundedNumber(val, decimal)
  if decimal then
    return string.format("%." .. decimal .. "f", val)
  else
    return math.floor(val + 0.5)
  end
end
function SplitString(str)
  local subs = {}
  for sub in string.gmatch(str, "%S+") do
    table.insert(subs, sub)
  end
  return subs
end
function GetFormattedNumber(amount, decimal, skipAddCommas)
  local str_amount, formatted, famount, remain
  decimal = decimal or 0
  famount = math.abs(GetRoundedNumber(amount, decimal))
  famount = math.floor(famount)
  remain = GetRoundedNumber(math.abs(amount) - famount, decimal)
  if not skipAddCommas then
    formatted = GetLocalizedNumber(famount)
  else
    formatted = string.format("%.0f", famount)
  end
  if 0 < decimal then
    if math.abs(remain) == 0 then
      remain = 0
    end
    remain = string.sub(tostring(remain), 3)
    formatted = formatted .. LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_decimal_separator") .. remain .. string.rep("0", decimal - string.len(remain))
  end
  if amount < 0 then
    formatted = "-" .. formatted
  end
  return formatted
end
function GetLocalizedRealWorldCurrency(value, currency)
  local valueNum = tonumber(value)
  local valueText = GetFormattedNumber(value, 2)
  local format = "@currency_" .. currency
  local text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(format, valueText)
  return text
end
local CURRENCY_MODIFIER = 100
function GetLocalizedCurrency(value, skipAddCommas)
  local valueNum = tonumber(value)
  if valueNum then
    return GetFormattedNumber(valueNum / CURRENCY_MODIFIER, 2, skipAddCommas)
  else
    return value
  end
end
function GetValueFromLocalized(value, isCurrency)
  if type(value) == "string" then
    local locDecimal = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_decimal_separator")
    value = value:gsub("[" .. locDecimal .. "]", ";")
    local separator = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_thousand_separator")
    value = value:gsub("[" .. separator .. "]", "")
    value = value:gsub("[;]", ".")
  end
  local valueNum = tonumber(value)
  if not valueNum then
    return value, false
  end
  if isCurrency then
    return math.floor(valueNum * CURRENCY_MODIFIER + 0.5), true
  end
  return valueNum, true
end
function GetCurrencyValueFromLocalized(value)
  return GetValueFromLocalized(value, true)
end
function GetLocalizedNumber(value)
  local separator = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_thousand_separator")
  local i, j, minus, int, fraction = string.format("%.0f", value):find("([-]?)(%d+)([.]?%d*)")
  if not int then
    Log([[
Warning: invalid value %s passed in to GetLocalizedNumber
%s]], tostring(value), debug.traceback())
    return "-"
  end
  int = int:reverse():gsub("(%d%d%d)", "%1;")
  int = int:reverse():gsub("^;", "")
  return string.gsub(int, ";", separator)
end
function LocalizeDecimalSeparators(value)
  local stringValue = tostring(value)
  if stringValue then
    local separator = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_decimal_separator")
    return stringValue:gsub("%.", separator)
  else
    return value
  end
end
function GetSmallImagePath(path)
  if path == nil or type(path) ~= "string" then
    return ""
  end
  if #path == 0 then
    return path
  end
  local extensionIndex = path:find(".", 1, true)
  if extensionIndex == nil then
    Debug.Log(string.format("Warning - GetSmallImagePath: path '%s' does not contain an extension", path))
    return path
  end
  local smallPath = path:sub(1, extensionIndex - 1)
  return smallPath .. "_small.png"
end
function Lerp(numAtZero, numAtOne, percent)
  return (1 - percent) * numAtZero + percent * numAtOne
end
function IsUsableNumber(number)
  if type(number) ~= "number" or number == nil or number ~= number or number < -math.huge or number > math.huge then
    return false
  end
  return true
end
function AdjustElementToCanvasSize(entityId, canvasId)
  local size = UiCanvasBus.Event.GetCanvasSize(canvasId)
  UiTransform2dBus.Event.SetLocalWidth(entityId, math.max(1920 / size.x, 1080 / size.y) * size.x)
  UiTransform2dBus.Event.SetLocalHeight(entityId, math.max(1920 / size.x, 1080 / size.y) * size.y)
end
function AdjustElementToCanvasWidth(entityId, canvasId)
  local size = UiCanvasBus.Event.GetCanvasSize(canvasId)
  UiTransform2dBus.Event.SetLocalWidth(entityId, math.max(1920 / size.x, 1080 / size.y) * size.x)
end
function AdjustElementToCanvasHeight(entityId, canvasId)
  local size = UiCanvasBus.Event.GetCanvasSize(canvasId)
  UiTransform2dBus.Event.SetLocalHeight(entityId, math.max(1920 / size.x, 1080 / size.y) * size.y)
end
function DeepClone(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[DeepClone(orig_key)] = DeepClone(orig_value)
    end
    setmetatable(copy, DeepClone(getmetatable(orig)))
  else
    copy = orig
  end
  return copy
end
function MixColors(colorA, colorB, bMixPerc)
  return ColorRgba(255 * Lerp(colorA.r, colorB.r, bMixPerc), 255 * Lerp(colorA.g, colorB.g, bMixPerc), 255 * Lerp(colorA.b, colorB.b, bMixPerc), Lerp(colorA.a, colorB.a, bMixPerc))
end
function PositionEntityOnScreen(entityId, desiredViewportPosition, padding)
  local paddingData = {
    left = padding and padding.left and padding.left or 0,
    right = padding and padding.right and padding.right or 0,
    top = padding and padding.top and padding.top or 0,
    bottom = padding and padding.bottom and padding.bottom or 0
  }
  local targetPos = Vector2(desiredViewportPosition.x, desiredViewportPosition.y)
  local entityRect = UiTransformBus.Event.GetViewportSpaceRect(entityId)
  local width = entityRect:GetWidth()
  local height = entityRect:GetHeight()
  local pivot = UiTransformBus.Event.GetPivot(entityId)
  local viewportSize = LyShineScriptBindRequestBus.Broadcast.GetViewportSize()
  targetPos.x = Clamp(targetPos.x, paddingData.left + width * pivot.x, viewportSize.x - (width * (1 - pivot.x) + paddingData.right))
  targetPos.y = Clamp(targetPos.y, paddingData.top + height * pivot.y, viewportSize.y - (height * (1 - pivot.y) + paddingData.bottom))
  UiTransformBus.Event.SetViewportPosition(entityId, targetPos)
end
function IsCursorOverUiEntity(entityId, padding)
  local isCursorOverEntity = false
  local screenPoint = CursorBus.Broadcast.GetCursorPosition()
  local point = UiTransformBus.Event.ViewportPointToLocalPoint(entityId, screenPoint)
  local width = UiTransform2dBus.Event.GetLocalWidth(entityId)
  local height = UiTransform2dBus.Event.GetLocalHeight(entityId)
  return point.x > -padding and point.x < width + padding and point.y > -padding and point.y < height + padding
end
function GetRandomString(length)
  local charset = {}
  for c = 48, 57 do
    table.insert(charset, string.char(c))
  end
  for c = 65, 90 do
    table.insert(charset, string.char(c))
  end
  for c = 97, 122 do
    table.insert(charset, string.char(c))
  end
  if not length or length <= 0 then
    return ""
  end
  math.randomseed(os.clock() ^ 5)
  return GetRandomString(length - 1) .. charset[math.random(1, #charset)]
end
function TableToKeyValueVectors(data)
  local keys = vector_basic_string_char_char_traits_char()
  local values = vector_basic_string_char_char_traits_char()
  for k, v in pairs(data) do
    keys:push_back(k)
    values:push_back(v)
  end
  return {keys = keys, values = values}
end
function GetLocalizedReplacementText(locString, keyValueTable)
  local numReplacements = 0
  local firstVal
  for _, val in pairs(keyValueTable) do
    numReplacements = numReplacements + 1
    firstVal = val
    if 1 < numReplacements then
      break
    end
  end
  if numReplacements == 1 then
    return LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(locString, firstVal)
  end
  local keyValueVectors = TableToKeyValueVectors(keyValueTable)
  return LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements(locString, keyValueVectors.keys, keyValueVectors.values)
end
function AddTextColorMarkup(text, color)
  return string.format("<font color=%s>%s</font>", ColorRgbaToHexString(color), text)
end
function SetActionmapsForTextInput(canvasId, enabled)
  if enabled then
    UiJavCanvasComponentBus.Event.SetOverridesActionMap(canvasId, "player", true)
    UiJavCanvasComponentBus.Event.SetOverridesActionMap(canvasId, "movement", true)
    UiJavCanvasComponentBus.Event.SetOverridesActionMap(canvasId, "camera", true)
    UiJavCanvasComponentBus.Event.SetOverridesActionMap(canvasId, "ui", true)
    UiJavCanvasComponentBus.Event.SetOverridesActionMap(canvasId, "combat", true)
    UiJavCanvasComponentBus.Event.SetOverridesActionMap(canvasId, "chat", true)
    UiJavCanvasComponentBus.Event.SetOverridesActionMap(canvasId, "housing", true)
    UiJavCanvasComponentBus.Event.SetOverridesActionMap(canvasId, "debug", true)
  else
    UiJavCanvasComponentBus.Event.ResetActionMapOverrides(canvasId)
  end
end
function CloneUiElement(canvasId, registrar, sourceEntity, parentEntity, startEnabled)
  if not sourceEntity or not parentEntity then
    Log("BaseScreen:CloneElement: Trying to clone an element that nil or has no parent\n" .. debug.traceback())
    return nil
  end
  local newEntityId = UiCanvasBus.Event.CloneElement(canvasId, sourceEntity, parentEntity, EntityId())
  if newEntityId:IsValid() then
    local newEntityTable = registrar:GetEntityTable(newEntityId)
    UiElementBus.Event.SetIsEnabled(newEntityId, startEnabled)
    return newEntityTable or newEntityId
  end
  Log("BaseScreen:CloneElement: Failed to clone element: " .. tostring(sourceEntity.entityId) .. "\n" .. debug.traceback())
  return nil
end
function DistanceToText(distance, decimal)
  if 1000 < distance then
    return LocalizeDecimalSeparators(LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_distanceKilometers", string.format("%.2f", distance / 1000)))
  else
    decimal = decimal or 0
    return LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_distanceMeters", string.format("%." .. decimal .. "f", distance))
  end
end
function GetLocalizedDistance(from, to)
  local fromPosition = Vector3(from.x, from.y, 0)
  local toPosition = Vector3(to.x, to.y, 0)
  local distance = toPosition:GetDistance(fromPosition)
  return DistanceToText(distance), distance
end
function GetOffsetFrom(toId, fromId)
  local toViewportPosition = UiTransformBus.Event.GetViewportPosition(toId)
  local localOffset = UiTransformBus.Event.ViewportPointToLocalPoint(fromId, toViewportPosition)
  return localOffset
end
local crcNil = 0
function GetNilCrc()
  return crcNil
end
function GetIsMouseOverEntity(entityId)
  local mouse = UiCursorBus.Broadcast.GetUiCursorPosition()
  local entityRect = UiTransformBus.Event.GetViewportSpaceRect(entityId)
  local w = entityRect:GetWidth()
  local h = entityRect:GetHeight()
  local centerVec2 = entityRect:GetCenter()
  return mouse.x >= centerVec2.x - w / 2 and mouse.x <= centerVec2.x + w / 2 and mouse.y >= centerVec2.y - h / 2 and mouse.y <= centerVec2.y + h / 2
end

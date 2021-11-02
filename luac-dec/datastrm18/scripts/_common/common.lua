function Merge(dst, src, shouldDeepCopy, omitFunctions, stompDst, tablesParsedMap)
  tablesParsedMap = tablesParsedMap or {}
  for i, v in pairs(src) do
    if not omitFunctions or type(v) ~= "function" then
      if shouldDeepCopy then
        if type(v) == "table" then
          if v == src or tablesParsedMap[tostring(v)] == true then
            Log("lua table merge detected a circular reference, bailing out of recursion.")
            return
          end
          if dst[i] == nil then
            dst[i] = {}
          end
          tablesParsedMap[tostring(v)] = true
          Merge(dst[i], v, shouldDeepCopy, omitFunctions, stompDst, tablesParsedMap)
        elseif stompDst or dst[i] == nil then
          dst[i] = v
        end
      elseif stompDst or dst[i] == nil then
        dst[i] = v
      end
    end
  end
  return dst
end
function Log(fmt, ...)
  g_Logger:Log(fmt, ...)
end
function LogTable(table, omitFunctions, depth, tabCount)
  if not table then
    Log("$2nil")
  else
    depth = depth or 8
    tabCount = tabCount or 0
    local str = ""
    for n = 0, tabCount do
      str = str .. "     "
    end
    for i, field in pairs(table) do
      if type(field) == "table" then
        if depth > tabCount then
          tabCount = tabCount + 1
          Log(str .. "$4" .. tostring(i) .. "$1= {")
          LogTable(field, omitFunctions, depth, tabCount)
          Log(str .. "$1}")
          tabCount = tabCount - 1
        else
          Log(str .. "$4" .. tostring(i) .. "$1= { $4...$1 }")
        end
      elseif type(field) == "number" then
        Log("$2" .. str .. "$6" .. tostring(i) .. "$1=$8" .. field)
      elseif type(field) == "string" then
        Log("$2" .. str .. "$6" .. tostring(i) .. "$1=$8" .. "\"" .. field .. "\"")
      elseif type(field) == "boolean" then
        Log("$2" .. str .. "$6" .. tostring(i) .. "$1=$8" .. "\"" .. tostring(field) .. "\"")
      elseif not omitFunctions then
        if type(field) == "function" then
          Log("$2" .. str .. "$5" .. tostring(i) .. "()")
        else
          Log("$2" .. str .. "$7" .. tostring(i) .. "$8<userdata>")
        end
      end
    end
  end
end
function RemoveFromTable(tbl, ent)
  for i, v in ipairs(tbl) do
    if v == ent then
      table.remove(tbl, i)
      break
    end
  end
end
function InsertIntoTable(tbl, ent)
  for i, v in ipairs(tbl) do
    if v == ent then
      return
    end
  end
  table.insert(tbl, ent)
end
function IsInsideTable(tbl, ent)
  for i, v in ipairs(tbl) do
    if v == ent then
      return true
    end
  end
  return false
end
function KeyIsInsideTable(tbl, ent)
  return tbl and ent and tbl[ent] ~= nil
end
function RandomString(length)
  length = length or 1
  if length < 1 then
    return nil
  end
  local array = {}
  for i = 1, length do
    array[i] = string.char(math.random(32, 126))
  end
  return table.concat(array)
end
function ShallowCopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
  else
    copy = orig
  end
  return copy
end
function Clamp(valueToClamp, min, max)
  return math.max(min, math.min(max, valueToClamp))
end
function GetTableValue(t, path, defaultValue)
  if type(t) ~= "table" and type(t) ~= "userdata" then
    return defaultValue
  end
  if type(path) ~= "string" or path == "" then
    return defaultValue
  end
  local delim_from, delim_to = string.find(path, ".", 1, true)
  if not delim_from then
    if t[path] == nil then
      return defaultValue
    end
    return t[path]
  end
  local left = string.sub(path, 1, delim_from - 1)
  local right = string.sub(path, delim_to + 1)
  return GetTableValue(t[left], right, defaultValue)
end
function StringSplit(targetString, delimiter)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find(targetString, delimiter, from)
  while delim_from do
    table.insert(result, string.sub(targetString, from, delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = string.find(targetString, delimiter, from)
  end
  table.insert(result, string.sub(targetString, from))
  return result
end
function ColorRgba(r, g, b, a)
  r = r / 255
  g = g / 255
  b = b / 255
  return Color(r, g, b, a)
end
function CountAssociativeTable(tableArg)
  local count = 0
  for _, _ in pairs(tableArg) do
    count = count + 1
  end
  return count
end
function PickFromList(itemList)
  if 0 < #itemList then
    if type(itemList[1]) == "table" then
      local totalProbability = 0
      for idx = 1, #itemList do
        local element = itemList[idx]
        if element and type(element) == "table" and 2 <= #element then
          local probability = itemList[idx][2]
          if probability and type(probability) == "number" then
            totalProbability = totalProbability + probability
          else
            Debug.Log("The probability of your { item, probability } pair isn't a number!")
          end
        else
          Debug.Log("Your { item, probability } pair is malformed! (ie. not enough elements, not a table, nil)")
        end
      end
      if totalProbability == 0 then
        return nil
      end
      local rand = math.random()
      local cumulativeProbability = 0
      for idx = 1, #itemList do
        local element = itemList[idx]
        if element and type(element) == "table" and 2 <= #element then
          local probability = itemList[idx][2]
          if probability and type(probability) == "number" then
            local normalizedProbability = probability / totalProbability
            cumulativeProbability = cumulativeProbability + normalizedProbability
            if rand <= cumulativeProbability or idx == #itemList then
              return itemList[idx][1]
            end
          end
        end
      end
    else
      local numItems = #itemList
      local rand = math.random(numItems)
      rand = math.min(rand, numItems)
      return itemList[rand]
    end
  else
    Debug.Log("You passed an empty list into PickFromList!")
    return nil
  end
  Debug.Log("PickFromList: Not able to pick any item from list!")
  return nil
end
function ClearTable(t)
  for k in pairs(t) do
    t[k] = nil
  end
end
function GetEpsilon()
  return 1.0E-6
end
function GetMaxNum()
  return 4500000000000000
end
function GetMaxInt()
  return 2147483647
end
function ImmediateIf(condition, trueCase, falseCase)
  if condition then
    return trueCase
  else
    return falseCase
  end
end
function RequireScript(scriptPath)
  if not g_cachedScripts[scriptPath] then
    g_cachedScripts[scriptPath] = require(scriptPath)
  end
  return g_cachedScripts[scriptPath]
end
function RoundToPrecision(number, precision)
  local d = 10 ^ precision
  return math.floor(number * d + 0.5) / d
end

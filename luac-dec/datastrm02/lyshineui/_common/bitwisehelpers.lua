local BitwiseHelperFunctions = {
  bitfieldBuffer = 1073741824,
  SERVERSTATUS_HIDDEN = 1,
  SERVERSTATUS_DISABLED = 2,
  SERVERSTATUS_DOWNFORMAINTENANCE = 4,
  SERVERSTATUS_CHARACTERCREATIONDISABLED = 8,
  SERVERSTATUS_NOCHARACTERTRANSFER = 16
}
local function tobittable_r(x, ...)
  if (x or 0) == 0 then
    return ...
  end
  return tobittable_r(math.floor(x / 2), x % 2, ...)
end
local function tobittable(x)
  assert(type(x) == "number", "argument must be a number")
  if x == 0 then
    return {0}
  end
  return {
    tobittable_r(x)
  }
end
local function makeop(cond)
  local function oper(x, y, ...)
    if not y then
      return x
    end
    x, y = tobittable(x), tobittable(y)
    local xl, yl = #x, #y
    local t, tl = {}, math.max(xl, yl)
    for i = 0, tl - 1 do
      local b1, b2 = x[xl - i], y[yl - i]
      if not b1 and not b2 then
        break
      end
      t[tl - i] = cond((b1 or 0) ~= 0, (b2 or 0) ~= 0) and 1 or 0
    end
    return oper(tonumber(table.concat(t), 2), ...)
  end
  return oper
end
local band = makeop(function(a, b)
  return a and b
end)
function BitwiseHelperFunctions:TestFlag(bitfield, flag)
  return flag <= (self.bitfieldBuffer + bitfield) % (2 * flag)
end
function BitwiseHelperFunctions:SetFlag(bitfield, flag)
  if self:TestFlag(bitfield, flag) then
    return bitfield
  end
  return bitfield + flag
end
function BitwiseHelperFunctions:ClearFlag(bitfield, flag)
  if self:TestFlag(bitfield, flag) then
    return bitfield - flag
  end
  return bitfield
end
function BitwiseHelperFunctions:LShift(x, bits)
  return math.floor(x) * 2 ^ bits
end
function BitwiseHelperFunctions:RShift(x, bits)
  return math.floor(math.floor(x) / 2 ^ bits)
end
function BitwiseHelperFunctions:And(value, mask)
  return band(value, mask)
end
return BitwiseHelperFunctions

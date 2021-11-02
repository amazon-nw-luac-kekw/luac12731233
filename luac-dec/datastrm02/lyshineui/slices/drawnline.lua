local DrawnLine = {
  Properties = {
    LineMask = {
      default = EntityId()
    },
    LineLeft = {
      default = EntityId()
    },
    LineSlice = {
      default = EntityId()
    },
    LineRight = {
      default = EntityId()
    },
    Overshoot = {Number = 0}
  },
  mLineEndWidth = 40,
  mWidth = 0,
  mOvershoot = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DrawnLine)
function DrawnLine:OnInit()
  BaseElement.OnInit(self)
  self.mOvershoot = self.Overshoot.Number
  self:ResetLength()
end
function DrawnLine:ResetLength()
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self:SetLength(self.mWidth)
end
function DrawnLine:Reset()
  self.ScriptedEntityTweener:Stop(self.Properties.LineMask)
  self.ScriptedEntityTweener:Set(self.Properties.LineMask, {w = 0})
end
function DrawnLine:SetLength(length)
  local lineSliceWidth = length + self.mOvershoot - self.mLineEndWidth * 2
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.LineSlice, lineSliceWidth)
  local lineRightPosX = length + self.mOvershoot + self.mLineEndWidth - self.mLineEndWidth * 2
  UiTransformBus.Event.SetLocalPosition(self.Properties.LineSlice, Vector2(self.mLineEndWidth, 0))
  UiTransformBus.Event.SetLocalPosition(self.Properties.LineRight, Vector2(lineRightPosX, 0))
  self.mWidth = length
end
function DrawnLine:SetOvershoot(overshoot)
  self.mOvershoot = overshoot
  self:SetLength(self.mWidth)
end
local defaults = {
  duration = 0.5,
  delay = 0,
  ease = "QuadOut"
}
local lineMaskDuration = 0
local lineMaskWidth = 0
local lineMaskAnimParams = {
  w = 0,
  ease = "",
  delay = 0
}
function DrawnLine:SetVisible(isVisible, duration, params)
  lineMaskDuration = duration ~= nil and duration or defaults.duration
  lineMaskAnimParams.delay = defaults.delay
  lineMaskAnimParams.ease = defaults.ease
  lineMaskWidth = self.mWidth + self.mOvershoot + self.mLineEndWidth * 2
  lineMaskAnimParams.w = isVisible and lineMaskWidth or 0
  if params ~= nil then
    if params.delay ~= nil then
      lineMaskAnimParams.delay = params.delay
    end
    if params.ease ~= nil then
      lineMaskAnimParams.ease = params.ease
    end
    if params.width ~= nil and isVisible then
      lineMaskAnimParams.w = params.width
    end
  end
  self.ScriptedEntityTweener:Stop(self.Properties.LineMask)
  self.ScriptedEntityTweener:StartAnimation(self.Properties.LineMask, lineMaskDuration, lineMaskAnimParams)
end
local colorDuration = 0
local colorAnimParams = {
  imgColor = ColorRgba(255, 255, 255, 1),
  ease = "",
  delay = 0
}
function DrawnLine:SetColor(color, duration, params)
  colorDuration = duration ~= nil and duration or defaults.duration
  colorAnimParams.delay = defaults.delay
  colorAnimParams.ease = defaults.ease
  colorAnimParams.imgColor = color
  if params ~= nil then
    if params.delay ~= nil then
      colorAnimParams.delay = params.delay
    end
    if params.ease ~= nil then
      colorAnimParams.ease = params.ease
    end
  end
  if duration ~= nil then
    self.ScriptedEntityTweener:StartAnimation(self.Properties.LineLeft, colorDuration, colorAnimParams)
    self.ScriptedEntityTweener:StartAnimation(self.Properties.LineSlice, colorDuration, colorAnimParams)
    self.ScriptedEntityTweener:StartAnimation(self.Properties.LineRight, colorDuration, colorAnimParams)
  else
    UiImageBus.Event.SetColor(self.Properties.LineLeft, color)
    UiImageBus.Event.SetColor(self.Properties.LineSlice, color)
    UiImageBus.Event.SetColor(self.Properties.LineRight, color)
  end
end
function DrawnLine:OnShutdown()
end
return DrawnLine

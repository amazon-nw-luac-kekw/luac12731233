local Icon = {
  Properties = {
    Image = {
      default = EntityId()
    },
    HoverButton = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    }
  },
  IMAGE_TYPE_STRETCHED_TO_FIT = eUiImageType_StretchedToFit,
  IMAGE_TYPE_STRETCHED = eUiImageType_Stretched,
  IMAGE_TYPE_SLICED = eUiImageType_Sliced,
  IMAGE_TYPE_FIXED = eUiImageType_Fixed,
  IMAGE_TYPE_TILED = eUiImageType_Tiled,
  isUsingTooltip = false,
  focusEnabled = false,
  focusColor = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Icon)
function Icon:OnInit()
  BaseElement.OnInit(self)
  self.color = UiImageBus.Event.GetColor(self.Properties.Image)
  self.focusColor = self.UIStyle.COLOR_WHITE
end
function Icon:SetIcon(path, color)
  self:SetPath(path)
  self:SetColor(color)
end
function Icon:SetPath(path)
  if path ~= nil then
    UiImageBus.Event.SetSpritePathname(self.Image, path)
  end
end
function Icon:SetColor(color)
  if color ~= nil then
    UiImageBus.Event.SetColor(self.Image, color)
    self.color = color
  end
end
function Icon:SetImageType(value)
  local isValid = value == self.IMAGE_TYPE_TILED or value == self.IMAGE_TYPE_FIXED or value == self.IMAGE_TYPE_SLICED or value == self.IMAGE_TYPE_STRETCHED or value == self.IMAGE_TYPE_STRETCHED_TO_FIT
  if isValid then
    UiImageBus.Event.SetImageType(self.Properties.Image, value)
  end
end
function Icon:SetFocusEnabled(isEnabled)
  self.focusEnabled = isEnabled
  UiElementBus.Event.SetIsEnabled(self.Properties.HoverButton, isEnabled)
end
function Icon:GetFocusEnabled()
  return self.focusEnabled
end
function Icon:SetFocusColor(color)
  self.focusColor = color
end
function Icon:GetFocusColor()
  return self.focusColor
end
function Icon:SetTooltip(value)
  if value == nil or value == "" then
    self.isUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.TooltipSetter, false)
  else
    self.isUsingTooltip = true
    if type(value) == "string" then
      self.TooltipSetter:SetSimpleTooltip(value)
    else
      self.TooltipSetter:SetTooltipInfo(value)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.TooltipSetter, true)
  end
end
function Icon:OnFocus()
  if not self.focusEnabled then
    return
  end
  if self.isUsingTooltip then
    self.TooltipSetter:OnTooltipSetterHoverStart()
  end
  self.ScriptedEntityTweener:Play(self.Properties.Image, 0.2, {
    imgColor = self.focusColor,
    scaleX = 1.1,
    scaleY = 1.1,
    ease = "QuadOut"
  })
end
function Icon:OnUnfocus()
  if not self.focusEnabled then
    return
  end
  if self.isUsingTooltip then
    self.TooltipSetter:OnTooltipSetterHoverEnd()
  end
  self.ScriptedEntityTweener:Play(self.Properties.Image, 0.1, {
    imgColor = self.color,
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
end
return Icon

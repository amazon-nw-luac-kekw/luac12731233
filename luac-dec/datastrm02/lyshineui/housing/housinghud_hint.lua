local HousingHUD_Hint = {
  Properties = {
    Hint = {
      default = EntityId()
    },
    Label = {
      default = EntityId()
    },
    Bg = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(HousingHUD_Hint)
function HousingHUD_Hint:OnInit()
  BaseElement.OnInit(self)
end
function HousingHUD_Hint:OnShutdown()
end
function HousingHUD_Hint:SetHousingHudHint(label, actionName, actionMap, isDisabled, tooltipText)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Label, label, eUiTextSet_SetLocalized)
  if actionMap then
    self.Hint:SetActionMap(actionMap)
  end
  if actionName then
    self.Hint:SetKeybindMapping(actionName)
  end
  self:SetIsDisabled(isDisabled)
  self:SetTooltip(tooltipText)
end
function HousingHUD_Hint:SetIsDisabled(isDisabled)
  UiImageBus.Event.SetColor(self.Properties.Bg, isDisabled == true and self.UIStyle.COLOR_HOUSING_HUD_BUTTON_DISABLED or self.UIStyle.COLOR_HOUSING_HUD_BUTTON)
  UiTextBus.Event.SetColor(self.Properties.Label, isDisabled == true and self.UIStyle.COLOR_RED_MEDIUM or self.UIStyle.COLOR_HOUSING_HUD_BUTTON_TEXT)
end
function HousingHUD_Hint:SetHintText(text)
  self.Hint:SetText(text)
end
function HousingHUD_Hint:SetTooltip(value)
  if value == nil or value == "" then
    self.isUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.isUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function HousingHUD_Hint:OnFocus()
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
end
function HousingHUD_Hint:OnUnfocus()
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
end
function HousingHUD_Hint:SetHighlightVisible(isVisible)
  self.Hint:SetHighlightVisible(isVisible)
end
function HousingHUD_Hint:GetHintWidth()
  return self.Hint:GetWidth()
end
function HousingHUD_Hint:SetLabelWidth(value)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Label, value)
end
function HousingHUD_Hint:GetLabelWidth()
  return UiTransform2dBus.Event.GetLocalWidth(self.Properties.Label)
end
return HousingHUD_Hint

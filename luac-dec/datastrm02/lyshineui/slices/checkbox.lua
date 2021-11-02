local Checkbox = {
  Properties = {
    Label = {
      default = EntityId()
    },
    Check = {
      default = EntityId()
    },
    CheckBg = {
      default = EntityId()
    },
    Glow = {
      default = EntityId()
    }
  },
  noLabelGlowWidth = 63
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Checkbox)
function Checkbox:OnInit()
  BaseElement.OnInit(self)
  self.defaultGlowWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.Glow)
  SetTextStyle(self.Properties.Label, self.UIStyle.FONT_STYLE_CHECKBOX_TEXT)
end
function Checkbox:SetCallback(table, command)
  self.callback = command
  self.callbackTable = table
end
function Checkbox:SetFocusChangeCallback(table, command)
  self.focusCallback = command
  self.focusCallbackTable = table
end
function Checkbox:SetText(value, skipLocalization)
  local labelEnabled = value ~= nil
  UiElementBus.Event.SetIsEnabled(self.Properties.Label, labelEnabled)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Glow, labelEnabled and self.defaultGlowWidth or self.noLabelGlowWidth)
  if value ~= nil then
    if not skipLocalization then
      UiTextBus.Event.SetTextWithFlags(self.Label, value, eUiTextSet_SetLocalized)
    else
      UiTextBus.Event.SetText(self.Label, value)
    end
  end
end
function Checkbox:SetTextSize(value)
  UiTextBus.Event.SetFontSize(self.Properties.Label, value)
end
function Checkbox:GetText()
  return UiTextBus.Event.GetText(self.Label)
end
function Checkbox:SetElementWidth()
  local checkBoxSize = UiTransform2dBus.Event.GetLocalWidth(self.Properties.Check)
  local labelSize = UiTextBus.Event.GetTextSize(self.Properties.Label).x
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, labelSize + checkBoxSize)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Label, labelSize)
end
function Checkbox:SetState(isChecked)
  if self:GetState() ~= isChecked then
    UiCheckboxBus.Event.SetState(self.entityId, isChecked)
  end
end
function Checkbox:GetState()
  return UiCheckboxBus.Event.GetState(self.entityId)
end
function Checkbox:OnFocus()
  self.ScriptedEntityTweener:Play(self.Label, 0.2, {
    textColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Glow, 0.2, {opacity = 1, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Item_Hover)
  self:FocusChanged(true)
end
function Checkbox:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Label, 0.2, {
    textColor = self.UIStyle.COLOR_TAN_HEADER_SECONDARY,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Glow, 0.1, {opacity = 0, ease = "QuadOut"})
  self:FocusChanged(false)
end
function Checkbox:OnChange()
  if self.callback ~= nil and self.callbackTable ~= nil then
    local isChecked = UiCheckboxBus.Event.GetState(self.entityId)
    if type(self.callback) == "function" then
      self.callback(self.callbackTable, isChecked, self.entityId)
    else
      self.callbackTable[self.callback](self.callbackTable, isChecked, self.entityId)
    end
  end
end
function Checkbox:FocusChanged(isFocused)
  if self.focusCallback ~= nil and self.focusCallbackTable ~= nil then
    if type(self.focusCallback) == "function" then
      self.focusCallback(self.focusCallbackTable, isFocused, self.entityId)
    else
      self.focusCallbackTable[self.focusCallback](self.focusCallbackTable, isFocused, self.entityId)
    end
  end
end
function Checkbox:OnShutdown()
end
return Checkbox

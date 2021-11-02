local OptionsListItem = {
  Properties = {
    ButtonText = {
      default = EntityId()
    },
    ButtonTextDescription = {
      default = EntityId()
    },
    ButtonBg = {
      default = EntityId()
    },
    ButtonInputHolder = {
      default = EntityId()
    },
    ButtonInputText = {
      default = EntityId()
    }
  },
  inputType = nil,
  width = 1230,
  height = 50,
  pressCallback = nil,
  pressTable = nil,
  initHeight = 50
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OptionsListItem)
function OptionsListItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_OPTION_BUTTON)
  SetTextStyle(self.Properties.ButtonTextDescription, self.UIStyle.FONT_STYLE_OPTION_BUTTON_DESCRIPTION)
  SetTextStyle(self.Properties.ButtonInputText, self.UIStyle.FONT_STYLE_OPTION_BUTTON_INPUT)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
end
function OptionsListItem:SetInputType(value)
  self.inputType = value
end
function OptionsListItem:GetInputType()
  return self.inputType
end
function OptionsListItem:SetCallback(command, table)
  self.pressCallback = command
  self.pressTable = table
end
function OptionsListItem:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function OptionsListItem:GetInputHolder()
  return self.ButtonInputHolder
end
function OptionsListItem:GetWidth()
  return self.width
end
function OptionsListItem:SetHeight(height)
  self.height = height
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, self.height)
  UiLayoutCellBus.Event.SetMinHeight(self.entityId, self.height)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.ButtonInputHolder, self.height)
end
function OptionsListItem:GetHeight()
  return self.height
end
function OptionsListItem:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ButtonText, value, eUiTextSet_SetLocalized)
end
function OptionsListItem:GetText()
  return UiTextBus.Event.GetText(self.Properties.ButtonText)
end
function OptionsListItem:SetTextColor(color)
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, 2, {textColor = color})
end
function OptionsListItem:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.Properties.ButtonText, value)
end
function OptionsListItem:GetFontSize()
  return UiTextBus.Event.GetFontSize(self.Properties.ButtonText)
end
function OptionsListItem:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.Properties.ButtonText, value)
end
function OptionsListItem:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.Properties.ButtonText)
end
function OptionsListItem:SetTextStyle(value)
  SetTextStyle(self.Properties.ButtonText, value)
end
function OptionsListItem:SetTextDescription(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ButtonTextDescription, value, eUiTextSet_SetLocalized)
  self:ResizeHeightToText()
end
function OptionsListItem:ResizeHeightToText()
  local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.ButtonTextDescription)
  local textValue = UiTextBus.Event.GetText(self.Properties.ButtonTextDescription)
  local textPadding = 15
  local newHeight = textValue ~= "" and self.initHeight + textHeight - textPadding or self.initHeight - textPadding
  self:SetHeight(newHeight)
end
function OptionsListItem:GetTextDescription()
  return UiTextBus.Event.GetText(self.Properties.ButtonTextDescription)
end
function OptionsListItem:SetTextInput(value)
  UiTextBus.Event.SetText(self.Properties.ButtonInputText, value)
end
function OptionsListItem:GetTextInput()
  return UiTextBus.Event.GetText(self.Properties.ButtonInputText)
end
function OptionsListItem:OnFocus()
  local animDuration1 = 0.15
  local animDuration2 = 0.2
  local animDuration3 = 0.45
  local animDuration4 = 0.9
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:Play(self.Properties.ButtonTextDescription, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:Play(self.Properties.ButtonInputText, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.ButtonBg:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_OptionsListItem)
end
function OptionsListItem:OnUnfocus(forceClose)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  local screenPoint = UiCanvasBus.Event.GetMousePosition(self.canvasId)
  local point = UiTransformBus.Event.ViewportPointToLocalPoint(self.entityId, screenPoint)
  local isInboundX = point.x > 0 and point.x < self.width
  local isInboundY = 0 < point.y and point.y < self.height
  if isInboundX == true and isInboundY == true and forceClose ~= true then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, 0.3, {opacity = 1, ease = "QuadOut"})
    return
  end
  local animDuration1 = 0.15
  local animDuration2 = 0.1
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:Play(self.Properties.ButtonTextDescription, animDuration1, {
    textColor = self.UIStyle.COLOR_GRAY_70
  })
  self.ScriptedEntityTweener:Play(self.Properties.ButtonInputText, animDuration1, {
    textColor = self.UIStyle.COLOR_GRAY_70
  })
  self.ButtonBg:OnUnfocus()
  local buttonInput = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.ButtonInputHolder, 0))
  if buttonInput ~= nil and self.inputType == "Dropdown" then
    UiDropdownBus.Event.Collapse(buttonInput.entityId)
  end
end
function OptionsListItem:OnPress()
  if self.pressCallback ~= nil and self.pressTable ~= nil then
    self.pressTable[self.pressCallback](self.pressTable)
    self.audioHelper:PlaySound(self.audioHelper.Accept)
  end
end
function OptionsListItem:OnShutdown()
end
return OptionsListItem

local LabelWithTextInput = {
  Properties = {
    Label = {
      default = EntityId(),
      order = 1
    },
    TextInput = {
      default = EntityId(),
      order = 2
    },
    ValidateForNumbers = {default = true, order = 3},
    PreviewText = {
      default = EntityId(),
      order = 4
    },
    autoResizeInput = {default = true, order = 10}
  },
  prevInputText = ""
}
BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(LabelWithTextInput)
function LabelWithTextInput:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  UiTextInputBus.Event.SetTextSelectionColor(self.Properties.TextInput, self.UIStyle.COLOR_INPUT_SELECTION)
end
function LabelWithTextInput:SetLabel(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Label, value, eUiTextSet_SetLocalized)
end
function LabelWithTextInput:SetInputValue(value)
  local newText = tostring(value)
  local curText = UiTextInputBus.Event.GetText(self.Properties.TextInput)
  if newText ~= curText then
    UiTextInputBus.Event.SetText(self.Properties.TextInput, newText)
    self:OnTextInputChange()
  end
end
function LabelWithTextInput:SetPreviewText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.PreviewText, value, eUiTextSet_SetLocalized)
end
function LabelWithTextInput:GetInputValue()
  return UiTextInputBus.Event.GetText(self.Properties.TextInput)
end
function LabelWithTextInput:SetIsInteractable(isInteractable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.TextInput, isInteractable)
end
function LabelWithTextInput:SetMaxStringLength(length)
  UiTextInputBus.Event.SetMaxStringLength(self.Properties.TextInput, length)
end
function LabelWithTextInput:ResizeTextInputBox()
  if not self.Properties.autoResizeInput then
    return
  end
  local textEntity = UiTextInputBus.Event.GetTextEntity(self.Properties.TextInput)
  local textSize = UiTextBus.Event.GetTextSize(textEntity)
  local inputTextPadding = 3
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.TextInput, textSize.x + inputTextPadding)
end
function LabelWithTextInput:OnTextInputChange()
  local currentText = UiTextInputBus.Event.GetText(self.Properties.TextInput)
  if self.Properties.ValidateForNumbers then
    local number, success = GetValueFromLocalized(currentText)
    if currentText ~= "" and not success then
      UiTextInputBus.Event.SetText(self.Properties.TextInput, self.prevInputText)
      return
    end
  end
  self.prevInputText = currentText
  if self.onChangeSelf then
    self.onChangeCallback(self.onChangeSelf, currentText)
  end
end
function LabelWithTextInput:OnTextInputStartEdit()
  SetActionmapsForTextInput(self.canvasId, true)
  if self.Properties.PreviewText then
    UiElementBus.Event.SetIsEnabled(self.Properties.PreviewText, false)
  end
end
function LabelWithTextInput:OnTextInputEndEdit()
  SetActionmapsForTextInput(self.canvasId, false)
  self:TriggerCallback(false)
end
function LabelWithTextInput:OnTextInputEnter()
  self:TriggerCallback(true)
end
function LabelWithTextInput:TriggerCallback(enterPressed)
  local currentText = UiTextInputBus.Event.GetText(self.Properties.TextInput)
  if self.callerSelf then
    self.callerFunc(self.callerSelf, currentText, enterPressed)
  end
end
function LabelWithTextInput:SetCallback(callerSelf, callerFunc)
  self.callerSelf = callerSelf
  self.callerFunc = callerFunc
end
function LabelWithTextInput:SetOnChangeCallback(callerSelf, callerFunc)
  self.onChangeSelf = callerSelf
  self.onChangeCallback = callerFunc
end
function LabelWithTextInput:OnShutdown()
end
return LabelWithTextInput

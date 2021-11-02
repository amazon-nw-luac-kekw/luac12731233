local SliderWithTextInput = {
  Properties = {
    Slider = {
      default = EntityId(),
      order = 1
    },
    SliderTextInput = {
      default = EntityId(),
      order = 2
    },
    SliderCurrentValueText = {
      default = EntityId(),
      order = 3
    },
    SliderExtraValueText = {
      default = EntityId(),
      order = 4
    },
    SliderMinValueText = {
      default = EntityId(),
      order = 5
    },
    SliderMaxValueText = {
      default = EntityId(),
      order = 6
    },
    SliderTextPadding = {default = 15, order = 7},
    SliderTextInputMaxDigits = {default = 9, order = 8},
    CrownIcons = {
      default = {
        EntityId()
      },
      order = 9
    },
    Label = {
      default = EntityId(),
      order = 10
    },
    autoResizeInput = {default = true, order = 11}
  },
  SLIDER_STYLE_0 = 0,
  SLIDER_STYLE_1 = 1,
  SLIDER_STYLE_2 = 2,
  mSliderCurrentValue = 0,
  mInputTextPreviousValue = "",
  mSliderCurrentStyle = 0,
  isShowingCrownIcons = true
}
BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SliderWithTextInput)
function SliderWithTextInput:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.Slider:SetTextInput(self)
  UiTextInputBus.Event.SetTextSelectionColor(self.SliderTextInput, self.UIStyle.COLOR_INPUT_SELECTION)
end
function SliderWithTextInput:SetSliderStyle(value)
  if value == self.SLIDER_STYLE_1 then
    self.mSliderCurrentStyle = self.SLIDER_STYLE_1
    local inputBoxWidth = 250
    local inputBoxHeight = 60
    local inputBoxOffsetY = -80
    self.ScriptedEntityTweener:Set(self.Properties.SliderTextInput, {
      y = inputBoxOffsetY,
      x = 0,
      w = inputBoxWidth,
      h = inputBoxHeight
    })
    UiTransform2dBus.Event.SetOffsets(self.Properties.SliderCurrentValueText, UiOffsets(0, 0, 0, -4))
    local currentValueTextStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
      fontSize = 60,
      hAlignment = self.UIStyle.TEXT_HALIGN_CENTER
    }
    SetTextStyle(self.Properties.SliderCurrentValueText, currentValueTextStyle)
    self:SetMaxValueTextPosition()
    local sliderWidth = self.Slider:GetWidth()
    local extraValuePosX = -sliderWidth / 2
    self.ScriptedEntityTweener:Set(self.Properties.SliderExtraValueText, {x = extraValuePosX})
    local currentText = UiTextBus.Event.GetText(self.Properties.SliderCurrentValueText)
    if self.isCurrencyDisplay then
      currentText = GetLocalizedCurrency(tonumber(currentText))
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.SliderExtraValueText, true)
    UiTextBus.Event.SetText(self.Properties.SliderExtraValueText, currentText)
  elseif value == self.SLIDER_STYLE_2 then
    self.mSliderCurrentStyle = self.SLIDER_STYLE_2
    local inputBoxWidth = 250
    local inputBoxHeight = 40
    local inputBoxOffsetY = -50
    self.ScriptedEntityTweener:Set(self.Properties.SliderTextInput, {
      y = inputBoxOffsetY,
      x = 0,
      w = inputBoxWidth,
      h = inputBoxHeight
    })
    UiTransform2dBus.Event.SetOffsets(self.Properties.SliderCurrentValueText, UiOffsets(0, 0, 0, -4))
    local currentValueTextStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
      fontSize = 36,
      hAlignment = self.UIStyle.TEXT_HALIGN_CENTER
    }
    SetTextStyle(self.Properties.SliderCurrentValueText, currentValueTextStyle)
    self:SetMaxValueTextPosition()
    local sliderWidth = self.Slider:GetWidth()
    local extraValuePosX = -sliderWidth / 2
    self.ScriptedEntityTweener:Set(self.Properties.SliderExtraValueText, {x = extraValuePosX})
    local currentText = UiTextBus.Event.GetText(self.Properties.SliderCurrentValueText)
    if self.isCurrencyDisplay then
      currentText = GetLocalizedCurrency(tonumber(currentText))
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.SliderExtraValueText, true)
    UiTextBus.Event.SetText(self.Properties.SliderExtraValueText, currentText)
  end
end
function SliderWithTextInput:SetMaxValueTextPosition()
  local sliderWidth = self.Slider:GetWidth()
  local maxValueWidth = UiTransform2dBus.Event.GetLocalWidth(self.SliderMaxValueText)
  local iconWidth = 10
  local maxValuePosX = sliderWidth / 2 - maxValueWidth / 2 - iconWidth
  self.ScriptedEntityTweener:Set(self.Properties.SliderMaxValueText, {y = 20, x = maxValuePosX})
  UiElementBus.Event.SetIsEnabled(self.Properties.CrownIcons[1], false)
end
function SliderWithTextInput:SetCurrencyDisplay(isCurrency)
  self.isCurrencyDisplay = isCurrency
end
function SliderWithTextInput:SetSliderText(value)
  if self.isCurrencyDisplay then
    value = GetLocalizedCurrency(math.floor(value))
  else
    value = math.floor(value)
  end
  local newText = tostring(value)
  local curText = UiTextBus.Event.GetText(self.SliderCurrentValueText)
  self.mInputTextPreviousValue = curText
  if newText ~= curText then
    UiTextBus.Event.SetText(self.SliderCurrentValueText, newText)
    self.mSliderCurrentValue = value
  end
end
function SliderWithTextInput:ResetSlider(value)
  self:SetSliderText(value)
  local curText = UiTextBus.Event.GetText(self.SliderCurrentValueText)
  self.mInputTextPreviousValue = curText
end
function SliderWithTextInput:SetLabel(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Label, value, eUiTextSet_SetLocalized)
end
function SliderWithTextInput:ResizeTextInputBox()
  if not self.autoResizeInput then
    return
  end
  local textSize = UiTextBus.Event.GetTextSize(self.SliderCurrentValueText)
  UiTransform2dBus.Event.SetLocalWidth(self.SliderTextInput, textSize.x + self.SliderTextPadding)
  UiTransform2dBus.Event.SetLocalWidth(self.SliderCurrentValueText, textSize.x + self.SliderTextPadding)
end
function SliderWithTextInput:OnTextInputChange()
  local currentText = UiTextInputBus.Event.GetText(self.SliderTextInput)
  local separator = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_decimal_separator")
  if currentText == "" or currentText == separator or currentText == "-" or currentText == "-" .. separator then
    self.mInputTextPreviousValue = currentText
    return
  end
  local _, countSpaces = string.gsub(currentText, "%s", "")
  local _, countDigits = string.gsub(currentText, "%d", "")
  local value, valueFromLocalizedSuccess = GetValueFromLocalized(currentText, self.isCurrencyDisplay)
  if not (not (0 < countSpaces) and not (countDigits > self.Properties.SliderTextInputMaxDigits) and value) or not valueFromLocalizedSuccess then
    currentText = self.mInputTextPreviousValue
    UiTextInputBus.Event.SetText(self.SliderTextInput, currentText)
    return
  end
  value = Math.Clamp(value, self.Slider:GetMinValue(), self.Slider:GetMaxValue())
  self.Slider:SetSliderValue(value, true)
  self.mInputTextPreviousValue = currentText
end
function SliderWithTextInput:OnTextInputStartEdit()
  SetActionmapsForTextInput(self.canvasId, true)
end
function SliderWithTextInput:OnTextInputEndEdit()
  local value = self.Slider:GetValue()
  value = Math.Clamp(value, self.Slider:GetMinValue(), self.Slider:GetMaxValue())
  if self.isCurrencyDisplay then
    self.mInputTextPreviousValue = GetLocalizedCurrency(value, true)
  else
    self.mInputTextPreviousValue = string.format("%d", value)
  end
  UiTextInputBus.Event.SetText(self.SliderTextInput, self.mInputTextPreviousValue)
  SetActionmapsForTextInput(self.canvasId, false)
end
function SliderWithTextInput:OnTextInputEnter()
end
function SliderWithTextInput:SetSliderValue(value, skipTextUpdate, skipCallback, durationOverride, boundsCheck)
  self.Slider:SetSliderValue(value, skipTextUpdate, skipCallback, durationOverride, boundsCheck)
end
function SliderWithTextInput:GetSliderValue()
  return self.Slider:GetValue()
end
function SliderWithTextInput:SetSliderMaxValue(maxValue)
  self.Slider:SetMaxValue(tonumber(maxValue))
  if self.Properties.SliderMaxValueText:IsValid() then
    if self.isCurrencyDisplay then
      maxValue = GetLocalizedCurrency(maxValue)
    end
    UiTextBus.Event.SetText(self.Properties.SliderMaxValueText, maxValue)
    local textSize = UiTextBus.Event.GetTextSize(self.Properties.SliderMaxValueText)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.SliderMaxValueText, textSize.x + self.SliderTextPadding)
    if self.mSliderCurrentStyle == self.SLIDER_STYLE_1 then
      self:SetMaxValueTextPosition()
    end
  end
end
function SliderWithTextInput:SetSliderMinValue(minValue)
  self.Slider:SetMinValue(minValue)
  if self.Properties.SliderMinValueText:IsValid() then
    if self.isCurrencyDisplay then
      minValue = GetLocalizedCurrency(minValue)
    end
    UiTextBus.Event.SetText(self.Properties.SliderMinValueText, minValue)
    local textSize = UiTextBus.Event.GetTextSize(self.Properties.SliderMinValueText)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.SliderMinValueText, textSize.x + self.SliderTextPadding)
  end
end
function SliderWithTextInput:SetCallback(command, table)
  self.Slider:SetCallback(command, table)
end
function SliderWithTextInput:HideCrownIcons()
  for _, image in pairs(self.Properties.CrownIcons) do
    UiElementBus.Event.SetIsEnabled(image, false)
  end
  self.isShowingCrownIcons = false
end
function SliderWithTextInput:SetSliderTextVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.SliderExtraValueText, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.SliderMaxValueText, isVisible)
end
function SliderWithTextInput:OnShutdown()
end
function SliderWithTextInput:SetTextInputWidth(width)
  self.autoResizeInput = false
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.SliderTextInput, width)
end
function SliderWithTextInput:SetMaxStringLength(length)
  UiTextInputBus.Event.SetMaxStringLength(self.Properties.SliderTextInput, length)
end
function SliderWithTextInput:SetInputMaxDigits(length)
  self.Properties.SliderTextInputMaxDigits = length
end
function SliderWithTextInput:SizeChildrenToSelf()
  local totalW = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  local halfW = totalW / 2
  local textInputWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.SliderTextInput)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.SliderTextInput, textInputWidth / 2 - halfW)
  local maxValueWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.SliderMaxValueText)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.SliderMaxValueText, halfW - maxValueWidth / 2)
  local extraMargin = 12
  local sliderWidth = totalW - textInputWidth - maxValueWidth - extraMargin
  local sliderX = textInputWidth - maxValueWidth + extraMargin
  if self.isShowingCrownIcons then
    sliderX = sliderX + 24
    sliderWidth = sliderWidth - 24
  end
  self.Slider:SetWidth(sliderWidth)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Slider, sliderWidth)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.Slider, sliderX)
end
return SliderWithTextInput

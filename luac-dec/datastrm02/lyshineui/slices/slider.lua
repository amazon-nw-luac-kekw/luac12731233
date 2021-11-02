local Slider = {
  Properties = {
    SliderText = {
      default = EntityId()
    },
    SliderHandleHolder = {
      default = EntityId()
    },
    SliderHandleFocus = {
      default = EntityId()
    },
    SliderHandleArrowLeft = {
      default = EntityId()
    },
    SliderHandleArrowRight = {
      default = EntityId()
    },
    SliderFillHolder = {
      default = EntityId()
    },
    SliderFillLeft = {
      default = EntityId()
    },
    SliderFillRight = {
      default = EntityId()
    },
    SliderFillSlice = {
      default = EntityId()
    },
    SliderTextureLeft = {
      default = EntityId()
    },
    SliderTextureRight = {
      default = EntityId()
    },
    SliderTextureCenter = {
      default = EntityId()
    },
    SliderFrameLeft = {
      default = EntityId()
    },
    SliderFrameRight = {
      default = EntityId()
    },
    SliderFrameSlice = {
      default = EntityId()
    },
    SliderValueTween = {
      default = EntityId()
    },
    snapToIntegers = {
      default = false,
      description = "If checked, the handle will snap to the location for values. This is often nice if there are a small number of possible values."
    },
    triggerCallbackOnUpdate = {
      default = false,
      description = "If checked, a callback applied for when the user is done dragging will also fire as the user is dragging."
    },
    clampHandle = {
      default = true,
      description = "If checked, the handle will be clamped inside of the slider"
    }
  },
  mWidth = 0,
  mHeight = 0,
  mSliderCurrentValue = nil,
  mSliderCallback = nil,
  mSliderTable = nil,
  mSliderMultiplier = 1,
  mSliderPrefix = "",
  mSliderSuffix = "",
  mIsSliderHandleFocused = nil,
  mTextInput = nil,
  releasedFunc = nil,
  releasedTable = nil,
  MAX_EXACTLY_REPRESENTABLE_NUMBER = 9007199254740992,
  actualMaxValue = 1,
  sliderMaxValue = 1,
  actualSetValue = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Slider)
function Slider:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiSliderNotificationBus, self.entityId)
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetWidth(self.mWidth)
  self:SetHeight(self.mHeight)
  self.sliderMaxValue = UiSliderBus.Event.GetMaxValue(self.entityId)
  self.actualMaxValue = self.sliderMaxValue
  self:SetLineColor(self.UIStyle.COLOR_GRAY_60)
  self:SetTextureColor(self.UIStyle.COLOR_SLIDER_TEXTURE_ORANGE)
  self:SetSliderValue()
end
function Slider:OnSliderValueChanged(value)
  self:SetSliderValue(value)
end
function Slider:SetCallback(command, table)
  self.mSliderCallback = command
  self.mSliderTable = table
end
function Slider:SetSliderReleasedCallback(func, table)
  self.releasedFunc = func
  self.releasedTable = table
end
function Slider:SliderReleased()
  if self.releasedFunc and self.releasedTable then
    self.releasedFunc(self.releasedTable)
  end
  self.mIsSliderHandlePressed = false
  if not GetIsMouseOverEntity(self.Properties.SliderHandleHolder) then
    self:OnSliderHandleUnfocus()
  end
end
function Slider:SetMultiplier(value)
  self.mSliderMultiplier = value
end
function Slider:GetMultiplier()
  return self.mSliderMultiplier
end
function Slider:SetDisplayToGameDataFunc(func)
  self.mDisplayToGameDataFunc = func
end
function Slider:GetDisplayToGameDataFunc()
  return self.mDisplayToGameDataFunc
end
function Slider:SetPrefix(value)
  self.mSliderPrefix = value
end
function Slider:GetPrefix()
  return self.mSliderPrefix
end
function Slider:SetSuffix(value)
  self.mSliderSuffix = value
end
function Slider:GetSuffix()
  return self.mSliderSuffix
end
function Slider:SetWidth(width)
  self.mWidth = width
  local fillEndCapWidth = 14
  local offsetPositionX = 2
  self.ScriptedEntityTweener:Set(self.entityId, {w = width})
  self.ScriptedEntityTweener:Set(self.SliderFillSlice, {
    w = width + offsetPositionX * 2 - fillEndCapWidth * 2
  })
  UiTransformBus.Event.SetLocalPosition(self.SliderFillLeft, Vector2(-offsetPositionX, 0))
  UiTransformBus.Event.SetLocalPosition(self.SliderFillRight, Vector2(width + offsetPositionX - fillEndCapWidth, 0))
  UiTransformBus.Event.SetLocalPosition(self.SliderFillSlice, Vector2(fillEndCapWidth - offsetPositionX, 0))
end
function Slider:GetWidth()
  return self.mWidth
end
function Slider:SetHeight(height)
  self.mHeight = height
end
function Slider:GetHeight(height)
  return self.mHeight
end
function Slider:GetSliderPercentage()
  local sliderVal = self:GetValue()
  local minVal = self:GetMinValue()
  local valueRange = self:GetMaxValue() - minVal
  if valueRange == 0 then
    return 1
  end
  local unitValue = (sliderVal - minVal) / valueRange
  return unitValue
end
function Slider:SetMinimumSliderAtQuantity(quantity)
  self.setMinimumSlider = true
  self.minimumSliderQuantity = quantity
  self:SetSliderValue(quantity)
  self.quantityWidth = self.mWidth * self:GetSliderPercentage()
end
function Slider:GetMinimumQuantity()
  return self.minimumSliderQuantity or self:GetMinValue() or 0
end
function Slider:UpdateSliderValue()
  self.actualSetValue = nil
  local sliderVal = self:GetValue()
  if sliderVal == self.lastSliderVal then
    return
  end
  local sliderFillWidth = self.mWidth * self:GetSliderPercentage()
  UiTransform2dBus.Event.SetLocalWidth(self.SliderFillHolder, sliderFillWidth)
  local sliderHandleHolderWidth = UiTransform2dBus.Event.GetLocalWidth(self.SliderHandleHolder)
  local sliderHandleHolderPosX
  if self.setMinimumSlider and self.quantityWidth then
    local minHandlePosition = sliderFillWidth < self.quantityWidth and self.quantityWidth or sliderFillWidth
    sliderHandleHolderPosX = minHandlePosition - sliderHandleHolderWidth / 2
    UiTransform2dBus.Event.SetLocalWidth(self.SliderFillHolder, minHandlePosition)
  else
    sliderHandleHolderPosX = sliderFillWidth - sliderHandleHolderWidth / 2
  end
  if self.Properties.clampHandle then
    if sliderHandleHolderPosX < 0 then
      sliderHandleHolderPosX = 0
    elseif sliderHandleHolderPosX > self.mWidth - sliderHandleHolderWidth then
      sliderHandleHolderPosX = self.mWidth - sliderHandleHolderWidth
    end
  end
  UiTransformBus.Event.SetLocalPosition(self.SliderHandleHolder, Vector2(sliderHandleHolderPosX, 0))
  sliderVal = self.setMinimumSlider and self.minimumSliderQuantity and tonumber(sliderVal) < self.minimumSliderQuantity and tostring(self.minimumSliderQuantity) or sliderVal
  self:SetSliderText(sliderVal)
  self:OnSliderHandleFocus()
  if self.Properties.triggerCallbackOnUpdate then
    self:ExecuteCallback()
  end
  self.lastSliderVal = sliderVal
end
function Slider:SetSliderValue(value, skipTextUpdate, skipCallback, durationOverride, boundsCheck)
  if type(value) == "number" then
    if boundsCheck then
      value = Clamp(value, self:GetMinValue(), self:GetMaxValue())
    end
    if self.Properties.snapToIntegers then
      value = GetRoundedNumber(value, 0)
    end
    self.actualSetValue = value * self.mSliderMultiplier
    if self.actualMaxValue ~= self.sliderMaxValue then
      value = value * self.mSliderMultiplier / self.actualMaxValue * self.sliderMaxValue
    else
      value = value * self.mSliderMultiplier
    end
    UiSliderBus.Event.SetValue(self.entityId, value)
  elseif not value then
    return
  end
  local sliderVal = self:GetValue()
  local maxValue = self:GetMaxValue()
  local sliderFillWidth = 0 < maxValue and self.mWidth * self:GetSliderPercentage() or 0
  local animDuration = durationOverride or 0.1
  self.ScriptedEntityTweener:Play(self.SliderFillHolder, animDuration, {w = sliderFillWidth, ease = "QuadOut"})
  local sliderHandleHolderWidth = UiTransform2dBus.Event.GetLocalWidth(self.SliderHandleHolder)
  local sliderHandleHolderPosX = sliderFillWidth - sliderHandleHolderWidth / 2
  if self.Properties.clampHandle then
    if sliderHandleHolderPosX < 0 then
      sliderHandleHolderPosX = 0
    elseif sliderHandleHolderPosX > self.mWidth - sliderHandleHolderWidth then
      sliderHandleHolderPosX = self.mWidth - sliderHandleHolderWidth
    end
  end
  self.ScriptedEntityTweener:Play(self.SliderHandleHolder, animDuration, {
    x = sliderHandleHolderPosX,
    ease = "QuadOut",
    onComplete = function()
      if not skipTextUpdate then
        self:SetSliderText(sliderVal)
      end
    end
  })
  if self.mSliderCurrentValue ~= nil and self.mSliderCurrentValue ~= math.floor(sliderVal) then
    UiTransformBus.Event.SetLocalPosition(self.SliderValueTween, Vector2(self.mSliderCurrentValue, 0))
    self.ScriptedEntityTweener:Play(self.SliderValueTween, animDuration, {
      x = sliderVal,
      ease = "QuadOut",
      onUpdate = function(currentValue, currentProgressPercent)
        if currentProgressPercent ~= 0 and not skipTextUpdate then
          self:SetSliderText(currentValue, currentProgressPercent)
        end
      end
    })
  end
  self:OnSliderHandleUnfocus()
  if not skipCallback then
    self:ExecuteCallback()
  end
  self.lastSliderVal = sliderVal
end
function Slider:ExecuteCallback()
  if self.mSliderCallback ~= nil and self.mSliderTable ~= nil then
    if type(self.mSliderCallback) == "function" then
      self.mSliderCallback(self.mSliderTable, self)
    else
      self.mSliderTable[self.mSliderCallback](self.mSliderTable, self)
    end
  end
end
function Slider:SetSliderText(value)
  if self.mTextInput == nil then
    value = math.floor(value)
    local newText = tostring(self.mSliderPrefix .. value .. self.mSliderSuffix)
    local curText = UiTextBus.Event.GetText(self.SliderText)
    if newText ~= curText then
      if self.mSliderCurrentValue ~= nil then
        self.audioHelper:PlaySound(self.audioHelper.OnSliderChanged)
      end
      UiTextBus.Event.SetText(self.SliderText, newText)
      self.mSliderCurrentValue = value
    end
  else
    self.mTextInput:SetSliderText(value)
  end
end
function Slider:SetColor(color)
  UiImageBus.Event.SetColor(self.Properties.SliderFillLeft, color)
  UiImageBus.Event.SetColor(self.Properties.SliderFillRight, color)
  UiImageBus.Event.SetColor(self.Properties.SliderFillSlice, color)
end
function Slider:SetTextureColor(color)
  UiImageBus.Event.SetColor(self.Properties.SliderTextureLeft, color)
  UiImageBus.Event.SetColor(self.Properties.SliderTextureRight, color)
  UiImageBus.Event.SetColor(self.Properties.SliderTextureCenter, color)
end
function Slider:SetLineColor(color, duration, params)
  local defaultDuration = 0.5
  local defaultDelay = 0
  local defaultEase = "QuadOut"
  local animDuration = duration ~= nil and duration or defaultDuration
  local animDelay = defaultDelay
  local animEase = defaultEase
  if params ~= nil then
    animDelay = params.delay ~= nil and params.delay or defaultDelay
    animEase = params.ease ~= nil and params.ease or defaultEase
  end
  if duration ~= nil then
    self.ScriptedEntityTweener:Play(self.SliderFrameLeft, animDuration, {
      imgColor = color,
      ease = animEase,
      delay = animDelay
    })
    self.ScriptedEntityTweener:Play(self.SliderFrameRight, animDuration, {
      imgColor = color,
      ease = animEase,
      delay = animDelay
    })
    self.ScriptedEntityTweener:Play(self.SliderFrameSlice, animDuration, {
      imgColor = color,
      ease = animEase,
      delay = animDelay
    })
  else
    UiImageBus.Event.SetColor(self.SliderFrameLeft, color)
    UiImageBus.Event.SetColor(self.SliderFrameRight, color)
    UiImageBus.Event.SetColor(self.SliderFrameSlice, color)
  end
end
function Slider:OnSliderHandleFocus()
  if self.mIsSliderHandleFocused == true or self.mIsSliderHandlePressed then
    return
  end
  local animDuration = 0.08
  local animDurationAlpha = 0.02
  local leftArrowOffsetPosX = 22
  local rightArrowOffsetPosX = 23
  self.ScriptedEntityTweener:Play(self.SliderHandleFocus, animDuration, {
    scaleX = 1.4,
    scaleY = 1.4,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.SliderHandleArrowLeft, animDuration, {
    x = -leftArrowOffsetPosX,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.SliderHandleArrowRight, animDuration, {x = rightArrowOffsetPosX, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.OnFocusStart)
  if self.mIsSliderHandleFocused ~= true then
    self.mIsSliderHandleFocused = true
  end
end
function Slider:OnSliderHandleUnfocus()
  if not self.mIsSliderHandleFocused or self.mIsSliderHandlePressed then
    return
  end
  self.mIsSliderHandleFocused = false
  local animDuration = 0.2
  self.ScriptedEntityTweener:Play(self.SliderHandleFocus, animDuration, {
    scaleX = 0.5,
    scaleY = 0.5,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.SliderHandleFocus, animDuration, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.SliderHandleArrowLeft, animDuration, {x = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.SliderHandleArrowRight, animDuration, {x = 0, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.OnFocusStop)
end
function Slider:OnSliderHandlePressed()
  self.mIsSliderHandlePressed = true
end
function Slider:OnSliderHandleReleased()
  self.mIsSliderHandlePressed = false
end
function Slider:GetText()
  return UiTextBus.Event.GetText(self.ButtonText)
end
function Slider:GetValue()
  if self.actualSetValue then
    return self.actualSetValue
  end
  local value = UiSliderBus.Event.GetValue(self.entityId) or 0
  if self.actualMaxValue ~= self.sliderMaxValue then
    value = value / self.sliderMaxValue * self.actualMaxValue
  end
  if self.Properties.snapToIntegers then
    value = GetRoundedNumber(value, 0)
  end
  return value
end
function Slider:SetMaxValue(maxValue)
  if maxValue <= self.MAX_EXACTLY_REPRESENTABLE_NUMBER then
    self.actualMaxValue = maxValue
    self.sliderMaxValue = maxValue
  else
    self.actualMaxValue = maxValue
    self.sliderMaxValue = self.MAX_EXACTLY_REPRESENTABLE_NUMBER
  end
  UiSliderBus.Event.SetMaxValue(self.entityId, self.sliderMaxValue)
end
function Slider:GetMaxValue()
  return self.actualMaxValue
end
function Slider:SetMinValue(value)
  UiSliderBus.Event.SetMinValue(self.entityId, value)
end
function Slider:GetMinValue()
  return UiSliderBus.Event.GetMinValue(self.entityId)
end
function Slider:SetTextInput(textInput)
  if textInput ~= nil then
    self.mTextInput = textInput
    UiElementBus.Event.SetIsEnabled(self.SliderText, false)
  end
end
function Slider:RemoveTextInput()
  self.mHasTextInput = nil
  UiElementBus.Event.SetIsEnabled(self.SliderText, true)
end
function Slider:SetSliderTextVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.SliderText, isVisible)
end
function Slider:OnShutdown()
end
return Slider

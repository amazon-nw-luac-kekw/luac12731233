local WeightBar = {
  Properties = {
    drawFromRight = {
      default = false,
      description = "When checked, the lines for the frame will draw in from the right instead of the left.",
      order = 0
    },
    showTopLine = {
      default = true,
      description = "When unchecked, no top line will render on the frame, allowing the bar to hang below something else instead",
      order = 1
    },
    showBottomLine = {
      default = true,
      description = "When unchecked, no bottom line will render on the frame, allowing the bar to hang below something else instead",
      order = 2
    },
    Frame = {
      TopLine = {
        default = EntityId()
      },
      BottomLine = {
        default = EntityId()
      },
      LeftLine = {
        default = EntityId()
      },
      RightLine = {
        default = EntityId()
      },
      Divider1 = {
        default = EntityId()
      },
      Divider2 = {
        default = EntityId()
      },
      DividerText1 = {
        default = EntityId()
      },
      DividerText2 = {
        default = EntityId()
      }
    },
    BarContainer = {
      default = EntityId()
    },
    BarFill = {
      default = EntityId()
    },
    BarOverage = {
      default = EntityId()
    },
    BarSegment = {
      default = EntityId()
    },
    ValueText = {
      default = EntityId()
    },
    MaxValueText = {
      default = EntityId()
    },
    WeightIcon = {
      default = EntityId()
    },
    OverageIndicators = {
      default = EntityId()
    },
    OverageIcon = {
      default = EntityId()
    },
    OverageText = {
      default = EntityId()
    }
  },
  FRAME_SETTINGS = {
    TopLine = {
      minOffset = -36,
      maxOffset = -24,
      minOvershoot = 54,
      maxOvershoot = 90,
      delay = 0,
      duration = 0.9
    },
    BottomLine = {
      minOffset = -18,
      maxOffset = -6,
      minOvershoot = 18,
      maxOvershoot = 36,
      delay = 0.2,
      duration = 1.4
    },
    LeftLine = {delay = 0.25, duration = 0.3},
    RightLine = {delay = 0.8, duration = 0.3},
    Divider1 = {delay = 0.2, duration = 0.2},
    Divider2 = {delay = 0.2, duration = 0.2}
  },
  value = 0,
  maxValue = 50,
  maxOveragePercent = 0.2,
  stackSplitValue = 0,
  barAnimationDuration = 0.3,
  segments = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WeightBar)
function WeightBar:OnInit()
  if self.Properties.drawFromRight then
    local origRightDelay = self.FRAME_SETTINGS.RightLine.delay
    self.FRAME_SETTINGS.RightLine.delay = self.FRAME_SETTINGS.LeftLine.delay
    self.FRAME_SETTINGS.LeftLine.delay = origRightDelay
  end
  self.barOverageTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.barOverageTimeline:Add(self.BarOverage, self.UIStyle.DURATION_TIMELINE_HOLD, {
    imgColor = self.UIStyle.COLOR_RED
  })
  self.barOverageTimeline:Add(self.BarOverage, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
    imgColor = self.UIStyle.COLOR_RED_DARKER
  })
  self.barOverageTimeline:Add(self.BarOverage, self.UIStyle.DURATION_TIMELINE_FADE_IN, {
    imgColor = self.UIStyle.COLOR_RED,
    onComplete = function()
      self.barOverageTimeline:Play()
    end
  })
  SetTextStyle(self.ValueText, self.UIStyle.FONT_STYLE_WEIGHT_VALUE)
  SetTextStyle(self.MaxValueText, self.UIStyle.FONT_STYLE_WEIGHT_MAX_VALUE)
  SetTextStyle(self.OverageText, self.UIStyle.FONT_STYLE_WEIGHT_OVERAGE)
  UiImageBus.Event.SetColor(self.BarOverage, self.UIStyle.COLOR_RED)
  UiImageBus.Event.SetColor(self.OverageIcon, self.UIStyle.COLOR_RED)
  UiImageBus.Event.SetColor(self.BarFill, self.UIStyle.COLOR_TAN)
  UiFaderBus.Event.SetFadeValue(self.OverageIndicators, 0)
  self:SetupFrame()
  self:SetFrameColor(self.UIStyle.COLOR_GRAY_80)
  self:SetMaxValue(self.maxValue, true)
  self.SEGMENT_COLORS = {
    [0] = self.UIStyle.COLOR_GREEN,
    [1] = self.UIStyle.COLOR_TAN_LIGHT,
    [2] = self.UIStyle.COLOR_YELLOW
  }
  self.weightIconPositionY = UiTransformBus.Event.GetLocalPositionY(self.Properties.WeightIcon)
end
function WeightBar:OnShutdown()
  self.ScriptedEntityTweener:TimelineDestroy(self.barOverageTimeline)
end
function WeightBar:SetMaxValue(newMaxValue, updateBar)
  self.maxValue = newMaxValue
  UiTextBus.Event.SetText(self.MaxValueText, LocalizeDecimalSeparators(string.format("/%.1f", self.maxValue)))
  local offset = UiTextBus.Event.GetTextWidth(self.MaxValueText)
  local iconMargin = 1
  UiTransformBus.Event.SetLocalPositionX(self.WeightIcon, offset + iconMargin)
  if updateBar == true then
    self:SetValue(self.value, 0)
  end
end
function WeightBar:SetValue(newValue, totalDuration, maxValue)
  local adjustedNewValue = newValue - self.stackSplitValue / 10
  totalDuration = totalDuration ~= nil and totalDuration or self.barAnimationDuration
  local newMaxValue = maxValue ~= nil and maxValue or self.maxValue
  local oldValue = self.value
  local oldPercentOfMax = 0
  local percentOfMax = 0
  if self.maxValue > 0 then
    oldPercentOfMax = self.value / self.maxValue
    percentOfMax = adjustedNewValue / newMaxValue
  end
  local fillDelay = 0
  local fillScale = Math.Clamp(percentOfMax, 0, 1)
  local fillEase = "QuadOut"
  local overageDelay = 0
  local overageScale = Math.Clamp(percentOfMax - 1, 0, self.maxOveragePercent)
  local overageEase = "QuadOut"
  local fillDuration = totalDuration - overageScale * totalDuration
  local overageDuration = math.max(totalDuration * overageScale, totalDuration / 4)
  if percentOfMax <= 1 and 1 < oldPercentOfMax then
    fillDelay = overageDuration
    overageEase = "QuadIn"
    overageDuration = fillDelay
    self.ScriptedEntityTweener:Play(self.OverageIndicators, totalDuration, {opacity = 0})
  elseif 1 < percentOfMax and oldPercentOfMax <= 1 then
    overageDelay = fillDuration
    fillEase = "QuadIn"
    self.ScriptedEntityTweener:Play(self.OverageIndicators, totalDuration, {opacity = 1})
  end
  local updateSegment
  local segmentColor = 1 < percentOfMax and self.UIStyle.COLOR_RED or self.UIStyle.FONT_STYLE_WEIGHT_VALUE.fontColor
  if self.segments ~= nil then
    if percentOfMax < 1 then
      do
        local targetSegment = self:GetSegmentAtPercent(percentOfMax)
        segmentColor = self.SEGMENT_COLORS[targetSegment]
        UiImageBus.Event.SetColor(self.BarSegment, segmentColor)
        function updateSegment(currentValue, percentOfAnim)
          currentValue = currentValue ~= nil and currentValue or percentOfMax
          if 0 < currentValue and currentValue < 1 then
            local segment = self:GetSegmentAtPercent(currentValue)
            if segment == targetSegment then
              local low = self.segments[segment] ~= nil and self.segments[segment] or 0
              UiTransform2dBus.Event.SetAnchorsScript(self.BarSegment, UiAnchors(low, 0, currentValue, 1))
            else
              UiTransform2dBus.Event.SetAnchorsScript(self.BarSegment, UiAnchors(0, 0, 0, 1))
            end
          else
            UiTransform2dBus.Event.SetAnchorsScript(self.BarSegment, UiAnchors(0, 0, 0, 1))
          end
        end
      end
    else
      UiTransform2dBus.Event.SetAnchorsScript(self.BarSegment, UiAnchors(0, 0, 0, 1))
    end
  end
  self.ScriptedEntityTweener:Play(self.BarFill, fillDuration, {
    delay = fillDelay,
    scaleX = fillScale,
    ease = fillEase,
    onUpdate = updateSegment,
    onComplete = updateSegment
  })
  self.ScriptedEntityTweener:Play(self.BarOverage, overageDuration, {
    delay = overageDelay,
    scaleX = overageScale,
    ease = overageEase,
    onComplete = function()
      if 0 < overageScale then
        self.barOverageTimeline:Play()
      else
        self.barOverageTimeline:Stop()
      end
    end
  })
  self.ScriptedEntityTweener:Play(self.ValueText, totalDuration, {
    textColor = segmentColor,
    onUpdate = function(currentValue, percentOfAnim)
      UiTextBus.Event.SetText(self.ValueText, LocalizeDecimalSeparators(string.format("%.1f", oldValue + (adjustedNewValue - oldValue) * percentOfAnim)))
    end,
    onComplete = function()
      UiTextBus.Event.SetText(self.ValueText, LocalizeDecimalSeparators(string.format("%.1f", adjustedNewValue)))
    end
  })
  self.value = newValue
  if maxValue then
    self:SetMaxValue(maxValue)
  end
  UiTextBus.Event.SetText(self.ValueText, LocalizeDecimalSeparators(string.format("%.1f", adjustedNewValue)))
end
function WeightBar:GetSegmentAtPercent(percent)
  local segment = 0
  for index, threshold in ipairs(self.segments) do
    if threshold <= percent then
      segment = index
    else
      break
    end
  end
  return segment
end
function WeightBar:SetOverageText(newText)
  UiTextBus.Event.SetTextWithFlags(self.OverageText, newText, eUiTextSet_SetLocalized)
end
function WeightBar:SetOverageIcon(iconPath)
  UiImageBus.Event.SetSpritePathname(self.OverageIcon, iconPath)
end
function WeightBar:SetWeightIcon(isVisible)
  UiElementBus.Event.SetIsEnabled(self.WeightIcon, isVisible)
end
function WeightBar:SetStackSplitValue(stackValue)
  self.stackSplitValue = stackValue
  self:SetValue(self.value, 0)
end
function WeightBar:SetupFrame()
  local barWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  local hLines = {
    self.Properties.showBottomLine and "BottomLine" or nil,
    self.Properties.showTopLine and "TopLine" or nil
  }
  for _, lineName in pairs(hLines) do
    local offsetX = math.random(self.FRAME_SETTINGS[lineName].minOffset, self.FRAME_SETTINGS[lineName].maxOffset)
    local overshoot = math.random(self.FRAME_SETTINGS[lineName].minOvershoot, self.FRAME_SETTINGS[lineName].maxOvershoot)
    self.Frame[lineName]:SetOvershoot(overshoot)
    self.Frame[lineName]:SetLength(barWidth - offsetX)
    if self.Properties.drawFromRight then
      UiTransformBus.Event.SetZRotation(self.Frame[lineName].entityId, 180)
      UiTransformBus.Event.SetLocalPositionX(self.Frame[lineName].entityId, barWidth + overshoot)
    else
      UiTransformBus.Event.SetLocalPositionX(self.Frame[lineName].entityId, offsetX)
    end
  end
  UiTransform2dBus.Event.SetLocalWidth(self.BarOverage, barWidth)
end
function WeightBar:SetDividerPositions(divider1Pos, divider2Pos)
  if divider1Pos == nil then
    divider1Pos = 0
  end
  if divider2Pos == nil then
    divider2Pos = 0
  end
  local segments = {}
  for index, position in pairs({divider1Pos, divider2Pos}) do
    local divider = self.Frame["Divider" .. tostring(index)]
    if 0 < position and position < 1 then
      UiElementBus.Event.SetIsEnabled(divider, true)
      UiTransform2dBus.Event.SetAnchorsScript(divider, UiAnchors(position, 0, position, 0))
      table.insert(segments, position)
      if self.Frame["DividerText" .. tostring(index)]:IsValid() then
        UiTextBus.Event.SetText(self.Frame["DividerText" .. tostring(index)], LocalizeDecimalSeparators(string.format("%.1f", position * self.maxValue)))
      end
    else
      UiElementBus.Event.SetIsEnabled(divider, false)
    end
  end
  if 0 < #segments then
    self.segments = segments
    UiElementBus.Event.SetIsEnabled(self.BarSegment, true)
  else
    self.segments = nil
    UiElementBus.Event.SetIsEnabled(self.BarSegment, false)
  end
end
function WeightBar:SetFrameColor(color)
  for lineName, line in pairs(self.Frame) do
    if type(line) == "table" then
      line:SetColor(color)
    else
      UiImageBus.Event.SetColor(line, color)
    end
  end
end
function WeightBar:SetLootBagMode(isLootBagMode)
  if isLootBagMode then
    UiElementBus.Event.SetIsEnabled(self.Properties.BarContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.OverageIndicators, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.MaxValueText, false)
    self.ScriptedEntityTweener:Set(self.Properties.ValueText, {x = 50})
    SetTextStyle(self.Properties.ValueText, self.UIStyle.FONT_STYLE_LOOT_BAG_WEIGHT)
    local weightIconPositionY = -3
    UiTransformBus.Event.SetLocalPositionY(self.Properties.WeightIcon, weightIconPositionY)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.BarContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.OverageIndicators, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.MaxValueText, true)
    self.ScriptedEntityTweener:Set(self.Properties.ValueText, {x = 0})
    SetTextStyle(self.Properties.ValueText, self.UIStyle.FONT_STYLE_WEIGHT_VALUE)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.WeightIcon, self.weightIconPositionY)
  end
end
function WeightBar:SetMaxOveragePercent(newMaxOveragePercent)
  self.maxOveragePercent = newMaxOveragePercent
  self:SetValue(self.value)
end
function WeightBar:AnimateIn()
  local hLines = {
    self.Properties.showBottomLine and "BottomLine" or nil,
    self.Properties.showTopLine and "TopLine" or nil
  }
  for _, lineName in pairs(hLines) do
    self.Frame[lineName]:SetVisible(false, 0)
    self.Frame[lineName]:SetVisible(true, self.FRAME_SETTINGS[lineName].duration, {
      delay = self.FRAME_SETTINGS[lineName].delay
    })
  end
  local vLines = {
    "LeftLine",
    "RightLine",
    "Divider1",
    "Divider2"
  }
  for _, lineName in pairs(vLines) do
    self.ScriptedEntityTweener:Play(self.Frame[lineName], self.FRAME_SETTINGS[lineName].duration, {scaleY = 0}, {
      delay = self.FRAME_SETTINGS[lineName].delay,
      scaleY = 1
    })
  end
  self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0}, {opacity = 1})
end
return WeightBar

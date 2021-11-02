local ArmorStat = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    DefenseValueText = {
      default = EntityId()
    },
    AbsorptionContainer = {
      default = EntityId()
    },
    AbsorptionValueText = {
      default = EntityId()
    },
    AbsorptionUnitText = {
      default = EntityId()
    },
    AbsorptionDivider = {
      default = EntityId()
    },
    AbsorptionBar = {
      default = EntityId()
    },
    AbsorptionBarFill = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    }
  },
  DEFAULT_HEIGHT = 32,
  height = 32,
  defenseValue = 0,
  absorptionValue = 0,
  baseOpacity = 1,
  isDefenseVisible = true,
  isAbsorptionVisible = true,
  allowAnimation = true,
  DELTA_COLOR_IN_TIME = 0.3,
  DELTA_COLOR_OUT_TIME = 0.8,
  DELTA_COLOR_HOLD_TIME = 0.1,
  FLASH_IN_TIME = 0.15,
  FLASH_OUT_TIME = 2,
  FLASH_HOLD_TIME = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ArmorStat)
function ArmorStat:OnInit()
  local absorptionValueStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_BOLD,
    fontSize = 27,
    fontColor = self.UIStyle.COLOR_WHITE,
    fontEffect = self.UIStyle.FONT_EFFECT_OUTLINE_FAINT
  }
  SetTextStyle(self.AbsorptionValueText, absorptionValueStyle)
  local defenseValueStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 38,
    fontColor = self.UIStyle.COLOR_WHITE,
    fontEffect = self.UIStyle.FONT_EFFECT_OUTLINE_FAINT
  }
  SetTextStyle(self.DefenseValueText, defenseValueStyle)
  local absorptionUnitStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 16,
    fontColor = self.UIStyle.COLOR_GRAY_80,
    fontEffect = self.UIStyle.FONT_EFFECT_OUTLINE_FAINT
  }
  SetTextStyle(self.AbsorptionUnitText, absorptionUnitStyle)
  local barColor = self.UIStyle.COLOR_BLACK
  UiImageBus.Event.SetColor(self.AbsorptionBar, barColor)
  self.barFillColor = self.UIStyle.COLOR_WHITE
  UiImageBus.Event.SetColor(self.AbsorptionBarFill, self.barFillColor)
  local lightGreen = MixColors(self.UIStyle.COLOR_WHITE, self.UIStyle.COLOR_GREEN, 0.25)
  self.defenseDeltaColorRamp = {
    {
      value = -14,
      color = self.UIStyle.COLOR_RED
    },
    {
      value = -1,
      color = self.UIStyle.COLOR_RED_LIGHT
    },
    {value = 1, color = lightGreen},
    {
      value = 14,
      color = self.UIStyle.COLOR_GREEN
    }
  }
  self.absorptionDeltaColorRamp = {
    {
      value = -20,
      color = self.UIStyle.COLOR_RED_DARK
    },
    {
      value = -1,
      color = self.UIStyle.COLOR_RED_LIGHT
    },
    {value = 1, color = lightGreen},
    {
      value = 20,
      color = self.UIStyle.COLOR_GREEN
    }
  }
  self:UpdateLayout()
end
function ArmorStat:SetHeight(height)
  if height ~= nil and height ~= self.height then
    local scale = height / self.DEFAULT_HEIGHT
    UiTransformBus.Event.SetScale(self.entityId, Vector2(scale, scale))
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, height)
    self.height = height
  end
end
function ArmorStat:SetIcon(path)
  if path == nil or path == "" then
    UiElementBus.Event.SetIsEnabled(self.Icon, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Icon, true)
    UiImageBus.Event.SetSpritePathname(self.Icon, path)
  end
end
function ArmorStat:SetDefenseValue(value)
  if value ~= nil and value ~= self.defenseValue then
    do
      local format = "%d"
      if self.allowAnimation then
        self:FlashFullOpacity()
        do
          local oldDefenseValue = self.defenseValue
          local color = self:GetColorFromRamp(self.defenseDeltaColorRamp, value - self.defenseValue)
          self.ScriptedEntityTweener:Play(self.DefenseValueText, self.DELTA_COLOR_IN_TIME, {
            textColor = color,
            onUpdate = function(currentAnimValue, currentAnimPercent)
              local nowNum = Lerp(oldDefenseValue, value, currentAnimPercent)
              UiTextBus.Event.SetText(self.DefenseValueText, string.format(format, nowNum))
            end,
            onComplete = function()
              UiTextBus.Event.SetText(self.DefenseValueText, string.format(format, value))
              self.ScriptedEntityTweener:Play(self.DefenseValueText, self.DELTA_COLOR_OUT_TIME, {
                textColor = self.UIStyle.COLOR_WHITE,
                delay = self.DELTA_COLOR_HOLD_TIME
              })
            end
          })
        end
      else
        UiTextBus.Event.SetText(self.DefenseValueText, string.format(format, value))
      end
      self.defenseValue = value
      self:UpdateTooltipWithValues()
    end
  end
end
function ArmorStat:SetIsDefenseVisible(visible)
  if visible ~= self.isDefenseVisible then
    self.isDefenseVisible = visible
    UiElementBus.Event.SetIsEnabled(self.DefenseValueText, visible)
    self:UpdateLayout()
  end
end
function ArmorStat:SetAbsorptionValue(value, forceUpdate)
  if value ~= nil then
    do
      local normalizedValue = value * 100
      if normalizedValue ~= self.absorptionValue or forceUpdate then
        do
          local format = "%.1f"
          if self.allowAnimation then
            self:FlashFullOpacity()
            do
              local oldAbsorptionValue = self.absorptionValue
              local color = self:GetColorFromRamp(self.absorptionDeltaColorRamp, normalizedValue - self.absorptionValue)
              self.ScriptedEntityTweener:Play(self.AbsorptionValueText, self.DELTA_COLOR_IN_TIME, {
                textColor = color,
                onUpdate = function(currentAnimValue, currentAnimPercent)
                  local nowNum = Lerp(oldAbsorptionValue, normalizedValue, currentAnimPercent)
                  UiTextBus.Event.SetText(self.AbsorptionValueText, LocalizeDecimalSeparators(string.format(format, nowNum)))
                end,
                onComplete = function()
                  UiTextBus.Event.SetText(self.AbsorptionValueText, LocalizeDecimalSeparators(string.format(format, normalizedValue)))
                  self.ScriptedEntityTweener:Play(self.AbsorptionValueText, self.DELTA_COLOR_OUT_TIME, {
                    textColor = self.UIStyle.COLOR_WHITE,
                    delay = self.DELTA_COLOR_HOLD_TIME
                  })
                  self.ScriptedEntityTweener:Play(self.AbsorptionBarFill, self.DELTA_COLOR_OUT_TIME, {
                    imgColor = self.barFillColor,
                    delay = self.DELTA_COLOR_HOLD_TIME
                  })
                end
              })
              self.ScriptedEntityTweener:Play(self.AbsorptionBarFill, self.DELTA_COLOR_IN_TIME, {scaleX = value, imgColor = color})
            end
          else
            UiTextBus.Event.SetText(self.AbsorptionValueText, LocalizeDecimalSeparators(string.format(format, normalizedValue)))
            self.ScriptedEntityTweener:Set(self.AbsorptionBarFill, {scaleX = value})
          end
          self.absorptionValue = normalizedValue
          self:UpdateTooltipWithValues()
        end
      end
    end
  end
end
function ArmorStat:SetIsAbsorptionVisible(visible)
  if visible ~= self.isAbsorptionVisible then
    self.isAbsorptionVisible = visible
    UiElementBus.Event.SetIsEnabled(self.AbsorptionContainer, visible)
    self:UpdateLayout()
  end
end
function ArmorStat:SetOpacity(opacity)
  if opacity ~= self.baseOpacity then
    self.ScriptedEntityTweener:Stop(self.entityId)
    self.baseOpacity = opacity
    if self.allowAnimation then
      self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
        opacity = self.baseOpacity
      })
    else
      self.ScriptedEntityTweener:Set(self.entityId, {
        opacity = self.baseOpacity
      })
    end
  end
end
function ArmorStat:SetTooltip(tooltipString, isDynamic)
  if tooltipString == nil or tooltipString == "" then
    UiElementBus.Event.SetIsEnabled(self.TooltipSetter.entityId, false)
    self.hasDynamicTooltip = false
  else
    UiElementBus.Event.SetIsEnabled(self.TooltipSetter.entityId, true)
    self.hasDynamicTooltip = isDynamic or false
    self.tooltipString = tooltipString
    if isDynamic then
      self:UpdateTooltipWithValues()
    else
      self.TooltipSetter:SetSimpleTooltip(tooltipString)
    end
  end
end
function ArmorStat:ResetTooltip()
  self:SetTooltip(self.tooltipString, self.hasDynamicTooltip)
  self:SetAbsorptionValue(self.absorptionValue / 100, true)
end
function ArmorStat:SetAllowAnimation(allow)
  self.allowAnimation = allow
end
function ArmorStat:UpdateLayout()
  if self.isDefenseVisible then
    local defenseWidth = self.isAbsorptionVisible and 36 or 72
    UiTransform2dBus.Event.SetLocalWidth(self.DefenseValueText, defenseWidth)
  end
end
function ArmorStat:UpdateTooltipWithValues()
  if self.hasDynamicTooltip then
    self.TooltipSetter:SetSimpleTooltip(GetLocalizedReplacementText(self.tooltipString, {
      defense = string.format("%d", self.defenseValue),
      absorption = LocalizeDecimalSeparators(string.format("%.1f", self.absorptionValue))
    }))
  end
end
function ArmorStat:FlashFullOpacity()
  if self.allowAnimation and self.baseOpacity < 1 then
    self.ScriptedEntityTweener:Stop(self.entityId)
    self.ScriptedEntityTweener:Play(self.entityId, self.FLASH_IN_TIME, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, self.FLASH_OUT_TIME, {
      opacity = self.baseOpacity,
      ease = "QuadInOut",
      delay = self.FLASH_HOLD_TIME + self.FLASH_IN_TIME
    })
  end
end
function ArmorStat:GetColorFromRamp(ramp, value)
  local lowValue, lowColor, highValue, highColor
  for _, stop in ipairs(ramp) do
    if value > stop.value then
      lowValue = stop.value
      lowColor = stop.color
    elseif value < stop.value then
      highValue = stop.value
      highColor = stop.color
      break
    else
      return stop.color
    end
  end
  if lowColor ~= nil and highColor ~= nil then
    local amount = (value - lowValue) / (highValue - lowValue)
    return MixColors(lowColor, highColor, amount)
  elseif lowColor ~= nil then
    return lowColor
  elseif highColor ~= nil then
    return highColor
  else
    return self.UIStyle.COLOR_WHITE
  end
end
return ArmorStat

local AbilityCooldownRadial = {
  Properties = {
    Warning = {
      default = EntityId()
    },
    Meter = {
      default = EntityId()
    },
    MeterFill = {
      default = EntityId()
    },
    Hint = {
      default = EntityId()
    },
    Countdown = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AbilityCooldownRadial)
function AbilityCooldownRadial:OnInit()
  self.defaultWidth = UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
  self.hasHint = type(self.Hint) == "table"
end
function AbilityCooldownRadial:SetHint(hintKeybind, actionMapName, onEndSound)
  if not self.hasHint then
    return
  end
  if actionMapName ~= nil then
    self.Hint:SetActionMap(actionMapName)
  end
  self.Hint:SetKeybindMapping(hintKeybind)
  self.onEndSound = onEndSound
end
function AbilityCooldownRadial:SetDescription(description)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Description, description, eUiTextSet_SetLocalized)
end
function AbilityCooldownRadial:SetDisabled()
end
function AbilityCooldownRadial:SetTimer(totalTime, cooldownRemainingPercentage)
  local initialScale = 1
  if self.isActive then
    self.ScriptedEntityTweener:Stop(self.Properties.MeterFill)
    initialScale = UiImageBus.Event.GetFillAmount(self.Properties.MeterFill)
    self.ScriptedEntityTweener:Stop(self.Properties.Hint)
    self.ScriptedEntityTweener:Stop(self.Properties.Countdown)
    self.ScriptedEntityTweener:Stop(self.Properties.Meter)
  end
  if cooldownRemainingPercentage then
    initialScale = cooldownRemainingPercentage
  end
  self:SetIsVisible(true)
  if self.hasHint then
    self.Hint:SetHighlightVisible(false)
  end
  self.ScriptedEntityTweener:Play(self.Properties.Hint, 0.3, {opacity = 1}, {
    opacity = 0.6,
    ease = "QuadInOut",
    delay = 0.1
  })
  self.ScriptedEntityTweener:Play(self.Properties.Countdown, 0.3, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Meter, 0.3, {opacity = 0.8, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MeterFill, totalTime, {imgFill = initialScale}, {
    imgFill = 0,
    ease = "Linear",
    onUpdate = function(currentValue, currentProgressPercent)
      local timeRemaining = (1 - currentProgressPercent) * totalTime
      UiTextBus.Event.SetText(self.Properties.Countdown, string.format("%.2f", timeRemaining))
    end,
    onComplete = function()
      self:OnCompleteTimer()
    end
  })
  self.ScriptedEntityTweener:Play(self.entityId, 1, {
    opacity = 1,
    ease = "QuadIn",
    delay = totalTime
  })
  self.isActive = true
end
function AbilityCooldownRadial:SetIsVisible(isVisible, delay, skipSounds)
  if self.isVisible == isVisible then
    return
  end
  delay = delay or 0
  self.ScriptedEntityTweener:Stop(self.entityId)
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
      opacity = 1,
      layoutTargetWidth = self.defaultWidth,
      ease = "QuadOut",
      delay = delay
    })
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.6, {
      opacity = 0,
      ease = "QuadIn",
      delay = delay
    })
    self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
      layoutTargetWidth = 0,
      ease = "QuadInOut",
      delay = delay + 0.6,
      onComplete = function()
        if self.hasHint then
          self.Hint:SetHighlightVisible(false)
        end
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
    if not skipSounds then
      self.audioHelper:PlaySound(self.onEndSound)
    end
  end
end
function AbilityCooldownRadial:FlashColor(color)
  local inTime = 0.15
  local outTime = 0.4
  self.ScriptedEntityTweener:Play(self.Properties.Warning, inTime, {
    imgColor = color,
    opacity = 0.4,
    ease = "QuadInOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Warning, outTime, {
    imgColor = self.UIStyle.COLOR_BLACK,
    opacity = 0.15,
    ease = "QuadInOut",
    delay = inTime
  })
  self.ScriptedEntityTweener:Play(self.Properties.MeterFill, inTime, {imgColor = color, ease = "QuadInOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MeterFill, outTime, {
    imgColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadInOut",
    delay = inTime
  })
end
function AbilityCooldownRadial:SetTimerCompleteCallback(fn, fnTable)
  self.callbackFunction = fn
  self.callbackTable = fnTable
end
function AbilityCooldownRadial:ForceStopTimer()
  if not self.isActive then
    return
  end
  self.ScriptedEntityTweener:Stop(self.Properties.Hint)
  self.ScriptedEntityTweener:Stop(self.Properties.Countdown)
  self.ScriptedEntityTweener:Stop(self.Properties.Meter)
  self.ScriptedEntityTweener:Stop(self.Properties.MeterFill)
  self:OnCompleteTimer()
end
function AbilityCooldownRadial:OnCompleteTimer()
  UiTextBus.Event.SetText(self.Properties.Countdown, string.format("%.2f", 0))
  if self.hasHint then
    self.Hint:SetHighlightVisible(true)
  end
  self.ScriptedEntityTweener:Play(self.Properties.Hint, 0.3, {opacity = 1, ease = "QuadInOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Countdown, 0.3, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.Meter, 0.3, {opacity = 0, ease = "QuadOut"})
  self:FlashColor(self.UIStyle.COLOR_YELLOW_GOLD)
  self:SetIsVisible(false, 0.3)
  self.isActive = false
  if self.callbackFunction then
    self.callbackFunction(self.callbackTable)
  end
end
function AbilityCooldownRadial:SetIsShowingAllWeapons(value)
end
function AbilityCooldownRadial:SetNumFreeCooldowns()
end
function AbilityCooldownRadial:SetIcon()
end
function AbilityCooldownRadial:SetAbilityTooltipData()
end
function AbilityCooldownRadial:SetIsAbilityProgressionEnabled()
end
function AbilityCooldownRadial:IsRadial()
  return true
end
return AbilityCooldownRadial

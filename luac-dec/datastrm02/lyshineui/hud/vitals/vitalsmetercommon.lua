local VitalsMeterCommon = {
  lastPercentage = 0,
  currentOpacity = 1,
  warningThreshold = -1,
  criticalThreshold = -1,
  fadeOutDelay = 0.6,
  fadeOutTime = 3,
  maxValue = 0,
  isTooltipEnabled = true
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function VitalsMeterCommon:AddFillColorStop(color, lowerBound)
  if lowerBound == nil then
    lowerBound = 0
  end
  self.fillColorStops[lowerBound] = color
  self:SetPercentage(self.lastPercentage, true, true)
end
function VitalsMeterCommon:AddOpacityStop(opacity, lowerBound)
  if lowerBound == nil then
    lowerBound = 0
  end
  self.opacityStops[lowerBound] = opacity
  self:SetPercentage(self.lastPercentage, true, true)
end
function VitalsMeterCommon:SetFadeOutDelay(delay)
  self.fadeOutDelay = delay
end
function VitalsMeterCommon:SetFadeOutTime(fadeTime)
  self.fadeOutTime = fadeTime
end
function VitalsMeterCommon:SetForceOpacity(opacity, animTime)
  self.forceOpacity = opacity
  animTime = animTime ~= nil and animTime or 0
  opacity = opacity ~= nil and opacity or self:GetOpacityAt(self.lastPercentage)
  self.ScriptedEntityTweener:Stop(self.entityId)
  if animTime == 0.3 and opacity == 1 then
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.3, tweenerCommon.vitalsMeterIn)
  elseif animTime == 0.3 and opacity == 0 then
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.3, tweenerCommon.vitalsMeterOut)
  else
    self.ScriptedEntityTweener:Play(self.entityId, animTime, {opacity = opacity, ease = "QuadInOut"})
  end
end
function VitalsMeterCommon:GetForceOpacity()
  return self.forceOpacity
end
function VitalsMeterCommon:SetWarningThreshold(threshold)
  self.warningThreshold = threshold
end
function VitalsMeterCommon:SetWarningSounds(enterSound, exitSound)
  self.enterWarningSound = enterSound
  self.exitWarningSound = exitSound
end
function VitalsMeterCommon:SetCriticalThreshold(threshold)
  self.criticalThreshold = threshold
end
function VitalsMeterCommon:SetCriticalSounds(enterSound, exitSound)
  self.enterCriticalSound = enterSound
  self.exitCriticalSound = exitSound
end
function VitalsMeterCommon:SetMaxValue(maxValue)
  if self.maxValue ~= nil then
    self.maxValue = maxValue
    self:UpdateTooltip()
    if type(self.UpdateText) == "function" then
      self:UpdateText()
    end
  end
end
function VitalsMeterCommon:SetTooltip(tooltipString)
  self.tooltipString = tooltipString
  self:SetIsTooltipEnabled(self.tooltipString ~= nil and self.isTooltipEnabled)
  self:UpdateTooltip()
end
function VitalsMeterCommon:UpdateTooltip()
  if self.tooltipString ~= nil then
    local currentValue = Math.Clamp(self.lastPercentage * self.maxValue, 0, self.maxValue)
    local tooltipValue = GetLocalizedReplacementText(self.tooltipString, {
      currentValue = GetFormattedNumber(currentValue, 0),
      maxValue = GetFormattedNumber(self.maxValue, 0)
    })
    self.TooltipSetter:SetSimpleTooltip(tooltipValue)
  end
end
function VitalsMeterCommon:SetIsTooltipEnabled(enable)
  self.isTooltipEnabled = enable
  UiElementBus.Event.SetIsEnabled(self.TooltipSetter.entityId, self.isTooltipEnabled)
  if not enable then
    timingUtils:StopDelay(self)
  end
end
function VitalsMeterCommon:GetFillColorAt(percentage)
  local highestFound = 0
  for threshold, color in pairs(self.fillColorStops) do
    if threshold <= percentage and threshold > highestFound then
      highestFound = threshold
    end
  end
  return self.fillColorStops[highestFound]
end
function VitalsMeterCommon:GetOpacityAt(percentage)
  local highestFound = 0
  for threshold, color in pairs(self.opacityStops) do
    if threshold <= percentage and threshold > highestFound then
      highestFound = threshold
    end
  end
  return self.opacityStops[highestFound]
end
function VitalsMeterCommon:SetIsPlayingWarningTimeline(play)
  if play == self.isPlayingWarningTimeline then
    return
  end
  if play then
    self.warningTimeline:Play()
    UiElementBus.Event.SetIsEnabled(self.Warning, true)
    if self.enterWarningSound then
      self.audioHelper:PlaySound(self.enterWarningSound)
    end
  else
    self.warningTimeline:Stop()
    UiElementBus.Event.SetIsEnabled(self.Warning, false)
    if self.exitWarningSound then
      self.audioHelper:PlaySound(self.exitWarningSound)
    end
  end
  self.isPlayingWarningTimeline = play
end
function VitalsMeterCommon:SetIsPlayingCriticalTimeline(play)
  if play == self.isPlayingCriticalTimeline then
    return
  end
  if play then
    self.criticalTimeline:Play()
    UiElementBus.Event.SetIsEnabled(self.Critical, true)
    if self.enterCriticalSound then
      self.audioHelper:PlaySound(self.enterCriticalSound)
    end
  else
    self.criticalTimeline:Stop()
    UiElementBus.Event.SetIsEnabled(self.Critical, false)
    if self.exitCriticalSound then
      self.audioHelper:PlaySound(self.exitCriticalSound)
    end
  end
  self.isPlayingCriticalTimeline = play
end
function VitalsMeterCommon:OnHoverStart()
  if self.forceOpacity ~= 0 and self.isTooltipEnabled then
    self:UpdateTooltip()
    self.TooltipSetter:OnTooltipSetterHoverStart()
    timingUtils:Delay(0.01, self, function(self)
      self:UpdateTooltip()
    end, true)
  end
end
function VitalsMeterCommon:OnHoverEnd()
  self.TooltipSetter:OnTooltipSetterHoverEnd()
  timingUtils:StopDelay(self)
end
return VitalsMeterCommon

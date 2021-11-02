local VitalsMeterHorizontal = {
  Properties = {
    Bg = {
      default = EntityId()
    },
    BgFill = {
      default = EntityId()
    },
    ValueText = {
      default = EntityId()
    },
    Warning = {
      default = EntityId()
    },
    Critical = {
      default = EntityId()
    },
    Deplete = {
      default = EntityId()
    },
    Fill = {
      default = EntityId()
    },
    Cost = {
      default = EntityId()
    },
    CostBg = {
      default = EntityId()
    },
    CostPattern = {
      default = EntityId()
    },
    Refill = {
      default = EntityId()
    },
    Detail = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    }
  },
  costPercentage = 0,
  warningThreshold = 0.5,
  criticalThreshold = 0.25
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(VitalsMeterHorizontal)
local VitalsMeterCommon = RequireScript("LyShineUI.HUD.Vitals.VitalsMeterCommon")
Merge(VitalsMeterHorizontal, VitalsMeterCommon, true)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function VitalsMeterHorizontal:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Video.HudShowVitalsValues", function(self, showVitalsValues)
    if not self.Properties.ValueText:IsValid() then
      return
    end
    self.showVitalsValues = showVitalsValues
    UiElementBus.Event.SetIsEnabled(self.Properties.ValueText, showVitalsValues == true)
    if showVitalsValues then
      self:UpdateText()
    end
  end)
  self.fillColorStops = {
    [0] = self.UIStyle.COLOR_WHITE
  }
  self.opacityStops = {
    [0] = 1
  }
  UiImageBus.Event.SetColor(self.Warning, self.UIStyle.COLOR_RED_DARK)
  self.warningTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.warningTimeline:Add(self.Warning, 0.15, {opacity = 0.4, ease = "QuadOut"})
  self.warningTimeline:Add(self.Warning, 0.85, {opacity = 0.1, ease = "QuadIn"})
  self.warningTimeline:Add(self.Warning, 1.5, {
    opacity = 0.1,
    onComplete = function()
      self.warningTimeline:Play(0)
    end
  })
  UiImageBus.Event.SetColor(self.Critical, self.UIStyle.COLOR_RED)
  self.criticalTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.criticalTimeline:Add(self.Critical, 0.15, {opacity = 1, ease = "QuadOut"})
  self.criticalTimeline:Add(self.Critical, 0.85, {opacity = 0, ease = "QuadIn"})
  self.criticalTimeline:Add(self.Critical, 0.25, {
    opacity = 0,
    onComplete = function()
      self.criticalTimeline:Play(0)
    end
  })
  self:SetRefillTime(1.5)
  self.fillAnimTable = {
    scaleX = 0,
    imgColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  }
  self.setOpacityTable = {opacity = 0}
  self.delayedOpacityTable = {
    delay = 0,
    opacity = 0,
    ease = "QuadInOut"
  }
  self.setCostAnchors = UiAnchors(0, 0, 0, 1)
  self.imgColorTable = {
    imgColor = self.UIStyle.COLOR_WHITE
  }
  self.setDepleteAnimTable = {scaleX = 0}
  self.depleteAnimTable = {scaleX = 0, delay = 0}
end
function VitalsMeterHorizontal:OnShutdown()
  self.ScriptedEntityTweener:TimelineDestroy(self.warningTimeline)
  self.ScriptedEntityTweener:TimelineDestroy(self.criticalTimeline)
  self.ScriptedEntityTweener:TimelineDestroy(self.refillTimeline)
end
function VitalsMeterHorizontal:SetRefillTime(seconds)
  if seconds == self.refillTime then
    return
  end
  if self.refillTimeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.refillTimeline)
  end
  local holdTime = math.max(seconds - 1, 0)
  self.refillTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.refillTimeline:Add(self.Refill, 0.15, {opacity = 0.15, ease = "QuadOut"})
  self.refillTimeline:Add(self.Refill, 0.85, {opacity = 0, ease = "QuadIn"})
  self.refillTimeline:Add(self.Refill, holdTime, {
    opacity = 0,
    onComplete = function()
      self.isShowingRefill = false
    end
  })
  self.refillTime = seconds
end
function VitalsMeterHorizontal:SetIcon(iconPath)
  if iconPath ~= nil then
    UiElementBus.Event.SetIsEnabled(self.Icon, true)
    UiImageBus.Event.SetSpritePathname(self.Icon, iconPath)
  else
    UiElementBus.Event.SetIsEnabled(self.Icon, false)
  end
end
function VitalsMeterHorizontal:DisableValueText()
  UiElementBus.Event.SetIsEnabled(self.Properties.ValueText, false)
end
function VitalsMeterHorizontal:SetTextStyle(style)
  if not self.Properties.ValueText:IsValid() then
    return
  end
  SetTextStyle(self.Properties.ValueText, style)
end
function VitalsMeterHorizontal:SetTextPosition(x, y)
  if not self.Properties.ValueText:IsValid() then
    return
  end
  UiTransformBus.Event.SetLocalPosition(self.Properties.ValueText, Vector2(x, y))
end
function VitalsMeterHorizontal:SetPercentage(percentage, skipAnimation, force)
  if percentage == self.lastPercentage and not force then
    return
  end
  local isIncrease = percentage >= self.lastPercentage
  local animTime = skipAnimation and 0 or 0.15
  local fadeTime = skipAnimation and 0 or self.fadeOutDelay
  local fillColor = self:GetFillColorAt(percentage)
  local opacity = self:GetOpacityAt(percentage)
  self.fillAnimTable.scaleX = percentage
  self.fillAnimTable.imgColor = fillColor
  self.ScriptedEntityTweener:Play(self.Fill, animTime, self.fillAnimTable)
  if not isIncrease then
    self:AnimateDeplete(percentage)
  elseif percentage ~= 1 then
    self:PlayRefillTimeline()
  end
  if opacity ~= self.currentOpacity and self.forceOpacity == nil then
    self.ScriptedEntityTweener:Stop(self.entityId)
    if not skipAnimation then
      self.delayedOpacityTable.delay = opacity < self.currentOpacity and self.fadeOutDelay or animTime
      self.delayedOpacityTable.opacity = opacity
      self.ScriptedEntityTweener:Play(self.entityId, opacity < self.currentOpacity and self.fadeOutTime or animTime, self.delayedOpacityTable)
    else
      self.setOpacityTable.opacity = 0
      self.ScriptedEntityTweener:Set(self.entityId, self.setOpacityTable)
    end
  end
  if 0 < self.costPercentage then
    local leftPercentage = percentage - self.costPercentage
    local costColor = self.UIStyle.COLOR_WHITE
    if leftPercentage < 0 then
      leftPercentage = 0
      costColor = self.UIStyle.COLOR_RED
    end
    self.setCostAnchors.left = leftPercentage
    self.setCostAnchors.right = percentage
    UiTransform2dBus.Event.SetAnchorsScript(self.Properties.Cost, self.setCostAnchors)
    if costColor ~= self.currentCostColor then
      self.imgColorTable.imgColor = costColor
      self.ScriptedEntityTweener:Play(self.Properties.CostBg, animTime, self.imgColorTable)
      self.ScriptedEntityTweener:Play(self.Properties.CostPattern, animTime, self.imgColorTable)
      self.currentCostColor = costColor
    end
  end
  self:SetIsPlayingWarningTimeline(percentage <= self.warningThreshold or percentage < self.costPercentage)
  self:SetIsPlayingCriticalTimeline(percentage <= self.criticalThreshold)
  self.lastPercentage = percentage
  self.currentOpacity = opacity
  self:UpdateText()
end
function VitalsMeterHorizontal:SetCostPercentage(percentage)
  if percentage == self.costPercentage then
    return
  end
  self.costPercentage = percentage
  self:SetPercentage(self.lastPercentage, true, true)
  self.ScriptedEntityTweener:Play(self.Cost, 0.3, {
    scaleX = self.costPercentage > 0 and 1 or 0,
    ease = "QuadOut",
    onComplete = function()
      if self.costPercentage <= 0 then
        UiElementBus.Event.SetIsEnabled(self.Cost, false)
      end
    end
  })
  if 0 < percentage then
    UiElementBus.Event.SetIsEnabled(self.Cost, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 1})
  else
    self.ScriptedEntityTweener:Stop(self.entityId)
    self.ScriptedEntityTweener:Play(self.entityId, self.fadeOutTime, {opacity = 1}, {
      opacity = self.forceOpacity or self:GetOpacityAt(self.lastPercentage),
      delay = self.fadeOutDelay
    })
  end
end
function VitalsMeterHorizontal:SetPulseBus(dynamicBus)
  self.pulseBus = dynamicBus
end
function VitalsMeterHorizontal:SetDepleteColor(value)
  UiImageBus.Event.SetColor(self.Properties.Deplete, value)
end
function VitalsMeterHorizontal:SetDepleteAlpha(value)
  self.ScriptedEntityTweener:Set(self.Properties.Deplete, {opacity = value})
end
function VitalsMeterHorizontal:OnInsufficientVitals()
  UiImageBus.Event.SetColor(self.Properties.BgFill, self.UIStyle.COLOR_RED)
  self.ScriptedEntityTweener:PlayC(self.Properties.BgFill, 0.15, tweenerCommon.opacityTo60)
  self.ScriptedEntityTweener:PlayC(self.Properties.BgFill, 0.6, tweenerCommon.fadeOutQuadIn, 0.2)
  self.ScriptedEntityTweener:PlayC(self.Properties.ValueText, 0.15, tweenerCommon.textToRed)
  self.ScriptedEntityTweener:PlayC(self.Properties.ValueText, 0.6, tweenerCommon.textToWhite, 0.2)
end
function VitalsMeterHorizontal:UpdateText()
  if not (self.Properties.ValueText:IsValid() and self.showVitalsValues) or not self.maxValue then
    return
  end
  local max = GetFormattedNumber(self.maxValue, 0)
  if self.lastPercentage == 1 then
    UiTextBus.Event.SetText(self.Properties.ValueText, max)
  else
    local value = GetFormattedNumber(self.lastPercentage * self.maxValue, 0)
    local text = GetLocalizedReplacementText("@ui_vitals_value", {value = value, max = max})
    UiTextBus.Event.SetText(self.Properties.ValueText, text)
  end
end
function VitalsMeterHorizontal:AnimateDeplete(newPercentage)
  local delay = 0.3
  local animTime = 0.3
  self.ScriptedEntityTweener:Stop(self.Properties.Deplete)
  self.depleteAnimTable.scaleX = newPercentage
  self.depleteAnimTable.delay = delay
  self.ScriptedEntityTweener:Play(self.Properties.Deplete, animTime, {
    scaleX = self.lastPercentage
  }, self.depleteAnimTable)
end
function VitalsMeterHorizontal:PlayRefillTimeline()
  if self.isShowingRefill then
    return
  end
  self.refillTimeline:Play()
  self.isShowingRefill = true
  if self.pulseBus then
    self.pulseBus.Broadcast.OnPulse()
  end
end
return VitalsMeterHorizontal

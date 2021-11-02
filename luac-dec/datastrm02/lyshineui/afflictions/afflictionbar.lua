local AfflictionBar = {
  Properties = {
    Background = {
      default = EntityId()
    },
    Resistance = {
      default = EntityId()
    },
    Bar = {
      default = EntityId()
    },
    BarBg = {
      default = EntityId()
    },
    BarEmpty = {
      default = EntityId()
    },
    BarDeplete = {
      default = EntityId()
    },
    BarFill = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    ResistanceText = {
      default = EntityId()
    },
    ValueText = {
      default = EntityId()
    },
    Afflicted = {
      default = EntityId()
    },
    AfflictedText = {
      default = EntityId()
    },
    AfflictedBarFill = {
      default = EntityId()
    },
    AfflictedTime = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    }
  },
  afflictionDamage = 0,
  resistanceMaxValue = 100,
  isAfflicted = nil,
  warningFlashPercent = 0.25,
  iconPathPattern = "lyshineui/images/afflictions/%s.png",
  addAfflictionCb = nil,
  removeAfflictionCb = nil,
  cbTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AfflictionBar)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function AfflictionBar:OnInit()
  BaseElement.OnInit(self)
  self.TIMING = {
    linesIn = 0.8,
    fadeIn = 0.3,
    fadeOut = 0.6,
    afflictedSwitch = 0.3,
    afflictedText = 0.9,
    depleteDelay = 0.3,
    deplete = 0.3
  }
  self.initialAfflictedTextParams = {
    textCharacterSpace = self.UIStyle.FONT_SPACING_AFFLICTION_ACTIVE / 3
  }
  self.barDepleteAnimParams = {
    delay = self.TIMING.depleteDelay,
    scaleY = 1,
    onComplete = function()
      self.isAnimatingDeplete = false
    end
  }
  self.backgroundImgColorParams = {
    imgColor = self.UIStyle.COLOR_BLACK
  }
  SetTextStyle(self.ResistanceText, self.UIStyle.FONT_STYLE_AFFLICTION_RESISTANCE)
  SetTextStyle(self.AfflictedText, self.UIStyle.FONT_STYLE_AFFLICTION_ACTIVE)
  SetTextStyle(self.ValueText, self.UIStyle.FONT_STYLE_AFFLICTION_VALUE)
  SetTextStyle(self.AfflictedTime, self.UIStyle.FONT_STYLE_AFFLICTION_VALUE)
  UiImageBus.Event.SetColor(self.Properties.Background, self.UIStyle.COLOR_BLACK)
  UiImageBus.Event.SetColor(self.Properties.BarEmpty, self.UIStyle.COLOR_RED_DARK)
  UiFaderBus.Event.SetFadeValue(self.Properties.BarEmpty, 0)
  self:CreateTimelines()
end
function AfflictionBar:OnShutdown()
  self:DestroyTimelines()
  self.dataLayer:UnregisterObservers(self)
end
function AfflictionBar:CreateTimelines()
  self.bgTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.bgTimeline:Add(self.Background, 0.1, {
    imgColor = self.UIStyle.COLOR_RED_DARKER
  })
  self.bgTimeline:Add(self.Background, 0.6, {
    imgColor = self.UIStyle.COLOR_BLACK
  })
  self.bgTimeline:Add(self.Background, 0.3, {
    imgColor = self.UIStyle.COLOR_BLACK,
    onComplete = function()
      self.bgTimeline:Play()
    end
  })
  self.emptyTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.emptyTimeline:Add(self.BarEmpty, 0.1, {opacity = 0.6})
  self.emptyTimeline:Add(self.BarEmpty, 0.6, {opacity = 0.1})
  self.emptyTimeline:Add(self.BarEmpty, 0.3, {
    opacity = 0.1,
    onComplete = function()
      self.emptyTimeline:Play()
    end
  })
end
function AfflictionBar:DestroyTimelines()
  self.ScriptedEntityTweener:TimelineDestroy(self.bgTimeline)
  self.ScriptedEntityTweener:TimelineDestroy(self.emptyTimeline)
end
function AfflictionBar:SetAfflictionById(afflictionId, addBarCb, removeBarCb, cbTable)
  self.dataLayer:UnregisterObservers(self)
  self.afflictionId = afflictionId
  self.afflictionRowKey = DamageDataBus.Broadcast.GetAfflictionRowKey(afflictionId)
  self.afflictionBaseName = DamageDataBus.Broadcast.GetAfflictionIcon(self.afflictionRowKey)
  self.afflictionTooltip = DamageDataBus.Broadcast.GetAfflictionTooltipText(self.afflictionRowKey)
  self.afflictedTooltip = DamageDataBus.Broadcast.GetAfflictedTooltipText(self.afflictionRowKey)
  self.afflictionColor = DamageDataBus.Broadcast.GetAfflictionColor(self.afflictionRowKey)
  self.afflictionColor.a = 1
  self.cachedIconColorAnim = self.ScriptedEntityTweener:CacheAnimation(0.3, {
    imgColor = self.afflictionColor,
    ease = "QuadOut"
  })
  self.addAfflictionCb = addBarCb
  self.removeAfflictionCb = removeBarCb
  self.cbTable = cbTable
  local iconPath = string.format(self.iconPathPattern, self.afflictionBaseName)
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, iconPath)
  UiImageBus.Event.SetColor(self.Properties.Bar, self.afflictionColor)
  UiImageBus.Event.SetColor(self.Properties.BarFill, self.afflictionColor)
  UiImageBus.Event.SetColor(self.Properties.AfflictedBarFill, self.afflictionColor)
  UiImageBus.Event.SetColor(self.Properties.BarDeplete, MixColors(self.afflictionColor, self.UIStyle.COLOR_WHITE, 0.9))
  UiTextBus.Event.SetTextWithFlags(self.Properties.AfflictedText, DamageDataBus.Broadcast.GetAfflictionTextAfflicted(self.afflictionRowKey) .. ".", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.AfflictedText, self.afflictionColor)
  local oneWordScale = 1.5
  local resistanceTextString = DamageDataBus.Broadcast.GetAfflictionText(self.afflictionRowKey)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ResistanceText, resistanceTextString, eUiTextSet_SetLocalized)
  local wordCount = 0
  for i in string.gmatch(resistanceTextString, "%S+") do
    wordCount = wordCount + 1
  end
  if wordCount < 2 then
    UiTextBus.Event.SetFontSize(self.Properties.ResistanceText, self.UIStyle.FONT_STYLE_AFFLICTION_RESISTANCE.fontSize * oneWordScale)
  else
    UiTextBus.Event.SetFontSize(self.Properties.ResistanceText, self.UIStyle.FONT_STYLE_AFFLICTION_RESISTANCE.fontSize)
  end
  local dataPrefix = "Hud.LocalPlayer.Afflictions." .. tostring(afflictionId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPrefix .. ".Max", self.SetResistanceMaxValue)
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPrefix .. ".Amount", self.SetAfflictionDamage)
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPrefix .. ".IsAfflicted", self.SetIsAfflicted)
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPrefix .. ".SecondsUntilDrain", function(self, data)
    self.secondsUntilDrain = data
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPrefix .. ".AfflictedDrainRate", function(self, data)
    self.drainRate = data
  end)
  local afflictedTooltip = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(self.afflictedTooltip)
  self.TooltipSetter:SetSimpleTooltip(afflictedTooltip)
end
function AfflictionBar:SetResistanceMaxValue(newResistanceMaxValue)
  if not IsUsableNumber(newResistanceMaxValue) then
    return
  end
  self.resistanceMaxValue = newResistanceMaxValue
  self.resistanceMaxValueText = " / " .. tostring(Math.Round(self.resistanceMaxValue))
  self:SetAfflictionDamage(self.afflictionDamage)
end
local newResistanceValue = 0
local scaleYParams = {scaleY = 1}
local imgFillParams = {imgFill = 1}
local timeUntilDrain = 0
function AfflictionBar:SetAfflictionDamage(damageTaken)
  if not IsUsableNumber(damageTaken) or not self.resistanceMaxValueText then
    return
  end
  newResistanceValue = self.resistanceMaxValue - damageTaken
  UiTextBus.Event.SetText(self.Properties.ValueText, tostring(Math.Round(newResistanceValue)) .. self.resistanceMaxValueText)
  if self.resistanceMaxValue > 0 then
    self.resistancePercent = Math.Clamp(newResistanceValue / self.resistanceMaxValue, 0, 1)
  else
    self.resistancePercent = 1
  end
  if not self.isAfflicted then
    scaleYParams.scaleY = self.resistancePercent
    self.ScriptedEntityTweener:Set(self.Properties.BarFill, scaleYParams)
    if damageTaken > self.afflictionDamage then
      self.isAnimatingDeplete = true
      self.barDepleteAnimParams.scaleY = self.resistancePercent
      self.ScriptedEntityTweener:Play(self.Properties.BarDeplete, self.TIMING.deplete, self.barDepleteAnimParams)
    elseif not self.isAnimatingDeplete then
      self.ScriptedEntityTweener:Set(self.Properties.BarDeplete, scaleYParams)
    end
    if self.resistancePercent < self.warningFlashPercent then
      if not self.warningFlashPlaying then
        self.bgTimeline:Play()
        self.emptyTimeline:Play()
        self.warningFlashPlaying = true
      end
    elseif self.warningFlashPlaying then
      self.bgTimeline:Stop()
      self.emptyTimeline:Stop()
      self.ScriptedEntityTweener:Set(self.Properties.Background, self.backgroundImgColorParams)
      UiFaderBus.Event.SetFadeValue(self.Properties.BarEmpty, 0)
      self.warningFlashPlaying = false
    end
  else
    self.emptyTimeline:Stop()
    imgFillParams.imgFill = 1 - self.resistancePercent
    self.ScriptedEntityTweener:Set(self.Properties.AfflictedBarFill, imgFillParams)
    if not self.warningFlashPlaying then
      self.bgTimeline:Play()
      self.warningFlashPlaying = true
    end
    if 0 < self.drainRate then
      timeUntilDrain = self.secondsUntilDrain + (self.resistanceMaxValue - newResistanceValue) / self.drainRate
      UiTextBus.Event.SetTextWithFlags(self.Properties.AfflictedTime, string.format("%d@ui_seconds_short", timeUntilDrain), eUiTextSet_SetLocalized)
    end
  end
  self.afflictionDamage = damageTaken
  self:UpdateAfflictionBarVisibility()
end
function AfflictionBar:SetIsAfflicted(shouldBeAfflicted)
  if shouldBeAfflicted == nil then
    return
  end
  if shouldBeAfflicted then
    self.ScriptedEntityTweener:PlayC(self.Properties.Afflicted, self.TIMING.afflictedSwitch, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.Resistance, self.TIMING.afflictedSwitch, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:Set(self.Properties.AfflictedText, self.initialAfflictedTextParams)
    self.ScriptedEntityTweener:PlayC(self.Properties.AfflictedText, self.TIMING.afflictedText, tweenerCommon.afflictionBarFontSpacing)
    self.ScriptedEntityTweener:PlayC(self.Properties.Icon, self.TIMING.afflictedSwitch, self.cachedIconColorAnim)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.Afflicted, self.TIMING.afflictedSwitch, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.Resistance, self.TIMING.afflictedSwitch, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.Icon, self.TIMING.afflictedSwitch, tweenerCommon.imgToGray80)
    local afflictionTooltip = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(self.afflictionTooltip)
    self.TooltipSetter:SetSimpleTooltip(afflictionTooltip)
  end
  self.isAfflicted = shouldBeAfflicted
  self:UpdateAfflictionBarVisibility()
end
local scaleXParams = {scaleX = 1}
local opacityParams = {opacity = 0}
function AfflictionBar:AnimateIn()
  self.isAnimatingOut = false
  self.ScriptedEntityTweener:Set(self.Properties.BarFill, scaleXParams)
  self.ScriptedEntityTweener:Set(self.Properties.BarDeplete, scaleXParams)
  self.ScriptedEntityTweener:Set(self.entityId, opacityParams)
  self.ScriptedEntityTweener:PlayC(self.entityId, self.TIMING.fadeIn, tweenerCommon.fadeInQuadOut)
  self:SetIsAfflicted(self.isAfflicted)
end
function AfflictionBar:AnimateOut(callback)
  self.isAnimatingOut = true
  self.ScriptedEntityTweener:PlayC(self.entityId, self.TIMING.fadeOut, tweenerCommon.fadeOutQuadOut, nil, function()
    self.isAnimatingOut = false
    if type(callback) == "function" then
      callback()
    end
  end)
end
function AfflictionBar:IsAnimatingOut()
  return self.isAnimatingOut
end
local barIsEnabled = false
function AfflictionBar:UpdateAfflictionBarVisibility()
  barIsEnabled = UiElementBus.Event.IsEnabled(self.entityId)
  if not barIsEnabled and (self.resistancePercent < 1 or self.isAfflicted) then
    if self.addAfflictionCb and self.cbTable then
      self.addAfflictionCb(self.cbTable, self)
    end
  elseif barIsEnabled and not self.isAfflicted and self.resistancePercent >= 1 and self.removeAfflictionCb and self.cbTable then
    self.removeAfflictionCb(self.cbTable, self)
  end
end
return AfflictionBar

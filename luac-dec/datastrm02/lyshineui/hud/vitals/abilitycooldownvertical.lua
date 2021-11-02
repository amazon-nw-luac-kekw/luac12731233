local AbilityCooldownVertical = {
  Properties = {
    Countdown = {
      default = EntityId()
    },
    CountdownBg = {
      default = EntityId()
    },
    AbilityIcon = {
      default = EntityId()
    },
    AbilityFrame = {
      default = EntityId()
    },
    AbilityDimmer = {
      default = EntityId()
    },
    AbilityFill = {
      default = EntityId()
    },
    AbilityIconBg = {
      default = EntityId()
    },
    AbilityFreeCooldownsText = {
      default = EntityId()
    },
    Hint = {
      default = EntityId()
    },
    HintContainer = {
      default = EntityId()
    },
    AbilityReadyLong = {
      default = EntityId()
    },
    AbilityReadyShort = {
      default = EntityId()
    }
  },
  iconPathRoot = "lyShineui/images/icons/abilities/",
  isAbilityProgressionEnabled = false
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local AbilitiesCommon = RequireScript("LyShineUI._Common.AbilitiesCommon")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AbilityCooldownVertical)
function AbilityCooldownVertical:OnInit()
  self.defaultWidth = UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
  self.hasHint = type(self.Hint) == "table"
  self:SetVisualElements()
end
function AbilityCooldownVertical:SetVisualElements()
  self.fullIconOpacity = UiFaderBus.Event.GetFadeValue(self.Properties.AbilityIcon)
end
function AbilityCooldownVertical:SetHint(hintKeybind, actionMapName, onEndSound)
  if not self.hasHint then
    return
  end
  if actionMapName ~= nil then
    self.Hint:SetActionMap(actionMapName)
  end
  self.Hint:SetKeybindMapping(hintKeybind)
  self.onEndSound = onEndSound
end
function AbilityCooldownVertical:SetIcon(iconName, uiCategory)
  UiElementBus.Event.SetIsEnabled(self.Properties.AbilityIcon, true)
  local iconPath
  if iconName then
    iconPath = self.iconPathRoot .. iconName .. ".dds"
    UiElementBus.Event.SetIsEnabled(self.Properties.AbilityIconBg, true)
    self.backgroundPath = AbilitiesCommon:GetBackgroundPath(uiCategory)
    if self.isActive then
      UiImageBus.Event.SetSpritePathname(self.Properties.AbilityIconBg, "lyShineui/images/icons/abilities/abilities_bg_cooldown.dds")
    else
      UiImageBus.Event.SetSpritePathname(self.Properties.AbilityIconBg, self.backgroundPath)
    end
  else
    iconPath = AbilitiesCommon.emptyIcon
    UiElementBus.Event.SetIsEnabled(self.Properties.AbilityIconBg, false)
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.AbilityIcon, iconPath)
end
function AbilityCooldownVertical:SetAbilityTooltipData(slotId, abilityIndex)
  self.activeAbilityIndex = abilityIndex
  self.slotId = slotId
end
function AbilityCooldownVertical:SetIsAbilityProgressionEnabled(value)
  self.isAbilityProgressionEnabled = value
end
function AbilityCooldownVertical:GetIsAbilityProgressionEnabled()
  return self.isAbilityProgressionEnabled
end
function AbilityCooldownVertical:SetNumFreeCooldowns(numCooldowns)
  if 0 < numCooldowns then
    numCooldowns = numCooldowns + 1
  end
  UiTextBus.Event.SetText(self.Properties.AbilityFreeCooldownsText, numCooldowns <= 0 and "" or tostring(numCooldowns))
end
function AbilityCooldownVertical:GetRemainingCooldownPercentage()
  if not self.isActive then
    return 0
  else
    return UiImageBus.Event.GetFillAmount(self.Properties.AbilityFill)
  end
end
function AbilityCooldownVertical:SetTimer(totalTime)
  local initialScale = 1
  if self.isActive and self.timeRemaining then
    if math.abs(self.timeRemaining - totalTime) < 0.05 then
      return
    end
    if self.timeRemaining > 0 then
      self.ScriptedEntityTweener:Stop(self.Properties.AbilityFill)
      initialScale = UiImageBus.Event.GetFillAmount(self.Properties.AbilityFill)
    end
  end
  if self.hasHint then
    self.Hint:SetHighlightVisible(false)
    self.ScriptedEntityTweener:PlayC(self.Properties.HintContainer, 0.1, tweenerCommon.opacityTo20)
  end
  self.ScriptedEntityTweener:PlayC(self.Properties.Countdown, 0.3, tweenerCommon.countdownOnCooldown)
  self.ScriptedEntityTweener:PlayC(self.Properties.CountdownBg, 0.3, tweenerCommon.countdownOnCooldown)
  UiImageBus.Event.SetColor(self.Properties.AbilityFrame, self.UIStyle.COLOR_GRAY_50)
  self.ScriptedEntityTweener:PlayC(self.Properties.AbilityIcon, 0.2, tweenerCommon.abilityIconOnCooldown)
  self.ScriptedEntityTweener:PlayC(self.Properties.AbilityDimmer, 0.05, tweenerCommon.abilityDimmerOnCooldown)
  if 0 < totalTime then
    self.ScriptedEntityTweener:PlayC(self.Properties.AbilityFill, 0.3, tweenerCommon.abilityFillOnCooldown)
    self.ScriptedEntityTweener:Play(self.Properties.AbilityFill, 0.4, {
      imgColor = self.UIStyle.COLOR_ABILITY_COOLDOWN,
      delay = 0.15
    })
    self.ScriptedEntityTweener:Play(self.Properties.AbilityFill, totalTime, {imgFill = initialScale}, {
      imgFill = 0,
      ease = "Linear",
      onUpdate = function(currentValue, currentProgressPercent)
        local timeRemaining = (1 - currentProgressPercent) * totalTime
        if 3 < timeRemaining then
          UiTextBus.Event.SetText(self.Properties.Countdown, string.format("%d", timeRemaining))
        else
          UiTextBus.Event.SetText(self.Properties.Countdown, string.format("%.1f", timeRemaining))
        end
        self.timeRemaining = timeRemaining
      end,
      onComplete = function()
        self:OnCompleteTimer()
      end
    })
  else
    self.ScriptedEntityTweener:Stop(self.Properties.AbilityFill)
    UiTextBus.Event.SetText(self.Properties.Countdown, "")
    self.timeRemaining = totalTime
  end
  self.ScriptedEntityTweener:Play(self.entityId, 1, {
    opacity = 1,
    ease = "QuadIn",
    delay = totalTime
  })
  UiFaderBus.Event.SetFadeValue(self.Properties.AbilityIconBg, 0.5)
  UiImageBus.Event.SetSpritePathname(self.Properties.AbilityIconBg, "lyShineui/images/icons/abilities/abilities_bg_cooldown.dds")
  self.isActive = true
end
function AbilityCooldownVertical:SetDisabled(isDisabled)
  if isDisabled then
    UiElementBus.Event.SetIsEnabled(self.Properties.AbilityDimmer, true)
    self.ScriptedEntityTweener:PlayC(self.Properties.AbilityFrame, 0.3, tweenerCommon.opacityTo50)
    if self.hasHint then
      self.Hint:SetHighlightVisible(false)
      self.ScriptedEntityTweener:PlayC(self.Properties.HintContainer, 0.1, tweenerCommon.opacityTo20)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.AbilityDimmer, false)
    self.ScriptedEntityTweener:PlayC(self.Properties.AbilityFrame, 0.3, tweenerCommon.fadeInQuadOut)
    if self.hasHint then
      self.Hint:SetHighlightVisible(false)
      self.ScriptedEntityTweener:PlayC(self.Properties.HintContainer, 0.1, tweenerCommon.fadeInQuadOut)
    end
  end
end
function AbilityCooldownVertical:SetIsVisible()
end
function AbilityCooldownVertical:FlashColor(color, forceFlash, isDisabled, flashIcon)
  local inTime = 0.01
  local outTime = 0.4
  if self.isActive then
    if not isDisabled then
      self.ScriptedEntityTweener:Play(self.Properties.AbilityDimmer, inTime, {
        imgColor = color,
        opacity = 0.5,
        ease = "QuadInOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.AbilityDimmer, outTime, {
        imgColor = self.UIStyle.COLOR_BLACK,
        opacity = self.isActive and 0 or 0.7,
        ease = "QuadOut",
        delay = inTime + 0.1
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.AbilityFill, inTime, {imgColor = color, ease = "QuadInOut"})
    self.ScriptedEntityTweener:Play(self.Properties.AbilityFill, outTime, {
      imgColor = self.UIStyle.COLOR_ABILITY_COOLDOWN,
      ease = "QuadOut",
      delay = inTime + 0.1
    })
  elseif forceFlash then
    if isDisabled and not self.isActive then
      self.ScriptedEntityTweener:Play(self.Properties.AbilityDimmer, inTime, {
        imgColor = color,
        opacity = 0.5,
        ease = "QuadInOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.AbilityDimmer, outTime, {
        imgColor = self.UIStyle.COLOR_BLACK,
        opacity = self.isActive and 0 or 0.7,
        ease = "QuadOut",
        delay = inTime + 0.1
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.AbilityFill, inTime, {imgColor = color, ease = "QuadInOut"})
    self.ScriptedEntityTweener:Play(self.Properties.AbilityFill, outTime, {
      imgColor = self.UIStyle.COLOR_ABILITY_COOLDOWN,
      ease = "QuadOut",
      delay = inTime + 0.1
    })
  end
  if flashIcon then
    self.ScriptedEntityTweener:Play(self.Properties.AbilityIcon, inTime, {imgColor = color, ease = "QuadInOut"})
    self.ScriptedEntityTweener:Play(self.Properties.AbilityIcon, outTime, {
      imgColor = self.UIStyle.COLOR_WHITE,
      ease = "QuadOut",
      delay = inTime + 0.1
    })
  end
end
function AbilityCooldownVertical:SetHintVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:PlayC(self.Properties.Hint, 0.25, tweenerCommon.fadeInQuadOut)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.Hint, 0.25, tweenerCommon.fadeOutQuadOut)
  end
end
function AbilityCooldownVertical:SetCooldownTimerVisuals(isSwapping)
  if self.isActive then
    self.ScriptedEntityTweener:PlayC(self.Properties.Countdown, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.CountdownBg, 0.3, tweenerCommon.fadeInQuadOut)
  end
end
function AbilityCooldownVertical:SetTimerCompleteCallback(fn, fnTable)
  self.callbackFunction = fn
  self.callbackTable = fnTable
end
function AbilityCooldownVertical:ForceStopTimer()
  if not self.isActive then
    return
  end
  self.ScriptedEntityTweener:Stop(self.Properties.Countdown)
  self.ScriptedEntityTweener:Stop(self.Properties.CountdownBg)
  self.ScriptedEntityTweener:Stop(self.Properties.AbilityIcon)
  self.ScriptedEntityTweener:Stop(self.Properties.AbilityDimmer)
  self.ScriptedEntityTweener:Stop(self.Properties.AbilityFill)
  self:OnCompleteTimer()
end
function AbilityCooldownVertical:OnCompleteTimer()
  UiTextBus.Event.SetText(self.Properties.Countdown, string.format("%.1f", 0))
  if self.hasHint then
    self.Hint:SetHighlightVisible(true)
  end
  self.ScriptedEntityTweener:PlayC(self.Properties.Countdown, 0.3, tweenerCommon.countdownOffCooldown)
  self.ScriptedEntityTweener:PlayC(self.Properties.CountdownBg, 0.3, tweenerCommon.countdownOffCooldown)
  self.ScriptedEntityTweener:PlayC(self.Properties.AbilityIcon, 0.2, tweenerCommon.abilityIconOffCooldown)
  self.ScriptedEntityTweener:PlayC(self.Properties.AbilityDimmer, 0.05, tweenerCommon.abilityDimmerOffCooldown)
  UiImageBus.Event.SetColor(self.Properties.AbilityFrame, self.UIStyle.COLOR_WHITE)
  self.ScriptedEntityTweener:Play(self.Properties.AbilityFill, 0.3, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      if self.hasHint then
        self.Hint:SetHighlightVisible(false)
        self.ScriptedEntityTweener:PlayC(self.Properties.HintContainer, 0.1, tweenerCommon.fadeInQuadOut)
      end
      self.audioHelper:PlaySound(self.onEndSound)
    end
  })
  self.isActive = false
  if type(self.callbackFunction) == "function" then
    self.callbackFunction(self.callbackTable)
  end
  UiFaderBus.Event.SetFadeValue(self.Properties.AbilityIconBg, 1)
  UiImageBus.Event.SetSpritePathname(self.Properties.AbilityIconBg, self.backgroundPath)
  UiElementBus.Event.SetIsEnabled(self.Properties.AbilityReadyShort, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.AbilityReadyLong, true)
  self.ScriptedEntityTweener:Play(self.Properties.AbilityReadyShort, 0.1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.AbilityReadyLong, 0.1, {opacity = 0, scaleY = 0.6}, {
    opacity = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.AbilityReadyShort, 1, {opacity = 1}, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.1
  })
  self.ScriptedEntityTweener:Play(self.Properties.AbilityReadyLong, 1, {opacity = 1}, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.1,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.AbilityReadyShort, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.AbilityReadyLong, false)
    end
  })
end
function AbilityCooldownVertical:OnAbilityFocus()
  if not self.activeAbilityIndex or not self.slotId then
    return
  end
  local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  if rootEntityId then
    local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
    local itemSlot = PaperdollRequestBus.Event.GetSlot(paperdollId, self.slotId)
    local activeAbilities = CharacterAbilityRequestBus.Event.GetActiveAbilityDataByItemSlot(rootEntityId, itemSlot)
    if self.activeAbilityIndex > 0 and self.activeAbilityIndex < #activeAbilities then
      local abilityData = activeAbilities[self.activeAbilityIndex]
      if not abilityData then
        return
      end
      local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
      local cooldownTime = CharacterAbilityRequestBus.Event.GetTotalCooldownTime(rootEntityId, abilityData.id)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
      local rows = {}
      local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
      local flyoutAbilityRow = {}
      flyoutAbilityRow.type = flyoutMenu.ROW_TYPE_Ability
      flyoutAbilityRow.abilityName = abilityData.displayName
      flyoutAbilityRow.abilityIcon = "lyShineui/images/icons/abilities/" .. abilityData.displayIcon .. ".dds"
      flyoutAbilityRow.cooldownTime = string.format("%.1f", cooldownTime)
      flyoutAbilityRow.abilityDescription = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(abilityData.displayDescription)
      flyoutAbilityRow.isAbilityUnlocked = true
      table.insert(rows, flyoutAbilityRow)
      flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
      flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
      flyoutMenu:SetOpenLocation(self.entityId)
      flyoutMenu:EnableFlyoutDelay(true)
      flyoutMenu:SetRowData(rows)
    end
  end
end
function AbilityCooldownVertical:SetIsShowingAllWeapons(value)
  self:SetCooldownTimerVisuals()
end
function AbilityCooldownVertical:OnAbilityUnfocus()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
end
function AbilityCooldownVertical:IsRadial()
  return false
end
return AbilityCooldownVertical

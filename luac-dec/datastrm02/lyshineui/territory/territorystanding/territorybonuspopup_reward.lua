local TerritoryBonusPopup_Reward = {
  Properties = {
    BG = {
      default = EntityId()
    },
    HighlightText = {
      default = EntityId()
    },
    DescriptionText = {
      default = EntityId()
    },
    ValueBG = {
      default = EntityId()
    },
    ValueText = {
      default = EntityId()
    },
    DisabledIcon = {
      default = EntityId()
    },
    DisabledValue = {
      default = EntityId()
    },
    DisabledReason = {
      default = EntityId()
    },
    DisabledBg = {
      default = EntityId()
    },
    HoverContainer = {
      default = EntityId()
    },
    HoverHash = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    },
    RedeemEffect = {
      default = EntityId()
    },
    Glow = {
      default = EntityId()
    }
  },
  isRevealed = false,
  mIsUsingTooltip = false,
  mIsSelected = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryBonusPopup_Reward)
function TerritoryBonusPopup_Reward:OnInit()
  BaseElement.OnInit(self)
  self.mIsEnabled = true
end
function TerritoryBonusPopup_Reward:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function TerritoryBonusPopup_Reward:SetTooltip(value)
  if value == nil or value == "" then
    self.mIsUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.mIsUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function TerritoryBonusPopup_Reward:SetBonusRewardData(rewardData, callbackSelf, callbackFn, territoryName)
  self.isRevealed = false
  local text = GetLocalizedReplacementText(rewardData.description, {
    territory = rewardData.territoryName,
    stat = rewardData.stat,
    description = rewardData.description,
    value = rewardData.value
  })
  if rewardData.additionalDescription then
    text = text .. rewardData.additionalDescription
  end
  local territoryText = GetLocalizedReplacementText("@ui_territory_standing_blank", {territory = territoryName})
  UiImageBus.Event.SetSpritePathname(self.Properties.BG, rewardData.bg)
  UiTextBus.Event.SetTextWithFlags(self.Properties.HighlightText, rewardData.category, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ValueText, rewardData.value, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DisabledValue, rewardData.disabledReason or "", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DisabledReason, territoryText or "", eUiTextSet_SetLocalized)
  local blockedIcon = "LyShineUI/Images/territory/standingrewards/territory_rewardLocked.png"
  if rewardData.disabledIcon and rewardData.disabledIcon ~= "" then
    blockedIcon = rewardData.disabledIcon
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.DisabledIcon, blockedIcon)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionText, text, eUiTextSet_SetLocalized)
  if rewardData.enabled then
    if rewardData.value and rewardData.value ~= "" then
      UiElementBus.Event.SetIsEnabled(self.Properties.ValueBG, true)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.ValueBG, false)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ValueBG, false)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.DisabledIcon, not rewardData.enabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.DisabledBg, not rewardData.enabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.DisabledReason, not rewardData.enabled)
  local tooltipText = GetLocalizedReplacementText("@ui_require_standing_level", {
    territory = territoryName,
    level = rewardData.disabledReason
  })
  if not rewardData.enabled then
    self:SetTooltip(tooltipText)
  end
  self:SetEnabled(rewardData.enabled)
  self.callbackSelf = callbackSelf
  self.callbackFn = callbackFn
  self.rewardData = rewardData
end
function TerritoryBonusPopup_Reward:OnBonusFocus()
  if self.mIsSelected then
    return
  end
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  if not self.mIsEnabled then
    return
  end
  local animTime = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.ScriptedEntityTweener:Play(self.entityId, animTime, {
    scaleX = 1.1,
    scaleY = 1.1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.HoverContainer, animTime, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.HighlightText, animTime, {
    textColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.audioHelper.Screen_TerritoryStandingHover)
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.Properties.HoverHash, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
    self.timeline:Add(self.Properties.HoverHash, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.Properties.HoverHash, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.HoverHash, animTime, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.HoverHash, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = animTime,
    onComplete = function()
      self.timeline:Play()
    end
  })
end
function TerritoryBonusPopup_Reward:OnBonusUnfocus()
  if self.mIsSelected == true then
    return
  end
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  if not self.mIsEnabled then
    return
  end
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.HoverContainer, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.HighlightText, 0.1, {
    textColor = self.UIStyle.COLOR_TAN,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.HoverHash, 0.1, {opacity = 0, ease = "QuadIn"})
end
function TerritoryBonusPopup_Reward:OnPress()
  if not self.mIsEnabled then
    return
  end
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  if self.callbackSelf then
    self.callbackFn(self.callbackSelf, self.rewardData)
  end
  self.audioHelper:PlaySound(self.audioHelper.Screen_TerritoryStandingHSelect)
end
function TerritoryBonusPopup_Reward:SetEnabled(enabled)
  self.mIsEnabled = enabled
end
function TerritoryBonusPopup_Reward:SetIsSelected(isSelected)
  self.mIsSelected = isSelected
end
function TerritoryBonusPopup_Reward:PlayRedeemEffect()
  UiElementBus.Event.SetIsEnabled(self.Properties.RedeemEffect, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.RedeemEffect, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.RedeemEffect)
  UiElementBus.Event.SetIsEnabled(self.Properties.Glow, true)
  self.ScriptedEntityTweener:Play(self.Properties.RedeemEffect, 0.1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.RedeemEffect, 0.25, {opacity = 1}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 1.2,
    onComplete = function()
      UiFlipbookAnimationBus.Event.Stop(self.Properties.RedeemEffect)
      UiElementBus.Event.SetIsEnabled(self.Properties.RedeemEffect, false)
    end
  })
  self.ScriptedEntityTweener:Play(self.entityId, 0.05, {scaleX = 1, scaleY = 1}, {scaleX = 0.95, scaleY = 0.95})
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {scaleX = 0.95, scaleY = 0.95}, {
    scaleX = 1.05,
    scaleY = 1.05,
    delay = 0.05
  })
  self.ScriptedEntityTweener:Play(self.Properties.Glow, 0.8, {
    scaleX = 1,
    scaleY = 1,
    opacity = 1
  }, {
    scaleX = 1.5,
    scaleY = 1.5,
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.Glow, false)
    end
  })
end
return TerritoryBonusPopup_Reward

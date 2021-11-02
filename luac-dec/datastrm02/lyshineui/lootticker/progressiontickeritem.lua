local ProgressionTickerItem = {
  Properties = {
    LabelText = {
      default = EntityId()
    },
    NumberText = {
      default = EntityId()
    },
    ProgressBar = {
      default = EntityId()
    },
    Line = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    IconCover = {
      default = EntityId()
    },
    DummyTweener = {
      default = EntityId()
    },
    Glow = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local WeaponMasteryData = RequireScript("LyShineUI.Skills.WeaponMastery.WeaponMasteryData")
BaseElement:CreateNewElement(ProgressionTickerItem)
function ProgressionTickerItem:OnInit()
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.eventTypeToData = {
    [eXpEventType_PlayerXp] = {
      labelText = "@ui_xp",
      valueLocText = "@ui_killfeed_xp_val",
      delay = 1
    },
    [eXpEventType_Currency] = {
      labelText = "@ui_currency",
      valueLocText = "@ui_killfeed_coin_val",
      delay = 2
    },
    [eXpEventType_Tradeskill] = {
      labelText = "",
      valueLocText = "@ui_killfeed_tradeskill_val",
      delay = 3
    },
    [eXpEventType_Standing] = {
      labelText = "@ui_territory_standing_with_icon",
      valueLocText = "@ui_killfeed_standing_val",
      delay = 4
    },
    [eXpEventType_Azoth] = {
      labelText = "@ui_azoth_currency",
      valueLocText = "@ui_killfeed_coin_val",
      delay = 5
    },
    [eXpEventType_Reputation] = {
      labelText = "",
      valueLocText = "",
      delay = 6
    },
    [eXpEventType_Tokens] = {
      labelText = "",
      valueLocText = "",
      delay = 7
    }
  }
  self.factionToIcon = {
    [eFactionType_Faction1] = "lyshineui/images/icons/objectives/reward_factionreputation" .. tostring(eFactionType_Faction1) .. ".dds",
    [eFactionType_Faction2] = "lyshineui/images/icons/objectives/reward_factionreputation" .. tostring(eFactionType_Faction2) .. ".dds",
    [eFactionType_Faction3] = "lyshineui/images/icons/objectives/reward_factionreputation" .. tostring(eFactionType_Faction3) .. ".dds"
  }
  self.factionToTokensIcon = {
    [eFactionType_Faction1] = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(eFactionType_Faction1) .. ".dds",
    [eFactionType_Faction2] = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(eFactionType_Faction2) .. ".dds",
    [eFactionType_Faction3] = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(eFactionType_Faction3) .. ".dds"
  }
  self.walletCap = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.wallet-cap-player")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey", function(self, claimKey)
    if claimKey and claimKey ~= 0 then
      self.claimKey = claimKey
    end
  end)
  self.claimKeyToIcon = {
    [2] = "lyshineui/images/icons/objectives/icon_territoryStanding_2.dds",
    [3] = "lyshineui/images/icons/objectives/icon_territoryStanding_3.dds",
    [4] = "lyshineui/images/icons/objectives/icon_territoryStanding_4.dds",
    [5] = "lyshineui/images/icons/objectives/icon_territoryStanding_5.dds",
    [6] = "lyshineui/images/icons/objectives/icon_territoryStanding_6.dds",
    [7] = "lyshineui/images/icons/objectives/icon_territoryStanding_7.dds",
    [8] = "lyshineui/images/icons/objectives/icon_territoryStanding_8.dds",
    [9] = "lyshineui/images/icons/objectives/icon_territoryStanding_9.dds",
    [10] = "lyshineui/images/icons/objectives/icon_territoryStanding_10.dds",
    [11] = "lyshineui/images/icons/objectives/icon_territoryStanding_11.dds",
    [12] = "lyshineui/images/icons/objectives/icon_territoryStanding_12.dds",
    [13] = "lyshineui/images/icons/objectives/icon_territoryStanding_13.dds",
    [14] = "lyshineui/images/icons/objectives/icon_territoryStanding_14.dds",
    [15] = "lyshineui/images/icons/objectives/icon_territoryStanding_15.dds",
    [16] = "lyshineui/images/icons/objectives/icon_territoryStanding_16.dds"
  }
  self.lastAmount = 0
  self.isEnabled = false
end
function ProgressionTickerItem:OnLocalPlayerNumberDisplayed(eventType, amount, masteryNameCrc, yOffset)
  local eventData = self.eventTypeToData[eventType]
  if not eventData then
    return
  end
  self.lastMasteryNameCrc = masteryNameCrc
  self.lastAmount = 0
  self:UpdateValue(eventType, amount, masteryNameCrc)
  local shouldShowProgress = false
  if eventType == eXpEventType_Tradeskill or eventType == eXpEventType_Standing then
    if eventType == eXpEventType_Standing then
      local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
      masteryNameCrc = Math.CreateCrc32(tostring(territoryId))
    end
    local currentLevel = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, masteryNameCrc)
    local currentProgress = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, masteryNameCrc)
    local requiredProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, masteryNameCrc, currentLevel)
    self.ProgressBar:SetProgressPercent((currentProgress - amount) / requiredProgress, currentProgress / requiredProgress)
    shouldShowProgress = true
  end
  if eventType == eXpEventType_PlayerXp then
    local prevReqGlory = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.PrevRequiredGlory") or 0
    local currentGlory = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Glory")
    local reqGlory = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.RequiredGlory")
    currentGlory = currentGlory - prevReqGlory
    reqGlory = reqGlory - prevReqGlory
    local oldPercent = (currentGlory - amount) / reqGlory
    local newPercent = currentGlory / reqGlory
    self.ProgressBar:SetProgressPercent(oldPercent, newPercent)
    shouldShowProgress = true
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ProgressBar, shouldShowProgress)
  UiElementBus.Event.SetIsEnabled(self.Properties.Line, shouldShowProgress)
  self.audioHelper:QueueSound("ProgressionTickerItem", self.audioHelper.onKill_XPnumber, 0.25)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Set(self.entityId, {y = yOffset})
  local fadeOutDelay = eventData.delay
  self:QueueFadeOut(fadeOutDelay)
  self.isEnabled = true
  self.ScriptedEntityTweener:Play(self.entityId, 0.01, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Icon, 0.2, {scaleX = 1.5, scaleY = 1.5}, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.IconCover, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.NumberText, 0.15, {opacity = 0, x = 30}, {
    opacity = 1,
    x = 44,
    ease = "QuadOut",
    delay = 0.05
  })
  self.ScriptedEntityTweener:Play(self.Properties.ProgressBar, 0.15, {opacity = 0, x = 31}, {
    opacity = 1,
    x = 45,
    ease = "QuadOut",
    delay = 0.05
  })
end
function ProgressionTickerItem:GetDisplayAmount(eventType, amount)
  local xpAmountText
  if eventType == eXpEventType_Currency then
    xpAmountText = "+" .. GetLocalizedCurrency(amount)
  elseif eventType == eXpEventType_Azoth then
    xpAmountText = "+" .. GetFormattedNumber(amount)
  else
    xpAmountText = "+" .. amount
  end
  return xpAmountText
end
function ProgressionTickerItem:UpdateValue(eventType, amount, masteryNameCrc, playAmountChangeAnim)
  local eventData = self.eventTypeToData[eventType]
  if not eventData then
    return
  end
  self.ScriptedEntityTweener:Stop(self.entityId)
  self.ScriptedEntityTweener:Stop(self.Properties.DummyTweener)
  local previousAmount = self.lastAmount
  if 0 < amount then
    amount = amount + self.lastAmount
  end
  self.lastAmount = amount
  local hideValue = false
  local locText = eventData.valueLocText
  local labelText = eventData.labelText
  if eventType == eXpEventType_Tradeskill then
    local progressionData = CategoricalProgressionRequestBus.Event.GetCategoricalProgressionData(self.playerEntityId, masteryNameCrc)
    local masteryName = progressionData.displayName
    local weaponMasteryData = WeaponMasteryData:GetByTableNameId(masteryNameCrc)
    local masteryIcon = weaponMasteryData.rewardIcon
    labelText = masteryName
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, masteryIcon)
  elseif eventType == eXpEventType_Standing then
    local icon = self.claimKeyToIcon[self.claimKey]
    local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(self.claimKey)
    local territoryName = territoryDefn.nameLocalizationKey
    labelText = GetLocalizedReplacementText(eventData.labelText, {territoryName = territoryName})
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, icon)
  elseif eventType == eXpEventType_Reputation then
    local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    local icon = self.factionToIcon[faction]
    if icon then
      UiImageBus.Event.SetSpritePathname(self.Properties.Icon, icon)
    end
  elseif eventType == eXpEventType_Tokens then
    local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    local icon = self.factionToTokensIcon[faction]
    if icon then
      UiImageBus.Event.SetSpritePathname(self.Properties.Icon, icon)
    end
  elseif eventType == eXpEventType_Currency then
    if amount >= self.walletCap then
      self.lastAmount = 0
      amount = amount - self.walletCap
      if 0 < amount then
        labelText = GetLocalizedReplacementText("@ui_coin_lost_ticker", {
          amount = GetLocalizedCurrency(amount, false)
        })
      else
        labelText = "@ui_coin_max_ticker"
      end
      hideValue = true
    elseif amount < 0 then
      labelText = GetLocalizedReplacementText("@ui_coin_lost_ticker", {
        amount = GetLocalizedCurrency(-amount, false)
      })
      hideValue = true
    end
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.LabelText, labelText, eUiTextSet_SetLocalized)
  local playAnims = false
  if hideValue then
    UiTextBus.Event.SetText(self.Properties.NumberText, "")
  elseif not playAmountChangeAnim then
    local xpAmountText = self:GetDisplayAmount(eventType, amount)
    UiTextBus.Event.SetText(self.Properties.NumberText, xpAmountText)
    playAnims = true
  else
    self.ScriptedEntityTweener:Play(self.Properties.DummyTweener, 0.5, {opacity = previousAmount}, {
      delay = 0,
      opacity = amount,
      ease = "CubicOut",
      onUpdate = function(currentValue, currentProgressPercent)
        local displayValue = math.floor(currentValue + 0.5)
        UiTextBus.Event.SetText(self.Properties.NumberText, self:GetDisplayAmount(eventType, displayValue))
      end
    })
    playAnims = true
  end
  if playAnims then
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.Properties.Icon, {scaleX = 1, scaleY = 1})
    self.ScriptedEntityTweener:Set(self.Properties.IconCover, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.NumberText, {
      textSize = 26,
      opacity = 1,
      x = 44
    })
    self.ScriptedEntityTweener:Set(self.Properties.ProgressBar, {opacity = 1, x = 45})
    self.ScriptedEntityTweener:Set(self.Properties.Glow, {opacity = 0})
  end
end
function ProgressionTickerItem:QueueFadeOut(delay)
  local displayTime = 3
  self.ScriptedEntityTweener:Stop(self.entityId)
  self.ScriptedEntityTweener:Play(self.entityId, displayTime, {
    opacity = 0,
    ease = "QuadOut",
    delay = 2,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.DummyTweener, displayTime + 1, {
    scaleX = 1,
    onComplete = function()
      self.isEnabled = false
    end
  })
end
function ProgressionTickerItem:IsEnabled()
  return self.isEnabled
end
return ProgressionTickerItem

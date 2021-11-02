local OWGuildShopLockedLevelInfo = {
  Properties = {
    UnlockButton = {
      default = EntityId()
    },
    PreviousLevelCheck = {
      default = EntityId()
    },
    PreviousLevelLabel = {
      default = EntityId()
    },
    RequiredPlayerLevel = {
      default = EntityId()
    },
    PlayerLevelCheck = {
      default = EntityId()
    }
  },
  CHECKMARK_ON = "LyShineUI/Images/SocialPane/socialPane_accept_symbol.png",
  CHECKMARK_OFF = "LyShineUI/Images/SocialPane/socialPane_decline_symbol.png"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OWGuildShopLockedLevelInfo)
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function OWGuildShopLockedLevelInfo:OnInit()
  BaseElement.OnInit(self)
  self.factionInfoTable = FactionCommon.factionInfoTable
  self.UnlockButton:SetCallback(self.OnUnlockRank, self)
  DynamicBus.OWGDynamicRequestBus.Connect(self.entityId, self)
  self.UnlockButton:SetButtonStyle(self.UnlockButton.BUTTON_STYLE_CTA)
end
function OWGuildShopLockedLevelInfo:SetRankInfo(rankInfo)
  self.rankInfo = rankInfo
  if self.rankInfo then
    local goldAmount = GetLocalizedCurrency(self.rankInfo.coin)
    local influenceAmount = self.rankInfo.influence
    local azothPrice = self.rankInfo.azothPrice
    local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    local currencyImagePath = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(faction)
    self:OnWalletChange()
    local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    rankName = self.factionInfoTable[faction].rankNames[self.rankInfo.rank]
    UiTextBus.Event.SetText(self.Properties.RequiredPlayerLevel, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_required_player_level", self.rankInfo.playerLevel))
    UiTextBus.Event.SetText(self.Properties.PreviousLevelLabel, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_unlock_previous_rank", rankName))
    local buttonText = GetLocalizedReplacementText("@owg_unlock_rank", {
      coin = goldAmount,
      token = influenceAmount,
      icon = currencyImagePath,
      coinTextColor = ColorRgbaToHexString(self.coinTextColor),
      influenceTextColor = ColorRgbaToHexString(self.influenceTextColor),
      azothTextColor = ColorRgbaToHexString(self.azothTextColor),
      azoth = GetFormattedNumber(azothPrice)
    })
    self.UnlockButton:SetText(buttonText)
  end
end
function OWGuildShopLockedLevelInfo:OnUnlockRank()
  DynamicBus.OWGuildShop.Broadcast.UnlockRank(self.rankInfo)
end
function OWGuildShopLockedLevelInfo:OnShutdown()
  DynamicBus.OWGDynamicRequestBus.Disconnect(self.entityId, self)
end
function OWGuildShopLockedLevelInfo:OnWalletChange()
  if not self.rankInfo then
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    return
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, self.rankInfo.isLocked)
  local wallet = DynamicBus.OWGuildShop.Broadcast.GetWallet()
  UiImageBus.Event.SetSpritePathname(self.Properties.PlayerLevelCheck, wallet.playerLevel >= self.rankInfo.playerLevel and self.CHECKMARK_ON or self.CHECKMARK_OFF)
  UiImageBus.Event.SetSpritePathname(self.Properties.PreviousLevelCheck, DynamicBus.OWGuildShop.Broadcast.IsRankLocked(self.rankInfo.rank - 1) and self.CHECKMARK_OFF or self.CHECKMARK_ON)
  UiImageBus.Event.SetColor(self.Properties.PlayerLevelCheck, wallet.playerLevel >= self.rankInfo.playerLevel and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED_MEDIUM)
  UiImageBus.Event.SetColor(self.Properties.PreviousLevelCheck, DynamicBus.OWGuildShop.Broadcast.IsRankLocked(self.rankInfo.rank - 1) and self.UIStyle.COLOR_RED_MEDIUM or self.UIStyle.COLOR_GREEN)
  UiTextBus.Event.SetColor(self.Properties.RequiredPlayerLevel, wallet.playerLevel >= self.rankInfo.playerLevel and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED_MEDIUM)
  UiTextBus.Event.SetColor(self.Properties.PreviousLevelLabel, DynamicBus.OWGuildShop.Broadcast.IsRankLocked(self.rankInfo.rank - 1) and self.UIStyle.COLOR_RED_MEDIUM or self.UIStyle.COLOR_GREEN)
  if wallet.coin >= self.rankInfo.coin then
    self.coinTextColor = self.UIStyle.COLOR_WHITE
  else
    self.coinTextColor = self.UIStyle.COLOR_RED_LIGHT
  end
  if wallet.influence >= self.rankInfo.influence then
    self.influenceTextColor = self.UIStyle.COLOR_WHITE
  else
    self.influenceTextColor = self.UIStyle.COLOR_RED_LIGHT
  end
  if wallet.azoth >= self.rankInfo.azothPrice then
    self.azothTextColor = self.UIStyle.COLOR_WHITE
  else
    self.azothTextColor = self.UIStyle.COLOR_RED_LIGHT
  end
  local canUnlockRank = DynamicBus.OWGuildShop.Broadcast.CanUnlockRank(self.rankInfo)
  if canUnlockRank then
  end
  local tooltip = "@owg_rank_unlock_tooltip"
  self.UnlockButton:SetEnabled(canUnlockRank)
  self.UnlockButton:SetTooltip(tooltip)
end
return OWGuildShopLockedLevelInfo

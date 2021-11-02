local OWGuild = {
  Properties = {
    ShopButton = {
      default = EntityId()
    },
    RankName = {
      default = EntityId()
    },
    ReputationAmount = {
      default = EntityId()
    },
    ReputationTitle = {
      default = EntityId()
    },
    ReputationIcon = {
      default = EntityId()
    },
    ReputationBar = {
      default = EntityId()
    },
    TokensTitle = {
      default = EntityId()
    },
    TokensIcon = {
      default = EntityId()
    },
    TokensAmount = {
      default = EntityId()
    },
    StoreItemsAvailableText = {
      default = EntityId()
    },
    PveMissionList = {
      default = EntityId()
    },
    PvpMissionList = {
      default = EntityId()
    }
  },
  guildIdToFaction = {
    [1459346962] = eFactionType_Faction1,
    [1410032581] = eFactionType_Faction2,
    [4109074679] = eFactionType_Faction3
  },
  reputationTooltipLocTag = "@ui_reputation_max_tooltip",
  tokensTooltipLocTag = "@ui_tokens_max_tooltip"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OWGuild)
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function OWGuild:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.factionInfoTable = FactionCommon.factionInfoTable
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      if self.playerEntityId then
        self:BusDisconnect(CategoricalProgressionNotificationBus, self.playerEntityId)
      end
      self.playerEntityId = playerEntityId
      self.categoricalProgressionHandler = self:BusConnect(CategoricalProgressionNotificationBus, self.playerEntityId)
    end
  end)
  self:SetVisualElements()
end
function OWGuild:OnShutdown()
end
function OWGuild:SetVisualElements()
  self.ShopButton:SetText("@owg_entershop_button")
  self.ShopButton:SetCallback("OpenShop", self)
  self.ShopButton:SetButtonStyle(self.ShopButton.BUTTON_STYLE_CTA)
  self.ShopButton:SizeTextToButton()
  SetTextStyle(self.Properties.RankName, self.UIStyle.FONT_STYLE_PRIMARY_TITLE)
  SetTextStyle(self.Properties.ReputationTitle, self.UIStyle.FONT_STYLE_BODY_NEW)
  SetTextStyle(self.Properties.ReputationAmount, self.UIStyle.FONT_STYLE_BODY_NEW_WHITE)
  SetTextStyle(self.Properties.StoreItemsAvailableText, self.UIStyle.FONT_STYLE_HINT)
  SetTextStyle(self.Properties.TokensTitle, self.UIStyle.FONT_STYLE_TITLE_GENERIC_SMALL)
  SetTextStyle(self.Properties.TokensAmount, self.UIStyle.FONT_STYLE_NUMBER_LARGE)
end
function OWGuild:OpenShop()
  DynamicBus.OWGDynamicRequestBus.Broadcast.OpenGuildShop(self.owGuildId)
end
function OWGuild:SetGuildId(id, progressionEntityId, guildShop)
  self.owGuildId = id
  self.progressionEntityId = progressionEntityId
  self.guildShop = guildShop
  local guildName = DynamicBus.OWGDynamicRequestBus.Broadcast.GetGuildName(self.owGuildId)
  local faction = self.guildIdToFaction[self.owGuildId]
  local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  self.owGuildTokensId = FactionRequestBus.Event.GetFactionTokensProgressionIdFromType(playerRootEntityId, faction)
  local factionBgColor = self.factionInfoTable[faction].crestBgColor
  local factionTextColor = self.factionInfoTable[faction].crestBgColorLight
  local reputationImagePath = "lyshineui/images/icons/objectives/reward_factionreputation" .. tostring(faction) .. ".dds"
  local tokensImagePath = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(faction) .. ".dds"
  UiTextBus.Event.SetText(self.Properties.ReputationTitle, LyShineScriptBindRequestBus.Broadcast.LocalizeText("@owg_guildreputation"))
  UiImageBus.Event.SetSpritePathname(self.Properties.ReputationIcon, reputationImagePath)
  UiTextBus.Event.SetText(self.Properties.TokensTitle, LyShineScriptBindRequestBus.Broadcast.LocalizeText("@owg_guildcurrency"))
  UiImageBus.Event.SetSpritePathname(self.Properties.TokensIcon, tokensImagePath)
  local numAvailableShopItems = self.guildShop:GetAvailableItemCountForCrc(self.owGuildId, self.progressionEntityId)
  UiTextBus.Event.SetText(self.Properties.StoreItemsAvailableText, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_shopitemsavailable", numAvailableShopItems))
  UiTextBus.Event.SetColor(self.Properties.RankName, factionTextColor)
  local currentRank = CategoricalProgressionRequestBus.Event.GetRank(progressionEntityId, self.owGuildId)
  local rankName = self.factionInfoTable[faction].rankNames[currentRank + 1]
  UiTextBus.Event.SetTextWithFlags(self.Properties.RankName, rankName, eUiTextSet_SetLocalized)
  local currentReputation = CategoricalProgressionRequestBus.Event.GetProgression(progressionEntityId, self.owGuildId)
  local reputationText = string.format("%s", GetFormattedNumber(currentReputation))
  UiTextBus.Event.SetTextWithFlags(self.Properties.ReputationAmount, reputationText, eUiTextSet_SetAsIs)
  self:RefreshCurrencyTextColorAndTooltip(self.owGuildId, self.ReputationAmount, self.reputationTooltipLocTag)
  self.ReputationBar:SetFillColor(factionBgColor)
  self.ReputationBar:SetProgressionId(self.owGuildId, self.progressionEntityId, self.guildShop, faction)
  self.ReputationBar:SetPoints(currentReputation)
  local currentTokens = CategoricalProgressionRequestBus.Event.GetProgression(progressionEntityId, self.owGuildTokensId)
  local tokensText = string.format("%s", GetFormattedNumber(currentTokens))
  UiTextBus.Event.SetTextWithFlags(self.Properties.TokensAmount, tokensText, eUiTextSet_SetAsIs)
  self:RefreshCurrencyTextColorAndTooltip(self.owGuildTokensId, self.TokensAmount, self.tokensTooltipLocTag)
end
function OWGuild:SetPveMissionData(missionDataList)
  self:SetMissionDataInternal(missionDataList, self.Properties.PveMissionList)
end
function OWGuild:SetPvpMissionData(missionDataList)
  self:SetMissionDataInternal(missionDataList, self.Properties.PvpMissionList)
end
function OWGuild:SetMissionDataInternal(missionDataList, listEntity)
  local children = UiElementBus.Event.GetChildren(listEntity)
  for i = 1, #children do
    local missionEntry = self.registrar:GetEntityTable(children[i])
    missionEntry:SetMissionData(self.owGuildId, missionDataList[i])
  end
end
function OWGuild:OnCategoricalProgressionPointsChanged(guildCRC, oldPoints, newPoints)
  if guildCRC == self.owGuildId then
    local reputationText = string.format("%s", GetFormattedNumber(newPoints))
    UiTextBus.Event.SetTextWithFlags(self.Properties.ReputationAmount, reputationText, eUiTextSet_SetAsIs)
    self.ReputationBar:SetPoints(newPoints)
    self:RefreshCurrencyTextColorAndTooltip(self.owGuildId, self.ReputationAmount, self.reputationTooltipLocTag)
  elseif guildCRC == self.owGuildTokensId then
    local tokensText = string.format("%s", GetFormattedNumber(newPoints))
    UiTextBus.Event.SetTextWithFlags(self.Properties.TokensAmount, tokensText, eUiTextSet_SetAsIs)
    self:RefreshCurrencyTextColorAndTooltip(self.owGuildTokensId, self.TokensAmount, self.tokensTooltipLocTag)
  end
end
function OWGuild:OnCategoricalProgressionRankChanged(guildCRC, oldRank, newRank)
  if guildCRC == self.owGuildId then
    local faction = self.guildIdToFaction[self.owGuildId]
    local rankName = self.factionInfoTable[faction].rankNames[newRank + 1]
    UiTextBus.Event.SetTextWithFlags(self.Properties.RankName, rankName, eUiTextSet_SetLocalized)
    local numAvailableShopItems = self.guildShop:GetAvailableItemCountForCrc(self.owGuildId, self.progressionEntityId)
    UiTextBus.Event.SetText(self.Properties.StoreItemsAvailableText, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_shopitemsavailable", numAvailableShopItems))
    self:RefreshCurrencyTextColorAndTooltip(self.owGuildId, self.ReputationAmount, self.reputationTooltipLocTag)
  elseif guildCRC == self.owGuildTokensId then
    self:RefreshCurrencyTextColorAndTooltip(self.owGuildTokensId, self.TokensAmount, self.tokensTooltipLocTag)
  end
end
function OWGuild:RefreshCurrencyTextColorAndTooltip(currencyId, textLabel, tooltipLocTag)
  if type(textLabel) ~= "table" then
    return
  end
  local currentRank = CategoricalProgressionRequestBus.Event.GetRank(self.progressionEntityId, currencyId)
  local currentPoints = CategoricalProgressionRequestBus.Event.GetProgression(self.progressionEntityId, currencyId)
  local maxPoints = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.progressionEntityId, currencyId, currentRank)
  if currentPoints >= maxPoints then
    UiTextBus.Event.SetColor(textLabel.entityId, self.UIStyle.COLOR_GREEN_BRIGHT)
  else
    UiTextBus.Event.SetColor(textLabel.entityId, self.UIStyle.COLOR_WHITE)
  end
  local tooltip = GetLocalizedReplacementText(tooltipLocTag, {amount = maxPoints})
  if textLabel.SetSimpleTooltip then
    textLabel:SetSimpleTooltip(tooltip)
  end
end
function OWGuild:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
end
function OWGuild:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  local children = UiElementBus.Event.GetChildren(self.Properties.PveMissionList)
  for i = 1, #children do
    local missionEntry = self.registrar:GetEntityTable(children[i])
    missionEntry:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  end
  children = UiElementBus.Event.GetChildren(self.Properties.PvpMissionList)
  if children then
    for i = 1, #children do
      local missionEntry = self.registrar:GetEntityTable(children[i])
      missionEntry:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
    end
  end
end
return OWGuild

local TerritoryIncentives = {
  Properties = {
    Company = {
      Screen = {
        default = EntityId()
      },
      CloseButton = {
        default = EntityId()
      },
      RunATownButton = {
        default = EntityId()
      },
      BonusFastTravel = {
        default = EntityId()
      },
      BonusTaxes = {
        default = EntityId()
      },
      BonusHouses = {
        default = EntityId()
      },
      BonusResourceContainer = {
        default = EntityId()
      },
      BonusTransferItem = {
        default = EntityId()
      },
      BonusGlobalLuck = {
        default = EntityId()
      },
      BonusGathering = {
        default = EntityId()
      },
      FrameHeader = {
        default = EntityId()
      },
      Frame = {
        default = EntityId()
      },
      CompanyBenefits = {
        default = EntityId()
      }
    },
    Faction = {
      Screen = {
        default = EntityId()
      },
      CloseButton = {
        default = EntityId()
      },
      BonusFastTravel = {
        default = EntityId()
      },
      BonusTaxes = {
        default = EntityId()
      },
      BonusHouses = {
        default = EntityId()
      },
      BonusFastTravelFaction = {
        default = EntityId()
      },
      BonusResourceContainer = {
        default = EntityId()
      },
      BonusTransferItem = {
        default = EntityId()
      },
      BonusGlobalLuck = {
        default = EntityId()
      },
      BonusGathering = {
        default = EntityId()
      },
      FrameHeader = {
        default = EntityId()
      },
      Frame = {
        default = EntityId()
      },
      CompanyBenefits = {
        default = EntityId()
      },
      FactionBenefits = {
        default = EntityId()
      }
    }
  },
  screenToShow = nil,
  screenToClose = nil,
  runATownEventId = "How_To_Run_A_Town_Popup",
  showTerritoryOwnerAfterTeleport = false,
  isLoadingScreenShowing = false,
  featureFlagToCheck = "UIFeatures.enable-territory-incentives-screen",
  SCREENSTATE_GOVERNER = 0,
  SCREENSTATE_FACTION = 1,
  SCREENSTATE_OTHER = 2
}
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(TerritoryIncentives)
function TerritoryIncentives:OnInit()
  BaseScreen.OnInit(self)
  local territoryIncentivesEnabled = ConfigProviderEventBus.Broadcast.GetBool(self.featureFlagToCheck)
  if not territoryIncentivesEnabled then
    return
  end
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    if data then
      self:BusConnect(PlayerComponentNotificationsBus, data)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey", function(self, claimKey)
    if self.landClaimHandler then
      self:BusDisconnect(self.landClaimHandler)
    end
    self.territoryId = claimKey
    if self.territoryId == nil then
      return
    end
    self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.territoryId)
  end)
  self:BusConnect(GroupsUINotificationBus)
  self:BusConnect(LoadScreenNotificationBus, self.entityId)
  DynamicBus.TerritoryIncentivesNotifications.Connect(self.entityId, self)
  UiElementBus.Event.SetIsEnabled(self.Company.Screen, false)
  UiElementBus.Event.SetIsEnabled(self.Faction.Screen, false)
  self:SetVisualElements()
end
function TerritoryIncentives:InitScreenData()
  if self.screenDataInitialized then
    return
  end
  local companyFastTravelDiscount = string.format("%d%%", PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryCompanyDiscountPct() + PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryFactionDiscountPct())
  local companyHouseCostDiscount = string.format("%d%%", math.floor(LocalPlayerUIRequestsBus.Broadcast.GetControllingCompanyHouseCostModifier() * 100 + 0.5))
  local companyTaxDiscount = string.format("%d%%", math.floor(LocalPlayerUIRequestsBus.Broadcast.GetControllingCompanyTaxModifier() * 100 + 0.5))
  local factionFastTravelDiscount = string.format("%d%%", PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryFactionDiscountPct())
  local factionLuckBonus = string.format("+%d", LocalPlayerUIRequestsBus.Broadcast.GetControllingFactionLuckModifier())
  local factionGatherBonus = string.format("+%d%%", math.floor(LocalPlayerUIRequestsBus.Broadcast.GetControllingFactionGatherModifier() * 100 + 0.5))
  self.CompanyData = {
    {
      entity = self.Properties.Company.BonusFastTravel,
      title = "@ui_eow_company_fast_travel_title",
      description = "@ui_eow_company_fast_travel_subtitle",
      replaceString = true,
      discount = companyFastTravelDiscount,
      image = "LyShineUI\\Images\\TerritoryIncentives\\discountFastTravel.dds"
    },
    {
      entity = self.Properties.Company.BonusTaxes,
      title = "@ui_eow_company_tax_title",
      description = "@ui_eow_company_tax_subtitle",
      replaceString = true,
      discount = companyTaxDiscount,
      image = "LyShineUI\\Images\\TerritoryIncentives\\discountTaxes.dds"
    },
    {
      entity = self.Properties.Company.BonusHouses,
      title = "@ui_eow_company_house_title",
      description = "@ui_eow_company_house_subtitle",
      replaceString = true,
      discount = companyHouseCostDiscount,
      image = "LyShineUI\\Images\\TerritoryIncentives\\discountHouses.dds"
    },
    {
      entity = self.Properties.Company.BonusResourceContainer,
      title = "@ui_eow_faction_town_containers_title",
      description = "@ui_eow_faction_town_containers_subtitle",
      replaceString = false,
      discount = nil,
      image = "LyShineUI\\Images\\TerritoryIncentives\\resourceContainers.dds"
    },
    {
      entity = self.Properties.Company.BonusTransferItem,
      title = "@ui_eow_faction_transfer_item_title",
      description = "@ui_eow_faction_transfer_item_subtitle",
      replaceString = true,
      discount = nil,
      image = "LyShineUI\\Images\\TerritoryIncentives\\transferItems.dds"
    },
    {
      entity = self.Properties.Company.BonusGlobalLuck,
      title = "@ui_eow_faction_global_luck_title",
      description = "@ui_eow_faction_global_luck_subtitle",
      replaceString = true,
      discount = factionLuckBonus,
      image = "LyShineUI\\Images\\TerritoryIncentives\\globalLuck.dds"
    },
    {
      entity = self.Properties.Company.BonusGathering,
      title = "@ui_eow_faction_gathering_title",
      description = "@ui_eow_faction_gathering_subtitle",
      replaceString = true,
      discount = factionGatherBonus,
      image = "LyShineUI\\Images\\TerritoryIncentives\\gatheringBonus.dds"
    }
  }
  self.FactionData = {
    {
      entity = self.Properties.Faction.BonusFastTravel,
      title = "@ui_eow_company_fast_travel_title",
      description = "@ui_eow_company_fast_travel_subtitle",
      replaceString = true,
      discount = companyFastTravelDiscount,
      isDisabled = true,
      image = "LyShineUI\\Images\\TerritoryIncentives\\discountFastTravel.dds"
    },
    {
      entity = self.Properties.Faction.BonusTaxes,
      title = "@ui_eow_company_tax_title",
      description = "@ui_eow_company_tax_subtitle",
      replaceString = true,
      discount = companyTaxDiscount,
      isDisabled = true,
      image = "LyShineUI\\Images\\TerritoryIncentives\\discountTaxes.dds"
    },
    {
      entity = self.Properties.Faction.BonusHouses,
      title = "@ui_eow_company_house_title",
      description = "@ui_eow_company_house_subtitle",
      replaceString = true,
      discount = companyHouseCostDiscount,
      isDisabled = true,
      image = "LyShineUI\\Images\\TerritoryIncentives\\discountHouses.dds"
    },
    {
      entity = self.Properties.Faction.BonusFastTravelFaction,
      title = "@ui_eow_faction_fast_travel_title",
      description = "@ui_eow_faction_fast_travel_subtitle",
      replaceString = true,
      discount = factionFastTravelDiscount,
      isDisabled = false,
      image = "LyShineUI\\Images\\TerritoryIncentives\\discountFastTravel.dds"
    },
    {
      entity = self.Properties.Faction.BonusResourceContainer,
      title = "@ui_eow_faction_town_containers_title",
      description = "@ui_eow_faction_town_containers_subtitle",
      replaceString = false,
      discount = nil,
      isDisabled = false,
      image = "LyShineUI\\Images\\TerritoryIncentives\\resourceContainers.dds"
    },
    {
      entity = self.Properties.Faction.BonusTransferItem,
      title = "@ui_eow_faction_transfer_item_title",
      description = "@ui_eow_faction_transfer_item_subtitle",
      replaceString = true,
      discount = nil,
      isDisabled = false,
      image = "LyShineUI\\Images\\TerritoryIncentives\\transferItems.dds"
    },
    {
      entity = self.Properties.Faction.BonusGlobalLuck,
      title = "@ui_eow_faction_global_luck_title",
      description = "@ui_eow_faction_global_luck_subtitle",
      replaceString = true,
      discount = factionLuckBonus,
      isDisabled = false,
      image = "LyShineUI\\Images\\TerritoryIncentives\\globalLuck.dds"
    },
    {
      entity = self.Properties.Faction.BonusGathering,
      title = "@ui_eow_faction_gathering_title",
      description = "@ui_eow_faction_gathering_subtitle",
      replaceString = true,
      discount = factionGatherBonus,
      isDisabled = false,
      image = "LyShineUI\\Images\\TerritoryIncentives\\gatheringBonus.dds"
    }
  }
  self.OtherData = {
    {
      entity = self.Properties.Faction.BonusFastTravel,
      title = "@ui_eow_company_fast_travel_title",
      description = "@ui_eow_company_fast_travel_subtitle",
      replaceString = true,
      discount = companyFastTravelDiscount,
      image = "LyShineUI\\Images\\TerritoryIncentives\\discountFastTravel.dds"
    },
    {
      entity = self.Properties.Faction.BonusTaxes,
      title = "@ui_eow_company_tax_title",
      description = "@ui_eow_company_tax_subtitle",
      replaceString = true,
      discount = companyTaxDiscount,
      image = "LyShineUI\\Images\\TerritoryIncentives\\discountTaxes.dds"
    },
    {
      entity = self.Properties.Faction.BonusHouses,
      title = "@ui_eow_company_house_title",
      description = "@ui_eow_company_house_subtitle",
      replaceString = true,
      discount = companyHouseCostDiscount,
      image = "LyShineUI\\Images\\TerritoryIncentives\\discountHouses.dds"
    },
    {
      entity = self.Properties.Faction.BonusFastTravelFaction,
      title = "@ui_eow_faction_fast_travel_title",
      description = "@ui_eow_faction_fast_travel_subtitle",
      replaceString = true,
      discount = factionFastTravelDiscount,
      image = "LyShineUI\\Images\\TerritoryIncentives\\discountFastTravel.dds"
    },
    {
      entity = self.Properties.Faction.BonusResourceContainer,
      title = "@ui_eow_faction_town_containers_title",
      description = "@ui_eow_faction_town_containers_subtitle",
      replaceString = false,
      discount = nil,
      image = "LyShineUI\\Images\\TerritoryIncentives\\resourceContainers.dds"
    },
    {
      entity = self.Properties.Faction.BonusTransferItem,
      title = "@ui_eow_faction_transfer_item_title",
      description = "@ui_eow_faction_transfer_item_subtitle",
      replaceString = true,
      discount = nil,
      image = "LyShineUI\\Images\\TerritoryIncentives\\transferItems.dds"
    },
    {
      entity = self.Properties.Faction.BonusGlobalLuck,
      title = "@ui_eow_faction_global_luck_title",
      description = "@ui_eow_faction_global_luck_subtitle",
      replaceString = true,
      discount = factionLuckBonus,
      image = "LyShineUI\\Images\\TerritoryIncentives\\globalLuck.dds"
    },
    {
      entity = self.Properties.Faction.BonusGathering,
      title = "@ui_eow_faction_gathering_title",
      description = "@ui_eow_faction_gathering_subtitle",
      replaceString = true,
      discount = factionGatherBonus,
      image = "LyShineUI\\Images\\TerritoryIncentives\\gatheringBonus.dds"
    }
  }
  self.screenDataInitialized = true
end
function TerritoryIncentives:SetVisualElements()
  self.Company.FrameHeader:SetHeaderStyle(self.Company.FrameHeader.HEADER_STYLE_LARGE_WITH_SUBTITLE)
  self.Company.CloseButton:SetCallback("OnCloseButtonPressed", self)
  self.Company.CloseButton:SetText("@ui_eow_close")
  self.Company.RunATownButton:SetCallback("OnHowToRunATownPressed", self)
  SetTextStyle(self.Properties.Company.CompanyBenefits, self.UIStyle.FONT_STYLE_TOOLTIP_HEADER)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Company.CompanyBenefits, "@ui_eow_company_benefits", eUiTextSet_SetLocalized)
  self.Faction.FrameHeader:SetHeaderStyle(self.Faction.FrameHeader.HEADER_STYLE_LARGE_WITH_SUBTITLE)
  self.Faction.CloseButton:SetCallback("OnCloseButtonPressed", self)
  self.Faction.CloseButton:SetText("@ui_eow_close")
  SetTextStyle(self.Properties.Faction.CompanyBenefits, self.UIStyle.FONT_STYLE_TOOLTIP_HEADER)
  SetTextStyle(self.Properties.Faction.FactionBenefits, self.UIStyle.FONT_STYLE_TOOLTIP_HEADER)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Faction.CompanyBenefits, "@ui_eow_others_company_benefits", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Faction.FactionBenefits, "@ui_eow_others_faction_benefits", eUiTextSet_SetLocalized)
end
function TerritoryIncentives:OnTransitionIn(fromStat, fromLevel, toState, toLevel)
  if self.screenToShow ~= nil then
    if self.screenToShow:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.screenToShow, true)
      self.screenToClose = self.screenToShow
      self:SetScreenVisible(true)
    end
    self.screenToShow = nil
  end
end
function TerritoryIncentives:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  if self.screenToClose ~= nil and self.screenToClose:IsValid() then
    self:SetScreenVisible(false)
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function TerritoryIncentives:SetScreenVisible(isVisible)
  self.ScriptedEntityTweener:Stop(self.entityId)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut"
    })
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.screenToClose, false)
      end
    })
  end
end
function TerritoryIncentives:OnSiegeWarfareEnded(isWinner, resolutionPhaseEndTimePoint)
  if isWinner then
    local raidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
    if not raidId or not raidId:IsValid() then
      return
    end
    local isAttacker = false
    local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(raidId)
    if warDetails:IsValid() then
      isAttacker = warDetails:IsAttackingRaid(raidId)
    end
    if isAttacker then
      local territoryNameFromId = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(warDetails:GetTerritoryId())
      if territoryNameFromId == nil or territoryNameFromId == "" then
        territoryNameFromId = "@ui_eow_invalid_territory_id"
      end
      local attackerFaction = warDetails:GetAttackerFaction()
      local playerGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
      local attackerGuildId = warDetails:GetAttackerGuildId()
      local sameGuild = playerGuildId ~= nil and attackerGuildId == playerGuildId
      if sameGuild then
        local factionNameFromInfo
        local factionInfoFromTable = FactionCommon.factionInfoTable[attackerFaction]
        if factionInfoFromTable ~= nil then
          factionNameFromInfo = factionInfoFromTable.factionName
        else
          factionNameFromInfo = "@ui_eow_invalid_faction_id"
        end
        local stringReplacements = {territoryName = territoryNameFromId, factionName = factionNameFromInfo}
        self:SetScreenState(self.SCREENSTATE_GOVERNER, stringReplacements)
      else
        local stringReplacements = {territoryName = territoryNameFromId}
        local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
        local sameFaction = playerFaction ~= nil and attackerFaction == playerFaction
        if sameFaction then
          self:SetScreenState(self.SCREENSTATE_FACTION, stringReplacements)
        end
      end
    end
  end
end
function TerritoryIncentives:SetScreenState(state, stringReplacements)
  self:InitScreenData()
  if state == self.SCREENSTATE_GOVERNER then
    self.screenToShow = self.Company.Screen
    self:SetBonusData(self.CompanyData, stringReplacements)
    local title = GetLocalizedReplacementText("@ui_eow_company_title", stringReplacements)
    local subtitle = GetLocalizedReplacementText("@ui_eow_company_subtitle", stringReplacements)
    self.Company.FrameHeader:SetText(title)
    self.Company.FrameHeader:SetTextSecondary(subtitle)
  elseif state == self.SCREENSTATE_FACTION then
    self.screenToShow = self.Faction.Screen
    self:SetBonusData(self.FactionData, stringReplacements)
    local title = GetLocalizedReplacementText("@ui_eow_faction_title", stringReplacements)
    self.Faction.FrameHeader:SetText(title)
    self.Faction.FrameHeader:SetTextSecondary("@ui_eow_faction_subtitle")
  elseif state == self.SCREENSTATE_OTHER then
    self.screenToShow = self.Faction.Screen
    self:SetBonusData(self.OtherData, stringReplacements)
    self.Faction.FrameHeader:SetText("@ui_eow_others_title")
    self.Faction.FrameHeader:SetTextSecondary("@ui_eow_others_subtitle")
  end
end
function TerritoryIncentives:OnPlayerTeleportCompleted()
  if self.screenToShow ~= nil and self.screenToShow:IsValid() then
    LyShineManagerBus.Broadcast.SetState(3288505562)
  elseif self.showTerritoryOwnerAfterTeleport and not self.isLoadingScreenShowing then
    self.showTerritoryOwnerAfterTeleport = false
    self:ShowTerritoryChangeNotification()
  end
end
function TerritoryIncentives:OnLoadingScreenShown()
  self.isLoadingScreenShowing = true
end
function TerritoryIncentives:OnLoadingScreenDismissed()
  self.isLoadingScreenShowing = false
  if self.showTerritoryOwnerAfterTeleport then
    self.showTerritoryOwnerAfterTeleport = false
    self:ShowTerritoryChangeNotification()
  end
end
function TerritoryIncentives:OnCloseButtonPressed()
  LyShineManagerBus.Broadcast.ExitState(3288505562)
end
function TerritoryIncentives:OnHowToRunATownPressed()
  if self.runATownOpen then
    return
  end
  self.runATownOpen = true
  PopupWrapper:RequestPopupWithParams({
    title = "@ui_run_a_town_popup_title",
    message = "@ui_run_a_town_popup_desc",
    eventId = self.runATownEventId,
    callerSelf = self,
    callback = self.OnHowToRunATownCloseButtonPressed,
    buttonText = "@ui_run_a_town_popup_close_button_text",
    showCloseButton = false,
    additionalHeight = 30
  })
end
function TerritoryIncentives:OnHowToRunATownCloseButtonPressed()
  self.runATownOpen = false
end
function TerritoryIncentives:OnRequestTerritoryIncentivesScreen(territoryId)
  local territoryNameFromId = territoryId and TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId) or "@ui_eow_default_territory_name"
  if territoryNameFromId == "" then
    territoryNameFromId = "@ui_eow_default_territory_name"
  end
  local stringReplacements = {territoryName = territoryNameFromId}
  self:SetScreenState(self.SCREENSTATE_OTHER, stringReplacements)
  LyShineManagerBus.Broadcast.SetState(3288505562)
end
function TerritoryIncentives:OnRequestHowToRunATownPopup()
  self:OnHowToRunATownPressed()
end
function TerritoryIncentives:SetBonusData(data, stringReplacements)
  for i = 1, #data do
    local currentItem = self.registrar:GetEntityTable(data[i].entity)
    currentItem:SetText(data[i].title)
    local descriptionText = data[i].description
    if data[i].replaceString then
      descriptionText = GetLocalizedReplacementText(data[i].description, stringReplacements)
    end
    currentItem:SetTextDescription(descriptionText)
    if data[i].isDisabled then
      currentItem:SetEnabled(not data[i].isDisabled)
    else
      currentItem:SetEnabled(true)
    end
    currentItem:SetImage(data[i].image)
    currentItem:SetDiscountValue(data[i].discount)
  end
end
function TerritoryIncentives:OnClaimOwnerChanged(territoryId, ownerData, oldOwnerData)
  if territoryId == nil or territoryId ~= self.territoryId then
    return
  end
  if ownerData.guildName == nil or ownerData.guildName == "" then
    return
  end
  local replacements = {
    guildName = ownerData.guildName
  }
  local territoryNameValue = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
  if territoryNameValue ~= nil and territoryNameValue ~= "" then
    replacements.territoryName = territoryNameValue
  else
    replacements.territoryName = "@ui_eow_invalid_territory_id"
  end
  local chatMessage = BaseGameChatMessage()
  chatMessage.type = eChatMessageType_System
  local claimedByText = GetLocalizedReplacementText("@ui_eow_territory_owner_change_chat_message", replacements)
  chatMessage.body = claimedByText
  ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
  local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  if playerFaction == nil or playerFaction == eFactionType_None then
    return
  end
  local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(territoryId)
  if warDetails and warDetails:IsValid() then
    if warDetails:GetWarPhase() ~= eWarPhase_Resolution then
      return
    end
    self.newOwnerTerritoryId = territoryId
    self.newOwnerTerritoryFaction = ownerData.faction
    local raidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
    if raidId and raidId:IsValid() and warDetails:IsRaidInWar(raidId) then
      self.showTerritoryOwnerAfterTeleport = playerFaction == oldOwnerData.faction
      return
    end
    self:ShowTerritoryChangeNotification()
  elseif oldOwnerData == nil or oldOwnerData.faction == eFactionType_None then
    self.newOwnerTerritoryId = territoryId
    self.newOwnerTerritoryFaction = ownerData.faction
    self:ShowTerritoryChangeNotification()
  end
end
function TerritoryIncentives:ShowTerritoryChangeNotification()
  if self.newOwnerTerritoryId == nil then
    return
  end
  if self.newOwnerTerritoryFaction == nil or self.newOwnerTerritoryFaction == eFactionType_None then
    return
  end
  local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  if playerFaction == nil or playerFaction == eFactionType_None then
    return
  end
  local replacements = {}
  local icon = ""
  local factionInfoFromTable = FactionCommon.factionInfoTable[self.newOwnerTerritoryFaction]
  if factionInfoFromTable ~= nil then
    replacements.factionName = factionInfoFromTable.factionName
    icon = factionInfoFromTable.crestFg
  else
    replacements.factionName = "@ui_eow_invalid_faction_id"
  end
  local territoryNameValue = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.newOwnerTerritoryId)
  if territoryNameValue ~= nil and territoryNameValue ~= "" then
    replacements.territoryName = territoryNameValue
  else
    replacements.territoryName = "@ui_eow_invalid_territory_id"
  end
  local playerFactionOwnsTerritory = self.newOwnerTerritoryFaction == playerFaction
  local notificationTitle = GetLocalizedReplacementText(playerFactionOwnsTerritory and "@ui_eow_territory_owner_change_win_title" or "@ui_eow_territory_owner_change_lose_title", replacements)
  local notificationText = GetLocalizedReplacementText(playerFactionOwnsTerritory and "@ui_eow_territory_owner_change_win_text" or "@ui_eow_territory_owner_change_lose_text", replacements)
  local notificationData = NotificationData()
  notificationData.type = "Generic"
  notificationData.icon = icon
  notificationData.title = notificationTitle
  notificationData.text = notificationText
  notificationData.hasChoice = true
  notificationData.contextId = self.entityId
  notificationData.acceptTextOverride = "@ui_notification_learn_more"
  notificationData.declineTextOverride = "@ui_dismiss"
  notificationData.callbackName = "OnTerritoryChangeNotificationChoice"
  notificationData.maximumDuration = 20
  notificationData.showProgress = true
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function TerritoryIncentives:OnTerritoryChangeNotificationChoice(notificationId, isAccepted)
  if isAccepted then
    self:OnRequestTerritoryIncentivesScreen(self.newOwnerTerritoryId)
  end
end
return TerritoryIncentives

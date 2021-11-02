local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local OWGuildShop = {
  Properties = {
    GuildName = {
      default = EntityId()
    },
    ShopLevelList = {
      default = EntityId()
    },
    ShopLevelContainer = {
      default = EntityId()
    },
    Level1Button = {
      default = EntityId()
    },
    GuildShopItemList = {
      default = EntityId()
    },
    GuildShopConfirmPopup = {
      default = EntityId()
    },
    NotificationBanner = {
      default = EntityId()
    },
    NotificationMessage = {
      default = EntityId()
    },
    GuildInfluence = {
      default = EntityId()
    },
    GuildCurrencyIcon = {
      default = EntityId()
    },
    Gold = {
      default = EntityId()
    },
    GoldIcon = {
      default = EntityId()
    },
    AzothCurrency = {
      default = EntityId()
    },
    CurrencyLabel = {
      default = EntityId()
    },
    CoinLabel = {
      default = EntityId()
    },
    AzothLabel = {
      default = EntityId()
    },
    LineTop1 = {
      default = EntityId()
    },
    LineTop2 = {
      default = EntityId()
    },
    LineLeft = {
      default = EntityId()
    },
    LineRight = {
      default = EntityId()
    },
    VerticalDivider = {
      default = EntityId()
    }
  },
  battleTokenIconPath = "lyshineui/images/HUD/WarHUD/icon_BattleTokens.dds",
  outpostRushAzothIconPath = "lyshineui/images/icons/items/resource/azureT1.dds",
  outpostRushItemPriceId = 324048019,
  guildIdToFaction = {
    [1459346962] = eFactionType_Faction1,
    [1410032581] = eFactionType_Faction2,
    [4109074679] = eFactionType_Faction3
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OWGuildShop)
function OWGuildShop:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.factionInfoTable = FactionCommon.factionInfoTable
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildShopConfirmPopup, false)
  self:BusConnect(UiScrollBoxNotificationBus, self.Properties.GuildShopItemList)
  DynamicBus.OWGuildShop.Connect(self.entityId, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if self.playerEntityId then
      self:BusDisconnect(CategoricalProgressionNotificationBus, self.playerEntityId)
    end
    self.playerEntityId = playerEntityId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    if data then
      self.inventoryId = data
    end
  end)
  self.wallet = {
    coin = 0,
    influence = 0,
    playerLevel = 0,
    azoth = 0
  }
  if self.Properties.AzothLabel:IsValid() then
    SetTextStyle(self.Properties.AzothLabel, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  end
  if self.Properties.CoinLabel:IsValid() then
    SetTextStyle(self.Properties.CoinLabel, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  end
  if self.Properties.CurrencyLabel:IsValid() then
    SetTextStyle(self.Properties.CurrencyLabel, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  end
end
function OWGuildShop:OnShutdown()
  DynamicBus.OWGuildShop.Disconnect(self.entityId, self)
end
function OWGuildShop:PopulateGuildShops()
  if self.guildShops then
    return
  end
  local currencyConversionEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrencyConversionComponentReady")
  local allItems = CurrencyConversionRequestBus.Event.GetConversionList(currencyConversionEntityId)
  if not allItems then
    return
  end
  self.guildShops = {}
  local availableItemCountsPerRankPerKey = {}
  for i = 1, #allItems do
    local itemConversionData = allItems[i]
    if itemConversionData.categoricalProgressionId ~= 0 then
      local gearScore = itemConversionData.itemDescriptor.gearScore
      if gearScore == 0 then
        local staticItemData = StaticItemDataManager:GetItem(itemConversionData.itemDescriptor.itemId)
        if 0 < staticItemData.gearScoreOverride then
          gearScore = staticItemData.gearScoreOverride
        else
          gearScore = staticItemData.baseGearScore
        end
      end
      local descriptor = ItemDescriptor()
      descriptor.itemId = itemConversionData.itemDescriptor.itemId
      descriptor.quantity = itemConversionData.itemDescriptor.quantity
      descriptor.gearScore = gearScore
      descriptor:SetPerks(ItemCommon:GetPerks(itemConversionData.itemDescriptor))
      local availableItem = {
        conversionID = itemConversionData.conversionID,
        itemDescriptor = descriptor,
        influence = itemConversionData.progressionPrice,
        coin = itemConversionData.currencyPrice,
        rank = itemConversionData.requiredRank,
        azothPrice = itemConversionData.azothCurrencyPrice,
        itemPriceId = itemConversionData.itemPriceId,
        itemPrice = itemConversionData.itemPrice
      }
      local guildKey = itemConversionData.rankCheckCategoricalProgressionId
      if not self.guildShops[guildKey] then
        self.guildShops[guildKey] = {
          crc = itemConversionData.rankCheckCategoricalProgressionId,
          availableItems = {}
        }
        availableItemCountsPerRankPerKey[guildKey] = {}
      end
      local curCount = availableItemCountsPerRankPerKey[guildKey][availableItem.rank] or 0
      availableItemCountsPerRankPerKey[guildKey][availableItem.rank] = curCount + 1
      table.insert(self.guildShops[guildKey].availableItems, availableItem)
    end
  end
  for guildKey, guildInfo in pairs(self.guildShops) do
    local currentRank = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, guildInfo.crc)
    guildInfo.ranks = {}
    guildInfo.rankToRankInfo = {}
    local maxRank = CategoricalProgressionRequestBus.Event.GetMaxRank(self.playerEntityId, guildInfo.crc) or -1
    for rank = 0, maxRank do
      local rankData = CategoricalProgressionRequestBus.Event.GetRankData(self.playerEntityId, guildInfo.crc, rank)
      local rankInfo = {
        rank = rank,
        numAvailableItems = availableItemCountsPerRankPerKey[guildInfo.crc][rank] or 0,
        isLocked = rank > currentRank,
        influence = CategoricalProgressionRequestBus.Event.GetRequiredPointsForRank(self.playerEntityId, guildInfo.crc, rank),
        maxInfluence = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, guildInfo.crc, rank),
        coin = CategoricalProgressionRequestBus.Event.GetRequiredCoinForRank(self.playerEntityId, guildInfo.crc, rank),
        playerLevel = CategoricalProgressionRequestBus.Event.GetRequiredLevelForRank(self.playerEntityId, guildInfo.crc, rank),
        azothPrice = rankData.azothCostToAttain
      }
      table.insert(guildInfo.ranks, rankInfo)
      guildInfo.rankToRankInfo[rankInfo.rank] = rankInfo
    end
  end
end
function OWGuildShop:GetAvailableItemCountForCrc(crc, progressionEntityId)
  self:PopulateGuildShops()
  local guildInfo = self.guildShops[crc]
  if guildInfo then
    local currentRank = CategoricalProgressionRequestBus.Event.GetRank(progressionEntityId, crc)
    local totalAvailableItems = 0
    for rank = 0, currentRank do
      local rankInfo = guildInfo.rankToRankInfo[rank]
      if rankInfo then
        totalAvailableItems = totalAvailableItems + rankInfo.numAvailableItems
      end
    end
    return totalAvailableItems
  end
  return 0
end
function OWGuildShop:GetAvailableItemCountForCrcForRank(crc, progressionEntityId, rank)
  self:PopulateGuildShops()
  local guildInfo = self.guildShops[crc]
  if guildInfo then
    local rankInfo = guildInfo.rankToRankInfo[rank]
    if rankInfo then
      return rankInfo.numAvailableItems
    end
  end
  return 0
end
function OWGuildShop:ShowBanner(message)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = message
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function OWGuildShop:GuildShopConfirmPopupIsOpen()
  return self.GuildShopConfirmPopup:IsOpen()
end
function OWGuildShop:CloseConfirmPopup()
  self.GuildShopConfirmPopup:OnClose()
end
function OWGuildShop:OpenGuildShop(guildCRC)
  self.guildCRC = guildCRC
  self.guildKey = guildCRC
  local faction = self.guildIdToFaction[self.guildCRC]
  if faction then
    local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    self.guildTokensCRC = FactionRequestBus.Event.GetFactionTokensProgressionIdFromType(playerRootEntityId, faction)
  else
    self.guildTokensCRC = 0
  end
  self:PopulateGuildShops()
  if not self.guildShops[self.guildKey] then
    Log("No OW guild shop for %s!", tostring(guildCRC))
    return false
  end
  if not self.playerEntityId then
    Log("No player entity for OW Guild Shop!")
    return false
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.Amount", function(self, currencyAmount)
    self.wallet.coin = currencyAmount
    self:UpdateWallet()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Progression.Level", function(self, playerLevel)
    self.wallet.playerLevel = playerLevel
    self:UpdateWallet()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.AzothAmount", function(self, azoth)
    self.wallet.azoth = azoth
    self:UpdateWallet()
  end)
  self.categoricalProgressionHandler = self:BusConnect(CategoricalProgressionNotificationBus, self.playerEntityId)
  self.currentShop = self.guildShops[self.guildKey]
  local currentRank = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, guildCRC)
  for _, rankInfo in pairs(self.currentShop.rankToRankInfo) do
    rankInfo.isLocked = currentRank < rankInfo.rank
  end
  local influenceCRC = self.guildTokensCRC == 0 and self.guildCRC or self.guildTokensCRC
  self.wallet.influence = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, influenceCRC)
  local contentOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.ShopLevelContainer)
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.ShopLevelContainer, #self.currentShop.ranks)
  for i = 1, #self.currentShop.ranks do
    local rankElement = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.ShopLevelContainer, i - 1))
    rankElement:SetRank(self.currentShop.ranks[i])
    rankElement:SetCallback(function()
      self.GuildShopItemList:GoToHeader(self.currentShop.ranks[i].rank)
      self:OnRankVisibilityChanged(self.currentShop.ranks[i].rank, true)
    end, self)
  end
  self.GuildShopItemList:SetAvailableItems(self.currentShop.ranks, self.currentShop.availableItems, {
    cbSelf = self,
    cbFunction = self.OnRankVisibilityChanged
  })
  self:UpdateWallet()
  local isSiegeArmory = guildCRC == 1175253129
  local isOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(self.playerEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  self.useItemForInfluence = false
  if isOutpostRush then
    self.useItemForInfluence = true
    self:OnContainerChanged()
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrencyLabel, "@OutpostRushAzothEssence", eUiTextSet_SetLocalized)
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCurrencyIcon, self.outpostRushAzothIconPath)
    UiElementBus.Event.SetIsEnabled(self.Properties.ShopLevelList, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.GoldIcon, false)
    UiTextBus.Event.SetColor(self.Properties.CurrencyLabel, self.UIStyle.COLOR_GRAY_80)
    if self.containerEventHandler == nil then
      self.containerEventHandler = self:BusConnect(ContainerEventBus, self.inventoryId)
    end
  elseif isSiegeArmory then
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrencyLabel, "@owg_battletoken_name", eUiTextSet_SetLocalized)
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCurrencyIcon, self.battleTokenIconPath)
    UiElementBus.Event.SetIsEnabled(self.Properties.ShopLevelList, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.GoldIcon, false)
    UiTextBus.Event.SetColor(self.Properties.CurrencyLabel, self.UIStyle.COLOR_GRAY_80)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ShopLevelList, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.GoldIcon, true)
    local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    local factionName = self.factionInfoTable[faction].factionName
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrencyLabel, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_guildcurrency_name", factionName), eUiTextSet_SetAsIs)
    local factionBgColor = self.UIStyle["COLOR_FACTION_BG_" .. tostring(faction)]
    local currencyImagePath = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(faction) .. ".dds"
    UiTextBus.Event.SetColor(self.Properties.CurrencyLabel, factionBgColor)
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCurrencyIcon, currencyImagePath)
    self.LineTop2:SetVisible(true, 1.2, {delay = 0.35})
    self.LineLeft:SetVisible(true, 1.2, {delay = 0.35})
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  local screenDelay = isSiegeArmory and 0 or 0.4
  local screenDuration = isSiegeArmory and 0.3 or 1
  self.ScriptedEntityTweener:Play(self.entityId, screenDuration, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = screenDelay
  })
  local lineDelay = isSiegeArmory and 0.05 or 0.35
  self.LineTop1:SetVisible(true, 1.2, {delay = lineDelay})
  self.LineRight:SetVisible(true, 1.2, {delay = lineDelay})
  self.VerticalDivider:SetVisible(true, 1.2, {delay = lineDelay})
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildShopConfirmPopup, false)
  return true
end
function OWGuildShop:CloseGuildShop()
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Currency.Amount")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Progression.Level")
  self:BusDisconnect(self.categoricalProgressionHandler)
  self.categoricalProgressionHandler = nil
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  if self.containerEventHandler then
    self:BusDisconnect(self.containerEventHandler)
    self.containerEventHandler = nil
  end
  self.LineTop1:SetVisible(false, 0)
  self.LineTop2:SetVisible(false, 0)
  self.LineLeft:SetVisible(false, 0)
  self.LineRight:SetVisible(false, 0)
  self.VerticalDivider:SetVisible(false, 0)
  self.guildCRC = nil
  self.guildKey = nil
end
function OWGuildShop:UpdateWallet()
  if not self.guildCRC or not self.currentShop then
    return
  end
  UiTextBus.Event.SetText(self.Properties.GuildInfluence, GetFormattedNumber(self.wallet.influence))
  UiTextBus.Event.SetText(self.Properties.Gold, GetLocalizedCurrency(self.wallet.coin))
  UiTextBus.Event.SetText(self.Properties.AzothCurrency, GetFormattedNumber(self.wallet.azoth))
  DynamicBus.OWGDynamicRequestBus.Broadcast.OnWalletChange(self.wallet)
end
function OWGuildShop:OnContainerChanged()
  local itemDescriptor = ItemDescriptor()
  itemDescriptor.itemId = self.outpostRushItemPriceId
  self.wallet.influence = ContainerRequestBus.Event.GetItemCount(self.inventoryId, itemDescriptor, false, true, false)
  self:UpdateWallet()
end
function OWGuildShop:CanBuyItem(availableItem)
  if not self.currentShop then
    return false
  end
  local hasInfluence = false
  if self.useItemForInfluence then
    hasInfluence = availableItem.itemPrice <= self.wallet.influence
  else
    hasInfluence = availableItem.influence <= self.wallet.influence
  end
  return not self.currentShop.rankToRankInfo[availableItem.rank].isLocked and availableItem.coin <= self.wallet.coin and availableItem.azothPrice <= self.wallet.azoth and hasInfluence
end
function OWGuildShop:IsRankLocked(rank)
  if not self.currentShop then
    return false
  end
  return self.currentShop.rankToRankInfo[rank].isLocked
end
function OWGuildShop:GetRankInfoFromRank(rank)
  if not self.currentShop then
    return nil
  end
  return self.currentShop.rankToRankInfo[rank]
end
function OWGuildShop:CanUnlockRank(rankInfo)
  if not self.currentShop then
    return false
  end
  for i = 1, #self.currentShop.ranks do
    if rankInfo == self.currentShop.ranks[i] then
      return rankInfo.coin <= self.wallet.coin and rankInfo.influence <= self.wallet.influence and rankInfo.playerLevel <= self.wallet.playerLevel and rankInfo.azothPrice <= self.wallet.azoth
    end
    if self.currentShop.ranks[i].isLocked then
      return false
    end
  end
end
function OWGuildShop:OnItemBuyButton(shopItemElement)
  local alternateCostIconPath = self.battleTokenIconPath
  local isSiegeArmoryProgression = self.guildCRC == 1175253129
  if shopItemElement.shopItemData.itemPrice > 0 then
    local itemPriceData = StaticItemDataManager:GetItem(shopItemElement.shopItemData.itemPriceId)
    alternateCostIconPath = "lyshineui/images/icons/items/" .. itemPriceData.itemType .. "/" .. itemPriceData.icon .. ".dds"
  end
  self.GuildShopConfirmPopup:ConfirmPurchase(shopItemElement.shopItemData, self.wallet, self.OnPurchaseConfirmed, self, isSiegeArmoryProgression, alternateCostIconPath)
end
function OWGuildShop:OnPurchaseConfirmed(availableItem, quantity)
  local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  local isAtItemCapacity = ContainerRequestBus.Event.IsAtItemCapacity(inventoryId)
  if isAtItemCapacity then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_inventoryfull"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  ObjectiveInteractorRequestBus.Broadcast.RequestPurchaseItem(availableItem.conversionID, quantity)
  if self.useItemForInfluence then
    DynamicBus.OutpostRush.Broadcast.RegisterPurchase()
  end
  local totalCost = availableItem.influence * quantity
  self.wallet.influence = self.wallet.influence - totalCost
  self:UpdateWallet()
  local totalQuantity = availableItem.itemDescriptor.quantity * quantity
  if totalQuantity == 1 then
    self:ShowBanner(LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_single_item_purchased", availableItem.itemDescriptor:GetDisplayName()))
  else
    self:ShowBanner(GetLocalizedReplacementText("@owg_multiple_items_purchased", {
      itemName = availableItem.itemDescriptor:GetDisplayName(),
      amount = totalQuantity
    }))
  end
  DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation(nil, 1)
end
function OWGuildShop:UnlockRank()
  ObjectiveInteractorRequestBus.Broadcast.RequestPurchaseRankIncrease(self.guildCRC)
end
function OWGuildShop:OnRankVisibilityChanged(rankIndex, forceSelect)
  if not self.currentShop then
    return
  end
  if not forceSelect then
    local rankData = self.GuildShopItemList:GetTopHeaderData()
    if rankData then
      rankIndex = rankData.rank
    end
  end
  for i = 1, #self.currentShop.ranks do
    local rankElement = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.ShopLevelContainer, i - 1))
    rankElement:SetRankVisible(i - 1 == rankIndex)
  end
  DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
end
function OWGuildShop:OnCategoricalProgressionPointsChanged(guildCRC, oldPoints, newPoints)
  local influenceCRC = self.guildTokensCRC == 0 and self.guildCRC or self.guildTokensCRC
  if guildCRC == influenceCRC and not self.useItemForInfluence then
    self.wallet.influence = newPoints
    self:UpdateWallet()
  end
end
function OWGuildShop:OnCategoricalProgressionRankChanged(guildCRC, oldRank, newRank)
  if guildCRC == self.guildCRC then
    local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    local rankName = self.factionInfoTable[faction].rankNames[newRank + 1]
    self:ShowBanner(LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_rank_unlocked", rankName))
    for i = oldRank + 1, newRank do
      local shopRank = self.currentShop.rankToRankInfo[i]
      shopRank.isLocked = false
      self.GuildShopItemList:RequestRefreshContent()
    end
  end
end
function OWGuildShop:GetWallet()
  return self.wallet
end
return OWGuildShop

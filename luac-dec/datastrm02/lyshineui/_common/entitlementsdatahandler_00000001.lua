local EntitlementsDataHandler = {
  cachedProductsPerKey = {},
  cachedRewardKeys = {},
  entitlementProductCallbacks = {},
  catalogCallbacks = {},
  cachedEntitlementDisplayInfo = {},
  SIZE_VALUES = {
    S = 1,
    M = 2,
    L = 4,
    X = 8
  },
  MTX_SOURCE_TYPE_STORE = "Store",
  MTX_SOURCE_TYPE_TWITCH = "Twitch",
  MTX_SOURCE_TYPE_PRIME = "Prime",
  MTX_SOURCE_TYPE_PREORDER = "Preorder"
}
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local jsonParser = RequireScript("LyShineUI.json")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function EntitlementsDataHandler:OnActivate()
  if not self.entitlementsDataNotificationHandler then
    self.entitlementsDataNotificationHandler = EntitlementNotificationBus.Connect(self)
  end
end
function EntitlementsDataHandler:OnDeactivate()
  self:ClearProductsCache()
  ClearTable(self.catalogCallbacks)
end
function EntitlementsDataHandler:ClearProductsCache()
  self.products = nil
  ClearTable(self.cachedProductsPerKey)
end
function EntitlementsDataHandler:Reset()
  self:OnDeactivate()
end
function EntitlementsDataHandler:GetCatalog(cbContext, cb)
  table.insert(self.catalogCallbacks, {context = cbContext, cb = cb})
  EntitlementRequestBus.Broadcast.FetchCatalog()
end
function EntitlementsDataHandler:GetPlayerTitleById(titleId)
  local titleData = JavSocialComponentBus.Broadcast.GetTitleData(titleId)
  return {
    text = titleData.title,
    titleId = titleId
  }
end
function EntitlementsDataHandler:GetProductTypeText(rewards)
  local productType = ""
  for i, reward in ipairs(rewards) do
    local rewardDisplayInfo = EntitlementsDataHandler:GetRewardDisplayInfo(reward)
    local type = rewardDisplayInfo.typeString
    if string.len(productType) == 0 then
      productType = type
    elseif productType ~= type then
      productType = "@ui_bundle"
    end
  end
  return productType
end
function EntitlementsDataHandler:GetProductTypeTooltipText(rewards)
  local productType = ""
  for i, reward in ipairs(rewards) do
    local rewardDisplayInfo = EntitlementsDataHandler:GetRewardDisplayInfo(reward)
    local type = rewardDisplayInfo.typeTooltipString
    if string.len(productType) == 0 then
      productType = type
    elseif productType ~= type then
      productType = "@ui_bundle"
    end
  end
  return productType
end
function EntitlementsDataHandler:GetProductTypeIcon(rewards)
  local productType = ""
  for i, reward in ipairs(rewards) do
    local rewardDisplayInfo = EntitlementsDataHandler:GetRewardDisplayInfo(reward)
    local type = rewardDisplayInfo.typeIcon
    if string.len(productType) == 0 then
      productType = type
    elseif productType ~= type then
      productType = "lyshineui/mtx/reward_type_bundle.dds"
    end
  end
  return productType
end
function EntitlementsDataHandler:GetRewardsForOffer(offer)
  if not self.rewardsForProductMap then
    self.rewardsForProductMap = {}
  end
  local rewards = {}
  for eidx, entitlement in ipairs(offer.entitlements) do
    local entitlementIds = {
      entitlement.entitlementId
    }
    local amount = entitlement.amount
    local cursor = 1
    while cursor <= #entitlementIds do
      local entitlementData = EntitlementRequestBus.Broadcast.GetEntitlementData(entitlementIds[cursor])
      if entitlementData then
        for i = 1, #entitlementData.rewards do
          if entitlementData.rewardType == eRewardTypeEntitlement then
            table.insert(entitlementIds, entitlementData.rewards[i])
          else
            local reward = {
              rewardType = entitlementData.rewardType,
              rewardId = entitlementData.rewards[i],
              storeTab = eStoreTabBundles,
              searchText = "",
              amount = amount,
              bonusAmount = entitlement.bonusAmount or 0,
              isConsumable = entitlementData.isConsumable
            }
            if reward.rewardType == eRewardTypeEmote then
              reward.storeTab = reward.isConsumable and eStoreTabConsumables or eStoreTabEmotes
            end
            if reward.rewardType == eRewardTypeInventoryItem then
              reward.storeTab = eStoreTabConsumables
            end
            if reward.rewardType == eRewardTypeItemDye then
              reward.storeTab = eStoreTabConsumables
            end
            if reward.rewardType == eRewardTypeItemSkin then
              local itemSkinData = ItemSkinData()
              if ItemSkinDataManagerBus.Broadcast.GetItemSkinDataFromId(reward.rewardId, itemSkinData) then
                local itemDescriptor = ItemDescriptor()
                itemDescriptor.itemId = itemSkinData.toItemId
                if itemDescriptor:HasItemClass(eItemClass_EquippableMainHand) or itemDescriptor:HasItemClass(eItemClass_EquippableTwoHand) or itemDescriptor:HasItemClass(eItemClass_EquippableOffHand) then
                  reward.storeTab = eStoreTabWeaponSkins
                else
                  reward.storeTab = eStoreTabArmorSkins
                end
              end
            end
            if reward.rewardType == eRewardTypeGuildBackgroundColor or reward.rewardType == eRewardTypeGuildCrest or reward.rewardType == eRewardTypeGuildForegroundColor then
              reward.storeTab = eStoreTabGuildCrestsAndColors
            end
            if reward.rewardType == eRewardTypeHousingItem then
              reward.storeTab = eStoreTabHousingItems
            end
            local displayInfo = self:GetEntitlementDisplayInfo(reward.rewardType, reward.rewardId)
            reward.unlocalizedSearchText = displayInfo.itemDescription
            table.insert(rewards, reward)
          end
        end
      end
      cursor = cursor + 1
    end
  end
  if offer.offerId then
    self.rewardsForProductMap[offer.offerId] = rewards
  end
  return rewards
end
function EntitlementsDataHandler:ConvertOfferToTable(offer)
  local offerTable = {
    offerIdText = offer.offerId,
    productIdText = offer.omniProductId,
    offerId = Math.CreateCrc32(offer.offerId),
    productId = Math.CreateCrc32(offer.productId),
    entitlements = {},
    discountStartDate = offer.discountStartDate,
    discountStart = offer.discountStart,
    discountEndDate = offer.discountEndDate,
    discountExpiration = offer.discountExpiration,
    productStartDate = offer.productStartDate,
    productStart = offer.productStart,
    productEndDate = offer.productEndDate,
    productExpiration = offer.productExpiration,
    description = offer.description,
    isStandalone = offer.isStandalone,
    bonusAmount = 0
  }
  local metadataText = offer.metadata
  if type(metadataText) == "string" and 0 < string.len(metadataText) then
    offerTable.metadata = jsonParser.decode(metadataText)
    offerTable.featuredStatus = offerTable.metadata.featuredStatus
    offerTable.bonusAmount = offerTable.metadata.bonusAmount or 0
  end
  offerTable.discountExpirationValid = 0 < offerTable.discountExpiration:GetTimeSinceEpoc():ToSeconds()
  offerTable.discountStartValid = 0 < offerTable.discountStart:GetTimeSinceEpoc():ToSeconds()
  offerTable.productExpirationValid = 0 < offerTable.productExpiration:GetTimeSinceEpoc():ToSeconds()
  offerTable.productStartValid = 0 < offerTable.productStart:GetTimeSinceEpoc():ToSeconds()
  if offerTable.featuredStatus and string.len(offerTable.featuredStatus) >= 2 then
    local featuredSize = self.SIZE_VALUES[string.sub(offerTable.featuredStatus, 1, 1)]
    if featuredSize then
      offerTable.featuredSize = featuredSize
      offerTable.featuredPriority = tonumber(string.sub(offerTable.featuredStatus, 2))
    end
  end
  offerTable.productData = EntitlementRequestBus.Broadcast.GetStoreProductData(Math.CreateCrc32(offer.productId))
  if offer.hasFictionalPrice then
    offerTable.isFictional = true
    offerTable.countryCode = ""
    offerTable.currencyCode = offer.fictionalCurrencyPrices[1].currencyEntitlementAlias
    offerTable.originalPrice = offer.fictionalCurrencyPrices[1].originalPrice
    offerTable.finalPrice = offer.fictionalCurrencyPrices[1].salesPrice
    offerTable.discountPercent = offer.fictionalCurrencyPrices[1].discountPercent
  else
    offerTable.isFictional = false
    offerTable.countryCode = offer.price.countryCode
    offerTable.currencyCode = offer.price.currencyCode
    offerTable.originalPrice = offer.price.originalPrice
    offerTable.finalPrice = offer.price.salesPrice
    offerTable.discountPercent = offer.price.discountPercent
  end
  function offerTable.GetActualPrice(t)
    if t.finalPrice or t.discountStartValid or t.discountExpirationValid then
      local now = TimeHelpers:ServerNow()
      if t.discountStartValid and now < t.discountStart then
        return t.originalPrice
      end
      if t.discountExpirationValid and now > t.discountExpiration then
        return t.originalPrice
      end
      return t.finalPrice
    end
    return t.originalPrice
  end
  for i = 1, #offer.entitlements do
    local entitlement = offer.entitlements[i]
    local entitlementId = Math.CreateCrc32(entitlement.alias)
    local entitlementData = EntitlementRequestBus.Broadcast.GetEntitlementData(entitlementId)
    table.insert(offerTable.entitlements, {
      omniEntitlementId = entitlement.id,
      amount = entitlement.amount,
      bonusAmount = offerTable.bonusAmount,
      entitlementId = entitlementId,
      isConsumable = entitlementData and entitlementData.isConsumable or false
    })
  end
  return offerTable
end
function EntitlementsDataHandler:OnCatalogReady(catalog)
  local catalogOut = {}
  local now = TimeHelpers:ServerNow()
  local includeDisabledProducts = ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiShowAllOmniProducts")
  for i = 1, #catalog do
    local offer = self:ConvertOfferToTable(catalog[i])
    local productEnabled = offer.productData.isEnabled or includeDisabledProducts
    local isExpired = offer.productExpirationValid and now > offer.productExpiration
    if productEnabled and not isExpired and offer.isStandalone then
      table.insert(catalogOut, self:ConvertOfferToTable(catalog[i]))
    end
  end
  for k, catalogCallback in ipairs(self.catalogCallbacks) do
    catalogCallback.cb(catalogCallback.context, catalogOut)
  end
  ClearTable(self.catalogCallbacks)
end
function EntitlementsDataHandler:OnEntitlementError(transactionId, error)
  Log("ERROR: EntitlementsDataHandler:OnEntitlementError, transactionId: %s, error: %s", tostring(transactionId), error)
end
function EntitlementsDataHandler:OnEntitlementsChange()
  if self.onChangeCallbacks then
    local toRemove = {}
    for i = #self.onChangeCallbacks, 1, -1 do
      local onChangeCallback = self.onChangeCallbacks[i]
      onChangeCallback.callback(onChangeCallback.callbackSelf)
      if onChangeCallback.removeOnCall then
        table.remove(self.onChangeCallbacks, i)
      end
    end
  end
end
function EntitlementsDataHandler:GetAllEntitlementsForEntitlements(entitlements)
  local all = {}
  local newEntitlements = {}
  for i = 1, #entitlements do
    table.insert(newEntitlements, entitlements[i])
  end
  local cursor = 1
  while cursor <= #newEntitlements do
    all[newEntitlements[cursor]] = newEntitlements[cursor]
    local nextLevel = EntitlementRequestBus.Broadcast.GetEntitlementsForEntryIdOfRewardType(eRewardTypeEntitlement, newEntitlements[cursor])
    for i = 1, #nextLevel do
      if not all[nextLevel[i]] then
        table.insert(newEntitlements, nextLevel[i])
      end
    end
    cursor = cursor + 1
  end
  return all
end
function EntitlementsDataHandler:GetAllEntitlementsForRewardTypeAndKey(rewardType, key)
  local entitlements = EntitlementRequestBus.Broadcast.GetEntitlementsForEntryIdOfRewardType(rewardType, key)
  return self:GetAllEntitlementsForEntitlements(entitlements)
end
function EntitlementsDataHandler:FilterRelevantProducts(products, entitlementKeys)
  local productSet = {}
  for j, v in pairs(entitlementKeys) do
    if products[v] then
      local entitlementData = EntitlementRequestBus.Broadcast.GetEntitlementData(v)
      productSet[v] = {
        entitlementData = entitlementData,
        productData = products[v]
      }
    end
  end
  local products = {}
  for k, v in pairs(productSet) do
    table.insert(products, v)
  end
  return products
end
function EntitlementsDataHandler:GetFeaturedProduct(context, cb)
  cb(context, nil)
end
function EntitlementsDataHandler:GetGrantorForRewardTypeAndKey(rewardType, rewardKey)
  if not self.cachedEntitlementGrantors then
    self.cachedEntitlementGrantors = {}
  end
  if not self.cachedEntitlementGrantors[rewardType] then
    self.cachedEntitlementGrantors[rewardType] = {}
  end
  local grantors = self.cachedEntitlementGrantors[rewardType][rewardKey]
  if not grantors then
    grantors = {}
    self.cachedEntitlementGrantors[rewardType][rewardKey] = grantors
    local all = self:GetAllEntitlementsForRewardTypeAndKey(rewardType, rewardKey)
    for _, entitlementId in pairs(all) do
      local data = EntitlementRequestBus.Broadcast.GetEntitlementData(entitlementId)
      if string.len(data.entitlementInfo) > 0 or 0 < string.len(data.icon) or 0 < string.len(data.sourceType) then
        table.insert(grantors, {
          entitlementId = entitlementId,
          icon = data.icon,
          name = data.entitlementInfo,
          sourceType = data.sourceType
        })
      end
    end
  end
  local info = {}
  for _, grantor in ipairs(grantors) do
    info.grantor = grantor
    if 0 < EntitlementRequestBus.Broadcast.GetEntitlementBalance(grantor.entitlementId) then
      info.isEntitled = true
      break
    end
  end
  return info
end
function EntitlementsDataHandler:GetAllRewardGrantsOfType(rewardType)
  if self.cachedRewardKeys[rewardType] then
    return self.cachedRewardKeys[rewardType]
  end
  local rewards = vector_Crc32()
  EntitlementRequestBus.Broadcast.GetAllRewardsOfType(rewardType, rewards)
  local rewardGrants = {}
  for i = 1, #rewards do
    local rewardGrant = {
      rewardKey = rewards[i],
      entitlements = {}
    }
    local all = self:GetAllEntitlementsForRewardTypeAndKey(rewardType, rewards[i])
    for j, entitlement in pairs(all) do
      local data = EntitlementRequestBus.Broadcast.GetEntitlementData(entitlement)
      if string.len(data.entitlementInfo) > 0 then
        rewardGrant.entitlements[entitlement] = data
      end
    end
    table.insert(rewardGrants, rewardGrant)
  end
  self.cachedRewardKeys[rewardType] = rewardGrants
  return rewardGrants
end
function EntitlementsDataHandler:GetRewardDisplayInfo(reward)
  return self:GetEntitlementDisplayInfo(reward.rewardType, reward.rewardId)
end
function EntitlementsDataHandler:BuildEntitledCrestPartsMap()
  if self.entitledCrestParts then
    return
  end
  self.entitledCrestParts = {}
  local countNode = dataLayer:Call(926587304)
  local count = 0
  if countNode then
    count = countNode:GetData()
  end
  local white = ColorRgba(255, 255, 255, 1)
  for i = 1, count do
    local crestPartNode = dataLayer:Call(2985482927, i)
    if crestPartNode then
      local crestPart = crestPartNode:GetData()
      if crestPart and 0 < string.len(crestPart.entitlementId) then
        local rewardKey = Math.CreateCrc32(crestPart.entitlementId)
        local isImage = 0 < string.len(crestPart.image)
        self.entitledCrestParts[rewardKey] = {
          isImage = isImage,
          image = isImage and crestPart.image or "LyShineUI/Images/Icons/GuildMenu/overview.dds",
          color = isImage and white or crestPart.color,
          displayName = crestPart.displayName
        }
      end
    end
  end
end
function EntitlementsDataHandler:GetEntitlementDisplayInfo(rewardType, rewardId)
  if rewardType and not self.cachedEntitlementDisplayInfo[rewardType] then
    self.cachedEntitlementDisplayInfo[rewardType] = {}
  end
  if self.cachedEntitlementDisplayInfo[rewardType][rewardId] then
    return self.cachedEntitlementDisplayInfo[rewardType][rewardId]
  end
  local displayInfo = {}
  local rewardTypeStrings = {
    "@reward_type_emote",
    "@reward_type_itemskin",
    "@reward_type_itemdye",
    "@reward_type_guildcrest",
    "@reward_type_guildcrest_fg",
    "@reward_type_guildcrest_bg",
    "@reward_type_housing_item",
    "@reward_type_player_title",
    "@reward_type_inventory_item",
    "@reward_type_extra",
    "@reward_type_marks_of_fortune",
    "@reward_type_entitlement"
  }
  local rewardTypeIcons = {
    "lyshineui/images/mtx/reward_type_emote.dds",
    "lyshineui/images/mtx/reward_type_itemskin.dds",
    "lyshineui/images/mtx/reward_type_itemdye.dds",
    "lyshineui/images/mtx/reward_type_guildcrest.dds",
    "lyshineui/images/mtx/reward_type_guildcrest.dds",
    "lyshineui/images/mtx/reward_type_guildcrest.dds",
    "lyshineui/images/mtx/reward_type_housing_item.dds",
    "lyshineui/images/mtx/reward_type_player_title.dds",
    "lyshineui/images/mtx/reward_type_inventory_item.dds",
    "lyshineui/images/mtx/reward_type_extra.dds",
    "lyshineui/images/mtx/reward_type_extra.dds",
    "lyshineui/images/mtx/reward_type_entitlement.dds"
  }
  local emoteTooltiptext = GetLocalizedReplacementText("@reward_type_tooltip_emote", {
    hintText = LyShineManagerBus.Broadcast.GetKeybind("toggleEmoteWindow", "ui")
  })
  local rewardTypeTooltipStrings = {
    emoteTooltiptext,
    "@reward_type_tooltip_itemskin",
    "@reward_type_tooltip_itemdye",
    "@reward_type_tooltip_guildcrest",
    "@reward_type_tooltip_guildcrest",
    "@reward_type_tooltip_guildcrest",
    "@reward_type_tooltip_housing_item",
    "@reward_type_tooltip_player_title",
    "@reward_type_tooltip_inventory_item",
    "@reward_type_tooltip_extra",
    "@reward_type_tooltip_marks_of_fortune",
    "@reward_type_tooltip_entitlement"
  }
  displayInfo.typeString = rewardTypeStrings[rewardType] or "?"
  displayInfo.typeIcon = rewardTypeIcons[rewardType] or "?"
  displayInfo.typeTooltipString = rewardTypeTooltipStrings[rewardType] or "?"
  displayInfo.spritePath = "LyShineUI/Images/Map/Icon/Gatherables/gold_compass.dds"
  displayInfo.spriteColor = ColorRgba(255, 255, 255, 1)
  displayInfo.itemDescription = rewardId
  displayInfo.isValid = false
  displayInfo.tooltip = ""
  local itemId
  if rewardType == eRewardTypeHousingItem then
    itemId = rewardId
    displayInfo.tooltip = "@reward_type_tooltip_housing_item"
  elseif rewardType == eRewardTypeInventoryItem then
    itemId = rewardId
    displayInfo.tooltip = "@reward_type_tooltip_inventory_item"
  elseif rewardType == eRewardTypeItemSkin then
    local itemSkinData = ItemSkinData()
    if ItemSkinDataManagerBus.Broadcast.GetItemSkinDataFromId(rewardId, itemSkinData) then
      itemId = itemSkinData.toItemId
    end
    displayInfo.tooltip = "@reward_type_tooltip_itemskin"
  elseif rewardType == eRewardTypeItemDye then
    itemId = rewardId
    displayInfo.isValid = true
    displayInfo.tooltip = "@reward_type_tooltip_itemdye"
  elseif rewardType == eRewardTypeEmote then
    local emoteData = EmoteDataManagerBus.Broadcast.GetEmoteDataById(rewardId)
    if emoteData and emoteData.isValid then
      if string.len(emoteData.uiImage) > 0 then
        displayInfo.spritePath = "lyShineui/images/icons/emotes/" .. emoteData.uiImage
      else
        displayInfo.spritePath = "lyShineui/images/icons/emotes/emote_Unknown.dds"
      end
      displayInfo.spritePathHiRes = emoteData.uiImageHiRes
      displayInfo.itemDescription = emoteData.displayName
      if string.len(displayInfo.itemDescription) == 0 then
        displayInfo.itemDescription = emoteData.slashCommand
      end
      displayInfo.isValid = true
    end
    displayInfo.tooltip = emoteTooltiptext
  elseif rewardType == eRewardTypeGuildCrest or rewardType == eRewardTypeGuildBackgroundColor or rewardType == eRewardTypeGuildForegroundColor then
    self:BuildEntitledCrestPartsMap()
    local crestPart = self.entitledCrestParts[rewardId]
    if crestPart then
      displayInfo.spritePathHiRes = crestPart.image
      displayInfo.spritePath = crestPart.image
      displayInfo.secondarySpritePath = crestPart.image
      displayInfo.itemDescription = crestPart.displayName
      displayInfo.isValid = true
      displayInfo.spriteColor = crestPart.color
    end
    displayInfo.tooltip = "@reward_type_tooltip_guildcrest"
  elseif rewardType == eRewardTypePlayerTitle then
    displayInfo.spritePath = "lyshineui/images/entitlements/newtitleicon.dds"
    local playerTitleReward = self:GetPlayerTitleById(rewardId)
    displayInfo.itemDescription = playerTitleReward.text
    displayInfo.isValid = playerTitleReward.titleId ~= 0
    displayInfo.tooltip = "@reward_type_tooltip_player_title"
  elseif rewardType == eRewardTypeMisc then
    displayInfo.itemDescription = "@art_book"
    displayInfo.spritePath = "LyShineUI/Images/Entitlements/NW_Artbook.dds"
    displayInfo.isValid = true
    displayInfo.tooltip = "@reward_type_tooltip_extra"
  end
  if itemId then
    local staticItem = StaticItemDataManager:GetItem(itemId)
    if staticItem then
      displayInfo.spritePath = "LyShineUI\\Images\\Icons\\Items\\" .. staticItem.itemType .. "\\" .. staticItem.icon .. ".dds"
      displayInfo.hiresSpritePath = "LyShineUI\\Images\\Icons\\Items_hires\\" .. staticItem.icon .. ".dds"
      displayInfo.itemDescription = staticItem.displayName
      displayInfo.isValid = true
      if rewardType == eRewardTypeItemSkin then
        local itemDescriptor = ItemDescriptor()
        itemDescriptor.itemId = itemId
        if itemDescriptor:HasItemClass(eItemClass_EquippableMainHand) or itemDescriptor:HasItemClass(eItemClass_EquippableTwoHand) or itemDescriptor:HasItemClass(eItemClass_EquippableOffHand) then
          displayInfo.typeString = "@reward_type_weaponskin"
        else
          displayInfo.typeString = "@reward_type_armorskin"
        end
      end
    end
  end
  if not displayInfo.spritePathHiRes or string.len(displayInfo.spritePathHiRes) == 0 then
    displayInfo.spritePathHiRes = displayInfo.spritePath
  end
  self.cachedEntitlementDisplayInfo[rewardType][rewardId] = displayInfo
  return displayInfo
end
function EntitlementsDataHandler:IsStoreEnabled()
  local disabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.red-button-disable-MTX-store")
  if disabled then
    local title = "@ui_disabled_default_title"
    local confirmation = "@ui_disabled_default_description"
    PopupWrapper:RequestPopup(ePopupButtons_OK, title, confirmation, "disabledMTXPopup", self, function(self, result, eventId)
    end)
    return false
  end
  return true
end
function EntitlementsDataHandler:IsRealWorldCurrencyPurchasingEnabled()
  local disabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.red-button-disable-spending-real-world-currency")
  if disabled then
    local title = "@ui_disabled_default_title"
    local confirmation = "@ui_disabled_default_description"
    PopupWrapper:RequestPopup(ePopupButtons_OK, title, confirmation, "disabledMTXPopup", self, function(self, result, eventId)
    end)
    return false
  end
  return true
end
function EntitlementsDataHandler:IsFictionalCurrencyPurchasingEnabled()
  local disabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.red-button-disable-spending-fictional-currency")
  if disabled then
    local title = "@ui_disabled_default_title"
    local confirmation = "@ui_disabled_default_description"
    PopupWrapper:RequestPopup(ePopupButtons_OK, title, confirmation, "disabledMTXPopup", self, function(self, result, eventId)
    end)
    return false
  end
  return true
end
function EntitlementsDataHandler:GetCharacterSlotEntitlementData()
  local isSlotPurchaseEnabled = dataLayer:GetDataFromNode("UIFeatures.enableCharacterSlotPurchase")
  if not isSlotPurchaseEnabled then
    return {numAvailable = 0, numEntitled = 0}
  end
  local numAvailable = 0
  local numEntitled = 0
  local rawEntitlementIds = ConfigProviderEventBus.Broadcast.GetString("javelin.additional-character-slot-aliases")
  for idStr in string.gmatch(rawEntitlementIds, "([^,]+)") do
    local idCrc = Math.CreateCrc32(idStr)
    local isEntitled = EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeEntitlement, idCrc)
    numAvailable = numAvailable + 1
    if isEntitled then
      numEntitled = numEntitled + 1
    end
  end
  return {numAvailable = numAvailable, numEntitled = numEntitled}
end
function EntitlementsDataHandler:StartCharacterSlotPurchase(onPurchaseCompleteCaller, onPurchaseCompleteCb)
  local isSlotPurchaseEnabled = dataLayer:GetDataFromNode("UIFeatures.enableCharacterSlotPurchase")
  if not isSlotPurchaseEnabled then
    return
  end
  if onPurchaseCompleteCaller then
    self:AddOnEntitlementChangedCallback(onPurchaseCompleteCaller, onPurchaseCompleteCb, true)
  end
  local rawEntitlementIds = ConfigProviderEventBus.Broadcast.GetString("javelin.additional-character-slot-aliases")
  for idStr in string.gmatch(rawEntitlementIds, "([^,]+)") do
    local idCrc = Math.CreateCrc32(idStr)
    local isEntitled = EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeEntitlement, idCrc)
    if not isEntitled then
      GameRequestsBus.Broadcast.OpenSteamStoreOverlay(idStr)
      return
    end
  end
  Debug.Log("Warning: failed to find character slot id to purchase")
end
function EntitlementsDataHandler:AddOnEntitlementChangedCallback(callbackOwner, callbackFunction, autoRemove)
  if not self.onChangeCallbacks then
    self.onChangeCallbacks = {}
  end
  table.insert(self.onChangeCallbacks, {
    callback = callbackFunction,
    callbackSelf = callbackOwner,
    removeOnCall = autoRemove
  })
end
function EntitlementsDataHandler:RemoveOnEntitlementChangedCallback(callbackOwner)
  if self.onChangeCallbacks then
    for i = #self.onChangeCallbacks, 1, -1 do
      local onChangeCallback = self.onChangeCallbacks[i]
      if onChangeCallback.callbackSelf == callbackOwner then
        table.remove(self.onChangeCallbacks, i)
      end
    end
  end
end
return EntitlementsDataHandler

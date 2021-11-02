local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OmniDataHandler = {
  entitlementsCache = {},
  FICTIONAL_CURRENCY_ENTITLEMENT_ID = 82978994,
  FICTIONAL_CURRENCY_ENTITLEMENT_ALIAS = "Marks of Fortune",
  FEATURED_DEALS_BUDGET = 8
}
function GetFutureTime(minutes)
  local duration = Duration.FromMinutesUnrounded(minutes)
  return WallClockTimePoint:Now():AddDuration(duration)
end
function OmniDataHandler:GetOmniOffers(context, cb)
  EntitlementsDataHandler:GetCatalog(context, cb)
end
function OmniDataHandler:GetEntitlementBalance(entitlementId)
  return EntitlementRequestBus.Broadcast.GetEntitlementBalance(entitlementId)
end
function OmniDataHandler:GetBalanceForRewardTypeAndKey(rewardType, rewardKey)
  local entitlements = EntitlementsDataHandler:GetAllEntitlementsForRewardTypeAndKey(rewardType, rewardKey)
  local balance = 0
  for i, entitlement in pairs(entitlements) do
    balance = balance + self:GetEntitlementBalance(entitlement)
  end
  return balance
end
function OmniDataHandler:GetRealMoneyOffers(context, cb)
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.red-button-disable-spending-real-world-currency") then
    cb(context, {})
    return
  end
  self:GetOmniOffers(self, function(self, offers)
    local tabOffers = {}
    for i, offer in ipairs(offers) do
      if not offer.isFictional then
        local rewards = EntitlementsDataHandler:GetRewardsForOffer(offer)
        for _, reward in ipairs(rewards) do
          if reward.rewardType == eRewardTypeFictionalCurrency then
            table.insert(tabOffers, {offer = offer})
            break
          end
        end
      end
    end
    cb(context, tabOffers)
  end)
end
function OmniDataHandler:GetOmniOffersByFilter(tabOrFilter, context, cb, cbNoCatalog)
  local request = {filter = tabOrFilter, completed = false}
  self:GetOmniOffers(self, function(self, offers)
    self.catalogOffers = offers
    local tabOffers = {}
    local language = LyShineScriptBindRequestBus.Broadcast.GetLanguage()
    local forceLocalize = language ~= self.language
    if #offers == 0 then
      cbNoCatalog(context)
      request.completed = true
      return
    end
    for i, offer in ipairs(offers) do
      local offerAdded = false
      local rewards = EntitlementsDataHandler:GetRewardsForOffer(offer)
      if 1 < #rewards or offer.isFictional then
        for _, reward in ipairs(rewards) do
          if type(request.filter) == "number" then
            if reward.storeTab == request.filter or request.filter == eStoreTabFeaturedDeals and offer.featuredSize or request.filter == eStoreTabBundles and 1 < #rewards then
              table.insert(tabOffers, {offer = offer})
              break
            end
          else
            if not reward.searchText or reward.searchText == "" or forceLocalize then
              reward.searchText = string.lower(LyShineScriptBindRequestBus.Broadcast.LocalizeText(offer.productData.displayName)) .. " " .. string.lower(LyShineScriptBindRequestBus.Broadcast.LocalizeText(reward.unlocalizedSearchText))
            end
            if string.find(reward.searchText, request.filter) then
              if not offerAdded then
                table.insert(tabOffers, {offer = offer})
                offerAdded = true
              end
              if not forceLocalize then
                break
              end
            end
          end
        end
      end
    end
    if type(request.filter) == "string" then
      self.language = language
    elseif request.filter == eStoreTabFeaturedDeals then
      table.sort(tabOffers, function(a, b)
        if a.offer.featuredSize > b.offer.featuredSize then
          return true
        elseif a.offer.featuredSize == b.offer.featuredSize then
          return a.offer.featuredPriority < b.offer.featuredPriority
        end
        return false
      end)
      local newTabOffers = {}
      local sizeAmount = 0
      for i, offer in ipairs(tabOffers) do
        sizeAmount = sizeAmount + offer.offer.featuredSize
        if sizeAmount <= self.FEATURED_DEALS_BUDGET then
          table.insert(newTabOffers, offer)
        else
          break
        end
      end
      tabOffers = newTabOffers
    end
    cb(context, tabOffers)
    request.completed = true
  end)
  return request
end
function OmniDataHandler:SearchOffersForRewardTypeAndKey(offers, rewardType, rewardKey)
  local matchingOffers = {}
  local storeDisabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.red-button-disable-MTX-store")
  if FtueSystemRequestBus.Broadcast.IsFtue() or storeDisabled then
    return matchingOffers
  end
  local entitlementIds = EntitlementsDataHandler:GetAllEntitlementsForRewardTypeAndKey(rewardType, rewardKey)
  for i, offer in ipairs(offers) do
    for j, entitlement in ipairs(offer.entitlements) do
      if entitlementIds[entitlement.entitlementId] then
        table.insert(matchingOffers, offer)
        break
      end
    end
  end
  return matchingOffers
end
return OmniDataHandler

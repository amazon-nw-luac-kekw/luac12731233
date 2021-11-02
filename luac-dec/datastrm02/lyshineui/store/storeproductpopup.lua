local StoreProductPopup = {
  Properties = {
    StoreProductElement = {
      default = EntityId()
    },
    RewardsList = {
      default = EntityId()
    },
    RewardPrototype = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    ConfirmButton = {
      default = EntityId()
    },
    StartStopButton = {
      default = EntityId()
    },
    ItemPreview2dFrame = {
      default = EntityId()
    },
    HiRes2dItemImage = {
      default = EntityId()
    },
    InfoText = {
      default = EntityId()
    },
    QuestionMark = {
      default = EntityId()
    },
    SkinsWarning = {
      default = EntityId()
    },
    SkinsQuestionMark = {
      default = EntityId()
    }
  }
}
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(StoreProductPopup)
function StoreProductPopup:OnInit()
  BaseElement.OnInit(self)
  self.CancelButton:SetCallback(self.OnCancel, self)
  self.CancelButton:SetText("@ui_back")
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_HERO)
  self.ConfirmButton:SetEnabled(true)
  self.ConfirmButton:SetCallback(self.OnPurchase, self)
  self.RewardsList:Initialize(self.RewardPrototype)
  self.RewardsList:OnListDataSet(nil)
  self.StartStopButton:SetButtonStyle(self.StartStopButton.BUTTON_STYLE_CTA)
  self.StartStopButton:SetText("@ui_end_preview")
  self.StartStopButton:SetCallback(self.OnStartStop, self)
  SetTextStyle(self.Properties.InfoText, self.UIStyle.FONT_STYLE_STORE_ITEM_DESCRIPTION)
  SetTextStyle(self.Properties.SkinsWarning, self.UIStyle.FONT_STYLE_STORE_ITEM_DESCRIPTION)
  self.QuestionMark:SetButtonStyle(self.QuestionMark.BUTTON_STYLE_QUESTION_MARK)
  self.SkinsQuestionMark:SetButtonStyle(self.SkinsQuestionMark.BUTTON_STYLE_QUESTION_MARK)
  self.SkinsQuestionMark:SetTooltip("@ui_fixed_appearance_tooltip")
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.HiRes2dItemImage, 512)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.AccountLocked", function(self, locked)
    self.accountLocked = locked
  end)
  self.itemSkinRewardIdToSlot = {}
  self.cachedEquippedItemSkins = {}
end
function StoreProductPopup:OnShutdown()
end
function StoreProductPopup:OnPurchase()
  if self.accountLocked then
    UiPopupBus.Broadcast.ShowPopup(ePopupButtons_OK, "@ui_locked_account_title", "@ui_locked_account_description", "AccountLockedPopup")
    return
  end
  self.onPurchasePopup(self.context, self.StoreProductElement.storeProductData)
end
function StoreProductPopup:Invoke(storeProductData, context, onPurchasePopup, sessionId, origin)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemPreview2dFrame, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.StartStopButton, false)
  self.StoreProductElement:StyleFeaturedElementByType(nil, "Offer")
  self.StoreProductElement:SetStoreProductData(storeProductData, "Offer")
  self.context = context
  self.onPurchasePopup = onPurchasePopup
  local rewards = EntitlementsDataHandler:GetRewardsForOffer(storeProductData.offer)
  self.rewards = {}
  self.singleReward = #rewards == 1
  for i, reward in ipairs(rewards) do
    table.insert(self.rewards, {
      rewardInfo = reward,
      cbContext = self,
      cb = self.OnRewardClick,
      cbHoverBegin = self.OnRewardHoverBegin,
      cbHoverEnd = self.OnRewardHoverEnd,
      isSingleReward = self.singleReward
    })
  end
  local event = UiAnalyticsEvent("enter_product_page")
  event:AddAttribute("session_id", sessionId)
  event:AddAttribute("origin", origin)
  if self.singleReward then
    event:AddMetric("rewardType", self.rewards[1].rewardInfo.rewardType)
    event:AddAttribute("rewardKey", tostring(self.rewards[1].rewardInfo.rewardId))
  end
  if storeProductData.offer then
    event:AddAttribute("product-description", storeProductData.offer.description)
    event:AddAttribute("productId", storeProductData.offer.productIdText)
    event:AddAttribute("offerId", storeProductData.offer.offerIdText)
    event:AddMetric("initialPrice", storeProductData.offer.originalPrice)
    event:AddMetric("finalPrice", storeProductData.offer:GetActualPrice())
    event:AddAttribute("currency", storeProductData.offer.currencyCode)
  end
  event:Send()
  self:FillOutfits()
  self:SetIsEnabled(true)
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  self.emoteNotificationBus = self:BusConnect(EmoteControllerComponentNotificationBus, playerEntityId)
  if self.singleReward then
    UiTransformBus.Event.SetLocalPosition(self.Properties.RewardsList, Vector2(-14, 104))
  else
    UiTransformBus.Event.SetLocalPosition(self.Properties.RewardsList, Vector2(0, 288))
  end
  self.RewardsList:OnListDataSet(self.rewards)
  UiElementBus.Event.SetIsEnabled(self.Properties.ConfirmButton, true)
  if storeProductData.canUnlock then
    if self.singleReward then
      local productType = EntitlementsDataHandler:GetProductTypeText(rewards)
      if productType == "@reward_type_service" then
        self.ConfirmButton:SetText("@server_transfer_select_world")
      else
        self.ConfirmButton:SetText("@ui_unlock")
      end
    else
      self.ConfirmButton:SetText("@ui_unlock_bundle")
    end
  elseif storeProductData.canPurchase then
    self.ConfirmButton:SetText("@ui_purchase")
  elseif storeProductData.comingSoon then
    self.ConfirmButton:SetText("@ui_mtx_coming_soon")
  elseif storeProductData.isUnlocked and storeProductData.hasDurables then
    UiElementBus.Event.SetIsEnabled(self.Properties.ConfirmButton, false)
  else
    self.ConfirmButton:SetText("@ui_get_credits")
  end
  self.ConfirmButton:SetEnabled(not storeProductData.comingSoon or storeProductData.canPurchase or storeProductData.canUnlock)
  self.showSkinWarning = false
  local infoText = "@ui_item_restrictions"
  local restrictionsString = self:GetItemRestrictionsString()
  if restrictionsString ~= "" then
    self.QuestionMark:SetTooltip(restrictionsString)
  end
  local questionMarkEnabled = restrictionsString ~= ""
  local infoTextEnabled = restrictionsString ~= ""
  if storeProductData.offer.metadata and storeProductData.offer.metadata.popupInfoOverride then
    questionMarkEnabled = false
    infoTextEnabled = true
    infoText = storeProductData.offer.metadata.popupInfoOverride
  end
  UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.InfoText, questionMarkEnabled)
  if not questionMarkEnabled then
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.InfoText, 509)
  end
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.InfoText, questionMarkEnabled and 28 or 52)
  UiTextBus.Event.SetTextWithFlags(self.Properties.InfoText, infoText, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.QuestionMark, questionMarkEnabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.InfoText, infoTextEnabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.SkinsWarning, self.showSkinWarning)
  self:OnRewardClick({
    itemData = self.rewards[1]
  })
end
function StoreProductPopup:GetItemRestrictionsString()
  local tooltipString = ""
  local rewardsByType = {}
  for i, reward in ipairs(self.rewards) do
    if not rewardsByType[reward.rewardInfo.rewardType] then
      rewardsByType[reward.rewardInfo.rewardType] = true
      if reward.rewardInfo.rewardType == eRewardTypeItemSkin then
        if tooltipString ~= "" then
          tooltipString = tooltipString .. [[


]]
        end
        tooltipString = tooltipString .. "@ui_item_restrictions_item_skins"
        self.showSkinWarning = true
      elseif reward.rewardInfo.rewardType == eRewardTypeGuildCrest then
        if tooltipString ~= "" then
          tooltipString = tooltipString .. [[


]]
        end
        tooltipString = tooltipString .. "@ui_item_restrictions_crests"
      elseif reward.rewardInfo.rewardType == eRewardTypeHousingItem then
        if tooltipString ~= "" then
          tooltipString = tooltipString .. [[


]]
        end
        tooltipString = tooltipString .. "@ui_item_restrictions_housing_items"
      elseif reward.rewardInfo.rewardType == eRewardTypeItemDye then
        if tooltipString ~= "" then
          tooltipString = tooltipString .. [[


]]
        end
        tooltipString = tooltipString .. "@ui_item_restrictions_dyes"
      elseif reward.rewardInfo.rewardType == eRewardTypeCampSkin then
        if tooltipString ~= "" then
          tooltipString = tooltipString .. [[


]]
        end
        tooltipString = tooltipString .. "@ui_item_restrictions_camp_skins"
      end
    end
  end
  return tooltipString
end
function StoreProductPopup:FillOutfits()
  self.outfits = {}
  self.outfitNames = {}
  self.itemSkinIdsToOutfits = {}
  for i, reward in ipairs(self.rewards) do
    if reward.rewardInfo.rewardType == eRewardTypeItemSkin then
      local itemSkinData = ItemSkinData()
      if ItemSkinDataManagerBus.Broadcast.GetItemSkinDataFromId(reward.rewardInfo.rewardId, itemSkinData) and string.len(itemSkinData.outfit) > 0 then
        local outfitData = self.outfits[itemSkinData.outfit]
        if not outfitData then
          table.insert(self.outfitNames, itemSkinData.outfit)
          outfitData = {
            name = itemSkinData.outfit,
            pieces = {}
          }
          self.outfits[itemSkinData.outfit] = outfitData
        end
        table.insert(outfitData.pieces, reward)
        self.itemSkinIdsToOutfits[reward.rewardInfo.rewardId] = outfitData
      end
    end
  end
end
function StoreProductPopup:OnRewardClick(rewardGridItem)
  for i, reward in ipairs(self.rewards) do
    reward.isSelected = false
  end
  self.emoteLocked = false
  self:ResetEquippedItemSkins()
  self.dataLayer:Call(1549315314)
  self.dataLayer:Call(3995983548)
  local clickedOnEmote = false
  if rewardGridItem.itemData.rewardInfo.rewardType == eRewardTypeItemSkin then
    local outfitData = self.itemSkinIdsToOutfits[rewardGridItem.itemData.rewardInfo.rewardId]
    if outfitData then
      for i, piece in ipairs(outfitData.pieces) do
        piece.isSelected = true
        self:ShowRewardPreview(piece)
      end
    else
      self:ShowRewardPreview(rewardGridItem.itemData)
    end
  elseif rewardGridItem.itemData.rewardInfo.rewardType == eRewardTypeEmote then
    rewardGridItem.itemData.isSelected = true
    self.emoteLocked = true
    self:ShowRewardPreview(rewardGridItem.itemData)
    clickedOnEmote = true
  else
    rewardGridItem.itemData.isSelected = true
    self:ShowRewardPreview(rewardGridItem.itemData)
  end
  if not clickedOnEmote and self.emotePlaying then
    LocalPlayerUIRequestsBus.Broadcast.StopEmoteLocalPreview()
  end
  self.RewardsList:RequestRefreshContent()
end
function StoreProductPopup:OnStartStop()
  if self.emotePlaying then
    LocalPlayerUIRequestsBus.Broadcast.StopEmoteLocalPreview()
  elseif self.emoteName then
    LocalPlayerUIRequestsBus.Broadcast.StopEmoteLocalPreview()
    LocalPlayerUIRequestsBus.Broadcast.StartEmoteLocalPreviewByName(self.emoteName)
  end
end
function StoreProductPopup:ShowSingleRewardTooltip(gridElement)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
    local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
    local reward = gridElement.itemData
    local displayInfo = EntitlementsDataHandler:GetEntitlementDisplayInfo(reward.rewardInfo.rewardType, reward.rewardInfo.rewardId)
    local rows = {}
    table.insert(rows, {
      slicePath = "LyShineUI/Tooltip/DynamicTooltip",
      itemTable = {
        displayName = displayInfo.itemDescription,
        spriteName = displayInfo.spritePath,
        spriteColor = displayInfo.spriteColor,
        itemTypeDisplayName = displayInfo.typeString
      },
      rewardType = reward.rewardInfo.rewardType,
      rewardKey = reward.rewardInfo.rewardId
    })
    flyoutMenu:SetOpenLocation(gridElement.entityId, flyoutMenu.PREFER_RIGHT)
    flyoutMenu:EnableFlyoutDelay(true, 0.5)
    flyoutMenu:SetFadeInTime(0.15)
    flyoutMenu:SetRowData(rows)
    flyoutMenu:DockToCursor(10)
  end
end
function StoreProductPopup:DisableEquippedItemSkin(paperdollSlotId)
  local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, paperdollSlotId)
  if slot and slot:IsValid() then
    local baseItemId = slot:GetItemId()
    local skinItemId = ItemSkinningRequestBus.Event.GetItemSkinItemId(playerEntityId, baseItemId)
    if skinItemId ~= 0 then
      table.insert(self.cachedEquippedItemSkins, {slotId = paperdollSlotId, itemId = skinItemId})
    end
    ItemSkinningRequestBus.Event.DisableItemSkin(playerEntityId, skinItemId)
  end
end
function StoreProductPopup:ResetEquippedItemSkins()
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
  for _, equippedSkinData in ipairs(self.cachedEquippedItemSkins) do
    local itemId = 0
    local paperdollSlot = PaperdollRequestBus.Event.GetSlot(paperdollId, equippedSkinData.slotId)
    if paperdollSlot and paperdollSlot:IsValid() then
      itemId = paperdollSlot:GetItemId()
    end
    ItemSkinningRequestBus.Event.EnableItemSkin(playerEntityId, itemId, equippedSkinData.itemId)
  end
  ClearTable(self.cachedEquippedItemSkins)
end
function StoreProductPopup:ShowRewardPreview(reward)
  if reward.rewardInfo.rewardType == eRewardTypeItemSkin then
    self:Hide2dPreview()
    local itemSkinData = ItemSkinData()
    if ItemSkinDataManagerBus.Broadcast.GetItemSkinDataFromId(reward.rewardInfo.rewardId, itemSkinData) then
      local itemDescriptor = ItemDescriptor()
      itemDescriptor.itemId = itemSkinData.toItemId
      local slotId = itemDescriptor:GetPaperdollSlot()
      if slotId == ePaperDollSlotTypes_MainHandOption1 or slotId == ePaperDollSlotTypes_MainHandOption2 then
        local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
        local activeWeaponSlotId = PaperdollRequestBus.Event.GetActiveSlot(paperdollId, ePaperdollSlotAlias_ActiveWeapon)
        slotId = activeWeaponSlotId
      end
      self.itemSkinRewardIdToSlot[reward.rewardInfo.rewardId] = slotId
      self.dataLayer:Call(2200389763, slotId, itemSkinData.toItemId)
      self:DisableEquippedItemSkin(slotId)
    end
  elseif reward.rewardInfo.rewardType == eRewardTypeEmote then
    self:Hide2dPreview()
    UiElementBus.Event.SetIsEnabled(self.Properties.StartStopButton, true)
    local emoteData = EmoteDataManagerBus.Broadcast.GetEmoteDataById(reward.rewardInfo.rewardId)
    self.emoteName = emoteData.displayName
    LocalPlayerUIRequestsBus.Broadcast.StopEmoteLocalPreview()
    LocalPlayerUIRequestsBus.Broadcast.StartEmoteLocalPreviewByName(self.emoteName)
  else
    local rewardItemData = EntitlementsDataHandler:GetEntitlementDisplayInfo(reward.rewardInfo.rewardType, reward.rewardInfo.rewardId)
    UiImageBus.Event.SetSpritePathname(self.Properties.HiRes2dItemImage, rewardItemData.spritePath)
    UiImageBus.Event.SetColor(self.Properties.HiRes2dItemImage, rewardItemData.spriteColor)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemPreview2dFrame, true)
    local displayInfo = EntitlementsDataHandler:GetRewardDisplayInfo(reward.rewardInfo)
    if displayInfo.secondarySpritePath then
      UiImageBus.Event.SetSpritePathname(self.Properties.HiRes2dItemImage, displayInfo.secondarySpritePath)
    elseif displayInfo.hiresSpritePath then
      UiImageBus.Event.SetSpritePathname(self.Properties.HiRes2dItemImage, displayInfo.hiresSpritePath)
    end
    if displayInfo.secondarySpriteColor then
      UiImageBus.Event.SetColor(self.Properties.HiRes2dItemImage, displayInfo.secondarySpriteColor)
    else
      UiImageBus.Event.SetColor(self.Properties.HiRes2dItemImage, displayInfo.spriteColor)
    end
    self.ScriptedEntityTweener:Play(self.Properties.ItemPreview2dFrame, 0.2, {opacity = 0}, {opacity = 1})
  end
end
function StoreProductPopup:Hide2dPreview()
  self.ScriptedEntityTweener:Play(self.Properties.ItemPreview2dFrame, 0.2, {
    opacity = 0,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemPreview2dFrame, false)
    end
  })
end
function StoreProductPopup:OnRewardHoverBegin(gridElement)
  self:ShowSingleRewardTooltip(gridElement)
  if not self.singleReward then
    self:ShowRewardPreview(gridElement.itemData)
  end
end
function StoreProductPopup:OnRewardHoverEnd(gridElement)
  local reward = gridElement.itemData
  if not self.singleReward then
    if reward.rewardInfo.rewardType == eRewardTypeItemSkin then
      local itemSkinData = ItemSkinData()
      if ItemSkinDataManagerBus.Broadcast.GetItemSkinDataFromId(reward.rewardInfo.rewardId, itemSkinData) then
        self:ResetEquippedItemSkins()
        self.dataLayer:Call(566834302, self.itemSkinRewardIdToSlot[reward.rewardInfo.rewardId])
      end
    else
      self:Hide2dPreview()
    end
  end
  if reward.rewardInfo.rewardType == eRewardTypeEmote and self.emotePlaying then
    LocalPlayerUIRequestsBus.Broadcast.StopEmoteLocalPreview()
  end
end
function StoreProductPopup:IsEnabled()
  return UiElementBus.Event.IsEnabled(self.entityId)
end
function StoreProductPopup:SetIsEnabled(isEnabled)
  if not isEnabled then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Inventory.SuppressNotificationsWhileItemSkinning", false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemPreview2dFrame, false)
  end
  if self:IsEnabled() == isEnabled then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
  if isEnabled then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Inventory.SuppressNotificationsWhileItemSkinning", true)
    self.dataLayer:Call(3995983548)
    self.ConfirmButton:StartStopImageSequence(true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  else
    if self.emotePlaying then
      LocalPlayerUIRequestsBus.Broadcast.StopEmoteLocalPreview()
    end
    self:ResetEquippedItemSkins()
    self.dataLayer:Call(1549315314)
    if self.emoteNotificationBus then
      self:BusDisconnect(self.emoteNotificationBus)
      self.emoteNotificationBus = nil
      self.emotePlaying = nil
    end
    if self.closeCallbackTable and type(self.closeCallback) == "function" then
      self.closeCallback(self.closeCallbackTable)
    end
    self.ConfirmButton:StartStopImageSequence(false)
    self.ScriptedEntityTweener:Play(self.entityId, 0.15, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  end
end
function StoreProductPopup:SetSelected(index, gridItemData)
  self.selectedIndex = index
  for k, gridItem in ipairs(self.rewards) do
    gridItem.isSelected = gridItem.index == index
  end
  self.RewardsList:RequestRefreshContent()
end
function StoreProductPopup:OnCancel()
  self:SetIsEnabled(false)
end
function StoreProductPopup:SetCloseCallback(command, table)
  self.closeCallback = command
  self.closeCallbackTable = table
end
function StoreProductPopup:OnEmotePreviewStarted(emoteId)
  UiElementBus.Event.SetIsEnabled(self.Properties.StartStopButton, self.emoteLocked)
  self.emotePlaying = emoteId
  self.StartStopButton:SetText("@ui_end_preview")
end
function StoreProductPopup:OnEmotePreviewEnded(emoteId, cooldownEndTimePoint)
  UiElementBus.Event.SetIsEnabled(self.Properties.StartStopButton, self.emoteLocked)
  self.emotePlaying = nil
  self.StartStopButton:SetText("@ui_preview_emote")
end
return StoreProductPopup

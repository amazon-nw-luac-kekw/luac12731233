local HousingDecoration_GridItem = {
  Properties = {
    ContentsContainer = {
      default = EntityId()
    },
    ItemLayout = {
      default = EntityId()
    },
    UnavailableCover = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    BgElement = {
      default = EntityId()
    }
  }
}
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
BaseElement:CreateNewElement(HousingDecoration_GridItem)
local descriptor = ItemDescriptor()
function HousingDecoration_GridItem:OnInit()
  BaseElement.OnInit(self)
  self.AVAILABLE_STATUS_OK = 1
  self.AVAILABLE_STATUS_NO_ITEM = 2
  self.AVAILABLE_STATUS_ENTITLED_OK = 3
  self.AVAILABLE_STATUS_ENTITLED_ALL_PLACED = 4
  self.AVAILABLE_STATUS_NOT_ENTITLED = 5
  self.UnavailableReasonText = {}
  self.UnavailableReasonText[self.AVAILABLE_STATUS_OK] = ""
  self.UnavailableReasonText[self.AVAILABLE_STATUS_NO_ITEM] = "@ui_housing_tooltip_noitem"
  self.UnavailableReasonText[self.AVAILABLE_STATUS_ENTITLED_OK] = ""
  self.UnavailableReasonText[self.AVAILABLE_STATUS_ENTITLED_ALL_PLACED] = "@ui_housing_tooltip_placed_all"
  self.UnavailableReasonText[self.AVAILABLE_STATUS_NOT_ENTITLED] = "@ui_housing_tooltip_not_entitled"
  self.BGColors = {}
  self.BGColors[self.AVAILABLE_STATUS_OK] = self.UIStyle.COLOR_WHITE
  self.BGColors[self.AVAILABLE_STATUS_NO_ITEM] = self.UIStyle.COLOR_WHITE
  self.BGColors[self.AVAILABLE_STATUS_ENTITLED_OK] = self.UIStyle.COLOR_WHITE
  self.BGColors[self.AVAILABLE_STATUS_ENTITLED_ALL_PLACED] = self.UIStyle.COLOR_WHITE
  self.BGColors[self.AVAILABLE_STATUS_NOT_ENTITLED] = self.UIStyle.COLOR_WHITE
  self.BGSprites = {}
  self.BGSprites[self.AVAILABLE_STATUS_OK] = "lyshineui/images/crafting/crafting_itemraritybg0.dds"
  self.BGSprites[self.AVAILABLE_STATUS_NO_ITEM] = "lyshineui/images/crafting/crafting_itemraritybg0.dds"
  self.BGSprites[self.AVAILABLE_STATUS_ENTITLED_OK] = "lyshineui/images/crafting/crafting_itemraritybg0.dds"
  self.BGSprites[self.AVAILABLE_STATUS_ENTITLED_ALL_PLACED] = "lyshineui/images/crafting/crafting_itemraritybg0.dds"
  self.BGSprites[self.AVAILABLE_STATUS_NOT_ENTITLED] = "lyshineui/images/crafting/crafting_itemraritybg0.dds"
end
function HousingDecoration_GridItem:OnShutdown()
end
function HousingDecoration_GridItem:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function HousingDecoration_GridItem:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function HousingDecoration_GridItem:GetHorizontalSpacing()
  return 5
end
function HousingDecoration_GridItem:UpdateAvailableStatus()
  self.isAvailable = self.decorationItemData:GetQuantity() > 0
  if self.decorationItemData.housingItemData:IsEntitlement() then
    if self.isAvailable then
      self.availableStatus = self.AVAILABLE_STATUS_ENTITLED_OK
    elseif EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeHousingItem, self.decorationItemData.housingItemData.id) then
      self.availableStatus = self.AVAILABLE_STATUS_ENTITLED_ALL_PLACED
    else
      self.availableStatus = self.AVAILABLE_STATUS_NOT_ENTITLED
    end
  elseif self.isAvailable then
    self.availableStatus = self.AVAILABLE_STATUS_OK
  else
    self.availableStatus = self.AVAILABLE_STATUS_NO_ITEM
  end
  self.unavailableReason = self.UnavailableReasonText[self.availableStatus]
end
function HousingDecoration_GridItem:SetGridItemData(decorationItemData)
  UiElementBus.Event.SetIsEnabled(self.entityId, decorationItemData ~= nil)
  self.decorationItemData = decorationItemData
  if decorationItemData then
    local itemId = self.decorationItemData.housingItemData.id
    local itemData = ItemDataManagerBus.Broadcast.GetItemData(itemId)
    self.ItemLayout:SetItemIconLocalPosition(5, 1)
    self.ItemLayout:SetItemByName(decorationItemData.housingItemData.id, "")
    self.ItemLayout:SetQuantityEnabled(true)
    local quantity = decorationItemData:GetQuantity()
    self.ItemLayout:SetQuantity(quantity)
    self:UpdateAvailableStatus()
    UiImageBus.Event.SetColor(self.Properties.BgElement, self.BGColors[self.availableStatus])
    UiImageBus.Event.SetSpritePathname(self.Properties.BgElement, self.BGSprites[self.availableStatus])
    local xPos = 4
    local unavailableAlpha = 0.4
    if self.decorationItemData.housingItemData:IsEntitlement() then
      if self.decorationItemData.availableProducts and #self.decorationItemData.availableProducts > 0 then
        unavailableAlpha = 1
        local isRewardFromTwitch = false
        local isRewardFromPrime = false
        local isRewardFromPreOrder = false
        local isRewardFromStore = false
        xPos = 4
        local iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
        if isRewardFromTwitch then
          iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_Twitch.dds"
        elseif isRewardFromPrime then
          iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_TwitchPrime.dds"
        elseif isRewardFromPreOrder then
          iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
          xPos = 8
        elseif isRewardFromStore then
          iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
        end
        UiImageBus.Event.SetSpritePathname(self.Properties.UnavailableCover, iconTexture)
      else
        UiImageBus.Event.SetSpritePathname(self.Properties.UnavailableCover, "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds")
        xPos = 8
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.UnavailableCover, self.availableStatus == self.AVAILABLE_STATUS_NOT_ENTITLED)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.UnavailableCover, xPos)
    local hoverColor = self.isAvailable and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_RED_DARK
    UiImageBus.Event.SetColor(self.Properties.Hover, hoverColor)
    if not self.isAvailable then
      self.ScriptedEntityTweener:Set(self.Properties.ContentsContainer, {opacity = unavailableAlpha})
    else
      self.ScriptedEntityTweener:Set(self.Properties.ContentsContainer, {opacity = 1})
    end
    if self.isAvailable or self.decorationItemData.availableProducts then
      self.callbackSelf = decorationItemData.callbackSelf
      self.callbackFn = decorationItemData.callbackFn
    else
      self.callbackSelf = nil
      self.callbackFn = nil
    end
  else
    self.callbackSelf = nil
    self.callbackFn = nil
    UiImageBus.Event.SetColor(self.Properties.BgElement, self.UIStyle.COLOR_BLACK)
  end
end
function HousingDecoration_GridItem:OnHousingDecorationItemFocus()
  if not self.decorationItemData then
    return
  end
  descriptor.itemId = self.decorationItemData.housingItemData.id
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu:IsLocked() then
    return
  end
  local flyoutVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible")
  if flyoutVisible and flyoutMenu.invokingEntityId == self.entityId then
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local itemTable = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil)
  if self.decorationItemData.availableProducts then
    local rewardDisplayInfo = EntitlementsDataHandler:GetEntitlementDisplayInfo(eRewardTypeHousingItem, self.decorationItemData.housingItemData.key)
    local productType = rewardDisplayInfo.typeString
    local grantInfo = EntitlementsDataHandler:GetGrantorForRewardTypeAndKey(eRewardTypeHousingItem, self.decorationItemData.housingItemData.key)
    itemTable.productType = productType
    itemTable.sourceType = grantInfo.grantor.sourceType
  end
  local rows = {}
  local tooltipData = {
    slicePath = "LyShineUI/Tooltip/DynamicTooltip",
    itemTable = itemTable,
    isInPaperdoll = false,
    inventoryTable = nil,
    slotIndex = nil,
    draggableItem = nil,
    rewardType = eRewardTypeHousingItem,
    rewardKey = self.decorationItemData.housingItemData.key,
    availableProducts = self.decorationItemData.availableProducts,
    disclaimerText = self.decorationItemData.availableProducts and "@ui_mtx_disclaimer" or nil
  }
  if not self.isAvailable then
    tooltipData.dynamicInfoText = self.unavailableReason
    tooltipData.dynamicInfoColor = self.UIStyle.COLOR_RED
  end
  table.insert(rows, tooltipData)
  if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
    flyoutMenu:SetOpenLocation(self.entityId)
    flyoutMenu:SetRowData(rows)
    flyoutMenu:SetSourceHoverOnly(true)
    flyoutMenu:DockToCursor(10)
    flyoutMenu:Unlock()
  end
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 1})
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Material_Hover)
end
function HousingDecoration_GridItem:OnHousingDecorationItemUnFocus()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 0})
end
function HousingDecoration_GridItem:OnHousingDecorationItemClick()
  if self.callbackSelf then
    self.callbackFn(self.callbackSelf, self.decorationItemData)
  end
end
return HousingDecoration_GridItem

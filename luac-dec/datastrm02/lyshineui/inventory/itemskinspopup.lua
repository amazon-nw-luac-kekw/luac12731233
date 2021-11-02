local ItemSkinsPopup = {
  Properties = {
    ItemSkinsList = {
      default = EntityId()
    },
    ItemSkinPrototype = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    ConfirmButton = {
      default = EntityId()
    },
    ScrollBoxDividerTop = {
      default = EntityId()
    },
    ScrollBoxDividerBottom = {
      default = EntityId()
    }
  }
}
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ItemSkinsPopup)
function ItemSkinsPopup:OnInit()
  BaseElement.OnInit(self)
  self.CancelButton:SetCallback(self.OnCancel, self)
  self.CancelButton:SetButtonStyle(self.CancelButton.BUTTON_STYLE_DEFAULT)
  self.CancelButton:SetText("@ui_cancel")
  self.ConfirmButton:SetText("@ui_confirm")
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
  self.ConfirmButton:SetEnabled(false)
  self.ConfirmButton:SetCallback(self.OnItemSkinConfirmed, self)
  self.visibleItemSkins = {}
  self.ItemSkinsList:Initialize(self.ItemSkinPrototype)
  self.ItemSkinsList:OnListDataSet(nil)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", function(self, paperdollId)
    if not paperdollId then
      return
    end
    self.paperdollId = paperdollId
  end)
end
function ItemSkinsPopup:OnEntitlementsChange()
  self:SetSlot(self.slotId, self.isInInventoryOrStorage, true)
end
function ItemSkinsPopup:SetSlot(slotId, isInInventoryOrStorage, forceUpdate, containerId)
  if self.slotId == tonumber(slotId) and not forceUpdate then
    return
  end
  self.slotId = tonumber(slotId)
  self.isInInventoryOrStorage = isInInventoryOrStorage
  local slot
  if isInInventoryOrStorage then
    local containerId = containerId == nil and self.inventoryId or containerId
    slot = ContainerRequestBus.Event.GetSlot(containerId, self.slotId)
  else
    slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, self.slotId)
  end
  if not slot:IsValid() then
    Debug.Log("Warning: ItemSkinsPopup:SetSlot - trying to skin item with invalid slot")
    return
  end
  self.paperdollSlotId = self:GetPaperdollSlotFromItemSlot(slot)
  self.baseItemId = slot:GetItemId()
  self.baseItemKey = slot:GetItemDescriptor():GetItemKey()
  self.dyeData = slot:GetDyeData()
  self.activeItemSkinItemId = ItemSkinningRequestBus.Event.GetItemSkinItemId(self.playerId, self.baseItemId)
  if self.activeItemSkinItemId == 0 then
    self.activeItemSkinItemId = self.baseItemId
  end
  self:PopulateItemSkinsList(slot)
end
function ItemSkinsPopup:OnSlotUpdate(localSlotId, slot, updateReason)
  if localSlotId == self.slotId then
    self:PopulateItemSkinsList(slot)
  end
end
function ItemSkinsPopup:IsWeapon(slot)
  return slot:HasItemClass(eItemClass_EquippableMainHand) or slot:HasItemClass(eItemClass_EquippableTwoHand) or slot:HasItemClass(eItemClass_EquippableOffHand)
end
function ItemSkinsPopup:GetPaperdollSlotFromItemSlot(slot)
  local paperdollSlotId
  if slot:HasItemClass(eItemClass_EquippableHead) then
    paperdollSlotId = ePaperDollSlotTypes_Head
  elseif slot:HasItemClass(eItemClass_EquippableChest) then
    paperdollSlotId = ePaperDollSlotTypes_Chest
  elseif slot:HasItemClass(eItemClass_EquippableHands) then
    paperdollSlotId = ePaperDollSlotTypes_Hands
  elseif slot:HasItemClass(eItemClass_EquippableLegs) then
    paperdollSlotId = ePaperDollSlotTypes_Legs
  elseif slot:HasItemClass(eItemClass_EquippableFeet) then
    paperdollSlotId = ePaperDollSlotTypes_Feet
  elseif slot:HasItemClass(eItemClass_EquippableMainHand) or slot:HasItemClass(eItemClass_EquippableTwoHand) then
    paperdollSlotId = PaperdollRequestBus.Event.GetActiveSlot(self.paperdollId, ePaperdollSlotAlias_ActiveWeapon)
  elseif slot:HasItemClass(eItemClass_EquippableOffHand) then
    paperdollSlotId = ePaperDollSlotTypes_OffHandOption1
  end
  return paperdollSlotId
end
function ItemSkinsPopup:IsEnabled()
  return UiElementBus.Event.IsEnabled(self.entityId)
end
function ItemSkinsPopup:SetIsEnabled(isEnabled)
  if not isEnabled then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Inventory.SuppressNotificationsWhileItemSkinning", false)
    self:ResetSelectedItem()
  end
  if self:IsEnabled() == isEnabled then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
  if isEnabled then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Inventory.SuppressNotificationsWhileItemSkinning", true)
    self.inventoryBus = self:BusConnect(ContainerEventBus, self.inventoryId)
    self.entitlementBus = self:BusConnect(EntitlementNotificationBus)
    DynamicBus.CatContainer.Broadcast.SetScreenVisible(false)
    self.dataLayer:Call(3995983548)
    DynamicBus.Inventory.Broadcast.SetScreenVisible(false, true)
  else
    DynamicBus.CatContainer.Broadcast.SetScreenVisible(true)
    if self.inventoryBus then
      self:BusDisconnect(self.inventoryBus)
      self.inventoryBus = nil
    end
    if self.entitlementBus then
      self:BusDisconnect(self.entitlementBus)
      self.entitlementBus = nil
    end
    self.slotId = nil
    self.dataLayer:Call(1549315314)
    JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.5)
    DynamicBus.Inventory.Broadcast.SetScreenVisible(true, true)
    DynamicBus.EquipmentBus.Broadcast.SetScreenVisible(true)
    if self.closeCallbackTable and type(self.closeCallback) == "function" then
      self.closeCallback(self.closeCallbackTable)
    end
  end
end
function ItemSkinsPopup:PopulateItemSkinsList(slot)
  self.itemDescriptor = slot:GetItemDescriptor()
  self.itemSkinEntries = ItemSkinDataManagerBus.Broadcast.GetItemSkinEntries(self.itemDescriptor.itemId)
  ClearTable(self.visibleItemSkins)
  if self.activeItemSkinItemId == slot:GetItemId() then
    self.selectedIndex = 0
    self.activeItemSkinEntry = 0
  end
  table.insert(self.visibleItemSkins, {
    displayItemId = slot:GetItemId(),
    index = 0,
    itemSkinEntry = GetNilCrc(),
    itemSkinKey = "",
    isEntitlement = false,
    isEnabled = true,
    isSelected = 0 == self.selectedIndex,
    cb = self.SetSelected,
    cbHoverBegin = self.OnItemSkinHoverBegin,
    cbHoverEnd = self.OnItemSkinHoverEnd,
    cbContext = self
  })
  local itemSkinData = ItemSkinData()
  self.originalSkinEntry = nil
  self.ItemSkinsList:SetSpinnerShowing(true)
  OmniDataHandler:GetOmniOffers(self, function(self, offers)
    for i = 1, #self.itemSkinEntries do
      local itemSkinEntry = self.itemSkinEntries[i]
      if ItemSkinDataManagerBus.Broadcast.GetItemSkinDataFromId(itemSkinEntry, itemSkinData) then
        local itemSkinKey = itemSkinData.key
        local isEnabled = true
        local isNew = false
        local availableProducts
        if itemSkinData.isEntitlement then
          if not EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeItemSkin, itemSkinEntry) then
            isEnabled = false
            availableProducts = OmniDataHandler:SearchOffersForRewardTypeAndKey(offers, eRewardTypeItemSkin, itemSkinEntry)
          else
            isNew = EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeNew(eRewardTypeItemSkin, itemSkinEntry)
          end
        end
        if itemSkinData.toItemId == self.activeItemSkinItemId then
          self.originalSkinEntry = itemSkinEntry
          self.activeItemSkinEntry = itemSkinEntry
          self.selectedIndex = i
        end
        table.insert(self.visibleItemSkins, {
          displayItemKey = itemSkinData.key,
          displayItemId = itemSkinData.toItemId,
          index = i,
          itemSkinEntry = itemSkinEntry,
          itemSkinKey = itemSkinKey,
          cb = self.SetSelected,
          cbHoverBegin = self.OnItemSkinHoverBegin,
          cbHoverEnd = self.OnItemSkinHoverEnd,
          isEnabled = isEnabled,
          isSelected = i == self.selectedIndex,
          isEntitlement = itemSkinData.isEntitlement,
          isNew = isNew,
          availableProducts = availableProducts,
          cbContext = self
        })
      else
        Log("Error: no item skin data found for %s", tostring(itemSkinEntry))
      end
    end
    self.ItemSkinsList:OnListDataSet(self.visibleItemSkins)
  end)
end
function ItemSkinsPopup:OnItemSkinHoverBegin(gridItemData)
  if gridItemData.isNew then
    EntitlementRequestBus.Broadcast.MarkEntryIdOfRewardTypeSeen(eRewardTypeItemSkin, gridItemData.itemSkinEntry)
  end
  self.dataLayer:Call(2200389763, self.paperdollSlotId, gridItemData.displayItemId)
end
function ItemSkinsPopup:OnItemSkinHoverEnd(gridItemData)
  self.dataLayer:Call(1549315314)
  if self:IsEnabled() then
    self.dataLayer:Call(3995983548)
  end
  if self.selectedIndex and self.gridItemData then
    self:SetSelected(self.selectedIndex, self.gridItemData)
    self.dataLayer:Call(2200389763, self.paperdollSlotId, self.gridItemData.displayItemId)
  end
end
function ItemSkinsPopup:SetDividers(isVisible)
  self.ScrollBoxDividerTop:SetVisible(isVisible)
  self.ScrollBoxDividerBottom:SetVisible(isVisible)
end
function ItemSkinsPopup:SetSelected(index, gridItemData)
  self.selectedIndex = index
  self.gridItemData = gridItemData
  self.activeItemSkinEntry = gridItemData.itemSkinEntry
  self.activeItemSkinItemId = gridItemData.displayItemId
  self.ConfirmButton:SetEnabled(true)
  for k, gridItem in ipairs(self.visibleItemSkins) do
    gridItem.isSelected = gridItem.index == index
  end
  self.ItemSkinsList:RequestRefreshContent()
end
function ItemSkinsPopup:SetItemSkinEnabled(itemSkinEntry)
  if self.enableSkinDelay then
    TimingUtils:StopDelay(self, self.SetItemSkinEnabledDelay)
  end
  for itemSkinIndex = 1, #self.itemSkinEntries do
    if self.itemSkinEntries[itemSkinIndex] ~= itemSkinEntry then
      ItemSkinningRequestBus.Event.DisableItemSkin(self.playerId, self.itemSkinEntries[itemSkinIndex])
    end
  end
  if itemSkinEntry then
    self.delayedSkinEntry = itemSkinEntry
    self.enableSkinDelay = TimingUtils:Delay(0.1, self, self.SetItemSkinEnabledDelay)
  end
end
function ItemSkinsPopup:SetItemSkinEnabledDelay()
  ItemSkinningRequestBus.Event.EnableItemSkin(self.playerId, self.baseItemId, self.delayedSkinEntry)
  self.enableSkinDelay = nil
end
function ItemSkinsPopup:OnItemSkinConfirmed()
  if not self.gridItemData then
    return
  end
  local gridItemData = self.gridItemData
  if gridItemData.index == 0 then
    self:SetItemSkinEnabled()
    self.activeItemSkinItemId = self.baseItemId
    self.activeItemSkinItemKey = ""
  elseif not gridItemData.isEntitled or EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeItemSkin, gridItemData.itemSkinKey) and self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableItemEntitlements") then
    self:SetItemSkinEnabled(gridItemData.itemSkinEntry)
    self.activeItemSkinItemKey = gridItemData.itemSkinEntry
    self.activeItemSkinItemId = gridItemData.displayItemId
  end
  self:SetIsEnabled(false)
  self:ResetSelectedItem()
end
function ItemSkinsPopup:ResetSelectedItem()
  self.selectedIndex = nil
  self.gridItemData = nil
  self.ConfirmButton:SetEnabled(false)
end
function ItemSkinsPopup:OnCancel()
  self:SetItemSkinEnabled(self.originalSkinEntry)
  self:SetIsEnabled(false)
end
function ItemSkinsPopup:SetCloseCallback(command, table)
  self.closeCallback = command
  self.closeCallbackTable = table
end
return ItemSkinsPopup

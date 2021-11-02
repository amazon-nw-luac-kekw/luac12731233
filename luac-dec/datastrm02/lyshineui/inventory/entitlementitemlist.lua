local EntitlementItemList = {
  Properties = {
    EntityScrollBar = {
      default = EntityId()
    }
  },
  numEntitlements = 0,
  elemPadding = 5
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(EntitlementItemList)
function EntitlementItemList:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.entityId)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.entityId)
end
function EntitlementItemList:OnShutdown()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IgnoreHoverExit", false)
end
function EntitlementItemList:SetBaseItem(itemDescriptor)
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasNotificationBus, canvasId)
  self.itemDescriptor = itemDescriptor
  self.itemSkinEntries = ItemSkinDataManagerBus.Broadcast.GetItemSkinEntries(itemDescriptor.itemId)
  self.numEntitlements = #self.itemSkinEntries
  if self.numEntitlements > 0 then
    self.numEntitlements = self.numEntitlements + 1
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.entityId)
  UiDynamicScrollBoxBus.Event.ScrollToEnd(self.entityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IgnoreHoverExit", true)
end
function EntitlementItemList:GetNumElements()
  return self.numEntitlements
end
function EntitlementItemList:GetElementHeight(index)
  return 60
end
function EntitlementItemList:GetElementWidth(index)
  local itemType = CraftingRequestBus.Broadcast.GetRecipeResultItemType(self.itemDescriptor:GetItemKey())
  if itemType == "Weapon" then
    return 122 + self.elemPadding
  else
    return 60 + self.elemPadding
  end
end
function EntitlementItemList:OnPrepareElementForSizeCalculation(rootEntity, index)
  local hasEntitlement = index < self.numEntitlements
  if not hasEntitlement then
    return
  end
  self:OnElementBecomingVisible(rootEntity, index)
end
function EntitlementItemList:OnElementBecomingVisible(rootEntity, index)
  local hasEntitlement = index < self.numEntitlements
  if not hasEntitlement then
    return
  end
  local itemLayout = self.registrar:GetEntityTable(rootEntity)
  itemLayout:SetItemByDescriptor(self.itemDescriptor)
  itemLayout:SetEntitlementIndex(index, {
    caller = self,
    func = self.OnEntitlementClicked
  })
  UiExitHoverEventBus.Event.ResetTimer(self.entityId)
end
function EntitlementItemList:OnEntitlementClicked(itemLayout)
  local entitlementIndex = itemLayout:GetEntitlementIndex()
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  if entitlementIndex == 1 then
    for itemSkinIndex = 1, #self.itemSkinEntries do
      if ItemSkinningRequestBus.Event.IsItemSkinEnabled(playerEntityId, self.itemSkinEntries[itemSkinIndex]) then
        ItemSkinningRequestBus.Event.DisableItemSkin(playerEntityId, self.itemSkinEntries[itemSkinIndex])
      end
    end
  elseif 1 < entitlementIndex then
    local selectedItemSkinEntry = self.itemSkinEntries[entitlementIndex - 1]
    local itemSkinData = ItemSkinData()
    if ItemSkinDataManagerBus.Broadcast.GetItemSkinDataFromKey(selectedItemSkinEntry, itemSkinData) and (EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeItemSkin, itemSkinData.key) or self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableItemEntitlements")) then
      ItemSkinningRequestBus.Event.EnableItemSkin(playerEntityId, self.itemDescriptor.m_itemId, selectedItemSkinEntry)
    else
    end
  end
end
function EntitlementItemList:OnAction(entityId, action)
  if action == "EntitlementExitHover" then
    self:EntitlementExitHover()
  end
end
function EntitlementItemList:EntitlementExitHover()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IgnoreHoverExit", false)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
end
return EntitlementItemList

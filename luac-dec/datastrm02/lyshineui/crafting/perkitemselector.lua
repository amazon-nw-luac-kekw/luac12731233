local PerkItemSelector = {
  Properties = {
    FrameMultiBg = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    Scrollbox = {
      default = EntityId()
    },
    Content = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    }
  },
  callbackFunction = nil,
  callbackTable = nil,
  closeCallbackFunction = nil,
  closeCallbackTable = nil
}
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PerkItemSelector)
function PerkItemSelector:OnInit()
  BaseElement:OnInit(self)
  self.ButtonClose:SetCallback(self.OnClose, self)
  self.FrameHeader:SetText("@crafting_perkselectiontitle")
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
end
function PerkItemSelector:Prepopulate(craftingItemId, selectedItemId)
  local itemList = ItemDataManagerBus.Broadcast.GetCompatiblePerkResourceIds(craftingItemId)
  self.availableItemCount = 0
  self.selectedItemDescriptor = ItemDescriptor()
  self.selectedItemDescriptor.itemId = selectedItemId
  local showAttributesItems = true
  local descriptor = ItemCommon:GetFullDescriptorFromId(craftingItemId)
  local info = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil)
  for _, perkId in ipairs(info.perks) do
    if showAttributesItems and perkId ~= 0 then
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData.perkType == ePerkType_Inherent then
        showAttributesItems = false
      end
    end
  end
  local staticItemDataList = {}
  for i = 1, #itemList do
    local perkId = ItemDataManagerBus.Broadcast.GetDisplayPerkIdFromResource(itemList[i])
    local perkData
    if perkId and perkId ~= 0 then
      perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
    end
    if perkData and perkData.perkType ~= ePerkType_Inherent or showAttributesItems then
      local staticItemData = StaticItemDataManager:GetItem(itemList[i])
      local quantity = DynamicBus.InventoryCacheBus.Broadcast.QueryInventoryCache(itemList[i])
      if 0 < quantity then
        self.availableItemCount = self.availableItemCount + 1
      end
      table.insert(staticItemDataList, {
        id = itemList[i],
        sortKey = staticItemData.key,
        quantity = quantity
      })
    end
  end
  table.sort(staticItemDataList, function(a, b)
    if a.quantity == 0 and b.quantity > 0 then
      return false
    elseif a.quantity > 0 and b.quantity == 0 then
      return true
    else
      return a.sortKey < b.sortKey
    end
  end)
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Content, #staticItemDataList + 1)
  local itemDescriptor = ItemDescriptor()
  local child = UiElementBus.Event.GetChild(self.Properties.Content, 0)
  local perkItem = self.registrar:GetEntityTable(child)
  perkItem:SetItem(itemDescriptor)
  perkItem:SetCallback(self.HandleSelection, self)
  perkItem:SelectIfItemId(self.selectedItemDescriptor.itemId)
  for i = 1, #staticItemDataList do
    child = UiElementBus.Event.GetChild(self.Properties.Content, i)
    perkItem = self.registrar:GetEntityTable(child)
    if perkItem ~= nil then
      itemDescriptor.itemId = staticItemDataList[i].id
      itemDescriptor.quantity = staticItemDataList[i].quantity
      perkItem:SetItem(itemDescriptor)
      perkItem:SetCallback(self.HandleSelection, self)
      perkItem:SelectIfItemId(self.selectedItemDescriptor.itemId)
    end
  end
end
function PerkItemSelector:GetAvailableItemCount()
  return self.availableItemCount
end
function PerkItemSelector:Show()
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut"
  })
end
function PerkItemSelector:Hide()
  self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
    end
  })
end
function PerkItemSelector:SetCallback(callback, callingTable)
  self.callbackFunction = callback
  self.callbackTable = callingTable
end
function PerkItemSelector:SetCloseCallback(callback, callingTable)
  self.closeCallbackFunction = callback
  self.closeCallbackTable = callingTable
end
function PerkItemSelector:HandleSelection(itemDescriptor)
  self.selectedItemDescriptor.itemId = itemDescriptor.itemId
  local childCount = UiElementBus.Event.GetNumChildElements(self.Properties.Content)
  for i = 1, childCount do
    local child = UiElementBus.Event.GetChild(self.Properties.Content, i - 1)
    local entityTable = self.registrar:GetEntityTable(child)
    entityTable:SelectIfItemId(self.selectedItemDescriptor.itemId)
  end
  if self.callbackFunction ~= nil and self.callbackTable ~= nil and type(self.callbackFunction) == "function" then
    self.callbackFunction(self.callbackTable, self.selectedItemDescriptor)
  end
end
function PerkItemSelector:OnClose()
  if self.closeCallbackFunction ~= nil and self.closeCallbackTable ~= nil and type(self.closeCallbackFunction) == "function" then
    self.closeCallbackFunction(self.closeCallbackTable)
  end
end
return PerkItemSelector

local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
local CompareItem = RequireScript("LyShineUI.FlyoutMenu.FlyoutRow_CompareItem")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local DynamicTooltip_Compare = {
  Properties = {
    CompareLabel = {
      default = EntityId()
    },
    CompareMaskFrame = {
      default = EntityId()
    },
    CompareListMask = {
      default = EntityId()
    },
    CompareList = {
      default = EntityId()
    },
    Divider1 = {
      default = EntityId()
    },
    UnusedCompareItems = {
      default = EntityId()
    }
  },
  ANIM_DURATION = 0.07,
  margin = 0,
  skillToText = {},
  repairSkillToText = {},
  COMPARE_ITEM_SLICE = "lyshineui/flyoutmenu/flyoutrow_compareitem"
}
local iconPathRoot = "lyShineui/images/icons/items/"
BaseElement:CreateNewElement(DynamicTooltip_Compare)
Spawner:AttachSpawner(DynamicTooltip_Compare)
function DynamicTooltip_Compare:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiSpawnerNotificationBus, self.CompareList)
  self.compareItemsCache = {}
  local childEntities = UiElementBus.Event.GetChildren(self.Properties.CompareList)
  for i = 1, #childEntities do
    local element = self.registrar:GetEntityTable(childEntities[i])
    table.insert(self.compareItemsCache, element)
  end
  self.maxCompareItems = #self.compareItemsCache - 1
end
function DynamicTooltip_Compare:OnChangeSourceHoverOnly(sourceHoverOnly)
  for k, button in ipairs(self.compareButtons) do
    UiElementBus.Event.SetIsEnabled(button.entityId, not sourceHoverOnly)
  end
end
function DynamicTooltip_Compare:OnFlyoutLocked()
  for k, button in ipairs(self.compareButtons) do
    local commandButtonEntity = UiElementBus.Event.FindChildByName(button.entityId, "Button")
    local commandButton = self.registrar:GetEntityTable(commandButtonEntity)
    local imagePath = "lyshineui/images/slices/buttonsimple/button_simple.png"
    local isDivider = "lyshineui/images/tooltip/tooltip_sectionDivider.png"
    local currentImagePath = UiImageBus.Event.GetSpritePathname(commandButton.ButtonBg)
    if currentImagePath ~= isDivider then
      commandButton:SetButtonToListStyle(imagePath)
      self.ScriptedEntityTweener:Play(commandButton.ButtonBg, 0.3, {opacity = 0}, {
        opacity = 0.1,
        ease = "QuadIn",
        delay = k * self.ANIM_DURATION / 2
      })
    end
    self.ScriptedEntityTweener:Play(commandButton.ButtonText, 0.3, {opacity = 0.5}, {opacity = 1})
  end
end
function DynamicTooltip_Compare:SetItem(itemTable, equipSlot, compareTo, itemSlotIndex, isInInventory, isInPaperdoll, isExternalItem)
  if not self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableTooltipCompare") or itemTable.itemType == "Consumable" then
    return 0
  end
  local currentLine = 0
  local isContainerOpen = LyShineManagerBus.Broadcast.IsInState(3349343259)
  local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  local openContainerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer") or EntityId()
  local openContainerName = ""
  if isContainerOpen then
    openContainerName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.InteractName")
  end
  local itemContainerSlot
  local isShopItem = itemTable.owgAvailableItem ~= nil
  local myItemId = GetTableValue(self.parent, "draggableItem.ItemLayout.itemId")
  local myGatheringType
  if isExternalItem then
    myGatheringType = ItemDataManagerBus.Broadcast.GetWeaponGatheringType(itemTable.id)
  elseif isShopItem then
    myGatheringType = ItemDataManagerBus.Broadcast.GetWeaponGatheringType(itemTable.owgAvailableItem.itemDescriptor.itemId)
  elseif myItemId then
    myGatheringType = ItemDataManagerBus.Broadcast.GetWeaponGatheringType(myItemId)
  end
  self.isInInventory = isInInventory
  self.isInPaperdoll = isInPaperdoll
  if not isShopItem and not isExternalItem and itemTable.itemInstanceId then
    self.itemInstanceId = itemTable.itemInstanceId
    self.gatheringType = ItemDataManagerBus.Broadcast.GetWeaponGatheringType(Math.CreateCrc32(itemTable.name))
    self.paperdollSlotId = tonumber(itemSlotIndex)
    self.inventorySlotId = tonumber(itemSlotIndex)
    if isInInventory then
      itemContainerSlot = ContainerRequestBus.Event.GetSlot(inventoryId, self.inventorySlotId)
    elseif isInPaperdoll then
      local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
      itemContainerSlot = PaperdollRequestBus.Event.GetSlot(paperdollId, self.paperdollSlotId)
    elseif openContainerId then
      itemContainerSlot = ContainerRequestBus.Event.GetSlot(openContainerId, self.inventorySlotId)
    end
  end
  if not isShopItem and not isExternalItem and (not itemContainerSlot or not itemContainerSlot:IsValid()) then
    return 0
  end
  self.itemTable = itemTable
  local itemEquipSlots
  if isExternalItem then
    itemEquipSlots = itemTable.equipSlots
  elseif isShopItem then
    local staticItemData = StaticItemDataManager:GetItem(itemTable.itemId)
    itemEquipSlots = staticItemData.equipSlots
  else
    itemEquipSlots = itemContainerSlot:GetEquipSlots()
  end
  if not itemEquipSlots or #itemEquipSlots == 0 then
    return 0
  end
  local compareItems = {}
  local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
  for i = 0, ePaperDollSlotTypes_Num do
    local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, i)
    if slot and slot:IsValid() then
      local gatheringType = ItemDataManagerBus.Broadcast.GetWeaponGatheringType(slot:GetItemId())
      local equipSlots = slot:GetEquipSlots()
      if equipSlots and #equipSlots == #itemEquipSlots and gatheringType == myGatheringType and equipSlots[1] == itemEquipSlots[1] and tostring(slot:GetItemInstanceId()) ~= tostring(itemTable.itemInstanceId) then
        local itemDescriptor = slot:GetItemDescriptor()
        table.insert(compareItems, {
          slot = slot,
          visible = true,
          location = "@ui_equipped",
          containerOrder = 1,
          gearScore = itemDescriptor:GetGearScore(),
          itemName = itemDescriptor:GetFullName()
        })
      end
    end
  end
  local containerValue = (isShopItem or isExternalItem or isInInventory or isInPaperdoll) and 2 or 3
  local inventoryValue = (isShopItem or isExternalItem or isInInventory or isInPaperdoll) and 3 or 2
  local containers = {
    {
      containerId = inventoryId,
      name = "@ui_inventory",
      containerOrder = inventoryValue
    },
    {
      containerId = openContainerId,
      name = openContainerName,
      containerOrder = containerValue
    }
  }
  for _, container in ipairs(containers) do
    if container.containerId:IsValid() then
      local availableSlots = ContainerRequestBus.Event.GetNumSlots(container.containerId) or 0
      for slotId = 0, availableSlots - 1 do
        local slot = ContainerRequestBus.Event.GetSlot(container.containerId, tostring(slotId))
        if slot and slot:IsValid() then
          local gatheringType = ItemDataManagerBus.Broadcast.GetWeaponGatheringType(slot:GetItemId())
          local equipSlots = slot:GetEquipSlots()
          if equipSlots and #equipSlots == #itemEquipSlots and gatheringType == myGatheringType and (slot:GetMaxStackSize() == 1 or slot:GetAmmoType() ~= 0) and equipSlots[1] == itemEquipSlots[1] and tostring(slot:GetItemInstanceId()) ~= tostring(itemTable.itemInstanceId) then
            local itemDescriptor = slot:GetItemDescriptor()
            table.insert(compareItems, {
              slot = slot,
              location = container.name,
              containerOrder = container.containerOrder,
              gearScore = itemDescriptor:GetGearScore(),
              itemName = itemDescriptor:GetFullName()
            })
          end
        end
      end
    end
  end
  table.sort(compareItems, function(a, b)
    if a.containerOrder < b.containerOrder then
      return true
    end
    if a.containerOrder > b.containerOrder then
      return false
    end
    if a.gearScore > b.gearScore then
      return true
    end
    return false
  end)
  for i, compareItem in ipairs(self.compareItemsCache) do
    UiElementBus.Event.Reparent(compareItem.entityId, self.Properties.UnusedCompareItems, EntityId())
  end
  self.compareButtons = {}
  local lastLocation = ""
  local height = 0
  local cellSpacing = 3
  local lastCompareItem
  local duplicates = 0
  for i, compare in ipairs(compareItems) do
    if not lastCompareItem or lastCompareItem.itemName ~= compare.itemName or lastCompareItem.gearScore ~= compare.gearScore or lastCompareItem.containerOrder ~= compare.containerOrder then
      compare.itemTable = itemTable
      compare.count = 1
      if lastLocation and compare.location == lastLocation then
        compare.location = ""
        height = height + CompareItem.HEIGHT_WITHOUT_HEADER + cellSpacing
      else
        lastLocation = compare.location
        height = height + CompareItem.HEIGHT_HEADER_ONLY + cellSpacing
      end
      currentLine = currentLine + 1
      if currentLine >= self.maxCompareItems then
        break
      end
      compare.index = currentLine
      self:OnCompareItemSpawned(self.compareItemsCache[compare.index], compare)
      lastCompareItem = compare
    elseif lastCompareItem then
      lastCompareItem.count = lastCompareItem.count + 1
      duplicates = duplicates + 1
    end
  end
  if currentLine == 0 then
    return 0
  end
  local additionalItems = #compareItems - self.maxCompareItems - duplicates
  if 0 < additionalItems then
    local additionalItemsText = GetLocalizedReplacementText("@inv_additionalItems", {count = additionalItems})
    self:OnCompareItemSpawned(self.compareItemsCache[#self.compareItemsCache], {location = additionalItemsText, index = currentLine})
    height = height + CompareItem.HEIGHT_HEADER_ONLY
  end
  local bottomPadding = 40
  local compareMaskOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.CompareMaskFrame)
  return compareMaskOffsets.top + height + bottomPadding
end
function DynamicTooltip_Compare:SetTextColor(entity, color)
  UiTextBus.Event.SetColor(entity, color)
end
function DynamicTooltip_Compare:OnCompareItemSpawned(element, data)
  UiElementBus.Event.Reparent(element.entityId, self.Properties.CompareList, EntityId())
  UiElementBus.Event.SetIsEnabled(element.entityId, true)
  element:SetCompareData(data.slot, data.location, data.count, self.isInPaperdoll, self.itemTable, self.flyoutOnRight)
  element.ItemLayout:SetFixed(data.itemTable)
  element.ItemLayout:SetShowTooltipInstantly(true)
  self.compareButtons[data.index] = element
end
function DynamicTooltip_Compare:SetFlyoutOnRight(isOnRight)
  self.flyoutOnRight = isOnRight
end
return DynamicTooltip_Compare

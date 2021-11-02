local ContainerAdditionalInfo = {
  Properties = {
    ItemContainerList = {
      default = EntityId()
    },
    ItemContainerListBG = {
      default = EntityId()
    },
    WeightContainer = {
      default = EntityId()
    },
    WeightValueText = {
      default = EntityId()
    },
    WeightMaxValueText = {
      default = EntityId()
    },
    WeightIcon = {
      default = EntityId()
    },
    AdditionalItemsText = {
      default = EntityId()
    }
  },
  itemsToShow = 6
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
BaseElement:CreateNewElement(ContainerAdditionalInfo)
function ContainerAdditionalInfo:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiInteractOptionAdditionalInfoRequestsBus, self.entityId)
  UiImageBus.Event.SetColor(self.WeightIcon, self.UIStyle.COLOR_WHITE)
  UiTextBus.Event.SetColor(self.WeightValueText, self.UIStyle.COLOR_WHITE)
  UiTextBus.Event.SetColor(self.WeightMaxValueText, self.UIStyle.COLOR_GRAY_60)
  self.items = UiElementBus.Event.GetChildren(self.Properties.ItemContainerList)
  self.itemsToShow = math.min(#self.items, self.itemsToShow)
  UiElementBus.Event.SetIsEnabled(self.ItemContainerList, false)
  UiElementBus.Event.SetIsEnabled(self.WeightContainer, false)
  self.slotsToShow = {}
  self.globalStorageKey = ""
  self.containerEntityId = 0
  DynamicBus.InteractNotifications.Connect(self.entityId, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
end
function ContainerAdditionalInfo:OnShutdown()
  DynamicBus.InteractNotifications.Disconnect(self.entityId, self)
end
function ContainerAdditionalInfo:StopLayoutEffect()
  if self.layoutWithRarityEffect then
    self.layoutWithRarityEffect:PlayRarityEffect(false)
    self.layoutWithRarityEffect = nil
  end
end
function ContainerAdditionalInfo:OnTick(deltaTime, timePoint)
  if self.containerEntityId then
    local slotIndex = self.slotsToShow[self.curProcessingIndex]
    local itemDisplayIndex = self.displayOffset + self.curProcessingIndex
    local isLastItem = itemDisplayIndex == self.itemsToShow
    if slotIndex and itemDisplayIndex <= self.itemsToShow then
      local itemLayoutEntity = self.items[itemDisplayIndex]
      local slot = self:GetSlotRef(slotIndex)
      if slot and slot:IsValid() then
        local itemLayoutTable = self.registrar:GetEntityTable(itemLayoutEntity)
        if itemLayoutTable then
          itemLayoutTable:SetItem(slot)
          local itemId = itemLayoutTable.mItemData_itemId
          local itemData = StaticItemDataManager:GetItem(itemId)
          local itemType = itemData.itemType
          local hideRarityEffect = itemType == "Resource" or itemType == "HousingItem" or itemType == "Lore" or itemType == "Dye"
          itemLayoutTable:SetModeType(itemLayoutTable.MODE_TYPE_ITEM_PREVIEW)
          if self.curProcessingIndex == 1 and itemLayoutTable.mItemData_itemDescriptor:UsesRarity() and itemLayoutTable.mItemData_itemDescriptor:GetRarityLevel() > 0 and not hideRarityEffect then
            itemLayoutTable:PlayRarityEffect(true)
            self:StopLayoutEffect()
            self.layoutWithRarityEffect = itemLayoutTable
          end
          local itemNameEntity = UiElementBus.Event.FindDescendantByName(itemLayoutEntity, "ItemName")
          local itemName = ItemDataManagerBus.Broadcast.GetDisplayName(itemLayoutTable.mItemData_itemId)
          UiTextBus.Event.SetTextWithFlags(itemNameEntity, itemName, eUiTextSet_SetLocalized)
          UiTransformBus.Event.SetLocalPositionX(itemNameEntity, 78)
          UiTransform2dBus.Event.SetLocalWidth(itemNameEntity, 174)
          local raritySuffix = tostring(itemLayoutTable.mItemData_itemDescriptor:GetRarityLevel())
          local colorName = string.format("COLOR_RARITY_LEVEL_%s_BRIGHT", raritySuffix)
          UiTextBus.Event.SetColor(itemNameEntity, self.UIStyle[colorName])
          UiElementBus.Event.SetIsEnabled(itemLayoutEntity, true)
        end
      end
      self.curProcessingIndex = self.curProcessingIndex + 1
    else
      self.containerEntityId = nil
      self:BusDisconnect(self.tickBus)
      self.tickBus = nil
      local containerHeight = 240
      local containerPos = -127
      if self.visibleItemCount > 4 then
        containerHeight = 240
        containerPos = -127
      elseif self.visibleItemCount > 2 then
        containerHeight = 182
        containerPos = -127
      elseif 0 < self.visibleItemCount then
        containerHeight = 112
        containerPos = -140
      end
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.ItemContainerListBG, containerHeight)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.ItemContainerListBG, containerPos)
      if self.visibleItemCount == 1 then
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.ItemContainerListBG, 500)
      else
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.ItemContainerListBG, 630)
      end
      if UiElementBus.Event.IsEnabled(self.Properties.AdditionalItemsText) then
        UiElementBus.Event.SetIsEnabled(self.items[#self.items], false)
      end
      ClearTable(self.slotsToShow)
    end
  else
    self:BusDisconnect(self.tickBus)
    self.tickBus = nil
  end
end
function ContainerAdditionalInfo:PopulateContainerAdditionalInfo(containerEntityId, globalStorageKey)
  self.containerEntityId = containerEntityId
  self.globalStorageKey = globalStorageKey
  for i = #self.items, 1, -1 do
    local itemLayoutEntity = self.items[i]
    UiElementBus.Event.SetIsEnabled(itemLayoutEntity, false)
  end
  if self.globalStorageKey ~= "" then
    contractsDataHandler:RequestStorageData(self.globalStorageKey, self, self.SetStorageItems)
  elseif self.containerEntityId then
    local maxWeight = ContainerRequestBus.Event.GetMaximumEncumbrance(self.containerEntityId)
    local currentWeight = ContainerRequestBus.Event.GetCurrentEncumbrance(self.containerEntityId)
    local numContainerSlots = ContainerRequestBus.Event.GetNumSlots(self.containerEntityId)
    self:DoInitialSetup(maxWeight, currentWeight, numContainerSlots)
  end
end
function ContainerAdditionalInfo:SetStorageItems(storageItems)
  if not storageItems then
    return
  end
  local globalStorageItems = GlobalStorageRequestBus.Event.GetStorageContents(self.playerEntityId, self.globalStorageKey)
  if globalStorageItems then
    self:DoInitialSetup(0, 0, #globalStorageItems)
  end
end
function ContainerAdditionalInfo:DoInitialSetup(maxWeight, currentWeight, numContainerSlots)
  local containerExists = maxWeight ~= nil
  if not containerExists then
    UiElementBus.Event.SetIsEnabled(self.WeightContainer, false)
    UiElementBus.Event.SetIsEnabled(self.ItemContainerList, false)
  else
    local showWeight = 0 < maxWeight
    if showWeight then
      UiTextBus.Event.SetText(self.WeightMaxValueText, LocalizeDecimalSeparators(string.format("/ %.1f", maxWeight / 10)))
      UiTextBus.Event.SetText(self.WeightValueText, LocalizeDecimalSeparators(string.format("%.1f", currentWeight / 10)))
    end
    UiElementBus.Event.SetIsEnabled(self.WeightContainer, showWeight)
    UiElementBus.Event.SetIsEnabled(self.ItemContainerList, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.AdditionalItemsText, false)
    ClearTable(self.slotsToShow)
    local additionalItems = 0
    for slotIndex = 0, numContainerSlots - 1 do
      local slot = self:GetSlotRef(slotIndex)
      if slot and slot:IsValid() then
        table.insert(self.slotsToShow, slotIndex)
        if #self.slotsToShow >= self.itemsToShow then
          additionalItems = additionalItems + 1
        end
      end
    end
    if 0 < #self.slotsToShow and not self.tickBus then
      self.visibleItemCount = math.min(#self.slotsToShow, self.itemsToShow)
      self.curProcessingIndex = 1
      self.displayOffset = self.itemsToShow - self.visibleItemCount
      if self.visibleItemCount % 2 ~= 0 and self.visibleItemCount < self.itemsToShow then
        self.displayOffset = self.displayOffset - 1
      end
      self.tickBus = self:BusConnect(DynamicBus.UITickBus)
      table.sort(self.slotsToShow, function(a, b)
        a = self:GetSlotRef(a)
        b = self:GetSlotRef(b)
        return a:GetItemDescriptor():GetRarityLevel() > b:GetItemDescriptor():GetRarityLevel()
      end)
      if 0 < additionalItems then
        additionalItems = additionalItems + 1
        local additionalItemsText = GetLocalizedReplacementText("@ui_additional_items", {
          count = tostring(additionalItems)
        })
        UiElementBus.Event.SetIsEnabled(self.Properties.AdditionalItemsText, true)
        UiTextBus.Event.SetText(self.Properties.AdditionalItemsText, additionalItemsText)
      end
    elseif self.tickBus then
      self:BusDisconnect(self.tickBus)
      self.tickBus = nil
    end
  end
end
function ContainerAdditionalInfo:GetSlotRef(index)
  if self.globalStorageKey ~= "" then
    local globalStorageItems = GlobalStorageRequestBus.Event.GetStorageContents(self.playerEntityId, self.globalStorageKey)
    if globalStorageItems then
      index = index + 1
      if 0 < index and index <= #globalStorageItems then
        return globalStorageItems[index]
      end
    end
  elseif self.containerEntityId then
    return ContainerRequestBus.Event.GetSlotRef(self.containerEntityId, index)
  end
  return ItemContainerSlot()
end
function ContainerAdditionalInfo:OnInteractUnfocus()
  self:StopLayoutEffect()
end
return ContainerAdditionalInfo

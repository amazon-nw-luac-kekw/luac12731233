RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local CommonDragDrop = RequireScript("LyShineUI.CommonDragDrop")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local ItemDraggable = {
  Properties = {
    DraggingSize = {
      default = Vector2(75, 75)
    },
    ItemLayout = {
      default = EntityId()
    }
  },
  enableBreadcrumbs = false,
  isSplittingStack = false,
  shouldCompareItems = false,
  isInInventory = false,
  canDrag = true,
  isSplittingStackModifierActive = false,
  isQuickMoveModifierActive = false,
  isInInventoryTutorial = false,
  isSelectedForTrade = false,
  isInTradeContainer = false,
  isInMapStorageContainer = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ItemDraggable)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local hoverIntentDetector = RequireScript("LyShineUI._Common.HoverIntentDetector")
function ItemDraggable:OnInit()
  BaseElement.OnInit(self)
  self.ItemLayout:ConnectContainerBus(self.entityId)
  self.ItemLayout:SetIsItemDraggable(true)
  self.ItemLayout:SetOnWidthChangedCallback(function(width, height)
    self.DraggingSize = Vector2(width, height)
    UiTransform2dBus.Event.SetLocalWidth(self.entityId, width)
    UiTransform2dBus.Event.SetLocalHeight(self.entityId, height)
  end)
  self.draggableHandler = self:BusConnect(UiDraggableNotificationBus, self.entityId)
  self.dragCanvas = EntityId()
  self.clonedElement = EntityId()
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasNotificationBus, self.canvasId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", function(self, paperdollId)
    self.paperdollId = paperdollId
  end)
  self.tweening = false
  self:BusConnect(UiInteractableNotificationBus, self.entityId)
  self.logSettings = {false, "Inventory"}
  self.dataLayer:RegisterObserver(self, "UIFeatures.g_uiItemBreadcrumbsActive", function(self, dataNode)
    self.logSettings[1] = dataNode:GetData()
  end)
  self.logSettings[1] = self.dataLayer:GetDataNode("UIFeatures.g_uiItemBreadcrumbsActive"):GetData()
  Log(self.logSettings, "IBC: ItemDraggable OnActivate")
  for _, actionNames in ipairs({
    "ui_splitItemStackModifierDown",
    "ui_splitItemStackModifierUp",
    "ui_quickMoveItemModifierDown",
    "ui_quickMoveItemModifierUp"
  }) do
    self:BusConnect(CryActionNotificationsBus, actionNames)
  end
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
  Log(self.logSettings, "IBC: ItemDraggable OnFirstTick, warning, the draggableName is %s", UiElementBus.Event.GetName(self.entityId))
end
function ItemDraggable:OnCanvasEnabledChanged(isEnabled)
  if not isEnabled then
    self.lockFlyoutOnOpen = false
  end
end
function ItemDraggable:SetItemInstanceId(value)
  self.itemInstanceId = value
end
function ItemDraggable:GetItemInstanceId()
  return self.itemInstanceId
end
function ItemDraggable:SetCanDrag(canDrag)
  self.canDrag = canDrag
  self.ItemLayout:SetIsItemDraggable(canDrag)
end
function ItemDraggable:GetCanDrag()
  return self.canDrag
end
function ItemDraggable:SetItemIsShowing(isShowing)
  self.ItemLayout:SetItemIsShowing(isShowing)
end
function ItemDraggable:OnReturnedToCache()
  self.itemInstanceId = nil
  self.ItemLayout:OnReturnedToCache()
end
function ItemDraggable:SetIsInInventory(value)
  self.ItemLayout:SetIsInInventory(value)
  self.isInInventory = value
  if self.isInInventory == true then
    local inventoryScriptEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.InventoryScriptElement")
    if inventoryScriptEntity and inventoryScriptEntity:IsValid() then
      self.inventoryTable = self.registrar:GetEntityTable(inventoryScriptEntity)
      self.itemInstanceId = self.ItemLayout:GetItemInstanceId()
    end
  end
end
function ItemDraggable:GetIsInInventory()
  return self.isInInventory
end
function ItemDraggable:OnShutdown()
  if self.inventoryTable and self.isInInventory then
    self.inventoryTable:RemoveDraggableItem(self)
    self.inventoryTable = nil
  end
  if self.draggableHandler then
    self.draggableHandler:Disconnect()
    self.draggableHandler = nil
  end
  if self.interactableHandler then
    self.interactableHandler:Disconnect()
    self.interactableHandler = nil
  end
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
  Log(self.logSettings, "IBC: ItemDraggable OnDeactivate")
  self.dataLayer:UnregisterObserver(self, "UIFeatures.g_uiItemBreadcrumbsActive")
  timingUtils:StopDelay(self)
end
function ItemDraggable:SetNewIndicatorVisible(isVisible)
  self.ItemLayout:SetNewIndicatorVisible(isVisible)
end
function ItemDraggable:GetStackSplitter()
  return self.registrar:GetEntityTable(self.dataLayer:GetDataFromNode("Hud.StackSplitter"))
end
function ItemDraggable:InvokeStackSplitter()
  local splitter = self:GetStackSplitter()
  if not splitter then
    return
  end
  splitter:Invoke(self)
end
function ItemDraggable:HideStackSplitter()
  local splitter = self:GetStackSplitter()
  if not splitter then
    return
  end
  if splitter.canvasId ~= self.canvasId then
    return
  end
  splitter:Hide()
end
function ItemDraggable:OnLinkItem()
  local isInPaperdoll = self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPPED or self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPMENT_WEAPON
  if isInPaperdoll then
    local slotIndex = self.ItemLayout:GetSlotName()
    local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
    local targetItem = PaperdollRequestBus.Event.GetSlot(paperdollId, slotIndex)
    DynamicBus.ChatBus.Broadcast.LinkItem(targetItem:GetItemDescriptor())
  end
end
function ItemDraggable:OnStoreItem()
  local isInPaperdoll = self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPPED or self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPMENT_WEAPON
  if isInPaperdoll then
    local isContainerOpen = LyShineManagerBus.Broadcast.IsInState(3349343259)
    local isLootContainer = isContainerOpen and self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop")
    if isLootContainer then
      return
    end
    local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
    local slotIndex = self.ItemLayout:GetSlotName()
    local targetItem = PaperdollRequestBus.Event.GetSlot(paperdollId, slotIndex)
    local paperdollSlotId = tonumber(slotIndex)
    if targetItem and targetItem:IsValid() then
      local containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
      local isSlotBlocked = PaperdollRequestBus.Event.SlotBlockedByCooldown(paperdollId, slotIndex)
      if isSlotBlocked then
        EquipmentCommon:TriggerEquipErrorNotification("@ui_equipment_cooldown_error")
      end
      LocalPlayerUIRequestsBus.Broadcast.UnequipItem(paperdollSlotId, -1, targetItem:GetStackSize(), containerId)
    end
  end
end
function ItemDraggable:OnRepair()
  local itemTable = self.ItemLayout:GetTooltipDisplayInfo()
  local maxDurability = itemTable.maxDurability or 0
  if maxDurability == 0 then
    return
  end
  local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  local isInPaperdoll = self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPPED or self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPMENT_WEAPON
  local slotIndex = self.ItemLayout:GetSlotName()
  local itemSlot
  if self.isInInventory then
    itemSlot = ContainerRequestBus.Event.GetSlot(inventoryId, slotIndex)
  elseif isInPaperdoll then
    local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
    itemSlot = PaperdollRequestBus.Event.GetSlot(paperdollId, slotIndex)
  else
    local containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
    itemSlot = ContainerRequestBus.Event.GetSlot(containerId, slotIndex)
  end
  if not itemSlot or not itemSlot:IsValid() then
    return
  end
  local repairEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.ItemRepairEntityId")
  local canRepair = ItemRepairRequestBus.Event.CanRepairItem(repairEntityId, itemSlot, false)
  if not canRepair then
    return
  end
  local repairIngredients = ItemRepairRequestBus.Event.GetRepairRecipeScript(repairEntityId, itemSlot)
  if not repairIngredients then
    return
  end
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local currentRepairParts = CategoricalProgressionRequestBus.Event.GetProgression(playerEntityId, 2817455512)
  local repairIngredient
  if 0 < #repairIngredients then
    repairIngredient = repairIngredients[1]
  end
  local durabilityToRepair = maxDurability
  if type(itemTable.durability) == "number" then
    durabilityToRepair = maxDurability - itemTable.durability
  end
  if durabilityToRepair <= 0 then
    return
  end
  self.repairItemInstanceId = self.ItemLayout:GetItemInstanceId()
  self.repairSlotIndex = slotIndex
  if self.isSplittingStackModifierActive then
    self:OnRepairConfirm()
    return
  end
  local descriptionLocTag = "@crafting_repair_requires"
  local descriptionReplacements = {}
  local needsIngredientsToRepair = repairIngredient and 0 < repairIngredient.quantity
  if needsIngredientsToRepair then
    descriptionReplacements.quantityRequired = repairIngredient.quantity
    descriptionReplacements.itemRequired = repairIngredient:GetDisplayName()
  end
  local isRepair = true
  local neededRepairParts = RecipeDataManagerBus.Broadcast.GetRepairDustQuantity(itemSlot, isRepair)
  local neededGold = RecipeDataManagerBus.Broadcast.GetRepairGoldQuantity(itemSlot:GetTierNumber(), itemSlot:GetMaxDurability() - itemSlot:GetDurability())
  local neededGoldDisplay = GetLocalizedCurrency(neededGold)
  descriptionLocTag = descriptionLocTag .. "_withrepairparts"
  descriptionReplacements.goldQuantityRequired = neededGoldDisplay
  descriptionReplacements.repairPartsRequired = neededRepairParts
  local description = GetLocalizedReplacementText(descriptionLocTag, descriptionReplacements)
  local confirmationData = {
    title = "@inv_repair",
    description = description,
    confirmCallback = self.OnRepairConfirm,
    confirmCallbackTable = self,
    closeFlyout = true
  }
  local buttonRect = UiTransformBus.Event.GetViewportSpaceRect(self.entityId)
  local positionVector = Vector2(buttonRect:GetCenterX(), buttonRect:GetCenterY() - 24)
  DynamicBus.ConfirmationPopup.Broadcast.ShowConfirmationPopup(positionVector, confirmationData)
end
function ItemDraggable:OnRepairConfirm()
  if not self.repairItemInstanceId or not self.repairSlotIndex then
    return
  end
  DynamicBus.ItemRepairDynamicBus.Broadcast.OnItemRepaired(self.repairItemInstanceId)
  local isInPaperdoll = self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPPED or self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPMENT_WEAPON
  if self.isInInventory then
    LocalPlayerUIRequestsBus.Broadcast.RepairItem(self.repairSlotIndex, false)
  elseif isInPaperdoll then
    LocalPlayerUIRequestsBus.Broadcast.PaperdollRepairItem(self.repairSlotIndex, false)
  else
    LocalPlayerUIRequestsBus.Broadcast.StorageRepairItem(self.repairSlotIndex, false)
  end
  self.repairItemInstanceId = nil
  self.repairSlotIndex = nil
end
function ItemDraggable:OnRepairKit()
  local itemTable = self.ItemLayout:GetTooltipDisplayInfo()
  local maxDurability = itemTable.maxDurability or 0
  if maxDurability == 0 then
    return
  end
  local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  local isInPaperdoll = self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPPED or self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPMENT_WEAPON
  local slotIndex = self.ItemLayout:GetSlotName()
  local itemSlot
  if self.isInInventory then
    itemSlot = ContainerRequestBus.Event.GetSlot(inventoryId, slotIndex)
  elseif isInPaperdoll then
    local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
    itemSlot = PaperdollRequestBus.Event.GetSlot(paperdollId, slotIndex)
  else
    local containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
    itemSlot = ContainerRequestBus.Event.GetSlot(containerId, slotIndex)
  end
  if not itemSlot or not itemSlot:IsValid() then
    return
  end
  local repairEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.ItemRepairEntityId")
  local canRepair = ItemRepairRequestBus.Event.CanRepairItem(repairEntityId, itemSlot, true)
  if not canRepair then
    return
  end
  local durabilityToRepair = maxDurability
  if type(itemTable.durability) == "number" then
    durabilityToRepair = maxDurability - itemTable.durability
  end
  if durabilityToRepair <= 0 then
    return
  end
  self.repairKitItemInstanceId = self.ItemLayout:GetItemInstanceId()
  self.repairKitSlotIndex = slotIndex
  if self.isSplittingStackModifierActive then
    self:OnRepairKitConfirm()
    return
  end
  local descriptionLocTag = "@crafting_repair_requires_kit"
  local repairKitsForItem = ItemRepairRequestBus.Event.GetRepairKitsForSlot(repairEntityId, itemSlot)
  if repairKitsForItem == nil or #repairKitsForItem == 0 then
    return
  end
  local repairKit = repairKitsForItem[1]
  local kitData = ItemDataManagerBus.Broadcast.GetItemData(repairKit.itemId)
  local repairKitTooltipReplacements = {}
  repairKitTooltipReplacements.quantityRequired = 1
  repairKitTooltipReplacements.tierNumber = kitData.tier
  repairKitTooltipReplacements.itemRequired = repairKit:GetDisplayName()
  local description = GetLocalizedReplacementText(descriptionLocTag, repairKitTooltipReplacements)
  local confirmationData = {
    title = "@inv_repair",
    description = description,
    confirmCallback = self.OnRepairKitConfirm,
    confirmCallbackTable = self,
    closeFlyout = true
  }
  local buttonRect = UiTransformBus.Event.GetViewportSpaceRect(self.entityId)
  local positionVector = Vector2(buttonRect:GetCenterX(), buttonRect:GetCenterY() - 24)
  DynamicBus.ConfirmationPopup.Broadcast.ShowConfirmationPopup(positionVector, confirmationData)
end
function ItemDraggable:OnRepairKitConfirm()
  if not self.repairKitItemInstanceId or not self.repairKitSlotIndex then
    return
  end
  DynamicBus.ItemRepairDynamicBus.Broadcast.OnItemRepaired(self.repairKitItemInstanceId)
  local isInPaperdoll = self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPPED or self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPMENT_WEAPON
  if self.isInInventory then
    LocalPlayerUIRequestsBus.Broadcast.RepairItem(self.repairKitSlotIndex, true)
  elseif isInPaperdoll then
    LocalPlayerUIRequestsBus.Broadcast.PaperdollRepairItem(self.repairKitSlotIndex, true)
  else
    LocalPlayerUIRequestsBus.Broadcast.StorageRepairItem(self.repairKitSlotIndex, false)
  end
  self.repairKitItemInstanceId = nil
  self.repairKitSlotIndex = nil
end
function ItemDraggable:HasItemClass(itemClass)
  local itemSlot = self.ItemLayout:GetItemContainerSlot()
  if not itemSlot or not itemSlot:IsValid() then
    return false
  else
    return itemSlot:HasItemClass(itemClass)
  end
end
function ItemDraggable:OnSalvage()
  local itemTable = self.ItemLayout:GetTooltipDisplayInfo()
  if not itemTable.canSalvage then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@tooltip_salvage_cannot"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  local inventoryIsFull = CommonDragDrop:GetInventorySlotsRemaining() <= 0
  if inventoryIsFull then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@inv_cannotsalvage_full"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  local isInPaperdoll = self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPPED or self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPMENT_WEAPON
  if isInPaperdoll then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@inv_cannotsalvage_equipped"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  local isInActiveContainer = false
  local containerId
  if self.isInInventory then
    containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  else
    containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
    isInActiveContainer = self.containerId == containerId
  end
  local slotIndex = self.ItemLayout:GetSlotName()
  local itemSlot = ContainerRequestBus.Event.GetSlot(containerId, slotIndex)
  if not itemSlot or not itemSlot:IsValid() then
    return
  end
  if itemSlot:IsLocked() then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@tooltip_unlock_salvage"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  local isLootContainer = itemSlot:HasItemClass(eItemClass_LootContainer)
  if isLootContainer then
    return
  end
  local isLootDrop = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop") and isInActiveContainer
  if isLootDrop then
    return
  end
  if not self.isInInventory then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local storageTransferType = GlobalStorageRequestBus.Event.GetCurrentGlobalStorageAllowTransactionType(playerEntityId)
    if storageTransferType ~= eGlobalStorageAllowTransactionType_AllowGiveAndTake then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@tooltip_salvage_remote"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      return
    end
  end
  local itemDescriptor = itemSlot:GetItemDescriptor()
  local salvageData
  local salvageIngredientList = CraftingRequestBus.Broadcast.GetSalvageOutputFromDescriptor(itemDescriptor, 1)
  if #salvageIngredientList == 0 and itemDescriptor ~= nil then
    salvageData = RecipeDataManagerBus.Broadcast.GetSalvageDataFromLootTable(itemDescriptor)
  end
  local salvageMin, salvageMax, salvageIngredientName
  local hasSalvageData = false
  if salvageIngredientList ~= nil and 0 < #salvageIngredientList then
    local salvageIngredient = salvageIngredientList[1]
    salvageIngredientName = salvageIngredient:GetDisplayName()
    salvageMin = math.floor(LocalPlayerUIRequestsBus.Broadcast.GetMinimumSalvagePercent() * salvageIngredient.quantity)
    salvageMax = math.floor(LocalPlayerUIRequestsBus.Broadcast.GetMaximumSalvagePercent() * salvageIngredient.quantity)
    local minQuantity = LocalPlayerUIRequestsBus.Broadcast.GetMinimumSalvageQuantity()
    if salvageMin < minQuantity then
      salvageMin = minQuantity
    end
    if salvageMax < salvageMin then
      salvageMax = salvageMin
    end
    hasSalvageData = true
  end
  if salvageData ~= nil and 0 < #salvageData then
    for i = 1, #salvageData do
      if salvageData[i].roll == 0 then
        local itemData = ItemDataManagerBus.Broadcast.GetItemData(Math.CreateCrc32(salvageData[i].itemId))
        salvageIngredientName = itemData.displayName
        salvageMin = salvageData[i].minQuantity
        salvageMax = salvageData[i].maxQuantity
        hasSalvageData = true
        self.salvageGuaranteedIndex = i
        break
      end
    end
  end
  if not hasSalvageData then
    return
  end
  self.salvageSlotIndex = slotIndex
  local quantity = self.ItemLayout:GetQuantity()
  if self.isSplittingStackModifierActive and not itemTable.confirmDestroy then
    self:OnSalvageConfirm(quantity)
    return
  end
  self.salvageRepairPartsQuantity = 0
  self.salvageRepairPartsToBeLost = 0
  local isRepair = false
  self.salvageRepairPartsQuantity = RecipeDataManagerBus.Broadcast.GetRepairDustQuantity(itemSlot, isRepair)
  if 0 < self.salvageRepairPartsQuantity then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local currentRepairParts = CategoricalProgressionRequestBus.Event.GetProgression(playerEntityId, 2817455512)
    local maxRepairParts = CategoricalProgressionRequestBus.Event.GetMaxPointsForCurrentRank(playerEntityId, 2817455512)
    local availableRepairParts = maxRepairParts - currentRepairParts
    local willLoseRepairParts = availableRepairParts < self.salvageRepairPartsQuantity
    if willLoseRepairParts then
      self.salvageRepairPartsToBeLost = self.salvageRepairPartsQuantity - availableRepairParts
    end
  end
  description = self:GetSalvageDescription(salvageMin, salvageMax, salvageIngredientName, itemDescriptor, salvageData)
  local confirmationData = {
    title = "@inv_salvage",
    description = description,
    confirmCallback = self.OnSalvageConfirm,
    confirmCallbackTable = self,
    closeFlyout = true,
    salvageData = salvageData,
    salvageGuaranteedIndex = self.salvageGuaranteedIndex
  }
  if 1 < quantity then
    confirmationData.sliderMax = quantity
    confirmationData.salvageMin = salvageMin
    confirmationData.salvageMax = salvageMax
    confirmationData.salvageItemName = salvageIngredientName
  end
  if 0 < self.salvageRepairPartsToBeLost then
    local atLimit = self.salvageRepairPartsToBeLost == self.salvageRepairPartsQuantity
    local salvageCount = atLimit and 0 or self.salvageRepairPartsQuantity - self.salvageRepairPartsToBeLost
    local salvageAdditionalString
    local gemPerk = itemDescriptor:GetGemPerk()
    local isTrinket = ItemCommon:IsTrinket(itemDescriptor.itemId)
    local hasGemInSlot = isTrinket and gemPerk ~= 0 and gemPerk ~= ItemCommon.EMPTY_GEM_SLOT_PERK_ID
    local gemMessage = hasGemInSlot and "@inv_salvage_tooltip_gemmessage" or ""
    if ItemDataManagerBus.Broadcast.CanSalvageResources(self.ItemLayout.itemId) then
      local resourceRange = atLimit and "@inv_repairparts_resources_atlimit" or "@inv_repairparts_resources_nearlimit"
      salvageAdditionalString = GetLocalizedReplacementText(resourceRange, {
        min = salvageMin,
        max = salvageMax,
        itemName = salvageIngredientName,
        numRepairParts = salvageCount
      })
      confirmationData.description = atLimit and "@inv_repairparts_atlimit " .. salvageAdditionalString .. " " .. gemMessage or "@inv_repairparts_nearlimit" .. " " .. salvageAdditionalString .. " " .. gemMessage
    else
      salvageAdditionalString = atLimit and "@inv_repairparts_atlimit" or "@inv_repairparts_nearlimit"
      local salvageSecondaryString = GetLocalizedReplacementText("@inv_repairparts_onlyrepairparts", {numRepairParts = salvageCount})
      if atLimit then
        confirmationData.description = salvageAdditionalString .. " " .. "<font color=" .. ColorRgbaToHexString(UIStyle.COLOR_RED) .. ">" .. salvageSecondaryString .. "</font>" .. " " .. gemMessage
      else
        confirmationData.description = salvageAdditionalString .. " " .. salvageSecondaryString .. " " .. gemMessage
      end
    end
  end
  local buttonRect = UiTransformBus.Event.GetViewportSpaceRect(self.entityId)
  local positionVector = Vector2(buttonRect:GetCenterX(), buttonRect:GetCenterY() - 24)
  DynamicBus.ConfirmationPopup.Broadcast.ShowConfirmationPopup(positionVector, confirmationData)
end
function ItemDraggable:OnSalvageConfirm(quantity)
  if not self.salvageSlotIndex then
    return
  end
  quantity = quantity or 1
  if self.isInInventory then
    local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    LocalPlayerUIRequestsBus.Broadcast.SalvageItem(self.salvageSlotIndex, quantity, inventoryId)
  else
    local containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
    LocalPlayerUIRequestsBus.Broadcast.SalvageItem(self.salvageSlotIndex, quantity, containerId)
  end
  self.salvageSlotIndex = nil
end
function ItemDraggable:GetSalvageDescription(minQuantity, maxQuantity, salvageIngredientName, itemDescriptor, salvageData)
  local descriptionLocTag = ""
  local descriptionReplacements = {}
  if minQuantity ~= maxQuantity then
    descriptionLocTag = "@inv_salvage_tooltip_range"
    descriptionReplacements.min = minQuantity
    descriptionReplacements.max = maxQuantity
    descriptionReplacements.itemName = salvageIngredientName
  else
    descriptionLocTag = "@inv_salvage_tooltip"
    descriptionReplacements.numItems = minQuantity
    descriptionReplacements.itemName = salvageIngredientName
  end
  if self.salvageRepairPartsQuantity > 0 then
    local itemTable = self.ItemLayout:GetTooltipDisplayInfo()
    local durabilityPercent = 0 < itemTable.maxDurability and itemTable.durability / itemTable.maxDurability or 1
    local coinSalvageAmount = GameEventRequestBus.Broadcast.GetSalvageCoinAmount(itemDescriptor:GetItemKey(), durabilityPercent)
    if ItemDataManagerBus.Broadcast.CanSalvageResources(self.ItemLayout.itemId) then
      descriptionLocTag = descriptionLocTag .. "_withrepairparts"
    elseif 0 < coinSalvageAmount then
      descriptionLocTag = "@inv_salvage_tooltip_repairparts_and_coin"
      descriptionReplacements.coinAmount = GetLocalizedReplacementText("@ui_coin_icon", {
        coin = GetLocalizedCurrency(coinSalvageAmount)
      })
    else
      descriptionLocTag = "@inv_salvage_tooltip_onlyrepairparts"
    end
    descriptionReplacements.numRepairParts = self.salvageRepairPartsQuantity
  end
  local salvageItemData = ItemDataManagerBus.Broadcast.GetItemData(self.ItemLayout.itemId)
  if salvageItemData.salvageAchievementId ~= 0 then
    local recipeId = RecipeDataManagerBus.Broadcast.GetRecipeIdByAchievementId(salvageItemData.salvageAchievementId)
    local recipeData = RecipeDataManagerBus.Broadcast.GetCraftingRecipeDataById(recipeId)
    local isProcedural = RecipeDataManagerBus.Broadcast.IsRecipeProcedural(recipeId)
    local itemData, displayName
    if isProcedural then
      local resultItemId = CraftingRequestBus.Broadcast.GetProceduralCraftingResult(recipeId, vector_Crc32())
      itemData = ItemDataManagerBus.Broadcast.GetItemData(resultItemId)
      displayName = recipeData.name
    else
      itemData = ItemDataManagerBus.Broadcast.GetItemData(Math.CreateCrc32(recipeData.resultItemId))
      displayName = itemData.displayName
    end
    descriptionLocTag = GetLocalizedReplacementText("@inv_salvage_tooltip_recipe", {recipeName = displayName})
  end
  local isTrinket = ItemCommon:IsTrinket(itemDescriptor.itemId)
  local gemPerk = itemDescriptor:GetGemPerk()
  local hasGemInSlot = isTrinket and gemPerk ~= 0 and gemPerk ~= ItemCommon.EMPTY_GEM_SLOT_PERK_ID
  descriptionReplacements.gemMessage = hasGemInSlot and "@inv_salvage_tooltip_gemmessage" or ""
  if salvageData and 1 < #salvageData then
    for i = 1, #salvageData do
      if self.salvageGuaranteedIndex ~= i then
        local itemData = ItemDataManagerBus.Broadcast.GetItemData(Math.CreateCrc32(salvageData[i].itemId))
        descriptionReplacements.gemMessage = GetLocalizedReplacementText("@inv_salvage_tooltip_additional_item", {
          itemData.displayName
        })
        break
      end
    end
  end
  return GetLocalizedReplacementText(descriptionLocTag, descriptionReplacements)
end
function ItemDraggable:OnSalvageLock()
  local itemTable = self.ItemLayout:GetTooltipDisplayInfo()
  if not itemTable.canSalvage then
    return
  end
  local isInPaperdoll = self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPPED or self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPMENT_WEAPON
  local isInActiveContainer = false
  local containerId
  if self.isInInventory then
    containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  else
    containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
    isInActiveContainer = self.containerId == containerId
  end
  local slotIndex = self.ItemLayout:GetSlotName()
  local itemSlot
  if isInPaperdoll then
    itemSlot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotIndex)
  else
    itemSlot = ContainerRequestBus.Event.GetSlot(containerId, slotIndex)
  end
  if not itemSlot or not itemSlot:IsValid() then
    return
  end
  local isLootContainer = itemSlot:HasItemClass(eItemClass_LootContainer)
  if isLootContainer then
    return
  end
  local isLootDrop = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop") and isInActiveContainer
  if isLootDrop then
    return
  end
  local itemLocation = ItemLocation()
  itemLocation.containerType = eItemContainerType_None
  itemLocation.containerSlotId = slotIndex
  if self.isInInventory then
    itemLocation.containerType = eItemContainerType_Container
  elseif isInPaperdoll then
    itemLocation.containerType = eItemContainerType_Paperdoll
  elseif not isLootDrop then
    itemLocation.containerType = eItemContainerType_GlobalStorage
  end
  if itemLocation.containerType ~= eItemContainerType_None then
    itemLocation.itemInstanceId = itemSlot:GetItemInstanceId()
  end
  if not itemLocation.itemInstanceId:IsNull() then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    ItemRepairRequestBus.Event.RequestSetLockState(playerEntityId, itemLocation, not itemSlot:IsLocked())
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  end
end
function ItemDraggable:OnPressed()
  local isLinkingItem = DynamicBus.Inventory.Broadcast.IsItemLinkModifierActive()
  if isLinkingItem then
    return
  end
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  flyoutMenu:SetSourceHoverOnly(true)
  local drawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
  UiCanvasBus.Event.SetDrawOrder(self.canvasId, drawOrder + 1)
  self.savedDrawOrder = drawOrder
end
function ItemDraggable:OnReleased()
  if self.savedDrawOrder then
    UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.savedDrawOrder)
    self.savedDrawOrder = nil
  end
  if self.isFtue and self.isInInventoryTutorial then
    return
  end
  local isLinkingItem = DynamicBus.Inventory.Broadcast.IsItemLinkModifierActive()
  if isLinkingItem then
    self:OnLinkItem()
    return
  end
  local isQuickMoveModifierActive = DynamicBus.Inventory.Broadcast.IsQuickMoveModifierActive()
  if isQuickMoveModifierActive then
    if not DynamicBus.TradeScreen.Broadcast.IsInTradeSession() then
      self:OnStoreItem()
    end
    return
  end
  if not self.isStackSplitClone then
    local salvageDown = DynamicBus.Inventory.Broadcast.IsSalvageItemModifierActive()
    local salvageLockDown = DynamicBus.Inventory.Broadcast.IsSalvageLockItemModifierActive()
    local repairDown = DynamicBus.Inventory.Broadcast.IsRepairItemModifierActive()
    local repairKitDown = DynamicBus.Inventory.Broadcast.IsRepairKitItemModifierActive()
    if not self.isQuickMoveModifierActive and not self.isSelectedForTrade and not self.isInTradeContainer then
      if self.isSplittingStackModifierActive and not salvageDown and not repairDown and not repairKitDown then
        UiCanvasBus.Event.SetActiveInteractable(self.canvasId, EntityId(), false)
        self:InvokeStackSplitter()
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
      elseif repairDown and not repairKitDown and not salvageDown and not salvageLockDown then
        self:OnRepair()
      elseif repairKitDown and not repairDown and not salvageDown and not salvageLockDown then
        self:OnRepairKit()
      elseif salvageDown and not repairDown and not repairKitDown and not salvageLockDown then
        self:OnSalvage()
      elseif salvageLockDown and not repairDown and not repairKitDown and not salvageDown then
        self:OnSalvageLock()
      else
        local flyoutVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible")
        if flyoutVisible then
          local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
          flyoutMenu:SetSourceHoverOnly(false)
          flyoutMenu:Lock()
        elseif not self.dragStartMouse and not self.dragEndMouse then
          self.lockFlyoutOnOpen = true
        end
        self:ClearDragMouse()
      end
    end
  end
end
function ItemDraggable:OnFlyoutMenuClosed()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  flyoutMenu:Unlock()
  self.lockFlyoutOnOpen = false
end
function ItemDraggable:UpdateAnimatedIndicator()
  self.ItemLayout:UpdateAnimatedIndicator()
end
function ItemDraggable:OnHoverStart()
  if self.isProxy then
    return
  end
  if self.inventoryTable and self.isInInventory then
    self.inventoryTable:MarkDraggableItemSeen(self)
  else
    self.ItemLayout:SetNewIndicatorVisible(false)
  end
  self.ItemLayout:OnFocus()
  if self.isStackSplitClone then
    return
  end
  if self.ItemLayout.mItemData_isValid and not g_isDragging then
    if not self:CanShowTooltip() then
      return
    end
    hoverIntentDetector:OnHoverDetected(self, self.TryShowTooltip)
  end
end
function ItemDraggable:CanShowTooltip()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu:IsLocked() then
    return false
  end
  local dropThreshold = 0.1
  local timeSinceLastDrop = WallClockTimePoint():Now():Subtract(g_lastDropTime):ToSecondsUnrounded()
  if dropThreshold > timeSinceLastDrop then
    return false
  end
  return true
end
function ItemDraggable:TryShowTooltip()
  if not self:CanShowTooltip() then
    return
  end
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  local tooltipClosedInSec = 3
  local tooltipJustClosedTolerance = 1
  if flyoutMenu.lastClosedTime then
    tooltipClosedInSec = timeHelpers:ServerNow():Subtract(flyoutMenu.lastClosedTime):ToSeconds()
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local flyoutVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible")
  local showInstantly = flyoutVisible or tooltipJustClosedTolerance > tooltipClosedInSec
  if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
    local rows = {}
    local thisItemTdi = self.ItemLayout:GetTooltipDisplayInfo()
    thisItemTdi.isSelectedForTrade = self.isSelectedForTrade
    if not self.isInTradeContainer then
      local isInPaperdoll = self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPPED or self.ItemLayout.mCurrentMode == self.ItemLayout.MODE_TYPE_EQUIPMENT_WEAPON
      table.insert(rows, {
        slicePath = "LyShineUI/Tooltip/DynamicTooltip",
        itemTable = thisItemTdi,
        itemInstanceId = self.ItemLayout:GetItemInstanceId(),
        isInPaperdoll = isInPaperdoll,
        inventoryTable = self.inventoryTable,
        slotIndex = self.ItemLayout:GetSlotName(),
        draggableItem = self,
        showInstantly = showInstantly,
        doDefaultCompare = true
      })
    else
      table.insert(rows, {
        slicePath = "LyShineUI/Tooltip/DynamicTooltip",
        itemTable = thisItemTdi,
        showInstantly = showInstantly
      })
    end
    flyoutMenu:SetFadeInTime(showInstantly and 0.05 or 0.15)
    flyoutMenu:SetOpenLocation(self.entityId, flyoutMenu.PREFER_RIGHT, self.ItemLayout:GetCurrentScale())
    flyoutMenu:SetClosedCallback(self, self.OnFlyoutMenuClosed)
    flyoutMenu:SetRowData(rows)
    flyoutMenu:DockToCursor(10, true)
    if self.lockFlyoutOnOpen then
      flyoutMenu:Lock()
      flyoutMenu:SetSourceHoverOnly(false)
      self.lockFlyoutOnOpen = false
    else
      flyoutMenu:Unlock()
      flyoutMenu:SetSourceHoverOnly(true)
    end
  end
end
function ItemDraggable:OnHoverEnd()
  if self.isProxy then
    return
  end
  self.ItemLayout:OnUnfocus()
  timingUtils:StopDelay(self)
  hoverIntentDetector:StopHoverDetected(self)
  self.lockFlyoutOnOpen = false
end
function ItemDraggable:OnCryAction(actionName, value)
  if g_isDragging == false then
    if actionName == "ui_quickMoveItemModifierDown" then
      self.isQuickMoveModifierActive = true
    elseif actionName == "ui_quickMoveItemModifierUp" then
      self.isQuickMoveModifierActive = false
    elseif actionName == "ui_splitItemStackModifierDown" then
      self.isSplittingStackModifierActive = true
    elseif actionName == "ui_splitItemStackModifierUp" then
      self.isSplittingStackModifierActive = false
    end
    if self.isSplittingStackModifierActive and not self.isStackSplitClone and not self.isProxy then
      if self.draggableHandler then
        self:BusDisconnect(self.draggableHandler)
        self.draggableHandler = nil
      end
    elseif not self.draggableHandler then
      self.draggableHandler = self:BusConnect(UiDraggableNotificationBus, self.entityId)
    end
  end
end
function ItemDraggable:OnDragStart(position)
  if not LocalPlayerUIRequestsBus.Broadcast.IsItemTransferEnabled() or not self.canDrag then
    return
  end
  Log(self.logSettings, "IBC: ItemDraggable OnDragStart")
  self.dragStartMouse = UiCursorBus.Broadcast.GetUiCursorPosition()
  self.isProxy = UiDraggableBus.Event.IsProxy(self.entityId)
  if self.isProxy == nil then
    Log(self.logSettings, "IBC: ItemDraggable isProxy == nil")
    self.isProxy = true
  end
  Log(self.logSettings, "IBC: ItemDraggable isProxy = " .. (self.isProxy and "true" or "false"))
  UiDraggableBus.Event.SetCanDropOnAnyCanvas(self.entityId, true)
  if g_isDragging then
    Log(self.logSettings, "IBC: ItemDraggable already dragging something returning early")
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  self:HideStackSplitter()
  if not self.isProxy then
    if self.isSplittingStackModifierActive and not self.isStackSplitClone then
      return
    end
    if self.isInTradeContainer then
      local slotId = self.ItemLayout:GetSlotName()
      local stackSize = self.ItemLayout:GetQuantity()
      local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerType", eItemDragContext_TradeScreen)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerId", inventoryId)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerSlotId", slotId)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.StackSize", stackSize)
    end
    g_isDragging = true
    self.dragCanvas = UiCanvasManagerBus.Broadcast.CreateCanvas()
    if self.dragCanvas:IsValid() then
      Log(self.logSettings, "IBC: ItemDraggable drag canvas is valid")
      UiCanvasBus.Event.SetDrawOrder(self.dragCanvas, 999)
      UiCanvasBus.Event.SetCanvasSize(self.dragCanvas, Vector2(1920, 1080))
      self.clonedElement = UiCanvasBus.Event.CloneElement(self.dragCanvas, self.entityId, EntityId(), EntityId())
      if self.clonedElement:IsValid() then
        self.dataLayer:RegisterEntity("CurrentDraggable", self.clonedElement)
        local clonedTable = self.registrar:GetEntityTable(self.clonedElement)
        clonedTable.ItemLayout:ConnectContainerBus(self.clonedElement)
        clonedTable.ItemLayout:DisableGemDropTarget()
        UiTransformBus.Event.SetScaleToDevice(self.clonedElement, true)
        if self.isStackSplitClone then
          local q = self.originalDraggableTable.ItemLayout:GetQuantity() - self.ItemLayout:GetQuantity()
          self.originalDraggableTable.ItemLayout:SetQuantity(q)
        end
        local anchors = UiTransform2dBus.Event.GetAnchors(self.clonedElement)
        local offsets = UiTransform2dBus.Event.GetOffsets(self.clonedElement)
        anchors.bottom = 0.5
        anchors.left = 0.5
        anchors.right = 0.5
        anchors.top = 0.5
        local halfDraggingSizeX = self.Properties.DraggingSize.x / 2
        local halfDraggingSizeY = self.Properties.DraggingSize.y / 2
        offsets.left = halfDraggingSizeX
        offsets.right = self.Properties.DraggingSize.x + halfDraggingSizeX
        offsets.top = halfDraggingSizeY
        offsets.bottom = self.Properties.DraggingSize.y + halfDraggingSizeY
        UiTransform2dBus.Event.SetAnchors(self.clonedElement, anchors, true, false)
        UiTransform2dBus.Event.SetOffsets(self.clonedElement, offsets)
        UiDraggableBus.Event.SetAsProxy(self.clonedElement, self.entityId, position)
        UiFaderBus.Event.SetFadeValue(self.entityId, 0.5)
        local draggedItemDataNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.ItemDragging")
        if draggedItemDataNode then
          local containerType = draggedItemDataNode.ContainerType:GetData()
          local slotId = draggedItemDataNode.ContainerSlotId:GetData()
          local containerId = draggedItemDataNode.ContainerId:GetData()
          local itemSlot
          if containerType == eItemDragContext_Inventory or containerType == eItemDragContext_Container then
            itemSlot = ContainerRequestBus.Event.GetSlot(containerId, slotId)
          elseif containerType == eItemDragContext_Paperdoll then
            itemSlot = PaperdollRequestBus.Event.GetSlot(containerId, slotId)
          end
          if itemSlot then
            DynamicBus.ItemLayoutSlotProvider.Event.SetItemAndSlotProvider(self.clonedElement, itemSlot, tostring(slotId), function()
              return nil
            end)
            local stackSize = self.ItemLayout:GetQuantity()
            local remainSize = stackSize
            if self.isSplittingStackModifierActive and not self.isStackSplitClone then
              stackSize = math.max(1, math.floor(stackSize / 2))
              remainSize = remainSize - stackSize
            end
            if stackSize then
              clonedTable.ItemLayout:SetQuantityText(tostring(stackSize))
              self.ItemLayout:SetQuantityText(tostring(remainSize))
              LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.StackSize", stackSize)
            end
            local equipSlots = itemSlot:GetEquipSlots()
            LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Paperdoll.EquipmentSlotsToHighlight", equipSlots)
            if containerType == eItemDragContext_Inventory or containerType == eItemDragContext_Container then
              local gemSlotId = -1
              if itemSlot:HasItemClass(eItemClass_Gem) and not self.isStackSplitClone then
                gemSlotId = slotId
                self.isSlottableGem = true
              end
              LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.GemSlotId", gemSlotId)
            end
            if containerType == eItemDragContext_Inventory then
              local repairKitSlotId = -1
              local repairKitTier = -1
              if itemSlot:HasItemClass(eItemClass_RepairKit) and not self.isStackSplitClone then
                repairKitTier = itemSlot:GetTierNumber()
                repairKitSlotId = slotId
                self.isRepairKit = true
              end
              LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.RepairKitTier", repairKitTier)
              LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.RepairKitSlotId", repairKitSlotId)
            end
          else
            Log(self.logSettings, "IBC: ItemDraggable, itemSlot is nil")
          end
          if self.isStackSplitClone then
            UiElementBus.Event.SetIsEnabled(self.entityId, false)
            UiFaderBus.Event.SetFadeValue(self.originalDraggableTable.entityId, 0.5)
          end
        else
          Log(self.logSettings, "IBC: ItemDraggable, draggedItemDataNode was nil?")
        end
      else
        Log(self.logSettings, "IBC: ItemDraggable, self.clonedElement is nil, clone failed?")
      end
    else
      Log(self.logSettings, "IBC: ItemDraggable dragcanvas is nil")
    end
  else
    UiTransformBus.Event.SetViewportPosition(self.entityId, position)
  end
  Log(self.logSettings, "IBC: ItemDraggable OnDragStart, complete")
end
function ItemDraggable:ClearDragMouse()
  self.dragStartMouse = nil
  self.dragEndMouse = nil
end
function ItemDraggable:OnDrag(position)
  if self.isProxy then
    UiTransformBus.Event.SetViewportPosition(self.entityId, position)
  end
end
function ItemDraggable:OnDragEnd(position)
  Log(self.logSettings, "IBC: ItemDraggable OnDragEnd, self.isProxy is " .. (self.isProxy and "true" or "false"))
  self.dragEndMouse = UiCursorBus.Broadcast.GetUiCursorPosition()
  if self.isProxy then
    UiDraggableBus.Event.ProxyDragEnd(self.entityId, position)
  else
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    UiCanvasBus.Event.SetActiveInteractable(canvasId, EntityId(), false)
    if not self.isSelectedForTrade then
      UiFaderBus.Event.SetFadeValue(self.entityId, 1)
    end
    if self.dragCanvas:IsValid() then
      if self.clonedElement:IsValid() then
        self.dataLayer:UnregisterEntity("CurrentDraggable")
        UiElementBus.Event.DestroyElement(self.clonedElement)
      else
        Log(self.logSettings, "IBC: ItemDraggable OnDragEnd, self.clonedElement was invalid")
      end
      UiCanvasManagerBus.Broadcast.UnloadCanvas(self.dragCanvas)
      self.dragCanvas = EntityId()
    end
    if self.isStackSplitClone then
      if self.originalDraggableTable then
        self.originalDraggableTable.ItemLayout:SetQuantityText(tostring(self.ItemLayout.mItemData_quantity))
      end
    else
      self.ItemLayout:SetQuantityText(tostring(self.ItemLayout.mItemData_quantity))
    end
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Paperdoll.ClearHighlight", true)
    if self.isSlottableGem then
      timingUtils:DelayFrames(1, self, function(self)
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.GemSlotId", -1)
      end)
      self.isSlottableGem = false
    end
    if self.isRepairKit then
      timingUtils:DelayFrames(1, self, function(self)
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.RepairKitTier", -1)
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.RepairKitSlotId", -1)
      end)
      self.isRepairKit = false
    end
  end
  g_isDragging = false
  g_lastDropTime = WallClockTimePoint():Now()
  UiDraggableBus.Event.SetCanDropOnAnyCanvas(self.entityId, false)
  Log(self.logSettings, "IBC: ItemDraggable OnDragEnd, complete")
  if self.isStackSplitClone then
    self:SetTicking(true)
    UiFaderBus.Event.SetFadeValue(self.originalDraggableTable.entityId, 1)
    self.tickForStackSplitClone = true
  end
  if self.isInMapStorageContainer then
    self:DisplayMinorNotification("@ui_global_storage_visit_storage_shed")
  end
end
function ItemDraggable:DisplayMinorNotification(notificationText)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = notificationText
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function ItemDraggable:SetIsSelectedForTrade(selected)
  if self.isSelectedForTrade ~= selected then
    self.isSelectedForTrade = selected
    local fadeValue = selected and 0.5 or 1
    UiFaderBus.Event.SetFadeValue(self.entityId, fadeValue)
  end
end
function ItemDraggable:IsSelectedForTrade()
  return self.isSelectedForTrade
end
function ItemDraggable:SetIsInTradeContainer(isInTradeContainer)
  self.isInTradeContainer = isInTradeContainer
end
function ItemDraggable:IsInTradeContainer(isInTradeContainer)
  return self.isInTradeContainer
end
function ItemDraggable:SetIsInMapStorageContainer(isInMapStorageContainer)
  self.isInMapStorageContainer = isInMapStorageContainer
end
function ItemDraggable:SetModeType(type)
  self.ItemLayout:SetModeType(type)
end
function ItemDraggable:SetIsStackSplitClone(originalDraggableTable)
  self.isStackSplitClone = true
  self.originalDraggableTable = originalDraggableTable
end
function ItemDraggable:OnTick(deltaTime)
  if self.tickForStackSplitClone then
    self:SetTicking(false)
    UiElementBus.Event.DestroyElement(self.entityId)
    self.tickForStackSplitClone = false
  end
end
function ItemDraggable:SetTicking(isTicking)
  if isTicking then
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  elseif self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function ItemDraggable:SetInventoryTutorialActive(isActive)
  self.isInInventoryTutorial = isActive
end
return ItemDraggable

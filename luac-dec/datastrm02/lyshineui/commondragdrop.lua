local registrar = RequireScript("LyShineUI.EntityRegistrar")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local CommonDragDrop = {
  draggableData = {},
  MAX_INVENTORY_SLOTS = 0,
  INVENTORY_SLOTS_WARNING_THRESHOLD = 10,
  INVENTORY_MIN_TIME_BETWEEN_NOTIFICATIONS = 5000
}
function CommonDragDrop:OnDropHoverStart(entityId, draggable, alwaysValid)
  if UiDraggableBus.Event.IsProxy(draggable) then
    if alwaysValid or UiElementBus.Event.GetNumChildElements(entityId) <= 0 then
      UiDraggableBus.Event.SetDragState(draggable, eUiDragState_Valid)
      UiDropTargetBus.Event.SetDropState(entityId, eUiDropState_Valid)
    else
      UiDraggableBus.Event.SetDragState(draggable, eUiDragState_Invalid)
      UiDropTargetBus.Event.SetDropState(entityId, eUiDropState_Invalid)
    end
  end
end
function CommonDragDrop:OnDropHoverEnd(entityId, draggable)
  UiDraggableBus.Event.SetDragState(draggable, eUiDragState_Normal)
  UiDropTargetBus.Event.SetDropState(entityId, eUiDropState_Normal)
end
function CommonDragDrop:IsValidDrop(draggable)
  if not draggable then
    return false
  end
  local draggableTable = registrar:GetEntityTable(draggable)
  if not draggableTable or draggableTable.Properties.ItemLayout == nil then
    return false
  end
  local isProxy = UiDraggableBus.Event.IsProxy(draggable)
  if isProxy == nil then
    isProxy = true
  end
  if draggableTable.dragStartMouse and draggableTable.dragEndMouse and draggableTable.dragStartMouse.x == draggableTable.dragEndMouse.x and draggableTable.dragStartMouse.y == draggableTable.dragEndMouse.y then
    return false
  end
  local draggableData = self:GetDraggableData()
  if draggableData then
    local sourceSlotId = draggableData.sourceSlotId
    local containerType = draggableData.containerType
    if containerType == eItemDragContext_TradeScreen then
      DynamicBus.TradeScreen.Broadcast.RemoveItem(sourceSlotId)
      return false
    end
  end
  if draggableTable:IsSelectedForTrade() or draggableTable:IsInTradeContainer() then
    return false
  end
  return not isProxy and UiElementBus.Event.GetCanvas(draggable)
end
function CommonDragDrop:OnInventoryDrop(draggable, targetSlotId)
  if self:IsValidDrop(draggable) then
    local draggableData = self:GetDraggableData()
    if draggableData then
      local sourceContainerId = draggableData.sourceContainerId
      local sourceSlotId = draggableData.sourceSlotId
      local containerType = draggableData.containerType
      local stackSize = draggableData.stackSize
      if containerType == eItemDragContext_Inventory then
        LocalPlayerUIRequestsBus.Broadcast.InventoryMoveStack(tonumber(sourceSlotId), targetSlotId, stackSize)
      elseif containerType == eItemDragContext_Container then
        local sourceSlot = ContainerRequestBus.Event.GetSlot(sourceContainerId, sourceSlotId)
        local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
        local globalStorageEntityId = PlayerComponentRequestsBus.Event.GetGlobalStorageEntityId(playerEntityId)
        local isPersonalStorage = globalStorageEntityId == sourceContainerId
        if isPersonalStorage then
          DynamicBus.CatContainer.Broadcast.SetStorageTransferItemInfo(sourceContainerId, sourceSlot:GetItemInstanceId(), stackSize)
        end
        LocalPlayerUIRequestsBus.Broadcast.TradeBatchAddItem(false, tonumber(sourceSlotId), targetSlotId, sourceSlot, stackSize)
        LocalPlayerUIRequestsBus.Broadcast.TradeBatchExecute(tonumber(sourceSlotId), sourceContainerId)
      elseif containerType == eItemDragContext_Paperdoll then
        local inventoryId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
        local slotsLeft = self:GetInventorySlotsRemaining()
        if 0 < slotsLeft then
          local paperdollId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
          local isSlotBlocked = PaperdollRequestBus.Event.SlotBlockedByCooldown(paperdollId, tonumber(sourceSlotId))
          if isSlotBlocked then
            EquipmentCommon:TriggerEquipErrorNotification("@ui_equipment_cooldown_error")
          end
          LocalPlayerUIRequestsBus.Broadcast.UnequipItem(tonumber(sourceSlotId), targetSlotId, stackSize, inventoryId)
        end
      end
    end
  end
end
function CommonDragDrop:GetInventorySlotsRemaining()
  if self.MAX_INVENTORY_SLOTS == 0 then
    self.MAX_INVENTORY_SLOTS = ConfigProviderEventBus.Broadcast.GetInt("javelin.max-container-size")
    if self.MAX_INVENTORY_SLOTS == 0 then
      self.MAX_INVENTORY_SLOTS = 500
    end
  end
  local slotsUsed = dataLayer:GetDataFromNode("Hud.LocalPlayer.Inventory.TotalInventorySlotsUsed") or 0
  return self.MAX_INVENTORY_SLOTS - slotsUsed
end
function CommonDragDrop:GetDropMissionItemWarning()
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local currentMissionId = ObjectivesComponentRequestBus.Event.GetCurrentMissionObjectiveId(playerEntityId)
  local objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(currentMissionId)
  local failurePenaltyData = GameEventRequestBus.Broadcast.GetGameSystemData(objectiveData.failureGameEventId)
  local message = GetLocalizedReplacementText("@owg_drop_item_warning", {
    amount = tostring(failurePenaltyData.categoricalProgressionReward),
    guildName = DynamicBus.OWGDynamicRequestBus.Broadcast.GetGuildName(failurePenaltyData.categoricalProgressionId)
  })
  return message
end
function CommonDragDrop:OnContainerDrop(draggable, targetSlotId, targetContainerId, isLootDrop)
  if self:IsValidDrop(draggable) then
    local draggableData = self:GetDraggableData()
    if draggableData then
      do
        local sourceContainerId = draggableData.sourceContainerId
        local sourceSlotId = draggableData.sourceSlotId
        local containerType = draggableData.containerType
        local stackSize = draggableData.stackSize
        local canDrop = not ContainerRequestBus.Event.IsEncumbered(targetContainerId) or not ContainerRequestBus.Event.IsFullWhenEncumbered(targetContainerId)
        if not canDrop then
          local notificationData = NotificationData()
          notificationData.type = "Minor"
          notificationData.text = "@ui_storage_is_full"
          UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
          return
        end
        local function dropFunction(self)
          if containerType == eItemDragContext_Inventory or containerType == eItemDragContext_Container then
            LocalPlayerUIRequestsBus.Broadcast.PerformContainerTradeEntity(sourceContainerId, sourceSlotId, targetContainerId, targetSlotId, stackSize)
          elseif containerType == eItemDragContext_Paperdoll then
            local paperdollId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
            local isSlotBlocked = PaperdollRequestBus.Event.SlotBlockedByCooldown(paperdollId, tonumber(sourceSlotId))
            if isSlotBlocked then
              EquipmentCommon:TriggerEquipErrorNotification("@ui_equipment_cooldown_error")
            end
            LocalPlayerUIRequestsBus.Broadcast.UnequipItem(tonumber(sourceSlotId), targetSlotId, stackSize, targetContainerId)
          end
        end
        local targetItem
        if containerType == eItemDragContext_Inventory or containerType == eItemDragContext_Container then
          targetItem = ContainerRequestBus.Event.GetSlot(sourceContainerId, sourceSlotId)
        else
          local paperdollId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
          targetItem = PaperdollRequestBus.Event.GetSlot(paperdollId, sourceSlotId)
        end
        if not targetItem:IsValid() then
          dropFunction()
        else
          local staticItemData = StaticItemDataManager:GetItem(targetItem:GetItemId())
          if staticItemData.nonremovable and not targetItem:IsBoundToPlayer() then
            local notificationData = NotificationData()
            notificationData.type = "Minor"
            notificationData.text = "@ui_cantDropMissionItem"
            UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
          elseif targetItem:IsBoundToPlayer() and not ContainerRequestBus.Event.IsPlayerContainer(targetContainerId) then
            PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_destroyBoundItem", "@ui_destroyBoundItemMessage", "destroyItemDragDrop", self, function(self, result, eventId)
              if result == ePopupResult_Yes then
                dropFunction()
              end
            end)
          else
            dropFunction()
          end
        end
      end
    end
  end
end
function CommonDragDrop:GetDraggableData()
  ClearTable(self.draggableData)
  local draggedItemDataNode = dataLayer:GetDataNode("Hud.LocalPlayer.ItemDragging")
  if draggedItemDataNode then
    self.draggableData.sourceContainerId = draggedItemDataNode.ContainerId:GetData()
    self.draggableData.sourceSlotId = draggedItemDataNode.ContainerSlotId:GetData()
    self.draggableData.containerType = draggedItemDataNode.ContainerType:GetData()
    self.draggableData.stackSize = draggedItemDataNode.StackSize:GetData() or 1
    return self.draggableData
  end
  return nil
end
function CommonDragDrop:GetTargetSlotId(dropTargetEntityId)
  local slotContainer = UiElementBus.Event.GetParent(dropTargetEntityId)
  local targetSlotId = UiElementBus.Event.GetIndexOfChildByEntityId(slotContainer, dropTargetEntityId)
  return targetSlotId
end
return CommonDragDrop

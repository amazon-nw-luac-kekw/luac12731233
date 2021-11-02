local ItemContainerList = {
  Properties = {
    DropTargetSpawner = {
      default = EntityId()
    },
    DraggableSpawner = {
      default = EntityId()
    }
  },
  currentCapacity = 0,
  enableBreadcrumbs = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ItemContainerList)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function ItemContainerList:OnInit()
  BaseElement.OnInit(self)
  self.spawnTickets = {}
  self.deferredSpawns = {}
  self:BusConnect(ItemListBus, self.entityId)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.DropTargetSpawner)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.DraggableSpawner)
  self:BusConnect(DynamicBus.UITickBus)
  self.dataLayer = dataLayer
  self.dataLayer:RegisterObserver(self, "UIFeatures.g_uiItemBreadcrumbsActive", function(self, dataNode)
    self.enableBreadcrumbs = dataNode:GetData()
  end)
  self.enableBreadcrumbs = self.dataLayer:GetDataNode("UIFeatures.g_uiItemBreadcrumbsActive"):GetData()
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList OnActivate")
  end
end
function ItemContainerList:OnShutdown()
  self:UnbindFromContainer()
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList OnDeactivate")
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObserver(self, "UIFeatures.g_uiItemBreadcrumbsActive")
    self.dataLayer = nil
  end
end
function ItemContainerList:OnTick(deltaTime, timePoint)
  for i = 1, #self.deferredSpawns do
    local spawnData = self.deferredSpawns[i]
    self:SetItem(spawnData.slotIndex, spawnData.item, spawnData.isItemDescriptor, spawnData.entityIdCallback)
    if self.enableBreadcrumbs then
      Debug.Log("IBC: ItemContainerList OnTick, deferred spawn for slotIndex = " .. spawnData.slotIndex)
    end
  end
  if #self.deferredSpawns > 0 then
    self.deferredSpawns = {}
  end
end
function ItemContainerList:BindToContainer(containerId, maxDisplayNum)
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList BindToContainer")
  end
  self.containerId = containerId
  self.containerEventHandler = ContainerEventBus.Connect(self, containerId)
  self.maxDisplayNum = maxDisplayNum
  self:RefreshContainer()
end
function ItemContainerList:UnbindFromContainer()
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList UnbindFromContainer")
  end
  if self.containerEventHandler then
    self.containerEventHandler:Disconnect()
    self.containerEventHandler = nil
  end
  self.containerId = nil
  self.spawnTickets = {}
  self.deferredSpawns = {}
end
function ItemContainerList:RefreshContainer()
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList RefreshContainer")
  end
  if self.containerId then
    local numContainerSlots = ContainerRequestBus.Event.GetNumSlots(self.containerId)
    local numDisplaySlots = numContainerSlots
    if self.maxDisplayNum > 0 and numDisplaySlots > self.maxDisplayNum then
      numDisplaySlots = self.maxDisplayNum
    end
    self:SetCapacity(numDisplaySlots)
    local displayOnlyFilledSlots = self.maxDisplayNum > 0
    if displayOnlyFilledSlots then
      local numSlotsShown = 0
      for i = 0, numContainerSlots - 1 do
        local slot = ContainerRequestBus.Event.GetSlot(self.containerId, tostring(i))
        local isSlotValid = slot and slot:IsValid()
        if isSlotValid then
          self:OnContainerSlotChanged(numSlotsShown, slot:GetItemDescriptor())
          numSlotsShown = numSlotsShown + 1
          if numSlotsShown == numDisplaySlots - 1 then
            break
          end
        end
      end
    else
      for i = 0, numDisplaySlots - 1 do
        local slot = ContainerRequestBus.Event.GetSlot(self.containerId, tostring(i))
        self:OnContainerSlotChanged(i, slot:GetItemDescriptor())
      end
    end
  elseif self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList:RefreshContainer containerId is nil")
  end
end
function ItemContainerList:GetGridHeight(gridEntityId, numCells)
  if numCells == 0 then
    return 0
  end
  local cellSize = UiLayoutGridBus.Event.GetCellSize(gridEntityId)
  local gridSpacing = UiLayoutGridBus.Event.GetSpacing(gridEntityId)
  local contentOffsets = UiTransform2dBus.Event.GetOffsets(gridEntityId)
  local gridWidth = contentOffsets.right - contentOffsets.left
  local columnCount = math.floor((gridWidth + gridSpacing.x) / (cellSize.x + gridSpacing.x))
  if columnCount == 0 then
    return 0
  end
  local rowCount = numCells / columnCount
  if 0 < numCells % columnCount then
    rowCount = rowCount + 1
  end
  local gridHeight = rowCount * cellSize.y + gridSpacing.y * (rowCount - 1)
  return gridHeight
end
function ItemContainerList:TrySpawnDraggable(localSlotId, item, isDescriptor, entityIdCallback)
  for _, data in pairs(self.spawnTickets) do
    if data.isDraggable and data.slotIndex == localSlotId then
      if self.enableBreadcrumbs then
        Debug.Log("IBC: ItemContainerList:TrySpawnDraggable item already spawning for this slot, " .. localSlotId)
      end
      data.item = item
      data.isItemDescriptor = isDescriptor
      data.entityIdCallback = entityIdCallback
      return
    end
  end
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList:TrySpawnDraggable need to spawn draggable, for slot " .. localSlotId)
  end
  local spawnTicket = UiSpawnerBus.Event.Spawn(self.Properties.DraggableSpawner)
  self.spawnTickets[spawnTicket] = {
    isDraggable = true,
    slotIndex = localSlotId,
    item = item,
    isItemDescriptor = isDescriptor,
    entityIdCallback = entityIdCallback
  }
end
function ItemContainerList:SetDraggableItem(draggableItem, localSlotId, item, isDescriptor)
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList:SetDraggableItem item already exists for " .. localSlotId .. " , so we'll set existing draggable's data")
  end
  ItemContainerBus.Event.SetSlotName(draggableItem, tostring(localSlotId))
  if isDescriptor then
    ItemContainerBus.Event.SetItemByDescriptor(draggableItem, item)
  else
    ItemContainerBus.Event.SetItem(draggableItem, item)
  end
end
function ItemContainerList:SetItem(localSlotId, item, isDescriptor, entityIdCallback)
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList:SetItem start")
  end
  if not item or not item:IsValid() then
    if self.enableBreadcrumbs then
      Debug.Log("IBC: ItemContainerList:SetItem item was nil or invalid")
    end
    return
  end
  self:SetCapacity(math.max(self.currentCapacity, localSlotId + 1))
  local dropTargetId = UiElementBus.Event.GetChild(self.entityId, localSlotId)
  if dropTargetId and dropTargetId:IsValid() then
    if self.enableBreadcrumbs then
      Debug.Log("IBC: ItemContainerList:SetItem dropTarget valid or unneeded")
    end
    local draggableItem = UiElementBus.Event.GetChild(dropTargetId, 0)
    if not draggableItem or draggableItem:IsValid() == false then
      self:TrySpawnDraggable(localSlotId, item, isDescriptor, entityIdCallback)
    else
      self:SetDraggableItem(draggableItem, tostring(localSlotId), item, isDescriptor)
      if entityIdCallback then
        entityIdCallback(draggableItem, item)
      end
    end
  else
    if self.enableBreadcrumbs then
      Debug.Log("IBC: ItemContainerList:SetItem No droptarget")
    end
    local isDropTargetCurrentlySpawning = false
    for ticketKey, data in pairs(self.spawnTickets) do
      if data.slotIndex == localSlotId then
        isDropTargetCurrentlySpawning = true
        data.spawnDraggable = true
        data.item = item
        data.isItemDescriptor = isDescriptor
        data.entityIdCallback = entityIdCallback
        if self.enableBreadcrumbs then
          Debug.Log("IBC: ItemContainerList:SetItem Droptarget is currently spawning, will spawn our draggble when it's done")
        end
        break
      end
    end
    if not isDropTargetCurrentlySpawning then
      Debug.Log("ItemContainerList - SetItem tried adding draggable item to slot id " .. localSlotId .. " , but no drop target exists here. Likely container has bad capacity")
    end
  end
end
function ItemContainerList:ClearItem(localSlotId)
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList:ClearItem slotId " .. localSlotId)
  end
  for ticketKey, data in pairs(self.spawnTickets) do
    if data.slotIndex == localSlotId and data.isDraggable then
      self.spawnTickets[ticketKey] = nil
      if self.enableBreadcrumbs then
        Debug.Log("IBC: ItemContainerList:ClearItem cleared ticket slotId " .. localSlotId)
      end
    end
  end
  local dropTargetId = UiElementBus.Event.GetChild(self.entityId, localSlotId)
  if dropTargetId then
    local draggableSlot = UiElementBus.Event.GetChild(dropTargetId, 0)
    if draggableSlot then
      UiElementBus.Event.DestroyElement(draggableSlot)
      if self.enableBreadcrumbs then
        Debug.Log("IBC: ItemContainerList:ClearItem draggable slot destroyed for slotId " .. localSlotId)
      end
    elseif self.enableBreadcrumbs then
      Debug.Log("IBC: ItemContainerList:ClearItem draggable slot not found for slotId " .. localSlotId)
    end
  elseif self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList:ClearItem invalid dropTargetId being cleared for slotId " .. localSlotId)
  end
end
function ItemContainerList:GetCapacity()
  return self.currentCapacity
end
function ItemContainerList:SetCapacity(capacity)
  self.currentCapacity = capacity
  local numChildren = UiElementBus.Event.GetNumChildElements(self.entityId)
  local totalChildren = numChildren + CountAssociativeTable(self.spawnTickets)
  if totalChildren < self.currentCapacity then
    for i = totalChildren, self.currentCapacity do
      local spawnTicket = UiSpawnerBus.Event.Spawn(self.Properties.DropTargetSpawner)
      self.spawnTickets[spawnTicket] = {slotIndex = i}
    end
  end
  for i = 0, numChildren - 1 do
    local dropTarget = UiElementBus.Event.GetChild(self.entityId, i)
    UiElementBus.Event.SetIsEnabled(dropTarget, i < self.currentCapacity)
  end
end
function ItemContainerList:GetContainerEntityId()
  local entityId = EntityId()
  if self.containerId then
    entityId = self.containerId
  end
  return entityId
end
function ItemContainerList:OnContainerSlotChanged(localSlotId, newItemDescriptor, oldItemDescriptor)
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList:OnContainerSlotChanged for slotId " .. localSlotId)
  end
  local isValid = newItemDescriptor and newItemDescriptor:IsValid()
  if isValid then
    self:SetItem(localSlotId, newItemDescriptor, true)
    if self.enableBreadcrumbs then
      Debug.Log("IBC: ItemContainerList:OnContainerSlotChanged for slotId " .. localSlotId .. " SetItemFinish")
    end
  else
    self:ClearItem(localSlotId)
    if self.enableBreadcrumbs then
      Debug.Log("IBC: ItemContainerList:OnContainerSlotChanged for slotId " .. localSlotId .. " ClearItemFinish")
    end
  end
end
function ItemContainerList:OnTopLevelEntitiesSpawned(ticket, entities)
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned")
  end
  local ticketData
  for ticketKey, data in pairs(self.spawnTickets) do
    if ticketKey == ticket then
      ticketData = data
      self.spawnTickets[ticketKey] = nil
      break
    end
  end
  if ticketData == nil then
    if self.enableBreadcrumbs then
      Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned ticketData == nil, return early")
    end
    return
  end
  local rootEntity = entities[1]
  if self.enableBreadcrumbs and (not rootEntity or not rootEntity:IsValid()) then
    Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned Warning:rootEntity is invalid or nil!")
  end
  if not ticketData.isDraggable then
    if self.enableBreadcrumbs then
      Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned spawned dropTarget")
    end
    UiElementBus.Event.Reparent(rootEntity, self.entityId, EntityId())
    if ticketData.spawnDraggable then
      if self.enableBreadcrumbs then
        Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned queueing a draggable spawn for this dropTarget " .. ticketData.slotIndex)
      end
      table.insert(self.deferredSpawns, {
        isDraggable = true,
        slotIndex = ticketData.slotIndex,
        item = ticketData.item,
        isItemDescriptor = ticketData.isItemDescriptor,
        entityIdCallback = ticketData.entityIdCallback
      })
    end
  else
    if self.enableBreadcrumbs then
      Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned spawned draggable")
    end
    local dropTarget = UiElementBus.Event.GetChild(self.entityId, ticketData.slotIndex)
    if not dropTarget or dropTarget:IsValid() == false then
      Debug.Log("The ItemContainerlist tried to spawn a draggable to an invalid slot id " .. ticketData.slotIndex)
    else
      if self.enableBreadcrumbs then
        Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned setting new draggable item")
      end
      UiElementBus.Event.Reparent(rootEntity, dropTarget, EntityId())
      ItemContainerBus.Event.SetSlotName(rootEntity, tostring(ticketData.slotIndex))
      local itemLayoutTable = self.registrar:GetEntityTable(rootEntity)
      if itemLayoutTable and itemLayoutTable.ConnectContainerBus then
        itemLayoutTable:ConnectContainerBus(rootEntity)
      end
      if ticketData.isItemDescriptor then
        ItemContainerBus.Event.SetItemByDescriptor(rootEntity, ticketData.item)
      else
        ItemContainerBus.Event.SetItem(rootEntity, ticketData.item)
      end
      if UiElementBus.Event.GetParent(rootEntity) == self.Properties.DraggableSpawner then
        if self.enableBreadcrumbs then
          Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned WARNING: new draggable item failed to reparent!")
        end
        UiElementBus.Event.DestroyElement(rootEntity)
        rootEntity = nil
      end
      if self.enableBreadcrumbs then
        Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned setting new draggable item complete")
        local numChildren = UiElementBus.Event.GetNumChildElements(self.Properties.DraggableSpawner)
        if 0 < numChildren then
          Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned WARNING: draggableSpawner has > 0 children, child failed to reparent!")
        end
      end
    end
  end
  if rootEntity and ticketData.isDraggable and ticketData.entityIdCallback then
    ticketData.entityIdCallback(rootEntity, ticketData.item)
  end
  local leftToSpawn = CountAssociativeTable(self.spawnTickets)
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned left to spawn = " .. leftToSpawn)
  end
  if leftToSpawn == 0 then
    if self.enableBreadcrumbs then
      Debug.Log("IBC: ItemContainerList:OnTopLevelEntitiesSpawned done spawning, enabling up to current container capacity")
    end
    local childElements = UiElementBus.Event.GetChildren(self.entityId)
    for i = 1, #childElements do
      UiElementBus.Event.SetIsEnabled(childElements[i], i <= self.currentCapacity)
    end
    local gridHeight = self:GetGridHeight(self.entityId, #childElements)
    local contentOffsets = UiTransform2dBus.Event.GetOffsets(self.entityId)
    contentOffsets.bottom = contentOffsets.top + gridHeight
    UiTransform2dBus.Event.SetOffsets(self.entityId, contentOffsets)
  end
end
return ItemContainerList

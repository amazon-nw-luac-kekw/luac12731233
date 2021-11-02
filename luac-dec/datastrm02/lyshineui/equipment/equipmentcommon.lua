local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local Equipment = {}
Equipment.nameToPaperdollSlotMap = {
  ["main-hand-option-1"] = ePaperDollSlotTypes_MainHandOption1,
  ["main-hand-option-2"] = ePaperDollSlotTypes_MainHandOption2,
  ["off-hand-option-1"] = ePaperDollSlotTypes_OffHandOption1,
  ["off-hand-option-2"] = ePaperDollSlotTypes_OffHandOption2,
  ["quickslot-1"] = ePaperDollSlotTypes_QuickSlot1,
  ["quickslot-2"] = ePaperDollSlotTypes_QuickSlot2,
  ["quickslot-3"] = ePaperDollSlotTypes_QuickSlot3,
  ["quickslot-4"] = ePaperDollSlotTypes_QuickSlot4,
  ["bag-slot-1"] = ePaperDollSlotTypes_BagSlot1,
  ["bag-slot-2"] = ePaperDollSlotTypes_BagSlot2,
  ["bag-slot-3"] = ePaperDollSlotTypes_BagSlot3,
  ["arrow-ammo"] = ePaperDollSlotTypes_Arrow,
  ["cartridge-ammo"] = ePaperDollSlotTypes_Cartridge,
  head = ePaperDollSlotTypes_Head,
  chest = ePaperDollSlotTypes_Chest,
  hands = ePaperDollSlotTypes_Hands,
  legs = ePaperDollSlotTypes_Legs,
  feet = ePaperDollSlotTypes_Feet,
  amulet = ePaperDollSlotTypes_Amulet,
  token = ePaperDollSlotTypes_Token,
  ring = ePaperDollSlotTypes_Ring,
  ["cartridge-ammo1"] = ePaperDollSlotTypes_Cartridge,
  ["cartridge-ammo2"] = ePaperDollSlotTypes_Cartridge,
  ["cartridge-ammo3"] = ePaperDollSlotTypes_Cartridge,
  ["arrow-ammo1"] = ePaperDollSlotTypes_Cartridge,
  ["arrow-ammo2"] = ePaperDollSlotTypes_Arrow,
  ["arrow-ammo3"] = ePaperDollSlotTypes_Arrow,
  ["chopping-slot"] = ePaperDollSlotTypes_Chopping,
  ["cutting-slot"] = ePaperDollSlotTypes_Cutting,
  ["dressing-slot"] = ePaperDollSlotTypes_Dressing,
  ["mining-slot"] = ePaperDollSlotTypes_Mining,
  ["azothstaff-slot"] = ePaperDollSlotTypes_AzothStaff,
  ["fishing-slot"] = ePaperDollSlotTypes_Fishing,
  ["main-hand"] = ePaperDollSlotTypes_GatherableHand
}
Equipment.toolTypeIcons = {
  ["chopping-slot"] = "LyShineUI/Images/Inventory/Button_PrimaryTool_Wood_c.png",
  ["cutting-slot"] = "LyShineUI/Images/Inventory/Button_PrimaryTool_Plant_c.png",
  ["dressing-slot"] = "LyShineUI/Images/Inventory/Button_PrimaryTool_Skinning_c.png",
  ["mining-slot"] = "LyShineUI/Images/Inventory/Button_PrimaryTool_Stone_c.png",
  ["azothstaff-slot"] = "LyShineUI/Images/Inventory/Button_PrimaryTool_AzothStaff_a.png",
  ["fishing-slot"] = "LyShineUI/Images/Inventory/Button_PrimaryTool_Fishing_a.png"
}
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local comparableWeaponSlotNames = {
  "main-hand-option-1",
  "main-hand-option-2"
}
function Equipment:EquipItemFromInventory(slotName, onlyEquipIfWeapon)
  self.inventoryId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  self:EquipItemToBestSlot(slotName, onlyEquipIfWeapon, self.inventoryId, nil)
end
function Equipment:EquipItemToBestSlot(slotName, onlyEquipIfWeapon, containerId, stackSizeOverride)
  local paperdollId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
  local targetItem = ContainerRequestBus.Event.GetSlot(containerId, slotName)
  if targetItem and targetItem:IsValid() then
    local itemType = targetItem:GetItemType()
    local isTool = targetItem:HasItemClass(eItemClass_UI_Tools)
    local staticItem = StaticItemDataManager:GetItem(targetItem:GetItemId())
    local gatheringType = ItemDataManagerBus.Broadcast.GetWeaponGatheringType(targetItem:GetItemId())
    local isWeapon = itemType == "Weapon"
    if onlyEquipIfWeapon and not isWeapon then
      return
    end
    local itemQuantity = stackSizeOverride
    if not itemQuantity or itemQuantity <= 0 then
      itemQuantity = targetItem:GetStackSize()
    end
    local equipSlots = targetItem:GetEquipSlots()
    if isTool then
      for i = 1, #equipSlots do
        local equipSlot = equipSlots[i]
        if equipSlot == "chopping-slot" or equipSlot == "cutting-slot" or equipSlot == "fishing-slot" or equipSlot == "mining-slot" or equipSlot == "dressing-slot" or equipSlot == "azothstaff-slot" then
          self:EquipItem(slotName, equipSlot, itemQuantity, containerId, true)
          return
        end
      end
    end
    if 1 < targetItem:GetMaxStackSize() then
      for i = 1, #equipSlots do
        local equipSlot = equipSlots[i]
        local slotEnum = self.nameToPaperdollSlotMap[equipSlot]
        if slotEnum then
          local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, slotEnum)
          if slot and slot:IsValid() then
            local slotDescriptor = slot:GetItemDescriptor()
            local myDescriptor = targetItem:GetItemDescriptor()
            if slotDescriptor:MatchesDescriptorExactly(myDescriptor, false) and slot:GetStackSize() < slot:GetMaxStackSize() then
              local toMove = math.min(slot:GetMaxStackSize() - slot:GetStackSize(), itemQuantity)
              self:EquipItem(slotName, equipSlot, toMove, containerId, true)
              return
            end
          end
        end
      end
    end
    if isWeapon then
      local itemTable = StaticItemDataManager:GetTooltipDisplayInfo(targetItem:GetItemDescriptor(), targetItem)
      local compareTo
      local comparableItems = {}
      for _, equipSlot in ipairs(comparableWeaponSlotNames) do
        local slotEnum = self.nameToPaperdollSlotMap[equipSlot]
        local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, slotEnum)
        local shouldCompare, tdi = StaticItemDataManager:ShouldTooltipCompare(itemTable, slot)
        if shouldCompare then
          table.insert(comparableItems, {tdi = tdi, equipSlot = equipSlot})
        end
      end
      for _, entry in ipairs(comparableItems) do
        if not compareTo or compareTo.tdi.gearScore < entry.tdi.gearScore then
          compareTo = entry
        end
      end
      if compareTo then
        self:EquipItem(slotName, compareTo.equipSlot, itemQuantity, containerId, true)
        return
      end
    end
    local lastUnlockedSlot
    for i = 1, #equipSlots do
      local equipSlot = equipSlots[i]
      local slotEnum = self.nameToPaperdollSlotMap[equipSlot]
      if slotEnum then
        local isLocked = not PaperdollRequestBus.Event.HasLevelRequirementForSlot(paperdollId, slotEnum)
        local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, slotEnum)
        if not isLocked then
          if not slot or not slot:IsValid() then
            self:EquipItem(slotName, equipSlot, itemQuantity, containerId, true)
            return
          end
          lastUnlockedSlot = equipSlot
        end
      end
    end
    if isWeapon then
      if targetItem:HasItemClass(eItemClass_EquippableOffHand) then
        if 0 < #equipSlots then
          self:EquipItem(slotName, equipSlots[1], itemQuantity, containerId, true)
        end
      else
        local activeSlot = LocalPlayerUIRequestsBus.Broadcast.PaperdollGetWeaponAutoEquipSlot()
        for i = 1, #equipSlots do
          if equipSlots[i] == activeSlot then
            self:EquipItem(slotName, activeSlot, itemQuantity, containerId, true)
            break
          end
        end
      end
    elseif lastUnlockedSlot then
      self:EquipItem(slotName, lastUnlockedSlot, itemQuantity, containerId, true)
    end
  end
end
function Equipment:OnPopupResult(result, eventId)
  if eventId == "bind_on_equip" and result == ePopupResult_Yes then
    LocalPlayerUIRequestsBus.Broadcast.EquipItem(tonumber(self.bindOnEquipPopupData.slotName), self.bindOnEquipPopupData.equipSlot, self.bindOnEquipPopupData.stackSize, self.bindOnEquipPopupData.sourceContainerId)
  end
end
function Equipment:TriggerEquipErrorNotification(notificationText)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = notificationText
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function Equipment:EquipItem(slotName, equipSlot, stackSize, sourceContainerId)
  local slotEnum = self.nameToPaperdollSlotMap[equipSlot]
  if slotEnum then
    local paperdollId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
    local isSlotBlocked = PaperdollRequestBus.Event.SlotBlockedByCooldown(paperdollId, slotEnum)
    if isSlotBlocked then
      self:TriggerEquipErrorNotification("@ui_equipment_cooldown_error")
      return
    end
  end
  local targetItem = ContainerRequestBus.Event.GetSlot(sourceContainerId, tostring(slotName))
  if not targetItem:IsEquippable() then
    self:TriggerEquipErrorNotification("@inv_cannotequipitem")
    return
  end
  local canEquipInSlot = targetItem:CanEquipInSlot(slotEnum)
  if not canEquipInSlot then
    self:TriggerEquipErrorNotification("@inv_cannotequipinslot")
    return
  end
  local rootEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local canEquipItem = targetItem:CanEquipItem(rootEntityId)
  if not canEquipItem and targetItem:IsEquippable() then
    self:TriggerEquipErrorNotification("@inv_cannotequip")
    return
  end
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local globalStorageEntityId = PlayerComponentRequestsBus.Event.GetGlobalStorageEntityId(playerEntityId)
  local isPersonalStorage = globalStorageEntityId == sourceContainerId
  if isPersonalStorage then
    DynamicBus.CatContainer.Broadcast.SetStorageTransferAndEquipItemInfo(sourceContainerId, equipSlot, targetItem:GetItemInstanceId(), stackSize)
  end
  if targetItem:IsBindOnEquip() and not targetItem:IsBoundToPlayer() then
    self.bindOnEquipPopupData = {
      slotName = slotName,
      equipSlot = equipSlot,
      stackSize = stackSize,
      sourceContainerId = sourceContainerId
    }
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_bindOnEquip_title", "@ui_bindOnEquip_body", "bind_on_equip", self, self.OnPopupResult)
  else
    LocalPlayerUIRequestsBus.Broadcast.EquipItem(tonumber(slotName), equipSlot, stackSize, sourceContainerId)
  end
end
return Equipment

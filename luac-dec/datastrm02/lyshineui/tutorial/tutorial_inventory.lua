local Tutorial_Inventory = {
  steps = {},
  lootedItem = false,
  isObjectiveReceived = false,
  isObjectiveMessageReceived = false,
  isActionMapSet = false,
  isChestOpen = false,
  isTakeAllBannerReady = false,
  isOpenInventoryReady = false,
  isFoodEaten = false,
  containerHandler = nil
}
local DataLayer = RequireScript("LyShineUI.UiDataLayer")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function Tutorial_Inventory:OnInit()
  self.steps = {
    self.WaitUntilConversationScreen,
    self.DoneWithConversationScreen,
    self.OpenInventory,
    self.WaitUntilInventoryState,
    self.HighlightShield,
    self.WaitForEquipShield,
    self.NotifyDrag,
    self.HighlightEquipSlots,
    self.WaitForEquip,
    self.CloseInventory,
    self.WaitForInventoryToClose,
    self.UseFoodPrompt,
    self.Wait1Second,
    self.WaitForFoodEaten,
    self.CheckIfUsedFood
  }
  self.paperDollSlots = {
    ePaperDollSlotTypes_QuickSlot1,
    ePaperDollSlotTypes_QuickSlot2,
    ePaperDollSlotTypes_QuickSlot3,
    ePaperDollSlotTypes_QuickSlot4
  }
  self.paperDollOffHand = ePaperDollSlotTypes_OffHandOption1
  DataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, inventoryEntityId)
    if inventoryEntityId then
      self.inventoryEntityId = inventoryEntityId
      self.containerHandler = ContainerEventBus.Connect(self, inventoryEntityId)
    end
  end)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockInventory", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockWeapons", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockSkills", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockJournal", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockAutorun", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockEmotes", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockCamping", true)
  self.lootedItem = false
  self.isObjectiveReceived = false
  self.isObjectiveMessageReceived = false
  self.isActionMapSet = false
  self.isChestOpen = false
  self.isTakeAllBannerReady = false
  self.isOpenInventoryReady = false
  self.isFoodEaten = false
end
function Tutorial_Inventory:OnShutdown()
  self.inventoryEntityId = nil
  if self.containerHandler then
    self.containerHandler:Disconnect()
    self.containerHandler = nil
  end
end
function Tutorial_Inventory:WaitUntilConversationScreen(elapsed)
  if LyShineManagerBus.Broadcast.GetCurrentState() == 1101180544 then
    DynamicBus.FtueMessageBus.Broadcast.SetInventoryTutorialActive(true)
    return true
  end
  return false
end
function Tutorial_Inventory:DoneWithConversationScreen(elapsed)
  if LyShineManagerBus.Broadcast.GetCurrentState() == 1101180544 then
    return false
  end
  if not self.isObjectiveReceived then
    self.isObjectiveReceived = true
    TimingUtils:Delay(5, self, function()
      DynamicBus.TutorialMessage.Broadcast.OnTutorialActivated("@TUT_TakeAll", true, "@TUT_Title_TakeAll", false, false, 0, {
        "ui_interact"
      }, {"ui"}, {}, 460, 200)
      self.isObjectiveMessageReceived = true
    end)
  end
  return true
end
function Tutorial_Inventory:WaitForChestOpen(elapsed)
  if self.isChestOpen == true then
    self.isActionMapSet = false
    self.actionHandler:Disconnect()
    return true
  else
    if not self.isActionMapSet then
      self.isActionMapSet = true
      self.actionHandler = CryActionNotificationsBus.Connect(self, "ui_interact")
    end
    return false
  end
end
function Tutorial_Inventory:OnCryAction(actionName, value)
  if actionName == "ui_interact" and self.isObjectiveMessageReceived then
    self.isChestOpen = true
    self.isObjectiveMessageReceived = false
  elseif self.indexSlotted and actionName == "quickslot-consumable-" .. self.indexSlotted then
    self.isFoodEaten = true
  end
end
function Tutorial_Inventory:DoneWithOpenChest(elapsed)
  if self.isChestOpen == true then
    TimingUtils:Delay(1.5, self, function()
      self.isTakeAllBannerReady = true
    end)
    return true
  else
    return false
  end
end
function Tutorial_Inventory:TakeAll(elapsed)
  if self.isTakeAllBannerReady == true then
    DynamicBus.TutorialMessage.Broadcast.OnTutorialActivated("@TUT_TakeAll", true, "@TUT_Title_TakeAll", false, false, 0, {
      "ui_interact"
    }, {"ui"}, {}, 460, 200)
    return true
  else
    return false
  end
end
function Tutorial_Inventory:OpenInventory(elapsed)
  if self.lootedItem == true then
    DynamicBus.TutorialMessage.Broadcast.OnTutorialActivated("@TUT_Inventory_Open", true, "@TUT_Title_Inventory", false, false, 0, {
      "toggleInventoryWindow"
    }, {"ui"}, {}, 460, 200)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockInventory", false)
    StaticItemDataManager:BlockUseItemFromFlyout(true)
    DynamicBus.FtueMessageBus.Broadcast.SetGroundDropTargetForceDisabled(true)
    return true
  else
    return false
  end
end
function Tutorial_Inventory:WaitUntilInventoryState(elapsed)
  if LyShineManagerBus.Broadcast.GetCurrentState() == 2972535350 then
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockInventory", true)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockCombat", true)
    LyShineManagerBus.Broadcast.EnableWorldHitUIAction(false)
    return true
  else
    return false
  end
end
function Tutorial_Inventory:HighlightContainer(elapsed)
  DynamicBus.TutorialMessage.Broadcast.OnTutorialActivated("@TUT_Looting", true, "@TUT_Title_Looting", false, false, 0, {
    "ui_interact_sec"
  }, {"ui"}, {}, 460, 200)
  return true
end
function Tutorial_Inventory:WaitForLoot(elapsed)
  if self.lootedItem then
    DynamicBus.TutorialMessage.Broadcast.OnTutorialDeactivated()
  end
  return self.lootedItem
end
function Tutorial_Inventory:OnSlotUpdate(localSlotId, itemSlot, action)
  if itemSlot:GetItemId() == 628315161 then
    self.lootedItem = true
  end
end
function Tutorial_Inventory:HighlightInventory(elapsed)
  return true
end
function Tutorial_Inventory:HighlightShield(elapsed)
  DynamicBus.FtueMessageBus.Broadcast.SetWaitingToEquip(true)
  DynamicBus.FocusOverlayBus.Broadcast.ShowOverlay("EquipShield")
  DynamicBus.TutorialMessage.Broadcast.OnTutorialActivated("@TUT_Equipping", true, "@TUT_Title_Equip", false, false, 0, {}, {}, {}, 460, 200, 1)
  return true
end
function Tutorial_Inventory:WaitForEquip(elapsed)
  local paperdollId = DataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
  if not paperdollId then
    return
  end
  for index, slotName in pairs(self.paperDollSlots) do
    local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, slotName)
    if slot and slot:GetItemName() == "FoodHealthRecoveryT1" then
      DynamicBus.FtueMessageBus.Broadcast.SetWaitingToEquip(false)
      DynamicBus.TutorialMessage.Broadcast.OnTutorialDeactivated()
      DynamicBus.FocusOverlayBus.Broadcast.OnTutorialStopFocusUIElement()
      self.indexSlotted = index
      StaticItemDataManager:BlockUseItemFromFlyout(false)
      return true
    end
  end
  return false
end
function Tutorial_Inventory:NotifyDrag(elapsed)
  DynamicBus.TutorialMessage.Broadcast.OnTutorialActivated("@TUT_Quickslots", true, "@TUT_Title_Inventory_Equip", false, false, 0, {}, {}, {}, 460, 200, 1)
  return true
end
function Tutorial_Inventory:Wait1Second(elapsed)
  self.timer = self.timer + elapsed
  if self.timer > 1 then
    return true
  end
  return false
end
function Tutorial_Inventory:HighlightEquipSlots(elapsed)
  DynamicBus.FtueMessageBus.Broadcast.SetWaitingToEquip(true)
  DynamicBus.FocusOverlayBus.Broadcast.ShowOverlay("QuickbarItems")
  return true
end
function Tutorial_Inventory:WaitForEquipShield(elapsed)
  local paperdollId = DataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
  if not paperdollId then
    return
  end
  local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, self.paperDollOffHand)
  if slot and slot:GetItemName() == "1hShieldAT2_FTUE" then
    DynamicBus.FtueMessageBus.Broadcast.SetWaitingToEquip(false)
    DynamicBus.TutorialMessage.Broadcast.OnTutorialDeactivated()
    DynamicBus.FocusOverlayBus.Broadcast.OnTutorialStopFocusUIElement()
    return true
  end
  return false
end
function Tutorial_Inventory:CloseInventory(elapsed)
  DynamicBus.TutorialMessage.Broadcast.OnTutorialActivated("@TUT_Inventory_Close", true, "@TUT_Title_Inv", false, false, 0, {
    "toggleInventoryWindow"
  }, {"ui"}, {}, 460, 200)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockInventory", false)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockEscMenu", false)
  LyShineManagerBus.Broadcast.EnableWorldHitUIAction(true)
  return true
end
function Tutorial_Inventory:WaitForInventoryToClose(elapsed)
  local inInventory = LyShineManagerBus.Broadcast.GetCurrentState() == 2972535350 or LyShineManagerBus.Broadcast.GetCurrentState() == 3349343259
  if not inInventory then
    DynamicBus.TutorialMessage.Broadcast.OnTutorialDeactivated()
  end
  return not inInventory
end
function Tutorial_Inventory:UseFoodPrompt(elapsed)
  DynamicBus.TutorialMessage.Broadcast.OnTutorialActivated("@TUT_Drink3", true, "@TUT_Title_EatHeal", false, false, 0, {
    "quickslot-consumable-" .. self.indexSlotted
  }, {"ui"}, {}, 460, 200)
  DynamicBus.QuickslotsBus.Broadcast.OnTutorialRevealUIElement("QuickSlots")
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockInventory", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockEscMenu", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockQuickslots", true)
  self.timer = 0
  return true
end
function Tutorial_Inventory:WaitForFoodEaten(elapsed)
  if self.isFoodEaten == true then
    self.isActionMapSet = false
    self.actionHandler:Disconnect()
    return true
  else
    if not self.isActionMapSet then
      UIInputRequestsBus.Broadcast.EnableInputFilter("LockQuickslots", false)
      self.isActionMapSet = true
      self.actionHandler = CryActionNotificationsBus.Connect(self, "quickslot-consumable-" .. self.indexSlotted)
    end
    return false
  end
end
function Tutorial_Inventory:CheckIfUsedFood(elapsed)
  if self.isFoodEaten then
    DynamicBus.TutorialMessage.Broadcast.OnTutorialDeactivated()
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockWeapons", false)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockCombat", false)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockJournal", false)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockInventory", false)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockEscMenu", false)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockAutorun", false)
    DynamicBus.FtueMessageBus.Broadcast.SetInventoryTutorialActive(false)
    DynamicBus.FtueMessageBus.Broadcast.SetGroundDropTargetForceDisabled(false)
    return true
  end
  return false
end
return Tutorial_Inventory

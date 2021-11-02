local Logger = RequireScript("LyShineUI.Automation.Logger")
local InputUtility = RequireScript("LyShineUI.Automation.Utilities.InputUtility")
local MenuStack = RequireScript("LyShineUI.Automation.MenuStack")
local MenuUtility = RequireScript("LyShineUI.Automation.Utilities.MenuUtility")
local PaperdollIndices = RequireScript("LyShineUI.Crafting.CraftingPaperdollSlotIndexToNameMap")
local PopupUtility = RequireScript("LyShineUI.Automation.Utilities.PopupUtility")
local DataLayer = RequireScript("LyShineUI.UiDataLayer")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local InventoryCommon = RequireScript("LyShineUI._Common.InventoryCommon")
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local InventoryUtility = {
  ScreenName = "NewInventory",
  DyeScreenName = "ArmorDyeing",
  DyePopupName = "ItemDyeingPopup",
  InventoryCRC = 2972535350,
  ChestCRC = 3349343259,
  LootContainerName = "CatContainer",
  TooltipName = "Tooltip",
  ScrollMultiplier = 5,
  Slots = {},
  Sections = {},
  Tooltip = nil
}
local function Log(msg)
  Logger:Log("[InventoryUtility] " .. tostring(msg))
end
function InventoryUtility:Initialize()
  self.Inventory = DynamicBus.NewInventory.Broadcast.GetTable()
  self.Equipment = DynamicBus.EquipmentV2.Broadcast.GetTable()
  self.LootContainer = DynamicBus.CatContainer.Broadcast.GetTable()
  self.DyeScreen = DynamicBus.ArmorDyeing.Broadcast.GetTable()
  self.DyePopup = MenuUtility:GetEntityTable(self.Inventory.Properties.ItemDyeingPopup)
  self.Slots = {
    Weapon_1 = {
      slot = ePaperDollSlotTypes_MainHandOption1,
      dropTarget = self.Equipment.Properties.QuickslotDropTargets.QuickslotWeapon1
    },
    Weapon_2 = {
      slot = ePaperDollSlotTypes_MainHandOption2,
      dropTarget = self.Equipment.Properties.QuickslotDropTargets.QuickslotWeapon2
    },
    Consumable_1 = {
      slot = ePaperDollSlotTypes_QuickSlot1,
      dropTarget = self.Equipment.Properties.QuickslotDropTargets.QuickslotConsumable1
    },
    Consumable_2 = {
      slot = ePaperDollSlotTypes_QuickSlot2,
      dropTarget = self.Equipment.Properties.QuickslotDropTargets.QuickslotConsumable2
    },
    Consumable_3 = {
      slot = ePaperDollSlotTypes_QuickSlot3,
      dropTarget = self.Equipment.Properties.QuickslotDropTargets.QuickslotConsumable3
    },
    Consumable_4 = {
      slot = ePaperDollSlotTypes_QuickSlot4,
      dropTarget = self.Equipment.Properties.QuickslotDropTargets.QuickslotConsumable4
    },
    Arrow = {
      slot = ePaperDollSlotTypes_Arrow,
      dropTarget = self.Equipment.Properties.ArrowDropTarget
    },
    Cartridge = {
      slot = ePaperDollSlotTypes_Cartridge,
      dropTarget = self.Equipment.Properties.CartridgeDropTarget
    },
    Ring = {
      slot = ePaperDollSlotTypes_Ring,
      dropTarget = self.Equipment.Properties.RingDropTarget
    },
    Amulet = {
      slot = ePaperDollSlotTypes_Amulet,
      dropTarget = self.Equipment.Properties.AmuletDropTarget
    },
    Bag_1 = {
      slot = ePaperDollSlotTypes_BagSlot1,
      dropTarget = self.Equipment.Properties.BagSlotDropTarget1
    },
    Bag_2 = {
      slot = ePaperDollSlotTypes_BagSlot2,
      dropTarget = self.Equipment.Properties.BagSlotDropTarget2
    },
    Bag_3 = {
      slot = ePaperDollSlotTypes_BagSlot3,
      dropTarget = self.Equipment.Properties.BagSlotDropTarget3
    },
    Token = {
      slot = ePaperDollSlotTypes_Token,
      dropTarget = self.Equipment.Properties.TokenDropTarget
    },
    OffHand = {
      slot = ePaperDollSlotTypes_OffHandOption1,
      dropTarget = self.Equipment.Properties.OffHandOption1DropTarget
    },
    Chest = {
      slot = ePaperDollSlotTypes_Chest,
      dropTarget = self.Equipment.Properties.ChestDropTarget
    },
    Feet = {
      slot = ePaperDollSlotTypes_Feet,
      dropTarget = self.Equipment.Properties.FeetDropTarget
    },
    Hands = {
      slot = ePaperDollSlotTypes_Hands,
      dropTarget = self.Equipment.Properties.HandsDropTarget
    },
    Head = {
      slot = ePaperDollSlotTypes_Head,
      dropTarget = self.Equipment.Properties.HeadDropTarget
    },
    Legs = {
      slot = ePaperDollSlotTypes_Legs,
      dropTarget = self.Equipment.Properties.LegsDropTarget
    }
  }
  self.Sections = {
    Weapons = self.Inventory.DynamicItemList.WeaponSection,
    Armor = self.Inventory.DynamicItemList.ArmorSection,
    Ammo = self.Inventory.DynamicItemList.AmmoSection,
    Consumables = self.Inventory.DynamicItemList.ConsumableSection,
    Tools = self.Inventory.DynamicItemList.ToolsSection,
    Materials = self.Inventory.DynamicItemList.MaterialSection,
    Lore = self.Inventory.DynamicItemList.LoreSection,
    RepairKit = self.Inventory.DynamicItemList.RepairKitSection,
    Cooking = self.Inventory.DynamicItemList.CookingSection,
    Furniture = self.Inventory.DynamicItemList.FurnitureSection,
    OutpostRush = self.Inventory.DynamicItemList.OutpostRushSection,
    Dye = self.Inventory.DynamicItemList.DyeSection,
    Bait = self.Inventory.DynamicItemList.BaitSection,
    Alchemy = self.Inventory.DynamicItemList.AlchemySection,
    TuningOrb = self.Inventory.DynamicItemList.TuningOrbSection,
    Quest = self.Inventory.DynamicItemList.QuestSection,
    Jewel = self.Inventory.DynamicItemList.JewelSection,
    Refining = self.Inventory.DynamicItemList.RefiningSection,
    AttributeFood = self.Inventory.DynamicItemList.AttributeFoodSection,
    Smelting = self.Inventory.DynamicItemList.SmeltingSection,
    TradeSkillFood = self.Inventory.DynamicItemList.TradeSkillFoodSection,
    Leatherworking = self.Inventory.DynamicItemList.LeatherworkingSection,
    Weaving = self.Inventory.DynamicItemList.WeavingSection,
    Woodworking = self.Inventory.DynamicItemList.WoodworkingSection,
    Stonecutting = self.Inventory.DynamicItemList.StonecuttingSection
  }
  self.InventoryScrollBox = self.Inventory.DynamicItemList.Scrollbox
  self.InventoryDropTarget = self.Inventory.InventoryAreaDropTarget
  self.GroundDropTarget = self.Inventory.GroundDropTarget
  self.LootSections = {
    LootContainer = self.LootContainer.DynamicItemList.LootContainerSection,
    Weapons = self.LootContainer.DynamicItemList.WeaponSection,
    Armor = self.LootContainer.DynamicItemList.ArmorSection,
    Ammo = self.LootContainer.DynamicItemList.AmmoSection,
    Consumables = self.LootContainer.DynamicItemList.ConsumableSection,
    Tools = self.LootContainer.DynamicItemList.ToolsSection,
    Materials = self.LootContainer.DynamicItemList.MaterialSection,
    Lore = self.LootContainer.DynamicItemList.LoreSection,
    RepairKit = self.LootContainer.DynamicItemList.RepairKitSection,
    Cooking = self.LootContainer.DynamicItemList.CookingSection,
    Furniture = self.LootContainer.DynamicItemList.FurnitureSection,
    OutpostRush = self.LootContainer.DynamicItemList.OutpostRushSection,
    Dye = self.LootContainer.DynamicItemList.DyeSection,
    Bait = self.LootContainer.DynamicItemList.BaitSection,
    Alchemy = self.LootContainer.DynamicItemList.AlchemySection,
    TuningOrb = self.LootContainer.DynamicItemList.TuningOrbSection,
    Quest = self.LootContainer.DynamicItemList.QuestSection,
    Jewel = self.LootContainer.DynamicItemList.JewelSection,
    Refining = self.LootContainer.DynamicItemList.RefiningSection,
    AttributeFood = self.LootContainer.DynamicItemList.AttributeFoodSection,
    Smelting = self.LootContainer.DynamicItemList.SmeltingSection,
    TradeSkillFood = self.LootContainer.DynamicItemList.TradeSkillFoodSection,
    Leatherworking = self.LootContainer.DynamicItemList.LeatherworkingSection,
    Weaving = self.LootContainer.DynamicItemList.WeavingSection,
    Woodworking = self.LootContainer.DynamicItemList.WoodworkingSection,
    Stonecutting = self.LootContainer.DynamicItemList.StonecuttingSection
  }
  self.LootScrollBox = self.LootContainer.DynamicItemList.Scrollbox
end
InventoryUtility.SortOptions = {
  Time = "SortByChrono",
  GearScore = "SortByGearScore",
  Tier = "SortByTier",
  Weight = "SortByWeight"
}
InventoryUtility.DyeSlots = {
  Primary = "PrimarySelector",
  Secondary = "SecondarySelector",
  Accent = "AccentSelector",
  Tint = "TintSelector"
}
local function CloseDyeScreen()
  if MenuStack:IsScreenOpen(InventoryUtility.DyeScreenName) then
    MenuUtility:ClickButton(InventoryUtility.DyeScreen.Properties.CancelButton)
  end
end
local function OpenDyeScreen()
  MenuStack:Push(nil, InventoryUtility.DyeScreenName, CloseDyeScreen)
  while not InventoryUtility:IsDyeScreenOpen() do
    coroutine.yield()
  end
end
local function CloseDyePopup()
  if MenuUtility:IsEnabled(InventoryUtility.DyePopup) then
    MenuUtility:ClickButton(InventoryUtility.DyePopup.Properties.CancelButton)
  end
end
local function OpenDyePopup()
  MenuStack:Push(nil, InventoryUtility.DyePopupName, CloseDyePopup)
  while not InventoryUtility:IsDyePopupOpen() do
    coroutine.yield()
  end
end
InventoryUtility.TooltipActions = {
  Buy = {
    IsAction = function(cb)
      return cb:GetText() == "@owg_buy_command_flyout_row"
    end
  },
  Repair = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_repair_icon"
    end,
    AfterAction = function()
      PopupUtility:WaitUntilAnyPopupIsOpen()
      PopupUtility:PopupClickPositive()
    end
  },
  Salvage = {
    IsAction = function(cb)
      return cb:GetText() == "@inv_salvage"
    end,
    AfterAction = function()
      PopupUtility:WaitUntilAnyPopupIsOpen()
      PopupUtility:PopupClickPositive()
    end
  },
  Equip = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_tooltip_equip"
    end
  },
  Unequip = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_tooltip_unequip"
    end
  },
  Read = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_tooltip_read"
    end
  },
  Open = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_open"
    end
  },
  Use = {
    IsAction = function(cb)
      return cb:GetText() == "@inv_use"
    end
  },
  Drop = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_tooltip_drop"
    end
  },
  AttachGem = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_replace_gem" or cb:GetText() == "@ui_attach_gem"
    end
  },
  Store = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_tooltip_store"
    end
  },
  Take = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_tooltip_take"
    end
  },
  Split = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_tooltip_split"
    end
  },
  Link = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_item_link_tooltip_command"
    end
  },
  DyeEquipped = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_tooltip_dye_equipped"
    end,
    AfterAction = function()
      coroutine.yield()
      InventoryUtility:CloseTooltip()
      coroutine.yield()
      OpenDyeScreen()
      return true
    end
  },
  DyeItem = {
    IsAction = function(cb)
      return cb:GetText() == "@ui_tooltip_dye_item"
    end,
    AfterAction = function()
      coroutine.yield()
      InventoryUtility:CloseTooltip()
      coroutine.yield()
      OpenDyePopup()
      return true
    end
  }
}
local function CloseInventory()
  if MenuStack:IsScreenOpen(InventoryUtility.ScreenName) then
    InputUtility:PressKey("toggleInventoryWindow")
  end
end
local function OpenInventory()
  InputUtility:PressKey("toggleInventoryWindow")
end
local function OpenLootContainer()
  InputUtility:PressKey("ui_interact_sec")
end
local function OpenLootChest()
  InputUtility:PressKey("ui_interact")
end
local function CloseTooltip()
  if InventoryUtility.Tooltip then
    if DataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible") then
      if MenuUtility:GetObjectViewportPosition(InventoryUtility.Tooltip, MenuUtility.Anchors.TopLeft).x > 1 then
        MenuUtility:ClickAt(Vector2(1, 1))
      else
        local position = MenuUtility:GetObjectViewportPosition(InventoryUtility.Tooltip, MenuUtility.Anchors.BotRight)
        MenuUtility:ClickAt(Vector2(position.x + 1, 1))
      end
    end
    InventoryUtility.Tooltip = nil
  end
end
function InventoryUtility:IsInventoryOpen()
  return not MenuStack:IsEmpty() and MenuStack:Peek().name == InventoryUtility.ScreenName and MenuStack:VerifyScreen() and MenuStack:VerifyState()
end
function InventoryUtility:IsDyeScreenOpen()
  return not MenuStack:IsEmpty() and MenuStack:Peek().name == self.DyeScreenName and MenuStack:VerifyScreen()
end
function InventoryUtility:IsDyePopupOpen()
  return not MenuStack:IsEmpty() and MenuStack:Peek().name == self.DyePopupName and MenuUtility:IsEnabled(InventoryUtility.DyePopup)
end
function InventoryUtility:IsLootContainerOpen()
  return MenuStack:IsScreenOpen(self.LootContainerName) and (self:GetLootItemsNum() > 0 or LyShineManagerBus.Broadcast.GetCurrentState() == self.ChestCRC)
end
function InventoryUtility:OpenInventory()
  MenuUtility:OpenMenu(InventoryUtility.ScreenName, "Inventory", OpenInventory, CloseInventory, InventoryUtility.IsInventoryOpen, InventoryUtility.InventoryCRC)
end
function InventoryUtility:OpenLootContainer()
  Log("Info: Opening loot container")
  if not MenuStack:IsEmpty() then
    Log("Warning: Menu stack is not empty, closing everything")
    MenuStack:Clear()
  end
  MenuStack:Push(OpenLootContainer, self.ScreenName, CloseInventory, self.InventoryCRC)
end
function InventoryUtility:WaitForLootContainer()
  self:OpenLootContainer()
  while not self:IsInventoryOpen() and not self:IsLootContainerOpen() do
    coroutine.yield()
  end
end
function InventoryUtility:OpenLootChest()
  Log("Info: Opening loot chest")
  if not MenuStack:IsEmpty() then
    Log("Warning: Menu stack is not empty, closing everything")
    MenuStack:Clear()
  end
  MenuStack:Push(OpenLootChest, self.ScreenName, CloseInventory, self.ChestCRC)
end
function InventoryUtility:WaitForLootChest()
  self:OpenLootChest()
  while not self:IsInventoryOpen() and not self:IsLootContainerOpen() do
    coroutine.yield()
  end
end
function InventoryUtility:WaitForInventory()
  MenuUtility:WaitForMenu(self.OpenInventory, self.IsInventoryOpen)
end
function InventoryUtility:CloseInventory()
  MenuUtility:CloseMenu(self.ScreenName, "Inventory")
end
function InventoryUtility:CloseDyeing()
  if self:IsDyeScreenOpen() or self:IsDyePopupOpen() then
    self:OpenInventory()
  else
    Log("Warning: Dyeing not opened")
  end
end
function InventoryUtility:GetItemsNumInSection(section)
  return #section.itemDefs
end
function InventoryUtility:GetItemsNum(sections)
  local numItems = 0
  for _, section in pairs(sections) do
    numItems = numItems + self:GetItemsNumInSection(section)
  end
  return numItems
end
function InventoryUtility:GetInventoryItemsNum()
  return self:GetItemsNum(self.Sections)
end
function InventoryUtility:GetLootItemsNum()
  return self:GetItemsNum(self.LootSections)
end
function InventoryUtility:GetItemDefByIndexInSection(index, section)
  local i = 0
  for key, itemDef in pairs(section.itemDefs) do
    i = i + 1
    if i == index then
      return itemDef
    end
  end
end
function InventoryUtility:GetItemDefByIndex(index, sections)
  local prototypeItem, targetItem
  local i = 0
  for _, list in pairs(sections) do
    for key, itemDef in pairs(list.itemDefs) do
      i = i + 1
      if not prototypeItem and itemDef.entityId then
        prototypeItem = itemDef.entityId
      end
      if tonumber(i) == tonumber(index) then
        targetItem = itemDef
      end
      if targetItem and prototypeItem then
        return targetItem, prototypeItem
      end
    end
  end
  return targetItem, prototypeItem
end
function InventoryUtility:GetItemDef(itemName, sections)
  local prototypeItem, targetItem
  for _, list in pairs(sections) do
    for key, itemDef in pairs(list.itemDefs) do
      if not prototypeItem and itemDef.entityId then
        prototypeItem = itemDef.entityId
      end
      if itemDef.slot:GetItemDescriptor():GetItemKey() == itemName then
        targetItem = itemDef
      end
      if targetItem and prototypeItem then
        return targetItem, prototypeItem
      end
    end
  end
  return targetItem, prototypeItem
end
function InventoryUtility:GetInventoryItemDefByIndex(index)
  return self:GetItemDefByIndex(index, self.Sections)
end
function InventoryUtility:GetLootItemDefByIndex(index)
  if InventoryUtility:IsLootContainerOpen() then
    return self:GetItemDefByIndex(index, self.LootSections)
  end
end
function InventoryUtility:GetInventoryItemDef(itemName)
  return self:GetItemDef(itemName, self.Sections)
end
function InventoryUtility:GetLootItemDef(itemName)
  if InventoryUtility:IsLootContainerOpen() then
    return self:GetItemDef(itemName, self.LootSections)
  end
end
function InventoryUtility:ScrollToItem(item, scrollBox, getItemFun)
  MenuUtility:ScrollBoxScrollVerticalToExtreme(scrollBox)
  coroutine.yield()
  local itemDef, prototypeItem = getItemFun(self, item)
  if itemDef then
    while not itemDef.entityId do
      local dy = MenuUtility:GetObjectViewportSize(prototypeItem).y
      MenuUtility:ScrollBoxScrollVerticalBy(scrollBox, dy * self.ScrollMultiplier)
      coroutine.yield()
      itemDef = getItemFun(self, item)
    end
    MenuUtility:ScrollBoxScrollVerticalToObject(scrollBox, scrollBox, itemDef.entityId)
    coroutine.yield()
    return MenuUtility:GetObjectViewportPosition(itemDef.entityId, MenuUtility.Anchors.Center)
  end
  return false
end
function InventoryUtility:ScrollToInventoryItem(itemName)
  return self:ScrollToItem(itemName, self.InventoryScrollBox, self.GetInventoryItemDef)
end
function InventoryUtility:ScrollToLootItem(itemName)
  if InventoryUtility:IsLootContainerOpen() then
    return self:ScrollToItem(itemName, self.LootScrollBox, self.GetLootItemDef)
  end
end
function InventoryUtility:ScrollToInventoryItemByIndex(index)
  return self:ScrollToItem(index, self.InventoryScrollBox, self.GetInventoryItemDefByIndex)
end
function InventoryUtility:ScrollToLootItemByIndex(index)
  if InventoryUtility:IsLootContainerOpen() then
    return self:ScrollToItem(index, self.LootScrollBox, self.GetLootItemDefByIndex)
  end
end
function InventoryUtility:CloseTooltip()
  if MenuStack:IsOnStack(self.TooltipName) then
    MenuStack:PopUntil(self.TooltipName)
  end
  while DataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible") do
    coroutine.yield()
  end
end
function InventoryUtility:OpenTooltip(position)
  self:CloseTooltip()
  if position then
    MenuUtility:ClickAt(position)
    while not DataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible") do
      coroutine.yield()
    end
    for _, entityId in pairs(GetFlyoutMenu().rowEntities) do
      local objTable = MenuUtility:GetEntityTable(entityId)
      if objTable.Commands then
        self.Tooltip = objTable
        MenuStack:Push(nil, self.TooltipName, CloseTooltip)
        return true
      end
    end
  end
  return false
end
function InventoryUtility:OpenInventoryTooltip(itemName)
  local position = self:ScrollToInventoryItem(itemName)
  return self:OpenTooltip(position)
end
function InventoryUtility:OpenSlotTooltip(slot)
  local position = MenuUtility:GetObjectViewportPosition(slot.dropTarget, MenuUtility.Anchors.Center)
  return self:OpenTooltip(position)
end
function InventoryUtility:OpenLootTooltip(itemName)
  if InventoryUtility:IsLootContainerOpen() then
    local position = self:ScrollToLootItem(itemName)
    return self:OpenTooltip(position)
  end
end
function InventoryUtility:VerifyTooltipAction(tooltipAction)
  local exists = false
  if self.Tooltip then
    for i, cb in ipairs(self.Tooltip.Commands.commandButtons) do
      local button = MenuUtility:GetEntityTable(cb.Properties.Button)
      if tooltipAction.IsAction(button) then
        exists = true
        break
      end
    end
    coroutine.yield()
    self:CloseTooltip()
  end
  return exists
end
function InventoryUtility:PerformTooltipAction(tooltipAction)
  local performed = false
  if self.Tooltip then
    for i, cb in ipairs(self.Tooltip.Commands.commandButtons) do
      local button = MenuUtility:GetEntityTable(cb.Properties.Button)
      if tooltipAction.IsAction(button) then
        performed = true
        MenuUtility:ClickButton(button)
        if tooltipAction.AfterAction then
          tooltipAction.AfterAction()
        end
        break
      end
    end
    coroutine.yield()
    self:CloseTooltip()
  end
  return performed
end
function InventoryUtility:GetTooltipData()
  local data = {
    valid = false,
    actions = {}
  }
  if self.Tooltip then
    data.valid = true
    for key, action in pairs(self.TooltipActions) do
      data.actions[key] = {available = false}
      for i, cb in ipairs(self.Tooltip.Commands.commandButtons) do
        if tooltipAction.IsAction(cb) then
          data.actions[key].available = MenuUtility:IsEnabled(cb)
          break
        end
      end
    end
  end
  return data
end
function InventoryUtility:DoubleClickInventoryItem(itemName)
  local position = self:ScrollToInventoryItem(itemName)
  if position then
    InputUtility:SetCursorPosition(position)
    InputUtility:DoubleLeftClick()
  end
end
function InventoryUtility:EquipToSlot(itemName, slot)
  if self:IsInventoryOpen() then
    local startPosition = self:ScrollToInventoryItem(itemName)
    if startPosition then
      local targetPosition = MenuUtility:GetObjectViewportPosition(slot.dropTarget, MenuUtility.Anchors.Center)
      MenuUtility:DragAndDropWithSmallMovement(startPosition, targetPosition)
      timeout = os.time() + 1
      while os.time() < timeout do
        coroutine.yield()
        if PopupUtility:IsAnyPopupOpen() then
          PopupUtility:PopupClickPositive()
          break
        end
      end
      return true
    end
  else
    Log("Error inventory not opened")
  end
  return false
end
function InventoryUtility:UnequipSlot(slot)
  if self:IsInventoryOpen() then
    local position = MenuUtility:GetObjectViewportPosition(slot.dropTarget, MenuUtility.Anchors.Center)
    if position then
      InputUtility:SetCursorPosition(position)
      InputUtility:DoubleLeftClick()
      return true
    end
  else
    Log("Error inventory not opened")
  end
  return false
end
function InventoryUtility:GetSlotItemDescriptor(slot)
  local paperdollId = DataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
  local slotObj = PaperdollRequestBus.Event.GetSlot(paperdollId, slot.slot)
  if slotObj then
    return slotObj:GetItemDescriptor()
  end
end
function InventoryUtility:DropItem(itemName)
  local startPosition = self:ScrollToInventoryItem(itemName)
  if startPosition then
    local targetPosition = MenuUtility:GetObjectViewportPosition(self.GroundDropTarget, MenuUtility.Anchors.Center)
    MenuUtility:DragAndDropWithSmallMovement(startPosition, targetPosition)
  end
end
function InventoryUtility:DropItemByIndex(index)
  local startPosition = self:ScrollToInventoryItemByIndex(index)
  if startPosition then
    local targetPosition = MenuUtility:GetObjectViewportPosition(self.GroundDropTarget, MenuUtility.Anchors.Center)
    MenuUtility:DragAndDropWithSmallMovement(startPosition, targetPosition)
  end
end
function InventoryUtility:DropItemFromSlot(slot)
  local startPosition = MenuUtility:GetObjectViewportPosition(slot.dropTarget, MenuUtility.Anchors.Center)
  if startPosition then
    local targetPosition = MenuUtility:GetObjectViewportPosition(self.GroundDropTarget, MenuUtility.Anchors.Center)
    MenuUtility:DragAndDropWithSmallMovement(startPosition, targetPosition)
  end
end
function InventoryUtility:DropAllItems()
  while self:GetInventoryItemsNum() > 0 do
    self:DropItemByIndex(1)
  end
end
function InventoryUtility:LeaveItem(itemName)
  local startPosition = self:ScrollToInventoryItem(itemName)
  if startPosition then
    local targetPosition = MenuUtility:GetObjectViewportPosition(self.LootContainer.ContainerAreaDropTarget, MenuUtility.Anchors.Center)
    MenuUtility:DragAndDropWithSmallMovement(startPosition, targetPosition)
  end
end
function InventoryUtility:LeaveItemByIndex(index)
  local startPosition = self:ScrollToInventoryItemByIndex(index)
  if startPosition then
    local targetPosition = MenuUtility:GetObjectViewportPosition(self.LootContainer.ContainerAreaDropTarget, MenuUtility.Anchors.Center)
    MenuUtility:DragAndDropWithSmallMovement(startPosition, targetPosition)
  end
end
function InventoryUtility:LeaveItemFromSlot(slot)
  local startPosition = MenuUtility:GetObjectViewportPosition(slot.dropTarget, MenuUtility.Anchors.Center)
  if startPosition then
    local targetPosition = MenuUtility:GetObjectViewportPosition(self.LootContainer.ContainerAreaDropTarget, MenuUtility.Anchors.Center)
    MenuUtility:DragAndDropWithSmallMovement(startPosition, targetPosition)
  end
end
function InventoryUtility:LeaveAllItems()
  while self:GetInventoryItemsNum() > 0 do
    self:LeaveItemByIndex(1)
  end
end
function InventoryUtility:TakeItem(itemName)
  if self:IsLootContainerOpen() then
    local startPosition = self:ScrollToLootItem(itemName)
    if startPosition then
      local targetPosition = MenuUtility:GetObjectViewportPosition(self.InventoryDropTarget, MenuUtility.Anchors.Center)
      MenuUtility:DragAndDropWithSmallMovement(startPosition, targetPosition)
    end
  end
end
function InventoryUtility:TakeItemByIndex(index)
  if self:IsLootContainerOpen() then
    local startPosition = self:ScrollToLootItemByIndex(index)
    if startPosition then
      local targetPosition = MenuUtility:GetObjectViewportPosition(self.InventoryDropTarget, MenuUtility.Anchors.Center)
      MenuUtility:DragAndDropWithSmallMovement(startPosition, targetPosition)
    end
  end
end
function InventoryUtility:TakeAllItems()
  local numLootItems = 0
  while self:IsLootContainerOpen() and 0 < self:GetLootItemsNum() do
    local currentNumItems = self:GetLootItemsNum()
    if numLootItems ~= currentNumItems then
      numLootItems = currentNumItems
      self:TakeItemByIndex(1)
    end
    coroutine.yield()
  end
end
function InventoryUtility:TakeAllItemsByButton()
  if self:IsLootContainerOpen() then
    MenuUtility:ClickButton(self.LootContainer.Properties.ButtonTakeAll)
  end
end
function InventoryUtility:Sort(sortOption, dynamicList)
  MenuUtility:ClickButton(dynamicList[sortOption])
end
function InventoryUtility:SortInventory(sortOption)
  self:Sort(sortOption, self.Inventory.DynamicItemList)
end
function InventoryUtility:SortLoot(sortOption)
  if self:IsLootContainerOpen() then
    self:Sort(sortOption, self.LootContainer.DynamicItemList)
  end
end
function InventoryUtility:GetColor(dyeSlot, eqSlot)
  if self:IsDyePopupOpen() then
    local slotTable = MenuUtility:GetEntityTable(self.DyePopup.Properties[dyeSlot])
    return slotTable:GetColor()
  elseif self:IsDyeScreenOpen() then
    if not eqSlot then
      error("No equipment slot provided")
    end
    local selector = MenuUtility:GetEntityTable(self.DyeScreen.slotEnumToSelectorsMap[eqSlot.slot])
    local slotTable = MenuUtility:GetEntityTable(selector[dyeSlot])
    return slotTable:GetColor()
  else
    error("No dyeing screen is opened")
  end
end
function InventoryUtility:PickDye(dyeSlot, dyeItemIndex, eqSlot)
  local function handleDyePicker(dyePicker)
    local scrollBox = MenuUtility:GetParent(dyePicker.AvailableList)
    local children = MenuUtility:GetChildren(dyePicker.AvailableList)
    for i = 1, #children do
      local color = MenuUtility:GetEntityTable(children[i])
      if color.index == dyeItemIndex then
        MenuUtility:ScrollBoxScrollVerticalToObject(scrollBox, scrollBox, color)
        MenuUtility:ClickButton(color)
        return true
      end
    end
    return false
  end
  local picked = false
  if self:IsDyePopupOpen() then
    local slotTable = MenuUtility:GetEntityTable(self.DyePopup.Properties[dyeSlot])
    if not dyeItemIndex or dyeItemIndex == 0 then
      MenuUtility:ClickButton(slotTable.ClearButton)
    else
      MenuUtility:ClickButton(slotTable.Arrow)
      coroutine.yield()
      local dyePicker = MenuUtility:GetEntityTable(self.DyePopup.Properties.DyePicker)
      picked = handleDyePicker(dyePicker)
    end
  elseif self:IsDyeScreenOpen() then
    if not eqSlot then
      error("No equipment slot provided")
    end
    local selector = MenuUtility:GetEntityTable(self.DyeScreen.slotEnumToSelectorsMap[eqSlot.slot])
    local slotTable = MenuUtility:GetEntityTable(selector[dyeSlot])
    if not dyeItemIndex or dyeItemIndex == 0 then
      MenuUtility:ClickButton(slotTable.ClearButton)
    else
      MenuUtility:ClickButton(slotTable.Arrow)
      coroutine.yield()
      local dyePicker = MenuUtility:GetEntityTable(self.DyeScreen.Properties.DyePicker)
      picked = handleDyePicker(dyePicker)
    end
  else
    error("No dyeing screen is opened")
  end
  coroutine.yield()
  return picked
end
function InventoryUtility:ConfirmDyes()
  if self:IsDyePopupOpen() then
    MenuUtility:ClickButton(self.DyePopup.Properties.ConfirmButton)
  elseif self:IsDyeScreenOpen() then
    MenuUtility:ClickButton(self.DyeScreen.Properties.ConfirmButton)
  else
    error("No dyeing screen is opened")
  end
  coroutine.yield()
  self:CloseDyeing()
end
function InventoryUtility:GetItemInformation(item)
  local function GetDescriptor()
    if item then
      if type(item) == "table" then
        for k, v in pairs(item) do
          if tostring(v) == "ItemDescriptor" then
            return v
          end
        end
        descriptor = item.descriptor
      elseif tostring(item) == "ItemDescriptor" then
        return item
      elseif item.GetItemDescriptor then
        return item:GetItemDescriptor()
      elseif item.descriptor then
        return item.descriptor
      end
    end
  end
  local descriptor = GetDescriptor()
  if not descriptor then
    error("Unsupported data type")
  end
  local staticData = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil)
  local data = {
    key = staticData.staticItem.original.key,
    itemType = staticData.staticItem.original.itemType,
    ammoType = staticData.staticItem.original.ammoType,
    tier = staticData.staticItem.original.tier,
    weight = staticData.overrides.weight,
    gearScore = staticData.overrides.gearScore,
    perks = staticData.overrides.perks,
    descriptor = descriptor
  }
  local itemContainerSlot
  local inventoryId = DataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  if not inventoryId then
    error("Unsupported inventory ID")
  end
  local slotId = ContainerRequestBus.Event.GetSlotIdByItemDescriptor(inventoryId, descriptor, true)
  if not slotId or slotId == -1 then
    local paperdollId = DataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
    slotId = EquipmentCommon.nameToPaperdollSlotMap[PaperdollRequestBus.Event.GetSlotIdByItemDescriptor(paperdollId, descriptor, true)]
    if slotId and slotId ~= "" then
      itemContainerSlot = PaperdollRequestBus.Event.GetSlot(paperdollId, slotId)
    end
  else
    itemContainerSlot = ContainerRequestBus.Event.GetSlot(inventoryId, slotId)
  end
  if itemContainerSlot then
    data.neededRepairParts = RecipeDataManagerBus.Broadcast.GetRepairDustQuantity(itemContainerSlot, true)
    data.neededGold = RecipeDataManagerBus.Broadcast.GetRepairGoldQuantity(itemContainerSlot:GetTierNumber(), itemContainerSlot:GetMaxDurability() - itemContainerSlot:GetDurability())
    data.currentDurability = itemContainerSlot:GetDurability()
    data.maxDurability = itemContainerSlot:GetMaxDurability()
  end
  return data
end
function InventoryUtility:GetGold()
  return DataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount")
end
function InventoryUtility:GetAzoth()
  return DataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothAmount")
end
function InventoryUtility:GetRepairParts()
  local repairPartId = InventoryCommon:GetRepairPartId(1)
  local playerEntityId = DataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  return CategoricalProgressionRequestBus.Event.GetProgression(playerEntityId, repairPartId)
end
return InventoryUtility

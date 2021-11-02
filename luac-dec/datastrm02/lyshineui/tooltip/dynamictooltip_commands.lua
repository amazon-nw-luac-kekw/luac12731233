local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
local CommonDragDrop = RequireScript("LyShineUI.CommonDragDrop")
local InventoryCommon = RequireScript("LyShineUI._Common.InventoryCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local DynamicTooltip_Commands = {
  Properties = {
    CommandsLabel = {
      default = EntityId()
    },
    CommandListMask = {
      default = EntityId()
    },
    CommandList = {
      default = EntityId()
    },
    EntitlementList = {
      default = EntityId()
    },
    EntitlementListParent = {
      default = EntityId()
    },
    EntitlementListBg = {
      default = EntityId()
    },
    CommandLineHeight = {default = 50},
    Divider1 = {
      default = EntityId()
    },
    RepairPartConversionConfirmation = {
      default = EntityId()
    },
    GemSelector = {
      default = EntityId()
    },
    UnusedCommandButtons = {
      default = EntityId()
    }
  },
  ANIM_DURATION = 0.07,
  itemIconScale = 2,
  repairButtonExtraLineHeight = 84,
  padding = 4,
  salvageButtonOneItemHeight = 84,
  mtxItemHeight = 84,
  fullTextWidth = 160,
  dividerHeight = 12,
  salvageConfirmPopup = "Salvage_Popup",
  repairConfirmPopup = "Repair_Popup",
  fictionalCurrencyIcon = "lyshineui/images/mtx/icon_mtx_currency.dds",
  skillToText = {},
  repairSkillToText = {},
  isInInventoryTutorial = false
}
local iconPathRoot = "lyShineui/images/icons/items/"
local StatIndendation = "   "
BaseElement:CreateNewElement(DynamicTooltip_Commands)
function DynamicTooltip_Commands:OnInit()
  BaseElement.OnInit(self)
  self.repairSkillToText.Repairing = "@ui_repairing"
  self.skillToText.Weaponsmithing = "@ui_weaponsmithing"
  self.skillToText.Armoring = "@ui_armoring"
  self.skillToText.Jewelcrafting = "@ui_jewelcrafting"
  self.skillToText.Arcana = "@ui_arcana"
  self.skillToText.Cooking = "@ui_cooking"
  self.skillToText.Furnishing = "@ui_furnishing"
  self.skillToText.Engineering = "@ui_engineering"
  self.skillToText.WildernessSurvival = "@ui_wildernesssurvival"
  self.skillToText.Alchemy = "@ui_alchemy"
  self.skillToText.Blacksmithing = "@ui_blacksmithing"
  self.skillToText.Outfitting = "@ui_outfitting"
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.isDyeingEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-dyeing")
  self.commandButtonsCache = {}
  local childEntities = UiElementBus.Event.GetChildren(self.Properties.CommandList)
  for i = 1, #childEntities do
    local element = self.registrar:GetEntityTable(childEntities[i])
    table.insert(self.commandButtonsCache, element)
  end
  self.maxCompareItems = #self.commandButtonsCache - 1
  SetTextStyle(self.Properties.CommandsLabel, self.UIStyle.FONT_STYLE_TOOLTIP_ACTIONS_HEADER)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
end
function DynamicTooltip_Commands:OnShutdown()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
end
function DynamicTooltip_Commands:OnChangeSourceHoverOnly(sourceHoverOnly)
  for k, button in ipairs(self.commandButtons) do
    UiElementBus.Event.SetIsEnabled(button.entityId, not sourceHoverOnly)
  end
end
function DynamicTooltip_Commands:OnEquip()
  self.ScriptedEntityTweener:Play(self.Properties.Divider1, 0.3, {
    opacity = 1,
    onComplete = function()
      if self.isInInventory then
        EquipmentCommon:EquipItemFromInventory(tostring(self.inventorySlotId))
      elseif not self.isInPaperdoll then
        local containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
        EquipmentCommon:EquipItemToBestSlot(tostring(self.inventorySlotId), false, containerId, nil)
      end
    end
  })
end
function DynamicTooltip_Commands:OnSalvage(pressedData)
  local slotsRemaining = CommonDragDrop:GetInventorySlotsRemaining()
  if 0 < slotsRemaining then
    self.ScriptedEntityTweener:Play(self.Properties.Divider1, 0.3, {opacity = 1})
    local pressedEntityTable = pressedData.button
    local flyoutData = {
      title = "@inv_salvage",
      description = pressedEntityTable.Button.tooltipInfo.description,
      confirmCallback = self.OnSalvageConfirm,
      confirmCallbackTable = self
    }
    if 1 < self.quantity then
      flyoutData.sliderMax = self.quantity
      flyoutData.salvageMin = self.salvageMin
      flyoutData.salvageMax = self.salvageMax
      flyoutData.salvageItemName = self.salvageItemName
    end
    if 0 < self.salvageRepairPartsToBeLost then
      local atLimit = self.salvageRepairPartsToBeLost == self.salvageRepairPartsQuantity
      local salvageCount = atLimit and 0 or self.salvageRepairPartsQuantity - self.salvageRepairPartsToBeLost
      local salvageAdditionalString
      local gemPerk = pressedData.itemDescriptor:GetGemPerk()
      local isTrinket = ItemCommon:IsTrinket(pressedData.itemDescriptor.itemId)
      local hasGemInSlot = isTrinket and gemPerk ~= 0 and gemPerk ~= ItemCommon.EMPTY_GEM_SLOT_PERK_ID
      local gemMessage = hasGemInSlot and "@inv_salvage_tooltip_gemmessage" or ""
      if ItemDataManagerBus.Broadcast.CanSalvageResources(pressedData.itemDescriptor.itemId) then
        local resourceRange = atLimit and "@inv_repairparts_resources_atlimit" or "@inv_repairparts_resources_nearlimit"
        salvageAdditionalString = GetLocalizedReplacementText(resourceRange, {
          min = self.salvageMin,
          max = self.salvageMax,
          itemName = self.salvageItemName,
          numRepairParts = salvageCount
        })
        flyoutData.description = atLimit and "@inv_repairparts_atlimit " .. salvageAdditionalString .. " " .. gemMessage or "@inv_repairparts_nearlimit" .. " " .. salvageAdditionalString .. " " .. gemMessage
      else
        salvageAdditionalString = atLimit and "@inv_repairparts_atlimit" or "@inv_repairparts_nearlimit"
        local salvageSecondaryString = GetLocalizedReplacementText("@inv_repairparts_onlyrepairparts", {numRepairParts = salvageCount})
        if atLimit then
          flyoutData.description = salvageAdditionalString .. " " .. "<font color=" .. ColorRgbaToHexString(UIStyle.COLOR_RED) .. ">" .. salvageSecondaryString .. "</font>" .. " " .. gemMessage
        else
          flyoutData.description = salvageAdditionalString .. " " .. salvageSecondaryString .. " " .. gemMessage
        end
      end
    end
    DynamicBus.ConfirmationPopup.Broadcast.ShowConfirmationPopup(self:GetFlyoutPositionFromButton(pressedEntityTable.entityId), flyoutData)
    self.salvageSlotId = self.inventorySlotId
  end
end
function DynamicTooltip_Commands:OnToggleSalvageLock(pressedData)
  if not self.itemLocation.itemInstanceId:IsNull() then
    ItemRepairRequestBus.Event.RequestSetLockState(self.playerEntityId, self.itemLocation, not self.salvageIsLocked)
  end
end
function DynamicTooltip_Commands:OnSalvageConfirm(quantity)
  quantity = quantity or 1
  if self.isInInventory then
    local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    LocalPlayerUIRequestsBus.Broadcast.SalvageItem(self.salvageSlotId, quantity, inventoryId)
  else
    local containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
    LocalPlayerUIRequestsBus.Broadcast.SalvageItem(self.salvageSlotId, quantity, containerId)
  end
  DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
end
function DynamicTooltip_Commands:OnAttachGem(pressedData)
  if not self.validGemItemSlots or #self.validGemItemSlots == 0 then
    return
  end
  local gemSelectorData = {
    itemIsInPaperdoll = self.isInPaperdoll,
    itemSlotId = self.inventorySlotId,
    itemGemPerkId = self.gemPerkId,
    validGemItemSlotIds = self.validGemItemSlots,
    confirmCallback = self.OnAttachGemConfirm,
    confirmCallbackTable = self
  }
  self.GemSelector:ShowGemSelector(self:GetFlyoutPositionFromButton(pressedData.button.entityId), gemSelectorData)
end
function DynamicTooltip_Commands:OnAttachGemConfirm()
  DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
end
function DynamicTooltip_Commands:OnOpen()
  if self.isInInventory then
    if self.isLootContainer then
      DynamicBus.BoxOpeningPopup.Broadcast.SetRewardBoxGameEventId(self.itemId)
    end
    local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    LocalPlayerUIRequestsBus.Broadcast.SalvageItem(self.inventorySlotId, 1, inventoryId)
  else
    local containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
    LocalPlayerUIRequestsBus.Broadcast.SalvageItem(self.inventorySlotId, 1, containerId)
  end
  DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
end
function DynamicTooltip_Commands:OnEntitlement(pressedData)
  local pressedEntity = pressedData.button
  local buttonPos = UiTransformBus.Event.GetViewportPosition(pressedEntity.entityId)
  local width = UiTransformBus.Event.GetViewportSpaceRect(pressedEntity.entityId):GetWidth()
  PositionEntityOnScreen(self.EntitlementListParent, Vector2(buttonPos.x + width / 2, buttonPos.y), {right = 5})
  self.EntitlementList:SetBaseItem(pressedData.itemDescriptor)
  UiElementBus.Event.SetIsEnabled(self.Properties.EntitlementListParent, true)
  self.ScriptedEntityTweener:Play(self.Properties.EntitlementListParent, 0.2, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.EntitlementListBg, 0.2, {x = -42}, {x = -32, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.EntitlementList, 0.2, {x = 0}, {x = 10, ease = "QuadOut"})
end
function DynamicTooltip_Commands:OnUnequip()
  local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
  local targetItem = PaperdollRequestBus.Event.GetSlot(paperdollId, self.paperdollSlotId)
  if targetItem and targetItem:IsValid() then
    local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    local slotsRemaining = CommonDragDrop:GetInventorySlotsRemaining()
    if 0 < slotsRemaining then
      local isSlotBlocked = PaperdollRequestBus.Event.SlotBlockedByCooldown(paperdollId, self.paperdollSlotId)
      if isSlotBlocked then
        EquipmentCommon:TriggerEquipErrorNotification("@ui_equipment_cooldown_error")
      end
      LocalPlayerUIRequestsBus.Broadcast.UnequipItem(self.paperdollSlotId, -1, targetItem:GetStackSize(), inventoryId)
    end
  end
end
function DynamicTooltip_Commands:OnRepair(pressedData)
  self.ScriptedEntityTweener:Play(self.Properties.Divider1, 0.3, {opacity = 1})
  if self.paperdollSlotId or self.inventorySlotId then
    local pressedEntityTable = pressedData.button
    if self.repairRequiresRepairPartConversion then
      self.RepairPartConversionConfirmation:ShowFlyout(self:GetFlyoutPositionFromButton(pressedEntityTable.entityId), {
        description = self.repairPartConversionMessage,
        confirmCallback = self.OnRepairConfirm,
        confirmCallbackTable = self,
        conversionData = self.repairPartConversionData
      })
    else
      DynamicBus.ConfirmationPopup.Broadcast.ShowConfirmationPopup(self:GetFlyoutPositionFromButton(pressedEntityTable.entityId), {
        title = "@inv_repair",
        description = pressedEntityTable.Button.tooltipInfo.description,
        confirmCallback = self.OnRepairConfirm,
        confirmCallbackTable = self
      })
    end
  end
end
function DynamicTooltip_Commands:OnRepairViaKit(pressedData)
  self.ScriptedEntityTweener:Play(self.Properties.Divider1, 0.3, {opacity = 1})
  if self.paperdollSlotId or self.inventorySlotId then
    local pressedEntityTable = pressedData.button
    if self.repairRequiresRepairPartConversion then
      self.RepairPartConversionConfirmation:ShowFlyout(self:GetFlyoutPositionFromButton(pressedEntityTable.entityId), {
        description = self.repairPartConversionMessage,
        confirmCallback = self.OnRepairViaKitConfirm,
        confirmCallbackTable = self,
        conversionData = self.repairPartConversionData
      })
    else
      DynamicBus.ConfirmationPopup.Broadcast.ShowConfirmationPopup(self:GetFlyoutPositionFromButton(pressedEntityTable.entityId), {
        title = "@inv_repair",
        description = pressedEntityTable.Button.tooltipInfo.description,
        confirmCallback = self.OnRepairViaKitConfirm,
        confirmCallbackTable = self
      })
    end
  end
end
function DynamicTooltip_Commands:OnRepairConfirm()
  DynamicBus.ItemRepairDynamicBus.Broadcast.OnItemRepaired(self.itemInstanceId)
  if self.isInPaperdoll then
    LocalPlayerUIRequestsBus.Broadcast.PaperdollRepairItem(self.paperdollSlotId, false)
  elseif self.isInInventory then
    LocalPlayerUIRequestsBus.Broadcast.RepairItem(self.inventorySlotId, false)
  else
    LocalPlayerUIRequestsBus.Broadcast.StorageRepairItem(self.inventorySlotId, false)
  end
  DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
end
function DynamicTooltip_Commands:OnRepairViaKitConfirm()
  DynamicBus.ItemRepairDynamicBus.Broadcast.OnItemRepaired(self.itemInstanceId)
  if self.isInPaperdoll then
    LocalPlayerUIRequestsBus.Broadcast.PaperdollRepairItem(self.paperdollSlotId, true)
  elseif self.isInInventory then
    LocalPlayerUIRequestsBus.Broadcast.RepairItem(self.inventorySlotId, true)
  else
    LocalPlayerUIRequestsBus.Broadcast.StorageRepairItem(self.inventorySlotId, true)
  end
  DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
end
function DynamicTooltip_Commands:OnDrop()
  self.ScriptedEntityTweener:Play(self.Properties.Divider1, 0.3, {
    opacity = 1,
    onComplete = function()
      self.parent.inventoryTable:DropItem(self.parent.draggableItem.entityId)
    end
  })
end
function DynamicTooltip_Commands:OnUse()
  self.ScriptedEntityTweener:Play(self.Properties.Divider1, 0.3, {
    opacity = 1,
    onComplete = function()
      self.parent.inventoryTable:UseItem(self.parent.draggableItem.entityId)
    end
  })
end
function DynamicTooltip_Commands:OnStore()
  self.ScriptedEntityTweener:Play(self.Properties.Divider1, 0.3, {
    opacity = 1,
    onComplete = function()
      if self.parent.inventoryTable then
        self.parent.inventoryTable:StoreItem(self.parent.draggableItem.entityId)
      else
        local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
        local targetItem = PaperdollRequestBus.Event.GetSlot(paperdollId, self.paperdollSlotId)
        if targetItem and targetItem:IsValid() then
          local containerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
          local isSlotBlocked = PaperdollRequestBus.Event.SlotBlockedByCooldown(paperdollId, self.paperdollSlotId)
          if isSlotBlocked then
            EquipmentCommon:TriggerEquipErrorNotification("@ui_equipment_cooldown_error")
          end
          LocalPlayerUIRequestsBus.Broadcast.UnequipItem(self.paperdollSlotId, -1, targetItem:GetStackSize(), containerId)
        end
      end
    end
  })
end
function DynamicTooltip_Commands:OnTake()
  self.ScriptedEntityTweener:Play(self.Properties.Divider1, 0.3, {
    opacity = 1,
    onComplete = function()
      self.parent.draggableItem.containerTable:TakeItem(self.parent.draggableItem.entityId)
    end
  })
end
function DynamicTooltip_Commands:OnSplit()
  self.parent.draggableItem:InvokeStackSplitter()
end
function DynamicTooltip_Commands:OnConvertRepairParts()
  DynamicBus.Inventory.Broadcast.ShowConvertRepairPartsPopup(self.tier)
end
function DynamicTooltip_Commands:OnLinkItem(itemDescriptor)
  if itemDescriptor then
    DynamicBus.ChatBus.Broadcast.LinkItem(itemDescriptor)
  end
end
function DynamicTooltip_Commands:OnBuyShopItem()
  self.parent.shopTable:BuyShopItem()
end
function DynamicTooltip_Commands:OnDyeEquipped()
  local state = LyShineManagerBus.Broadcast.GetCurrentState()
  if state ~= 3548394217 then
    LyShineManagerBus.Broadcast.SetState(3548394217)
  end
end
function DynamicTooltip_Commands:OnSkinInventoryOrStorageItem()
  local storageContainerId
  if self.itemLocation.containerType == eItemContainerType_GlobalStorage and self.storageContainerId ~= nil then
    storageContainerId = self.storageContainerId
    self.storageContainerId = nil
  end
  DynamicBus.Inventory.Broadcast.ShowItemSkinsPopup(self.parent.draggableItem.entityId, true, storageContainerId)
end
function DynamicTooltip_Commands:OnSkinPaperdollItem()
  local state = LyShineManagerBus.Broadcast.GetCurrentState()
  if state ~= 2972535350 then
    LocalPlayerUIRequestsBus.Broadcast.SetIsLookingThroughLoadout(true)
  end
  DynamicBus.Inventory.Broadcast.ShowItemSkinsPopup(self.parent.draggableItem.entityId, false, nil)
end
function DynamicTooltip_Commands:OnDyeItem()
  DynamicBus.Inventory.Broadcast.ShowItemDyeingPopup(self.parent.draggableItem.entityId)
end
function DynamicTooltip_Commands:OnOpenSteamStore(availableProduct)
  if EntitlementsDataHandler:IsStoreEnabled() then
    GameRequestsBus.Broadcast.OpenSteamStoreOverlay(availableProduct.productData.steamId)
  end
end
function DynamicTooltip_Commands:OnFlyoutLocked()
  if not self.commandButtons then
    return
  end
  for k, button in ipairs(self.commandButtons) do
    local commandButtonEntity = UiElementBus.Event.FindChildByName(button.entityId, "Button")
    local commandButton = self.registrar:GetEntityTable(commandButtonEntity)
    local isDivider = "lyshineui/images/tooltip/tooltip_sectiondivider.dds"
    local currentImagePath = UiImageBus.Event.GetSpritePathname(commandButton.ButtonBg)
    if currentImagePath ~= isDivider then
      self.ScriptedEntityTweener:Play(commandButton.ButtonBg, 0.3, {opacity = 0}, {
        opacity = 0.5,
        ease = "QuadIn",
        delay = k * self.ANIM_DURATION / 2
      })
    end
  end
end
function DynamicTooltip_Commands:SetItem(itemTable, equipSlot, compareTo, itemSlotIndex, isInInventory, isInPaperdoll)
  if self.dataLayer:IsScreenOpen("NavBar") then
    return 0
  end
  self.itemId = itemTable.id
  local isContainerOpen = LyShineManagerBus.Broadcast.IsInState(3349343259)
  local isRemoteGlobalStorage = not isInInventory and not isInPaperdoll and not isContainerOpen
  local currentLine = 0
  local isEquipped = false
  local meetsEquipRequirements = true
  local isNavBarOpen = LyShineManagerBus.Broadcast.IsInState(3766762380)
  local containerId = GetTableValue(self.parent, "draggableItem.containerId")
  local activeContainerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
  local storageTransferType = eGlobalStorageAllowTransactionType_AllowGiveAndTake
  local isLootDrop = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop") and containerId == activeContainerId
  local itemDescriptor = GetTableValue(self.parent, "draggableItem.ItemLayout.mItemData_itemDescriptor")
  local allowSplit = GetTableValue(self.parent, "draggableItem.canDrag") and not isRemoteGlobalStorage
  local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  local allowItemLinking = self.dataLayer:GetDataFromNode("UIFeatures.g_chatItemLinking")
  local itemContainerSlot
  local isGatheringTool = false
  local canUseTool = false
  local hasItemInstance = false
  local inventoryIsFull = 0 >= CommonDragDrop:GetInventorySlotsRemaining()
  self.quantity = GetTableValue(self.parent, "draggableItem.ItemLayout.mItemData_quantity") or 0
  self.RepairPartConversionConfirmation:HideFlyout(true)
  self.GemSelector:HideGemSelector()
  UiElementBus.Event.SetIsEnabled(self.Properties.EntitlementListParent, false)
  if itemTable.itemInstanceId then
    hasItemInstance = true
    self.itemInstanceId = itemTable.itemInstanceId
    self.paperdollSlotId = tonumber(itemSlotIndex)
    self.inventorySlotId = tonumber(itemSlotIndex)
    self.isInInventory = isInInventory
    self.isInPaperdoll = isInPaperdoll
    self.itemLocation = ItemLocation()
    self.itemLocation.containerType = eItemContainerType_None
    if isInInventory then
      itemContainerSlot = ContainerRequestBus.Event.GetSlot(inventoryId, self.inventorySlotId)
      self.itemLocation.containerSlotId = self.inventorySlotId
      self.itemLocation.containerType = eItemContainerType_Container
    elseif isInPaperdoll then
      local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
      itemContainerSlot = PaperdollRequestBus.Event.GetSlot(paperdollId, self.paperdollSlotId)
      isEquipped = 0 <= self.paperdollSlotId and self.paperdollSlotId < ePaperDollSlotTypes_Invalid
      self.itemLocation.containerSlotId = self.paperdollSlotId
      self.itemLocation.containerType = eItemContainerType_Paperdoll
    else
      if activeContainerId then
        self.storageContainerId = activeContainerId
        itemContainerSlot = ContainerRequestBus.Event.GetSlot(activeContainerId, itemSlotIndex)
      end
      if not isLootDrop then
        self.itemLocation.containerSlotId = itemSlotIndex
        self.itemLocation.containerType = eItemContainerType_GlobalStorage
        storageTransferType = GlobalStorageRequestBus.Event.GetCurrentGlobalStorageAllowTransactionType(self.playerEntityId)
      end
    end
    if itemContainerSlot and itemContainerSlot:IsValid() and self.itemLocation.containerType ~= eItemContainerType_None then
      self.itemLocation.itemInstanceId = itemContainerSlot:GetItemInstanceId()
    end
  end
  local itemContainerSlotIsValid = itemContainerSlot and itemContainerSlot:IsValid()
  local repairPartId
  local currentRepairParts = 0
  local repairPartIconTag = ""
  self.tier = 0
  if itemContainerSlotIsValid then
    self.tier = itemContainerSlot:GetTierNumber()
    repairPartId = InventoryCommon:GetRepairPartId(self.tier)
    if repairPartId then
      currentRepairParts = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, repairPartId)
      repairPartIconTag = "<img src=\"lyshineui/images/icons/items/resource/repairpartst1.dds\" scale=\"" .. tostring(self.itemIconScale) .. "\" yOffset=\"6\"/>"
    end
  end
  local repairIngredients, repairKitsForItem
  local repairEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.ItemRepairEntityId")
  if itemContainerSlotIsValid and repairEntityId:IsValid() then
    repairIngredients = ItemRepairRequestBus.Event.GetRepairRecipeScript(repairEntityId, itemContainerSlot)
    repairKitsForItem = ItemRepairRequestBus.Event.GetRepairKitsForSlot(repairEntityId, itemContainerSlot)
  end
  local salvageData, salvageIngredientList
  if itemDescriptor ~= nil then
    salvageIngredientList = CraftingRequestBus.Broadcast.GetSalvageOutputFromDescriptor(itemDescriptor, 1)
    salvageData = RecipeDataManagerBus.Broadcast.GetSalvageDataFromLootTable(itemDescriptor)
  end
  local repairText = "@ui_repair_icon"
  local salvageText = "@inv_salvage"
  local repairShortcutText = "@ui_tooltip_repairclick"
  local repairSecondaryText = repairShortcutText
  local repairSecondaryTextHint = LyShineManagerBus.Broadcast.GetKeybind("ui_repairItemModifier", "ui")
  local repairTertiaryText = ""
  local salvageSecondaryText = ""
  local salvageSecondaryTextHint = ""
  local salvageTertiaryText = ""
  local entitlementsText = "@ui_skin_change_skin"
  local needsRepair = false
  local canRepair = false
  local salvageTooltip = "@inv_cannotsalvage_full"
  local repairTooltip = "@ui_repair_notneeded"
  local ingredientIconTag = ""
  local repairButtonHeight, salvageButtonHeight
  local hasSalvageData = false
  local maxDurability = itemTable.maxDurability or 0
  local durabilityToRepair = maxDurability
  if type(itemTable.durability) == "number" then
    durabilityToRepair = maxDurability - itemTable.durability
  end
  if repairIngredients ~= nil and not isRemoteGlobalStorage then
    local neededRepairParts = 0
    local neededGold = 0
    if itemContainerSlotIsValid then
      local isRepair = true
      neededRepairParts = RecipeDataManagerBus.Broadcast.GetRepairDustQuantity(itemContainerSlot, isRepair)
      neededGold = RecipeDataManagerBus.Broadcast.GetRepairGoldQuantity(itemContainerSlot:GetTierNumber(), itemContainerSlot:GetMaxDurability() - itemContainerSlot:GetDurability())
    end
    local repairIngredient
    if 0 < #repairIngredients then
      repairIngredient = repairIngredients[1]
    end
    if 0 < maxDurability and 0 < durabilityToRepair then
      needsRepair = true
      if itemContainerSlotIsValid then
        canRepair = ItemRepairRequestBus.Event.CanRepairItem(repairEntityId, itemContainerSlot, false)
      end
      local repairTooltipReplacements = {}
      local ingredientText = ""
      local neededQuantity = 0
      local needsIngredientsToRepair = repairIngredient and 0 < repairIngredient.quantity
      if needsIngredientsToRepair then
        local itemData = ItemDataManagerBus.Broadcast.GetItemData(repairIngredient.itemId)
        ingredientIconTag = "<img src=\"lyshineui/images/icons/items/" .. string.lower(itemData.itemType) .. "/" .. string.lower(itemData.icon) .. ".dds\" scale=\"" .. tostring(self.itemIconScale) .. "\" yOffset=\"6\"/>"
        ingredientText = repairIngredient:GetDisplayName()
        neededQuantity = repairIngredient.quantity
        local ingredientCount = ContainerRequestBus.Event.GetMaxUniqueItemCount(inventoryId, repairIngredient, true)
        local hasIngredients = neededQuantity <= ingredientCount
        if not hasIngredients then
          repairTertiaryText = repairTertiaryText .. string.format("   <font color=\"#f25d5d\">%d</font> / <font face=\"lyshineui/fonts/Nimbus_Medium.font\">%d</font> %s", ingredientCount, neededQuantity, ingredientIconTag)
        else
          repairTertiaryText = repairTertiaryText .. string.format("   <font color=\"#c3c3c3\">%d</font> / <font face=\"lyshineui/fonts/Nimbus_Medium.font\">%d</font> %s", ingredientCount, neededQuantity, ingredientIconTag)
        end
        repairTooltipReplacements.quantityRequired = neededQuantity
        repairTooltipReplacements.itemRequired = ingredientText
      end
      local repairTooltipLocTag = "@crafting_repair_requires"
      if 0 < neededRepairParts or 0 < neededGold then
        local coinIconTag = "<img src=\"lyshineui/images/Icon_Crown\" scale=\"1.3\" yOffset=\"2\"/>"
        local currentGoldQuantity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount")
        local hasGoldQuantity = neededGold <= currentGoldQuantity
        local neededGoldDisplay = GetLocalizedCurrency(neededGold)
        local currentGoldDisplay = GetLocalizedCurrency(currentGoldQuantity)
        if not hasGoldQuantity then
          repairTertiaryText = repairTertiaryText .. string.format("   <font color=\"#f25d5d\">%s</font> / <font face=\"lyshineui/fonts/Nimbus_Medium.font\">%s</font> %s", currentGoldDisplay, neededGoldDisplay, coinIconTag)
        else
          repairTertiaryText = repairTertiaryText .. string.format("   <font color=\"#c3c3c3\">%s</font> / <font face=\"lyshineui/fonts/Nimbus_Medium.font\">%s</font> %s", currentGoldDisplay, neededGoldDisplay, coinIconTag)
        end
        local hasRepairParts = currentRepairParts >= neededRepairParts
        if not hasRepairParts then
          repairTertiaryText = repairTertiaryText .. string.format("   <font color=\"#f25d5d\">%d</font> / <font face=\"lyshineui/fonts/Nimbus_Medium.font\">%d</font> %s", currentRepairParts, neededRepairParts, repairPartIconTag)
        else
          repairTertiaryText = repairTertiaryText .. string.format("   <font color=\"#c3c3c3\">%d</font> / <font face=\"lyshineui/fonts/Nimbus_Medium.font\">%d</font> %s", currentRepairParts, neededRepairParts, repairPartIconTag)
        end
        repairTooltipLocTag = repairTooltipLocTag .. "_withrepairparts"
        repairTooltipReplacements.goldQuantityRequired = neededGoldDisplay
        repairTooltipReplacements.repairPartsRequired = neededRepairParts
        repairButtonHeight = self.repairButtonExtraLineHeight
      end
      repairTooltip = GetLocalizedReplacementText(repairTooltipLocTag, repairTooltipReplacements)
      if not canRepair and itemContainerSlotIsValid and not ItemRepairRequestBus.Event.IsRepairRecipeKnown(repairEntityId, itemContainerSlot) then
        local repairRecipeId = ItemDataManagerBus.Broadcast.GetRepairRecipe(Math.CreateCrc32(itemTable.name))
        local reqTradeskill = CraftingRequestBus.Broadcast.GetRecipeTradeskill(repairRecipeId)
        local reqRecipeLevel = CraftingRequestBus.Broadcast.GetRequiredRecipeLevel(repairRecipeId)
        local reqTradeskillLevel = CraftingRequestBus.Broadcast.GetTradeskillLevelRequiredForRecipeLevel(reqTradeskill, reqRecipeLevel)
        local repairSkillIconTag = "<img src=\"lyshineui/images/icons/Tradeskills/icon_tradeskill_" .. string.lower(reqTradeskill) .. "\" scale=\"2\" />"
        local reqRepairTradeskill = CraftingRequestBus.Broadcast.GetRecipeRepairTradeskill(repairRecipeId)
        local reqRepairTradeskillLevel = CraftingRequestBus.Broadcast.GetTradeskillLevelRequiredForRecipeLevel(reqRepairTradeskill, reqRecipeLevel)
        repairSecondaryText = "<img src=\"lyshineui/images/icons/misc/icon_question\" scale=\"1.7\" yOffset=\"4\" />" .. " @ui_tooltip_why"
        repairText = "@ui_tooltip_cantrepair"
        repairTertiaryText = ""
        local keyValueVectors = TableToKeyValueVectors({
          skillLevel = tostring(reqTradeskillLevel),
          skillName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(self.skillToText[reqTradeskill]),
          repairLevel = tostring(reqRepairTradeskillLevel),
          repairName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(self.repairSkillToText[reqRepairTradeskill])
        })
        repairTooltip = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_repair_tooltip", keyValueVectors.keys, keyValueVectors.values)
      end
    end
    if not canRepair then
      repairText = needsRepair and "@crafting_cannot_repair" or "@ui_inv_noNeedRepair"
    end
    if salvageIngredientList ~= nil and 0 < #salvageIngredientList then
      local salvageIngredient = salvageIngredientList[1]
      local itemData = ItemDataManagerBus.Broadcast.GetItemData(salvageIngredient.itemId)
      ingredientIconTag = "<img src=\"lyshineui/images/icons/items/" .. string.lower(itemData.itemType) .. "/" .. string.lower(itemData.icon) .. ".dds\" scale=\"" .. tostring(self.itemIconScale) .. "\" yOffset=\"6\"/>"
      self.salvageItemName = salvageIngredient:GetDisplayName()
      self.salvageMin = math.floor(LocalPlayerUIRequestsBus.Broadcast.GetMinimumSalvagePercent() * salvageIngredient.quantity)
      self.salvageMax = math.floor(LocalPlayerUIRequestsBus.Broadcast.GetMaximumSalvagePercent() * salvageIngredient.quantity)
      local minQuantity = LocalPlayerUIRequestsBus.Broadcast.GetMinimumSalvageQuantity()
      if minQuantity > self.salvageMin then
        self.salvageMin = minQuantity
      end
      if self.salvageMax < self.salvageMin then
        self.salvageMax = self.salvageMin
      end
      hasSalvageData = true
    end
  end
  local repairKitText = "@ui_inv_noNeedRepair"
  local repairKitShortcutText = "@ui_tooltip_repairkitclick"
  local repairKitSecondaryText = repairKitShortcutText
  local repairKitSecondaryTextHint = LyShineManagerBus.Broadcast.GetKeybind("ui_repairKitItemModifier", "ui")
  local repairKitTertiaryText = ""
  local canRepairViaKits = false
  local repairKitTooltip = "@ui_repair_notneeded"
  local repairKitButtonHeight
  local repairKitIconTag = "<img src=\"lyshineui/images/icons/items/resource/repairpartst1.dds\" scale=\"" .. tostring(self.itemIconScale) .. "\" yOffset=\"6\"/>"
  if 0 < maxDurability and 0 < durabilityToRepair then
    needsRepair = true
    if repairKitsForItem ~= nil and not isRemoteGlobalStorage then
      local repairKit
      if 0 < #repairKitsForItem then
        repairKit = repairKitsForItem[1]
      end
      if repairKit ~= nil then
        repairKitButtonHeight = self.repairButtonExtraLineHeight
        if itemContainerSlotIsValid and repairEntityId:IsValid() then
          canRepairViaKits = ItemRepairRequestBus.Event.CanRepairItem(repairEntityId, itemContainerSlot, true)
        end
        local kitData = ItemDataManagerBus.Broadcast.GetItemData(repairKit.itemId)
        local repairKitTooltipReplacements = {}
        repairKitTooltipReplacements.quantityRequired = 1
        repairKitTooltipReplacements.tierNumber = kitData.tier
        repairKitTooltipReplacements.itemRequired = repairKit:GetDisplayName()
        repairKitTooltip = GetLocalizedReplacementText("@crafting_repair_requires_kit", repairKitTooltipReplacements)
        if canRepairViaKits then
          repairKitText = "@ui_repair_kit_icon"
          repairKitTertiaryText = repairKitTertiaryText .. string.format("   <font color=\"#c3c3c3\">%d</font> / <font face=\"lyshineui/fonts/Nimbus_Medium.font\">%d</font> %s", repairKit.quantity, 1, repairKitIconTag)
        else
          repairKitText = "@crafting_cannot_repair"
          repairKitSecondaryText = "<img src=\"lyshineui/images/icons/misc/icon_question\" scale=\"1.7\" yOffset=\"4\" />" .. " @ui_tooltip_why"
          repairKitTertiaryText = repairKitTertiaryText .. string.format("   <font color=\"#f25d5d\">%d</font> / <font face=\"lyshineui/fonts/Nimbus_Medium.font\">%d</font> %s", 0, 1, repairKitIconTag)
        end
      else
        repairKitText = "@crafting_cannot_repair"
        repairKitSecondaryText = "<img src=\"lyshineui/images/icons/misc/icon_question\" scale=\"1.7\" yOffset=\"4\" />" .. " @ui_tooltip_why"
        repairKitTertiaryText = repairKitTertiaryText .. string.format("   <font color=\"#f25d5d\">%d</font> / <font face=\"lyshineui/fonts/Nimbus_Medium.font\">%d</font> %s", 0, 1, repairKitIconTag)
      end
    else
      repairKitButtonHeight = self.repairButtonExtraLineHeight
      repairKitText = "@crafting_cannot_repair"
      repairKitSecondaryText = "<img src=\"lyshineui/images/icons/misc/icon_question\" scale=\"1.7\" yOffset=\"4\" />" .. " @ui_tooltip_why"
      repairKitTertiaryText = repairKitTertiaryText .. string.format("   <font color=\"#f25d5d\">%d</font> / <font face=\"lyshineui/fonts/Nimbus_Medium.font\">%d</font> %s", 0, 1, repairKitIconTag)
    end
  end
  if salvageData ~= nil and 0 < #salvageData then
    for i = 1, #salvageData do
      if salvageData[i].roll == 0 then
        local itemData = ItemDataManagerBus.Broadcast.GetItemData(Math.CreateCrc32(salvageData[i].itemId))
        ingredientIconTag = "<img src=\"lyshineui/images/icons/items/" .. string.lower(itemData.itemType) .. "/" .. string.lower(itemData.icon) .. ".dds\" scale=\"" .. tostring(self.itemIconScale) .. "\" yOffset=\"6\"/>"
        self.salvageItemName = itemData.displayName
        self.salvageMin = salvageData[i].minQuantity
        self.salvageMax = salvageData[i].maxQuantity
        self.salvageGuaranteedIndex = i
        break
      end
    end
    hasSalvageData = true
  end
  self.salvageRepairPartsQuantity = 0
  self.salvageRepairPartsToBeLost = 0
  if itemContainerSlotIsValid then
    local isRepair = false
    self.salvageRepairPartsQuantity = RecipeDataManagerBus.Broadcast.GetRepairDustQuantity(itemContainerSlot, isRepair)
    if 0 < self.salvageRepairPartsQuantity then
      local maxRepairParts = CategoricalProgressionRequestBus.Event.GetMaxPointsForCurrentRank(self.playerEntityId, repairPartId)
      local availableRepairParts = maxRepairParts - currentRepairParts
      local willLoseRepairParts = availableRepairParts < self.salvageRepairPartsQuantity
      if willLoseRepairParts then
        self.salvageRepairPartsToBeLost = self.salvageRepairPartsQuantity - availableRepairParts
      end
    end
  end
  self.isLootContainer = itemContainerSlot and itemContainerSlot:HasItemClass(eItemClass_LootContainer)
  local salvageCommandVisible = itemTable.canSalvage and not self.isLootContainer and (isEquipped or (isInInventory or not isLootDrop) and hasSalvageData)
  local salvageLockCommandVisible = salvageCommandVisible and itemContainerSlot and itemContainerSlot:CanBeLocked()
  self.salvageIsLocked = salvageLockCommandVisible and itemContainerSlot:IsLocked()
  local salvageCommandDisabled = itemTable.canSalvage and (inventoryIsFull or isEquipped or self.salvageIsLocked or storageTransferType ~= eGlobalStorageAllowTransactionType_AllowGiveAndTake)
  local salvageLockSecondaryTextHint = LyShineManagerBus.Broadcast.GetKeybind("ui_salvageLockItemModifier", "ui")
  if salvageCommandVisible then
    if not salvageCommandDisabled then
      salvageText = "@ui_salvage_icon"
      self.durabilityPercent = 0 < itemTable.maxDurability and itemTable.durability / itemTable.maxDurability or 1
      salvageSecondaryText, salvageSecondaryTextHint, salvageTertiaryText, salvageTooltip, salvageButtonHeight = self:GetSalvageSecondaryAndTooltipText(ingredientIconTag, repairPartIconTag, itemDescriptor, salvageData)
    elseif isEquipped then
      salvageTooltip = "@inv_cannotsalvage_equipped"
    elseif self.salvageIsLocked then
      salvageTooltip = "@tooltip_salvage_locked"
    elseif storageTransferType ~= eGlobalStorageAllowTransactionType_AllowGiveAndTake then
      salvageTooltip = "@tooltip_salvage_remote"
    end
  end
  local repairCommandVisible = 0 < maxDurability and (isEquipped or isInInventory) and not isRemoteGlobalStorage
  local repairKitCommandVisible = repairCommandVisible and needsRepair and canRepairViaKits
  self.gemPerkId = nil
  self.validGemItemSlots = nil
  local hasGemSlot = false
  local hasGemInSlot = false
  if (isInPaperdoll or isInInventory) and itemDescriptor ~= nil then
    self.gemPerkId = itemDescriptor:GetGemPerk()
    hasGemSlot = self.gemPerkId ~= 0
    hasGemInSlot = hasGemSlot and self.gemPerkId ~= ItemCommon.EMPTY_GEM_SLOT_PERK_ID
    if itemContainerSlotIsValid then
      self.validGemItemSlots = ContainerRequestBus.Event.FindGemsForItem(inventoryId, itemContainerSlot)
    end
  end
  local hasValidGemForItem = self.validGemItemSlots and 0 < #self.validGemItemSlots
  local attachGemCommandVisible = hasGemSlot
  local attachGemText = hasGemInSlot and "@ui_replace_gem" or "@ui_attach_gem"
  local attachGemTooltip = "@ui_no_gems_tooltip"
  if itemTable.canReplaceGem == false then
    attachGemTooltip = "@ui_cannot_replace_gem_tooltip"
  elseif hasValidGemForItem then
    attachGemTooltip = hasGemInSlot and "@ui_replace_gem_tooltip" or "@ui_attach_gem_tooltip"
  end
  if itemTable.requiredLevel then
    local requirements = {
      {
        attribute = "requiredLevel",
        dataPath = "Hud.LocalPlayer.Progression.Level"
      }
    }
    for _, requirement in ipairs(requirements) do
      local value = GetTableValue(itemTable, requirement.attribute)
      if type(value) == "number" and 0 < value then
        local playerValue = self.dataLayer:GetDataFromNode(requirement.dataPath)
        if not playerValue or value > playerValue then
          meetsEquipRequirements = false
          break
        end
      end
    end
  end
  local equipText = "@ui_tooltip_equip"
  local equipCommandTooltip
  local isEquippable = self.itemId and ItemDataManagerBus.Broadcast.IsEquippable(self.itemId)
  if isEquippable and not meetsEquipRequirements then
    equipCommandTooltip = {
      description = "@ui_tooltip_equip_requirements_not_met"
    }
  end
  local equipCommandVisible = isEquippable and not isEquipped and storageTransferType == eGlobalStorageAllowTransactionType_AllowGiveAndTake
  if itemTable.isRewardOwned ~= nil and equipCommandVisible then
    equipCommandVisible = itemTable.isRewardOwned
  end
  local buyCommandVisible = false
  local buyCommandTooltip
  if itemTable.owgAvailableItem then
    buyCommandVisible = false
    buyCommandTooltip = GetLocalizedReplacementText("@owg_buy_command_tooltip", {
      influence = itemTable.owgAvailableItem.influence,
      coin = GetLocalizedCurrency(itemTable.owgAvailableItem.coin)
    })
  end
  local isDyable = itemContainerSlot and (itemContainerSlot:HasItemClass(eItemClass_EquippableChest) or itemContainerSlot:HasItemClass(eItemClass_EquippableHands) or itemContainerSlot:HasItemClass(eItemClass_EquippableLegs) or itemContainerSlot:HasItemClass(eItemClass_EquippableFeet) or itemContainerSlot:HasItemClass(eItemClass_EquippableHead) or itemContainerSlot:HasItemClass(eItemClass_Shield))
  local inventoryTutorialActive = self.isFtue and self.isInInventoryTutorial
  local isLockedInInventory = itemTable.isSelectedForTrade
  local commands = {
    {
      visible = buyCommandVisible and not inventoryTutorialActive,
      text = "@owg_buy_command_flyout_row",
      callback = self.OnBuyShopItem,
      isDisabled = not self.parent.shopTable or not self.parent.shopTable:CanBuy(),
      showDisabled = not self.parent.shopTable or not self.parent.shopTable:CanBuy(),
      tooltip = {description = buyCommandTooltip}
    },
    {
      visible = repairCommandVisible and not inventoryTutorialActive and not isLockedInInventory,
      text = repairText,
      secondaryText = repairSecondaryText,
      secondaryTextHint = repairSecondaryTextHint,
      tertiaryText = repairTertiaryText,
      callback = self.OnRepair,
      showDisabled = not canRepair,
      tooltip = {description = repairTooltip, isRepair = true},
      buttonHeight = repairButtonHeight,
      stayOpenOnPress = true
    },
    {
      visible = repairKitCommandVisible and not inventoryTutorialActive and not isLockedInInventory,
      text = repairKitText,
      secondaryText = repairKitSecondaryText,
      secondaryTextHint = repairKitSecondaryTextHint,
      tertiaryText = repairKitTertiaryText,
      callback = self.OnRepairViaKit,
      showDisabled = not canRepairViaKits,
      tooltip = {
        description = repairKitTooltip,
        isRepair = true,
        isRepairKit = true
      },
      buttonHeight = repairKitButtonHeight,
      stayOpenOnPress = true
    },
    {
      visible = salvageCommandVisible and not inventoryTutorialActive and not isLockedInInventory,
      text = salvageText,
      secondaryText = salvageSecondaryText,
      secondaryTextHint = salvageSecondaryTextHint,
      tertiaryText = salvageTertiaryText,
      callback = self.OnSalvage,
      showDisabled = salvageCommandDisabled,
      isDisabled = salvageCommandDisabled,
      tooltip = {
        description = salvageTooltip,
        isSalvage = not salvageCommandDisabled
      },
      buttonHeight = salvageButtonHeight,
      stayOpenOnPress = true
    },
    {
      visible = equipCommandVisible and not inventoryTutorialActive and not isLockedInInventory,
      text = equipText,
      secondaryText = isInInventory and "@ui_tooltip_doubleclick" or nil,
      callback = self.OnEquip,
      showDisabled = not meetsEquipRequirements,
      isDisabled = not meetsEquipRequirements,
      tooltip = equipCommandTooltip
    },
    {
      visible = itemTable.canEquip and isEquipped and not inventoryTutorialActive,
      text = "@ui_tooltip_unequip",
      secondaryText = "@ui_tooltip_doubleclick",
      showDisabled = inventoryIsFull or isNavBarOpen,
      isDisabled = inventoryIsFull or isNavBarOpen,
      req = isEquipped,
      callback = self.OnUnequip
    },
    {
      visible = itemTable.canUse and itemTable.itemType == "Lore",
      text = "@ui_tooltip_read",
      callback = self.OnUse
    },
    {
      visible = self.isLootContainer and (isInInventory or not isLootDrop) and storageTransferType == eGlobalStorageAllowTransactionType_AllowGiveAndTake and not inventoryTutorialActive,
      text = "@ui_open",
      callback = self.OnOpen
    },
    {
      visible = isInInventory and itemTable.itemType == "Consumable" and not inventoryTutorialActive and not isLockedInInventory,
      text = "@inv_use",
      showDisabled = not itemTable.canUse or itemTable.isOnCooldown,
      isDisabled = not itemTable.canUse or itemTable.isOnCooldown,
      callback = self.OnUse
    },
    {
      visible = itemTable.canDrop and not inventoryTutorialActive and not isEquipped and isInInventory and (not isContainerOpen or isLootDrop) and not isLockedInInventory,
      text = "@ui_tooltip_discard",
      secondaryText = "@ui_tooltip_shiftclick",
      callback = self.OnDrop
    },
    {
      visible = attachGemCommandVisible and not inventoryTutorialActive and not isRemoteGlobalStorage and not isLockedInInventory,
      text = attachGemText,
      callback = self.OnAttachGem,
      showDisabled = not hasValidGemForItem,
      tooltip = {description = attachGemTooltip},
      stayOpenOnPress = true
    },
    {
      visible = isContainerOpen and not isLootDrop and (isInInventory or isEquipped) and not inventoryTutorialActive and itemTable.canDrop,
      text = "@ui_tooltip_store",
      secondaryText = "@ui_tooltip_shiftclick",
      callback = self.OnStore
    },
    {
      visible = hasItemInstance and isContainerOpen and not isEquipped and not isInInventory and not inventoryTutorialActive,
      text = "@ui_tooltip_take",
      secondaryText = "@ui_tooltip_shiftclick",
      showDisabled = inventoryIsFull or storageTransferType == eGlobalStorageAllowTransactionType_AllowNone,
      callback = self.OnTake,
      tooltip = storageTransferType == eGlobalStorageAllowTransactionType_AllowNone and {
        description = "@ui_transfertooltip"
      } or nil
    },
    {
      visible = self.quantity > 1 and allowSplit and not inventoryTutorialActive and not isLockedInInventory and itemTable.canDrop,
      text = "@ui_tooltip_split",
      secondaryText = "@ui_tooltip_ctrlclick",
      showDisabled = itemTable.isOnCooldown,
      isDisabled = itemTable.isOnCooldown,
      callback = self.OnSplit
    },
    {
      visible = itemDescriptor ~= nil and allowItemLinking and not self.isFtue,
      text = "@ui_item_link_tooltip_command",
      secondaryText = "@ui_tooltip_altclick",
      callback = function(self)
        self:OnLinkItem(itemDescriptor)
      end
    },
    {
      visible = self.isDyeingEnabled and not inventoryTutorialActive and (itemTable.itemType == "Dye" and isInInventory or isDyable and isEquipped) and not isLockedInInventory,
      text = "@ui_itemtypedescription_dye",
      callback = self.OnDyeEquipped
    },
    {
      visible = self.isDyeingEnabled and not inventoryTutorialActive and isDyable and isInInventory and not isLockedInInventory,
      text = "@ui_itemtypedescription_dye",
      callback = self.OnDyeItem
    },
    {
      visible = salvageLockCommandVisible,
      text = self.salvageIsLocked and "@command_unlock_salvage" or "@command_lock_salvage",
      secondaryText = "@ui_tooltip_salvagelockclick",
      secondaryTextHint = salvageLockSecondaryTextHint,
      callback = self.OnToggleSalvageLock,
      tooltip = {
        description = self.salvageIsLocked and "@tooltip_unlock_salvage" or "@tooltip_lock_salvage"
      },
      stayOpenOnPress = false
    }
  }
  local titleText = itemTable.availableProducts and "@ui_purchase" or "@ui_tooltip_actions"
  UiTextBus.Event.SetTextWithFlags(self.Properties.CommandsLabel, titleText, eUiTextSet_SetLocalized)
  if itemTable.availableProducts then
    for productIdx, availableProduct in ipairs(itemTable.availableProducts) do
      local priceTextSecondary = ""
      local priceTextTertiary = ""
      local buttonHeight
      local textHeight = 40
      local secondaryTextStyle = {
        fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
        fontSize = 22,
        fontColor = self.UIStyle.COLOR_GRAY_50
      }
      local tertiaryTextStyle = {
        fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
        fontSize = 28,
        fontColor = self.UIStyle.COLOR_WHITE
      }
      local isCrossVisible = false
      local secondaryTextPosY = 36
      local secondaryTextIcon = self.fictionalCurrencyIcon
      if availableProduct.isFictional then
        secondaryTextIcon = self.fictionalCurrencyIcon
        priceTextSecondary = GetLocalizedNumber(availableProduct.finalPrice)
        priceTextTertiary = GetLocalizedNumber(availableProduct.originalPrice)
      else
        secondaryTextIcon = nil
        priceTextSecondary = GetLocalizedRealWorldCurrency(availableProduct.finalPrice, availableProduct.currencyCode)
        priceTextTertiary = GetLocalizedRealWorldCurrency(availableProduct.originalPrice, availableProduct.currencyCode)
      end
      if availableProduct.originalPrice == availableProduct.finalPrice then
        priceTextTertiary = ""
        buttonHeight = self.mtxItemHeight
        isCrossVisible = false
        secondaryTextPosY = 56
        secondaryTextStyle = {
          fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
          fontSize = 22,
          fontColor = self.UIStyle.COLOR_WHITE
        }
      else
        if availableProduct.isFictional then
          priceTextTertiary = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_currency_price_big", GetLocalizedNumber(availableProduct.finalPrice))
        else
          priceTextTertiary = GetLocalizedRealWorldCurrency(availableProduct.finalPrice, availableProduct.currencyCode)
        end
        buttonHeight = self.mtxItemHeight
        isCrossVisible = true
        secondaryTextStyle = {
          fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
          fontSize = 22,
          fontColor = self.UIStyle.COLOR_GRAY_50
        }
      end
      local rewards = EntitlementsDataHandler:GetRewardsForOffer(availableProduct)
      local buttonText = availableProduct.productData.displayName
      table.insert(commands, {
        visible = true,
        text = buttonText,
        textHeight = textHeight,
        secondaryText = priceTextSecondary,
        tertiaryText = priceTextTertiary,
        buttonHeight = buttonHeight,
        secondaryTextStyle = secondaryTextStyle,
        tertiaryTextStyle = tertiaryTextStyle,
        isDividerVisible = false,
        isCrossVisible = isCrossVisible,
        secondaryTextPosY = secondaryTextPosY,
        tertiaryTextPosY = 52,
        secondaryTextIcon = secondaryTextIcon,
        callback = function(self)
          DynamicBus.StoreScreenBus.Broadcast.InvokeStoreWithOffer(availableProduct, "tooltip")
        end
      })
    end
  end
  if itemTable.hasEntitlements and self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableItemEntitlements") and not isRemoteGlobalStorage then
    local activeItemSkinItemId = ItemSkinningRequestBus.Event.GetItemSkinItemId(self.playerEntityId, Math.CreateCrc32(itemTable.name))
    local callback = self.OnSkinInventoryOrStorageItem
    if isInPaperdoll then
      callback = self.OnSkinPaperdollItem
    end
    local entitlementIcon = "lyshineui/images/icons/crafting/icon_skin_mask_tan"
    table.insert(commands, {
      visible = itemTable.hasEntitlements,
      stayOpenOnPress = false,
      text = entitlementsText,
      secondaryText = "<img src=\"" .. entitlementIcon .. "\" scale=\"1\" yOffset=\"1.2\"/>",
      callback = callback
    })
  end
  for i, commandButton in ipairs(self.commandButtonsCache) do
    UiElementBus.Event.Reparent(commandButton.entityId, self.Properties.UnusedCommandButtons, EntityId())
  end
  self.commandButtons = {}
  local margin = 0
  for i, command in ipairs(commands) do
    if command.visible then
      local commandLine = self.commandButtonsCache[currentLine + 1]
      currentLine = currentLine + 1
      if commandLine then
        UiElementBus.Event.Reparent(commandLine.entityId, self.Properties.CommandList, EntityId())
        UiElementBus.Event.SetIsEnabled(commandLine.entityId, true)
        local button = UiElementBus.Event.FindChildByName(commandLine.entityId, "Button")
        local buttonTable = self.registrar:GetEntityTable(button)
        local textWidth
        if itemTable.availableProducts then
          textWidth = self.fullTextWidth
        elseif command.secondaryText == nil or command.text == repairText then
          textWidth = self.fullTextWidth
        end
        local buttonData = {
          buttonText = command.text,
          secondaryText = command.secondaryText,
          secondaryTextHint = command.secondaryTextHint,
          tertiaryText = command.tertiaryText,
          secondaryTextStyle = command.secondaryTextStyle,
          tertiaryTextStyle = command.tertiaryTextStyle,
          buttonHeight = command.buttonHeight,
          callbackTable = self,
          textWidth = command.textWidth or textWidth,
          textHeight = command.textHeight,
          callback = command.callback,
          callbackData = {button = commandLine, itemDescriptor = itemDescriptor},
          hint = command.hint,
          tooltipInfo = command.tooltip,
          isDisabled = command.isDisabled,
          stayOpenOnPress = command.stayOpenOnPress,
          isDivider = command.isDivider,
          isDividerVisible = command.isDividerVisible,
          isCrossVisible = command.isCrossVisible,
          secondaryTextIcon = command.secondaryTextIcon,
          secondaryTextPosY = command.secondaryTextPosY,
          tertiaryTextPosY = command.tertiaryTextPosY
        }
        if command.showDisabled then
          buttonData.bgColor = self.UIStyle.COLOR_GRAY_DARK
          buttonData.color = self.UIStyle.COLOR_GRAY_30
          buttonData.isDisabled = true
        else
          buttonData.bgColor = self.UIStyle.COLOR_TOOLTIP_COMMAND_BG
          buttonData.color = self.UIStyle.COLOR_WHITE
          buttonData.isDisabled = false
        end
        commandLine:SetData(buttonData)
        if command.buttonHeight then
          if command.tooltip and (command.tooltip.isRepair or command.tooltip.isSalvage) then
            command.buttonHeight = self.Properties.CommandLineHeight
          end
          margin = margin + command.buttonHeight - self.Properties.CommandLineHeight
        end
      end
      self.commandButtons[#self.commandButtons + 1] = commandLine
    end
  end
  if currentLine == 0 then
    return 0
  end
  return self.Properties.CommandLineHeight * currentLine + (currentLine - 1) * self.padding + margin
end
function DynamicTooltip_Commands:SetTextColor(entity, color)
  UiTextBus.Event.SetColor(entity, color)
end
function DynamicTooltip_Commands:GetFlyoutPositionFromButton(buttonEntityId)
  local buttonRect = UiTransformBus.Event.GetViewportSpaceRect(buttonEntityId)
  return Vector2(buttonRect:GetCenterX(), buttonRect:GetCenterY() - 24)
end
function DynamicTooltip_Commands:GetSalvageSecondaryAndTooltipText(ingredientIconTag, repairPartIconTag, itemDescriptor, salvageData)
  local salvageShortcutText = "@ui_tooltip_salvageclick"
  local secondaryText = salvageShortcutText
  local secondaryTextHint = LyShineManagerBus.Broadcast.GetKeybind("ui_salvageItemModifier", "ui")
  local tertiaryText = ""
  local tooltipLocTag = ""
  local tooltipReplacements = {}
  local buttonHeight
  local canSalvageResouces = ItemDataManagerBus.Broadcast.CanSalvageResources(itemDescriptor.itemId)
  local coinSalvageAmount = GameEventRequestBus.Broadcast.GetSalvageCoinAmount(itemDescriptor:GetItemKey(), self.durabilityPercent)
  if canSalvageResouces then
    if self.salvageMin ~= self.salvageMax then
      tertiaryText = tertiaryText .. string.format("   <font color=\"#ffffff\">%d - %d</font> %s", self.salvageMin, self.salvageMax, ingredientIconTag)
      tooltipLocTag = "@inv_salvage_tooltip_range"
      tooltipReplacements.min = self.salvageMin
      tooltipReplacements.max = self.salvageMax
      tooltipReplacements.itemName = self.salvageItemName
    else
      tertiaryText = tertiaryText .. string.format("   <font color=\"#ffffff\">%d</font> %s", self.salvageMin, ingredientIconTag)
      tooltipLocTag = "@inv_salvage_tooltip"
      tooltipReplacements.numItems = self.salvageMin
      tooltipReplacements.itemName = self.salvageItemName
    end
  end
  if self.salvageRepairPartsQuantity > 0 then
    tooltipReplacements.coinAmount = GetLocalizedReplacementText("@ui_coin_icon", {
      coin = GetLocalizedCurrency(coinSalvageAmount)
    })
    tertiaryText = tertiaryText .. string.format("   <font color=\"#ffffff\">%d</font> %s", self.salvageRepairPartsQuantity, repairPartIconTag)
    if canSalvageResouces then
      tooltipLocTag = tooltipLocTag .. "_withrepairparts"
    elseif 0 < coinSalvageAmount then
      tooltipLocTag = "@inv_salvage_tooltip_repairparts_and_coin"
      tertiaryText = tertiaryText .. "   " .. tooltipReplacements.coinAmount
    else
      tooltipLocTag = "@inv_salvage_tooltip_onlyrepairparts"
    end
    tooltipReplacements.numRepairParts = self.salvageRepairPartsQuantity
  end
  local salvageItemData = ItemDataManagerBus.Broadcast.GetItemData(itemDescriptor.itemId)
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
    tertiaryText = GetLocalizedReplacementText("@inv_salvage_tertiary_recipe", {recipeName = displayName})
    tooltipLocTag = GetLocalizedReplacementText("@inv_salvage_tooltip_recipe", {recipeName = displayName})
  end
  buttonHeight = self.salvageButtonOneItemHeight
  local isTrinket = ItemCommon:IsTrinket(itemDescriptor.itemId)
  local gemPerk = itemDescriptor:GetGemPerk()
  local hasGemInSlot = isTrinket and gemPerk ~= 0 and gemPerk ~= ItemCommon.EMPTY_GEM_SLOT_PERK_ID
  tooltipReplacements.gemMessage = hasGemInSlot and " @inv_salvage_tooltip_gemmessage" or ""
  if 1 < #salvageData then
    for i = 1, #salvageData do
      if i ~= self.salvageGuaranteedIndex then
        local itemData = ItemDataManagerBus.Broadcast.GetItemData(Math.CreateCrc32(salvageData[i].itemId))
        tooltipReplacements.gemMessage = GetLocalizedReplacementText("@inv_salvage_tooltip_additional_item", {
          itemData.displayName
        })
        break
      end
    end
    tertiaryText = tertiaryText .. " + <img src=\"lyShineui/images/icons/tooltip/icon_unknown.dds\" scale=\"" .. tostring(self.itemIconScale) .. "\" yOffset=\"9\"/>"
  end
  local tooltip = GetLocalizedReplacementText(tooltipLocTag, tooltipReplacements)
  return secondaryText, secondaryTextHint, tertiaryText, tooltip, buttonHeight
end
function DynamicTooltip_Commands:GetRepairPartsAutoConversionData(currentParts, neededParts)
  if neededParts <= currentParts or self.tier == 1 then
    return false
  end
  local conversionData = {}
  local convertedParts = self:AutoConvertRepairPartsRecursive(conversionData, self.tier, neededParts, true)
  return neededParts <= currentParts + convertedParts, conversionData
end
function DynamicTooltip_Commands:AutoConvertRepairPartsRecursive(conversionData, tier, neededParts, isOriginalTier)
  local exchangeData = InventoryCommon:GetRepairPartExchangeData(tier)
  local repairPartId = InventoryCommon:GetRepairPartId(tier)
  local currentParts = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, repairPartId)
  if not isOriginalTier and exchangeData then
    neededParts = math.ceil(neededParts / exchangeData.toCurrencyQuantity) * exchangeData.fromCurrencyQuantity
  end
  table.insert(conversionData, {
    tier = tier,
    currentParts = currentParts,
    neededParts = neededParts,
    convertedParts = 0
  })
  local index = #conversionData
  if currentParts >= neededParts then
    if exchangeData then
      return neededParts * exchangeData.toCurrencyQuantity / exchangeData.fromCurrencyQuantity
    else
      return neededParts
    end
  elseif tier == 1 then
    return 0
  end
  conversionData[index].convertedParts = self:AutoConvertRepairPartsRecursive(conversionData, tier - 1, neededParts - currentParts, false)
  if neededParts <= currentParts + conversionData[index].convertedParts then
    if isOriginalTier then
      return conversionData[index].convertedParts
    elseif exchangeData then
      return neededParts * exchangeData.toCurrencyQuantity / exchangeData.fromCurrencyQuantity
    else
      return neededParts
    end
  else
    return 0
  end
end
function DynamicTooltip_Commands:SetInventoryTutorialActive(isActive)
  self.isInInventoryTutorial = isActive
end
return DynamicTooltip_Commands

local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local ClickRecognizer = RequireScript("LyShineUI._Common.ClickRecognizer")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local cryActionCommon = RequireScript("LyShineUI._Common.CryActionCommon")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local CatContainer = {
  Properties = {
    Content = {
      default = EntityId()
    },
    FrameMultiBg = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    PrimaryTitle = {
      default = EntityId()
    },
    DynamicItemList = {
      default = EntityId()
    },
    LootBagSimpleGrid = {
      default = EntityId()
    },
    ContainerAreaDropTarget = {
      default = EntityId()
    },
    ButtonTakeAll = {
      default = EntityId()
    },
    WeightBar = {
      default = EntityId()
    },
    HiddenItemsText = {
      default = EntityId()
    },
    HiddenItemsContainer = {
      default = EntityId()
    },
    SortAndFilterBar = {
      default = EntityId()
    },
    LootBagInfoContainer = {
      default = EntityId()
    },
    LootBagItemsText = {
      default = EntityId()
    },
    ScrollboxContent = {
      default = EntityId()
    },
    ScrollBar = {
      default = EntityId()
    },
    LineHorizontal1 = {
      default = EntityId()
    },
    LineHorizontal2 = {
      default = EntityId()
    },
    GlobalStorageLocationHolder = {
      default = EntityId()
    },
    GlobalStorageLocationDropDown = {
      default = EntityId()
    },
    GlobalStorageLocationTitle = {
      default = EntityId()
    },
    GlobalStorageLocationDivider = {
      default = EntityId()
    }
  },
  containerEntityId = nil,
  interactorEntityId = nil,
  buildableEntityId = nil,
  ownershipEntityId = nil,
  storageEntityId = nil,
  lootDropEntityId = nil,
  itemCount = 0,
  canTakeAllItems = false,
  cryActionHandlers = {},
  STATE_NAME_NAVBAR = 3766762380,
  STATE_NAME_CONTAINER = 3349343259,
  STATE_NAME_TRANSFER_CURRENCY = 2729122569,
  STATE_ITEM_TAKE_REQUEST = 0,
  STATE_ITEMS_BY_CLASS_TAKE_REQUEST = 1,
  STATE_ALL_ITEMS_TAKE_REQUEST = 2,
  remoteTakeRequestType = 0,
  isSplittingStackModifierActive = false,
  isUsingLootBagMode = false,
  globalStorageMaxRows = 7
}
BaseScreen:CreateNewScreen(CatContainer)
function CatContainer:OnInit()
  BaseScreen.OnInit(self)
  DynamicBus.CatContainer.Connect(self.entityId, self)
  self.dataLayer:SetScreenNameOverride("Container", "CatContainer")
  self.remoteStorageEnabled = ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enable-remote-storage-transfer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, factionType)
    self.localPlayerFaction = factionType
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.HudComponent.InteractorEntityId", function(self, interactorEntityId)
    self.interactorEntityId = interactorEntityId
  end)
  self.dataLayer:RegisterOpenEvent("CatContainer", self.canvasId)
  ClickRecognizer:OnActivate(self, "ItemUpdateDragData", "ItemInteract", self.OnDoubleClick, nil, self.OnSingleClick)
  if not self.containerScreenRequestBusHandler then
    self.containerScreenRequestBusHandler = self:BusConnect(ContainerScreenRequestBus)
  end
  SetTextStyle(self.Properties.PrimaryTitle, self.UIStyle.FONT_STYLE_INVENTORY_PRIMARY_TITLE)
  SetTextStyle(self.Properties.LootBagItemsText, self.UIStyle.FONT_STYLE_LOOT_BAG_ITEMS)
  SetTextStyle(self.Properties.GlobalStorageLocationTitle, self.UIStyle.FONT_STYLE_FLAVOR_TEXT)
  UiTextBus.Event.SetTextWithFlags(self.Properties.GlobalStorageLocationTitle, "@ui_remotetransfer_storage_location", eUiTextSet_SetLocalized)
  self.ButtonTakeAll:SetText("@interact_takeAll")
  self.ButtonTakeAll:SetBackgroundOpacity(0.2)
  self.ButtonTakeAll:SetCallback("ContainerTakeAll", self)
  self.ButtonTakeAll:SetHint("ui_interact", true)
  self.WeightBar:SetMaxOveragePercent(0.135)
  self.WeightBar:SetOverageText("@ui_storage_is_full")
  self.DynamicItemList:SetTransferAllInfo(self, self.CanTransferAllByClass, self.OnTransferAllByClass, "@ui_takeAll", 0.5)
  self.DynamicItemList:SetRepairAllEnabled(false)
  local colorLine = self.UIStyle.COLOR_TAN_LIGHT
  self.LineHorizontal1:SetColor(colorLine)
  self.LineHorizontal2:SetColor(colorLine)
  self.GlobalStorageLocationDivider:SetColor(colorLine)
  local alphaLine = 0.7
  self.ScriptedEntityTweener:Set(self.Properties.LineHorizontal1, {opacity = alphaLine})
  self.ScriptedEntityTweener:Set(self.Properties.LineHorizontal2, {opacity = alphaLine})
  self.ScriptedEntityTweener:Set(self.Properties.GlobalStorageLocationDivider, {opacity = alphaLine})
  self.GlobalStorageLocationDropDown:SetWidth(560)
  self.GlobalStorageLocationDropDown:SetDropdownScreenCanvasId(self.entityId)
end
function CatContainer:BuildOutpostData()
  self.outpostData = {}
  local outpostsAndSettlements = ObjectiveInteractorRequestBus.Broadcast.GetOutpostDestinations()
  if outpostsAndSettlements then
    for i = 1, #outpostsAndSettlements do
      local locationData = outpostsAndSettlements[i]
      local definition = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(locationData.territoryId)
      if definition.isTerritory or definition.outpostId ~= "" then
        local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(locationData.territoryId)
        local outpostData = {
          actorId = locationData.id,
          name = locationData.nameLocalizationKey,
          territoryId = locationData.territoryId,
          parentEntity = self.entityId,
          faction = ownerData.faction,
          hasItems = false,
          currentLocation = false
        }
        table.insert(self.outpostData, outpostData)
      end
    end
  end
end
function CatContainer:UpdateOutpostData()
  if not self.outpostData then
    self:BuildOutpostData()
  end
  local hasViewOnlyOptions = false
  local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  local currentTerritoryData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(territoryId)
  local useTerritoryId = true
  for _, outpostData in ipairs(self.outpostData) do
    if self.currentStorageId == outpostData.territoryId then
      useTerritoryId = false
      break
    end
  end
  if useTerritoryId then
    self.currentStorageId = territoryId
  end
  local currentOutpostData
  for _, outpostData in ipairs(self.outpostData) do
    local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(outpostData.territoryId)
    outpostData.faction = ownerData.faction
    outpostData.currentLocation = self.currentStorageId == outpostData.territoryId
    outpostData.canTransfer = currentTerritoryData.faction == outpostData.faction and self.localPlayerFaction ~= eFactionType_None and self.localPlayerFaction == outpostData.faction
    hasViewOnlyOptions = hasViewOnlyOptions or not outpostData.canTransfer and not outpostData.currentLocation
  end
  local extraOptions = hasViewOnlyOptions and 3 or 1
  local listItemData = {}
  table.insert(listItemData, {
    style = "TransferHeader",
    text = "@ui_transferheader"
  })
  for _, outpostData in ipairs(self.outpostData) do
    if outpostData.currentLocation or outpostData.canTransfer then
      local dropdownData = {}
      dropdownData.style = "Location"
      dropdownData.image = FactionCommon.factionInfoTable[outpostData.faction].npcIcon
      dropdownData.text = outpostData.name
      dropdownData.actorId = outpostData.actorId
      if outpostData.currentLocation then
        self.selectedStorageLocation = dropdownData.text
        dropdownData.text = dropdownData.text .. " <font color=\"#edc63e\">(@ui_current_location)</font>"
        self.GlobalStorageLocationDropDown:SetText(dropdownData.text)
        self.GlobalStorageLocationDropDown:SetSelectedImage(dropdownData.image)
      end
      table.insert(listItemData, dropdownData)
    end
  end
  if hasViewOnlyOptions then
    table.insert(listItemData, {
      style = "ViewOnlyHeader",
      text = "@ui_viewheader"
    })
    for _, outpostData in ipairs(self.outpostData) do
      if not outpostData.currentLocation and not outpostData.canTransfer then
        local dropdownData = {}
        dropdownData.style = "Location"
        dropdownData.image = FactionCommon.factionInfoTable[outpostData.faction].npcIcon
        dropdownData.text = outpostData.name
        dropdownData.actorId = outpostData.actorId
        table.insert(listItemData, dropdownData)
      end
    end
  end
  local rowsToDisplay = #listItemData > self.globalStorageMaxRows and self.globalStorageMaxRows or #listItemData
  self.GlobalStorageLocationDropDown:SetDropdownListHeightByRows(rowsToDisplay)
  self.GlobalStorageLocationDropDown:SetListData(listItemData)
  self.GlobalStorageLocationDropDown:SetCallback(self.OnLocationSelected, self)
  self.GlobalStorageLocationDropDown:SetImageSize(50)
  self.GlobalStorageLocationDropDown:SetImagePositionX(5)
  self.GlobalStorageLocationDropDown:SetImagePositionY(3)
  self.GlobalStorageLocationDropDown:SetImageAlignment(self.GlobalStorageLocationDropDown.IMAGE_ALIGNMENT_LEFT)
end
function CatContainer:OnLocationSelected(item, itemData)
  self.selectedStorageLocation = itemData.text
  self.GlobalStorageLocationDropDown:SetSelectedImage(itemData.image)
  self.DynamicItemList:ClearList()
  StorageComponentRequestBus.Event.ChangeStorageSessionForPlayer(self.storageEntityId, self.playerEntityId, itemData.actorId, true)
end
function CatContainer:OnAction(entityId, actionName)
  if not BaseScreen.OnAction(self, entityId, actionName) and type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function CatContainer:OnShutdown()
  DynamicBus.CatContainer.Disconnect(self.entityId, self)
  ClickRecognizer:OnDeactivate(self)
  BaseScreen.OnShutdown(self)
  cryActionCommon:UnregisterActionListener(self, "ui_interact")
end
function CatContainer:OnDoubleClick(entityId)
  self:TakeItem(entityId)
end
function CatContainer:TakeItem(entityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  if not slotName or self.containerEntityId == nil or inventoryId == nil then
    return
  end
  local targetItem = ContainerRequestBus.Event.GetSlot(self.containerEntityId, slotName)
  local sourceSlotId = tonumber(slotName)
  local sourceSlot = ContainerRequestBus.Event.GetSlot(self.containerEntityId, sourceSlotId)
  self:SetStorageTransferItemInfo(self.containerEntityId, sourceSlot:GetItemInstanceId(), targetItem:GetStackSize())
  LocalPlayerUIRequestsBus.Broadcast.TradeBatchAddItem(false, sourceSlotId, 0, sourceSlot, targetItem:GetStackSize())
  LocalPlayerUIRequestsBus.Broadcast.TradeBatchExecute(sourceSlotId, self.containerEntityId)
end
function CatContainer:IsOtherKeyComboDown()
  return DynamicBus.Inventory.Broadcast.IsSalvageItemModifierActive() or DynamicBus.Inventory.Broadcast.IsSalvageLockItemModifierActive() or DynamicBus.Inventory.Broadcast.IsRepairItemModifierActive() or self.isSplittingStackModifierActive
end
function CatContainer:OnSingleClick(entityId)
  if self.isQuickMoveModifierActive and not self:IsOtherKeyComboDown() then
    self:OnDoubleClick(entityId)
  elseif self.isLinkItemModifierActive then
    local slotName = ItemContainerBus.Event.GetSlotName(entityId)
    local targetItem = ContainerRequestBus.Event.GetSlot(self.containerEntityId, slotName)
    DynamicBus.ChatBus.Broadcast.LinkItem(targetItem:GetItemDescriptor())
  end
end
function CatContainer:OnCryAction(actionName, value)
  local wasKeyPress = 0 < value
  if actionName == "ui_interact_sec" then
    if wasKeyPress then
      LyShineManagerBus.Broadcast.SetState(2702338936)
    end
  elseif actionName == "ui_interact" then
    if wasKeyPress and self.canTakeAllItems then
      self:ContainerTakeAll()
    end
  elseif actionName == "ui_quickMoveItemModifierDown" then
    self.isQuickMoveModifierActive = true
  elseif actionName == "ui_quickMoveItemModifierUp" then
    self.isQuickMoveModifierActive = false
  elseif actionName == "ui_splitItemStackModifierDown" then
    self.isSplittingStackModifierActive = true
  elseif actionName == "ui_splitItemStackModifierUp" then
    self.isSplittingStackModifierActive = false
  elseif actionName == "link_item" then
    self.isLinkItemModifierActive = wasKeyPress
  elseif actionName == "ui_repairItemModifier" then
    self.isRepairItemModifierActive = wasKeyPress
  end
end
function CatContainer:ToggleLootBagMode(lootBagMode)
  if lootBagMode then
    self.isUsingLootBagMode = true
    self.ScriptedEntityTweener:Set(self.Properties.DynamicItemList, {
      x = 41,
      y = 222,
      w = 284,
      h = 670
    })
    self.ScriptedEntityTweener:Set(self.Properties.PrimaryTitle, {y = 39, w = 270})
    self.ScriptedEntityTweener:Set(self.Properties.LineHorizontal1, {y = 190})
    self.ScriptedEntityTweener:Set(self.Properties.ScrollBar, {x = 0})
    self.DynamicItemList:SetUseSections(false)
    UiElementBus.Event.SetIsEnabled(self.Properties.SortAndFilterBar, false)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Content, 340)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.WeightBar, 246)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Content, -7)
    self.FrameHeader:SetHeight(180)
    local durationLineHorzMax = 1.2
    local durationLineHorzMin = 0.8
    self.LineHorizontal1:SetLength(320)
    self.LineHorizontal1:SetVisible(true, math.max(math.random() * durationLineHorzMax, durationLineHorzMin))
    self.LineHorizontal2:SetLength(320)
    self.LineHorizontal2:SetVisible(true, math.max(math.random() * durationLineHorzMax, durationLineHorzMin))
    UiElementBus.Event.SetIsEnabled(self.Properties.LootBagInfoContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.GlobalStorageLocationHolder, false)
    self.WeightBar:SetLootBagMode(true)
    self.ScriptedEntityTweener:Set(self.Properties.WeightBar, {x = 75, y = 225})
    UiTransform2dBus.Event.SetOffsets(self.Properties.ContainerAreaDropTarget, UiOffsets(20, 0, 0, 0))
    self.ScriptedEntityTweener:Set(self.Properties.ScrollboxContent, {y = 10})
  else
    self.isUsingLootBagMode = false
    self.WeightBar:SetLootBagMode(false)
    self.ScriptedEntityTweener:Set(self.Properties.WeightBar, {x = 36, y = 84})
    self.ScriptedEntityTweener:Set(self.Properties.PrimaryTitle, {y = 39, w = 550})
    if self.isPersonalStorage then
      self.ScriptedEntityTweener:Set(self.Properties.DynamicItemList, {
        x = 36,
        y = 282,
        w = 578,
        h = 670
      })
      self.DynamicItemList:SetSortAndFilterPosY(-141)
    else
      self.ScriptedEntityTweener:Set(self.Properties.DynamicItemList, {
        x = 36,
        y = 162,
        w = 578,
        h = 790
      })
      self.DynamicItemList:SetSortAndFilterPosY(-21)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.GlobalStorageLocationHolder, self.isPersonalStorage)
    self.FrameHeader:SetHeight(121)
    self.ScriptedEntityTweener:Set(self.Properties.ScrollBar, {x = -5})
    self.DynamicItemList:SetUseSections(true)
    UiElementBus.Event.SetIsEnabled(self.Properties.SortAndFilterBar, true)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Content, 623)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.WeightBar, 556)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Content, -15)
    local durationLineHorzMax = 1.2
    local durationLineHorzMin = 0.8
    self.LineHorizontal1:SetVisible(false, 0)
    self.LineHorizontal2:SetLength(598)
    self.LineHorizontal2:SetVisible(true, math.max(math.random() * durationLineHorzMax, durationLineHorzMin))
    self.GlobalStorageLocationDivider:SetVisible(true)
    UiElementBus.Event.SetIsEnabled(self.Properties.LootBagInfoContainer, false)
    UiTransform2dBus.Event.SetOffsets(self.Properties.ContainerAreaDropTarget, UiOffsets(6, 0, 0, 0))
    self.ScriptedEntityTweener:Set(self.Properties.ScrollboxContent, {y = 0})
  end
end
function CatContainer:SetScreenVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  if isVisible == true then
    if self.lootDropEntityId then
      self:ToggleLootBagMode(true)
    else
      self:ToggleLootBagMode(false)
    end
    self.ScriptedEntityTweener:PlayC(self.Properties.Content, 0.3, tweenerCommon.fadeInQuadOut)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.Content, 0.2, tweenerCommon.fadeOutQuadIn)
    self.LineHorizontal1:SetVisible(false, 0.1)
    self.LineHorizontal2:SetVisible(false, 0.1)
    self.GlobalStorageLocationDivider:SetVisible(false, 0.1)
  end
end
function CatContainer:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if fromState == self.STATE_NAME_TRANSFER_CURRENCY and toState == self.STATE_NAME_CONTAINER then
    return
  end
  self.audioHelper:PlaySound(self.audioHelper.OnShow)
  self.DynamicItemList:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.playerTradeNotificationBus = self:BusConnect(PlayerTradeNotificationBus, self.playerEntityId)
  if #self.cryActionHandlers == 0 then
    self.cryActionHandlers[#self.cryActionHandlers + 1] = self:BusConnect(CryActionNotificationsBus, "ui_interact_sec")
    self.cryActionHandlers[#self.cryActionHandlers + 1] = self:BusConnect(CryActionNotificationsBus, "ui_quickMoveItemModifierDown")
    self.cryActionHandlers[#self.cryActionHandlers + 1] = self:BusConnect(CryActionNotificationsBus, "ui_quickMoveItemModifierUp")
    self.cryActionHandlers[#self.cryActionHandlers + 1] = self:BusConnect(CryActionNotificationsBus, "ui_splitItemStackModifierDown")
    self.cryActionHandlers[#self.cryActionHandlers + 1] = self:BusConnect(CryActionNotificationsBus, "ui_splitItemStackModifierUp")
    self.cryActionHandlers[#self.cryActionHandlers + 1] = self:BusConnect(CryActionNotificationsBus, "link_item")
    self.cryActionHandlers[#self.cryActionHandlers + 1] = self:BusConnect(CryActionNotificationsBus, "ui_repairItemModifier")
  end
  cryActionCommon:RegisterActionListener(self, "ui_interact", 0, self.OnCryAction)
  self:SetScreenVisible(true)
  self:UpdateWeight()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.InteractName", function(self, interactName)
    UiTextBus.Event.SetTextWithFlags(self.PrimaryTitle, interactName, eUiTextSet_SetLocalized)
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.StackSplitter.ContainerStackWeight", function(self, stackWeight)
    if stackWeight then
      self.WeightBar:SetStackSplitValue(stackWeight)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.GlobalStorage.OverflowItemCount", function(self, overflowItemCount)
    overflowItemCount = overflowItemCount or 0
    UiElementBus.Event.SetIsEnabled(self.Properties.HiddenItemsContainer, 0 < overflowItemCount)
    UiTextBus.Event.SetTextWithFlags(self.Properties.HiddenItemsText, GetLocalizedReplacementText("@ui_overflow_items_amount", {
      amount = tostring(overflowItemCount)
    }), eUiTextSet_SetAsIs)
  end)
end
function CatContainer:OnTransitionOut(stateName, levelName)
  self.audioHelper:PlaySound(self.audioHelper.OnHide)
  self.DynamicItemList:OnTransitionOut(stateName, levelName)
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  if self.playerTradeNotificationBus then
    self:BusDisconnect(self.playerTradeNotificationBus)
    self.playerTradeNotificationBus = nil
  end
  if self.storageEntityId or self.lootDropEntityId then
    self.DynamicItemList:OnClearFilter()
    self.DynamicItemList:ClearList(true)
    self.DynamicItemList:SetContainer(EntityId())
  end
  self.containerEntityId = nil
  self.buildableEntityId = nil
  self.storageEntityId = nil
  self.lootDropEntityId = nil
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ActiveContainer", EntityId())
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ActiveContainerIsLootDrop", false)
  LocalPlayerUIRequestsBus.Broadcast.InteractPanelClosed()
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  for _, handler in ipairs(self.cryActionHandlers) do
    self:BusDisconnect(handler)
  end
  ClearTable(self.cryActionHandlers)
  self:SetScreenVisible(false)
  self.weightBarShowing = false
  self.WeightBar:SetLootBagMode(false)
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.InteractName")
  self.dataLayer:UnregisterObserver(self, "Hud.StackSplitter.ContainerStackWeight")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.GlobalStorage.OverflowItemCount")
  cryActionCommon:UnregisterActionListener(self, "ui_interact")
end
function CatContainer:RegisterWithStorageInteractable(containerEntityId, storageEntityId, buildableEntityId, vitalsEntityId, ownershipEntityId)
  self.containerEntityId = containerEntityId
  self.buildableEntityId = buildableEntityId
  self.ownershipEntityId = ownershipEntityId
  self.storageEntityId = storageEntityId
  if self.remoteStorageEnabled then
    local globalStorageEntityId = PlayerComponentRequestsBus.Event.GetGlobalStorageEntityId(self.playerEntityId)
    self.isPersonalStorage = globalStorageEntityId == self.containerEntityId
    if self.isPersonalStorage then
      self.currentStorageId = ContainerRequestBus.Event.GetTerritoryIdForGlobalStorage(self.containerEntityId)
      self:UpdateOutpostData()
    end
  else
    self.isPersonalStorage = false
  end
  self.lootDropEntityId = nil
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ActiveContainer", self.containerEntityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ActiveContainerIsLootDrop", false)
  self.DynamicItemList:SetContainer(self.containerEntityId, self)
  self.ContainerAreaDropTarget:SetContainer(self.containerEntityId, false)
  self:RefreshStorageContainer()
  LocalPlayerUIRequestsBus.Broadcast.SetIsLookingThroughLoadout(true)
end
function CatContainer:OnContainerItemCountChange(count)
  if count == 0 and 0 < self.itemCount and self.lootDropEntityId and self.lootDropEntityId:IsValid() then
    self:UnregisterInteractable(self.lootDropEntityId)
  end
  self.itemCount = count
  self:RefreshStorageContainer()
end
function CatContainer:RegisterWithLootDropInteractable(containerEntityId, lootDropEntityId)
  self.containerEntityId = containerEntityId
  self.lootDropEntityId = lootDropEntityId
  self.storageEntityId = nil
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ActiveContainer", self.containerEntityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ActiveContainerIsLootDrop", true)
  self.DynamicItemList:SetContainer(self.containerEntityId, self)
  self.ContainerAreaDropTarget:SetContainer(self.containerEntityId, true)
  self:RefreshStorageContainer()
  LocalPlayerUIRequestsBus.Broadcast.SetIsLookingThroughLoadout(true)
end
function CatContainer:UnregisterInteractable(entityId)
  if entityId == self.lootDropEntityId or entityId == self.storageEntityId then
    self.DynamicItemList:ClearList(true)
    self.DynamicItemList:SetContainer(EntityId())
    LyShineManagerBus.Broadcast.SetState(2972535350)
    self.containerEntityId = nil
    self.buildableEntityId = nil
    self.storageEntityId = nil
    self.lootDropEntityId = nil
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ActiveContainer", EntityId())
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ActiveContainerIsLootDrop", false)
  end
end
function CatContainer:RefreshStorageContainer()
  self:UpdateWeight()
  local totalItems = self.DynamicItemList:GetNumberItems()
  if totalItems == 1 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.LootBagItemsText, "@ui_loot_bag_1_item", eUiTextSet_SetLocalized)
  else
    local text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_loot_bag_items", tostring(totalItems))
    UiTextBus.Event.SetTextWithFlags(self.Properties.LootBagItemsText, text, eUiTextSet_SetAsIs)
  end
  self.canTakeAllItems = 0 < totalItems
  self.ButtonTakeAll:SetEnabled(self.canTakeAllItems)
  local enableCamera = self.containerEntityId ~= nil or self.itemCount ~= 0
  if enableCamera and not LyShineManagerBus.Broadcast.IsInState(self.STATE_NAME_CONTAINER) then
    LyShineManagerBus.Broadcast.QueueState(self.STATE_NAME_CONTAINER)
  end
end
function CatContainer:UpdateWeight()
  if not self.containerEntityId then
    return
  end
  local currentWeight = ContainerRequestBus.Event.GetCurrentEncumbrance(self.containerEntityId)
  local maxWeight = ContainerRequestBus.Event.GetMaximumEncumbrance(self.containerEntityId)
  if maxWeight == 0 and not self.isUsingLootBagMode then
    self.ScriptedEntityTweener:Set(self.WeightBar.entityId, {opacity = 0})
    self.weightBarShowing = false
  else
    if not self.weightBarShowing then
      self.WeightBar:AnimateIn()
      self.weightBarShowing = true
    end
    self.WeightBar:SetMaxValue(maxWeight / 10)
    self.WeightBar:SetValue(currentWeight / 10)
  end
end
function CatContainer:ContainerTakeAll()
  if self.containerEntityId then
    self:SetStorageTransferAllInfo(self.containerEntityId)
    LocalPlayerUIRequestsBus.Broadcast.TakeAll(self.containerEntityId)
    self.audioHelper:PlaySound(self.audioHelper.InteractOptionPressed)
  end
end
function CatContainer:OnTransferAllByClass(itemClass)
  self:SetStorageTransferByClassInfo(self.containerEntityId, itemClass)
  LocalPlayerUIRequestsBus.Broadcast.TakeAllByClass(self.containerEntityId, itemClass)
end
function CatContainer:CanTransferAllByClass(itemClass)
  return self.containerEntityId and self.containerEntityId:IsValid()
end
function CatContainer:ItemUpdateDragData(entityId)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerType", eItemDragContext_Container)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerId", self.containerEntityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerSlotId", slotName)
end
function CatContainer:SetStorageTransferItemInfo(containerId, instanceId, quantity)
  self.remoteStorageContainerId = containerId
  self.remoteItemInstanceId = instanceId
  self.remoteItemQuantity = quantity
  self.remoteTakeRequestType = self.STATE_ITEM_TAKE_REQUEST
end
function CatContainer:SetStorageTransferByClassInfo(containerId, itemClass)
  self.remoteStorageContainerId = containerId
  self.remoteStorageItemClass = itemClass
  self.remoteTakeRequestType = self.STATE_ITEMS_BY_CLASS_TAKE_REQUEST
end
function CatContainer:SetStorageTransferAllInfo(containerId)
  self.remoteStorageContainerId = containerId
  self.remoteTakeRequestType = self.STATE_ALL_ITEMS_TAKE_REQUEST
end
function CatContainer:SetStorageTransferAndEquipItemInfo(containerId, toEquipSlotName, instanceId, quantity)
  self.remoteStorageContainerId = containerId
  self.toEquipSlotName = toEquipSlotName
  self.remoteItemInstanceId = instanceId
  self.remoteItemQuantity = quantity
end
function CatContainer:OnShowRemoteGlobalStorageWithdrawDialog(fee)
  local playerWallet = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") or 0
  if fee == 0 then
    if self.remoteTakeRequestType == self.STATE_ALL_ITEMS_TAKE_REQUEST then
      PlayerTradeRequestBus.Event.RequestConfirmRemoteGlobalStorageWithdrawAllItems(self.playerEntityId, self.remoteStorageContainerId)
    elseif self.remoteTakeRequestType == self.STATE_ITEMS_BY_CLASS_TAKE_REQUEST then
      PlayerTradeRequestBus.Event.RequestConfirmRemoteGlobalStorageWithdrawItemsByClass(self.playerEntityId, self.remoteStorageContainerId, self.remoteStorageItemClass)
    else
      PlayerTradeRequestBus.Event.RequestConfirmRemoteGlobalStorageWithdrawItem(self.playerEntityId, self.remoteStorageContainerId, self.remoteItemInstanceId, self.remoteItemQuantity)
    end
  elseif fee > playerWallet then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_remotetransfererror_coin"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  elseif self.remoteTakeRequestType == self.STATE_ALL_ITEMS_TAKE_REQUEST then
    local messageBody = GetLocalizedReplacementText("@ui_remotetransferallbody", {
      territoryName = self.selectedStorageLocation,
      amount = GetLocalizedCurrency(fee)
    })
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_remotetransferalltitle", messageBody, "remote_transfer_all", self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        PlayerTradeRequestBus.Event.RequestConfirmRemoteGlobalStorageWithdrawAllItems(self.playerEntityId, self.remoteStorageContainerId)
      else
        self.DynamicItemList:UpdateLists()
      end
    end)
  elseif self.remoteTakeRequestType == self.STATE_ITEMS_BY_CLASS_TAKE_REQUEST then
    local itemClassName = ItemCommon:GetItemClassName(self.remoteStorageItemClass)
    local messageTitle = GetLocalizedReplacementText("@ui_remotetransferbyclasstitle", {itemClassName = itemClassName})
    local messageBody = GetLocalizedReplacementText("@ui_remotetransferbyclassbody", {
      itemClassName = itemClassName,
      territoryName = self.selectedStorageLocation,
      amount = GetLocalizedCurrency(fee)
    })
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, messageTitle, messageBody, "remote_transfer_class", self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        PlayerTradeRequestBus.Event.RequestConfirmRemoteGlobalStorageWithdrawItemsByClass(self.playerEntityId, self.remoteStorageContainerId, self.remoteStorageItemClass)
      else
        self.DynamicItemList:UpdateLists()
      end
    end)
  else
    local messageBody = GetLocalizedReplacementText("@ui_remotetransfersinglebody", {
      territoryName = self.selectedStorageLocation,
      amount = GetLocalizedCurrency(fee)
    })
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_remotetransfersingletitle", messageBody, "remote_transfer_single", self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        PlayerTradeRequestBus.Event.RequestConfirmRemoteGlobalStorageWithdrawItem(self.playerEntityId, self.remoteStorageContainerId, self.remoteItemInstanceId, self.remoteItemQuantity)
      else
        self.DynamicItemList:UpdateLists()
      end
    end)
  end
end
function CatContainer:OnShowRemoteGlobalStorageWithdrawAndEquipDialog(fee)
  local messageBody = GetLocalizedReplacementText("@ui_remotetransfersinglebody", {
    territoryName = self.selectedStorageLocation,
    amount = GetLocalizedCurrency(fee)
  })
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_remotetransfersingletitle", messageBody, "remote_transfer_single", self, function(self, result, eventId)
    if result == ePopupResult_Yes then
      PlayerTradeRequestBus.Event.RequestConfirmRemoteGlobalStorageWithdrawAndEquipItem(self.playerEntityId, self.remoteStorageContainerId, self.toEquipSlotName, self.remoteItemInstanceId, self.remoteItemQuantity)
    end
  end)
end
return CatContainer

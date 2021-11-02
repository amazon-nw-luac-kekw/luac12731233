local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
local ClickRecognizer = RequireScript("LyShineUI._Common.ClickRecognizer")
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
local CommonDragDrop = RequireScript("LyShineUI.CommonDragDrop")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local InteractCommon = RequireScript("LyShineUI.HUD.UnifiedInteractCard.InteractCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local NewInventory = {
  Properties = {
    Content = {
      default = EntityId()
    },
    FrameMultiBg = {
      default = EntityId()
    },
    DynamicItemList = {
      default = EntityId()
    },
    CurrencyText = {
      default = EntityId()
    },
    AzothCurrencyText = {
      default = EntityId()
    },
    InventoryTitle = {
      default = EntityId()
    },
    WeightBar = {
      default = EntityId()
    },
    InventoryAreaDropTarget = {
      default = EntityId()
    },
    GoldButton = {
      default = EntityId()
    },
    EncumberedHighlight = {
      default = EntityId()
    },
    InventoryFullIndicator = {
      default = EntityId()
    },
    InventoryFullText = {
      default = EntityId()
    },
    ItemDyeingPopupContainer = {
      default = EntityId()
    },
    RepairPartsContainer = {
      default = EntityId()
    },
    RepairPartsPopup = {
      default = EntityId()
    },
    ItemDyeingPopup = {
      default = EntityId()
    },
    DyeSkinCameraPrompt = {
      default = EntityId()
    },
    DyeSkinCameraButton = {
      default = EntityId()
    },
    ItemSkinsPopup = {
      default = EntityId()
    },
    GroundDropTarget = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    },
    ActionHintContainer = {
      default = EntityId()
    },
    ActionHintText = {
      default = EntityId()
    },
    LineHorizontal = {
      default = EntityId()
    },
    EncumbranceTooltip = {
      HitArea = {
        default = EntityId(),
        description = "Element that opens the tooltip when hovered. Must have button component."
      },
      Container = {
        default = EntityId(),
        description = "Full tooltip element"
      },
      Frame = {
        default = EntityId()
      },
      Title = {
        default = EntityId()
      },
      Description = {
        default = EntityId()
      },
      Unencumbered = {
        default = EntityId()
      },
      UnencumberedTitle = {
        default = EntityId()
      },
      UnencumberedText = {
        default = EntityId()
      },
      Encumbered = {
        default = EntityId()
      },
      EncumberedTitle = {
        default = EntityId()
      },
      EncumberedText = {
        default = EntityId()
      }
    }
  },
  STATE_NAME_INVENTORY = 2972535350,
  STATE_NAME_CONTAINER = 3349343259,
  STATE_NAME_BUILDMODE = 3406343509,
  STATE_NAME_GENERATOR = 1809891471,
  STATE_NAME_ARMORDYEING = 3548394217,
  STATE_NAME_P2PTRADING = 2552344588,
  STATE_NAME_STORE = 4283914359,
  isCameraDelayInProcess = false,
  cameraDelayTimer = 0,
  cameraDelayDuration = 0,
  confirmConsumePopupEventId = "Confirm_Consume_Popup",
  destroyItemPopupEventId = "confirmDestroyItemFromInv",
  destroyItemsPopupEventId = "confirmDestroyItemsFromInv",
  confirmDropPopupEventId = "Confirm_Drop_Popup",
  isFirstLoad = true,
  isInInventoryTutorial = false,
  actionNames = {},
  knownItems = {}
}
BaseScreen:CreateNewScreen(NewInventory)
function NewInventory:OnInit()
  BaseScreen.OnInit(self)
  self.knownItems = {}
  DynamicBus.Inventory.Connect(self.entityId, self)
  g_watchedVariables.NewInventory = self
  self:SetVisualElements()
  self.defaultDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
  self.dataLayer:SetScreenNameOverride("Inventory", "NewInventory")
  ClickRecognizer:OnActivate(self, "ItemUpdateDragData", "ItemInteract", self.ItemDoubleClickAction, self.OpenContextMenu, self.ItemSingleClickAction)
  local inventoryIdNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  if inventoryIdNode then
    self.inventoryId = inventoryIdNode:GetData()
    self.DynamicItemList:SetContainer(self.inventoryId)
  end
  self.dataLayer:RegisterObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, dataNode)
    self.inventoryId = dataNode:GetData()
    self.DynamicItemList:SetContainer(self.inventoryId)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.BuilderEntityId", function(self, data)
    self.builderId = data
  end)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.ClickRecognizer = ClickRecognizer
  self.nearbyLootContainers = {}
  self.openLootContainers = {}
  local eventNotificationIdNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.EventNotificationEntityId")
  if eventNotificationIdNode then
    self.eventNotificationId = eventNotificationIdNode:GetData()
  end
  self.dataLayer:RegisterOpenEvent("NewInventory", self.canvasId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.InventoryScriptElement", self.entityId)
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.LootDrop.TriggerAreaEntered", function(self, dataNode)
    local lootDropEntity = dataNode:GetData()
    self.nearbyLootContainers[tostring(lootDropEntity)] = lootDropEntity
    if self.dataLayer:IsScreenOpen("NewInventory") then
      self:OpenNearbyLootContainers(lootDropEntity)
    end
  end)
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.LootDrop.TriggerAreaExited", function(self, dataNode)
    local lootDropEntity = dataNode:GetData()
    self.nearbyLootContainers[tostring(lootDropEntity)] = nil
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    if data then
      self.playerId = data
      self:BusConnect(PlayerComponentNotificationsBus, self.playerId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", function(self, paperdollId)
    if not paperdollId then
      return
    end
    self.paperdollId = paperdollId
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.HudComponent.CraftingEntityId", function(self, craftingId)
    if craftingId then
      self:BusConnect(CraftingEventBus, craftingId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Encumbrance.ShouldUpdateWeight", function(self, data)
    if data == nil then
      data = true
    end
    self.updateWeight = data
  end)
  self.inventoryMessagingData = {}
  self.dataLayer:RegisterDataObserver(self, "Hud.StackSplitter.InventoryStackWeight", function(self, stackWeight)
    if stackWeight then
      self.WeightBar:SetStackSplitValue(stackWeight)
      local adjustedValue = self.encumbranceValue - stackWeight
      local isEncumbered = adjustedValue > self.maxEncumbranceValue
      self.ScriptedEntityTweener:Set(self.EncumberedHighlight, {
        opacity = isEncumbered and 0.35 or 0
      })
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Inventory.TotalInventorySlotsUsed", function(self, totalSlots)
    local slotsLeft = CommonDragDrop:GetInventorySlotsRemaining()
    if slotsLeft <= CommonDragDrop.INVENTORY_SLOTS_WARNING_THRESHOLD then
      local message = "@ui_inventoryfull"
      if 0 < slotsLeft then
        message = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_inventoryslotsremaining", slotsLeft)
      end
      local maxSlots = ConfigProviderEventBus.Broadcast.GetInt("javelin.max-container-size")
      local usedSlots = maxSlots - slotsLeft
      local percentUsed = usedSlots / maxSlots
      self:UpdateInventoryFullMessage("slots", true, message, percentUsed)
    else
      self:UpdateInventoryFullMessage("slots", false)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.Housing.IsWithinAPlot", function(self, isInPlot)
    self.isInPlot = isInPlot
  end)
  self.walletCap = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.wallet-cap-player")
  self.paperdollUXProviderHandler = DynamicBus.PaperdollUXProvider.Connect(self.entityId, self)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("inventory", false)
  LocalPlayerUIRequestsBus.Broadcast.SetIsLookingThroughLoadout(false)
end
function NewInventory:UpdateInventoryFullMessage(messageType, shouldShow, message, percentFull)
  if shouldShow then
    self.inventoryMessagingData[messageType] = {message = message, percent = percentFull}
  else
    self.inventoryMessagingData[messageType] = nil
  end
  local messageToShow
  local highestPercent = -1
  for _, messageData in pairs(self.inventoryMessagingData) do
    if highestPercent < messageData.percent then
      messageToShow = messageData.message
      highestPercent = messageData.percent
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.InventoryFullIndicator, messageToShow ~= nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.InventoryTitle, messageToShow == nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.WeightBar, messageToShow == nil)
  if messageToShow then
    UiTextBus.Event.SetTextWithFlags(self.Properties.InventoryFullText, messageToShow, eUiTextSet_SetLocalized)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.InventoryFullText, 0.9, {
      textColor = self.UIStyle.COLOR_WHITE
    }, tweenerCommon.textToRed)
  end
end
function NewInventory:SetVisualElements()
  SetTextStyle(self.InventoryTitle, self.UIStyle.FONT_STYLE_INVENTORY_PRIMARY_TITLE)
  UiTextBus.Event.SetTextWithFlags(self.InventoryTitle, "@ui_inventory", eUiTextSet_SetLocalized)
  self.GoldButton:SetText("@inv_giveGold")
  self.GoldButton:SetBackgroundOpacity(0.2)
  self.GoldButton:SetCallback("OnShowTransferCurrencyPopup", self)
  local colorLine = self.UIStyle.COLOR_TAN_LIGHT
  self.LineHorizontal:SetColor(colorLine)
  local alphaLine = 0.7
  self.ScriptedEntityTweener:Set(self.LineHorizontal.entityId, {opacity = alphaLine})
  self.WeightBar:SetOverageText("@inv_encumbered")
  self.WeightBar:SetOverageIcon("lyshineui/images/icons/encumbrance/encumbered.png")
  self.WeightBar:SetMaxOveragePercent(0.03)
  UiImageBus.Event.SetColor(self.EncumberedHighlight, self.UIStyle.COLOR_RED_DARK)
  self.encumbranceTooltipSettings = {sectionOpacity = 0.4, intentTime = 0.25}
  local oldHoverStart = UiInteractableActionsBus.Event.GetHoverStartActionName(self.EncumbranceTooltip.HitArea)
  if oldHoverStart == "" then
    UiInteractableActionsBus.Event.SetHoverStartActionName(self.EncumbranceTooltip.HitArea, "self:OnEncumbranceHoverStart")
    UiInteractableActionsBus.Event.SetHoverEndActionName(self.EncumbranceTooltip.HitArea, "self:OnEncumbranceHoverEnd")
  end
  SetTextStyle(self.EncumbranceTooltip.Description, self.UIStyle.FONT_STYLE_EQUIP_LOAD_TOOLTIP)
  SetTextStyle(self.EncumbranceTooltip.Title, self.UIStyle.FONT_STYLE_EQUIP_LOAD_TOOLTIP_TITLE)
  local tooltipTitles = {
    self.EncumbranceTooltip.EncumberedTitle,
    self.EncumbranceTooltip.UnencumberedTitle
  }
  for _, element in pairs(tooltipTitles) do
    SetTextStyle(element, self.UIStyle.FONT_STYLE_EQUIP_LOAD_TOOLTIP_SUBTITLE)
  end
  local tooltipTexts = {
    self.EncumbranceTooltip.EncumberedText,
    self.EncumbranceTooltip.UnencumberedText
  }
  for _, element in pairs(tooltipTexts) do
    SetTextStyle(element, self.UIStyle.FONT_STYLE_EQUIP_LOAD_TOOLTIP)
  end
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    self:BusConnect(TutorialComponentNotificationsBus, self.canvasId)
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
  self:SizeEncumbranceTooltip()
end
function NewInventory:OnAction(entityId, actionName)
  if not BaseScreen.OnAction(self, entityId, actionName) and type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function NewInventory:OnCryAction(actionName, value)
  if self.dataLayer:GetScreenNameOverride("Inventory") ~= "NewInventory" then
    return
  end
  if self.actionNames[actionName] then
    self.actionNames[actionName](self, value)
  end
end
function NewInventory:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, 10)
end
local hintPos = Vector2(0, 0)
function NewInventory:OnTick(deltaTime, timePoint)
  if self.isCameraDelayInProcess then
    self.cameraDelayTimer = self.cameraDelayTimer + deltaTime
    if self.cameraDelayTimer >= self.cameraDelayDuration then
      local isContainerOpen = LyShineManagerBus.Broadcast.IsInState(self.STATE_NAME_CONTAINER)
      local isLootDrop = isContainerOpen and self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop")
      if not (not isContainerOpen or isLootDrop) or LyShineManagerBus.Broadcast.IsInState(self.STATE_NAME_GENERATOR) or LyShineManagerBus.Broadcast.IsInState(self.STATE_NAME_P2PTRADING) then
        JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_Storage", 0.5)
      else
        JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_Inventory", 0.5)
      end
      self:ClearCameraDelayFlags()
    end
  end
end
function NewInventory:OnCrySystemPostViewSystemUpdate()
  if self:IsModifierActive() then
    local isOnRight = DynamicBus.TooltipsRequestBus.Broadcast.GetFlyoutOnRight()
    local mouse = CursorBus.Broadcast.GetCursorPosition()
    local screenSize = UiCanvasBus.Event.GetCanvasSize(self.canvasId)
    local hintWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ActionHintContainer)
    local offsetX = isOnRight and -hintWidth - 10 or 10
    hintPos.y = mouse.y + 10
    hintPos.x = mouse.x + offsetX
    if hintPos.x + hintWidth > screenSize.x then
      hintPos.x = screenSize.x - hintWidth
    elseif hintPos.x < 0 then
      hintPos.x = 0
    end
    UiTransformBus.Event.SetViewportPosition(self.Properties.ActionHintContainer, hintPos)
  end
end
function NewInventory:AddTickBus()
  if self.tickBusHandler == nil then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function NewInventory:RemoveTickBus(forceRemove)
  if forceRemove == false and (self.isCameraDelayInProcess or self:IsModifierActive()) then
    return
  end
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
  end
  self.tickBusHandler = nil
end
function NewInventory:ClearCameraDelayFlags()
  self.isCameraDelayInProcess = false
  self.cameraDelayTimer = 0
end
function NewInventory:OnShutdown()
  DynamicBus.Inventory.Disconnect(self.entityId, self)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.InventoryScriptElement", EntityId())
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("inventory", false)
  ClickRecognizer:OnDeactivate(self)
  JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
  self:RemoveTickBus(true)
  self:ClearCameraDelayFlags()
  BaseScreen.OnShutdown(self)
  if self.debugActionMapDisabled then
    UiJavCanvasComponentBus.Event.SetOverridesActionMap(self.canvasId, "debug", false)
    self.debugActionMapDisabled = false
  end
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
  if self.paperdollUXProviderHandler then
    DynamicBus.PaperdollUXProvider.Disconnect(self.entityId, self)
    self.paperdollUXProviderHandler = nil
  end
end
function NewInventory:AddDraggableItem(draggable)
  local isScreenEnabled = UiCanvasBus.Event.GetEnabled(self.canvasId)
  if isScreenEnabled then
    local item = self:GetKnownItem(draggable)
    if item then
      item.draggables[draggable] = draggable
    else
      item = {}
      item.draggables = {}
      item.draggables[draggable] = draggable
      item.seen = false
      item.currentQuantity = draggable.ItemLayout:GetQuantity()
      self.knownItems[tostring(draggable:GetItemInstanceId())] = item
      if self.isFirstLoad == false or self.isFtue == true then
        draggable:SetNewIndicatorVisible(true)
      else
        draggable:SetNewIndicatorVisible(false)
      end
    end
    if item.seen then
      local newQuantity = draggable.ItemLayout:GetQuantity()
      if item.currentQuantity ~= newQuantity then
        item.currentQuantity = newQuantity
        if self.isFirstLoad == false then
          draggable:SetNewIndicatorVisible(true)
        end
      else
        draggable:SetNewIndicatorVisible(false)
      end
    end
  end
end
function NewInventory:RemoveDraggableItem(draggable)
  local item = self:GetKnownItem(draggable)
  if item then
    item.draggables[draggable] = nil
  end
end
function NewInventory:MarkDraggableItemSeen(draggable)
  local item = self:GetKnownItem(draggable)
  if item then
    item.seen = true
    for _, draggable in pairs(item.draggables) do
      draggable:SetNewIndicatorVisible(false)
    end
  end
end
function NewInventory:GetKnownItem(draggable)
  return self.knownItems[tostring(draggable:GetItemInstanceId())]
end
function NewInventory:UseItem(entityId)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  if not slotName then
    return
  end
  local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local targetItem = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotName)
  local canUseItem = targetItem:CanUseItem(rootEntityId)
  if canUseItem then
    if targetItem:ShouldConfirmBeforeUse() then
      self:ClearAllModifiers()
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_confirm_before_use_title", "@ui_confirm_before_use_message", self.confirmConsumePopupEventId, self, self.OnPopupResult)
      self.pendingConfirmItem = targetItem
      self.pendingConfirmEntityId = entityId
    else
      if targetItem:GetItemDescriptor().quantity == 1 then
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
      end
      self:ContextInventoryUseItem(entityId)
    end
  end
end
function NewInventory:OnPopupResult(result, eventId)
  if eventId == self.confirmConsumePopupEventId then
    if result == ePopupResult_Yes then
      if self.pendingConfirmItem:GetItemDescriptor().quantity == 1 then
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
      end
      self:ContextInventoryUseItem(self.pendingConfirmEntityId)
    end
  elseif eventId == self.destroyItemPopupEventId then
    if result == ePopupResult_Yes then
      self:DropItemWork(self.popupDraggableEntityId)
    end
  elseif eventId == self.destroyItemsPopupEventId and result == ePopupResult_Yes and self.dropAllItemClass then
    self:ExecuteTransferAllByClass(self.dropAllItemClass, true)
    self.dropAllItemClass = nil
  end
end
function NewInventory:EquipItem(entityId)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  if not slotName then
    return
  end
  local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local targetItem = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotName)
  local canEquipItem = targetItem:CanEquipItem(rootEntityId)
  local meetsWeaponRequirements
  if targetItem:GetItemType() == "Weapon" then
    meetsWeaponRequirements = LocalPlayerUIRequestsBus.Broadcast.MeetsWeaponRequirements(targetItem)
  else
    meetsWeaponRequirements = true
  end
  if canEquipItem and meetsWeaponRequirements then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    self:ContextInventoryEquipItem(entityId)
  elseif not meetsWeaponRequirements then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@inv_does_not_meet_weapon_requirements"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function NewInventory:StoreItem(draggableEntityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local slotName = ItemContainerBus.Event.GetSlotName(draggableEntityId)
  local targetItem = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotName)
  local itemId = targetItem:GetItemId()
  local staticItemData = StaticItemDataManager:GetItem(itemId)
  if staticItemData.nonremovable and not targetItem:IsBoundToPlayer() then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_cantDropMissionItem"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  elseif targetItem:IsBoundToPlayer() then
    local targetContainerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
    if not ContainerRequestBus.Event.IsPlayerContainer(targetContainerId) then
      self.popupDraggableEntityId = draggableEntityId
      self:ClearAllModifiers()
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_destroyBoundItem", "@ui_destroyBoundItemMessage", self.destroyItemPopupEventId, self, self.OnPopupResult)
    else
      self:StoreItemWork(draggableEntityId)
    end
  else
    self:StoreItemWork(draggableEntityId)
  end
end
function NewInventory:StoreItemWork(entityId)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  if not slotName then
    return
  end
  local targetItem = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotName)
  if LyShineManagerBus.Broadcast.IsInState(3349343259) then
    local targetContainerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
    local sourceSlotId = tonumber(slotName)
    local stackSize = targetItem:GetStackSize()
    LocalPlayerUIRequestsBus.Broadcast.PerformContainerTradeEntity(self.inventoryId, sourceSlotId, targetContainerId, -1, stackSize)
  end
end
function NewInventory:StoreOrDropItem(entityId)
  local isContainerOpen = LyShineManagerBus.Broadcast.IsInState(3349343259)
  if isContainerOpen then
    self:StoreItem(entityId)
  else
    self:DropItem(entityId)
  end
end
function NewInventory:ItemDoubleClickAction(entityId)
  if self.isSalvageItemModifierActive or self.isSalvageLockItemModifierActive or self.isSplittingStackModfierActive or self.isRepairItemModifierActive then
    return
  end
  local draggable = self.registrar:GetEntityTable(entityId)
  if draggable:IsSelectedForTrade() then
    return
  end
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local targetItem = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotName)
  local canEquipItem = targetItem:CanEquipItem(rootEntityId)
  local isItemTransferEnabled = LocalPlayerUIRequestsBus.Broadcast.IsItemTransferEnabled()
  if canEquipItem and isItemTransferEnabled and (not self.isInInventoryTutorial or self.isWaitingToEquip) then
    self:EquipItem(entityId)
    return
  elseif targetItem:HasItemClass(eItemClass_LootContainer) then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    self:ContextInventorySalvageItem(entityId, targetItem:GetItemId())
    return
  end
  if not canEquipItem and targetItem:IsEquippable() then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@inv_cannotequip"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function NewInventory:ItemSingleClickAction(entityId)
  if not self.isRepairItemModifierActive and not self.isRepairKitItemModifierActive and not self.isSalvageItemModifierActive and not self.isSplittingStackModfierActive and not self.isInInventoryTutorial then
    if self.isQuickMoveModifierActive then
      if DynamicBus.TradeScreen.Broadcast.IsInTradeSession() then
        local slotName = ItemContainerBus.Event.GetSlotName(entityId)
        DynamicBus.TradeScreen.Broadcast.AddItem(slotName)
      else
        self:StoreOrDropItem(entityId, false)
      end
    elseif self.isLinkItemModifierActive then
      local slotName = ItemContainerBus.Event.GetSlotName(entityId)
      local targetItem = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotName)
      DynamicBus.ChatBus.Broadcast.LinkItem(targetItem:GetItemDescriptor())
    end
  end
end
function NewInventory:IsItemLinkModifierActive()
  return self.isLinkItemModifierActive
end
function NewInventory:IsQuickMoveModifierActive()
  return self.isQuickMoveModifierActive
end
function NewInventory:IsRepairItemModifierActive()
  return self.isRepairItemModifierActive
end
function NewInventory:IsRepairKitItemModifierActive()
  return self.isRepairKitItemModifierActive
end
function NewInventory:IsSalvageItemModifierActive()
  return self.isSalvageItemModifierActive
end
function NewInventory:IsSalvageLockItemModifierActive()
  return self.isSalvageLockItemModifierActive
end
function NewInventory:GetNearestLootContainer()
  local nearestLootDrop
  if not self.nearbyLootContainers then
    return nil
  end
  local closestDistSq = 10000
  for k, v in pairs(self.nearbyLootContainers) do
    local thisDistSq = LootDropRequestsBus.Event.GetDistanceSqToLocalPlayer(v)
    if type(thisDistSq) == "number" and closestDistSq > thisDistSq then
      nearestLootDrop = v
      closestDistSq = thisDistSq
    end
  end
  return nearestLootDrop
end
function NewInventory:OpenNearbyLootContainers(lootDropEntity)
  local activeContainerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
  if activeContainerId and activeContainerId:IsValid() then
    return false
  end
  local nearestLootDrop = lootDropEntity ~= nil and lootDropEntity or self:GetNearestLootContainer()
  if nearestLootDrop and not self.openLootContainers[tostring(nearestLootDrop)] then
    self.openLootContainers[tostring(nearestLootDrop)] = nearestLootDrop
    LootDropRequestsBus.Event.OpenLootDrop(nearestLootDrop)
    return true
  end
  return false
end
function NewInventory:OnIsLookingThroughLoadoutChanged(isLookingThroughLoadout)
  if isLookingThroughLoadout then
    local isInInventoryState = LyShineManagerBus.Broadcast.IsInState(self.STATE_NAME_INVENTORY)
    local isInContainerState = LyShineManagerBus.Broadcast.IsInState(self.STATE_NAME_CONTAINER)
    local isInP2PTradingState = LyShineManagerBus.Broadcast.IsInState(self.STATE_NAME_P2PTRADING)
    local isCraftingInteraction = false
    local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
    if interactorEntity then
      isCraftingInteraction = UiInteractorComponentRequestsBus.Event.IsInCommittedInteraction(interactorEntity, eInteractionUIActions_OpenCrafting)
    end
    if not isInInventoryState and not isInContainerState and not isCraftingInteraction and not isInP2PTradingState then
      if not self:OpenNearbyLootContainers() then
        LyShineManagerBus.Broadcast.QueueState(2972535350)
      else
        self.skipNextLootOpen = true
      end
    end
  else
    if LyShineManagerBus.Broadcast.IsInState(2729122569) or LyShineManagerBus.Broadcast.IsInState(3548394217) then
      LyShineManagerBus.Broadcast.ExitState(0)
    end
    if LyShineManagerBus.Broadcast.IsInLevel(5) then
      LyShineManagerBus.Broadcast.ExitState(0)
    end
  end
end
function NewInventory:SetScreenVisible(isVisible, doCameraTransition)
  if isVisible == true then
    self.ScriptedEntityTweener:PlayC(self.Properties.Content, 0.5, tweenerCommon.fadeInQuadOut)
    if doCameraTransition then
      self:DoCameraTransition(true)
    end
  elseif isVisible == false then
    self.ScriptedEntityTweener:PlayC(self.Properties.Content, 0.5, tweenerCommon.fadeOutQuadIn)
    self.LineHorizontal:SetVisible(false, 0.1)
    if doCameraTransition then
      self:DoCameraTransition(false)
    end
  end
  self.isScreenVisible = isVisible
end
function NewInventory:DoCameraTransition(screenVisibleTransition)
  if screenVisibleTransition then
    self.isCameraDelayInProcess = true
    self.cameraDelayTimer = 0
    self:AddTickBus()
  else
    JavCameraControllerRequestBus.Broadcast.MakeActiveView(4, 2, 5)
    self:ClearCameraDelayFlags()
    self:RemoveTickBus(false)
  end
end
function NewInventory:SetInventoryVisible(isVisible)
  local animDuration = 0.3
  local durationLineHorzMax = 1.2
  local durationLineHorzMin = 0.8
  if isVisible == true then
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.Amount", function(self, currencyAmount)
      UiTextBus.Event.SetText(self.Properties.CurrencyText, GetLocalizedCurrency(currencyAmount or 0))
      if currencyAmount >= self.walletCap then
        UiTextBus.Event.SetColor(self.Properties.CurrencyText, self.UIStyle.COLOR_GREEN_BRIGHT)
      else
        UiTextBus.Event.SetColor(self.Properties.CurrencyText, self.UIStyle.COLOR_WHITE)
      end
    end)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.AzothAmount", function(self, currencyAmount)
      local max = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothMax")
      UiTextBus.Event.SetText(self.Properties.AzothCurrencyText, GetFormattedNumber(currencyAmount or 0) .. " / " .. GetFormattedNumber(max or 1000))
    end)
    local coinCappedTooltip = GetLocalizedReplacementText("@ui_coin_max_tooltip", {
      amount = GetLocalizedCurrency(self.walletCap)
    })
    self.CurrencyText:SetSimpleTooltip(coinCappedTooltip)
    UiElementBus.Event.SetIsEnabled(self.Properties.InventoryAreaDropTarget, true)
    UiElementBus.Event.SetIsEnabled(self.DynamicItemList.entityId, true)
    self.ScriptedEntityTweener:Play(self.DynamicItemList.entityId, animDuration, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.CurrencyText, animDuration, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.InventoryTitle, animDuration, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.LineHorizontal:SetVisible(true, math.max(math.random() * durationLineHorzMax, durationLineHorzMin))
  elseif isVisible == false then
    UiElementBus.Event.SetIsEnabled(self.Properties.InventoryAreaDropTarget, false)
    UiElementBus.Event.SetIsEnabled(self.DynamicItemList.entityId, false)
    self.ScriptedEntityTweener:Set(self.DynamicItemList.entityId, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.CurrencyText, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.InventoryTitle, {opacity = 0})
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Currency.Amount")
  end
end
function NewInventory:SetContainerBgVisible(isVisible)
  local durationLineHorzMax = 1.2
  local durationLineHorzMin = 0.8
  if isVisible then
    self.LineHorizontal:SetVisible(true, math.max(math.random() * durationLineHorzMax, durationLineHorzMin))
  else
    self.LineHorizontal:SetVisible(true, math.max(math.random() * durationLineHorzMax, durationLineHorzMin))
  end
end
function NewInventory:SetEncumbrance(value)
  local maxEncumbrance = LocalPlayerUIRequestsBus.Broadcast.GetMaximumEncumbrance() * ContainerRequestBus.Event.GetFullWhenEncumberedModifier(self.inventoryId)
  local encumbrancePercentageToWarn = ContainerRequestBus.Event.GetEncumbranceWarningPercent(self.inventoryId)
  local percentage = value / maxEncumbrance
  if encumbrancePercentageToWarn < percentage then
    if 0.99 <= percentage then
      message = "@ui_inventoryMaxWeight"
    else
      message = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_inventoryweightremaining", GetFormattedNumber((maxEncumbrance - value) / 10, 1, false))
    end
    self:UpdateInventoryFullMessage("weight", true, message, percentage)
  else
    self:UpdateInventoryFullMessage("weight", false)
  end
  if self.updateWeight == false then
    return
  end
  maxEncumbrance = LocalPlayerUIRequestsBus.Broadcast.GetMaximumEncumbrance()
  if self.encumbranceValue == value and self.maxEncumbranceValue == maxEncumbrance then
    return
  end
  self.WeightBar:SetValue(value / 10, nil, maxEncumbrance / 10)
  self.encumbranceValue = value
  self.maxEncumbranceValue = maxEncumbrance
  if value > maxEncumbrance then
    self.ScriptedEntityTweener:Play(self.EncumberedHighlight, 0.3, {opacity = 0.35})
    self.ScriptedEntityTweener:Set(self.EncumbranceTooltip.Unencumbered, {
      opacity = self.encumbranceTooltipSettings.sectionOpacity
    })
    self.ScriptedEntityTweener:Set(self.EncumbranceTooltip.Encumbered, {opacity = 1})
  else
    self.ScriptedEntityTweener:Play(self.EncumberedHighlight, 0.3, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.EncumbranceTooltip.Unencumbered, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.EncumbranceTooltip.Encumbered, {
      opacity = self.encumbranceTooltipSettings.sectionOpacity
    })
  end
end
function NewInventory:ClearAllModifiers()
  self.isQuickMoveModifierActive = false
  self.isRepairItemModifierActive = false
  self.isRepairKitItemModifierActive = false
  self.isSalvageItemModifierActive = false
  self.isSalvageLockItemModifierActive = false
  self.isSplittingStackModfierActive = false
  self.isLinkItemModifierActive = false
  self:ModifiersChanged()
end
function NewInventory:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if toState == 3548394217 or toState == 4283914359 then
    self:SetScreenVisible(false)
    return
  end
  local equipmentCanvas = UiCanvasManagerBus.Broadcast.FindLoadedCanvasByPathName("LyShineUI/equipment/equipmentv2.uicanvas")
  self.equipmentDrawOrder = UiCanvasBus.Event.GetDrawOrder(equipmentCanvas)
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 3
  self.targetDOFBlur = 0.8
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 0.5,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
  local isContainerOpen = LyShineManagerBus.Broadcast.IsInState(self.STATE_NAME_CONTAINER)
  local isLootDrop = isContainerOpen and self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop")
  if isContainerOpen and not isLootDrop then
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Content, 0)
  else
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Content, 300)
  end
  if toState == self.STATE_NAME_GENERATOR or toState == self.STATE_NAME_P2PTRADING then
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Content, 0)
  end
  if fromState == self.STATE_NAME_INVENTORY and toState == self.STATE_NAME_CONTAINER then
    self:SetContainerBgVisible(true)
    return
  end
  if fromState == self.STATE_NAME_CONTAINER and toState == self.STATE_NAME_INVENTORY then
    self:SetContainerBgVisible(false)
    return
  end
  if toState ~= 476411249 then
    if not self.eventNotificationId then
      local eventNotificationIdNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.EventNotificationEntityId")
      if eventNotificationIdNode then
        self.eventNotificationId = eventNotificationIdNode:GetData()
      end
    end
    if self.eventNotificationId then
      EventNotificationRequestBus.Event.ClientRequestSendNotification(self.eventNotificationId, "Open_Inventory")
    end
    if not self.skipNextLootOpen and toState ~= self.STATE_NAME_GENERATOR and toState ~= self.STATE_NAME_P2PTRADING then
      self:OpenNearbyLootContainers()
      self.skipNextLootOpen = nil
    end
  end
  self.DynamicItemList:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("inventory", true)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("housing", false)
  UiJavCanvasComponentBus.Event.SetOverridesActionMap(self.canvasId, "debug", true)
  self.debugActionMapDisabled = true
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  self:UpdateSectionButtons()
  self.audioHelper:PlaySound(self.audioHelper.Screen_InventoryOpen)
  self.audioHelper:onUIStateChanged(self.audioHelper.UIState_Inventory)
  if not self.isScreenVisible then
    local doCameraTransition = toState == self.STATE_NAME_CONTAINER or toState == self.STATE_NAME_INVENTORY or toState == self.STATE_NAME_GENERATOR or toState == self.STATE_NAME_P2PTRADING
    self:SetScreenVisible(true, doCameraTransition)
  end
  if toState == self.STATE_NAME_INVENTORY or toState == self.STATE_NAME_CONTAINER or toState == self.STATE_NAME_P2PTRADING then
    self:SetInventoryVisible(true)
  end
  if toState == self.STATE_NAME_CONTAINER or toState == self.STATE_NAME_GENERATOR then
    self:SetContainerBgVisible(true)
  end
  if toState == self.STATE_NAME_INVENTORY then
    self:SetContainerBgVisible(false)
  end
  self.GoldButton:SetEnabled(toState ~= self.STATE_NAME_P2PTRADING)
  if not self.actionHandlers then
    self.actionHandlers = {}
    self.actionNames = {
      ui_splitItemStackModifierDown = function()
        self:SetSplittingModifier(true)
      end,
      ui_splitItemStackModifierUp = function()
        self:SetSplittingModifier(false)
      end,
      ui_quickMoveItemModifierDown = function()
        self:SetQuickMoveModifier(true)
      end,
      ui_quickMoveItemModifierUp = function()
        self:SetQuickMoveModifier(false)
      end,
      ui_repairItemModifier = function(self, value)
        self:SetRepairModifier(0 < value)
      end,
      ui_repairKitItemModifier = function(self, value)
        self:SetRepairKitModifier(0 < value)
      end,
      ui_salvageItemModifier = function(self, value)
        self:SetSalvageModifier(0 < value)
      end,
      ui_salvageLockItemModifier = function(self, value)
        self:SetSalvageLockModifier(0 < value)
      end,
      link_item = function(self, value)
        self:SetLinkItemModifier(0 < value)
      end
    }
  end
  for actionNames, _ in pairs(self.actionNames) do
    table.insert(self.actionHandlers, self:BusConnect(CryActionNotificationsBus, actionNames))
  end
  self:ClearAllModifiers()
  for k, item in pairs(self.knownItems) do
    item.seen = true
    for _, draggable in pairs(item.draggables) do
      draggable:SetItemIsShowing(true)
    end
  end
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Inventory.CurrentEncumbrance", self.SetEncumbrance)
  self.WeightBar:AnimateIn()
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    local event = UiAnalyticsEvent("OpenedInventory")
    event:Send()
  end
end
function NewInventory:SetSplittingModifier(active)
  self.isSplittingStackModfierActive = active
  self:ModifiersChanged()
end
function NewInventory:SetQuickMoveModifier(active)
  if FtueSystemRequestBus.Broadcast.IsFtue() == false or self.isInInventoryTutorial == false then
    self.isQuickMoveModifierActive = active
    self:ModifiersChanged()
  end
end
function NewInventory:SetRepairModifier(active)
  self.isRepairItemModifierActive = active
  self:ModifiersChanged()
end
function NewInventory:SetRepairKitModifier(active)
  self.isRepairKitItemModifierActive = active
  self:ModifiersChanged()
end
function NewInventory:SetSalvageModifier(active)
  self.isSalvageItemModifierActive = active
  self:ModifiersChanged()
end
function NewInventory:SetSalvageLockModifier(active)
  self.isSalvageLockItemModifierActive = active
  self:ModifiersChanged()
end
function NewInventory:SetLinkItemModifier(active)
  self.isLinkItemModifierActive = active
  self:ModifiersChanged()
end
function NewInventory:ModifiersChanged()
  local modifier = self:GetActiveModifier()
  if modifier.isValid then
    UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.equipmentDrawOrder + 1)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ActionHintText, modifier.hintText, eUiTextSet_SetLocalized)
    self:AddTickBus()
  else
    UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.defaultDrawOrder)
    self:RemoveTickBus(false)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ActionHintContainer, modifier.isValid)
end
function NewInventory:IsModifierActive()
  return self.isQuickMoveModifierActive or self.isRepairItemModifierActive or self.isRepairKitItemModifierActive or self.isSalvageItemModifierActive or self.isSalvageLockItemModifierActive or self.isSplittingStackModfierActive or self.isLinkItemModifierActive
end
function NewInventory:GetActiveModifier()
  local modifier = {isValid = true, hintText = ""}
  if self.isInInventoryTutorial then
    modifier.isValid = false
    return modifier
  end
  local splitModifier = self.isSplittingStackModfierActive and not self.isQuickMoveModifierActive and not self.isLinkItemModifierActive
  local moveModifierOnly = not self.isSplittingStackModfierActive and self.isQuickMoveModifierActive and not self.isLinkItemModifierActive and not self.isRepairItemModifierActive and not self.isRepairKitItemModifierActive and not self.isSalvageItemModifierActive and not self.isSalvageLockItemModifierActive
  local linkModifierOnly = not self.isSplittingStackModfierActive and not self.isQuickMoveModifierActive and self.isLinkItemModifierActive and not self.isRepairItemModifierActive and not self.isRepairKitItemModifierActive and not self.isSalvageItemModifierActive and not self.isSalvageLockItemModifierActive
  if moveModifierOnly then
    modifier.hintText = "@ui_move_hint"
  elseif linkModifierOnly then
    modifier.hintText = "@ui_link_to_chat_hint"
  elseif splitModifier then
    modifier.hintText = "@ui_split_stack_hint"
    if self.isRepairItemModifierActive then
      modifier.hintText = "@ui_repair_icon_noconfirm"
    elseif self.isRepairKitItemModifierActive then
      modifier.hintText = "@ui_repair_kit_icon_noconfirm"
    elseif self.isSalvageItemModifierActive then
      modifier.hintText = "@ui_salvage_icon_noconfirm"
    end
  elseif self.isRepairItemModifierActive then
    modifier.hintText = "@ui_repair_icon"
  elseif self.isRepairKitItemModifierActive then
    modifier.hintText = "@ui_repair_kit_icon"
  elseif self.isSalvageItemModifierActive then
    modifier.hintText = "@ui_salvage_icon"
  elseif self.isSalvageLockItemModifierActive then
    modifier.hintText = "@ui_salvage_lock_icon"
  else
    modifier.isValid = false
  end
  return modifier
end
function NewInventory:SetInventoryTutorialActive(isActive)
  self.isInInventoryTutorial = isActive
end
function NewInventory:SetWaitingToEquip(isWaitingToEquip)
  self.isWaitingToEquip = isWaitingToEquip
end
function NewInventory:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.defaultDrawOrder)
  if toState ~= self.STATE_NAME_CONTAINER and toState ~= self.STATE_NAME_INVENTORY then
    self.isFirstLoad = false
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
    UiContextMenuBus.Broadcast.SetEnabled(false)
    for k, item in pairs(self.knownItems) do
      item.seen = true
      for _, draggable in pairs(item.draggables) do
        draggable:SetNewIndicatorVisible(false)
        draggable:SetItemIsShowing(false)
      end
    end
    ClearTable(self.openLootContainers)
    local durationOut = 0.2
    self.ScriptedEntityTweener:Play(self.DOFTweenDummyElement, 0.3, {
      opacity = 0,
      onUpdate = function(currentValue, currentProgressPercent)
        self:UpdateDepthOfField(currentValue)
      end,
      onComplete = function()
        JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
      end
    })
    JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_Inventory", 0.5)
    JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_Storage", 0.5)
    self.DynamicItemList:OnTransitionOut(fromState, fromLevel, toState, toLevel)
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
    UIInputRequestsBus.Broadcast.SetActionMapEnabled("inventory", false)
    UIInputRequestsBus.Broadcast.SetActionMapEnabled("housing", self.isInPlot)
    UiJavCanvasComponentBus.Event.SetOverridesActionMap(self.canvasId, "debug", false)
    self.debugActionMapDisabled = false
    LocalPlayerUIRequestsBus.Broadcast.SetIsLookingThroughLoadout(false)
    if not DynamicBus.StatusEffects.Broadcast.IsCurrentlyResting() then
      CraftingRequestBus.Broadcast.OnCraftingScreenHidden()
    end
    local splitter = self:GetStackSplitter()
    if splitter then
      splitter:Hide()
    end
    if self.ItemDyeingPopup:IsEnabled() then
      self:HideItemDyeingPopup()
    end
    if self.ItemSkinsPopup:IsEnabled() then
      self.ItemSkinsPopup:SetIsEnabled(false)
      self.ItemSkinsPopup:SetDividers(false)
    end
    local boxOpeningPopupEnabled = self.dataLayer:GetDataFromNode("UIFeatures.enableBoxOpeningPopup")
    if boxOpeningPopupEnabled then
      DynamicBus.BoxOpeningPopup.Broadcast.HideBoxOpeningPopup()
    end
    if self.actionHandlers then
      for _, handler in ipairs(self.actionHandlers) do
        self:BusDisconnect(handler)
      end
      ClearTable(self.actionHandlers)
    end
    self.isQuickMoveModifierActive = false
    self.isRepairItemModifierActive = false
    self.isRepairKitItemModifierActive = false
    self.isSalvageItemModifierActive = false
    self.isSalvageLockItemModifierActive = false
    self.isSplittingStackModfierActive = false
    self.isLinkItemModifierActive = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ActionHintContainer, false)
    self:SetScreenVisible(false, true)
    self.audioHelper:PlaySound(self.audioHelper.Screen_InventoryClose)
    self.audioHelper:onUIStateChanged(self.audioHelper.UIState_Default)
    local draggable = self.dataLayer:GetEntityTable("CurrentDraggable")
    if draggable then
      draggable:OnDragEnd(Vector2(-10, -10))
    end
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Inventory.CurrentEncumbrance")
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function NewInventory:ItemUpdateDragData(entityId)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  local itemSlot = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotName)
  local stackSize = itemSlot:GetStackSize()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerType", eItemDragContext_Inventory)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerId", self.inventoryId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerSlotId", slotName)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.StackSize", stackSize)
end
function NewInventory:OpenContextMenu(entityId)
end
function NewInventory:ContextInventoryUseItem(entityId)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  LocalPlayerUIRequestsBus.Broadcast.InventoryUseItem(tonumber(slotName))
  self.pendingConfirmItem = nil
  self.pendingConfirmEntityId = nil
end
function NewInventory:ContextInventoryEquipItem(entityId, actionName)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  EquipmentCommon:EquipItemFromInventory(slotName)
end
function NewInventory:ContextInventoryDropItem(entityId, actionName)
  self:DropItem(entityId)
end
function NewInventory:ContextInventorySalvageItem(entityId, itemId)
  DynamicBus.BoxOpeningPopup.Broadcast.SetRewardBoxGameEventId(itemId)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  LocalPlayerUIRequestsBus.Broadcast.SalvageItem(tonumber(slotName), 1, self.inventoryId)
end
function NewInventory:ContextInventoryRepairItem(entityId)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  LocalPlayerUIRequestsBus.Broadcast.RepairItem(slotName, false)
end
function NewInventory:DropItem(draggableEntityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local slotName = ItemContainerBus.Event.GetSlotName(draggableEntityId)
  local targetItem = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotName)
  local itemId = targetItem:GetItemId()
  local staticItemData = StaticItemDataManager:GetItem(itemId)
  local isNonRemovable = targetItem:IsNonRemovableFromPlayer(true)
  if isNonRemovable then
    if not targetItem:IsBoundToPlayer() then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@ui_cantDropMissionItem"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    else
      self:ClearAllModifiers()
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_destroyBoundItem", "@ui_destroyBoundItemMessage", self.destroyItemPopupEventId, self, self.OnPopupResult)
      self.popupDraggableEntityId = draggableEntityId
    end
  else
    self:DropItemWork(draggableEntityId)
  end
end
function NewInventory:DropItemWork(draggableEntityId)
  local slotName = ItemContainerBus.Event.GetSlotName(draggableEntityId)
  local targetItem = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotName)
  local stackSize = targetItem:GetStackSize()
  local draggableTable = self.registrar:GetEntityTable(draggableEntityId)
  if draggableTable then
    stackSize = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ItemDragging.StackSize")
  end
  local isDroppingMissionItem = false
  local procurementDataPath = "Hud.LocalPlayer.ItemsToProcure.ObjectiveIds." .. tostring(targetItem:GetItemName())
  local dataNode = self.dataLayer:GetDataNode(procurementDataPath)
  if dataNode then
    local children = dataNode:GetChildren()
    if 0 < #children then
      for i = 1, #children do
        local childData = children[i]:GetData()
        if childData then
          local objectiveType = ObjectiveRequestBus.Event.GetType(childData)
          if objectiveType ~= eObjectiveType_Crafting then
            isDroppingMissionItem = true
            break
          end
        end
      end
    end
  end
  if isDroppingMissionItem then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@owg_drop_item_notification"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  if self.openLootContainers then
    local nearestLootDrop = self:GetNearestLootContainer()
    if nearestLootDrop then
      local sourceSlotId = tonumber(slotName)
      local targetContainerId = self.dataLayer:GetDataNode("Hud.LocalPlayer.ActiveContainer"):GetData()
      local totalSlots = ContainerRequestBus.Event.GetNumSlots(targetContainerId)
      local emptySlots = ContainerRequestBus.Event.GetNumEmptySlots(targetContainerId)
      local hasItems = emptySlots ~= totalSlots
      if targetContainerId and targetItem and hasItems then
        LocalPlayerUIRequestsBus.Broadcast.PerformContainerTradeEntity(self.inventoryId, sourceSlotId, targetContainerId, -1, stackSize)
        return
      end
    end
  end
  LocalPlayerUIRequestsBus.Broadcast.InventoryDropItem(tonumber(slotName), stackSize)
end
function NewInventory:OnShowTransferCurrencyPopup()
  LyShineManagerBus.Broadcast.SetState(2729122569)
end
function NewInventory:SizeEncumbranceTooltip()
  local sectionMargin = 24
  local descriptionOffsets = UiTransform2dBus.Event.GetOffsets(self.EncumbranceTooltip.Description)
  local lastY = descriptionOffsets.top + UiTransform2dBus.Event.GetLocalHeight(self.EncumbranceTooltip.Description)
  local lastHeight = 0
  local sections = {
    self.EncumbranceTooltip.Unencumbered,
    self.EncumbranceTooltip.Encumbered
  }
  for _, section in ipairs(sections) do
    self.ScriptedEntityTweener:Set(section, {
      y = lastY + sectionMargin
    })
    local children = UiElementBus.Event.GetChildren(section)
    for j = 1, #children do
      lastHeight = math.max(lastHeight, UiTransform2dBus.Event.GetOffsets(children[j]).top + UiTransform2dBus.Event.GetLocalHeight(children[j]))
    end
    lastY = lastY + sectionMargin + lastHeight
    lastHeight = 0
  end
  self.EncumbranceTooltip.Frame:SetWidth(UiTransform2dBus.Event.GetLocalWidth(self.EncumbranceTooltip.Container))
  self.EncumbranceTooltip.Frame:SetHeight(lastY + sectionMargin)
end
function NewInventory:OnEncumbranceHoverStart()
  local fadeInTime = 0.15
  self.ScriptedEntityTweener:Play(self.EncumbranceTooltip.Container, fadeInTime, {
    delay = self.encumbranceTooltipSettings.intentTime,
    opacity = 1
  })
  self.EncumbranceTooltip.Frame:SetLineVisible(true, fadeInTime * 4, {
    delay = self.encumbranceTooltipSettings.intentTime
  })
end
function NewInventory:OnEncumbranceHoverEnd()
  local fadeOutTime = 0.15
  self.ScriptedEntityTweener:Stop(self.EncumbranceTooltip.Container)
  self.EncumbranceTooltip.Frame:SetLineVisible(false, fadeOutTime)
  self.ScriptedEntityTweener:Play(self.EncumbranceTooltip.Container, fadeOutTime, {opacity = 0})
end
function NewInventory:GetStackSplitter()
  return self.registrar:GetEntityTable(self.dataLayer:GetDataFromNode("Hud.StackSplitter"))
end
function NewInventory:CanTransferAllByClass(itemClass)
  if DynamicBus.TradeScreen.Broadcast.IsInTradeSession() then
    return false
  end
  local targetContainerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
  if targetContainerEntityId and targetContainerEntityId:IsValid() then
    return ContainerRequestBus.Event.CheckItemClassCompatibility(targetContainerEntityId, itemClass)
  else
    return true
  end
end
function NewInventory:IsOnlyHoldingBoundItems()
  local availableSlots = ContainerRequestBus.Event.GetNumSlots(self.inventoryId) or 0
  local numRemovable = 0
  for slotId = 0, availableSlots - 1 do
    local slot = ContainerRequestBus.Event.GetSlot(self.inventoryId, tostring(slotId))
    if slot and slot:IsValid() then
      local itemId = slot:GetItemId()
      local staticItemData = StaticItemDataManager:GetItem(itemId)
      if not staticItemData.nonremovable then
        return false
      else
        numRemovable = numRemovable + 1
      end
    end
  end
  return 0 < numRemovable
end
function NewInventory:OnTransferAllByClass(itemClass)
  if self.isInInventoryTutorial then
    return false
  end
  local targetContainerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
  if self:IsOnlyHoldingBoundItems() then
    local isDestroyRequest = not ContainerRequestBus.Event.IsPlayerContainer(targetContainerId)
    if isDestroyRequest then
      self.dropAllItemClass = itemClass
      self:ClearAllModifiers()
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_destroyBoundItems", "@ui_destroyBoundItemsMessage", self.destroyItemsPopupEventId, self, self.OnPopupResult)
    end
  elseif not targetContainerId or not targetContainerId:IsValid() then
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_dropconfirm_title", "@ui_dropconfirm_msg", self.confirmDropPopupEventId, self, function(self, result, eventId)
      if eventId ~= self.confirmDropPopupEventId then
        return
      end
      if result ~= ePopupResult_Yes then
        return
      end
      self:ExecuteTransferAllByClass(itemClass, false)
    end)
  else
    self:ExecuteTransferAllByClass(itemClass, false)
  end
  self.audioHelper:PlaySound(self.audioHelper.InteractOptionPressed)
end
function NewInventory:ExecuteTransferAllByClass(itemClass, dropBound)
  local targetContainerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainer")
  if not dropBound and targetContainerId and targetContainerId:IsValid() then
    LocalPlayerUIRequestsBus.Broadcast.GiveAllByClass(targetContainerId, itemClass)
  else
    LocalPlayerUIRequestsBus.Broadcast.DropAllByClass(itemClass, dropBound)
  end
end
function NewInventory:ShowConvertRepairPartsPopup(tier)
  local pos = self.RepairPartsContainer:GetTierButtonPosition(tier)
  self.RepairPartsPopup:SetConvertRepairPartsPopupVisibility(true, tier, pos)
end
function NewInventory:ShowAzothTooltip()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local rows = {}
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_CurrencyInfo,
    iconPath = "LyShineUI/Images/Icons/Items_HiRes/AzureT1.dds",
    descriptionText = "@ui_azoth_desc",
    currencyName = "@ui_azoth_currency",
    derivedFrom = "@inv_azoth_tooltip_drivedfrom"
  })
  flyoutMenu:SetOpenLocation(self.Properties.AzothCurrencyText)
  flyoutMenu:SetSourceHoverOnly(true)
  flyoutMenu:DockToCursor()
  flyoutMenu:SetRowData(rows)
end
function NewInventory:HideAzothTooltip()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
end
function NewInventory:ShowItemSkinsPopup(entityId, isInInventoryOrStorage, storageContainerId)
  local state = LyShineManagerBus.Broadcast.GetCurrentState()
  if state == 3548394217 then
    LyShineManagerBus.Broadcast.ExitState(3548394217)
  end
  local slotId = ItemContainerBus.Event.GetSlotName(entityId)
  if not slotId then
    return
  end
  DynamicBus.EquipmentBus.Broadcast.SetScreenVisible(false)
  if not isInInventoryOrStorage then
    JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_ItemSkinning", 0.5)
  end
  local positionX = -100
  UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemSkinsPopup, positionX)
  self.ItemSkinsPopup.inventoryId = self.inventoryId
  self.ItemSkinsPopup.playerId = self.playerId
  self.ItemSkinsPopup:SetCloseCallback(self.DisableOrbitCamera, self)
  self.ItemSkinsPopup:SetIsEnabled(true)
  self.ItemSkinsPopup:SetSlot(slotId, isInInventoryOrStorage, true, storageContainerId)
  self.ItemSkinsPopup:SetDividers(true)
  self:EnableOrbitCamera(-70)
end
function NewInventory:OnCameraPressed(entityId)
  UiInteractableBus.Event.SetStayActiveAfterRelease(entityId, true)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", true)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
end
function NewInventory:OnCameraReleased(entityId)
  UiInteractableBus.Event.SetStayActiveAfterRelease(entityId, false)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", false)
end
function NewInventory:ShowItemDyeingPopup(entityId)
  local state = LyShineManagerBus.Broadcast.GetCurrentState()
  if state == 3548394217 then
    LyShineManagerBus.Broadcast.ExitState(3548394217)
  end
  DynamicBus.CatContainer.Broadcast.SetScreenVisible(false)
  DynamicBus.VitalsBus.Broadcast.SetVisible(false)
  DynamicBus.StatusEffects.Broadcast.SetVisible(false)
  local slotId = ItemContainerBus.Event.GetSlotName(entityId)
  if not slotId then
    return
  end
  self.ScriptedEntityTweener:Play(self.Properties.ItemDyeingPopup, 0.2, {opacity = 0, y = -70}, {
    opacity = 1,
    y = -80,
    ease = "QuadOut"
  })
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_ArmorDyeingInventory", 0.5)
  self.ItemDyeingPopup.inventoryId = self.inventoryId
  self.ItemDyeingPopup.playerId = self.playerId
  self.ItemDyeingPopup:SetIsEnabled(true)
  self.ItemDyeingPopup:SetSlot(slotId)
  self:EnableOrbitCamera(-70)
end
function NewInventory:HideItemDyeingPopup()
  DynamicBus.VitalsBus.Broadcast.SetVisible(true)
  DynamicBus.StatusEffects.Broadcast.SetVisible(true)
  self.ItemDyeingPopup:SetIsEnabled(false)
  self:DisableOrbitCamera()
end
function NewInventory:EnableOrbitCamera(promptOffset)
  UiElementBus.Event.SetIsEnabled(self.Properties.DyeSkinCameraButton, true)
  self.ScriptedEntityTweener:Set(self.Properties.DyeSkinCameraPrompt, {x = promptOffset})
  UiElementBus.Event.SetIsEnabled(self.Properties.DyeSkinCameraPrompt, true)
end
function NewInventory:DisableOrbitCamera()
  UiElementBus.Event.SetIsEnabled(self.Properties.DyeSkinCameraButton, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.DyeSkinCameraPrompt, false)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", false)
end
function NewInventory:SetItemSelectedForTrade(slotId, selected)
  local itemSlot = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotId)
  local instanceId = itemSlot:GetItemInstanceId()
  local item = self.knownItems[tostring(instanceId)]
  for _, draggable in pairs(item.draggables) do
    if draggable:GetItemInstanceId() == instanceId then
      draggable:SetIsSelectedForTrade(selected)
    end
  end
end
function NewInventory:ClearItemsSelectedForTrade()
  for _, item in pairs(self.knownItems) do
    for _, draggable in pairs(item.draggables) do
      draggable:SetIsSelectedForTrade(false)
    end
  end
end
function NewInventory:UpdateSectionButtons()
  local isContainerOpen = LyShineManagerBus.Broadcast.IsInState(3349343259)
  local isLootDrop = isContainerOpen and self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop")
  local text = "@ui_dropall"
  if DynamicBus.TradeScreen.Broadcast.IsInTradeSession() then
    text = "@ui_dropall_in_trade"
  elseif isContainerOpen and not isLootDrop then
    text = "@ui_storeall"
  end
  self.DynamicItemList:SetTransferAllInfo(self, self.CanTransferAllByClass, self.OnTransferAllByClass, text, -0.5)
end
function NewInventory:SetGroundDropTargetForceDisabled(isForceDisabled)
  self.GroundDropTarget:SetIsForceDisabled(isForceDisabled)
end
function NewInventory:BeginPaperdollMode()
  self.defaultItemSkinIds = {}
  local slots = {
    ePaperDollSlotTypes_Head,
    ePaperDollSlotTypes_Chest,
    ePaperDollSlotTypes_Hands,
    ePaperDollSlotTypes_Legs,
    ePaperDollSlotTypes_Feet,
    ePaperDollSlotTypes_MainHandOption1,
    ePaperDollSlotTypes_OffHandOption1
  }
  for i, slotId in ipairs(slots) do
    local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotId)
    if slot then
      local baseItemId = slot:GetItemId()
      local overrideItemId = ItemSkinningRequestBus.Event.GetItemSkinItemId(self.playerId, baseItemId)
      if overrideItemId ~= 0 then
        self.defaultItemSkinIds[slotId] = overrideItemId
      else
        self.defaultItemSkinIds[slotId] = baseItemId
      end
    end
  end
  DynamicBus.CatContainer.Broadcast.SetScreenVisible(false)
  CustomizableCharacterRequestBus.Event.StartPreview(self.playerId)
  DynamicBus.Inventory.Broadcast.SetScreenVisible(false, true)
end
function NewInventory:PreviewItem(itemSkinData)
  local itemDescriptor = ItemDescriptor()
  itemDescriptor.itemId = itemSkinData.toItemId
  local slotId = itemDescriptor:GetPaperdollSlot()
  local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotId)
  local dyeData = slot:GetDyeData()
  local forceShortSleeves = false
  CustomizableCharacterRequestBus.Event.PreviewEquipmentPart(self.playerId, slotId, itemSkinData.toItemId, dyeData, forceShortSleeves)
end
function NewInventory:ResetPreviewItem(itemSkinData)
  local itemDescriptor = ItemDescriptor()
  itemDescriptor.itemId = itemSkinData.toItemId
  local slotId = itemDescriptor:GetPaperdollSlot()
  if self.defaultItemSkinIds[slotId] then
    local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotId)
    local dyeData = slot:GetDyeData()
    local forceShortSleeves = false
    CustomizableCharacterRequestBus.Event.PreviewEquipmentPart(self.playerId, slotId, self.defaultItemSkinIds[slotId], dyeData, forceShortSleeves)
  end
end
function NewInventory:EndPaperdollMode()
  CustomizableCharacterRequestBus.Event.StopPreview(self.playerId)
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.5)
  if self.closeCallbackTable and type(self.closeCallback) == "function" then
    self.closeCallback(self.closeCallbackTable)
  end
end
return NewInventory

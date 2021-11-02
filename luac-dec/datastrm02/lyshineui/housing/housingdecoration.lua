local HousingDecoration = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    DecorationWindow = {
      default = EntityId()
    },
    SimpleGridItemList = {
      default = EntityId()
    },
    HousingGridItemPrototype = {
      default = EntityId()
    },
    HousingWorldInteraction = {
      default = EntityId()
    },
    ItemCountLabel = {
      default = EntityId()
    },
    ItemScoreLabel = {
      default = EntityId()
    },
    ItemScoreText = {
      default = EntityId()
    },
    ItemCountText = {
      default = EntityId()
    },
    ItemScoreDeltaLabel = {
      default = EntityId()
    },
    Trophies = {
      default = EntityId()
    },
    SearchInputText = {
      default = EntityId()
    },
    ShowOnlyOwnedCheckbox = {
      default = EntityId()
    },
    TabbedList = {
      default = EntityId()
    }
  },
  categoryPaths = "lyShineui/images/icons/housing/icon_housing_category_",
  BUTTONS = {},
  BUTTON_SIZE = 50
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(HousingDecoration)
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
function HousingDecoration:OnInit()
  BaseScreen.OnInit(self)
  self.ScreenHeader:SetText("@ui_housing_decorations")
  self.ScreenHeader:SetHintCallback(self.OnDecorationExitButton, self)
  SetTextStyle(self.Properties.ItemScoreLabel, self.UIStyle.FONT_STYLE_SCREEN_HEADER_DATA)
  SetTextStyle(self.Properties.ItemScoreDeltaLabel, self.UIStyle.FONT_STYLE_SCREEN_HEADER_DATA)
  SetTextStyle(self.Properties.ItemCountLabel, self.UIStyle.FONT_STYLE_SCREEN_HEADER_DATA)
  SetTextStyle(self.Properties.ItemScoreText, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  SetTextStyle(self.Properties.ItemCountText, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  self.clonedElements = {}
  self.itemCategoriesToItemData = {}
  local housingItemIds = ItemDataManagerBus.Broadcast.GetHousingItemIds()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    self.inventoryId = data
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableEntitlements", function(self, enableEntitlements)
    self.entitlementsEnabled = enableEntitlements
  end)
  local itemDescriptor = ItemDescriptor()
  local function GetInventoryQuantityFn(callingSelf)
    if callingSelf.housingItemData:IsEntitlement() then
      if EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeHousingItem, callingSelf.housingItemData.id) then
        return PlayerHousingClientRequestBus.Broadcast.GetRemainingEntitlementHousingItems(callingSelf.housingItemData.id)
      end
      return 0
    end
    itemDescriptor.itemId = callingSelf.housingItemData.id
    return ContainerRequestBus.Event.GetItemCount(self.inventoryId, itemDescriptor, false, true, true)
  end
  local allItems = {}
  for i = 1, #housingItemIds do
    local housingItemId = housingItemIds[i]
    local housingItemData = ItemDataManagerBus.Broadcast.GetHousingItemData(housingItemId)
    local itemDataList = self.itemCategoriesToItemData[housingItemData.uiHousingCategory]
    if not itemDataList then
      itemDataList = {}
      self.itemCategoriesToItemData[housingItemData.uiHousingCategory] = itemDataList
    end
    local itemId = housingItemData.id
    local staticItemData = ItemDataManagerBus.Broadcast.GetItemData(itemId)
    local itemData = {
      housingItemData = housingItemData,
      callbackSelf = self,
      callbackFn = self.OnDecorationItemClicked,
      GetQuantity = GetInventoryQuantityFn,
      locSearchText = string.lower(LyShineScriptBindRequestBus.Broadcast.LocalizeText(staticItemData.displayName)),
      displayName = staticItemData.displayName
    }
    if not housingItemData:IsEntitlement() or self.entitlementsEnabled then
      table.insert(itemDataList, itemData)
      table.insert(allItems, itemData)
    end
  end
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    for _, itemData in ipairs(allItems) do
      itemData.locSearchText = LyShineScriptBindRequestBus.Broadcast.LocalizeText(itemData.displayName)
    end
  end)
  local listData = self.BUTTONS
  local allCategoryId = "all"
  local iconPath = self.categoryPaths .. allCategoryId .. ".dds"
  table.insert(listData, {
    iconPath = iconPath,
    text = "",
    callback = self.OnDecorationTabSelected,
    height = self.BUTTON_SIZE,
    width = self.BUTTON_SIZE,
    category = allCategoryId
  })
  for categoryName, _ in pairs(self.itemCategoriesToItemData) do
    local entitlementCategory = categoryName == "Entitlements"
    if not entitlementCategory or self.entitlementsEnabled then
      local iconPath = self.categoryPaths .. categoryName .. ".dds"
      table.insert(listData, {
        iconPath = iconPath,
        text = "",
        callback = self.OnDecorationTabSelected,
        height = self.BUTTON_SIZE,
        width = self.BUTTON_SIZE,
        category = categoryName
      })
    end
  end
  self.TabbedList:SetListData(listData, self)
  self.itemCategoriesToItemData[allCategoryId] = allItems
  self.SimpleGridItemList:Initialize(self.HousingGridItemPrototype)
  self.SimpleGridItemList:OnListDataSet(nil)
  self.cryActionHandlers = {}
  HousingDecorationRequestBus.Broadcast.DisableGridSnapping()
  self.gridSnappingEnabled = false
  self.HousingWorldInteraction:OnToggleGrid(self.gridSnappingEnabled)
  HousingDecorationRequestBus.Broadcast.EnableSurfaceLock(false)
  self.SearchInputText:SetSearchOverride(self.ItemSearch, self)
  self.SearchInputText:SetSelectedCallback(self.OnItemSearchSelected, self)
  self.SearchInputText:SetEnterCallback(self.OnItemSearchEnter, self)
  self.ShowOnlyOwnedCheckbox:SetText("@ui_housing_owned_filter")
  self.ShowOnlyOwnedCheckbox:SetCallback(self, self.OnOwnedFilterPressed)
  self.ShowOnlyOwnedCheckbox:SetState(false)
  self.noItemsData = {
    label = "@ui_housing_no_items_found"
  }
  self.housingPlaceResultToText = {
    [eHousingDecorationResult_NotOwner] = "@ui_housingDecResult_NotOwner",
    [eHousingDecorationResult_NoItemSelected] = "@ui_housingDecResult_NoItemSelected",
    [eHousingDecorationResult_InvalidItem] = "@ui_housingDecResult_InvalidItem",
    [eHousingDecorationResult_InvalidPosition] = "@ui_housingDecResult_InvalidPosition",
    [eHousingDecorationResult_InvalidHousingItemId] = "@ui_housingDecResult_InvalidItem",
    [eHousingDecorationResult_HousingItemIdExceeded] = "@ui_housingDecResult_ItemIdLimit",
    [eHousingDecorationResult_WaitingOnAction] = "@ui_housingDecResult_Waiting",
    [eHousingDecorationResult_TimeOut] = "@ui_housingDecResult_TimeOut",
    [eHousingDecorationResult_TotalHousingItemLimitReached] = "@ui_housingDecResult_ItemLimit",
    [eHousingDecorationResult_TotalHousingItemTagLimitReached] = "@ui_housingDecResult_TagLimit",
    [eHousingDecorationResult_TotalHousingItemEntitlementLimitReached] = "@ui_housingDecResult_entitlementLimit"
  }
  self.dataLayer:RegisterDataCallback(self, "Housing.PlacedItemsUpdated", function(self, hasUpdated)
    self:RefreshTrophies()
  end)
end
function HousingDecoration:OnShutdown()
  BaseScreen.OnShutdown(self)
  for _, elementId in ipairs(self.clonedElements) do
    UiElementBus.Event.DestroyElement(elementId)
  end
end
local cryActions = {
  "start_rotate_camera",
  "stop_rotate_camera",
  "housing_confirm",
  "ui_scroll_up",
  "ui_scroll_down",
  "housing_toggle_grid",
  "housing_toggle_surface_lock"
}
function HousingDecoration:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  self.isTransitionedIn = true
  if not self.decorationBusHandler then
    self.decorationBusHandler = self:BusConnect(HousingDecorationEventBus)
    JavCameraControllerRequestBus.Broadcast.OverrideCameraState("HousingDecorationCam", 0.5)
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
    HousingDecorationRequestBus.Broadcast.EnableDecorationMode()
    self:RefreshTrophies()
  end
  if #self.cryActionHandlers == 0 then
    for _, action in ipairs(cryActions) do
      local handler = self:BusConnect(CryActionNotificationsBus, action)
      table.insert(self.cryActionHandlers, handler)
    end
  end
  if not self.containerBus then
    local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    self.containerBus = self:BusConnect(ContainerEventBus, inventoryId)
  end
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
  self.ScriptedEntityTweener:Set(self.ItemScoreDeltaLabel, {opacity = 0})
  self.itemScore = PlayerHousingClientRequestBus.Broadcast.GetHouseDecorationScore()
  self:OnDecorationScoreChanged(self.itemScore)
  local itemCount = PlayerHousingClientRequestBus.Broadcast.GetPlacedHousingItemCount()
  self.itemLimit = PlayerHousingClientRequestBus.Broadcast.GetTotalHousingItemLimit()
  self:OnTotalPlacedHousingItemsCountChanged(itemCount)
  self.TabbedList:SetUnselected()
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    onComplete = function()
      self.TabbedList:SetSelected(1)
    end
  })
end
function HousingDecoration:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  self.isTransitionedIn = false
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  if self.decorationBusHandler then
    self:BusDisconnect(self.decorationBusHandler)
    self.decorationBusHandler = nil
    HousingDecorationRequestBus.Broadcast.DisableDecorationMode()
    self:OnStopHoverOverHousingItem()
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
    JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.3)
  end
  self.HousingWorldInteraction:OnEndWorldInteraction()
  for _, handler in ipairs(self.cryActionHandlers) do
    self:BusDisconnect(handler)
  end
  ClearTable(self.cryActionHandlers)
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  if self.containerBus then
    self:BusDisconnect(self.containerBus)
    self.containerBus = nil
  end
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function HousingDecoration:RefreshTrophies()
  local maxTrophies = 5
  local activeTrophyData = {}
  local inOwnHouse = PlayerHousingClientRequestBus.Broadcast.HasEnteredOwnHouse()
  if inOwnHouse then
    local trophyHousingItems = PlayerHousingClientRequestBus.Broadcast.GetCurrentTrophyHousingItems()
    for i = 1, #trophyHousingItems do
      local housingItemClientData = trophyHousingItems[i]
      local item = StaticItemDataManager:GetItem(housingItemClientData.itemId)
      if item then
        table.insert(activeTrophyData, {
          icon = item.iconPath,
          staticItemData = item
        })
      end
    end
  end
  self.Trophies:OnSetTrophyData(activeTrophyData, math.max(maxTrophies, #activeTrophyData))
end
function HousingDecoration:OnContainerChanged()
  self:FillList(self.lastFilledList)
end
function HousingDecoration:OnCryAction(actionName, value)
  if actionName == "start_rotate_camera" then
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  elseif actionName == "stop_rotate_camera" then
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  end
  if HousingDecorationRequestBus.Broadcast.IsInMoveMode() then
    DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
    if actionName == "housing_confirm" then
      local result = HousingDecorationRequestBus.Broadcast.ConfirmPlacement()
    elseif actionName == "housing_toggle_grid" then
      self.gridSnappingEnabled = not self.gridSnappingEnabled
      if self.gridSnappingEnabled then
        HousingDecorationRequestBus.Broadcast.EnableGridSnapping()
      else
        HousingDecorationRequestBus.Broadcast.DisableGridSnapping()
      end
      self.HousingWorldInteraction:OnToggleGrid(self.gridSnappingEnabled)
    elseif actionName == "disable_grid" then
      HousingDecorationRequestBus.Broadcast.DisableGridSnapping()
    elseif actionName == "housing_toggle_surface_lock" then
      self.surfaceLockEnabled = not self.surfaceLockEnabled
      HousingDecorationRequestBus.Broadcast.EnableSurfaceLock(self.surfaceLockEnabled)
      self.HousingWorldInteraction:OnToggleSurfaceLock(self.surfaceLockEnabled)
    elseif actionName == "ui_scroll_up" then
      HousingDecorationRequestBus.Broadcast.RotateItemCounterClockwise(value)
    elseif actionName == "ui_scroll_down" then
      HousingDecorationRequestBus.Broadcast.RotateItemClockwise(value)
    end
  end
end
local notificationData = NotificationData()
notificationData.type = "Minor"
function HousingDecoration:OnPlaceNewItem(result, newHousingItemId)
  self:HandleHousingOperationResult(result)
end
function HousingDecoration:OnMoveItem(result, movedHousingItemId)
  self:HandleHousingOperationResult(result)
end
function HousingDecoration:OnRemoveItem(result, removedHousingItemId)
  self:HandleHousingOperationResult(result)
end
function HousingDecoration:HandleHousingOperationResult(result)
  if result ~= eHousingDecorationResult_Success then
    local errorText = self.housingPlaceResultToText[result]
    errorText = errorText or "@ui_housingDecResult_Unknown"
    notificationData.text = errorText
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function HousingDecoration:OnTotalPlacedHousingItemsCountChanged(newCount)
  UiTextBus.Event.SetText(self.ItemCountLabel, tostring(newCount) .. "/" .. tostring(self.itemLimit))
end
function HousingDecoration:OnHousingItemCountChanged(housingItemId, newCount)
  self:FillList(self.lastFilledList)
end
function HousingDecoration:OnDecorationScoreChanged(newScore)
  if Math.IsClose(newScore, 0) then
    newScore = 0
  end
  local delta = newScore - self.itemScore
  self.itemScore = newScore
  UiTextBus.Event.SetText(self.ItemScoreLabel, GetFormattedNumber(self.itemScore * 100))
  if not Math.IsClose(delta, 0) then
    local deltaString = (0 < delta and "+" or "") .. GetFormattedNumber(delta * 100)
    UiTextBus.Event.SetText(self.ItemScoreDeltaLabel, deltaString)
    self.ScriptedEntityTweener:Play(self.ItemScoreDeltaLabel, 0.1, {y = 10, opacity = 0}, {
      y = 0,
      opacity = 1,
      ease = "QuadIn"
    })
    self.ScriptedEntityTweener:Play(self.ItemScoreDeltaLabel, 0.1, {y = 0}, {
      y = -20,
      opacity = 0,
      delay = 1.25,
      ease = "QuadOut"
    })
  end
end
function HousingDecoration:OnModeChanged(oldModeEnum, newModeEnum)
  self.currentHousingMode = newModeEnum
  local showDecorationWindow = newModeEnum ~= eHousingDecorationMode_Move
  UiElementBus.Event.SetIsEnabled(self.Properties.DecorationWindow, showDecorationWindow)
  if newModeEnum == eHousingDecorationMode_Move then
    self.HousingWorldInteraction:OnStartWorldInteraction()
  elseif oldModeEnum == eHousingDecorationMode_Move then
    self.HousingWorldInteraction:OnEndWorldInteraction()
    HousingDecorationRequestBus.Broadcast.EnableSurfaceLock(false)
  elseif newModeEnum == eHousingDecorationMode_Disabled and LyShineManagerBus.Broadcast.IsInState(2640373987) then
    self:OnDecorationExitButton()
  end
end
function HousingDecoration:OnHoverOverHousingItem(housingItemId)
  self.HousingWorldInteraction:OnInteractionAvailable(housingItemId)
end
function HousingDecoration:OnStopHoverOverHousingItem()
  self.HousingWorldInteraction:OnInteractionUnavailable()
end
function HousingDecoration:OnSurfaceLockDisabled()
  self.surfaceLockEnabled = false
  self.HousingWorldInteraction:OnToggleSurfaceLock(self.surfaceLockEnabled)
end
function HousingDecoration:OnDecorationExitButton()
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
function HousingDecoration:OnEscapeKeyPressed()
  if self.currentHousingMode == eHousingDecorationMode_Move then
    HousingDecorationRequestBus.Broadcast.CancelPlacement()
  elseif self.currentHousingMode == eHousingDecorationMode_ContextMenu then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  else
    self:OnDecorationExitButton()
  end
end
function HousingDecoration:FillList(itemDataList)
  self.lastFilledList = itemDataList
  self.outpostId = LocalPlayerUIRequestsBus.Broadcast.GetStorageKeyForGlobalStorage()
  if not self.outpostId or string.len(self.outpostId) == 0 then
    self:FillListCallback()
  else
    contractsDataHandler:RequestStorageData(self.outpostId, self, self.FillListCallback)
  end
end
function HousingDecoration:FillListCallback()
  table.sort(self.lastFilledList, function(a, b)
    local aQuantity = a:GetQuantity()
    local bQuantity = b:GetQuantity()
    if aQuantity ~= bQuantity then
      return aQuantity > bQuantity
    else
      return a.displayName < b.displayName
    end
  end)
  if self.filterToOwnedItems then
    local ownedList = {}
    for _, itemData in ipairs(self.lastFilledList) do
      if itemData:GetQuantity() <= 0 then
        break
      end
      table.insert(ownedList, itemData)
    end
    self.SimpleGridItemList:OnListDataSet(ownedList, (not ownedList or ownedList[1] == nil) and self.noItemsData or nil)
  else
    self.SimpleGridItemList:OnListDataSet(self.lastFilledList, (not self.lastFilledList or self.lastFilledList[1] == nil) and self.noItemsData or nil)
  end
end
function HousingDecoration:OnDecorationTabSelected(entity)
  local buttonIndex = entity:GetIndex()
  local categoryId = self.BUTTONS[buttonIndex].category
  local itemDataList = self.itemCategoriesToItemData[categoryId]
  local locTag = string.lower("@ui_" .. categoryId)
  self.SimpleGridItemList:SetHeaderText(locTag)
  if categoryId == "Entitlements" or categoryId == "all" then
    self.SimpleGridItemList:SetSpinnerShowing(true)
    if self.inventoryId and self.isTransitionedIn then
      OmniDataHandler:GetOmniOffers(self, function(self, offers)
        if not self.inventoryId or not self.isTransitionedIn then
          return
        end
        local filteredList = {}
        for i, itemData in ipairs(itemDataList) do
          itemData.availableProducts = nil
          if itemData.housingItemData:IsEntitlement() and not EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeHousingItem, itemData.housingItemData.id) then
            itemData.availableProducts = OmniDataHandler:SearchOffersForRewardTypeAndKey(offers, eRewardTypeHousingItem, itemData.housingItemData.id)
          end
          table.insert(filteredList, itemData)
        end
        self:FillList(filteredList)
      end)
    end
  else
    self:FillList(itemDataList)
  end
end
function HousingDecoration:OnDecorationItemClicked(decorationItemData)
  if decorationItemData.availableProducts then
    local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
    flyoutMenu:SetSourceHoverOnly(false)
    flyoutMenu:Lock()
  else
    local result = HousingDecorationRequestBus.Broadcast.SpawnNewHousingItem(decorationItemData.housingItemData.id)
    self:HandleHousingOperationResult(result)
  end
end
function HousingDecoration:ItemSearch(searchText)
  local term = string.lower(searchText)
  local allItems = self.itemCategoriesToItemData.all
  local itemList = {}
  for _, itemData in ipairs(allItems) do
    if string.find(itemData.locSearchText, term) then
      table.insert(itemList, itemData)
    end
  end
  self.lastSearchResults = itemList
  return itemList
end
function HousingDecoration:OnItemSearchSelected(itemData)
  self:FillList({itemData})
end
function HousingDecoration:OnItemSearchEnter()
  self:FillList(self.lastSearchResults)
  self.SearchInputText:ClearMatchingList()
end
function HousingDecoration:OnOwnedFilterPressed(isChecked)
  self.filterToOwnedItems = isChecked
  self:FillList(self.lastFilledList)
end
return HousingDecoration

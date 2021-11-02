local ArmorDyeing = {
  Properties = {
    HeadSlot = {
      default = EntityId(),
      order = 1
    },
    ChestSlot = {
      default = EntityId(),
      order = 2
    },
    HandsSlot = {
      default = EntityId(),
      order = 3
    },
    LegsSlot = {
      default = EntityId(),
      order = 4
    },
    FeetSlot = {
      default = EntityId(),
      order = 5
    },
    ShieldSlot = {
      default = EntityId(),
      order = 6
    },
    HeadSelectorRow = {
      default = EntityId(),
      order = 7
    },
    ChestSelectorRow = {
      default = EntityId(),
      order = 8
    },
    HandsSelectorRow = {
      default = EntityId(),
      order = 9
    },
    LegsSelectorRow = {
      default = EntityId(),
      order = 10
    },
    FeetSelectorRow = {
      default = EntityId(),
      order = 11
    },
    ShieldSelectorRow = {
      default = EntityId(),
      order = 12
    },
    DyePicker = {
      default = EntityId()
    },
    ConfirmButton = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    SpawnerComponent = {
      default = EntityId()
    }
  },
  slotEnumToEntityIdMap = {},
  slotEnumToSelectorsMap = {},
  availableDyes = {},
  ITEM_LAYOUT_SLICE = "LyShineUI/Slices/ItemLayout"
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(ArmorDyeing)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(ArmorDyeing)
local CommonDragDrop = RequireScript("LyShineUI.CommonDragDrop")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
function ArmorDyeing:OnInit()
  BaseScreen.OnInit(self)
  self.ConfirmButton:SetCallback(self.OnConfirm, self)
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
  self.ConfirmButton:SetText("@ui_confirm")
  self.CancelButton:SetCallback(self.OnCancel, self)
  self.CancelButton:SetText("@ui_cancel")
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.SpawnerComponent)
  self.slotEnumToSelectorsMap = {
    [ePaperDollSlotTypes_Head] = self.HeadSelectorRow,
    [ePaperDollSlotTypes_Chest] = self.ChestSelectorRow,
    [ePaperDollSlotTypes_Hands] = self.HandsSelectorRow,
    [ePaperDollSlotTypes_Legs] = self.LegsSelectorRow,
    [ePaperDollSlotTypes_Feet] = self.FeetSelectorRow,
    [ePaperDollSlotTypes_OffHandOption1] = self.ShieldSelectorRow
  }
  for slotId, selectorRow in pairs(self.slotEnumToSelectorsMap) do
    selectorRow:SetSlot(slotId)
    selectorRow:SetCallback(self, self.OnSlotColorsChanged)
    selectorRow:SetPicker(self.DyePicker)
  end
  self.DyePicker:SetOpenCallback(self, function()
    self:PopulatePicker()
  end)
  self.cryActionHandlers = {}
  self.slotEnumToEntityIdMap = {
    [ePaperDollSlotTypes_Head] = self.Properties.HeadSlot,
    [ePaperDollSlotTypes_Chest] = self.Properties.ChestSlot,
    [ePaperDollSlotTypes_Hands] = self.Properties.HandsSlot,
    [ePaperDollSlotTypes_Legs] = self.Properties.LegsSlot,
    [ePaperDollSlotTypes_Feet] = self.Properties.FeetSlot,
    [ePaperDollSlotTypes_OffHandOption1] = self.Properties.ShieldSlot
  }
  for slotIndex = 0, ePaperDollSlotTypes_Num do
    local dropTargetId = self.slotEnumToEntityIdMap[slotIndex]
    if dropTargetId then
      local data = {
        slotIndex = slotIndex,
        item = nil,
        parentId = dropTargetId
      }
      self:SpawnSlice(self.Properties.SpawnerComponent, self.ITEM_LAYOUT_SLICE, self.OnItemLayoutSpawned, data)
    end
  end
end
function ArmorDyeing:OnShutdown()
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  BaseScreen.OnShutdown(self)
end
function ArmorDyeing:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", function(self, data)
    if self.paperdollId then
      self:BusDisconnect(self.paperdollBus)
    end
    self.paperdollId = data
    self.paperdollBus = self:BusConnect(PaperdollEventBus, self.paperdollId)
    for i = 0, ePaperDollSlotTypes_Num do
      local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, i)
      self:OnPaperdollSlotUpdate(i, slot)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    if self.inventoryId then
      self:BusDisconnect(self.inventoryBus)
    end
    self.inventoryId = data
    self.inventoryBus = self:BusConnect(ContainerEventBus, self.inventoryId)
    self:PopulatePicker()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    self.playerId = data
  end)
end
function ArmorDyeing:UnregisterObservers()
  if self.paperdollId then
    self:BusDisconnect(self.paperdollBus)
  end
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId")
  if self.inventoryId then
    self:BusDisconnect(self.inventoryBus)
  end
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId")
end
function ArmorDyeing:OnSlotColorsChanged(slotId, dyeData)
  if not self.playerId then
    return
  end
  local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotId)
  if slot then
    if slotId == ePaperDollSlotTypes_OffHandOption1 then
      PaperdollRequestBus.Event.PreviewEquipmentPart(self.playerId, slotId, dyeData)
    else
      CustomizableCharacterRequestBus.Event.PreviewEquipmentPart(self.playerId, slotId, slot:GetItemId(), dyeData)
    end
  end
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
  self:RefreshConfirmEnabledState()
end
function ArmorDyeing:GetUsedDyeColors()
  local colorsUsed = {}
  for _, selectorRow in pairs(self.slotEnumToSelectorsMap) do
    local colorsUsedInRow = selectorRow:GetColorsUsed()
    for colorId, quantity in pairs(colorsUsedInRow) do
      colorsUsed[colorId] = colorsUsed[colorId] and colorsUsed[colorId] + quantity or quantity
    end
  end
  return colorsUsed
end
function ArmorDyeing:RefreshConfirmEnabledState()
  local colorsUsed = self:GetUsedDyeColors()
  local isConfirmButtonEnabled = CountAssociativeTable(colorsUsed) > 0
  self.ConfirmButton:SetEnabled(isConfirmButtonEnabled)
end
function ArmorDyeing:OnConfirm()
  local colorsUsed = self:GetUsedDyeColors()
  local slots = vector_int()
  for colorId, slotData in pairs(self.availableDyes) do
    local dyeCount = ContainerRequestBus.Event.GetItemCount(self.inventoryId, slotData.slot:GetItemDescriptor(), true, false, false)
    if colorsUsed[colorId] and dyeCount < colorsUsed[colorId] then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@dyeing_error_not_enough_dyes"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      return
    end
    slots:push_back(slotData.slotId)
  end
  local shieldChanged = self.slotEnumToSelectorsMap[ePaperDollSlotTypes_OffHandOption1]:HasChanges()
  PaperdollRequestBus.Event.StopPreview(self.playerId, ePaperDollSlotTypes_OffHandOption1, shieldChanged)
  LocalPlayerUIRequestsBus.Broadcast.PaperdollDyeItems(self.slotEnumToSelectorsMap[ePaperDollSlotTypes_Head]:GetDyeData(), self.slotEnumToSelectorsMap[ePaperDollSlotTypes_Chest]:GetDyeData(), self.slotEnumToSelectorsMap[ePaperDollSlotTypes_Hands]:GetDyeData(), self.slotEnumToSelectorsMap[ePaperDollSlotTypes_Legs]:GetDyeData(), self.slotEnumToSelectorsMap[ePaperDollSlotTypes_Feet]:GetDyeData(), self.slotEnumToSelectorsMap[ePaperDollSlotTypes_OffHandOption1]:GetDyeData(), slots)
  self.DyePicker:OnDyeConfirmed()
  LyShineManagerBus.Broadcast.ExitState(3548394217)
end
function ArmorDyeing:OnCancel()
  PaperdollRequestBus.Event.StopPreview(self.playerId, ePaperDollSlotTypes_OffHandOption1, false)
  LyShineManagerBus.Broadcast.ExitState(3548394217)
end
function ArmorDyeing:OnBlockerPress()
  self.DyePicker:SetVisible(false)
end
function ArmorDyeing:PopulatePicker()
  self.DyePicker:ResetColors()
  local colorsUsed = self:GetUsedDyeColors()
  self.availableDyes = {}
  OmniDataHandler:GetOmniOffers(self, function(self, offers)
    if self.inventoryId then
      local addedDyes = {}
      local numSlots = ContainerRequestBus.Event.GetNumSlots(self.inventoryId) or 0
      for slotId = 0, numSlots - 1 do
        local slot = ContainerRequestBus.Event.GetSlotRef(self.inventoryId, slotId)
        if slot and slot:IsValid() and slot:GetItemType() == "Dye" then
          local colorId = ItemDataManagerBus.Broadcast.GetColorIndex(slot:GetItemId())
          local numColorCurrentlyUsed = colorsUsed[colorId] and colorsUsed[colorId] or 0
          self.DyePicker:AddColor(colorId, slot:GetStackSize() - numColorCurrentlyUsed, slot:GetItemId())
          self.availableDyes[colorId] = {slotId = slotId, slot = slot}
          addedDyes[colorId] = true
        end
      end
      if self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableEntitlements") then
        local entitledDyes = LocalPlayerUIRequestsBus.Broadcast.GetEntitlementDyes()
        for i = 1, #entitledDyes do
          local colorId = entitledDyes[i]
          local numColorCurrentlyUsed = colorsUsed[colorId] and colorsUsed[colorId] or 0
          local itemIdForDye = ItemDataManagerBus.Broadcast.GetItemIdForDyeColorIndex(colorId)
          local count = OmniDataHandler:GetBalanceForRewardTypeAndKey(eRewardTypeItemDye, itemIdForDye)
          local availableOffers
          if count == 0 then
            availableOffers = OmniDataHandler:SearchOffersForRewardTypeAndKey(offers, eRewardTypeItemDye, itemIdForDye)
          end
          if availableOffers and 0 < #availableOffers or 0 < count then
            local isNew = EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeNew(eRewardTypeItemDye, itemIdForDye)
            self.DyePicker:AddColor(entitledDyes[i], count - numColorCurrentlyUsed, itemIdForDye, availableOffers, isNew)
            addedDyes[entitledDyes[i]] = true
          end
        end
      end
      for i = 1, 255 do
        if not addedDyes[i] then
          local color = ItemDataManagerBus.Broadcast.GetDyeColor(i)
          if 0 < color.r or 0 < color.g or 0 < color.b then
            local itemId = ItemDataManagerBus.Broadcast.GetItemIdForDyeColorIndex(i)
            if itemId ~= 0 then
              self.DyePicker:AddColor(i, 0, itemId, nil, false)
            end
          end
        end
      end
    end
    self.DyePicker:RefreshRecentColorDisplay()
  end)
end
function ArmorDyeing:OnSlotUpdate(localSlotId, slot, updateReason)
  self:PopulatePicker()
  self:RefreshConfirmEnabledState()
end
function ArmorDyeing:OnPaperdollSlotUpdate(localSlotId, slot, updateReason)
  if localSlotId <= ePaperDollSlotTypes_Num then
    local itemLayoutId = self.slotEnumToEntityIdMap[localSlotId]
    if not itemLayoutId then
      return
    end
    local layoutName = "Layout"
    local layoutId
    local children = UiElementBus.Event.GetChildren(itemLayoutId)
    for i = 1, #children do
      local childName = UiElementBus.Event.GetName(children[i])
      if string.match(childName, layoutName) then
        layoutId = children[i]
        break
      end
    end
    if not layoutId then
      return
    end
    local selectorRow = self.slotEnumToSelectorsMap[localSlotId]
    local layoutTable = self.registrar:GetEntityTable(itemLayoutId)
    local isSlotInvalid = not slot or not slot:IsValid()
    if isSlotInvalid then
      UiElementBus.Event.SetIsEnabled(layoutId, false)
      selectorRow:ClearColors()
      layoutTable:SetEmptyIconVisible(true)
    else
      if layoutId:IsValid() then
        UiElementBus.Event.SetIsEnabled(layoutId, true)
        self:SetItem(layoutId, slot, localSlotId)
      end
      local dyes = slot:GetDyeData()
      selectorRow:SetColors(dyes.rColorId, dyes.gColorId, dyes.bColorId, dyes.aColorId)
      local staticItemData = StaticItemDataManager:GetItem(slot:GetItemId())
      selectorRow:SetDyeSlotsEnabled(not staticItemData.rDyeSlotDisabled, not staticItemData.gDyeSlotDisabled, not staticItemData.bDyeSlotDisabled, not staticItemData.aDyeSlotDisabled)
      layoutTable:SetEmptyIconVisible(false)
    end
    selectorRow:SetIsEnabled(not isSlotInvalid)
    self:RefreshConfirmEnabledState()
  end
end
function ArmorDyeing:SetItem(itemEntityId, itemSlot, slotIndex)
  local itemLayout = self.registrar:GetEntityTable(itemEntityId)
  itemLayout:SetModeType(itemLayout.MODE_TYPE_EQUIPPED)
  itemLayout:SetItemAndSlotProvider(itemSlot, slotIndex, function()
    local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotIndex)
    return slot
  end)
end
function ArmorDyeing:OnItemLayoutSpawned(itemLayout, data)
  if itemLayout then
    UiElementBus.Event.Reparent(itemLayout.entityId, data.parentId, EntityId())
    if self.paperdollId and not data.item then
      data.item = PaperdollRequestBus.Event.GetSlot(self.paperdollId, data.slotIndex)
    end
    if data.item and data.item:IsValid() then
      self:SetItem(itemLayout.entityId, data.item, data.slotIndex)
    else
      UiElementBus.Event.SetIsEnabled(itemLayout.entityId, false)
    end
  end
end
function ArmorDyeing:OnAction(entityId, actionName)
  BaseScreen.OnAction(self, entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function ArmorDyeing:OnCameraPressed(entityId)
  UiInteractableBus.Event.SetStayActiveAfterRelease(entityId, true)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", true)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
end
function ArmorDyeing:OnCameraReleased(entityId)
  UiInteractableBus.Event.SetStayActiveAfterRelease(entityId, false)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", false)
end
function ArmorDyeing:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  DynamicBus.Inventory.Broadcast.HideItemDyeingPopup()
  DynamicBus.CatContainer.Broadcast.SetScreenVisible(false)
  self:RegisterObservers()
  CustomizableCharacterRequestBus.Event.StartPreview(self.playerId)
  for slotId = ePaperDollSlotTypes_Head, ePaperDollSlotTypes_Feet do
    local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotId)
    if slot then
      CustomizableCharacterRequestBus.Event.PreviewEquipmentPart(self.playerId, slotId, slot:GetItemId(), slot:GetDyeData())
    end
  end
  PaperdollRequestBus.Event.StartPreview(self.playerId, ePaperDollSlotTypes_OffHandOption1)
  DynamicBus.Inventory.Broadcast.SetScreenVisible(false, true)
  self.ConfirmButton:SetEnabled(false)
  self:RefreshConfirmEnabledState()
  self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {y = 24}, tweenerCommon.yTo0)
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_ArmorDyeing", 0.5)
end
function ArmorDyeing:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self.DyePicker:ResetColors()
  self.DyePicker:SetVisible(false)
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  self:UnregisterObservers()
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", false)
  DynamicBus.CatContainer.Broadcast.SetScreenVisible(true)
  CustomizableCharacterRequestBus.Event.StopPreview(self.playerId)
  if toState == 2972535350 then
    DynamicBus.Inventory.Broadcast.SetScreenVisible(true, true)
  end
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.5)
end
function ArmorDyeing:OnEscapeKeyPressed()
  self:OnCancel()
end
return ArmorDyeing

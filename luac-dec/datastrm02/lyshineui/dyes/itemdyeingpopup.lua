local ItemDyeingPopup = {
  Properties = {
    PrimarySelector = {
      default = EntityId(),
      order = 1
    },
    SecondarySelector = {
      default = EntityId(),
      order = 2
    },
    AccentSelector = {
      default = EntityId(),
      order = 3
    },
    TintSelector = {
      default = EntityId(),
      order = 4
    },
    ConfirmButton = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    DyePicker = {
      default = EntityId()
    }
  },
  selectorList = {},
  availableDyes = {}
}
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ItemDyeingPopup)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function ItemDyeingPopup:OnInit()
  BaseElement.OnInit(self)
  self.dyeData = DyeData()
  self.ConfirmButton:SetCallback(self.OnConfirm, self)
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
  self.ConfirmButton:SetText("@ui_confirm")
  self.CancelButton:SetCallback(self.OnCancel, self)
  self.CancelButton:SetText("@ui_cancel")
  table.insert(self.selectorList, self.PrimarySelector)
  table.insert(self.selectorList, self.SecondarySelector)
  table.insert(self.selectorList, self.AccentSelector)
  table.insert(self.selectorList, self.TintSelector)
  for i = 1, #self.selectorList do
    self.selectorList[i]:SetPicker(self.DyePicker)
    self.selectorList[i]:SetCallback(self, self.OnColorChanged)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", function(self, paperdollId)
    if not paperdollId then
      return
    end
    self.paperdollId = paperdollId
  end)
  self.DyePicker:SetOpenCallback(self, function()
    self:PopulatePicker()
  end)
end
function ItemDyeingPopup:SetSlot(slotId, forceUpdate)
  if self.slotId == tonumber(slotId) and not forceUpdate then
    return
  end
  self.slotId = tonumber(slotId)
  if self:IsEnabled() then
    for slotId = ePaperDollSlotTypes_Head, ePaperDollSlotTypes_Feet do
      if slotId ~= self.slotId then
        local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotId)
        if slot then
          CustomizableCharacterRequestBus.Event.PreviewEquipmentPart(self.playerId, slotId, slot:GetItemId(), slot:GetDyeData())
        end
      end
    end
  end
  local slot = ContainerRequestBus.Event.GetSlot(self.inventoryId, self.slotId)
  if slot:IsValid() then
    self.dyeData = slot:GetDyeData()
    self:SetColors(self.dyeData.rColorId, self.dyeData.gColorId, self.dyeData.bColorId, self.dyeData.aColorId)
    local staticItemData = StaticItemDataManager:GetItem(slot:GetItemId())
    self:SetDyeSlotsEnabled(not staticItemData.rDyeSlotDisabled, not staticItemData.gDyeSlotDisabled, not staticItemData.bDyeSlotDisabled, not staticItemData.aDyeSlotDisabled)
    local paperdollSlotId = self:GetPaperdollSlotFromItemSlot(slot)
    if paperdollSlotId == ePaperDollSlotTypes_OffHandOption1 then
      PaperdollRequestBus.Event.StartPreviewFromInventory(self.playerId, ePaperDollSlotTypes_OffHandOption1, self.slotId)
    else
      if paperdollSlotId == ePaperDollSlotTypes_Hands then
        local itemSlot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, ePaperDollSlotTypes_Chest)
        if itemSlot and itemSlot:IsValid() then
          CustomizableCharacterRequestBus.Event.PreviewEquipmentPart(self.playerId, ePaperDollSlotTypes_Chest, itemSlot:GetItemId(), itemSlot:GetDyeData())
        end
      end
      if self:IsEnabled() then
        CustomizableCharacterRequestBus.Event.PreviewEquipmentPart(self.playerId, paperdollSlotId, slot:GetItemId(), self.dyeData)
      end
    end
  else
    Debug.Log("Warning: ItemDyeingPopup:SetSlot - trying to dye item with invalid slot")
  end
end
function ItemDyeingPopup:OnSlotUpdate(localSlotId, slot, updateReason)
  if localSlotId == self.slotId then
    if not slot or not slot:IsValid() then
      self:OnCancel()
      return
    end
    self:PopulatePicker()
  end
end
function ItemDyeingPopup:GetPaperdollSlotFromItemSlot(slot)
  local paperdollSlotId
  if slot:HasItemClass(eItemClass_EquippableHead) then
    paperdollSlotId = ePaperDollSlotTypes_Head
  elseif slot:HasItemClass(eItemClass_EquippableChest) then
    paperdollSlotId = ePaperDollSlotTypes_Chest
  elseif slot:HasItemClass(eItemClass_EquippableHands) then
    paperdollSlotId = ePaperDollSlotTypes_Hands
  elseif slot:HasItemClass(eItemClass_EquippableLegs) then
    paperdollSlotId = ePaperDollSlotTypes_Legs
  elseif slot:HasItemClass(eItemClass_EquippableFeet) then
    paperdollSlotId = ePaperDollSlotTypes_Feet
  elseif slot:HasItemClass(eItemClass_Shield) then
    paperdollSlotId = ePaperDollSlotTypes_OffHandOption1
  end
  return paperdollSlotId
end
function ItemDyeingPopup:OnColorChanged()
  local slot = ContainerRequestBus.Event.GetSlot(self.inventoryId, self.slotId)
  if slot:IsValid() then
    local paperdollSlotId = self:GetPaperdollSlotFromItemSlot(slot)
    if paperdollSlotId then
      if paperdollSlotId == ePaperDollSlotTypes_OffHandOption1 then
        PaperdollRequestBus.Event.PreviewEquipmentPart(self.playerId, paperdollSlotId, self:GetDyeData())
      else
        CustomizableCharacterRequestBus.Event.PreviewEquipmentPart(self.playerId, paperdollSlotId, slot:GetItemId(), self:GetDyeData())
      end
    else
      Debug.Log("Warning: ItemDyeingPopup:OnColorChanged - slot isn't an equipable piece of clothing/armor")
    end
    self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
    self.ConfirmButton:SetEnabled(true)
  end
end
function ItemDyeingPopup:GetDyeData()
  self.dyeData.rColorId = self.PrimarySelector:GetColor()
  self.dyeData.gColorId = self.SecondarySelector:GetColor()
  self.dyeData.bColorId = self.AccentSelector:GetColor()
  self.dyeData.aColorId = self.TintSelector:GetColor()
  return self.dyeData
end
function ItemDyeingPopup:GetColorsUsed()
  local dyesUsed = {}
  for i = 1, #self.selectorList do
    local selector = self.selectorList[i]
    local colorId = selector:GetColor()
    if colorId ~= selector:GetInitialColor() then
      dyesUsed[colorId] = dyesUsed[colorId] and dyesUsed[colorId] + 1 or 1
    end
  end
  return dyesUsed
end
function ItemDyeingPopup:SetColors(primary, secondary, accent, tint)
  self.PrimarySelector:SetInitialColor(primary)
  self.SecondarySelector:SetInitialColor(secondary)
  self.AccentSelector:SetInitialColor(accent)
  self.TintSelector:SetInitialColor(tint)
  self.ConfirmButton:SetEnabled(false)
end
function ItemDyeingPopup:SetDyeSlotsEnabled(primary, secondary, accent, tint)
  UiElementBus.Event.SetIsEnabled(self.Properties.PrimarySelector, primary)
  UiElementBus.Event.SetIsEnabled(self.Properties.SecondarySelector, secondary)
  UiElementBus.Event.SetIsEnabled(self.Properties.AccentSelector, accent)
  UiElementBus.Event.SetIsEnabled(self.Properties.TintSelector, tint)
end
function ItemDyeingPopup:ClearColors()
  self.dyeData.rColorId = 0
  self.dyeData.gColorId = 0
  self.dyeData.bColorId = 0
  self.dyeData.aColorId = 0
  for i = 1, #self.selectorList do
    self.selectorList[i]:SetInitialColor(0)
  end
end
function ItemDyeingPopup:IsEnabled()
  return UiElementBus.Event.IsEnabled(self.entityId)
end
function ItemDyeingPopup:SetIsEnabled(isEnabled)
  if self:IsEnabled() == isEnabled then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
  if isEnabled then
    self.inventoryBus = self:BusConnect(ContainerEventBus, self.inventoryId)
    self:PopulatePicker()
    CustomizableCharacterRequestBus.Event.StartPreview(self.playerId)
    DynamicBus.Inventory.Broadcast.DoCameraTransition(false)
    DynamicBus.EquipmentBus.Broadcast.SetScreenVisible(false)
    DynamicBus.Inventory.Broadcast.SetScreenVisible(false, true)
  else
    if self.inventoryBus then
      self:BusDisconnect(self.inventoryBus)
      self.inventoryBus = nil
    end
    self.slotId = nil
    CustomizableCharacterRequestBus.Event.StopPreview(self.playerId)
    PaperdollRequestBus.Event.StopPreview(self.playerId, ePaperDollSlotTypes_OffHandOption1, false)
    JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.5)
    DynamicBus.Inventory.Broadcast.DoCameraTransition(true)
    DynamicBus.Inventory.Broadcast.SetScreenVisible(true, true)
    DynamicBus.EquipmentBus.Broadcast.SetScreenVisible(true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DyePicker, false)
  end
end
function ItemDyeingPopup:PopulatePicker()
  self.DyePicker:ResetColors()
  self.availableDyes = {}
  OmniDataHandler:GetOmniOffers(self, function(self, offers)
    if self.inventoryId then
      local addedDyes = {}
      local numSlots = ContainerRequestBus.Event.GetNumSlots(self.inventoryId) or 0
      for slotId = 0, numSlots - 1 do
        local slot = ContainerRequestBus.Event.GetSlotRef(self.inventoryId, slotId)
        if slot and slot:IsValid() and slot:GetItemType() == "Dye" then
          local colorId = ItemDataManagerBus.Broadcast.GetColorIndex(slot:GetItemId())
          self.DyePicker:AddColor(colorId, slot:GetStackSize(), slot:GetItemId())
          self.availableDyes[colorId] = {slotId = slotId, slot = slot}
          addedDyes[colorId] = true
        end
      end
      if self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableEntitlements") then
        local entitledDyes = LocalPlayerUIRequestsBus.Broadcast.GetEntitlementDyes()
        for i = 1, #entitledDyes do
          local colorId = entitledDyes[i]
          local itemIdForDye = ItemDataManagerBus.Broadcast.GetItemIdForDyeColorIndex(colorId)
          local count = OmniDataHandler:GetBalanceForRewardTypeAndKey(eRewardTypeItemDye, itemIdForDye)
          local availableOffers
          if count == 0 then
            availableOffers = OmniDataHandler:SearchOffersForRewardTypeAndKey(offers, eRewardTypeItemDye, itemIdForDye)
          end
          if availableOffers and 0 < #availableOffers or 0 < count then
            local isNew = EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeNew(eRewardTypeItemDye, itemIdForDye)
            self.DyePicker:AddColor(entitledDyes[i], count, itemIdForDye, availableOffers, isNew)
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
function ItemDyeingPopup:OnConfirm()
  local colorsUsed = {}
  local colorsUsedInRow = self:GetColorsUsed()
  for colorId, quantity in pairs(colorsUsedInRow) do
    colorsUsed[colorId] = colorsUsed[colorId] and colorsUsed[colorId] + quantity or quantity
  end
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
  LocalPlayerUIRequestsBus.Broadcast.InventoryDyeItem(self.slotId, self:GetDyeData(), slots)
  DynamicBus.CatContainer.Broadcast.SetScreenVisible(true)
  self:SetIsEnabled(false)
  DynamicBus.Inventory.Broadcast.HideItemDyeingPopup()
end
function ItemDyeingPopup:OnCancel()
  DynamicBus.CatContainer.Broadcast.SetScreenVisible(true)
  self:SetIsEnabled(false)
  DynamicBus.Inventory.Broadcast.HideItemDyeingPopup()
end
return ItemDyeingPopup

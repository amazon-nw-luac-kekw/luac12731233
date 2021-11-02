local GemSelector = {
  Properties = {
    FrameHeader = {
      default = EntityId()
    },
    GemGrid = {
      default = EntityId()
    },
    CurrentGemContainer = {
      default = EntityId()
    },
    CurrentGemIcon = {
      default = EntityId()
    },
    CurrentGemName = {
      default = EntityId()
    },
    CurrentGemDescription = {
      default = EntityId()
    },
    SelectedGemIcon = {
      default = EntityId()
    },
    SelectedGemName = {
      default = EntityId()
    },
    SelectedGemDescription = {
      default = EntityId()
    },
    AcceptButton = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    GemListItemPrototype = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(GemSelector)
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local CanvasCommon = RequireScript("LyShineUI._Common.CanvasCommon")
function GemSelector:OnInit()
  BaseElement:OnInit(self)
  self.GemGrid:Initialize(self.GemListItemPrototype, nil)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, inventoryEntityId)
    self.inventoryEntityId = inventoryEntityId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.AcceptButton:SetButtonStyle(self.AcceptButton.BUTTON_STYLE_CTA)
  self.CancelButton:SetText("@ui_cancel")
end
function GemSelector:ShowGemSelector(positionVector, selectorData)
  if self.isShowing then
    return
  end
  self.isShowing = true
  self.itemSlotId = selectorData.itemSlotId
  self.containerType = eItemContainerType_Container
  if selectorData.itemIsInPaperdoll then
    self.containerType = eItemContainerType_Paperdoll
  end
  self.gems = {}
  for i = 1, #selectorData.validGemItemSlotIds do
    local gemSlotId = selectorData.validGemItemSlotIds[i]
    local gemData = self:GetGemDataForSlotId(gemSlotId)
    if gemData then
      table.insert(self.gems, {
        iconPath = self:GetGemIconPath(gemData),
        data = gemSlotId,
        isSelected = false,
        selectedCallback = self.OnGemSelected,
        hoverStartCallback = self.OnGemHoverStart,
        hoverEndCallback = self.OnGemHoverEnd,
        selectedCallbackTable = self
      })
    end
  end
  self.GemGrid:OnListDataSet(self.gems, nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectedGemIcon, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectedGemName, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectedGemDescription, false)
  self.hasGemInSlot = selectorData.itemGemPerkId ~= ItemCommon.EMPTY_GEM_SLOT_PERK_ID
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrentGemContainer, self.hasGemInSlot)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.hasGemInSlot and 696 or 540)
  if self.hasGemInSlot then
    local currentGemData = ItemDataManagerBus.Broadcast.GetStaticPerkData(selectorData.itemGemPerkId)
    if currentGemData then
      UiImageBus.Event.SetSpritePathname(self.Properties.CurrentGemIcon, self:GetGemIconPath(currentGemData))
      UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentGemName, currentGemData.displayName, eUiTextSet_SetLocalized)
      local localizedDescription = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(currentGemData.description)
      UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentGemDescription, localizedDescription, eUiTextSet_SetAsIs)
    end
  end
  PositionEntityOnScreen(self.entityId, positionVector, {
    left = 12,
    right = 12,
    top = 50,
    bottom = 12
  })
  self.confirmCallback = selectorData.confirmCallback
  self.confirmCallbackTable = selectorData.confirmCallbackTable
  self.AcceptButton:SetCallback(self.OnAcceptPress, self)
  self.AcceptButton:SetEnabled(false)
  self.AcceptButton:SetText(self.hasGemInSlot and "@ui_replace_gem" or "@ui_attach_gem")
  self.FrameHeader:SetText(self.hasGemInSlot and "@ui_replace_gem" or "@ui_attach_gem")
  self.CancelButton:SetCallback(self.HideGemSelector, self)
  self.ButtonClose:SetCallback(self.HideGemSelector, self)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
end
function GemSelector:HideGemSelector()
  if not self.isShowing then
    return
  end
  self.isShowing = false
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
end
function GemSelector:GetGemDataForSlotId(slotId)
  local itemSlotToGem
  if self.containerType == eItemContainerType_Paperdoll then
    itemSlotToGem = PaperdollRequestBus.Event.GetSlot(self.inventoryEntityId, self.itemSlotId)
  else
    itemSlotToGem = ContainerRequestBus.Event.GetSlot(self.inventoryEntityId, self.itemSlotId)
  end
  local gemSlot = ContainerRequestBus.Event.GetSlot(self.inventoryEntityId, slotId)
  if gemSlot:IsValid() then
    local gemPerk = gemSlot:GetResourceGemPerkForItem(itemSlotToGem:GetItemId())
    if gemPerk ~= 0 then
      return ItemDataManagerBus.Broadcast.GetStaticPerkData(gemPerk)
    end
  end
  return nil
end
function GemSelector:OnGemHoverStart(selectedEntityTable)
  local gemSlot = ContainerRequestBus.Event.GetSlot(self.inventoryEntityId, selectedEntityTable.data)
  if gemSlot:IsValid() then
    local descriptor = ItemDescriptor()
    descriptor.itemId = gemSlot:GetItemId()
    local tdi = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil)
    DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(tdi, self)
  end
end
function GemSelector:OnGemHoverEnd()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
function GemSelector:GetGemIconPath(gemData)
  return "lyshineui/images/" .. gemData.iconPath .. ".dds"
end
function GemSelector:OnGemSelected(selectedEntityTable)
  self.selectedGemSlotId = selectedEntityTable.data
  local selectedGemData = self:GetGemDataForSlotId(self.selectedGemSlotId)
  if selectedGemData then
    self.selectedGemName = selectedGemData.displayName
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedGemIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedGemName, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedGemDescription, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.SelectedGemIcon, self:GetGemIconPath(selectedGemData))
    UiTextBus.Event.SetTextWithFlags(self.Properties.SelectedGemName, selectedGemData.displayName, eUiTextSet_SetLocalized)
    local localizedDescription = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(selectedGemData.description)
    UiTextBus.Event.SetTextWithFlags(self.Properties.SelectedGemDescription, localizedDescription, eUiTextSet_SetAsIs)
    self.AcceptButton:SetEnabled(true)
  end
  for i = 1, #self.gems do
    local gemData = self.gems[i]
    gemData.isSelected = gemData.data == self.selectedGemSlotId
  end
  self.GemGrid:RequestRefreshContent()
end
function GemSelector:OnAcceptPress()
  local itemName = ""
  local itemInstanceId
  if self.containerType == eItemContainerType_Paperdoll then
    local itemSlot = PaperdollRequestBus.Event.GetSlot(self.inventoryEntityId, self.itemSlotId)
    if itemSlot:IsValid() then
      itemName = ItemDataManagerBus.Broadcast.GetDisplayName(itemSlot:GetItemId())
      itemInstanceId = itemSlot:GetItemInstanceId()
    end
  else
    local itemSlot = ContainerRequestBus.Event.GetSlot(self.inventoryEntityId, self.itemSlotId)
    if itemSlot:IsValid() then
      itemName = ItemDataManagerBus.Broadcast.GetDisplayName(itemSlot:GetItemId())
      itemInstanceId = itemSlot:GetItemInstanceId()
    end
  end
  local gemInstanceId
  local gemSlot = ContainerRequestBus.Event.GetSlot(self.inventoryEntityId, self.selectedGemSlotId)
  if gemSlot:IsValid() then
    gemInstanceId = gemSlot:GetItemInstanceId()
  end
  if itemInstanceId and gemInstanceId then
    do
      local titleText = self.hasGemInSlot and "@ui_replace_gem" or "@ui_attach_gem"
      local messageText = self.hasGemInSlot and "@ui_replace_gem_confirmation_message" or "@ui_attach_gem_confirmation_message"
      local popupCanvasId = UiCanvasManagerBus.Broadcast.FindLoadedCanvasByPathName("LyShineUI/popup/popup.uicanvas")
      local draworder = UiCanvasBus.Event.GetDrawOrder(popupCanvasId)
      UiCanvasBus.Event.SetDrawOrder(popupCanvasId, CanvasCommon.TOP_LEVEL_DRAW_ORDER + 1)
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, titleText, messageText, "attachGemToItem", self, function(self, result, eventId)
        if result == ePopupResult_Yes then
          local itemLocation = ItemLocation()
          itemLocation.containerSlotId = self.itemSlotId
          itemLocation.containerType = self.containerType
          itemLocation.itemInstanceId = itemInstanceId
          local gemLocation = ItemLocation()
          gemLocation.containerSlotId = self.selectedGemSlotId
          gemLocation.containerType = eItemContainerType_Container
          gemLocation.itemInstanceId = gemInstanceId
          ItemRepairRequestBus.Event.RequestSlotItemWithGem(self.playerEntityId, itemLocation, gemLocation)
          local message = GetLocalizedReplacementText("@ui_gem_added_notification", {
            gemPerkName = self.selectedGemName,
            itemName = itemName
          })
          local notificationData = NotificationData()
          notificationData.type = "Minor"
          notificationData.text = message
          UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
          if self.confirmCallback then
            self.confirmCallback(self.confirmCallbackTable)
          end
          self:HideGemSelector()
        end
        UiCanvasBus.Event.SetDrawOrder(popupCanvasId, draworder)
      end)
    end
  end
end
return GemSelector

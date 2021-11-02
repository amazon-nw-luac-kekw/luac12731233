local EquipmentItemDropTarget = {
  Properties = {
    HighlightElement = {
      default = EntityId()
    },
    EmptyIcon = {
      default = EntityId()
    },
    LockIcon = {
      default = EntityId()
    },
    LockText = {
      default = EntityId()
    },
    IsCompatibleWithShieldIcon = {
      default = EntityId()
    },
    NotCompatibleIcon = {
      default = EntityId()
    },
    EquipmentUniversalDropTarget = {
      default = EntityId()
    }
  },
  isLocked = false,
  compatibleIconPathRoot = "lyShineui/images/icons/items/weapon/",
  compatibleIconPath = nil,
  emptyTooltipText = "",
  lockText = ""
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(EquipmentItemDropTarget)
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
function EquipmentItemDropTarget:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiDropTargetNotificationBus, self.entityId)
  self.commonFunctions = RequireScript("LyShineUI.CommonDragDrop")
  if not self.Properties.EquipmentUniversalDropTarget:IsValid() then
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    local entityId = UiCanvasBus.Event.FindElementByName(canvasId, "UniversalDropTarget")
    self.EquipmentUniversalDropTarget = self.registrar:GetEntityTable(entityId)
  end
  self.dataLayer:RegisterObserver(self, "Hud.LocalPlayer.Paperdoll.EquipmentSlotsToHighlight", function(self, dataNode)
    local shouldHighlight = false
    if dataNode then
      local equipmentSlots = dataNode:GetData()
      local slotName = UiElementBus.Event.GetName(self.entityId)
      for i = 1, #equipmentSlots do
        if equipmentSlots[i] == slotName then
          shouldHighlight = true
          break
        end
      end
    end
    local highlightColor = self.isLocked and self.UIStyle.COLOR_RED_MEDIUM or self.UIStyle.COLOR_WHITE
    UiImageBus.Event.SetColor(self.Properties.HighlightElement, highlightColor)
    UiElementBus.Event.SetIsEnabled(self.Properties.HighlightElement, shouldHighlight)
    if shouldHighlight then
      local parentId = UiElementBus.Event.GetParent(self.entityId)
      UiElementBus.Event.Reparent(self.entityId, parentId, EntityId())
    end
  end)
  self.dataLayer:RegisterObserver(self, "Hud.LocalPlayer.Paperdoll.ClearHighlight", function(self, dataNode)
    UiElementBus.Event.SetIsEnabled(self.Properties.HighlightElement, false)
  end, true)
  self.checkShield = self.Properties.IsCompatibleWithShieldIcon:IsValid()
  UiElementBus.Event.SetIsEnabled(self.Properties.HighlightElement, false)
  if not self.Properties.LockIcon:IsValid() then
    self.Properties.LockIcon = UiElementBus.Event.FindDescendantByName(self.entityId, "LockIcon")
    self.Properties.LockText = UiElementBus.Event.FindDescendantByName(self.entityId, "LockText")
    UiElementBus.Event.SetIsEnabled(self.Properties.LockIcon, false)
  end
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Abilities.OnDataUpdate", function(self, onUpdate)
    if self.slotId then
      local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
      self:SetItemSlot(PaperdollRequestBus.Event.GetSlot(paperdollId, self.slotId), self.slotId)
    end
  end)
  if self.Properties.EmptyIcon:IsValid() and type(self.EmptyIcon) == "table" then
    self.EmptyIcon:SetShouldCloseOpenTooltip(true)
  end
  self.rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  self.cooldownEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.CooldownTimersEntityId")
end
function EquipmentItemDropTarget:OnShutdown()
  self.commonFunctions = nil
  self.dataLayer = nil
end
function EquipmentItemDropTarget:GetDraggableId()
  return self.draggableId
end
function EquipmentItemDropTarget:OnDropHoverStart(draggable)
  self.commonFunctions:OnDropHoverStart(self.entityId, draggable)
  self.EquipmentUniversalDropTarget:OnDropHoverStart(draggable)
end
function EquipmentItemDropTarget:OnDropHoverEnd(draggable)
  self.commonFunctions:OnDropHoverEnd(self.entityId, draggable)
end
function EquipmentItemDropTarget:OnDrop(draggable)
  if self.commonFunctions:IsValidDrop(draggable) then
    local draggableData = self.commonFunctions:GetDraggableData()
    if draggableData then
      local containerType = draggableData.containerType
      local sourceSlotId = draggableData.sourceSlotId
      local sourceContainerId = draggableData.sourceContainerId
      local stackSize = draggableData.stackSize
      local toSlotName = UiElementBus.Event.GetName(self.entityId)
      if containerType == eItemDragContext_Inventory or containerType == eItemDragContext_Container then
        EquipmentCommon:EquipItem(sourceSlotId, toSlotName, stackSize, sourceContainerId)
      elseif containerType == eItemDragContext_Paperdoll then
        LocalPlayerUIRequestsBus.Broadcast.PaperdollSwapItems(sourceSlotId, toSlotName, stackSize)
      end
    end
  end
end
function EquipmentItemDropTarget:SetEmptyIconVisible(isVisible)
  if isVisible ~= nil then
    UiElementBus.Event.SetIsEnabled(self.Properties.EmptyIcon, isVisible)
  end
end
function EquipmentItemDropTarget:GetDraggableInsertBeforeEntityId()
  return self.Properties.LockIcon
end
function EquipmentItemDropTarget:SetLockIconVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.LockIcon, isVisible)
end
function EquipmentItemDropTarget:SetEmptyTooltip(tooltipText)
  self.emptyTooltipText = tooltipText
  self:UpdateTooltipText()
end
function EquipmentItemDropTarget:UpdateTooltipText()
  local tooltipText = self.emptyTooltipText
  if self.lockText and self.lockText ~= "" then
    if string.len(tooltipText) > 0 then
      tooltipText = tooltipText .. [[


]]
    end
    tooltipText = tooltipText .. self.lockText
  end
  self.EmptyIcon:SetSimpleTooltip(tooltipText)
end
function EquipmentItemDropTarget:SetLockText(unlockLevel, fullText)
  local lockText = GetLocalizedReplacementText(fullText and "@ui_slot_unlock_at" or "@ui_slot_unlock_at_abbr", {level = unlockLevel})
  if not fullText then
    self.lockText = GetLocalizedReplacementText("@ui_slot_unlock_at", {level = unlockLevel})
  else
    self.lockText = lockText
  end
  UiTextBus.Event.SetText(self.Properties.LockText, lockText)
  self:UpdateTooltipText()
end
function EquipmentItemDropTarget:SetIsLocked(value)
  self.isLocked = value
end
function EquipmentItemDropTarget:GetIsLocked()
  return self.isLocked
end
function EquipmentItemDropTarget:SetItemSlot(itemSlot, slotId)
  if not self.hasAbilities then
    return
  end
  self.slotId = slotId
  if itemSlot and itemSlot:IsValid() and self.checkShield then
    local itemSupportsShield = itemCommon:DoesItemSupportShieldOffhand(itemSlot:GetItemName())
    UiElementBus.Event.SetIsEnabled(self.Properties.IsCompatibleWithShieldIcon, itemSupportsShield)
    if self.compatibleIconPath then
      UiElementBus.Event.SetIsEnabled(self.Properties.IsCompatibleWithShieldIcon, true)
      UiImageBus.Event.SetSpritePathname(self.Properties.IsCompatibleWithShieldIcon, self.compatibleIconPath)
      if itemSupportsShield then
        UiFaderBus.Event.SetFadeValue(self.Properties.IsCompatibleWithShieldIcon, 1)
        UiElementBus.Event.SetIsEnabled(self.Properties.NotCompatibleIcon, false)
      else
        UiFaderBus.Event.SetFadeValue(self.Properties.IsCompatibleWithShieldIcon, 0.5)
        UiElementBus.Event.SetIsEnabled(self.Properties.NotCompatibleIcon, true)
      end
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.IsCompatibleWithShieldIcon, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.NotCompatibleIcon, false)
    end
  end
end
function EquipmentItemDropTarget:SetCompatibleIconPath(value)
  if value then
    self.compatibleIconPath = self.compatibleIconPathRoot .. value .. ".dds"
  else
    self.compatibleIconPath = nil
  end
end
function EquipmentItemDropTarget:SetCompatibleIconVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.IsCompatibleWithShieldIcon, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.NotCompatibleIcon, isVisible)
end
function EquipmentItemDropTarget:SetAbilityClickedCallback(callbackSelf, callbackFn)
  self.onAbilityClickedCallbackSelf = callbackSelf
  self.onAbilityClickedCallbackFn = callbackFn
end
return EquipmentItemDropTarget

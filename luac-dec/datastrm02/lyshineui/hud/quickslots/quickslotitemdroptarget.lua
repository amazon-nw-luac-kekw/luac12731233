local QuickslotItemDropTarget = {
  Properties = {
    SheathedElement = {
      default = EntityId()
    },
    SlotNameToHighlightFor = {default = ""},
    AbilityCooldowns = {
      default = EntityId()
    },
    LockIcon = {
      default = EntityId()
    },
    LockText = {
      default = EntityId()
    },
    ItemBg = {
      default = EntityId()
    },
    LineTop1 = {
      default = EntityId()
    },
    LineTop2 = {
      default = EntityId()
    },
    LineLeft = {
      default = EntityId()
    },
    LineBottom = {
      default = EntityId()
    },
    LineRight = {
      default = EntityId()
    },
    Cover = {
      default = EntityId()
    }
  }
}
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(QuickslotItemDropTarget)
function QuickslotItemDropTarget:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiDropTargetNotificationBus, self.entityId)
  self.commonFunctions = RequireScript("LyShineUI.CommonDragDrop")
  self.hasAbilityCooldowns = self.Properties.AbilityCooldowns:IsValid()
  if not self.Properties.LockIcon:IsValid() then
    self.Properties.LockIcon = UiElementBus.Event.FindDescendantByName(self.entityId, "LockIcon")
    self.Properties.LockText = UiElementBus.Event.FindDescendantByName(self.entityId, "LockText")
    UiElementBus.Event.SetIsEnabled(self.Properties.LockIcon, false)
    UiFaderBus.Event.SetFadeValue(self.entityId, 1)
  end
end
function QuickslotItemDropTarget:OnShutdown()
  self.commonFunctions = nil
  self.dataLayer = nil
end
function QuickslotItemDropTarget:OnDropHoverStart(draggable)
  self.commonFunctions:OnDropHoverStart(self.entityId, draggable)
end
function QuickslotItemDropTarget:OnDropHoverEnd(draggable)
  self.commonFunctions:OnDropHoverEnd(self.entityId, draggable)
end
function QuickslotItemDropTarget:OnDrop(draggable)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Paperdoll.ClearHighlight", true)
  local isInInventoryState = LyShineManagerBus.Broadcast.IsInState(2972535350)
  local isInContainerState = LyShineManagerBus.Broadcast.IsInState(3349343259)
  local isInGeneratorState = LyShineManagerBus.Broadcast.IsInState(1809891471)
  if (isInInventoryState or isInContainerState or isInGeneratorState) and self.commonFunctions:IsValidDrop(draggable) then
    local draggableData = self.commonFunctions:GetDraggableData()
    if draggableData then
      local containerType = draggableData.containerType
      local sourceSlotId = draggableData.sourceSlotId
      local sourceContainerId = draggableData.sourceContainerId
      local stackSize = draggableData.stackSize
      local toSlotName = UiElementBus.Event.GetName(self.entityId)
      if containerType == eItemDragContext_Inventory or containerType == eItemDragContext_Container then
        local targetItem = ContainerRequestBus.Event.GetSlot(sourceContainerId, sourceSlotId)
        if targetItem ~= nil then
          local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
          local canEquipItem = targetItem:CanEquipItem(rootEntityId)
          if canEquipItem then
            local isValidEquipSlot = false
            local equipSlots = targetItem:GetEquipSlots()
            for i = 1, #equipSlots do
              local equipSlot = equipSlots[i]
              if equipSlot == toSlotName then
                isValidEquipSlot = true
                break
              end
            end
            canEquipItem = isValidEquipSlot
          end
          local meetsWeaponRequirements
          if targetItem:GetItemType() == "Weapon" then
            meetsWeaponRequirements = LocalPlayerUIRequestsBus.Broadcast.MeetsWeaponRequirements(targetItem)
          else
            meetsWeaponRequirements = true
          end
          if canEquipItem and meetsWeaponRequirements then
            EquipmentCommon:EquipItem(sourceSlotId, toSlotName, stackSize, sourceContainerId, true)
          elseif not meetsWeaponRequirements then
            local notificationData = NotificationData()
            notificationData.type = "Minor"
            notificationData.text = "@inv_does_not_meet_weapon_requirements"
            UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
          end
        end
      elseif containerType == eItemDragContext_Paperdoll then
        LocalPlayerUIRequestsBus.Broadcast.PaperdollSwapItems(sourceSlotId, toSlotName, stackSize)
      end
    end
  end
end
local sheathAnim = {
  delay = 0.5,
  opacity = 1,
  ease = "QuadOut"
}
function QuickslotItemDropTarget:SetIsSheathedHintVisible(isSheathed)
  self.ScriptedEntityTweener:Stop(self.Properties.SheathedElement)
  sheathAnim.opacity = isSheathed and 1 or 0
  self.ScriptedEntityTweener:Play(self.Properties.SheathedElement, 0.2, sheathAnim)
end
function QuickslotItemDropTarget:SetSlot(paperdollSlotId, itemSlot)
  if self.hasAbilityCooldowns then
    self.AbilityCooldowns:SetAbilitiesForItem(paperdollSlotId, itemSlot)
  end
end
function QuickslotItemDropTarget:SetAbilitiesActive(isActive)
  if isActive then
    self:SetAbilitiesDimmed(false)
    self:SetHintVisible(true)
    self:SetAbilitiesSmaller(false)
  else
    self:SetAbilitiesDimmed(true)
    self:SetHintVisible(false)
    self:SetAbilitiesSmaller(true)
  end
  self.AbilityCooldowns:SetAbilitiesActive(isActive)
end
function QuickslotItemDropTarget:MoveDownAbilities(moveDown)
  if moveDown then
    self.ScriptedEntityTweener:PlayC(self.Properties.AbilityCooldowns, 0.2, tweenerCommon.abilityHolderDown)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.AbilityCooldowns, 0.2, tweenerCommon.abilityHolderUp)
  end
end
function QuickslotItemDropTarget:SetAbilitiesVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:PlayC(self.Properties.AbilityCooldowns, 0.15, tweenerCommon.fadeInQuadOut)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.AbilityCooldowns, 0.15, tweenerCommon.fadeOutQuadOut)
  end
end
function QuickslotItemDropTarget:SetAbilitiesDimmed(isDimmed)
  if isDimmed then
    self.ScriptedEntityTweener:PlayC(self.Properties.AbilityCooldowns, 0.2, tweenerCommon.abilityHolderDimmed)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.AbilityCooldowns, 0.2, tweenerCommon.abilityHolderNotDimmed)
  end
  self.AbilityCooldowns:SetCoversVisible(isDimmed)
end
function QuickslotItemDropTarget:SetAbilitiesSmaller(isSmaller)
  if isSmaller then
    self.ScriptedEntityTweener:PlayC(self.Properties.AbilityCooldowns, 0.2, tweenerCommon.abilityHolderSmall)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.AbilityCooldowns, 0.2, tweenerCommon.abilityHolderNotSmall)
  end
end
function QuickslotItemDropTarget:SetHintVisible(isVisible)
  self.AbilityCooldowns:SetHintVisible(isVisible)
end
function QuickslotItemDropTarget:PlayWeaponDeselectLineAnim(delay)
  UiElementBus.Event.SetIsEnabled(self.Properties.LineRight, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.LineLeft, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.LineBottom, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.LineTop1, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.LineTop2, true)
  self.ScriptedEntityTweener:Play(self.Properties.LineRight, 1.2, {scaleX = -1}, {scaleX = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.LineLeft, 1.2, {scaleX = 1}, {scaleX = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.LineBottom, 1.2, {scaleX = -1}, {scaleX = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.LineTop1, 1.2, {scaleX = 1}, {scaleX = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.LineTop2, 1.2, {scaleX = 1}, {
    scaleX = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.LineRight, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.LineLeft, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.LineBottom, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.LineTop1, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.LineTop2, false)
    end
  })
  if delay == nil then
    delay = 0
  end
  self.ScriptedEntityTweener:Stop(self.Properties.Cover)
  self.ScriptedEntityTweener:Play(self.Properties.Cover, 0.75, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = delay
  })
end
function QuickslotItemDropTarget:SetLockIconVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.LockIcon, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.AbilityCooldowns, not isVisible)
  if isVisible then
    UiFaderBus.Event.SetFadeValue(self.entityId, 0.3)
    if self.Properties.ItemBg:IsValid() then
      UiFaderBus.Event.SetFadeValue(self.Properties.ItemBg, 0.3)
    end
  else
    UiFaderBus.Event.SetFadeValue(self.entityId, 1)
    if self.Properties.ItemBg:IsValid() then
      UiFaderBus.Event.SetFadeValue(self.Properties.ItemBg, 1)
    end
  end
end
function QuickslotItemDropTarget:IsLocked()
  return UiElementBus.Event.IsEnabled(self.Properties.LockIcon)
end
function QuickslotItemDropTarget:SetLockText(lockText)
  SetTextStyle(self.Properties.LockText, self.UIStyle.STANDARD_BODY_TEXT_SEMIBOLD)
  UiTextBus.Event.SetText(self.Properties.LockText, lockText)
end
return QuickslotItemDropTarget

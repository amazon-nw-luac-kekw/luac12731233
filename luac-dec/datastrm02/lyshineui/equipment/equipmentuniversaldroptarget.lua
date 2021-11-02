local tweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
local style = RequireScript("LyShineUI._Common.UIStyle")
local EquipmentUniversalDropTarget = {
  Properties = {
    DropTargetHighlight = {
      default = EntityId()
    }
  },
  defaultColor = style.COLOR_WHITE,
  defaultOpacity = 0.1,
  invalidColor = style.COLOR_RED,
  invalidOpacity = 0.2
}
local registrar = RequireScript("LyShineUI.EntityRegistrar")
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
function EquipmentUniversalDropTarget:OnActivate()
  self.dropTargetHandler = UiDropTargetNotificationBus.Connect(self, self.entityId)
  self.commonFunctions = RequireScript("LyShineUI.CommonDragDrop")
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.ScriptedEntityTweener = tweener
  self.ScriptedEntityTweener:OnActivate()
  registrar:RegisterEntity(self)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Paperdoll.ClearHighlight", function(self, clear)
    local isEnabled = UiElementBus.Event.IsEnabled(self.Properties.DropTargetHighlight)
    if isEnabled then
      self.ScriptedEntityTweener:Play(self.Properties.DropTargetHighlight, 0.25, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(self.Properties.DropTargetHighlight, false)
        end
      })
    end
  end)
end
function EquipmentUniversalDropTarget:OnDeactivate()
  self.dropTargetHandler:Disconnect()
  self.commonFunctions = nil
  self.dataLayer = nil
  self.ScriptedEntityTweener:OnDeactivate()
  self.ScriptedEntityTweener = nil
  registrar:UnregisterEntity(self)
end
function EquipmentUniversalDropTarget:OnDropHoverStart(draggable)
  self.commonFunctions:OnDropHoverStart(self.entityId, draggable)
  local targetOpacity = self.defaultOpacity
  if self:CanEquipCurrentDraggable() then
    self.ScriptedEntityTweener:Set(self.Properties.DropTargetHighlight, {
      imgColor = self.defaultColor
    })
  else
    self.ScriptedEntityTweener:Set(self.Properties.DropTargetHighlight, {
      imgColor = self.invalidColor
    })
    targetOpacity = self.invalidOpacity
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.DropTargetHighlight, true)
  self.ScriptedEntityTweener:Play(self.Properties.DropTargetHighlight, 0.15, {opacity = targetOpacity, ease = "QuadOut"})
end
function EquipmentUniversalDropTarget:OnDropHoverEnd(draggable)
  self.commonFunctions:OnDropHoverEnd(self.entityId, draggable)
  self.ScriptedEntityTweener:Play(self.Properties.DropTargetHighlight, 0.25, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.DropTargetHighlight, false)
    end
  })
end
function EquipmentUniversalDropTarget:CanEquipCurrentDraggable(doingOnDrop)
  local draggableData = self.commonFunctions:GetDraggableData()
  if draggableData then
    local containerType = draggableData.containerType
    local sourceSlotId = draggableData.sourceSlotId
    local sourceContainerId = draggableData.sourceContainerId
    local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    if containerType == eItemDragContext_Paperdoll or containerType == eItemDragContext_Quickslot then
      return not doingOnDrop
    elseif containerType == eItemDragContext_Inventory or containerType == eItemDragContext_Container then
      local draggableItem = ContainerRequestBus.Event.GetSlot(sourceContainerId, sourceSlotId)
      if draggableItem ~= nil then
        local canEquipItem = draggableItem:CanEquipItem(rootEntityId)
        local meetsWeaponRequirements
        if draggableItem:GetItemType() == "Weapon" then
          meetsWeaponRequirements = LocalPlayerUIRequestsBus.Broadcast.MeetsWeaponRequirements(draggableItem)
        else
          meetsWeaponRequirements = true
        end
        return canEquipItem and meetsWeaponRequirements
      end
    end
    return false
  end
  return false
end
function EquipmentUniversalDropTarget:OnDrop(draggable)
  if self.commonFunctions:IsValidDrop(draggable) and self:CanEquipCurrentDraggable(true) then
    local draggableData = self.commonFunctions:GetDraggableData()
    local sourceSlotId = draggableData.sourceSlotId
    local sourceContainerId = draggableData.sourceContainerId
    local stackSize = draggableData.stackSize
    EquipmentCommon:EquipItemToBestSlot(sourceSlotId, false, sourceContainerId, stackSize)
  end
end
return EquipmentUniversalDropTarget

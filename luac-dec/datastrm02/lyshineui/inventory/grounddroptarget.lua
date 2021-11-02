local CommonFunctions = require("LyShineUI.CommonDragDrop")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
local GroundDropTarget = {
  Properties = {
    GroundDropMessage = {
      default = EntityId()
    },
    InventoryEntity = {
      default = EntityId()
    },
    CampHolder = {
      default = EntityId()
    },
    DropTargetHighlight = {
      default = EntityId()
    }
  },
  isforceDisabled = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(GroundDropTarget)
function GroundDropTarget:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiDropTargetNotificationBus, self.entityId)
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.Paperdoll.EquipmentSlotsToHighlight", function(self, dataNode)
    local draggedItemDataNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.ItemDragging")
    if draggedItemDataNode then
      local containerType = draggedItemDataNode.ContainerType:GetData()
      if containerType == eItemDragContext_Inventory or containerType == eItemDragContext_Paperdoll then
        local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
        if currentState ~= 3349343259 and currentState ~= 1809891471 then
          self:SetIsEnabled(true)
          self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 1, ease = "QuadOut"})
          self.ScriptedEntityTweener:Play(self.Properties.CampHolder, 0.3, {x = 100, ease = "QuadOut"})
          self.ScriptedEntityTweener:Play(self.Properties.CampHolder, 0.2, {
            opacity = 0,
            ease = "QuadOut",
            onComplete = function()
              UiElementBus.Event.SetIsEnabled(self.Properties.CampHolder, false)
            end
          })
        end
      end
    end
  end)
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.Paperdoll.ClearHighlight", function(self, dataNode)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        self:SetIsEnabled(false)
      end
    })
    local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
    if currentState ~= 3349343259 and currentState ~= 1809891471 then
      local animDelay = 0.1
      if not self.camphidden then
        UiElementBus.Event.SetIsEnabled(self.Properties.CampHolder, true)
        self.ScriptedEntityTweener:Play(self.Properties.CampHolder, 0.3, {
          opacity = 1,
          x = 0,
          ease = "QuadOut",
          delay = animDelay
        })
      end
    end
  end)
  local textStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA_ITALIC,
    fontSize = 30,
    fontColor = self.UIStyle.COLOR_GRAY_90
  }
  SetTextStyle(self.GroundDropMessage, textStyle)
  UiTextBus.Event.SetTextWithFlags(self.Properties.GroundDropMessage, "@inv_dropTargetMessage", eUiTextSet_SetLocalized)
  self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0})
  self:SetIsEnabled(false)
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    self.camphidden = true
    self.ScriptedEntityTweener:Set(self.Properties.CampHolder, {opacity = 0})
    UiElementBus.Event.SetIsEnabled(self.Properties.CampHolder, false)
    self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    self.tutorialBusHandler = self:BusConnect(TutorialComponentNotificationsBus, self.canvasId)
  end
end
function GroundDropTarget:OnShutdown()
end
function GroundDropTarget:SetIsEnabled(isEnabled)
  if self.isforceDisabled then
    isEnabled = false
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
end
function GroundDropTarget:SetIsForceDisabled(isforceDisabled)
  self.isforceDisabled = isforceDisabled
end
function GroundDropTarget:OnDropHoverStart(draggable)
  CommonFunctions:OnDropHoverStart(self.entityId, draggable)
  UiElementBus.Event.SetIsEnabled(self.Properties.DropTargetHighlight, true)
  self.ScriptedEntityTweener:Play(self.Properties.DropTargetHighlight, 0.15, {opacity = 1, ease = "QuadOut"})
end
function GroundDropTarget:OnDropHoverEnd(draggable)
  CommonFunctions:OnDropHoverEnd(self.entityId, draggable)
  self.ScriptedEntityTweener:Play(self.Properties.DropTargetHighlight, 0.25, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.DropTargetHighlight, false)
    end
  })
end
function GroundDropTarget:OnDrop(draggable)
  if CommonFunctions:IsValidDrop(draggable) then
    if not self.inventoryTable then
      self.inventoryTable = self.registrar:GetEntityTable(self.Properties.InventoryEntity)
      if not self.inventoryTable then
        Debug.Log("In GroundDropTarget:OnDrop, self.inventoryTable does not exist")
        return
      end
    end
    do
      local draggableData = CommonFunctions:GetDraggableData()
      if draggableData.containerType == eItemDragContext_Inventory then
        self.inventoryTable:DropItem(draggable)
      elseif draggableData.containerType == eItemDragContext_Paperdoll then
        local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
        local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, draggableData.sourceSlotId)
        if slot and slot:IsValid() and slot:IsBoundToPlayer() and slot:IsNonRemovableFromPlayer(true) then
          PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_destroyBoundItem", "@ui_destroyBoundItemMessage", "destroyItemDragDrop", self, function(self, result, eventId)
            if result == ePopupResult_Yes then
              LocalPlayerUIRequestsBus.Broadcast.PaperdollDropItem(draggableData.sourceSlotId, draggableData.stackSize)
            end
          end)
          return
        end
        local isSlotBlocked = PaperdollRequestBus.Event.SlotBlockedByCooldown(paperdollId, draggableData.sourceSlotId)
        if isSlotBlocked then
          EquipmentCommon:TriggerEquipErrorNotification("@ui_equipment_cooldown_error")
          return
        end
        LocalPlayerUIRequestsBus.Broadcast.PaperdollDropItem(draggableData.sourceSlotId, draggableData.stackSize)
      end
    end
  end
end
function GroundDropTarget:OnTutorialRevealUIElement(elementName)
  if elementName == "InventoryCamp" then
    self.camphidden = nil
    if self.tutorialBusHandler ~= nil then
      self.tutorialBusHandler:Disconnect()
      self.tutorialBusHandler = nil
    end
  end
end
return GroundDropTarget

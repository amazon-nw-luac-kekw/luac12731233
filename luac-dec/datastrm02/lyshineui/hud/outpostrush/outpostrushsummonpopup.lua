local OutpostRushSummonPopup = {
  Properties = {
    Frame = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    ButtonAccept = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    SummonList = {
      default = EntityId()
    }
  },
  selectedItemId = nil
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(OutpostRushSummonPopup)
function OutpostRushSummonPopup:OnInit()
  BaseScreen.OnInit(self)
  self.summonItems = {
    {itemId = 3898673229, itemLayout = nil},
    {itemId = 4002565342, itemLayout = nil},
    {itemId = 1743054195, itemLayout = nil}
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    self.inventoryId = data
  end)
  self:SetVisualElements()
end
function OutpostRushSummonPopup:SetVisualElements()
  self.FrameHeader:SetText("@ui_outpost_rush_select_summoning_stone")
  self.FrameHeader:SetTextAlignment(eUiHAlign_Center)
  self.ButtonAccept:SetText("@ui_accept")
  self.ButtonAccept:SetCallback(self.SummonCreature, self)
  self.ButtonAccept:SetButtonStyle(self.ButtonAccept.BUTTON_STYLE_CTA)
  self.ButtonAccept:SetEnabled(false)
  self.ButtonClose:SetCallback(self.OnExit, self)
end
function OutpostRushSummonPopup:SetScreenVisible(isVisible)
  self.ScriptedEntityTweener:Stop(self.entityId)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut"
    })
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
        self:OnTransitionOutCompleted()
      end
    })
  end
end
function OutpostRushSummonPopup:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  local children = UiElementBus.Event.GetChildren(self.Properties.SummonList)
  for i = 1, #children do
    local itemLayout = self.registrar:GetEntityTable(children[i])
    if itemLayout then
      self.summonItems[i].itemLayout = itemLayout
      local itemDescriptor = ItemDescriptor()
      itemDescriptor.itemId = self.summonItems[i].itemId
      itemDescriptor.quantity = ContainerRequestBus.Event.GetItemCount(self.inventoryId, itemDescriptor, false, true, false)
      itemLayout:SetItemByDescriptor(itemDescriptor)
      itemLayout:SetIsHandlingEvents(true)
      itemLayout:SetTooltipEnabled(true)
      itemLayout:SetIsItemDraggable(true)
      itemLayout:SetHighlightVisible(false)
      local isEnabled = itemDescriptor.quantity > 0
      if isEnabled then
        itemLayout:SetCallback(self, self.SetSelected)
        itemLayout:SetQuantityEnabled(true)
        self.ScriptedEntityTweener:Set(children[i], {opacity = 1})
      else
        itemLayout:SetCallback()
        itemLayout:SetQuantityEnabled(false)
        self.ScriptedEntityTweener:Set(children[i], {opacity = 0.3})
      end
      UiTransformBus.Event.SetScale(children[i], Vector2(1.5, 1.5))
    end
  end
  self.ButtonAccept:SetEnabled(false)
  self:SetScreenVisible(true)
end
function OutpostRushSummonPopup:SetSelected(itemLayout)
  self.selectedItemId = itemLayout.itemId
  if self.selectedItemId then
    self.ButtonAccept:SetEnabled(true)
  end
  itemLayout:SetHighlightVisible(true)
  for i = 1, #self.summonItems do
    local currentItemLayout = self.summonItems[i].itemLayout
    local currentItemId = self.summonItems[i].itemId
    if currentItemId ~= self.selectedItemId then
      currentItemLayout:SetHighlightVisible(false)
    end
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function OutpostRushSummonPopup:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self:SetScreenVisible(false)
end
function OutpostRushSummonPopup:SummonCreature()
  if self.selectedItemId == 3898673229 then
    LocalPlayerUIRequestsBus.Broadcast.OutpostRushSummonBear()
  elseif self.selectedItemId == 4002565342 then
    LocalPlayerUIRequestsBus.Broadcast.OutpostRushSummonWraith()
  elseif self.selectedItemId == 1743054195 then
    LocalPlayerUIRequestsBus.Broadcast.OutpostRushSummonBrute()
  end
  self:OnExit()
end
function OutpostRushSummonPopup:OnTransitionOutCompleted()
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  if interactorEntity then
    UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  end
  UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function OutpostRushSummonPopup:OnShutdown()
end
function OutpostRushSummonPopup:OnExit()
  self.selectedItemId = nil
  LyShineManagerBus.Broadcast.ExitState(4241440342)
end
return OutpostRushSummonPopup

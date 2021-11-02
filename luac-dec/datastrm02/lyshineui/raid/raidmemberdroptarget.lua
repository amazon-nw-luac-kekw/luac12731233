local RaidMemberDropTarget = {
  Properties = {
    RaidMember = {
      default = EntityId()
    },
    Bg = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RaidMemberDropTarget)
local CommonFunctions = RequireScript("LyShineUI.CommonDragDrop")
function RaidMemberDropTarget:OnInit()
  self.draggableHandler = self:BusConnect(UiDropTargetNotificationBus, self.entityId)
end
function RaidMemberDropTarget:OnDropHoverStart(draggable)
  CommonFunctions:OnDropHoverStart(self.entityId, draggable)
  if g_isDragging then
    self.ScriptedEntityTweener:Set(self.RaidMember.Properties.Hover, {opacity = 1})
  end
end
function RaidMemberDropTarget:OnDrop(draggable)
  self.ScriptedEntityTweener:Set(self.RaidMember.Properties.Hover, {opacity = 0})
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Button_Select)
  local draggableTable = self.registrar:GetEntityTable(draggable)
  if not draggableTable or draggableTable.isProxy or not draggableTable.characterId then
    return
  end
  DynamicBus.Raid.Broadcast.SetMemberToSlot(draggableTable, self.RaidMember)
  self.ScriptedEntityTweener:Play(self.Properties.RaidMember, 0.2, {scaleX = 1.15, scaleY = 1.15}, {scaleX = 1, scaleY = 1})
  self.ScriptedEntityTweener:Play(self.RaidMember.PlayerBg, 0.2, {
    imgColor = self.UIStyle.COLOR_TAN_MEDIUM
  }, {
    imgColor = self.UIStyle.COLOR_BROWN_DARK
  })
  self.ScriptedEntityTweener:Set(self.RaidMember.NameText, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.RaidMember.NameText, 0.3, {opacity = 0}, {opacity = 1, delay = 0.2})
end
function RaidMemberDropTarget:OnDropHoverEnd(draggable)
  CommonFunctions:OnDropHoverEnd(self.entityId, draggable)
  self.ScriptedEntityTweener:Set(self.RaidMember.Properties.Hover, {opacity = 0})
end
return RaidMemberDropTarget

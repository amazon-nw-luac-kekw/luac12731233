local RepairSalvageTooltip = {
  Properties = {
    Button = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RepairSalvageTooltip)
function RepairSalvageTooltip:OnInit()
  BaseElement.OnInit()
  self.originalHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
end
function RepairSalvageTooltip:SetData(data)
  self.Button:SetData(data.data)
  local height = self.originalHeight
  if data.data.buttonHeight then
    height = math.max(height, data.data.buttonHeight)
  end
  self.ScriptedEntityTweener:Set(self.entityId, {h = height})
  self.ScriptedEntityTweener:Play(self.entityId, 0.25, {opacity = 0}, {opacity = 1, ease = "QuadIn"})
end
return RepairSalvageTooltip

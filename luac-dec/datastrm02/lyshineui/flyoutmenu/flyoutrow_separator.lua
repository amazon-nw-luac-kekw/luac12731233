local FlyoutRow_Separator = {
  Properties = {
    Line = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_Separator)
function FlyoutRow_Separator:OnInit()
  BaseElement.OnInit(self)
  self.originalRowHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self.originalLinePosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.Line)
end
function FlyoutRow_Separator:OnShutdown()
end
function FlyoutRow_Separator:SetData(data)
  local linePosY = self.originalLinePosY
  local height = self.originalRowHeight
  if data.paddingTop then
    linePosY = linePosY + data.paddingTop
    height = height + data.paddingTop
  end
  if data.paddingBottom then
    height = height + data.paddingBottom
  end
  UiTransformBus.Event.SetLocalPositionY(self.Properties.Line, linePosY)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, height)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, height)
end
return FlyoutRow_Separator

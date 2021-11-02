local FlyoutRow_AttributeThreshold = {
  Properties = {
    DescriptionText = {
      default = EntityId()
    },
    PointsLabel = {
      default = EntityId()
    },
    PointsText = {
      default = EntityId()
    }
  },
  defaultHeight = 100,
  lineHeight = 23
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_AttributeThreshold)
function FlyoutRow_AttributeThreshold:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.DescriptionText, self.UIStyle.FONT_STYLE_ATTRIBUTES_TOOLTIP_DESC)
  SetTextStyle(self.Properties.PointsLabel, self.UIStyle.FONT_STYLE_ATTRIBUTES_TOOLTIP_DESC)
  SetTextStyle(self.Properties.PointsText, self.UIStyle.FONT_STYLE_ATTRIBUTES_TOOLTIP_POINTS)
end
function FlyoutRow_AttributeThreshold:OnShutdown()
end
function FlyoutRow_AttributeThreshold:SetData(data)
  if not data then
    Log("[FlyoutRow_AttributeThreshold] Error: invalid data passed to SetData")
    return
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionText, data.description, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(self.Properties.PointsText, data.threshold)
  UiTextBus.Event.SetColor(self.Properties.PointsText, data.thresholdColor)
  local descriptionHeight = UiTextBus.Event.GetTextHeight(self.Properties.DescriptionText) - self.lineHeight
  local height = self.defaultHeight + descriptionHeight
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, height)
end
return FlyoutRow_AttributeThreshold

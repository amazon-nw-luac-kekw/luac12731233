BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local ExtraPoiObjectivesLabel = {
  Properties = {}
}
BaseElement:CreateNewElement(ExtraPoiObjectivesLabel)
function ExtraPoiObjectivesLabel:OnInit()
  BaseElement.OnInit(self)
  self.isEnabled = false
end
function ExtraPoiObjectivesLabel:SetAnchorsPosition(anchors)
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, anchors)
end
function ExtraPoiObjectivesLabel:SetNumExtraPoiObjectives(numExtraObjectives)
  UiTextBus.Event.SetText(self.entityId, "+" .. tostring(numExtraObjectives))
end
function ExtraPoiObjectivesLabel:SetScale(scale)
  UiTransformBus.Event.SetScale(self.entityId, Vector2(scale, scale))
end
function ExtraPoiObjectivesLabel:SetIsEnabled(isEnabled)
  if isEnabled ~= self.isEnabled then
    self.isEnabled = isEnabled
    UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
  end
end
return ExtraPoiObjectivesLabel

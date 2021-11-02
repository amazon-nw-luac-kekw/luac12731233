local TextAdditionalInfo = {
  Properties = {
    TextEntity = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TextAdditionalInfo)
function TextAdditionalInfo:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiInteractOptionAdditionalInfoRequestsBus, self.entityId)
end
function TextAdditionalInfo:OnShutdown()
end
function TextAdditionalInfo:PopulateAdditionalInfo(additionalInfoType, playerComponentData, interactionEntityId)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
end
return TextAdditionalInfo

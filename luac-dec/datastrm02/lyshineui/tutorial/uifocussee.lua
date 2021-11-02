local UIFocussee = {
  Properties = {
    Name = {default = ""},
    ArrowIdx = {default = 0}
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(UIFocussee)
function UIFocussee:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.tutorialBusHandler = TutorialComponentNotificationsBus.Connect(self, self.canvasId)
end
function UIFocussee:OnShutdown()
  if self.tutorialBusHandler ~= nil then
    self.tutorialBusHandler:Disconnect()
    self.tutorialBusHandler = nil
  end
end
function UIFocussee:OnTutorialFocusUIElementByName(name, returnId)
  if name == self.Properties.Name then
    local rect = UiTransformBus.Event.GetViewportSpaceRect(self.entityId)
    if returnId:IsValid() then
      TutorialUIRequestsBus.Event.FocusUIElement(returnId, rect:GetCenter(), rect:GetWidth(), rect:GetHeight(), self.Properties.ArrowIdx)
    else
      local tutorialComponentId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
      TutorialUIRequestsBus.Event.FocusUIElement(tutorialComponentId, rect:GetCenter(), rect:GetWidth(), rect:GetHeight())
    end
  end
end
return UIFocussee

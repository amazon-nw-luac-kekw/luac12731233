local UnifiedInteractOption = {
  Properties = {
    NameText = {
      default = EntityId()
    }
  },
  isHeld = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(UnifiedInteractOption)
function UnifiedInteractOption:OnInit()
  BaseElement.OnInit(self)
  self.enabledColor = ColorRgba(255, 255, 255, 1)
  self.disabledColor = ColorRgba(128, 128, 128, 1)
  self:BusConnect(UnifiedInteractOptionNotificationsBus, self.entityId)
end
function UnifiedInteractOption:OnShutdown()
  if self.isHeld then
    self:OnInteractOptionHoldEnd()
  end
end
function UnifiedInteractOption:OnInteractOptionPressed()
  self.audioHelper:PlaySound(self.audioHelper.InteractOptionPressed)
end
function UnifiedInteractOption:OnInteractOptionHoldBegin()
  self.audioHelper:PlaySound(self.audioHelper.InteractOptionHold_Loop_Play)
  self.isHeld = true
end
function UnifiedInteractOption:OnInteractOptionHoldEnd()
  self.audioHelper:PlaySound(self.audioHelper.InteractOptionHold_Loop_Stop)
  self.isHeld = false
end
function UnifiedInteractOption:OnCanExecuteInteractOptionChanged(canExecute)
  UiTextBus.Event.SetColor(self.NameText, canExecute and self.enabledColor or self.disabledColor)
end
return UnifiedInteractOption

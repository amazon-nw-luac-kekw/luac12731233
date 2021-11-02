local NameValidationStatus = {
  Properties = {
    ValidEntity = {
      default = EntityId()
    },
    InvalidEntity = {
      default = EntityId()
    },
    ValidatingEntity = {
      default = EntityId()
    }
  }
}
function NameValidationStatus:OnActivate()
  if not self.Properties.ValidEntity:IsValid() then
    Debug.Log("NameValidationStatus: Lua property ValidEntity is not set")
  end
  if not self.Properties.InvalidEntity:IsValid() then
    Debug.Log("NameValidationStatus: Lua property InvalidEntity is not set")
  end
  if not self.Properties.ValidatingEntity:IsValid() then
    Debug.Log("NameValidationStatus: Lua property ValidatingEntity is not set")
  end
  self.handler = UiCharacterNameValidationStatusBus.Connect(self, self.entityId)
  if not self.tickBusHandler then
    self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
  end
  self.ScriptedEntityTweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
  self.ScriptedEntityTweener:OnActivate()
end
function NameValidationStatus:OnDeactivate()
  self.handler:Disconnect()
end
function NameValidationStatus:OnTick(deltaTime, timePoint)
  DynamicBus.UITickBus.Disconnect(self.entityId, self)
  self.tickBusHandler = nil
  if self.Properties.ValidatingEntity:IsValid() then
    self.ScriptedEntityTweener:StartAnimation({
      id = self.Properties.ValidatingEntity,
      duration = 1,
      opacity = 1,
      timesToPlay = -1,
      rotation = 359
    })
  end
end
function NameValidationStatus:SetStatus(status)
  UiElementBus.Event.SetIsEnabled(self.Properties.ValidEntity, status == ENameValidationState_Valid)
  UiElementBus.Event.SetIsEnabled(self.Properties.InvalidEntity, status == ENameValidationState_Invalid)
  UiElementBus.Event.SetIsEnabled(self.Properties.ValidatingEntity, status == ENameValidationState_Validating)
end
return NameValidationStatus

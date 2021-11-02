local NameValidationInput = {
  Properties = {
    ValidationErrorText = {
      default = EntityId()
    },
    ValidationIcon = {
      default = EntityId()
    },
    ValidationLockedButton = {
      default = EntityId()
    }
  },
  validatedName = "",
  nameValidationTimer = 0,
  nameNeedsValidation = false,
  isValidating = false,
  nameValidationInterval = 2,
  nameStatus = ENameValidationState_Invalid
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(NameValidationInput)
local dataLayer = RequireScript("LyShineUI.UIDataLayer")
local NameValidationCommon = RequireScript("LyShineUI._Common.NameValidationCommon")
function NameValidationInput:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiCharacterServiceNotificationBus, self)
  self.dataLayer = dataLayer
end
function NameValidationInput:OnShow(shown)
  if shown then
    if not self.tickBusHandler then
      self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
    end
    self:ClearName()
    self.ValidationLockedButton:SetEnabled(false)
  else
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBusHandler = nil
  end
end
function NameValidationInput:OnTick(deltaTime, timePoint)
  if self.nameValidationTimer < self.nameValidationInterval then
    self.nameValidationTimer = self.nameValidationTimer + deltaTime
  elseif self.nameNeedsValidation and not self.isValidating then
    self.isValidating = true
    self.validatedName = UiTextInputBus.Event.GetText(self.entityId)
    self.validatedName = NameValidationCommon:TrimString(self.validatedName)
    if string.len(self.validatedName) > 0 then
      local result, errorString = NameValidationCommon:CheckNameValid(self.validatedName)
      self.nameNeedsValidation = false
      if result == eValidStringResponse_Valid then
        self.selectedWorldId = MainMenuSystemRequestBus.Broadcast.GetSelectedWorldId()
        UiCharacterServiceRequestBus.Broadcast.ValidateName(self.selectedWorldId, self.validatedName)
      else
        self.nameValidationTimer = 0
        self.isValidating = false
        self:SetNameValidationStatus(ENameValidationState_Invalid)
        UiTextBus.Event.SetTextWithFlags(self.Properties.ValidationErrorText, errorString, eUiTextSet_SetLocalized)
      end
    else
      self.nameValidationTimer = 0
      self.isValidating = false
      self.nameNeedsValidation = false
      self:SetNameValidationStatus(ENameValidationState_Invalid)
      UiTextBus.Event.SetText(self.Properties.ValidationErrorText, "")
    end
  end
end
function NameValidationInput:OnShutdown()
  if self.tickBusHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBusHandler = nil
  end
  self.dataLayer = nil
end
function NameValidationInput:ClearName()
  self.validatedName = ""
  UiTextInputBus.Event.SetText(self.entityId, "")
  self:ValidateName()
end
function NameValidationInput:EditPlayerName()
  self:ValidateName()
end
function NameValidationInput:ValidateNameResult(status, errorMessage)
  if not self.nameNeedsValidation then
    self:SetNameValidationStatus(status)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ValidationErrorText, errorMessage, eUiTextSet_SetLocalized)
    self.nameValidationTimer = 0
    self.nameNeedsValidation = false
  end
  self.isValidating = false
end
function NameValidationInput:SetNameValidationStatus(status)
  self.nameStatus = status
  local isValid = self.nameStatus == ENameValidationState_Valid
  UiCharacterNameValidationStatusBus.Event.SetStatus(self.Properties.ValidationIcon, status)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ValidationLockedButton, isValid)
  if type(self.ValidationLockedButton) == "table" then
    self.ValidationLockedButton:SetEnabled(isValid)
  end
end
function NameValidationInput:ValidateName()
  self.nameNeedsValidation = true
  self:SetNameValidationStatus(ENameValidationState_Validating)
end
return NameValidationInput

local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local CACIdentityTab = {
  Properties = {
    PrimaryTitle = {
      default = EntityId()
    },
    NameInputField = {
      default = EntityId()
    },
    ValidationErrorText = {
      default = EntityId()
    },
    ValidationIcon = {
      default = EntityId()
    },
    PlaceholderText = {
      default = EntityId()
    },
    CreateButton = {
      default = EntityId()
    },
    CreateButtonSpinner = {
      default = EntityId()
    }
  },
  validatedName = "",
  nameValidationTimer = 0,
  nameNeedsValidation = false,
  isValidating = false,
  nameValidationInterval = 2,
  nameStatus = ENameValidationState_Invalid,
  selectedWorldId = "",
  CREATE_CHARACTER_TIMER_DURATION = 60,
  createCharacterTimer = -1,
  connectionErrorTitle = "@mm_connection_error_title",
  connectionErrorMessage = "@mm_connerr_createcharacter_timeout",
  errorEventId = "Popup_ErrorMessage",
  errorTimeoutEventId = "Popup_ErrorTimeout",
  isScreenVisible = false,
  animDelay = 0.5
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CACIdentityTab)
local dataLayer = RequireScript("LyShineUI.UIDataLayer")
local NameValidationCommon = RequireScript("LyShineUI._Common.NameValidationCommon")
function CACIdentityTab:OnInit()
  BaseElement.OnInit(self)
  self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
  self.errorsToQuitOn = {
    "@mm_loginservices_worldmaintenance"
  }
  self:BusConnect(UiCharacterServiceNotificationBus, self)
  self.dataLayer = dataLayer
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:SetVisualElements()
end
function CACIdentityTab:OnTick(deltaTime, timePoint)
  if self.nameValidationTimer < self.nameValidationInterval then
    self.nameValidationTimer = self.nameValidationTimer + deltaTime
  elseif self.nameNeedsValidation and not self.isValidating then
    self.isValidating = true
    self.validatedName = UiTextInputBus.Event.GetText(self.Properties.NameInputField)
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
        self.ScriptedEntityTweener:Play(self.Properties.ValidationErrorText, 0.2, {opacity = 1, ease = "QuadOut"})
      end
    else
      self.nameValidationTimer = 0
      self.isValidating = false
      self.nameNeedsValidation = false
      self:SetNameValidationStatus(ENameValidationState_Invalid)
      self.ScriptedEntityTweener:Play(self.Properties.ValidationErrorText, 0.2, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          UiTextBus.Event.SetText(self.Properties.ValidationErrorText, "")
        end
      })
    end
  end
  if 0 < self.createCharacterTimer then
    self.createCharacterTimer = self.createCharacterTimer - deltaTime
    if 0 > self.createCharacterTimer then
      self:OnCreateCharacterTimedOut()
    end
  end
end
function CACIdentityTab:OnShutdown()
  DynamicBus.UITickBus.Disconnect(self.entityId, self)
  self.tickBusHandler = nil
  self.dataLayer = nil
end
function CACIdentityTab:SetVisualElements()
  SetTextStyle(self.Properties.PrimaryTitle, self.UIStyle.FONT_STYLE_HEADER_SMALL_CAPS_BIG)
  UiTextBus.Event.SetFontSize(self.Properties.PrimaryTitle, 40)
  UiTextBus.Event.SetTextWithFlags(self.PrimaryTitle, "@ui_name_your_avatar", eUiTextSet_SetLocalized)
  UiTextInputBus.Event.SetTextSelectionColor(self.NameInputField, self.UIStyle.COLOR_INPUT_SELECTION)
end
function CACIdentityTab:FocusNameField()
  UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.NameInputField, true)
  UiTextInputBus.Event.BeginEdit(self.NameInputField)
end
function CACIdentityTab:SetScreenVisible(isVisible)
  if isVisible and self.isScreenVisible == false then
    self.isScreenVisible = true
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    local animDuration = 0.4
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.Properties.PrimaryTitle, animDuration, {opacity = 0, y = 30}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.1
    })
    self.ScriptedEntityTweener:Play(self.Properties.NameInputField, animDuration, {opacity = 0, y = 30}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2,
      onComplete = function()
        self:FocusNameField()
      end
    })
  elseif isVisible == false and self.isScreenVisible == true then
    self.isScreenVisible = false
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
  end
end
function CACIdentityTab:GetAnimDelay()
  return self.animDelay
end
function CACIdentityTab:StartCreateCharacterTimer()
  self:EnableButtons(false)
  self.createCharacterTimer = -1
  self.CreateButton:SetText("@ui_validatingcharacter")
  UiElementBus.Event.SetIsEnabled(self.Properties.CreateButtonSpinner, true)
  self.ScriptedEntityTweener:Play(self.Properties.CreateButtonSpinner, 2.5, {rotation = 0}, {timesToPlay = -1, rotation = 359})
end
function CACIdentityTab:StopCreateCharacterTimer()
  self:EnableButtons(true)
  self.createCharacterTimer = -1
  self.CreateButton:SetText("@ui_createcharacter")
  UiElementBus.Event.SetIsEnabled(self.Properties.CreateButtonSpinner, false)
  self.ScriptedEntityTweener:Stop(self.Properties.CreateButtonSpinner)
end
function CACIdentityTab:OnCreateCharacterTimedOut()
  self.showingTimeoutPopup = true
  PopupWrapper:RequestPopup(ePopupButtons_OK, self.connectionErrorTitle, self.connectionErrorMessage, self.errorTimeoutEventId, self, self.OnPopupResult)
  self:StopCreateCharacterTimer()
end
function CACIdentityTab:OnAction(entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function CACIdentityTab:OnTransitionIn(stateName, levelName)
  self.validatedName = ""
  self:ClearName()
end
function CACIdentityTab:OnTransitionOut(stateName, levelName)
  self:StopCreateCharacterTimer()
end
function CACIdentityTab:OnPopupResult(result, eventId)
  if self.quitOnPopupClose then
    self.audioHelper:PlaySound(self.audioHelper.Set_State_MX_Main_Return)
    AudioUtilsBus.Broadcast.ExecuteGlobalAudioTrigger("Stop_FTUE_All", true, EntityId())
    IntroControllerComponentRequestBus.Broadcast.OnExit()
  else
    if eventId == self.errorTimeoutEventId then
      self.showingTimeoutPopup = false
    end
    if result == ePopupResult_OK then
      self:ValidateName()
      self:StopCreateCharacterTimer()
    end
  end
end
function CACIdentityTab:editPlayerName()
  self:ValidateName()
end
function CACIdentityTab:StartPlayerNameEdit()
  self.ScriptedEntityTweener:Play(self.Properties.PlaceholderText, 0.2, {opacity = 0, ease = "QuadOut"})
end
function CACIdentityTab:EndPlayerNameEdit()
  local currentName = UiTextInputBus.Event.GetText(self.Properties.NameInputField)
  if currentName == "" then
    self.ScriptedEntityTweener:Play(self.Properties.PlaceholderText, 0.2, {opacity = 1, ease = "QuadOut"})
  end
end
function CACIdentityTab:CreateCharacterResult(characterId, errorCode, errorMessage)
  if self.showingTimeoutPopup then
    UiPopupBus.Broadcast.HidePopup(self.errorTimeoutEventId)
  end
  self.quitOnPopupClose = IsInsideTable(self.errorsToQuitOn, errorMessage)
  if string.len(characterId) == 0 then
    PopupWrapper:RequestPopup(ePopupButtons_OK, errorCode, errorMessage, self.errorEventId, self, self.OnPopupResult)
    if self.onCreateCharacterFailedCb then
      self.onCreateCharacterFailedCb.func(self.self.onCreateCharacterFailedCb.callerSelf)
    end
  else
    local introControllerIdDataNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.Intro.IntroControllerEntityID")
    if introControllerIdDataNode then
      self.introControllerEntityID = introControllerIdDataNode:GetData()
      if self.introControllerEntityID then
        return
      end
    end
    LyShineDataLayerBus.Broadcast.SetData("MainMenu.NewCharacterId", characterId)
    LyShineManagerBus.Broadcast.SetState(3881446394)
  end
end
function CACIdentityTab:SetOnCreateCharacterFailedResult(callerSelf, func)
  self.onCreateCharacterFailedCb = {callerSelf = callerSelf, func = func}
end
function CACIdentityTab:ValidateNameResult(status, errorMessage)
  if not self.nameNeedsValidation then
    self:SetNameValidationStatus(status)
    if status == ENameValidationState_Invalid then
      UiTextBus.Event.SetTextWithFlags(self.Properties.ValidationErrorText, errorMessage, eUiTextSet_SetLocalized)
      self.ScriptedEntityTweener:Play(self.Properties.ValidationErrorText, 0.2, {opacity = 1, ease = "QuadOut"})
    elseif status == ENameValidationState_Valid then
      self.ScriptedEntityTweener:Play(self.Properties.ValidationErrorText, 0.2, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          UiTextBus.Event.SetText(self.Properties.ValidationErrorText, "")
        end
      })
    end
    self.nameValidationTimer = 0
    self.nameNeedsValidation = false
  end
  self.isValidating = false
end
function CACIdentityTab:EnableButtons(enable)
  self.CreateButton:SetEnabled(enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.NameInputField, enable)
end
function CACIdentityTab:ClearName()
  if self.Properties.NameInputField:IsValid() then
    UiTextInputBus.Event.SetText(self.Properties.NameInputField, "")
    self:ValidateName()
  end
end
function CACIdentityTab:SetNameValidationStatus(status)
  self.nameStatus = status
  UiCharacterNameValidationStatusBus.Event.SetStatus(self.Properties.ValidationIcon, status)
  self.CreateButton:SetEnabled(self.nameStatus == ENameValidationState_Valid)
end
function CACIdentityTab:ValidateName()
  self.nameNeedsValidation = true
  self:SetNameValidationStatus(ENameValidationState_Validating)
  self.ScriptedEntityTweener:Play(self.Properties.ValidationErrorText, 0.2, {opacity = 0, ease = "QuadOut"})
end
function CACIdentityTab:IsNameValid()
  return self.nameNeedsValidation == false and self.nameStatus == ENameValidationState_Valid
end
return CACIdentityTab

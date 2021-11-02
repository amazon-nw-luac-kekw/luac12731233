local Voip = {
  Properties = {
    VoipContainer = {
      default = EntityId()
    },
    VoipSpeaker = {
      default = EntityId()
    },
    YouText = {
      default = EntityId()
    },
    ErrorText = {
      default = EntityId()
    }
  },
  isDisplaying = false,
  inputMode = eVoiceChatInputMode_Push_To_Talk
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(Voip)
function Voip:OnInit()
  BaseScreen.OnInit(self)
  self.micOnAction = "toggleMicrophoneOn"
  self.micOffActions = {
    "toggleMicrophoneOff",
    "toggleChatComponent",
    "toggleChatComponentSlash"
  }
  self:BusConnect(CryActionNotificationsBus, self.micOnAction)
  for i = 1, #self.micOffActions do
    self:BusConnect(CryActionNotificationsBus, self.micOffActions[i])
  end
  self:BusConnect(UiTextInputNotificationBus, EntityId())
  UiElementBus.Event.SetIsEnabled(self.VoipContainer, false)
  self.VoipSpeaker:SetPlayer(nil, false)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Vitals.IsDead", function(self, isDead)
    if self.isDisplaying and isDead then
      self:UnregisterObservers()
      self:HideVoipSpeaker()
      VoiceChatControlBus.Broadcast.SetLocalMicOn(false)
      self.isDisplaying = false
    elseif not isDead and self.inputMode == eVoiceChatInputMode_Always_On then
      VoiceChatControlBus.Broadcast.SetLocalMicOn(true)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Voip.InputMode", function(self, mode)
    self.inputMode = mode
    if mode == eVoiceChatInputMode_Always_On then
      VoiceChatControlBus.Broadcast.SetLocalMicOn(true)
    else
      self.isDisplaying = false
      self:OnCryAction(nil)
    end
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Voip.IsSpeaking", function(self, speaking)
    if self.inputMode == eVoiceChatInputMode_Always_On then
      self.isDisplaying = speaking
      if speaking then
        self:RegisterObservers()
        UiElementBus.Event.SetIsEnabled(self.VoipContainer, true)
        self:ShowVoipSpeaker()
      else
        self:UnregisterObservers()
        self:HideVoipSpeaker()
      end
    end
  end)
end
function Voip:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Position", function(self, playerPos)
    self.playerPos = playerPos
    self.playerPos.z = self.playerPos.z + 2
    self:UpdatePosition()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CameraPosition", function(self, cameraPos)
    self.cameraPos = cameraPos
    self:UpdatePosition()
  end)
end
function Voip:UnregisterObservers()
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Position")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.CameraPosition")
end
function Voip:UpdatePosition()
  if not self.isDisplaying then
    return
  end
  if self.playerPos and self.cameraPos then
    local screenPosition = LyShineManagerBus.Broadcast.ProjectToScreen(self.playerPos, false, false)
    local xOffset = 0
    local yOffset = 0
    local distance = self.cameraPos:GetDistanceSq(self.playerPos)
    local maxScale = 1
    local scaleTo = maxScale
    local scaleStart = 15
    local scaleDistance = 45
    local minScale = 0.65
    scaleTo = math.max(scaleTo - (distance - scaleStart) / (scaleDistance - scaleStart), minScale)
    UiTransformBus.Event.SetScale(self.entityId, Vector2(scaleTo, scaleTo))
    UiTransformBus.Event.SetViewportPosition(self.entityId, Vector2(screenPosition.x + xOffset, screenPosition.y + yOffset))
  end
end
function Voip:OnTextInputStateChanged(entityId, isEditing)
  if isEditing then
    self:OnCryAction(nil)
  end
end
function Voip:ShowVoipSpeaker()
  self.VoipSpeaker:SetColor(Color(1, 1, 1, 1))
  UiElementBus.Event.SetIsEnabled(self.ErrorText, false)
  UiElementBus.Event.SetIsEnabled(self.YouText, true)
end
function Voip:HideVoipSpeaker()
  UiElementBus.Event.SetIsEnabled(self.VoipContainer, false)
end
function Voip:OnCryAction(actionName)
  if self.inputMode == eVoiceChatInputMode_Always_On then
    return
  end
  if self.inputMode == eVoiceChatInputMode_Push_To_Talk_Toggle then
    if actionName == self.micOnAction then
      self.isDisplaying = not self.isDisplaying
    end
  else
    self.isDisplaying = actionName == self.micOnAction
  end
  if self.isDisplaying then
    self:RegisterObservers()
    UiElementBus.Event.SetIsEnabled(self.VoipContainer, true)
    local registrationRestricted = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Voip.RegistrationRestricted")
    if VoiceChatControlBus.Broadcast.IsVoiceChatServiceActivated() then
      local in2dChannel = VoiceChatControlBus.Broadcast.IsIn2dChannel()
      local in3dChannel = VoiceChatControlBus.Broadcast.IsIn3dChannel()
      if in2dChannel or in3dChannel then
        self:ShowVoipSpeaker()
        VoiceChatControlBus.Broadcast.SetLocalMicOn(true)
      elseif VoiceChatControlBus.Broadcast.GetCurrentMode() == eVoiceChatMode_Only_2d or registrationRestricted then
        self:ShowError("@ui_voipDisabled")
      else
        self:ShowError("@ui_voipChannelFail")
      end
    else
      self:ShowError("@ui_voipDisabled")
    end
  else
    self:UnregisterObservers()
    self:HideVoipSpeaker()
    VoiceChatControlBus.Broadcast.SetLocalMicOn(false)
  end
end
function Voip:ShowError(errorText)
  self.VoipSpeaker:SetColor(Color(1, 0, 0, 1))
  UiElementBus.Event.SetIsEnabled(self.ErrorText, true)
  UiElementBus.Event.SetIsEnabled(self.YouText, false)
  UiTextBus.Event.SetTextWithFlags(self.ErrorText, errorText, eUiTextSet_SetLocalized)
end
return Voip

local SocialMarkers = {
  Properties = {
    VoipSpeakerMarker = {
      default = EntityId()
    },
    ChatBubbleMarker = {
      default = EntityId()
    }
  },
  voipPoolSize = 5,
  chatPoolSize = 10
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(SocialMarkers)
local markerCommon = RequireScript("LyShineUI.Markers.MarkerCommon")
function SocialMarkers:OnInit()
  BaseScreen.OnInit(self)
  self.screenStatesToDisable = markerCommon.screenStatesToDisable
  self.voipMarkers = self:CreatePool(self.voipPoolSize, self.Properties.VoipSpeakerMarker)
  self.chatMarkers = self:CreatePool(self.chatPoolSize, self.Properties.ChatBubbleMarker)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Voip.OtherSpeakerUpdate.IsSpeaking", self.OnOtherSpeakerUpdate)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Voip.Disconnected", function(self, isDisconnected)
    local voipContainer = UiElementBus.Event.GetParent(self.Properties.VoipSpeakerMarker)
    UiElementBus.Event.SetIsEnabled(voipContainer, not isDisconnected)
    if isDisconnected then
      for _, marker in pairs(self.voipMarkers) do
        marker:SetIsSpeaking(false)
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.OnOtherPlayerChat.EntityId", function(self, playerEntityId)
    local chatMessage = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OnOtherPlayerChat.ChatMessage")
    if chatMessage and playerEntityId then
      local availableMarker = self:GetAvailablePlayerMarker(playerEntityId)
      if availableMarker then
        local markerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OnOtherPlayerChat.MarkerEntityId")
        local isMarkerVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OnOtherPlayerChat.IsMarkerVisible")
        availableMarker:SetIsChatting(true, chatMessage, playerEntityId, markerEntityId, isMarkerVisible)
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.OnOtherPlayerChatState.EntityId", function(self, playerEntityId)
    local chatState = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OnOtherPlayerChatState.State")
    if chatState and playerEntityId then
      local availableMarker = self:GetAvailablePlayerMarker(playerEntityId)
      if availableMarker then
        local isChatting = chatState == eSocialChattingState_Text
        local notChattingButHasMessage = not isChatting and availableMarker.chatMessage
        if notChattingButHasMessage then
          return
        end
        local markerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OnOtherPlayerChatState.MarkerEntityId")
        local isMarkerVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OnOtherPlayerChatState.IsMarkerVisible")
        availableMarker:SetIsChatting(isChatting, nil, playerEntityId, markerEntityId, isMarkerVisible)
      end
    end
  end)
end
function SocialMarkers:GetAvailablePlayerMarker(playerEntityId)
  local freeMarker
  for _, marker in pairs(self.chatMarkers) do
    if marker.playerEntityId == playerEntityId then
      return marker
    end
    if freeMarker == nil and marker.playerEntityId == nil then
      freeMarker = marker
    end
  end
  return freeMarker
end
function SocialMarkers:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[toState] and self.canvasId then
    self.screenStateDesiredVisibility = false
    self:UpdateCanvasVisibility()
  end
end
function SocialMarkers:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[fromState] and self.canvasId then
    self.screenStateDesiredVisibility = true
    self:UpdateCanvasVisibility()
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function SocialMarkers:UpdateCanvasVisibility()
  UiCanvasBus.Event.SetEnabled(self.canvasId, self.screenStateDesiredVisibility)
end
function SocialMarkers:CreatePool(poolSize, poolEntity)
  UiElementBus.Event.SetIsEnabled(poolEntity, false)
  local poolTable = {}
  for i = 1, poolSize do
    local clone = CloneUiElement(self.canvasId, self.registrar, poolEntity, UiElementBus.Event.GetParent(poolEntity), false)
    table.insert(poolTable, clone)
  end
  return poolTable
end
function SocialMarkers:OnOtherSpeakerUpdate(isSpeaking)
  local playerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Voip.OtherSpeakerUpdate.AccountId")
  if not playerId then
    return
  end
  if isSpeaking then
    for _, marker in pairs(self.voipMarkers) do
      if marker.playerId == nil then
        marker:SetIsSpeaking(true, playerId)
        break
      end
    end
  else
    for _, marker in pairs(self.voipMarkers) do
      if marker.playerId == playerId then
        marker:SetIsSpeaking(false)
        break
      end
    end
  end
end
return SocialMarkers

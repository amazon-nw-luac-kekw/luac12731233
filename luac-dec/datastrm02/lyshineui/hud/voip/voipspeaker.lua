local VoipSpeaker = {
  Properties = {
    Speaker = {
      default = EntityId()
    },
    Waves = {
      default = EntityId()
    }
  },
  LOCAL_PLAYER_NODE = "Hud.LocalPlayer.Voip.IsSpeaking",
  OTHER_PLAYER_NODE = "Hud.LocalPlayer.Voip.OtherSpeakerUpdate",
  DEAD_NODE = "Hud.LocalPlayer.Vitals.IsDead",
  playerId = nil,
  hideSpeaker = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(VoipSpeaker)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function VoipSpeaker:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  self:SetIsSpeaking(false)
  self:RegisterForLocalPlayer(true)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Voip.Disconnected", function(self, data)
    self:SetIsSpeaking(false)
  end)
end
function VoipSpeaker:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  self.dataLayer = nil
end
function VoipSpeaker:RegisterForLocalPlayer(doRegister)
  if doRegister then
    self.dataLayer:RegisterDataObserver(self, self.LOCAL_PLAYER_NODE, self.OnLocalPlayerSpeakingUpdate)
    self.dataLayer:RegisterDataObserver(self, self.DEAD_NODE, function(self, isDead)
      if isDead then
        self:SetIsSpeaking(false)
      end
    end)
  else
    self.dataLayer:UnregisterObserver(self, self.LOCAL_PLAYER_NODE)
    self.dataLayer:UnregisterObserver(self, self.DEAD_NODE)
  end
end
function VoipSpeaker:SetPlayer(playerId, hideSpeaker)
  self.playerId = playerId
  self.hideSpeaker = hideSpeaker
  self:SetIsSpeaking(false)
  if self.playerId then
    self:RegisterForLocalPlayer(false)
    self.dataLayer:RegisterAndExecuteObserver(self, self.OTHER_PLAYER_NODE, self.OnOtherSpeakerUpdate)
  else
    self.dataLayer:UnregisterObserver(self, self.OTHER_PLAYER_NODE)
    self:RegisterForLocalPlayer(true)
  end
end
function VoipSpeaker:SetColor(color)
  UiImageBus.Event.SetColor(self.Speaker, color)
  UiImageBus.Event.SetColor(self.Waves, color)
end
function VoipSpeaker:SetIsSpeaking(isSpeaking)
  local fade = isSpeaking and 1 or 0
  UiFaderBus.Event.SetFadeValue(self.Waves, fade)
  if self.hideSpeaker then
    UiFaderBus.Event.SetFadeValue(self.Speaker, fade)
  end
end
function VoipSpeaker:OnLocalPlayerSpeakingUpdate(isSpeaking)
  if self.playerId ~= nil then
    return
  end
  self:SetIsSpeaking(isSpeaking)
end
function VoipSpeaker:OnOtherSpeakerUpdate(dataNode)
  if not self.playerId then
    return
  end
  local playerIdNode = dataNode.AccountId
  if playerIdNode and playerIdNode:GetData() == self.playerId then
    local isSpeakingNode = dataNode.IsSpeaking
    if isSpeakingNode then
      self:SetIsSpeaking(isSpeakingNode:GetData())
    end
  end
end
return VoipSpeaker

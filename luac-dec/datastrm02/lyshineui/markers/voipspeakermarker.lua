local VoipSpeakerMarker = {
  Properties = {
    Speaker = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(VoipSpeakerMarker)
function VoipSpeakerMarker:OnInit()
  BaseElement.OnInit(self)
end
function VoipSpeakerMarker:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
end
function VoipSpeakerMarker:SetIsSpeaking(isSpeaking, playerId)
  self.playerId = playerId
  UiElementBus.Event.SetIsEnabled(self.entityId, isSpeaking)
  if isSpeaking then
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
    self.playerEntityId = LocalPlayerMarkerRequestBus.Broadcast.GetPlayerEntityIdByName(playerId)
  else
    if self.tickHandler then
      self:BusDisconnect(self.tickHandler)
      self.tickHandler = nil
    end
    self.playerEntityId = nil
  end
end
local zOffset = 1.9
function VoipSpeakerMarker:OnCrySystemPostViewSystemUpdate()
  local worldPosition = TransformBus.Event.GetWorldTranslation(self.playerEntityId)
  if not worldPosition then
    self:SetIsSpeaking(false)
    return
  end
  worldPosition.z = worldPosition.z + zOffset
  local screenPosition = LyShineManagerBus.Broadcast.ProjectToScreen(worldPosition, false, false)
  UiTransformBus.Event.SetViewportPosition(self.entityId, Vector2(screenPosition.x, screenPosition.y))
end
return VoipSpeakerMarker

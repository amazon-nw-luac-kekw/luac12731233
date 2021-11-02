local SimpleFoleyScript = {
  Properties = {
    areaTriggerEntity = {
      default = EntityId(),
      description = "Area Trigger Entity",
      order = 1
    },
    foleyEntities = {
      default = {
        EntityId()
      },
      description = "List of Foley entities to set the value of.",
      order = 2
    },
    scalar = {
      default = 100,
      description = "Number to multiple the distance by before setting as the RTPC value.",
      order = 3
    },
    preloadName = {
      default = "FLY_TorsoBoss",
      description = "Soundbank to load for the specific Foley loops",
      order = 4
    }
  }
}
function SimpleFoleyScript:OnActivate()
  if self.Properties.preloadName == "" or self.Properties.preloadName == nil then
    Debug.Log("Foley - Unit missing preload name")
    return
  end
  if self.Properties.areaTriggerEntity == nil then
    Debug.Log("Foley - Unit missing areaTriggerEntity")
    return
  end
  if self.Properties.foleyEntities == nil then
    Debug.Log("Foley - Unit missing foleyEntities")
    return
  end
  self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
  self.localTranslation = {}
  self.lastFrameTranslation = {}
  self.dataLayer = require("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
end
function SimpleFoleyScript:OnTriggerAreaEntered(entityId)
  if self.playerEntityId == entityId then
    for idx, foleyEntityId in pairs(self.Properties.foleyEntities) do
      local key = tostring(idx)
      AudioPreloadComponentRequestBus.Event.LoadPreload(foleyEntityId, self.Properties.preloadName)
      AudioTriggerComponentRequestBus.Event.Play(foleyEntityId)
      self.localTranslation[idx] = TransformBus.Event.GetLocalTranslation(foleyEntityId)
      self.lastFrameTranslation[idx] = self.localTranslation[idx]
    end
    if self.tickBusHandler == nil then
      self.tickBusHandler = TickBus.Connect(self)
    end
  end
end
function SimpleFoleyScript:OnTriggerAreaExited(entityId)
  if self.playerEntityId == entityId then
    for idx, foleyEntityId in pairs(self.Properties.foleyEntities) do
      AudioTriggerComponentRequestBus.Event.Stop(foleyEntityId)
      AudioPreloadComponentRequestBus.Event.UnloadPreload(foleyEntityId, self.Properties.preloadName)
    end
    if self.tickBusHandler ~= nil then
      self.tickBusHandler:Disconnect()
      self.tickBusHandler = nil
    end
  end
end
function SimpleFoleyScript:OnTick(deltaTime, timePoint)
  for idx, foleyEntityId in pairs(self.Properties.foleyEntities) do
    if foleyEntityId ~= nil then
      self.localTranslation[idx] = TransformBus.Event.GetLocalTranslation(foleyEntityId)
      local deltaTranslation
      if self.localTranslation[idx] ~= nil and self.lastFrameTranslation[idx] ~= nil then
        deltaTranslation = self.localTranslation[idx] - self.lastFrameTranslation[idx]
      else
        deltaTranslation = Vector3(0, 0, 0)
      end
      local deltaDistance = Vector3.GetLength(deltaTranslation) * self.Properties.scalar
      local rtpcValue = deltaDistance / deltaTime
      AudioRtpcComponentRequestBus.Event.SetValue(foleyEntityId, rtpcValue)
      self.lastFrameTranslation[idx] = self.localTranslation[idx]
    end
  end
end
function SimpleFoleyScript:OnDeactivate()
  AudioTriggerComponentRequestBus.Event.KillAllTriggers(self.entityId)
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
  end
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return SimpleFoleyScript

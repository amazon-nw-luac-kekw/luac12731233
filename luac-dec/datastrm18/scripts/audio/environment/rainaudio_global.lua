local RainAudio = {
  Properties = {
    Rain_EntityId = {
      default = EntityId(),
      description = "Root EntityId",
      order = 1
    },
    TriggerAreaEntity = {
      default = EntityId(),
      description = "EntityId of the TriggerArea component",
      order = 2
    },
    updateTime = {
      default = 1,
      description = "Time it takes to onTick to wait until the next computation",
      order = 5
    }
  }
}
function RainAudio:OnActivate()
  if self.triggerAreaBusHandler == nil then
    self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.TriggerAreaEntity)
  end
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
  self.deltaTime = 0
  self.rainDropAmount = RainComponentRequestBus.Event.GetRainDropsAmount(self.Properties.Rain_EntityId)
  self.rainAmount = RainComponentRequestBus.Event.GetAmount(self.Properties.Rain_EntityId)
  self.innerRadius = RainComponentRequestBus.Event.GetInnerRadius(self.Properties.Rain_EntityId)
  self.outerRadius = RainComponentRequestBus.Event.GetOuterRadius(self.Properties.Rain_EntityId)
end
function RainAudio:OnTriggerAreaEntered(entityId)
  if entityId == self.playerEntityId and TagComponentRequestBus.Event.HasTag(self.entityId, 3599956300) then
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Weather", "Rain")
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.playerEntityId, "Weather", "Rain")
    self:OnTickConnection(true)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.playerEntityId, "Play_QuadAmb_Rain")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.playerEntityId, "Play_FLY_Weather_Chest")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.playerEntityId, "Play_FLY_Weather_Helmet")
  end
end
function RainAudio:OnTriggerAreaExited(entityId)
  if entityId == self.playerEntityId and TagComponentRequestBus.Event.HasTag(self.entityId, 3599956300) then
    self:setClearWeather()
  end
end
function RainAudio:setClearWeather()
  AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Weather", "Clear")
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.playerEntityId, "Weather", "Clear")
  self:OnTickConnection(false)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.playerEntityId, "Stop_QuadAmb_Rain")
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.playerEntityId, "Stop_FLY_Weather_Chest")
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.playerEntityId, "Stop_FLY_Weather_Helmet")
end
function RainAudio:OnTickConnection(bool)
  if bool == true then
    if self.tickBusHandler == nil then
      self.tickBusHandler = TickBus.Connect(self)
    end
  elseif self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
end
function RainAudio:OnTick(deltaTime, timePoint)
  self.deltaTime = self.deltaTime + deltaTime
  if self.deltaTime > self.Properties.updateTime then
    local playerPosition = TransformBus.Event.GetWorldTranslation(self.playerEntityId)
    local rainPosition = TransformBus.Event.GetWorldTranslation(self.Properties.Rain_EntityId)
    if playerPosition ~= nil and rainPosition ~= nil then
      local distance = Vector3.GetDistance(playerPosition, rainPosition)
      local distanceScaled = 1
      if distance < self.innerRadius then
        distanceScaled = 0
      elseif distance > self.outerRadius then
        distanceScaled = 1
      else
        distanceScaled = (distance - self.innerRadius) / (self.outerRadius - self.innerRadius)
      end
      AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Area_Rain_Distance", distanceScaled)
    end
    self.deltaTime = 0
  end
end
function RainAudio:OnDeactivate()
  self:setClearWeather()
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return RainAudio

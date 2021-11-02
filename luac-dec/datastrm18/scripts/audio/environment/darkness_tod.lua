local Darkness_ToD = {
  Properties = {
    ShapeEntity = {
      default = EntityId(),
      description = "EntityId of the shape component",
      order = 1
    },
    TriggerAreaEntity = {
      default = EntityId(),
      description = "EntityId of the TriggerArea component",
      order = 2
    },
    updateTime = {
      default = 0.1,
      description = "Time it takes to onTick to wait until the next computation",
      order = 3
    }
  }
}
function Darkness_ToD:OnActivate()
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
  local rootID = TransformBus.Event.GetRootId(self.entityId)
  local entityName = GameEntityContextRequestBus.Broadcast.GetEntityName(rootID)
  if self.Properties.ShapeEntity then
    local shapeAabb = ShapeComponentRequestsBus.Event.GetEncompassingAabb(self.Properties.ShapeEntity)
    if shapeAabb then
      self.shapeRadius = shapeAabb:GetWidth() / 2
    else
      Debug.Log("#### AUDIO <" .. entityName .. "> has no shape entity Aabb")
      return
    end
  else
    Debug.Log("#### AUDIO <" .. entityName .. "> is missing a shape entity")
  end
  self.deltaTime = 0
  self.hasEnteredDarkness = false
  if self.triggerAreaBusHandler == nil then
    self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.TriggerAreaEntity)
  end
end
function Darkness_ToD:OnTriggerAreaEntered(entityId)
  if entityId == self.playerEntityId and self.tickBusHandler == nil then
    self.tickBusHandler = TickBus.Connect(self)
  end
  if self.VitalsComponentBusHandler == nil then
    self.VitalsComponentBusHandler = VitalsComponentNotificationBus.Connect(self, self.playerEntityId)
  end
  if self.audioDarknessMusicBusHandler == nil then
    self.audioDarknessMusicBusHandler = DynamicBus.audioDarknessMusicBus.Connect(self.entityId, self)
  end
  DynamicBus.audioDarknessMusicBus.Event.RegisterDarknessEventDB(self.playerEntityId, self.entityId, true)
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.playerEntityId, "Decals", "corruption")
  self.hasEnteredDarkness = true
end
function Darkness_ToD:OnTick(deltaTime, timePoint)
  self.deltaTime = self.deltaTime + deltaTime
  if self.deltaTime > self.Properties.updateTime and self.playerEntityId ~= nil and self.shapeRadius ~= nil and self.shapeRadius ~= 0 then
    local playerPosition = TransformBus.Event.GetWorldTranslation(self.playerEntityId)
    local darknessPosition = TransformBus.Event.GetWorldTranslation(self.Properties.ShapeEntity)
    local distance = Vector3.GetDistance(playerPosition, darknessPosition)
    if distance <= self.shapeRadius then
      local distanceScaled = distance / self.shapeRadius
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.ShapeEntity, "Area_Darkness_Distance", distanceScaled)
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.playerEntityId, "Area_Darkness_Distance", distanceScaled)
      AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Area_Darkness_Distance", distanceScaled)
    end
    self.deltaTime = 0
  end
end
function Darkness_ToD:OnTriggerAreaExited(entityId)
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.VitalsComponentBusHandler ~= nil then
    self.VitalsComponentBusHandler:Disconnect()
    self.VitalsComponentBusHandler = nil
  end
  self.hasEnteredDarkness = false
  DynamicBus.audioDarknessMusicBus.Event.RegisterDarknessEventDB(self.playerEntityId, self.entityId, false)
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.playerEntityId, "Decals", "default")
  self:ResetRTPC()
end
function Darkness_ToD:OnDeath()
  if self.hasEnteredDarkness then
    self:OnTriggerAreaExited(self.playerEntityId)
  end
end
function Darkness_ToD:ResetRTPC()
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.ShapeEntity, "Area_Darkness_Distance", 1)
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.playerEntityId, "Area_Darkness_Distance", 1)
  AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Area_Darkness_Distance", 1)
end
function Darkness_ToD:OnDeactivate()
  if self.hasEnteredDarkness then
    self:ResetRTPC()
  end
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.VitalsComponentBusHandler ~= nil then
    self.VitalsComponentBusHandler:Disconnect()
    self.VitalsComponentBusHandler = nil
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return Darkness_ToD

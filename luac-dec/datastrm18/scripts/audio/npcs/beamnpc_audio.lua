beamAudioScript = {
  beamAttackBusHandler = nil,
  rootEntityId = nil,
  Properties = {
    beamSourceEntity = {
      default = EntityId(),
      description = "Beam Source EntityId",
      order = 1
    },
    beamHitEntity = {
      default = EntityId(),
      description = "Beam Hit EntityId",
      order = 2
    },
    onActive_SFX_Source = {
      default = {""},
      description = "Name of the ATL event",
      order = 3
    },
    onInactive_SFX_Source = {
      default = {""},
      description = "Name of the ATL event",
      order = 4
    },
    onActive_SFX_BeamHit = {
      default = {""},
      description = "Name of the ATL event",
      order = 5
    },
    onInactive_SFX_BeamHit = {
      default = {""},
      description = "Name of the ATL event",
      order = 6
    },
    followLocalPlayer = {
      default = false,
      description = "Follow the player position if set to true",
      order = 7
    },
    followerEntity = {
      default = EntityId(),
      description = "Entity following the player on the line",
      order = 8
    },
    onActive_SFX_Follower = {
      default = {""},
      description = "Name of the ATL event",
      order = 9
    },
    onInactive_SFX_Follower = {
      default = {""},
      description = "Name of the ATL event",
      order = 10
    }
  }
}
function beamAudioScript:OnActivate()
  self.deltaTime = 0
  self.onSetBeamActive = 0
  self.rootEntityId = TransformBus.Event.GetRootId(self.entityId)
  self.beamAttackBusHandler = BeamAttackComponentNotificationBus.Connect(self, self.rootEntityId)
  if self.tickBusHandler == nil then
    self.tickBusHandler = TickBus.Connect(self)
  end
end
function beamAudioScript:OnDeactivate()
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.beamAttackBusHandler ~= nil then
    self.beamAttackBusHandler:Disconnect()
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
function beamAudioScript:OnSetBeamActive(nameCRC, active)
  self.nameCRC = nameCRC
  if self.Properties.followLocalPlayer then
    self.dataLayer = require("LyShineUI.UiDataLayer")
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
      if playerEntityId ~= nil then
        self.playerEntityId = playerEntityId
      end
    end)
  end
  if active then
    self.onSetBeamActive = self.onSetBeamActive + 1
    for idx, onActive_SFX_Source in pairs(self.Properties.onActive_SFX_Source) do
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamSourceEntity, onActive_SFX_Source)
    end
    for idx, onActive_SFX_BeamHit in pairs(self.Properties.onActive_SFX_BeamHit) do
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamHitEntity, onActive_SFX_BeamHit)
    end
    for idx, onActive_SFX_Follower in pairs(self.Properties.onActive_SFX_Follower) do
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.followerEntity, onActive_SFX_Follower)
    end
  else
    self.onSetBeamActive = self.onSetBeamActive - 1
    for idx, onInactive_SFX_Source in pairs(self.Properties.onInactive_SFX_Source) do
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamSourceEntity, onInactive_SFX_Source)
    end
    for idx, onInactive_SFX_BeamHit in pairs(self.Properties.onInactive_SFX_BeamHit) do
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamHitEntity, onInactive_SFX_BeamHit)
    end
    for idx, onInactive_SFX_Follower in pairs(self.Properties.onInactive_SFX_Follower) do
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.followerEntity, onInactive_SFX_Follower)
    end
  end
end
function beamAudioScript:OnTick(deltaTime, timePoint)
  self.deltaTime = self.deltaTime + deltaTime
  if self.deltaTime > 0.1 and self.onSetBeamActive > 0 and self.nameCRC ~= nil then
    local hitPos = BeamAttackComponentRequestBus.Event.GetBeamHitPos(self.rootEntityId, self.nameCRC)
    if self.Properties.beamHitEntity ~= nil and hitPos ~= nil then
      TransformBus.Event.SetWorldTranslation(self.Properties.beamHitEntity, hitPos)
    end
    if self.Properties.followLocalPlayer and self.Properties.followerEntity ~= nil then
      local playerPos = TransformBus.Event.GetWorldTranslation(self.playerEntityId)
      local sourcePos = TransformBus.Event.GetWorldTranslation(self.Properties.beamSourceEntity)
      local hitMinusSource = hitPos - sourcePos
      local beamDir = hitMinusSource:GetNormalized()
      local beamLength = hitMinusSource:GetLength()
      local sourceToPlayerPos = playerPos - sourcePos
      local dotProd = beamDir:Dot(sourceToPlayerPos)
      local audioEntityPos
      if dotProd < 0 then
        audioEntityPos = sourcePos
      elseif beamLength < dotProd then
        audioEntityPos = hitPos
      else
        audioEntityPos = sourcePos + beamDir * dotProd
      end
      if audioEntityPos ~= nil then
        TransformBus.Event.SetWorldTranslation(self.Properties.followerEntity, audioEntityPos)
      end
    end
    self.deltaTime = 0
  end
end
return beamAudioScript

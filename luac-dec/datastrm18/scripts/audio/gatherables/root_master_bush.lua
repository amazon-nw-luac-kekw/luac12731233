local rootmasterbush = {
  Properties = {
    Root_Entity = {
      default = EntityId(),
      description = "Root entity",
      order = 1
    },
    TriggerArea_Entity = {
      default = EntityId(),
      description = "Select the entity containing the area trigger component",
      order = 2
    },
    CollisionFX_Entity = {
      default = EntityId(),
      description = "Entity having the SFX and VFX components",
      order = 3
    },
    MaxDistanceRendering = {
      default = 50,
      description = "Max distance at which SFX and VFX will be triggered from",
      order = 4
    },
    vfx_Scalar = {
      default = 0.15,
      description = "Scalar to offset Particle z axis",
      order = 5
    },
    vfx_Clamping_Value = {
      default = 6,
      description = "vfx clamping value to avoid speed oversizing particle count scale",
      order = 6
    },
    entity_Speed_Scalar = {
      default = 0.1,
      description = "Scalar reducing speed value of the entity entering",
      order = 7
    },
    updateTime = {
      default = 0.1,
      description = "Time it takes to onTick to wait until the next comnputation",
      order = 8
    },
    LocalPlayerOnly = {
      default = true,
      description = "Script will only work for local player. If disabled, any players can use it",
      order = 9
    }
  }
}
function rootmasterbush:OnActivate()
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
  self.enteringEntityId = nil
  self.inAreaTrigger = false
  self.inSphere = false
  self.entityWorldTranslation = nil
  self.prevWorldPos = nil
  self.deltaTime = 0
  self.sphereRadius = nil
  if self.triggerAreaBusHandler == nil then
    self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.TriggerArea_Entity)
  end
  self.transformOffset = Transform.CreateTranslation(Vector3(0, 0, 0))
end
function rootmasterbush:OnTriggerAreaEntered(entityId)
  if self.Properties.LocalPlayerOnly then
    if self.playerEntityId == entityId then
      self:InitializeBushSound(self.playerEntityId)
    end
  else
    self:InitializeBushSound(entityId)
  end
end
function rootmasterbush:InitializeBushSound(entityId)
  if self.sphereRadius == nil then
    local shapeType = ShapeComponentRequestsBus.Event.GetShapeType(self.Properties.Root_Entity)
    if shapeType == 1442408071 then
      local sphereShapeConfig = SphereShapeComponentRequestsBus.Event.GetSphereConfiguration(self.Properties.Root_Entity)
      self.sphereRadius = sphereShapeConfig.Radius
    else
      local shapeAabb = ShapeComponentRequestsBus.Event.GetEncompassingAabb(self.Properties.Root_Entity)
      self.sphereRadius = shapeAabb:GetWidth() / 2
    end
  end
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) or TagComponentRequestBus.Event.HasTag(entityId, 2491369782) then
    if self.VitalsComponentBusHandler == nil then
      self.VitalsComponentBusHandler = VitalsComponentNotificationBus.Connect(self, TransformBus.Event.GetRootId(entityId))
    end
    local characterPosition = TransformBus.Event.GetWorldTranslation(entityId)
    local bushPosition = TransformBus.Event.GetWorldTranslation(self.Properties.Root_Entity)
    local bushDistance = Vector3.GetDistance(bushPosition, characterPosition)
    if not self.inAreaTrigger and bushDistance < self.Properties.MaxDistanceRendering then
      self.inAreaTrigger = true
      self.enteringEntityId = entityId
      self.tickBusHandler = TickBus.Connect(self)
    end
  end
end
function rootmasterbush:OnTick(deltaTime, timePoint)
  self.deltaTime = self.deltaTime + deltaTime
  if self.deltaTime > self.Properties.updateTime and self.enteringEntityId ~= nil and self.sphereRadius ~= nil then
    self.entityWorldTranslation = TransformBus.Event.GetWorldTranslation(self.enteringEntityId)
    local bushWorldTranslation = TransformBus.Event.GetWorldTranslation(self.Properties.Root_Entity)
    local bushDistance = Vector3.GetDistance(bushWorldTranslation, self.entityWorldTranslation)
    if bushDistance <= self.sphereRadius then
      local bushDistScaled = bushDistance / self.sphereRadius
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.CollisionFX_Entity, "Dist_ToBush", bushDistScaled)
      if not self.inSphere then
        self.inSphere = true
        AudioTriggerComponentRequestBus.Event.Play(self.Properties.CollisionFX_Entity)
        AttachmentComponentRequestBus.Event.Attach(self.Properties.CollisionFX_Entity, self.enteringEntityId, 0, self.transformOffset, 0)
      end
      if self.prevWorldPos ~= nil then
        if self.prevWorldPos ~= self.entityWorldTranslation then
          local distTravelled = Vector3.GetDistance(self.entityWorldTranslation, self.prevWorldPos)
          local distDelta = distTravelled / deltaTime
          local entitySpeed = math.abs(distDelta) * self.Properties.entity_Speed_Scalar
          AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.CollisionFX_Entity, "Speed_InBush", entitySpeed)
        else
          AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.CollisionFX_Entity, "Speed_InBush", 0)
        end
      end
    elseif self.inSphere then
      self.inSphere = false
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.CollisionFX_Entity, "Speed_InBush", 0)
      AttachmentComponentRequestBus.Event.Detach(self.Properties.CollisionFX_Entity)
      AudioTriggerComponentRequestBus.Event.Stop(self.Properties.CollisionFX_Entity)
    end
    self.deltaTime = 0
    self.prevWorldPos = self.entityWorldTranslation
  end
end
function rootmasterbush:OnDeath()
  self:StopAllEffects()
end
function rootmasterbush:StopAllEffects()
  self.inSphere = false
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.CollisionFX_Entity, "Speed_InBush", 0)
  AttachmentComponentRequestBus.Event.Detach(self.Properties.CollisionFX_Entity)
  AudioTriggerComponentRequestBus.Event.Stop(self.Properties.CollisionFX_Entity)
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.VitalsComponentBusHandler ~= nil then
    self.VitalsComponentBusHandler:Disconnect()
    self.VitalsComponentBusHandler = nil
  end
  self.enteringEntityId = nil
  self.inAreaTrigger = false
end
function rootmasterbush:OnTriggerAreaExited(entityId)
  if self.enteringEntityId ~= nil and self.enteringEntityId == entityId then
    self:StopAllEffects()
  end
end
function rootmasterbush:OnDeactivate()
  self:StopAllEffects()
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return rootmasterbush

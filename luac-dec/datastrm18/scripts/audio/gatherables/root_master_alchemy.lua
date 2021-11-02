require("Scripts.Utils.TimingUtils")
local root_master_alchemy = {
  Properties = {
    TriggerAreaEntity = {
      default = EntityId(),
      description = "Select the entity containing the area trigger component",
      order = 1
    },
    FX_01 = {
      default = EntityId(),
      description = "Set the 1st particle entityId",
      order = 2
    },
    FX_02 = {
      default = EntityId(),
      description = "Set the 2nd particle entityId",
      order = 3
    },
    FX_03 = {
      default = EntityId(),
      description = "Set the 3rd particle entityId",
      order = 4
    },
    TimeInterval = {
      default = 1,
      description = "Time it takes to loop effects",
      order = 5
    },
    MinRandomTime = {
      default = 0.8,
      description = "Minimum random",
      order = 6
    },
    MaxRandomTime = {
      default = 1,
      description = "Maximum random",
      order = 7
    }
  }
}
function root_master_alchemy:OnActivate()
  self.firstTimeInterval = 0
  self.alreadyEntered = false
  self.triggerAreaHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.TriggerAreaEntity)
  self.deltaTime = 0
  self.effectsEnabled = false
  self.fxIDs = {}
  self.randomNum = nil
  if self.Properties.FX_01 ~= nil then
    local effect01 = self.Properties.FX_01
    table.insert(self.fxIDs, effect01)
  end
  if self.Properties.FX_02 ~= nil then
    local effect02 = self.Properties.FX_02
    table.insert(self.fxIDs, effect02)
  end
  if self.Properties.FX_03 ~= nil then
    local effect03 = self.Properties.FX_03
    table.insert(self.fxIDs, effect03)
  end
end
function root_master_alchemy:OnTriggerAreaEntered(EntityId)
  if TagComponentRequestBus.Event.HasTag(EntityId, 2866540111) and self.alreadyEntered == false then
    self.alreadyEntered = true
    self.effectsEnabled = true
    self.tickBusHandler = TickBus.Connect(self)
    for k = table.maxn(self.fxIDs), 1, -1 do
      if self.fxIDs[k] ~= nil then
        AudioPreloadComponentRequestBus.Event.Load(self.fxIDs[k])
      end
    end
  end
end
function root_master_alchemy:OnTriggerAreaExited(EntityId)
  if TagComponentRequestBus.Event.HasTag(EntityId, 2866540111) and self.alreadyEntered == true then
    self:StopAllEffects()
    if self.fxIDs[self.randomNum] ~= nil then
      ParticleComponentRequestBus.Event.Enable(self.fxIDs[self.randomNum], false)
    end
    for k = table.maxn(self.fxIDs), 1, -1 do
      if self.fxIDs[k] ~= nil then
        AudioPreloadComponentRequestBus.Event.Unload(self.fxIDs[k])
      end
    end
    self.firstTimeInterval = 0
  end
end
function root_master_alchemy:OnTick(deltaTime, timePoint)
  if self.effectsEnabled == true then
    self.deltaTime = self.deltaTime + deltaTime
    local minRandTime = math.random()
    local minRandTime = minRandTime * self.Properties.MinRandomTime
    local maxRandTime = math.random()
    local maxRandTime = maxRandTime * self.Properties.MaxRandomTime
    self.updateTime = (self.Properties.TimeInterval - minRandTime + maxRandTime) * self.firstTimeInterval
    if self.deltaTime > self.updateTime then
      local ParticlePos = TransformBus.Event.GetWorldTranslation(self.entityId)
      local ParticleNormal = Vector3(1, 1, 1)
      self.randomNum = math.random(1, table.maxn(self.fxIDs))
      if self.randomNum ~= nil then
        self.effectId = ParticleComponentRequestBus.Event.Enable(self.fxIDs[self.randomNum], true)
        local size_rtpc = self.randomNum * 33
        AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.fxIDs[self.randomNum], "Particle_Size", size_rtpc)
        AudioTriggerComponentRequestBus.Event.Play(self.fxIDs[self.randomNum])
      end
      self.deltaTime = self.deltaTime - self.updateTime
      self.firstTimeInterval = 1
    end
  end
end
function root_master_alchemy:StopAllEffects()
  self.alreadyEntered = false
  self.effectsEnabled = false
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
end
function root_master_alchemy:OnDeactivate()
  self.triggerAreaHandler:Disconnect()
  self.triggerAreaHandler = nil
  self:StopAllEffects()
end
return root_master_alchemy

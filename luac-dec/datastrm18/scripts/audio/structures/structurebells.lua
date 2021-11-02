local StructureBells = {
  Properties = {
    area_trigger_entity = {
      default = EntityId(),
      description = "Main area trigger entity used to activate the script",
      order = 1
    },
    bell_audio_entity = {
      default = EntityId(),
      description = "Bell Trigger Entity",
      order = 3
    },
    bell_ATL_Hour_name = {
      default = "Play_Bell_Church_C_3_Single",
      description = "Name of the bell sound to play each hour",
      order = 4
    },
    bell_ATL_12Hour_name = {
      default = "Play_Bell_Church_C_3_Multi",
      description = "Name of the bell sound to play when 12 hour strikes",
      order = 5
    }
  }
}
function StructureBells:OnActivate()
  self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.area_trigger_entity)
  self.deltaTime = 0
  self.previousHour = nil
end
function StructureBells:OnTriggerAreaEntered(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer and self.tickBusHandler == nil then
    self.tickBusHandler = TickBus.Connect(self)
  end
end
function StructureBells:OnTriggerAreaExited(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer then
    if self.tickBusHandler ~= nil then
      self.tickBusHandler:Disconnect()
      self.tickBusHandler = nil
    end
    self.deltaTime = 0
  end
end
function StructureBells:OnTick(deltaTime, timePoint)
  self.deltaTime = self.deltaTime + deltaTime
  if self.deltaTime > 1 then
    local gameTime = LyShineScriptBindRequestBus.Broadcast.GetGameTime()
    local currentHour = math.floor(gameTime / 3600)
    local currentMinute = math.floor(gameTime / 60) % 60
    local currentSecond = gameTime % 60
    if self.previousHour ~= currentHour and currentMinute <= 1 then
      if currentHour == 12 or currentHour == 24 then
        AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.bell_audio_entity, self.Properties.bell_ATL_12Hour_name)
      else
        AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.bell_audio_entity, self.Properties.bell_ATL_Hour_name)
      end
      self.previousHour = currentHour
    end
    self.deltaTime = 0
  end
end
function StructureBells:OnDeactivate()
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
end
return StructureBells

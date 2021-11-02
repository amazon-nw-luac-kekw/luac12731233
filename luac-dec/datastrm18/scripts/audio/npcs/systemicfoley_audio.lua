local audioScriptLimiter = RequireScript("Scripts.Audio.NPCs.scriptLimiter_audio")
local SystemicFoley = {
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
      default = "LeatherLight",
      description = "Soundbank to load for the specific Foley loops",
      order = 4
    }
  }
}
function SystemicFoley:OnActivate()
  audioScriptLimiter:OnActivate()
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
  self.limbCount = 0
  self.localTranslation = {}
  self.lastFrameTranslation = {}
  self.playEventNames = {}
  self.stopEventNames = {}
  self.limbNameConcatenator = {}
  for idx, foleyEntityId in pairs(self.Properties.foleyEntities) do
    self.limbCount = self.limbCount + 1
  end
  if self.limbCount == 2 then
    self.limbNameConcatenator["0"] = "_Leg_L"
    self.limbNameConcatenator["1"] = "_Leg_R"
  else
    self.limbNameConcatenator["0"] = "_Arm_L"
    self.limbNameConcatenator["1"] = "_Arm_R"
    self.limbNameConcatenator["2"] = "_Leg_L"
    self.limbNameConcatenator["3"] = "_Leg_R"
  end
  self.dataLayer = require("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
  self.preloadSoundbankName = "FLY_" .. tostring(self.Properties.preloadName)
  for idx, foleyEntityId in pairs(self.Properties.foleyEntities) do
    local key = tostring(idx)
    self.playEventNames[foleyEntityId] = "Play_FLY_" .. tostring(self.Properties.preloadName) .. tostring(self.limbNameConcatenator[key])
    self.stopEventNames[foleyEntityId] = "Stop_FLY_" .. tostring(self.Properties.preloadName) .. tostring(self.limbNameConcatenator[key])
  end
end
function SystemicFoley:OnTriggerAreaEntered(entityId)
  if self.playerEntityId == entityId then
    if not audioScriptLimiter:CanActivateMore() then
      return
    end
    audioScriptLimiter:Activated()
    self.isActivated = true
    for idx, foleyEntityId in pairs(self.Properties.foleyEntities) do
      local key = tostring(idx)
      AudioPreloadComponentRequestBus.Event.LoadPreload(foleyEntityId, self.preloadSoundbankName)
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(foleyEntityId, self.playEventNames[foleyEntityId])
      self.localTranslation[idx] = TransformBus.Event.GetLocalTranslation(foleyEntityId)
      self.lastFrameTranslation[idx] = self.localTranslation[idx]
    end
    if self.tickBusHandler == nil then
      self.tickBusHandler = TickBus.Connect(self)
    end
  end
end
function SystemicFoley:OnTriggerAreaExited(entityId)
  if self.playerEntityId == entityId then
    if self.isActivated then
      audioScriptLimiter:Deactivated()
    end
    for idx, foleyEntityId in pairs(self.Properties.foleyEntities) do
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(foleyEntityId, self.stopEventNames[foleyEntityId])
      AudioPreloadComponentRequestBus.Event.UnloadPreload(foleyEntityId, self.preloadSoundbankName)
    end
    if self.tickBusHandler ~= nil then
      self.tickBusHandler:Disconnect()
      self.tickBusHandler = nil
    end
    self.isActivated = false
  end
end
function SystemicFoley:OnTick(deltaTime, timePoint)
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
function SystemicFoley:OnDeactivate()
  AudioTriggerComponentRequestBus.Event.KillAllTriggers(self.entityId)
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
  end
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.isActivated then
    audioScriptLimiter:Deactivated()
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return SystemicFoley

local CeilingRaycastLimiterNPC = RequireScript("Scripts.Audio.NPCs.ceilingRaycastLimiterNPC_Audio")
local ceilingRaycastAudioNPC = RequireScript("Scripts.Audio.NPCs.ceilingRaycastNPC_Audio")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local commonNPScript = {
  Properties = {}
}
function commonNPScript:OnActivate()
  if not self.acousticList then
    self.acousticList = {
      "00_Small",
      "00_Small",
      "01_Medium",
      "01_Medium",
      "02_Big",
      "03_Large",
      "03_Large"
    }
    self.acousticRange = {
      0,
      5,
      10,
      15,
      20,
      25,
      30
    }
  end
  self.dataLayer = dataLayer
  self.isDead = VitalsComponentRequestBus.Event.IsDead(self.entityId)
  if self.isDead then
    return
  else
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
      if playerEntityId then
        if self.playerEntityId and self.playerEntityId ~= playerEntityId then
          self:OnDeactivate()
        end
        self.playerEntityId = playerEntityId
        DynamicBus.audioAITrackerBus.Event.OnNPCActivated(self.playerEntityId, self.entityId)
        self.isPlayingVoice = false
        self.rtpcHDRPriority = 0
        self.refreshRate = 1
        self.npcDeltaTime = 0
        self.myTag = nil
        self.bankName = nil
        self.isTargetingPlayer = nil
        self.prevEnvName = nil
        self.envName = nil
        self.acouName = nil
        self.audioAITrackerBusHandler = DynamicBus.audioAITrackerBus.Connect(self.entityId, self)
        self.TopRaycastNPCBusHandler = DynamicBus.TopRaycastNPC.Connect(self.entityId, self)
        self.VitalsComponentBusHandler = VitalsComponentNotificationBus.Connect(self, self.entityId)
        self.TransformNotificationBusHandler = TransformNotificationBus.Connect(self, self.entityId)
        self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
        AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityId, "NetworkType", 100)
        AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityId, "rtpc_HDRPriority", 0)
        self:InitNPCAudioSystem()
        CeilingRaycastLimiterNPC:OnActivate()
      end
    end)
  end
end
function commonNPScript:OnTransformChanged(localTm, worldTm)
  if self.TransformNotificationBusHandler then
    self.TransformNotificationBusHandler:Disconnect()
    self.TransformNotificationBusHandler = nil
  end
  self.npcWorldPosition = TransformBus.Event.GetWorldTranslation(self.entityId)
  ceilingRaycastAudioNPC:OnActivate(self.entityId, self.npcWorldPosition)
end
function commonNPScript:TriggerCharacterEvent(eventName, shouldPlay, jointId)
  if eventName == nil or self.myTag == nil then
    return
  else
    if not shouldPlay then
      self.prefix = "Stop_"
    else
      self.prefix = "Play_"
    end
    local wwiseTrigger
    if string.match(eventName, "VOX_") then
      local lineParts = StringSplit(eventName, "_")
      wwiseTrigger = self.prefix .. "VOX_" .. self.myTag .. "_" .. tostring(lineParts[2])
      if lineParts[3] then
        wwiseTrigger = wwiseTrigger .. "_" .. lineParts[3]
      end
      if lineParts[4] then
        wwiseTrigger = wwiseTrigger .. "_" .. lineParts[4]
      end
    elseif shouldPlay and string.match(eventName, "BlockBreaker") then
      self:BlockBreaker()
    elseif shouldPlay and string.match(eventName, "Bodyfall") then
      wwiseTrigger = self.prefix .. eventName
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, wwiseTrigger)
    elseif shouldPlay and string.match(eventName, "Ground_Slam") then
      wwiseTrigger = self.prefix .. "SFX_" .. self.myTag .. "_" .. eventName
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, wwiseTrigger)
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_NPC_Ground_Slam")
    elseif shouldPlay and string.match(eventName, "Voice") then
      self:StartVoice()
    else
      wwiseTrigger = self.prefix .. "SFX_" .. self.myTag .. "_" .. eventName
    end
    self:PlaySounds(wwiseTrigger, jointId)
  end
end
function commonNPScript:IsTriggerValid(wwiseTrigger)
  controlID = AudioTriggerComponentRequestBus.Event.GetTriggerID(self.entityId, wwiseTrigger)
  return controlID ~= 0
end
function commonNPScript:PlaySounds(wwiseTrigger, jointId)
  if wwiseTrigger and self:IsTriggerValid(wwiseTrigger) then
    AudioTriggerComponentRequestBus.Event.ExecuteTriggerOnJoint(self.entityId, wwiseTrigger, jointId)
  end
end
function commonNPScript:BlockBreaker()
  AudioTriggerComponentRequestBus.Event.KillAllTriggers(self.entityId)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_GPUI_BlockBreaker")
end
function commonNPScript:InitNPCAudioSystem()
  if rawget(_G, "NPCTags") == nil then
    if self.AudioUtilsEventBusHandler == nil then
      self.AudioUtilsEventBusHandler = AudioUtilsEventBus.Connect(self, self.entityId)
    end
    self.loadingCsvTemp = "Valid_Npc_Tags.csv"
    AudioUtilsBus.Broadcast.LoadFileAsync("@assets@/Sounds/wwise/Valid_Npc_Tags.csv", self.entityId)
    return
  end
  self.myTag = nil
  for key, tagString in pairs(_G.NPCTags) do
    if TagComponentRequestBus.Event.HasTag(self.entityId, Math.CreateCrc32(tagString)) then
      self.myTag = tagString
      break
    end
  end
  if self.myTag == nil then
    return
  end
  self.bankName = "npc_" .. self.myTag
  AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, self.bankName)
  AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, "bodyfalls")
  self.characterEventBusHandler = CharacterEventBus.Connect(self, self.entityId)
  self:StartVoice()
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_GPUI_Spawn_NPC")
end
function commonNPScript:parseTxtFile(rawMappingsString)
  rawMappingsString = tostring(rawMappingsString)
  local csvFileData = {}
  local indexEvents = 1
  local indexEventIds = 1
  for s in rawMappingsString:gmatch("[^\r\n\",]+") do
    table.insert(csvFileData, s)
  end
  return csvFileData
end
function commonNPScript:OnAsyncFileLoadComplete(fileData)
  if self.AudioUtilsEventBusHandler then
    self.AudioUtilsEventBusHandler:Disconnect()
    self.AudioUtilsEventBusHandler = nil
  end
  _G.NPCTags = self:parseTxtFile(fileData)
  self:InitNPCAudioSystem()
end
function commonNPScript:OnTargetingPlayerHDR(enable)
  if enable then
    self:AddBusses()
    self.isTargetingPlayer = true
    self:StopVoice()
  else
    self:RemoveBusses()
    self.isTargetingPlayer = false
    self:StartVoice()
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityId, "rtpc_HDRPriority", 0)
  end
end
function commonNPScript:onTopRayHitNPC(getHitCount, dist2Player, surfaceType, entityId, entityName)
  if getHitCount == 0 then
    self:setAcoustics(0, "Acou_Ext")
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_FL", 1)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_FR", 1)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_BR", 1)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_BL", 1)
  else
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_FL", 0)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_FR", 0)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_BR", 0)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_BL", 0)
    if surfaceType and (surfaceType == 109 or surfaceType == 104 or surfaceType == 0) then
      for i = 1, #self.acousticRange do
        if dist2Player < self.acousticRange[i] and (i == 1 or dist2Player > self.acousticRange[i - 1]) then
          if self.surfaceType == 104 or self.surfaceType == 0 then
            self.envName = "ENV_INT_" .. tostring(self.acousticList[i])
            self.acouName = "Acou_Int_" .. tostring(self.acousticList[i])
          else
            self.envName = "ENV_INT_" .. tostring(self.acousticList[i]) .. "_Stone"
            self.acouName = "Acou_Int_" .. tostring(self.acousticList[i]) .. "_Stone"
          end
          self:setAcoustics(1, self.acouName)
        end
      end
    end
  end
end
function commonNPScript:OnTriggerAreaEntered(entityId)
  VegetationAudioRequestBus.Event.StartVegetationProcessing(self.entityId)
end
function commonNPScript:OnTriggerAreaExited(entityId)
  VegetationAudioRequestBus.Event.EndVegetationProcessing(self.entityId)
end
function commonNPScript:setAcoustics(envValue, acousticName)
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityId, "Acoustics", acousticName)
  if self.envName then
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, self.envName, envValue)
    if self.prevEnvName and self.prevEnvName ~= self.envName then
      AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, self.prevEnvName, 0)
    end
    self.prevEnvName = self.envName
  end
end
function commonNPScript:OnTick(deltaTime, timePoint)
  self.npcDeltaTime = self.npcDeltaTime + deltaTime
  if self.npcDeltaTime > self.refreshRate and self.playerEntityId and self.entityId then
    local playerLocation = TransformBus.Event.GetWorldTranslation(self.playerEntityId)
    self.npcWorldPosition = TransformBus.Event.GetWorldTranslation(self.entityId)
    if playerLocation and self.npcWorldPosition then
      if self.isCeilingRemoteActivated then
        ceilingRaycastAudioNPC:DetectCeiling(self.entityId, self.npcWorldPosition)
      end
      local distance = Vector3.GetDistance(playerLocation, self.npcWorldPosition)
      if distance and distance <= 30 then
        self.rtpcHDRPriority = (30 - distance) / 30
      else
        self.rtpcHDRPriority = 0
      end
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityId, "rtpc_HDRPriority", self.rtpcHDRPriority)
    end
    self.npcDeltaTime = 0
  end
end
function commonNPScript:StartVoice()
  if not self.isDead and not self.isPlayingVoice and self.myTag and (not self.isTargetingPlayer or self.isTargetingPlayer == nil) then
    local voStartEvent = "play_" .. string.lower(self.myTag) .. "_voice"
    if self:IsTriggerValid(voStartEvent) then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, voStartEvent)
      self.isPlayingVoice = true
    end
  end
end
function commonNPScript:StopVoice()
  if self.isPlayingVoice and self.myTag then
    local voStopEvent = "stop_" .. string.lower(self.myTag) .. "_voice"
    if self:IsTriggerValid(voStopEvent) then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, voStopEvent)
      self.isPlayingVoice = false
    end
  end
end
function commonNPScript:OnDeath()
  self:StopVoice()
  self.isDead = true
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_GPUI_DeathFade")
  DynamicBus.audioAITrackerBus.Event.OnNPCDeath(self.playerEntityId, self.entityId)
  local deathtime
  if self.myTag == "LostSiren" then
    deathtime = 15
  else
    deathtime = 8
  end
  TimingUtils:Delay(self.entityId, deathtime, function()
    self:OnDeactivate()
  end)
end
function commonNPScript:AddBusses()
  if not CeilingRaycastLimiterNPC:CanActivateMore() then
    self:onTopRayHitNPC(0, nil, nil, nil, nil)
    return
  else
    self.isCeilingRemoteActivated = true
    CeilingRaycastLimiterNPC:Activated()
    if self.tickBusHandler == nil then
      self.tickBusHandler = TickBus.Connect(self)
    end
  end
end
function commonNPScript:RemoveBusses()
  if self.tickBusHandler then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.TransformNotificationBusHandler then
    self.TransformNotificationBusHandler:Disconnect()
    self.TransformNotificationBusHandler = nil
  end
  if self.isCeilingRemoteActivated then
    CeilingRaycastLimiterNPC:Deactivated()
    self:onTopRayHitNPC(0, nil, nil, nil, nil)
    self.isCeilingRemoteActivated = false
  end
  if self.AudioUtilsEventBusHandler then
    self.AudioUtilsEventBusHandler:Disconnect()
    self.AudioUtilsEventBusHandler = nil
  end
end
function commonNPScript:OnDeactivate()
  self:RemoveBusses()
  AudioTriggerComponentRequestBus.Event.KillAllTriggers(self.entityId)
  if self.playerEntityId then
    if not self.isDead then
      DynamicBus.audioAITrackerBus.Event.OnNPCDeactivated(self.playerEntityId, self.entityId)
    end
    DynamicBus.audioAITrackerBus.Event.UntargetedFailsafe(self.playerEntityId, self.entityId)
  end
  if self.bankName then
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, self.bankName)
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, "bodyfalls")
  end
  if self.VitalsComponentBusHandler then
    self.VitalsComponentBusHandler:Disconnect()
    self.VitalsComponentBusHandler = nil
  end
  if self.triggerAreaBusHandler then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  if self.characterEventBusHandler then
    self.characterEventBusHandler:Disconnect()
    self.characterEventBusHandler = nil
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
  if self.audioAITrackerBusHandler then
    DynamicBus.audioAITrackerBus.Disconnect(self.entityId, self)
    self.audioAITrackerBusHandler = nil
  end
  if self.TopRaycastNPCBusHandler then
    DynamicBus.TopRaycastNPC.Disconnect(self.entityId, self)
    self.TopRaycastNPCBusHandler = nil
  end
end
return commonNPScript

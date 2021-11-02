require("Scripts.Utils.TimingUtils")
require("Scripts._Common.Common")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local ambientAudio = RequireScript("Scripts.Audio.Environment.AmbientAudio_Global")
local quadRaycastAudio = RequireScript("Scripts.Audio.Players.QuadRaycast_Audio")
local ceilingRaycastAudio = require("Scripts.Audio.Players.CeilingRaycast_Audio")
local PlayerScript = {
  Properties = {
    AudioListener_EntityId = {
      default = EntityId(),
      description = "Audio Listener EntityId",
      order = 1
    },
    GameCamera_EntityId = {
      default = EntityId(),
      description = "Camera EntityId",
      order = 2
    },
    InventoryCamera_EntityId = {
      default = EntityId(),
      description = "Inventory EntityId",
      order = 3
    },
    GatherCamera_EntityId = {
      default = EntityId(),
      description = "Gather EntityId",
      order = 4
    },
    Foley_EntityId = {
      default = EntityId(),
      description = "Foley EntityId",
      order = 5
    }
  }
}
function PlayerScript:OnActivate()
  self.entityIdOverride = self.entityId
  if self.EntityBusHandler == nil then
    self.EntityBusHandler = EntityBus.Connect(self, self.entityIdOverride)
  end
  if self.PlayerComponentBusHandler == nil then
    self.PlayerComponentBusHandler = PlayerComponentNotificationsBus.Connect(self, self.entityIdOverride)
  end
  if self.WaterLevelBusHandler == nil then
    self.WaterLevelBusHandler = WaterLevelNotificationBus.Connect(self, self.entityIdOverride)
  end
  if self.TopRaycastBusHandler == nil then
    self.TopRaycastBusHandler = DynamicBus.TopRaycast.Connect(self.entityIdOverride, self)
  end
  if self.AITargetSelectionBusHandler == nil then
    self.AITargetSelectionBusHandler = AITargetSelectionNotificationBus.Connect(self, self.entityIdOverride)
  end
  self.waterDeltaTime = 0
  self.prevWorldPos = nil
  self.inWater = false
  self.isEditor = false
  self.remoteCeilingDeltaTime = 0
  self.isCeilingRemoteActivated = nil
  self.prevEnvName = nil
  self.envName = nil
  self.acouName = nil
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
  dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.OnLocalPlayerSet", function(self, isSet)
    if isSet then
      dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.OnLocalPlayerSet")
      if PlayerComponentRequestsBus.Event.IsLocalPlayer(self.entityIdOverride) == true then
        self.isEditor = LyShineScriptBindRequestBus.Broadcast.IsEditor()
        if self.tickBusHandler == nil then
          self.tickBusHandler = TickBus.Connect(self)
        end
        if self.crySystemEventHandler == nil then
          self.crySystemEventHandler = CrySystemEventBus.Connect(self)
        end
        if self.playerSpawningBusHandler == nil then
          self.playerSpawningBusHandler = DynamicBus.playerSpawningBus.Connect(self.entityIdOverride, self)
        end
        if self.uiStateBusHandler == nil then
          self.uiStateBusHandler = DynamicBus.uiStateBus.Connect(self.entityIdOverride, self)
        end
        if self.mixStateBusHandler == nil then
          self.mixStateBusHandler = DynamicBus.mixStateBus.Connect(self.entityIdOverride, self)
        end
        if self.outputConfigBusHandler == nil then
          self.outputConfigBusHandler = DynamicBus.outputConfigBus.Connect(self.entityIdOverride, self)
        end
        if self.triggerAreaEntityBusHandler == nil then
          self.triggerAreaEntityBusHandler = TriggerAreaEntityNotificationBus.Connect(self, self.entityIdOverride)
        end
        if self.transformNotificationBusHandler == nil then
          self.transformNotificationBusHandler = TransformNotificationBus.Connect(self, self.entityIdOverride)
        end
        if self.ghostZoneBusHandler == nil then
          self.ghostZoneBusHandler = DynamicBus.ghostZoneBus.Connect(self.entityIdOverride, self)
        end
        if self.LoadingScreenBusHandler == nil then
          self.LoadingScreenBusHandler = LoadScreenNotificationBus.Connect(self, self.entityIdOverride)
        end
        if not LoadScreenBus.Broadcast.IsLoadingScreenShown() then
          local currentLevelName = LoadScreenBus.Broadcast.GetCurrentLevelName()
          if currentLevelName == "newworld_vitaeeterna" then
            self:OnLoadingScreenDismissed()
          end
        end
        AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Weather", "Clear")
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Weather", "Clear")
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Mix_state", "Default")
        AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Mix_state", "Default")
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Mode", "Default")
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Network", "Local")
        AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "NetworkType", 0)
        self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
        self.isLocalPlayer = true
        self.tractDeltaTime = 0
        self.travDeltaTime = 0
        self.todDeltaTime = 0
        self.prevTOD = nil
        self.tod = "day"
        self.playerSpawned = false
        self.tractAtPosition = nil
        self.maxLoadedTractPreloads = 4
        self.playerXYPosition = nil
        self.ghostZoneIN = false
        self.isOutpostRush = nil
        self.isDuel = nil
        self.loadedTractPreloads = {}
        self.tractMappings = loadTwoColumCSV(AudioUtilsBus.Broadcast.LoadFile("@assets@/Sounds/wwise/Soundbank_Tract_mapping.csv"))
        self.surfaceTypeMappings = loadTwoColumCSV(AudioUtilsBus.Broadcast.LoadFile("@assets@/Libs/MaterialEffects/SurfaceTypeMapping.csv"))
        ambientAudio:OnActivate()
      else
        self.CeilingRaycastLimiter = RequireScript("Scripts.Audio.Players.CeilingRaycastLimiter_Audio")
        self.CeilingRaycastLimiter:OnActivate()
        if self.triggerAreaBusHandler == nil then
          self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.entityIdOverride)
        end
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Network", "Remote")
        AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "NetworkType", 50)
        self:setPlayerQuadDelay(1)
        self:SetPlayerVoice()
        self:SetGameMode()
        self.isLocalPlayer = false
        self.playerWorldPosition = TransformBus.Event.GetWorldTranslation(self.entityIdOverride)
        ceilingRaycastAudio:OnActivate(self.entityIdOverride, self.playerWorldPosition)
        dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
          if playerEntityId then
            self.localPlayerEntityId = playerEntityId
            DynamicBus.audioAITrackerBus.Event.OnPlayerActivated(self.localPlayerEntityId, self.entityIdOverride)
          end
        end)
      end
    end
  end)
end
function PlayerScript:SetPlayerVoice()
  local playerGender = CustomizableCharacterRequestBus.Event.GetGender(self.entityIdOverride)
  self.playerVoice = "Play_" .. playerGender .. "_" .. "Race" .. "_01_Voice"
  AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityIdOverride, "PlayVoice_" .. playerGender)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, self.playerVoice)
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Gender", playerGender)
end
function PlayerScript:OnLoadingScreenDismissed()
  if not self.isEditor then
    self:onPlayerSpawned(true)
  end
end
function PlayerScript:SetGameMode()
  local isOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(self.entityIdOverride, 2444859928)
  local isDuel = GameModeParticipantComponentRequestBus.Event.IsInGameMode(self.entityIdOverride, 2612307810)
  local raidId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  if isOutpostRush then
    AudioSwitchComponentRequestBus.Broadcast.SetSwitchState("Mode", "OutpostRush")
    self.gameMode = "OutpostRush"
  elseif isDuel then
    AudioSwitchComponentRequestBus.Broadcast.SetSwitchState("Mode", "Duel")
    self.gameMode = "Duel"
  elseif raidId and raidId:IsValid() then
    local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(raidId)
    local isInvasion = warDetails:IsInvasion()
    local currentPhase = warDetails:GetWarPhase()
    if currentPhase == eWarPhase_Conquest then
      if isInvasion then
        AudioSwitchComponentRequestBus.Broadcast.SetSwitchState("Mode", "Invasion")
        self.gameMode = "Invasion"
      else
        AudioSwitchComponentRequestBus.Broadcast.SetSwitchState("Mode", "Siege")
        self.gameMode = "Siege"
      end
    else
      AudioSwitchComponentRequestBus.Broadcast.SetSwitchState("Mode", "Default")
      self.gameMode = "Default"
    end
  else
    AudioSwitchComponentRequestBus.Broadcast.SetSwitchState("Mode", "Default")
    self.gameMode = "Default"
  end
end
function PlayerScript:onPlayerSpawned(bool)
  self:SetGameMode()
  if self.playerSpawned == false then
    if self.LoadingScreenBusHandler ~= nil then
      self.LoadingScreenBusHandler:Disconnect()
      self.LoadingScreenBusHandler = nil
    end
    self.outputConfiguration = dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Audio.OutputConfiguration")
    if self.outputConfiguration == 1 then
      self.audioListenerPercentage = 1
    else
      self.audioListenerPercentage = 0
    end
    self:SetPlayerVoice()
    if not self.isFtue and not self.isEditor then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_AMB_EXT_Grass")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_QuadAmb_Wildlife")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_QuadAmb_Layer")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_QuadAmb_POIs")
      if self.ghostZoneBusHandler == nil then
        self.ghostZoneBusHandler = DynamicBus.ghostZoneBus.Connect(self.entityIdOverride, self)
      end
      if self.SpectatorBusBusHandler == nil then
        self.SpectatorBusBusHandler = DynamicBus.SpectatorBus.Connect(self.entityIdOverride, self)
      end
      if self.GatheringBusHandler == nil then
        self.GatheringBusHandler = UiGatheringComponentNotificationsBus.Connect(self, self.entityIdOverride)
      end
    end
    DynamicBus.playerSpawningBus.Event.postPlayerSpawn(self.Properties.Foley_EntityId, true)
    self.playerWorldPosition = TransformBus.Event.GetWorldTranslation(self.entityIdOverride)
    quadRaycastAudio:OnActivate(self.entityIdOverride, self.playerWorldPosition)
    ceilingRaycastAudio:OnActivate(self.entityIdOverride, self.playerWorldPosition)
  end
  if self.isLocalPlayer == true then
    local showRespawnEffects = dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.ShowRespawnEffects")
    if showRespawnEffects then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_GPUI_Spawn_Azoth_Player")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Set_Switch_Vocals_Breathing")
    end
  end
  self.playerSpawned = true
  if not self.isFtue and not self.isEditor then
    self:switchTract()
  end
end
function PlayerScript:onTopRayHit(getHitCount, dist2Player, surfaceType, entityId, entityName)
  if getHitCount == 0 then
    if self.playerOutside ~= true then
      if self.isLocalPlayer == true then
        AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("CeilingType", "none")
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "CeilingType", "none")
      else
        self:setPlayerQuadDelay(1)
      end
      self:setAcoustics("Ext", "Amb_Ext", 0, "Acou_Ext")
      self.playerOutside = true
    end
  else
    if self.playerOutside == true then
      if self.isLocalPlayer == true then
        local surfaceTypeName = self.surfaceTypeMappings[tostring(surfaceType)]
        AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("CeilingType", surfaceTypeName)
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "CeilingType", surfaceTypeName)
      else
        self:setPlayerQuadDelay(0)
      end
      self.playerOutside = false
    end
    if surfaceType ~= nil and (surfaceType == 109 or surfaceType == 104 or surfaceType == 121 or surfaceType == 0) then
      for i = 1, #self.acousticRange do
        if dist2Player < self.acousticRange[i] and dist2Player > self.acousticRange[i - 1] then
          if surfaceType == 104 or surfaceType == 0 then
            self.envName = "ENV_INT_" .. tostring(self.acousticList[i])
            self.acouName = "Acou_Int_" .. tostring(self.acousticList[i])
            self:setAcoustics(self.envName, "Amb_Int", 1, self.acouName)
          elseif surfaceType == 121 and self.isLocalPlayer == true then
            self:setAcoustics("Ext", "Amb_Ext", 0, "Acou_Ext")
          else
            self.envName = "ENV_INT_" .. tostring(self.acousticList[i]) .. "_Stone"
            self.acouName = "Acou_Int_" .. tostring(self.acousticList[i]) .. "_Stone"
            self:setAcoustics(self.envName, "Amb_Int", 1, self.acouName)
          end
        end
      end
    end
  end
end
function PlayerScript:setAcoustics(Interior_state, Ext_Int, envValue, acousticName)
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Acoustics", acousticName)
  if self.isLocalPlayer == true then
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Interior_state", Interior_state)
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Ext_Int", Ext_Int)
  end
  if self.envName ~= nil then
    AudioEnvironmentComponentRequestBus.Event.SetAndCacheEnvironmentAmount(self.entityIdOverride, self.envName, envValue)
    if self.prevEnvName ~= nil and self.prevEnvName ~= self.envName then
      AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, self.prevEnvName, 0)
    end
    local children = TransformBus.Event.GetChildren(self.Properties.Foley_EntityId)
    if children ~= nil then
      for i = 1, #children do
        local childEntityId = children[i]
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Acoustics", acousticName)
        AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(childEntityId, self.envName, envValue)
        if self.prevEnvName ~= nil and self.prevEnvName ~= self.envName then
          AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(childEntityId, self.prevEnvName, 0)
        end
      end
    end
  end
  self.prevEnvName = self.envName
end
function PlayerScript:setPlayerQuadDelay(value)
  AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_FL", value)
  AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_FR", value)
  AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_BR", value)
  AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_BL", value)
end
function PlayerScript:onUIStateChanged(UIstate)
  self.UIState = UIstate
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "UI_state", self.UIState)
  if self.UIState == "Crafting" then
  elseif self.UIState == "Inventory" then
  elseif self.outputConfiguration == 1 then
    self.audioListenerPercentage = 1
  else
    self.audioListenerPercentage = 0
  end
end
function PlayerScript:onOutputConfigurationChanged(config)
  if config == 1 then
    self.audioListenerPercentage = 1
    self.outputConfiguration = 1
  elseif config == 0 then
    self.audioListenerPercentage = 0
    self.outputConfiguration = 0
  end
end
function PlayerScript:OnCrySystemPostViewSystemUpdate()
  if self.entityIdOverride ~= nil and self.Properties.AudioListener_EntityId ~= nil and self.Properties.GameCamera_EntityId ~= nil and self.isLocalPlayer == true then
    local maxCamDistance = 11
    local camPlayerAngle = JavCameraControllerRequestBus.Broadcast.GetAngleFromCamera(self.playerWorldPosition)
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "CamPlayerAngle", camPlayerAngle)
    local cameraTM = TransformBus.Event.GetWorldTM(self.Properties.GameCamera_EntityId)
    local camPosition = JavCameraControllerRequestBus.Broadcast.GetCameraPosition()
    local camStateId = JavCameraControllerRequestBus.Broadcast.GetCameraStateId()
    local playerPositionWithOffset = self.playerWorldPosition + Vector3.ConstructFromValues(0, 0, 1)
    local camToPlayerRatio = Vector3.GetDistance(cameraTM.position, self.playerWorldPosition) / maxCamDistance
    if camStateId ~= 4053507317 and camStateId ~= 1789754717 and camStateId ~= 3719651160 and camStateId ~= 1849067346 then
      self.camPlayerDistance = camPosition + (playerPositionWithOffset - camPosition) * camToPlayerRatio
    else
      self.camPlayerDistance = camPosition
    end
    cameraTM:SetTranslation(self.camPlayerDistance)
    TransformBus.Event.SetWorldTranslation(self.Properties.AudioListener_EntityId, self.camPlayerDistance)
  end
end
function PlayerScript:OnTransformChanged()
  local transformRotation = TransformBus.Event.GetWorldRotation(self.entityIdOverride)
  if self.oldTransformRotation ~= transformRotation then
    AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("transform_Rotation", transformRotation.z)
    self.oldTransformRotation = transformRotation
  end
end
function PlayerScript:onMixStateChanged(mixState)
  self.mixState = mixState
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Mix_state", self.mixState)
  AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Mix_state", self.mixState)
end
function PlayerScript:onEnterGhostzone(ghostEntityId)
  if self.ghostZoneIN == false then
    self.ghostZoneIN = true
    AudioPreloadComponentRequestBus.Event.LoadPreload(ghostEntityId, "GhostZone")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(ghostEntityId, "Play_GhostZone")
  end
end
function PlayerScript:onExitGhostzone(ghostEntityId)
  if self.ghostZoneIN == true then
    self.ghostZoneIN = false
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(ghostEntityId, "Stop_GhostZone")
    AudioPreloadComponentRequestBus.Event.UnloadPreload(ghostEntityId, "GhostZone")
  end
end
function PlayerScript:onSpectatorChanged(bool, spectatorEntityId)
  if bool == 1 then
    self.entityIdOverride = spectatorEntityId
  else
    self.entityIdOverride = self.entitydId
  end
end
function PlayerScript:OnGatheringStart(UiGatheringStart)
end
function PlayerScript:OnGatheringEnd(UiGatheringEnd)
end
function PlayerScript:OnEnterWater()
  self.inWater = true
  if self.entityIdOverride ~= nil then
    self.prevWorldPos = self.playerWorldPosition
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_Male01_WaterEnter")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_FLY_WaterBody")
    if not self.isLocalPlayer then
      if self.tickBusHandler == nil then
        self.tickBusHandler = TickBus.Connect(self)
      end
    else
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_QuadAmb_Water")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Stop_AMB_EXT_Grass")
    end
  end
end
function PlayerScript:OnExitWater()
  self.inWater = false
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "object_waterspeed", 0)
  if not self.isLocalPlayer and self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "object_waterspeed", 0)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_Male01_WaterLeave")
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Stop_FLY_WaterBody")
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Stop_QuadAmb_Water")
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_AMB_EXT_Grass")
end
function PlayerScript:OnSelectedAsTarget(EntityId)
  if (TagComponentRequestBus.Event.HasTag(EntityId, 648976088) or TagComponentRequestBus.Event.HasTag(EntityId, 3160857707) or TagComponentRequestBus.Event.HasTag(EntityId, 846028842) or TagComponentRequestBus.Event.HasTag(EntityId, 2807827481) or TagComponentRequestBus.Event.HasTag(EntityId, 1504998328) or TagComponentRequestBus.Event.HasTag(EntityId, 2638353735)) and self.ghostZoneIN == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(EntityId, "Stop_GhostZone")
  end
end
function PlayerScript:OnTick(deltaTime, timePoint)
  self.playerWorldPosition = TransformBus.Event.GetWorldTranslation(self.entityIdOverride)
  if self.inWater == true then
    self.waterDeltaTime = self.waterDeltaTime + deltaTime
    if self.waterDeltaTime > 0.1 then
      if self.playerWorldPosition ~= nil and self.prevWorldPos ~= nil and self.playerWorldPosition ~= self.prevWorldPos then
        local distTravelled = Vector3.GetDistance(self.playerWorldPosition, self.prevWorldPos)
        local waterDelta = distTravelled / deltaTime
        local waterSpeed = math.abs(waterDelta)
        AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "object_waterspeed", waterSpeed)
      else
        AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "object_waterspeed", 0)
      end
      self.prevWorldPos = self.playerWorldPosition
      self.waterDeltaTime = 0
    end
  end
  if self.isLocalPlayer == true then
    self.tractDeltaTime = self.tractDeltaTime + deltaTime
    self.travDeltaTime = self.travDeltaTime + deltaTime
    self.todDeltaTime = self.todDeltaTime + deltaTime
    if self.playerSpawned == true and self.isEditor == false then
      if self.travDeltaTime > 1 then
        quadRaycastAudio:DetectGeo(self.playerWorldPosition)
        ceilingRaycastAudio:DetectCeiling(self.entityIdOverride, self.playerWorldPosition)
        if self.playerOutside == true then
          local PineTree_weight = ambientAudio:GetAmbientWeight("PineTree")
          local BeechTree_weight = ambientAudio:GetAmbientWeight("BeechTree")
          local PoplarTree_weight = ambientAudio:GetAmbientWeight("PoplarTree")
          local OakTree_weight = ambientAudio:GetAmbientWeight("OakTree")
          local DeadTree_weight = ambientAudio:GetAmbientWeight("DeadTree")
          local BananaTree_weight = ambientAudio:GetAmbientWeight("BananaTree")
          local BaldCypressTree_weight = ambientAudio:GetAmbientWeight("BaldCypressTree")
          local KapokTree_weight = ambientAudio:GetAmbientWeight("KapokTree")
          local FL_weight = PineTree_weight[1] + BeechTree_weight[1] + PoplarTree_weight[1] + OakTree_weight[1] + DeadTree_weight[1] + BananaTree_weight[1] + BaldCypressTree_weight[1] + KapokTree_weight[1]
          local FR_weight = PineTree_weight[2] + BeechTree_weight[2] + PoplarTree_weight[2] + OakTree_weight[2] + DeadTree_weight[2] + BananaTree_weight[2] + BaldCypressTree_weight[2] + KapokTree_weight[2]
          local BR_weight = PineTree_weight[3] + BeechTree_weight[3] + PoplarTree_weight[3] + OakTree_weight[3] + DeadTree_weight[3] + BananaTree_weight[3] + BaldCypressTree_weight[3] + KapokTree_weight[3]
          local BL_weight = PineTree_weight[4] + BeechTree_weight[4] + PoplarTree_weight[4] + OakTree_weight[4] + DeadTree_weight[4] + BananaTree_weight[4] + BaldCypressTree_weight[4] + KapokTree_weight[4]
          AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_FL", FL_weight)
          AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_FR", FR_weight)
          AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_BR", BR_weight)
          AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_BL", BL_weight)
          AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Weight_EarlyRef_FL", FL_weight)
          AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Weight_EarlyRef_FR", FR_weight)
          AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Weight_EarlyRef_BR", BR_weight)
          AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Weight_EarlyRef_BL", BL_weight)
        else
          self:setPlayerQuadDelay(0)
        end
        self:switchTract()
        self.travDeltaTime = 0
      end
      if self.todDeltaTime > 2 and not self.isFtue then
        local TOD = TimeOfDay.GetTime()
        if TOD < 6 or 18 < TOD then
          self.currentTOD = 0
          if self.currentTOD ~= self.prevTOD then
            self.tod = "night"
            self:loadTractPreload()
            AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "TOD_state", "Night")
          end
        elseif 6 < TOD and TOD < 18 then
          self.currentTOD = 1
          if self.currentTOD ~= self.prevTOD then
            self.tod = "day"
            self:loadTractPreload()
            AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "TOD_state", "Day")
          end
        end
        self.todDeltaTime = 0
        self.prevTOD = self.currentTOD
      end
      if self.tractDeltaTime > 3 and not self.isFtue then
        if self.prevTractAtPosition ~= self.tractAtPosition then
          self:loadTractPreload()
          if self.tractAtPosition ~= "roads" and self.tractAtPosition ~= "cliffs" and self.tractAtPosition ~= "forest_erosion" and self.tractAtPosition ~= "forest_erosion_fall01" and self.tractAtPosition ~= "forest_erosion_fall02" and self.tractAtPosition ~= "forest_erosion_spri01" and self.tractAtPosition ~= "forest_erosion_wint01" and self.tractAtPosition ~= "forest_tropical_erosion" and self.tractAtPosition ~= "jungle_erosion" then
            AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Tract_switch", tostring(self.tractAtPosition))
            AudioSwitchComponentRequestBus.Broadcast.SetSwitchState("Tract_switch", tostring(self.tractAtPosition))
            AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Tract_state", tostring(self.tractAtPosition))
            AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("MMFX_Tract_State", "Default")
          end
        end
        self.tractDeltaTime = 0
        self.todDeltaTime = 0
      end
    end
  else
    self.remoteCeilingDeltaTime = self.remoteCeilingDeltaTime + deltaTime
    if self.isCeilingRemoteActivated == true and 1 < self.remoteCeilingDeltaTime and self.playerWorldPosition ~= nil and self.entityIdOverride ~= nil then
      ceilingRaycastAudio:DetectCeiling(self.entityIdOverride, self.playerWorldPosition)
      self.remoteCeilingDeltaTime = 0
    end
  end
end
function PlayerScript:switchTract()
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  self.playerXYPosition = Vector2.ConstructFromValues(self.playerWorldPosition.x, self.playerWorldPosition.y)
  self.tractAtPosition = MapComponentBus.Broadcast.GetTractAtPosition(self.playerXYPosition)
  if self.tractAtPosition == "roads" or self.tractAtPosition == "cliffs" or self.tractAtPosition == "forest_erosion" or self.tractAtPosition == "forest_erosion_fall01" or self.tractAtPosition == "forest_erosion_fall02" or self.tractAtPosition == "forest_erosion_spri01" or self.tractAtPosition ~= "forest_erosion_wint01" and self.tractAtPosition ~= "forest_tropical_erosion" and self.tractAtPosition ~= "jungle_erosion" then
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("MMFX_Tract_State", tostring(self.tractAtPosition))
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "MM_TallGrass_density", 0)
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "MM_VegeDry_density", 0)
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "MM_Vegetation_density", 0)
  end
end
function PlayerScript:OnTriggerAreaEntered(entityId)
  if self.tickBusHandler == nil then
    self.tickBusHandler = TickBus.Connect(self)
  end
  if not self.CeilingRaycastLimiter:CanActivateMore() then
    self:onTopRayHit(0, nil, nil, nil, nil)
    return
  end
  self.isCeilingRemoteActivated = true
  self.CeilingRaycastLimiter:Activated()
  VegetationAudioRequestBus.Event.StartVegetationProcessing(self.entityId)
end
function PlayerScript:OnTriggerAreaExited(entityId)
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.isCeilingRemoteActivated then
    self.CeilingRaycastLimiter:Deactivated()
    self:onTopRayHit(0, nil, nil, nil, nil)
    self.isCeilingRemoteActivated = false
  end
  VegetationAudioRequestBus.Event.EndVegetationProcessing(self.entityId)
end
function PlayerScript:SetFoleyProxyEnvironments(float)
  local children = TransformBus.Event.GetChildren(self.Properties.Foley_EntityId)
  if children ~= nil and self.trigerAreaNameEnvironment ~= nil then
    for i = 1, #children do
      local childEntityId = children[i]
      AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(childEntityId, self.trigerAreaNameEnvironment, float)
    end
  end
end
function PlayerScript:OnDeactivate()
  if self.EntityBusHandler ~= nil then
    self.EntityBusHandler:Disconnect()
    self.EntityBusHandler = nil
  end
  if self.PlayerComponentBusHandler ~= nil then
    self.PlayerComponentBusHandler:Disconnect()
    self.PlayerComponentBusHandler = nil
  end
  if self.WaterLevelBusHandler ~= nil then
    self.WaterLevelBusHandler:Disconnect()
    self.WaterLevelBusHandler = nil
  end
  if self.TopRaycastBusHandler ~= nil then
    DynamicBus.TopRaycast.Disconnect(self.entityIdOverride, self)
    self.TopRaycastBusHandler = nil
  end
  if self.AITargetSelectionBusHandler ~= nil then
    self.AITargetSelectionBusHandler:Disconnect()
    self.AITargetSelectionBusHandler = nil
  end
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.crySystemEventHandler ~= nil then
    self.crySystemEventHandler:Disconnect()
    self.crySystemEventHandler = nil
  end
  if self.playerSpawningBusHandler then
    DynamicBus.playerSpawningBus.Disconnect(self.entityIdOverride, self)
    self.playerSpawningBusHandler = nil
  end
  if self.uiStateBusHandler then
    DynamicBus.uiStateBus.Disconnect(self.entityIdOverride, self)
    self.uiStateBusHandler = nil
  end
  if self.mixStateBusHandler then
    DynamicBus.mixStateBus.Disconnect(self.entityIdOverride, self)
    self.mixStateBusHandler = nil
  end
  if self.outputConfigBusHandler then
    DynamicBus.outputConfigBus.Disconnect(self.entityIdOverride, self)
    self.outputConfigBusHandler = nil
  end
  if self.triggerAreaEntityBusHandler then
    self.triggerAreaEntityBusHandler:Disconnect()
    self.triggerAreaEntityBusHandler = nil
  end
  if self.transformNotificationBusHandler ~= nil then
    self.transformNotificationBusHandler:Disconnect()
    self.transformNotificationBusHandler = nil
  end
  if self.ghostZoneBusHandler then
    DynamicBus.ghostZoneBus.Disconnect(self.entityIdOverride, self)
    self.ghostZoneBusHandler = nil
  end
  if self.SpectatorBusBusHandler then
    DynamicBus.SpectatorBus.Disconnect(self.entityIdOverride, self)
    self.SpectatorBusBusHandler = nil
  end
  if self.LoadingScreenBusHandler ~= nil then
    self.LoadingScreenBusHandler:Disconnect()
    self.LoadingScreenBusHandler = nil
  end
  if self.GatheringBusHandler ~= nil then
    self.GatheringBusHandler:Disconnect()
    self.GatheringBusHandler = nil
  end
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  dataLayer:UnregisterObservers(self)
  if self.isLocalPlayer == true then
    self.playerSpawned = false
  elseif self.localPlayerEntityId then
    DynamicBus.audioAITrackerBus.Event.OnPlayerDeactivated(self.localPlayerEntityId, self.entityIdOverride)
    self.localPlayerEntityId = nil
  end
end
function getIndexOfValue(tbl, ent)
  for i, v in ipairs(tbl) do
    if v == ent then
      return i
    end
  end
  return -1
end
function loadTwoColumCSV(rawMappingsString)
  local table = {}
  for s in rawMappingsString:gmatch("[^\r\n]+") do
    lineParts = StringSplit(s, ",")
    table[lineParts[1]] = lineParts[2]
  end
  return table
end
function PlayerScript:loadTractPreload()
  local tractPreloadName = self.tractMappings[self.tractAtPosition]
  if tractPreloadName == nil then
  else
    tractPreloadName = tractPreloadName .. self.tod
    local index = getIndexOfValue(self.loadedTractPreloads, tractPreloadName)
    if index == -1 then
      AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityIdOverride, tractPreloadName)
      table.insert(self.loadedTractPreloads, 1, tractPreloadName)
      if table.getn(self.loadedTractPreloads) > self.maxLoadedTractPreloads then
        oldPreload = table.remove(self.loadedTractPreloads)
        AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityIdOverride, oldPreload)
      end
    else
      table.remove(self.loadedTractPreloads, index)
      table.insert(self.loadedTractPreloads, 1, tractPreloadName)
    end
    self.prevTractAtPosition = self.tractAtPosition
  end
end
return PlayerScript

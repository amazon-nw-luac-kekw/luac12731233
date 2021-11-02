require("Scripts.Utils.TimingUtils")
require("Scripts._Common.Common")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local MusicManager = {
  Properties = {},
  targetingAIs = {},
  aliveAIs = {},
  targetingAIEntityTypeAndId = {},
  targetingAIEntityIdList = {},
  aliveAIEntityTypeAndId = {},
  aliveAIEntityIdStringList = {},
  aliveAIEntityIdList = {},
  alivePlayerEntityIdList = {},
  gameModeList = {
    [1784989592] = true,
    [3554825874] = true,
    [4216632563] = true,
    [4204622694] = true,
    [4110364685] = true,
    [1976698637] = true,
    [3102420563] = true,
    [591930786] = true,
    [2312627222] = true,
    [3035219293] = true,
    [4275098752] = true,
    [2132576867] = true
  }
}
function MusicManager:OnActivate()
  self.entityIdOverride = self.entityId
  dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.OnLocalPlayerSet", function(self, isSet)
    if isSet then
      dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.OnLocalPlayerSet")
      if PlayerComponentRequestsBus.Event.IsLocalPlayer(self.entityIdOverride) then
        self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
        self.isLocalPlayer = true
        self.deltaTime = 0
        self.tod = "day"
        self.waitTime = 0
        self.navTime = 0
        self.musicOffTime = 0
        self.playerSpawned = false
        self.playerXYPosition = nil
        self.prevPlayerXYPosition = nil
        self.aiTargetingEntityId = nil
        self.combatMusicEndState = nil
        self.combatMusicEndPad = 1
        self.combatMusicEndDeltaTime = 0
        self.canCombatMusicTick = false
        self.isAiThreatening = false
        self.aiThreatDistance = 25
        self.currentMixState = "Default"
        self.isInDarkness = false
        self.darknessEntityId = nil
        self.currentPlayingDungeon = nil
        self:InitMusicParams()
        self.isEditor = LyShineScriptBindRequestBus.Broadcast.IsEditor()
        AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("rtpc_MX_Combat", 5)
        if not self.EntityBusHandler then
          self.EntityBusHandler = EntityBus.Connect(self, self.entityIdOverride)
        end
        if not self.PlayerComponentBusHandler then
          self.PlayerComponentBusHandler = PlayerComponentNotificationsBus.Connect(self, self.entityIdOverride)
        end
        if not self.tickBusHandler then
          self.tickBusHandler = TickBus.Connect(self)
        end
        if not self.playerSpawningBusHandler then
          self.playerSpawningBusHandler = DynamicBus.playerSpawningBus.Connect(self.entityIdOverride, self)
        end
        if not self.uiStateBusHandler then
          self.uiStateBusHandler = DynamicBus.uiStateBus.Connect(self.entityIdOverride, self)
        end
        if not self.mixStateBusHandler then
          self.mixStateBusHandler = DynamicBus.mixStateBus.Connect(self.entityIdOverride, self)
        end
        if not self.switchMusicBusHandler and not self.isEditor then
          self.switchMusicBusHandler = DynamicBus.switchMusicBus.Connect(self.entityIdOverride, self)
        end
        if not self.outputConfigBusHandler then
          self.outputConfigBusHandler = DynamicBus.outputConfigBus.Connect(self.entityIdOverride, self)
        end
        if not self.dungeonBusHandler then
          self.dungeonBusHandler = DynamicBus.dungeonAudioBus.Connect(self.entityIdOverride, self)
        end
        if not self.triggerAreaEntityBusHandler then
          self.triggerAreaEntityBusHandler = TriggerAreaEntityNotificationBus.Connect(self, self.entityIdOverride)
        end
        if not self.uiTriggerAreaEventBusHandler then
          self.uiTriggerAreaEventBusHandler = UiTriggerAreaEventNotificationBus.Connect(self)
        end
        if not self.loadScreenBusHandler then
          self.loadScreenBusHandler = LoadScreenNotificationBus.Connect(self)
        end
        if not LoadScreenBus.Broadcast.IsLoadingScreenShown() then
          local currentLevelName = LoadScreenBus.Broadcast.GetCurrentLevelName()
          if currentLevelName == "newworld_vitaeeterna" then
            self:OnLoadingScreenDismissed()
            self:onPlayerSpawned()
          end
        end
        self.refreshRate = 10
        self.triggerAreaTag = nil
        self.stingerCooldown = 5
        self.poiMappings = loadTwoColumCSV(AudioUtilsBus.Broadcast.LoadFile("@assets@/Sounds/wwise/Soundbank_POI_mapping.csv", self.poiMappings))
        self.combatMusicMapping = loadThreeColumnCSV(AudioUtilsBus.Broadcast.LoadFile("@assets@/Scripts/Audio/Players/Combat_Music_Mapping.csv", self.combatMusicMapping))
        dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.AudioState", self.SetTerritoryState)
        dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.SmallestAudioState", self.SetPoiState)
      else
        return
      end
    end
  end)
end
function MusicManager:onPlayerSpawned()
  if not self.playerSpawned then
    self:InitValidUnitTags()
    if not self.isEditor then
      self:SetGameMode()
      if self.currentlyPlayingMusicType == nil then
        self.currentlyPlayingMusicType = "None"
      end
      if self.isFtue then
        AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Music_Shell", "Mx_Shell_FTUE")
        AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Music_FTUE", "Mx_FTUE_Combat_A1")
      else
        AudioUtilsBus.Broadcast.ExecuteGlobalAudioTrigger("Stop_MX_MainMenu", true, EntityId())
      end
      if self.gameMode == "Default" then
        if self.currentlyPlayingMusicType ~= "Settlement" then
          self:SetCurrentlyPlayingMusic("Ambient", "MX_Gameplay", "Ambient")
        else
          self:SetCurrentlyPlayingMusic("Settlement", "MX_Gameplay", "Settlement")
        end
      end
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Stop_MX_Gameplay")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_MX_Gameplay")
    end
    if self.LandClaimBusHandler == nil then
      self.LandClaimBusHandler = LandClaimNotificationBus.Connect(self, self.entityIdOverride)
    end
    if self.AITargetSelectionBusHandler == nil then
      self.AITargetSelectionBusHandler = AITargetSelectionNotificationBus.Connect(self, self.entityIdOverride)
    end
    if self.audioAITrackerBusHandler == nil then
      self.audioAITrackerBusHandler = DynamicBus.audioAITrackerBus.Connect(self.entityIdOverride, self)
    end
    if self.audioDarknessMusicBusHandler == nil then
      self.audioDarknessMusicBusHandler = DynamicBus.audioDarknessMusicBus.Connect(self.entityIdOverride, self)
    end
    if self.poiZoneBusHandler == nil then
      self.poiZoneBusHandler = DynamicBus.poiZoneBus.Connect(self.entityIdOverride, self)
    end
    if self.SpectatorBusBusHandler == nil then
      self.SpectatorBusBusHandler = DynamicBus.SpectatorBus.Connect(self.entityIdOverride, self)
    end
    self.playerSpawned = true
  end
end
function MusicManager:SetGameMode()
  self.gameMode = "Default"
  local isOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(self.entityIdOverride, 2444859928)
  local isDuel = GameModeParticipantComponentRequestBus.Event.IsInGameMode(self.entityIdOverride, 2612307810)
  if isOutpostRush then
    if self.currentORState == nil then
      self:SetCurrentlyPlayingMusic("OutpostRush", "Music_OutpostRush", "None")
    end
    self.gameMode = "OutpostRush"
  elseif isDuel then
    self:SetCurrentlyPlayingMusic("Duel", "Music_Duel", "None")
    self.gameMode = "Duel"
  else
    local raidId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
    if raidId and raidId:IsValid() then
      local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(raidId)
      local isInvasion = warDetails:IsInvasion()
      local currentPhase = warDetails:GetWarPhase()
      if currentPhase == eWarPhase_Conquest then
        if isInvasion then
          self:SetCurrentlyPlayingMusic("Invasion", "Music_Invasion", "None")
          self.gameMode = "Invasion"
        else
          self:SetCurrentlyPlayingMusic("Siege", "Music_Siege", "None")
          self.gameMode = "Siege"
        end
      end
    end
  end
end
function MusicManager:SetPoiState(state)
  if not state then
    return
  end
  local musicGroup = dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.SmallestAudioGroup")
  if not self.playerInFortress and not self.playerInSettlement then
    if musicGroup == "Music_Territory" then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "POI_State", "None")
      self.playerOutsideOfPreviousPOI = true
      TimingUtils:Delay(self.entityIdOverride, 3, function()
        if self.reloadingSamePreload == true then
          return
        elseif self.poiSoundbankLoaded ~= nil then
          AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityIdOverride, self.poiSoundbankLoaded)
          self.reloadingSamePreload = false
          self.poiSoundbankLoaded = nil
        end
      end)
    elseif musicGroup == "Music_POI" then
      local poiPreloadName = self.poiMappings[tostring(state)]
      self.poiSoundbankToLoad = "Amb_POI_" .. tostring(poiPreloadName)
      if poiPreloadName == nil then
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "POI_State", "None")
        return
      elseif self.poiSoundbankToLoad == self.poiSoundbankLoaded and not self.playerOutsideOfPreviousPOI then
        self.reloadingSamePreload = true
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "POI_State", state)
        return
      else
        AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityIdOverride, self.poiSoundbankToLoad)
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "POI_State", state)
        self.poiSoundbankLoaded = self.poiSoundbankToLoad
        self.playerOutsideOfPreviousPOI = false
      end
    elseif musicGroup == "Music_Arena" then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Arena", state)
    end
  end
end
function MusicManager:SetTerritoryState(state)
  if not state then
    return
  end
  local musicGroup = dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.AudioGroup")
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Territory", state)
end
function MusicManager:OnUiTriggerAreaEventEntered(enteringEntityId, triggerEntityId, eventId, identifier)
  if eventId == 3718191953 then
    self.playerInSettlement = true
    self:SetCurrentlyPlayingMusic("Settlement", "MX_Gameplay", "Settlement")
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityIdOverride, "Amb_POI_Settlement")
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "POI_State", "settlement")
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Mix_state", "Default")
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Mix_state", "Default")
  elseif eventId == 114609139 then
    self.playerInFortress = true
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "POI_State", "fortress")
  elseif eventId == 3422532346 then
  elseif eventId == 2429410629 then
  end
end
function MusicManager:OnUiTriggerAreaEventExited(exitingEntityId, eventId)
  if eventId == 3718191953 then
    self.playerInSettlement = false
    if self.currentlyPlayingMusicType == "None" or self.currentlyPlayingMusicType == "Settlement" and self.gameMode == "Default" then
      self:SetCurrentlyPlayingMusic("Ambient", "MX_Gameplay", "Ambient")
    end
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "POI_State", "None")
    TimingUtils:Delay(self.entityIdOverride, 3, function()
      if self.playerInSettlement == true then
        return
      else
        AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityIdOverride, "Amb_POI_Settlement")
      end
    end)
  elseif eventId == 114609139 then
    self.playerInFortress = false
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "POI_State", "None")
  elseif eventId == 3422532346 then
  elseif eventId == 2429410629 then
  end
end
function MusicManager:SwitchMusicDB(switch, state)
  if self.isFtue then
    return
  elseif string.match(switch, "Music_") then
    lineParts = StringSplit(switch, "_")
    self:SetCurrentlyPlayingMusic(tostring(lineParts[2]), switch, state)
  elseif state == "Mx_LevelingUp" then
    self:SetCurrentlyPlayingMusic("Stinger", "MX_Context", "LevelUp")
  elseif switch == "MX_Darkness" then
    for key, value in pairs(self.nonAmbientMusicTypes) do
      if self.currentlyPlayingMusicType ~= key then
        self:DarknessMusicEvent(switch, state)
      end
    end
  elseif state ~= nil and switch ~= nil then
    self:SetCurrentlyPlayingMusic("Stinger", switch, state)
  end
  if switch == "Music_Arena" then
    self:SetCurrentlyPlayingMusic("Arena", switch, state)
  elseif switch == "MX_Arena" then
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Arena", state)
  end
end
function MusicManager:DarknessMusicEvent(switch, state)
  if state == "Major" or state == "Minor" then
    if self.isInDarkness then
      return
    end
    self.isInDarkness = true
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, switch, state)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Play_MX_Darkness")
  elseif state == "Abandoned" or state == "Completed" or self.darknessEntityId == nil and self.isInDarkness then
    self.isInDarkness = false
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, switch, state)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Stop_MX_Darkness")
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Darkness", "None")
  end
end
function MusicManager:DarknessMusicEventDB(switch, state, wwiseEvent, darknessEntityId)
  if self.darknessEntityId == darknessEntityId then
    if state ~= nil and switch ~= nil then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, switch, state)
    end
    if wwiseEvent ~= nil then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, wwiseEvent)
    end
  end
end
function MusicManager:RegisterDarknessEventDB(darknessEntityId, isActivated)
  if isActivated then
    self.darknessEntityId = darknessEntityId
  elseif self.darknessEntityId == darknessEntityId then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityIdOverride, "Stop_MX_Darkness")
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Darkness", "None")
    self.isInDarkness = false
    self.darknessEntityId = nil
  end
end
function MusicManager:onMixStateChanged(mixState)
  if self.playerSpawned then
    if mixState == "DeathsDoor" then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Context", "DeathsDoor")
      self.currentMixState = "DeathsDoor"
    elseif mixState == "Default" and self.currentMixState == "DeathsDoor" then
      for key, value in pairs(self.nonAmbientMusicTypes) do
        if self.currentlyPlayingMusicType == key and self.gameMode == "OutpostRush" then
          self:SetCurrentlyPlayingMusic("OutpostRush", "Music_OutpostRush", self.currentORState == "OR_Conclusion_Start" and "OR_Conclusion_Start" or "None")
        elseif self.currentlyPlayingMusicType == key then
          AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Context", self.currentlyPlayingMusicType)
        else
          AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Context", "Territory")
        end
      end
      self.currentMixState = "Default"
    elseif mixState == "Default" and self.currentMixState == "Death" then
      self:SetGameMode()
      if self.gameMode == "Siege" then
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Context", self.currentlyPlayingMusicType)
        self:SetCurrentlyPlayingMusic("Siege", "Music_Siege", "Siege_Start")
      elseif self.gameMode == "Invasion" then
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Context", self.currentlyPlayingMusicType)
        self:SetCurrentlyPlayingMusic("Invasion", "Music_Invasion", "Invasion_Start")
      elseif self.gameMode == "OutpostRush" then
        self:SetCurrentlyPlayingMusic("OutpostRush", "Music_OutpostRush", self.currentORState == "OR_Conclusion_Start" and "OR_Conclusion_Start" or "OR_Respawn")
      elseif self.gameMode == "Default" then
        if self.currentlyPlayingMusicType == "Dungeon" then
          AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Context", self.currentlyPlayingMusicType)
          AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Music_Dungeon", "MX_Start")
        else
          AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Context", "Territory")
        end
      end
      self.currentMixState = "Default"
    elseif mixState == "Dead" then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Context", "Death")
      self:onMusicReset()
      self.currentMixState = "Death"
    end
  end
end
function MusicManager:onMusicReset()
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Music_Dungeon", self.gameMode == "Dungeon" and "Dungeon" or "None")
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Music_OutpostRush", self.gameMode == "OutpostRush" and "OutpostRush" or "None")
end
function MusicManager:onDungeon_Started(dungeon_name)
  local isDungeon
  for key, value in pairs(self.gameModeList) do
    isDungeon = GameModeParticipantComponentRequestBus.Event.IsInGameMode(self.entityIdOverride, key)
    if isDungeon then
      self.gameMode = "Dungeon"
      return
    end
  end
  self.gameMode = "Dungeon"
  self.currentlyPlayingMusicType = "Dungeon"
  self.currentPlayingDungeon = dungeon_name
  AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("rtpc_MX_Combat", 0)
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Context", "Dungeon")
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Dungeon", self.currentPlayingDungeon)
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "Music_Dungeon", "MX_Start")
end
function MusicManager:onDungeonArea_Interact(dungeon_name, dungeon_mx_group, dungeon_mx_state, onExit)
  if self.currentPlayingDungeon == nil or self.currentPlayingDungeon == "" then
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Dungeon", dungeon_name)
    self.currentPlayingDungeon = dungeon_name
  end
  if dungeon_mx_state ~= nil and dungeon_mx_state ~= "" then
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Context", "Dungeon")
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, dungeon_mx_group, dungeon_mx_state)
  end
end
function MusicManager:onDungeonMusic_Changed(dungeon_mx_group, dungeon_mx_state)
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Context", "Dungeon")
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, dungeon_mx_group, dungeon_mx_state)
end
function MusicManager:OnUnselectedAsTarget(EntityId)
  self:OnUnselectedAsTargetInternal(EntityId, false)
end
function MusicManager:UntargetedFailsafe(EntityId)
  self:OnUnselectedAsTargetInternal(EntityId, false)
end
function MusicManager:OnSelectedAsTarget(EntityId)
  local entityString = tostring(EntityId)
  self.combatMusicState = nil
  for key, string in pairs(self.targetingAIs) do
    if TagComponentRequestBus.Event.HasTag(EntityId, Math.CreateCrc32(key)) then
      self.targetingAIEntityTypeAndId[entityString] = key
      table.insert(self.targetingAIEntityIdList, entityString)
      DynamicBus.audioAITrackerBus.Event.OnTargetingPlayerHDR(EntityId, true)
      self:WhoIsTargetingMe(true)
      if self.combatMusicMapping[self.targetingAIEntityTypeAndId[entityString]] ~= nil then
        self.combatMusicState = self.combatMusicMapping[self.targetingAIEntityTypeAndId[entityString]].StartState
      end
      self:StartCombatMusic(EntityId)
    end
  end
end
function MusicManager:OnUnselectedAsTargetInternal(EntityId, isDead)
  if EntityId == nil then
    return
  end
  local entityString = tostring(EntityId)
  for k = table.maxn(self.targetingAIEntityIdList), 1, -1 do
    if entityString == self.targetingAIEntityIdList[k] then
      if self.combatMusicMapping[self.targetingAIEntityTypeAndId[entityString]] ~= nil then
        self.combatMusicEndState = self.combatMusicMapping[self.targetingAIEntityTypeAndId[entityString]].EndState
      end
      self.targetingAIEntityTypeAndId[entityString] = nil
      table.remove(self.targetingAIEntityIdList, k)
      DynamicBus.audioAITrackerBus.Event.OnTargetingPlayerHDR(EntityId, false)
      self:WhoIsTargetingMe(false)
    end
  end
  if self.unitsTargeting == 0 then
    AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("rtpc_MX_Combat", 0)
    self:EndCombatMusic(false)
  end
  if isDead then
    self:OnNPCDeactivated(EntityId)
  end
  if self.combatMusicState == nil then
    return
  end
end
function MusicManager:StartCombatMusic(EntityId)
  if self.combatMusicState ~= nil and self.currentlyPlayingMusicType ~= "CombatStart" then
    self:SetCurrentlyPlayingMusic("CombatStart", "Music_Combat", self.combatMusicState)
    self.aiTargetingEntityId = EntityId
  end
end
function MusicManager:EndCombatMusic(shouldEnd)
  if shouldEnd then
    if self.unitsTargeting == 0 and self.combatMusicEndState ~= nil then
      self:SetCurrentlyPlayingMusic("CombatEnd", "Music_Combat", self.combatMusicEndState)
      self.aiTargetingEntityId = nil
      self.combatMusicEndState = nil
      self.canCombatMusicTick = false
    end
  elseif self.unitsTargeting == 0 then
    self.combatMusicEndDeltaTime = 0
    self.canCombatMusicTick = true
  end
end
function MusicManager:WhoIsTargetingMe(targeting)
  self.unitsTargeting = 0
  for key, int in pairs(self.targetingAIs) do
    self.targetingAIs[key] = 0
  end
  for key, string in pairs(self.targetingAIEntityTypeAndId) do
    self.targetingAIs[string] = self.targetingAIs[string] + 1
    self.unitsTargeting = self.unitsTargeting + 1
  end
  if self.unitsTargeting >= 3 then
    AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("rtpc_MX_Combat", 10)
  else
    AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("rtpc_MX_Combat", 5)
  end
  return self.unitsTargeting
end
function MusicManager:OnNPCActivated(npcEntityId)
  local entityString = tostring(npcEntityId)
  for key, string in pairs(self.aliveAIs) do
    if TagComponentRequestBus.Event.HasTag(npcEntityId, Math.CreateCrc32(key)) and self.combatMusicMapping[key] ~= nil then
      self.aliveAIEntityTypeAndId[entityString] = key
      table.insert(self.aliveAIEntityIdStringList, entityString)
      table.insert(self.aliveAIEntityIdList, npcEntityId)
      self:CheckAliveNPC(true)
    end
  end
end
function MusicManager:OnNPCDeath(npcEntityId)
  self:OnUnselectedAsTargetInternal(npcEntityId, true)
end
function MusicManager:OnNPCDeactivated(npcEntityId)
  local entityString = tostring(npcEntityId)
  for k = table.maxn(self.aliveAIEntityIdStringList), 1, -1 do
    if entityString == self.aliveAIEntityIdStringList[k] then
      self.aliveAIEntityTypeAndId[entityString] = nil
      table.remove(self.aliveAIEntityIdStringList, k)
      self:CheckAliveNPC(false)
    end
  end
  for k = table.maxn(self.aliveAIEntityIdList), 1, -1 do
    if npcEntityId == self.aliveAIEntityIdList[k] then
      self.aliveAIEntityTypeAndId[npcEntityId] = nil
      table.remove(self.aliveAIEntityIdList, k)
    end
  end
end
function MusicManager:CheckAliveNPC(alive)
  self.unitsAlive = 0
  for key, int in pairs(self.aliveAIs) do
    self.aliveAIs[key] = 0
  end
  for key, string in pairs(self.aliveAIEntityTypeAndId) do
    self.aliveAIs[string] = self.aliveAIs[string] + 1
    self.unitsAlive = self.unitsAlive + 1
  end
  return self.unitsAlive
end
function MusicManager:CheckAiThreat()
  self.isAiThreatening = false
  local playerWorldPosition = TransformBus.Event.GetWorldTranslation(self.entityIdOverride)
  if playerWorldPosition ~= nil then
    for k = table.maxn(self.aliveAIEntityIdList), 1, -1 do
      if self.aliveAIEntityIdList[k] ~= nil then
        local aiWorldPosition = TransformBus.Event.GetWorldTranslation(self.aliveAIEntityIdList[k])
        local distanceToAi = Vector3.GetDistance(aiWorldPosition, playerWorldPosition)
        if distanceToAi <= self.aiThreatDistance then
          self.isAiThreatening = true
          return self.isAiThreatening
        end
      end
    end
  end
end
function MusicManager:OnPlayerActivated(playerEntityId)
  local entityString = tostring(playerEntityId)
  table.insert(self.alivePlayerEntityIdList, playerEntityId)
  self:CheckAlivePlayers(true)
end
function MusicManager:OnPlayerDeactivated(playerEntityId)
  local entityString = tostring(playerEntityId)
  for k = table.maxn(self.alivePlayerEntityIdList), 1, -1 do
    if playerEntityId == self.alivePlayerEntityIdList[k] then
      table.remove(self.alivePlayerEntityIdList, k)
    end
  end
end
function MusicManager:CheckAlivePlayers(alive)
  self.totalPlayersAlive = 0
  for key, string in pairs(self.alivePlayerEntityIdList) do
    self.totalPlayersAlive = self.totalPlayersAlive + 1
  end
  return self.totalPlayersAlive
end
function MusicManager:OnTick(deltaTime, timePoint)
  self.deltaTime = self.deltaTime + deltaTime
  if self.isLocalPlayer then
    if self.canCombatMusicTick then
      self.combatMusicEndDeltaTime = self.combatMusicEndDeltaTime + deltaTime
      if self.combatMusicEndDeltaTime > self.combatMusicEndPad then
        self:CheckAiThreat()
        if not self.isAiThreatening then
          self.canCombatMusicTick = false
          self:EndCombatMusic(true)
        else
          self.combatMusicEndDeltaTime = 0
        end
      end
    end
    if self.currentlyPlayingMusicType == "None" then
      self.musicOffTime = self.musicOffTime + deltaTime
      if self.musicOffTime > 5 then
        self:CheckAiThreat()
        if not self.isAiThreatening and self.gameMode == "Default" then
          if not self.playerInSettlement then
            self:SetCurrentlyPlayingMusic("Ambient", "MX_Gameplay", "Ambient")
          else
            self:SetCurrentlyPlayingMusic("Settlement", "MX_Gameplay", "Settlement")
          end
        end
        self.musicOffTime = 0
      end
    end
  end
  self.deltaTime = 0
end
function MusicManager:onSpectatorChanged(bool, spectatorEntityId)
  if bool == 1 then
    self.entityIdOverride = spectatorEntityId
  else
    self.entityIdOverride = self.entitydId
  end
end
function MusicManager:SetCurrentlyPlayingMusic(musicType, switchName, state)
  if (self.currentlyPlayingMusicType == "None" or self.currentlyPlayingMusicType == "Settlement" and self.gameMode == "Default") and (musicType == "Ambient" or musicType == "Settlement") then
    self:ChangeSwitches(musicType, switchName, state)
  end
  if (self.currentlyPlayingMusicType == "Ambient" or self.currentlyPlayingMusicType == "None") and musicType == "Stinger" then
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, switchName, state)
    self.currentlyPlayingMusicType = musicType
    TimingUtils:Delay(self.entityIdOverride, 12, function()
      self.currentlyPlayingMusicType = "None"
    end)
  end
  if self.currentlyPlayingMusicType ~= "Invasion" and self.currentlyPlayingMusicType ~= "Siege" and self.currentlyPlayingMusicType ~= "Dungeon" and self.currentlyPlayingMusicType ~= "Arena" and (musicType == "CombatStart" or musicType == "CombatEnd") and self.currentORState ~= "OR_Conclusion_Start" then
    self:ChangeSwitches(musicType, switchName, state)
  end
  if musicType == "Invasion" or musicType == "Siege" or musicType == "Arena" or musicType == "Settlement" or musicType == "Housing" then
    if state == "Siege_CP_Captured" or state == "Siege_CP_Lost" then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, switchName, state)
      TimingUtils:Delay(self.entityIdOverride, 3, function()
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, switchName, "None")
      end)
    elseif state == "Settlement" then
      self:OnSeasonChanged()
      self:ChangeSwitches(musicType, switchName, state)
    elseif state == "None" then
      self.currentlyPlayingMusicType = "None"
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, switchName, state)
    else
      self:ChangeSwitches(musicType, switchName, state)
    end
  end
  if musicType == "OutpostRush" then
    if self.currentORState == "OR_Conclusion_Start" and (state == "OR_Outpost_Enter" or state == "OR_Outpost_Exit" or musicType == "CombatStart") then
      return
    else
      self:ChangeSwitches(musicType, switchName, state)
    end
    self.currentORState = state
  end
  if musicType == "Duel" then
    self:ChangeSwitches(musicType, switchName, state)
    if state == "Duel_Lose" or state == "Duel_Win" then
      TimingUtils:Delay(self.entityIdOverride, 10, function()
        self.currentlyPlayingMusicType = "None"
      end)
    end
  end
  if musicType == "Dungeon" then
    self:onDungeonMusic_Changed(switchName, state)
  end
end
function MusicManager:ChangeSwitches(musicType, customSwitch, customState)
  if self.isLoading then
    self.customSwitch = customSwitch
    self.customState = customState
    self.musicType = musicType
    self.currentlyPlayingMusicType = musicType
    self.queueMusic = true
  else
    for switch, state in pairs(self.musicData[musicType]) do
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, switch, state)
    end
    if customSwitch ~= nil and customState ~= nil then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, customSwitch, customState)
    end
    if musicType == "CombatEnd" then
      self.currentlyPlayingMusicType = "None"
    else
      self.currentlyPlayingMusicType = musicType
    end
  end
end
function MusicManager:OnSeasonChanged()
  local currentTimeSeconds = WallClockTimePoint:Now():SubtractSeconds(WallClockTimePoint()):ToSeconds()
  local dateInfo = os.date("*t", currentTimeSeconds)
  local holidaysTable = {
    ["12/24"] = "Xmas",
    ["12/25"] = "Xmas",
    ["12/31"] = "NewYears",
    ["1/1"] = "NewYears",
    ["2/14"] = "Valentines"
  }
  local date = dateInfo.month .. "/" .. dateInfo.day
  local holiday = holidaysTable[date]
  if holiday ~= nil then
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Season", holiday)
  else
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "MX_Season", "_Default")
  end
end
function MusicManager:OnLoadingScreenShown()
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "UI_state", "Loading")
  self.isLoading = true
end
function MusicManager:OnLoadingScreenDismissed()
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, "UI_State", "Default")
  self.isLoading = false
  if self.queueMusic then
    for switch, state in pairs(self.musicData[self.musicType]) do
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, switch, state)
    end
    if self.customSwitch ~= nil and self.customState ~= nil then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityIdOverride, self.customSwitch, self.customState)
    end
    if self.musicType == "CombatEnd" then
      self.currentlyPlayingMusicType = "None"
    else
      self.currentlyPlayingMusicType = self.musicType
    end
    self.queueMusic = false
  end
end
function MusicManager:InitValidUnitTags()
  local validTags = self:loadTxtFile(AudioUtilsBus.Broadcast.LoadFile("@assets@/Sounds/wwise/Valid_Npc_Tags.csv"))
  for key, string in pairs(validTags) do
    self.targetingAIs[string] = 0
    self.aliveAIs[string] = 0
  end
end
function MusicManager:loadTxtFile(rawMappingsString, hasTwoColumns)
  rawMappingsString = tostring(rawMappingsString)
  local csvFileData = {}
  for s in rawMappingsString:gmatch("[^\r\n\",]+") do
    table.insert(csvFileData, s)
  end
  return csvFileData
end
function MusicManager:InitMusicParams()
  self.musicData = {
    Ambient = {
      MX_Context = "Territory",
      MX_Gameplay = "Ambient",
      Mix_state = "Default",
      Music_Combat = "None"
    },
    Settlement = {
      MX_Context = "Territory",
      MX_Gameplay = "Settlement",
      Mix_state = "Default",
      Music_Combat = "None"
    },
    Housing = {
      MX_Context = "Housing",
      MX_Gameplay = "Settlement",
      Mix_state = "Default",
      Music_Combat = "None"
    },
    Invasion = {MX_Context = "Invasion", Mix_state = "Invasion"},
    Siege = {MX_Context = "Siege", Mix_state = "Siege"},
    OutpostRush = {
      MX_Context = "OutpostRush",
      Mix_state = "OutpostRush"
    },
    Duel = {MX_Context = "Duel", Mix_state = "Duel"},
    Arena = {MX_Context = "Arena", Mix_state = "Arena"},
    CombatStart = {MX_Context = "Combat", Mix_state = "Combat"},
    CombatEnd = {Mix_state = "Default"}
  }
  self.nonAmbientMusicTypes = {
    Invasion = "true",
    Siege = "true",
    Dungeon = "true",
    Duel = "true",
    Arena = "true",
    OutpostRush = "true"
  }
end
function loadTwoColumCSV(rawMappingsString)
  local table = {}
  for s in rawMappingsString:gmatch("[^\r\n]+") do
    lineParts = StringSplit(s, ",")
    table[lineParts[1]] = lineParts[2]
  end
  return table
end
function loadThreeColumnCSV(rawMappingsString)
  local table = {}
  for s in rawMappingsString:gmatch("[^\r\n]+") do
    lineParts = StringSplit(s, ",")
    table[lineParts[1]] = {
      StartState = lineParts[2],
      EndState = lineParts[3]
    }
  end
  return table
end
function MusicManager:OnDeactivate()
  if self.isLocalPlayer then
    self.playerSpawned = false
    self.targetingAIEntityIdList = nil
    if self.playerSpawningBusHandler then
      DynamicBus.playerSpawningBus.Disconnect(self.entityIdOverride, self)
      self.playerSpawningBusHandler = nil
    end
    if self.aiVitalsComponentBusHandler then
      self.aiVitalsComponentBusHandler:Disconnect()
      self.aiVitalsComponentBusHandler = nil
    end
    if self.AITargetSelectionBusHandler then
      self.AITargetSelectionBusHandler:Disconnect()
      self.AITargetSelectionBusHandler = nil
    end
    if self.LandClaimBusHandler then
      self.LandClaimBusHandler:Disconnect()
      self.LandClaimBusHandler = nil
    end
    if self.EntityBusHandler then
      self.EntityBusHandler:Disconnect()
      self.EntityBusHandler = nil
    end
    if self.tickBusHandler then
      self.tickBusHandler:Disconnect()
      self.tickBusHandler = nil
    end
    if self.triggerAreaEntityBusHandler then
      self.triggerAreaEntityBusHandler:Disconnect()
      self.triggerAreaEntityBusHandler = nil
    end
    if self.PlayerComponentBusHandler then
      self.PlayerComponentBusHandler:Disconnect()
      self.PlayerComponentBusHandler = nil
    end
    if self.transformNotificationBusHandler then
      self.transformNotificationBusHandler:Disconnect()
      self.transformNotificationBusHandler = nil
    end
    if self.uiTriggerAreaEventBusHandler then
      self.uiTriggerAreaEventBusHandler:Disconnect()
      self.uiTriggerAreaEventBusHandler = nil
    end
    if self.loadScreenBusHandler then
      self.loadScreenBusHandler:Disconnect()
      self.loadScreenBusHandler = nil
    end
    if dataLayer then
      dataLayer:UnregisterObservers(self)
    end
  else
    if self.EntityBusHandler then
      self.EntityBusHandler:Disconnect()
      self.EntityBusHandler = nil
    end
    if self.PlayerComponentBusHandler then
      self.PlayerComponentBusHandler:Disconnect()
    end
  end
end
return MusicManager

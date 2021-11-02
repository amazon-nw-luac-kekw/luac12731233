local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local OWMissionBoard = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    GuildList = {
      default = EntityId()
    },
    GuildShop = {
      default = EntityId()
    },
    MissionDetailsPopup = {
      default = EntityId()
    },
    CompleteMissionButton = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    Scrim = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    InfluenceWarInfo = {
      default = EntityId()
    },
    InfluenceWarContainer = {
      default = EntityId()
    },
    NoOwningFactionWidget = {
      default = EntityId()
    },
    CurrentTerritoryText = {
      default = EntityId()
    },
    WarGovernanceContainer = {
      default = EntityId()
    },
    AttackerCrest = {
      default = EntityId()
    },
    AttackerWash = {
      default = EntityId()
    },
    DefenderCrest = {
      default = EntityId()
    },
    DefenderWash = {
      default = EntityId()
    },
    ConflictText = {
      default = EntityId()
    },
    ConflictTextBg = {
      default = EntityId()
    },
    MissionRefreshTime = {
      default = EntityId()
    },
    MissionRefreshContainer = {
      default = EntityId()
    },
    TimeLabel = {
      default = EntityId()
    },
    TaskRefreshHolder = {
      default = EntityId()
    },
    DailyBonusText = {
      default = EntityId()
    },
    DailyBonusLabel = {
      default = EntityId()
    }
  },
  guildIdToName = {
    [1459346962] = "@ui_faction_name1",
    [1410032581] = "@ui_faction_name2",
    [4109074679] = "@ui_faction_name3",
    [1175253129] = "@battle_token_guildname"
  },
  FACTION_MISSION_BONUS = 2245201753,
  STATE_MISSION_BOARD = 1,
  STATE_MISSION_SHOP = 2,
  STATE_MISSION_DETAIL = 3,
  ARMORY_GUILD_NAME = 1175253129,
  NUM_MISSIONS_SHOWN = 3,
  basicCrestBg = "lyshineui/images/crests/backgrounds/icon_shield_shape1V1.dds",
  invasionCrestFg = "lyshineui/images/crests/foregrounds/icon_crest_44.dds",
  lastSortedPveMissionList = {},
  lastSortedPvpMissionList = {}
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(OWMissionBoard)
local territoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function OWMissionBoard:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterOpenEvent("OWMissionBoard", self.canvasId)
  self:SetVisualElements()
  self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.Frame, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.MasterContainer, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.GuildList, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.InfluenceWarContainer, {opacity = 0})
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ObjectiveEntityId", self.OnObjectiveEntityIdChanged)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.EventNotificationEntityId", self.OnProgressionEntityIdChanged)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildShop, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildList, false)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  DynamicBus.OWGDynamicRequestBus.Connect(self.entityId, self)
  self.currentState = self.STATE_MISSION_BOARD
  self.factionInfoTable = factionCommon.factionInfoTable
  if LyShineScriptBindRequestBus.Broadcast.IsEditor() then
    self:OpenGuildShop(3132300288)
  end
end
function OWMissionBoard:OnObjectiveEntityIdChanged(entityId)
  self.objectiveEntityId = entityId
end
function OWMissionBoard:OnObjectiveAdded(objectiveId)
  self:ObjectiveDataReady()
end
function OWMissionBoard:OnObjectiveRemoved(objectiveId)
  self:ObjectiveDataReady()
end
function OWMissionBoard:OnProgressionEntityIdChanged(entityId)
  self.progressionEntityId = entityId
end
function OWMissionBoard:SetVisualElements()
  self.ScreenHeader:SetHintCallback(self.OnEscapeKeyPressed, self)
  self.ScreenHeader:SetBgVisible(false)
  SetTextStyle(self.Properties.TimeLabel, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  SetTextStyle(self.Properties.DailyBonusLabel, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  self.CompleteMissionButton:SetText("@owg_action_complete")
  self.CompleteMissionButton:SetCallback(self.ShowActiveMissionDetails, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
end
function OWMissionBoard:UpdateDailyBonus()
  local max = GameEventRequestBus.Broadcast.GetMaxDailyBonuses(self.FACTION_MISSION_BONUS)
  local current = GameEventRequestBus.Broadcast.GetAvailableDailyBonuses(self.FACTION_MISSION_BONUS)
  if self.previousBonuses and current < self.previousBonuses then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_daily_mission_bonus_awarded"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  self.previousBonuses = current
  UiTextBus.Event.SetText(self.Properties.DailyBonusText, tostring(current) .. "/" .. tostring(max))
end
function OWMissionBoard:OnTransitionIn(stateName, levelName, toState, toLevel)
  if self.isVisible then
    return
  end
  self.showInfluenceWarInfo = false
  self.claimKey = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  self.validClaimKey = self.claimKey and self.claimKey ~= 0
  if self.validClaimKey then
    local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.claimKey)
    self:UpdateInfluenceWarInfo(self.claimKey, ownerData)
    self:RegisterForUpdates()
  end
  self.isVisible = true
  self:BusDisconnect(self.objectiveInteractorHandler)
  self.objectiveInteractorHandler = self:BusConnect(ObjectiveInteractorNotificationBus, self.entityId)
  self.owGuilds = ObjectiveInteractorRequestBus.Broadcast.GetCurrentMissionCategories()
  if #self.owGuilds then
    self.currentGuild = self.owGuilds[1]
  else
    self.currentGuild = nil
  end
  if self:IsUsingSiegeArmory() then
    self.InfluenceWarInfo:SetIsEnabled(false)
    UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceWarContainer, false)
  end
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  local factionName = self.factionInfoTable[faction].factionName
  self.ScreenHeader:SetText(LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_missions_header", factionName), true)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_FactionMission", 0.5)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", false)
  self.ScriptedEntityTweener:PlayC(self.entityId, 0.5, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, 0.5, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.MasterContainer, 0.5, tweenerCommon.fadeInQuadOut, 0.2)
  self.ScriptedEntityTweener:PlayC(self.Properties.GuildList, 0.5, tweenerCommon.fadeInQuadOut, 0.2)
  self.ScriptedEntityTweener:PlayC(self.Properties.InfluenceWarContainer, 0.5, tweenerCommon.fadeInQuadOut, 0.2)
  self.ScriptedEntityTweener:PlayC(self.Properties.TaskRefreshHolder, 0.5, tweenerCommon.fadeInQuadOut, 0.2)
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 5
  self.targetDOFBlur = 0.8
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 1.2,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
  UiElementBus.Event.SetIsEnabled(self.Properties.CompleteMissionButton, false)
  self:BusDisconnect(self.objectivesComponentBusHandler)
  self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, self.objectiveEntityId)
  UiElementBus.Event.SetIsEnabled(self.Properties.MissionDetailsPopup, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildList, false)
  self.currentState = self.STATE_MISSION_BOARD
  self.fromConversationService = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ConversationServiceOpen")
  self:UpdateDailyBonus()
  local missionId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OpenMapMission")
  if missionId ~= nil then
    self:ObjectiveDataReady(missionId)
    LyShineDataLayerBus.Broadcast.Delete("Hud.LocalPlayer.OpenMapMission")
  elseif self.fromConversationService or self:IsUsingSiegeArmory() then
    self:ObjectiveDataReady()
  end
  local duration = ObjectiveInteractorRequestBus.Broadcast.GetTimeTillNextProviderUpdate()
  self.MissionRefreshTime:SetOmitZeros(true)
  self.MissionRefreshTime:SetCurrentCountdownTime(duration:ToSeconds())
end
function OWMissionBoard:RegisterForUpdates()
  self.landClaimNotificationBusHandler = self:BusConnect(LandClaimNotificationBus)
end
function OWMissionBoard:UnregisterForUpdates()
  if self.landClaimNotificationBusHandler then
    self:BusDisconnect(self.landClaimNotificationBusHandler)
    self.landClaimNotificationBusHandler = nil
  end
end
function OWMissionBoard:OnTerritoryFactionInfluenceChanged(claimKey, influenceData)
  if self.showInfluenceWarInfo then
    self.InfluenceWarInfo:UpdateInfluenceBars(influenceData)
  end
end
function OWMissionBoard:OnClaimOwnerChanged(claimKey, newOwnerData, oldOwnerData)
  if self.claimKey == claimKey then
    self:UpdateInfluenceWarInfo(claimKey, newOwnerData)
  end
end
function OWMissionBoard:UpdateInfluenceWarInfo(claimKey, ownerData)
  UiElementBus.Event.SetIsEnabled(self.Properties.WarGovernanceContainer, false)
  factionCommon:GetFaction(ownerData.guildId, function(self, owningFaction, owningCrest)
    local territoryName = territoryDataHandler:GetCurrentTerritoryName()
    local localTerritoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
    local influenceData = LandClaimRequestBus.Broadcast.GetTerritoryFactionInfluencePercentages(localTerritoryId)
    if not owningFaction then
      self.showInfluenceWarInfo = false
      self.showNoOwningFactionWidget = true
      UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceWarContainer, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.NoOwningFactionWidget, true)
      UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentTerritoryText, territoryName, eUiTextSet_SetLocalized)
    else
      self.showInfluenceWarInfo = true
      self.showNoOwningFactionWidget = false
      UiElementBus.Event.SetIsEnabled(self.Properties.NoOwningFactionWidget, false)
      local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(claimKey)
      local validWarDetails
      if warDetails:IsValid() and warDetails:IsWarActive() then
        validWarDetails = warDetails
      end
      if validWarDetails then
        self.guildId = ownerData.guildId
        self.guildName = ownerData.guildName
        self.guildCrestData = ownerData.guildCrestData
        local isClaimed = self.guildId and self.guildId:IsValid()
        if isClaimed then
          self.DefenderCrest:SetIcon(self.guildCrestData)
          UiImageBus.Event.SetColor(self.Properties.DefenderWash, self.guildCrestData.backgroundColor)
        end
        local warPhase = validWarDetails:GetWarPhase()
        local isConflict = warPhase == eWarPhase_Conquest
        local isResolution = warPhase == eWarPhase_Resolution
        if validWarDetails:IsInvasion() then
          self.AttackerCrest:SetBackground(self.basicCrestBg, self.UIStyle.COLOR_RED_DEEP)
          self.AttackerCrest:SetForeground(self.invasionCrestFg, self.UIStyle.COLOR_RED)
          UiImageBus.Event.SetColor(self.Properties.AttackerWash, self.UIStyle.COLOR_RED_DARK)
          if isConflict or isResolution then
            UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_encounter_ongoinginvasion", eUiTextSet_SetLocalized)
          else
            UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_encounter_upcominginvasion", eUiTextSet_SetLocalized)
          end
        else
          local otherGuildId = validWarDetails:GetOtherGuild(self.guildId)
          local ready = SocialDataHandler:GetGuildDetailedData_ServerCall(self, function(self, result)
            local guildData
            if 0 < #result then
              guildData = type(result[1]) == "table" and result[1].guildData or result[1]
            else
              Log("ERR - OWMissionBoard:UpdateInfluenceWarInfo: GuildData request returned with no data")
              return
            end
            if guildData and guildData:IsValid() then
              UiElementBus.Event.SetIsEnabled(self.Properties.AttackerCrest, true)
              self.AttackerCrest:SetIcon(guildData.crestData)
              UiImageBus.Event.SetColor(self.Properties.AttackerWash, guildData.crestData.backgroundColor)
            end
          end, function()
            Log("ERR - OWMissionBoard:UpdateInfluenceWarInfo: GuildData request returned with no data")
          end, otherGuildId)
          if not ready then
            UiElementBus.Event.SetIsEnabled(self.Properties.AttackerCrest, false)
          end
          if isConflict or isResolution then
            UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_encounter_ongoingwar", eUiTextSet_SetLocalized)
          else
            UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_encounter_upcomingwar", eUiTextSet_SetLocalized)
          end
        end
        UiElementBus.Event.SetIsEnabled(self.Properties.AttackerWash, true)
        UiElementBus.Event.SetIsEnabled(self.Properties.DefenderWash, true)
        UiImageBus.Event.SetColor(self.Properties.ConflictTextBg, self.UIStyle.COLOR_RED_DARK)
        self.InfluenceWarInfo:SetIsEnabled(false)
        UiElementBus.Event.SetIsEnabled(self.Properties.WarGovernanceContainer, true)
        self.InfluenceWarInfo:SetInfluenceWarData(territoryName, owningFaction, owningCrest, influenceData, true)
      else
        local conflictFaction = 0
        for i = 1, #influenceData do
          local influencePercent = influenceData[i] / 100
          if influencePercent == 1 then
            conflictFaction = i
          end
        end
        if 0 < conflictFaction then
          local attackingFactionData = factionCommon.factionInfoTable[conflictFaction]
          local defendingFactionData = factionCommon.factionInfoTable[owningFaction]
          local blankBg = factionCommon.factionInfoTable[0].crestBgSmall
          self.AttackerCrest:SetForeground(attackingFactionData.crestFgSmall, attackingFactionData.crestBgColor)
          self.AttackerCrest:SetBackground(blankBg, attackingFactionData.crestBgColor)
          UiElementBus.Event.SetIsEnabled(self.Properties.AttackerWash, false)
          self.DefenderCrest:SetForeground(defendingFactionData.crestFgSmall, defendingFactionData.crestBgColor)
          self.DefenderCrest:SetBackground(blankBg, defendingFactionData.crestBgColor)
          UiElementBus.Event.SetIsEnabled(self.Properties.DefenderWash, false)
          self.InfluenceWarInfo:SetIsEnabled(false)
          UiElementBus.Event.SetIsEnabled(self.Properties.WarGovernanceContainer, true)
          UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_in_conflict", eUiTextSet_SetLocalized)
          UiImageBus.Event.SetColor(self.Properties.ConflictTextBg, attackingFactionData.crestBgColor)
          self.InfluenceWarInfo:SetInfluenceWarData(territoryName, owningFaction, owningCrest, influenceData, true)
        else
          UiElementBus.Event.SetIsEnabled(self.Properties.AttackerWash, true)
          UiElementBus.Event.SetIsEnabled(self.Properties.DefenderWash, true)
          UiImageBus.Event.SetColor(self.Properties.ConflictTextBg, self.UIStyle.COLOR_RED_DARK)
          self.InfluenceWarInfo:SetInfluenceWarData(territoryName, owningFaction, owningCrest, influenceData)
          self.showInfluenceWarInfo = true
          self.InfluenceWarInfo:SetIsEnabled(self.showInfluenceWarInfo)
        end
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceWarContainer, true)
    end
  end, self)
end
function OWMissionBoard:IsDuplicateObjective(creationParamsLeft, creationParamsRight)
  return creationParamsLeft.missionId == creationParamsRight.missionId and creationParamsLeft.destinationOverride == creationParamsRight.destinationOverride
end
function OWMissionBoard:PopulateLastMissionList(listToPopulate, missionList)
  for i, creationParams in pairs(missionList) do
    listToPopulate[i] = {
      missionId = creationParams.missionId,
      destinationOverride = creationParams.destinationOverride
    }
  end
end
function OWMissionBoard:SortMissionList(currentMissionList, missionData, lastSortedList)
  local invalidMissionFlags = {}
  local invalidMissionFlagsForMissionData = {}
  local finalMissionList = {}
  for i, curMission in pairs(lastSortedList) do
    for j = 1, #currentMissionList do
      if self:IsDuplicateObjective(currentMissionList[j], curMission) then
        invalidMissionFlags[j] = true
        finalMissionList[i] = currentMissionList[j]
        break
      end
    end
  end
  for i = 1, #missionData do
    if ObjectivesComponentRequestBus.Event.HasMission(self.playerEntityId, missionData[i].missionId) then
      invalidMissionFlagsForMissionData[i] = true
    end
  end
  local replaceableIndices = {}
  for i = 1, self.NUM_MISSIONS_SHOWN do
    if finalMissionList[i] == nil then
      table.insert(replaceableIndices, i)
    end
  end
  if #replaceableIndices == 0 then
    return finalMissionList
  end
  local missionToReplaceIdx = 1
  for i = 1, #currentMissionList do
    if not invalidMissionFlags[i] and missionToReplaceIdx <= #replaceableIndices then
      finalMissionList[replaceableIndices[missionToReplaceIdx]] = currentMissionList[i]
      missionToReplaceIdx = missionToReplaceIdx + 1
    elseif missionToReplaceIdx > #replaceableIndices then
      break
    end
  end
  replaceableIndices = {}
  for i = 1, self.NUM_MISSIONS_SHOWN do
    if finalMissionList[i] == nil then
      table.insert(replaceableIndices, i)
    end
  end
  if #replaceableIndices == 0 then
    return finalMissionList
  end
  missionToReplaceIdx = 1
  for i = 1, #missionData do
    if not invalidMissionFlagsForMissionData[i] and missionToReplaceIdx <= #replaceableIndices then
      local existingIndexToUse = 0
      for j, curMission in pairs(lastSortedList) do
        if self:IsDuplicateObjective(missionData[i], curMission) then
          for k = missionToReplaceIdx, #replaceableIndices do
            if j == replaceableIndices[k] then
              existingIndexToUse = k
            end
          end
        end
      end
      if existingIndexToUse == 0 then
        finalMissionList[replaceableIndices[missionToReplaceIdx]] = missionData[i]
        missionToReplaceIdx = missionToReplaceIdx + 1
      else
        finalMissionList[replaceableIndices[existingIndexToUse]] = missionData[i]
        table.remove(replaceableIndices, existingIndexToUse)
      end
    elseif missionToReplaceIdx > #replaceableIndices then
      break
    end
  end
  return finalMissionList
end
function OWMissionBoard:ObjectiveDataReady(showDetailsMissionId)
  if self:IsUsingSiegeArmory() then
    self:OpenGuildShop(1175253129)
  else
    self.currentMissionId = ObjectivesComponentRequestBus.Event.GetCurrentMissionId(self.playerEntityId)
    local currentMissionObjectiveId = ObjectivesComponentRequestBus.Event.GetCurrentMissionObjectiveId(self.playerEntityId)
    local children = UiElementBus.Event.GetChildren(self.Properties.GuildList)
    if #children < 1 then
      return
    end
    local currentMissionList = {}
    local currentPvpMissionList = {}
    local objectiveList = ObjectivesComponentRequestBus.Event.GetObjectives(self.playerEntityId)
    local localTerritoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
    for i = 1, #objectiveList do
      local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveList[i])
      if objectiveType == eObjectiveType_Mission then
        local creationParams = ObjectiveRequestBus.Event.GetCreationParams(objectiveList[i])
        local missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(creationParams.missionId)
        local destinationData = self:GetDestination(creationParams.destinationOverride)
        local playerTerritoryId = TerritoryDetectorServiceRequestBus.Event.GetDetectedTerritoryId(self.playerEntityId)
        if playerTerritoryId and playerTerritoryId ~= 0 then
          if playerTerritoryId == creationParams.originTerritoryId or not missionData.forceReturnToGiver and missionData.availableTerritoryId == 0 then
            table.insert(missionData.isPvpMission and currentPvpMissionList or currentMissionList, creationParams)
          end
        elseif not destinationData or destinationData.settlementId == localTerritoryId then
          table.insert(missionData.isPvpMission and currentPvpMissionList or currentMissionList, creationParams)
        end
      end
    end
    local showDetailsGuildId, showDetailsParams
    local missionData = ObjectiveInteractorRequestBus.Broadcast.GetCurrentMissions()
    local finalMissionList = self:SortMissionList(currentMissionList, missionData, self.lastSortedPveMissionList)
    self.lastSortedPveMissionList = {}
    self:PopulateLastMissionList(self.lastSortedPveMissionList, finalMissionList)
    local pvpMissionData = ObjectiveInteractorRequestBus.Broadcast.GetCurrentPvpMissions()
    local finalPvpMissionList = self:SortMissionList(currentPvpMissionList, pvpMissionData, self.lastSortedPvpMissionList)
    self.lastSortedPvpMissionList = {}
    self:PopulateLastMissionList(self.lastSortedPvpMissionList, finalPvpMissionList)
    if children[1] then
      local guildEntry = self.registrar:GetEntityTable(children[1])
      guildEntry:SetGuildId(self.currentGuild, self.progressionEntityId, self.GuildShop)
      guildEntry:SetPveMissionData(finalMissionList)
      guildEntry:SetPvpMissionData(finalPvpMissionList)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.GuildList, true)
    if showDetailsParams then
      self:ShowMissionDetails(showDetailsParams, currentMissionObjectiveId, showDetailsGuildId)
    end
    self:ShowCompleteButton(false)
    local player = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
    local interactable = UiInteractorComponentRequestsBus.Event.GetInteractable(player)
    local structurePosition = TransformBus.Event.GetWorldTranslation(interactable)
    local rightOffsetDir = Vector3(1, 0, 0)
    local vecFromPlayerToStructure = Vector3(0, 1, 0)
    local upOffset = 1.3
    local rightOffset = 1.2
    local forwardOffset = 1
    local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    if faction == 3 then
      upOffset = 1
      rightOffset = 1.35
      forwardOffset = 2
    elseif faction == 2 then
      upOffset = 1.1
      rightOffset = 1.6
      forwardOffset = 2
    elseif faction == 1 then
      upOffset = 1.1
      rightOffset = 1
      forwardOffset = 2
    end
    local playerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
    if playerPosition then
      local structurePositionWithPlayerZ = Vector3(structurePosition.x, structurePosition.y, playerPosition.z)
      vecFromPlayerToStructure = structurePositionWithPlayerZ - playerPosition
      Vector3.Normalize(vecFromPlayerToStructure)
      rightOffsetDir = Vector3.CrossZAxis(vecFromPlayerToStructure)
      Vector3.Normalize(rightOffsetDir)
    end
    local lookAtPos = structurePosition
    lookAtPos.z = lookAtPos.z + upOffset
    lookAtPos = lookAtPos + rightOffsetDir * rightOffset
    lookAtPos = lookAtPos + vecFromPlayerToStructure * forwardOffset
    self.lookAtPos = lookAtPos
    if self.lookAtPos then
      JavCameraControllerRequestBus.Broadcast.SetCameraLookAt(self.lookAtPos, false)
    end
    local player = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    MeshComponentRequestBus.Event.SetVisibility(player, false)
    self:UpdateDailyBonus()
  end
end
function OWMissionBoard:IsUsingSiegeArmory()
  if self.currentGuild == self.ARMORY_GUILD_NAME then
    local warDetails = dominionCommon:GetWarDetails()
    if warDetails and warDetails:IsValid() and (warDetails:GetWarPhase() == eWarPhase_PreWar or warDetails:GetWarPhase() == eWarPhase_War or warDetails:GetWarPhase() == eWarPhase_Conquest) then
      return true
    end
    local localPlayerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    if localPlayerEntityId ~= nil and GameModeParticipantComponentRequestBus.Event.IsInGameMode(localPlayerEntityId, 2444859928) then
      return true
    end
  end
  return false
end
function OWMissionBoard:OnTransitionOut(stateName, levelName, toState, toLevel)
  UiElementBus.Event.SetIsEnabled(self.Properties.TaskRefreshHolder, true)
  self.ScriptedEntityTweener:Play(self.Properties.Frame, 0.35, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Scrim, 0.35, {opacity = 0, ease = "QuadOut"})
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", true)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  if not self.isVisible then
    LyShineManagerBus.Broadcast.TransitionOutComplete()
    return
  end
  self.isVisible = false
  if self.fromConversationService then
    self.fromConversationService = false
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ConversationServiceOpen", false)
  end
  self:UnregisterForUpdates()
  self.GuildShop:CloseGuildShop()
  self.MissionDetailsPopup:CloseMissionDetails()
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildList, true)
  local missionId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OpenMapMission")
  if missionId == nil then
    local interactorEntityNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
    if interactorEntityNode then
      local interactorEntity = interactorEntityNode:GetData()
      UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
    end
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  end
  local children = UiElementBus.Event.GetChildren(self.Properties.GuildList)
  for i = 1, #children do
    local guildEntry = self.registrar:GetEntityTable(children[i])
    guildEntry:OnTransitionOut(stateName, levelName, toState, toLevel)
  end
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.5)
  JavCameraControllerRequestBus.Broadcast.ClearCameraLookAt()
  self.ScriptedEntityTweener:PlayC(self.entityId, 0.1, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, 0.1, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.MasterContainer, 0.1, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.InfluenceWarContainer, 0.1, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.TaskRefreshHolder, 0.1, tweenerCommon.fadeOutQuadOut)
  local durationOut = 0.2
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = durationOut,
    opacity = 0,
    onComplete = function()
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    end
  })
  local player = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  MeshComponentRequestBus.Event.SetVisibility(player, true)
  self:BusDisconnect(self.objectivesComponentBusHandler)
  self:BusDisconnect(self.objectiveInteractorHandler)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function OWMissionBoard:RefreshAll()
  local children = UiElementBus.Event.GetChildren(self.Properties.GuildList)
  for i = 1, #self.owGuilds do
    local pveMissionData = ObjectiveInteractorRequestBus.Broadcast.GetCurrentMissions()
    local pvpMissionData = ObjectiveInteractorRequestBus.Broadcast.GetCurrentPvpMissions()
    if children[i] then
      local guildEntry = self.registrar:GetEntityTable(children[i])
      guildEntry:SetGuildId(self.owGuilds[i], self.progressionEntityId, self.GuildShop)
      guildEntry:SetPveMissionData(pveMissionData)
      guildEntry:SetPvpMissionData(pvpMissionData)
    end
  end
end
function OWMissionBoard:ShowCompleteButton(show)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompleteMissionButton, show)
end
function OWMissionBoard:OnExit()
  LyShineManagerBus.Broadcast.ExitState(2609973752)
end
function OWMissionBoard:OnShutdown()
  self:UnregisterForUpdates()
  DynamicBus.OWGDynamicRequestBus.Disconnect(self.entityId, self)
  BaseScreen.OnShutdown(self)
end
function OWMissionBoard:ShowMissionDetails(objectiveParams, objectiveId, guildId)
  if guildId == nil then
    local missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(objectiveParams.missionId)
    guildId = missionData.categoricalProgressionId
  end
  self.MissionDetailsPopup:ShowDetails(guildId, objectiveId, objectiveParams)
  self.currentState = self.STATE_MISSION_DETAIL
  self.audioHelper:PlaySound(self.audioHelper.OWG_OpenDetails)
end
function OWMissionBoard:ShowActiveMissionDetails()
  local objectiveId = ObjectivesComponentRequestBus.Event.GetCurrentMissionObjectiveId(self.playerEntityId)
  local missionParams = ObjectiveRequestBus.Event.GetCreationParams(objectiveId)
  if missionParams ~= nil then
    self:ShowMissionDetails(missionParams, objectiveId)
  end
end
function OWMissionBoard:GetGuildName(guildId)
  if self.guildIdToName[guildId] then
    return self.guildIdToName[guildId]
  end
  return ""
end
function OWMissionBoard:GetDestination(destinationId)
  return territoryDataHandler:GetDestination(destinationId)
end
function OWMissionBoard:GetMissionTitle(objectiveParams)
  return territoryDataHandler:GetMissionTitle(objectiveParams)
end
function OWMissionBoard:GetMissionDescription(objectiveParams)
  return territoryDataHandler:GetMissionDescription(objectiveParams)
end
function OWMissionBoard:OpenGuildShop(guildCRC)
  if self.GuildShop:OpenGuildShop(guildCRC) then
    self.currentState = self.STATE_MISSION_SHOP
    self.InfluenceWarInfo:SetIsEnabled(false)
    UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceWarContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.NoOwningFactionWidget, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TaskRefreshHolder, false)
    local isUsingSiegeArmory = self:IsUsingSiegeArmory()
    if isUsingSiegeArmory then
      JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_FortShop", 0.3)
    else
      JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_FactionShop", 0.3)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.MissionRefreshContainer, not isUsingSiegeArmory)
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
    self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
    self.targetDOFDistance = isUsingSiegeArmory and 2.5 or 0
    self.targetDOFBlur = isUsingSiegeArmory and 0.4 or 0.95
    self.ScriptedEntityTweener:StartAnimation({
      id = self.DOFTweenDummyElement,
      easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
      duration = 0.5,
      opacity = 1,
      onUpdate = function(currentValue, currentProgressPercent)
        self:UpdateDepthOfField(currentValue)
      end
    })
    self.audioHelper:PlaySound(self.audioHelper.Crafting_IntroStep2)
    self.ScriptedEntityTweener:Play(self.Properties.GuildList, 0.2, {opacity = 1}, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.GuildList, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.MissionDetailsPopup, false)
      end
    })
    local offsets = UiTransform2dBus.Event.GetOffsets(self.Properties.Frame)
    if isUsingSiegeArmory then
      self.ScreenHeader:SetText("@ui_armory")
      offsets.left = -200
      offsets.right = 0
      UiTransform2dBus.Event.SetOffsets(self.Properties.Frame, offsets)
      self.ScriptedEntityTweener:Play(self.Properties.Frame, 0.25, {opacity = 1, ease = "QuadOut"})
    else
      local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
      local factionName = self.factionInfoTable[faction].factionName
      self.ScreenHeader:SetText(LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@faction_shop_name", factionName), true)
      offsets.left = 300
      offsets.right = 200
      UiTransform2dBus.Event.SetOffsets(self.Properties.Frame, offsets)
      self.ScriptedEntityTweener:Play(self.Properties.Frame, 0.35, {opacity = 0, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.Scrim, 0.35, {opacity = 1, ease = "QuadOut"})
    end
  end
end
function OWMissionBoard:OnEscapeKeyPressed()
  if self.currentState == self.STATE_MISSION_SHOP then
    if self.GuildShop:GuildShopConfirmPopupIsOpen() then
      self.GuildShop:CloseConfirmPopup()
      return
    end
    if self:IsUsingSiegeArmory() then
      self.currentState = self.STATE_MISSION_BOARD
      self:OnExit()
    else
      JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_FactionMission", 0.4)
      JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
      self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
      self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
      self.targetDOFDistance = 5
      self.targetDOFBlur = 0.8
      self.ScriptedEntityTweener:StartAnimation({
        id = self.DOFTweenDummyElement,
        easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
        duration = 1.2,
        opacity = 1,
        onUpdate = function(currentValue, currentProgressPercent)
          self:UpdateDepthOfField(currentValue)
        end
      })
      self.audioHelper:PlaySound(self.audioHelper.Crafting_IntroStep1)
      self.ScriptedEntityTweener:Play(self.Properties.Frame, 0.35, {opacity = 1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.Scrim, 0.35, {opacity = 0, ease = "QuadOut"})
      self.ScriptedEntityTweener:PlayC(self.Properties.TaskRefreshHolder, 0.35, tweenerCommon.fadeInQuadOut)
      self.GuildShop:CloseGuildShop()
      self.InfluenceWarInfo:SetIsEnabled(self.showInfluenceWarInfo)
      UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceWarContainer, self.showInfluenceWarInfo)
      UiElementBus.Event.SetIsEnabled(self.Properties.NoOwningFactionWidget, self.showNoOwningFactionWidget)
      UiElementBus.Event.SetIsEnabled(self.Properties.TaskRefreshHolder, true)
      self.currentState = self.STATE_MISSION_BOARD
      UiElementBus.Event.SetIsEnabled(self.Properties.GuildList, true)
      self.ScriptedEntityTweener:Play(self.Properties.GuildList, 0.4, {opacity = 0}, {
        opacity = 1,
        ease = "QuadOut",
        delay = 0.1
      })
    end
  elseif self.currentState == self.STATE_MISSION_DETAIL then
    self.MissionDetailsPopup:CloseMissionDetails()
    UiElementBus.Event.SetIsEnabled(self.Properties.GuildList, true)
    self.currentState = self.STATE_MISSION_BOARD
  else
    self:OnExit()
  end
end
function OWMissionBoard:OnCloseMissionDetailsButtonPressed()
  self:OnEscapeKeyPressed()
end
function OWMissionBoard:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, 10)
end
function OWMissionBoard:OnInfluenceFactionMissionTurnedIn()
  local myFactionType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  self.InfluenceWarInfo:PlayInfluenceChangedAnimation(myFactionType)
end
return OWMissionBoard

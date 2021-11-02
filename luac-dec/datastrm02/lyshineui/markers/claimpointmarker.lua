local ClaimPointMarker = {
  Properties = {
    ClaimPointStatus = {
      default = EntityId()
    },
    ScreenStates = {
      OffScreen = {
        default = EntityId()
      }
    }
  },
  isOnScreen = true,
  claimMarkerTable = nil,
  requestedEnabled = 0,
  screenPosVec2 = Vector2(0),
  raidId = RaidId()
}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local registrar = RequireScript("LyShineUI.EntityRegistrar")
local tweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
local markerTypeData = RequireScript("LyShineUI.Markers.MarkerData")
local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local BitwiseHelper = RequireScript("LyShineUI._Common.BitwiseHelpers")
local SiegeMarkerData = RequireScript("LyShineUI.Markers.SiegeMarkerData")
function ClaimPointMarker:OnActivate()
  self.dataLayer = dataLayer
  self.registrar = registrar
  self.tweener = tweener
  self.registrar:RegisterEntity(self)
  self.tweener:OnActivate()
end
function ClaimPointMarker:OnDeactivate()
  self.dataLayer:UnregisterObservers(self)
  if self.registrar then
    self.registrar:UnregisterEntity(self)
  end
  self.tweener:OnDeactivate()
  if self.canvasSizeNotificationHandler then
    self.canvasSizeNotificationHandler:Disconnect()
    self.markerNotificationHandler = nil
  end
  if self.tickHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickHandler = nil
  end
end
function ClaimPointMarker:RegisterDatapaths(index)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.id = index
  self.claimMarkerTable = self.registrar:GetEntityTable(self.Properties.ClaimPointStatus)
  self.markerClass = UiMarkerBus.Event.GetMarker(self.entityId)
  self.markerClass:SetMarkerType("SiegeStructure")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootPlayerId)
    if rootPlayerId then
      self.rootPlayerId = rootPlayerId
    end
  end)
  local basePath = "Hud.LocalPlayer.Siege.ClaimPoints." .. tostring(index) .. "."
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "Reset", function(self, reset)
    if reset then
      self.claimMarkerTable:Reset()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "WorldPosition", function(self, worldPosition)
    if not worldPosition then
      return
    end
    self.lastWorldPos = worldPosition
    self:OnCrySystemPostViewSystemUpdate()
    self:UpdateEnabled()
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "State", function(self, state)
    if not state then
      return
    end
    self.claimMarkerTable:SetState(state)
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "Progress", function(self, progress)
    if not progress then
      return
    end
    self.claimMarkerTable:SetProgress(progress)
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "Name", function(self, name)
    if not name then
      return
    end
    self.claimMarkerTable:SetName(name)
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "Icon", function(self, id)
    if not id then
      return
    end
    self.claimMarkerTable:SetIcon(id)
  end)
  self.dataLayer:RegisterDataCallback(self, basePath .. "CustomIcon", function(self, imagePath)
    if not imagePath then
      return
    end
    self.claimMarkerTable:SetCustomIcon(imagePath, true)
  end)
  self.dataLayer:RegisterDataCallback(self, basePath .. "IconColor", function(self, color)
    if not color then
      return
    end
    self.claimMarkerTable:SetIconColor(color)
  end)
  self.dataLayer:RegisterDataCallback(self, basePath .. "IconScale", function(self, scale)
    if not scale then
      return
    end
    self.claimMarkerTable:SetIconScale(scale)
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "Type", function(self, fortSpawnId)
    if not fortSpawnId then
      return
    end
    if fortSpawnId <= eFortSpawnId_CapturePoint_Claim then
      self.claimMarkerTable:SetMeterColor(DynamicBus.WarHUD.Broadcast.GetClaimTargetColor())
      self.claimMarkerTable:SetMeterBGColor(DynamicBus.WarHUD.Broadcast.GetClaimStartingColor())
    else
      self.claimMarkerTable:SetMeterColor(UIStyle.COLOR_BLACK, DynamicBus.WarHUD.Broadcast.GetClaimTargetColor())
      self.claimMarkerTable:SetMeterBGColor(DynamicBus.WarHUD.Broadcast.GetClaimStartingColor())
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "BGColor", function(self, color)
    local isLocalPlayerTeamIdx = DynamicBus.OutpostRush.Broadcast.GetIsLocalPlayerTeamIdx()
    if isLocalPlayerTeamIdx ~= nil then
      self.claimMarkerTable:SetName(self.claimMarkerTable:GetName(), isLocalPlayerTeamIdx)
    end
    if color then
      self.claimMarkerTable:SetMeterBGColor(color)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "Color", function(self, color)
    if color then
      self.claimMarkerTable:SetMeterColor(color)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, basePath .. "ReplicatedId", function(self, id)
    if id then
      self.replicatedId = id
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "VitalsDataPath", function(self, path)
    if path then
      self.dataLayer:RegisterAndExecuteDataObserver(self, path, function(self, value)
        if value then
          local vitalsEntityId = DynamicBus.OutpostRush.Broadcast.GetReplicatedValueAsEntityId(self.replicatedId)
          if vitalsEntityId and self.vitalsEntityId ~= vitalsEntityId then
            self.vitalsEntityId = vitalsEntityId
            if self.vitalsNotificationHandler then
              self.vitalsNotificationHandler:Disconnect()
            end
            self.vitalsNotificationHandler = UiVitalsNotificationsBus.Connect(self, vitalsEntityId)
            local currentHealth = VitalsComponentRequestBus.Event.GetCurrentHealth(vitalsEntityId)
            local maxHealth = VitalsComponentRequestBus.Event.GetHealthMax(vitalsEntityId)
            local pct = 1
            if currentHealth and maxHealth then
              pct = currentHealth / maxHealth
            end
            self.claimMarkerTable:SetProgress(pct)
          end
        end
      end)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, basePath .. "SetMarkerToFade", function(self, shouldFade)
    self.shouldFade = shouldFade
    if shouldFade then
      self.markerClass:SetFadeDistance(70, 90)
    else
      self.markerClass:SetFadeDistance(120, 120)
      self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Position")
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "Enabled", function(self, bitMaskFlag)
    self:SetEnable(true, bitMaskFlag)
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, basePath .. "Disabled", function(self, bitMaskFlag)
    self:SetEnable(false, bitMaskFlag)
  end)
  self.dataLayer:RegisterDataCallback(self, basePath .. ".IsTargetTagged", function(self, isTargetTagged)
    self.claimMarkerTable:SetIsTargetTagged(isTargetTagged)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    if raidId and raidId:IsValid() then
      self.raidId = raidId
      if self.groupsNotificationBusHandler then
        self.groupsNotificationBusHandler:Disconnect()
        self.groupsNotificationBusHandler = nil
      end
      self.groupsNotificationBusHandler = GroupsUINotificationBus.Connect(self)
      local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(self.raidId)
      if warDetails and warDetails:IsValid() then
        local warId = warDetails:GetWarId()
        if warId ~= nil and not warId:IsNull() then
          self:OnSiegeWarfareStarted(warId)
        end
      end
    else
      self.raidId:Reset()
      self:OnSiegeWarfareCompleted()
      if self.groupsNotificationBusHandler then
        self.groupsNotificationBusHandler:Disconnect()
        self.groupsNotificationBusHandler = nil
      end
    end
  end)
end
function ClaimPointMarker:SetEnable(enabled, bitMaskFlag)
  if enabled == nil or bitMaskFlag == nil then
    return
  end
  if enabled then
    self.requestedEnabled = BitwiseHelper:SetFlag(self.requestedEnabled, bitMaskFlag)
  else
    self.requestedEnabled = BitwiseHelper:ClearFlag(self.requestedEnabled, bitMaskFlag)
  end
  local enable = self.requestedEnabled ~= SiegeMarkerData.USAGE_NONE
  self.inOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(self.rootPlayerId, 2444859928)
  if self.inOutpostRush and self.shouldFade and enabled then
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Position", function(self, position)
      if position and self.lastWorldPos then
        self.distance = self.lastWorldPos:GetDistance(position)
      end
    end)
  else
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Position")
  end
  self:UpdateEnabled()
end
function ClaimPointMarker:OnSiegeWarfareStarted(warId)
  if warId == nil then
    return
  end
  self.currentWarPhase = eWarPhase_Conquest
  self:UpdateEnabled()
end
function ClaimPointMarker:OnSiegeWarfareEnded(isWinner, resolutionPhaseEndTimePoint)
  self:OnSiegeWarfareCompleted()
end
function ClaimPointMarker:OnSiegeWarfareCompleted()
  self.requestedEnabled = 0
  self.currentWarPhase = eWarPhase_Resolution
  self:UpdateEnabled()
end
function ClaimPointMarker:UpdateEnabled()
  local isFcpHudVisible = false
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
    isFcpHudVisible = DynamicBus.FactionControlPointHUD.Broadcast.IsVisible()
  end
  self.isMarkerEnabled = (self.currentWarPhase == eWarPhase_Conquest or self.inOutpostRush or isFcpHudVisible) and self.requestedEnabled ~= 0 and self.lastWorldPos ~= nil
  UiElementBus.Event.SetIsEnabled(self.entityId, self.isMarkerEnabled)
  if self.isMarkerEnabled then
    self.tickHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
  elseif self.tickHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickHandler = nil
  end
end
function ClaimPointMarker:OnCrySystemPostViewSystemUpdate()
  if self.lastWorldPos then
    self.markerClass:OnWorldPositionChanged(self.lastWorldPos)
  end
  if self.distance then
    self.markerClass:OnDistanceChanged(self.distance, false)
  end
end
function ClaimPointMarker:OnHealthChangedUi(vitalsStatChanged)
  local newValue = vitalsStatChanged.newVitalsStat.value
  local newMax = vitalsStatChanged.newVitalsStat.maxValue
  self.claimMarkerTable:SetProgress(newValue / newMax)
end
return ClaimPointMarker

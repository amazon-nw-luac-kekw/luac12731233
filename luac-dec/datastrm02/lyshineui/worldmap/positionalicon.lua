local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local PositionalIcon = {
  Properties = {
    BeginPulseRadius = {default = 0},
    EndPulseRadius = {default = 20},
    LabelParent = {
      default = EntityId()
    },
    LabelText = {
      default = EntityId()
    },
    Pulse = {
      default = EntityId()
    },
    Image = {
      default = EntityId()
    },
    ImageContainer = {
      default = EntityId()
    },
    InteractArea = {
      default = EntityId()
    },
    RespawnCooldownContainer = {
      default = EntityId()
    },
    RespawnCooldownFill = {
      default = EntityId()
    },
    HighlightImage = {
      default = EntityId()
    },
    CallOutFrame = {
      default = EntityId()
    },
    CallOutText = {
      default = EntityId()
    },
    TextBackgroundImageWidth = {default = 140},
    TextBackgroundImageDarkAreaWidth = {default = 86}
  },
  DISCOVERED_ICON = "lyshineui/images/map/icon/icon_discovered.dds",
  mapPoiButtonFlyoutContext = "mapPoiButton",
  contractsCount = 0,
  groupDataDynamicBusHandler = nil,
  localPlayerGameModeIndex = -1,
  gameModeIndex = -1,
  respawnDistanceCheckTimer = 0,
  respawnDistanceCheckTimerTick = 1
}
local RESPAWN_PRIVATE_POINT_PNG = "LyShineUI/Images/Map/Icon/respawnPoint.dds"
local RESPAWN_GUILD_POINT_PNG = "LyShineUI/Images/Map/Icon/respawnGuildPoint.dds"
local TWO_PI = 2 * math.pi
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PositionalIcon)
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local EncounterDataHandler = RequireScript("LyShineUI._Common.EncounterDataHandler")
local hoverIntentDetector = RequireScript("LyShineUI._Common.HoverIntentDetector")
local Pulse = {}
function Pulse:Add(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.progress = o.progress or 0
  o.period = o.period or 1
  o.beginColor = o.beginColor or Color(1, 1, 1)
  o.endColor = o.endColor or Color(1, 1, 1)
  o.endRadius = o.endRadius or WorldMap.Properties.EndPulseRadius
  o.beginRadius = o.beginRadius or WorldMap.Properties.BeginPulseRadius
  o.timesToPlay = o.timesToPlay or 0
  o.timesPlayed = 0
  return o
end
function Pulse:SetOptions(o)
  self.beginColor = o.beginColor or self.beginColor
  self.endColor = o.endColor or self.endColor
  self.endRadius = o.endRadius or self.endRadius
  self.timesToPlay = o.timesToPlay or self.timesToPlay
end
function Pulse:Update(deltaTime)
  self.progress = self.progress + deltaTime
  if self.progress > self.period then
    self.progress = self.progress - self.period
    self.timesPlayed = self.timesPlayed + 1
    if self.timesToPlay ~= 0 and self.timesPlayed >= self.timesToPlay then
      return true
    end
  end
  local percent = self.progress / self.period
  local color = Color(1, 1, 1)
  local channels = {
    "r",
    "g",
    "b",
    "a"
  }
  for _, channel in ipairs(channels) do
    color[channel] = self.beginColor[channel] + (self.endColor[channel] - self.beginColor[channel]) * percent
  end
  local radius = self.beginRadius + (self.endRadius - self.beginRadius) * percent
  local offsets = UiOffsets(-radius, -radius, radius, radius)
  if self.entity then
    UiTransform2dBus.Event.SetOffsets(self.entity, offsets)
    UiImageBus.Event.SetColor(self.entity, color)
  end
  return false
end
function PositionalIcon:OnInit()
  BaseElement.OnInit(self)
  self.iconTypes = mapTypes.iconTypes
  self.sourceTypes = mapTypes.sourceTypes
  self.panelTypes = mapTypes.panelTypes
  self.iconData = {}
  self.isDataInitialized = false
  self.currentScale = 1
  self.isVisible = true
  self.isFilterEnabled = true
  UiImageBus.Event.SetFillClockwise(self.Properties.RespawnCooldownFill, false)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.externalVisibility = true
  self.cachedTextBackgroundDarknessRatio = self.Properties.TextBackgroundImageWidth / self.Properties.TextBackgroundImageDarkAreaWidth
  self.defaultLabelYPos = UiTransformBus.Event.GetLocalPositionY(self.Properties.LabelParent)
  UiInteractableBus.Event.SetHoverEnterEventHandlingScale(self.Properties.InteractArea, Vector2(0.8, 0.8))
end
function PositionalIcon:OnShutdown()
  self:BusDisconnect(self.tickBusHandler)
  self.tickBusHandler = nil
  self.dataLayer:UnregisterObservers(self)
  if self.groupDataDynamicBusHandler then
    DynamicBus.GroupDataNotification.Disconnect(self.entityId, self)
    self.groupDataDynamicBusHandler = nil
  end
end
function PositionalIcon:OnTick(deltaTime, timePoint)
  if self.pulser and self.pulser:Update(deltaTime) then
    self:ClearPulse()
  end
  if self.iconData.iconType == self.iconTypes.Respawn then
    if self.respawnRemaining and self.respawnRemaining > 0 then
      self.respawnRemaining = self.respawnRemaining - deltaTime
      self:UpdateRespawnFill()
    end
    if self.maxRespawnDistanceSq then
      self.respawnDistanceCheckTimer = self.respawnDistanceCheckTimer - deltaTime
      if 0 >= self.respawnDistanceCheckTimer then
        self.respawnDistanceCheckTimer = self.respawnDistanceCheckTimer + self.respawnDistanceCheckTimerTick
        self:CheckRespawnDistance()
      end
    end
  elseif self.iconData.iconType == self.iconTypes.AttackNotification and self.timeRemaining and 0 < self.timeRemaining then
    self.timeRemaining = self.timeRemaining - deltaTime
    if 0 > self.timeRemaining then
      self:SetVisible(false)
    end
  end
  if not UiCanvasBus.Event.GetEnabled(self.canvasId) and self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function PositionalIcon:OnIsShowingChanged(isShowing)
  if self.pulser or self.iconData.iconType == self.iconTypes.Respawn or self.iconData.iconType == self.iconTypes.AttackNotification then
    if not isShowing then
      if self.tickBusHandler then
        self:BusDisconnect(self.tickBusHandler)
        self.tickBusHandler = nil
      end
    elseif not self.tickBusHandler then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  end
  if self.iconData.iconType == self.iconTypes.RaidGroupLeader then
    if isShowing then
      if self.groupId and self.groupId:IsValid() and not self.groupDataHandler then
        self.groupDataHandler = self:BusConnect(GroupDataNotificationBus, self.groupId)
        self:OnPositionChanged(GroupDataRequestBus.Event.GetGroupLeaderPosition(groupId))
      end
    else
      self:BusDisconnect(self.groupDataHandler)
      self.groupDataHandler = nil
    end
  end
end
function PositionalIcon:ResetData()
  self.dataLayer:UnregisterObservers(self)
  self.localPlayerGameModeIndex = -1
  self.gameModeIndex = -1
  self.isDataInitialized = false
  self.displayDistance = false
  self:SetImageScale(1, true)
  self:SetVisible(false)
end
function PositionalIcon:UpdateData(iconData)
  self:ResetData()
  self:SetData(iconData)
end
function PositionalIcon:SetData(iconData)
  self.__index = self
  if not iconData then
    Log("Error: iconData is nil in PositionalIcon:SetData")
    return
  end
  if not self.isDataInitialized then
    self.isDataInitialized = true
    self.dataManager = self.registrar:GetEntityTable(iconData.dataManagerId)
    local isCompassIcon = iconData.sourceType == self.sourceTypes.Compass
    local labelParentYOffset = 0
    local hasPulse = false
    local pulseRadiusOverride
    local hasInteract = true
    local isHiddenAtStart = isCompassIcon
    iconData.scale = iconData.scale or 1
    if iconData.iconType == self.iconTypes.LocalPlayer then
      iconData.imageFGPath = "LyShineUI/Images/Map/Icon/player.dds"
      iconData.imageFGColor = self.UIStyle.COLOR_GROUP_MEMBERS[1]
      hasPulse = true
      hasInteract = false
    elseif iconData.iconType == self.iconTypes.Respawn then
      self.displayDistance = true
      self.respawnDistanceCheckTimer = 0
      self.respawnImageFGPath = isCompassIcon and "LyShineUI/Images/Map/Icon/respawnPoint.dds" or "LyShineUI/Images/Map/Icon/respawnPointCentered.dds"
      self.respawnImageDisabledFGPath = isCompassIcon and "LyShineUI/Images/Map/Icon/respawnPointDeactivated.dds" or "LyShineUI/Images/Map/Icon/respawnPointCenteredDeactivated.dds"
      iconData.imageFGPath = self.respawnImageFGPath
      iconData.imageFGColor = Color(1, 1, 1)
      iconData.tooltipHeader = "@camp"
      iconData.tooltipSubtext = "-"
      iconData.scalesWithZoom = true
      iconData.minScale = isCompassIcon and 0.75 or 1
      iconData.maxScale = isCompassIcon and 1 or 1.5
      iconData.scale = 1.5
    elseif iconData.iconType == self.iconTypes.GroupMember then
      iconData.imageFGPath = self.UIStyle.ICONS_GROUP_MEMBERS[iconData.index]
      iconData.imageFGColor = self.UIStyle.COLOR_GROUP_MEMBERS[iconData.index]
      iconData.scale = 0.9
      isHiddenAtStart = true
      hasPulse = true
      pulseRadiusOverride = self.Properties.EndPulseRadius * 0.75
    elseif iconData.iconType == self.iconTypes.RaidGroupLeader then
      iconData.imageFGPath = self.UIStyle.ICONS_GROUP_MEMBERS[1]
      iconData.imageFGColor = self.UIStyle.COLOR_WHITE
      iconData.scale = 0.9
      isHiddenAtStart = true
    elseif iconData.iconType == self.iconTypes.GroupWaypoint then
      self.displayDistance = true
      iconData.imageFGPath = "LyShineUI/Images/Map/Icon/waypoint_Compass.dds"
      iconData.imageFGColor = self.UIStyle.COLOR_GROUP_MEMBERS[iconData.index]
      if iconData.sourceType ~= self.sourceTypes.Compass then
        iconData.imageAnchors = UiAnchors(0.5, 0, 0.5, 0)
        iconData.imageFGPath = "LyShineUI/Images/Map/Icon/waypoint.dds"
      end
      isHiddenAtStart = true
    elseif iconData.iconType == self.iconTypes.Waypoint then
      self.displayDistance = true
      iconData.imageFGPath = "LyShineUI/Images/Map/Icon/waypoint_Compass.dds"
      iconData.imageFGColor = self.UIStyle.COLOR_GROUP_MEMBERS[1]
      if iconData.sourceType ~= self.sourceTypes.Compass then
        iconData.imageAnchors = UiAnchors(0.5, 0, 0.5, 0)
        iconData.imageFGPath = "LyShineUI/Images/Map/Icon/waypoint.dds"
      end
      isHiddenAtStart = true
      hasInteract = false
      if iconData.sourceType == self.sourceTypes.Map then
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.WayPointEntityId", self.entityId)
      end
    elseif iconData.iconType == self.iconTypes.Death then
      iconData.imageFGPath = "LyShineUI/Images/Map/Icon/lastDeathPosition.dds"
      iconData.tooltipHeader = "@ui_map_death"
      iconData.tooltipSubtext = "@ui_map_death_description"
      isHiddenAtStart = true
    elseif iconData.iconType == self.iconTypes.AttackNotification then
      iconData.imageFGPath = "LyShineUI/Images/Map/Icon/lastDeathPosition.dds"
      isHiddenAtStart = true
      iconData.imageFGColor = self.UIStyle.COLOR_RED
    elseif iconData.iconType == self.iconTypes.OWGMissionTurnIn then
      iconData.imageFGPath = "LyShineUI/Images/OldWorldGuilds/MissionIcon.dds"
      iconData.imageAnchors = UiAnchors(0.5, 0.5, 0.5, 0.5)
      isHiddenAtStart = true
      iconData.imageFGColor = self.UIStyle.COLOR_WHITE
      iconData.scale = 0.5
      self.displayDistance = true
    elseif isCompassIcon then
      self:SetVisible(true)
      self.isEncounter = iconData.isEncounter
    end
    if iconData.renderPriority ~= nil then
      UiElementBus.Event.SetRenderPriority(self.entityId, iconData.renderPriority)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.RespawnCooldownContainer, false)
    self.iconData = iconData
    self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enablePOIDiscovery", function(self, isPOIDiscoveryEnabled)
      self.isPOIDiscoveryEnabled = isPOIDiscoveryEnabled
    end)
    if not isCompassIcon then
      local filterType = iconData.zoomFilterType or iconData.iconType
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.Filter." .. iconData.sourceType .. "." .. tostring(filterType), self.OnMapFilterChanged)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.InteractArea, hasInteract)
    if iconData.imageFGPath then
      UiImageBus.Event.SetSpritePathname(self.Properties.Image, iconData.imageFGPath)
      if iconData.imageFGColor then
        self:SetImageColor(iconData.imageFGColor)
      end
    end
    if iconData.imageAnchors then
      if self.Properties.ImageContainer:IsValid() then
        UiTransform2dBus.Event.SetAnchorsScript(self.Properties.ImageContainer, iconData.imageAnchors)
      end
      if self.Properties.InteractArea:IsValid() then
        UiTransform2dBus.Event.SetAnchorsScript(self.Properties.InteractArea, iconData.imageAnchors)
      end
    end
    self.isLabelValid = not isCompassIcon and (self.displayDistance or iconData.label and iconData.label ~= "")
    UiElementBus.Event.SetIsEnabled(self.Properties.LabelParent, self.isLabelValid)
    if self.isLabelValid then
      UiTransformBus.Event.SetLocalPositionY(self.Properties.LabelParent, self.defaultLabelYPos + labelParentYOffset)
      if not iconData.label then
        iconData.label = ""
      end
      self:SetLabelText(iconData.label)
    end
    if iconData.scale ~= 1 then
      self:SetImageScale(iconData.scale)
    end
    if iconData.iconType == self.iconTypes.PointOfInterest then
      self:UpdateCurrentState(iconData.isDiscovered, iconData.isCharted)
    end
    if hasPulse then
      self:CreatePulse(nil, nil, pulseRadiusOverride)
    end
    if isHiddenAtStart then
      if isCompassIcon then
        self:SetExternalVisibility(false)
      else
        self:SetVisible(false)
      end
    end
    if iconData.scalesWithZoom then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.ZoomLevelMPP." .. iconData.sourceType, self.OnZoomLevelChanged)
    end
    if iconData.rotationZ then
      self:SetRotationZ(iconData.rotationZ)
    end
    if iconData.anchors and iconData.sourceType ~= self.sourceTypes.Compass then
      self:SetAnchorsPosition(iconData.anchors)
    end
    if self.groupDataDynamicBusHandler then
      DynamicBus.GroupDataNotification.Disconnect(self.entity, self)
      self.groupDataDynamicBusHandler = nil
    end
    if self.participantBusHandler then
      self:BusDisconnect(self.participantBusHandler)
      self.participantBusHandler = nil
    end
    if iconData.iconType == self.iconTypes.Respawn then
      local homePointIndex = iconData.index
      if iconData.customData then
        homePointIndex = iconData.customData[iconData.index]
      end
      self.dataNodePrefix = "Hud.LocalPlayer.HomePoints." .. homePointIndex .. "."
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "Position", self.OnPositionChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "Cooldown", self.OnRespawnCooldownChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "CooldownDuration", self.OnRespawnCooldownDurationChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "Type", self.OnRespawnTypeChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "CooldownEnd", self.OnRespawnCooldownRemainingChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "MaxRespawnDistance", self.OnMaxRespawnDistanceChanged)
    elseif iconData.iconType == self.iconTypes.GroupMember then
      self.groupDataDynamicBusHandler = DynamicBus.GroupDataNotification.Connect(self.entityId, self)
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, rootPlayerId)
        if not rootPlayerId then
          return
        end
        self.participantBusHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, rootPlayerId)
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.GameModeParticipantBus.IsReady", function(self, isReady)
        self.gameModeParticipantBusReady = isReady
        self:CheckGameMode()
      end)
      self.dataNodePrefix = "Hud.LocalPlayer.Group.Members." .. iconData.index .. "."
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerName", self.OnPlayerNameChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "CharacterName", self.OnGroupMemberIdChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "WorldRotation", self.OnWorldRotationChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "WorldPosition", self.OnPositionChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "GameModeIndex", self.OnGameModeIndexChanged)
    elseif iconData.iconType == self.iconTypes.GroupWaypoint then
      self.groupDataDynamicBusHandler = DynamicBus.GroupDataNotification.Connect(self.entityId, self)
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, rootPlayerId)
        if not rootPlayerId then
          return
        end
        self.participantBusHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, rootPlayerId)
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.GameModeParticipantBus.IsReady", function(self, isReady)
        self.gameModeParticipantBusReady = isReady
        self:CheckGameMode()
      end)
      self.dataNodePrefix = "Hud.LocalPlayer.Group.Members." .. iconData.index .. "."
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerName", self.OnPlayerNameChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "Waypoint", self.OnPositionChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "CharacterName", self.OnGroupMemberIdChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataNodePrefix .. "GameModeIndex", self.OnGameModeIndexChanged)
    elseif iconData.iconType == self.iconTypes.Waypoint then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.WaypointPosition", self.OnPositionChanged)
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerName", self.OnPlayerNameChanged)
    elseif iconData.iconType == self.iconTypes.Death then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.DeathPosition", self.OnPositionChanged)
    end
    if self.isEncounter then
      self.encounterEntityId = iconData.entityId
      self:UpdateEncounterIcon()
      self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Progression.Level", self.UpdateEncounterIcon)
      self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Group.MemberCount", self.UpdateEncounterIcon)
    end
    if iconData.debugText then
      UiElementBus.Event.SetIsEnabled(self.Properties.LabelParent, true)
      self:SetLabelText(iconData.debugText)
      self.isLabelValid = true
    end
  end
end
function PositionalIcon:OnMemberAdded(addedIndex)
  if self.iconData.index == addedIndex then
    self:SetVisible(true)
  end
end
function PositionalIcon:OnMemberRemoved(removedIndex)
  if self.iconData.index == removedIndex then
    self:SetVisible(false)
  end
end
function PositionalIcon:UpdateAttackNotification(attackingGuildName)
  local position = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastBuildableAttacked.Position")
  self:OnPositionChanged(position)
  self:CreatePulse()
  self:SetVisible(true)
  self.timeRemaining = 10
end
function PositionalIcon:UpdateOWGMissionTurnIn(guildCrc)
  local position = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OWGMissionTurnIn.Position")
  local isVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OWGMissionTurnIn.Visible")
  self:OnPositionChanged(position)
  self:SetVisible(isVisible)
end
function PositionalIcon:SetColorOverride(color)
  self.colorOverride = color
  self:SetImageColor(self.colorOverride)
  if self.pulser then
    beginColor = Color.Clone(self.colorOverride)
    beginColor.a = 0.7
    endColor = Color.Clone(self.colorOverride)
    endColor.a = 0
    self.pulser:SetOptions({endColor = endColor, beginColor = beginColor})
  end
end
function PositionalIcon:SetImageColor(color)
  UiImageBus.Event.SetColor(self.Properties.Image, self.colorOverride or color)
end
function PositionalIcon:SetImageScale(scale, force)
  if scale ~= self.currentScale or force then
    if not force then
      if self.iconData.minScale and scale < self.iconData.minScale then
        scale = self.iconData.minScale
      elseif self.iconData.maxScale and scale > self.iconData.maxScale then
        scale = self.iconData.maxScale
      end
      if self.iconData.hideLabelsBelowScale and scale < self.iconData.hideLabelsBelowScale then
        UiElementBus.Event.SetIsEnabled(self.Properties.LabelParent, false)
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.LabelParent, self.isLabelValid)
      end
    end
    self.currentScale = scale
    UiTransformBus.Event.SetScale(self.Properties.Image, Vector2(scale, scale))
    UiTransformBus.Event.SetScale(self.Properties.HighlightImage, Vector2(scale, scale))
  end
end
function PositionalIcon:SetContractCounts(contractsCount)
  self.contractsCount = contractsCount
end
function PositionalIcon:OnPlayerNameChanged(data)
  self.localPlayerName = data or ""
  if self.iconData.iconType == self.iconTypes.Waypoint then
    self.iconData.tooltipHeader = self.localPlayerName
    self.iconData.tooltipSubtext = "@ui_map_waypoint"
  end
end
function PositionalIcon:ShouldBeForceHidden()
  local isWaypoint = self.iconData.iconType == self.iconTypes.GroupWaypoint or self.iconData.iconType == self.iconTypes.Waypoint
  if isWaypoint and (not self.iconData.position or math.abs(self.iconData.position.x + self.iconData.position.y) < 5 or not self.iconData.position:IsFinite()) then
    return true
  end
  return false
end
function PositionalIcon:OnPositionChanged(newPosition)
  if not newPosition or not newPosition:IsFinite() then
    self:SetVisible(false)
    return
  end
  self.iconData.position = newPosition
  self:SetVisible(newPosition.x > 0 and 0 < newPosition.y)
  if self.iconData.sourceType == self.sourceTypes.Compass then
    if not self.groupPlayerName or self.groupPlayerName ~= self.localPlayerName then
      DynamicBus.Compass.Broadcast.UpdateCompassIconPosition(self)
    end
  else
    local anchors = self.dataManager:WorldPositionToAnchors(self.iconData.position)
    self:SetAnchorsPosition(anchors)
  end
end
function PositionalIcon:OnGameModeIndexChanged(newGameModeIndex)
  self.gameModeIndex = newGameModeIndex
  self:CheckGameMode()
end
function PositionalIcon:OnEnteredGameMode(gameModeEntityId, gameModeId)
  self:CheckGameMode()
end
function PositionalIcon:OnExitedGameMode(gameModeEntityId)
  self:CheckGameMode()
end
function PositionalIcon:CheckGameMode()
  local groupId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
  if self.groupPlayerName and groupId and groupId:IsValid() and self.gameModeParticipantBusReady then
    local localPlayerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    self.localPlayerGameModeIndex = GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeIndex(localPlayerRootEntityId)
    self:SetVisible(self.localPlayerGameModeIndex == self.gameModeIndex)
  end
end
function PositionalIcon:SetAnchorsPosition(anchors)
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, anchors)
end
function PositionalIcon:OnWorldRotationChanged(rotation)
  local rotation = rotation or Vector3(0, 0, 0)
  self:SetRotationZ(rotation.z)
end
function PositionalIcon:OnRotationZChanged(data)
  self:SetRotationZ(data or 0)
end
function PositionalIcon:SetRotationZ(rotation)
  local direction = self:GetDirectionFromRotation(rotation)
  UiTransformBus.Event.SetZRotation(self.Properties.Image, direction)
end
function PositionalIcon:GetDirectionFromRotation(rotation)
  return 360 - rotation * 360 / TWO_PI
end
function PositionalIcon:OnNameChanged(data)
  if self.iconData.iconType == self.iconTypes.Respawn then
    self.iconData.tooltipHeader = data
  end
end
function PositionalIcon:OnHoverStart()
  if self.iconData.tooltipHeader and self.iconData.tooltipHeader ~= "" and self.iconData.tooltipSubtext and self.iconData.tooltipSubtext ~= "" then
    hoverIntentDetector:OnHoverDetected(self, self.ShowFlyoutMenu)
    self.audioHelper:PlaySound(self.audioHelper.MapIconOnHover)
  end
  if self.iconData.outpostId then
    self.ScriptedEntityTweener:Play(self.Properties.Image, 0.05, {
      scaleX = self.currentScale * 1.17,
      scaleY = self.currentScale * 1.17,
      ease = "QuadOut"
    })
  end
end
function PositionalIcon:OnHoverEnd()
  if self.iconData.outpostId then
    self.ScriptedEntityTweener:Play(self.Properties.Image, 0.05, {
      scaleX = self.currentScale,
      scaleY = self.currentScale
    })
  end
  hoverIntentDetector:StopHoverDetected(self)
end
function PositionalIcon:OnMapFilterChanged(isFilterEnabled)
  if isFilterEnabled ~= nil then
    self:UpdateEnabled(self.isVisible, isFilterEnabled)
  end
end
function PositionalIcon:ShowFlyoutMenu()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu.openingContext == self.mapPoiButtonFlyoutContext and flyoutMenu:ExitHover() then
    return
  end
  local rows = {}
  local headerText = self.iconData.tooltipHeader
  local subtextText = self.iconData.tooltipSubtext
  if self.iconData.iconType == self.iconTypes.PointOfInterest and self.iconData.isDiscovered and not self.iconData.isCharted then
    headerText = "@ui_uncharted_landmark"
    subtextText = "@ui_uncharted_landmark_subtext"
  end
  if self.iconData.iconType == self.iconTypes.Respawn then
    local playerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
    playerPosition.z = 0
    local distance = playerPosition:GetDistance(Vector3(self.iconData.position.x, self.iconData.position.y, 0))
    if 0 < self.maxRespawnDistance then
      local isOutOfRange = distance > self.maxRespawnDistance
      local locTag = isOutOfRange and "@ui_map_respawn_out_of_range" or "@ui_map_respawn"
      local decimal = isOutOfRange and 2 or 0
      subtextText = GetLocalizedReplacementText(locTag, {
        distance = DistanceToText(distance, decimal),
        maxDistance = DistanceToText(self.maxRespawnDistance)
      })
    else
      subtextText = GetLocalizedReplacementText("@ui_map_respawn_no_range", {
        distance = DistanceToText(distance)
      })
    end
  end
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_PointOfInterest,
    header = headerText,
    subtext = subtextText,
    outpostId = self.iconData.outpostId,
    contractsCount = self.contractsCount
  })
  local sourceHoverOnly = not self.iconData.outpostId
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
  flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
  flyoutMenu:SetOpenLocation(self.InteractArea)
  flyoutMenu:EnableFlyoutDelay(false)
  flyoutMenu:SetFadeInTime(0.05)
  flyoutMenu:SetFadeOutTime(0.05)
  flyoutMenu:SetRowData(rows)
  flyoutMenu:SourceHoverOnly(sourceHoverOnly)
  if not sourceHoverOnly then
    flyoutMenu.openingContext = self.mapPoiButtonFlyoutContext
  end
end
function PositionalIcon:OnGroupMemberIdChanged(data)
  if data then
    self.groupPlayerName = data
  end
  if self.iconData.iconType == self.iconTypes.GroupMember then
    self.iconData.tooltipHeader = self.groupPlayerName
    self.iconData.tooltipSubtext = "@ui_map_groupmember"
    if self.groupPlayerName == self.localPlayerName then
      self:SetVisible(false)
      self.dataManager:UpdateLocalPlayerColor(self.iconData.index)
    end
  elseif self.iconData.iconType == self.iconTypes.GroupWaypoint then
    self.iconData.tooltipHeader = self.groupPlayerName
    self.iconData.tooltipSubtext = "@ui_map_waypoint"
    if self.groupPlayerName == self.localPlayerName then
      self:SetVisible(false)
    end
  end
end
function PositionalIcon:OnZoomLevelChanged(zoom)
  local newLevelMPP = zoom
  if newLevelMPP == nil or newLevelMPP == 0 or not self:GetIsEnabled() then
    return
  end
  local newScale = self.iconData.scale / newLevelMPP
  self:SetImageScale(newScale)
end
function PositionalIcon:CreatePulse(beginColor, endColor, endRadius, timesToPlay)
  if not self.pulser then
    beginColor = beginColor and Color.Clone(beginColor) or Color.Clone(self.iconData.imageFGColor)
    beginColor.a = 0.7
    endColor = endColor and Color.Clone(endColor) or Color.Clone(self.iconData.imageFGColor)
    endColor.a = 0
    endRadius = endRadius or self.Properties.EndPulseRadius
    self.pulser = Pulse:Add({
      entity = self.Pulse,
      beginRadius = self.Properties.BeginPulseRadius,
      endRadius = endRadius,
      beginColor = beginColor,
      endColor = endColor,
      timesToPlay = timesToPlay
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.Pulse, true)
    if not self.tickBusHandler then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  end
end
function PositionalIcon:ClearPulse()
  if self.pulser then
    UiElementBus.Event.SetIsEnabled(self.Properties.Pulse, false)
    self.pulser = nil
  end
end
function PositionalIcon:ShowHighlight(showDistance, color)
  UiElementBus.Event.SetIsEnabled(self.Properties.CallOutFrame, showDistance)
  if showDistance then
    local startPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
    local distanceText = GetLocalizedDistance(startPosition, self.iconData.position)
    distanceText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@objective_destination_distance", distanceText)
    UiTextBus.Event.SetTextWithFlags(self.Properties.CallOutText, distanceText, eUiTextSet_SetLocalized)
    UiImageBus.Event.SetColor(self.Properties.CallOutFrame, color)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.HighlightImage, true)
  UiImageBus.Event.SetColor(self.Properties.HighlightImage, color)
end
function PositionalIcon:ClearHighlight()
  UiElementBus.Event.SetIsEnabled(self.Properties.CallOutFrame, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.HighlightImage, false)
end
function PositionalIcon:SetExternalVisibility(isVisible)
  self.externalVisibility = isVisible
  self:SetVisible(self.isVisible and self.externalVisibility, self.isFilterEnabled, true)
end
function PositionalIcon:SetVisible(isVisible, isExternalChange)
  if self.iconData.iconType == self.iconTypes.GroupMember or self.iconData.iconType == self.iconTypes.GroupWaypoint then
    if self.localPlayerName == self.groupPlayerName then
      isVisible = false
    end
    if self.localPlayerGameModeIndex ~= self.gameModeIndex then
      isVisible = false
    end
  end
  if isVisible and self:ShouldBeForceHidden() then
    isVisible = false
  end
  self:UpdateEnabled(isVisible, self.isFilterEnabled, isExternalChange)
end
function PositionalIcon:UpdateEnabled(isVisible, isFilterEnabled, isExternalChange)
  local wasEnabled = self:GetIsEnabled()
  local shouldBeEnabled = isVisible and isFilterEnabled and self.externalVisibility
  UiElementBus.Event.SetIsEnabled(self.entityId, shouldBeEnabled)
  if not isExternalChange then
    self.isVisible = isVisible
    self.isFilterEnabled = isFilterEnabled
  end
end
function PositionalIcon:UpdateEncounterIcon()
  if self.isEncounter then
    local spawnerTag = SpawnerRequestBus.Event.GetSpawnerTag(self.encounterEntityId)
    local definitionId = TerritoryDataProviderRequestBus.Event.GetTerritoryId(self.encounterEntityId)
    if definitionId then
      local definition = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(definitionId)
      local _, encounterIcon = EncounterDataHandler:GetRecommendedIcons(spawnerTag, definition)
      if encounterIcon and encounterIcon ~= self.iconData.imageFGPath then
        self.iconData.imageFGPath = encounterIcon
        UiImageBus.Event.SetSpritePathname(self.Properties.Image, encounterIcon)
      end
    end
  end
end
function PositionalIcon:GetIsEnabled()
  return UiElementBus.Event.IsEnabled(self.entityId)
end
function PositionalIcon:OnLeftClick()
  if self.iconData.outpostId then
    DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.Storage, self.iconData.outpostId, self.iconData.tooltipHeader)
  end
  DynamicBus.Map.Broadcast.OnMapLeftClick()
end
function PositionalIcon:OnRightClick()
  local isInSpectatorMode = SpectatorUIRequestBus.Broadcast.IsInSpectatorMode()
  if isInSpectatorMode then
    local magicMap = self.dataManager.MagicMap
    if magicMap then
      local worldPosition = magicMap:GetCursorWorldPosition()
      SpectatorUIRequestBus.Broadcast.RequestTeleport(worldPosition.x, worldPosition.y)
    end
    return
  end
  if self.iconData.iconType == self.iconTypes.Waypoint then
    WaypointsRequestBus.Broadcast.RequestSetWaypoint(Vector3(0, 0, 0))
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  else
    local magicMap = self.dataManager.MagicMap
    if magicMap then
      local worldPosition = magicMap:GetCursorWorldPosition()
      if worldPosition then
        WaypointsRequestBus.Broadcast.RequestSetWaypoint(worldPosition)
      end
    end
  end
end
function PositionalIcon:OnRespawnCooldownChanged(isOnCooldown)
  if self.iconData.sourceType ~= self.sourceTypes.RespawnMap and self.iconData.sourceType ~= self.sourceTypes.Map then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.RespawnCooldownContainer, isOnCooldown or false)
  if isOnCooldown and not self.tickBusHandler then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function PositionalIcon:OnRespawnTypeChanged(type)
  if type == "Camp" then
    self.iconData.imageFGPath = RESPAWN_PRIVATE_POINT_PNG
  elseif type == "Private" then
    self.iconData.imageFGPath = RESPAWN_PRIVATE_POINT_PNG
  elseif type == "Guild" then
    self.iconData.imageFGPath = RESPAWN_GUILD_POINT_PNG
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Image, self.iconData.imageFGPath)
end
function PositionalIcon:OnRespawnCooldownDurationChanged(duration)
  if self.iconData.sourceType ~= self.sourceTypes.RespawnMap and self.iconData.sourceType ~= self.sourceTypes.Map then
    return
  end
  self.respawnDuration = duration or 0
  self:UpdateRespawnFill()
end
function PositionalIcon:OnRespawnCooldownRemainingChanged(remaining)
  if self.iconData.sourceType ~= self.sourceTypes.RespawnMap and self.iconData.sourceType ~= self.sourceTypes.Map then
    return
  end
  self.respawnRemaining = remaining or 0
  self:UpdateRespawnFill()
end
function PositionalIcon:OnMaxRespawnDistanceChanged(distance)
  if not distance then
    return
  end
  self.maxRespawnDistance = distance
  self.maxRespawnDistanceSq = distance * distance
end
function PositionalIcon:UpdateRespawnFill()
  if self.iconData.sourceType ~= self.sourceTypes.RespawnMap and self.iconData.sourceType ~= self.sourceTypes.Map then
    return
  end
  if self.respawnDuration and self.respawnDuration > 0 and self.respawnRemaining then
    local oldFillAmount = UiImageBus.Event.GetFillAmount(self.Properties.RespawnCooldownFill)
    local newFillAmount = (self.respawnDuration - (self.respawnDuration - math.max(0, self.respawnRemaining))) / self.respawnDuration
    if oldFillAmount ~= newFillAmount then
      UiImageBus.Event.SetFillAmount(self.Properties.RespawnCooldownFill, newFillAmount)
    end
  end
  if self.respawnRemaining and 0 >= self.respawnRemaining then
    UiElementBus.Event.SetIsEnabled(self.Properties.RespawnCooldownContainer, false)
  end
end
function PositionalIcon:CheckRespawnDistance()
  local playerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
  playerPosition.z = 0
  local distanceSq = playerPosition:GetDistanceSq(Vector3(self.iconData.position.x, self.iconData.position.y, 0))
  local isOutOfRange = 0 < self.maxRespawnDistanceSq and distanceSq > self.maxRespawnDistanceSq
  self:SetRespawnIsOutOfRange(isOutOfRange)
end
function PositionalIcon:SetRespawnIsOutOfRange(isOutOfRange)
  if self.isOutOfRange == isOutOfRange then
    return
  end
  self.isOutOfRange = isOutOfRange
  local iconPath = isOutOfRange and self.respawnImageDisabledFGPath or self.respawnImageFGPath
  self.iconData.imageFGPath = iconPath
  UiImageBus.Event.SetSpritePathname(self.Properties.Image, iconPath)
end
function PositionalIcon:UpdateCurrentState(isDiscovered, isCharted)
  self.iconData.isDiscovered = isDiscovered
  self.iconData.isCharted = isCharted
  if isCharted or not self.isPOIDiscoveryEnabled then
    self:SetVisible(true)
    UiImageBus.Event.SetSpritePathname(self.Properties.Image, self.iconData.imageFGPath)
  elseif isDiscovered then
    self:SetVisible(true)
    UiImageBus.Event.SetSpritePathname(self.Properties.Image, self.DISCOVERED_ICON)
  else
    self:SetVisible(false)
  end
end
function PositionalIcon:SetRaidGroupData(groupId)
  if self.groupDataHandler then
    self:BusDisconnect(self.groupDataHandler)
  end
  self.groupId = groupId
  if groupId:IsValid() then
    self.groupDataHandler = self:BusConnect(GroupDataNotificationBus, groupId)
    self:OnPositionChanged(GroupDataRequestBus.Event.GetGroupLeaderPosition(groupId))
  else
    self:SetVisible(false)
  end
end
function PositionalIcon:OnMemberLeaderStatusChanged(index, isLeader)
  if self.GroupLeaderIndex == index and not isLeader then
    self:SetVisible(false)
    self.GroupLeaderIndex = nil
  end
  if isLeader then
    self.GroupLeaderIndex = index
    self:SetVisible(true)
  end
end
function PositionalIcon:OnLeaderPositionChanged(pos)
  self:OnPositionChanged(pos)
end
function PositionalIcon:SetLabelText(text)
  UiTextBus.Event.SetText(self.Properties.LabelText, text)
  local width = UiTransform2dBus.Event.GetLocalWidth(self.Properties.LabelText)
  width = width * self.cachedTextBackgroundDarknessRatio
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.LabelParent, width)
end
function PositionalIcon:SetHeading(value)
  self.heading = value
end
function PositionalIcon:GetHeading()
  return self.heading
end
return PositionalIcon

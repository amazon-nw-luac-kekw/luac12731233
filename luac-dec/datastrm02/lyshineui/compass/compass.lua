local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local ObjectiveTypeData = RequireScript("LyShineUI.Objectives.ObjectiveTypeData")
local EncounterDataHandler = RequireScript("LyShineUI._Common.EncounterDataHandler")
local profiler = RequireScript("LyShineUI._Common.Profiler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local CompassScreen = {
  Properties = {
    DirectionsElement = {
      default = EntityId()
    },
    CompassPointSpawner = {
      default = EntityId()
    },
    CompassLines = {
      default = EntityId()
    },
    PoiName = {
      default = EntityId()
    },
    PoiBg = {
      default = EntityId()
    },
    RevealFlash = {
      default = EntityId()
    },
    DistanceContainer = {
      default = EntityId()
    },
    DistanceText = {
      default = EntityId()
    },
    EastToSouth = {
      default = EntityId()
    },
    SouthToSouth = {
      default = EntityId()
    },
    SouthToWest = {
      default = EntityId()
    },
    PropertiesPerIconType = {
      Respawn = {
        RenderOnCompass = {default = true},
        ClampToEdge = {default = false},
        MaxRange = {default = 0},
        YOffset = {default = -16},
        Scale = {default = 1},
        RenderPriority = {default = 90},
        ShowDistance = {default = true}
      },
      EntityTrackingIcon = {
        RenderOnCompass = {default = true},
        ClampToEdge = {default = false},
        MaxRange = {default = 50},
        YOffset = {default = -16},
        Scale = {default = 1},
        RenderPriority = {default = 70},
        ShowDistance = {default = false}
      },
      PointOfInterest = {
        RenderOnCompass = {default = true},
        ClampToEdge = {default = false},
        MaxRange = {default = 100},
        YOffset = {default = -16},
        Scale = {default = 1.1},
        RenderPriority = {default = 80},
        ShowDistance = {default = true}
      },
      Waypoint = {
        RenderOnCompass = {default = true},
        ClampToEdge = {default = true},
        MaxRange = {default = 0},
        YOffset = {default = -14},
        Scale = {default = 1.1},
        RenderPriority = {default = 10},
        ShowDistance = {default = true}
      },
      Death = {
        RenderOnCompass = {default = false},
        ClampToEdge = {default = false},
        MaxRange = {default = 0},
        YOffset = {default = -14},
        Scale = {default = 1.1},
        RenderPriority = {default = 90},
        ShowDistance = {default = false}
      },
      TrackedObjective = {
        RenderOnCompass = {default = true},
        ClampToEdge = {default = true},
        MaxRange = {default = 0},
        YOffset = {default = 0},
        Scale = {default = 0.8},
        RenderPriority = {default = 20},
        ShowDistance = {default = true}
      },
      AvailableObjective = {
        RenderOnCompass = {default = true},
        ClampToEdge = {default = false},
        MaxRange = {default = 0},
        YOffset = {default = 0},
        Scale = {default = 0.4},
        RenderPriority = {default = 60},
        ShowDistance = {default = true}
      },
      GroupWaypoint = {
        RenderOnCompass = {default = true},
        ClampToEdge = {default = true},
        MaxRange = {default = 0},
        YOffset = {default = -14},
        Scale = {default = 1},
        RenderPriority = {default = 30},
        ShowDistance = {default = true}
      },
      OutpostRushMarkers = {
        RenderOnCompass = {default = true},
        ClampToEdge = {default = false},
        MaxRange = {default = 0},
        YOffset = {default = 0},
        Scale = {default = 1.1},
        RenderPriority = {default = 20},
        ShowDistance = {default = true}
      }
    }
  },
  cachedTau = 2 * math.pi,
  cachedHalfPi = math.pi / 2,
  cachedCompassSetWidth = nil,
  offsetModifier = 0,
  lastPlayerPosition = Vector3(0, 0, 0),
  lastCompassHeading = 0,
  markerIconData = {},
  uiMarkers = {},
  currentUpdateIndex = 1,
  maxPOIMarkers = 15,
  maxUpdateCount = 1,
  compassOffset = Vector2(0, 0),
  memberIndices = {},
  enteredTerritories = {},
  currentTerritoryId = 0,
  newPOIs = {},
  poiIdToIconData = {},
  maxHeadingDifferenceForClamped = 72.5 * math.pi / 180,
  numClampedUiMarkers = 0,
  clampedMinPercentage = -1,
  clampedMaxPercentage = 1,
  maxHeadingDifferenceForDistance = 45 * math.pi / 180,
  showIconsOnCompass = true,
  MAX_TRACKED_OBJECTIVES = 6,
  SORTED_DISTANCE_OBJECTIVES_INDEX = 1,
  TRACKING_REASON_PLAYER_PINNED = 1,
  TRACKING_REASON_DISTANCE = 2,
  screenStatesToDisable = {
    [2478623298] = true,
    [3901667439] = true,
    [3777009031] = true,
    [3766762380] = true,
    [1967160747] = true,
    [3576764016] = true,
    [1643432462] = true,
    [3493198471] = true,
    [898756891] = true,
    [3525919832] = true,
    [2815678723] = true,
    [3175660710] = true,
    [1823500652] = true,
    [156281203] = true,
    [3784122317] = true,
    [640726528] = true,
    [3370453353] = true,
    [2896319374] = true,
    [828869394] = true,
    [3211015753] = true,
    [2640373987] = true,
    [1319313135] = true,
    [1468490675] = true,
    [1101180544] = true,
    [3024636726] = true,
    [2972535350] = true,
    [3349343259] = true,
    [2552344588] = true,
    [1809891471] = true,
    [3664731564] = true,
    [4119896358] = true,
    [1634988588] = true,
    [319051850] = true,
    [2609973752] = true
  },
  COMPASS_ICON_SLICE_POI = "LyShineUI\\Compass\\CompassDot",
  closedLinesHeight = 8,
  openLinesHeight = 28,
  closedDistanceTextY = 38,
  openDistanceTextY = 50
}
BaseElement:CreateNewElement(CompassScreen)
Spawner:AttachSpawner(CompassScreen)
function CompassScreen:OnInit()
  BaseElement.OnInit(self)
  self:CacheAnimations()
  self.iconTypes = mapTypes.iconTypes
  self.sourceTypes = mapTypes.sourceTypes
  self.entityTrackingIconsToRemove = {}
  self.objectivePositions = {}
  self.uniqueTrackedObjectives = {}
  self.taskHandlers = {}
  self.trackedNpcIds = {}
  self.trackedObjectiveReasons = {}
  self.numTrackedObjectives = 0
  self.poiBgColor = self.UIStyle.COLOR_BLACK
  self.poiBgOpacity = 0.2
  self.poiNameColor = self.UIStyle.COLOR_WHITE
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(LyShineManagerNotificationBus, self.canvasId)
  self:BusConnect(NpcComponentNotificationsBus, self.entityId)
  self.cachedCompassSetWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.DirectionsElement) * 0.5
  self.offsetModifier = self.cachedCompassSetWidth / self.cachedTau
  self.sourceType = self.sourceTypes.Compass
  self:BusConnect(UiSpawnerNotificationBus, self.CompassPointSpawner)
  for i = 1, self.maxPOIMarkers do
    self:SpawnSlice(self.CompassPointSpawner, self.COMPASS_ICON_SLICE_POI, self.MarkerSpawned, i)
  end
  for _, properties in pairs(self.PropertiesPerIconType) do
    properties.maxSqRange = properties.MaxRange * properties.MaxRange
  end
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.CompassLines, {opacity = 0})
  end
  DynamicBus.Compass.Connect(self.entityId, self)
  DynamicBus.GroupDataNotification.Connect(self.entityId, self)
  UiImageBus.Event.SetUVOverrides(self.Properties.EastToSouth, 0.7021484375, 0, 0.904296875, 1)
  UiImageBus.Event.SetUVOverrides(self.Properties.SouthToSouth, 0.09521484375, 0, 0.904296875, 1)
  UiImageBus.Event.SetUVOverrides(self.Properties.SouthToWest, 0.09521484375, 0, 0.29736328125, 1)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    self.isInRaid = raidId and raidId:IsValid()
    self:CheckShowIcons()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self:BusDisconnect(self.participantBusHandler)
    if not playerEntityId then
      return
    end
    self.playerEntityId = playerEntityId
    self.participantBusHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, playerEntityId)
  end)
  self.nearbySortingEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.objectives-enableNearbySorting")
  SetTextStyle(self.Properties.DistanceText, self.UIStyle.FONT_STYLE_COMPASS_DISTANCE_TEXT)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.DistanceContainer, self.closedDistanceTextY)
  SetTextStyle(self.Properties.PoiName, self.UIStyle.FONT_STYLE_COMPASS_POI_NAME)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.CurrentAreaTerritory.SmallestContainingId", function(self, territoryId)
    if territoryId and territoryId ~= self.currentTerritoryId then
      self.currentTerritoryId = territoryId
      self:SetTerritoryData(self.currentTerritoryId)
    end
  end)
  self:BusConnect(UiTriggerAreaEventNotificationBus)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.enable-objective-poi-highlight", function(self, enablePoiHighlight)
    self.enablePoiHighlight = enablePoiHighlight
  end)
end
function CompassScreen:CacheAnimations()
  if not self.anim then
    self.anim = {}
    self.anim.openCompassLines1 = self.ScriptedEntityTweener:CacheAnimation(0.3, {
      h = self.openLinesHeight,
      imgColor = self.UIStyle.COLOR_WHITE,
      ease = "QuadOut"
    })
    self.anim.openCompassLines2 = self.ScriptedEntityTweener:CacheAnimation(0.3, {
      imgColor = self.UIStyle.COLOR_TAN_MEDIUM_LIGHT,
      ease = "QuadOut"
    })
    self.anim.revealFlash1 = self.ScriptedEntityTweener:CacheAnimation(0.3, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadInOut"
    })
    self.anim.revealFlash2 = self.ScriptedEntityTweener:CacheAnimation(0.3, {
      scaleX = 0.6,
      scaleY = 0,
      opacity = 0,
      imgColor = self.UIStyle.COLOR_YELLOW,
      ease = "QuadInOut"
    })
    self.anim.closeCompassLines = self.ScriptedEntityTweener:CacheAnimation(0.3, {
      h = self.closedLinesHeight,
      ease = "QuadOut"
    })
    self.anim.distanceToOpenPos = self.ScriptedEntityTweener:CacheAnimation(0.3, {
      y = self.openDistanceTextY,
      ease = "QuadOut"
    })
    self.anim.distanceToClosedPos = self.ScriptedEntityTweener:CacheAnimation(0.3, {
      y = self.closedDistanceTextY,
      ease = "QuadOut"
    })
  end
end
function CompassScreen:CheckShowIcons()
  self.showIconsOnCompass = not self.isInRaid or self.gameModeId == GameModeCommon.GAMEMODE_OUTPOST_RUSH
end
function CompassScreen:IsIconAlwaysShowing(iconData)
  return iconData.isAlwaysOn or iconData.maxSqRange == 0
end
function CompassScreen:OnEnteredGameMode(gameModeEntityId, gameModeId)
  self.gameModeId = gameModeId
  self.gameModeEntityId = gameModeEntityId
  self:CheckShowIcons()
end
function CompassScreen:OnExitedGameMode(gameModeEntityId)
  self.gameModeId = nil
  self.gameModeEntityId = nil
  self:CheckShowIcons()
end
function CompassScreen:OnTick()
  local numMarkerData = #self.markerIconData
  local iterateTo = math.min(self.currentUpdateIndex + self.maxUpdateCount, numMarkerData)
  for i = self.currentUpdateIndex, iterateTo do
    local iconData = self.markerIconData[i]
    if iconData.iconType == self.iconTypes.EntityTrackingIcon then
      local entityId = iconData.entityId
      if entityId and entityId:IsValid() and self.showIconsOnCompass then
        local x = TransformBus.Event.GetWorldX(entityId)
        local y = x and TransformBus.Event.GetWorldY(entityId)
        if x and y then
          iconData.position.x = x
          iconData.position.y = y
        else
          table.insert(self.entityTrackingIconsToRemove, iconData)
        end
      else
        table.insert(self.entityTrackingIconsToRemove, iconData)
      end
    end
    local distanceSq = self.lastPlayerPosition:GetDistanceSq(Vector3(iconData.position.x, iconData.position.y, 0))
    iconData.distance = distanceSq
    if iconData.attachedUiMarker then
      self:UpdatePositionalIconDistance(iconData.attachedUiMarker)
    end
  end
  self.currentUpdateIndex = iterateTo + 1
  if numMarkerData < self.currentUpdateIndex then
    self.currentUpdateIndex = 1
    local closestHiddenIconData
    for i = 1, numMarkerData do
      local iconData = self.markerIconData[i]
      if self:ShouldIconBeDisplayed(iconData) and not self:IsIconDisplaying(iconData) then
        if not closestHiddenIconData then
          closestHiddenIconData = iconData
        elseif self:IsIconAlwaysShowing(closestHiddenIconData) then
          if self:IsIconAlwaysShowing(iconData) and iconData.distance < closestHiddenIconData.distance then
            closestHiddenIconData = iconData
          end
        elseif self:IsIconAlwaysShowing(iconData) then
          closestHiddenIconData = iconData
        elseif iconData.distance < closestHiddenIconData.distance then
          closestHiddenIconData = iconData
        end
      end
    end
    if closestHiddenIconData then
      local furthestDisplayedUiMarker, isMarkerDisplaying = self:FindFurthestDisplayedUiMarker()
      if furthestDisplayedUiMarker and (not isMarkerDisplaying or self:IsIconAlwaysShowing(closestHiddenIconData) or furthestDisplayedUiMarker.iconData.distance > closestHiddenIconData.distance) then
        if furthestDisplayedUiMarker.iconData.clampToEdge and not closestHiddenIconData.clampToEdge then
          self.numClampedUiMarkers = self.numClampedUiMarkers - 1
        elseif not furthestDisplayedUiMarker.iconData.clampToEdge and closestHiddenIconData.clampToEdge then
          self.numClampedUiMarkers = self.numClampedUiMarkers + 1
        end
        furthestDisplayedUiMarker.iconData.attachedUiMarker = nil
        furthestDisplayedUiMarker:UpdateData(closestHiddenIconData)
        closestHiddenIconData.attachedUiMarker = furthestDisplayedUiMarker
        furthestDisplayedUiMarker:SetExternalVisibility(true)
        self.shouldTickAllMarkers = true
        if closestHiddenIconData.keyId and self.newPOIs[closestHiddenIconData.keyId] then
          self.newPOIs[closestHiddenIconData.keyId] = nil
          self:PulseIcon(furthestDisplayedUiMarker)
        else
        end
      end
    end
  end
end
function CompassScreen:OnCrySystemPostViewSystemUpdate()
  self:UpdateUiMarkerPositions()
end
function CompassScreen:UpdateUiMarkerPositions()
  for j = 1, #self.entityTrackingIconsToRemove do
    local iconData = self.entityTrackingIconsToRemove[j]
    self:RemoveMarkerDataForDisplay(self.iconTypes.EntityTrackingIcon, iconData.markerUuid)
  end
  ClearTable(self.entityTrackingIconsToRemove)
  local centermostIcon = self.centermostIcon
  local centermostIconHeadingOffset = self.maxHeadingDifferenceForDistance
  for i = 1, #self.uiMarkers do
    local positionalIcon = self.uiMarkers[i]
    if self.shouldTickAllMarkers or positionalIcon.iconData.iconType == self.iconTypes.EntityTrackingIcon or self.shouldTickClampedMarkers and positionalIcon.iconData.clampToEdge then
      self:UpdateCompassIconVisibility(positionalIcon)
      if positionalIcon:GetIsEnabled() then
        self:UpdateCompassIconPosition(positionalIcon)
      end
    end
    local iconProperties = self.PropertiesPerIconType[positionalIcon.iconData.iconType]
    if positionalIcon:GetIsEnabled() and iconProperties.ShowDistance then
      local iconHeading = positionalIcon:GetHeading()
      headingOffset = math.abs(iconHeading - self.lastCompassHeading)
      if headingOffset > math.pi then
        headingOffset = math.abs(self.cachedTau - headingOffset)
      end
      if centermostIconHeadingOffset > headingOffset then
        centermostIcon = positionalIcon
        centermostIconHeadingOffset = headingOffset
      elseif centermostIcon == positionalIcon then
        centermostIcon = nil
      end
    elseif centermostIcon == positionalIcon then
      centermostIcon = nil
    end
  end
  if centermostIcon then
    UiElementBus.Event.SetIsEnabled(self.Properties.DistanceContainer, true)
    local iconX = UiTransformBus.Event.GetLocalPositionX(centermostIcon.entityId)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.DistanceContainer, iconX)
    if self.centermostIcon ~= centermostIcon then
      if self.centermostIcon then
        UiElementBus.Event.SetRenderPriority(self.centermostIcon.entityId, self.centermostIcon.iconData.renderPriority)
      end
      UiElementBus.Event.SetRenderPriority(centermostIcon.entityId, 0)
      self.centermostIcon = centermostIcon
      self:UpdatePositionalIconDistance(centermostIcon)
    end
  else
    self.centermostIcon = nil
    UiElementBus.Event.SetIsEnabled(self.Properties.DistanceContainer, false)
  end
  self.shouldTickAllMarkers = false
  self.shouldTickClampedMarkers = false
end
function CompassScreen:OnPlayerHeadingChanged(heading)
  self.lastCompassHeading = heading * -1
  self.clampedMinPercentage = (self.lastCompassHeading - self.maxHeadingDifferenceForClamped) / self.cachedTau
  self.clampedMaxPercentage = (self.lastCompassHeading + self.maxHeadingDifferenceForClamped) / self.cachedTau
  local newQuad = math.floor(heading / self.cachedHalfPi)
  self.compassOffset.x = heading * self.offsetModifier
  UiTransformBus.Event.SetLocalPosition(self.Properties.DirectionsElement, self.compassOffset)
  if not self.lastQuad or self.lastQuad ~= newQuad then
    self:OnPlayerPositionChanged(self.lastPlayerPosition, true)
  elseif self.numClampedUiMarkers > 0 then
    self.shouldTickClampedMarkers = true
  end
  self.lastQuad = newQuad
end
function CompassScreen:UpdatePositionalIconDistance(positionalIcon)
  if positionalIcon:GetIsEnabled() and positionalIcon == self.centermostIcon and positionalIcon.isDataInitialized then
    local distance = math.sqrt(positionalIcon.iconData.distance)
    local distanceText = DistanceToText(distance)
    UiTextBus.Event.SetText(self.Properties.DistanceText, distanceText)
  end
  if positionalIcon.iconData.iconType == self.iconTypes.Respawn and positionalIcon:GetIsEnabled() and positionalIcon.isDataInitialized and positionalIcon.maxRespawnDistanceSq then
    local isOutOfRange = positionalIcon.maxRespawnDistanceSq > 0 and positionalIcon.iconData.distance > positionalIcon.maxRespawnDistanceSq
    positionalIcon:SetRespawnIsOutOfRange(isOutOfRange)
  end
end
function CompassScreen:OnPlayerPositionChanged(playerPos, forceRecalc)
  if not playerPos then
    return
  end
  if not forceRecalc and not playerPos and playerPos.x == self.lastPlayerPosition.x and playerPos.y == self.lastPlayerPosition.y then
    return
  end
  self.lastPlayerPosition = playerPos
  self.lastPlayerPosition.z = 0
  self.shouldTickAllMarkers = true
end
function CompassScreen:UpdateCompassIconPosition(positionalIcon)
  if positionalIcon.iconData.position then
    local poiValue = math.atan2(positionalIcon.iconData.position.x - self.lastPlayerPosition.x, positionalIcon.iconData.position.y - self.lastPlayerPosition.y)
    if poiValue < 0 then
      poiValue = poiValue + self.cachedTau
    end
    local poiPercentage = poiValue / self.cachedTau
    local differenceFromCurrentHeading = math.abs(poiValue - self.lastCompassHeading)
    if differenceFromCurrentHeading > math.pi then
      poiPercentage = (1 - poiPercentage) * -1
    end
    if positionalIcon.iconData.clampToEdge then
      poiPercentage = Clamp(poiPercentage, self.clampedMinPercentage, self.clampedMaxPercentage)
    end
    local yOffset = 0
    local iconProperties = self.PropertiesPerIconType[positionalIcon.iconData.iconType]
    if iconProperties ~= nil then
      yOffset = iconProperties.YOffset
    end
    UiTransformBus.Event.SetLocalPosition(positionalIcon.entityId, Vector2(poiPercentage * self.cachedCompassSetWidth, yOffset))
    positionalIcon:SetHeading(poiValue)
  end
end
function CompassScreen:UpdateCompassIconVisibility(positionalIcon)
  local iconData = positionalIcon.iconData
  if iconData.iconType == nil then
    return
  end
  if iconData.distance ~= -1 or self:IsIconAlwaysShowing(iconData) then
    positionalIcon:SetExternalVisibility(self:ShouldIconBeDisplayed(iconData))
  else
    positionalIcon:SetExternalVisibility(false)
  end
end
function CompassScreen:ShouldIconBeDisplayed(iconData)
  if (iconData.iconType == self.iconTypes.PointOfInterest or iconData.iconType == self.iconTypes.TrackedObjective) and self.enteredTerritories[iconData.keyId] then
    return false
  end
  if self:IsIconAlwaysShowing(iconData) then
    return true
  else
    return iconData.distance < iconData.maxSqRange
  end
end
function CompassScreen:AddEntityIconToCompass(entityId, imagePath)
  if not self.showIconsOnCompass then
    return
  end
  for i = 1, #self.markerIconData do
    if self.markerIconData[i].entityId == entityId then
      return
    end
  end
  local spawnerTag = SpawnerRequestBus.Event.GetSpawnerTag(entityId)
  local definitionId = TerritoryDataProviderRequestBus.Event.GetTerritoryId(entityId)
  local isEncounter = false
  if definitionId then
    local definition = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(definitionId)
    local _, encounterIcon = EncounterDataHandler:GetRecommendedIcons(spawnerTag, definition)
    if encounterIcon then
      imagePath = encounterIcon
      isEncounter = true
    end
  end
  self:AddMarkerDataForDisplay(Vector3(0, 0, 0), Color(1, 1, 1), self.iconTypes.EntityTrackingIcon, imagePath, entityId, nil, nil, nil, nil, nil, entityId, nil, isEncounter)
end
function CompassScreen:RemoveEntityIconFromCompass(entityId)
  for i = 1, #self.markerIconData do
    if self.markerIconData[i].entityId == entityId then
      self:RemoveMarkerDataForDisplay(self.iconTypes.EntityTrackingIcon, entityId)
      return
    end
  end
end
function CompassScreen:FindFurthestDisplayedUiMarker()
  local furthestMarker
  for i = 1, #self.uiMarkers do
    local positionalIcon = self.uiMarkers[i]
    if not positionalIcon.isDataInitialized then
      return positionalIcon, false
    end
    local iconData = positionalIcon.iconData
    if not self:IsIconAlwaysShowing(iconData) then
      if not self:ShouldIconBeDisplayed(iconData) then
        return positionalIcon, false
      end
      if not furthestMarker then
        furthestMarker = positionalIcon
      elseif furthestMarker.iconData.distance < iconData.distance then
        furthestMarker = positionalIcon
      end
    end
  end
  return furthestMarker, true
end
function CompassScreen:IsIconDisplaying(iconData)
  return iconData.attachedUiMarker ~= nil
end
function CompassScreen:OnMemberAdded(addedIndex, isLocalPlayer)
  if self.PropertiesPerIconType.GroupWaypoint.RenderOnCompass and not self.memberIndices[addedIndex] then
    self.memberIndices[addedIndex] = true
    self:AddMarkerDataForDisplay(Vector3(0, 0, 0), Color(1, 1, 1), self.iconTypes.GroupWaypoint, "", nil, true, nil, nil, nil, nil, nil, addedIndex)
  end
  if isLocalPlayer then
    for i = 1, #self.uiMarkers do
      if self.uiMarkers[i].iconData.iconType == self.iconTypes.Waypoint then
        self.uiMarkers[i].iconData.imageFGColor = self.UIStyle.COLOR_GROUP_MEMBERS[addedIndex]
        self.uiMarkers[i]:SetImageColor(self.UIStyle.COLOR_GROUP_MEMBERS[addedIndex])
        break
      end
    end
  end
end
function CompassScreen:OnMemberRemoved(removedIndex)
  if self.PropertiesPerIconType.GroupWaypoint.RenderOnCompass and self.memberIndices[removedIndex] then
    self.memberIndices[removedIndex] = nil
    self:RemoveMarkerDataForDisplay(self.iconTypes.GroupWaypoint, removedIndex)
  end
end
function CompassScreen:OnGroupDisbanded()
  for i = 1, #self.uiMarkers do
    if self.uiMarkers[i].iconData.iconType == self.iconTypes.Waypoint then
      self.uiMarkers[i].iconData.imageFGColor = self.UIStyle.COLOR_GROUP_MEMBERS[1]
      self.uiMarkers[i]:SetImageColor(self.UIStyle.COLOR_GROUP_MEMBERS[1])
      break
    end
  end
end
function CompassScreen:MarkerSpawned(entity, index)
  table.insert(self.uiMarkers, entity)
  entity:SetExternalVisibility(false)
  if #self.uiMarkers == self.maxPOIMarkers then
    self:OnUiMarkersSpawned()
  end
end
function CompassScreen:OnUiMarkersSpawned()
  self:BusConnect(DynamicBus.UITickBus)
  self:BusConnect(MapComponentEventBus)
  self:AddMarkerDataForDisplay(Vector3(0, 0, 0), Color(1, 1, 1), self.iconTypes.Death, "", nil, true)
  self:AddMarkerDataForDisplay(Vector3(0, 0, 0), Color(1, 1, 1), self.iconTypes.Waypoint, "", nil, true)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.PlayerHeading", self.OnPlayerHeadingChanged)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Position", self.OnPlayerPositionChanged)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HomePoints.Count", function(self, count)
    local campIndex = -1
    local count = count or 0
    for i = 1, count do
      if self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HomePoints." .. i .. ".Type") == "Camp" then
        campIndex = i
        break
      end
    end
    if campIndex ~= -1 or self.lastCampIndex ~= campIndex then
      self:RemoveMarkerDataForDisplay(self.iconTypes.Respawn)
      self.lastCampIndex = nil
    end
    if not self.lastCampIndex then
      self:AddMarkerDataForDisplay(Vector3(0, 0, 0), Color(1, 1, 1), self.iconTypes.Respawn, "", nil, true, nil, nil, nil, nil, nil, campIndex)
      self.lastCampIndex = campIndex
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enablePOIDiscovery", function(self, enabled)
    if enabled then
      self.isPOIDiscoveryEnabled = enabled
      self.isPOIInitialized = false
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "ObjectivesComponentRequestBus.IsConnected", function(self, isConnected)
    if isConnected == nil then
      return
    end
    self.objectivesBusConnected = isConnected
    self:TryInitTrackedObjectives()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ObjectiveEntityId", function(self, entityId)
    if entityId == nil then
      return
    end
    self.objectivesComponentEntityId = entityId
    self.objectivesEntitySet = true
    if self.objectivesComponentBusHandler then
      self:BusDisconnect(self.objectivesComponentBusHandler)
    end
    self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, entityId)
    self:TryInitTrackedObjectives()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, entityId)
    if entityId == nil then
      return
    end
    self:BusConnect(ObjectivesComponentNotificationsBus, entityId)
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.EnteredTerritoryId", function(self, territoryId)
    if territoryId then
      self.enteredTerritories[territoryId] = true
      if self.isPOIDiscoveryEnabled and not self.isPOIInitialized then
        self:UpdateSimplePOIs()
        self.isPOIInitialized = true
      end
      self:RefreshCompassIconVisibilityWithTerritoryId(territoryId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.ExitedTerritoryId", function(self, territoryId)
    if territoryId then
      self.enteredTerritories[territoryId] = nil
      self:RefreshCompassIconVisibilityWithTerritoryId(territoryId)
    end
  end)
  self.dataLayer:RegisterMultiObserver(self, {
    "Hud.LocalPlayer.Progression.Level",
    "Hud.LocalPlayer.Faction"
  }, function(self, _)
    NpcComponentRequestBus.Broadcast.RequestPublishNpcStates()
  end)
end
function CompassScreen:RefreshCompassIconVisibilityWithTerritoryId(territoryId)
  if self.poiIdToIconData[territoryId] then
    for _, iconData in pairs(self.poiIdToIconData[territoryId]) do
      if iconData and iconData.attachedUiMarker then
        self:UpdateCompassIconVisibility(iconData.attachedUiMarker)
      end
    end
  end
end
function CompassScreen:TryInitTrackedObjectives()
  if self.objectivesBusConnected and self.objectivesEntitySet then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local objectives = ObjectivesComponentRequestBus.Event.GetTrackedObjectives(playerEntityId)
    for i = 1, #objectives do
      self:OnTrackedObjectiveAdded(objectives[i])
    end
    self:OnObjectiveSortingChanged()
  end
end
function CompassScreen:AddTrackedObjectiveTask(objectiveTaskInstanceId, position, trackedReasonNum)
  local objectiveId = objectiveTaskInstanceId.objectiveInstanceId
  if not self.taskHandlers[objectiveId.value] then
    self.taskHandlers[objectiveId.value] = self:BusConnect(ObjectiveNotificationBus, objectiveId)
  end
  if self.uniqueTrackedObjectives[objectiveTaskInstanceId:ToString()] then
    for i = 1, #self.markerIconData do
      local shouldUpdatePosition = self.markerIconData[i].iconType == self.iconTypes.TrackedObjective and self.markerIconData[i].markerUuid and self.markerIconData[i].markerUuid == objectiveTaskInstanceId
      if shouldUpdatePosition then
        self.markerIconData[i].position = position
        break
      end
    end
  else
    self.uniqueTrackedObjectives[objectiveTaskInstanceId:ToString()] = true
    if not self.trackedObjectiveReasons[objectiveId.value] then
      self.trackedObjectiveReasons[objectiveId.value] = trackedReasonNum or self.TRACKING_REASON_PLAYER_PINNED
      self.numTrackedObjectives = self.numTrackedObjectives + 1
      self:RemoveExcessTrackedObjectives()
    end
    local objectiveTaskTerritoryId
    if self.objectivePositions[objectiveId.value] then
      local objectiveData = self.objectivePositions[objectiveId.value][objectiveTaskInstanceId.taskIndex]
      objectiveTaskTerritoryId = objectiveData.territoryId
    end
    local iconPath, iconColor = ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(objectiveId)
    self:AddMarkerDataForDisplay(position, iconColor, self.iconTypes.TrackedObjective, iconPath, nil, nil, objectiveTaskTerritoryId, nil, nil, nil, objectiveTaskInstanceId)
  end
end
function CompassScreen:OnTrackedObjectiveAdded(objectiveId, trackedReasonNum)
  if self.trackedObjectiveReasons[objectiveId.value] then
    self.trackedObjectiveReasons[objectiveId.value] = trackedReasonNum or self.TRACKING_REASON_PLAYER_PINNED
  end
  if self.objectivePositions[objectiveId.value] then
    for taskIndex, data in pairs(self.objectivePositions[objectiveId.value]) do
      self:AddTrackedObjectiveTask(data.taskId, data.position, trackedReasonNum)
      data.isTracked = true
    end
  end
end
function CompassScreen:OnTrackedObjectiveRemoved(objectiveId)
  if self.objectivePositions[objectiveId.value] and self:ShouldRemoveTrackedObjective(objectiveId) then
    for taskIndex, data in pairs(self.objectivePositions[objectiveId.value]) do
      self:RemoveTrackedObjective(data.taskId, true)
      data.isTracked = false
    end
    if self.trackedObjectiveReasons[objectiveId.value] then
      self.trackedObjectiveReasons[objectiveId.value] = nil
      self.numTrackedObjectives = self.numTrackedObjectives - 1
    end
  end
end
function CompassScreen:OnObjectiveTaskPositionAdded(objectiveTaskInstanceId, position, isTracked, attachedPoi)
  local objectiveId = objectiveTaskInstanceId.objectiveInstanceId
  if not self.objectivePositions[objectiveId.value] then
    self.objectivePositions[objectiveId.value] = {}
  end
  if attachedPoi ~= 0 then
    local overrideLocation = ObjectiveTaskRequestBus.Event.GetUIData(objectiveTaskInstanceId, "OverrideLocation")
    if overrideLocation and overrideLocation.x ~= 0 and overrideLocation.y ~= 0 then
      attachedPoi = 0
    end
  end
  local objectiveData = {
    taskId = objectiveTaskInstanceId,
    position = position,
    territoryId = attachedPoi
  }
  self.objectivePositions[objectiveId.value][objectiveTaskInstanceId.taskIndex] = objectiveData
  if isTracked then
    self:AddTrackedObjectiveTask(objectiveTaskInstanceId, position)
    objectiveData.isTracked = true
  end
  if attachedPoi == self.currentTerritoryId then
    self:UpdateObjectiveHighlight()
  end
end
function CompassScreen:OnObjectiveTaskPositionsRemoved(objectiveTaskInstanceId, isTracked)
  local objectiveId = objectiveTaskInstanceId.objectiveInstanceId
  if self.objectivePositions[objectiveId.value] then
    local positionData = self.objectivePositions[objectiveId.value][objectiveTaskInstanceId.taskIndex]
    if positionData then
      if positionData.territoryId == self.currentTerritoryId then
        self:UpdateObjectiveHighlight()
      end
      self:RemoveTrackedObjective(objectiveTaskInstanceId, false)
    end
    self.objectivePositions[objectiveId.value][objectiveTaskInstanceId.taskIndex] = nil
  end
end
function CompassScreen:OnObjectiveSortingChanged()
  if self.nearbySortingEnabled and self.numTrackedObjectives < self.MAX_TRACKED_OBJECTIVES then
    local objectivesSortedByDistance = ObjectivesComponentRequestBus.Event.GetObjectivesOrdered(self.objectivesComponentEntityId, eObjectiveOrder_Distance)
    if objectivesSortedByDistance and objectivesSortedByDistance[self.SORTED_DISTANCE_OBJECTIVES_INDEX] then
      local sortedByDistanceList = objectivesSortedByDistance[self.SORTED_DISTANCE_OBJECTIVES_INDEX].second
      if sortedByDistanceList then
        for i = 1, #sortedByDistanceList do
          if not self.trackedObjectiveReasons[sortedByDistanceList[i].value] then
            self:OnTrackedObjectiveAdded(sortedByDistanceList[i], self.TRACKING_REASON_DISTANCE)
            if self.numTrackedObjectives >= self.MAX_TRACKED_OBJECTIVES then
              break
            end
          end
        end
      end
    end
  end
  self:OnObjectiveChanged()
end
function CompassScreen:RemoveExcessTrackedObjectives()
  if self.nearbySortingEnabled and self.numTrackedObjectives > self.MAX_TRACKED_OBJECTIVES then
    local objectivesSortedByDistance = ObjectivesComponentRequestBus.Event.GetObjectivesOrdered(self.objectivesComponentEntityId, eObjectiveOrder_Distance)
    if objectivesSortedByDistance and objectivesSortedByDistance[self.SORTED_DISTANCE_OBJECTIVES_INDEX] then
      local sortedByDistanceList = objectivesSortedByDistance[self.SORTED_DISTANCE_OBJECTIVES_INDEX].second
      if sortedByDistanceList then
        for i = #sortedByDistanceList, 1, -1 do
          if self.trackedObjectiveReasons[sortedByDistanceList[i].value] == self.TRACKING_REASON_DISTANCE then
            self:OnTrackedObjectiveRemoved(sortedByDistanceList[i])
            if self.numTrackedObjectives <= self.MAX_TRACKED_OBJECTIVES then
              break
            end
          end
        end
      end
    end
  end
  self:OnObjectiveChanged()
end
function CompassScreen:ShouldRemoveTrackedObjective(objectiveInstanceId)
  if not self.trackedObjectiveReasons[objectiveInstanceId.value] or self.trackedObjectiveReasons[objectiveInstanceId.value] == self.TRACKING_REASON_DISTANCE then
    return true
  end
  if self.nearbySortingEnabled then
    local objectivesSortedByDistance = ObjectivesComponentRequestBus.Event.GetObjectivesOrdered(self.objectivesComponentEntityId, eObjectiveOrder_Distance)
    if objectivesSortedByDistance and objectivesSortedByDistance[self.SORTED_DISTANCE_OBJECTIVES_INDEX] then
      local sortedByDistanceList = objectivesSortedByDistance[self.SORTED_DISTANCE_OBJECTIVES_INDEX].second
      local availableObjectiveSlots = self.MAX_TRACKED_OBJECTIVES - self.numTrackedObjectives + 1
      if sortedByDistanceList and 0 < availableObjectiveSlots then
        for i = 1, #sortedByDistanceList do
          if sortedByDistanceList[i].value == objectiveInstanceId.value then
            return false
          elseif not self.trackedObjectiveReasons[sortedByDistanceList[i].value] then
            availableObjectiveSlots = availableObjectiveSlots - 1
            if availableObjectiveSlots <= 0 then
              return true
            end
          end
        end
      end
    end
  end
  return true
end
function CompassScreen:RemoveTrackedObjective(taskInstanceId, disconnectHandler)
  self:RemoveMarkerDataForDisplay(self.iconTypes.TrackedObjective, taskInstanceId)
  self.uniqueTrackedObjectives[taskInstanceId:ToString()] = nil
  if disconnectHandler then
    local objectiveId = taskInstanceId.objectiveInstanceId
    local handler = self.taskHandlers[objectiveId.value]
    if handler then
      self:BusDisconnect(handler)
      self.taskHandlers[objectiveId.value] = nil
    end
  end
end
function CompassScreen:OnObjectiveChanged()
  for objectiveIdValues, taskTable in pairs(self.objectivePositions) do
    for _, taskData in pairs(taskTable) do
      if taskData.isTracked then
        local objectiveTaskInstanceId = taskData.taskId
        local found = false
        for i = 1, #self.uiMarkers do
          local positionalIcon = self.uiMarkers[i]
          local iconData = positionalIcon.iconData
          if iconData.iconType == self.iconTypes.TrackedObjective and iconData.markerUuid == objectiveTaskInstanceId then
            local iconPath, iconColor = ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(objectiveTaskInstanceId.objectiveInstanceId)
            iconData.imageFGColor = iconColor
            iconData.imageFGPath = iconPath
            UiImageBus.Event.SetSpritePathname(positionalIcon.Properties.Image, iconPath)
            UiImageBus.Event.SetColor(positionalIcon.Properties.Image, iconColor)
            found = true
            break
          end
        end
        if not found then
          for i = 1, #self.markerIconData do
            local iconData = self.markerIconData[i]
            if iconData.iconType == self.iconTypes.TrackedObjective and iconData.markerUuid == objectiveTaskInstanceId then
              local iconPath, iconColor = ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(objectiveTaskInstanceId.objectiveInstanceId)
              iconData.imageFGColor = iconColor
              iconData.imageFGPath = iconPath
              break
            end
          end
        end
      end
    end
  end
  self:UpdateObjectiveHighlight()
end
function CompassScreen:OnObjectiveAdded(objectiveId)
  NpcComponentRequestBus.Broadcast.RequestPublishNpcStates()
end
function CompassScreen:OnObjectiveRemoved(objectiveId)
  NpcComponentRequestBus.Broadcast.RequestPublishNpcStates()
end
function CompassScreen:AddCapitals(capitals)
  if #capitals == 0 then
    Debug.Log("Warning: CompassScreen:AddCapitals, list of capitals was empty")
  end
  for index = 1, #capitals do
    if capitals[index].compassIconPath and capitals[index].compassIconPath ~= "" then
      self:AddMarkerDataForDisplay(capitals[index].capitalPosition, Color(1, 1, 1), self.iconTypes.PointOfInterest, capitals[index].compassIconPath, nil)
    end
  end
end
function CompassScreen:CreatePOIMarkers()
  local claims = MapComponentBus.Broadcast.GetClaims()
  local outposts = MapComponentBus.Broadcast.GetOutposts()
  local settlements = MapComponentBus.Broadcast.GetSettlements()
  self:AddCapitals(claims)
  self:AddCapitals(outposts)
  self:AddCapitals(settlements)
end
function CompassScreen:UpdateDiscoveredPOI(poiData, isInitialUpdate)
  if not self.showIconsOnCompass then
    return
  end
  local targetIcon = poiData.compassIconPath
  if targetIcon == "" then
    targetIcon = poiData.mapIconPath
  end
  if targetIcon == "" then
    return
  end
  local isAwareOf = poiData.isDiscovered or poiData.isCharted
  local alreadyExists = false
  local markerUuid = "poi" .. poiData.id
  if not isInitialUpdate then
    local foundIconData
    if self.poiIdToIconData[poiData.id] then
      for uuid, iconData in pairs(self.poiIdToIconData[poiData.id]) do
        if iconData and uuid == markerUuid then
          foundIconData = iconData
        end
      end
    end
    if foundIconData then
      alreadyExists = true
      foundIconData.imageFGPath = targetIcon
      foundIconData.isDiscovered = poiData.isDiscovered
      foundIconData.isCharted = poiData.isCharted
      if foundIconData.attachedUiMarker then
        if isAwareOf then
          foundIconData.attachedUiMarker:UpdateCurrentState(poiData.isDiscovered, poiData.isCharted)
          UiImageBus.Event.SetSpritePathname(foundIconData.attachedUiMarker.Properties.Image, targetIcon)
          self:UpdateCompassIconVisibility(foundIconData.attachedUiMarker)
        else
          self.poiIdToIconData[poiData.id][markerUuid] = nil
          self:RemoveMarkerDataForDisplay(foundIconData.iconType, foundIconData.removeUuid)
        end
      end
    end
  end
  if not alreadyExists and isAwareOf then
    if not self.newPOIs[poiData.id] and poiData.isDiscovered and not poiData.isCharted then
      self.newPOIs[poiData.id] = true
    end
    self:AddMarkerDataForDisplay(poiData.position, Color(1, 1, 1), self.iconTypes.PointOfInterest, targetIcon, nil, nil, poiData.id, poiData.isDiscovered, poiData.isCharted, poiData.discoveryRadius, markerUuid)
  end
end
function CompassScreen:UpdateSimplePOIs()
  local simplePOIs = MapComponentBus.Broadcast.GetSimplePOIs()
  for i = 1, #simplePOIs do
    local poiData = simplePOIs[i]
    self:UpdateDiscoveredPOI(poiData, true)
  end
end
function CompassScreen:OnNpcHasAvailableQuestChanged(npcId, hasAvailable, worldPos)
  if hasAvailable then
    if not self.trackedNpcIds[npcId] then
      self.trackedNpcIds[npcId] = worldPos
      local iconPath = ObjectiveTypeData.ObjectiveStates.Available.iconPath
      local npcData = MapComponentBus.Broadcast.GetNpcData(npcId)
      local npcFaction = npcData.factionType
      local iconColor = self.UIStyle.COLOR_WHITE
      if npcFaction ~= eFactionType_None and npcFaction ~= eFactionType_Any then
        iconPath = FactionCommon.factionInfoTable[npcFaction].objectiveIcon
        iconColor = FactionCommon.factionInfoTable[npcFaction].crestBgColor
      end
      self:AddMarkerDataForDisplay(worldPos, iconColor, self.iconTypes.AvailableObjective, iconPath, nil, nil, nil, nil, nil, nil, npcId)
    end
  elseif self.trackedNpcIds[npcId] then
    self:RemoveMarkerDataForDisplay(self.iconTypes.AvailableObjective, npcId)
    self.trackedNpcIds[npcId] = nil
  end
end
function CompassScreen:AddMarkerDataForDisplay(position, color, iconType, imagePath, markerId, isAlwaysOn, keyId, isDiscovered, isCharted, discoveryRadius, markerUuid, index, isEncounter)
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    return
  end
  if not iconType then
    Debug.Log("Trying to add compass icon without iconType, imagePath = " .. tostring(imagePath) .. ", markerId = " .. tostring(markerId))
    return
  end
  local iconProperties = self.PropertiesPerIconType[iconType]
  if not iconProperties.RenderOnCompass then
    return
  end
  local discoveryRadiusSq = discoveryRadius and discoveryRadius * discoveryRadius or 0
  local iconData = {
    entityId = markerId,
    position = position,
    iconType = iconType,
    sourceType = self.sourceTypes.Compass,
    imageFGColor = color,
    imageFGPath = imagePath,
    keyId = keyId,
    isDiscovered = isDiscovered,
    isCharted = isCharted,
    discoveryRadiusSq = discoveryRadiusSq,
    scale = iconProperties.Scale or 1,
    markerUuid = markerUuid,
    isAlwaysOn = isAlwaysOn,
    isEncounter = isEncounter,
    distance = -1,
    index = index,
    maxSqRange = iconProperties.maxSqRange,
    clampToEdge = iconProperties.ClampToEdge,
    renderPriority = iconProperties.RenderPriority
  }
  if iconData.iconType == self.iconTypes.PointOfInterest and discoveryRadiusSq ~= 0 then
    iconData.maxSqRange = discoveryRadiusSq
  end
  if keyId and markerUuid then
    if not self.poiIdToIconData[keyId] then
      self.poiIdToIconData[keyId] = {}
    end
    self.poiIdToIconData[keyId][markerUuid] = iconData
  end
  table.insert(self.markerIconData, iconData)
end
function CompassScreen:RemoveAllMarkersOfType(iconType)
  for i = 1, #self.uiMarkers do
    local positionalIcon = self.uiMarkers[i]
    if positionalIcon.iconData.iconType == iconType then
      positionalIcon.iconData.attachedUiMarker = nil
      positionalIcon:SetExternalVisibility(false)
      positionalIcon:ResetData()
    end
  end
  for i = #self.markerIconData, 1, -1 do
    if self.markerIconData[i].iconType == iconType then
      table.remove(self.markerIconData, i)
    end
  end
end
function CompassScreen:RemoveMarkerDataForDisplay(iconType, removeUuid)
  for i = 1, #self.uiMarkers do
    local positionalIcon = self.uiMarkers[i]
    if positionalIcon.iconData.iconType == iconType and (not removeUuid or positionalIcon.iconData.markerUuid == removeUuid) then
      positionalIcon.iconData.attachedUiMarker = nil
      positionalIcon:SetExternalVisibility(false)
      positionalIcon:ResetData()
    end
  end
  for i = #self.markerIconData, 1, -1 do
    if self.markerIconData[i].iconType == iconType and (not removeUuid or self.markerIconData[i].markerUuid == removeUuid) then
      table.remove(self.markerIconData, i)
    end
  end
end
function CompassScreen:OnShutdown()
  DynamicBus.GroupDataNotification.Disconnect(self.entityId, self)
  DynamicBus.Compass.Disconnect(self.entityId, self)
  for i = 1, #self.uiMarkers do
    UiElementBus.Event.DestroyElement(self.uiMarkers[i].entityId)
  end
  self:BusDisconnect(self.participantBusHandler)
  self.participantBusHandler = nil
  self.dataLayer:UnregisterObservers(self)
  self.dataLayer = nil
  self.taskHandlers = nil
end
function CompassScreen:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
end
function CompassScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[fromState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function CompassScreen:PulseIcon(iconTable)
  if iconTable then
    local startColor = self.UIStyle.COLOR_TAN_LIGHT
    local endColor = self.UIStyle.COLOR_TAN_LIGHT
    local pulseRadius = 50
    iconTable:CreatePulse(startColor, endColor, pulseRadius, 3)
  end
end
function CompassScreen:SetTerritoryData(territoryId)
  if territoryId == 0 then
    self.currentPoiName = nil
  else
    local territoryData = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(territoryId)
    local territoryName = territoryData.nameLocalizationKey
    local isPOI = territoryData.isPOI and not territoryData.isArea
    local showPOI = true
    if isPOI then
      local landmarkData = MapComponentBus.Broadcast.GetFirstLandmarkByType(territoryId, eTerritoryLandmarkType_FishingHotspot)
      level = FishingRequestsBus.Event.GetRequiredLevelByHotspotId(self.playerEntityId, Math.CreateCrc32(landmarkData.landmarkData))
      if level > CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, 1975517117) then
        showPOI = false
      end
    end
    self.currentPoiName = isPOI and showPOI and territoryName or nil
  end
  self:UpdatePoiName()
  self:UpdateObjectiveHighlight()
end
function CompassScreen:OnUiTriggerAreaEventEntered(enteringEntityId, triggerEntityId, eventId, identifier)
  if eventId == 3718191953 or eventId == 114609139 then
    local claimKey = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
    local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(claimKey)
    local isSettlementData = eventId == 3718191953
    local upgradeType = isSettlementData and eTerritoryUpgradeType_Settlement or eTerritoryUpgradeType_Fortress
    local tierInfo = TerritoryDataHandler:GetUpgradeTierInfoByTerritoryId(claimKey, upgradeType)
    local locTag = isSettlementData and "@ui_territory_name_with_settlement_tier_name" or "@ui_territory_name_with_fort_tier_name"
    local unclaimedText = GetLocalizedReplacementText("@ui_unclaimed_settlementorfort", {
      tierName = tierInfo.name
    })
    local territoryNameWithTierName = GetLocalizedReplacementText(locTag, {
      territoryName = territoryName,
      tierName = tierInfo.name
    })
    self.currentSettlementName = territoryNameWithTierName
  else
    self.currentSettlementName = nil
  end
  self:UpdatePoiName()
end
function CompassScreen:OnUiTriggerAreaEventExited(enteringEntityId, eventId)
  if eventId == 3718191953 or eventId == 114609139 then
    self.currentSettlementName = nil
  end
  self:UpdatePoiName()
end
function CompassScreen:UpdateObjectiveHighlight()
  if not self.enablePoiHighlight then
    return
  end
  local isObjectiveLocation = false
  for objectiveIdValues, taskTable in pairs(self.objectivePositions) do
    if isObjectiveLocation then
      break
    end
    for _, taskData in pairs(taskTable) do
      if taskData.territoryId == self.currentTerritoryId then
        isObjectiveLocation = true
        break
      end
    end
  end
  if self.isObjectiveLocation == isObjectiveLocation then
    return
  end
  self.poiBgColor = isObjectiveLocation and self.UIStyle.COLOR_YELLOW_LIGHT or self.UIStyle.COLOR_BLACK
  self.poiBgOpacity = isObjectiveLocation and 0.8 or 0.2
  self.poiNameColor = isObjectiveLocation and self.UIStyle.COLOR_BLACK or self.UIStyle.COLOR_WHITE
  if self.shownName then
    UiElementBus.Event.SetIsEnabled(self.Properties.PoiName, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.PoiBg, true)
    self.ScriptedEntityTweener:Stop(self.Properties.PoiName)
    self.ScriptedEntityTweener:Stop(self.Properties.PoiBg)
    if isObjectiveLocation then
      UiTextBus.Event.SetFontEffectByName(self.Properties.PoiName, self.UIStyle.FONT_EFFECT_NONE)
    else
      UiTextBus.Event.SetFontEffectByName(self.Properties.PoiName, self.UIStyle.FONT_EFFECT_OUTLINE_FAINT)
    end
    self.ScriptedEntityTweener:Play(self.Properties.PoiBg, 0.3, {
      opacity = self.poiBgOpacity,
      imgColor = self.poiBgColor,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.PoiName, 0.3, {
      opacity = 1,
      textColor = self.poiNameColor,
      ease = "QuadOut",
      delay = 0.2
    })
  end
  self.isObjectiveLocation = isObjectiveLocation
end
function CompassScreen:UpdatePoiName()
  local nameToShow = self.currentSettlementName or self.currentPoiName or nil
  if self.shownName == nameToShow then
    return
  end
  if nameToShow then
    UiElementBus.Event.SetIsEnabled(self.Properties.PoiName, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.PoiBg, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.PoiName, nameToShow, eUiTextSet_SetLocalized)
    self.ScriptedEntityTweener:Stop(self.Properties.PoiName)
    self.ScriptedEntityTweener:Stop(self.Properties.PoiBg)
    self.ScriptedEntityTweener:Play(self.Properties.PoiName, 0.3, {
      opacity = 1,
      textColor = self.poiNameColor,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:PlayC(self.Properties.CompassLines, 0.3, self.anim.openCompassLines1)
    self.ScriptedEntityTweener:PlayC(self.Properties.CompassLines, 1.5, self.anim.openCompassLines2, 0.3)
    local textWidth = UiTextBus.Event.GetTextWidth(self.Properties.PoiName)
    local bgPadding = 240
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.PoiBg, textWidth + bgPadding)
    if self.isObjectiveLocation then
      UiFaderBus.Event.SetFadeValue(self.Properties.PoiBg, 1)
    end
    self.ScriptedEntityTweener:Play(self.Properties.PoiBg, 0.3, {
      opacity = self.poiBgOpacity,
      imgColor = self.poiBgColor,
      ease = "QuadOut"
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.RevealFlash, true)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.RevealFlash, 0.2, {
      scaleX = 0,
      scaleY = 0,
      opacity = 0.6,
      imgColor = self.UIStyle.COLOR_WHITE
    }, self.anim.revealFlash1)
    self.ScriptedEntityTweener:PlayC(self.Properties.RevealFlash, 1.2, self.anim.revealFlash2, 0.2, function()
      UiElementBus.Event.SetIsEnabled(self.Properties.RevealFlash, false)
    end)
    self.ScriptedEntityTweener:PlayC(self.Properties.DistanceContainer, 0.3, self.anim.distanceToOpenPos)
    self.audioHelper:PlaySound(self.audioHelper.Compass_Open)
  else
    self.ScriptedEntityTweener:Stop(self.Properties.PoiName)
    self.ScriptedEntityTweener:Stop(self.Properties.PoiBg)
    self.ScriptedEntityTweener:PlayC(self.Properties.PoiName, 0.15, tweenerCommon.fadeOutQuadIn, 0, function()
      UiElementBus.Event.SetIsEnabled(self.Properties.PoiName, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PoiBg, false)
    end)
    self.ScriptedEntityTweener:PlayC(self.Properties.CompassLines, 0.3, self.anim.closeCompassLines)
    self.ScriptedEntityTweener:PlayC(self.Properties.PoiBg, 0.3, tweenerCommon.fadeOutQuadIn)
    self.ScriptedEntityTweener:PlayC(self.Properties.DistanceContainer, 0.3, self.anim.distanceToClosedPos)
    self.audioHelper:PlaySound(self.audioHelper.Compass_Close)
  end
  self.shownName = nameToShow
end
return CompassScreen

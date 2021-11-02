BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local PointOfInterestIcon = {
  Properties = {
    IconImage = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    },
    TextBG = {
      default = EntityId()
    },
    Pulse = {
      default = EntityId()
    },
    Content = {
      default = EntityId()
    },
    CompletedIcon = {
      default = EntityId()
    }
  },
  BEGIN_PULSE_RADIUS = 0,
  END_PULSE_RADIUS = 20,
  DEFAULT_TIMES_TO_PLAY = 20,
  FLYOUT_CONTEXT = "PointOfInterestIcon",
  DISCOVERED_ICON = "lyshineui/images/map/icon/icon_discovered.dds",
  empty_button_icon = "lyshineui/images/icons/misc/empty.dds",
  activeInnIconButtonPath = "lyshineui/images/map/icon/icon_inn_button.dds",
  inactiveInnIconButtonPath = "lyshineui/images/map/icon/icon_inn_inactive_button.dds",
  hourglassIcon = "lyshineui/images/icons/misc/icon_hourglass.dds",
  RECOMMENDED_FORMAT = "<font color = \"#76ffd7\">%s</font>",
  NOT_RECOMMENDED_FORMAT = "<font color = \"#ff9393\">%s</font>",
  currentZoom = 6,
  poiLevels = {},
  areaLevels = {},
  timer = 0,
  timerTick = 1,
  dungeonElapsedTimer = 0,
  dungeonEstimatedTimer = 0,
  fishingCrc = 1975517117,
  completedIcon = "lyshineui/images/map/icon/icon_poi_completed.dds",
  notCompletedIcon = "lyshineui/images/map/icon/icon_poi_not_completed.dds"
}
BaseElement:CreateNewElement(PointOfInterestIcon)
local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local EncounterDataHandler = RequireScript("LyShineUI._Common.EncounterDataHandler")
local hoverIntentDetector = RequireScript("LyShineUI._Common.HoverIntentDetector")
local Pulse = {}
function Pulse:Add(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.progress = o.progress or 0
  o.period = o.period or 1
  o.beginColor = o.beginColor or Color(1, 1, 1, 0.5)
  o.endColor = o.endColor or Color(1, 1, 1, 0)
  o.endRadius = o.endRadius or PointOfInterestIcon.END_PULSE_RADIUS
  o.beginRadius = o.beginRadius or PointOfInterestIcon.BEGIN_PULSE_RADIUS
  o.timesToPlay = o.timesToPlay or PointOfInterestIcon.DEFAULT_TIMES_TO_PLAY
  o.timesPlayed = 0
  return o
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
function PointOfInterestIcon:CreatePulse(beginColor, endColor, endRadius, timesToPlay)
  if not self.pulser then
    if beginColor then
      beginColor.a = 0.5
    end
    if endColor then
      endColor.a = 0
    end
    self.pulser = Pulse:Add({
      entity = self.Properties.Pulse,
      beginRadius = self.BEGIN_PULSE_RADIUS,
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
function PointOfInterestIcon:ClearPulse()
  if self.pulser then
    UiElementBus.Event.SetIsEnabled(self.Properties.Pulse, false)
    self.pulser = nil
  end
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function PointOfInterestIcon:OnInit()
  BaseElement.OnInit(self)
  self.iconTypes = mapTypes.iconTypes
  self.sourceTypes = mapTypes.sourceTypes
  self.panelTypes = mapTypes.panelTypes
  self.poiLevels = {minZoomLevel = 0.25, maxZoomLevel = 4}
  self.areaLevels = {minZoomLevel = 0.5, maxZoomLevel = 2}
  self.filterVisible = true
  UiInteractableBus.Event.SetHoverEnterEventHandlingScale(self.Properties.IconImage, Vector2(0.6, 0.6))
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.playerEntityId = playerEntityId
    end
  end)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompletedIcon, false)
end
function PointOfInterestIcon:OnTick(deltaTime, timePoint)
  if self.pulser and self.pulser:Update(deltaTime) then
    self:ClearPulse()
  end
end
function PointOfInterestIcon:OnHoverStart()
  if self.iconData.titleText and self.iconData.titleText ~= "" and self.iconData.descriptionText and self.iconData.descriptionText ~= "" then
    hoverIntentDetector:OnHoverDetected(self, self.ShowFlyoutMenu)
    self.originalScale = UiTransformBus.Event.GetScaleX(self.entityId)
    self.ScriptedEntityTweener:Play(self.entityId, 0.05, {
      scaleX = self.originalScale * 1.2,
      scaleY = self.originalScale * 1.2,
      ease = "QuadOut"
    })
    self.audioHelper:PlaySound(self.audioHelper.MapIconOnHover)
  end
end
function PointOfInterestIcon:OnHoverEnd()
  if self.originalScale then
    self.ScriptedEntityTweener:Play(self.entityId, 0.05, {
      scaleX = self.originalScale,
      scaleY = self.originalScale
    })
    self.originalScale = nil
  end
  hoverIntentDetector:StopHoverDetected(self)
end
function PointOfInterestIcon:ShowFlyoutMenu()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu.openingContext == self.FLYOUT_CONTEXT and flyoutMenu:ExitHover() then
    return
  end
  local rows = {}
  local headerText = self.iconData.titleText
  local subtext = self.iconData.descriptionText
  local recommendedLevel, minimumPlayers
  local backgroundImage = self.iconData.tooltipBackground
  local showDungeonInfo = false
  if self.iconData.isDiscovered and not self.iconData.isCharted then
    headerText = "@ui_uncharted_landmark"
    subtext = "@ui_uncharted_landmark_subtext"
  end
  if self.iconData.timeRemainingNode then
    local timeRemaining = self.dataLayer:GetDataFromNode(self.iconData.timeRemainingNode)
    if timeRemaining then
      if 0 < timeRemaining then
        local secondsRemaining = math.max(math.ceil(timeRemaining / 1000), 0)
        local _, _, minutes, seconds = timeHelpers:ConvertSecondsToDaysHoursMinutesSeconds(secondsRemaining)
        local timerText = string.format("%d:%02d", minutes, seconds)
        subtext = GetLocalizedReplacementText(subtext, {time = timerText})
      else
        subtext = self.iconData.descriptionTextTimerCompleted
      end
    else
      subtext = ""
      if self.iconData.descriptionTextTimerInit ~= nil then
        subtext = self.iconData.descriptionTextTimerInit
      end
    end
  end
  if self.iconData.isCharted then
    if self.minLevel ~= 0 then
      recommendedLevel = self.minLevel
    end
    if self.iconData.groupSize ~= 0 then
      minimumPlayers = EncounterDataHandler:GetGroupRange(self.iconData)
    end
    if self.iconData.gameModeId ~= nil and self.iconData.gameModeId ~= "" then
      local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
      local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(playerRootEntityId, self.iconData.gameModeId)
      recommendedLevel = gameModeData.requiredLevel
      minimumPlayers = gameModeData.minGroupSize
      backgroundImage = gameModeData.backgroundImagePath
      showDungeonInfo = true
    end
  end
  local openLocation = self.Properties.Text
  if self.hasMapIcon then
    openLocation = self.Properties.IconImage
  end
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_PointOfInterest,
    header = headerText,
    subtext = subtext,
    recommendedLevel = recommendedLevel,
    minimumPlayers = minimumPlayers,
    tooltipBackground = backgroundImage,
    showDungeonInfo = showDungeonInfo
  })
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
  flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
  flyoutMenu:SetOpenLocation(openLocation)
  flyoutMenu:SetRowData(rows)
  flyoutMenu:EnableFlyoutDelay(false)
  flyoutMenu:SetFadeInTime(0.05)
  flyoutMenu:SetFadeOutTime(0.05)
  flyoutMenu:SourceHoverOnly()
end
function PointOfInterestIcon:OnRightClick()
  DynamicBus.MagicMap.Broadcast.MapRightClick()
end
function PointOfInterestIcon:SetData(iconData)
  self.iconData = iconData
  if iconData.mapIconPath ~= "" then
    UiImageBus.Event.SetSpritePathname(self.Properties.IconImage, iconData.mapIconPath)
    if not iconData.keepText then
      UiElementBus.Event.DestroyElement(self.Properties.Text)
    end
    self.hasMapIcon = true
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.Text, iconData.titleText, eUiTextSet_SetLocalized)
    if iconData.textColor ~= nil then
      UiTextBus.Event.SetColor(self.Properties.Text, iconData.textColor)
    end
    if iconData.dungeonRegionText ~= nil then
      self.isDungeonRegionText = true
    end
    UiElementBus.Event.DestroyElement(self.Properties.IconImage)
    self.hasMapIcon = false
  end
  if self.Properties.TextBG:IsValid() and iconData.backgroundWidth then
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.TextBG, iconData.backgroundWidth)
  end
  if iconData.dataManager and iconData.dataManager.markersLayer then
    local sourceType = iconData.dataManager.markersLayer.sourceType
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.ZoomLevelMPP." .. sourceType, self.OnZoomLevelChanged)
  end
  self.minLevel = MapComponentBus.Broadcast.GetMedianPoiLevel(iconData.index)
  self:UpdateCurrentState(iconData.isDiscovered, iconData.isCharted)
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, iconData.anchors)
end
function PointOfInterestIcon:UpdateAnchors(anchors)
  self.iconData.anchors = anchors
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, anchors)
end
function PointOfInterestIcon:OnZoomLevelChanged(zoomLevel)
  if not zoomLevel or zoomLevel == self.currentZoom then
    return
  end
  self.currentZoom = zoomLevel
  self.scale = Math.Clamp(2 / self.currentZoom, 0.5, 1.5)
  self.dungeonRegionTextScale = self.currentZoom == 1 and 0.95 or 1.5
  local currentPoiLevel = self.iconData.isArea and self.areaLevels or self.poiLevels
  if currentPoiLevel then
    if zoomLevel < currentPoiLevel.minZoomLevel or zoomLevel > currentPoiLevel.maxZoomLevel then
      self.isVisible = false
    elseif self.isDungeonRegionText then
      UiTransformBus.Event.SetScale(self.entityId, Vector2(self.dungeonRegionTextScale, self.dungeonRegionTextScale))
      if self.currentZoom == 2 then
        self.isVisible = false
      else
        self.isVisible = true
      end
    else
      UiTransformBus.Event.SetScale(self.entityId, Vector2(self.scale, self.scale))
      self.isVisible = true
    end
  end
  self:UpdateVisibility()
end
function PointOfInterestIcon:UpdateCurrentState(isDiscovered, isCharted)
  self.iconData.isDiscovered = isDiscovered
  self.iconData.isCharted = isCharted
  local iconColor = self.UIStyle.COLOR_WHITE
  if self.iconData.isHotspot then
    local landmarkData = MapComponentBus.Broadcast.GetFirstLandmarkByType(self.iconData.index, eTerritoryLandmarkType_FishingHotspot)
    local hotspotLevel = FishingRequestsBus.Event.GetRequiredLevelByHotspotId(self.playerEntityId, Math.CreateCrc32(landmarkData.landmarkData))
    local playerLevel = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, self.fishingCrc)
    if self.playerEntityId and hotspotLevel <= playerLevel then
      self.isEnabled = true
    else
      self.isEnabled = false
      self:BusConnect(CategoricalProgressionNotificationBus, self.playerEntityId)
    end
  elseif isCharted or not self.iconData.dataManager.isPOIDiscoveryEnabled then
    self.isEnabled = true
    if self.hasMapIcon then
      UiImageBus.Event.SetSpritePathname(self.Properties.IconImage, self.iconData.mapIconPath)
    end
    local hasDynamicObjective = MapComponentBus.Broadcast.HasDynamicPoiObjective(self.iconData.index)
    if hasDynamicObjective then
      if self.hasMapIcon then
        UiElementBus.Event.SetIsEnabled(self.Properties.CompletedIcon, true)
        local isPoiComplete = MapComponentBus.Broadcast.IsDynamicPoiObjectiveComplete(self.iconData.index)
        if isPoiComplete then
          UiImageBus.Event.SetSpritePathname(self.Properties.CompletedIcon, self.completedIcon)
        else
          UiImageBus.Event.SetSpritePathname(self.Properties.CompletedIcon, self.notCompletedIcon)
        end
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.CompletedIcon, false)
      end
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.CompletedIcon, false)
    end
  elseif isDiscovered then
    self.isEnabled = true
    if self.hasMapIcon then
      UiImageBus.Event.SetSpritePathname(self.Properties.IconImage, self.DISCOVERED_ICON)
    end
  else
    self.isEnabled = false
  end
  self:UpdateVisibility()
end
function PointOfInterestIcon:OnCategoricalProgressionRankChanged(progressionId, oldRank, newRank, oldPoints)
  if progressionId == self.fishingCrc then
    self:UpdateCurrentState(self.iconData.isDiscovered, self.iconData.isCharted)
  end
end
function PointOfInterestIcon:SetFilterVisibility(isVisible)
  self.filterVisible = isVisible
  self:UpdateVisibility()
end
function PointOfInterestIcon:UpdateVisibility()
  UiElementBus.Event.SetIsEnabled(self.entityId, self.isEnabled and self.isVisible and self.filterVisible)
end
function PointOfInterestIcon:UpdateText(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, text, eUiTextSet_SetLocalized)
end
local popupId = "queueLeaveGroupId"
function PointOfInterestIcon:OnLeaveButton()
  if self.iconData.gameModeId ~= nil and self.iconData.gameModeId ~= "" then
    local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(playerRootEntityId, self.iconData.gameModeId)
    local message = GetLocalizedReplacementText("@ui_queue_leave_group_confirm_message", {
      minGroupSize = gameModeData.minGroupSize
    })
    if self.groupMemberCount > gameModeData.minGroupSize then
      message = "@ui_dungeon_leave_group_sufficient_members"
    end
    popupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_queue_leave_group_confirm_title", message, popupId, self, function(self, result, eventId)
      if popupId == eventId and result == ePopupResult_Yes then
        GroupsRequestBus.Broadcast.RequestLeaveGroup()
      end
    end)
  end
end
return PointOfInterestIcon

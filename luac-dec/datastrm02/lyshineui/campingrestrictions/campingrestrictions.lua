local CampingRestrictions = {
  Properties = {
    PoiCampingRestrictedIcon = {
      default = EntityId()
    },
    CampingAlertHolder = {
      default = EntityId()
    },
    CampingAlertText = {
      default = EntityId()
    },
    CampingAlertIcon = {
      default = EntityId()
    },
    CampingAlertHint = {
      default = EntityId()
    },
    CampBreakingFill = {
      default = EntityId()
    },
    DifficultiesContainer = {
      default = EntityId()
    },
    DifficultiesBg = {
      default = EntityId()
    },
    DifficultiesLabel = {
      default = EntityId()
    },
    DifficultyItems = {
      default = {
        EntityId()
      }
    }
  },
  STATE_NAME_BUILDMODE = 3406343509,
  campDestroyTime = nil,
  campDestroyWaitTime = nil,
  isCampDestroyInProcess = false,
  isCampNotificationShown = nil,
  isCampDestroyHoldSoundPlayable = nil,
  isAtWar = false,
  iconCampingRestricted = "lyShineui/images/campingrestrictions/campingrestricted.dds",
  iconCampingAllowed = "lyShineui/images/campingrestrictions/campingallowed.dds",
  iconCampingBreaking = "lyShineui/images/campingrestrictions/campingbreaking.dds"
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(CampingRestrictions)
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local CampCommon = RequireScript("LyShineUI.Inventory.CampCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local layouts = RequireScript("LyShineUI.Banner.Layouts")
local EncounterDataHandler = RequireScript("LyShineUI._Common.EncounterDataHandler")
function CampingRestrictions:OnInit()
  BaseScreen.OnInit(self)
  self:SetVisualElements()
  self:BusConnect(CryActionNotificationsBus, "makeCampOn")
  self:BusConnect(CryActionNotificationsBus, "makeCampOff")
  self:BusConnect(GroupsUINotificationBus)
  self:BusConnect(MapComponentEventBus)
  self:SetTerritoryNameVisible(false)
  self.difficultiesBgOut = self.ScriptedEntityTweener:CacheAnimation(0.2, {
    opacity = 0,
    scaleX = 0.5,
    ease = "QuadIn"
  })
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.CurrentAreaTerritory.SmallestContainingId", function(self, territoryId)
    if territoryId and territoryId ~= self.currentTerritoryId then
      if territoryId == 0 then
        self.currentTerritoryId = nil
      else
        self.currentTerritoryId = territoryId
      end
      self.territoryCanPlaceCamp = nil
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.CurrentAreaTerritory.CanPlaceCamp", function(self, canPlaceCamp)
    if canPlaceCamp ~= self.canPlaceCamp then
      self.canPlaceCamp = canPlaceCamp
      self:ShowCampingMessage()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HasSanctuary", function(self, isSanctuary)
    if isSanctuary ~= self.isSanctuary then
      self.isSanctuary = isSanctuary
      self:ShowCampingMessage()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Camping.IsUnlocked", function(self, isUnlocked)
    self.isCampingUnlocked = isUnlocked
  end)
  self.dataLayer:RegisterAndExecuteObserver(self, "Hud.LocalPlayer.Camping.GDEID", function(self, dataNode)
    CampCommon:UpdateCampInfo(self.dataLayer)
  end)
  self.dataLayer:RegisterAndExecuteObserver(self, "Hud.LocalPlayer.HomePoints.Count", function(self, dataNode)
    CampCommon:UpdateCampInfo(self.dataLayer)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.BuilderEntityId", function(self, data)
    self.builderId = data
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    if raidId and raidId:IsValid() then
      local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(raidId)
      if warDetails then
        local currentPhase = warDetails:GetWarPhase()
        if currentPhase == eWarPhase_PreWar then
          self.isAtWar = true
        end
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.playerEntityId = playerEntityId
    end
  end)
  AdjustElementToCanvasSize(self.entityId, self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
end
function CampingRestrictions:OnShutdown()
  self:ClearCampDestroyFlags()
  self:StopTicking()
  TimingUtils:StopDelay(self)
  BaseScreen.OnShutdown(self)
end
function CampingRestrictions:SetVisualElements()
  self.CampingAlertHint:SetKeybindMapping("makeCampOn")
  self.campDestroyTime = CampCommon:GetCampDestroyTime()
  self.poiTitleCharacterSpaceAnim = self.ScriptedEntityTweener:CacheAnimation(2.5, {textCharacterSpace = 300, ease = "QuadOut"})
  SetTextStyle(self.Properties.DifficultiesLabel, self.UIStyle.FONT_STYLE_BANNER_DIFFICULTY_LABEL)
end
function CampingRestrictions:ShowCampingMessage()
  if self.currentTerritoryId then
    local territoryCanPlaceCamp = self.canPlaceCamp and not self.isSanctuary
    if territoryCanPlaceCamp ~= self.territoryCanPlaceCamp then
      self.territoryCanPlaceCamp = territoryCanPlaceCamp
      self:SetTerritoryData(self.currentTerritoryId)
    end
  end
end
function CampingRestrictions:SetTerritoryData(territoryId)
  local territoryData = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(territoryId)
  local territoryName = territoryData.nameLocalizationKey
  local isPOI = territoryData.isPOI and not territoryData.isArea
  if territoryData and territoryData.HasPoiTag and territoryData:HasPoiTag(597936596) then
    local landmarkData = MapComponentBus.Broadcast.GetFirstLandmarkByType(territoryId, eTerritoryLandmarkType_FishingHotspot)
    level = FishingRequestsBus.Event.GetRequiredLevelByHotspotId(self.playerEntityId, Math.CreateCrc32(landmarkData.landmarkData))
    if level > CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, 1975517117) then
      return
    end
    local gatheringEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GatheringEntityId")
    local tool = UiGatheringComponentRequestsBus.Event.GetValidGatheringToolList(gatheringEntityId, "Fishing")
    local hasItem = tool and tool:IsValid()
    local bannerData = {
      AchievementCard1 = {
        title = territoryData.nameLocalizationKey,
        subject = hasItem and "" or "@ui_no_pole_instruction",
        icon = territoryData.mapIcon,
        iconScale = 2,
        iconColor = self.UIStyle.COLOR_WHITE,
        shouldPlayGlow = true,
        promptAction = hasItem and "fishing_activate" or nil,
        promptActionMap = "player",
        prompt = hasItem and "@ui_start_fishing_instruction" or nil,
        promptHighlight = true
      }
    }
    local bannerDisplayTime = 5
    local priority = 3
    DynamicBus.Banner.Broadcast.EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, bannerDisplayTime, nil, nil, false, priority)
    return
  end
  self.isCampingPoiRestricted = not self.territoryCanPlaceCamp
  if isPOI and not self.territoryCanPlaceCamp then
    local difficultyData = {}
    local poiLevel = MapComponentBus.Broadcast.GetMedianPoiLevel(territoryId)
    if poiLevel ~= 0 then
      if not self.playerLevel then
        self.playerLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
      end
      local isRecommendedLevel = poiLevel <= self.playerLevel
      table.insert(difficultyData, {
        text = GetLocalizedReplacementText("@objective_recommendedlevel", {
          level = tostring(poiLevel)
        }),
        isMet = isRecommendedLevel
      })
    end
    if territoryData.groupSize ~= 0 then
      local minGroup, maxGroup = EncounterDataHandler:GetGroupRange(territoryData)
      local isRecommendedGroup = EncounterDataHandler:IsRecommendedGroup(territoryData)
      local groupText = tostring(minGroup) .. " - " .. tostring(maxGroup)
      if minGroup == maxGroup then
        groupText = tostring(maxGroup)
      end
      if maxGroup <= 1 then
        groupText = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_solo")
      end
      table.insert(difficultyData, {
        text = GetLocalizedReplacementText("@objective_recommendedgroup", {group = groupText}),
        isMet = isRecommendedGroup
      })
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.DifficultiesContainer, false)
    if difficultyData and 0 < #difficultyData then
      local difficultyItemsShowing = 0
      local curX = UiTextBus.Event.GetTextWidth(self.Properties.DifficultiesLabel) + 12
      local margin = 36
      local allMet = true
      for i = 0, #self.DifficultyItems do
        local difficultyItem = self.DifficultyItems[i]
        local difficultyItemData = difficultyData[i + 1]
        if difficultyItemData then
          UiElementBus.Event.SetIsEnabled(self.Properties.DifficultyItems[i], true)
          UiTransformBus.Event.SetLocalPositionX(self.Properties.DifficultyItems[i], curX)
          difficultyItem:SetText(difficultyItemData.text)
          difficultyItem:SetIsMet(difficultyItemData.isMet)
          difficultyItemsShowing = difficultyItemsShowing + 1
          curX = curX + margin + difficultyItem:GetWidth()
          if not difficultyItemData.isMet then
            allMet = false
          end
        else
          UiElementBus.Event.SetIsEnabled(self.Properties.DifficultyItems[i], false)
        end
      end
      UiImageBus.Event.SetColor(self.Properties.DifficultiesBg, allMet and self.UIStyle.COLOR_GRAY_60 or self.UIStyle.COLOR_RED_DARKER)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.DifficultiesContainer, curX - margin)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.DifficultiesContainer, -1 * (curX - margin) / 2)
      self.difficultiesToShow = difficultyItemsShowing
      self.shouldShowDifficulties = true
    else
      self.shouldShowDifficulties = false
    end
    self:SetTerritoryCampingAlertVisible(false)
    TimingUtils:Delay(0.5, self, function()
      self:TryShowCampingMessage(territoryId)
    end)
  elseif self.territoryCanPlaceCamp then
    self:SetTerritoryNameVisible(false)
    UiTextBus.Event.SetTextWithFlags(self.Properties.CampingAlertText, "@ui_camping_available", eUiTextSet_SetLocalized)
    UiImageBus.Event.SetSpritePathname(self.Properties.CampingAlertIcon, self.iconCampingAllowed)
    if self.isCampingUnlocked and not self.isAtWar then
      self:SetCampingRestrictedIconVisible(false)
      self:SetTerritoryCampingAlertVisible(true)
    end
  end
end
function CampingRestrictions:TryShowCampingMessage(territoryId)
  if self.enqueuedMessage then
    return
  end
  if self.newlyChartedPOI and self.newlyChartedPOI == territoryId then
    self.newlyChartedPOI = nil
    return
  end
  self.enqueuedMessage = true
  local messageDelay = 9
  local messagePriority = 4
  self.enqueuedBannerId = DynamicBus.Banner.Broadcast.EnqueueExternalBanner(self, layouts.LAYOUT_ACHIEVEMENT, messageDelay, messagePriority, function(self)
    self:SetTerritoryNameVisible(true)
    if self.isCampingUnlocked and not self.isAtWar then
      self:SetCampingRestrictedIconVisible(true)
    end
  end, function(self)
    self.enqueuedMessage = false
  end)
  self.enqueuedBannerTerritoryId = territoryId
end
function CampingRestrictions:UpdateDiscoveredPOI(poiData)
  if poiData.isCharted then
    self.newlyChartedPOI = poiData.id
    if self.enqueuedBannerTerritoryId and self.enqueuedBannerTerritoryId == poiData.id and self.enqueuedBannerId then
      DynamicBus.Banner.Broadcast.RescindBanner(self.enqueuedBannerId)
    end
  end
end
function CampingRestrictions:SetTerritoryNameVisible(isVisible)
  self.ScriptedEntityTweener:Stop(self.Properties.DifficultiesBg)
  if isVisible then
    if self.shouldShowDifficulties then
      UiElementBus.Event.SetIsEnabled(self.Properties.DifficultiesContainer, true)
      self.ScriptedEntityTweener:Set(self.Properties.DifficultiesBg, {scaleX = 0, opacity = 0})
      self.ScriptedEntityTweener:PlayC(self.Properties.DifficultiesBg, 0.4, tweenerCommon.scaleXTo1)
      self.ScriptedEntityTweener:PlayC(self.Properties.DifficultiesBg, 0.2, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.DifficultiesBg, 0.2, tweenerCommon.opacityTo60, 0.2)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.DifficultiesLabel, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
      local firstDifficultyDelay = 0.2
      local difficultyStagger = 0.45
      for i = 0, self.difficultiesToShow - 1 do
        self.DifficultyItems[i]:AnimateIn(firstDifficultyDelay + i * difficultyStagger)
      end
      TimingUtils:Delay(4.5, self, function()
        self:SetTerritoryNameVisible(false)
      end)
    end
  elseif self.shouldShowDifficulties then
    self.ScriptedEntityTweener:PlayC(self.Properties.DifficultiesBg, 0.5, self.difficultiesBgOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.DifficultiesLabel, 0.3, tweenerCommon.fadeOutQuadIn)
    for i = 0, self.difficultiesToShow - 1 do
      self.DifficultyItems[i]:AnimateOut()
    end
  end
end
function CampingRestrictions:SetCampingRestrictedIconVisible(isVisible)
  self.ScriptedEntityTweener:Stop(self.Properties.PoiCampingRestrictedIcon)
  if isVisible then
    self.ScriptedEntityTweener:PlayC(self.Properties.PoiCampingRestrictedIcon, 0.5, tweenerCommon.fadeInQuadOut, 0.3, function()
      self.ScriptedEntityTweener:PlayC(self.Properties.PoiCampingRestrictedIcon, 2.5, tweenerCommon.fadeOutQuadOut, 2.5)
    end)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.PoiCampingRestrictedIcon, 1, tweenerCommon.fadeOutQuadOut, 0.3)
  end
end
function CampingRestrictions:SetTerritoryCampingAlertVisible(isVisible)
  if isVisible and not self.isCampingUnlocked then
    isVisible = false
  end
  TimingUtils:StopDelay(self)
  if isVisible then
    self.ScriptedEntityTweener:PlayC(self.Properties.CampingAlertText, 0.5, tweenerCommon.fadeInQuadOut, 0.3)
    self.ScriptedEntityTweener:PlayC(self.Properties.CampingAlertIcon, 0.5, tweenerCommon.fadeInQuadOut, 0.3)
    TimingUtils:Delay(3, self, function()
      self:SetTerritoryCampingAlertVisible(false)
    end)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.CampingAlertText, 0.5, tweenerCommon.fadeOutQuadOut, 0.3)
    self.ScriptedEntityTweener:PlayC(self.Properties.CampingAlertIcon, 0.5, tweenerCommon.fadeOutQuadOut, 0.3)
  end
end
function CampingRestrictions:SetTerritoryCampBreakingVisible(isVisible)
  if isVisible then
    UiImageBus.Event.SetSpritePathname(self.Properties.CampingAlertIcon, self.iconCampingBreaking)
    self.ScriptedEntityTweener:PlayC(self.Properties.CampingAlertIcon, 0.3, tweenerCommon.fadeInQuadOut, 0.2)
    self.ScriptedEntityTweener:PlayC(self.Properties.CampBreakingFill, 0.3, tweenerCommon.fadeInQuadOut, 0.2)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.CampingAlertIcon, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.CampBreakingFill, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.CampingAlertText, 0.3, tweenerCommon.fadeOutQuadOut)
  end
end
function CampingRestrictions:SetDestroyCampMeter(value)
  local currentFillAmount = UiImageBus.Event.GetFillAmount(self.Properties.CampBreakingFill)
  local newFillAmount = value / self.campDestroyTime
  UiImageBus.Event.SetFillAmount(self.Properties.CampBreakingFill, newFillAmount)
end
function CampingRestrictions:OnMakeCamp()
  LocalPlayerUIRequestsBus.Broadcast.RequestPlaceCamp()
end
function CampingRestrictions:OnBreakCamp()
  LocalPlayerUIRequestsBus.Broadcast.RequestDemolishCamp()
  CampCommon:UpdateCampInfo(self.dataLayer)
  self.audioHelper:PlaySound(self.audioHelper.OnCampBroken)
end
function CampingRestrictions:OnCryAction(actionName)
  local canPlaceOrDestroyCamp = CampCommon:GetCanPlaceOrDestroyCamp()
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  local isCampingLocked = not self.isCampingUnlocked
  local isCampingRestricted = isCampingLocked or self.isCampingPoiRestricted or self.isAtWar
  if actionName == "makeCampOn" then
    if isCampingLocked then
      if not self.isCampNotificationShown then
        self.isCampNotificationShown = true
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = "@ui_camping_error_not_unlocked"
        notificationData.callbackName = "OnCampNotificationComplete"
        notificationData.contextId = self.entityId
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
    elseif self.isAtWar then
      if not self.isCampNotificationShown then
        self.isCampNotificationShown = true
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = "@ui_cannot_place_camp_in_war"
        notificationData.callbackName = "OnCampNotificationComplete"
        notificationData.contextId = self.entityId
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
    elseif self.isCampingPoiRestricted then
      if not self.isCampNotificationShown then
        self.isCampNotificationShown = true
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = "@ui_camping_error_poi_restricted"
        notificationData.callbackName = "OnCampNotificationComplete"
        notificationData.contextId = self.entityId
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
    elseif canPlaceOrDestroyCamp then
      CampCommon:UpdateCampInfo(self.dataLayer)
      local isCampAvailable = CampCommon:GetIsCampAvailable()
      if isCampAvailable == false and currentState ~= self.STATE_NAME_BUILDMODE then
        if not self.isCampNotificationShown then
          self.isCampNotificationShown = true
          local message = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@fc_breakCampNotification", LyShineManagerBus.Broadcast.GetKeybind("makeCampOn", "ui"))
          local notificationData = NotificationData()
          notificationData.type = "Minor"
          notificationData.text = message
          notificationData.callbackName = "OnCampNotificationComplete"
          notificationData.contextId = self.entityId
          UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        end
        self:ClearCampDestroyFlags()
        self:StartTicking()
        self.isCampDestroyInProcess = true
      end
    end
  elseif actionName == "makeCampOff" and canPlaceOrDestroyCamp and isCampingRestricted == false then
    local isCampAvailable = CampCommon:GetIsCampAvailable()
    local isInOptions = currentState == 3493198471
    local isCurrentlyBuildingCamp = BuilderRequestBus.Event.IsBuildingCamp(self.builderId)
    if isCampAvailable and not isCurrentlyBuildingCamp and not isInOptions and not self.isAtWar then
      self:OnMakeCamp()
    elseif isCurrentlyBuildingCamp then
      LyShineManagerBus.Broadcast.ExitState(3406343509)
    end
    self:ClearCampDestroyFlags()
    self:StopTicking()
  else
    if actionName == "makeCampOff" and currentState == self.STATE_NAME_BUILDMODE then
      local isCurrentlyBuildingCamp = BuilderRequestBus.Event.IsBuildingCamp(self.builderId)
      if isCurrentlyBuildingCamp then
        LyShineManagerBus.Broadcast.ExitState(3406343509)
      end
    else
    end
  end
end
function CampingRestrictions:OnCampNotificationComplete()
  self.isCampNotificationShown = false
end
function CampingRestrictions:OnTick(deltaTime, timePoint)
  if self.isCampDestroyInProcess then
    self.campDestroyWaitTime = self.campDestroyWaitTime + deltaTime
    self:SetDestroyCampMeter(self.campDestroyWaitTime)
    if self.isCampDestroyHoldSoundPlayable ~= false then
      self.isCampDestroyHoldSoundPlayable = false
      self:SetTerritoryCampBreakingVisible(true)
      self.audioHelper:PlaySound(self.audioHelper.OnCampDestroyHold)
    end
    if self.campDestroyWaitTime >= self.campDestroyTime then
      self:OnBreakCamp()
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@fc_campBroken"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      self:ClearCampDestroyFlags()
    end
  end
end
function CampingRestrictions:StartTicking()
  if not self.tickBusHandler then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function CampingRestrictions:StopTicking()
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function CampingRestrictions:ClearCampDestroyFlags()
  self.campDestroyWaitTime = 0
  self.isCampDestroyHoldSoundPlayable = true
  self.isCampDestroyInProcess = false
  self:SetDestroyCampMeter(self.campDestroyWaitTime)
  self:SetTerritoryCampBreakingVisible(false)
end
function CampingRestrictions:OnSiegeWarfareStarted(warId)
  self.isAtWar = true
end
function CampingRestrictions:OnSiegeWarfareEnded(isWinner, resolutionPhaseEndTimePoint)
  self:OnSiegeWarfareCompleted()
end
function CampingRestrictions:OnSiegeWarfareCompleted(reason)
  self.isAtWar = false
  if reason == eGroupMemberRemovedReason_Kicked then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_kicked_from_army"
    notificationData.maximumDuration = 30
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function CampingRestrictions:OnTransitionIn(fromState, fromLevel, toState, toLevel)
end
function CampingRestrictions:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function CampingRestrictions:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.entityId, self.canvasId)
  end
end
return CampingRestrictions

local ObjectivesHud = {
  Properties = {
    ObjectivesContainer = {
      default = EntityId()
    },
    PinnedObjectives = {
      default = {
        EntityId()
      }
    },
    LocationObjective = {
      default = EntityId()
    },
    RecipeObjective = {
      default = EntityId()
    },
    LocationHeader = {
      default = EntityId()
    },
    LocationHeaderText = {
      default = EntityId()
    },
    LocationContainer = {
      default = EntityId()
    },
    PinnedHeader = {
      default = EntityId()
    },
    PinnedHeaderText = {
      default = EntityId()
    },
    PinnedContainer = {
      default = EntityId()
    },
    NearbyHeader = {
      default = EntityId()
    },
    NearbyHeaderText = {
      default = EntityId()
    },
    NearbyContainer = {
      default = EntityId()
    },
    HiddenContainer = {
      default = EntityId()
    }
  },
  pinnedObjectivesByIds = {},
  unusedPinnedObjectives = {},
  MAX_PINNED_RECIPES = 1,
  height = 0,
  MAX_CONTAINER_BOTTOM = 910,
  notificationsBottom = 0,
  queueHudBottom = 0,
  headerHeight = 36,
  isLoadingScreenShowing = nil,
  isShowingHeaders = false,
  isFtue = false,
  objectiveTypesToUseLocationSlot = {
    [eObjectiveType_Darkness_Minor] = true,
    [eObjectiveType_Darkness_Major] = true,
    [eObjectiveType_POI] = true,
    [eObjectiveType_Arena] = true,
    [eObjectiveType_Dungeon] = true,
    [eObjectiveType_DefendObject] = true
  },
  DEBUG = false,
  showDelay = 0,
  transitionTime = 0,
  isInOutpostRush = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(ObjectivesHud)
local ScriptActionQueue = RequireScript("LyShineUI._Common.ScriptActionQueue")
local ObjectiveTypeData = RequireScript("LyShineUI.Objectives.ObjectiveTypeData")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function ObjectivesHud:OnInit()
  BaseScreen.OnInit(self)
  self.nonUpdateScreens = {
    [2972535350] = true,
    [3349343259] = true,
    [2552344588] = true,
    [2478623298] = true,
    [3024636726] = true,
    [3777009031] = true,
    [1823500652] = true,
    [156281203] = true,
    [3901667439] = true,
    [3576764016] = true,
    [1967160747] = true,
    [3493198471] = true,
    [943559040] = true,
    [3406343509] = true,
    [2477632187] = true,
    [1809891471] = true,
    [2609973752] = true,
    [3211015753] = true,
    [849925872] = true,
    [640726528] = true,
    [3370453353] = true,
    [3211015753] = true,
    [2896319374] = true,
    [828869394] = true,
    [2640373987] = true,
    [2437603339] = true,
    [1319313135] = true,
    [1468490675] = true,
    [1101180544] = true,
    [1643432462] = true,
    [3664731564] = true,
    [4119896358] = true,
    [663562859] = true,
    [1634988588] = true,
    [319051850] = true,
    [3940276153] = true,
    [921202721] = true,
    [4283914359] = true
  }
  self.notificationIdsToData = {
    [4247229705] = {
      title = "@objective_onboarding_tools_title",
      text = "@objective_onboarding_tools_message"
    },
    [4159155657] = {
      title = "@objective_onboarding_complete_title",
      text = "@objective_onboarding_complete_message"
    }
  }
  self.defaultY = UiTransformBus.Event.GetLocalPositionY(self.ObjectivesContainer)
  self.changeYScreens = {}
  self.showControlsScreens = {
    [3766762380] = true
  }
  self.darkBgScreens = {
    [3766762380] = true
  }
  self.addActionQueue = ScriptActionQueue:QueueCreate()
  self.removeActionQueue = ScriptActionQueue:QueueCreate()
  self.numNotificationsShowing = 0
  DynamicBus.NotificationsDisplayBus.Connect(self.entityId, self)
  self.lastToScreen = {value = 0}
  DynamicBus.QueueHudDisplayBus.Connect(self.entityId, self)
  for i = 0, #self.Properties.PinnedObjectives do
    self.PinnedObjectives[i]:SetUpdatedCallback(self.UpdateObjectivePositions, self)
    table.insert(self.unusedPinnedObjectives, self.PinnedObjectives[i])
  end
  self.LocationObjective:SetUpdatedCallback(self.UpdateObjectivePositions, self)
  self.RecipeObjective:SetUpdatedCallback(self.UpdateObjectivePositions, self)
  self:BusConnect(LoadScreenNotificationBus, self.entityId)
  self:UpdateScreenState()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      self.rootEntityId = rootEntityId
      self:BusDisconnect(self.participantBusHandler)
      self.participantBusHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, rootEntityId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "ObjectivesComponentRequestBus.IsConnected", self.OnObjectivesBusConnected)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ObjectiveEntityId", self.OnObjectiveEntityIdChanged)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    self:RefreshDescriptions()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Siege.SiegePhase", function(self, isInSiege)
    self.isInWarSiegePhase = isInSiege
    self:UpdateScreenState()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, factionType)
    ObjectiveTypeData:SetFaction(factionType)
  end)
  self.nearbySortingEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.objectives-enableNearbySorting")
  self.LocationObjective:SetStyle(self.LocationObjective.OBJECTIVE_STYLE_LARGE)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
  SetTextStyle(self.Properties.LocationHeaderText, self.UIStyle.FONT_STYLE_SUBHEADER)
  SetTextStyle(self.Properties.PinnedHeaderText, self.UIStyle.FONT_STYLE_SUBHEADER)
  SetTextStyle(self.Properties.NearbyHeaderText, self.UIStyle.FONT_STYLE_SUBHEADER)
end
function ObjectivesHud:OnShutdown()
  DynamicBus.NotificationsDisplayBus.Disconnect(self.entityId, self)
  DynamicBus.QueueHudDisplayBus.Disconnect(self.entityId, self)
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
  BaseScreen.OnShutdown(self)
end
function ObjectivesHud:OnObjectivesBusConnected(isConnected)
  if isConnected == nil then
    return
  end
  self.objectivesBusConnected = isConnected
  if isConnected and self.enableObjectives then
    self:OnObjectiveSortingChanged()
  end
end
function ObjectivesHud:OnObjectiveEntityIdChanged(objectiveEntityId)
  if objectiveEntityId == nil or objectiveEntityId == self.objectiveEntityId then
    return
  end
  self.objectiveEntityId = objectiveEntityId
  self.enableObjectives = false
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-objectives") then
    self.enableObjectives = true
  end
  if self.enableObjectives then
    self:BusDisconnect(self.objectivesComponentBusHandler)
    self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, self.objectiveEntityId)
    if self.objectivesBusConnected then
      self:OnObjectiveSortingChanged()
    end
  end
end
function ObjectivesHud:OnObjectiveSortingChanged()
  self.removeActionQueue:Add(self, function()
    self:SetIsEnqueuing(true)
    self:ClearUntrackedObjectives()
    self:SetIsEnqueuing(false)
  end)
  self.addActionQueue:Add(self, function()
    self:SetIsEnqueuing(true)
    local trackedObjectiveList = ObjectivesComponentRequestBus.Event.GetTrackedObjectives(self.objectiveEntityId)
    for i = 1, #trackedObjectiveList do
      local objectiveType = ObjectiveRequestBus.Event.GetType(trackedObjectiveList[i])
      if not self.objectiveTypesToUseLocationSlot[objectiveType] then
        self:SetPinnedObjective(self.PinnedContainer, i, trackedObjectiveList[i])
      end
    end
    if self.nearbySortingEnabled then
      local nearbyObjectiveList = ObjectivesComponentRequestBus.Event.GetNearbyObjectives(self.objectiveEntityId)
      for i = 1, #nearbyObjectiveList do
        self:SetPinnedObjective(self.NearbyContainer, i, nearbyObjectiveList[i])
      end
    end
    local hasLocationObjective = false
    for i = 1, #trackedObjectiveList do
      local objectiveType = ObjectiveRequestBus.Event.GetType(trackedObjectiveList[i])
      if self.objectiveTypesToUseLocationSlot[objectiveType] and not hasLocationObjective then
        self.locationObjectiveId = trackedObjectiveList[i]
        self:SetPinnedObjective(self.Properties.LocationContainer, 1, self.locationObjectiveId, self.LocationObjective)
        hasLocationObjective = true
      elseif self.objectiveTypesToUseLocationSlot[objectiveType] then
        Debug.Log("[WARNING] Attemping to pin multiple location objectives. ObjectiveId: " .. trackedObjectiveList[i]:ToString())
      end
    end
    self:UpdateObjectivePositions()
    self:SetIsEnqueuing(false)
  end)
  self.addActionQueue:DoAll()
  self.removeActionQueue:DoAll()
end
function ObjectivesHud:SetPinnedObjective(containerId, index, objectiveId, pinnedObjective)
  if not pinnedObjective then
    local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveId)
    if objectiveType == eObjectiveType_Crafting or objectiveType == eObjectiveType_DynamicPOI then
      pinnedObjective = self.RecipeObjective
    else
      pinnedObjective = self.pinnedObjectivesByIds[objectiveId:ToString()] or table.remove(self.unusedPinnedObjectives, 1)
    end
  end
  if not pinnedObjective then
    self.waitingForFreePinnedObjective = true
    return
  end
  self.pinnedObjectivesByIds[objectiveId:ToString()] = pinnedObjective
  local entityInTargetIndex = UiElementBus.Event.GetChild(containerId, index - 1)
  if pinnedObjective.entityId == entityInTargetIndex and pinnedObjective:GetObjectiveId() == objectiveId then
    return
  end
  if pinnedObjective.entityId ~= entityInTargetIndex then
    UiElementBus.Event.Reparent(pinnedObjective.entityId, containerId, entityInTargetIndex)
  end
  if pinnedObjective:GetObjectiveId() ~= objectiveId then
    pinnedObjective:SetObjectiveId(objectiveId)
    if containerId == self.Properties.LocationContainer and pinnedObjective == self.LocationObjective then
      self.shouldAnimateInLocationObjective = true
      UiElementBus.Event.SetIsEnabled(self.LocationObjective.entityId, false)
    else
      UiElementBus.Event.SetIsEnabled(pinnedObjective.entityId, true)
      self:SetIsEnqueuing(true)
      pinnedObjective:AnimateIn(function()
        self:SetIsEnqueuing(false)
      end, self.showDelay - self.transitionTime, true)
    end
  end
end
function ObjectivesHud:ClearObjectivesAfterIndex(containerId, index)
  local children = UiElementBus.Event.GetChildren(containerId)
  if index >= #children then
    return
  end
  for i = index + 1, #children do
    if children[i] then
      local pinnedObjective = self.registrar:GetEntityTable(children[i])
      self:RemovePinnedObjective(pinnedObjective)
    end
  end
end
function ObjectivesHud:RemovePinnedObjective(pinnedObjective)
  local objectiveId = pinnedObjective:GetObjectiveId()
  if not objectiveId then
    if pinnedObjective ~= self.RecipeObjective and pinnedObjective ~= self.LocationObjective then
      local addToUnused = true
      for _, unusedPinnedObjective in pairs(self.unusedPinnedObjectives) do
        if pinnedObjective == unusedPinnedObjective then
          addToUnused = false
          break
        end
      end
      if addToUnused then
        table.insert(self.unusedPinnedObjectives, pinnedObjective)
      end
    end
    return
  end
  local objectiveIdString = objectiveId:ToString()
  self.pinnedObjectivesByIds[objectiveIdString] = nil
  if pinnedObjective ~= self.RecipeObjective and pinnedObjective ~= self.LocationObjective then
    table.insert(self.unusedPinnedObjectives, pinnedObjective)
  end
  self.removeActionQueue:Add(self, function()
    self:SetIsEnqueuing(true)
    if pinnedObjective:GetObjectiveId() ~= objectiveId then
      self:SetIsEnqueuing(false)
      return
    end
    pinnedObjective:AnimateOut(function()
      local shouldRunSortingChanged = false
      pinnedObjectiveId = pinnedObjective:GetObjectiveId()
      if pinnedObjective and self.pinnedObjectivesByIds[pinnedObjectiveId:ToString()] then
        shouldRunSortingChanged = true
      end
      UiElementBus.Event.Reparent(pinnedObjective.entityId, self.Properties.HiddenContainer, EntityId())
      pinnedObjective:SetObjectiveId(nil)
      if shouldRunSortingChanged then
        self:OnObjectiveSortingChanged()
      else
        self:UpdateObjectivePositions()
      end
      self:SetIsEnqueuing(false)
    end)
  end)
end
function ObjectivesHud:ClearUntrackedObjectives()
  local trackedObjectiveList = ObjectivesComponentRequestBus.Event.GetTrackedObjectives(self.objectiveEntityId)
  local nearbyObjectiveList = self.nearbySortingEnabled and ObjectivesComponentRequestBus.Event.GetNearbyObjectives(self.objectiveEntityId) or {}
  local removedAnObjective = false
  for objectiveId, pinnedObjective in pairs(self.pinnedObjectivesByIds) do
    if pinnedObjective ~= self.LocationObjective then
      local isStillTracked = false
      for _, list in ipairs({trackedObjectiveList, nearbyObjectiveList}) do
        for i = 1, #list do
          if list[i]:ToString() == objectiveId then
            isStillTracked = true
            break
          end
        end
        if isStillTracked then
          break
        end
      end
      if not isStillTracked then
        removedAnObjective = true
        self:RemovePinnedObjective(pinnedObjective)
      end
    end
  end
  if self.waitingForFreePinnedObjective and removedAnObjective then
    self.waitingForFreePinnedObjective = false
    self:OnObjectiveSortingChanged()
  end
end
function ObjectivesHud:UpdateObjectivePositions(skipAnimation)
  local animTime = 0.3
  local skipEntityId
  if skipAnimation == true then
    animTime = 0
  elseif skipAnimation ~= nil then
    skipEntityId = skipAnimation
  end
  local containerEntityIds = {
    self.Properties.LocationContainer,
    self.Properties.PinnedContainer,
    self.Properties.NearbyContainer
  }
  local headerEntityIds = {
    self.Properties.LocationHeader,
    self.Properties.PinnedHeader,
    self.Properties.NearbyHeader
  }
  local containerY = 0
  local lowestNonEmptyContainer
  for i, container in ipairs(containerEntityIds) do
    local pinnedObjectiveEntities = UiElementBus.Event.GetChildren(container)
    if 0 < #pinnedObjectiveEntities then
      lowestNonEmptyContainer = container
    end
  end
  for i, container in ipairs(containerEntityIds) do
    local pinnedObjectiveEntities = UiElementBus.Event.GetChildren(container)
    local y = 0
    local margin = 10
    if 0 < #pinnedObjectiveEntities then
      for j = 1, #pinnedObjectiveEntities do
        local entityId = pinnedObjectiveEntities[j]
        if UiElementBus.Event.IsEnabled(entityId) or container == self.Properties.LocationContainer and self.shouldAnimateInLocationObjective then
          if entityId ~= skipEntityId then
            self.ScriptedEntityTweener:Play(entityId, animTime, {y = y, ease = "QuadOut"})
          else
            UiTransformBus.Event.SetLocalPositionY(entityId, y)
          end
          local objectiveTable = self.registrar:GetEntityTable(entityId)
          objectiveTable:RefreshObjectiveIcon()
          local objectiveHeight = objectiveTable:GetHeight() or 0
          y = y + margin + objectiveHeight
        end
      end
      do
        local header = headerEntityIds[i]
        if self.isShowingHeaders then
          if not UiElementBus.Event.IsEnabled(header) then
            UiElementBus.Event.SetIsEnabled(header, true)
            self.ScriptedEntityTweener:PlayFromC(header, animTime / 2, {opacity = 0, y = containerY}, tweenerCommon.fadeInQuadOut)
          else
            self.ScriptedEntityTweener:Play(header, animTime, {y = containerY, ease = "QuadOut"})
          end
          containerY = containerY + self.headerHeight
        elseif UiElementBus.Event.IsEnabled(header) then
          self.ScriptedEntityTweener:PlayC(header, animTime / 2, tweenerCommon.fadeOutQuadOut, 0, function()
            UiElementBus.Event.SetIsEnabled(header, false)
          end)
        end
        if container == lowestNonEmptyContainer and self.shouldAnimateInLocationObjective then
          self.ScriptedEntityTweener:Play(container, animTime, {
            y = containerY,
            ease = "QuadOut",
            onComplete = function()
              self.shouldAnimateInLocationObjective = false
              local locObjectiveId = self.LocationObjective:GetObjectiveId()
              if locObjectiveId and self.locationObjectiveId and locObjectiveId.value == self.locationObjectiveId.value then
                UiElementBus.Event.SetIsEnabled(self.LocationObjective.entityId, true)
                self:SetIsEnqueuing(true)
                self.LocationObjective:AnimateIn(function()
                  self:SetIsEnqueuing(false)
                end, self.showDelay - self.transitionTime, true)
              end
            end
          })
        else
          self.ScriptedEntityTweener:Play(container, animTime, {y = containerY, ease = "QuadOut"})
        end
        containerY = containerY + y
      end
    else
      do
        local header = headerEntityIds[i]
        if UiElementBus.Event.IsEnabled(header) then
          self.ScriptedEntityTweener:PlayC(header, animTime / 2, tweenerCommon.fadeOutQuadOut, 0, function()
            UiElementBus.Event.SetIsEnabled(header, false)
          end)
        end
      end
    end
  end
  self.height = containerY
end
function ObjectivesHud:SetHeadersVisible(visible)
  if self.isShowingHeaders == visible then
    return
  end
  self.isShowingHeaders = visible
  self:UpdateObjectivePositions()
end
function ObjectivesHud:OnTrackedObjectiveAdded(objectiveId)
  if objectiveId == nil then
    return
  end
  local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveId)
  if objectiveType == eObjectiveType_Darkness_Minor then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Darkness, self.audioHelper.MusicState_Darkness_Minor)
  elseif objectiveType == eObjectiveType_Darkness_Major then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Darkness, self.audioHelper.MusicState_Darkness_Major)
  elseif objectiveType == eObjectiveType_Arena then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.audioHelper.MusicState_Arena)
  end
end
function ObjectivesHud:OnTrackedObjectiveRemoved(objectiveId)
  local objectiveIdString = objectiveId:ToString()
  local pinnedObjective = self.pinnedObjectivesByIds[objectiveIdString]
  if pinnedObjective ~= nil then
    local isLocationObjective = self.locationObjectiveId and objectiveId.value == self.locationObjectiveId.value
    if not isLocationObjective then
      return
    end
    self:SetIsEnqueuing(true)
    pinnedObjective:AnimateOut(function()
      self.pinnedObjectivesByIds[objectiveIdString] = nil
      UiElementBus.Event.Reparent(pinnedObjective.entityId, self.HiddenContainer, EntityId())
      self:UpdateObjectivePositions()
      self:SetIsEnqueuing(false)
    end)
    self.locationObjectiveId = nil
    self.LocationObjective:SetObjectiveId(nil)
  else
    self:SetIsEnqueuing(false)
  end
end
function ObjectivesHud:OnObjectiveCompleted(objectiveId)
  local objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(objectiveId)
  if not objectiveData then
    return
  end
  local notificationData = self.notificationIdsToData[objectiveData.successGameEventId]
  if notificationData then
    self.removeActionQueue:Add(self, self.ShowNotification, notificationData)
  end
end
function ObjectivesHud:ShowNotification(specialNotificationData)
  local notificationTime = 7
  local notificationData = NotificationData()
  notificationData.type = "Generic"
  notificationData.title = specialNotificationData.title
  notificationData.text = specialNotificationData.text
  notificationData.contextId = self.entityId
  notificationData.maximumDuration = notificationTime
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  self.removeActionQueue:DoNext()
end
function ObjectivesHud:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.lastToScreen = toState
  self:UpdateScreenState()
end
function ObjectivesHud:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self.lastToScreen = toState
  if fromState == 1101180544 then
    self.showDelay = 1
    self.transitionTime = self.fadeTime
  else
    self.showDelay = 0
    self.transitionTime = 0
  end
  self:UpdateScreenState(self.showDelay)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function ObjectivesHud:UpdateScreenState(showDelay)
  if self.isLoadingScreenShowing ~= false and not self.DEBUG then
    self.forceEnqueuing = true
    self:SetIsEnqueuing(true)
    return
  end
  local newY = math.max(self.changeYScreens[self.lastToScreen] or self.defaultY, math.max(self.notificationsBottom, self.queueHudBottom))
  local shouldEnqueue = self.nonUpdateScreens[self.lastToScreen] or newY + self.height > self.MAX_CONTAINER_BOTTOM or self.isInWarSiegePhase or self.isInOutpostRush
  local shouldShowControls = self.showControlsScreens[self.lastToScreen]
  local shouldUseDarkBg = self.darkBgScreens[self.lastToScreen]
  local shouldAnimate = false
  local shouldUpdatePinnedObjectives = false
  local shouldUpdatePositions = false
  if shouldEnqueue ~= self.forceEnqueuing then
    self.forceEnqueuing = shouldEnqueue
    self:SetIsEnqueuing(shouldEnqueue)
    shouldAnimate = true
    shouldUpdatePinnedObjectives = true
  end
  if newY ~= self.currentY then
    self.currentY = newY
    shouldAnimate = true
  end
  if shouldShowControls ~= self.isShowingControls then
    self.isShowingControls = shouldShowControls or false
    self.isShowingHeaders = shouldShowControls or false
    shouldUpdatePinnedObjectives = true
    shouldAnimate = true
    shouldUpdatePositions = true
  end
  if shouldUseDarkBg ~= self.isUsingDarkBg then
    self.isUsingDarkBg = shouldUseDarkBg or false
    shouldUpdatePinnedObjectives = true
  end
  if showDelay == nil then
    showDelay = 0
  end
  if shouldAnimate then
    self.fadeTime = 0.25
    local opacity = self.forceEnqueuing and 0 or 1
    if not self.forceEnqueuing then
      UiElementBus.Event.SetIsEnabled(self.Properties.ObjectivesContainer, true)
    end
    self.ScriptedEntityTweener:Play(self.Properties.ObjectivesContainer, self.fadeTime, {
      opacity = opacity,
      ease = "QuadOut",
      delay = showDelay
    })
    self.ScriptedEntityTweener:Play(self.Properties.ObjectivesContainer, self.fadeTime, {
      y = self.currentY,
      x = self.isShowingControls and -70 or -40,
      ease = "QuadOut",
      onComplete = function()
        if self.forceEnqueuing then
          UiElementBus.Event.SetIsEnabled(self.Properties.ObjectivesContainer, false)
        end
      end
    })
  end
  if shouldUpdatePinnedObjectives then
    for objectiveIdString, pinnedObjective in pairs(self.pinnedObjectivesByIds) do
      pinnedObjective:SetIsEnqueuing(self.forceEnqueuing)
      pinnedObjective:SetIsShowingControls(self.isShowingControls)
      pinnedObjective:SetIsUsingDarkBg(self.isUsingDarkBg)
    end
  end
  if shouldUpdatePositions then
    self:UpdateObjectivePositions()
  end
end
function ObjectivesHud:RefreshDescriptions()
  for objectiveId, pinnedObjective in pairs(self.pinnedObjectivesByIds) do
    pinnedObjective:RefreshDescriptions()
  end
end
function ObjectivesHud:SetIsEnqueuing(shouldEnqueue)
  if self.forceEnqueuing == true and shouldEnqueue == false then
    return
  end
  self.isEnqueuing = shouldEnqueue
  self.addActionQueue:SetIsEnqueuing(self.isEnqueuing)
  self.removeActionQueue:SetIsEnqueuing(self.isEnqueuing)
  if not self.isEnqueuing then
    if #self.removeActionQueue.queue == 0 then
      self.addActionQueue:DoNext()
    else
      self.removeActionQueue:DoNext()
    end
  end
end
function ObjectivesHud:OnNotificationCountChanged(num, notificationsBottom)
  self.numNotificationsShowing = num
  self.notificationsBottom = notificationsBottom
  self:UpdateScreenState()
end
function ObjectivesHud:OnQueueHudBottomChanged(queueHudBottom)
  self.queueHudBottom = queueHudBottom
  self:UpdateScreenState()
end
function ObjectivesHud:OnLoadingScreenDismissed()
  local updateDelay = 0.75
  self.ScriptedEntityTweener:Play(self.Properties.ObjectivesContainer, updateDelay, {
    x = 0,
    onComplete = function()
      self.isLoadingScreenShowing = false
      self:UpdateScreenState()
    end
  })
end
function ObjectivesHud:SetElementVisibleForFtue(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:PlayC(self.Properties.ObjectivesContainer, self.UIStyle.DURATION_FTUE_OUTRO, tweenerCommon.fadeInQuadOut)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.ObjectivesContainer, self.UIStyle.DURATION_FTUE_OUTRO, tweenerCommon.fadeOutQuadOut)
  end
end
function ObjectivesHud:SetElementVisibleForTutorial(isVisible)
  self:SetElementVisibleForFtue(isVisible)
end
function ObjectivesHud:OnEnteredGameMode(gameModeEntityId, gameModeId)
  if gameModeId ~= 2444859928 then
    return
  end
  self.gameModeEntityId = gameModeEntityId
  self.isInOutpostRush = true
  self:UpdateScreenState()
end
function ObjectivesHud:OnExitedGameMode(gameModeEntityId)
  if gameModeEntityId == self.gameModeEntityId then
    self.gameModeEntityId = nil
    self.isInOutpostRush = false
    self:UpdateScreenState()
  end
end
return ObjectivesHud

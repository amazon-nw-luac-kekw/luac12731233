local QueueHud = {
  Properties = {
    MasterContainer = {
      default = EntityId()
    },
    ExpandedContainer = {
      default = EntityId()
    },
    ExpandedIcon = {
      default = EntityId()
    },
    NameText = {
      default = EntityId()
    },
    WaitingText = {
      default = EntityId()
    },
    ElapsedLabel = {
      default = EntityId()
    },
    ElapsedTimeText = {
      default = EntityId()
    },
    ExpectedLabel = {
      default = EntityId()
    },
    ExpectedTimeText = {
      default = EntityId()
    },
    CollapseButton = {
      default = EntityId()
    },
    LeaveGroupButton = {
      default = EntityId()
    },
    QueueProgress = {
      default = EntityId()
    },
    CollapsedContainer = {
      default = EntityId()
    },
    HoverHighlight = {
      default = EntityId()
    },
    CollapsedIcon = {
      default = EntityId()
    },
    SpinnerForeground = {
      default = EntityId()
    }
  },
  bottomPadding = 40,
  timer = 0,
  timerTick = 1,
  MIN_DUNGEON_WARN_TIME = 10,
  screenStatesToDisable = {
    [2478623298] = true,
    [3901667439] = true,
    [3777009031] = true,
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
  GAMEMODE_DUNGEON = 1073356688
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(QueueHud)
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
function QueueHud:OnInit()
  BaseScreen.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.Properties.ExpectedLabel, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ExpectedTimeText, false)
  self.CollapseButton:SetCallback(self.OnCollapse, self)
  self.CollapseButton:SetImageType(self.CollapseButton.ButtonTypes.collapse)
  self.LeaveGroupButton:SetText("@ui_queue_leave_group")
  self.LeaveGroupButton:SetCallback(self.OnLeaveGroup, self)
  self.expandedContainerY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ExpandedContainer)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootPlayerId)
    self.rootPlayerId = rootPlayerId
    self:BusDisconnect(self.participantBusHandler)
    if not rootPlayerId then
      return
    end
    self.participantBusHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, rootPlayerId)
    self:TrySetDungeonMap()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.GameModeParticipantBus.IsReady", function(self, isReady)
    self.gameModeParticipantBusIsReady = isReady
    if not isReady then
      return
    end
    self:TrySetDungeonMap()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.InitCount", function(self, count)
    if not count or count < 2 then
      return
    end
    self.mapIsReady = true
    self:TrySetDungeonMap()
  end)
  self:BusConnect(UIArenaAndDungeonEventBus)
  self.groupDungeonInstanceState = DungeonInstanceState_NoDungeon
  self.isEligible = false
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ObjectiveEntityId", function(self, objectiveEntityId)
    self.objectiveEntityId = objectiveEntityId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.Id", function(self, groupId)
    if not groupId then
      return
    end
    if self.groupDataEventHandler then
      self:BusDisconnect(self.groupDataEventHandler)
    end
    self.groupId = groupId
    if self.groupId and self.groupId:IsValid() then
      self.groupDataEventHandler = self:BusConnect(GroupDataNotificationBus, self.groupId)
      GroupDataRequestBus.Event.NotifyConnectedForDungeonState(self.groupId)
    else
      self:OnDungeonStateChanged(DungeonInstanceState_NoDungeon)
    end
  end)
  DynamicBus.DungeonEnterScreenBus.Connect(self.entityId, self)
end
function QueueHud:OnShutdown()
  BaseScreen.OnShutdown(self)
  if self.timelineHighlight then
    self.ScriptedEntityTweener:TimelineDestroy(self.timelineHighlight)
    self.timelineHighlight = nil
  end
  if self.dungeonFastTravelKeyHandler then
    self:BusDisconnect(self.dungeonFastTravelKeyHandler)
    self.dungeonFastTravelKeyHandler = nil
  end
  DynamicBus.DungeonEnterScreenBus.Disconnect(self.entityId, self)
end
function QueueHud:SetTicking(isTicking)
  if isTicking then
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  else
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function QueueHud:OnTick(deltaTime)
  self.timer = self.timer + deltaTime
  if self.timer >= self.timerTick then
    self.timer = self.timer - self.timerTick
    local now = TimeHelpers:ServerNow()
    local elapsedTime = now:SubtractSeconds(self.startTime):ToSeconds()
    if self.elapseTime == nil or self.elapseTime ~= elapsedTime then
      self.elapseTime = elapsedTime
      local durationText = TimeHelpers:ConvertToShorthandString(elapsedTime, true)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ElapsedTimeText, durationText, eUiTextSet_SetLocalized)
    end
    if self.gameModeId == GameModeCommon.GAMEMODE_OUTPOST_RUSH and self.numPlayers then
      local numPlayersText = string.format("%d/%d", self.numPlayers, self.totalPlayers)
      UiTextBus.Event.SetTextWithFlags(self.Properties.QueueProgress, numPlayersText, eUiTextSet_SetAsIs)
      UiElementBus.Event.SetIsEnabled(self.Properties.QueueProgress, true)
    end
  end
end
function QueueHud:EvaluateQueueHud()
  local canFastTravelToDungeon = self:CanFastTravelToDungeon()
  local showDungeonQueueHud = self.groupDungeonInstanceState ~= DungeonInstanceState_NoDungeon and self.groupDungeonInstanceState ~= DungeonInstanceState_Finished
  UiElementBus.Event.SetIsEnabled(self.entityId, showDungeonQueueHud)
  if canFastTravelToDungeon then
    if self.readyNotificationId then
      UiNotificationsBus.Broadcast.RescindNotification(self.readyNotificationId, true, true)
      self.readyNotificationId = nil
    end
    if self.groupDungeonInstanceState == DungeonInstanceState_Entered then
      local notificationData = NotificationData()
      notificationData.type = "DungeonInvite"
      notificationData.title = "@ui_dungeon_opened_title"
      notificationData.text = "@ui_dungeon_enter_info_entered"
      notificationData.hasChoice = true
      notificationData.acceptTextOverride = "@dungeon_enter"
      notificationData.declineTextOverride = "@ui_dismiss"
      notificationData.contextId = self.entityId
      notificationData.callbackName = "OnTeleportToDungeonNotificationChoice"
      self.readyNotificationId = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  end
  if self.groupDungeonInstanceState == DungeonInstanceState_Queued then
    self:OnQueued()
    self:SetTicking(true)
  else
    self:OnRemovedFromQueue()
    self:SetTicking(false)
  end
end
function QueueHud:OnQueued()
  self:SetQueueHudVisible(true)
end
function QueueHud:OnRemovedFromQueue()
  self:SetQueueHudVisible(false)
end
function QueueHud:OnDungeonStateChanged(instanceState)
  if self.gameModeId == GameModeCommon.GAMEMODE_OUTPOST_RUSH then
    return
  end
  if instanceState == DungeonInstanceState_NoDungeon or instanceState == DungeonInstanceState_Finished then
    if self.groupDungeonInstanceState == DungeonInstanceState_Queued then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@ui_dungeon_removed_from_queue"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    elseif self.groupDungeonInstanceState == DungeonInstanceState_WaitingEntry then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@ui_dungeon_entry_expired"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    elseif self.groupDungeonInstanceState == DungeonInstanceState_Entered then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@ui_dungeon_closed"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
    if self.readyNotificationId then
      UiNotificationsBus.Broadcast.RescindNotification(self.readyNotificationId, true, true)
      self.readyNotificationId = nil
    end
  end
  self.groupDungeonInstanceState = instanceState
  self:EvaluateQueueHud()
end
function QueueHud:OnDungeonTimeChangedSeconds(dungeonTimeSeconds)
  if not self.readyNotificationId and self:CanFastTravelToDungeon() then
    local showTimer = self.groupDungeonInstanceState ~= DungeonInstanceState_Entered
    local notificationData = NotificationData()
    notificationData.type = "DungeonInvite"
    notificationData.title = "@ui_dungeon_opened_title"
    notificationData.text = showTimer and "@ui_dungeon_enter_info" or "@ui_dungeon_enter_info_entered"
    notificationData.hasChoice = true
    notificationData.maximumDuration = showTimer and dungeonTimeSeconds or -1
    notificationData.showProgress = showTimer
    notificationData.acceptTextOverride = "@dungeon_enter"
    notificationData.declineTextOverride = "@ui_dismiss"
    notificationData.contextId = self.entityId
    notificationData.callbackName = "OnTeleportToDungeonNotificationChoice"
    self.readyNotificationId = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function QueueHud:OnTeleportToDungeonNotificationChoice(notificationId, isAccepted)
  self.readyNotificationId = nil
  if isAccepted and self:CanFastTravelToDungeon() then
    local dungeonTimeAcceptSeconds = GroupDataRequestBus.Event.GetDungeonRemainingEnterTime(self.groupId)
    if ObjectivesComponentRequestBus.Event.HasPvpObjective(self.objectiveEntityId) and dungeonTimeAcceptSeconds > self.MIN_DUNGEON_WARN_TIME then
      local notificationData = NotificationData()
      notificationData.type = "DungeonInvite"
      notificationData.title = "@ui_dungeon_opened_pvpwarning_title"
      notificationData.text = "@ui_dungeon_enter_pvpwarning_info"
      notificationData.hasChoice = true
      notificationData.maximumDuration = dungeonTimeAcceptSeconds
      notificationData.showProgress = true
      notificationData.acceptTextOverride = "@dungeon_enter"
      notificationData.declineTextOverride = "@ui_dismiss"
      notificationData.contextId = self.entityId
      notificationData.callbackName = "OnTeleportToDungeonWarningChoice"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    else
      DynamicBus.QueueHudDisplayBus.Broadcast.OnDungeonAcceptedFromBanner()
      UIArenaAndDungeonRequestBus.Broadcast.TeleportIntoDungeon()
    end
  end
end
function QueueHud:OnTeleportToDungeonWarningChoice(notificationId, isAccepted)
  if isAccepted and self:CanFastTravelToDungeon() then
    UIArenaAndDungeonRequestBus.Broadcast.TeleportIntoDungeon()
  end
end
function QueueHud:OnEligibleForDungeonFastTravelChanged(isEligible)
  self.isEligible = isEligible
  self:EvaluateQueueHud()
end
function QueueHud:CanFastTravelToDungeon()
  return self.isEligible and (self.groupDungeonInstanceState == DungeonInstanceState_WaitingEntry or self.groupDungeonInstanceState == DungeonInstanceState_Entered)
end
function QueueHud:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if toState == 3766762380 then
    self.navBarIsShowing = true
    if self.isVisible then
      self:UpdateNavBarState(true, false)
    end
  end
  if self.screenStatesToDisable[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
end
function QueueHud:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if fromState == 3766762380 then
    self.navBarIsShowing = false
    if self.isVisible then
      self:UpdateNavBarState(false, false)
    end
  end
  if self.screenStatesToDisable[fromState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function QueueHud:SetQueueHudVisible(isVisible)
  local needsGroupCheck = self.gameModeId ~= GameModeCommon.GAMEMODE_OUTPOST_RUSH
  local isInGroup = self.groupId and self.groupId:IsValid()
  if needsGroupCheck and not isInGroup then
    return
  end
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  UiElementBus.Event.SetIsEnabled(self.Properties.ExpandedContainer, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.CollapsedContainer, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.QueueProgress, false)
  if isVisible then
    local isOutpostRush = self.gameModeId == GameModeCommon.GAMEMODE_OUTPOST_RUSH
    if self.gameModeId == nil or not isOutpostRush then
      self.gameModeId = GroupDataRequestBus.Event.GetDungeonGameModeId(self.groupId)
    end
    local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(self.rootPlayerId, self.gameModeId)
    UiTextBus.Event.SetTextWithFlags(self.Properties.NameText, gameModeData.displayName, eUiTextSet_SetLocalized)
    UiImageBus.Event.SetSpritePathname(self.Properties.ExpandedIcon, gameModeData.iconPath)
    UiImageBus.Event.SetSpritePathname(self.Properties.CollapsedIcon, gameModeData.iconPath)
    if isOutpostRush then
      local now = TimeHelpers:ServerNow()
      self.elapseTime = now:SubtractSeconds(self.startTime):ToSeconds()
      self.totalPlayers = gameModeData.numTeams * gameModeData.teamCapacity
      self.LeaveGroupButton:SetText("@ui_outpost_rush_signup_leave_queue")
      self.LeaveGroupButton:SetCallback(self.OnLeaveQueue, self)
    else
      local remainingWaitTime = 180
      self:OnEstimatedWaitTimeChanged(self.gameModeId, remainingWaitTime)
      self.startTime = TimeHelpers:ServerNow()
      self.elapseTime = 0
      local isDungeon = self.groupDungeonInstanceState == DungeonInstanceState_Queued
      if isDungeon then
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.QueueStartTime", self.startTime)
      end
      self.LeaveGroupButton:SetText("@ui_queue_leave_group")
      self.LeaveGroupButton:SetCallback(self.OnLeaveGroup, self)
    end
    local durationText = TimeHelpers:ConvertToShorthandString(self.elapseTime, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ElapsedTimeText, durationText, eUiTextSet_SetLocalized)
    self:UpdateNavBarState(self.navBarIsShowing, true)
    self:UpdateCollapsedState(false, true)
  else
    self.ScriptedEntityTweener:Stop(self.Properties.SpinnerForeground)
    DynamicBus.QueueHudDisplayBus.Broadcast.OnQueueHudBottomChanged(0)
  end
end
function QueueHud:UpdateNavBarState(isShowing, skipAnimation)
  local height = isShowing and 110 or 80
  local posY = isShowing and 80 or 0
  if skipAnimation then
    self.ScriptedEntityTweener:Set(self.Properties.MasterContainer, {y = posY})
    self.ScriptedEntityTweener:Set(self.Properties.ExpandedContainer, {h = height})
  else
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.25, {y = posY, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ExpandedContainer, 0.25, {h = height})
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.CollapseButton, isShowing)
  UiElementBus.Event.SetIsEnabled(self.Properties.LeaveGroupButton, isShowing)
  local bottom = posY + height + self.expandedContainerY + self.bottomPadding
  DynamicBus.QueueHudDisplayBus.Broadcast.OnQueueHudBottomChanged(bottom)
end
function QueueHud:OnEstimatedWaitTimeChanged(gameModeId, remainingWaitTime)
  local durationText = TimeHelpers:ConvertToShorthandString(remainingWaitTime)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ExpectedTimeText, durationText, eUiTextSet_SetLocalized)
end
function QueueHud:UpdateCollapsedState(isCollapsed, skipAnimation)
  if isCollapsed then
    UiElementBus.Event.SetIsEnabled(self.Properties.CollapsedContainer, true)
    if skipAnimation then
      self.ScriptedEntityTweener:Set(self.Properties.CollapsedContainer, {opacity = 1})
      self.ScriptedEntityTweener:Set(self.Properties.ExpandedContainer, {opacity = 0, x = 0})
      UiElementBus.Event.SetIsEnabled(self.Properties.ExpandedContainer, false)
    else
      self.ScriptedEntityTweener:Play(self.Properties.CollapsedContainer, 0.2, {
        opacity = 1,
        ease = "QuadIn",
        delay = 0.2
      })
      self.ScriptedEntityTweener:Play(self.Properties.ExpandedContainer, 0.3, {x = 0, opacity = 1}, {
        x = 500,
        opacity = 0,
        ease = "QuadIn",
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(self.Properties.ExpandedContainer, false)
        end
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.SpinnerForeground, 2.5, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ExpandedContainer, true)
    if skipAnimation then
      self.ScriptedEntityTweener:Set(self.Properties.ExpandedContainer, {opacity = 1, x = 0})
      self.ScriptedEntityTweener:Set(self.Properties.CollapsedContainer, {opacity = 0})
      UiElementBus.Event.SetIsEnabled(self.Properties.CollapsedContainer, false)
    else
      self.ScriptedEntityTweener:Play(self.Properties.ExpandedContainer, 0.3, {x = 500, opacity = 0}, {
        x = 0,
        opacity = 1,
        ease = "QuadIn",
        delay = 0.1
      })
      self.ScriptedEntityTweener:Play(self.Properties.CollapsedContainer, 0.2, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(self.Properties.CollapsedContainer, false)
        end
      })
    end
    self.ScriptedEntityTweener:Stop(self.Properties.SpinnerForeground)
  end
end
function QueueHud:OnCollapse()
  self:UpdateCollapsedState(true)
end
function QueueHud:OnExpandFocus()
  if not self.timelineHighlight then
    self.timelineHighlight = self.ScriptedEntityTweener:TimelineCreate()
    self.timelineHighlight:Add(self.Properties.HoverHighlight, 0.35, {opacity = 0.3, ease = "QuadInOut"})
    self.timelineHighlight:Add(self.Properties.HoverHighlight, 0.05, {opacity = 0.3})
    self.timelineHighlight:Add(self.Properties.HoverHighlight, 0.3, {
      opacity = 0.15,
      ease = "QuadInOut",
      onComplete = function()
        self.timelineHighlight:Play()
      end
    })
  end
  self.timelineHighlight:Play()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function QueueHud:OnExpandUnfocus()
  if self.timelineHighlight then
    self.timelineHighlight:Stop()
    self.ScriptedEntityTweener:Play(self.Properties.HoverHighlight, 0.3, {opacity = 0, ease = "QuadOut"})
  end
end
function QueueHud:OnExpand()
  self:UpdateCollapsedState(false)
end
local popupId = "queueLeaveGroupId"
function QueueHud:OnLeaveGroup()
  local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(self.rootPlayerId, self.gameModeId)
  local message = GetLocalizedReplacementText("@ui_queue_leave_group_confirm_message", {
    minGroupSize = gameModeData.minGroupSize
  })
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_queue_leave_group_confirm_title", message, popupId, self, function(self, result, eventId)
    if popupId == eventId and result == ePopupResult_Yes then
      GroupsRequestBus.Broadcast.RequestLeaveGroup()
    end
  end)
end
function QueueHud:OnLeaveQueue()
  if self.groupId and self.groupId:IsValid() then
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_outpost_rush_leave_title", "@ui_outpost_rush_leave_desc", "leaveQueue", self, function(self, result, eventId)
      if "leaveQueue" == eventId and result == ePopupResult_Yes then
        GameModeParticipantComponentRequestBus.Event.LeaveQueueForGameMode(self.rootPlayerId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
      end
    end)
  else
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_outpost_rush_leave_title", "@ui_outpost_rush_leave_desc", "leaveQueue", self, function(self, result, eventId)
      if "leaveQueue" == eventId and result == ePopupResult_Yes then
        GameModeParticipantComponentRequestBus.Event.LeaveQueueForGameMode(self.rootPlayerId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
      end
    end)
  end
end
function QueueHud:OnGameModeQueueGroupRemoved()
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = "@ui_outpost_rush_queue_group_removed"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function QueueHud:OnMatchmakingForGameModeFailed()
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = "@ui_game_mode_matchmaking_failed"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function QueueHud:TrySetDungeonMap()
  if not (self.gameModeId and self.rootPlayerId and self.mapIsReady) or not self.gameModeParticipantBusIsReady then
    return
  end
  local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(self.rootPlayerId, self.gameModeId)
  if not gameModeData.isDungeon or #gameModeData.mapId == 0 then
    return
  end
  DynamicBus.WorldMapDataBus.Broadcast.SetWorldMapDataById(gameModeData.mapId)
end
function QueueHud:OnEnteredGameMode(gameModeEntityId, gameModeId)
  if gameModeId == self.GAMEMODE_OUTPOSTRUSH then
    return
  end
  self.gameModeId = gameModeId
  self.gameModeEntityId = gameModeEntityId
  self:TrySetDungeonMap()
end
function QueueHud:OnExitedGameMode(gameModeEntityId)
  if gameModeEntityId ~= self.gameModeEntityId then
    return
  end
  self.gameModeId = nil
  self.gameModeEntityId = nil
end
function QueueHud:OnJoinedQueueForGameMode(gameModeData)
  if gameModeData.gameModeId == GameModeCommon.GAMEMODE_OUTPOST_RUSH then
    self.gameModeId = gameModeData.gameModeId
    self.numPlayers = gameModeData.numPlayers
    self.numGroups = gameModeData.numGroups
    local timePointNow = gameModeData.queuingStartTime:Now()
    self.startTime = TimeHelpers:ServerNow():SubtractDuration(timePointNow:Subtract(gameModeData.queuingStartTime))
    self:OnQueued()
    self:SetTicking(true)
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
  end
end
function QueueHud:OnUpdatedQueueForGameMode(gameModeData)
  if gameModeData.gameModeId == GameModeCommon.GAMEMODE_OUTPOST_RUSH then
    self.numPlayers = gameModeData.numPlayers
    self.numGroups = gameModeData.numGroups
  end
end
function QueueHud:OnLeftQueueForGameMode(gameModeId)
  if gameModeId == GameModeCommon.GAMEMODE_OUTPOST_RUSH and self.gameModeId == gameModeId then
    self.gameModeId = nil
    self.gameModeEntityId = nil
    self:OnRemovedFromQueue()
    self:SetTicking(false)
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
  end
end
function QueueHud:OnEnterButtonPressed()
  if self.readyNotificationId then
    UiNotificationsBus.Broadcast.RescindNotification(self.readyNotificationId, true, true)
    self.readyNotificationId = nil
  end
end
return QueueHud

local OWMissionDetailsPopup = {
  Properties = {
    MissionTitle = {
      default = EntityId()
    },
    MissionDesc1 = {
      default = EntityId()
    },
    MissionDesc2 = {
      default = EntityId()
    },
    Rewards = {
      default = {
        EntityId()
      }
    },
    TimePanel = {
      default = EntityId()
    },
    TimeTitle = {
      default = EntityId()
    },
    TimeLabel = {
      default = EntityId()
    },
    MapButton = {
      default = EntityId()
    },
    StartButton = {
      default = EntityId()
    },
    ReplaceButton = {
      default = EntityId()
    },
    AbandonButton = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    CompleteButton = {
      default = EntityId()
    },
    KillPanel = {
      default = EntityId()
    },
    CollectPanel = {
      default = EntityId()
    },
    TransportPanel = {
      default = EntityId()
    },
    KillTargetImage = {
      default = EntityId()
    },
    CollectTargetImage = {
      default = EntityId()
    },
    TransportTargetImage = {
      default = EntityId()
    },
    TransportTargetName = {
      default = EntityId()
    },
    TransportDistanceText = {
      default = EntityId()
    },
    FailureWarning = {
      default = EntityId()
    }
  },
  replacementBodyText = "",
  KILL_MISSION_TYPE = "TaskKillContribution",
  ITEM_MISSION_TYPE = "TaskHaveAndReturnItems",
  TRANSPORT_MISSION_TYPE = "TaskGiveAndTakeItem",
  SIMPLE_TASK_CONTAINER_TYPE = "SimpleTaskContainer",
  KILL_ICON_PATH = "LyShineUI/Images/missions/kill/",
  ITEM_ICON_PATH = "LyShineUI/Images/icons/items_hires/"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OWMissionDetailsPopup)
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local jsonParser = RequireScript("LyShineUI.json")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function OWMissionDetailsPopup:OnInit()
  BaseElement.OnInit(self)
  if self.Properties.Rewards[3] then
    self:BusConnect(UiMarkupButtonNotificationsBus, self.Properties.Rewards[3])
  end
  self:SetVisualElements()
end
function OWMissionDetailsPopup:OnShutdown()
end
function OWMissionDetailsPopup:SetVisualElements()
  self.StartButton:SetText("@owg_action_start")
  self.StartButton:SetCallback("AcceptMission", self)
  self.AbandonButton:SetText("@owg_action_abandon")
  self.AbandonButton:SetCallback("AbandonMission", self)
  self.MapButton:SetText("@owg_action_viewmap")
  self.MapButton:SetCallback("ViewMap", self)
  self.ReplaceButton:SetText("@owg_action_replace")
  self.ReplaceButton:SetTooltip("@owg_tooltip_warning")
  self.ReplaceButton:SetCallback("ReplaceMission", self)
  self.CompleteButton:SetText("@owg_action_complete")
  self.CompleteButton:SetCallback("CompleteMission", self)
  self.CloseButton:SetCallback(self.OnClose, self)
end
function OWMissionDetailsPopup:OnTick(deltaTime, timePoint)
  local timeRemainingSeconds = self.objectiveEndTime:Subtract(timeHelpers:ServerNow()):ToSecondsUnrounded()
  if timeRemainingSeconds ~= self.timeRemainingSeconds then
    self.timeRemainingSeconds = timeRemainingSeconds
    local durationText = timeHelpers:ConvertToShorthandString(timeRemainingSeconds)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeLabel, durationText, eUiTextSet_SetLocalized)
  end
end
function OWMissionDetailsPopup:Notify(message)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = message
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function OWMissionDetailsPopup:AcceptMission()
  ObjectiveInteractorRequestBus.Broadcast.RequestMissionSelectionById(self.objectiveParams.missionId)
  if self.taskType == self.TRANSPORT_MISSION_TYPE then
    DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation(nil, 1)
  end
  self:OnClose()
  local destination = self:GetDestination()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OWGMissionTurnIn.Position", destination)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OWGMissionTurnIn.Visible", true)
  self:Notify("@mission_accepted")
end
function OWMissionDetailsPopup:ReplaceMission()
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local currentMissionId = ObjectivesComponentRequestBus.Event.GetCurrentMissionId(playerEntityId)
  local objectiveData = ObjectivesDataManagerBus.Broadcast.GetMissionObjectiveData(currentMissionId)
  local failurePenaltyData = GameEventRequestBus.Broadcast.GetGameSystemData(objectiveData.failureGameEventId)
  self.replacementBodyText = ""
  if failurePenaltyData.categoricalProgressionReward and failurePenaltyData.categoricalProgressionReward > 0 then
    self.replacementBodyText = GetLocalizedReplacementText("@owg_replacepopup_body", {
      amount = tostring(failurePenaltyData.categoricalProgressionReward),
      guildName = DynamicBus.OWGDynamicRequestBus.Broadcast.GetGuildName(failurePenaltyData.categoricalProgressionId)
    })
  else
    self.replacementBodyText = "@owg_abandonpopup_body"
  end
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@owg_replacepopup_title", self.replacementBodyText, "replace_mission_id", self, self.OnPopupResult)
end
function OWMissionDetailsPopup:ViewMap()
  if self.mapLocation then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OpenMapMission", self.objectiveParams.missionId)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OpenMapPosition", self.mapLocation)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OpenMapHighlightId", self.highlightId)
    LyShineManagerBus.Broadcast.SetState(2477632187)
  end
end
function OWMissionDetailsPopup:AbandonMission()
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local currentMissionObjectiveId = ObjectivesComponentRequestBus.Event.GetCurrentMissionObjectiveId(playerEntityId)
  local objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(currentMissionObjectiveId)
  local failurePenaltyData = GameEventRequestBus.Broadcast.GetGameSystemData(objectiveData.failureGameEventId)
  self.replacementBodyText = "@owg_abandonpopup_body"
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@owg_action_abandon", self.replacementBodyText, "abandon_mission_id", self, self.OnPopupResult)
end
function OWMissionDetailsPopup:CompleteMission()
  ObjectiveInteractorRequestBus.Broadcast.RequestMissionCompletion(self.objectiveId)
  DynamicBus.OWGDynamicRequestBus.Broadcast.ShowCompleteButton(false)
  self:OnClose()
  local objectiveData = ObjectivesDataManagerBus.Broadcast.GetMissionObjectiveData(self.objectiveParams.missionId)
  local successRewardData = ObjectiveDataHelper:GetGameEventDataWithObjectiveRewardData(objectiveData.successGameEventId, Math.CreateCrc32(objectiveData.id))
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OWGMissionTurnIn.Visible", false)
  if string.len(successRewardData.itemReward) > 0 then
    DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation(nil, 2)
  end
end
function OWMissionDetailsPopup:CloseMissionDetails()
  if self.objectiveEndTime then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
end
function OWMissionDetailsPopup:OnClose()
  DynamicBus.OWGDynamicRequestBus.Broadcast.OnCloseMissionDetailsButtonPressed()
end
function OWMissionDetailsPopup:OnPopupResult(result, eventId)
  if eventId == "replace_mission_id" and result == ePopupResult_Yes then
    ObjectiveInteractorRequestBus.Broadcast.RequestMissionSelectionById(self.objectiveParams.missionId)
    local destination = self:GetDestination()
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OWGMissionTurnIn.Position", destination)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OWGMissionTurnIn.Visible", true)
    self:OnClose()
    self:Notify("@mission_replaced")
  elseif eventId == "abandon_mission_id" and result == ePopupResult_Yes then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    ObjectivesComponentRequestBus.Event.AbandonCurrentMission(playerEntityId)
    self:OnClose()
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OWGMissionTurnIn.Visible", false)
    self:Notify("@mission_abandoned")
  end
end
function OWMissionDetailsPopup:ShowDetails(owGuildId, objectiveId, objectiveParams)
  self.owGuildId = owGuildId
  self.objectiveParams = objectiveParams
  self.objectiveId = objectiveId
  local objectiveData = ObjectivesDataManagerBus.Broadcast.GetMissionObjectiveData(objectiveParams.missionId)
  local missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(objectiveParams.missionId)
  local successRewardData
  if missionData.successGameEventIdOverride ~= 0 then
    successRewardData = ObjectiveDataHelper:GetGameEventDataWithObjectiveRewardData(missionData.successGameEventIdOverride, missionData.objectiveId)
  else
    successRewardData = ObjectiveDataHelper:GetGameEventDataWithObjectiveRewardData(objectiveData.successGameEventId, missionData.objectiveId)
  end
  local failurePenaltyData
  if missionData.failureGameEventIdOverride ~= 0 then
    failurePenaltyData = GameEventRequestBus.Broadcast.GetGameSystemData(missionData.failureGameEventIdOverride)
  else
    failurePenaltyData = GameEventRequestBus.Broadcast.GetGameSystemData(objectiveData.failureGameEventId)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.MissionTitle, DynamicBus.OWGDynamicRequestBus.Broadcast.GetMissionTitle(self.objectiveParams), eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.MissionDesc1, DynamicBus.OWGDynamicRequestBus.Broadcast.GetMissionDescription(self.objectiveParams), eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.MissionDesc2, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_rank_number", tostring(missionData.missionTier)), eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Rewards[0], LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_rewardtype_guildcurrency", tostring(successRewardData.categoricalProgressionReward)), eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Rewards[1], LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_rewardtype_currency", GetLocalizedCurrency(successRewardData.currencyRewardRange)), eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Rewards[2], LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_rewardtype_experience", tostring(successRewardData.progressionReward)), eUiTextSet_SetAsIs)
  UiElementBus.Event.SetIsEnabled(self.Properties.Rewards[3], 0 < string.len(successRewardData.itemReward))
  if 0 < string.len(successRewardData.itemReward) then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Rewards[3], "<a action=\"ShowTooltip\" data=\"" .. successRewardData.itemReward .. "\">" .. StaticItemDataManager:GetItemName(successRewardData.itemReward) .. "</a>", eUiTextSet_SetLocalized)
  end
  local text = GetLocalizedReplacementText("@owg_failure_warning", {
    amount = tostring(-failurePenaltyData.categoricalProgressionReward),
    guildName = DynamicBus.OWGDynamicRequestBus.Broadcast.GetGuildName(self.owGuildId)
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.FailureWarning, text, eUiTextSet_SetAsIs)
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local currentMissionId = ObjectivesComponentRequestBus.Event.GetCurrentMissionId(playerEntityId)
  self.isCurrentMission = objectiveParams.missionId == currentMissionId
  local hasValidMission = currentMissionId ~= 0
  local canComplete = false
  if objectiveId ~= nil then
    canComplete = ObjectiveInteractorRequestBus.Broadcast.CanCompleteMission(objectiveId)
  end
  self:CollectMissionImages(objectiveParams.missionId, objectiveData)
  UiElementBus.Event.SetIsEnabled(self.Properties.StartButton, not self.isCurrentMission and not hasValidMission)
  UiElementBus.Event.SetIsEnabled(self.Properties.AbandonButton, self.isCurrentMission and hasValidMission and not canComplete)
  UiElementBus.Event.SetIsEnabled(self.Properties.ReplaceButton, not self.isCurrentMission and hasValidMission)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompleteButton, self.isCurrentMission and hasValidMission and canComplete)
  UiElementBus.Event.SetIsEnabled(self.Properties.MapButton, self.taskType == self.TRANSPORT_MISSION_TYPE and (self.isCurrentMission and not canComplete or not hasValidMission))
  if self.isCurrentMission then
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeTitle, "@owg_time_remaining", eUiTextSet_SetLocalized)
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local currentObjectiveId = ObjectivesComponentRequestBus.Event.GetCurrentMissionObjectiveId(playerEntityId)
    local timerDataLayerKey = string.format("Hud.LocalPlayer.MissionTimers.%08x.TargetTime", currentObjectiveId)
    self.objectiveEndTime = self.dataLayer:GetDataFromNode(timerDataLayerKey)
    if self.objectiveEndTime then
      self.timeRemainingSeconds = 0
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeTitle, "@owg_time_limit", eUiTextSet_SetLocalized)
    local durationText = timeHelpers:ConvertToShorthandString(missionData.taskTimerOverride:ToSeconds())
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeLabel, durationText, eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
end
function OWMissionDetailsPopup:GetTaskData(objectiveTaskID)
  local taskType = ""
  local taskContainer = ObjectivesDataManagerBus.Broadcast.GetTaskDataByName(objectiveTaskID)
  for i = 1, #taskContainer.subTaskList do
    local subTaskData = ObjectivesDataManagerBus.Broadcast.GetTaskDataByName(taskContainer.subTaskList[i])
    if subTaskData.type == self.SIMPLE_TASK_CONTAINER_TYPE then
      return self:GetTaskData(taskContainer.subTaskList[i])
    elseif subTaskData.type == self.KILL_MISSION_TYPE then
      taskType = self.KILL_MISSION_TYPE
    elseif subTaskData.type == self.TRANSPORT_MISSION_TYPE then
      taskType = self.TRANSPORT_MISSION_TYPE
    elseif taskType == "" and subTaskData.type == self.ITEM_MISSION_TYPE then
      taskType = self.ITEM_MISSION_TYPE
    end
  end
  return taskType
end
function OWMissionDetailsPopup:GetDestination()
  local outpostData = DynamicBus.OWGDynamicRequestBus.Broadcast.GetOutpost(self.objectiveParams.destinationOverride)
  if outpostData then
    return Vector3(outpostData.worldPosition.x, outpostData.worldPosition.y, 0)
  end
end
function OWMissionDetailsPopup:CollectMissionImages(missionId, objectiveData)
  local taskType = self:GetTaskData(objectiveData.taskID)
  self.taskType = taskType
  self.mapLocation = nil
  self.highlightId = nil
  local missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(missionId)
  if taskType == self.KILL_MISSION_TYPE then
    local imagePath = self.KILL_ICON_PATH .. missionData.taskKillContributionOverride .. ".png"
    UiImageBus.Event.SetSpritePathname(self.Properties.KillTargetImage, imagePath)
  elseif taskType == self.TRANSPORT_MISSION_TYPE then
    local imagePath = self.ITEM_ICON_PATH .. missionData.taskHaveItemsOverride .. ".png"
    local destinationName = ""
    local distanceText = ""
    local outpostData = DynamicBus.OWGDynamicRequestBus.Broadcast.GetOutpost(self.objectiveParams.destinationOverride)
    if outpostData then
      destinationName = outpostData.nameLocalizationKey
      local startPosition = ObjectiveInteractorRequestBus.Broadcast.GetCurrentProviderPosition()
      self.mapLocation = Vector3(outpostData.worldPosition.x, outpostData.worldPosition.y, 0)
      self.highlightId = outpostData.monikerId
      distanceText = GetLocalizedDistance(startPosition, self.mapLocation)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.TransportTargetName, destinationName, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TransportDistanceText, LocalizeDecimalSeparators(distanceText), eUiTextSet_SetAsIs)
  elseif taskType == self.ITEM_MISSION_TYPE then
    local imagePath = self.ITEM_ICON_PATH .. missionData.taskHaveItemsOverride .. ".png"
    UiImageBus.Event.SetSpritePathname(self.Properties.CollectTargetImage, imagePath)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.KillPanel, taskType == self.KILL_MISSION_TYPE)
  UiElementBus.Event.SetIsEnabled(self.Properties.CollectPanel, taskType == self.ITEM_MISSION_TYPE)
  UiElementBus.Event.SetIsEnabled(self.Properties.TransportPanel, taskType == self.TRANSPORT_MISSION_TYPE)
end
function OWMissionDetailsPopup:OnTransitionIn(stateName, levelName)
end
function OWMissionDetailsPopup:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
end
function OWMissionDetailsPopup:OnHoverStart(markupId, actionName, data)
  local descriptor = ItemDescriptor()
  descriptor.itemId = Math.CreateCrc32(data)
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu:IsLocked() then
    return
  end
  local flyoutVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible")
  if flyoutVisible and flyoutMenu.invokingEntityId == self.entityId then
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local rows = {}
  table.insert(rows, {
    slicePath = "LyShineUI/Tooltip/DynamicTooltip",
    itemTable = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil),
    isInPaperdoll = false,
    inventoryTable = nil,
    slotIndex = nil,
    draggableItem = nil,
    allowExternalCompare = true
  })
  if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
    flyoutMenu:SetOpenLocation(self.Properties.Rewards[3])
    flyoutMenu:SetRowData(rows)
    flyoutMenu:SetSourceHoverOnly(true)
    flyoutMenu:DockToCursor()
    flyoutMenu:Unlock()
  end
end
function OWMissionDetailsPopup:OnHoverEnd(markupId, actionName, data)
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
return OWMissionDetailsPopup

local TownProject_ActiveProject = {
  Properties = {
    ActiveProjectContent = {
      default = EntityId()
    },
    ProjectImage = {
      default = EntityId()
    },
    ProjectTitle = {
      default = EntityId()
    },
    ProjectProgressBar = {
      default = EntityId()
    },
    ProjectProgressBarLabel = {
      default = EntityId()
    },
    ProjectTimeRemaining = {
      default = EntityId()
    },
    Task1 = {
      default = EntityId()
    },
    Task2 = {
      default = EntityId()
    },
    Task3 = {
      default = EntityId()
    },
    ProjectTypeContent = {
      default = EntityId()
    },
    ProjectType = {
      default = EntityId()
    },
    ProjectTypeIcon = {
      default = EntityId()
    },
    Circle = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TownProject_ActiveProject)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
function TownProject_ActiveProject:OnInit()
  BaseElement.OnInit(self)
  self.ProjectTimeRemaining:SetTimerCompleteCallback(self.OnTimerEnded, self)
end
function TownProject_ActiveProject:OnShutdown()
end
function TownProject_ActiveProject:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function TownProject_ActiveProject:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function TownProject_ActiveProject:GetHorizontalSpacing()
  return 0
end
function TownProject_ActiveProject:UpdateProjectInfo(projectData)
  if projectData and projectData:IsActive() then
    UiElementBus.Event.SetIsEnabled(self.Properties.ActiveProjectContent, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ProjectTypeContent, false)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ProjectTitle, projectData.projectTitle, eUiTextSet_SetLocalized)
    local imagePath = "lyshineui/images/icons/misc/icon_projectType_" .. projectData.upgradeType .. ".dds"
    UiImageBus.Event.SetSpritePathname(self.Properties.ProjectImage, imagePath)
    local displayProjectProgressBar = projectData.progressionNeeded > 0
    UiElementBus.Event.SetIsEnabled(self.Properties.ProjectProgressBar, displayProjectProgressBar)
    UiElementBus.Event.SetIsEnabled(self.Properties.ProjectProgressBarLabel, displayProjectProgressBar)
    local overcompleted = projectData.currentProgress >= projectData.progressionNeeded
    local incomplete = projectData.currentProgress < projectData.progressionNeeded
    if displayProjectProgressBar then
      local currentProgressText = tostring(projectData.currentProgress)
      local progressionNeededText = tostring(projectData.progressionNeeded)
      local progressText = GetLocalizedReplacementText("@ui_project_points", {current = currentProgressText, total = progressionNeededText})
      if incomplete then
        self.ScriptedEntityTweener:Set(self.Properties.ProjectProgressBar, {
          scaleX = projectData:GetProgressPercent()
        })
      elseif overcompleted then
        self.ScriptedEntityTweener:Set(self.Properties.ProjectProgressBar, {scaleX = 1})
      end
      UiTextBus.Event.SetText(self.Properties.ProjectProgressBarLabel, progressText)
    end
    local timeRemainingSeconds = projectData:GetTimeRemaining()
    self.ProjectTimeRemaining:SetCurrentCountdownTime(timeRemainingSeconds)
    local localTerritoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
    local tasks = TerritoryDataHandler:GetAvailableTownProjectTasks(localTerritoryId, projectData.projectId)
    local tasksToShow = {
      [eMissionGoalType_Gather] = false,
      [eMissionGoalType_Kill] = false,
      [eMissionGoalType_Explore] = false
    }
    local taskElements = {
      self.Task1,
      self.Task2,
      self.Task3
    }
    for _, task in ipairs(tasks) do
      if not tasksToShow[task.taskType] then
        tasksToShow[task.taskType] = task
      end
    end
    local curElement = 1
    for _, task in pairs(tasksToShow) do
      if task and curElement <= #taskElements then
        taskElements[curElement]:SetTaskData(task, projectData.projectId, self, self.OnTaskStart, self.OnTaskComplete, self.OnTaskCancel)
        UiElementBus.Event.SetIsEnabled(taskElements[curElement].entityId, true)
        curElement = curElement + 1
      end
    end
    for i = curElement, #taskElements do
      UiElementBus.Event.SetIsEnabled(taskElements[i].entityId, false)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ActiveProjectContent, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ProjectTypeContent, true)
    if projectData then
      UiTextBus.Event.SetTextWithFlags(self.Properties.ProjectType, projectData.upgradeTypeText, eUiTextSet_SetLocalized)
      UiImageBus.Event.SetSpritePathname(self.Properties.ProjectTypeIcon, projectData.upgradeIcon)
    end
  end
end
function TownProject_ActiveProject:SetGridItemData(projectData)
  UiElementBus.Event.SetIsEnabled(self.entityId, projectData ~= nil)
  self.callbackSelf = nil
  self.callbackFn = nil
  self.projectData = projectData
  self:UpdateProjectInfo(projectData)
end
function TownProject_ActiveProject:OnTimerEnded()
  self.ProjectTimeRemaining:OverrideTimeText("@ui_any_moment")
  self:UpdateProjectInfo(self.projectData)
end
function TownProject_ActiveProject:OnFocus()
end
function TownProject_ActiveProject:OnUnfocus()
end
function TownProject_ActiveProject:OnClick()
  if self.callbackSelf then
    self.callbackFn(self.callbackSelf, self.taskData)
    self.audioHelper:PlaySound(self.audioHelper.Accept)
  end
end
function TownProject_ActiveProject:OnTaskStart(data, projectId)
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local canRequest = ObjectivesComponentRequestBus.Event.HasRoomForObjectiveType(playerEntityId, eObjectiveType_CommunityGoal)
  if not canRequest then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_objective_type_full"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  ObjectiveInteractorRequestBus.Broadcast.RequestCommunityGoalSelection(data.missionId, projectId)
end
function TownProject_ActiveProject:OnTaskCancel(data)
  local popupId = "abandonMissionTownProject"
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@owg_action_abandon", "@owg_abandonpopup_body", popupId, self, function(self, result, eventId)
    if popupId ~= eventId then
      return
    end
    if result == ePopupResult_Yes then
      local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
      local currentObjectiveId = data.objectiveInstanceId
      ObjectivesComponentRequestBus.Event.AbandonObjective(playerEntityId, currentObjectiveId)
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@ui_mission_canceled"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  end)
end
function TownProject_ActiveProject:OnTaskComplete(data)
  local currentObjectiveId = data.objectiveInstanceId
  ObjectiveInteractorRequestBus.Broadcast.RequestMissionCompletion(currentObjectiveId)
end
return TownProject_ActiveProject

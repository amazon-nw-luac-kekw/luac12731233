local TownProjects = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    ProjectsGrid = {
      default = EntityId()
    },
    ActiveProjectPrototype = {
      default = EntityId()
    },
    DetailPopup = {
      default = EntityId()
    },
    CompleteAllMissionsPopup = {
      default = EntityId()
    },
    CompleteAllMissionButtonContainer = {
      default = EntityId()
    },
    CompletedMissionTextLabel = {
      default = EntityId()
    },
    CompleteAllMissionsButton = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    TerritoryName = {
      default = EntityId()
    },
    TasksRefreshTime = {
      default = EntityId()
    },
    TasksRefreshTimeIcon = {
      default = EntityId()
    }
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(TownProjects)
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function TownProjects:OnInit()
  BaseScreen.OnInit(self)
  self.ProjectsGrid:Initialize(self.ActiveProjectPrototype, nil)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.ScreenHeader:SetText("@ui_town_project.")
  self.ScreenHeader:SetHintCallback(self.OnExit, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
  self.townProjecthandler = DynamicBus.TownProjectsBus.Connect(self.entityId, self)
  self.CompleteAllMissionsButton:SetText("@ui_complete_all_missions")
  self.CompleteAllMissionsButton:SetCallback(self.OnCompleteAllMissionsButton, self)
  self.CompleteAllMissionsButton:SetButtonStyle(self.CompleteAllMissionsButton.BUTTON_STYLE_CTA)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ObjectiveEntityId", function(self, objectiveEntityId)
    if objectiveEntityId == nil or self.objectiveEntityId ~= nil then
      return
    end
    self.objectiveEntityId = objectiveEntityId
  end)
  self.sortOrder = {
    [eTerritoryUpgradeType_Settlement] = 1,
    [eTerritoryUpgradeType_Fortress] = 2,
    [eTerritoryUpgradeType_Lifestyle] = 3,
    [eTerritoryUpgradeType_AlwaysAvailable] = 4
  }
end
function TownProjects:OnShutdown()
  BaseScreen.OnShutdown(self)
  if self.townProjecthandler then
    DynamicBus.TownProjectsBus.Disconnect(self.entityId, self)
    self.townProjecthandler = nil
  end
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
end
function TownProjects:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_TownProjects", 0.5)
  self.fromConversationService = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ConversationServiceOpen")
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Frame, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.5, {opacity = 0}, {
    opacity = 1,
    delay = 0.2,
    ease = "QuadOut"
  })
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 4
  self.targetDOFBlur = 0.5
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 1.2,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
  self:BusDisconnect(self.objectivesComponentBusHandler)
  self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, self.objectiveEntityId)
  if not self.interfaceComponentHandler then
    local territoryEntityId = self.dataLayer:GetDataFromNode("Hud.TerritoryGovernance.EntityId")
    self.interfaceComponentHandler = self:BusConnect(TerritoryInterfaceComponentNotificationsBus, territoryEntityId)
  end
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
  self.dataLayer:RegisterDataCallback(self, "Hud.Objective.OnActiveObjectiveUpdate", function(self, hasUpdated)
    if hasUpdated then
      self:RefreshProjectContent()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    self.inventoryId = data
  end)
  self.territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  UiTextBus.Event.SetText(self.Properties.TerritoryName, TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.territoryId))
  self.nextUpdate = 0
  self:UpdateTasksRefreshTime()
  TimingUtils:Delay(1, self, self.UpdateTasksRefreshTime, true)
end
function TownProjects:UpdateTasksRefreshTime()
  self.nextUpdate = self.nextUpdate - 1
  if self.nextUpdate < 0 then
    self.nextUpdate = TerritoryDataHandler:GetSecondsToNextSeed()
    self:RefreshProjectContent()
  end
  UiTextBus.Event.SetText(self.Properties.TasksRefreshTime, timeHelpers:ConvertSecondsToHrsMinSecString(self.nextUpdate, false, true, true), eUiTextSet_SetLocalized)
end
function TownProjects:RefreshProjectContent()
  local emptyUpgradeTypes = {
    {
      upgradeType = eTerritoryUpgradeType_Settlement,
      upgradeTypeText = "@ui_upgradebutton_label_settlement",
      upgradeIcon = "lyshineui/images/icons/misc/icon_projectType_2.dds",
      IsActive = function()
        return false
      end
    },
    {
      upgradeType = eTerritoryUpgradeType_Fortress,
      upgradeTypeText = "@ui_upgradebutton_label_fort",
      upgradeIcon = "lyshineui/images/icons/misc/icon_projectType_1.dds",
      IsActive = function()
        return false
      end
    },
    {
      upgradeType = eTerritoryUpgradeType_Lifestyle,
      upgradeTypeText = "@ui_upgradebutton_label_lifestyle",
      upgradeIcon = "lyshineui/images/icons/misc/icon_projectType_3.dds",
      IsActive = function()
        return false
      end
    },
    {
      upgradeType = eTerritoryUpgradeType_AlwaysAvailable,
      upgradeTypeText = "@ui_upgradebutton_label_alwaysavailable",
      upgradeIcon = "lyshineui/images/icons/misc/icon_projectType_5.dds",
      IsActive = function()
        return false
      end
    }
  }
  local typeToProjectIdx = {}
  for idx, emptyUpgradeType in ipairs(emptyUpgradeTypes) do
    typeToProjectIdx[emptyUpgradeType.upgradeType] = idx
  end
  self.projects = {}
  local projectsById = {}
  UiElementBus.Event.SetIsEnabled(self.Properties.TasksRefreshTimeIcon, false)
  local allProjects = TerritoryDataHandler:GetAvailableTerritoryProjectUpgrades()
  for k, categoryData in ipairs(allProjects) do
    for i, projectData in ipairs(categoryData) do
      if projectData:IsActive() then
        local detailedProjectData = TerritoryDataHandler:GetDetailedTerritoryProject(projectData.projectId)
        local projectUpgradeType = TerritoryDataHandler:GetTerritoryProjectDataFromProjectId(projectData.projectId)
        table.insert(self.projects, detailedProjectData)
        projectsById[detailedProjectData.projectId] = detailedProjectData
        emptyUpgradeTypes[typeToProjectIdx[projectData.upgradeType]] = false
        UiElementBus.Event.SetIsEnabled(self.Properties.TasksRefreshTimeIcon, true)
      end
    end
  end
  for k, emptyUpgradeType in ipairs(emptyUpgradeTypes) do
    if emptyUpgradeType then
      table.insert(self.projects, emptyUpgradeType)
    end
  end
  table.sort(self.projects, function(a, b)
    return self.sortOrder[a.upgradeType] < self.sortOrder[b.upgradeType]
  end)
  local localTerritoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  self.readyMissions = TerritoryDataHandler:GetOrderedTownProjectCompletedMissions(localTerritoryId, projectsById)
  local text = GetLocalizedReplacementText("@ui_you_have_n_completed_missions", {
    count = #self.readyMissions
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.CompletedMissionTextLabel, text, eUiTextSet_SetAsIs)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompleteAllMissionButtonContainer, #self.readyMissions > 0)
  self.ProjectsGrid:OnListDataSet(self.projects)
end
function TownProjects:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  self.dataLayer:UnregisterObserver(self, "Hud.Objective.OnActiveObjectiveUpdate")
  UiElementBus.Event.SetIsEnabled(self.Properties.CompleteAllMissionsPopup, false)
  if self.fromConversationService then
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
    JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.5)
    JavCameraControllerRequestBus.Broadcast.ClearCameraLookAt()
    self.ScriptedEntityTweener:Play(self.DOFTweenDummyElement, 0.3, {
      opacity = 0,
      onUpdate = function(currentValue, currentProgressPercent)
        self:UpdateDepthOfField(currentValue)
      end,
      onComplete = function()
        JavCameraControllerRequestBus.Broadcast.MakeActiveView(4, 2, 5)
        JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
      end
    })
    self.fromConversationService = false
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ConversationServiceOpen", false)
  else
    JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_TownProjects", 0.5)
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
  end
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Frame, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  if self.objectivesComponentBusHandler then
    self:BusDisconnect(self.objectivesComponentBusHandler)
    self.objectivesComponentBusHandler = nil
  end
  if self.interfaceComponentHandler then
    self:BusDisconnect(self.interfaceComponentHandler)
    self.interfaceComponentHandler = nil
  end
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  TimingUtils:StopDelay(self)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function TownProjects:OnReceivedTerritoryProgressionData(territoryProgressionData)
  self:RefreshProjectContent()
end
function TownProjects:OnTaskClicked(taskData)
  self.DetailPopup:ShowProjectTaskDetails(taskData, self, self.OnTaskDetailCallback)
end
function TownProjects:OnTaskDetailCallback(taskData)
  if taskData:IsReadyToComplete() then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local currentObjectiveId = ObjectivesComponentRequestBus.Event.GetCurrentMissionObjectiveId(playerEntityId)
    ObjectiveInteractorRequestBus.Broadcast.RequestMissionCompletion(currentObjectiveId)
  elseif taskData:IsInProgress() then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    ObjectivesComponentRequestBus.Event.AbandonCurrentMission(playerEntityId)
  else
    local hasAnotherMission = false
    if hasAnotherMission then
    else
      local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
      local canRequest = ObjectivesComponentRequestBus.Event.HasRoomForObjectiveType(playerEntityId, eObjectiveType_CommunityGoal)
      if not canRequest then
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = "@ui_objective_type_full"
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
      ObjectiveInteractorRequestBus.Broadcast.RequestCommunityGoalSelection(taskData.missionId, 0)
    end
  end
  self:RefreshProjectContent()
end
function TownProjects:OnCompleteAllMissionsButton()
  local missionsInfo = {
    missionCount = 0,
    turnIns = {},
    gold = "",
    xp = 0,
    territoryStanding = 0
  }
  local goldMin = 0
  local goldMax = 0
  local countPerItem = {}
  for k, mission in ipairs(self.readyMissions) do
    if mission:IsReadyToComplete() then
      local meetsRequirements = true
      if mission.itemsToCollect and mission.itemCount then
        if not countPerItem[mission.itemsToCollect] then
          countPerItem[mission.itemsToCollect] = mission.itemCount
        else
          countPerItem[mission.itemsToCollect] = countPerItem[mission.itemsToCollect] + mission.itemCount
        end
        local itemDescriptor = ItemDescriptor()
        itemDescriptor.itemId = Math.CreateCrc32(mission.itemsToCollect)
        meetsRequirements = ContainerRequestBus.Event.HasItem(self.inventoryId, itemDescriptor, false, countPerItem[mission.itemsToCollect])
      end
      if meetsRequirements then
        local rewardData = mission:GetRewardData()
        missionsInfo.missionCount = missionsInfo.missionCount + 1
        local range = rewardData.currencyRewardRange
        local minMax = StringSplit(range, "-")
        goldMin = goldMin + tonumber(minMax[1])
        if #minMax == 1 then
          goldMax = goldMax + tonumber(minMax[1])
        else
          goldMax = goldMax + tonumber(minMax[2])
        end
        missionsInfo.territoryStanding = missionsInfo.territoryStanding + rewardData.categoricalProgressionReward + rewardData.territoryStanding
        missionsInfo.xp = missionsInfo.xp + rewardData.progressionReward
        if 0 < mission.itemCount then
          table.insert(missionsInfo.turnIns, {
            spritePath = mission.image,
            count = mission.itemCount
          })
        end
      end
    end
  end
  missionsInfo.gold = GetLocalizedCurrency(goldMin)
  if goldMin < goldMax then
    missionsInfo.gold = missionsInfo.gold .. " - " .. GetLocalizedCurrency(goldMax)
  end
  self.CompleteAllMissionsPopup:ShowCompleteAllMissionsPopup(missionsInfo, self.OnCompleteAllMissionsConfirm, self)
end
function TownProjects:OnCompleteAllMissionsConfirm(accept)
  if not accept then
    return
  end
  for k, mission in ipairs(self.readyMissions) do
    ObjectiveInteractorRequestBus.Broadcast.RequestMissionCompletion(mission.objectiveInstanceId)
  end
  self:RefreshProjectContent()
end
function TownProjects:OnEscapeKeyPressed()
  local isPopupEnabled = UiElementBus.Event.IsEnabled(self.Properties.DetailPopup)
  if isPopupEnabled then
    self.DetailPopup:OnClose()
    return
  else
    LyShineManagerBus.Broadcast.SetState(2702338936)
  end
end
function TownProjects:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function TownProjects:OnExit()
  LyShineManagerBus.Broadcast.ExitState(640726528)
end
function TownProjects:OnObjectiveAdded(objectiveId)
  self:RefreshProjectContent()
end
function TownProjects:OnObjectiveRemoved(objectiveId)
  self:RefreshProjectContent()
end
return TownProjects

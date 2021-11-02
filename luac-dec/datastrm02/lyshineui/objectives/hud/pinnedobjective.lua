local PinnedObjective = {
  Properties = {
    Container = {
      default = EntityId()
    },
    Bg = {
      default = EntityId()
    },
    FlashLine1 = {
      default = EntityId()
    },
    FlashLine2 = {
      default = EntityId()
    },
    FlashGlow = {
      default = EntityId()
    },
    FlashLight = {
      default = EntityId()
    },
    FlashContainer = {
      default = EntityId()
    },
    Effect = {
      default = EntityId()
    },
    Pulse1 = {
      default = EntityId()
    },
    Pulse2 = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    TitleBg = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Label = {
      default = EntityId()
    },
    TasksContainer = {
      default = EntityId()
    },
    Tasks = {
      default = {
        EntityId()
      }
    },
    IngredientsContainer = {
      default = EntityId()
    },
    UnusedIngredients = {
      default = EntityId()
    },
    Ingredients = {
      default = {
        EntityId()
      }
    },
    UnpinButton = {
      default = EntityId()
    },
    JournalButton = {
      default = EntityId()
    },
    MapButton = {
      default = EntityId()
    },
    TimeRemaining = {
      default = EntityId()
    },
    TimeRemainingIcon = {
      default = EntityId()
    }
  },
  OBJECTIVE_STYLE_NORMAL = 0,
  OBJECTIVE_STYLE_LARGE = 1,
  TIME_REMAINING_YELLOW = 600,
  TIME_REMAINING_RED = 300,
  availableTaskElements = {},
  taskDataById = {},
  taskTablesById = {},
  orderedTasks = {},
  disallowControlsTypes = {
    [eObjectiveType_Darkness_Minor] = true,
    [eObjectiveType_Darkness_Major] = true,
    [eObjectiveType_POI] = true,
    [eObjectiveType_DefendObject] = true,
    [eObjectiveType_Dungeon] = true
  },
  labelsByType = {
    [eObjectiveType_Darkness_Minor] = "@incursion",
    [eObjectiveType_Darkness_Major] = "@incursion",
    [eObjectiveType_POI] = "@location",
    [eObjectiveType_Dungeon] = "@dungeon"
  },
  opacity = 1,
  taskContainerOffset = 21,
  showDelay = 0.75
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PinnedObjective)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local ObjectiveTypeData = RequireScript("LyShineUI.Objectives.ObjectiveTypeData")
local ObjectivesDataHandler = RequireScript("LyShineUI._Common.ObjectivesDataHandler")
local ScriptActionQueue = RequireScript("LyShineUI._Common.ScriptActionQueue")
local AudioHelper = RequireScript("LyShineUI.AudioEvents")
function PinnedObjective:OnInit()
  BaseElement.OnInit(self)
  self.actionQueue = ScriptActionQueue:QueueCreate()
  self.baseWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  if type(self.UnpinButton) ~= "table" or type(self.UnpinButton.SetIconPathname) ~= "function" then
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    return
  end
  self.isObjectiveLocation = false
  local titleStyle = self.UIStyle.FONT_STYLE_PINNED_OBJECTIVE_TITLE
  SetTextStyle(self.Properties.Title, titleStyle)
  UiImageBus.Event.SetColor(self.Properties.TitleBg, self.UIStyle.COLOR_YELLOW_LIGHT)
  local labelStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
    fontSize = self.UIStyle.FONT_SIZE_BODY_NEW,
    fontColor = self.UIStyle.COLOR_TAN,
    characterSpacing = 0,
    fontEffect = self.UIStyle.FONT_EFFECT_DROP_SHADOW
  }
  SetTextStyle(self.Properties.Label, labelStyle)
  local timeRemainingStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = self.UIStyle.FONT_SIZE_OBJECTIVE_TIMER,
    fontColor = self.UIStyle.COLOR_WHITE,
    characterSpacing = 25,
    fontEffect = self.UIStyle.FONT_EFFECT_DROP_SHADOW
  }
  SetTextStyle(self.Properties.TimeRemaining, timeRemainingStyle)
  self.timeColor = self.UIStyle.COLOR_GRAY_80
  if self.Properties.UnpinButton:IsValid() then
    self.UnpinButton:SetIconPathname("lyshineui/images/icons/objectives/icon_pin.dds")
    self.UnpinButton:SetIconColorUnfocused(self.UIStyle.COLOR_TAN)
    self.UnpinButton:SetCallback(self.OnUnpinPressed, self)
    self.ScriptedEntityTweener:Set(self.Properties.UnpinButton, {opacity = 0})
  end
  if self.Properties.JournalButton:IsValid() then
    self.JournalButton:SetIconPathname("lyshineui/images/icons/objectives/icon_objectives.dds")
    self.JournalButton:SetIconColorUnfocused(self.UIStyle.COLOR_TAN)
    self.JournalButton:SetCallback(self.OnJournalPressed, self)
    self.ScriptedEntityTweener:Set(self.Properties.JournalButton, {opacity = 0})
  end
  if self.Properties.MapButton:IsValid() then
    self.MapButton:SetIconPathname("lyshineui/images/map/icon/waypoint.dds")
    self.MapButton:SetIconColorUnfocused(self.UIStyle.COLOR_TAN)
    self.MapButton:SetCallback(self.OnMapPressed, self)
    self.ScriptedEntityTweener:Set(self.Properties.MapButton, {opacity = 0})
  end
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.CurrentAreaTerritory.SmallestContainingId", function(self, territoryId)
    if territoryId and territoryId ~= self.currentTerritoryId then
      self.currentTerritoryId = territoryId
      self:UpdateTerritoryHighlight()
    end
  end)
  self.taskContainerOffset = UiTransformBus.Event.GetLocalPositionY(self.Properties.TasksContainer)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.enable-objective-poi-highlight", function(self, enablePoiHighlight)
    self.enablePoiHighlight = enablePoiHighlight
  end)
end
function PinnedObjective:OnTick(deltaTime, timePoint)
  local timeRemainingSeconds = self.objectiveEndTime:Subtract(timeHelpers:ServerNow()):ToSecondsUnrounded()
  if timeRemainingSeconds ~= self.timeRemainingSeconds then
    self.timeRemainingSeconds = timeRemainingSeconds
    local color
    if self.timeRemainingSeconds <= self.TIME_REMAINING_RED then
      color = self.UIStyle.COLOR_RED
    elseif self.timeRemainingSeconds <= self.TIME_REMAINING_YELLOW then
      color = self.UIStyle.COLOR_YELLOW
    else
      color = self.UIStyle.COLOR_GRAY_80
    end
    if color ~= self.timeColor then
      self.timeColor = color
      self.ScriptedEntityTweener:Set(self.Properties.TimeRemaining, {textColor = color})
      self.ScriptedEntityTweener:Play(self.Properties.TimeRemainingIcon, 0.3, {imgColor = color})
    end
    local durationText = timeHelpers:ConvertSecondsToHrsMinSecString(self.timeRemainingSeconds, false)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeRemaining, durationText, eUiTextSet_SetLocalized)
  end
end
function PinnedObjective:SetStyle(style)
  local taskStyle = self.Tasks[0].TASK_STYLE_NORMAL
  if style == self.OBJECTIVE_STYLE_LARGE then
    taskStyle = self.Tasks[0].TASK_STYLE_LARGE
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Icon, -18)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Icon, 4)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Icon, 35)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.Icon, 35)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.Title, 25)
    UiTextBus.Event.SetFontSize(self.Properties.Title, self.UIStyle.FONT_SIZE_BODY_NEW)
  else
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Icon, -18)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Icon, -12)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Icon, 35)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.Icon, 35)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.Title, 23)
    UiTextBus.Event.SetFontSize(self.Properties.Title, self.UIStyle.FONT_SIZE_BODY_NEW)
  end
  for i = 0, #self.Tasks do
    self.Tasks[i]:SetTaskStyle(taskStyle)
  end
  self.style = style
end
function PinnedObjective:UpdateTaskPositions()
  local taskPositionY = 0
  local taskPadding = -3
  for i, taskId in ipairs(self.orderedTasks) do
    local taskTable = self.taskTablesById[taskId]
    if taskTable then
      if taskTable.level == 0 then
      end
      taskTable:SetPositionY(taskPositionY)
      taskPositionY = taskPositionY + taskTable:GetHeight() + taskPadding
    end
  end
  if self.handInTaskTable then
    self.handInTaskTable:SetPositionY(taskPositionY)
    if UiElementBus.Event.IsEnabled(self.handInTaskTable.entityId) then
      taskPositionY = taskPositionY + self.handInTaskTable:GetHeight() + taskPadding
    end
  end
  self.height = taskPositionY + self.taskContainerOffset
  if self.objectiveEndTime then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.TimeRemaining, self.height)
    timeContainerHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.TimeRemaining)
    self.height = self.height + timeContainerHeight
  end
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
  if self.updatedCallback then
    self.updatedCallback(self.updatedCallbackTable, self)
  end
end
function PinnedObjective:RefreshObjectiveIcon()
  if self.objectiveId then
    local iconPath = ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(self.objectiveId)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, iconPath)
  end
end
function PinnedObjective:RefreshObjectiveIconAndTextColor(animTime, animDelay)
  animTime = animTime or 0
  animDelay = animDelay or 0
  if self.objectiveId then
    local iconPath, iconColor, isReadyToTurnIn, textColor = ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(self.objectiveId)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, iconPath)
    self.ScriptedEntityTweener:Play(self.Properties.Icon, animTime, {imgColor = iconColor, delay = animDelay})
    self.ScriptedEntityTweener:Play(self.Properties.Title, animTime, {
      textColor = self.titleColorOverride or textColor,
      delay = animDelay,
      onComplete = function()
        UiTextBus.Event.SetFontEffectByName(self.Properties.Title, self.titleColorOverride and self.UIStyle.FONT_EFFECT_NONE or self.UIStyle.FONT_EFFECT_DROPSHADOW)
      end
    })
  end
end
function PinnedObjective:SetObjectiveId(objectiveId)
  if objectiveId == nil then
    self.objectiveId = nil
    return
  end
  self:BusDisconnect(self.objectiveNotificationBusHandler)
  self.objectiveNotificationBusHandler = self:BusConnect(ObjectiveNotificationBus, objectiveId)
  self.handInTaskTable = nil
  self.isComplete = false
  self.isFailed = false
  self.objectiveId = objectiveId
  local taskIds = ObjectiveRequestBus.Event.GetTasks(self.objectiveId)
  if taskIds == nil then
    return
  end
  self.containerTaskId = taskIds[1]
  local objectiveType = ObjectiveRequestBus.Event.GetType(self.objectiveId)
  self.objectiveType = objectiveType
  if objectiveType == eObjectiveType_Mission then
    local missionParams = ObjectiveRequestBus.Event.GetCreationParams(objectiveId)
    local outpostData = DynamicBus.OWGDynamicRequestBus.Broadcast.GetOutpost(missionParams.destinationOverride)
    if outpostData then
      local destination = Vector3(outpostData.worldPosition.x, outpostData.worldPosition.y, 0)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OWGMissionTurnIn.Position", destination)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OWGMissionTurnIn.Visible", true)
    else
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OWGMissionTurnIn.Visible", false)
    end
  end
  self.isRecipe = objectiveType == eObjectiveType_Crafting
  local typeData = ObjectiveTypeData:GetType(objectiveType)
  self:RefreshObjectiveIconAndTextColor()
  local bgColor = typeData.bgColor or self.UIStyle.COLOR_BLACK
  UiImageBus.Event.SetColor(self.Properties.Bg, bgColor)
  UiElementBus.Event.SetIsEnabled(self.TasksContainer, not self.isRecipe)
  UiElementBus.Event.SetIsEnabled(self.IngredientsContainer, self.isRecipe)
  local bottomMargin = 18
  if not self.isRecipe then
    ClearTable(self.orderedTasks)
    ClearTable(self.taskTablesById)
    ClearTable(self.availableTaskElements)
    for i = 0, #self.Tasks do
      table.insert(self.availableTaskElements, self.Tasks[i])
    end
    for taskId, taskData in pairs(self.taskDataById) do
      self:BusDisconnect(taskData.handler)
    end
    ClearTable(self.taskDataById)
    self:SetupTaskOrder(taskIds)
    for i = 1, #taskIds do
      self:SetupTask(taskIds[i], 0)
    end
    local objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(self.objectiveId)
    if objectiveData ~= nil and objectiveData.npcDestinationId ~= GetNilCrc() then
      self:SetupHandInTask()
    end
    for i, taskTable in pairs(self.availableTaskElements) do
      UiElementBus.Event.SetIsEnabled(taskTable.entityId, false)
    end
    local timeContainerHeight = 0
    local timerDataLayerKey = string.format("Hud.LocalPlayer.MissionTimers.%08x.TargetTime", self.objectiveId.value)
    self.objectiveEndTime = self.dataLayer:GetDataFromNode(timerDataLayerKey)
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeRemaining, self.objectiveEndTime ~= nil)
    self:UpdateTaskPositions()
  else
    self.ingredientIteration = 0
    taskIds = ObjectiveTaskRequestBus.Event.GetTasks(self.containerTaskId)
    for i = 1, #taskIds do
      self:SetupIngredient(taskIds[i], 0)
    end
    for i = self.ingredientIteration, #self.Properties.Ingredients do
      UiElementBus.Event.Reparent(self.Properties.Ingredients[i], self.Properties.UnusedIngredients, EntityId())
      UiElementBus.Event.SetIsEnabled(self.Properties.Ingredients[i], false)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeRemaining, false)
    local ingredientsContainerOffset = UiTransformBus.Event.GetLocalPositionY(self.Properties.IngredientsContainer)
    local ingredientsContainerHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.IngredientsContainer)
    self.height = ingredientsContainerOffset + ingredientsContainerHeight
  end
  self:RefreshTitle()
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local isTracked = ObjectivesComponentRequestBus.Event.IsObjectiveTracked(playerEntityId, self.objectiveId)
  if isTracked then
    self.UnpinButton:SetIconPathname("lyshineui/images/icons/objectives/icon_unpin.dds")
  else
    self.UnpinButton:SetIconPathname("lyshineui/images/icons/objectives/icon_pin.dds")
  end
  local position = DynamicBus.ObjectivesLayer.Broadcast.GetObjectivePosition(self.objectiveId)
  UiElementBus.Event.SetIsEnabled(self.Properties.MapButton, position ~= nil)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
  return true
end
function PinnedObjective:SetupTaskOrder(taskIds)
  for i = 1, #taskIds do
    local taskId = taskIds[i]
    local isHidden = ObjectiveTaskRequestBus.Event.GetIsHidden(taskId)
    if not isHidden and taskId ~= self.containerTaskId then
      table.insert(self.orderedTasks, taskIds[i]:ToString())
    end
    local subtaskIds = ObjectiveTaskRequestBus.Event.GetTasks(taskId)
    if 0 < #subtaskIds then
      local hideChildren = ObjectiveTaskRequestBus.Event.GetHideChildren(taskId)
      if not hideChildren then
        self:SetupTaskOrder(subtaskIds)
      end
    end
  end
end
function PinnedObjective:RemoveTask(taskId)
  local taskIdString = taskId
  if type(taskId) ~= "string" then
    taskIdString = taskId:ToString()
  end
  for subTaskId, taskData in pairs(self.taskDataById) do
    if taskData.containerTaskId:ToString() == taskIdString then
      self:RemoveTask(subTaskId)
    end
  end
  local taskTable = self.taskTablesById[taskIdString]
  if taskTable then
    UiElementBus.Event.SetIsEnabled(taskTable.entityId, false)
    table.insert(self.availableTaskElements, taskTable)
    self.taskTablesById[taskIdString] = nil
  end
end
function PinnedObjective:SetupTask(taskId, level, index)
  local elementIndex, taskTable = next(self.availableTaskElements)
  if elementIndex then
    local isConsecutive = ObjectiveTaskRequestBus.Event.ContainsConsecutiveTasks(taskId)
    local isHidden = ObjectiveTaskRequestBus.Event.GetIsHidden(taskId)
    if isHidden or taskId == self.containerTaskId then
      level = level - 1
    else
      taskTable:SetUpdatedCallback(self.OnTaskUpdated, self)
      taskTable:SetUpdateTaskPositionsCallback(self.UpdateTaskPositions, self)
      taskTable:SetObjectivePositionsCallback(self.updatedCallback, self.updatedCallbackTable)
      taskTable:SetTaskById(taskId, level, index)
      UiElementBus.Event.SetIsEnabled(taskTable.entityId, true)
      self.taskTablesById[taskId:ToString()] = taskTable
      table.remove(self.availableTaskElements, elementIndex)
    end
    local subtaskIds = ObjectiveTaskRequestBus.Event.GetTasks(taskId)
    if 0 < #subtaskIds then
      local hideChildren = ObjectiveTaskRequestBus.Event.GetHideChildren(taskId)
      if not hideChildren then
        for i = 1, #subtaskIds do
          local subtaskIdString = subtaskIds[i]:ToString()
          self.taskDataById[subtaskIdString] = {
            containerTaskId = taskId,
            level = level + 1,
            index = i,
            isConsecutive = isConsecutive
          }
          if isConsecutive then
            self.taskDataById[subtaskIdString].handler = self:BusConnect(ObjectiveTaskNotificationBus, subtaskIds[i])
            local taskState = ObjectiveTaskRequestBus.Event.GetState(subtaskIds[i])
            if taskState == eObjectiveTaskState_Active then
              local progressPercent = ObjectiveTaskRequestBus.Event.GetProgressPercent(subtaskIds[i])
              if progressPercent and progressPercent < 1 then
                self:SetupTask(subtaskIds[i], level + 1, i)
              end
            end
          else
            self:SetupTask(subtaskIds[i], level + 1, nil)
          end
        end
      end
    end
  end
end
function PinnedObjective:UpdateHandInTaskVisibility(delay)
  if self.handInTaskTable ~= nil then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local canCompleteObjective = ObjectivesComponentRequestBus.Event.IsObjectiveReadyForCompletion(playerEntityId, self.objectiveId)
    UiElementBus.Event.SetIsEnabled(self.handInTaskTable.entityId, canCompleteObjective)
    if canCompleteObjective then
      TimingUtils:Delay(delay, self, function()
        self:PlayFlashAtY(10)
      end)
    end
  end
  self:UpdateTaskPositions()
  self:RefreshObjectiveIconAndTextColor()
end
function PinnedObjective:SetupHandInTask()
  local index, taskTable = next(self.availableTaskElements)
  if index then
    self.handInTaskTable = taskTable
    taskTable:SetHandInTask(self.objectiveId)
    self:UpdateHandInTaskVisibility(0.75)
    table.remove(self.availableTaskElements, index)
  end
end
function PinnedObjective:SetupIngredient(taskId)
  if self.Ingredients[self.ingredientIteration] ~= nil then
    local isHidden = ObjectiveTaskRequestBus.Event.GetIsHidden(taskId)
    if not isHidden then
      self.Ingredients[self.ingredientIteration]:SetTaskById(taskId)
      UiElementBus.Event.Reparent(self.Properties.Ingredients[self.ingredientIteration], self.Properties.IngredientsContainer, EntityId())
      UiElementBus.Event.SetIsEnabled(self.Properties.Ingredients[self.ingredientIteration], true)
      self.ingredientIteration = self.ingredientIteration + 1
    end
  end
end
function PinnedObjective:OnObjectiveHandInToNpc()
  if self.handInTaskTable ~= nil then
    self.handInTaskTable:SetTaskState(eObjectiveTaskState_Active, false)
    self:UpdateHandInTaskVisibility(0)
  end
end
function PinnedObjective:ActivateTask(taskId)
  if not self.taskTablesById[taskId:ToString()] then
    local taskData = self.taskDataById[taskId:ToString()]
    if taskData then
      self:SetupTask(taskId, taskData.level, taskData.index)
    end
    self:UpdateTaskPositions()
  end
end
function PinnedObjective:OnTaskActivated(taskId)
  self.actionQueue:Add(self, self.ActivateTask, taskId)
end
function PinnedObjective:CloseTaskIfHidden(taskId)
  local isHidden = ObjectiveTaskRequestBus.Event.GetIsHidden(taskId)
  if isHidden then
    local taskString = taskId:ToString()
    if self.taskDataById[taskString] and self.taskDataById[taskString].isConsecutive then
      self:RemoveTask(taskId)
      self:UpdateTaskPositions()
    end
  end
end
function PinnedObjective:OnTaskCompleted(taskId)
  self:CloseTaskIfHidden(taskId)
end
function PinnedObjective:OnTaskFailed(taskId)
  self:CloseTaskIfHidden(taskId)
end
function PinnedObjective:OnTaskUpdated(taskTable)
  if self.objectiveId == nil then
    Debug.Log("[Error] PinnedObjective:OnTaskUpdated self.objectiveId == nil!")
    return
  end
  local y = self.taskContainerOffset + taskTable:GetPositionY() + taskTable:GetHeight() / 2
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local canCompleteObjective = ObjectivesComponentRequestBus.Event.IsObjectiveReadyForCompletion(playerEntityId, self.objectiveId)
  if taskTable.taskId then
    local taskString = taskTable.taskId:ToString()
    if not taskTable.isActive and self.taskDataById[taskString] and self.taskDataById[taskString].isConsecutive then
      self:RemoveTask(taskTable.taskId)
      if not canCompleteObjective then
        self:PlayFlashAtY(y)
      end
      self:UpdateTaskPositions()
    elseif not taskTable.isActive and not canCompleteObjective then
      self:PlayFlashAtY(y)
    end
  end
end
function PinnedObjective:GetObjectiveId()
  return self.objectiveId
end
function PinnedObjective:SetIsEnqueuing(isEnqueuing)
  if self.isEnqueuing == isEnqueuing then
    return
  end
  self.isEnqueuing = isEnqueuing
  for i = 0, #self.Tasks do
    self.Tasks[i]:SetIsEnqueuing(self.isEnqueuing)
  end
  self.actionQueue:SetIsEnqueuing(self.isEnqueuing)
  if not self.isEnqueuing then
    self.actionQueue:DoAll()
  end
end
function PinnedObjective:SetIsShowingControls(isShowingControls)
  if self.disallowControlsTypes[self.objectiveType] then
    isShowingControls = false
  end
  if isShowingControls ~= self.isShowingControls then
    if isShowingControls then
      self.ScriptedEntityTweener:PlayC(self.Properties.UnpinButton, 0.3, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.JournalButton, 0.3, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.MapButton, 0.3, tweenerCommon.fadeInQuadOut)
    else
      self.ScriptedEntityTweener:PlayC(self.Properties.UnpinButton, 0.3, tweenerCommon.fadeOutQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.JournalButton, 0.3, tweenerCommon.fadeOutQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.MapButton, 0.3, tweenerCommon.fadeOutQuadOut)
    end
    self.isShowingControls = isShowingControls
  end
end
function PinnedObjective:SetIsUsingDarkBg(isUsingDarkBg)
  if isUsingDarkBg ~= self.isUsingDarkBg then
    self.isUsingDarkBg = isUsingDarkBg
    local bgOpacity = self.isUsingDarkBg and 0.7 or 0.17
    self.ScriptedEntityTweener:Play(self.Bg, 0.3, {opacity = bgOpacity})
  end
end
function PinnedObjective:GetHeight()
  return self.height
end
function PinnedObjective:AnimateIn(callback, showDelay, forcePlay)
  local fadeTime = 0.3
  if showDelay == nil then
    showDelay = 0
  elseif showDelay < 0 then
    showDelay = 0
  end
  self.showDelay = showDelay
  if forcePlay == nil then
    forcePlay = false
  end
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local canCompleteObjective = ObjectivesComponentRequestBus.Event.IsObjectiveReadyForCompletion(playerEntityId, self.objectiveId)
  TimingUtils:Delay(showDelay, self, function()
    if not canCompleteObjective then
      self:PlayFlashAtY(10, forcePlay)
    end
  end)
  self.ScriptedEntityTweener:Stop(self.entityId)
  self.ScriptedEntityTweener:Stop(self.Properties.Container)
  self.ScriptedEntityTweener:Set(self.entityId, {
    opacity = self.opacity,
    x = 0
  })
  self.ScriptedEntityTweener:PlayFromC(self.Properties.Container, 0.3, {opacity = 0, x = 20}, tweenerCommon.containerIn, showDelay + 0.5)
  TimingUtils:Delay(fadeTime + showDelay, self, callback)
  if self.objectiveEndTime then
    self.timeRemainingSeconds = 0
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function PinnedObjective:AnimateOut(callback)
  local fadeTime = 0.3
  self.ScriptedEntityTweener:PlayC(self.entityId, fadeTime, tweenerCommon.objectiveOut)
  TimingUtils:Delay(fadeTime, self, callback)
  if self.objectiveEndTime then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function PinnedObjective:PlayFlashAtY(yPos, forcePlay)
  if not forcePlay and self.isFlashPlaying then
    return
  end
  self.ScriptedEntityTweener:Stop(self.Properties.FlashContainer)
  self.ScriptedEntityTweener:Stop(self.Properties.FlashLine1)
  self.ScriptedEntityTweener:Stop(self.Properties.FlashLine2)
  self.ScriptedEntityTweener:Stop(self.Properties.FlashGlow)
  self.ScriptedEntityTweener:Stop(self.Properties.FlashLight)
  self.ScriptedEntityTweener:Stop(self.Properties.Effect)
  self.ScriptedEntityTweener:Stop(self.Properties.Pulse1)
  self.ScriptedEntityTweener:Stop(self.Properties.Pulse2)
  self.ScriptedEntityTweener:PlayC(self.Properties.FlashLine1, 0, tweenerCommon.flashStart)
  self.ScriptedEntityTweener:PlayC(self.Properties.FlashLine2, 0, tweenerCommon.flashStart)
  UiElementBus.Event.SetIsEnabled(self.Properties.FlashContainer, true)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.FlashContainer, yPos)
  UiElementBus.Event.SetIsEnabled(self.Properties.Effect, false)
  self.ScriptedEntityTweener:PlayC(self.Properties.FlashContainer, 2, tweenerCommon.flashContainerScaleTo1, 0, function()
    self.isFlashPlaying = false
    UiElementBus.Event.SetIsEnabled(self.Properties.FlashContainer, false)
  end)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine1, 0.8, {x = -2000, opacity = 0}, tweenerCommon.flashEnd)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine1, 0.5, {opacity = 1}, tweenerCommon.fadeOutHalfSec, 0.8)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine1, 0.5, {scaleY = 2.5}, tweenerCommon.flashScaleUp, 0.28, function()
    self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine1, 0.5, {scaleY = 3.5}, tweenerCommon.flashScaleDown)
  end)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine2, 0.8, {x = -2000, opacity = 0}, tweenerCommon.flashEnd)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine2, 0.5, {opacity = 1}, tweenerCommon.fadeOutHalfSec, 0.8)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine2, 0.5, {scaleY = 2.5}, tweenerCommon.flashScaleUp, 0.28, function()
    self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine2, 0.5, {scaleY = 3.5}, tweenerCommon.flashScaleDown)
  end)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashGlow, 0.1, {opacity = 0}, tweenerCommon.flashGlowIn, 0.4, function()
    self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashGlow, 0.83, {opacity = 1}, tweenerCommon.flashGlowOut)
  end)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLight, 0.1, {opacity = 0}, tweenerCommon.flashGlowIn, 0.4, function()
    self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLight, 0.83, {opacity = 1}, tweenerCommon.flashGlowOut)
  end)
  self.ScriptedEntityTweener:PlayC(self.Properties.Effect, 0.4, tweenerCommon.flashEffectPosYTo0, 0, function()
    UiElementBus.Event.SetIsEnabled(self.Properties.Effect, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.Effect, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.Effect)
  end)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.Effect, 0.65, {opacity = 1}, tweenerCommon.flashEffectOut, 0.78, function()
    UiFlipbookAnimationBus.Event.Stop(self.Properties.Effect)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.Effect, 0)
    UiElementBus.Event.SetIsEnabled(self.Properties.Effect, false)
  end)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.Pulse1, 1.2, {
    scaleX = 0,
    scaleY = 0,
    opacity = 1
  }, tweenerCommon.pulseShow, 0.4)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.Pulse2, 1.2, {
    scaleX = 0,
    scaleY = 0,
    opacity = 1
  }, tweenerCommon.pulseShow, 0.55)
  self.audioHelper:PlaySound(self.audioHelper.PinnedObjective)
  self.isFlashPlaying = true
end
function PinnedObjective:RefreshTitle()
  local missionParams = ObjectiveRequestBus.Event.GetCreationParams(self.objectiveId)
  local title, _ = ObjectivesDataHandler:GetMissionTitleAndDescription(missionParams, self.objectiveId)
  if self.isRecipe then
    title = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@objective_recipetemplate", title)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, title, eUiTextSet_SetLocalized)
end
function PinnedObjective:RefreshDescriptions()
  self:RefreshTitle()
  for i = 0, #self.Tasks do
    if UiElementBus.Event.IsEnabled(self.Properties.Tasks[i]) then
      self.Tasks[i]:RefreshDescription()
    end
  end
end
function PinnedObjective:SetOpacity(opacity)
  if opacity ~= self.opacity then
    self.opacity = opacity
    if UiElementBus.Event.IsEnabled(self.entityId) then
      self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
        opacity = self.opacity,
        ease = "QuadOut"
      })
    end
  end
end
function PinnedObjective:OnObjectiveCompleted()
  self:UpdateObjectiveStatus(true)
end
function PinnedObjective:OnObjectiveFailed()
  self:UpdateObjectiveStatus(false)
end
function PinnedObjective:OnObjectiveChanged()
  self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
    opacity = 1,
    ease = "QuadOut",
    onComplete = function()
      if self.opacity ~= 1 then
        self.ScriptedEntityTweener:Play(self.entityId, 1, {
          opacity = self.opacity,
          ease = "QuadInOut"
        })
      end
    end
  })
  self:UpdateTerritoryHighlight()
end
function PinnedObjective:IsMatchingTaskTerritory(territoryId)
  local poiTaskList = DynamicBus.ObjectivesLayer.Broadcast.GetObjectiveTasksByTerritoryId(territoryId)
  if poiTaskList then
    for i, curTaskIdString in ipairs(poiTaskList) do
      local taskEntityTable = self.taskTablesById[curTaskIdString]
      if taskEntityTable then
        return true
      end
    end
  end
  return false
end
function PinnedObjective:UpdateTerritoryHighlight()
  if not self.enablePoiHighlight then
    return
  end
  local isObjectiveLocation = self:IsMatchingTaskTerritory(self.currentTerritoryId)
  if not isObjectiveLocation then
    local playerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
    local territories = MapComponentBus.Broadcast.GetContainingTerritories(playerPosition)
    if territories and 0 < #territories then
      for i = 1, #territories do
        if territories[i] and self:IsMatchingTaskTerritory(territories[i]) then
          isObjectiveLocation = true
          break
        end
      end
    end
  end
  if self.isObjectiveLocation ~= isObjectiveLocation then
    local animDelay = 0
    if isObjectiveLocation then
      animDelay = 0.6
      UiElementBus.Event.SetIsEnabled(self.Properties.TitleBg, true)
      self.ScriptedEntityTweener:PlayC(self.Properties.TitleBg, 0.3, tweenerCommon.fadeInQuadOut, animDelay)
      self.titleColorOverride = self.UIStyle.COLOR_GRAY_20
      TimingUtils:Delay(animDelay, self, function()
        self:RefreshObjectiveIconAndTextColor()
      end)
      self:PlayFlashAtY(10)
    else
      self.ScriptedEntityTweener:PlayC(self.Properties.TitleBg, 0.3, tweenerCommon.fadeOutQuadIn, 0, function()
        UiElementBus.Event.SetIsEnabled(self.Properties.TitleBg, false)
        self:RefreshObjectiveIconAndTextColor()
      end)
      self.titleColorOverride = nil
    end
    self:RefreshObjectiveIconAndTextColor(0.15, animDelay)
  else
    self:RefreshObjectiveIconAndTextColor()
  end
  self.isObjectiveLocation = isObjectiveLocation
end
function PinnedObjective:UpdateTask(taskId)
  local taskIdString = taskId:ToString()
  if self.taskTablesById[taskIdString] then
    self.taskTablesById[taskIdString]:UpdateProgress()
  end
end
function PinnedObjective:UpdateObjectiveStatus(isComplete)
  self.isComplete = isComplete
  self.isFailed = not isComplete
end
function PinnedObjective:SetUpdatedCallback(command, table)
  self.updatedCallback = command
  self.updatedCallbackTable = table
end
function PinnedObjective:OnUnpinPressed()
  if self.objectiveId ~= nil then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local isTracked = ObjectivesComponentRequestBus.Event.IsObjectiveTracked(playerEntityId, self.objectiveId)
    ObjectivesComponentRequestBus.Event.SetObjectiveTracked(playerEntityId, self.objectiveId, not isTracked)
  end
end
function PinnedObjective:OnJournalPressed()
  if self.objectiveId ~= nil then
    DynamicBus.JournalScreen.Broadcast.OpenToObjectiveId(self.objectiveId)
  end
end
function PinnedObjective:OnMapPressed()
  if self.objectiveId ~= nil then
    local position = DynamicBus.ObjectivesLayer.Broadcast.GetObjectivePosition(self.objectiveId)
    if position then
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OpenMapPosition", position)
      LyShineManagerBus.Broadcast.SetState(2477632187)
    end
  end
end
function PinnedObjective:OnShutdown()
  TimingUtils:StopDelay(self)
end
return PinnedObjective

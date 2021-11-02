local PinnedObjectiveTask = {
  Properties = {
    Checkbox = {
      default = EntityId()
    },
    Checkmark = {
      default = EntityId()
    },
    Shadow = {
      default = EntityId()
    },
    TaskDescription = {
      default = EntityId()
    },
    Strikethrough = {
      default = EntityId()
    },
    ProgressText = {
      default = EntityId()
    }
  },
  progressString = "",
  progressNumerator = "",
  progressDenominator = "",
  PRIMARY_BOX_IMAGE = "lyshineui/images/objectives/hud/taskBoxPrimary.png",
  SECONDARY_BOX_IMAGE = "lyshineui/images/objectives/hud/taskBoxSecondary.png",
  TIMEOUT_FORMAT = "  <font color=%s>%s</font>",
  TIMEOUT_WARN_TIME = 60,
  TIMEOUT_ALERT_TIME = 30,
  height = 24,
  isFtue = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PinnedObjectiveTask)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local ScriptActionQueue = RequireScript("LyShineUI._Common.ScriptActionQueue")
local objectivesDataHandler = RequireScript("LyShineUI._Common.ObjectivesDataHandler")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function PinnedObjectiveTask:OnInit()
  BaseElement.OnInit(self)
  self.actionQueue = ScriptActionQueue:QueueCreate()
  self.boxColor = self.UIStyle.COLOR_GRAY_80
  UiImageBus.Event.SetColor(self.Properties.Checkbox, self.boxColor)
  self.progressColor = self.UIStyle.COLOR_GRAY_80
  local descriptionTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
    fontSize = self.UIStyle.FONT_SIZE_BODY_NEW,
    fontColor = self.UIStyle.COLOR_WHITE,
    characterSpacing = 0,
    fontEffect = self.UIStyle.FONT_EFFECT_DROP_SHADOW
  }
  local progressTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_BOLD,
    fontSize = self.UIStyle.FONT_SIZE_BODY_NEW,
    fontColor = self.UIStyle.COLOR_WHITE,
    characterSpacing = 0,
    fontEffect = self.UIStyle.FONT_EFFECT_DROP_SHADOW
  }
  SetTextStyle(self.Properties.TaskDescription, descriptionTextStyle)
  SetTextStyle(self.Properties.ProgressText, progressTextStyle)
  UiTextBus.Event.SetText(self.Properties.ProgressText, "")
  self.timerColorNormal = ColorRgbaToHexString(self.UIStyle.COLOR_WHITE)
  self.timerColorWarn = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW)
  self.timerColorAlert = ColorRgbaToHexString(self.UIStyle.COLOR_RED)
  self:SetTaskStyle(self.TASK_STYLE_NORMAL)
  self:SetTaskState(eObjectiveTaskState_Active)
  self:BusConnect(UiElementNotificationBus, self.entityId)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
end
function PinnedObjectiveTask:OnShutdown()
end
function PinnedObjectiveTask:SetTaskStyle(style)
  self.descriptionOffsets = UiOffsets(19, 0, 10, 20)
  self.style = style
end
function PinnedObjectiveTask:SetTaskById(taskId, level, index)
  if taskId == nil then
    return
  end
  if taskId ~= self.taskId then
    self.targetTime = nil
  end
  self.taskId = taskId
  self.level = level
  self.index = index
  self.isConsecutiveTask = index ~= nil
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
  self:BusDisconnect(self.objectiveTaskNotificationBusHandler)
  self.objectiveTaskNotificationBusHandler = self:BusConnect(ObjectiveTaskNotificationBus, self.taskId)
  local indentPerLevel = 24
  if level == nil then
    level = 0
  end
  local taskOffsets = UiTransform2dBus.Event.GetOffsets(self.entityId)
  taskOffsets.left = indentPerLevel * level
  UiTransform2dBus.Event.SetOffsets(self.entityId, taskOffsets)
  UiTextBus.Event.SetIsMarkupEnabled(self.Properties.TaskDescription, false)
  UiImageBus.Event.SetSpritePathname(self.Properties.Checkbox, level == 0 and self.PRIMARY_BOX_IMAGE or self.SECONDARY_BOX_IMAGE)
  local subtasks = ObjectiveTaskRequestBus.Event.GetTasks(self.taskId)
  self.targetNumber = ObjectiveTaskRequestBus.Event.GetTarget(self.taskId)
  self.hasProgress = #subtasks == 0 and self.targetNumber > 1
  if not self.hasProgress then
    self.progressString = ""
  end
  UiTransform2dBus.Event.SetOffsets(self.Properties.TaskDescription, self.descriptionOffsets)
  local hideProgress = ObjectiveTaskRequestBus.Event.GetHideProgress(self.taskId)
  if self.hasProgress and not hideProgress then
    self.progressDenominator = tostring(self.targetNumber)
    self.progressString = self.progressNumerator .. " / " .. self.progressDenominator
  end
  self:UpdateProgress(true)
  self:RefreshDescription()
end
function PinnedObjectiveTask:SetHandInTask(parentObjectiveId)
  if parentObjectiveId == nil then
    return
  end
  self.handInTaskId = parentObjectiveId
  self.taskState = nil
  self.taskId = nil
  UiImageBus.Event.SetSpritePathname(self.Properties.Checkbox, self.PRIMARY_BOX_IMAGE)
  local npcDestinationGenericName = ObjectiveRequestBus.Event.GetNpcDestinationGenericName(parentObjectiveId)
  local descriptionText = GetLocalizedReplacementText("@objective_hand_in_destination", {npcName = npcDestinationGenericName})
  self.hasProgress = false
  self.progressString = ""
  UiTransform2dBus.Event.SetOffsets(self.Properties.TaskDescription, self.descriptionOffsets)
  UiElementBus.Event.SetIsEnabled(self.Properties.Checkmark, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Strikethrough, false)
  self.ScriptedEntityTweener:PlayC(self.Properties.TaskDescription, 0, tweenerCommon.textToWhite)
  self.ScriptedEntityTweener:PlayC(self.Properties.Checkbox, 0, tweenerCommon.imgFillTo1Instant)
  self.ScriptedEntityTweener:PlayC(self.Properties.Checkbox, 0, tweenerCommon.imgToGray90)
  self:SetDescription(descriptionText)
  self:UpdateSize()
end
function PinnedObjectiveTask:UpdateSize()
  local descriptionHeight = UiTextBus.Event.GetTextHeight(self.Properties.TaskDescription)
  self.height = descriptionHeight
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
  if type(self.updateTaskPositions) == "function" and self.updateTaskPositionsTable then
    self.updateTaskPositions(self.updateTaskPositionsTable, self)
  end
  if type(self.objectiveUpdateCallback) == "function" and self.objectiveUpdatePositionsCallbackTable then
    self.objectiveUpdateCallback(self.objectiveUpdatePositionsCallbackTable, self)
  end
end
function PinnedObjectiveTask:SetUpdatedCallback(command, table)
  self.updatedCallback = command
  self.updatedCallbackTable = table
end
function PinnedObjectiveTask:SetUpdateTaskPositionsCallback(command, table)
  self.updateTaskPositions = command
  self.updateTaskPositionsTable = table
end
function PinnedObjectiveTask:SetObjectivePositionsCallback(command, table)
  self.objectiveUpdateCallback = command
  self.objectiveUpdatePositionsCallbackTable = table
end
function PinnedObjectiveTask:SetTaskState(taskState, skipAnimation)
  if self.taskId == nil then
    return
  end
  if self.taskState == taskState then
    skipAnimation = true
  end
  if taskState == eObjectiveTaskState_Complete or taskState == eObjectiveTaskState_CompleteActive then
    local prevComplete = self.isComplete
    self.isComplete = true
    self.isActive = false
    if not prevComplete and type(self.updatedCallback) == "function" and self.updatedCallbackTable then
      self.updatedCallback(self.updatedCallbackTable, self)
    end
  else
    self.isComplete = false
  end
  self.taskState = taskState
  local colorAnimTime = 0.4
  if skipAnimation then
    colorAnimTime = 0
  end
  local textAnim = tweenerCommon.textToWhite
  local imgAnim = tweenerCommon.imgToGray90
  UiElementBus.Event.SetIsEnabled(self.Properties.Checkmark, self.isComplete)
  UiElementBus.Event.SetIsEnabled(self.Properties.Strikethrough, self.isComplete)
  if self.isComplete then
    self.ScriptedEntityTweener:PlayC(self.Properties.Checkbox, 0, tweenerCommon.imgFillTo0Instant)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.Checkbox, 0, tweenerCommon.imgFillTo1Instant)
  end
  if self.taskState == eObjectiveTaskState_Active or self.taskState == eObjectiveTaskState_Inactive then
    if not self.isFtue and self.taskId and not self.tickBusHandler and self.taskState == eObjectiveTaskState_Active then
      self.tickInterval = ObjectiveTaskRequestBus.Event.GetRefreshDescriptionInterval(self.taskId) or 0
      local shouldTick = 0 < self.tickInterval
      local timeLimit = ObjectiveTaskRequestBus.Event.GetUIData(self.taskId, "TimeLimit")
      if timeLimit and 0 < timeLimit and timeLimit < GetMaxInt() then
        local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
        local taskStartTime = ObjectivesComponentRequestBus.Event.GetTaskStartTime(playerEntityId, self.taskId)
        self.targetTime = taskStartTime:AddDuration(Duration.FromSecondsUnrounded(timeLimit))
        UiTextBus.Event.SetIsMarkupEnabled(self.Properties.TaskDescription, true)
        shouldTick = true
        self.tickInterval = 1
      end
      self:SetIsTicking(shouldTick)
    end
    self.isActive = true
  elseif self.isComplete then
    textAnim = tweenerCommon.textToGray60
    imgAnim = tweenerCommon.imgToGray60
    if not skipAnimation then
      self.ScriptedEntityTweener:Set(self.Properties.Checkmark, {opacity = 0})
      self.ScriptedEntityTweener:PlayC(self.Properties.Checkmark, 0.3, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:Set(self.Properties.Strikethrough, {imgFill = 0})
      self.ScriptedEntityTweener:PlayC(self.Properties.Strikethrough, 0.4, tweenerCommon.imgFillTo1)
      self.audioHelper:PlaySound(self.audioHelper.Objectives_CompletedPinnedTask)
    else
      UiTransformBus.Event.SetScale(self.Properties.Checkmark, Vector2(1, 1))
      UiImageBus.Event.SetFillAmount(self.Properties.Strikethrough, 1)
    end
    self:SetIsTicking(false)
    self.isActive = false
  else
    textAnim = tweenerCommon.textToGray60
    imgAnim = tweenerCommon.imgToGray60
    self:SetIsTicking(false)
    self.isActive = false
  end
  self.ScriptedEntityTweener:PlayC(self.Properties.TaskDescription, colorAnimTime, textAnim)
  self.ScriptedEntityTweener:PlayC(self.Properties.ProgressText, colorAnimTime, textAnim)
  self.ScriptedEntityTweener:PlayC(self.Properties.Checkbox, colorAnimTime, imgAnim)
end
function PinnedObjectiveTask:SetDescription(description)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TaskDescription, description, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(self.Properties.ProgressText, self.progressString)
  local descriptionWidth = UiTextBus.Event.GetTextWidth(self.Properties.TaskDescription)
  local shadowWidth = (self.descriptionOffsets.left + descriptionWidth) * 1.3
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Shadow, shadowWidth)
  local strikethroughWidth = descriptionWidth + 6
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Strikethrough, strikethroughWidth)
end
function PinnedObjectiveTask:SetIsEnqueuing(isEnqueuing)
  if self.isEnqueuing == isEnqueuing then
    return
  end
  self.isEnqueuing = isEnqueuing
  self.actionQueue:SetIsEnqueuing(self.isEnqueuing)
  if not self.isEnqueuing then
    self.actionQueue:DoAll()
  end
end
function PinnedObjectiveTask:UpdateProgress(skipAnimation)
  if self.taskId == nil then
    return
  end
  local progressPercent = ObjectiveTaskRequestBus.Event.GetProgressPercent(self.taskId)
  if progressPercent == nil then
    progressPercent = 1
  end
  local taskState = ObjectiveTaskRequestBus.Event.GetState(self.taskId)
  if 1 <= progressPercent then
    taskState = eObjectiveTaskState_Complete
  end
  self:SetTaskState(taskState, skipAnimation)
  if not self.hasProgress or self.progressPercent == progressPercent then
    return
  end
  local barAnimTime = skipAnimation and 0 or 0.3
  local progressNumber = ObjectiveTaskRequestBus.Event.GetProgress(self.taskId)
  if progressNumber == nil or progressNumber > self.targetNumber then
    progressNumber = self.targetNumber
  end
  local hideProgress = ObjectiveTaskRequestBus.Event.GetHideProgress(self.taskId)
  if not hideProgress then
    self.progressNumerator = tostring(progressNumber)
    self.progressString = self.progressNumerator .. " / " .. self.progressDenominator
  else
    self.progressString = ""
  end
  if not skipAnimation and not self.isComplete then
    if type(self.updatedCallback) == "function" and self.updatedCallbackTable then
      self.updatedCallback(self.updatedCallbackTable, self)
    end
    if type(self.objectiveUpdateCallback) == "function" and self.objectiveUpdatePositionsCallbackTable then
      self.objectiveUpdateCallback(self.objectiveUpdatePositionsCallbackTable, self)
    end
    self.audioHelper:PlaySound(self.audioHelper.Objectives_UpdatedPinnedTask)
  end
  self.progressPercent = progressPercent
  self:RefreshDescription()
end
function PinnedObjectiveTask:SetPositionY(newY)
  self.positionY = newY
  UiTransformBus.Event.SetLocalPositionY(self.entityId, newY)
end
function PinnedObjectiveTask:GetPositionY()
  return self.positionY or 0
end
function PinnedObjectiveTask:GetHeight()
  return self.height
end
function PinnedObjectiveTask:OnTaskChanged(data)
  self.actionQueue:Add(self, self.UpdateProgress)
end
function PinnedObjectiveTask:OnTaskCompleted(data)
  self.actionQueue:Add(self, self.UpdateProgress)
end
function PinnedObjectiveTask:OnTaskActivated(data)
  self.actionQueue:Add(self, self.UpdateProgress)
end
function PinnedObjectiveTask:OnTick(deltaTime, timePoint)
  self.currentTickInterval = self.currentTickInterval - deltaTime
  if self.currentTickInterval <= 0 then
    self.currentTickInterval = self.tickInterval
    self:RefreshDescription()
  end
end
function PinnedObjectiveTask:OnUiElementAndAncestorsEnabledChanged(isEnabled)
  if not isEnabled then
    self:SetIsTicking(false)
  end
end
function PinnedObjectiveTask:SetIsTicking(isTicking)
  if isTicking then
    if not self.tickBusHandler then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
      self.currentTickInterval = self.tickInterval
    end
  elseif self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function PinnedObjectiveTask:RefreshDescription()
  if not self.taskId then
    if self.handInTaskId then
      self:SetHandInTask(self.handInTaskId)
    end
    return
  end
  local description = ObjectiveTaskRequestBus.Event.GetDescription(self.taskId) or ""
  local objectiveId = ObjectiveTaskRequestBus.Event.GetObjectiveInstanceId(self.taskId)
  if objectiveId then
    local creationParams = ObjectiveRequestBus.Event.GetCreationParams(objectiveId)
    if creationParams.missionId ~= 0 then
      description = objectivesDataHandler:GetLocalizedDescText(description, creationParams)
    end
  end
  if self.targetTime then
    local remainingTime = self.targetTime:Subtract(timeHelpers:ServerNow()):ToSeconds()
    remainingTime = math.max(remainingTime, 0)
    local timeRemainingText = timeHelpers:ConvertSecondsToHrsMinSecString(remainingTime)
    local color = self.timerColorNormal
    if remainingTime < self.TIMEOUT_ALERT_TIME then
      color = self.timerColorAlert
    elseif remainingTime < self.TIMEOUT_WARN_TIME then
      color = self.timerColorWarn
    end
    description = description .. string.format(self.TIMEOUT_FORMAT, color, timeRemainingText)
  end
  local indentLength = #self.progressString * 2 + 1
  if 1 < indentLength then
    description = string.format("%+" .. indentLength .. "s%s", " - ", description)
  end
  self:SetDescription(description)
  self:UpdateSize()
end
return PinnedObjectiveTask

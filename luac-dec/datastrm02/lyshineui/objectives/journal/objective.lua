local Objective = {
  Properties = {
    DifficultyText = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    PinButton = {
      default = EntityId()
    },
    AbandonButton = {
      default = EntityId()
    },
    TimeRemaining = {
      default = EntityId()
    },
    TimeRemainingIcon = {
      default = EntityId()
    },
    RewardsBox = {
      default = EntityId()
    },
    RewardsTitle = {
      default = EntityId()
    },
    RewardsList = {
      default = EntityId()
    },
    Rewards = {
      default = {
        EntityId()
      }
    },
    ItemRewardIcon = {
      default = EntityId()
    },
    TasksBox = {
      default = EntityId()
    },
    TasksTitle = {
      default = EntityId()
    },
    TaskContainer = {
      default = EntityId()
    },
    Task = {
      default = EntityId()
    },
    IngredientsContainer = {
      default = EntityId()
    },
    Ingredients = {
      default = {
        EntityId()
      }
    },
    FrameGlow = {
      default = EntityId()
    },
    PinnedFlag = {
      default = EntityId()
    },
    FlagBg = {
      default = EntityId()
    },
    ShareButton = {
      default = EntityId()
    },
    ViewInMapButton = {
      default = EntityId()
    }
  },
  TIME_REMAINING_YELLOW = 600,
  TIME_REMAINING_RED = 300,
  MIN_HEIGHT = 168,
  MAX_OBJECTIVE_TASKS = 25
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Objective)
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local ObjectivesDataHandler = RequireScript("LyShineUI._Common.ObjectivesDataHandler")
local ObjectiveTypeData = RequireScript("LyShineUI.Objectives.ObjectiveTypeData")
function Objective:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.Tasks = {
    self.Task
  }
  SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_OBJECTIVE_JOURNAL_OBJECTIVE)
  local bodyTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
    fontSize = 22,
    fontColor = self.UIStyle.COLOR_GRAY_60,
    characterSpacing = 0
  }
  SetTextStyle(self.Properties.TimeRemaining, bodyTextStyle)
  SetTextStyle(self.Properties.Description, bodyTextStyle)
  local subtitleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 16,
    fontColor = self.UIStyle.COLOR_TAN,
    characterSpacing = 100
  }
  SetTextStyle(self.Properties.TasksTitle, subtitleStyle)
  SetTextStyle(self.Properties.RewardsTitle, subtitleStyle)
  self.timeColor = self.UIStyle.COLOR_GRAY_80
  self.rewardListItemHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Rewards[0])
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
    if self.objectiveId then
      self:SetObjectiveId(self.objectiveId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "javelin.enable-objective-sharing", function(self, enableObjectiveSharing)
    self.enableObjectiveSharing = enableObjectiveSharing
    if self.Properties.ShareButton:IsValid() and enableObjectiveSharing == false then
      UiElementBus.Event.SetIsEnabled(self.Properties.ShareButton, false)
    end
  end)
end
function Objective:OnShutdown()
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function Objective:EnableTimer(enable)
  if self.objectiveEndTime then
    if self.tickBusHandler then
      self:BusDisconnect(self.tickBusHandler)
      self.tickBusHandler = nil
    end
    if enable then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  end
end
function Objective:OnTick(deltaTime, timePoint)
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
function Objective:UpdatePinStatus()
  local isPinned = ObjectivesComponentRequestBus.Event.IsObjectiveTracked(self.playerEntityId, self.objectiveId)
  if isPinned ~= self.isPinned then
    self.isPinned = isPinned
    self:UpdatePinnedVisuals()
  end
end
function Objective:ChangePinStatus()
  self.isPinned = ObjectivesComponentRequestBus.Event.IsObjectiveTracked(self.playerEntityId, self.objectiveId)
  ObjectivesComponentRequestBus.Event.SetObjectiveTracked(self.playerEntityId, self.objectiveId, not self.isPinned)
  self.isPinned = not self.isPinned
  self:UpdatePinnedVisuals()
  if self.pinnedCallbackFn then
    self.pinnedCallbackFn(self.pinnedCallbackTable)
  end
end
function Objective:SetPinnedCallback(callbackTable, callbackFn)
  self.pinnedCallbackTable = callbackTable
  self.pinnedCallbackFn = callbackFn
end
function Objective:ResetObjective()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@objective_reset", "@objective_resetpopup_body", "reset_objective_id", self, self.OnPopupResult)
end
function Objective:AbandonObjective()
  local title = "@owg_action_abandon"
  local body = "@owg_abandonpopup_body"
  if self.isRecipe then
    title = "@objective_recipe_abandontitle"
    body = "@objective_recipe_abandonbody"
  end
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, title, body, "abandon_mission_id", self, self.OnPopupResult)
end
function Objective:ShareObjective()
  ObjectivesComponentRequestBus.Event.RequestShareObjectiveWithGroup(self.playerEntityId, self.objectiveId)
end
function Objective:ViewObjectiveInMap()
  local position = DynamicBus.ObjectivesLayer.Broadcast.GetObjectivePosition(self.objectiveId)
  if position then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OpenMapPosition", position)
    LyShineManagerBus.Broadcast.SetState(2477632187)
  end
end
function Objective:OnPopupResult(result, eventId)
  if result == ePopupResult_Yes then
    if eventId == "abandon_mission_id" then
      ObjectivesComponentRequestBus.Event.AbandonObjective(self.playerEntityId, self.objectiveId)
    elseif eventId == "reset_objective_id" then
      ObjectivesComponentRequestBus.Event.ResetObjective(self.playerEntityId, self.objectiveId)
    end
  end
end
function Objective:SetObjectiveId(objectiveId)
  if self.objectiveId ~= objectiveId then
    self.hasStyledButtons = false
  end
  self.objectiveId = objectiveId
  if not self.playerEntityId then
    return
  end
  self.objectiveType = ObjectiveRequestBus.Event.GetType(self.objectiveId)
  local typeData = ObjectiveTypeData:GetType(self.objectiveType)
  self:BusDisconnect(self.objectiveNotificationBusHandler)
  self.objectiveNotificationBusHandler = self:BusConnect(ObjectiveNotificationBus, objectiveId)
  if not self.hasStyledButtons then
    self.PinButton:SetButtonSingleIconSize(12)
    self.PinButton:SetCallback(self.ChangePinStatus, self)
    if ObjectiveRequestBus.Event.CanBeAbandoned(self.objectiveId) then
      self.AbandonButton:SetButtonSingleIconSize(12)
      self.AbandonButton:SetButtonSingleIconPath("lyshineui/images/icons/misc/icon_close.png")
      self.AbandonButton:SetText("@objective_abandon")
      self.AbandonButton:SetCallback(self.AbandonObjective, self)
      self.AbandonButton:PositionButtonSingleIconToText()
      UiElementBus.Event.SetIsEnabled(self.Properties.AbandonButton, true)
    elseif ObjectiveRequestBus.Event.CanBeReset(self.objectiveId) then
      self.AbandonButton:SetButtonSingleIconPath(nil)
      self.AbandonButton:SetText("@objective_reset")
      self.AbandonButton:SetCallback(self.ResetObjective, self)
      UiElementBus.Event.SetIsEnabled(self.Properties.AbandonButton, true)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.AbandonButton, false)
    end
    self.hasStyledButtons = true
  end
  self.isPinned = ObjectivesComponentRequestBus.Event.IsObjectiveTracked(self.playerEntityId, self.objectiveId)
  self:UpdatePinnedVisuals(true)
  local missionParams = ObjectiveRequestBus.Event.GetCreationParams(self.objectiveId)
  local titleText, descriptionText = ObjectivesDataHandler:GetMissionTitleAndDescription(missionParams, self.objectiveId, true)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, titleText, eUiTextSet_SetLocalized)
  local titleTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.Title)
  local titleTextPos = UiTransformBus.Event.GetLocalPositionY(self.Properties.Title)
  local textBottomPadding = 20
  local hasDescription = descriptionText ~= nil and descriptionText ~= "" and self.objectiveType ~= eObjectiveType_Crafting
  local descriptionHeight = 0
  local descSpacing = 10
  local objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(self.objectiveId)
  if self.objectiveType ~= eObjectiveType_Darkness_Minor and self.objectiveType ~= eObjectiveType_Darkness_Major and self.objectiveType ~= eObjectiveType_POI and self.objectiveType ~= eObjectiveType_Dungeon and self.objectiveType ~= eObjectiveType_Arena and self.objectiveType ~= eObjectiveType_DefendObject and self.objectiveType ~= eObjectiveType_DynamicPOI then
    local difficulty = objectiveData.difficulty
    if 0 < difficulty then
      local difficultyString = "@objective_difficulty_" .. tostring(difficulty)
      local difficultyColor = self.UIStyle["COLOR_DIFFICULTY_" .. tostring(difficulty)]
      UiTextBus.Event.SetTextWithFlags(self.Properties.DifficultyText, difficultyString, eUiTextSet_SetLocalized)
      if difficultyColor ~= nil then
        UiTextBus.Event.SetColor(self.Properties.DifficultyText, difficultyColor)
      end
      descSpacing = 32
    else
      UiTextBus.Event.SetText(self.Properties.DifficultyText, "")
    end
  else
    UiTextBus.Event.SetText(self.Properties.DifficultyText, "")
  end
  if hasDescription then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Description, descriptionText, eUiTextSet_SetLocalized)
    descriptionHeight = UiTextBus.Event.GetTextHeight(self.Properties.Description) + descSpacing
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Description, descSpacing)
  else
    UiTextBus.Event.SetText(self.Properties.Description, "")
  end
  local textHeight = titleTextHeight + titleTextPos + descriptionHeight + textBottomPadding
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Description, descriptionHeight)
  local rewardsBottomPadding = 20
  local rewardsHeight = 0
  local missionId = missionParams and missionParams.missionId or nil
  local rewards = ObjectiveDataHelper:GetRewardData(self.objectiveId, missionId)
  UiElementBus.Event.SetIsEnabled(self.Properties.RewardsBox, 0 < #rewards)
  if 0 < #rewards then
    local layoutIndex = 0
    local nonItemRewardsShowing = 0
    local isItemRewardShowing = false
    for i = 1, #rewards do
      local rewardData = rewards[i]
      if rewardData.type ~= ObjectiveDataHelper.REWARD_TYPES.ITEM and rewardData.type ~= ObjectiveDataHelper.REWARD_TYPES.RECIPE then
        local rewardLayoutId = self.Properties.Rewards[layoutIndex]
        local rewardLayout = self.registrar:GetEntityTable(rewardLayoutId)
        if rewardLayout then
          UiElementBus.Event.SetIsEnabled(rewardLayoutId, true)
          rewardLayout:SetRewardType(rewardData.type)
          rewardEvent = ObjectiveDataHelper:GetRewardEventData(self.objectiveId, missionId)
          if rewardData.type == ObjectiveDataHelper.REWARD_TYPES.FACTION_INFLUENCE then
            local finalText = "@owg_rewardtype_warinfluence_low"
            if rewardEvent.contributionLevel == eGameEventContributionLevel_Medium then
              finalText = "@owg_rewardtype_warinfluence_med"
            elseif rewardEvent.contributionLevel == eGameEventContributionLevel_High then
              finalText = "@owg_rewardtype_warinfluence_high"
            end
            local rewardValue = LyShineScriptBindRequestBus.Broadcast.LocalizeText(finalText)
            rewardLayout:SetRewardValue(rewardValue)
          elseif rewardData.type == ObjectiveDataHelper.REWARD_TYPES.CATEGORICAL and rewardData.shouldShowAsObjectiveReward then
            rewardLayout:SetRewardType(rewardData.type, nil, rewardData.displayName, rewardData.iconPath)
            rewardLayout:SetRewardValue(rewardData.displayValue)
          elseif rewardData.type ~= ObjectiveDataHelper.REWARD_TYPES.CATEGORICAL then
            rewardLayout:SetRewardValue(rewardData.value)
          end
          if rewardData.type ~= ObjectiveDataHelper.REWARD_TYPES.CATEGORICAL or rewardData.shouldShowAsObjectiveReward then
            nonItemRewardsShowing = nonItemRewardsShowing + 1
            layoutIndex = layoutIndex + 1
          end
        else
          Debug.Log("[WARNING] Not enough reward items available for objective")
        end
      elseif rewardData.type ~= ObjectiveDataHelper.REWARD_TYPES.RECIPE then
        local descriptor = ItemDescriptor()
        descriptor.itemId = Math.CreateCrc32(rewardData.value)
        self.ItemRewardIcon:SetItemByDescriptor(descriptor)
        self.ItemRewardIcon:SetTooltipEnabled(true)
        isItemRewardShowing = true
      end
    end
    local rewardsListTop = UiTransformBus.Event.GetLocalPositionY(self.Properties.RewardsList)
    local itemRewardHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ItemRewardIcon)
    rewardsHeight = rewardsListTop + rewardsBottomPadding + nonItemRewardsShowing * self.rewardListItemHeight
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemRewardIcon, isItemRewardShowing)
    if isItemRewardShowing then
      local rewardYPos = self.rewardListItemHeight * nonItemRewardsShowing
      local itemSpacing = 10
      UiTransformBus.Event.SetLocalPositionY(self.Properties.ItemRewardIcon, rewardYPos + itemSpacing)
      rewardsHeight = rewardsHeight + itemRewardHeight + itemSpacing
      UiCanvasBus.Event.RecomputeChangedLayouts(self.canvasId)
    end
    for i = layoutIndex, #self.Properties.Rewards do
      UiElementBus.Event.SetIsEnabled(self.Properties.Rewards[i], false)
    end
  end
  local taskIds = ObjectiveRequestBus.Event.GetTasks(self.objectiveId)
  if taskIds == nil then
    return
  end
  self.containerTaskId = taskIds[1]
  self.isRecipe = self.objectiveType == eObjectiveType_Crafting
  self.taskIteration = 1
  UiElementBus.Event.SetIsEnabled(self.Properties.TaskContainer, not self.isRecipe)
  UiElementBus.Event.SetIsEnabled(self.Properties.IngredientsContainer, self.isRecipe)
  local tasksBottomPadding = 20
  local tasksHeight = UiTransformBus.Event.GetLocalPositionY(self.Properties.TaskContainer) + tasksBottomPadding
  if not self.isRecipe then
    self.nextTaskY = 0
    for i = 1, #taskIds do
      self:SetupTask(taskIds[i], 0)
    end
    local objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(self.objectiveId)
    if objectiveData ~= nil and objectiveData.npcDestinationId ~= GetNilCrc() then
      self:SetupHandInTask()
    end
    for i = self.taskIteration, #self.Tasks do
      UiElementBus.Event.SetIsEnabled(self.Tasks[i].entityId, false)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.TasksTitle, "@objective_tasks", eUiTextSet_SetLocalized)
    tasksHeight = tasksHeight + self.nextTaskY
  else
    taskIds = ObjectiveTaskRequestBus.Event.GetTasks(self.containerTaskId)
    for i = 1, #taskIds do
      self:SetupIngredient(taskIds[i])
    end
    local index = self.taskIteration - 1
    for i = index, #self.Properties.Ingredients do
      UiElementBus.Event.SetIsEnabled(self.Properties.Ingredients[i], false)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.TasksTitle, "@objective_ingredients", eUiTextSet_SetLocalized)
    tasksHeight = tasksHeight + UiTransform2dBus.Event.GetLocalHeight(self.Properties.IngredientsContainer)
    UiElementBus.Event.SetIsEnabled(self.Properties.DifficultyText, false)
  end
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
  local timerDataLayerKey = string.format("Hud.LocalPlayer.MissionTimers.%08x.TargetTime", self.objectiveId.value)
  self.objectiveEndTime = self.dataLayer:GetDataFromNode(timerDataLayerKey)
  UiElementBus.Event.SetIsEnabled(self.Properties.TimeRemaining, self.objectiveEndTime ~= nil)
  self.timeRemainingSeconds = 0
  if self.enableObjectiveSharing and self.Properties.ShareButton:IsValid() then
    self.ShareButton:SetText("@ui_shareObjective")
    self.ShareButton:SetCallback(self.ShareObjective, self)
    local enableShareButton = false
    local groupId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
    local isInGroup = groupId and groupId:IsValid()
    if isInGroup then
      enableShareButton = objectiveData and objectiveData.canBeShared
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.ShareButton, enableShareButton)
  end
  if self.Properties.ViewInMapButton:IsValid() then
    self.ViewInMapButton:SetText("@ui_viewinmap")
    self.ViewInMapButton:SetCallback(self.ViewObjectiveInMap, self)
    local enableButton = false
    local position = DynamicBus.ObjectivesLayer.Broadcast.GetObjectivePosition(self.objectiveId)
    enableButton = position ~= nil
    UiElementBus.Event.SetIsEnabled(self.Properties.ViewInMapButton, enableButton)
  end
  local outerMargin = 12
  local totalHeight = math.max(rewardsHeight, tasksHeight, textHeight, self.MIN_HEIGHT)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.RewardsBox, totalHeight)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.TasksBox, totalHeight)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, totalHeight + outerMargin)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, totalHeight + outerMargin)
  self:RefreshObjectiveIconAndTextColor()
end
function Objective:CreateTaskIfNeeded()
  if self.Tasks[self.taskIteration] == nil and CountAssociativeTable(self.Tasks) < self.MAX_OBJECTIVE_TASKS then
    local taskParent = UiElementBus.Event.GetParent(self.Properties.Task)
    local clonedElement = CloneUiElement(self.canvasId, self.registrar, self.Properties.Task, taskParent, true)
    self.Tasks[self.taskIteration] = clonedElement
  end
end
function Objective:SetupTask(taskId, level, index)
  self:CreateTaskIfNeeded()
  local isConsecutive = ObjectiveTaskRequestBus.Event.ContainsConsecutiveTasks(taskId)
  local isHidden = ObjectiveTaskRequestBus.Event.GetIsHidden(taskId)
  if isHidden or taskId == self.containerTaskId then
    level = level - 1
  else
    local taskTable = self.Tasks[self.taskIteration]
    if level == 0 then
      taskTable:SetTaskStyle(taskTable.TASK_STYLE_LARGE)
      if self.taskIteration ~= 0 then
        self.nextTaskY = self.nextTaskY + 6
      end
    else
      taskTable:SetTaskStyle(taskTable.TASK_STYLE_NORMAL)
    end
    taskTable:SetTaskById(taskId, level, index)
    taskTable:SetPositionY(self.nextTaskY)
    self.nextTaskY = self.nextTaskY + taskTable:GetHeight()
    UiElementBus.Event.SetIsEnabled(self.Tasks[self.taskIteration].entityId, true)
    self.taskIteration = self.taskIteration + 1
  end
  local subtaskIds = ObjectiveTaskRequestBus.Event.GetTasks(taskId)
  if 0 < #subtaskIds then
    local hideChildren = ObjectiveTaskRequestBus.Event.GetHideChildren(taskId)
    if not hideChildren then
      for i = 1, #subtaskIds do
        if isConsecutive then
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
function Objective:SetupHandInTask()
  self:CreateTaskIfNeeded()
  self.handInTaskIndex = self.taskIteration
  local taskTable = self.Tasks[self.taskIteration]
  taskTable:SetTaskStyle(taskTable.TASK_STYLE_LARGE)
  taskTable:SetHandInTask(self.objectiveId)
  self.nextTaskY = self.nextTaskY + 6
  taskTable:SetPositionY(self.nextTaskY)
  self.nextTaskY = self.nextTaskY + taskTable:GetHeight()
  UiElementBus.Event.SetIsEnabled(self.Tasks[self.taskIteration].entityId, true)
  self.taskIteration = self.taskIteration + 1
end
function Objective:SetupIngredient(taskId)
  local index = self.taskIteration - 1
  if self.Properties.Ingredients[index] ~= nil then
    local isHidden = ObjectiveTaskRequestBus.Event.GetIsHidden(taskId)
    if not isHidden then
      self.Ingredients[index]:SetTaskById(taskId)
      UiElementBus.Event.SetIsEnabled(self.Properties.Ingredients[index], true)
      self.taskIteration = self.taskIteration + 1
    end
  end
end
function Objective:OnObjectiveHandInToNpc()
  if self.handInTaskIndex ~= nil and self.Tasks[self.handInTaskIndex] ~= nil then
    local taskTable = self.Tasks[self.handInTaskIndex]
    taskTable:SetTaskState(eObjectiveTaskState_Active, false)
  end
end
function Objective:UpdatePinnedVisuals(skipAnimation)
  if self.isPinned then
    self.PinButton:SetText("@objective_unpin")
    self.PinButton:SetButtonSingleIconPath("lyshineui/images/icons/objectives/icon_unpin.png")
    UiElementBus.Event.SetIsEnabled(self.Properties.FrameGlow, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.PinnedFlag, true)
    UiTextBus.Event.SetColor(self.Properties.Title, self.UIStyle.COLOR_YELLOW_GOLD)
    local endingGlowOpacity = 1
    if skipAnimation then
      self.ScriptedEntityTweener:Set(self.Properties.FrameGlow, {opacity = endingGlowOpacity})
      self.ScriptedEntityTweener:Set(self.Properties.PinnedFlag, {opacity = 1})
      self.ScriptedEntityTweener:Set(self.Properties.FlagBg, {scaleX = 1})
      self.ScriptedEntityTweener:Set(self.Properties.ButtonContainer, {y = 0})
    else
      self.ScriptedEntityTweener:Play(self.Properties.FrameGlow, 0.15, {opacity = 1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.FrameGlow, 0.4, {
        opacity = endingGlowOpacity,
        delay = 0.15,
        ease = "QuadInOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.PinnedFlag, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadInOut"})
      self.ScriptedEntityTweener:Play(self.Properties.FlagBg, 0.5, {scaleX = 0.7}, {scaleX = 1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Stop(self.Properties.ButtonContainer)
      self.ScriptedEntityTweener:Play(self.Properties.ButtonContainer, 0.4, {y = 0, ease = "QuadInOut"})
    end
    self.PinButton:SetEnabled(true)
    self.PinButton:SetTooltip(nil)
  else
    self.PinButton:SetText("@objective_pin")
    self.PinButton:SetButtonSingleIconPath("lyshineui/images/icons/objectives/icon_pin.png")
    UiTextBus.Event.SetColor(self.Properties.Title, self.UIStyle.COLOR_TAN_LIGHT)
    if skipAnimation then
      UiElementBus.Event.SetIsEnabled(self.Properties.FrameGlow, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PinnedFlag, false)
      self.ScriptedEntityTweener:Set(self.Properties.ButtonContainer, {y = -28})
    else
      self.ScriptedEntityTweener:Play(self.Properties.FrameGlow, 0.15, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(self.Properties.FrameGlow, false)
        end
      })
      self.ScriptedEntityTweener:Play(self.Properties.PinnedFlag, 0.15, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(self.Properties.PinnedFlag, false)
        end
      })
      self.ScriptedEntityTweener:Stop(self.Properties.ButtonContainer)
      self.ScriptedEntityTweener:Play(self.Properties.ButtonContainer, 0.4, {
        y = -28,
        delay = 0.15,
        ease = "QuadInOut"
      })
    end
  end
  self.PinButton:PositionButtonSingleIconToText()
end
function Objective:EnablePinButton(enableButton, tooltip)
  self.pinButtonEnabled = enableButton
  if self.pinningBlocked then
    self.PinButton:SetEnabled(false)
    self.PinButton:SetTooltip(self.pinningBlockedTooltip)
  elseif not self.isPinned then
    self.PinButton:SetEnabled(self.pinButtonEnabled)
    self.PinButton:SetTooltip(tooltip)
  else
    self.PinButton:SetEnabled(true)
    self.PinButton:SetTooltip(nil)
  end
end
function Objective:SetPinningBlocked(isBlocked, tooltip)
  self.pinningBlocked = isBlocked
  self.pinningBlockedTooltip = tooltip
end
function Objective:RefreshObjectiveIconAndTextColor()
  if self.objectiveId then
    local iconPath, iconColor, isReadyToTurnIn, textColor = ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(self.objectiveId)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, iconPath)
    UiImageBus.Event.SetColor(self.Properties.Icon, iconColor)
    UiTextBus.Event.SetColor(self.Properties.Title, textColor)
  end
end
return Objective

local TownProject_AvailableTask = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    RewardsText = {
      default = EntityId()
    },
    RewardsCoinText = {
      default = EntityId()
    },
    RewardsCoinOnlyText = {
      default = EntityId()
    },
    ProjectPointText = {
      default = EntityId()
    },
    ProjectPointTextSmall = {
      default = EntityId()
    },
    ProjectPointIconSmall = {
      default = EntityId()
    },
    InProgress = {
      default = EntityId()
    },
    InProgressEffect = {
      default = EntityId()
    },
    RewardContainer = {
      default = EntityId()
    },
    CompleteContainer = {
      default = EntityId()
    },
    CompleteEffect = {
      default = EntityId()
    },
    UnavailableContainer = {
      default = EntityId()
    },
    AvailableContainer = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    HoverHash = {
      default = EntityId()
    },
    ActionText = {
      default = EntityId()
    },
    ActionButtonGlow = {
      default = EntityId()
    },
    Glow = {
      default = EntityId()
    },
    InnerFrame = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TownProject_AvailableTask)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function TownProject_AvailableTask:OnInit()
  BaseElement.OnInit(self)
  self.isEnabled = true
  self.newMission = false
  self.rewardsTextPositionY = UiTransformBus.Event.GetLocalPositionY(self.Properties.RewardsText)
end
function TownProject_AvailableTask:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
  if self.glowTimeline ~= nil then
    self.glowTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.glowTimeline)
  end
end
function TownProject_AvailableTask:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function TownProject_AvailableTask:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function TownProject_AvailableTask:GetHorizontalSpacing()
  return 15
end
function TownProject_AvailableTask:SetTaskData(taskData, projectId, callbackSelf, taskStartCallback, taskCompleteCallback, taskCancelCallback)
  UiElementBus.Event.SetIsEnabled(self.entityId, taskData ~= nil)
  self.callbackSelf = callbackSelf
  self.taskStartCallback = taskStartCallback
  self.taskCompleteCallback = taskCompleteCallback
  self.taskCancelCallback = taskCancelCallback
  self.taskData = taskData
  self.projectId = projectId
  if taskData then
    local isReadyToComplete = taskData:IsReadyToComplete()
    UiElementBus.Event.SetIsEnabled(self.Properties.CompleteContainer, isReadyToComplete)
    self.showPoints = taskData:GetCommunityGoalProgressAmount() > 0
    UiElementBus.Event.SetIsEnabled(self.Properties.ProjectPointText, self.showPoints)
    UiElementBus.Event.SetIsEnabled(self.Properties.ProjectPointTextSmall, self.showPoints)
    UiElementBus.Event.SetIsEnabled(self.Properties.ProjectPointIconSmall, self.showPoints)
    UiElementBus.Event.SetIsEnabled(self.Properties.RewardsCoinOnlyText, not self.showPoints)
    local coinIconSize = 26
    local coinTextSize = UiTextBus.Event.GetTextSize(self.Properties.RewardsCoinText).x
    if self.showPoints then
      UiTextBus.Event.SetTextWithFlags(self.Properties.ProjectPointText, taskData:GetProjectImpact(), eUiTextSet_SetAsIs)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ProjectPointTextSmall, taskData:GetProjectImpactDetailed(), eUiTextSet_SetAsIs)
      UiTextBus.Event.SetTextWithFlags(self.Properties.RewardsCoinText, taskData:GetRewardCoin(), eUiTextSet_SetAsIs)
      local projectIconSize = 25
      local spacing = 14
      local projectPointTextSize = UiTextBus.Event.GetTextSize(self.Properties.ProjectPointText).x
      local totalTextSize = projectIconSize + coinIconSize + spacing + projectPointTextSize + coinTextSize
      local centeredPos = totalTextSize / 2
      UiTransformBus.Event.SetLocalPositionX(self.Properties.ProjectPointText, -centeredPos)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.RewardsText, self.rewardsTextPositionY)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.RewardsCoinOnlyText, taskData:GetRewardCoin(), eUiTextSet_SetAsIs)
      local totalTextSize = coinIconSize + coinTextSize
      local centeredPos = totalTextSize / 2
      UiTransformBus.Event.SetLocalPositionX(self.Properties.RewardsCoinText, -centeredPos)
      local projectPointTextSmallPositionY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ProjectPointTextSmall)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.RewardsText, projectPointTextSmallPositionY)
    end
    if taskData.detailImage ~= "" then
      UiImageBus.Event.SetSpritePathname(self.Properties.Icon, taskData.detailImage)
      self.ScriptedEntityTweener:Set(self.Properties.Icon, {
        w = 242,
        h = 345,
        y = 0
      })
    else
      UiImageBus.Event.SetSpritePathname(self.Properties.Icon, taskData.image)
      self.ScriptedEntityTweener:Set(self.Properties.Icon, {
        w = 280,
        h = 140,
        y = 118
      })
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, taskData.title, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Description, taskData.description, eUiTextSet_SetLocalized)
    local durationText = timeHelpers:ConvertToShorthandString(taskData.timeLimit:ToSeconds())
    UiTextBus.Event.SetText(self.Properties.RewardsText, taskData:GetDetailedRewardsDisplayString())
    SetTextStyle(self.Properties.RewardsText, self.UIStyle.STANDARD_BODY_TEXT_SEMIBOLD_TAN)
    local isInProgress = taskData:IsInProgress()
    local isAvailable = self.taskData:IsAvailable()
    UiElementBus.Event.SetIsEnabled(self.Properties.InProgress, isInProgress)
    if isInProgress and not isReadyToComplete then
      UiElementBus.Event.SetIsEnabled(self.Properties.InProgressEffect, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.CompleteEffect, false)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ActionText, "@ui_cancel_mission", eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.ActionText, true)
    elseif isReadyToComplete then
      UiElementBus.Event.SetIsEnabled(self.Properties.CompleteEffect, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.InProgressEffect, false)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ActionText, "@ui_complete", eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.ActionText, true)
    elseif isAvailable then
      UiElementBus.Event.SetIsEnabled(self.Properties.CompleteEffect, false)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ActionText, "@ui_start_mission", eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.ActionText, true)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.ActionText, false)
    end
    local isUnavailable = not isAvailable and not isInProgress and not isReadyToComplete
    if self.newMission and isAvailable then
      UiImageBus.Event.SetColor(self.Properties.Glow, self.UIStyle.COLOR_GREEN)
      UiElementBus.Event.SetIsEnabled(self.Properties.Glow, true)
      self.ScriptedEntityTweener:Set(self.Properties.Glow, {
        scaleX = 1,
        scaleY = 1,
        opacity = 0
      })
      self.ScriptedEntityTweener:Play(self.Properties.Glow, 1, {opacity = 1}, {
        delay = 1,
        scaleX = 1.5,
        scaleY = 1.5,
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(self.Properties.Glow, false)
        end
      })
      self.newMission = false
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.UnavailableContainer, isUnavailable)
    UiElementBus.Event.SetIsEnabled(self.Properties.AvailableContainer, not isUnavailable)
    UiElementBus.Event.SetIsEnabled(self.Properties.InProgress, isInProgress)
    self.isEnabled = not isUnavailable
  else
    self.isEnabled = false
    self.newMission = false
  end
end
function TownProject_AvailableTask:OnFocus()
  if not self.isEnabled then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Hover, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.RewardContainer, true)
  UiElementBus.Event.SetIsEnabled(self.showPoints and self.Properties.ProjectPointText or self.Properties.RewardsCoinOnlyText, false)
  self.ScriptedEntityTweener:Play(self.Hover, 0.1, {opacity = 0}, {opacity = 1})
  self.ScriptedEntityTweener:Play(self.Properties.Icon, 0.1, {opacity = 1}, {opacity = 0.5})
  self.audioHelper:PlaySound(self.audioHelper.Screen_TerritoryStandingHover)
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.Properties.HoverHash, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
    self.timeline:Add(self.Properties.HoverHash, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.Properties.HoverHash, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.HoverHash, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.HoverHash, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  if not self.glowTimeline then
    self.glowTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.glowTimeline:Add(self.Properties.ActionButtonGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
    self.glowTimeline:Add(self.Properties.ActionButtonGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.glowTimeline:Add(self.Properties.ActionButtonGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.glowTimeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ActionButtonGlow, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ActionButtonGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.glowTimeline:Play()
    end
  })
end
function TownProject_AvailableTask:OnUnfocus()
  UiElementBus.Event.SetIsEnabled(self.Properties.Hover, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.RewardContainer, false)
  UiElementBus.Event.SetIsEnabled(self.showPoints and self.Properties.ProjectPointText or self.Properties.RewardsCoinOnlyText, true)
  self.ScriptedEntityTweener:Play(self.Hover, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.HoverHash, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.ActionButtonGlow, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.Icon, 0.1, {opacity = 0.5}, {opacity = 1})
  self.ScriptedEntityTweener:Play(self.Properties.HoverHash, 0.1, {opacity = 0, ease = "QuadIn"})
end
function TownProject_AvailableTask:OnClick()
  if not self.isEnabled then
    return
  end
  local isInProgress = self.taskData:IsInProgress()
  local isAvailable = self.taskData:IsAvailable()
  local isReadyToComplete = self.taskData:IsReadyToComplete()
  local playGlowAnim = false
  if isInProgress and not isReadyToComplete then
    self:OnCancelMission()
  elseif isReadyToComplete then
    self:OnCompleteMission()
  elseif isAvailable then
    playGlowAnim = true
    self:OnStartMission()
  end
  self.ScriptedEntityTweener:Play(self.entityId, 0.05, {
    scaleX = 0.9,
    scaleY = 0.9,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut",
    delay = 0.05
  })
  if playGlowAnim then
    UiImageBus.Event.SetColor(self.Properties.Glow, self.UIStyle.COLOR_WHITE)
    UiElementBus.Event.SetIsEnabled(self.Properties.Glow, true)
    self.ScriptedEntityTweener:Play(self.Properties.Glow, 1, {
      scaleX = 1,
      scaleY = 1,
      opacity = 1
    }, {
      scaleX = 1.5,
      scaleY = 1.5,
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.Glow, false)
      end
    })
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  self:OnUnfocus()
end
function TownProject_AvailableTask:OnStartMission(data)
  if self.callbackSelf and self.taskStartCallback then
    self.taskStartCallback(self.callbackSelf, self.taskData, self.projectId)
  end
end
function TownProject_AvailableTask:OnCancelMission(data)
  if self.callbackSelf and self.taskCancelCallback then
    self.newMission = true
    self.taskCancelCallback(self.callbackSelf, self.taskData)
  end
end
function TownProject_AvailableTask:OnCompleteMission(data)
  if self.callbackSelf and self.taskCompleteCallback then
    self.newMission = true
    self.taskCompleteCallback(self.callbackSelf, self.taskData)
  end
end
function TownProject_AvailableTask:ShowFlyoutMenu()
  if not self.isEnabled then
    return
  end
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu:IsLocked() then
    return
  end
  local flyoutVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible")
  if flyoutVisible and flyoutMenu.invokingEntityId == self.entityId then
    return
  end
  local rows = {}
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_ProjectTask,
    task = self.taskData,
    callbackSelf = self,
    callbackOnCancel = self.OnCancelMission,
    callbackOnStart = self.OnStartMission,
    callbackOnComplete = self.OnCompleteMission
  })
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
  flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
  flyoutMenu:EnableFlyoutDelay(true, 0.4)
  flyoutMenu:SetFadeInTime(0.4)
  flyoutMenu:SetOpenLocation(self.entityId)
  flyoutMenu:DockToCursor(true)
  flyoutMenu:Unlock()
  flyoutMenu:SetRowData(rows)
  flyoutMenu:SetSourceHoverOnly(true)
  flyoutMenu.openingContext = nil
end
return TownProject_AvailableTask

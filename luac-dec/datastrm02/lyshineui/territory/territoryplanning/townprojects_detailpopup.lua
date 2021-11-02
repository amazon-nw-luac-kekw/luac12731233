local TownProjects_DetailPopup = {
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
    MissionImageLarge = {
      default = EntityId()
    },
    RewardText = {
      default = EntityId()
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
    ImpactText = {
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
    PopupBackground = {
      default = EntityId()
    },
    PopupWindow = {
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
    },
    TimeToCompleteText = {
      default = EntityId()
    },
    GroupSizeText = {
      default = EntityId()
    },
    DifficultyText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TownProjects_DetailPopup)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function TownProjects_DetailPopup:OnInit()
  BaseElement.OnInit(self)
  self.CloseButton:SetCallback(self.OnClose, self)
  self.MapButton:SetCallback("ViewMap", self)
  self.MapButton:SetText("@owg_action_viewmap")
  self.StartButton:SetText("@owg_action_start")
  self.AbandonButton:SetText("@owg_action_abandon")
  self.ReplaceButton:SetText("@owg_action_replace")
  self.CompleteButton:SetText("@owg_action_complete")
  self.ReplaceButton:SetTooltip("@owg_tooltip_warning")
end
function TownProjects_DetailPopup:OnShutdown()
end
function TownProjects_DetailPopup:ViewMap()
  if self.taskData and self.taskData.mapLocation then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OpenMapMission", self.objectiveParams.missionId)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OpenMapPosition", self.mapLocation)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OpenMapHighlightId", self.highlightId)
    LyShineManagerBus.Broadcast.SetState(2477632187)
  end
end
function TownProjects_DetailPopup:OnClose()
  if self.IsClosing then
    return
  end
  self.IsClosing = true
  self.ScriptedEntityTweener:Play(self.Properties.PopupWindow, 0.3, {opacity = 1, y = 0}, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      self.IsClosing = false
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
end
function TownProjects_DetailPopup:ShowProjectTaskDetails(taskData, callbackTable, callbackFunction)
  self.taskData = taskData
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.PopupWindow, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.MissionTitle, taskData.title, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.MissionImageLarge, taskData.detailImage)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TimeToCompleteText, timeHelpers:ConvertToShorthandString(taskData.timeToCompleteMinutes), eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.GroupSizeText, tostring(taskData.groupSize), eUiTextSet_SetLocalized)
  local difficultyText = ""
  local difficulty = taskData.difficulty
  if difficulty == eObjectiveDifficulty_Easy then
    difficultyText = "@ui_easy"
  elseif difficulty == eObjectiveDifficulty_Medium then
    difficultyText = "@ui_medium"
  elseif difficulty == eObjectiveDifficulty_Hard then
    difficultyText = "@ui_hard"
  else
    difficultyText = "@ui_notavailable"
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.DifficultyText, difficultyText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ImpactText, taskData:GetProjectImpact(), eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.RewardText, taskData:GetRewardsDisplayString(), eUiTextSet_SetAsIs)
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local currentMissionId = ObjectivesComponentRequestBus.Event.GetCurrentMissionId(playerEntityId)
  local hasValidMission = currentMissionId ~= 0
  local isCurrentMission = taskData:IsInProgress()
  local canComplete = taskData:IsReadyToComplete()
  local isAvailable = taskData:IsAvailable()
  UiElementBus.Event.SetIsEnabled(self.Properties.StartButton, not isCurrentMission and not hasValidMission and isAvailable)
  UiElementBus.Event.SetIsEnabled(self.Properties.AbandonButton, isCurrentMission and hasValidMission and not canComplete)
  UiElementBus.Event.SetIsEnabled(self.Properties.ReplaceButton, not isCurrentMission and hasValidMission and isAvailable)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompleteButton, isCurrentMission and hasValidMission and canComplete)
  UiElementBus.Event.SetIsEnabled(self.Properties.MapButton, false)
  local durationText = timeHelpers:ConvertToShorthandString(taskData.timeLimit:ToSeconds())
  UiTextBus.Event.SetTextWithFlags(self.Properties.TimeLabel, durationText, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.KillPanel, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CollectPanel, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.TransportPanel, false)
  self.callbackTable = callbackTable
  self.callbackFunction = callbackFunction
  self.StartButton:SetCallback(self.OnConfirmationButtonClicked, self)
  self.AbandonButton:SetCallback(self.OnConfirmationButtonClicked, self)
  self.ReplaceButton:SetCallback(self.OnConfirmationButtonClicked, self)
  self.CompleteButton:SetCallback(self.OnConfirmationButtonClicked, self)
  self.StartButton:SetButtonStyle(self.StartButton.BUTTON_STYLE_CTA)
  self.CompleteButton:SetButtonStyle(self.CompleteButton.BUTTON_STYLE_CTA)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
end
function TownProjects_DetailPopup:OnConfirmationButtonClicked()
  self.callbackFunction(self.callbackTable, self.taskData)
  self:OnClose()
end
return TownProjects_DetailPopup

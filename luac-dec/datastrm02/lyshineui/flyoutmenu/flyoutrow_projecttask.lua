local FlyoutRow_ProjectTask = {
  Properties = {
    ContentContainer = {
      default = EntityId()
    },
    HeaderContainer = {
      default = EntityId()
    },
    TaskName = {
      default = EntityId()
    },
    DifficultyLevel = {
      default = EntityId()
    },
    TaskDescription = {
      default = EntityId()
    },
    Image = {
      default = EntityId()
    },
    GroupSizeContainer = {
      default = EntityId()
    },
    GroupSizeText = {
      default = EntityId()
    },
    TasksContainer = {
      default = EntityId()
    },
    Objective = {
      default = EntityId()
    },
    ProjectImpactContainer = {
      default = EntityId()
    },
    ProjectImpactText = {
      default = EntityId()
    },
    RewardsContainer = {
      default = EntityId()
    },
    RewardsText = {
      default = EntityId()
    },
    Divider1 = {
      default = EntityId()
    },
    Divider2 = {
      default = EntityId()
    },
    Divider3 = {
      default = EntityId()
    },
    Button = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_ProjectTask)
function FlyoutRow_ProjectTask:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.groupSizeHeight = UiLayoutCellBus.Event.GetTargetHeight(self.Properties.GroupSizeContainer)
  self.taskSizeHeight = UiLayoutCellBus.Event.GetTargetHeight(self.Properties.TasksContainer)
end
local difficultyTexts = {
  [eObjectiveDifficulty_None] = "",
  [eObjectiveDifficulty_Easy] = "@ui_easy",
  [eObjectiveDifficulty_Medium] = "@ui_medium",
  [eObjectiveDifficulty_Hard] = "@ui_hard"
}
function FlyoutRow_ProjectTask:SetData(data)
  if not data then
    Log("[FlyoutRow_ProjectTask] Error: invalid data passed to SetData")
    return
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.TaskName, data.task.title, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TaskDescription, data.task.description, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.Image, data.task.image)
  UiTextBus.Event.SetTextWithFlags(self.Properties.RewardsText, data.task:GetDetailedRewardsDisplayString(), eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DifficultyLevel, difficultyTexts[data.task.difficulty], eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.GroupSizeText, tostring(data.task.groupSize), eUiTextSet_SetAsIs)
  if tonumber(data.task.groupSize) > 0 then
    UiElementBus.Event.SetIsEnabled(self.Properties.GroupSizeContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.Divider2, true)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.GroupSizeContainer, self.groupSizeHeight)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.GroupSizeContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Divider2, false)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.GroupSizeContainer, 0)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.ProjectImpactText, tostring(data.task:GetProjectImpact()) .. " @ui_project_points_label", eUiTextSet_SetLocalized)
  local isInProgress = data.task:IsInProgress()
  local isAvailable = data.task:IsAvailable()
  local isReadyToComplete = data.task:IsReadyToComplete()
  if isInProgress and not isReadyToComplete then
    self.Button:SetCallback(data.callbackOnCancel, data.callbackSelf)
    self.Button:SetText("@ui_cancel_mission")
    self.Button:SetButtonStyle(self.Button.BUTTON_STYLE_DEFAULT)
  elseif isReadyToComplete then
    self.Button:SetCallback(data.callbackOnComplete, data.callbackSelf)
    self.Button:SetText("@ui_complete_mission")
    self.Button:SetButtonStyle(self.Button.BUTTON_STYLE_CTA)
  elseif isAvailable then
    self.Button:SetCallback(data.callbackOnStart, data.callbackSelf)
    self.Button:SetText("@ui_start_mission")
    self.Button:SetButtonStyle(self.Button.BUTTON_STYLE_CTA)
  end
  local containerHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ContentContainer)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, containerHeight)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, containerHeight)
end
return FlyoutRow_ProjectTask

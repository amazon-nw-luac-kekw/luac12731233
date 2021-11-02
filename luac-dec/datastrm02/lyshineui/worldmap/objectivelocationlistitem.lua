local ObjectiveLocationListItem = {
  Properties = {
    BG = {
      default = EntityId()
    },
    ObjectiveName = {
      default = EntityId()
    },
    ObjectiveIconImage = {
      default = EntityId()
    },
    Difficulty = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ObjectiveLocationListItem)
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local ObjectivesDataHandler = RequireScript("LyShineUI._Common.ObjectivesDataHandler")
local ObjectiveTypeData = RequireScript("LyShineUI.Objectives/ObjectiveTypeData")
local DifficultyColors = RequireScript("LyShineUI._Common.DifficultyColors")
function ObjectiveLocationListItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.ObjectiveName, self.UIStyle.FONT_STYLE_PINNED_OBJECTIVE_TITLE)
  SetTextStyle(self.Properties.Difficulty, self.UIStyle.FONT_STYLE_NUMBER_SMALL)
end
function ObjectiveLocationListItem:SetData(objectiveInstanceId, objectiveLocationListPane, cb)
  self.objectiveLocationListPane = objectiveLocationListPane
  self.cb = cb
  self.objectiveInstanceId = objectiveInstanceId
  local missionParams = ObjectiveRequestBus.Event.GetCreationParams(objectiveInstanceId)
  local title, _ = ObjectivesDataHandler:GetMissionTitleAndDescription(missionParams, objectiveInstanceId)
  if self.isRecipe then
    title = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@objective_recipetemplate", title)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.ObjectiveName, title, eUiTextSet_SetLocalized)
  local iconPath, iconColor, isReadyForTurnIn, titleColor = ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(self.objectiveInstanceId)
  UiImageBus.Event.SetSpritePathname(self.Properties.ObjectiveIconImage, iconPath)
  UiImageBus.Event.SetColor(self.Properties.ObjectiveIconImage, iconColor)
  UiTextBus.Event.SetColor(self.Properties.ObjectiveName, titleColor)
  local objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(self.objectiveInstanceId)
  local difficultyLevel = ObjectiveRequestBus.Event.GetDifficultyLevel(self.objectiveInstanceId)
  if difficultyLevel and 0 < difficultyLevel then
    UiTextBus.Event.SetText(self.Properties.Difficulty, tostring(difficultyLevel))
    local difficultyColor = DifficultyColors:GetColor(difficultyLevel)
    UiTextBus.Event.SetColor(self.Properties.Difficulty, difficultyColor)
  else
    UiTextBus.Event.SetText(self.Properties.Difficulty, "")
  end
end
function ObjectiveLocationListItem:OnFocus(entity)
  self.BG:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function ObjectiveLocationListItem:OnUnfocus(entity)
  self.BG:OnUnfocus()
end
function ObjectiveLocationListItem:OnPressed(entity)
  if self.cb then
    self.cb(self.objectiveLocationListPane, self.objectiveInstanceId)
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
return ObjectiveLocationListItem

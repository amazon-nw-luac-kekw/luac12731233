local PinnedObjectiveIngredient = {
  Properties = {
    ItemLayout = {
      default = EntityId()
    },
    Checkmark = {
      default = EntityId()
    },
    AmountContainer = {
      default = EntityId()
    },
    NumeratorText = {
      default = EntityId()
    },
    DenominatorText = {
      default = EntityId()
    }
  },
  denominatorWidth = 0,
  numeratorWidth = 0,
  fractionPadding = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PinnedObjectiveIngredient)
function PinnedObjectiveIngredient:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.NumeratorText, self.UIStyle.FONT_STYLE_PINNED_OBJECTIVE_NUMERATOR)
  SetTextStyle(self.Properties.DenominatorText, self.UIStyle.FONT_STYLE_PINNED_OBJECTIVE_DENOMINATOR)
  self:SetIsComplete(false)
end
function PinnedObjectiveIngredient:SetTaskById(taskId, level)
  if taskId == nil or taskId == self.taskId then
    return
  end
  self.taskId = taskId
  self:BusDisconnect(self.objectiveTaskNotificationBusHandler)
  self.objectiveTaskNotificationBusHandler = self:BusConnect(ObjectiveTaskNotificationBus, self.taskId)
  local descriptor = ObjectiveTaskRequestBus.Event.GetUIData(self.taskId, "ItemDescriptor")
  self.ItemLayout:SetItemByDescriptor(descriptor)
  self.ItemLayout:SetQuantityEnabled(false)
  self.ItemLayout:SetTooltipEnabled(true)
  self.ItemLayout.tooltipsOnLeft = true
  UiTransformBus.Event.SetScale(self.Properties.ItemLayout, Vector2(0.7, 0.7))
  local progressPercent = ObjectiveTaskRequestBus.Event.GetProgressPercent(self.taskId)
  self:SetIsComplete(1 <= progressPercent, true)
  self.targetNumber = ObjectiveTaskRequestBus.Event.GetTarget(self.taskId)
  UiTextBus.Event.SetText(self.Properties.DenominatorText, "/" .. tostring(self.targetNumber))
  self.denominatorWidth = UiTextBus.Event.GetTextWidth(self.Properties.DenominatorText)
  self:UpdateProgress()
end
function PinnedObjectiveIngredient:SetIsComplete(isComplete, skipAnimation)
  self.isComplete = isComplete
  UiElementBus.Event.SetIsEnabled(self.Checkmark, self.isComplete)
  if self.isComplete then
    self.audioHelper:PlaySound(self.audioHelper.Objectives_CompletedPinnedIngredient)
  end
end
function PinnedObjectiveIngredient:UpdateProgress()
  local progressPercent = ObjectiveTaskRequestBus.Event.GetProgressPercent(self.taskId)
  self:SetIsComplete(1 <= progressPercent or progressPercent == nil)
  local progressNumber = ObjectiveTaskRequestBus.Event.GetProgress(self.taskId)
  UiTextBus.Event.SetText(self.NumeratorText, tostring(progressNumber))
  self.numeratorWidth = UiTextBus.Event.GetTextWidth(self.Properties.NumeratorText)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.AmountContainer, self.numeratorWidth + self.fractionPadding + self.denominatorWidth)
end
function PinnedObjectiveIngredient:OnTaskChanged(data)
  self:UpdateProgress()
end
function PinnedObjectiveIngredient:OnTaskCompleted(data)
  self:UpdateProgress()
end
function PinnedObjectiveIngredient:OnTaskActivated(data)
  self:UpdateProgress()
end
return PinnedObjectiveIngredient

local GenericTextInputSearch = {
  Properties = {
    ClearFieldButton = {
      default = EntityId()
    },
    SearchbarBackground = {
      default = EntityId()
    },
    SearchbarFrame = {
      default = EntityId()
    },
    DisabledContainer = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    }
  },
  maxStringLength = 50,
  isSpinning = false,
  selectedCallback = nil,
  selectedTable = nil,
  enterCallback = nil,
  enterTable = nil,
  startEditCallback = nil,
  startEditTable = nil,
  endEditCallback = nil,
  endEditTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(GenericTextInputSearch)
function GenericTextInputSearch:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiTextInputNotificationBus, self.entityId)
  self:SetMaxStringLength(self.maxStringLength)
  self.ScriptedEntityTweener:Set(self.Properties.ClearFieldButton, {opacity = 0})
  UiElementBus.Event.SetIsEnabled(self.Properties.ClearFieldButton, false)
  self.ScriptedEntityTweener:Set(self.Properties.Spinner, {rotation = 0, opacity = 0})
end
function GenericTextInputSearch:OnShutdown()
end
function GenericTextInputSearch:SetText(text)
  UiTextInputBus.Event.SetText(self.entityId, text)
end
function GenericTextInputSearch:GetText()
  return UiTextInputBus.Event.GetText(self.entityId)
end
function GenericTextInputSearch:SetMaxStringLength(value)
  UiTextInputBus.Event.SetMaxStringLength(self.entityId, value)
end
function GenericTextInputSearch:GetMaxStringLength()
  return UiTextInputBus.Event.GetMaxStringLength(self.entityId)
end
function GenericTextInputSearch:SetSelectedCallback(command, table)
  self.selectedCallback = command
  self.selectedTable = table
end
function GenericTextInputSearch:SetEnterCallback(command, table)
  self.enterCallback = command
  self.enterTable = table
end
function GenericTextInputSearch:SetStartEditCallback(command, table)
  self.startEditCallback = command
  self.startEditTable = table
end
function GenericTextInputSearch:SetEndEditCallback(command, table)
  self.endEditCallback = command
  self.endEditTable = table
end
function GenericTextInputSearch:SetEditChangeCallback(command, table)
  self.editChangeCallback = command
  self.editChangeTable = table
end
function GenericTextInputSearch:SetActiveAndBegin()
  UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.entityId, true)
  UiTextInputBus.Event.BeginEdit(self.entityId)
end
function GenericTextInputSearch:StartSpinner()
  if self.Spinner:IsValid() and not self.isSpinning then
    self.ScriptedEntityTweener:Play(self.Properties.Spinner, 1, {rotation = 0, opacity = 1}, {timesToPlay = -1, rotation = 359})
    self.isSpinning = true
  end
end
function GenericTextInputSearch:StopSpinner()
  if self.Spinner:IsValid() and self.isSpinning then
    self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
    self.ScriptedEntityTweener:Set(self.Properties.Spinner, {rotation = 0, opacity = 0})
    self.isSpinning = false
  end
end
function GenericTextInputSearch:OnTextInputChange(textString)
  textString = textString or ""
  if textString == self.currentText then
    return
  end
  self.currentText = textString
  self:ExecuteCallback(self.editChangeCallback, self.editChangeTable, textString)
end
function GenericTextInputSearch:ExecuteCallback(command, table, data)
  if command ~= nil and table ~= nil and type(command) == "function" then
    command(table, data)
  end
end
function GenericTextInputSearch:OnHoverSearchBar()
  self.ScriptedEntityTweener:Play(self.Properties.SearchbarBackground, 0.15, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.SearchbarFrame, 0.15, {opacity = 1, ease = "QuadOut"})
end
function GenericTextInputSearch:OnUnhoverSearchBar()
  self.ScriptedEntityTweener:Play(self.Properties.SearchbarBackground, 0.15, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.SearchbarFrame, 0.15, {opacity = 0.7, ease = "QuadOut"})
end
function GenericTextInputSearch:OnStartEdit()
  SetActionmapsForTextInput(self.canvasId, true)
  self.ScriptedEntityTweener:Play(self.Properties.SearchbarBackground, 0.3, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.SearchbarFrame, 0.15, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Set(self.Properties.ClearFieldButton, {opacity = 1})
  UiElementBus.Event.SetIsEnabled(self.Properties.ClearFieldButton, true)
  self:ExecuteCallback(self.startEditCallback, self.startEditTable)
end
function GenericTextInputSearch:OnEndEdit()
  SetActionmapsForTextInput(self.canvasId, false)
  self.ScriptedEntityTweener:Play(self.Properties.SearchbarBackground, 0.3, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.SearchbarFrame, 0.15, {opacity = 0.7, ease = "QuadOut"})
  self.ScriptedEntityTweener:Set(self.Properties.ClearFieldButton, {opacity = 0})
  UiElementBus.Event.SetIsEnabled(self.Properties.ClearFieldButton, false)
  self:ExecuteCallback(self.endEditCallback, self.endEditTable)
end
function GenericTextInputSearch:OnEnter()
  self:ExecuteCallback(self.enterCallback, self.enterTable)
end
function GenericTextInputSearch:ClearSearchField()
  UiTextInputBus.Event.SetText(self.entityId, "")
  self:StopSpinner()
  self:OnTextInputChange("")
end
return GenericTextInputSearch

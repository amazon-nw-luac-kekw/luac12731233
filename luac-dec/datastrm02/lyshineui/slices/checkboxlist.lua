local CheckboxList = {
  Properties = {
    Label = {
      default = EntityId()
    },
    ListContainer = {
      default = EntityId()
    }
  },
  checkboxEntities = {},
  callback = nil,
  callbackTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CheckboxList)
function CheckboxList:OnInit()
  BaseElement.OnInit(self)
end
function CheckboxList:OnShutdown()
end
function CheckboxList:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function CheckboxList:SetLabel(value, skipLocalization)
  if not skipLocalization then
    UiTextBus.Event.SetTextWithFlags(self.Label, value, eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetText(self.Label, value)
  end
end
function CheckboxList:GetLabel()
  return UiTextBus.Event.GetText(self.Label)
end
function CheckboxList:InitCheckboxes(checkboxes)
  if not checkboxes or type(checkboxes) ~= "table" then
    return
  end
  UiDynamicLayoutBus.Event.SetNumChildElements(self.ListContainer, #checkboxes)
  self.checkboxEntities = {}
  local childElements = UiElementBus.Event.GetChildren(self.ListContainer)
  for i = 1, #childElements do
    local checkboxId = childElements[i]
    local checkboxTable = self.registrar:GetEntityTable(checkboxId)
    checkboxTable:SetCallback(self, self.OnChange)
    checkboxTable:SetText(checkboxes[i].text)
    self.checkboxEntities[tostring(checkboxId)] = i
  end
end
function CheckboxList:SetStates(checkboxes)
  if not checkboxes or type(checkboxes) ~= "table" then
    return
  end
  local childElements = UiElementBus.Event.GetChildren(self.ListContainer)
  for i = 1, #childElements do
    local checkboxData = checkboxes[i]
    if checkboxData then
      local isChecked = checkboxData.isChecked ~= nil and checkboxData.isChecked or false
      local checkboxId = childElements[i]
      local checkboxTable = self.registrar:GetEntityTable(checkboxId)
      checkboxTable:SetState(isChecked)
    end
  end
end
function CheckboxList:OnChange(isChecked, entityId)
  if self.checkboxEntities[tostring(entityId)] then
    self:ExecuteCallback(isChecked, self.checkboxEntities[tostring(entityId)])
  end
end
function CheckboxList:ExecuteCallback(isChecked, index)
  if self.callback ~= nil and self.callbackTable ~= nil then
    if type(self.callback) == "function" then
      self.callback(self.callbackTable, isChecked, index)
    else
      self.callbackTable[self.callback](self.callbackTable, isChecked, index)
    end
  end
end
return CheckboxList

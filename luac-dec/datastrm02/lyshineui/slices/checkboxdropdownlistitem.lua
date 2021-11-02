local CheckboxDropdownListItem = {
  Properties = {
    CheckBox = {
      default = EntityId()
    },
    TextRight = {
      default = EntityId()
    },
    ItemBg = {
      default = EntityId()
    }
  },
  mWidth = nil,
  mHeight = 40,
  mData = nil,
  mCallback = nil,
  mCallbackTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CheckboxDropdownListItem)
function CheckboxDropdownListItem:OnInit()
  BaseElement.OnInit(self)
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.mWidth, self.mHeight)
  self:SetTextRight("")
  self.CheckBox:SetCallback(self, self.OnCheckboxChange)
  self.CheckBox:SetFocusChangeCallback(self, self.OnFocusChange)
end
function CheckboxDropdownListItem:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function CheckboxDropdownListItem:GetWidth()
  return self.mWidth
end
function CheckboxDropdownListItem:GetHeight()
  return self.mHeight
end
function CheckboxDropdownListItem:SetText(value)
  self.CheckBox:SetText(value)
end
function CheckboxDropdownListItem:GetText()
  return self.CheckBox:GetText()
end
function CheckboxDropdownListItem:SetTextRight(value)
  UiTextBus.Event.SetText(self.Properties.TextRight, value)
end
function CheckboxDropdownListItem:GetTextRight()
  return UiTextBus.Event.GetText(self.Properties.TextRight)
end
function CheckboxDropdownListItem:SetData(data)
  self.mData = data
end
function CheckboxDropdownListItem:GetData()
  return self.mData
end
function CheckboxDropdownListItem:SetState(isChecked)
  self.CheckBox:SetState(isChecked)
end
function CheckboxDropdownListItem:GetState()
  return self.CheckBox:GetState()
end
function CheckboxDropdownListItem:OnFocus()
  self.ItemBg:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_DropdownListItem)
end
function CheckboxDropdownListItem:OnUnfocus()
  self.ItemBg:OnUnfocus()
end
function CheckboxDropdownListItem:OnCheckboxChange(isChecked)
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  if self.mCallback ~= nil and self.mCallbackTable ~= nil then
    self.mCallback(self.mCallbackTable, self.mData, isChecked)
  end
end
function CheckboxDropdownListItem:OnFocusChange(isFocused)
  if isFocused then
    self:OnFocus()
  else
    self:OnUnfocus()
  end
end
function CheckboxDropdownListItem:SetCallback(command, table)
  self.mCallback = command
  self.mCallbackTable = table
end
return CheckboxDropdownListItem

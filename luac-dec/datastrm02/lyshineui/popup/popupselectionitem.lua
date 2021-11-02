local PopupSelectionItem = {
  Properties = {
    Text = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    SelectedHighlight = {
      default = EntityId()
    }
  },
  cbTable = nil,
  cbFunc = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PopupSelectionItem)
function PopupSelectionItem:OnInit()
  BaseElement.OnInit(self)
  self.radioHandler = DynamicBus.PopupSelectionRadioBehavior.Connect(self.entityId, self)
end
function PopupSelectionItem:OnShutdown()
  if self.radioHandler then
    DynamicBus.PopupSelectionRadioBehavior.Disconnect(self.entityId, self)
    self.radioHandler = nil
  end
end
function PopupSelectionItem:OnHoverStart()
  UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, true)
end
function PopupSelectionItem:OnHoverEnd()
  UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, false)
end
function PopupSelectionItem:OnClick()
  if self.cbFunc and self.cbTable then
    self.cbFunc(self.cbTable, self.data)
  end
  DynamicBus.PopupSelectionRadioBehavior.Broadcast.OnOtherItemSelected()
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectedHighlight, true)
end
function PopupSelectionItem:OnOtherItemSelected()
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectedHighlight, false)
end
function PopupSelectionItem:SetGridItemData(data)
  if not data then
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    return
  end
  self.data = data
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, data.text, eUiTextSet_SetLocalized)
  if data.callbackSelf then
    self:SetCallback(data.callbackFunc, data.callbackSelf)
  else
    self:SetCallback(nil, nil)
  end
end
function PopupSelectionItem:GetElementHeight()
  return UiTransform2dBus.Event.GetLocalHeight(self.entityId)
end
function PopupSelectionItem:GetElementWidth()
  return UiTransform2dBus.Event.GetLocalWidth(self.entityId)
end
function PopupSelectionItem:GetHorizontalSpacing()
  return 1
end
function PopupSelectionItem:SetCallback(callback, table)
  self.cbFunc = callback
  self.cbTable = table
end
return PopupSelectionItem

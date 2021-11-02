local SelectionIcon = {
  Properties = {
    highlight = {
      default = EntityId()
    }
  },
  cbTable = nil,
  cbFunc = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SelectionIcon)
function SelectionIcon:OnInit()
  BaseElement.OnInit(self)
end
function SelectionIcon:OnIconHoverStart()
  UiElementBus.Event.SetIsEnabled(self.Properties.highlight, true)
end
function SelectionIcon:OnIconHoverEnd()
  UiElementBus.Event.SetIsEnabled(self.Properties.highlight, false)
end
function SelectionIcon:OnIconClick()
  if self.cbFunc and self.cbTable then
    self.cbFunc(self.cbTable)
  end
  if self.data and self.data.callback and self.data.callbackTable then
    self.data.callback(self.data.callbackTable, self.data.index)
  end
end
function SelectionIcon:SetGridItemData(data)
  if not data then
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    return
  end
  self.data = data
  if data.color then
    UiImageBus.Event.SetColor(self.entityId, data.color)
  end
  if data.icon then
    UiImageBus.Event.SetSpritePathname(self.entityId, data.icon)
  end
end
function SelectionIcon:GetElementHeight()
  return UiTransform2dBus.Event.GetLocalHeight(self.entityId)
end
function SelectionIcon:GetElementWidth()
  return UiTransform2dBus.Event.GetLocalWidth(self.entityId)
end
function SelectionIcon:GetHorizontalSpacing()
  return 1
end
function SelectionIcon:SetCallback(callback, table)
  self.cbFunc = callback
  self.cbTable = table
end
return SelectionIcon

local RadioButtonGridItemRowElement = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    }
  },
  highlightOpacity = 0.7
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RadioButtonGridItemRowElement)
function RadioButtonGridItemRowElement:OnInit()
  BaseElement.OnInit(self)
end
function RadioButtonGridItemRowElement:OnShutdown()
end
function RadioButtonGridItemRowElement:GetElementWidth()
  return 60
end
function RadioButtonGridItemRowElement:GetElementHeight()
  return 60
end
function RadioButtonGridItemRowElement:GetHeaderElementHeight()
  return UiTransform2dBus.Event.GetLocalHeight(self.Properties.HeaderContainer)
end
function RadioButtonGridItemRowElement:GetHorizontalSpacing()
  return 10
end
function RadioButtonGridItemRowElement:SetGridItemData(data)
  UiElementBus.Event.SetIsEnabled(self.entityId, data ~= nil)
  if not data then
    return
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, data.iconPath)
  self.isSelected = data.isSelected
  self.data = data.data
  self.selectedCallback = data.selectedCallback
  self.hoverStartCallback = data.hoverStartCallback
  self.hoverEndCallback = data.hoverEndCallback
  self.selectedCallbackTable = data.selectedCallbackTable
  local highlightOpacity = self.isSelected and self.highlightOpacity or 0
  self.ScriptedEntityTweener:Set(self.Properties.Highlight, {opacity = highlightOpacity})
end
function RadioButtonGridItemRowElement:OnHoverStart()
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.2, {
    opacity = self.highlightOpacity,
    ease = "QuadOut"
  })
  if self.hoverStartCallback then
    self.hoverStartCallback(self.selectedCallbackTable, self)
  end
end
function RadioButtonGridItemRowElement:OnHoverEnd()
  if not self.isSelected then
    self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.1, {opacity = 0, ease = "QuadOut"})
  end
  if self.hoverEndCallback then
    self.hoverEndCallback()
  end
end
function RadioButtonGridItemRowElement:OnPressed()
  if self.selectedCallback then
    self.selectedCallback(self.selectedCallbackTable, self)
  end
  self.ScriptedEntityTweener:Set(self.Properties.Highlight, {
    opacity = self.highlightOpacity
  })
end
return RadioButtonGridItemRowElement

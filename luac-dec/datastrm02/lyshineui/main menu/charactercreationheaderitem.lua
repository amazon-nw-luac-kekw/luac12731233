local CharacterCreationHeaderItem = {
  Properties = {
    HeaderText = {
      default = EntityId()
    },
    HeaderPrefix = {
      default = EntityId()
    }
  },
  activeColor = nil,
  inactiveColor = nil,
  state = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CharacterCreationHeaderItem)
function CharacterCreationHeaderItem:OnInit()
  BaseElement.OnInit(self)
  self.activeColor = self.UIStyle.COLOR_TAN_LIGHT
  self.inactiveColor = self.UIStyle.COLOR_TAN_DARK
  UiTextBus.Event.SetColor(self.HeaderText, self.inactiveColor)
  UiTextBus.Event.SetColor(self.HeaderPrefix, self.inactiveColor)
end
function CharacterCreationHeaderItem:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.HeaderText, value, eUiTextSet_SetLocalized)
end
function CharacterCreationHeaderItem:GetText()
  return UiTextBus.Event.GetText(self.HeaderText)
end
function CharacterCreationHeaderItem:SetPrefix(value)
  UiTextBus.Event.SetTextWithFlags(self.HeaderPrefix, value, eUiTextSet_SetLocalized)
end
function CharacterCreationHeaderItem:GetPrefix()
  return UiTextBus.Event.GetText(self.HeaderPrefix)
end
function CharacterCreationHeaderItem:SetState(value)
  self.state = value
end
function CharacterCreationHeaderItem:GetState()
  return self.state
end
function CharacterCreationHeaderItem:SetActive(isActive)
  local color = isActive and self.activeColor or self.inactiveColor
  local animDuration = 0.4
  self.ScriptedEntityTweener:Play(self.HeaderText, animDuration, {textColor = color, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.HeaderPrefix, animDuration, {textColor = color, ease = "QuadOut"})
end
return CharacterCreationHeaderItem

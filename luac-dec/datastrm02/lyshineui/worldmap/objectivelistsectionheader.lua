local ObjectiveListSectionHeader = {
  Properties = {
    Title = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ObjectiveListSectionHeader)
function ObjectiveListSectionHeader:OnInit()
  SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_ATTRIBUTES_STAT_LABEL)
end
function ObjectiveListSectionHeader:SetTitle(titleText)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, titleText, eUiTextSet_SetLocalized)
end
function ObjectiveListSectionHeader:SetIsBright(isBright)
  local textColor = isBright and self.UIStyle.FONT_STYLE_ATTRIBUTES_STAT_LABEL.fontColor or self.UIStyle.COLOR_TAN_DARK
  UiTextBus.Event.SetColor(self.Properties.Title, textColor)
end
return ObjectiveListSectionHeader

local TutorialKeyBindingSeparator = {
  Properties = {
    Text = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TutorialKeyBindingSeparator)
function TutorialKeyBindingSeparator:SetText(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, text, eUiTextSet_SetLocalized)
end
return TutorialKeyBindingSeparator

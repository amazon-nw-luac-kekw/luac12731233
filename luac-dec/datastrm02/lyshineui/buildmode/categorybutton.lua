local CategoryButton = {
  Properties = {
    text = {
      default = EntityId()
    },
    selectedBG = {
      default = EntityId()
    },
    topline = {
      default = EntityId()
    },
    bottomline = {
      default = EntityId()
    }
  },
  selected = false,
  cbTable = nil,
  cbFunc = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CategoryButton)
function CategoryButton:SetText(text, localize)
  if localize then
    UiTextBus.Event.SetTextWithFlags(self.text, text, eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetText(self.text, text)
  end
end
function CategoryButton:SetSelected(selected)
  self.selected = selected
  UiElementBus.Event.SetIsEnabled(self.selectedBG, selected)
  self.topline:SetVisible(selected)
  self.bottomline:SetVisible(selected)
  if self.selected then
    self.audioHelper:PlaySound(self.audioHelper.OnBuildModeScrollCategory)
  end
end
function CategoryButton:OnPressed()
  self:SetSelected(true)
end
return CategoryButton

local PopUpSelection = {
  Properties = {
    SelectionPopup = {
      default = EntityId()
    },
    SimpleGrid = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PopUpSelection)
function PopUpSelection:OnInit()
  BaseElement.OnInit(self)
  self.SimpleGrid:Initialize(self.Icon)
  self.Icon:SetCallback(self.OnIconClick, self)
end
function PopUpSelection:OnIconClick()
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectionPopup, not UiElementBus.Event.IsEnabled(self.Properties.SelectionPopup))
end
return PopUpSelection

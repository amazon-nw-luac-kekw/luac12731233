local AzothTextContainer = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    CurrentAzothText = {
      default = EntityId()
    },
    RequiredAzothText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AzothTextContainer)
function AzothTextContainer:OnInit()
  BaseElement.OnInit(self)
end
function AzothTextContainer:SetValues(currentAzoth, requiredAzoth)
  self.currentAzoth = currentAzoth
  self.requiredAzoth = requiredAzoth
  self.insufficientAzoth = self.currentAzoth < self.requiredAzoth
  self:SetCurrentAzothText(self.currentAzoth)
  self:SetRequiredAzothText(self.requiredAzoth)
end
function AzothTextContainer:SetCurrentAzothText(azothAmount)
  local color = self.insufficientAzoth and ColorRgbaToHexString(self.UIStyle.COLOR_RED_MEDIUM) or ColorRgbaToHexString(self.UIStyle.COLOR_WHITE)
  UiTextBus.Event.SetText(self.Properties.CurrentAzothText, "<font color=" .. color .. ">" .. GetFormattedNumber(azothAmount) .. "</font>")
end
function AzothTextContainer:SetRequiredAzothText(requiredAmount)
  UiTextBus.Event.SetText(self.Properties.RequiredAzothText, GetFormattedNumber(requiredAmount))
end
return AzothTextContainer

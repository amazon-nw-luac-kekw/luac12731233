local XpNumber_ProgressBar = {
  Properties = {
    ProgressBarImage = {
      default = EntityId()
    },
    ProgressBarBG = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(XpNumber_ProgressBar)
function XpNumber_ProgressBar:OnInit()
  BaseElement.OnInit(self)
end
function XpNumber_ProgressBar:SetProgressPercent(oldPercent, newPercentage)
  UiImageBus.Event.SetFillAmount(self.Properties.ProgressBarImage, oldPercent)
  UiImageBus.Event.SetFillAmount(self.Properties.ProgressBarBG, newPercentage)
end
return XpNumber_ProgressBar

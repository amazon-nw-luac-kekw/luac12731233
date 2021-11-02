local ProgressBar = {
  Properties = {
    ProgressBarImage = {
      default = EntityId()
    },
    ProgressBarBG = {
      default = EntityId()
    },
    ProgressBarText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ProgressBar)
function ProgressBar:OnInit()
  BaseElement.OnInit(self)
end
function ProgressBar:SetProgressPercent(percentage, label)
  UiImageBus.Event.SetFillAmount(self.Properties.ProgressBarImage, percentage)
  UiTextBus.Event.SetText(self.Properties.ProgressBarText, label)
end
return ProgressBar

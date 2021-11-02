local ProgressBarWithGlow = {
  Properties = {
    ProgressBarImage = {
      default = EntityId()
    },
    ProgressBarBG = {
      default = EntityId()
    },
    ProgressBarText = {
      default = EntityId()
    },
    ProgressBarGlow = {
      default = EntityId()
    },
    GlowContainer = {
      default = EntityId()
    }
  },
  startingWidth = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ProgressBarWithGlow)
function ProgressBarWithGlow:OnInit()
  BaseElement.OnInit(self)
  self.startingWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.GlowContainer)
end
function ProgressBarWithGlow:SetProgressPercent(percentage, label)
  UiImageBus.Event.SetFillAmount(self.Properties.ProgressBarImage, percentage)
  UiTextBus.Event.SetText(self.Properties.ProgressBarText, label)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.GlowContainer, self.startingWidth * percentage)
  UiImageBus.Event.SetAlpha(self.Properties.ProgressBarGlow, percentage)
end
return ProgressBarWithGlow

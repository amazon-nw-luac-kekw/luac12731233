local TutorialHeader = {
  Properties = {
    Text = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    }
  }
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TutorialHeader)
function TutorialHeader:OnInit()
  BaseElement.OnInit(self)
  self.ScriptedEntityTweener:Set(self.Properties.Text, {
    opacity = 0.4,
    textColor = self.UIStyle.COLOR_TAN_MEDIUM_LIGHT
  })
end
function TutorialHeader:SetHighlight(highlight)
  if highlight then
    self.ScriptedEntityTweener:PlayC(self.Properties.Text, 0.2, tweenerCommon.fadeInQuadOut)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.Text, 0.2, tweenerCommon.opacityTo40)
  end
end
return TutorialHeader

local HowDoesWarWork = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    },
    Line = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(HowDoesWarWork)
function HowDoesWarWork:OnInit()
end
function HowDoesWarWork:OnFocus(isInvasion)
  self.ScriptedEntityTweener:Play(self.Properties.Icon, 0.1, {
    imgColor = self.UIStyle.COLOR_YELLOW_LIGHT
  }, {
    imgColor = self.UIStyle.COLOR_TAN_LIGHT,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Line, 0.1, {
    imgColor = self.UIStyle.COLOR_YELLOW_LIGHT
  }, {
    imgColor = self.UIStyle.COLOR_TAN_LIGHT,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Text, 0.1, {
    textColor = self.UIStyle.COLOR_YELLOW_LIGHT
  }, {
    textColor = self.UIStyle.COLOR_TAN_LIGHT,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Tab_Hover)
end
function HowDoesWarWork:OnUnfocus(isInvasion)
  self.ScriptedEntityTweener:Play(self.Properties.Icon, 0.1, {
    imgColor = self.UIStyle.COLOR_TAN_LIGHT
  }, {
    imgColor = self.UIStyle.COLOR_YELLOW_LIGHT,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Line, 0.1, {
    imgColor = self.UIStyle.COLOR_TAN_LIGHT
  }, {
    imgColor = self.UIStyle.COLOR_YELLOW_LIGHT,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Text, 0.1, {
    textColor = self.UIStyle.COLOR_TAN_LIGHT
  }, {
    textColor = self.UIStyle.COLOR_YELLOW_LIGHT,
    ease = "QuadOut"
  })
end
return HowDoesWarWork

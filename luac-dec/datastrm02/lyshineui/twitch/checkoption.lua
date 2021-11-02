local CheckOption = {
  Properties = {
    Glow = {
      default = EntityId()
    },
    RadioLabel = {
      default = EntityId()
    },
    RadioLabelOn = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CheckOption)
function CheckOption:OnInit()
end
function CheckOption:OnFocus()
  self.ScriptedEntityTweener:Play(self.RadioLabel, 0.2, {
    opacity = 1,
    textColor = self.UIStyle.COLOR_TAN_LIGHT,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Item_Hover)
end
function CheckOption:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.RadioLabel, 0.2, {
    opacity = 0.65,
    textColor = self.UIStyle.COLOR_TAN,
    ease = "QuadOut"
  })
end
function CheckOption:OnPress()
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Tab_Select)
end
function CheckOption:OnChecked()
  UiElementBus.Event.SetIsEnabled(self.Glow, true)
  UiElementBus.Event.SetIsEnabled(self.RadioLabelOn, true)
end
function CheckOption:OffChecked()
  UiElementBus.Event.SetIsEnabled(self.Glow, false)
  UiElementBus.Event.SetIsEnabled(self.RadioLabelOn, false)
end
function CheckOption:OnShutdown()
end
return CheckOption

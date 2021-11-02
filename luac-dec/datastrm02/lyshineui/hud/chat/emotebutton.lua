local EmoteButton = {
  Properties = {
    EmoteFocusedIcon = {
      default = EntityId()
    },
    EmoteUnfocusedIcon = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(EmoteButton)
function EmoteButton:OnInit()
  BaseElement.OnInit(self)
end
function EmoteButton:OnFocus()
  self.ScriptedEntityTweener:Play(self.EmoteFocusedIcon, 0.2, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.EmoteUnfocusedIcon, 0.2, {opacity = 0, ease = "QuadOut"})
end
function EmoteButton:OnUnFocus()
  self.ScriptedEntityTweener:Play(self.EmoteFocusedIcon, 0.18, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.EmoteUnfocusedIcon, 0.18, {opacity = 0.65, ease = "QuadOut"})
end
function EmoteButton:OnPress()
  LyShineManagerBus.Broadcast.SetState(663562859)
end
function EmoteButton:OnShutdown()
end
return EmoteButton

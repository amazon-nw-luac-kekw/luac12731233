local SkipIntro = {
  Properties = {
    Circle = {
      default = EntityId()
    },
    CircleProgress = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SkipIntro)
function SkipIntro:OnInit()
  BaseElement.OnInit(self)
  self.ScriptedEntityTweener:Set(self.Properties.Circle, {opacity = 0})
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.introNotificationsBusHandler = IntroControllerComponentNotificationsBus.Connect(self, self.canvasId)
end
function SkipIntro:OnShutdown()
  if self.introNotificationsBusHandler then
    self.introNotificationsBusHandler:Disconnect()
    self.introNotificationsBusHandler = nil
  end
end
function SkipIntro:ShowSkipIcon()
  UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.Circle, 0.1, {
    opacity = 1,
    ease = "QuadIn",
    delay = 0.1
  })
  self.ScriptedEntityTweener:Stop(self.Properties.CircleProgress)
  self.ScriptedEntityTweener:Play(self.Properties.CircleProgress, 2, {imgFill = 0}, {
    imgFill = 1,
    ease = "QuadInOut",
    delay = 0.25
  })
  AudioUtilsBus.Broadcast.ExecuteGlobalAudioTrigger("Play_UI_FTUE_SkipStart", true, EntityId())
end
function SkipIntro:HideSkipIcon()
  self.ScriptedEntityTweener:Play(self.Properties.Circle, 0.1, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.1
  })
  self.ScriptedEntityTweener:Set(self.Properties.CircleProgress, {imgFill = 0})
  AudioUtilsBus.Broadcast.ExecuteGlobalAudioTrigger("Stop_UI_FTUE_SkipStart", true, EntityId())
end
return SkipIntro

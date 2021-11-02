local FullScreenFader = {
  Properties = {
    BlackScreenFader = {
      default = EntityId()
    }
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(FullScreenFader)
function FullScreenFader:OnInit()
  BaseScreen.OnInit(self)
  DynamicBus.FullScreenFader.Connect(self.entityId, self)
  self.fullScreenFaderEventHandler = self:BusConnect(FullScreenFaderEventBus, self.entityId)
end
function FullScreenFader:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.FullScreenFader.Disconnect(self.entityId, self)
  if self.fullScreenFaderEventHandler then
    self:BusDisconnect(self.fullScreenFaderEventHandler)
    self.fullScreenFaderEventHandler = nil
  end
end
function FullScreenFader:ExecuteFadeInOutCode(fadeInTime, fadeOutTime, fadeOutdelay)
  self:ExecuteFadeInOut(fadeInTime, fadeOutTime, fadeOutdelay)
end
function FullScreenFader:ExecuteFadeInOut(fadeInTime, fadeOutTime, fadeOutdelay, callbackSelf, onFadeInCallback, onFadeOutCallback)
  UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.BlackScreenFader, true)
  self.ScriptedEntityTweener:Set(self.Properties.BlackScreenFader, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.BlackScreenFader, fadeInTime, {
    opacity = 1,
    ease = "QuadIn",
    onComplete = function()
      if onFadeInCallback then
        onFadeInCallback(callbackSelf)
      end
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.BlackScreenFader, fadeOutTime, {
    delay = fadeOutdelay,
    opacity = 0,
    ease = "QuadIn",
    onComplete = function()
      if onFadeOutCallback then
        onFadeOutCallback(callbackSelf)
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.BlackScreenFader, false)
      UiCanvasBus.Event.SetEnabled(self.canvasId, false)
    end
  })
end
return FullScreenFader

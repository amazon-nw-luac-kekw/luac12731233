local FullScreenSpinner = {
  Properties = {
    Background = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    }
  }
}
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(FullScreenSpinner)
function FullScreenSpinner:OnInit()
  BaseScreen.OnInit(self)
  DynamicBus.FullScreenSpinner.Connect(self.entityId, self)
end
function FullScreenSpinner:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.FullScreenSpinner.Disconnect(self.entityId, self)
  timingUtils:StopDelay(self)
end
function FullScreenSpinner:SetFullscreenSpinnerVisible(isVisible, timeoutSec, timeoutCallbackSelf, timeoutCallbackFn)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  local backgroundOpacity = 0.8
  local fadeDuration = 0.5
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, isVisible)
  if isVisible then
    LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
    self.ScriptedEntityTweener:Play(self.Background, fadeDuration, {opacity = 0}, {opacity = backgroundOpacity, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Spinner, fadeDuration, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Spinner, 1, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
    if timeoutSec then
      timingUtils:Delay(timeoutSec, self, function(self)
        self:SetFullscreenSpinnerVisible(false)
        if timeoutCallbackFn then
          timeoutCallbackFn(timeoutCallbackSelf)
        end
      end)
    end
  else
    self.ScriptedEntityTweener:Play(self.Spinner, fadeDuration, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Background, fadeDuration, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
        self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
      end
    })
    timingUtils:StopDelay(self)
  end
end
function FullScreenSpinner:GetFullscreenSpinnerVisible()
  return self.isVisible
end
return FullScreenSpinner

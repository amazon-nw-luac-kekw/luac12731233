local WorldHitArea = {
  Properties = {}
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(WorldHitArea)
function WorldHitArea:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterOpenEvent("WorldHitArea", self.canvasId)
end
function WorldHitArea:OnRelease()
  if LyShineManagerBus.Broadcast.IsWorldHitUIActionAllowed() then
    LyShineManagerBus.Broadcast.SetState(2702338936)
  end
end
function WorldHitArea:OnTransitionIn(fromState, fromLevel, toState, toLevel)
end
function WorldHitArea:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
return WorldHitArea

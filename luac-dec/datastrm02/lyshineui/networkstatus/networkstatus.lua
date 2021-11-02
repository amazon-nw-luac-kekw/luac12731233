local NetworkStatus = {
  Properties = {}
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(NetworkStatus)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function NetworkStatus:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Client.ConnectionIsBad", function(self, isConnectionBad)
    UiCanvasBus.Event.SetEnabled(self.canvasId, isConnectionBad == true)
    if isConnectionBad then
      self.ScriptedEntityTweener:Stop(self.entityId)
      self.ScriptedEntityTweener:PlayC(self.entityId, 0.5, tweenerCommon.fadeInQuadOut)
    else
      self.ScriptedEntityTweener:PlayC(self.entityId, 0.5, tweenerCommon.fadeOutQuadOut)
    end
  end)
end
return NetworkStatus

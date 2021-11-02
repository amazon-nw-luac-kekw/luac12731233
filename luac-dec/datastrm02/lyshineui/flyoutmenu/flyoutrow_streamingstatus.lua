local FlyoutRow_StreamingStatus = {
  Properties = {
    ViewerCountText = {
      default = EntityId()
    },
    LiveText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_StreamingStatus)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function FlyoutRow_StreamingStatus:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  UiTextBus.Event.SetTextWithFlags(self.LiveText, "@ui_streaming_live", eUiTextSet_SetLocalized)
end
function FlyoutRow_StreamingStatus:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  self.dataLayer = nil
end
function FlyoutRow_StreamingStatus:SetData(data)
  if not data then
    Log("[FlyoutRow_StreamingStatus] Error: invalid data passed to SetData")
    return
  end
  if self.viewerCountDataPath then
    self.dataLayer:UnregisterObserver(self, self.viewerCountDataPath)
  end
  self:OnViewerCountChanged(MarkerRequestBus.Event.GetViewerCount(data.markerId))
end
function FlyoutRow_StreamingStatus:OnViewerCountChanged(viewerCount)
  local text = GetLocalizedNumber(viewerCount or 0)
  UiTextBus.Event.SetText(self.ViewerCountText, text)
end
return FlyoutRow_StreamingStatus

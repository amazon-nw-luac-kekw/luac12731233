local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local FlyoutRow_SimpleHeaderAndSubtext = {
  Properties = {
    Header = {
      default = EntityId()
    },
    Subtext = {
      default = EntityId()
    },
    TextContainer = {
      default = EntityId()
    }
  },
  heightBuffer = 30
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_SimpleHeaderAndSubtext)
function FlyoutRow_SimpleHeaderAndSubtext:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.dataLayer = dataLayer
end
function FlyoutRow_SimpleHeaderAndSubtext:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  self.dataLayer = nil
end
function FlyoutRow_SimpleHeaderAndSubtext:SetData(data)
  if not (data and data.header) or not data.subtext then
    Log("[FlyoutRow_SimpleHeaderAndSubtext] Error: invalid data passed to SetData")
    return
  end
  UiTextBus.Event.SetTextWithFlags(self.Header, data.header, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Subtext, data.subtext, eUiTextSet_SetLocalized)
  UiCanvasBus.Event.RecomputeChangedLayouts(self.canvasId)
  local textContainerHeight = UiTransform2dBus.Event.GetLocalHeight(self.TextContainer)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, textContainerHeight + self.heightBuffer)
end
return FlyoutRow_SimpleHeaderAndSubtext

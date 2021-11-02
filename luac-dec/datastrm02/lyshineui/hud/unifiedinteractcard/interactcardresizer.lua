local InteractCardResizer = {
  Properties = {
    BankInfoHeight = {default = 50},
    ContainerInfoHeight = {default = 50},
    ApplyResourceHeightPadding = {default = 10},
    AdditionalInfo = {
      default = EntityId()
    },
    TextBg = {
      default = EntityId()
    },
    TextName = {
      default = EntityId()
    }
  },
  TickHandler = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(InteractCardResizer)
function InteractCardResizer:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UnifiedInteractOptionNotificationsBus, self.entityId)
  self.TickHandler = self:BusConnect(DynamicBus.UITickBus)
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.initialHeight = UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.UnifiedInteract.AdditionalInfoHeightOverride", function(self, height)
    if self.useHeightOverride and height then
      UiLayoutCellBus.Event.SetTargetHeight(self.entityId, self.initialHeight + height)
    end
  end)
end
function InteractCardResizer:OnTick(deltaTime, timePoint)
  if not self.tickCount then
    self.tickCount = 0
  end
  self.tickCount = self.tickCount + 1
  if self.tickCount == 2 then
    local textSize = UiTextBus.Event.GetTextSize(self.Properties.TextName)
    local textWidth = textSize.x
    local paddingX = 150
    textWidth = textWidth + paddingX
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.TextBg, textWidth)
    self:BusDisconnect(self.TickHandler)
    self.TickHandler = nil
  end
end
function InteractCardResizer:OnAdditionalInfoChanged(infoType, rootEntity)
  if self.transformHandler then
    self:BusDisconnect(self.transformHandler)
    self.transformHandler = nil
  end
  self.useHeightOverride = infoType == eInteractAdditionalType_Repair
  if infoType == eInteractAdditionalType_None or infoType == eInteractAdditionalType_Repair then
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, self.initialHeight)
    return
  end
  if infoType == eInteractAdditionalType_ApplyResource then
    local layoutEntity = UiElementBus.Event.FindDescendantByName(rootEntity, "Layout")
    if layoutEntity and layoutEntity:IsValid() then
      self.transformHandler = self:BusConnect(UiTransformChangeNotificationBus, layoutEntity)
    end
    return
  end
  local cellHeight = self.initialHeight
  if infoType == eInteractAdditionalType_Bank then
    cellHeight = self.Properties.BankInfoHeight
  elseif infoType == eInteractAdditionalType_Container then
    cellHeight = self.Properties.ContainerInfoHeight
  end
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, cellHeight)
end
function InteractCardResizer:OnCanvasSpaceRectChanged(entity, oldRect, newRect)
  local layoutHeight = newRect:GetHeight()
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, layoutHeight + self.Properties.ApplyResourceHeightPadding)
end
return InteractCardResizer

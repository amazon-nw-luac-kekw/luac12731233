local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local TooltipSetter = {
  Properties = {
    InitialSimpleTooltip = {default = ""},
    TooltipDelay = {default = 0}
  }
}
BaseElement:CreateNewElement(TooltipSetter)
function TooltipSetter:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  local oldHoverStart = UiInteractableActionsBus.Event.GetHoverStartActionName(self.entityId)
  if oldHoverStart == "" then
    UiInteractableActionsBus.Event.SetHoverStartActionName(self.entityId, "entity:OnTooltipSetterHoverStart")
    UiInteractableActionsBus.Event.SetHoverEndActionName(self.entityId, "entity:OnTooltipSetterHoverEnd")
  end
  self:SetSimpleTooltip(self.Properties.InitialSimpleTooltip)
end
function TooltipSetter:SetShouldCloseOpenTooltip(shouldClose)
  self.shouldCloseOpenTooltip = shouldClose
end
function TooltipSetter:SetSimpleTooltip(text, horizontalAlignment)
  if type(text) ~= "string" or string.len(text) == 0 then
    self.tooltipInfo = nil
    self.equipped = nil
    self.compareToItemTable = nil
    return
  end
  if horizontalAlignment == nil then
    horizontalAlignment = 0
  end
  self.tooltipInfo = {description = text, descriptionHorizontalAlignment = horizontalAlignment}
  self.equipped = nil
  self.compareToItemTable = nil
  if self.isActiveTooltip then
    local activeTooltip = DynamicBus.TooltipsRequestBus.Broadcast.GetActiveTooltipTable()
    if activeTooltip and activeTooltip.UpdateSectionsWithoutResize then
      activeTooltip:UpdateSectionsWithoutResize(self.tooltipInfo, self.equipped, self.compareToItemTable)
    end
  end
end
function TooltipSetter:SetTooltipInfo(tooltipInfo, equipped, compareTo)
  self.tooltipInfo = tooltipInfo
  self.equipped = equipped
  self.compareToItemTable = compareTo
end
function TooltipSetter:OnTick(deltaTime, timePoint)
  self.timeToWait = self.timeToWait - deltaTime
  if self.waitingForTooltipSpawn and self.timeToWait <= 0 then
    if self.shouldCloseOpenTooltip then
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    end
    DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(self.tooltipInfo, self, nil)
    self.isActiveTooltip = true
    self.waitingForTooltipSpawn = false
  end
  if not UiCanvasBus.Event.GetEnabled(self.canvasId) then
    self:OnTooltipSetterHoverEnd()
  end
end
function TooltipSetter:OnTooltipSetterHoverStart()
  if type(self.tooltipInfo) ~= "table" then
    return
  end
  self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  self.timeToWait = self.Properties.TooltipDelay
  self.waitingForTooltipSpawn = true
  if not self.elementNotifications then
    self.elementNotifications = self:BusConnect(UiElementNotificationBus, self.entityId)
  end
end
function TooltipSetter:OnTooltipSetterHoverEnd()
  DynamicBus.DynamicTooltip.Broadcast.StopOpenSound()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
  self.isActiveTooltip = false
  self.waitingForTooltipSpawn = false
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  if self.elementNotifications then
    self:BusDisconnect(self.elementNotifications)
    self.elementNotifications = nil
  end
end
function TooltipSetter:OnUiElementAndAncestorsEnabledChanged(isEnabled)
  if not isEnabled then
    self:OnTooltipSetterHoverEnd()
  end
end
return TooltipSetter

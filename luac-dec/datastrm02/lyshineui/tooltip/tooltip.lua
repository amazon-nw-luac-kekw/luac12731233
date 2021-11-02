local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
local Tooltip = {
  Properties = {
    RootElement = {
      default = EntityId()
    },
    SimpleTooltip = {
      default = EntityId()
    },
    DynamicTooltip = {
      default = EntityId()
    },
    SimpleTooltipText = {
      default = EntityId()
    },
    DynamicSpawner = {
      default = EntityId()
    },
    CursorRightMargin = {default = 32},
    CompareTooltipOnly = {default = false},
    DiscountTooltip = {
      default = EntityId()
    },
    RepairSalvageTooltip = {
      default = EntityId()
    }
  },
  tooltipJson = "",
  tooltipText = "",
  buildingTooltip = false,
  compositeJob = 0
}
BaseScreen:CreateNewScreen(Tooltip)
function Tooltip:OnInit()
  self.tooltipPosition = Vector2(0, 0)
  self.tooltipOffsets = UiOffsets(0, 0, 0, 0)
  self.tooltipElement = EntityId()
  BaseScreen.OnInit(self)
  Spawner:AttachSpawner(Tooltip)
  self.LogSettings = {false, "Tooltips"}
  if not self.Properties.CompareTooltipOnly and not self.Properties.SimpleTooltip:IsValid() then
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    local name = UiCanvasBus.Event.GetCanvasName(self.canvasId)
    Debug.Log("Tooltip: Lua property SimpleTooltip is not set on element " .. UiElementBus.Event.GetName(self.entityId) .. " in canvas " .. name)
  end
  if not self.Properties.CompareTooltipOnly and not self.Properties.SimpleTooltipText:IsValid() then
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    local name = UiCanvasBus.Event.GetCanvasName(self.canvasId)
    Debug.Log("Tooltip: Lua property SimpleTooltipText is not set on element " .. UiElementBus.Event.GetName(self.entityId) .. " in canvas " .. name)
  end
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.DynamicSpawner)
  UiElementBus.Event.SetIsEnabled(self.Properties.SimpleTooltip, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.DiscountTooltip, false)
  UiTextBus.Event.SetIsMarkupEnabled(self.Properties.SimpleTooltipText, true)
  self.originalWindowOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.SimpleTooltip)
  self.originalTextOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.SimpleTooltipText)
  self.dataLayer:RegisterObserver(self, "Hud.LocalPlayer.Tooltip.Position", function(self, dataNode)
    Log("ERROR: Hud.LocalPlayer.Tooltip.* has been deprecated.")
  end)
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.Tooltip.Text", function(self, dataNode)
    Log("ERROR: Hud.LocalPlayer.Tooltip.* has been deprecated.")
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Tooltip.JsonCompare1", function(self, jsonString)
    Log("ERROR: Hud.LocalPlayer.Tooltip.* has been deprecated.")
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Tooltip.JsonCompare2", function(self, jsonString)
    Log("ERROR: Hud.LocalPlayer.Tooltip.* has been deprecated.")
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Tooltip.Json", function(self, jsonString)
    Log("ERROR: Hud.LocalPlayer.Tooltip.* has been deprecated.")
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Tooltip.IsVisible", function(self, isVisible)
    Log("ERROR: Hud.LocalPlayer.Tooltip.* has been deprecated.")
  end)
  if self.Properties.CompareTooltipOnly then
    DynamicBus.CompareTooltipRequestBus.Connect(self.entityId, self)
  else
    DynamicBus.TooltipsRequestBus.Connect(self.entityId, self)
  end
  self:OnCanvasSizeOrScaleChange()
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
end
function Tooltip:ShowTooltip(tooltipDisplayInfo, owner, dockedEntityId, showTooltipInstantly, lockToEntitySides)
  self.tooltipOwner = owner
  self.dockedEntityId = dockedEntityId
  self.lockToEntitySides = lockToEntitySides
  local tooltipElement
  if tooltipDisplayInfo.isDiscount then
    self.DiscountTooltip:SetData(tooltipDisplayInfo)
    tooltipElement = self.Properties.DiscountTooltip
  elseif tooltipDisplayInfo.isRepair or tooltipDisplayInfo.isSalvage then
    self.RepairSalvageTooltip:SetData(tooltipDisplayInfo)
    tooltipElement = self.Properties.RepairSalvageTooltip
  else
    self.DynamicTooltip:SetItem(tooltipDisplayInfo, {
      compareTo = self.tooltipOwner and self.tooltipOwner.compareToItemTable,
      isFixed = self.tooltipOwner and self.tooltipOwner.isFixed,
      column2Width = owner.column2Width
    }, showTooltipInstantly)
    tooltipElement = self.Properties.DynamicTooltip
  end
  self:UseElementAsTooltip(tooltipElement)
  if not self.tickHandler and not self.Properties.CompareTooltipOnly then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
  self.doTick = true
end
function Tooltip:HideTooltip()
  self.tooltipOwner = nil
  UiElementBus.Event.SetIsEnabled(self.Properties.DynamicTooltip, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.DiscountTooltip, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.RepairSalvageTooltip, false)
  self.DynamicTooltip:OnHideTooltip()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
  self.dockedEntityId = nil
  self.doTick = false
end
function Tooltip:SetFlyoutInfo(position, width, onRight)
  self.flyoutPosition = position
  self.flyoutWidth = width
  self.flyoutOnRight = onRight
end
function Tooltip:GetActiveTooltipTable()
  return self.registrar:GetEntityTable(self.tooltipElement)
end
function Tooltip:OnShutdown()
  if self.Properties.CompareTooltipOnly then
    DynamicBus.CompareTooltipRequestBus.Disconnect(self.entityId, self)
  else
    DynamicBus.TooltipsRequestBus.Disconnect(self.entityId, self)
  end
  BaseScreen.OnShutdown(self)
end
function Tooltip:GetDynamicTooltip()
  return self.DynamicTooltip
end
function Tooltip:GetFlyoutPosition()
  return self.flyoutPosition
end
function Tooltip:GetFlyoutOnRight()
  return self.flyoutOnRight
end
function Tooltip:OnTick(deltaTime, timePoint)
  if not self.doTick then
    return
  end
  if g_isDragging or UiContextMenuBus.Broadcast.IsContextMenuActive() then
    if self.tooltipElement and self.tooltipElement:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.tooltipElement, false)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.SimpleTooltip, false)
    self:HideTooltip()
    return
  end
  local isFixedToAnotherTooltip = self.tooltipOwner and self.tooltipOwner.isFixed
  if isFixedToAnotherTooltip then
    local otherTooltipFlyoutPosition = DynamicBus.TooltipsRequestBus.Broadcast.GetFlyoutPosition()
    local point = Vector2(otherTooltipFlyoutPosition.x, otherTooltipFlyoutPosition.y)
    local entityRect = UiTransformBus.Event.GetViewportSpaceRect(self.tooltipElement)
    local padding = 10
    DynamicBus.FlyoutMenuBus.Broadcast.SetExtraWidth(entityRect:GetWidth() + padding)
    if DynamicBus.TooltipsRequestBus.Broadcast.GetFlyoutOnRight() then
      local dynamicTooltip = DynamicBus.FlyoutMenuBus.Broadcast.GetDynamicTooltipTable()
      local column2Width = dynamicTooltip.column2Width
      local baseWidth = UiTransform2dBus.Event.GetLocalWidth(self.tooltipElement)
      point.x = point.x + (baseWidth + column2Width) * self.viewportScale
    else
      point.x = point.x - entityRect:GetWidth()
    end
    self.tooltipPosition = UiTransformBus.Event.ViewportPointToLocalPoint(self.Properties.RootElement, point)
    self.tooltipOffsets = self:MoveOffsetsToPosition(self.tooltipOffsets, self.tooltipPosition)
    local visualHeight = entityRect:GetHeight()
    local visualBottom = self.tooltipOffsets.top + visualHeight
    if visualBottom > self.viewportSize.y then
      local delta = visualBottom - self.viewportSize.y
      self.tooltipOffsets.bottom = self.tooltipOffsets.bottom - delta
      self.tooltipOffsets.top = self.tooltipOffsets.top - delta
    end
    local relevantTooltip = self.Properties.SimpleTooltip
    if self.tooltipElement and self.tooltipElement:IsValid() then
      relevantTooltip = self.tooltipElement
    end
    UiTransform2dBus.Event.SetOffsets(relevantTooltip, self.tooltipOffsets)
  else
    local desiredViewportPos
    if self.dockedEntityId then
      desiredViewportPos = UiTransformBus.Event.GetViewportPosition(self.dockedEntityId)
    else
      desiredViewportPos = CursorBus.Broadcast.GetCursorPosition()
      if self.lockToEntitySides then
        local entityRect = UiTransformBus.Event.GetViewportSpaceRect(self.tooltipElement)
        local invokingEntityRect = UiTransformBus.Event.GetViewportSpaceRect(self.tooltipOwner.entityId)
        local left = invokingEntityRect:GetCenterX() - invokingEntityRect:GetWidth() / 2
        local right = left + invokingEntityRect:GetWidth()
        if right + entityRect:GetWidth() > self.viewportSize.x then
          desiredViewportPos.x = left - entityRect:GetWidth()
        else
          desiredViewportPos.x = right
        end
      end
    end
    local relevantTooltip = self.Properties.SimpleTooltip
    if self.tooltipElement and self.tooltipElement:IsValid() then
      relevantTooltip = self.tooltipElement
    end
    if relevantTooltip and desiredViewportPos then
      PositionEntityOnScreen(relevantTooltip, desiredViewportPos)
    end
  end
end
function Tooltip:MoveOffsetsToPosition(offsets, position)
  local width = offsets.right - offsets.left
  local height = offsets.bottom - offsets.top
  local newOffsets = UiOffsets(position.x, position.y, position.x + width, position.y + height)
  return newOffsets
end
function Tooltip:CheckTooltipOnLeft()
  if type(self.tooltipOwner) == "table" then
    return self.tooltipOwner.tooltipsOnLeft
  end
  return false
end
function Tooltip:ConstrainTooltipOffsets(offsets)
  local viewportSize = CanvasAuthoringSize
  local xMargin, point, dockedPos, dockedRect
  if self.dockedEntityId then
    dockedPos = UiTransformBus.Event.GetViewportPosition(self.dockedEntityId)
    dockedRect = UiTransformBus.Event.GetViewportSpaceRect(self.dockedEntityId)
    point = Vector2(dockedRect:GetWidth() + dockedPos.x, dockedPos.y)
    point = UiTransformBus.Event.ViewportPointToLocalPoint(self.Properties.RootElement, point)
    xMargin = 0
  else
    local mouse = UiCursorBus.Broadcast.GetUiCursorPosition()
    point = UiTransformBus.Event.ViewportPointToLocalPoint(self.Properties.RootElement, mouse)
    xMargin = self.Properties.CursorRightMargin
  end
  local width = offsets.right - offsets.left
  local height = offsets.bottom - offsets.top
  local newOffsets = UiOffsets(offsets.left, offsets.top, offsets.right, offsets.bottom)
  local tooltipOnLeft = self:CheckTooltipOnLeft()
  newOffsets.left = point.x + xMargin
  newOffsets.right = newOffsets.left + width
  newOffsets.top = point.y - height / 2
  newOffsets.bottom = newOffsets.top + height
  if newOffsets.right > viewportSize.x or tooltipOnLeft and point.x > width + xMargin then
    if self.dockedEntityId then
      point = UiTransformBus.Event.ViewportPointToLocalPoint(self.Properties.RootElement, dockedPos)
    end
    newOffsets.right = point.x - xMargin
    newOffsets.left = newOffsets.right - width
  end
  if newOffsets.bottom > viewportSize.y then
    local delta = newOffsets.bottom - viewportSize.y
    newOffsets.top = newOffsets.top - delta
    newOffsets.bottom = newOffsets.bottom - delta
  end
  if 0 > newOffsets.left then
    local delta = newOffsets.left * -1
    newOffsets.left = newOffsets.left + delta
    newOffsets.right = newOffsets.right + delta
  end
  if 0 > newOffsets.top then
    local delta = newOffsets.top * -1
    newOffsets.top = newOffsets.top + delta
    newOffsets.bottom = newOffsets.bottom + delta
  end
  return newOffsets
end
function Tooltip:ChangeTooltipText(text)
  UiTransform2dBus.Event.SetOffsets(self.Properties.SimpleTooltip, self.originalWindowOffsets)
  UiTransform2dBus.Event.SetOffsets(self.Properties.SimpleTooltipText, self.originalTextOffsets)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SimpleTooltipText, text, eUiTextSet_SetLocalized)
end
function Tooltip:FinishedTooltip(element, param)
  self.buildingTooltip = false
  self:UseElementAsTooltip(element)
  UiElementBus.Event.SetIsEnabled(element.entityId, isVisible)
end
function Tooltip:UseElementAsTooltip(element)
  local tooltipElement
  if type(element) == "table" and element.entityId then
    tooltipElement = element.entityId
  elseif type(element.IsValid) == "function" then
    tooltipElement = element
  end
  if not tooltipElement or not tooltipElement:IsValid() then
    return
  end
  Log(self.LogSettings, "Using element %s as tooltip", tostring(tooltipElement))
  UiElementBus.Event.SetIsEnabled(self.Properties.SimpleTooltip, false)
  UiElementBus.Event.SetIsEnabled(tooltipElement, true)
  local elementCanvasId = UiElementBus.Event.GetCanvas(tooltipElement)
  if elementCanvasId ~= self.canvasId then
    local elementTable = self:CloneElement(tooltipElement, self.Properties.RootElement, false)
    if elementTable ~= nil then
      self.tooltipElement = elementTable.entityId
    end
  else
    self.tooltipElement = tooltipElement
    UiElementBus.Event.Reparent(tooltipElement, self.Properties.RootElement, EntityId())
  end
  local windowOffsets = UiTransform2dBus.Event.GetOffsets(tooltipElement)
  windowOffsets = self:MoveOffsetsToPosition(windowOffsets, self.tooltipPosition)
  windowOffsets = self:ConstrainTooltipOffsets(windowOffsets)
  UiTransform2dBus.Event.SetOffsets(tooltipElement, windowOffsets)
  self.tooltipOffsets = windowOffsets
end
function Tooltip:OnCanvasSizeOrScaleChange()
  self.viewportSize = LyShineScriptBindRequestBus.Broadcast.GetViewportSize()
  self.viewportScale = math.min(self.viewportSize.x / 1920, self.viewportSize.y / 1080)
end
return Tooltip

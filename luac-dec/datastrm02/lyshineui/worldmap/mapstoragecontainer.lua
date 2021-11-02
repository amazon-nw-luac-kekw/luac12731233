local MapStorageContainer = {
  Properties = {
    DynamicItemList = {
      default = EntityId()
    },
    OutpostHeader = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  },
  isVisible = false
}
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MapStorageContainer)
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
function MapStorageContainer:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self.panelTypes = mapTypes.panelTypes
  DynamicBus.Map.Connect(self.entityId, self)
  self.CloseButton:SetCallback(self.OnStorageClose, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_SIDE_PANEL_RIGHT)
  self.DynamicItemList:SetRepairAllEnabled(false)
end
function MapStorageContainer:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
end
function MapStorageContainer:OnShowPanel(panelType, outpostId, outpostName)
  if panelType ~= self.panelTypes.Storage then
    self:SetMapStorageVisibility(false)
    return
  end
  self.DynamicItemList:ClearList()
  self.DynamicItemList:UpdateSizes()
  self.outpostId = outpostId
  contractsDataHandler:RequestStorageData(outpostId, self, self.SetStorageItems)
  UiTextBus.Event.SetTextCase(self.OutpostHeader, self.UIStyle.TEXT_CASING_UPPER)
  UiTextBus.Event.SetTextWithFlags(self.OutpostHeader, outpostName, eUiTextSet_SetLocalized)
  self:SetMapStorageVisibility(true)
end
function MapStorageContainer:SetStorageItems(storageItems)
  if not storageItems then
    return
  end
  self.DynamicItemList:SetGlobalStorageId(self.outpostId)
  self.DynamicItemList:UpdateLists()
end
function MapStorageContainer:SetMapStorageVisibility(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.35, {
      x = 0,
      alpha = 1,
      ease = "QuadOut"
    })
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.25, {
      x = 600,
      alpha = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
  end
end
function MapStorageContainer:IsCursorOnMapStorageContainer()
  if self.isVisible then
    local screenPoint = CursorBus.Broadcast.GetCursorPosition()
    local point = UiTransformBus.Event.ViewportPointToLocalPoint(self.entityId, screenPoint)
    if point.x > 0 and point.x <= self.width and 0 < point.y and point.y <= self.height then
      return true
    end
  end
  return false
end
function MapStorageContainer:OnStorageClose()
  self:SetMapStorageVisibility(false)
end
function MapStorageContainer:OnCanvasSizeOrScaleChange()
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
end
return MapStorageContainer

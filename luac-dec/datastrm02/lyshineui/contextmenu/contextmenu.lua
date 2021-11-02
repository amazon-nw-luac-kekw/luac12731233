local ContextMenu = {
  Properties = {
    Frame = {
      default = EntityId()
    },
    ContextMenu = {
      default = EntityId()
    }
  },
  contextEntityId = EntityId(),
  openLocation = Vector2:CreateZero(),
  spawnCount = 0,
  spawnTotal = 0,
  defaultWidth = 160,
  maxWidth = 160
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(ContextMenu)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(ContextMenu)
function ContextMenu:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(UiContextMenuBus)
  self:BusConnect(UiSpawnerNotificationBus, self.ContextMenu)
  self.Frame:SetFillAlpha(0.9)
  self.Frame:SetFrameTextureVisible(false)
end
function ContextMenu:OnTransitionIn(stateName, levelName)
  self.audioHelper:PlaySound(self.audioHelper.OnShow)
  local openOffset = self.openLocation - Vector2(1, 1)
  UiTransformBus.Event.SetLocalPosition(self.entityId, openOffset)
  self.Frame:SetLineVisible(true, 0.24)
  self.cursorNotificationBus = self:BusConnect(CursorNotificationBus)
end
function ContextMenu:OnTransitionOut(stateName, levelName)
  self.audioHelper:PlaySound(self.audioHelper.OnHide)
  local childElements = UiElementBus.Event.GetChildren(self.ContextMenu)
  for i = 1, #childElements do
    UiElementBus.Event.DestroyElement(childElements[i])
  end
  self.contextEntityId = EntityId()
  self.openLocation = Vector2:CreateZero()
  self.spawnTotal = 0
  if self.cursorNotificationBus then
    self:BusDisconnect(self.cursorNotificationBus)
    self.cursorNotificationBus = nil
  end
end
function ContextMenu:OnAction(entityId, actionName)
  if BaseScreen.OnAction(self, entityId, actionName) then
    return
  end
  if actionName == "closeContextMenu" then
    LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
  elseif self.contextEntityId:IsValid() then
    local contextCavasId = UiElementBus.Event.GetCanvas(self.contextEntityId)
    LyShineManagerBus.Broadcast.OnAction(contextCavasId, self.contextEntityId, actionName)
    LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
  end
end
function ContextMenu:OnMenuItemPress(data)
  if self.contextEntityId:IsValid() then
    local contextCavasId = UiElementBus.Event.GetCanvas(self.contextEntityId)
    LyShineManagerBus.Broadcast.OnAction(contextCavasId, self.contextEntityId, data.actionName)
    LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
  end
end
function ContextMenu:AddAction(buttonText, actionName, enabled)
  local actionData = {
    buttonText = buttonText,
    actionName = actionName,
    enabled = enabled
  }
  self.spawnCount = self.spawnCount + 1
  self.spawnTotal = self.spawnTotal + 1
  self.maxWidth = self.defaultWidth
  self:SpawnSlice(self.ContextMenu, "LyShineUI\\Slices\\DropdownListItem", self.OnActionSpawned, actionData)
end
function ContextMenu:SetContextEntityId(entityId)
  self.contextEntityId = entityId
end
function ContextMenu:SetOpenLocation(location)
  self.openLocation = location
end
function ContextMenu:SetEnabled(isEnabled)
  if isEnabled then
    LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
  else
    LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
  end
end
function ContextMenu:IsContextMenuActive()
  return UiCanvasBus.Event.GetEnabled(self.canvasId)
end
function ContextMenu:OnActionSpawned(entity, actionData)
  entity:SetText(actionData.buttonText)
  entity:SetData(actionData)
  entity:SetCallback("OnMenuItemPress", self)
  UiInteractableBus.Event.SetIsHandlingEvents(entity.entityId, actionData.enabled)
  local buttonWidth = entity:GetTextWidth()
  local buttonHeight = entity:GetHeight()
  local widthPadding = 32
  local heightPadding = 12
  self.maxWidth = math.max(self.maxWidth, buttonWidth)
  local localWidth = self.maxWidth + widthPadding
  local localHeight = buttonHeight * self.spawnTotal + heightPadding
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, localWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, localHeight)
  self.Frame:SetSize(localWidth, localHeight)
  self.spawnCount = self.spawnCount - 1
  if self.spawnCount == 0 then
    UiCanvasBus.Event.RecomputeChangedLayouts(self.canvasId)
    local canvasSize = UiCanvasBus.Event.GetCanvasSize(self.canvasId)
    local windowOffsets = UiTransform2dBus.Event.GetOffsets(self.entityId)
    if windowOffsets.bottom > canvasSize.y then
      local diff = windowOffsets.bottom - canvasSize.y
      windowOffsets.top = windowOffsets.top - diff
      windowOffsets.bottom = windowOffsets.bottom - diff
    end
    if windowOffsets.right > canvasSize.x then
      local diff = windowOffsets.right - canvasSize.x
      windowOffsets.left = windowOffsets.left - diff
      windowOffsets.right = windowOffsets.right - diff
    end
    UiTransform2dBus.Event.SetOffsets(self.entityId, windowOffsets)
  end
end
function ContextMenu:OnCursorPressed()
  if not IsCursorOverUiEntity(self.entityId, 15) then
    self:SetEnabled(false)
  end
end
return ContextMenu

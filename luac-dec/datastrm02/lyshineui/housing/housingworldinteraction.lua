local HousingWorldInteraction = {
  Properties = {
    RotateCameraHint = {
      default = EntityId()
    },
    LeftPanelContainer = {
      default = EntityId()
    },
    RotateObjectHint = {
      default = EntityId()
    },
    CancelHint = {
      default = EntityId()
    },
    SurfaceLockHint = {
      default = EntityId()
    },
    GridSnapHint = {
      default = EntityId()
    },
    ObjectName = {
      default = EntityId()
    },
    ObjectDetail = {
      default = EntityId()
    },
    ContextMenuHint = {
      default = EntityId()
    },
    FlyoutPositioner = {
      default = EntityId()
    },
    SurfaceLockOnOff = {
      default = EntityId()
    },
    GridSnapOnOff = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(HousingWorldInteraction)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function HousingWorldInteraction:OnInit()
  BaseElement.OnInit(self)
  UiTextBus.Event.SetTextWithFlags(self.Properties.RotateCameraHint, "@ui_housing_rotate_camera_hint", eUiTextSet_SetLocalized)
  self.RotateObjectHint:SetHousingHudHint("@ui_housing_rotate_object_hint", "ui_scroll_up", "ui")
  self.ContextMenuHint:SetHousingHudHint("@ui_context_menu_hint", "housing_confirm", "housing")
  self.CancelHint:SetHousingHudHint("@ui_cancel", "toggleMenuComponent", "ui")
  self.SurfaceLockHint:SetHousingHudHint("@ui_housing_surface_lock_hint", "housing_toggle_surface_lock", "housing")
  self.GridSnapHint:SetHousingHudHint("@ui_housing_grid_snap_hint", "housing_toggle_grid", "housing")
  self.dataLayer:RegisterDataObserver(self, "Hud.Housing.SelectedItemId", function(self, housingItemId)
    local itemName = "@ui_housing_object"
    local itemDesc = ""
    local staticItem = StaticItemDataManager:GetItem(housingItemId)
    if staticItem then
      itemName = staticItem.displayName
      itemDesc = staticItem.description
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.ObjectName, itemName, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ObjectDetail, itemDesc, eUiTextSet_SetLocalized)
  end)
  self.dataLayer:RegisterDataCallback(self, "Housing.PlacedItemsUpdated", function(self, hasUpdated)
    if self.interactionAvailable then
      local housingItemData = PlayerHousingClientRequestBus.Broadcast.GetHousingItemData(self.interactableId)
      self.interactionWorldPos = housingItemData.position
    end
  end)
end
function HousingWorldInteraction:OnShutdown()
end
function HousingWorldInteraction:OnStartWorldInteraction()
  UiElementBus.Event.SetIsEnabled(self.Properties.LeftPanelContainer, true)
  self:OnPlacingObjectEnd()
  self:OnInteractionUnavailable()
  self:OnPlacingObject()
end
function HousingWorldInteraction:OnEndWorldInteraction()
  self:OnPlacingObjectEnd()
  self:OnInteractionUnavailable()
  UiElementBus.Event.SetIsEnabled(self.Properties.LeftPanelContainer, false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function HousingWorldInteraction:OnInteractionAvailable(interactableId)
  self.interactableId = interactableId
  local housingItemData = PlayerHousingClientRequestBus.Broadcast.GetHousingItemData(interactableId)
  self.interactionWorldPos = housingItemData.position
  self.interactionAvailable = true
  UiElementBus.Event.SetIsEnabled(self.Properties.ContextMenuHint, self.interactionAvailable)
  if not self.actionHandler then
    self.actionHandler = self:BusConnect(CryActionNotificationsBus, "housing_confirm")
  end
  if not self.tickBusHandler then
    self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
  end
end
function HousingWorldInteraction:OnInteractionUnavailable()
  self.interactionAvailable = false
  UiElementBus.Event.SetIsEnabled(self.Properties.ContextMenuHint, self.interactionAvailable)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  if self.actionHandler then
    self:BusDisconnect(self.actionHandler)
    self.actionHandler = nil
  end
  if self.tickBusHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBusHandler = nil
  end
end
function HousingWorldInteraction:OnTick()
  local screenPos
  if self.interactionAvailable then
    screenPos = LyShineManagerBus.Broadcast.ProjectToScreen(self.interactionWorldPos, false, false)
  else
    screenPos = CursorBus.Broadcast.GetCursorPosition()
  end
  PositionEntityOnScreen(self.Properties.ContextMenuHint, screenPos)
end
function HousingWorldInteraction:OnPlacingObject()
  UiElementBus.Event.SetIsEnabled(self.Properties.LeftPanelContainer, true)
end
function HousingWorldInteraction:OnPlacingObjectEnd()
  UiElementBus.Event.SetIsEnabled(self.Properties.LeftPanelContainer, false)
end
function HousingWorldInteraction:OnCryAction(actionName, value)
  if not self.contextMenuOpen and self.interactionAvailable then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
    local rows = {
      {
        type = flyoutMenu.ROW_TYPE_CircularOptions,
        context = self,
        options = {
          {
            buttonIcon = "LyShineUI\\Images\\icons\\housing\\icon_housing_move.dds",
            buttonText = "@ui_move",
            enabled = true,
            callback = function(self)
              HousingDecorationRequestBus.Broadcast.StartMovingHousingItem()
            end
          },
          {
            buttonIcon = "LyShineUI\\Images\\icons\\housing\\icon_housing_pickup.dds",
            buttonText = "@ui_pick_up",
            enabled = true,
            callback = function(self)
              HousingDecorationRequestBus.Broadcast.PickUpHousingItem()
              self:OnInteractionUnavailable()
            end
          },
          {
            buttonIcon = "LyShineUI\\Images\\icons\\housing\\icon_housing_cancel.dds",
            buttonText = "@ui_cancel",
            enabled = true,
            callback = function(self)
              LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
            end
          }
        },
        useClickBehavior = true
      }
    }
    self:OnTick()
    flyoutMenu:SetAllowPositionalExitHover(false)
    flyoutMenu:SetIgnoreHoverExit(true)
    flyoutMenu:SetOpenLocation(self.Properties.FlyoutPositioner)
    flyoutMenu:SetBackgroundVisibility(false)
    flyoutMenu:SetClosedCallback(self, self.OnFlyoutMenuClosed)
    flyoutMenu:SetFlipBasedOnPosition(false)
    flyoutMenu:SetArrowVisibility(false)
    flyoutMenu:SetScaleTween(true)
    flyoutMenu:SetRowData(rows)
    HousingDecorationRequestBus.Broadcast.OnOpenContextMenu()
    self.contextMenuOpen = true
    UiElementBus.Event.SetIsEnabled(self.Properties.ContextMenuHint, false)
  end
end
function HousingWorldInteraction:OnFlyoutMenuClosed()
  HousingDecorationRequestBus.Broadcast.OnCloseContextMenu()
  self.contextMenuOpen = false
  UiElementBus.Event.SetIsEnabled(self.Properties.ContextMenuHint, self.interactionAvailable)
end
function HousingWorldInteraction:OnToggleGrid(enabled)
  local gridSnapText = enabled and "@ui_on" or "@ui_off"
  local gridSnapTextColor = enabled and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED_MEDIUM
  UiTextBus.Event.SetTextWithFlags(self.Properties.GridSnapOnOff, gridSnapText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.GridSnapOnOff, gridSnapTextColor)
end
function HousingWorldInteraction:OnToggleSurfaceLock(enabled)
  local surfaceLockText = enabled and "@ui_on" or "@ui_off"
  local surfaceLockTextColor = enabled and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED_MEDIUM
  UiTextBus.Event.SetTextWithFlags(self.Properties.SurfaceLockOnOff, surfaceLockText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.SurfaceLockOnOff, surfaceLockTextColor)
end
return HousingWorldInteraction

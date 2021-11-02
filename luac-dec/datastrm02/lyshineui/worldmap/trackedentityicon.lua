BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local TrackedEntityIcon = {
  Properties = {},
  FLYOUT_CONTEXT = "TrackedEntityIcon",
  GROUP_SIZE_PREFIX = "@ui_groupsize_",
  RECOMMENDED_FORMAT = "<font color = \"#76ffd7\">%s</font>",
  NOT_RECOMMENDED_FORMAT = "<font color = \"#ff9393\">%s</font>",
  currentZoom = 6,
  DEFAULT_BACKGROUND = "lyShineui/images/map/tooltipimages/mapTooltip_territory_default.png"
}
BaseElement:CreateNewElement(TrackedEntityIcon)
local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local hoverIntentDetector = RequireScript("LyShineUI._Common.HoverIntentDetector")
function TrackedEntityIcon:OnInit()
  BaseElement.OnInit(self)
end
function TrackedEntityIcon:OnHoverStart()
  hoverIntentDetector:OnHoverDetected(self, self.ShowFlyoutMenu)
  self.audioHelper:PlaySound(self.audioHelper.MapIconOnHover)
end
function TrackedEntityIcon:OnHoverEnd()
  hoverIntentDetector:StopHoverDetected(self)
end
function TrackedEntityIcon:ShowFlyoutMenu()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu.openingContext == self.FLYOUT_CONTEXT and flyoutMenu:ExitHover() then
    return
  end
  local header = self.iconData.titleText
  local subtext = self.iconData.descriptionText
  local rows = {}
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_PointOfInterest,
    header = self.iconData.titleText,
    subtext = self.iconData.descriptionText,
    tooltipBackground = self.iconData.tooltipBackground or self.DEFAULT_BACKGROUND
  })
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
  flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
  flyoutMenu:SetOpenLocation(self.entityId)
  flyoutMenu:EnableFlyoutDelay(false)
  flyoutMenu:SetFadeInTime(0.05)
  flyoutMenu:SetFadeOutTime(0.05)
  flyoutMenu:SetRowData(rows)
  flyoutMenu:SourceHoverOnly()
end
function TrackedEntityIcon:OnRightClick()
  DynamicBus.MagicMap.Broadcast.MapRightClick()
end
function TrackedEntityIcon:SetData(iconData)
  self.markersLayer = iconData.dataManager.markersLayer
  if not iconData.descriptionText or iconData.descriptionText == "" then
    iconData.descriptionText = "@ui_nearby"
  end
  UiImageBus.Event.SetSpritePathname(self.entityId, iconData.mapIconPath)
  self.iconData = iconData
end
function TrackedEntityIcon:OnPositionChanged(position)
  self.iconData.position = position
  local anchors = self.markersLayer:WorldPositionToAnchors(position)
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, anchors)
end
function TrackedEntityIcon:OnZoomLevelChanged(zoomLevel)
  if not zoomLevel or zoomLevel == self.currentZoom then
    return
  end
  self.currentZoom = zoomLevel
  self.scale = Math.Clamp(2 / self.currentZoom, 0.3, 1.5)
  UiTransformBus.Event.SetScale(self.entityId, Vector2(self.scale, self.scale))
end
return TrackedEntityIcon

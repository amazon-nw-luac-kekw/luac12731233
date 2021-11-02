BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local GlobalMapEntityIcon = {
  Properties = {},
  FLYOUT_CONTEXT = "GlobalMapEntityIcon",
  GROUP_SIZE_PREFIX = "@ui_groupsize_",
  RECOMMENDED_FORMAT = "<font color = \"#76ffd7\">%s</font>",
  NOT_RECOMMENDED_FORMAT = "<font color = \"#ff9393\">%s</font>",
  currentZoom = 6
}
BaseElement:CreateNewElement(GlobalMapEntityIcon)
local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local EncounterDataHandler = RequireScript("LyShineUI._Common.EncounterDataHandler")
local hoverIntentDetector = RequireScript("LyShineUI._Common.HoverIntentDetector")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function GlobalMapEntityIcon:OnInit()
  BaseElement.OnInit(self)
end
function GlobalMapEntityIcon:OnHoverStart()
  hoverIntentDetector:OnHoverDetected(self, self.ShowFlyoutMenu)
  self.audioHelper:PlaySound(self.audioHelper.MapIconOnHover)
end
function GlobalMapEntityIcon:OnHoverEnd()
  hoverIntentDetector:StopHoverDetected(self)
end
function GlobalMapEntityIcon:ShowFlyoutMenu()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu.openingContext == self.FLYOUT_CONTEXT and flyoutMenu:ExitHover() then
    return
  end
  local header = ""
  local subtext = ""
  local background = ""
  local recommendedLevel, minimumPlayers
  if self.definitionData then
    if self.definitionData.tooltipBackground then
      background = self.definitionData.tooltipBackground
    end
    if self.definitionData.nameLocalizationKey and self.definitionData.nameLocalizationKey ~= "" then
      header = self.definitionData.nameLocalizationKey
      subtext = subtext .. self.definitionData.nameLocalizationKey .. "_description \n"
    end
    local minLevel = EncounterDataHandler:GetLevel(self.iconData.spawnerTag)
    if self.definitionData.recommendedLevel and self.definitionData.recommendedLevel > 0 then
      minLevel = self.definitionData.recommendedLevel
    end
    if minLevel ~= 0 then
      recommendedLevel = minLevel
    end
    if self.definitionData.groupSize ~= 0 then
      minimumPlayers = EncounterDataHandler:GetGroupRange(self.definitionData)
    end
    local itemDescriptor = ItemDescriptor()
    itemDescriptor.itemId = EncounterDataHandler:GetRequiredItem(self.iconData.spawnerTag)
    local tier = StaticItemDataManager:GetItem(itemDescriptor.itemId).tier
    subtext = subtext .. "\n" .. GetLocalizedReplacementText("@objective_requiresitem", {
      itemName = itemDescriptor:GetDisplayName(),
      tier = tier
    })
  end
  local rows = {}
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_PointOfInterest,
    header = header,
    subtext = subtext,
    recommendedLevel = recommendedLevel,
    minimumPlayers = minimumPlayers,
    tooltipBackground = background
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
function GlobalMapEntityIcon:OnRightClick()
  DynamicBus.MagicMap.Broadcast.MapRightClick()
end
function GlobalMapEntityIcon:SetGlobalMapIconData(iconData)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.markersLayer = iconData.dataManager.markersLayer
  self.definitionData = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(iconData.territoryId)
  self.iconData = iconData
  self:UpdateIconPath()
  self:OnPositionChanged(iconData.position)
end
function GlobalMapEntityIcon:ClearIconData(iconData)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.iconData = nil
end
function GlobalMapEntityIcon:UpdateIconPath()
  if self.definitionData then
    local mapIcon = EncounterDataHandler:GetRecommendedIcons(self.iconData.spawnerTag, self.definitionData)
    if mapIcon then
      self.iconData.mapIconPath = mapIcon
    end
  end
  if self.lastIconPath ~= self.iconData.mapIconPath then
    UiImageBus.Event.SetSpritePathname(self.entityId, self.iconData.mapIconPath)
  end
  self.lastIconPath = self.iconData.mapIconPath
end
function GlobalMapEntityIcon:IsEnabled()
  return self.iconData ~= nil
end
function GlobalMapEntityIcon:OnPositionChanged(position)
  self.iconData.position = position
  local anchors = self.markersLayer:WorldPositionToAnchors(position)
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, anchors)
end
function GlobalMapEntityIcon:OnZoomLevelChanged(zoomLevel)
  if not zoomLevel or zoomLevel == self.currentZoom then
    return
  end
  self.currentZoom = zoomLevel
  self.scale = Math.Clamp(2 / self.currentZoom, 0.3, 1.5)
  UiTransformBus.Event.SetScale(self.entityId, Vector2(self.scale, self.scale))
end
return GlobalMapEntityIcon

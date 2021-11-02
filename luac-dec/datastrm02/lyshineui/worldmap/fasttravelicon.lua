BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local FastTravelIcon = {
  Properties = {
    IconImage = {
      default = EntityId()
    },
    Content = {
      default = EntityId()
    }
  },
  FLYOUT_CONTEXT = "FastTravelIcon",
  fastTravelPopupId = "fast_travel_icon_popup_id",
  unselected_icon = "lyShineui/images/map/icon/icon_map_fasttravel.dds",
  selected_icon = "lyShineui/images/map/icon/icon_map_fasttravel_selected.dds",
  currentZoom = 2,
  zoomScales = {},
  filterVisible = true
}
BaseElement:CreateNewElement(FastTravelIcon)
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local fastTravelCommon = RequireScript("LyShineUI._Common.FastTravelCommon")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local hoverIntentDetector = RequireScript("LyShineUI._Common.HoverIntentDetector")
local TooltipCommon = RequireScript("LyShineUI._Common.TooltipCommon")
function FastTravelIcon:OnInit()
  BaseElement.OnInit(self)
  self.zoomScales = {
    [0.25] = 1.5,
    [0.5] = 1.5,
    [1] = 1.5,
    [2] = 1,
    [4] = 1,
    [8] = 0.75,
    [16] = 0.5
  }
  self.iconTypes = mapTypes.iconTypes
  self.fastTravelErrorToText = fastTravelCommon.fastTravelErrorToText
  UiInteractableBus.Event.SetHoverEnterEventHandlingScale(self.Properties.IconImage, Vector2(0.6, 0.6))
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.playerEntityId = playerEntityId
    end
  end)
end
function FastTravelIcon:OnHoverStart()
  if self.iconData.titleText and self.iconData.titleText ~= "" and self.iconData.descriptionText and self.iconData.descriptionText ~= "" then
    hoverIntentDetector:OnHoverDetected(self, self.ShowFlyoutMenu)
    UiImageBus.Event.SetSpritePathname(self.Properties.IconImage, self.selected_icon)
    self.originalScale = UiTransformBus.Event.GetScaleX(self.entityId)
    self.ScriptedEntityTweener:Play(self.entityId, 0.05, {
      scaleX = self.originalScale * 1.2,
      scaleY = self.originalScale * 1.2,
      ease = "QuadOut"
    })
    self.audioHelper:PlaySound(self.audioHelper.MapIconOnHover)
  end
end
function FastTravelIcon:OnHoverEnd()
  UiImageBus.Event.SetSpritePathname(self.Properties.IconImage, self.unselected_icon)
  if self.originalScale then
    self.ScriptedEntityTweener:Play(self.entityId, 0.05, {
      scaleX = self.originalScale,
      scaleY = self.originalScale
    })
    self.originalScale = nil
  end
  hoverIntentDetector:StopHoverDetected(self)
end
function FastTravelIcon:ShowFlyoutMenu()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  local rows = {}
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_PointOfInterest,
    header = self.iconData.titleText,
    subtext = self.iconData.descriptionText,
    bottomPadding = 0,
    tooltipBackground = "lyshineui/images/map/tooltipimages/maptooltip_spiritshrine.dds"
  })
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_Subheader,
    header = "@ui_travel",
    textSize = 18
  })
  local buttonText = "@ui_fast_travel"
  local timerText, timerIcon, costText, totalText, buttonTextTertiary
  local buttonIcon = "LyShineUI/Images/map/icon/icon_fastTravel_button.dds"
  local refreshTimer, cooldownEndCallback, cooldownTimeWallClock, timerLocTag
  local fastTravelResult = PlayerHousingClientRequestBus.Broadcast.CanFastTravelToTerritoryLandmark(self.iconData.index, eTerritoryLandmarkType_FastTravelPoint)
  local canFastTravel = fastTravelResult == eCanFastTravelToSettlementResults_Success
  local azothAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothAmount") or 0
  local fastTravelCost = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryLandmarkCost(self.iconData.index, eTerritoryLandmarkType_FastTravelPoint)
  costText = fastTravelCost
  totalText = azothAmount .. " /"
  timerIcon = "lyshineui/images/icon_azoth.dds"
  if not canFastTravel then
    buttonTextTertiary = self.fastTravelErrorToText[fastTravelResult]
  end
  local fastTravelPopupHeader = "@ui_fast_travel"
  local fastTravelPopupDesc = "@ui_fast_travel_popup_confirm"
  local bottomPadding = 28
  local tooltipInfo
  local factionDiscountPct = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryFactionDiscountPct()
  local companyDiscountPct = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryCompanyDiscountPct()
  local attributeDiscountPct = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryAttributeDiscountPct()
  local costs = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryLandmarkCosts(self.iconData.index, eTerritoryLandmarkType_FastTravelPoint)
  local distanceCost = math.floor(costs.distanceCost)
  local encumbranceCost = math.floor(costs.encumbranceCost)
  local baseCost = math.floor(costs.baseCost)
  local territoryId = LandClaimRequestBus.Broadcast.GetTerritoryIdForWorldPos(self.iconData.worldPosition)
  local governanceData = LandClaimRequestBus.Broadcast.GetTerritoryGovernanceData(territoryId)
  local overdueUpkeep = governanceData.failedToPayUpkeep
  local factionType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  local myGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(territoryId)
  local hasFactionDiscount = factionType == ownerData.faction and factionType ~= nil and factionType ~= eFactionType_None and not overdueUpkeep
  local hasCompanyDiscount = ownerData.guildId ~= nil and myGuildId == ownerData.guildId and not overdueUpkeep
  local totalFCPDiscount = costs.baseCostDiscount + costs.distanceCostDiscount + costs.encumbranceCostDiscount
  tooltipInfo = {
    isDiscount = true,
    name = "@ui_tooltip_fasttravel_cost",
    costEntries = {
      {
        name = "@ui_tooltip_base_cost",
        type = TooltipCommon.DiscountEntryTypes.Cost,
        cost = baseCost + costs.baseCostDiscount
      },
      {
        name = "@ui_tooltip_distance_cost",
        type = TooltipCommon.DiscountEntryTypes.Cost,
        cost = distanceCost + costs.distanceCostDiscount
      },
      {
        name = "@ui_tooltip_encumbrance_cost",
        type = TooltipCommon.DiscountEntryTypes.Cost,
        cost = encumbranceCost + costs.encumbranceCostDiscount
      }
    },
    costEntriesDiscounts = {
      {
        name = "@ui_fcp_fast_travel_discounts_title",
        type = TooltipCommon.DiscountEntryTypes.CostDiscounts,
        discount = totalFCPDiscount
      }
    },
    discountEntries = {
      {
        name = "@ui_tooltip_faction_discount",
        type = TooltipCommon.DiscountEntryTypes.Faction,
        discountPct = factionDiscountPct,
        hasDiscount = hasFactionDiscount,
        roundValue = true
      },
      {
        name = "@ui_tooltip_company_discount",
        type = TooltipCommon.DiscountEntryTypes.Company,
        discountPct = companyDiscountPct,
        hasDiscount = hasCompanyDiscount,
        roundValue = true
      }
    }
  }
  if attributeDiscountPct ~= 0 then
    table.insert(tooltipInfo.discountEntries, {
      name = "@ui_tooltip_attribute_discount",
      type = TooltipCommon.DiscountEntryTypes.Attribute,
      discountPct = attributeDiscountPct,
      hasDiscount = true,
      roundValue = true
    })
  end
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_Button,
    buttonText = buttonText,
    isEnabled = canFastTravel,
    icon = buttonIcon,
    buttonTextTertiary = buttonTextTertiary,
    timer = timerText,
    cost = costText,
    total = totalText,
    timerIcon = timerIcon,
    bottomPadding = bottomPadding,
    refreshTimer = refreshTimer,
    timeWallClock = cooldownTimeWallClock,
    timerEndCallback = cooldownEndCallback,
    timerLocTag = timerLocTag,
    tooltipInfo = tooltipInfo,
    callbackTable = self,
    callback = function(self)
      if canFastTravel then
        self:RequestFastTravelPopup(fastTravelPopupHeader, fastTravelPopupDesc)
      end
    end
  })
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
  flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
  flyoutMenu:SetOpenLocation(self.Properties.IconImage)
  flyoutMenu:EnableFlyoutDelay(false)
  flyoutMenu:SetFadeInTime(0.05)
  flyoutMenu:SetFadeOutTime(0.05)
  flyoutMenu:SetSourceHoverOnly(false)
  flyoutMenu:SetRowData(rows)
end
function FastTravelIcon:RequestFastTravelPopup(fastTravelText, fastTravelDesc)
  popupWrapper:RequestPopup(ePopupButtons_YesNo, fastTravelText, fastTravelDesc, self.fastTravelPopupId, self, function(self, result, eventId)
    if eventId == self.fastTravelPopupId and result == ePopupResult_Yes then
      local numMissionsAbandonedOnFastTravel = ObjectivesComponentRequestBus.Event.GetNumObjectivesCannotFastTravel(self.playerEntityId)
      if numMissionsAbandonedOnFastTravel == 0 then
        self:RequestFastTravel()
      else
        do
          local confirmAbandonText = GetLocalizedReplacementText("@ui_fast_travel_mission_abandon_confirm", {count = numMissionsAbandonedOnFastTravel})
          local abandonMissionsId = "FastTravelAbandon"
          popupWrapper:RequestPopup(ePopupButtons_YesNo, "@owg_action_abandon", confirmAbandonText, abandonMissionsId, self, function(self, result, eventId)
            if eventId == abandonMissionsId and result == ePopupResult_Yes then
              self:RequestFastTravel()
            end
          end)
        end
      end
    end
  end)
end
function FastTravelIcon:RequestFastTravel()
  PlayerHousingClientRequestBus.Broadcast.RequestFastTravelToTerritory(self.iconData.index, false, true)
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
function FastTravelIcon:OnRightClick()
  DynamicBus.MagicMap.Broadcast.MapRightClick()
end
function FastTravelIcon:SetData(iconData)
  self.iconData = iconData
  if iconData.dataManager and iconData.dataManager.markersLayer then
    local sourceType = iconData.dataManager.markersLayer.sourceType
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.ZoomLevelMPP." .. sourceType, self.OnZoomLevelChanged)
    self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.HomePoints.Count", function(self, dataNode)
      self.isEnabled = PlayerHousingClientRequestBus.Broadcast.HasFastTravelPointInTerritory(self.iconData.index, false)
      self:UpdateVisibility()
    end)
  end
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, iconData.anchors)
end
function FastTravelIcon:UpdateAnchors(anchors)
  self.iconData.anchors = anchors
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, anchors)
end
function FastTravelIcon:OnZoomLevelChanged(zoomLevel)
  if not zoomLevel or zoomLevel == self.currentZoom then
    return
  end
  self.currentZoom = zoomLevel
  if self.zoomScales[self.currentZoom] ~= nil then
    self.scale = self.zoomScales[self.currentZoom]
  else
    self.scale = Math.Clamp(2 / self.currentZoom, 0.5, 1.5)
  end
  self.isVisible = true
  UiTransformBus.Event.SetScale(self.entityId, Vector2(self.scale, self.scale))
  self:UpdateVisibility()
end
function FastTravelIcon:SetFilterVisibility(isVisible)
  self.filterVisible = isVisible
  self:UpdateVisibility()
end
function FastTravelIcon:SetIsVisible(isVisible)
  self.isVisible = isVisible
  self:UpdateVisibility()
end
function FastTravelIcon:UpdateVisibility()
  UiElementBus.Event.SetIsEnabled(self.entityId, self.isEnabled and self.isVisible and self.filterVisible)
end
return FastTravelIcon

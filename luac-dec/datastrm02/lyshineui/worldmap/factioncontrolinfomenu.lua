local FactionControlInfoMenu = {
  Properties = {
    HeaderImage = {
      FortNameText = {
        default = EntityId()
      },
      DescriptionText = {
        default = EntityId()
      },
      FortImage = {
        default = EntityId()
      }
    },
    Claim = {
      ReminderText = {
        default = EntityId()
      },
      StatusIcon = {
        default = EntityId()
      },
      FactionNameText = {
        default = EntityId()
      },
      FactionImage = {
        default = EntityId()
      },
      ControlledByLabel = {
        default = EntityId()
      },
      ClaimLabel = {
        default = EntityId()
      },
      ClaimText = {
        default = EntityId()
      },
      LockIcon = {
        default = EntityId()
      }
    },
    Bonuses = {
      TitleText = {
        default = EntityId()
      },
      BenefitsText = {
        default = EntityId()
      },
      TerritoryBonusesHeader = {
        default = EntityId()
      },
      TerritoryBonusContainer = {
        default = EntityId()
      },
      TerritoryBonusList = {
        default = EntityId()
      },
      FactionBonusHeader = {
        default = EntityId()
      },
      FactionBonusContainer = {
        default = EntityId()
      },
      FactionBonusList = {
        default = EntityId()
      }
    },
    CloseButton = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FactionControlInfoMenu)
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local FcpCommon = RequireScript("LyShineUI._Common.FactionControlPointCommon")
function FactionControlInfoMenu:OnInit()
  BaseElement.OnInit(self)
  self.panelTypes = mapTypes.panelTypes
  DynamicBus.Map.Connect(self.entityId, self)
  self.CloseButton:SetCallback(self.OnFactionControlInfoClose, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_SIDE_PANEL_RIGHT)
  SetTextStyle(self.Properties.Claim.ReminderText, self.UIStyle.FONT_STYLE_FACTIONCONTROL_BODY_TEXT)
  SetTextStyle(self.Properties.Claim.ControlledByLabel, self.UIStyle.FONT_STYLE_FACTIONCONTROL_LINEITEM_HEADER)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Claim.ControlledByLabel, "@ui_factioncontrol_controlledby_label", eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.Claim.ClaimLabel, self.UIStyle.FONT_STYLE_FACTIONCONTROL_LINEITEM_HEADER)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Claim.ClaimLabel, "@ui_factioncontrol_status_label:", eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.Bonuses.TitleText, self.UIStyle.FONT_STYLE_FACTIONCONTROL_HEADER)
  SetTextStyle(self.Properties.Bonuses.BenefitsText, self.UIStyle.FONT_STYLE_FACTIONCONTROL_BODY_TEXT)
  SetTextStyle(self.Properties.Bonuses.TerritoryBonusesHeader, self.UIStyle.FONT_STYLE_FACTIONCONTROL_SUB_HEADER)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Bonuses.TerritoryBonusesHeader, "@ui_factioncontrol_territory_bonuses_label:", eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.Bonuses.FactionBonusHeader, self.UIStyle.FONT_STYLE_FACTIONCONTROL_SUB_HEADER)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Bonuses.FactionBonusHeader, "@ui_factioncontrol_faction_bonuses_label:", eUiTextSet_SetLocalized)
end
function FactionControlInfoMenu:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
end
function FactionControlInfoMenu:OnShowPanel(panelType, settlementId)
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
    if panelType ~= self.panelTypes.Fortress then
      self:SetVisibility(false)
      return
    end
    self.settlementId = settlementId
    if self.landClaimHandler then
      self:BusDisconnect(self.landClaimHandler)
    end
    self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, settlementId)
    local posData = LandClaimRequestBus.Broadcast.GetClaimPosData(settlementId)
    local factionOwner = LandClaimRequestBus.Broadcast.GetFactionControlOwner(settlementId)
    local captureStatus = LandClaimRequestBus.Broadcast.GetFactionControlCaptureStatus(settlementId)
    self.isContested = captureStatus == eFactionControlCaptureStatus_Contested
    self:UpdatePosition(posData)
    self:UpdateFactionOwnership(factionOwner)
    self:SetupBonuses()
    self:SetVisibility(true)
  else
    self:SetVisibility(false)
  end
end
function FactionControlInfoMenu:OnFactionControlInfoClose()
  self:SetVisibility(false)
end
function FactionControlInfoMenu:SetVisibility(isVisible)
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
    if self.landClaimHandler then
      self:BusDisconnect(self.landClaimHandler)
    end
    self.landClaimHandler = nil
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
function FactionControlInfoMenu:UpdatePosition(posData)
  if posData then
    local territoryName = posData.territoryName
    if territoryName == nil or territoryName == "" then
      local vec2Pos = Vector2(posData.worldPos.x, posData.worldPos.y)
      local tract = MapComponentBus.Broadcast.GetTractAtPosition(vec2Pos)
      territoryName = "@" .. tract
    end
    local tierInfo = TerritoryDataHandler:GetUpgradeTierInfoByTerritoryId(self.settlementId, eTerritoryUpgradeType_Fortress)
    local nameText = GetLocalizedReplacementText("@ui_fortress_header", {
      name = territoryName,
      tier = tierInfo.name
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderImage.FortNameText, nameText, eUiTextSet_SetAsIs)
    local descriptionText = GetLocalizedReplacementText("@ui_fortressinfo_description", {name = territoryName})
    UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderImage.DescriptionText, descriptionText, eUiTextSet_SetAsIs)
    local imagePath = "lyshineui/images/map/panelImages/mapPanel_fort" .. self.settlementId .. ".dds"
    local invalidImagePath = "lyshineui/images/map/panelImages/mapPanel_fort_default.dds"
    if not LyShineScriptBindRequestBus.Broadcast.IsFileExists(imagePath) then
      imagePath = invalidImagePath
    end
    UiImageBus.Event.SetSpritePathname(self.Properties.HeaderImage.FortImage, imagePath)
  end
end
function FactionControlInfoMenu:UpdateFactionOwnership(faction)
  local isClaimed = faction ~= eFactionType_None
  SetTextStyle(self.Properties.Claim.ClaimText, self.UIStyle.FONT_STYLE_FACTIONCONTROL_BODY_TEXT)
  local imagePath = "lyshineui/images/icons/territory/icon_whiteflag.dds"
  UiImageBus.Event.SetColor(self.Properties.Claim.StatusIcon, self.UIStyle.COLOR_WHITE)
  if not isClaimed then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Claim.ReminderText, "@ui_factioncontrol_reminder_unclaimed", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Claim.ClaimText, "@ui_factioncontrol_unclaimed", eUiTextSet_SetLocalized)
  else
    local reminderString
    if FactionControlLandClaimClientRequestBus.Broadcast.GetFactionControlIsActive(self.settlementId) then
      reminderString = "@ui_factioncontrol_reminder_map"
      UiElementBus.Event.SetIsEnabled(self.Properties.Claim.LockIcon, false)
    else
      reminderString = FcpCommon:BuildReminderString(self.settlementId)
      UiElementBus.Event.SetIsEnabled(self.Properties.Claim.LockIcon, true)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.Claim.ReminderText, reminderString, eUiTextSet_SetLocalized)
    self:SetFactionInfo(faction)
    if self.isContested then
      imagePath = "lyshineui/images/map/icon/icon_crossedswords_small_white.dds"
      UiImageBus.Event.SetColor(self.Properties.Claim.StatusIcon, self.UIStyle.COLOR_CONTESTED_RED)
      SetTextStyle(self.Properties.Claim.ClaimText, self.UIStyle.FONT_STYLE_FACTIONCONTROL_CONTESTED_BODY_TEXT)
      UiTextBus.Event.SetTextWithFlags(self.Properties.Claim.ClaimText, "@ui_factioncontrol_contested", eUiTextSet_SetLocalized)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.Claim.ClaimText, "@ui_factioncontrol_claimed", eUiTextSet_SetLocalized)
    end
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Claim.StatusIcon, imagePath)
  UiElementBus.Event.SetIsEnabled(self.Properties.Claim.ControlledByLabel, isClaimed)
  UiElementBus.Event.SetIsEnabled(self.Properties.Claim.FactionImage, isClaimed)
  UiElementBus.Event.SetIsEnabled(self.Properties.Claim.FactionNameText, isClaimed)
end
function FactionControlInfoMenu:SetFactionInfo(faction)
  local factionData = FactionCommon.factionInfoTable[faction]
  if factionData then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Claim.FactionNameText, factionData.factionName, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.Claim.FactionNameText, factionData.chatColor)
    UiImageBus.Event.SetSpritePathname(self.Properties.Claim.FactionImage, factionData.crestFg)
    UiImageBus.Event.SetColor(self.Properties.Claim.FactionImage, factionData.crestBgColor)
  end
end
function FactionControlInfoMenu:OnFactionControlStatusChanged(settlementId, faction, captureStatus, isActive)
  if settlementId == self.settlementId then
    self.isContested = captureStatus == eFactionControlCaptureStatus_Contested
    self:UpdateFactionOwnership(faction)
  end
end
function FactionControlInfoMenu:SetupBonuses()
  if self.settlementId == nil then
    return
  end
  self:PopulateBonusList(self.Properties.Bonuses.TerritoryBonusList, FcpCommon:GetTerritoryBonuses(self.settlementId))
  self:PopulateBonusList(self.Properties.Bonuses.FactionBonusList, FcpCommon:GetFactionBonuses(self.settlementId))
end
function FactionControlInfoMenu:PopulateBonusList(listEntityId, bonusList)
  if #bonusList == 0 then
    Log("ERROR: FactionControlInfoMenu:PopulateBonusList - Territory Id " .. self.settlementId .. " has no bonuses")
  end
  UiDynamicLayoutBus.Event.SetNumChildElements(listEntityId, #bonusList)
  for i = 1, #bonusList do
    local childElement = UiElementBus.Event.GetChild(listEntityId, i - 1)
    local nameId = UiElementBus.Event.FindChildByName(childElement, "Name")
    UiTextBus.Event.SetTextWithFlags(nameId, bonusList[i].bonusName, eUiTextSet_SetLocalized)
    local valueId = UiElementBus.Event.FindChildByName(childElement, "Stat")
    UiTextBus.Event.SetText(valueId, bonusList[i].bonusValue)
    local iconId = UiElementBus.Event.FindChildByName(childElement, "Icon")
    UiImageBus.Event.SetSpritePathname(iconId, bonusList[i].imagePath)
    local buttonId = UiElementBus.Event.FindChildByName(childElement, "ButtonCircle")
    local buttonItem = self.registrar:GetEntityTable(buttonId)
    buttonItem:SetTooltip(bonusList[i].tooltiptext)
  end
end
return FactionControlInfoMenu

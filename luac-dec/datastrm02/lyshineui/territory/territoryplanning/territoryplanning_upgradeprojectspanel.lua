local TerritoryPlanning_UpgradeProjectsPanel = {
  Properties = {
    IsSettlement = {default = false, order = 0},
    Outline = {
      default = EntityId()
    },
    TierText = {
      default = EntityId()
    },
    TierNameText = {
      default = EntityId()
    },
    UpgradesCompletedText = {
      default = EntityId()
    },
    UpgradeLabelText = {
      default = EntityId()
    },
    TierIcons = {
      default = {
        EntityId()
      }
    },
    UpgradePipIcons = {
      default = {
        EntityId()
      }
    },
    SettlementButtons = {
      BlacksmithingButton = {
        default = EntityId()
      },
      OutfittingButton = {
        default = EntityId()
      },
      EngineeringButton = {
        default = EntityId()
      },
      AlchemyButton = {
        default = EntityId()
      },
      CookingButton = {
        default = EntityId()
      },
      CarpentryButton = {
        default = EntityId()
      },
      TanningButton = {
        default = EntityId()
      },
      WeavingButton = {
        default = EntityId()
      },
      SmeltingButton = {
        default = EntityId()
      },
      MasonryButton = {
        default = EntityId()
      }
    },
    FortButtons = {
      GatesButton = {
        default = EntityId()
      },
      HardPointsButton = {
        default = EntityId()
      },
      BallistaButton = {
        default = EntityId()
      },
      FireBarrelButton = {
        default = EntityId()
      },
      RepeaterButton = {
        default = EntityId()
      },
      HornButton = {
        default = EntityId()
      },
      ExplosiveButton = {
        default = EntityId()
      }
    }
  },
  settlementOutlinePath = "LyShineUI/Images/Territory/Outlines/territoryPlanning_town%d.dds",
  fortOutlinePath = "LyShineUI/Images/Territory/Outlines/territoryPlanning_fort%d.dds",
  invalidSettlementOutlinePath = "LyShineUI/Images/Territory/Outlines/territoryPlanning_town_invalid.dds",
  invalidFortOutlinePath = "LyShineUI/Images/Territory/Outlines/territoryPlanning_fort_invalid.dds",
  settlementTierPath = "LyShineUI/Images/Icons/Misc/icon_settlement_t",
  fortTierPath = "LyShineUI/Images/Icons/Misc/icon_fort_t"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_UpgradeProjectsPanel)
local territoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
function TerritoryPlanning_UpgradeProjectsPanel:OnInit()
  BaseElement.OnInit(self)
  self.isSettlement = self.Properties.IsSettlement
  if self.isSettlement then
    self.upgradeType = eTerritoryUpgradeType_Settlement
    self.outlinePath = self.settlementOutlinePath
    self.categoryToButton = {
      [eSettlementProgressionCategory_Blacksmithing] = {
        button = self.SettlementButtons.BlacksmithingButton,
        showOnRight = false
      },
      [eSettlementProgressionCategory_Outfitting] = {
        button = self.SettlementButtons.OutfittingButton,
        showOnRight = false
      },
      [eSettlementProgressionCategory_Engineering] = {
        button = self.SettlementButtons.EngineeringButton,
        showOnRight = false
      },
      [eSettlementProgressionCategory_Alchemy] = {
        button = self.SettlementButtons.AlchemyButton,
        showOnRight = false
      },
      [eSettlementProgressionCategory_Cooking] = {
        button = self.SettlementButtons.CookingButton,
        showOnRight = false
      },
      [eSettlementProgressionCategory_Carpentry] = {
        button = self.SettlementButtons.CarpentryButton,
        showOnRight = true
      },
      [eSettlementProgressionCategory_Tanning] = {
        button = self.SettlementButtons.TanningButton,
        showOnRight = true
      },
      [eSettlementProgressionCategory_Weaving] = {
        button = self.SettlementButtons.WeavingButton,
        showOnRight = true
      },
      [eSettlementProgressionCategory_Smelting] = {
        button = self.SettlementButtons.SmeltingButton,
        showOnRight = true
      },
      [eSettlementProgressionCategory_Masonry] = {
        button = self.SettlementButtons.MasonryButton,
        showOnRight = true
      }
    }
  else
    self.upgradeType = eTerritoryUpgradeType_Fortress
    self.outlinePath = self.fortOutlinePath
    self.categoryToButton = {
      [eSettlementProgressionCategory_FortGates] = {
        button = self.FortButtons.GatesButton,
        showOnRight = true
      },
      [eSettlementProgressionCategory_FortHardPoints] = {
        button = self.FortButtons.HardPointsButton,
        showOnRight = true
      },
      [eSettlementProgressionCategory_BallistaUpgrade] = {
        button = self.FortButtons.BallistaButton,
        showOnRight = true
      },
      [eSettlementProgressionCategory_FireBarrelUpgrade] = {
        button = self.FortButtons.FireBarrelButton,
        showOnRight = true
      },
      [eSettlementProgressionCategory_RepeaterUpgrade] = {
        button = self.FortButtons.RepeaterButton,
        showOnRight = true
      },
      [eSettlementProgressionCategory_HornUpgrade] = {
        button = self.FortButtons.HornButton,
        showOnRight = true
      },
      [eSettlementProgressionCategory_ExplosiveUpgrade] = {
        button = self.FortButtons.ExplosiveButton,
        showOnRight = true
      }
    }
  end
  for _, buttonData in pairs(self.categoryToButton) do
    local button = buttonData.button
    button:SetProjectButtonStyle(buttonData.showOnRight and button.STYLE_RIGHT or button.STYLE_LEFT)
  end
end
function TerritoryPlanning_UpgradeProjectsPanel:SetTerritoryId(territoryId)
  local outlinePath = string.format(self.outlinePath, territoryId)
  if not LyShineScriptBindRequestBus.Broadcast.IsFileExists(outlinePath) then
    if self.isSettlement then
      outlinePath = self.invalidSettlementOutlinePath
    else
      outlinePath = self.invalidFortOutlinePath
    end
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Outline, outlinePath)
end
function TerritoryPlanning_UpgradeProjectsPanel:SetUpgradeData(projectGroups)
  for i = 1, #projectGroups do
    local projectGroupData = projectGroups[i]
    local projectGroupElement = projectGroupData[1]
    local button = self.categoryToButton[projectGroupElement.projectCategory].button
    if button then
      button:SetGridItemData(projectGroupData)
    end
  end
end
function TerritoryPlanning_UpgradeProjectsPanel:SetNumProjectsCompleted(numCompleted)
  if self.numCompleted == numCompleted then
    return
  end
  self.numCompleted = numCompleted
  UiTextBus.Event.SetTextWithFlags(self.Properties.UpgradesCompletedText, tostring(numCompleted), eUiTextSet_SetAsIs)
  local upgradeLabelText = numCompleted == 1 and "@ui_projects_done_singular" or "@ui_projects_done"
  UiTextBus.Event.SetTextWithFlags(self.Properties.UpgradeLabelText, upgradeLabelText, eUiTextSet_SetLocalized)
  local tierInfo, tier = territoryDataHandler:GetUpgradeTierInfo(self.upgradeType, numCompleted)
  local tierText = GetLocalizedReplacementText("@ui_territory_upgrade_tier", {
    number = GetRomanFromNumber(tier)
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.TierText, tierText, eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TierNameText, tierInfo.name, eUiTextSet_SetLocalized)
  for i = 0, #self.Properties.TierIcons do
    local icon = self.Properties.TierIcons[i]
    local iconTier = i + 1
    local imageTierPath = self.settlementTierPath
    local imagePath = imageTierPath .. iconTier .. ".png"
    local text = UiElementBus.Event.FindChildByName(icon, "TierText")
    if self.upgradeType == eTerritoryUpgradeType_Settlement then
      imageTierPath = self.settlementTierPath
    elseif self.upgradeType == eTerritoryUpgradeType_Fortress then
      imageTierPath = self.fortTierPath
    end
    if tier >= iconTier then
      imagePath = imageTierPath .. iconTier .. "_enabled.png"
      UiTextBus.Event.SetColor(text, self.UIStyle.COLOR_YELLOW)
    else
      imagePath = imageTierPath .. iconTier .. ".png"
      UiTextBus.Event.SetColor(text, self.UIStyle.COLOR_GRAY_70)
    end
    UiImageBus.Event.SetSpritePathname(icon, imagePath)
  end
  for i = 0, #self.Properties.UpgradePipIcons do
    local icon = self.Properties.UpgradePipIcons[i]
    local iconLevel = i + 1
    local path = numCompleted >= iconLevel and "LyShineUI/Images/Territory/territory_upgradedotfilled.png" or "LyShineUI/Images/Territory/territory_upgradedot.png"
    UiImageBus.Event.SetSpritePathname(icon, path)
  end
end
return TerritoryPlanning_UpgradeProjectsPanel

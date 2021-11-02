local TerritoryDataHandler = {}
local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function TerritoryDataHandler:OnActivate()
end
function TerritoryDataHandler:OnDeactivate()
end
function TerritoryDataHandler:Reset()
  self:OnDeactivate()
end
function TerritoryDataHandler:GetTerritoryProjectDataFromProjectId(projectId)
  local progressionStaticData = TerritoryGovernanceRequestBus.Broadcast.GetTerritoryProgressionData(projectId)
  return {
    projectId = progressionStaticData.id,
    projectIcon = progressionStaticData.icon,
    upgradeType = progressionStaticData.projectType,
    projectImage = progressionStaticData.image,
    projectCurrentTier = progressionStaticData.currentTier,
    projectTitle = progressionStaticData.title,
    projectButtonLabel = progressionStaticData.buttonLabel,
    projectDescription = progressionStaticData.description,
    projectTime = progressionStaticData.totalCompletionTime,
    cost = progressionStaticData.cost,
    nextLevelProjectId = progressionStaticData.nextLevelProjectId,
    projectCategory = progressionStaticData.progressionCategory,
    projectCategoryName = progressionStaticData.categoryDisplayName,
    projectLevel = progressionStaticData.progressionLevel,
    currentProgress = 0,
    progressionNeeded = 1,
    projectSubCategory = progressionStaticData.categoryDisplayName,
    lifestyleBuffEffectId = progressionStaticData.lifestyleBuffEffectId,
    lifestyleBuffEffectDuration = progressionStaticData.lifestyleBuffEffectDuration,
    IsActive = function(self)
      local claimKey = dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
      local summaryData = LandClaimRequestBus.Broadcast.GetTerritoryProgressionData(claimKey)
      for i = 1, #summaryData.activeProjects do
        local territoryProgressionProjectSummary = summaryData.activeProjects[i]
        if territoryProgressionProjectSummary.activeProjectId == self.projectId and territoryProgressionProjectSummary.activeState ~= eSettlementProgressionState_Cancelled then
          return true
        end
      end
      return false
    end,
    IsComplete = function(self)
      local territoryId = dataLayer:GetDataFromNode("Hud.TerritoryGovernance.EntityId")
      local persistentTerritoryProgressionData = TerritoryInterfaceComponentRequestBus.Event.GetTerritoryProgressionData(territoryId)
      if self.upgradeType == eTerritoryUpgradeType_Lifestyle then
        local territoryStatusEffects = persistentTerritoryProgressionData.territoryStatusEffects
        for i = 1, #territoryStatusEffects do
          if territoryStatusEffects[i].effectId == self.lifestyleBuffEffectId then
            return true
          end
        end
      else
        local completedUpgrades = persistentTerritoryProgressionData.completedTerritoryUpgrades
        for i = 1, #completedUpgrades do
          if completedUpgrades[i].projectId == self.projectId then
            return true
          end
        end
      end
      return false
    end,
    IsAvailable = function(self)
      if self.upgradeType == eTerritoryUpgradeType_Lifestyle then
        return true
      end
      local claimKey = dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
      local summaryData = LandClaimRequestBus.Broadcast.GetTerritoryProgressionData(claimKey)
      local availableTerritoryUpgrades = summaryData.territoryUpgrades
      for i = 1, #availableTerritoryUpgrades do
        local upgradeData = availableTerritoryUpgrades[i]
        if upgradeData.category == self.projectCategory then
          return true
        end
      end
      return false
    end,
    GetProgressPercent = function(self)
      return 0
    end,
    GetTimeRemaining = function(self)
      return 0
    end,
    GetLifestyleEndTime = function(self)
      if self.upgradeType == eTerritoryUpgradeType_Lifestyle then
        local territoryId = dataLayer:GetDataFromNode("Hud.TerritoryGovernance.EntityId")
        local persistentTerritoryProgressionData = TerritoryInterfaceComponentRequestBus.Event.GetTerritoryProgressionData(territoryId)
        local territoryStatusEffects = persistentTerritoryProgressionData.territoryStatusEffects
        for i = 1, #territoryStatusEffects do
          local statusEffect = territoryStatusEffects[i]
          if statusEffect.effectId == self.lifestyleBuffEffectId then
            return statusEffect.endTimestamp
          end
        end
      end
    end
  }, progressionStaticData
end
function TerritoryDataHandler:GetTerritoryProjectUpgrades()
  local allTerritoryProjectIds = TerritoryGovernanceRequestBus.Broadcast.GetTerritoryProgressionProjectIds()
  local upgradeData = {}
  for i = 1, #allTerritoryProjectIds do
    local projectId = allTerritoryProjectIds[i]
    local territoryProject = self:GetTerritoryProjectDataFromProjectId(projectId)
    table.insert(upgradeData, territoryProject)
  end
  return upgradeData
end
function TerritoryDataHandler:GetUpgradesDonePerClaimAndType(claimKey, territoryUpgradeType)
  local summaryData = LandClaimRequestBus.Broadcast.GetTerritoryProgressionData(claimKey)
  local availableTerritoryUpgrades = summaryData.territoryUpgrades
  local upgradesDone = 0
  for i = 1, #availableTerritoryUpgrades do
    local upgradeData = availableTerritoryUpgrades[i]
    if territoryUpgradeType == upgradeData.category then
      upgradesDone = upgradesDone + 1
    end
  end
  return upgradesDone
end
function TerritoryDataHandler:GetAvailableTerritoryProjectUpgrades()
  local territoryProjectUpgrades = self:GetTerritoryProjectUpgrades()
  local territoryIdToRelatedProjectId = {}
  local territoryIdLeafNodes = {}
  local territoryIdToData = {}
  for i, territoryData in ipairs(territoryProjectUpgrades) do
    if territoryData.nextLevelProjectId ~= 0 then
      territoryIdToRelatedProjectId[territoryData.nextLevelProjectId] = territoryData.projectId
    else
      table.insert(territoryIdLeafNodes, territoryData.projectId)
    end
    territoryIdToData[territoryData.projectId] = territoryData
  end
  local projectGroups = {}
  for _, projectId in pairs(territoryIdLeafNodes) do
    local projectGroup = {}
    local parentProjectId = projectId
    while parentProjectId do
      table.insert(projectGroup, 1, territoryIdToData[parentProjectId])
      parentProjectId = territoryIdToRelatedProjectId[parentProjectId]
    end
    projectGroup.maxLevel = #projectGroup
    table.insert(projectGroups, projectGroup)
  end
  return projectGroups
end
function TerritoryDataHandler:GetAdditionalDetailsForProjectUpgrade(projectId, upgradeType)
  if upgradeType == eTerritoryUpgradeType_Settlement then
    if not self.settlementAdditionalDetails then
      self.settlementAdditionalDetails = {
        [3221089780] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/1hswordt3.png",
            upgradeDetailText = "@ui_reward_BlacksmithProjectId_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/1hsicklet3.png",
            upgradeDetailText = "@ui_reward_BlacksmithProjectId_2"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/armor/heavychestat3.png",
            upgradeDetailText = "@ui_reward_BlacksmithProjectId_3"
          }
        },
        [2696574437] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/1hswordt4.png",
            upgradeDetailText = "@ui_reward_BlacksmithProjectId2_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/1hsicklet4.png",
            upgradeDetailText = "@ui_reward_BlacksmithProjectId2_2"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/armor/heavychestat4.png",
            upgradeDetailText = "@ui_reward_BlacksmithProjectId2_3"
          }
        },
        [3619505523] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/1hswordt5.png",
            upgradeDetailText = "@ui_reward_BlacksmithProjectId3_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/1hsicklet5.png",
            upgradeDetailText = "@ui_reward_BlacksmithProjectId3_2"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/armor/heavychestat5.png",
            upgradeDetailText = "@ui_reward_BlacksmithProjectId3_3"
          }
        },
        [4167761087] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/resource/IngotT4.png",
            upgradeDetailText = "@IngotT4_MasterName"
          }
        },
        [1106475756] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/resource/IngotT5.png",
            upgradeDetailText = "@IngotT5_MasterName"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/resource/IngotPreciousT3.png",
            upgradeDetailText = "@IngotPreciousT3_MasterName"
          }
        },
        [2829357662] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items_hires/TimberT4.png",
            upgradeDetailText = "@TimberT4_MasterName"
          }
        },
        [2528011884] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items_hires/TimberT5.png",
            upgradeDetailText = "@TimberT5_MasterName"
          }
        },
        [3935775224] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/resource/BlockT4.png",
            upgradeDetailText = "@BlockT4_MasterName"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/resource/GarnetCutT3.png",
            upgradeDetailText = "@GenericGemCutT3"
          }
        },
        [2841203466] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/resource/BlockT5.png",
            upgradeDetailText = "@BlockT5_MasterName"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/resource/GarnetCutT4.png",
            upgradeDetailText = "@GenericGemCutT4"
          }
        },
        [790794754] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items_hires/ClothT4.png",
            upgradeDetailText = "@ClothT4_MasterName"
          }
        },
        [4109696435] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items_hires/ClothT5.png",
            upgradeDetailText = "@ClothT5_MasterName"
          }
        },
        [872841938] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/resource/LeatherT4.png",
            upgradeDetailText = "@LeatherT4_MasterName"
          }
        },
        [1916537719] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/resource/LeatherT5.png",
            upgradeDetailText = "@LeatherT5_MasterName"
          }
        },
        [3251382872] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hmuskett2.png",
            upgradeDetailText = "@ui_reward_EngineeringProjectId_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/ammo/ShotT3.png",
            upgradeDetailText = "@ui_reward_EngineeringProjectId_2"
          }
        },
        [2141498337] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hmuskett3.png",
            upgradeDetailText = "@ui_reward_EngineeringProjectId2_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/ammo/ShotT4.png",
            upgradeDetailText = "@ui_reward_EngineeringProjectId2_2"
          }
        },
        [144939895] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hmuskett4.png",
            upgradeDetailText = "@ui_reward_EngineeringProjectId3_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/ammo/ShotT5.png",
            upgradeDetailText = "@ui_reward_EngineeringProjectId3_2"
          }
        },
        [2220614008] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/armor/LightChestAT3.png",
            upgradeDetailText = "@ui_reward_OutfittingProjectId_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/armor/MediumChestAT3.png",
            upgradeDetailText = "@ui_reward_OutfittingProjectId_2"
          }
        },
        [1150229730] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/armor/LightChestAT4.png",
            upgradeDetailText = "@ui_reward_OutfittingProjectId2_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/armor/MediumChestAT4.png",
            upgradeDetailText = "@ui_reward_OutfittingProjectId2_2"
          }
        },
        [864562292] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/armor/LightChestAT5.png",
            upgradeDetailText = "@ui_reward_OutfittingProjectId3_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/armor/MediumChestAT5.png",
            upgradeDetailText = "@ui_reward_OutfittingProjectId3_2"
          }
        },
        [1734832804] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/consumable/PotionHealthT2.png",
            upgradeDetailText = "@ui_reward_AlchemistProjectId_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hElementalStaff_FireT3.png",
            upgradeDetailText = "@2hElementalStaff_FireT3_MasterName"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hCelestialStaff_LifeT3.png",
            upgradeDetailText = "@2hCelestialStaff_LifeT3_MasterName"
          }
        },
        [3406413454] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/consumable/PotionHealthT3.png",
            upgradeDetailText = "@ui_reward_AlchemistProjectId2_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hElementalStaff_FireT4.png",
            upgradeDetailText = "@2hElementalStaff_FireT4_MasterName"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hCelestialStaff_LifeT4.png",
            upgradeDetailText = "@2hCelestialStaff_LifeT4_MasterName"
          }
        },
        [3155070488] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/consumable/PotionHealthT4.png",
            upgradeDetailText = "@ui_reward_AlchemistProjectId3_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hElementalStaff_FireT5.png",
            upgradeDetailText = "@2hElementalStaff_FireT5_MasterName"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hCelestialStaff_LifeT5.png",
            upgradeDetailText = "@2hCelestialStaff_LifeT5_MasterName"
          }
        },
        [1116409385] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/consumable/FoodEngineerT3.png",
            upgradeDetailText = "@ui_reward_CookingProjectId_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/consumable/Drink5T3.png",
            upgradeDetailText = "@ui_reward_CookingProjectId_2"
          }
        },
        [1478864239] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/consumable/FoodDEXFOCT4.png",
            upgradeDetailText = "@ui_reward_CookingProjectId2_1"
          },
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items/consumable/Drink5T4.png",
            upgradeDetailText = "@ui_reward_CookingProjectId2_2"
          }
        },
        [790797817] = {
          {
            upgradeDetailIcon = "LyShineUI/images/icons/items_hires/FoodDEXSTRT5.png",
            upgradeDetailText = "@ui_reward_CookingProjectId3_1"
          }
        }
      }
    end
    local detailData = self.settlementAdditionalDetails[projectId]
    if not detailData then
      return {
        {
          upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hDemoHammerT3.png",
          upgradeDetailText = "Reward 1"
        },
        {
          upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/1hsicklet3.png",
          upgradeDetailText = "Reward 2"
        }
      }
    end
    return detailData
  elseif upgradeType == eTerritoryUpgradeType_Fortress then
    if not self.fortAdditionalDetails then
      self.fortAdditionalDetails = {
        [3522641493] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_gate.png",
            upgradeDetailText = "@ui_upgrade_button_FortGatesProjectId2"
          }
        },
        [17165384] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_gate.png",
            upgradeDetailText = "@ui_upgrade_button_FortGatesProjectId3"
          }
        },
        [2767160949] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_fort_hardpoint.png",
            upgradeDetailText = "@ui_reward_FortHardPointsProjectId"
          }
        },
        [975098936] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_fort_hardpoint.png",
            upgradeDetailText = "@ui_reward_FortHardPointsProjectId2"
          }
        },
        [485456798] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_ballistaT2.png",
            upgradeDetailText = "@ui_upgrade_button_BallistaProjectId2"
          }
        },
        [226422581] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_ballistaT3.png",
            upgradeDetailText = "@ui_upgrade_button_BallistaProjectId3"
          }
        },
        [752682656] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_firebarrelT2.png",
            upgradeDetailText = "@ui_upgrade_button_FireBarrelProjectId2"
          }
        },
        [3425681635] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_firebarrelT3.png",
            upgradeDetailText = "@ui_upgrade_button_FireBarrelProjectId3"
          }
        },
        [3342509408] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_repeaterT2.png",
            upgradeDetailText = "@ui_upgrade_button_RepeaterProjectId2"
          }
        },
        [1470162416] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_repeaterT3.png",
            upgradeDetailText = "@ui_upgrade_button_RepeaterProjectId3"
          }
        },
        [2157306644] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_warhornT2.png",
            upgradeDetailText = "@ui_upgrade_button_HornProjectId2"
          }
        },
        [9437075] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_warhornT3.png",
            upgradeDetailText = "@ui_upgrade_button_HornProjectId3"
          }
        },
        [969848383] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_explosiveLauncherT2.png",
            upgradeDetailText = "@ui_upgrade_button_ExplosiveProjectId2"
          }
        },
        [2894749062] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Territory/townProjectImages/townProject_explosiveLauncherT3.png",
            upgradeDetailText = "@ui_upgrade_button_ExplosiveProjectId3"
          }
        }
      }
    end
    local detailData = self.fortAdditionalDetails[projectId]
    if not detailData then
      return {
        {
          upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hDemoHammerT3.png",
          upgradeDetailText = "Reward 1"
        },
        {
          upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/1hsicklet3.png",
          upgradeDetailText = "Reward 2"
        }
      }
    end
    return detailData
  elseif upgradeType == eTerritoryUpgradeType_Lifestyle then
    if not self.fortAdditionalDetails then
      self.fortAdditionalDetails = {
        [1268736313] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_logging.png",
            upgradeDetailText = "@lifestyle_button_LumberJackSpiritProjectId"
          }
        },
        [3702925108] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_mining.png",
            upgradeDetailText = "@lifestyle_button_MinersResolveProjectId"
          }
        },
        [434658486] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_skinning.png",
            upgradeDetailText = "@lifestyle_button_HuntersBountyProjectId"
          }
        },
        [2709415009] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_farming.png",
            upgradeDetailText = "@lifestyle_button_FarmersHarvestProjectId"
          }
        },
        [3344018718] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_damage.png",
            upgradeDetailText = "@lifestyle_button_ArcaneBlessingProjectId"
          }
        },
        [338734146] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_HP.png",
            upgradeDetailText = "@lifestyle_button_HaleAndHeartyProjectId"
          }
        },
        [2600066891] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_defense.png",
            upgradeDetailText = "@lifestyle_button_StalwartProjectId"
          }
        },
        [4281938261] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_outfitting.png",
            upgradeDetailText = "@lifestyle_button_OutfittersInspirationProjectId"
          }
        },
        [1767656898] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_blacksmith.png",
            upgradeDetailText = "@lifestyle_button_BlacksmithTemperamentProjectId"
          }
        },
        [1660338562] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_arcane.png",
            upgradeDetailText = "@lifestyle_button_ArcaneWisdomProjectId"
          }
        },
        [1929839827] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_cooking.png",
            upgradeDetailText = "@lifestyle_button_ChefsPassionProjectId"
          }
        },
        [844280886] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_engineering.png",
            upgradeDetailText = "@lifestyle_button_EngineersPatienceProjectId"
          }
        },
        [323268525] = {
          {
            upgradeDetailIcon = "LyShineUI/Images/Icons/Territory/icon_lifestyle_fishing.png",
            upgradeDetailText = "@lifestyle_button_FishermansFortuneProjectId"
          }
        }
      }
    end
    local detailData = self.fortAdditionalDetails[projectId]
    if not detailData then
      return {
        {
          upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/2hDemoHammerT3.png",
          upgradeDetailText = "Reward 1"
        },
        {
          upgradeDetailIcon = "LyShineUI/images/icons/items/weapon/1hsicklet3.png",
          upgradeDetailText = "Reward 2"
        }
      }
    end
    return detailData
  end
end
function TerritoryDataHandler:GetDetailedTerritoryProject(projectId)
  local territoryId = dataLayer:GetDataFromNode("Hud.TerritoryGovernance.EntityId")
  local persistentTerritoryProgressionData = TerritoryInterfaceComponentRequestBus.Event.GetTerritoryProgressionData(territoryId)
  local activeTerritoryProject = persistentTerritoryProgressionData:GetActiveProjectById(projectId)
  local activeTerritoryProjectData, progressionStaticData = self:GetTerritoryProjectDataFromProjectId(projectId)
  local timeProjectEnds = activeTerritoryProject.timeProjectEnds
  activeTerritoryProjectData.currentProgress = activeTerritoryProject.currentProgress
  activeTerritoryProjectData.progressionNeeded = progressionStaticData.progressionNeeded
  function activeTerritoryProjectData:GetTimeRemaining()
    return timeProjectEnds:Subtract(timeHelpers:ServerNow()):ToSeconds()
  end
  function activeTerritoryProjectData:GetProgressPercent()
    return self.currentProgress / self.progressionNeeded
  end
  return activeTerritoryProjectData
end
function TerritoryDataHandler:GetDestination(destinationId)
  if not self.destinationList then
    self.destinationList = MapComponentBus.Broadcast.GetOutposts()
  end
  if not self.claimList then
    self.claimList = MapComponentBus.Broadcast.GetClaims()
  end
  for i = 1, #self.destinationList do
    if destinationId == self.destinationList[i].id then
      return self.destinationList[i]
    end
  end
  for i = 1, #self.claimList do
    if destinationId == self.claimList[i].id then
      return self.claimList[i]
    end
  end
  return nil
end
local typesToUiData = {
  [eMissionGoalType_Gather] = {
    name = "@ui_gather",
    color = UIStyle.COLOR_MISSION_GATHER,
    icon = "lyshineUI/images/missionimages/missionType_gather.dds"
  },
  [eMissionGoalType_Courier] = {
    name = "@ui_courier",
    color = UIStyle.COLOR_MISSION_COURIER,
    icon = "lyshineUI/images/missionimages/missionType_courier.dds"
  },
  [eMissionGoalType_Creative] = {
    name = "@ui_creative",
    color = UIStyle.COLOR_MISSION_CREATIVE,
    icon = "lyshineUI/images/missionimages/missionType_creative.dds"
  },
  [eMissionGoalType_Kill] = {
    name = "@ui_kill",
    color = UIStyle.COLOR_MISSION_KILL,
    icon = "lyshineUI/images/missionimages/missionType_kill.dds"
  },
  [eMissionGoalType_Explore] = {
    name = "@ui_explore",
    color = UIStyle.COLOR_MISSION_EXPLORE,
    icon = "lyshineUI/images/missionimages/missionType_explore.dds"
  },
  [eMissionGoalType_Raid] = {
    name = "@ui_raid",
    color = UIStyle.COLOR_MISSION_RAID,
    icon = "lyshineUI/images/missionimages/missionType_explore.dds"
  },
  [eMissionGoalType_Loot] = {
    name = "@ui_loot",
    color = UIStyle.COLOR_MISSION_LOOT,
    icon = "lyshineUI/images/missionimages/missionType_gather.dds"
  },
  [eMissionGoalType_Hunt] = {
    name = "@ui_hunt",
    color = UIStyle.COLOR_MISSION_HUNT,
    icon = "lyshineUI/images/missionimages/missionType_gather.dds"
  },
  [eMissionGoalType_Fish] = {
    name = "@ui_fish",
    color = UIStyle.COLOR_MISSION_FISH,
    icon = "lyshineUI/images/missionimages/missionType_gather.dds"
  },
  [eMissionGoalType_Mine] = {
    name = "@ui_mine",
    color = UIStyle.COLOR_MISSION_MINE,
    icon = "lyshineUI/images/missionimages/missionType_gather.dds"
  },
  [eMissionGoalType_Harvest] = {
    name = "@ui_harvest",
    color = UIStyle.COLOR_MISSION_HARVEST,
    icon = "lyshineUI/images/missionimages/missionType_gather.dds"
  },
  [eMissionGoalType_Log] = {
    name = "@ui_log",
    color = UIStyle.COLOR_MISSION_LOG,
    icon = "lyshineUI/images/missionimages/missionType_gather.dds"
  },
  [eMissionGoalType_Craft] = {
    name = "@ui_craft",
    color = UIStyle.COLOR_MISSION_CRAFT,
    icon = "lyshineUI/images/missionimages/missionType_gather.dds"
  },
  [eMissionGoalType_Espionage] = {
    name = "@ui_espionage",
    color = UIStyle.COLOR_MISSION_ESPIONAGE,
    icon = "lyshineUI/images/missionimages/missionImage_PvP3.dds"
  },
  [eMissionGoalType_Intercept] = {
    name = "@ui_intercept",
    color = UIStyle.COLOR_MISSION_INTERCEPT,
    icon = "lyshineUI/images/missionimages/missionImage_PvP1.dds"
  },
  [eMissionGoalType_Control] = {
    name = "@ui_control",
    color = UIStyle.COLOR_MISSION_CONTROL,
    icon = "lyshineUI/images/missionimages/missionImage_PvP2.dds"
  },
  [eMissionGoalType_Poach] = {
    name = "@ui_poach",
    color = UIStyle.COLOR_MISSION_POACH,
    icon = "lyshineUI/images/missionimages/missionImage_PvP3.dds"
  }
}
function TerritoryDataHandler:GetObjectivesForTerritory(territoryId, allowNonCommunityGoals)
  local territoryObjectives = {}
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local objectives = ObjectivesComponentRequestBus.Event.GetObjectives(playerEntityId)
  for i = 1, #objectives do
    local missionParams = ObjectiveRequestBus.Event.GetCreationParams(objectives[i])
    if missionParams and (missionParams.isCommunityGoal or allowNonCommunityGoals) then
      local destinationData = self:GetDestination(missionParams.destinationOverride)
      if destinationData and destinationData.settlementId == territoryId then
        table.insert(territoryObjectives, missionParams)
      end
    end
  end
  return territoryObjectives
end
function TerritoryDataHandler:IsProjectTypeValid(type)
  return type == eTerritoryUpgradeType_Fortress or type == eTerritoryUpgradeType_Settlement or type == eTerritoryUpgradeType_Lifestyle or type == eTerritoryUpgradeType_WarPrep or type == eTerritoryUpgradeType_WeakenInvasion or type == eTerritoryUpgradeType_AlwaysAvailable
end
function TerritoryDataHandler:GetOrderedTownProjectCompletedMissions(territoryId, townProjectsById)
  local orderedTasks = {}
  local orphanedTasks = {}
  local currentObjectives = self:GetObjectivesForTerritory(territoryId, false)
  for k, objectiveParams in ipairs(currentObjectives) do
    local goalData = self:GetGoalDataFromObjectiveParams(objectiveParams)
    local progressionStaticData = TerritoryGovernanceRequestBus.Broadcast.GetTerritoryProgressionData(goalData.projectId)
    if progressionStaticData and self:IsProjectTypeValid(progressionStaticData.projectType) then
      function goalData.IsInProgress()
        return true
      end
      if goalData:IsReadyToComplete() then
        if not townProjectsById[goalData.projectId] then
          table.insert(orphanedTasks, goalData)
        else
          table.insert(orderedTasks, goalData)
        end
      end
    end
  end
  for k, orphan in ipairs(orphanedTasks) do
    table.insert(orderedTasks, orphan)
  end
  return orderedTasks
end
function TerritoryDataHandler:GetSecondsToNextSeed()
  return ObjectiveInteractorRequestBus.Broadcast.GetSecondsToNextSeed()
end
function TerritoryDataHandler:GetAvailableTownProjectTasks(territoryId, projectId)
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local activeMissions = {}
  local goals = {}
  local currentObjectives = self:GetObjectivesForTerritory(territoryId, false)
  for k, objectiveParams in ipairs(currentObjectives) do
    local goalData = self:GetGoalDataFromObjectiveParams(objectiveParams)
    if goalData:IsValidForProjectType(projectId) and goalData:IsAvailable() then
      function goalData.IsInProgress()
        return true
      end
      activeMissions[goalData.missionId] = true
      table.insert(goals, goalData)
    end
  end
  local currentCommunityGoals = ObjectiveInteractorRequestBus.Broadcast.GetCurrentCommunityGoals()
  for i = 1, #currentCommunityGoals do
    local objectiveParams = currentCommunityGoals[i]
    local goalData = self:GetGoalDataFromObjectiveParams(objectiveParams)
    if goalData:IsValidForProjectType(projectId) and not activeMissions[goalData.missionId] then
      table.insert(goals, goalData)
    else
    end
  end
  return goals
end
function TerritoryDataHandler:LocalizeMissionData(locString, objectiveParams, missionData)
  missionData = missionData or ObjectivesDataManagerBus.Broadcast.GetMissionData(objectiveParams.missionId)
  local destinationData = self:GetDestination(objectiveParams.destinationOverride)
  local destination = ""
  if destinationData then
    destination = destinationData.nameLocalizationKey
  else
    local originTerritoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(objectiveParams.originTerritoryId)
    destination = originTerritoryDefn.nameLocalizationKey
  end
  local territoryName = ""
  if missionData.territoryIdOverride ~= 0 then
    local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(missionData.territoryIdOverride)
    territoryName = territoryDefn.nameLocalizationKey
  end
  local poiName = ""
  if missionData.poiTagsOverride and 0 < #missionData.poiTagsOverride then
    local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinitionByPoiTag(missionData.poiTagsOverride[1])
    poiName = territoryDefn.nameLocalizationKey
  end
  return GetLocalizedReplacementText(locString, {
    enemyName = "@VC_" .. missionData.taskKillContributionOverride,
    killAmount = tostring(missionData.taskKillContributionQtyOverride),
    destinationName = destination,
    itemName = StaticItemDataManager:GetItemName(missionData.taskHaveItemsOverride),
    itemAmount = tostring(missionData.taskHaveItemsQtyOverride),
    giveItemName = StaticItemDataManager:GetItemName(missionData.taskGiveItemOverride),
    time = tostring(missionData.taskTimerOverride),
    territoryID = territoryName,
    POITags = poiName
  })
end
function TerritoryDataHandler:GetMissionTitle(objectiveParams)
  local missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(objectiveParams.missionId)
  if missionData.isCustomObjective then
    local objectiveData = ObjectivesDataManagerBus.Broadcast.GetObjectiveData(missionData.objectiveId)
    if objectiveData.title and objectiveData.title ~= "" then
      return LyShineScriptBindRequestBus.Broadcast.LocalizeText(objectiveData.title)
    end
  end
  return self:LocalizeMissionData(missionData.titleOverride, objectiveParams, missionData)
end
function TerritoryDataHandler:GetMissionDescription(objectiveParams)
  local missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(objectiveParams.missionId)
  if missionData.isCustomObjective then
    local objectiveData = ObjectivesDataManagerBus.Broadcast.GetObjectiveData(missionData.objectiveId)
    if objectiveData.description and objectiveData.description ~= "" then
      return LyShineScriptBindRequestBus.Broadcast.LocalizeText(objectiveData.description)
    end
  end
  return self:LocalizeMissionData(missionData.descriptionOverride, objectiveParams, missionData)
end
function TerritoryDataHandler:GetGoalDataFromObjectiveParams(objectiveParams, cloneObjParams)
  if cloneObjParams then
    objectiveParams = objectiveParams:Clone()
  end
  local missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(objectiveParams.missionId)
  local objectiveData = ObjectivesDataManagerBus.Broadcast.GetObjectiveData(missionData.objectiveId)
  local missionTitle = self:GetMissionTitle(objectiveParams)
  local missionDescription = self:GetMissionDescription(objectiveParams)
  local originTerritoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(objectiveParams.originTerritoryId)
  local localize = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement
  return {
    projectId = missionData.projectId,
    missionId = objectiveParams.missionId,
    objectiveInstanceId = objectiveParams.instanceId,
    image = missionData.imagePath,
    detailImage = missionData.detailImagePath,
    taskType = missionData.missionGoalType,
    title = missionTitle,
    description = missionDescription,
    timeLimit = missionData.taskTimerOverride,
    itemsToCollect = missionData.taskHaveItemsOverride,
    itemCount = missionData.taskHaveItemsQtyOverride,
    missionObjectiveId = missionData.objectiveId,
    isPvpMission = missionData.isPvpMission,
    objectiveParams = objectiveParams,
    GetRewardData = function(self)
      local successRewardDataId = objectiveData.successGameEventId
      if missionData.successGameEventIdOverride ~= GetNilCrc() then
        successRewardDataId = missionData.successGameEventIdOverride
      end
      local successRewardData = ObjectiveDataHelper:GetGameEventDataWithObjectiveRewardData(successRewardDataId, missionData.objectiveId)
      return successRewardData
    end,
    GetSuccessRewardId = function(self)
      local successRewardDataId = objectiveData.successGameEventId
      if missionData.successGameEventIdOverride ~= GetNilCrc() then
        successRewardDataId = missionData.successGameEventIdOverride
      end
      return successRewardDataId
    end,
    GetRewardsDisplayString = function(self)
      local successRewardData = self:GetRewardData()
      local territoryStanding = localize("@owg_rewardtype_standing", tostring(successRewardData.territoryStanding))
      local currencyReward = localize("@owg_rewardtype_currency", GetLocalizedCurrency(successRewardData.currencyRewardRange))
      local progressionReward = localize("@owg_rewardtype_experience", tostring(successRewardData.progressionReward))
      return territoryStanding .. "  " .. currencyReward .. "  " .. progressionReward
    end,
    GetDetailedRewardsDisplayString = function(self, rewardModifiers, modifierStr)
      local successRewardData = self:GetRewardData()
      local territoryModifier = 1
      local currencyModifier = 1
      local progressModifier = 1
      if rewardModifiers then
        territoryModifier = rewardModifiers.territoryStandingRewardModifier
        currencyModifier = rewardModifiers.currencyModifier
        progressModifier = rewardModifiers.categoricalProgressionRewardModifier
      end
      local territoryStanding = localize("@owg_detailed_rewardtype_standing", tostring(math.floor(successRewardData.territoryStanding * territoryModifier)))
      local currencyReward = localize("@owg_rewardtype_currency", GetLocalizedCurrency(math.floor(successRewardData.currencyRewardRange * currencyModifier)))
      local progressionReward = localize("@owg_rewardtype_experience", tostring(math.floor(successRewardData.progressionReward * progressModifier)))
      if 1 < territoryModifier then
        territoryStanding = territoryStanding .. " " .. localize(modifierStr, tostring(math.floor(successRewardData.territoryStanding * (territoryModifier - 1))))
      end
      if 1 < currencyModifier then
        currencyReward = currencyReward .. " " .. localize(modifierStr, GetLocalizedCurrency(math.floor(successRewardData.currencyRewardRange * (currencyModifier - 1))))
      end
      if 1 < progressModifier then
        progressionReward = progressionReward .. " " .. localize(modifierStr, tostring(math.floor(successRewardData.progressionReward * (progressModifier - 1))))
      end
      return currencyReward .. "\n" .. territoryStanding .. "\n" .. progressionReward
    end,
    GetTypeDisplayName = function(self)
      return typesToUiData[self.taskType].name
    end,
    GetTypeDisplayColor = function(self)
      return typesToUiData[self.taskType].color
    end,
    GetTypeDisplayIcon = function(self)
      return typesToUiData[self.taskType].icon
    end,
    GetProjectImpact = function(self)
      return GetLocalizedReplacementText("@ui_community_points", {
        amount = tostring(missionData.communityGoalProgressAmount)
      })
    end,
    GetProjectImpactDetailed = function(self)
      return GetLocalizedReplacementText("@ui_community_points_detail", {
        amount = tostring(missionData.communityGoalProgressAmount)
      })
    end,
    GetRewardCoin = function(self)
      local successRewardData = self:GetRewardData()
      return GetLocalizedCurrency(successRewardData.currencyRewardRange)
    end,
    GetCommunityGoalProgressAmount = function(self)
      return missionData.communityGoalProgressAmount
    end,
    difficulty = objectiveData.difficulty,
    groupSize = missionData.recommendedGroupSize,
    vcLevelRange = missionData.vcLevelRange,
    timeToCompleteMinutes = missionData.estimatedTimeToCompleteMinutes,
    IsValidForProjectType = function(self, otherProjectId)
      if self.projectId == 0 then
        return false
      end
      local myProjectData = TerritoryGovernanceRequestBus.Broadcast.GetTerritoryProgressionData(self.projectId)
      if not myProjectData then
        return false
      end
      local otherProjectData = TerritoryGovernanceRequestBus.Broadcast.GetTerritoryProgressionData(otherProjectId)
      if not otherProjectData then
        return false
      end
      if myProjectData.projectType ~= otherProjectData.projectType then
        return false
      end
      return myProjectData.progressionLevel <= otherProjectData.progressionLevel
    end,
    IsAvailable = function(self)
      return objectiveParams.available
    end,
    IsInProgress = function(self)
      return false
    end,
    IsReadyToComplete = function(self)
      if self:IsInProgress() then
        return ObjectiveInteractorRequestBus.Broadcast.CanCompleteMission(self.objectiveInstanceId)
      end
      return false
    end,
    GetDetailText = function(tableSelf)
      return missionDescription
    end,
    GetDestinationDistance = function(tableSelf)
      local targetPosition
      local playerPosition = dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
      if #missionData.poiTagsOverride > 0 then
        local territoryId = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryIdByPoiTag(missionData.poiTagsOverride[1])
        targetPosition = MapComponentBus.Broadcast.GetTerritoryPosition(territoryId)
      end
      if targetPosition and targetPosition.x ~= 0 and targetPosition.y ~= 0 then
        local destinationData = self:GetDestination(objectiveParams.destinationOverride)
        if destinationData then
          targetPosition = destinationData.worldPosition
        else
          targetPosition = ObjectiveRequestBus.Event.GetClosestPOIPosition(objectiveParams.instanceId)
        end
      end
      local distance = ""
      if targetPosition and targetPosition.x ~= 0 and targetPosition.y ~= 0 then
        distance = GetLocalizedDistance(playerPosition, targetPosition)
      end
      return distance
    end,
    GetPoiDestinationDisplayName = function(tableSelf)
      local distance = tableSelf:GetDestinationDistance()
      local destinationLabel = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_destination")
      local destinationLabelFormatted = "<font face=\"lyshineui/fonts/nimbus_semibold.font\">" .. destinationLabel .. "</font>"
      local playerPosition = dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
      if #missionData.poiTagsOverride > 0 then
        local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinitionByPoiTag(missionData.poiTagsOverride[1])
        return destinationLabelFormatted .. " : " .. "<font color=" .. ColorRgbaToHexString(UIStyle.COLOR_WHITE) .. ">" .. territoryDefn.nameLocalizationKey .. " (" .. distance .. ")" .. "</font>"
      end
      local destinationData = self:GetDestination(objectiveParams.destinationOverride)
      local destination = ""
      if destinationData then
        destination = destinationData.nameLocalizationKey
      else
        destination = originTerritoryDefn.nameLocalizationKey
      end
      return destinationLabelFormatted .. " : " .. "<font color=" .. ColorRgbaToHexString(UIStyle.COLOR_WHITE) .. ">" .. destination .. " (" .. distance .. ")" .. "</font>"
    end,
    GetEnemyLevelRange = function(tableSelf)
      local levelsLabel = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_enemyLevels")
      local levelsLabelFormatted = "<font face=\"lyshineui/fonts/nimbus_semibold.font\">" .. tostring(levelsLabel) .. "</font>"
      local rangeText = "@ui_none"
      if tableSelf.vcLevelRange and tableSelf.vcLevelRange ~= "" then
        rangeText = tostring(tableSelf.vcLevelRange)
      end
      return levelsLabelFormatted .. " : " .. "<font color=" .. ColorRgbaToHexString(UIStyle.COLOR_WHITE) .. ">" .. rangeText .. "</font>"
    end,
    GetFactionWarInfluence = function(self)
      local finalText = ""
      local rewards = ObjectiveDataHelper:GetRewardData(missionData.objectiveId, objectiveParams.missionId)
      for _, rewardData in ipairs(rewards) do
        if rewardData.type == ObjectiveDataHelper.REWARD_TYPES.FACTION_INFLUENCE then
          finalText = "@owg_rewardtype_warinfluence_low"
          local successRewardData = self:GetRewardData()
          if successRewardData.contributionLevel == eGameEventContributionLevel_Medium then
            finalText = "@owg_rewardtype_warinfluence_med"
            break
          end
          if successRewardData.contributionLevel == eGameEventContributionLevel_High then
            finalText = "@owg_rewardtype_warinfluence_high"
          end
          break
        end
      end
      return LyShineScriptBindRequestBus.Broadcast.LocalizeText(finalText)
    end
  }
end
function TerritoryDataHandler:ProgressionPointsToRewards(progressionPoints, territoryId, playerEntityId)
  local hasHousingRewardAvailable = false
  local rewards = {}
  for i = 1, #progressionPoints do
    local progressionPointData = progressionPoints[i]
    local pointId = progressionPointData.id
    local staticRewardData = ProgressionPointRequestBus.Event.GetStaticProgressionPointData(playerEntityId, pointId)
    local isHousing = staticRewardData.territoryBonusCategory == eTerritoryBonus_HousePurchase
    local value = progressionPointData.upgradeValue
    if staticRewardData.territoryBonusCategory == eTerritoryBonus_GainStorage then
      value = GetFormattedNumber(value / 10, 1)
    elseif isHousing then
      value = ""
      hasHousingRewardAvailable = progressionPointData.canUpgrade
    elseif staticRewardData.territoryBonusCategory == eTerritoryBonus_GainHousePoints then
      value = GetFormattedNumber(value, 0)
    else
      value = GetFormattedNumber(value * 100, 1) .. "%"
    end
    local data = {
      rewardId = pointId,
      bg = "LyShineUI\\Images\\Territory\\StandingRewards\\" .. staticRewardData.upgradeCardSprite,
      enabled = progressionPointData.canUpgrade,
      value = value,
      stat = staticRewardData.upgradeCardStat,
      category = staticRewardData.upgradeCardCategory,
      description = staticRewardData.upgradeCardDescription,
      territoryName = self:GetTerritoryNameFromTerritoryId(territoryId),
      bonusCategory = staticRewardData.territoryBonusCategory
    }
    if not progressionPointData.canUpgrade then
      data.disabledReason = tostring(staticRewardData.requiredProgressionLevel)
    end
    table.insert(rewards, data)
  end
  if hasHousingRewardAvailable then
    for _, rewardData in ipairs(rewards) do
      if rewardData.bonusCategory == eTerritoryBonus_HousePurchase then
        local hasPurchasedHouse = PlayerHousingClientRequestBus.Broadcast.GetHasPurchasedHouse()
        if not hasPurchasedHouse then
          rewardData.additionalDescription = " @ui_tooltip_firsthouse"
        end
        return {rewardData}
      end
    end
  end
  return rewards
end
function TerritoryDataHandler:GetRedeemableTerritoryRewards(territoryId)
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local progressionPoints = ProgressionPointRequestBus.Event.GetAvailableProgressionPointsData(playerEntityId, Math.CreateCrc32(tostring(territoryId)), true)
  return self:ProgressionPointsToRewards(progressionPoints, territoryId, playerEntityId)
end
function TerritoryDataHandler:GetCurrentTerritoryRewards(territoryId)
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local progressionPoints = ProgressionPointRequestBus.Event.GetCurrentProgressionPointsData(playerEntityId, Math.CreateCrc32(tostring(territoryId)), true)
  return self:ProgressionPointsToRewards(progressionPoints, territoryId, playerEntityId)
end
function TerritoryDataHandler:RedeemTerritoryReward(territoryId, rewardId, caller, cb)
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  ProgressionPointRequestBus.Event.RequestSpendTerritoryStandingPoint(playerEntityId, Math.CreateCrc32(tostring(territoryId)), rewardId)
  cb(caller, true)
end
function TerritoryDataHandler:GetTerritoryLevel(territoryId)
  return TerritoryGovernanceRequestBus.Broadcast.GetTerritoryLevel(territoryId)
end
function TerritoryDataHandler:GetTerritoryStanding(territoryId)
  local territoryStandingRank = self:GetTerritoryStandingRank(territoryId)
  if not self.territoryRankTitles then
    local crc = Math.CreateCrc32(tostring(territoryId))
    local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    self.territoryRankTitles = {}
    local maxRank = CategoricalProgressionRequestBus.Event.GetMaxRank(playerEntityId, crc) or -1
    local lastRank = ""
    for rank = 0, maxRank do
      local rankData = CategoricalProgressionRequestBus.Event.GetRankData(playerEntityId, crc, rank)
      if rankData.displayName and 0 < string.len(rankData.displayName) then
        lastRank = rankData.displayName
      end
      self.territoryRankTitles[rank] = lastRank
    end
  end
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local unspent = ProgressionPointRequestBus.Event.GetUnspentTokens(playerEntityId, Math.CreateCrc32(tostring(territoryId)))
  local info = {rank = territoryStandingRank, tokens = unspent}
  if self.territoryRankTitles[territoryStandingRank] then
    info.displayName = self.territoryRankTitles[territoryStandingRank]
    info.newTitle = 0 < territoryStandingRank and self.territoryRankTitles[territoryStandingRank] ~= self.territoryRankTitles[territoryStandingRank - 1]
  else
    info.displayName = self.territoryRankTitles[#self.territoryRankTitles] or ""
    info.newTitle = false
  end
  return info
end
function TerritoryDataHandler:GetTerritoryStandingRank(territoryId)
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local territoryStanding = CategoricalProgressionRequestBus.Event.GetRank(playerEntityId, Math.CreateCrc32(tostring(territoryId)))
  return territoryStanding
end
function TerritoryDataHandler:GetUpgradeTierInfo(upgradeType, numCompletedUpgrades)
  if not self.upgradeTierInfo then
    self.upgradeTierInfo = {
      [eTerritoryUpgradeType_Settlement] = {
        {
          name = "@ui_territory_settlement_upgrade_tier_1",
          icon = "lyshineui/images/icons/misc/icon_settlement_t1.png",
          threshold = 5
        },
        {
          name = "@ui_territory_settlement_upgrade_tier_2",
          icon = "lyshineui/images/icons/misc/icon_settlement_t2.png",
          threshold = 11
        },
        {
          name = "@ui_territory_settlement_upgrade_tier_3",
          icon = "lyshineui/images/icons/misc/icon_settlement_t3.png",
          threshold = 17
        },
        {
          name = "@ui_territory_settlement_upgrade_tier_4",
          icon = "lyshineui/images/icons/misc/icon_settlement_t4.png",
          threshold = 24
        },
        {
          name = "@ui_territory_settlement_upgrade_tier_5",
          icon = "lyshineui/images/icons/misc/icon_settlement_t5.png",
          threshold = 25
        }
      },
      [eTerritoryUpgradeType_Fortress] = {
        {
          name = "@ui_territory_fort_upgrade_tier_1",
          icon = "lyshineui/images/icons/misc/icon_fort_t1.png",
          threshold = 2
        },
        {
          name = "@ui_territory_fort_upgrade_tier_2",
          icon = "lyshineui/images/icons/misc/icon_fort_t2.png",
          threshold = 5
        },
        {
          name = "@ui_territory_fort_upgrade_tier_3",
          icon = "lyshineui/images/icons/misc/icon_fort_t3.png",
          threshold = 9
        },
        {
          name = "@ui_territory_fort_upgrade_tier_4",
          icon = "lyshineui/images/icons/misc/icon_fort_t4.png",
          threshold = 13
        },
        {
          name = "@ui_territory_fort_upgrade_tier_5",
          icon = "lyshineui/images/icons/misc/icon_fort_t5.png",
          threshold = 14
        }
      }
    }
  end
  local upgradeTierInfo = self.upgradeTierInfo[upgradeType]
  if not upgradeTierInfo then
    return nil
  end
  for tier = 1, #upgradeTierInfo do
    local info = upgradeTierInfo[tier]
    if numCompletedUpgrades <= info.threshold then
      return info, tier
    end
  end
end
function TerritoryDataHandler:GetUpgradeTierInfoByTerritoryId(territoryId, tierType)
  if not self.upgradeCategories then
    self.upgradeCategories = {
      [eTerritoryUpgradeType_Settlement] = {
        eSettlementProgressionCategory_Blacksmithing,
        eSettlementProgressionCategory_Engineering,
        eSettlementProgressionCategory_Outfitting,
        eSettlementProgressionCategory_Cooking,
        eSettlementProgressionCategory_Alchemy,
        eSettlementProgressionCategory_Carpentry,
        eSettlementProgressionCategory_Masonry,
        eSettlementProgressionCategory_Weaving,
        eSettlementProgressionCategory_Tanning,
        eSettlementProgressionCategory_Smelting,
        eSettlementProgressionCategory_Church
      },
      [eTerritoryUpgradeType_Fortress] = {
        eSettlementProgressionCategory_FortGates,
        eSettlementProgressionCategory_FortHardPoints,
        eSettlementProgressionCategory_BallistaUpgrade,
        eSettlementProgressionCategory_FireBarrelUpgrade,
        eSettlementProgressionCategory_RepeaterUpgrade,
        eSettlementProgressionCategory_HornUpgrade,
        eSettlementProgressionCategory_ExplosiveUpgrade
      }
    }
  end
  if not self.upgradeCategories[tierType] then
    Debug.Log("[TerritoryDataHandler:GetUpgradeTierInfoByTerritoryId] invalid tierType requested: " .. tostring(tierType))
    return
  end
  local tierCategories = self.upgradeCategories[tierType]
  local numCompletedUpgrades = 0
  local progressionData = LandClaimRequestBus.Broadcast.GetTerritoryProgressionData(territoryId)
  for i = 1, #tierCategories do
    local upgradeData = progressionData:GetUpgradeDataForCategory(tierCategories[i])
    if upgradeData.category ~= eSettlementProgressionCategory_None then
      numCompletedUpgrades = numCompletedUpgrades + upgradeData.categoryLevel
    end
  end
  return self:GetUpgradeTierInfo(tierType, numCompletedUpgrades)
end
function TerritoryDataHandler:GetGoverningGuildId(territoryId)
  if territoryId ~= 0 then
    return LandClaimRequestBus.Broadcast.GetClaimOwnerData(territoryId).guildId
  end
  return 0
end
function TerritoryDataHandler:GetGoverningGuildData(territoryId)
  if territoryId ~= 0 then
    return LandClaimRequestBus.Broadcast.GetClaimOwnerData(territoryId)
  end
  return 0
end
function TerritoryDataHandler:GetGoverningSince(territoryId)
  local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(territoryId)
  return ownerData.lastClaimedTime
end
function TerritoryDataHandler:SetTaxOrFee(territoryId, taxId, newRate)
  local localTerritoryId = dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  if not territoryId or territoryId ~= localTerritoryId then
    return
  end
  return TerritoryGovernanceRequestBus.Broadcast.SetTaxOrFee(territoryId, taxId, newRate)
end
function TerritoryDataHandler:PayUpkeepCost(territoryId, useCompanyWallet)
  local localTerritoryId = dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  if not territoryId or territoryId ~= localTerritoryId then
    return
  end
  return TerritoryGovernanceRequestBus.Broadcast.PayUpkeepCost(territoryId, useCompanyWallet)
end
function TerritoryDataHandler:GetUpkeepCost(territoryId)
  return TerritoryGovernanceRequestBus.Broadcast.GetUpkeepCost(territoryId)
end
function TerritoryDataHandler:GetUpkeepDueTime(territoryId)
  return TerritoryGovernanceRequestBus.Broadcast.GetUpkeepDueTime(territoryId)
end
function TerritoryDataHandler:IsUpkeepOverdue(territoryId)
  local governanceData = LandClaimRequestBus.Broadcast.GetTerritoryGovernanceData(territoryId)
  return governanceData.failedToPayUpkeep
end
function TerritoryDataHandler:GetUpkeepCanPayTime(territoryId)
  return TerritoryGovernanceRequestBus.Broadcast.GetUpkeepCanPayTime(territoryId)
end
function TerritoryDataHandler:GetUpkeepPenaltyTime(territoryId)
  return TerritoryGovernanceRequestBus.Broadcast.GetUpkeepPenaltyTime(territoryId)
end
function TerritoryDataHandler:GetTaxOrFeeDisplayText(value, taxId)
  local taxDisplayStr = ""
  if taxId == eTaxOrFee_PropertyTax or taxId == eTaxOrFee_TradingTax then
    local baseTax = 1
    if taxId == eTaxOrFee_PropertyTax then
      baseTax = ConfigProviderEventBus.Broadcast.GetFloat("javelin.housing.taxes-base-percent")
    elseif taxId == eTaxOrFee_TradingTax then
      baseTax = ContractsRequestBus.Broadcast.GetBaseTradingTax()
    end
    taxDisplayStr = GetFormattedNumber(value * baseTax * 100, 2) .. "%"
  elseif taxId == eTaxOrFee_CraftingFee or taxId == eTaxOrFee_RefiningFee then
    taxDisplayStr = "x " .. GetFormattedNumber(value, 2)
  end
  return taxDisplayStr
end
function TerritoryDataHandler:GetTaxOrFeeAmount(territoryId, taxId)
  local govData = LandClaimRequestBus.Broadcast.GetTerritoryGovernanceData(territoryId)
  local fees = {
    govData.houseFee,
    govData.tradingFee,
    govData.craftingFee,
    govData.refiningFee
  }
  if 1 <= taxId and taxId <= 4 then
    return fees[taxId]
  end
  return 0
end
function TerritoryDataHandler:GetTaxOrFeeAmountNormalized(territoryId, taxId)
  local govData = LandClaimRequestBus.Broadcast.GetTerritoryGovernanceDataNormalized(territoryId)
  local fees = {
    govData.houseFee,
    govData.tradingFee,
    govData.craftingFee,
    govData.refiningFee
  }
  if 1 <= taxId and taxId <= 4 then
    return fees[taxId]
  end
  return 0
end
function TerritoryDataHandler:GetTaxOrFeeText(territoryId, taxId)
  if not self.taxAndFeeText then
    self.taxAndFeeText = {
      {
        text = "@ui_taxes_low",
        threshold = 0.05
      },
      {
        text = "@ui_taxes_average",
        threshold = 0.2
      },
      {
        text = "@ui_taxes_moderate",
        threshold = 0.4
      },
      {
        text = "@ui_taxes_high",
        threshold = 0.7
      },
      {
        text = "@ui_taxes_very_high",
        threshold = 0.95
      },
      {
        text = "@ui_taxes_extreme",
        threshold = 999
      }
    }
  end
  local value = self:GetTaxOrFeeAmountNormalized(territoryId, taxId)
  for i = 1, #self.taxAndFeeText do
    local data = self.taxAndFeeText[i]
    if value <= data.threshold then
      return data.text
    end
  end
end
function TerritoryDataHandler:GetTaxOrFeeColor(territoryId, taxId)
  if not self.taxAndFeeColor then
    self.taxAndFeeColor = {
      {
        color = UIStyle.COLOR_TAX_LEVEL_1,
        threshold = 0.05
      },
      {
        color = UIStyle.COLOR_TAX_LEVEL_2,
        threshold = 0.2
      },
      {
        color = UIStyle.COLOR_TAX_LEVEL_3,
        threshold = 0.4
      },
      {
        color = UIStyle.COLOR_TAX_LEVEL_4,
        threshold = 0.7
      },
      {
        color = UIStyle.COLOR_TAX_LEVEL_5,
        threshold = 0.95
      },
      {
        color = UIStyle.COLOR_TAX_LEVEL_6,
        threshold = 999
      }
    }
  end
  local value = self:GetTaxOrFeeAmountNormalized(territoryId, taxId)
  for i = 1, #self.taxAndFeeColor do
    local data = self.taxAndFeeColor[i]
    if value <= data.threshold then
      return data.color
    end
  end
end
function TerritoryDataHandler:GetAverageTaxOrFeeAmount(taxId)
  if not self.territoryIds then
    self.territoryIds = {}
    local claims = MapComponentBus.Broadcast.GetClaims()
    for index = 1, #claims do
      local capital = claims[index]
      table.insert(self.territoryIds, capital.settlementId)
    end
    if #self.territoryIds == 0 then
      Log("Warning: MapComponentBus.GetClaims returned no claims.")
      self.territoryIds = nil
      return 0
    end
  end
  local total = 0
  for k, territoryId in ipairs(self.territoryIds) do
    total = total + (self:GetTaxOrFeeAmount(territoryId, taxId) or 0)
  end
  return total / #self.territoryIds
end
function TerritoryDataHandler:GetTaxOrFeeCanChange(territoryId, taxId)
  local localTerritoryId = dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  if not territoryId or territoryId ~= localTerritoryId then
    return timeHelpers:ServerNow()
  end
  return TerritoryGovernanceRequestBus.Broadcast.GetTaxOrFeeCanChange(territoryId, taxId)
end
function TerritoryDataHandler:GetCompanyEarningsData(territoryId)
  local localTerritoryId = dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  if not territoryId or territoryId ~= localTerritoryId then
    return nil
  end
  local earningsData = TerritoryGovernanceRequestBus.Broadcast.GetTerritoryGovernanceEarningsData()
  return earningsData
end
function TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
  if not territoryId then
    return "Debug Name"
  end
  local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(territoryId)
  return territoryDefn and territoryDefn.nameLocalizationKey or ""
end
function TerritoryDataHandler:GetCurrentTerritoryName()
  local claimKey = dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  return self:GetTerritoryNameFromTerritoryId(claimKey)
end
return TerritoryDataHandler

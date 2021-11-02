local CraftingStatsPanel = {
  Properties = {
    CraftButton = {
      default = EntityId()
    },
    CraftButtonTaxAmount = {
      default = EntityId()
    },
    SkillExpAmount = {
      default = EntityId()
    },
    CraftingRequirements = {
      ParentContainer = {
        default = EntityId(),
        order = 1
      },
      SubContainer = {
        default = EntityId(),
        order = 2
      },
      CraftCommonButton = {
        default = EntityId(),
        order = 3
      },
      StationRequirement = {
        default = EntityId(),
        order = 4
      },
      StationIcon = {
        default = EntityId(),
        order = 5
      },
      StationRequirementIcon = {
        default = EntityId(),
        order = 6
      },
      StationDescText = {
        default = EntityId(),
        order = 7
      },
      SkillRequirement = {
        default = EntityId(),
        order = 8
      },
      SkillIcon = {
        default = EntityId(),
        order = 9
      },
      SkillRequirementIcon = {
        default = EntityId(),
        order = 10
      },
      SkillDescText = {
        default = EntityId(),
        order = 11
      },
      RequirementsHeaderLeft = {
        default = EntityId(),
        order = 12
      },
      HasResourcesIcon = {
        default = EntityId(),
        order = 13
      },
      HasResourcesText = {
        default = EntityId(),
        order = 14
      }
    },
    Stats = {
      BonusChanceToClone = {
        default = EntityId()
      },
      DividerToClone = {
        default = EntityId()
      },
      StatRowToClone = {
        default = EntityId()
      },
      Container = {
        default = EntityId()
      },
      Scrollbar = {
        default = EntityId()
      }
    },
    RefiningInfo = {
      Panel = {
        default = EntityId()
      },
      BonusAmount = {
        default = EntityId()
      },
      SkillLevel = {
        default = EntityId()
      },
      SkillName = {
        default = EntityId()
      }
    },
    QuantityWidget = {
      default = EntityId()
    },
    QualityBar = {
      default = EntityId()
    },
    TopInfo = {
      default = EntityId()
    },
    HeaderTooltip = {
      default = EntityId()
    },
    PinRecipeButton = {
      default = EntityId()
    },
    CooldownThresholdWarning = {
      default = EntityId()
    },
    CooldownTooltip = {
      default = EntityId()
    },
    CraftingRecipePanel = {
      default = EntityId()
    }
  },
  statObjs = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftingStatsPanel)
local CommonDragDrop = require("LyShineUI.CommonDragDrop")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local TradeSkillsCommon = RequireScript("LyShineUI._Common.TradeSkillsCommon")
local TooltipCommon = RequireScript("LyShineUI._Common.TooltipCommon")
function CraftingStatsPanel:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:SetVisualElements()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    self.playerEntityId = data
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Progression.Level", function(self, playerLevel)
    self.playerLevel = playerLevel
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ObjectiveEntityId", function(self, data)
    self.objectiveComponentEntityId = data
  end)
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-objectives") then
    self.enableObjectives = true
  end
  if self.enableObjectives then
    self.PinRecipeButton:SetText("@ui_pin_recipe")
    self.PinRecipeButton:SetCallback(self.OnPinRecipe, self)
    self.PinRecipeButton:SetTextStyle(self.UIStyle.FONT_STYLE_CRAFTING_PIN_RECIPE)
    self.PinRecipeButton:SetTooltip("@ui_pin_recipe_tooltip")
  end
  self.damageCategories = {
    {
      subTableName = "weaponAttributes.primaryAttack",
      name = "@ui_primary_attack"
    }
  }
  self:CheckPinButton()
end
function CraftingStatsPanel:SetVisualElements()
  local textStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = self.UIStyle.FONT_SIZE_BODY_NEW,
    fontColor = self.UIStyle.COLOR_YELLOW,
    characterSpacing = 0
  }
  SetTextStyle(self.Properties.CooldownThresholdWarning, textStyle)
  SetTextStyle(self.Properties.SkillExpAmount, textStyle)
  SetTextStyle(self.Properties.CraftingRequirements.RequirementsHeaderLeft, self.UIStyle.FONT_STYLE_BODY_NEW)
  self.CraftButton:SetButtonStyle(self.CraftButton.BUTTON_STYLE_HERO)
  self.CraftButton:StartStopImageSequence(true)
  self.CraftButton:SetSoundOnPress(self.audioHelper.Crafting_Button_Select)
  self.CraftButton:SetFontSize(40)
end
function CraftingStatsPanel:StartTick()
  if not self.tickHandler then
    self.lastTimeRemainingSeconds = -1
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function CraftingStatsPanel:StopTick(checkCanCraft)
  self:UpdateCooldownCount()
  self.cooldownEndTime = 0
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
  if checkCanCraft then
    self.CraftingRecipePanel:Refresh()
  end
end
function CraftingStatsPanel:OnTick(deltaTime, timePoint)
  if self.cooldownEndTime ~= 0 then
    local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
    local timeRemainingSeconds = self.cooldownEndTime:Subtract(now):ToSeconds()
    if timeRemainingSeconds ~= self.lastTimeRemainingSeconds then
      if timeRemainingSeconds <= 0 then
        self:UpdateCooldownCount()
        if 0 < self.remainingCooldownCount then
          self:StopTick(true)
          return
        end
      end
      self.lastTimeRemainingSeconds = timeRemainingSeconds
    end
    local timeToShow = 0 < timeRemainingSeconds and timeRemainingSeconds or 1
    local timeRemaningText = GetLocalizedReplacementText("@cooldown_cancraftin", {
      time = TimeHelpers:ConvertToShorthandString(timeToShow)
    })
    self.CraftButton:SetText(timeRemaningText)
  end
end
function CraftingStatsPanel:UpdateCooldownCount()
  self.remainingCooldownCount = CraftingRequestBus.Broadcast.GetRemainingCooldownCount(self.recipeIdCrc)
  local cooldownText = GetLocalizedReplacementText("@cooldown_threshold", {
    count = self.remainingCooldownCount
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.CooldownThresholdWarning, cooldownText, eUiTextSet_SetLocalized)
  local tooltipPrompt = self.remainingCooldownCount > 1 and "@cr_tooltip_cooldown_many" or "@cr_tooltip_cooldown_one"
  local tooltipText = GetLocalizedReplacementText(tooltipPrompt, {
    amount = self.remainingCooldownCount,
    time = TimeHelpers:ConvertToShorthandString(self.cooldownDuration)
  })
  self.CooldownTooltip:SetSimpleTooltip(tooltipText)
end
function CraftingStatsPanel:SetCurrentStation(stationName)
  self.viewingStation = string.lower(string.sub(stationName, 1, string.len(stationName) - 1))
  self.viewingStationTier = tonumber(string.sub(stationName, -1))
end
function CraftingStatsPanel:SetCraftingParams(recipeData, resultItemId, resultItemTier, ingredients, quantityToMake, perkItemId, maximumPerks, upgradeCostLevel)
  self.recipeData = recipeData
  self.recipeIdCrc = Math.CreateCrc32(recipeData.id)
  self.resultItemId = resultItemId
  self.resultItemTier = resultItemTier
  self.quantityToMake = quantityToMake
  self.perkItemId = perkItemId
  self.maximumPerks = maximumPerks
  self.upgradeCostLevel = upgradeCostLevel
  self.ingredients = ingredients
  self.remainingCooldownCount = -1
  self.cooldownEndTime = 0
  self.cooldownDuration = 0
  self.hasCooldown = CraftingRequestBus.Broadcast.HasCooldown(self.recipeIdCrc)
  self.isCraftAll = CraftingRequestBus.Broadcast.IsRecipeCraftAll(self.recipeData.id) or CraftingRequestBus.Broadcast.IsRecipeRefining(self.recipeData.id)
  self:StopTick(false)
  local descriptor = ItemCommon:GetFullDescriptorFromId(self.resultItemId)
  self.info = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil)
  if self.isCraftAll then
    UiElementBus.Event.SetIsEnabled(self.Properties.RefiningInfo.Panel, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.QualityBar, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TopInfo, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Stats.Container, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.RefiningInfo.Panel, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.QualityBar, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TopInfo, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.Stats.Container, true)
    self.QualityBar:SetRecipeData(self.recipeData, self.resultItemId, self.resultItemTier, ingredients)
    self.gearScoreRollRange = self.QualityBar:GetGearScoreRollRange()
    self:UpdateStatsInfo()
  end
  local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  self.territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
  UiElementBus.Event.SetIsEnabled(self.Properties.CooldownThresholdWarning, self.hasCooldown and self.QuantityWidget:IsVisible())
  if self.hasCooldown then
    self.cooldownDuration = CraftingRequestBus.Broadcast.GetCooldownDuration(self.recipeIdCrc)
    self:UpdateCooldownCount()
  end
  self:CheckPinButton()
  self:UpdateSkillAmount()
end
function CraftingStatsPanel:UpdateSkillAmount()
  local gameEventData = GameEventRequestBus.Broadcast.GetGameSystemData(Math.CreateCrc32(self.recipeData.gameEventId))
  UiElementBus.Event.SetIsEnabled(self.Properties.SkillExpAmount, gameEventData.isValid)
  if gameEventData.isValid then
    local reqTradeskill = CraftingRequestBus.Broadcast.GetRecipeTradeskill(self.recipeData.id)
    local skillText = GetLocalizedReplacementText("@ui_stat_bonus", {
      amount = gameEventData.categoricalProgressionReward * self.recipeData:GetIngredientCount(),
      attribute = "@ui_" .. reqTradeskill
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.SkillExpAmount, skillText, eUiTextSet_SetLocalized)
  end
end
function CraftingStatsPanel:SetCanCraft(canCraft, hasMaterials)
  self.canCraft = canCraft
  self:UpdateRequirements()
  self.CraftButton:SetEnabled(self.canCraft)
  UiElementBus.Event.SetIsEnabled(self.Properties.QuantityWidget, self.canCraft)
  self.CraftButton:SetHeroPulseActive(self.canCraft)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.CraftButton, self.canCraft)
  local craftQuantity = math.max(self.quantityToMake, 1)
  local discountList = CraftingRequestBus.Broadcast.GetCraftingDiscountList(self.recipeData.id)
  local craftingFee = CraftingRequestBus.Broadcast.GetCraftingFeeOnCurrentTerritory(self.recipeData.id, craftQuantity)
  if 1 < #discountList then
    local tooltipInfo = {
      isDiscount = true,
      name = "@ui_tooltip_cost",
      useLocalizedCurrency = true,
      costEntries = {
        {
          name = discountList[1].discountName,
          type = TooltipCommon.DiscountEntryTypes.Cost,
          cost = discountList[1].discountPercent * craftQuantity
        }
      },
      discountEntries = {}
    }
    for i = 2, #discountList do
      local type = TooltipCommon.DiscountEntryTypes.TerritoryStanding
      if discountList[i].discountName == "@ui_tooltip_company_discount" then
        type = TooltipCommon.DiscountEntryTypes.Company
      elseif discountList[i].discountName == "@ui_tooltip_faction_discount" then
        type = TooltipCommon.DiscountEntryTypes.Faction
      end
      table.insert(tooltipInfo.discountEntries, {
        name = discountList[i].discountName,
        type = type,
        discountPct = discountList[i].discountPercent * 100,
        hasMultiplicativeDiscount = true
      })
    end
    self.CraftButton:SetTooltip(tooltipInfo)
  else
    self.CraftButton:SetTooltip(nil)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.CraftingRequirements.HasResourcesText, "@ui_has_resources", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.CraftingRequirements.HasResourcesText, self.UIStyle.COLOR_GREEN)
  UiImageBus.Event.SetSpritePathname(self.Properties.CraftingRequirements.HasResourcesIcon, "lyshineui/images/icons/misc/icon_requirement_check.dds")
  if self.canCraft == false then
    if self.hasCooldown then
      self:UpdateCooldownCount()
    end
    if self.hasCooldown and self.remainingCooldownCount == 0 then
      self.cooldownEndTime = CraftingRequestBus.Broadcast.GetCooldownEndTime(self.recipeIdCrc)
      self:StartTick()
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftButtonTaxAmount, false)
    else
      self.CraftButton:SetText("@cr_cantcraft")
      if 0 < craftingFee then
        UiTextBus.Event.SetTextWithFlags(self.Properties.CraftButtonTaxAmount, GetLocalizedReplacementText("@ui_craft_fee", {
          territoryName = self.territoryName,
          fee = GetLocalizedCurrency(craftingFee)
        }), eUiTextSet_SetLocalized)
        UiElementBus.Event.SetIsEnabled(self.Properties.CraftButtonTaxAmount, true)
        UiTextBus.Event.SetColor(self.Properties.CraftButtonTaxAmount, self.UIStyle.COLOR_GRAY_50)
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.CraftButtonTaxAmount, false)
      end
    end
    if craftQuantity > self.CraftingRecipePanel:GetCalculatedInventorySpace() then
      if hasMaterials then
        UiTextBus.Event.SetTextWithFlags(self.Properties.CraftingRequirements.HasResourcesText, "@ui_inventoryfull", eUiTextSet_SetLocalized)
      end
      UiTextBus.Event.SetColor(self.Properties.CraftingRequirements.HasResourcesText, self.UIStyle.COLOR_RED_MEDIUM)
      UiImageBus.Event.SetSpritePathname(self.Properties.CraftingRequirements.HasResourcesIcon, "lyshineui/images/icons/misc/icon_requirement_x.dds")
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftingRequirements.CraftCommonButton, false)
    end
    local myCurrency = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount")
    if craftingFee > myCurrency and hasMaterials then
      UiTextBus.Event.SetTextWithFlags(self.Properties.CraftingRequirements.HasResourcesText, "@crafting_fee_low_no_fee", eUiTextSet_SetLocalized)
    end
    if not hasMaterials or not (craftingFee < myCurrency) then
      UiTextBus.Event.SetColor(self.Properties.CraftingRequirements.HasResourcesText, self.UIStyle.COLOR_RED_MEDIUM)
      UiImageBus.Event.SetSpritePathname(self.Properties.CraftingRequirements.HasResourcesIcon, "lyshineui/images/icons/misc/icon_requirement_x.dds")
    end
  else
    self.CraftButton:SetText("@ui_craft")
    if 0 < craftingFee then
      UiTextBus.Event.SetTextWithFlags(self.Properties.CraftButtonTaxAmount, GetLocalizedReplacementText("@ui_craft_fee", {
        territoryName = self.territoryName,
        fee = GetLocalizedCurrency(craftingFee)
      }), eUiTextSet_SetLocalized)
      UiTextBus.Event.SetColor(self.Properties.CraftButtonTaxAmount, self.UIStyle.COLOR_TAN)
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftButtonTaxAmount, true)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftButtonTaxAmount, false)
    end
  end
end
function CraftingStatsPanel:UpdateRequirements()
  local isRecipeKnown = CraftingRequestBus.Broadcast.IsRecipeKnown(self.recipeData.id, true)
  local isValidRecipe = CraftingRequestBus.Broadcast.IsValidRecipe(self.recipeData.id, -1)
  local reqTradeskill = CraftingRequestBus.Broadcast.GetRecipeTradeskill(self.recipeData.id)
  local tradeSkillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(Math.CreateCrc32(reqTradeskill))
  local stationData = TradeSkillsCommon:GetStationData(self.viewingStation)
  local isPlayerLevel = reqTradeskill == "WildernessSurvival"
  local currentSkillRank = 0
  local reqRecipeLevel = CraftingRequestBus.Broadcast.GetRequiredRecipeLevel(self.recipeData.id)
  local reqTradeskillLevel = CraftingRequestBus.Broadcast.GetTradeskillLevelRequiredForRecipeLevel(reqTradeskill, reqRecipeLevel)
  if reqTradeskillLevel < 0 then
    reqTradeskillLevel = reqRecipeLevel
  end
  if reqTradeskill then
    if isPlayerLevel then
      currentSkillRank = self.playerLevel
      isValidRecipe = reqTradeskillLevel <= currentSkillRank
    else
      currentSkillRank = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, Math.CreateCrc32(reqTradeskill))
      isValidRecipe = reqTradeskillLevel <= currentSkillRank
    end
  end
  if self.isCraftAll then
    local bonusChance = CraftingRequestBus.Broadcast.GetChanceForBonusItems(self.recipeData, self.CraftingRecipePanel:GetIngredients())
    UiTextBus.Event.SetTextWithFlags(self.Properties.RefiningInfo.BonusAmount, string.format("%.0f%%", bonusChance), eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.RefiningInfo.SkillLevel, isPlayerLevel and currentSkillRank + 1 or currentSkillRank, eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.RefiningInfo.SkillName, isPlayerLevel and "@ui_current_level" or "@ui_" .. reqTradeskill, eUiTextSet_SetLocalized)
  end
  local stations = RecipeDataManagerBus.Broadcast.GetStationsFromCraftingRecipe(self.recipeData.id)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingRequirements.StationIcon, false)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.CraftingRequirements.StationDescText, 3)
  for i = 1, #stations do
    local stationName = string.lower(string.sub(stations[i], 1, #stations[i] - 1))
    local stationTier = tonumber(string.sub(stations[i], -1))
    if stationName == self.viewingStation then
      local isValidStation = stationTier <= self.viewingStationTier
      local tierRequired = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@cr_tierRequired", stationTier)
      local currentTierText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@cr_tierRequired", self.viewingStationTier)
      local description = GetLocalizedReplacementText("@ui_station_desc_text", {
        stationName = "@" .. string.upper(string.sub(stationName, 1, 1)) .. string.sub(stationName, 2),
        tier = tierRequired,
        current = isValidStation and "" or "(" .. "@ui_current_stat " .. currentTierText .. ")"
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.CraftingRequirements.StationDescText, description, eUiTextSet_SetLocalized)
      if stationData then
        UiElementBus.Event.SetIsEnabled(self.Properties.CraftingRequirements.StationIcon, true)
        UiImageBus.Event.SetSpritePathname(self.Properties.CraftingRequirements.StationIcon, stationData.icon)
        UiTransformBus.Event.SetLocalPositionX(self.Properties.CraftingRequirements.StationDescText, 23)
      else
        Debug.Log("[WARNING]: No station icon in TradeSkillsCommon.lua for: " .. tostring(self.viewingStation))
      end
      UiTextBus.Event.SetColor(self.Properties.CraftingRequirements.StationDescText, isValidStation and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED_MEDIUM)
      UiImageBus.Event.SetColor(self.Properties.CraftingRequirements.StationIcon, isValidStation and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED_MEDIUM)
      if isValidStation then
        UiImageBus.Event.SetSpritePathname(self.Properties.CraftingRequirements.StationRequirementIcon, "lyshineui/images/icons/misc/icon_requirement_check.dds")
        break
      end
      UiImageBus.Event.SetSpritePathname(self.Properties.CraftingRequirements.StationRequirementIcon, "lyshineui/images/icons/misc/icon_requirement_x.dds")
      break
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingRequirements.SkillDescText, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingRequirements.SkillRequirementIcon, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingRequirements.SkillIcon, true)
  if not isValidRecipe then
    UiImageBus.Event.SetSpritePathname(self.Properties.CraftingRequirements.SkillRequirementIcon, "lyshineui/images/icons/misc/icon_requirement_x.dds")
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.CraftingRequirements.SkillRequirementIcon, "lyshineui/images/icons/misc/icon_requirement_check.dds")
  end
  UiTransformBus.Event.SetLocalPositionX(self.Properties.CraftingRequirements.SkillDescText, 3)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingRequirements.SkillIcon, false)
  if isPlayerLevel then
    local levelRequiredText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_charlevel", {
      levelNum = reqTradeskillLevel,
      current = isValidRecipe and "" or "(" .. "@ui_current_stat " .. currentSkillRank .. ")"
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.CraftingRequirements.SkillDescText, levelRequiredText, eUiTextSet_SetLocalized)
  else
    if tradeSkillData then
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftingRequirements.SkillIcon, true)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.CraftingRequirements.SkillDescText, 23)
      UiImageBus.Event.SetSpritePathname(self.Properties.CraftingRequirements.SkillIcon, tradeSkillData.smallIcon)
    else
      Debug.Log("[WARNING]: No tradeskill data found in TradeSkillsCommon.lua for: " .. tostring(reqTradeskill))
    end
    local levelRequiredText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@cr_levelRequired", reqTradeskillLevel)
    local currentLevelText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@cr_levelRequired", currentSkillRank)
    local skillText = GetLocalizedReplacementText("@ui_station_skill_desc_text", {
      skillName = "@ui_" .. tostring(reqTradeskill),
      skillLoc = "@cr_skill",
      level = levelRequiredText,
      current = isValidRecipe and "" or "(" .. "@ui_current_stat " .. currentLevelText .. ")"
    })
    UiTextBus.Event.SetText(self.Properties.CraftingRequirements.SkillDescText, skillText)
  end
  UiTextBus.Event.SetColor(self.Properties.CraftingRequirements.SkillDescText, isValidRecipe and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED_MEDIUM)
  UiImageBus.Event.SetColor(self.Properties.CraftingRequirements.SkillIcon, isValidRecipe and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED_MEDIUM)
end
function CraftingStatsPanel:CreateBonusChanceStat(name, value, color)
  local newEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, self.Stats.BonusChanceToClone, self.Stats.Container, EntityId())
  table.insert(self.statObjs, newEntityId)
  local nameId = UiElementBus.Event.FindChildByName(newEntityId, "Name")
  UiTextBus.Event.SetTextWithFlags(nameId, name, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(nameId, color)
  local valueId = UiElementBus.Event.FindDescendantByName(newEntityId, "Value")
  UiTextBus.Event.SetTextWithFlags(valueId, value, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(newEntityId, true)
end
function CraftingStatsPanel:CreateStat(name, value, dataPath)
  local newEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, self.Stats.StatRowToClone, self.Stats.Container, EntityId())
  table.insert(self.statObjs, newEntityId)
  local isPlayerLevel = name == "@ui_level_requirement"
  local targetHeight = isPlayerLevel and 50 or 25
  UiLayoutCellBus.Event.SetTargetHeight(newEntityId, targetHeight)
  local nameId = UiElementBus.Event.FindChildByName(newEntityId, "Name")
  UiTextBus.Event.SetTextWithFlags(nameId, name, eUiTextSet_SetLocalized)
  local valueId = UiElementBus.Event.FindChildByName(newEntityId, "Value")
  UiTextBus.Event.SetTextWithFlags(valueId, value, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(newEntityId, true)
  if dataPath then
    if value <= self.dataLayer:GetDataFromNode(dataPath) then
      UiTextBus.Event.SetColor(nameId, self.UIStyle.COLOR_WHITE)
      UiTextBus.Event.SetColor(valueId, self.UIStyle.COLOR_WHITE)
    else
      UiTextBus.Event.SetColor(nameId, self.UIStyle.COLOR_RED_MEDIUM)
      UiTextBus.Event.SetColor(valueId, self.UIStyle.COLOR_RED_MEDIUM)
    end
  elseif isPlayerLevel then
    local requiredLevel = tonumber(string.match(value, "%d+"))
    if requiredLevel > self.playerLevel then
      UiTextBus.Event.SetColor(nameId, self.UIStyle.COLOR_RED_MEDIUM)
      UiTextBus.Event.SetColor(valueId, self.UIStyle.COLOR_RED_MEDIUM)
    else
      UiTextBus.Event.SetColor(nameId, self.UIStyle.COLOR_WHITE)
      UiTextBus.Event.SetColor(valueId, self.UIStyle.COLOR_WHITE)
    end
  end
end
function CraftingStatsPanel:CreateSeparator(spacerOnly)
  local newEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, self.Stats.DividerToClone, self.Stats.Container, EntityId())
  table.insert(self.statObjs, newEntityId)
  UiElementBus.Event.SetIsEnabled(newEntityId, true)
  if spacerOnly then
    local dividerElement = UiElementBus.Event.FindChildByName(newEntityId, "divider")
    self.ScriptedEntityTweener:Set(dividerElement, {opacity = 0})
  end
end
function CraftingStatsPanel:GetLabelString(type, index)
  if type == ePerkType_Inherent then
    return "@crafting_azothbonus_attribute"
  elseif type == ePerkType_Generated then
    return "@crafting_azothbonus_perk" .. tostring(index)
  else
    return "@crafting_azothbonus_gemslot"
  end
end
function CraftingStatsPanel:GetChanceString(modifier)
  if 0.75 < modifier then
    return "@crafting_veryhighchance"
  elseif 0.5 < modifier then
    return "@crafting_highchance"
  elseif 0.25 < modifier then
    return "@crafting_medchance"
  else
    return "@crafting_lowchance"
  end
end
function CraftingStatsPanel:UpdateStatsInfo()
  for i = 1, #self.statObjs do
    UiElementBus.Event.DestroyElement(self.statObjs[i])
  end
  if self.resultItemId == 0 then
    return
  end
  self:CreateSeparator()
  local descriptor = ItemCommon:GetFullDescriptorFromId(self.resultItemId)
  descriptor.gearScore = self.QualityBar:GetMaxGearScoreRoll()
  self.HighestInfo = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil)
  self.isTool = false
  if self.info.weaponAttributes then
    self.isTool = type(self.info.weaponAttributes.gatheringEfficiency) == "number" and 0 < self.info.weaponAttributes.gatheringEfficiency or type(self.info.weaponAttributes.maxCastDistance) == "number" and 0 < self.info.weaponAttributes.maxCastDistance
    if not self.isTool then
      if self.damageCategories then
        for _, damageCategory in ipairs(self.damageCategories) do
          local subTable = GetTableValue(self.info, damageCategory.subTableName)
          local topTable = GetTableValue(self.HighestInfo, damageCategory.subTableName)
          if subTable and 0 < #subTable then
            local damageInfo = subTable[#subTable]
            local minAmount = math.floor(damageInfo.amount)
            local maxAmount = math.floor(topTable[#subTable].amount)
            if minAmount == maxAmount then
              self:CreateStat(damageCategory.name, minAmount)
            else
              self:CreateStat(damageCategory.name, string.format("%s - %s", minAmount, maxAmount))
            end
          end
        end
      end
      local blockStability = self.info.weaponAttributes.blockStability
      if 0 < blockStability then
        self:CreateStat("@ui_tooltip_blockingstability", string.format("%.0f%%", blockStability))
      end
    elseif 0 < self.info.weaponAttributes.maxCastDistance then
      local minAmount = self.info.weaponAttributes.maxCastDistance
      local maxAmount = self.HighestInfo.weaponAttributes.maxCastDistance
      if minAmount == maxAmount then
        self:CreateStat("@ui_tooltip_maxcastdistance", string.format("%dm", minAmount))
      else
        self:CreateStat("@ui_tooltip_maxcastdistance", string.format("%dm - %dm", minAmount, maxAmount))
      end
    else
      local minAmount = math.floor(self.info.weaponAttributes.gatheringEfficiency * 100)
      local maxAmount = math.floor(self.HighestInfo.weaponAttributes.gatheringEfficiency * 100)
      self:CreateStat("@ui_tooltip_gatherspeed", string.format("%.0f%% - %.0f%%", minAmount, maxAmount))
    end
  elseif self.info.armorAttributes then
    local minAmount = math.floor(self.info.armorAttributes.physicalArmorRating)
    local maxAmount = math.floor(self.HighestInfo.armorAttributes.physicalArmorRating)
    if minAmount == maxAmount then
      self:CreateStat("@ui_physical", minAmount)
    else
      self:CreateStat("@ui_physical", string.format("%s - %s", minAmount, maxAmount))
    end
    minAmount = math.floor(self.info.armorAttributes.elementalArmorRating)
    maxAmount = math.floor(self.HighestInfo.armorAttributes.elementalArmorRating)
    if minAmount == maxAmount then
      self:CreateStat("@ui_elemental", minAmount)
    else
      self:CreateStat("@ui_elemental", string.format("%s - %s", minAmount, maxAmount))
    end
  elseif self.info.ammoAttributes and 0 < self.info.ammoAttributes.damageModifier then
    self:CreateStat("@ui_tooltip_damagemodifier", string.format("%.2f", self.info.ammoAttributes.damageModifier))
  end
  if 0 < self.info.requiredLevel then
    if self.info.requiredLevel == self.HighestInfo.requiredLevel then
      self:CreateStat("@ui_level_requirement", string.format("%d", self.info.requiredLevel + 1))
    else
      self:CreateStat("@ui_level_requirement", string.format("%d - %d", self.info.requiredLevel + 1, self.HighestInfo.requiredLevel + 1))
    end
    self:CreateSeparator(true)
    self:CreateSeparator()
  end
  local addSeparator = false
  local descriptor = ItemCommon:GetFullDescriptorFromId(self.resultItemId)
  for _, perkId in ipairs(self.info.perks) do
    if perkId ~= 0 then
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      local statLabel = ""
      if perkData.perkType == ePerkType_Inherent then
        local perkMultiplier = perkData:GetPerkMultiplier(descriptor:GetGearScore())
        for _, attributeData in ipairs(ItemCommon.AttributeDisplayOrder) do
          local statValue = perkData:GetAttributeBonus(attributeData.stat, descriptor:GetGearScoreRangeMod(true), perkMultiplier)
          if statValue ~= 0 then
            if 0 < string.len(statLabel) then
              statLabel = statLabel .. "  "
            end
            statLabel = statLabel .. "+" .. tostring(statValue) .. " " .. attributeData.name
          end
        end
        self:CreateBonusChanceStat(self:GetLabelString(ePerkType_Inherent), statLabel, self.UIStyle.COLOR_YELLOW)
        addSeparator = true
      end
    end
  end
  local perkItemForAttributes = false
  if self.perkItemId ~= 0 then
    local perkId = ItemDataManagerBus.Broadcast.GetDisplayPerkIdFromResource(self.perkItemId)
    if perkId ~= 0 then
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData.perkType == ePerkType_Inherent then
        local statString = ItemCommon:GetInherentPerkSummary(self.perkItemId)
        local statLabel = GetLocalizedReplacementText("@crafting_guaranteed_perk", {
          perkImage = "icons/misc/icon_attribute_arrow",
          perkName = statString
        })
        self:CreateBonusChanceStat("@crafting_azothbonus_attribute", statLabel, self.UIStyle.COLOR_YELLOW)
        addSeparator = true
        perkItemForAttributes = true
      end
    end
  end
  for _, perkId in ipairs(self.info.perks) do
    if perkId ~= 0 then
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData.perkType == ePerkType_Gem then
        local statLabel = GetLocalizedReplacementText("@crafting_guaranteed_perk", {
          perkImage = perkData.iconPath,
          perkName = perkData.displayName
        })
        self:CreateBonusChanceStat(self:GetLabelString(perkData.perkType), statLabel, self.UIStyle.COLOR_YELLOW)
        addSeparator = true
      end
    end
  end
  local perkOrderIndex = 1
  for _, perkId in ipairs(self.info.perks) do
    if perkId ~= 0 then
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData.perkType == ePerkType_Generated then
        local statLabel = GetLocalizedReplacementText("@crafting_guaranteed_perk", {
          perkImage = perkData.iconPath,
          perkName = perkData.displayName
        })
        self:CreateBonusChanceStat(self:GetLabelString(perkData.perkType, perkOrderIndex), statLabel, self.UIStyle.COLOR_YELLOW)
        addSeparator = true
        perkOrderIndex = perkOrderIndex + 1
      end
    end
  end
  if self.perkItemId ~= 0 then
    local perkId = ItemDataManagerBus.Broadcast.GetDisplayPerkIdFromResource(self.perkItemId)
    if perkId ~= 0 then
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData.perkType ~= ePerkType_Inherent then
        local statLabel = GetLocalizedReplacementText("@crafting_guaranteed_perk", {
          perkImage = perkData.iconPath,
          perkName = perkData.displayName
        })
        self:CreateBonusChanceStat(self:GetLabelString(perkData.perkType, perkOrderIndex), statLabel, self.UIStyle.COLOR_YELLOW)
        addSeparator = true
        if perkData.perkType == ePerkType_Generated then
          perkOrderIndex = perkOrderIndex + 1
        end
      end
    end
  end
  local totalRolls = (self.perkItemId == 0 and self.maximumPerks or self.maximumPerks - 1) - #self.info.perks
  if 0 < totalRolls then
    local skippedPerk1 = false
    local totalPerksListed = 1
    for i = 1, 5 do
      local chance = ItemDataManagerBus.Broadcast.GetPerkChance(self.resultItemId, i, totalPerksListed <= self.upgradeCostLevel)
      local type = ItemDataManagerBus.Broadcast.GetPerkBucketType(self.resultItemId, i)
      if type == ePerkType_Generated and self.perkItemId ~= 0 and not skippedPerk1 then
        skippedPerk1 = true
      elseif type == ePerkType_Inherent and perkItemForAttributes then
        perkItemForAttributes = true
      elseif type ~= ePerkType_Invalid then
        self:CreateBonusChanceStat(self:GetLabelString(type, perkOrderIndex), self:GetChanceString(chance), self.UIStyle.COLOR_WHITE)
        addSeparator = true
        if type == ePerkType_Generated then
          perkOrderIndex = perkOrderIndex + 1
        end
        totalPerksListed = totalPerksListed + 1
      end
      if totalRolls < totalPerksListed then
        break
      end
    end
  end
  if addSeparator then
    self:CreateSeparator()
  end
end
function CraftingStatsPanel:ShowHeaderTooltip()
  DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(self.info, self)
end
function CraftingStatsPanel:HideHeaderTooltip()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
function CraftingStatsPanel:OnPinRecipe()
  if self.recipeData then
    if self.isPinned then
      ObjectivesComponentRequestBus.Event.AbandonAllRecipes(self.objectiveComponentEntityId)
    else
      local ingredients = self.CraftingRecipePanel:GetIngredients()
      ObjectivesComponentRequestBus.Event.AddObjectiveFromRecipe(self.objectiveComponentEntityId, self.recipeData.id, eObjectiveCraftingType_Item, ingredients)
    end
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PinRecipeButton, false)
  end
end
function CraftingStatsPanel:CheckPinButton()
  if self.enableObjectives and self.recipeData then
    self.isPinned = ObjectivesComponentRequestBus.Event.HasObjective(self.objectiveComponentEntityId, self.recipeIdCrc)
    if self.isPinned then
      self.PinRecipeButton:SetText("@ui_unpin_recipe")
      self.PinRecipeButton:SetTooltip("@ui_unpin_recipe_tooltip")
    else
      self.PinRecipeButton:SetText("@ui_pin_recipe")
      self.PinRecipeButton:SetTooltip("@ui_pin_recipe_tooltip")
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.PinRecipeButton, true)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PinRecipeButton, true)
end
return CraftingStatsPanel

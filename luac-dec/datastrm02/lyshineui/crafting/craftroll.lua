local CraftRoll = {
  Properties = {
    ItemName = {
      default = EntityId()
    },
    CraftedFromName = {
      default = EntityId()
    },
    Cloud = {
      default = EntityId()
    },
    RarityBg = {
      default = EntityId()
    },
    RarityBgMask = {
      default = EntityId()
    },
    RarityLabelContainer = {
      default = EntityId()
    },
    RarityText = {
      default = EntityId()
    },
    RarityLabel = {
      default = EntityId()
    },
    RefiningAmount = {
      default = EntityId()
    },
    CraftsmanshipEffects = {
      default = EntityId()
    },
    GearScore = {
      default = EntityId()
    },
    ItemImage = {
      default = EntityId()
    },
    QualityContainer = {
      default = EntityId()
    },
    Header = {
      default = EntityId()
    },
    HeaderOffset = {
      default = EntityId()
    },
    WeaponResults = {
      StatLabel = {
        default = EntityId()
      },
      BaseDamage = {
        default = EntityId()
      },
      FinalDamage = {
        default = EntityId()
      },
      Container = {
        default = EntityId()
      },
      FinalDamageGlow = {
        default = EntityId()
      }
    },
    ArmorResults = {
      BasePhysical = {
        default = EntityId()
      },
      BaseElemental = {
        default = EntityId()
      },
      FinalPhysical = {
        default = EntityId()
      },
      FinalElemental = {
        default = EntityId()
      },
      Container = {
        default = EntityId()
      },
      FinalPhysicalGlow = {
        default = EntityId()
      },
      FinalElementalGlow = {
        default = EntityId()
      }
    },
    TrinketResults = {
      Container = {
        default = EntityId()
      }
    },
    QuantityResults = {
      BaseAmount = {
        default = EntityId()
      },
      BonusAmount = {
        default = EntityId()
      },
      Container = {
        default = EntityId()
      }
    },
    PerkContainer = {
      default = EntityId()
    },
    PerkList = {
      default = {
        EntityId()
      }
    },
    AttributeList = {
      default = {
        EntityId()
      }
    },
    AttributesContainer = {
      default = EntityId()
    },
    GemPerkSlot = {
      default = EntityId()
    },
    ResultsPanels = {
      Weapons = {
        default = EntityId()
      },
      Armor = {
        default = EntityId()
      },
      Quantity = {
        default = EntityId()
      },
      Trinket = {
        default = EntityId()
      }
    },
    QualityBar = {
      default = EntityId()
    },
    QualityIndicator = {
      default = EntityId()
    },
    StandingProgression = {
      Container = {
        default = EntityId()
      },
      ProgressLabel = {
        default = EntityId()
      },
      StandingIcon = {
        default = EntityId()
      },
      PreviousAmount = {
        default = EntityId()
      },
      NewAmount = {
        default = EntityId()
      },
      NumberText = {
        default = EntityId()
      }
    },
    SkillProgression = {
      Container = {
        default = EntityId()
      },
      Text = {
        default = EntityId()
      },
      SkillCircle = {
        default = EntityId()
      },
      NumberText = {
        default = EntityId()
      },
      Pulse1 = {
        default = EntityId()
      },
      Pulse2 = {
        default = EntityId()
      }
    },
    RarityOffset = {
      default = EntityId()
    },
    GemDivider = {
      default = EntityId()
    },
    ProgressionContainer = {
      default = EntityId()
    },
    ProgressionOffset = {
      default = EntityId()
    },
    NoPerkLabel = {
      default = EntityId()
    },
    RarityGlow1 = {
      default = EntityId()
    },
    RarityGlow2 = {
      default = EntityId()
    },
    RisingSun = {
      default = EntityId()
    },
    VisibleLayout = {
      default = EntityId()
    },
    InvisibleLayout = {
      default = EntityId()
    },
    FixedItemCelebrationSequence = {
      default = EntityId()
    },
    FixedItemCelebrationRunesContainer = {
      default = EntityId()
    },
    FixedItemCelebrationRuneClockwise = {
      default = EntityId()
    },
    FixedItemCelebrationRuneCounterClockwise = {
      default = EntityId()
    },
    RarityEffect = {
      Effect1 = {
        default = EntityId()
      },
      Effect2 = {
        default = EntityId()
      },
      Effect3 = {
        default = EntityId()
      },
      Effect4 = {
        default = EntityId()
      }
    }
  },
  rollDelay = 0.5,
  isQuantityCraft = false,
  quantity = 1,
  duration = 1,
  curDuration = 0,
  quantityToMake = 0,
  totalDuration = 0,
  gemPerkHeight = 76,
  perkHeight = 76,
  perkDelay = 0.15,
  rarityEffectDelayWithCelebration = 0.65,
  rarityEffectDelayNormal = 0.5,
  numPerksDisplay = 0,
  IconPathRoot = "lyShineui/images/icons/items_hires/"
}
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local TradeSkillsCommon = RequireScript("LyShineUI._Common.TradeSkillsCommon")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftRoll)
function CraftRoll:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.ItemName, self.UIStyle.FONT_STYLE_CRAFTROLL_ITEMNAME)
  SetTextStyle(self.Properties.CraftedFromName, self.UIStyle.FONT_STYLE_FLAVOR_TEXT)
  self.ScriptedEntityTweener:Set(self.Properties.WeaponResults.Container, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.ArmorResults.Container, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.TrinketResults.Container, {opacity = 0})
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      self.localPlayerEntityId = rootEntityId
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey", function(self, claimKey)
    if claimKey and claimKey ~= 0 then
      self.claimKey = claimKey
    end
  end)
  self.claimKeyToIcon = {
    [2] = "lyshineui/images/icons/objectives/icon_territoryStanding_2.dds",
    [3] = "lyshineui/images/icons/objectives/icon_territoryStanding_3.dds",
    [4] = "lyshineui/images/icons/objectives/icon_territoryStanding_4.dds",
    [5] = "lyshineui/images/icons/objectives/icon_territoryStanding_5.dds",
    [6] = "lyshineui/images/icons/objectives/icon_territoryStanding_6.dds",
    [7] = "lyshineui/images/icons/objectives/icon_territoryStanding_7.dds",
    [8] = "lyshineui/images/icons/objectives/icon_territoryStanding_8.dds",
    [9] = "lyshineui/images/icons/objectives/icon_territoryStanding_9.dds",
    [10] = "lyshineui/images/icons/objectives/icon_territoryStanding_10.dds",
    [11] = "lyshineui/images/icons/objectives/icon_territoryStanding_11.dds",
    [12] = "lyshineui/images/icons/objectives/icon_territoryStanding_12.dds",
    [13] = "lyshineui/images/icons/objectives/icon_territoryStanding_13.dds",
    [14] = "lyshineui/images/icons/objectives/icon_territoryStanding_14.dds",
    [15] = "lyshineui/images/icons/objectives/icon_territoryStanding_15.dds",
    [16] = "lyshineui/images/icons/objectives/icon_territoryStanding_16.dds"
  }
end
function CraftRoll:OnShutdown()
end
function CraftRoll:SetIsQuantityCraft(isQuantityCraft)
  self.isQuantityCraft = isQuantityCraft
  UiElementBus.Event.SetIsEnabled(self.Properties.RefiningAmount, false)
  UiTextBus.Event.SetText(self.Properties.RefiningAmount, "0")
end
function CraftRoll:SetQuantityCrafted(quantity, quantityToMake, quantityPerCraft)
  self.quantityToMake = quantityToMake * quantityPerCraft
  self.quantity = quantity
end
function CraftRoll:StartRefiningBarAnimation(duration)
  UiElementBus.Event.SetIsEnabled(self.Properties.RefiningAmount, true)
  local itemDescriptor = ItemDescriptor()
  itemDescriptor.itemId = self.resultItemId
  local usesRarity = itemDescriptor:UsesRarity()
  self.raritySuffix = "0"
  if usesRarity then
    local rarityLevel = itemDescriptor:GetRarityLevel()
    self.raritySuffix = tostring(rarityLevel)
  end
  self.curDuration = 0
  self.totalDuration = duration or self.duration
  self.ScriptedEntityTweener:Play(self.Properties.ProgressionContainer, 0.5, {opacity = 0}, {
    opacity = 1,
    "QuadOut",
    delay = 0.5
  })
  self:AnimateRefiningBar(self.totalDuration)
  if self.tickHandler == nil then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
  if not self.isSingleMultiCraft then
    TimingUtils:Delay(1, self, self.AdvanceStep)
  end
end
function CraftRoll:AnimateRefiningBar(newDuration)
  self.curDuration = self.totalDuration > 0 and self.curDuration * newDuration / self.totalDuration or 0
  self.totalDuration = newDuration
  if self.raritySuffix ~= "0" then
    local colorName = string.format("COLOR_RARITY_LEVEL_%s", self.raritySuffix)
    local bgColorName = string.format("COLOR_RARITY_LEVEL_%s_BG", self.raritySuffix)
    local brightColorName = string.format("COLOR_RARITY_LEVEL_%s_BRIGHT", self.raritySuffix)
    UiTextBus.Event.SetColor(self.Properties.RarityText, self.UIStyle[brightColorName])
    UiTextBus.Event.SetColor(self.Properties.ItemName, self.UIStyle[brightColorName])
    UiImageBus.Event.SetColor(self.Properties.Cloud, self.UIStyle[colorName])
    UiImageBus.Event.SetColor(self.Properties.RarityGlow1, self.UIStyle[bgColorName])
  else
    UiTextBus.Event.SetColor(self.Properties.ItemName, self.UIStyle.COLOR_TAN)
    UiImageBus.Event.SetColor(self.Properties.Cloud, self.UIStyle.COLOR_GRAY_90)
  end
  UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionContainer, -68)
  self.ScriptedEntityTweener:Play(self.Properties.RarityOffset, 0.4, {y = 100}, {
    y = 0,
    ease = "QuadOut",
    delay = self.duration,
    onComplete = function()
      self.audioHelper:PlaySound(self.audioHelper.Crafting_Done)
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.Header, 0.4, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Cloud, 1, {opacity = 0}, {opacity = 0.25, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ResultsPanels.Quantity, 0.4, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
end
function CraftRoll:ConnectProgressionListeners()
  if self.categoricalProgressionHandler then
    self:BusDisconnect(self.categoricalProgressionHandler)
  end
  self.categoricalProgressionHandler = self:BusConnect(CategoricalProgressionNotificationBus, self.localPlayerEntityId)
end
function CraftRoll:DisconnectProgressionListeners()
  if self.categoricalProgressionHandler then
    self:BusDisconnect(self.categoricalProgressionHandler)
    self.categoricalProgressionHandler = nil
  end
end
function CraftRoll:TradeSkillLevelUpCelebration()
  self.audioHelper:PlaySound(self.audioHelper.Tradeskill_LevelUp)
  self.ScriptedEntityTweener:Play(self.Properties.SkillProgression.SkillCircle, 0.1, {scaleX = 0.4, scaleY = 0.4}, {scaleX = 0.55, scaleY = 0.55})
  self.ScriptedEntityTweener:Play(self.Properties.SkillProgression.SkillCircle, 0.6, {scaleX = 0.55, scaleY = 0.55}, {
    scaleX = 0.4,
    scaleY = 0.4,
    delay = 0.1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.SkillProgression.Pulse1, 1, {
    scaleX = 0,
    scaleY = 0,
    opacity = 1
  }, {
    scaleX = 1.5,
    scaleY = 1.5,
    opacity = 0
  })
  self.ScriptedEntityTweener:Play(self.Properties.SkillProgression.Pulse2, 1, {
    scaleX = 0,
    scaleY = 0,
    opacity = 1
  }, {
    scaleX = 1.5,
    scaleY = 1.5,
    opacity = 0,
    delay = 0.3
  })
end
function CraftRoll:StandingLevelUpCelebration()
end
function CraftRoll:PlayStandingProgress(duration, fromLevel, fromProgress, toLevel, toProgress)
  if fromLevel ~= toLevel then
    self.ScriptedEntityTweener:Play(self.Properties.StandingProgression.NewAmount, duration / 2, {imgFill = fromProgress}, {
      imgFill = 1,
      onComplete = function()
        UiImageBus.Event.SetFillAmount(self.Properties.StandingProgression.PreviousAmount, 0)
        UiImageBus.Event.SetFillAmount(self.Properties.StandingProgression.NewAmount, 0)
        self:StandingLevelUpCelebration()
        self.ScriptedEntityTweener:Play(self.Properties.StandingProgression.NewAmount, duration / 2, {imgFill = 0}, {imgFill = toProgress})
      end
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.StandingProgression.NewAmount, duration, {imgFill = fromProgress}, {imgFill = toProgress})
  end
end
function CraftRoll:OnCategoricalProgressionRankChanged(masteryNameCrc, oldRank, newRank, oldPoints)
  if masteryNameCrc == self.activeTradeskill then
    self.tradeskillNewRank = newRank
    self.tradeskillNewProgression = CategoricalProgressionRequestBus.Event.GetProgression(self.localPlayerEntityId, self.activeTradeskill)
    if self.tradeskillNewProgression == self.tradeskillPrevProgression then
      local totalProgressionGain = 0
      self.SkillProgression.SkillCircle:SetLevel(oldRank)
      for i = 1, self.tradeskillNewRank - self.tradeskillPrevRank do
        local prevMaxProgression = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.localPlayerEntityId, self.activeTradeskill, self.tradeskillPrevRank + i - 1)
        totalProgressionGain = totalProgressionGain + prevMaxProgression
      end
      local maxProgression = CategoricalProgressionRequestBus.Event.GetMaxPointsForCurrentRank(self.localPlayerEntityId, self.activeTradeskill)
      if maxProgression and 0 < maxProgression then
        do
          local progress = self.tradeskillNewProgression / maxProgression
          local showDelay = self.isQuantityCraft and 0.7 or 0.1
          self.ScriptedEntityTweener:Play(self.Properties.SkillProgression.Container, showDelay, {
            scaleX = 1,
            onComplete = function()
              self.SkillProgression.SkillCircle:PlayCraftingProgress(2, self.tradeskillPrevRank, self.tradeskillPrevProgress, self.tradeskillNewRank, progress, self.TradeSkillLevelUpCelebration, self)
            end
          })
        end
      end
      local tradeSkillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(self.activeTradeskill)
      UiTextBus.Event.SetTextWithFlags(self.Properties.SkillProgression.Text, tradeSkillData.locName, eUiTextSet_SetLocalized)
      local textTotalProgressionGain = GetLocalizedReplacementText("@ui_plus_amount", {amount = totalProgressionGain})
      UiTextBus.Event.SetTextWithFlags(self.Properties.SkillProgression.NumberText, textTotalProgressionGain, eUiTextSet_SetAsIs)
      UiElementBus.Event.Reparent(self.Properties.SkillProgression.Container, self.Properties.VisibleLayout, EntityId())
      self.ScriptedEntityTweener:Play(self.Properties.SkillProgression.Container, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    end
  end
end
function CraftRoll:OnCategoricalProgressionPointsChanged(masteryNameCrc, oldPoints, newPoints)
  if masteryNameCrc == self.activeTradeskill then
    self.tradeskillNewRank = CategoricalProgressionRequestBus.Event.GetRank(self.localPlayerEntityId, self.activeTradeskill)
    self.tradeskillNewProgression = CategoricalProgressionRequestBus.Event.GetProgression(self.localPlayerEntityId, self.activeTradeskill)
    local totalProgressionGain = newPoints - oldPoints
    if self.tradeskillNewRank ~= self.tradeskillPrevRank then
      self.SkillProgression.SkillCircle:SetLevel(self.tradeskillNewRank)
      for i = 1, self.tradeskillNewRank - self.tradeskillPrevRank do
        local prevMaxProgression = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.localPlayerEntityId, self.activeTradeskill, self.tradeskillPrevRank + i - 1)
        totalProgressionGain = totalProgressionGain + prevMaxProgression
      end
    end
    local maxProgression = CategoricalProgressionRequestBus.Event.GetMaxPointsForCurrentRank(self.localPlayerEntityId, self.activeTradeskill)
    if maxProgression and 0 < maxProgression then
      do
        local progress = self.tradeskillNewProgression / maxProgression
        local showDelay = self.isQuantityCraft and 0.7 or 0.1
        self.ScriptedEntityTweener:Play(self.Properties.SkillProgression.Container, showDelay, {
          scaleX = 1,
          onComplete = function()
            self.SkillProgression.SkillCircle:PlayCraftingProgress(2, self.tradeskillPrevRank, self.tradeskillPrevProgress, self.tradeskillNewRank, progress, self.TradeSkillLevelUpCelebration, self)
          end
        })
      end
    end
    local tradeSkillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(self.activeTradeskill)
    UiTextBus.Event.SetTextWithFlags(self.Properties.SkillProgression.Text, tradeSkillData.locName, eUiTextSet_SetLocalized)
    local textTotalProgressionGain = GetLocalizedReplacementText("@ui_plus_amount", {amount = totalProgressionGain})
    UiTextBus.Event.SetTextWithFlags(self.Properties.SkillProgression.NumberText, textTotalProgressionGain, eUiTextSet_SetAsIs)
    UiElementBus.Event.Reparent(self.Properties.SkillProgression.Container, self.Properties.VisibleLayout, EntityId())
    self.ScriptedEntityTweener:Play(self.Properties.SkillProgression.Container, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  elseif masteryNameCrc == self.territoryId then
    self.standingNewRank = CategoricalProgressionRequestBus.Event.GetRank(self.localPlayerEntityId, self.territoryId)
    self.standingNewProgression = CategoricalProgressionRequestBus.Event.GetProgression(self.localPlayerEntityId, self.territoryId)
    local totalProgressionGain = newPoints - oldPoints
    if self.standingNewRank ~= self.standingPrevRank then
      local prevMaxProgression = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.localPlayerEntityId, self.territoryId, self.standingPrevRank)
      totalProgressionGain = newPoints + prevMaxProgression - oldPoints
    end
    local maxProgression = CategoricalProgressionRequestBus.Event.GetMaxPointsForCurrentRank(self.localPlayerEntityId, self.territoryId)
    if maxProgression and 0 < maxProgression then
      local progress = self.standingNewProgression / maxProgression
      self:PlayStandingProgress(2, self.standingPrevRank, self.standingPrevProgress, self.standingNewRank, progress)
      UiImageBus.Event.SetFillAmount(self.Properties.StandingProgression.NewAmount, progress)
    end
    local territoryText = GetLocalizedReplacementText("@ui_territory_standing_with_icon", {
      territoryName = self.territoryName
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.StandingProgression.ProgressLabel, territoryText, eUiTextSet_SetAsIs)
    local icon = self.claimKeyToIcon[self.claimKey]
    UiImageBus.Event.SetSpritePathname(self.Properties.StandingProgression.StandingIcon, icon)
    local textTotalProgressionGain = GetLocalizedReplacementText("@ui_plus_amount", {amount = totalProgressionGain})
    UiTextBus.Event.SetTextWithFlags(self.Properties.StandingProgression.NumberText, textTotalProgressionGain, eUiTextSet_SetAsIs)
    UiElementBus.Event.Reparent(self.Properties.StandingProgression.Container, self.Properties.VisibleLayout, EntityId())
    self.ScriptedEntityTweener:Play(self.Properties.StandingProgression.Container, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  end
end
function CraftRoll:GetProgressionInitialState(recipeId)
  self.activeTradeskill = CraftingRequestBus.Broadcast.GetRecipeTradeskill(recipeId)
  self.activeTradeskill = Math.CreateCrc32(tostring(self.activeTradeskill))
  self.tradeskillPrevRank = CategoricalProgressionRequestBus.Event.GetRank(self.localPlayerEntityId, self.activeTradeskill)
  self.tradeskillPrevProgression = CategoricalProgressionRequestBus.Event.GetProgression(self.localPlayerEntityId, self.activeTradeskill)
  local tradeSkillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(self.activeTradeskill)
  local maxProgression = CategoricalProgressionRequestBus.Event.GetMaxPointsForCurrentRank(self.localPlayerEntityId, self.activeTradeskill)
  if maxProgression and 0 < maxProgression then
    self.tradeskillPrevProgress = self.tradeskillPrevProgression / maxProgression
    self.SkillProgression.SkillCircle:SetLevel(self.tradeskillPrevRank)
    self.SkillProgression.SkillCircle:SetProgress(self.tradeskillPrevProgress, true)
  end
  self.ScriptedEntityTweener:Set(self.Properties.SkillProgression.Container, {opacity = 0})
  local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  self.territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
  self.territoryId = Math.CreateCrc32(tostring(territoryId))
  self.standingPrevRank = CategoricalProgressionRequestBus.Event.GetRank(self.localPlayerEntityId, self.territoryId)
  self.standingPrevProgression = CategoricalProgressionRequestBus.Event.GetProgression(self.localPlayerEntityId, self.territoryId)
  maxProgression = CategoricalProgressionRequestBus.Event.GetMaxPointsForCurrentRank(self.localPlayerEntityId, self.territoryId)
  if maxProgression and 0 < maxProgression then
    self.standingPrevProgress = self.standingPrevProgression / maxProgression
    UiImageBus.Event.SetFillAmount(self.Properties.StandingProgression.PreviousAmount, self.standingPrevProgress)
    UiImageBus.Event.SetFillAmount(self.Properties.StandingProgression.NewAmount, self.standingPrevProgress)
  end
  self.ScriptedEntityTweener:Set(self.Properties.StandingProgression.Container, {opacity = 0})
end
function CraftRoll:SetRollData(recipeData, resultItemId, resultItemTier, ingredients)
  if self.isQuantityCraft == false then
    self.finished = false
  end
  self.curDuration = 0
  self.totalDuration = 0
  self.ScriptedEntityTweener:Play(self.Properties.RarityBg, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.RarityGlow1, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.RarityGlow2, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.RarityLabel, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.QualityContainer, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.Header, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.WeaponResults.Container, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.WeaponResults.FinalDamage, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.ArmorResults.Container, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.TrinketResults.Container, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.ArmorResults.FinalPhysical, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.ArmorResults.FinalElemental, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.ResultsPanels.Quantity, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.RisingSun, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.Cloud, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.NoPerkLabel, 0.1, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.ProgressionContainer, 0.1, {opacity = 0})
  UiElementBus.Event.Reparent(self.Properties.StandingProgression.Container, self.Properties.InvisibleLayout, EntityId())
  UiElementBus.Event.Reparent(self.Properties.SkillProgression.Container, self.Properties.InvisibleLayout, EntityId())
  if not self.isQuantityCraft then
    self.QualityBar:SetRecipeData(recipeData, resultItemId, resultItemTier, ingredients)
    self.minGearScore = self.QualityBar.minGearScore
    self.maxGearScore = self.QualityBar.maxGearScore
    self:SetGearScoreText(self.lastGearScore or self.minGearScore)
  end
  self:GetProgressionInitialState(recipeData.id)
  self.resultItemId = resultItemId
  local staticItemData = StaticItemDataManager:GetItem(resultItemId)
  local descriptor = ItemDescriptor()
  descriptor.itemId = resultItemId
  descriptor.gearScore = staticItemData.gearScoreRange.minValue
  local info = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil)
  self.type = staticItemData.itemType
  self.oldItemName = staticItemData.displayName
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, staticItemData.displayName, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.ItemImage, self.IconPathRoot .. staticItemData.icon .. ".png")
  self.showPerks = true
  if self.type == "Weapon" then
    local isTool = type(info.weaponAttributes.gatheringEfficiency) == "number" and 0 < info.weaponAttributes.gatheringEfficiency
    self.showPerks = not isTool
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Weapons, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Armor, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Quantity, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Trinket, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.PerkContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.QualityContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.QualityBar, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemName, false)
    SetTextStyle(self.Properties.ItemName, self.UIStyle.FONT_STYLE_CRAFTROLL_ITEMNAME)
    self.ScriptedEntityTweener:Set(self.Properties.ItemImage, {scaleX = 1, scaleY = 1})
    if isTool then
      UiTextBus.Event.SetTextWithFlags(self.Properties.WeaponResults.StatLabel, "@ui_tooltip_gatherspeed", eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.Properties.WeaponResults.BaseDamage, string.format("%.0f%%", info.weaponAttributes.gatheringEfficiency * 100), eUiTextSet_SetAsIs)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.WeaponResults.StatLabel, "@ui_tooltip_basedamage", eUiTextSet_SetLocalized)
      if info.weaponAttributes.primaryAttack and 0 < #info.weaponAttributes.primaryAttack then
        local damageInfo = info.weaponAttributes.primaryAttack[#info.weaponAttributes.primaryAttack]
        UiTextBus.Event.SetTextWithFlags(self.Properties.WeaponResults.BaseDamage, tostring(math.floor(damageInfo.amount)), eUiTextSet_SetAsIs)
      else
        UiTextBus.Event.SetTextWithFlags(self.Properties.WeaponResults.BaseDamage, tostring(math.floor(info.weaponAttributes.baseDamage)), eUiTextSet_SetAsIs)
      end
    end
    self.ScriptedEntityTweener:Set(self.Properties.WeaponResults.FinalDamage, {opacity = 0})
    UiTransformBus.Event.SetLocalPositionY(self.Properties.HeaderOffset, -14)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionOffset, 0)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.QualityBar, 211)
  elseif self.type == "Armor" then
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Weapons, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Armor, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Quantity, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Trinket, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.PerkContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.QualityContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.QualityBar, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemName, false)
    SetTextStyle(self.Properties.ItemName, self.UIStyle.FONT_STYLE_CRAFTROLL_ITEMNAME)
    self.ScriptedEntityTweener:Set(self.Properties.ItemImage, {scaleX = 1, scaleY = 1})
    local isTrinket = CraftingRequestBus.Broadcast.GetRecipeResultIsTrinket(staticItemData.key)
    if isTrinket then
      self.type = "Trinket"
      UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Armor, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Trinket, true)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.QualityBar, 257)
    else
      if info.armorAttributes then
        UiTextBus.Event.SetTextWithFlags(self.Properties.ArmorResults.BasePhysical, tostring(math.floor(info.armorAttributes.physicalArmorRating)), eUiTextSet_SetAsIs)
        UiTextBus.Event.SetTextWithFlags(self.Properties.ArmorResults.BaseElemental, tostring(math.floor(info.armorAttributes.elementalArmorRating)), eUiTextSet_SetAsIs)
      end
      self.ScriptedEntityTweener:Set(self.Properties.ArmorResults.FinalPhysical, {opacity = 0})
      self.ScriptedEntityTweener:Set(self.Properties.ArmorResults.FinalElemental, {opacity = 0})
      UiTransformBus.Event.SetLocalPositionY(self.Properties.QualityBar, 211)
    end
    UiTransformBus.Event.SetLocalPositionY(self.Properties.HeaderOffset, -14)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionOffset, 0)
  elseif self.isQuantityCraft then
    self.type = "Quantity"
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Weapons, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Armor, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Trinket, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Quantity, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.PerkContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.QualityContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.QualityBar, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemName, true)
    self.ScriptedEntityTweener:Set(self.Properties.QuantityResults.BaseAmount, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.QuantityResults.BonusAmount, {opacity = 0})
    SetTextStyle(self.Properties.ItemName, self.UIStyle.FONT_STYLE_CRAFTROLL_ITEMNAME)
    self.ScriptedEntityTweener:Set(self.Properties.ItemImage, {scaleX = 1, scaleY = 1})
    UiTransformBus.Event.SetLocalPositionY(self.Properties.HeaderOffset, 80)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionOffset, -150)
  else
    self.type = "Single"
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Weapons, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Armor, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Trinket, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ResultsPanels.Quantity, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.QualityContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.QualityBar, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.PerkContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemName, false)
    SetTextStyle(self.Properties.ItemName, self.UIStyle.FONT_STYLE_CRAFTROLL_ITEMNAME_BIG)
    self.ScriptedEntityTweener:Set(self.Properties.ItemImage, {scaleX = 1.4, scaleY = 1.4})
    UiTransformBus.Event.SetLocalPositionY(self.Properties.RarityOffset, 0)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.HeaderOffset, 80)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionOffset, -150)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.QualityBar, 211)
  end
  self.skipCraftsmanship = false
  self:ConnectProgressionListeners()
end
function CraftRoll:OnTick(deltaTime, timePoint)
  if self.totalDuration > 0 then
    if self.type == "Quantity" then
      self.curDuration = self.curDuration + deltaTime
      if self.curDuration >= self.totalDuration then
        UiTextBus.Event.SetTextWithFlags(self.Properties.QuantityResults.BaseAmount, tostring(self.quantityToMake), eUiTextSet_SetAsIs)
        UiTextBus.Event.SetTextWithFlags(self.Properties.QuantityResults.BonusAmount, tostring(self.quantity - self.quantityToMake), eUiTextSet_SetAsIs)
        self.ScriptedEntityTweener:Play(self.Properties.QuantityResults.BaseAmount, 0.5, {opacity = 0}, {
          opacity = 1,
          ease = "QuadOut",
          delay = 0.2
        })
        self.ScriptedEntityTweener:Play(self.Properties.QuantityResults.BonusAmount, 0.5, {opacity = 0}, {
          opacity = 1,
          ease = "QuadOut",
          delay = 0.2
        })
        self:RollComplete()
      end
      if self.totalDuration > 0 then
        local curQuantity = Clamp(math.floor(self.quantity * (self.curDuration / self.totalDuration)), 0, self.quantity)
        UiTextBus.Event.SetTextWithFlags(self.RefiningAmount, curQuantity, eUiTextSet_SetAsIs)
      else
        UiTextBus.Event.SetTextWithFlags(self.RefiningAmount, self.quantity, eUiTextSet_SetAsIs)
      end
    elseif self.type == "Single" then
      self.curDuration = self.curDuration + deltaTime
      if self.curDuration >= self.totalDuration then
        UiTextBus.Event.SetTextWithFlags(self.RefiningAmount, tostring(1), eUiTextSet_SetAsIs)
        self:RollComplete()
      end
    else
      self.curDuration = self.curDuration + deltaTime
      local currentGearScore = self.currentGearScore + (self.gearScore - self.currentGearScore) * (self.curDuration / self.totalDuration)
      currentGearScore = math.floor(Math.Clamp(currentGearScore, 0, self.gearScore))
      if self.curDuration >= self.totalDuration or self.gearScore == currentGearScore then
        self.lastGearScore = currentGearScore
        self:SetGearScoreText(self.gearScore)
        self:RollComplete()
      else
        self:SetGearScoreText(currentGearScore)
      end
    end
  end
end
function CraftRoll:SetSlot(slot, skipDuration)
  local itemDescriptor = slot:GetItemDescriptor()
  local staticItemData = StaticItemDataManager:GetItem(itemDescriptor.itemId)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, staticItemData.displayName, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemName, true)
  self.ScriptedEntityTweener:Set(self.Properties.FixedItemCelebrationRunesContainer, {opacity = 0})
  local info = StaticItemDataManager:GetTooltipDisplayInfo(itemDescriptor, nil)
  if info.weaponAttributes and self.type == "Weapon" then
    self:SetGearScore(tostring(itemDescriptor:GetGearScore()), skipDuration)
    if type(info.weaponAttributes.gatheringEfficiency) == "number" and 0 < info.weaponAttributes.gatheringEfficiency then
      UiTextBus.Event.SetTextWithFlags(self.Properties.WeaponResults.FinalDamage, string.format("%.0f%%", info.weaponAttributes.gatheringEfficiency * 100), eUiTextSet_SetAsIs)
    elseif info.weaponAttributes.primaryAttack and 0 < #info.weaponAttributes.primaryAttack then
      local damageInfo = info.weaponAttributes.primaryAttack[#info.weaponAttributes.primaryAttack]
      UiTextBus.Event.SetTextWithFlags(self.Properties.WeaponResults.FinalDamage, tostring(math.floor(damageInfo.amount)), eUiTextSet_SetAsIs)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.WeaponResults.FinalDamage, tostring(math.floor(info.weaponAttributes.baseDamage)), eUiTextSet_SetAsIs)
    end
  elseif info.armorAttributes then
    self:SetGearScore(tostring(itemDescriptor:GetGearScore()), skipDuration)
    if self.type == "Armor" then
      UiTextBus.Event.SetTextWithFlags(self.Properties.ArmorResults.FinalPhysical, tostring(math.floor(info.armorAttributes.physicalArmorRating)), eUiTextSet_SetAsIs)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ArmorResults.FinalElemental, tostring(math.floor(info.armorAttributes.elementalArmorRating)), eUiTextSet_SetAsIs)
    end
  elseif self.type == "Single" then
    self:StartRefiningBarAnimation(1)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.AttributesContainer, false)
  for i = 0, #self.Properties.AttributeList do
    UiElementBus.Event.SetIsEnabled(self.Properties.AttributeList[i], false)
  end
  local numPerks = #info.perks
  self.numPerksDisplay = 0
  self.hasPerks = numPerks and 0 < numPerks
  self.attributesCount = 0
  local hasGemPerk = false
  local numNonGemPerks = 0
  if self.hasPerks then
    local perkData = {}
    local gemIndex = -1
    for i = 1, #info.perks do
      perkData[i] = ItemDataManagerBus.Broadcast.GetStaticPerkData(info.perks[i])
      if perkData[i].perkType == ePerkType_Gem then
        self.GemPerkSlot:SetPerkData(perkData[i], false)
        hasGemPerk = true
        gemIndex = i
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.GemPerkSlot, 0 < gemIndex)
    local perkIndex = 0
    table.sort(perkData, function(perk1, perk2)
      return perk1 and perk1.perkType == ePerkType_Inherent
    end)
    for i = 1, #perkData do
      if perkData[i].perkType ~= ePerkType_Gem then
        local entityTable = self.registrar:GetEntityTable(self.Properties.PerkList[perkIndex])
        if perkData[i].perkType == ePerkType_Inherent then
          UiElementBus.Event.SetIsEnabled(self.Properties.AttributesContainer, true)
          local perkMultiplier = perkData[i]:GetPerkMultiplier(itemDescriptor:GetGearScore())
          for _, attributeData in ipairs(ItemCommon.AttributeDisplayOrder) do
            local statValue = perkData[i]:GetAttributeBonus(attributeData.stat, itemDescriptor:GetGearScoreRangeMod(true), perkMultiplier)
            if statValue ~= 0 then
              local attributes = {}
              table.insert(attributes, {
                amount = statValue,
                attribute = attributeData.name
              })
              UiElementBus.Event.SetIsEnabled(self.Properties.AttributeList[self.attributesCount], true)
              self.AttributeList[self.attributesCount]:SetAttributes(attributes)
              self.attributesCount = self.attributesCount + 1
            end
          end
          UiElementBus.Event.SetIsEnabled(self.Properties.PerkList[perkIndex], false)
        else
          local perkMultiplier = perkData[i]:GetPerkMultiplier(itemDescriptor:GetGearScore())
          entityTable:SetPerkData(perkData[i], false, false, false, false, perkMultiplier)
          UiElementBus.Event.SetIsEnabled(self.Properties.PerkList[perkIndex], true)
        end
        perkIndex = perkIndex + 1
      end
    end
    numNonGemPerks = perkIndex
    for i = perkIndex, #self.Properties.PerkList do
      UiElementBus.Event.SetIsEnabled(self.Properties.PerkList[i], false)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.NoPerkLabel, false)
    self.numPerksDisplay = numPerks
    local locTag = "@ui_numperks"
    if numPerks == 1 then
      if hasGemPerk then
        UiElementBus.Event.SetIsEnabled(self.Properties.NoPerkLabel, true)
        self.numPerksDisplay = 0
      else
        self.numPerksDisplay = 1
      end
      locTag = "@ui_numperk"
    else
      if hasGemPerk then
        self.numPerksDisplay = numPerks - 1
      else
        self.numPerksDisplay = numPerks
      end
      locTag = self.numPerksDisplay == 1 and "@ui_numperk" or "@ui_numperks"
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.NoPerkLabel, true)
  end
  self.ScriptedEntityTweener:Play(self.Properties.RarityBg, 0.1, {opacity = 0}, {opacity = 1, "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.QualityContainer, 0.2, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Header, 0.2, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ItemImage, 0.6, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ItemName, 0.6, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Cloud, 1, {opacity = 0}, {opacity = 0.3, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.NoPerkLabel, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.25
  })
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.RarityBgMask, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.RarityBgMask)
  UiElementBus.Event.SetIsEnabled(self.Properties.RarityLabelContainer, false)
  if self.type == "Weapon" then
    self.ScriptedEntityTweener:Play(self.Properties.WeaponResults.Container, 0.4, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0
    })
    self.ScriptedEntityTweener:Play(self.Properties.WeaponResults.FinalDamage, 0.3, {x = 40, opacity = 0}, {
      x = 50,
      opacity = 1,
      ease = "QuadOut",
      delay = 0.2
    })
    if self.damageGlowtimeline == nil then
      self.damageGlowtimeline = self.ScriptedEntityTweener:TimelineCreate()
      self.damageGlowtimeline:Add(self.Properties.WeaponResults.FinalDamageGlow, 0.6, {opacity = 1})
      self.damageGlowtimeline:Add(self.Properties.WeaponResults.FinalDamageGlow, 0.05, {opacity = 1})
      self.damageGlowtimeline:Add(self.Properties.WeaponResults.FinalDamageGlow, 0.6, {
        opacity = 0.2,
        onComplete = function()
          self.damageGlowtimeline:Play()
        end
      })
    end
    self.damageGlowtimeline:Play()
  elseif self.type == "Armor" then
    self.ScriptedEntityTweener:Play(self.Properties.ArmorResults.Container, 0.4, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0
    })
    self.ScriptedEntityTweener:Play(self.Properties.ArmorResults.FinalPhysical, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ArmorResults.FinalElemental, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    if self.physicalGlowtimeline == nil then
      self.physicalGlowtimeline = self.ScriptedEntityTweener:TimelineCreate()
      self.physicalGlowtimeline:Add(self.Properties.ArmorResults.FinalPhysicalGlow, 0.6, {opacity = 1})
      self.physicalGlowtimeline:Add(self.Properties.ArmorResults.FinalPhysicalGlow, 0.05, {opacity = 1})
      self.physicalGlowtimeline:Add(self.Properties.ArmorResults.FinalPhysicalGlow, 0.6, {
        opacity = 0.2,
        onComplete = function()
          self.physicalGlowtimeline:Play()
        end
      })
    end
    self.physicalGlowtimeline:Play()
    if self.elementalGlowtimeline == nil then
      self.elementalGlowtimeline = self.ScriptedEntityTweener:TimelineCreate()
      self.elementalGlowtimeline:Add(self.Properties.ArmorResults.FinalElementalGlow, 0.6, {opacity = 1})
      self.elementalGlowtimeline:Add(self.Properties.ArmorResults.FinalElementalGlow, 0.05, {opacity = 1})
      self.elementalGlowtimeline:Add(self.Properties.ArmorResults.FinalElementalGlow, 0.6, {
        opacity = 0.2,
        onComplete = function()
          self.elementalGlowtimeline:Play()
        end
      })
    end
    self.elementalGlowtimeline:Play()
  elseif self.type == "Trinket" then
    self.ScriptedEntityTweener:Play(self.Properties.TrinketResults.Container, 0.4, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0
    })
  end
  local progressionDelay = 0.5
  if self.hasPerks then
    UiElementBus.Event.SetIsEnabled(self.Properties.PerkContainer, true)
    local delayTime = (self.craftedFixedFromProcedural and self.rarityEffectDelayWithCelebration or self.rarityEffectDelayNormal) + 0.05
    local attributeDelay = 0
    local perkIndex = 0
    if 0 < self.attributesCount then
      attributeDelay = self.attributesCount * self.perkDelay
      delayTime = delayTime - attributeDelay
    end
    for i = 1, self.attributesCount do
      self.ScriptedEntityTweener:Play(self.Properties.AttributeList[i - 1], 0.2, {
        opacity = 0,
        scaleX = 1.4,
        scaleY = 1.4
      }, {
        opacity = 1,
        scaleX = 1,
        scaleY = 1,
        ease = "QuadOut",
        delay = delayTime
      })
      delayTime = delayTime + self.perkDelay
    end
    for i = 1, numNonGemPerks do
      self.PerkList[perkIndex]:ShowPerk(delayTime, false)
      delayTime = delayTime + self.perkDelay
      perkIndex = perkIndex + 1
    end
    if hasGemPerk then
      self.GemPerkSlot:ShowPerk(delayTime, true)
      delayTime = delayTime + self.perkDelay
      UiElementBus.Event.SetIsEnabled(self.Properties.GemDivider, true)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.GemDivider, false)
    end
    progressionDelay = delayTime + self.perkDelay
  end
  self.ScriptedEntityTweener:Play(self.Properties.ProgressionContainer, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = progressionDelay
  })
  local usesRarity = itemDescriptor:UsesRarity()
  local scaleValue = 2.5
  local rarityLabelDelay = 0.4
  if usesRarity then
    local rarityLevel = itemDescriptor:GetRarityLevel()
    local raritySuffix = tostring(rarityLevel)
    local displayName = "@RarityLevel" .. raritySuffix .. "_DisplayName"
    UiTextBus.Event.SetTextWithFlags(self.Properties.RarityText, displayName, eUiTextSet_SetLocalized)
    local colorName = string.format("COLOR_RARITY_LEVEL_%s", raritySuffix)
    local bgColorName = string.format("COLOR_RARITY_LEVEL_%s_BG", raritySuffix)
    local brightColorName = string.format("COLOR_RARITY_LEVEL_%s_BRIGHT", raritySuffix)
    UiImageBus.Event.SetSpritePathname(self.Properties.RarityBg, "lyshineui/images/crafting/crafting_itemRarityBgLarge" .. rarityLevel .. ".dds")
    UiTextBus.Event.SetColor(self.Properties.RarityText, self.UIStyle[brightColorName])
    UiTextBus.Event.SetColor(self.Properties.ItemName, self.UIStyle[brightColorName])
    UiImageBus.Event.SetColor(self.Properties.Cloud, self.UIStyle[colorName])
    UiImageBus.Event.SetColor(self.Properties.RarityGlow1, self.UIStyle[bgColorName])
    local soundName = string.format("Crafting_Rarity_%s", raritySuffix)
    self.audioHelper:PlaySound(self.audioHelper[soundName])
    if self.numPerksDisplay == 2 then
      if hasGemPerk then
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RarityOffset, 40)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionContainer, -104)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.GemPerkSlot, 186)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkContainer, 114)
      else
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RarityOffset, 70)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionContainer, -166)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkContainer, 124)
      end
      UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkList[0], 0)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.AttributesContainer, -3)
    elseif 1 >= self.numPerksDisplay then
      if hasGemPerk then
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RarityOffset, 40)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionContainer, -104)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.GemPerkSlot, 186)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkList[0], 32)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.AttributesContainer, 36)
      else
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RarityOffset, 70)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionContainer, -166)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkList[0], 42)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.AttributesContainer, 41)
      end
      UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkContainer, 114)
      scaleValue = 1
      rarityLabelDelay = 0
    elseif self.numPerksDisplay == 4 then
      if hasGemPerk then
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RarityOffset, -10)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionContainer, -10)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.GemPerkSlot, 334)
      else
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RarityOffset, 46)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionContainer, -58)
      end
      UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkList[0], 0)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.AttributesContainer, -2)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkContainer, 114)
    else
      if hasGemPerk then
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RarityOffset, 0)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionContainer, -68)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.GemPerkSlot, 260)
      else
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RarityOffset, 46)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionContainer, -132)
      end
      UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkList[0], 0)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.AttributesContainer, -2)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkContainer, 114)
    end
    if raritySuffix ~= "0" then
      do
        local effectName = string.format("Effect%s", raritySuffix)
        local delay = self.craftedFixedFromProcedural and self.rarityEffectDelayWithCelebration or self.rarityEffectDelayNormal
        TimingUtils:Delay(delay, self, function()
          UiElementBus.Event.SetIsEnabled(self.Properties.RarityEffect[effectName], true)
          UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.RarityEffect[effectName], 0)
          UiFlipbookAnimationBus.Event.Start(self.Properties.RarityEffect[effectName])
          UiElementBus.Event.SetIsEnabled(self.Properties.RarityLabelContainer, true)
          self.ScriptedEntityTweener:Play(self.Properties.RarityLabelContainer, 0.1, {opacity = 0}, {
            opacity = 1,
            delay = 0.3,
            ease = "QuadOut"
          })
          self.ScriptedEntityTweener:Play(self.Properties.RarityText, 0.3, {scaleX = 1.5, scaleY = 1.5}, {
            scaleX = 1,
            scaleY = 1,
            ease = "QuadOut",
            delay = 0.4
          })
          self.ScriptedEntityTweener:Play(self.Properties.RisingSun, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
          self.ScriptedEntityTweener:Play(self.Properties.RarityGlow2, 0.02, {opacity = 0}, {
            opacity = 1,
            delay = 0.5,
            ease = "QuadOut"
          })
          self.ScriptedEntityTweener:Play(self.Properties.RarityGlow2, 0.3, {opacity = 1}, {
            opacity = 0,
            delay = 0.6,
            ease = "QuadOut"
          })
        end)
      end
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.RarityLabelContainer, true)
    end
  else
    self.audioHelper:PlaySound(self.audioHelper.Crafting_Rarity_0)
    UiImageBus.Event.SetSpritePathname(self.Properties.RarityBg, "lyshineui/images/crafting/crafting_itemRarityBgLarge0.dds")
    UiTextBus.Event.SetColor(self.Properties.RarityText, self.UIStyle.COLOR_GRAY_80)
    UiTextBus.Event.SetColor(self.Properties.ItemName, self.UIStyle.COLOR_TAN)
    UiImageBus.Event.SetColor(self.Properties.Cloud, self.UIStyle.COLOR_GRAY_50)
    UiImageBus.Event.SetColor(self.Properties.RarityGlow1, self.UIStyle.COLOR_GRAY_20)
    if hasGemPerk then
      UiTransformBus.Event.SetLocalPositionY(self.Properties.RarityOffset, 40)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionContainer, -104)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.GemPerkSlot, 184)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkList[0], 32)
    else
      UiTransformBus.Event.SetLocalPositionY(self.Properties.RarityOffset, 70)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionContainer, -166)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkList[0], 42)
    end
    UiTransformBus.Event.SetLocalPositionY(self.Properties.PerkContainer, 114)
    scaleValue = 1
    rarityLabelDelay = 0
  end
  if self.craftedFixedFromProcedural then
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftedFromName, true)
    self.ScriptedEntityTweener:Play(self.Properties.CraftedFromName, 0, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.6
    })
    local craftedFromText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_crafted_from", self.oldItemName)
    UiTextBus.Event.SetTextWithFlags(self.Properties.CraftedFromName, craftedFromText, eUiTextSet_SetAsIs)
    UiElementBus.Event.SetIsEnabled(self.Properties.FixedItemCelebrationSequence, true)
    self.ScriptedEntityTweener:Set(self.Properties.FixedItemCelebrationSequence, {opacity = 1})
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.FixedItemCelebrationSequence, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.FixedItemCelebrationSequence)
    self.ScriptedEntityTweener:Play(self.Properties.FixedItemCelebrationSequence, 0.3, {
      opacity = 0,
      delay = 0.6,
      ease = "QuadOut"
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.FixedItemCelebrationRunesContainer, true)
    self.ScriptedEntityTweener:Stop(self.Properties.FixedItemCelebrationRunesContainer)
    self.ScriptedEntityTweener:Play(self.Properties.FixedItemCelebrationRunesContainer, 1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Stop(self.Properties.FixedItemCelebrationRuneClockwise)
    self.ScriptedEntityTweener:Play(self.Properties.FixedItemCelebrationRuneClockwise, 30, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    self.ScriptedEntityTweener:Stop(self.Properties.FixedItemCelebrationRuneCounterClockwise)
    self.ScriptedEntityTweener:Play(self.Properties.FixedItemCelebrationRuneCounterClockwise, 30, {rotation = 0}, {timesToPlay = -1, rotation = -359})
    self.ScriptedEntityTweener:Play(self.Properties.FixedItemCelebrationRunesContainer, 1, {
      opacity = 0,
      ease = "QuadOut",
      delay = 5
    })
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.RisingSun, usesRarity)
  if usesRarity then
    self.ScriptedEntityTweener:Play(self.Properties.RisingSun, 30, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  end
  self.ScriptedEntityTweener:Play(self.Properties.RarityLabel, 0.2, {
    scaleX = scaleValue,
    scaleY = scaleValue,
    opacity = 0
  }, {
    scaleX = 1,
    scaleY = 1,
    opacity = 1,
    delay = rarityLabelDelay,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.RarityGlow1, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
end
function CraftRoll:SetMultiCraft(isSingleMultiCraft)
  self.isSingleMultiCraft = isSingleMultiCraft
end
function CraftRoll:SetFixedFromProcedural(craftedFixedFromProcedural)
  self.craftedFixedFromProcedural = craftedFixedFromProcedural
end
function CraftRoll:RollComplete()
  if self.rollCompleted then
    return
  end
  self.rollCompleted = true
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
  self.totalDuration = 0
  self:DisconnectProgressionListeners()
  if self.isSingleMultiCraft then
    local delay = self.craftedFixedFromProcedural and 1.2 or 0.5
    local perksDelay = self.numPerksDisplay * self.perkDelay
    delay = delay + perksDelay
    TimingUtils:Delay(self.skipTried and 0.1 or delay, self, self.AdvanceStep)
  end
end
function CraftRoll:OnAnimationStopped()
  self:BusDisconnect(self.flipbookAnimationHandler)
  UiElementBus.Event.SetIsEnabled(self.CraftsmanshipEffects, false)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.CraftsmanshipEffects, 0)
  self.isAnimatingCraftsmanshipEffects = false
end
function CraftRoll:AdvanceStep()
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  LyShineManagerBus.Broadcast.OnAction(canvasId, self.entityId, "ancestor:OnSkip")
end
function CraftRoll:GetNumPerks()
  return self.numPerksDisplay, self.perkDelay
end
function CraftRoll:SetGearScoreText(score)
  UiTextBus.Event.SetTextWithFlags(self.Properties.GearScore, tostring(score), eUiTextSet_SetAsIs)
  score = math.max(score, self.minGearScore)
  local qualityPercent = (score - self.minGearScore) / (self.maxGearScore - self.minGearScore)
  local anchors = UiAnchors(qualityPercent, 0, qualityPercent, 0.5)
  UiTransform2dBus.Event.SetAnchorsScript(self.Properties.QualityIndicator, anchors)
end
function CraftRoll:SetGearScore(gearScore, duration)
  self.gearScore = gearScore
  self.currentGearScore = self.gearScore - (math.random(20) + 40)
  self.currentGearScore = math.max(self.currentGearScore, 0)
  self:SetGearScoreText(self.currentGearScore)
  if duration ~= nil and duration < self.duration then
    self.skipCraftsmanship = true
  end
  local duration = duration or self.duration
  self:AnimateGearScore(duration)
end
function CraftRoll:AnimateGearScore(newDuration)
  self.curDuration = 0
  self.totalDuration = newDuration
  self:SetGearScoreText(self.currentGearScore)
  if self.tickHandler == nil then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
  if not self.isSingleMultiCraft then
    TimingUtils:Delay(1, self, self.AdvanceStep)
  end
end
function CraftRoll:SkipAnimation(newDuration)
  self.skipTried = true
  local newDuration = newDuration or 0.1
  if self.type == "Quantity" or self.type == "Single" then
    self:AnimateRefiningBar(newDuration)
  else
    self.endRollTypeIndex = nil
    self.skipCraftsmanship = true
    if self.isAnimatingCraftsmanshipEffects then
      self:OnAnimationStopped()
    end
    self:AnimateGearScore(newDuration)
  end
end
function CraftRoll:Reset()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
  self.rollDelayTimer = 0
  self.skipTried = false
  self.rollCompleted = false
  self.ScriptedEntityTweener:Stop(self.Properties.WeaponResults.Container)
  self.ScriptedEntityTweener:Stop(self.Properties.ArmorResults.Container)
  self.ScriptedEntityTweener:Stop(self.Properties.TrinketResults.Container)
  self.ScriptedEntityTweener:Stop(self.Properties.RarityBg)
  self.ScriptedEntityTweener:Stop(self.Properties.RarityGlow1)
  self.ScriptedEntityTweener:Stop(self.Properties.RarityGlow2)
  self.ScriptedEntityTweener:Stop(self.Properties.RisingSun)
  self.ScriptedEntityTweener:Stop(self.Properties.NoPerkLabel)
  self.ScriptedEntityTweener:Stop(self.Properties.Cloud)
  self.ScriptedEntityTweener:Stop(self.Properties.RarityLabel)
  self.ScriptedEntityTweener:Stop(self.Properties.RarityLabelContainer)
  self.ScriptedEntityTweener:Stop(self.Properties.ProgressionContainer)
  self.ScriptedEntityTweener:Set(self.Properties.WeaponResults.Container, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.ArmorResults.Container, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.TrinketResults.Container, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RarityBg, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RarityGlow1, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RarityGlow2, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RisingSun, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.NoPerkLabel, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.Cloud, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RarityLabel, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.PerkContainer, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RisingSun, {rotation = 0})
  self.ScriptedEntityTweener:Set(self.Properties.ProgressionContainer, {opacity = 0})
  for i = 0, #self.Properties.PerkList do
    self.PerkList[i]:StopAnimation()
  end
  self.GemPerkSlot:StopAnimation()
  if self.physicalGlowtimeline ~= nil then
    self.physicalGlowtimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.physicalGlowtimeline)
  end
  if self.elementalGlowtimeline ~= nil then
    self.elementalGlowtimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.elementalGlowtimeline)
  end
  if self.damageGlowtimeline ~= nil then
    self.damageGlowtimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.damageGlowtimeline)
  end
  UiElementBus.Event.Reparent(self.Properties.StandingProgression.Container, self.Properties.InvisibleLayout, EntityId())
  UiElementBus.Event.Reparent(self.Properties.SkillProgression.Container, self.Properties.InvisibleLayout, EntityId())
  UiElementBus.Event.SetIsEnabled(self.Properties.RarityEffect.Effect1, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.RarityEffect.Effect2, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.RarityEffect.Effect3, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.FixedItemCelebrationSequence, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.FixedItemCelebrationRunesContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftedFromName, false)
end
return CraftRoll

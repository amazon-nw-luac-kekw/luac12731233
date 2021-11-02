local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local DynamicTooltip_ItemStats = {
  Properties = {
    StatList = {
      default = EntityId()
    },
    GearScoreText = {
      default = EntityId()
    },
    GearScoreLabel = {
      default = EntityId()
    },
    GearScoreTextCompareArrow = {
      default = EntityId()
    },
    SecondaryTextContainer = {
      default = EntityId()
    },
    SecondaryText = {
      default = EntityId()
    },
    SecondaryTextCompareArrow = {
      default = EntityId()
    },
    SecondaryTextCompareExtraArrow = {
      default = EntityId()
    },
    SecondaryHeader = {
      default = EntityId()
    },
    SecondaryTextExtra = {
      default = EntityId()
    },
    SecondaryTextExtraHeader = {
      default = EntityId()
    },
    PerksInfoText = {
      default = EntityId()
    },
    PerksContainer = {
      default = EntityId()
    },
    PerksList = {
      default = EntityId()
    },
    PerksDivider = {
      default = EntityId()
    },
    ArmorRatingContainer = {
      default = EntityId()
    },
    DamageContainer = {
      default = EntityId()
    },
    StatContainer = {
      default = EntityId()
    },
    DamageTypeContainer = {
      default = EntityId()
    },
    DamageTypeList = {
      default = EntityId()
    },
    ArmorRatingPhysical = {
      default = EntityId()
    },
    ArmorRatingPhysicalPenalty = {
      default = EntityId()
    },
    ArmorRatingPhysicalCompareArrow = {
      default = EntityId()
    },
    ArmorRatingElemental = {
      default = EntityId()
    },
    ArmorRatingElementalPenalty = {
      default = EntityId()
    },
    ArmorRatingElementalCompareArrow = {
      default = EntityId()
    }
  },
  isWeapon = false,
  GEAR_SCORE_HEIGHT = 47,
  GEAR_SCORE_POSITIONX = 15,
  TOTAL_HEIGHT = 10,
  STAT_LINE_SPACING = 21,
  END_OF_SECTION_SPACING = 15
}
local StatIndendation = ""
BaseElement:CreateNewElement(DynamicTooltip_ItemStats)
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
function DynamicTooltip_ItemStats:OnInit()
  BaseElement.OnInit(self)
  self.originalEntityOffsets = UiTransform2dBus.Event.GetOffsets(self.entityId)
  SetTextStyle(self.Properties.GearScoreText, self.UIStyle.FONT_STYLE_GEAR_SCORE)
  SetTextStyle(self.Properties.GearScoreLabel, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
  SetTextStyle(self.Properties.SecondaryText, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_NUMBER)
  SetTextStyle(self.Properties.SecondaryHeader, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
  SetTextStyle(self.Properties.SecondaryTextExtra, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_NUMBER)
  SetTextStyle(self.Properties.SecondaryTextExtraHeader, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
  SetTextStyle(self.Properties.PerksInfoText, self.UIStyle.FONT_STYLE_FLAVOR_TEXT)
end
function DynamicTooltip_ItemStats:SetItem(itemTable, equipSlot, compareTo)
  self.TOTAL_HEIGHT = 10
  local gearScoreLabelPositionX = 8
  local secondaryTextpositionX = 0
  UiTransform2dBus.Event.SetOffsets(self.entityId, self.originalEntityOffsets)
  UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryTextContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.DamageContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.StatContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ArmorRatingContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PerksInfoText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PerksDivider, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.DamageTypeContainer, false)
  local resourceData = itemTable.id and ItemDataManagerBus.Broadcast.GetResourceData(itemTable.id)
  if resourceData and resourceData:IsValid() then
    local perks = ItemDataManagerBus.Broadcast.GetValidPerksForPerkBucket(resourceData.perkBucketCrc)
    local numPerks = #perks
    local nonInherentPerks = 0
    for i = 1, #perks do
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perks[i])
      if perkData.perkType ~= ePerkType_Inherent then
        nonInherentPerks = nonInherentPerks + 1
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.PerksContainer, 0 < nonInherentPerks)
    if 0 < nonInherentPerks then
      UiElementBus.Event.SetIsEnabled(self.Properties.PerksInfoText, true)
      self.ScriptedEntityTweener:Set(self.Properties.PerksInfoText, {
        y = self.TOTAL_HEIGHT
      })
      local perksInfoText = ""
      if resourceData.isGem then
        perksInfoText = 1 < nonInherentPerks and "@ui_tooltip_perks_info_text_gem_plural" or "@ui_tooltip_perks_info_text_gem_singular"
      else
        perksInfoText = 1 < nonInherentPerks and "@ui_tooltip_perks_info_text_craft_plural" or "@ui_tooltip_perks_info_text_craft_singular"
      end
      UiTextBus.Event.SetTextWithFlags(self.Properties.PerksInfoText, perksInfoText, eUiTextSet_SetLocalized)
      local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.PerksInfoText)
      self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + textHeight
      self.ScriptedEntityTweener:Set(self.Properties.PerksContainer, {
        y = self.TOTAL_HEIGHT
      })
      UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.PerksList, numPerks)
      local children = UiElementBus.Event.GetChildren(self.Properties.PerksList)
      for i = 1, numPerks do
        local entityId = children[i]
        local entityTable = self.registrar:GetEntityTable(entityId)
        local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perks[i])
        local showOrText = numPerks > i
        if perkData.perkType ~= ePerkType_Inherent then
          local perkMultiplier = perkData:GetPerkMultiplier(itemTable.gearScore)
          self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + entityTable:SetPerkData(perkData, false, false, true, showOrText, perkMultiplier)
        end
      end
      return self.TOTAL_HEIGHT + self.END_OF_SECTION_SPACING
    end
  end
  local equipSlot = itemTable.equipSlot
  if not equipSlot and itemTable.equipSlots then
    equipSlot = itemTable.equipSlots[1]
  end
  if type(equipSlot) ~= "string" then
    return 0
  end
  equipSlot = string.upper(equipSlot)
  local currentLine = 0
  if type(itemTable.gearScore) == "number" and 0 < itemTable.gearScore then
    self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.GEAR_SCORE_HEIGHT
    UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreText, true)
    UiTextBus.Event.SetText(self.Properties.GearScoreText, tostring(itemTable.gearScore))
    UiTextBus.Event.SetTextWithFlags(self.Properties.GearScoreLabel, "@cr_gearscore", eUiTextSet_SetLocalized)
    local difference = 0
    if type(compareTo) == "table" and type(compareTo.gearScore) == "number" then
      difference = itemTable.gearScore - compareTo.gearScore
    end
    gearScoreLabelPositionX = difference == 0 and 8 or 23
    self.ScriptedEntityTweener:Set(self.Properties.GearScoreLabel, {x = gearScoreLabelPositionX})
    self.ScriptedEntityTweener:Set(self.Properties.GearScoreText, {
      x = self.GEAR_SCORE_POSITIONX
    })
    self:ShowCompare(self.GearScoreText, self.GearScoreTextCompareArrow, difference)
  elseif itemTable.itemType ~= "Ammo" then
    return 0
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryHeader, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryTextExtra, false)
  if itemTable.itemType == "Ammo" then
    self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.GEAR_SCORE_HEIGHT
    self.ScriptedEntityTweener:Set(self.Properties.SecondaryTextContainer, {
      y = self.TOTAL_HEIGHT
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryTextContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryHeader, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreText, true)
    UiTextBus.Event.SetText(self.Properties.GearScoreText, LocalizeDecimalSeparators(string.format("x %.02f", itemTable.ammoAttributes.damageModifier)))
    UiTextBus.Event.SetTextWithFlags(self.Properties.GearScoreLabel, "@ui_tooltip_damagemodifier", eUiTextSet_SetLocalized)
    local difference = 0
    if compareTo then
      difference = itemTable.ammoAttributes.damageModifier - compareTo.ammoAttributes.damageModifier
    end
    gearScoreLabelPositionX = difference == 0 and 8 or 23
    self.ScriptedEntityTweener:Set(self.Properties.GearScoreLabel, {x = gearScoreLabelPositionX})
    self.ScriptedEntityTweener:Set(self.Properties.GearScoreText, {
      x = self.GEAR_SCORE_POSITIONX
    })
    self:ShowCompare(self.GearScoreText, self.GearScoreTextCompareArrow, difference)
  end
  if itemTable.itemType == "Consumable" then
    self.ScriptedEntityTweener:Set(self.Properties.GearScoreText, {
      x = self.GEAR_SCORE_POSITIONX
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.DamageContainer, false)
  end
  local isBroken = itemTable.durability == 0 and 0 < itemTable.maxDurability
  if itemTable.weaponAttributes then
    local statLine = UiElementBus.Event.GetChild(self.Properties.StatList, currentLine)
    if type(itemTable.weaponAttributes.gatheringEfficiency) == "number" and 0 < itemTable.weaponAttributes.gatheringEfficiency or type(itemTable.weaponAttributes.maxCastDistance) == "number" and 0 < itemTable.weaponAttributes.maxCastDistance then
      self.ScriptedEntityTweener:Set(self.Properties.GearScoreText, {
        x = self.GEAR_SCORE_POSITIONX
      })
      local scoreReduced = false
      if isBroken and itemTable.hasBaseAttributes and type(itemTable.baseAttributes.weaponAttributes.gatheringEfficiency) == "number" and 0 < itemTable.baseAttributes.weaponAttributes.gatheringEfficiency then
        local base = itemTable.baseAttributes.weaponAttributes.gatheringEfficiency
        local current = itemTable.weaponAttributes.gatheringEfficiency
        if base > current then
          scoreReduced = true
        end
      end
      local difference = 0
      if compareTo then
        difference = itemTable.weaponAttributes.gatheringEfficiency - compareTo.weaponAttributes.gatheringEfficiency
      end
      secondaryTextpositionX = difference == 0 and 5 or 17
      self.ScriptedEntityTweener:Set(self.Properties.SecondaryHeader, {x = secondaryTextpositionX})
      self:ShowCompare(self.SecondaryText, self.SecondaryTextCompareArrow, difference, scoreReduced)
      UiElementBus.Event.SetIsEnabled(self.Properties.DamageContainer, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryHeader, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryTextContainer, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.StatContainer, true)
      self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + 12
      self.ScriptedEntityTweener:Set(self.Properties.StatContainer, {
        y = self.TOTAL_HEIGHT
      })
      local gatherStats = {
        {
          stat = itemTable.weaponAttributes.gatheringEfficiency * 100,
          name = "@ui_tooltip_gatherspeed",
          dataPath = "weaponAttributes.gatheringEfficiency",
          baseStat = isBroken and itemTable.hasBaseAttributes and itemTable.baseAttributes.weaponAttributes.gatheringEfficiency * 100 or 0,
          statStringFormat = "%.0f%%"
        }
      }
      if 0 < itemTable.weaponAttributes.maxCastDistance then
        gatherStats[1].stat = itemTable.weaponAttributes.maxCastDistance
        gatherStats[1].name = "@ui_tooltip_maxcastdistance"
        gatherStats[1].dataPath = "weaponAttributes.maxCastDistance"
        gatherStats[1].baseStat = 0
        gatherStats[1].statStringFormat = "%dm"
      end
      UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.StatList, #gatherStats)
      for _, gatherStat in ipairs(gatherStats) do
        self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.STAT_LINE_SPACING
        statLine = UiElementBus.Event.GetChild(self.Properties.StatList, currentLine)
        currentLine = currentLine + 1
        local valueEntity = UiElementBus.Event.FindChildByName(statLine, "Value")
        local statLabel = UiElementBus.Event.FindChildByName(valueEntity, "Stat")
        SetTextStyle(valueEntity, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_NUMBER)
        SetTextStyle(statLabel, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
        UiTextBus.Event.SetTextWithFlags(statLabel, StatIndendation .. gatherStat.name, eUiTextSet_SetLocalized)
        local scoreReduced = false
        local valueText = StatIndendation .. string.format(gatherStat.statStringFormat, gatherStat.stat)
        if 0 < gatherStat.baseStat then
          local gatherDelta = gatherStat.stat - gatherStat.baseStat
          if gatherDelta < 0 then
            scoreReduced = true
          end
        end
        UiTextBus.Event.SetTextWithFlags(valueEntity, valueText, eUiTextSet_SetLocalized)
        local difference = 0
        if compareTo then
          local value = GetTableValue(itemTable, gatherStat.dataPath, 0)
          local compareValue = GetTableValue(compareTo, gatherStat.dataPath, 0)
          difference = value - compareValue
        end
        local positionX = difference == 0 and 5 or 17
        self.ScriptedEntityTweener:Set(statLabel, {x = positionX})
        self:ShowCompare(valueEntity, UiElementBus.Event.FindChildByName(valueEntity, "ValueCompareArrow"), difference, scoreReduced)
      end
    elseif type(itemTable.weaponAttributes.baseDamage) == "number" and 0 < itemTable.weaponAttributes.baseDamage then
      self.ScriptedEntityTweener:Set(self.Properties.GearScoreText, {
        x = self.GEAR_SCORE_POSITIONX
      })
      local coreDamage = math.floor(itemTable.coreDamage)
      if compareTo then
        if compareTo.isEquipped and not itemTable.isEquipped then
          local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
          local paperdollSlotType = ePaperDollSlotTypes_MainHandOption1
          local relevantEquippedSlot = PaperdollRequestBus.Event.GetSlot(paperdollId, paperdollSlotType)
          if relevantEquippedSlot and relevantEquippedSlot:GetItemInstanceId() ~= compareTo.itemInstanceId then
            paperdollSlotType = ePaperDollSlotTypes_MainHandOption2
            relevantEquippedSlot = PaperdollRequestBus.Event.GetSlot(paperdollId, paperdollSlotType)
            if relevantEquippedSlot ~= compareTo.itemInstanceId then
              paperdollSlotType = nil
            end
          end
          if paperdollSlotType and not isBroken then
            local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
            coreDamage = math.floor(itemTable.itemDescriptorRef:GetCoreDamageForOwner(rootEntityId, false, paperdollSlotType))
          end
        end
      elseif not isBroken then
        local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
        coreDamage = math.floor(itemTable.itemDescriptorRef:GetCoreDamageForOwner(rootEntityId, itemTable.isEquipped, ePaperDollSlotTypes_MainHandOption3))
      end
      self.ScriptedEntityTweener:Set(self.Properties.SecondaryTextContainer, {
        y = self.TOTAL_HEIGHT
      })
      local scoreReduced = false
      if isBroken and itemTable.hasBaseAttributes and type(itemTable.baseAttributes.weaponAttributes.baseDamage) == "number" and 0 < itemTable.baseAttributes.weaponAttributes.baseDamage then
        local baseDamage = itemTable.baseAttributes.weaponAttributes.baseDamage
        local currentDamage = itemTable.weaponAttributes.baseDamage
        if baseDamage > currentDamage then
          scoreReduced = true
        end
      end
      UiTextBus.Event.SetText(self.Properties.SecondaryText, GetLocalizedNumber(coreDamage))
      self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.STAT_LINE_SPACING
      local secondaryText = itemTable.weaponAttributes.isMagic and "@ui_tooltip_corepower" or "@ui_tooltip_coredamage"
      local secondaryTextExtraHeaderText = itemTable.weaponAttributes.isMagic and "@ui_tooltip_basepower" or "@ui_tooltip_basedamage"
      UiTextBus.Event.SetTextWithFlags(self.Properties.SecondaryHeader, secondaryText, eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryHeader, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryTextContainer, true)
      local difference = 0
      if compareTo then
        difference = coreDamage - math.floor(compareTo.coreDamage)
      end
      secondaryTextpositionX = difference == 0 and 5 or 17
      self.ScriptedEntityTweener:Set(self.Properties.SecondaryHeader, {x = secondaryTextpositionX})
      self:ShowCompare(self.SecondaryText, self.SecondaryTextCompareArrow, difference, scoreReduced)
      self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + 11
      self.ScriptedEntityTweener:Set(self.Properties.DamageContainer, {
        y = self.TOTAL_HEIGHT
      })
      local currentDamageStat = 0
      local damageStatLine = UiElementBus.Event.GetChild(self.Properties.DamageContainer, currentDamageStat)
      UiElementBus.Event.SetIsEnabled(damageStatLine, false)
      if type(itemTable.weaponAttributes.critChance) == "number" and 0 < itemTable.weaponAttributes.critChance then
        UiElementBus.Event.SetIsEnabled(damageStatLine, true)
        self.ScriptedEntityTweener:Set(damageStatLine, {
          y = currentDamageStat * self.STAT_LINE_SPACING
        })
        SetTextStyle(damageStatLine, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_NUMBER)
        local critChance = string.format("%.1f%%", itemTable.weaponAttributes.critChance * 100)
        UiTextBus.Event.SetText(damageStatLine, critChance)
        local statName = UiElementBus.Event.FindChildByName(damageStatLine, "StatName")
        SetTextStyle(statName, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
        UiTextBus.Event.SetTextWithFlags(statName, "@ui_tooltip_critical_hit_chance", eUiTextSet_SetLocalized)
        local valueArrowEntity = UiElementBus.Event.FindChildByName(damageStatLine, "ValueCompareArrow")
        local difference = 0
        if compareTo then
          difference = itemTable.weaponAttributes.critChance - compareTo.weaponAttributes.critChance
        end
        local positionX = difference == 0 and 5 or 17
        self.ScriptedEntityTweener:Set(statName, {x = positionX})
        self:ShowCompare(damageStatLine, valueArrowEntity, difference)
        UiElementBus.Event.SetIsEnabled(self.Properties.DamageContainer, true)
        self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.STAT_LINE_SPACING
        currentDamageStat = currentDamageStat + 1
      end
      damageStatLine = UiElementBus.Event.GetChild(self.Properties.DamageContainer, currentDamageStat)
      UiElementBus.Event.SetIsEnabled(damageStatLine, false)
      if type(itemTable.weaponAttributes.critDamageMultiplier) == "number" and 0 < itemTable.weaponAttributes.critDamageMultiplier then
        UiElementBus.Event.SetIsEnabled(damageStatLine, true)
        self.ScriptedEntityTweener:Set(damageStatLine, {
          y = currentDamageStat * self.STAT_LINE_SPACING
        })
        SetTextStyle(damageStatLine, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_NUMBER)
        local critDamageMultiplier = string.format("%.1f", itemTable.weaponAttributes.critDamageMultiplier)
        UiTextBus.Event.SetText(damageStatLine, critDamageMultiplier)
        local statName = UiElementBus.Event.FindChildByName(damageStatLine, "StatName")
        SetTextStyle(statName, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
        UiTextBus.Event.SetTextWithFlags(statName, "@ui_tooltip_critical_damage_multiplier", eUiTextSet_SetLocalized)
        local valueArrowEntity = UiElementBus.Event.FindChildByName(damageStatLine, "ValueCompareArrow")
        local difference = 0
        if compareTo then
          difference = itemTable.weaponAttributes.critDamageMultiplier - compareTo.weaponAttributes.critDamageMultiplier
        end
        local positionX = difference == 0 and 5 or 17
        self.ScriptedEntityTweener:Set(statName, {x = positionX})
        self:ShowCompare(damageStatLine, valueArrowEntity, difference)
        UiElementBus.Event.SetIsEnabled(self.Properties.DamageContainer, true)
        self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.STAT_LINE_SPACING
        currentDamageStat = currentDamageStat + 1
      end
      damageStatLine = UiElementBus.Event.GetChild(self.Properties.DamageContainer, currentDamageStat)
      UiElementBus.Event.SetIsEnabled(damageStatLine, false)
      if type(itemTable.weaponAttributes.blockStaminaDamage) == "number" and 0 < itemTable.weaponAttributes.blockStaminaDamage then
        UiElementBus.Event.SetIsEnabled(damageStatLine, true)
        self.ScriptedEntityTweener:Set(damageStatLine, {
          y = currentDamageStat * self.STAT_LINE_SPACING
        })
        SetTextStyle(damageStatLine, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_NUMBER)
        local blockStaminaDamage = string.format("%.1f", itemTable.weaponAttributes.blockStaminaDamage)
        UiTextBus.Event.SetText(damageStatLine, blockStaminaDamage)
        local statName = UiElementBus.Event.FindChildByName(damageStatLine, "StatName")
        SetTextStyle(statName, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
        UiTextBus.Event.SetTextWithFlags(statName, "@ui_tooltip_block_stamina_damage", eUiTextSet_SetLocalized)
        local valueArrowEntity = UiElementBus.Event.FindChildByName(damageStatLine, "ValueCompareArrow")
        local difference = 0
        if compareTo then
          difference = itemTable.weaponAttributes.blockStaminaDamage - compareTo.weaponAttributes.blockStaminaDamage
        end
        local positionX = difference == 0 and 5 or 17
        self.ScriptedEntityTweener:Set(statName, {x = positionX})
        self:ShowCompare(damageStatLine, valueArrowEntity, difference)
        UiElementBus.Event.SetIsEnabled(self.Properties.DamageContainer, true)
        self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.STAT_LINE_SPACING
        currentDamageStat = currentDamageStat + 1
      end
      damageStatLine = UiElementBus.Event.GetChild(self.Properties.DamageContainer, currentDamageStat)
      UiElementBus.Event.SetIsEnabled(damageStatLine, false)
      if itemTable.weaponAttributes.physicalArmorRating and 0 < itemTable.weaponAttributes.physicalArmorRating or itemTable.weaponAttributes.elementalArmorRating and 0 < itemTable.weaponAttributes.elementalArmorRating then
        self.ScriptedEntityTweener:Set(self.Properties.ArmorRatingContainer, {
          y = self.TOTAL_HEIGHT
        })
        UiElementBus.Event.SetIsEnabled(self.Properties.ArmorRatingContainer, true)
        local ratingsMap = {
          ArmorRatingPhysical = {
            currentValue = "weaponAttributes.physicalArmorRating",
            baseValue = "baseAttributes.weaponAttributes.physicalArmorRating"
          },
          ArmorRatingElemental = {
            currentValue = "weaponAttributes.elementalArmorRating",
            baseValue = "baseAttributes.weaponAttributes.elementalArmorRating"
          }
        }
        local appended = 0
        for entityName, dataLocation in pairs(ratingsMap) do
          local statLabel
          if self[entityName] then
            if entityName == "ArmorRatingPhysical" or entityName == "ArmorRatingElemental" then
              statLabel = UiElementBus.Event.FindChildByName(self[entityName], "StatName")
              SetTextStyle(self[entityName], self.UIStyle.FONT_STYLE_TOOLTIP_STAT_NUMBER)
              SetTextStyle(statLabel, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
              self.ScriptedEntityTweener:Set(self[entityName], {
                y = appended * self.STAT_LINE_SPACING
              })
              appended = appended + 1
              self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.STAT_LINE_SPACING
            end
            local value = GetTableValue(itemTable, dataLocation.currentValue, 0)
            UiTextBus.Event.SetTextWithFlags(self[entityName], LocalizeDecimalSeparators(string.format("%.1f", value)), eUiTextSet_SetAsIs)
            local scoreReduced = false
            if isBroken and itemTable.hasBaseAttributes then
              local ratingDelta = value - GetTableValue(itemTable, dataLocation.baseValue, 0)
              if ratingDelta < 0 then
                scoreReduced = true
              end
            end
            local difference = 0
            if compareTo then
              local compareValue = GetTableValue(compareTo, dataLocation.currentValue, 0)
              difference = value - compareValue
            end
            local positionX = difference == 0 and 5 or 17
            if statLabel ~= nil then
              self.ScriptedEntityTweener:Set(statLabel, {x = positionX})
            else
              Debug.Log("Could not find statLabel entity")
            end
            self:ShowCompare(self[entityName], self[entityName .. "CompareArrow"], difference, scoreReduced)
          end
        end
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.StatContainer, not itemTable.isRanged)
      self.ScriptedEntityTweener:Set(self.Properties.StatContainer, {
        y = self.TOTAL_HEIGHT
      })
      if not itemTable.isRanged then
        UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.StatList, 1)
        statLine = UiElementBus.Event.GetChild(self.Properties.StatList, currentLine)
        local valueEntity = UiElementBus.Event.FindChildByName(statLine, "Value")
        local statLabel = UiElementBus.Event.FindChildByName(valueEntity, "Stat")
        SetTextStyle(statLabel, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
        SetTextStyle(valueEntity, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_NUMBER)
        UiTextBus.Event.SetTextWithFlags(statLabel, "@ui_tooltip_blockingstability", eUiTextSet_SetLocalized)
        local blockStability = isBroken and 0 or itemTable.weaponAttributes.blockStability
        local blockingText = string.format("%.0f%%", blockStability)
        UiTextBus.Event.SetText(valueEntity, blockingText)
        local difference = 0
        if compareTo then
          local blockStabilityComp = compareTo.durability == 0 and 0 < compareTo.maxDurability and 0 or compareTo.weaponAttributes.blockStability
          difference = blockStability - blockStabilityComp
        end
        local positionX = difference == 0 and 5 or 17
        self.ScriptedEntityTweener:Set(statLabel, {x = positionX})
        self:ShowCompare(valueEntity, UiElementBus.Event.FindChildByName(valueEntity, "ValueCompareArrow"), difference, isBroken)
        self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.STAT_LINE_SPACING
      end
    else
      self.ScriptedEntityTweener:Set(self.Properties.GearScoreText, {
        x = self.GEAR_SCORE_POSITIONX
      })
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.DamageTypeContainer, false)
    if not self.damageCategories then
      self.damageCategories = {
        {
          current = "weaponAttributes.primaryAttack",
          base = "baseAttributes.weaponAttributes.primaryAttack"
        }
      }
    end
    local damagesByType = {}
    local compareDamagesByType = {}
    for _, damageCategory in ipairs(self.damageCategories) do
      local subTable = GetTableValue(itemTable, damageCategory.current)
      local compareSubTable = compareTo and GetTableValue(compareTo, damageCategory.current)
      local baseTable = itemTable.hasBaseAttributes and GetTableValue(itemTable, damageCategory.base)
      if compareSubTable then
        for k = 1, #compareSubTable do
          local damageInfo = compareSubTable[k]
          local damage = GetTableValue(damageInfo, "amount", 0)
          table.insert(compareDamagesByType, {
            damage = GetTableValue(damageInfo, "amount", 0),
            name = damageInfo.name
          })
        end
      end
      for k = 1, #subTable do
        local damageInfo = subTable[k]
        local damage = GetTableValue(damageInfo, "amount", 0)
        local baseDamage
        if baseTable and k <= #baseTable then
          local baseDamageInfo = baseTable[k]
          baseDamage = baseDamageInfo and GetTableValue(baseDamageInfo, "amount", 0) or nil
        end
        table.insert(damagesByType, {
          damage = damage,
          name = damageInfo.name,
          base = baseDamage
        })
      end
    end
    table.sort(damagesByType, function(a, b)
      return a.damage > b.damage
    end)
    UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.DamageTypeList, #damagesByType)
    local damageTypeChildren = UiElementBus.Event.GetChildren(self.Properties.DamageTypeList)
    for i = 1, #damageTypeChildren do
      local entityId = damageTypeChildren[i]
      local damageInfo = damagesByType[i]
      local hasDamageInfo = damageInfo ~= nil and 0 < damageInfo.damage
      local hasBaseDamageInfo = damageInfo ~= nil and damageInfo.base ~= nil and 0 < damageInfo.base
      UiElementBus.Event.SetIsEnabled(entityId, hasDamageInfo)
      if hasDamageInfo then
        if not UiElementBus.Event.IsEnabled(self.Properties.DamageTypeContainer) then
          UiElementBus.Event.SetIsEnabled(self.Properties.DamageTypeContainer, true)
          self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + 10
          self.ScriptedEntityTweener:Set(self.Properties.DamageTypeContainer, {
            y = self.TOTAL_HEIGHT
          })
        end
        local damageToUse = damageInfo.damage
        local baseDamageToUse = damageInfo.base
        local damageNameToUse = damageInfo.name
        local imageEntity = UiElementBus.Event.FindDescendantByName(entityId, "DamageTypeIcon")
        local damageAmount = UiElementBus.Event.FindDescendantByName(entityId, "DamageAmount")
        local description = UiElementBus.Event.FindDescendantByName(entityId, "Description")
        local arrowEntity = UiElementBus.Event.FindDescendantByName(entityId, "CompareArrow")
        local iconPath = "lyshineui/images/icons/tooltip/icon_tooltip_" .. damageNameToUse .. "_opaque.dds"
        local damageName = "@" .. string.lower(damageNameToUse) .. "_DamageName"
        local scoreReduced = false
        if isBroken and hasBaseDamageInfo and damageToUse < baseDamageToUse then
          scoreReduced = true
        end
        local difference = 0
        if compareTo then
          for i = 1, #compareDamagesByType do
            local current = compareDamagesByType[i]
            local compareNameToUse = current.name
            local compareDamageToUse = current.damage
            if compareNameToUse == damageNameToUse then
              difference = damageToUse - compareDamageToUse
              break
            end
          end
        end
        local positionX = difference == 0 and 5 or 17
        self.ScriptedEntityTweener:Set(description, {x = positionX})
        UiImageBus.Event.SetSpritePathname(imageEntity, iconPath)
        UiTextBus.Event.SetText(damageAmount, damageToUse)
        UiTextBus.Event.SetTextWithFlags(description, damageName, eUiTextSet_SetLocalized)
        self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + UiLayoutCellBus.Event.GetTargetHeight(entityId)
        self:ShowCompare(damageAmount, arrowEntity, difference, scoreReduced)
      end
    end
  end
  if itemTable.armorAttributes then
    self.ScriptedEntityTweener:Set(self.Properties.GearScoreText, {
      x = self.GEAR_SCORE_POSITIONX
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.StatContainer, false)
    if 0 < itemTable.armorAttributes.physicalArmorRating or 0 < itemTable.armorAttributes.elementalArmorRating then
      self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + 11
      self.ScriptedEntityTweener:Set(self.Properties.ArmorRatingContainer, {
        y = self.TOTAL_HEIGHT
      })
      UiElementBus.Event.SetIsEnabled(self.Properties.ArmorRatingContainer, true)
      local ratingsMap = {
        ArmorRatingPhysical = {
          currentValue = "armorAttributes.physicalArmorRating",
          baseValue = "baseAttributes.armorAttributes.physicalArmorRating"
        },
        ArmorRatingElemental = {
          currentValue = "armorAttributes.elementalArmorRating",
          baseValue = "baseAttributes.armorAttributes.elementalArmorRating"
        }
      }
      local appended = 0
      for entityName, dataLocation in pairs(ratingsMap) do
        local statLabel
        if self[entityName] then
          if entityName == "ArmorRatingPhysical" or entityName == "ArmorRatingElemental" then
            statLabel = UiElementBus.Event.FindChildByName(self[entityName], "StatName")
            SetTextStyle(self[entityName], self.UIStyle.FONT_STYLE_TOOLTIP_STAT_NUMBER)
            SetTextStyle(statLabel, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
            self.ScriptedEntityTweener:Set(self[entityName], {
              y = appended * self.STAT_LINE_SPACING
            })
            appended = appended + 1
            self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.STAT_LINE_SPACING
          end
          local value = GetTableValue(itemTable, dataLocation.currentValue, 0)
          UiTextBus.Event.SetTextWithFlags(self[entityName], LocalizeDecimalSeparators(string.format("%.1f", value)), eUiTextSet_SetAsIs)
          local scoreReduced = false
          if dataLocation.baseValue and isBroken and itemTable.hasBaseAttributes then
            local ratingDelta = value - GetTableValue(itemTable, dataLocation.baseValue, 0)
            if ratingDelta < 0 then
              scoreReduced = true
            end
          end
          local difference = 0
          if compareTo then
            local compareValue = GetTableValue(compareTo, dataLocation.currentValue, 0)
            difference = value - compareValue
          end
          local positionX = difference == 0 and 5 or 17
          if statLabel ~= nil then
            self.ScriptedEntityTweener:Set(statLabel, {x = positionX})
          else
            Debug.Log("Could not find statLabel entity")
          end
          self:ShowCompare(self[entityName], self[entityName .. "CompareArrow"], difference, scoreReduced)
        end
      end
    elseif 0 < itemTable.armorAttributes.encumbranceModifier or 0 < itemTable.armorAttributes.equipLoadModifier then
      self.ScriptedEntityTweener:Set(self.Properties.GearScoreText, {
        x = self.GEAR_SCORE_POSITIONX
      })
      local isEncumbrance = 0 < itemTable.armorAttributes.encumbranceModifier
      local modifierToDisplay = isEncumbrance and itemTable.armorAttributes.encumbranceModifier or itemTable.armorAttributes.equipLoadModifier
      local scoreReduced = false
      if isBroken and itemTable.hasBaseAttributes then
        local base = isEncumbrance and itemTable.baseAttributes.armorAttributes.encumbranceModifier or itemTable.baseAttributes.armorAttributes.equipLoadModifier
        if type(base) == "number" and 0 < base and modifierToDisplay < base then
          scoreReduced = true
        end
      end
      if isEncumbrance then
        modifierToDisplay = modifierToDisplay / 10
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryHeader, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryTextContainer, true)
      UiTextBus.Event.SetText(self.Properties.SecondaryText, LocalizeDecimalSeparators(string.format("+%.1f", modifierToDisplay)))
      UiTextBus.Event.SetTextWithFlags(self.Properties.SecondaryHeader, isEncumbrance and "@ui_encumbrance" or "@ui_equip_load", eUiTextSet_SetLocalized)
      local difference = 0
      if compareTo then
        local toCompareModifer = isEncumbrance and compareTo.armorAttributes.encumbranceModifier or compareTo.armorAttributes.equipLoadModifier
        if isEncumbrance then
          toCompareModifer = toCompareModifer / 10
        end
        difference = modifierToDisplay - toCompareModifer
      end
      local positionX = difference == 0 and 5 or 17
      self.ScriptedEntityTweener:Set(self.Properties.SecondaryHeader, {x = positionX})
      self:ShowCompare(self.SecondaryText, self.SecondaryTextCompareArrow, difference, scoreReduced)
      self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.STAT_LINE_SPACING
    end
  end
  self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.END_OF_SECTION_SPACING
  local numPerks = itemTable.perks and #itemTable.perks or 0
  UiElementBus.Event.SetIsEnabled(self.Properties.PerksContainer, 0 < numPerks)
  if 0 < numPerks then
    UiElementBus.Event.SetIsEnabled(self.Properties.PerksDivider, true)
    self.ScriptedEntityTweener:Set(self.Properties.PerksContainer, {
      y = self.TOTAL_HEIGHT
    })
    local isWeapon = itemTable.weaponAttributes ~= nil
    local firstEntityId, gemPerkEntityId, inherentPerkEntityId
    local attributes = {}
    for i = 1, numPerks do
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(itemTable.perks[i])
      if perkData.perkType == ePerkType_Inherent then
        local perkMultiplier = perkData:GetPerkMultiplier(itemTable.gearScore)
        for _, attributeData in ipairs(ItemCommon.AttributeDisplayOrder) do
          local statValue = perkData:GetAttributeBonus(attributeData.stat, itemTable.gearScoreRangeMod, perkMultiplier)
          if statValue ~= 0 then
            table.insert(attributes, {
              amount = statValue,
              attribute = attributeData.name
            })
          end
        end
      end
    end
    local additionalAttributeElements = math.max(#attributes - 1, 0)
    UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.PerksList, numPerks + additionalAttributeElements)
    local children = UiElementBus.Event.GetChildren(self.Properties.PerksList)
    for i = 1, #attributes do
      local entityId = children[i]
      local entityTable = self.registrar:GetEntityTable(entityId)
      entityTable:ClearPerkData()
      local isLastAttribute = i == #attributes
      self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + entityTable:SetAttributes(attributes[i], isBroken, true, isLastAttribute)
    end
    local currentChild = #attributes + 1
    for i = 1, numPerks do
      if currentChild > #children then
        break
      end
      local entityId = children[currentChild]
      local entityTable = self.registrar:GetEntityTable(entityId)
      entityTable:ClearPerkData()
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(itemTable.perks[i])
      if perkData.perkType ~= ePerkType_Inherent then
        local perkMultiplier = perkData:GetPerkMultiplier(itemTable.gearScore)
        self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + entityTable:SetPerkData(perkData, isWeapon, isBroken, true, false, perkMultiplier)
        if currentChild == #attributes + 1 then
          firstEntityId = entityId
        end
        currentChild = currentChild + 1
      end
      if perkData.perkType == ePerkType_Gem then
        gemPerkEntityId = entityId
      end
    end
    if firstEntityId and gemPerkEntityId and gemPerkEntityId ~= firstEntityId then
      UiElementBus.Event.Reparent(gemPerkEntityId, self.Properties.PerksList, firstEntityId)
      firstEntityId = gemPerkEntityId
    end
    self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + self.END_OF_SECTION_SPACING
  end
  return self.TOTAL_HEIGHT
end
function DynamicTooltip_ItemStats:SetTextColor(entity, color)
  UiTextBus.Event.SetColor(entity, color)
end
function DynamicTooltip_ItemStats:ShowCompare(text, arrow, difference, isBroken)
  local color = self.UIStyle.COLOR_COMPARE_EVEN
  local arrowScale = 1
  local arrowEnabled = false
  if isBroken then
    color = self.UIStyle.COLOR_COMPARE_WORSE
  end
  if difference < 0 then
    color = self.UIStyle.COLOR_COMPARE_WORSE
    arrowEnabled = true
    arrowScale = -1
  end
  if 0 < difference then
    color = self.UIStyle.COLOR_COMPARE_BETTER
    arrowEnabled = true
    arrowScale = 1
  end
  if text and text:IsValid() then
    UiTextBus.Event.SetColor(text, color)
  end
  if arrow and arrow:IsValid() then
    UiElementBus.Event.SetIsEnabled(arrow, arrowEnabled)
    if arrowEnabled then
      UiImageBus.Event.SetColor(arrow, color)
      self.ScriptedEntityTweener:Set(arrow, {scaleY = arrowScale})
    end
  end
end
return DynamicTooltip_ItemStats

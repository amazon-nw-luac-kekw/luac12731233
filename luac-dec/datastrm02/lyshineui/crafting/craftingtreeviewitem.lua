local CraftingTreeViewItem = {
  Properties = {
    Background = {
      default = EntityId(),
      order = 1
    },
    StateIcon = {
      default = EntityId(),
      order = 2
    },
    TypeIcon = {
      default = EntityId(),
      order = 3
    },
    EntryText = {
      default = EntityId(),
      order = 4
    },
    GearScoreText = {
      default = EntityId(),
      order = 5
    },
    Highlight = {
      default = EntityId(),
      order = 6
    },
    SelectedBg = {
      default = EntityId(),
      order = 7
    },
    RarityFrame = {
      default = EntityId(),
      order = 8
    },
    RarityBg = {
      default = EntityId(),
      order = 9
    },
    RarityGradient = {
      default = EntityId(),
      order = 10
    },
    TradeskillIcon = {
      default = EntityId(),
      order = 11
    },
    ObjectiveIcon = {
      default = EntityId(),
      order = 12
    },
    TradeskillTooltipSetter = {
      default = EntityId(),
      order = 13
    }
  },
  entryDepth = 0,
  DEPTH_STATUS = 0,
  DEPTH_FAMILY = 1,
  DEPTH_GROUP = 2,
  DEPTH_RECIPE = 3,
  SORT_BY_NAME = 0,
  SORT_BY_LEVEL = 1,
  SORT_BY_TIER = 2,
  SORT_BY_GEAR_SCORE = 3,
  SORT_BY_XP = 4,
  defaultEntryTextWidth = 360,
  typeIconPositionX = 0,
  expandedArrow = "lyshineui/images/icons/misc/dropdownArrowWhite.dds",
  collapsedArrow = "lyshineui/images/icons/misc/dropdownArrowWhiteRight.dds",
  hourglassIcon = "lyshineui/images/icons/misc/icon_hourglass.dds",
  scissorsIcon = "lyshineui/images/icons/misc/icon_scissors.dds",
  ITEM_RARITY_FRAME_PREFIX = "lyshineui/images/slices/itemlayout/itembgsquare",
  ITEM_RARITY_BG_PREFIX = "lyshineui/images/slices/itemlayout/itemraritybgsquare",
  mIconPathRoot = "lyShineui/images/icons/items/",
  ITEM_TYPE_WEAPON = "Weapon",
  ITEM_TYPE_AMMO = "Ammo",
  ITEM_TYPE_ARMOR = "Armor",
  ITEM_TYPE_BLUEPRINT = "Blueprint",
  ITEM_TYPE_CONSUMABLE = "Consumable",
  ITEM_TYPE_CURRENCY = "Currency",
  ITEM_TYPE_KIT = "Kit",
  ITEM_TYPE_PASSIVE_TOOL = "PassiveTool",
  ITEM_TYPE_RESOURCE = "Resource",
  ITEM_TYPE_LORE = "Lore",
  ITEM_TYPE_DYE = "Dye",
  ITEM_TYPE_HOUSING_ITEM = "HousingItem"
}
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local TradeSkillsCommon = RequireScript("LyShineUI._Common.TradeSkillsCommon")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftingTreeViewItem)
function CraftingTreeViewItem:OnInit()
  BaseElement.OnInit(self)
  self.Background:SetListItemStyle(self.Background.LIST_ITEM_STYLE_ZEBRA)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
end
function CraftingTreeViewItem:SetData(entryData)
  self.ScriptedEntityTweener:Set(self.Properties.Highlight, {opacity = 0})
  self.entryData = entryData
  self:SetExpandCallback(nil, nil)
  self:SetRecipeSelectCallback(nil, nil)
  local entryWidth = 360
  self.ScriptedEntityTweener:Set(self.Properties.EntryText, {
    w = self.defaultEntryTextWidth
  })
  SetTextStyle(self.Properties.EntryText, self.UIStyle.FONT_STYLE_CRAFTING_FILTER_HEADER)
  SetTextStyle(self.Properties.GearScoreText, self.UIStyle.FONT_STYLE_CRAFTING_FILTER_ENTRY)
  UiImageBus.Event.SetColor(self.Properties.StateIcon, self.UIStyle.COLOR_WHITE)
  if self.entryData.depth == self.DEPTH_STATUS then
    self.ScriptedEntityTweener:Set(self.Properties.StateIcon, {x = 15})
    self.ScriptedEntityTweener:Set(self.Properties.EntryText, {x = 30})
    UiElementBus.Event.SetIsEnabled(self.Properties.StateIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.EntryText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TypeIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreText, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.RarityFrame, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TradeskillIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedBg, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ObjectiveIcon, false)
    self:SetExpanded(self.entryData.expanded)
    UiTextBus.Event.SetTextWithFlags(self.Properties.EntryText, self.entryData.text, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.EntryText, self.entryData.locked and self.UIStyle.COLOR_GRAY_50 or self.UIStyle.COLOR_YELLOW)
  elseif self.entryData.depth == self.DEPTH_FAMILY then
    UiElementBus.Event.SetIsEnabled(self.Properties.TypeIcon, false)
    self.ScriptedEntityTweener:Set(self.Properties.StateIcon, {x = 36})
    self.typeIconPositionX = 42
    self.ScriptedEntityTweener:Set(self.Properties.EntryText, {x = 51})
    UiElementBus.Event.SetIsEnabled(self.Properties.StateIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.EntryText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreText, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.RarityFrame, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TradeskillIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedBg, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ObjectiveIcon, false)
    self:SetExpanded(self.entryData.expanded)
    local categoryData = CraftingCategoryDataManagerBus.Broadcast.GetCategoryData(self.entryData.text)
    if categoryData.displayText ~= "" then
      UiTextBus.Event.SetTextWithFlags(self.Properties.EntryText, categoryData.displayText, eUiTextSet_SetLocalized)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.EntryText, self.entryData.text, eUiTextSet_SetLocalized)
    end
    UiTextBus.Event.SetColor(self.Properties.EntryText, self.UIStyle.COLOR_YELLOW)
  elseif self.entryData.depth == self.DEPTH_GROUP then
    UiElementBus.Event.SetIsEnabled(self.Properties.TypeIcon, false)
    self.ScriptedEntityTweener:Set(self.Properties.StateIcon, {x = 59})
    self.typeIconPositionX = 66
    self.ScriptedEntityTweener:Set(self.Properties.EntryText, {x = 74})
    UiElementBus.Event.SetIsEnabled(self.Properties.StateIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.EntryText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreText, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.RarityFrame, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TradeskillIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedBg, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ObjectiveIcon, false)
    self:SetExpanded(self.entryData.expanded)
    local categoryData = CraftingCategoryDataManagerBus.Broadcast.GetCategoryData(self.entryData.text)
    if categoryData.displayText ~= "" then
      UiTextBus.Event.SetTextWithFlags(self.Properties.EntryText, categoryData.displayText, eUiTextSet_SetLocalized)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.EntryText, self.entryData.text, eUiTextSet_SetLocalized)
    end
    UiTextBus.Event.SetColor(self.Properties.EntryText, self.UIStyle.COLOR_YELLOW)
  elseif self.entryData.depth == self.DEPTH_RECIPE then
    SetTextStyle(self.Properties.EntryText, self.UIStyle.FONT_STYLE_CRAFTING_FILTER_ENTRY)
    local reqTradeskill = CraftingRequestBus.Broadcast.GetRecipeTradeskill(self.entryData.recipeData.id)
    local activeTradeskill = Math.CreateCrc32(tostring(reqTradeskill))
    local tradeSkillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(activeTradeskill)
    local reqRecipeLevel = CraftingRequestBus.Broadcast.GetRequiredRecipeLevel(self.entryData.recipeData.id)
    self.reqTradeskillLevel = CraftingRequestBus.Broadcast.GetTradeskillLevelRequiredForRecipeLevel(reqTradeskill, reqRecipeLevel)
    UiElementBus.Event.SetIsEnabled(self.Properties.TradeskillIcon, tradeSkillData ~= nil)
    if tradeSkillData then
      UiImageBus.Event.SetSpritePathname(self.Properties.TradeskillIcon, tradeSkillData.smallIcon)
      local skillText = GetLocalizedReplacementText("@ui_crating_tree_item_tradeskill_desc", {
        skillName = tradeSkillData.locName,
        skillLoc = "@cr_skill",
        required = tostring(self.reqTradeskillLevel)
      })
      self.TradeskillTooltipSetter:SetSimpleTooltip(skillText)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.EntryText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.RarityFrame, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedBg, self.entryData.isSelected)
    if self.entryData.isSelected then
      self.ScriptedEntityTweener:Play(self.Properties.SelectedBg, 0.1, {opacity = 1, ease = "QuadOut"})
    else
      self.ScriptedEntityTweener:Set(self.Properties.SelectedBg, {opacity = 0})
    end
    self:SetBgIndex(self.entryData.bgIndex)
    local isProcedural = RecipeDataManagerBus.Broadcast.IsRecipeProcedural(self.entryData.recipeData.id)
    local resultItemId
    if isProcedural then
      resultItemId = CraftingRequestBus.Broadcast.GetProceduralCraftingResult(self.entryData.recipeData.id, vector_Crc32())
    else
      resultItemId = Math.CreateCrc32(self.entryData.recipeData.resultItemId)
    end
    local itemData = ItemDataManagerBus.Broadcast.GetItemData(resultItemId)
    local imagePathIcon
    local itemDescriptor = ItemCommon:GetFullDescriptorFromId(resultItemId)
    local staticItem = StaticItemDataManager:GetItem(itemDescriptor.itemId)
    self.info = StaticItemDataManager:GetTooltipDisplayInfo(itemDescriptor, nil)
    if staticItem then
      self.itemType = staticItem.itemType
      self.iconPath = staticItem.iconPath or staticItem.icon
    end
    local imagePathFolder = self.mIconPathRoot
    if self.itemType == self.ITEM_TYPE_RESOURCE or self.itemType == self.ITEM_TYPE_AMMO or self.itemType == self.ITEM_TYPE_ARMOR or self.itemType == self.ITEM_TYPE_BLUEPRINT or self.itemType == self.ITEM_TYPE_DYE or self.itemType == self.ITEM_TYPE_LORE or self.itemType == self.ITEM_TYPE_WEAPON or self.itemType == self.ITEM_TYPE_CONSUMABLE or self.itemType == self.ITEM_TYPE_CURRENCY or self.itemType == self.ITEM_TYPE_HOUSING_ITEM or self.itemType == self.ITEM_TYPE_KIT or self.itemType == self.ITEM_TYPE_PASSIVE_TOOL then
      imagePathFolder = self.mIconPathRoot .. self.itemType .. "/"
      imagePathIcon = imagePathFolder .. self.iconPath .. ".dds"
    end
    if imagePathIcon ~= nil then
      UiElementBus.Event.SetIsEnabled(self.Properties.TypeIcon, true)
      UiImageBus.Event.SetSpritePathname(self.Properties.TypeIcon, imagePathIcon)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.TypeIcon, false)
    end
    local rarity = itemDescriptor:GetRarityLevel()
    UiImageBus.Event.SetSpritePathname(self.Properties.RarityFrame, self.ITEM_RARITY_FRAME_PREFIX .. tostring(rarity) .. ".dds")
    UiImageBus.Event.SetSpritePathname(self.Properties.RarityBg, self.ITEM_RARITY_BG_PREFIX .. tostring(rarity) .. ".dds")
    UiElementBus.Event.SetIsEnabled(self.Properties.RarityGradient, 0 < rarity and not self.entryData.isSelected)
    if 0 < rarity then
      local rarityColor = "COLOR_RARITY_LEVEL_" .. tostring(rarity)
      UiImageBus.Event.SetColor(self.Properties.RarityGradient, self.UIStyle[rarityColor])
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.StateIcon, self.entryData.hasCooldown)
    if self.entryData.hasCooldown then
      UiImageBus.Event.SetSpritePathname(self.Properties.StateIcon, self.hourglassIcon)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.ObjectiveIcon, self.entryData.isMissionItem)
    local stateIconPositionX, entryTextPositionX, entryTextWidth
    if self.entryData.locked then
      stateIconPositionX = 16
      entryTextPositionX = 76
      self.typeIconPositionX = 34
      entryTextWidth = 280
    else
      stateIconPositionX = 59
      entryTextPositionX = 118
      self.typeIconPositionX = 76
      entryTextWidth = 245
    end
    self.rarityFramePositionX = self.typeIconPositionX - 2
    self.ScriptedEntityTweener:Set(self.Properties.StateIcon, {x = stateIconPositionX})
    self.ScriptedEntityTweener:Set(self.Properties.TypeIcon, {
      x = self.typeIconPositionX
    })
    self.ScriptedEntityTweener:Set(self.Properties.RarityFrame, {
      x = self.rarityFramePositionX
    })
    self.ScriptedEntityTweener:Set(self.Properties.EntryText, {x = entryTextPositionX})
    self.ScriptedEntityTweener:Set(self.Properties.EntryText, {w = entryTextWidth})
    if self.width then
      local bgWidth = self.width - (self.typeIconPositionX - 2)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.Background, bgWidth)
    end
    local gearScoreText = ""
    if self.entryData.sortMethod == self.SORT_BY_LEVEL or self.entryData.sortMethod == self.SORT_BY_NAME then
      if self.reqTradeskillLevel then
        self.reqTradeskillLevel = math.max(self.reqTradeskillLevel, 0)
        gearScoreText = tostring(self.reqTradeskillLevel)
      end
    elseif self.entryData.sortMethod == self.SORT_BY_TIER then
      SetTextStyle(self.Properties.GearScoreText, self.UIStyle.FONT_STYLE_TOOLTIP_TIER_ITALIC)
      local romanString = GetRomanFromNumber(self.entryData.tier)
      gearScoreText = romanString
    elseif self.entryData.sortMethod == self.SORT_BY_GEAR_SCORE then
      if 0 < self.entryData.gearScoreOverride then
        gearScoreText = tostring(self.entryData.gearScoreOverride)
      else
        gearScoreText = tostring(self.entryData.minGearScore)
        if self.entryData.minGearScore ~= self.entryData.maxGearScore then
          gearScoreText = gearScoreText .. "+"
        end
      end
    elseif self.entryData.sortMethod == self.SORT_BY_XP then
      gearScoreText = "+" .. tostring(self.entryData.xp)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.GearScoreText, gearScoreText, eUiTextSet_SetLocalized)
    local displayName
    if isProcedural then
      displayName = self.entryData.recipeData.name
    else
      displayName = itemData.displayName
    end
    local quantityPerCraft = CraftingRequestBus.Broadcast.GetRecipeOutputQuantity(self.entryData.recipeData.id)
    if 1 < quantityPerCraft then
      displayName = displayName .. " " .. GetLocalizedReplacementText("@ui_quantitywithx", {quantity = quantityPerCraft})
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.EntryText, displayName, eUiTextSet_SetLocalized)
    local lockedForCooldown = false
    if self.entryData.hasCooldown then
      lockedForCooldown = 0 >= CraftingRequestBus.Broadcast.GetRemainingCooldownCount(self.entryData.recipeIdCrc)
    end
    local color
    if self.entryData.locked then
      color = self.UIStyle.COLOR_GRAY_50
    elseif self.entryData.hasIngredients and self.entryData.isRecipeKnown and not lockedForCooldown then
      color = self.UIStyle.COLOR_WHITE
    else
      color = self.UIStyle.COLOR_RED_MEDIUM
    end
    UiTextBus.Event.SetColor(self.Properties.EntryText, color)
    UiTextBus.Event.SetColor(self.Properties.GearScoreText, color)
    UiImageBus.Event.SetColor(self.Properties.StateIcon, color)
    UiImageBus.Event.SetColor(self.Properties.TradeskillIcon, color)
  end
end
function CraftingTreeViewItem:OnFocus()
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.15, {opacity = 0.1, ease = "QuadOut"})
  local newHover = true
  if self.craftingView then
    newHover = self.craftingView:GetLastHoveredItem() ~= self.entityId
  end
  if not self.entryData.isSelected and newHover then
    self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
  end
  if newHover and self.craftingView then
    self.craftingView:SetLastHoveredItem(self.entityId)
  end
end
function CraftingTreeViewItem:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.15, {
    opacity = 0,
    ease = "QuadIn",
    onComplete = function()
      if self.craftingView and self.craftingView:GetLastHoveredItem() == self.entityId then
        self.craftingView:SetLastHoveredItem(nil)
      end
    end
  })
end
function CraftingTreeViewItem:SetBackgroundEnabled(enabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.Background, enabled)
end
function CraftingTreeViewItem:OnClicked()
  if self.entryData.depth < self.DEPTH_RECIPE then
    if self.expandCallbackFunction ~= nil and self.expandCallbackTable ~= nil and type(self.expandCallbackFunction) == "function" then
      self.expandCallbackFunction(self.expandCallbackTable, self.entryData.id)
    end
  elseif self.entryData.depth == self.DEPTH_RECIPE and self.entryData.recipeData and not self.entryData.isSelected and self.selectCallbackFunction ~= nil and self.selectCallbackTable ~= nil and type(self.selectCallbackFunction) == "function" then
    self.selectCallbackFunction(self.selectCallbackTable, self.entryData.recipeData, self.entryData.recipeData.id)
    self.audioHelper:PlaySound(self.audioHelper.Accept)
  end
end
function CraftingTreeViewItem:SetExpanded(expanded)
  if self.entryData.depth < self.DEPTH_RECIPE then
    local expandedIcon = self.entryData.expanded and self.expandedArrow or self.collapsedArrow
    UiImageBus.Event.SetSpritePathname(self.Properties.StateIcon, expandedIcon)
  end
end
function CraftingTreeViewItem:SetBgIndex(index)
  self.Background:SetIndex(index)
  self.Background:SetZebraOpacity(0.5)
  self.Background:SetListItemStyle(self.Background.LIST_ITEM_STYLE_ZEBRA)
end
function CraftingTreeViewItem:ShowItemTooltip(entityTable)
  self:OnFocus()
  DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(self.info, self)
end
function CraftingTreeViewItem:HideItemTooltip(entityTable)
  self:OnUnfocus()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
function CraftingTreeViewItem:ShowTradeskillTooltip(entityTable)
  self:OnFocus()
  self.TradeskillTooltipSetter:OnTooltipSetterHoverStart()
end
function CraftingTreeViewItem:HideTradeskillTooltip(entityTable)
  self:OnUnfocus()
  self.TradeskillTooltipSetter:OnTooltipSetterHoverEnd()
end
function CraftingTreeViewItem:SetExpandCallback(callback, callingTable)
  self.expandCallbackFunction = callback
  self.expandCallbackTable = callingTable
end
function CraftingTreeViewItem:SetRecipeSelectCallback(callback, callingTable)
  self.selectCallbackFunction = callback
  self.selectCallbackTable = callingTable
end
function CraftingTreeViewItem:SetCraftingView(table)
  self.craftingView = table
end
return CraftingTreeViewItem

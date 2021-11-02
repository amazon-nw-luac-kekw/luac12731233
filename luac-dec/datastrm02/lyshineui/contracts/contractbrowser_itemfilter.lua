local ContractBrowser_ItemFilter = {
  Properties = {
    BreadcrumbContainer = {
      default = EntityId()
    },
    Breadcrumbs = {
      All = {
        default = EntityId()
      },
      Category = {
        default = EntityId()
      },
      Family = {
        default = EntityId()
      },
      Group = {
        default = EntityId()
      },
      Arrow = {
        default = EntityId()
      }
    },
    PrimaryFilterContainer = {
      default = EntityId()
    },
    SecondaryFilterContainer = {
      default = EntityId()
    },
    PrimaryFilterElement = {
      default = EntityId()
    },
    SecondaryFilterElement = {
      default = EntityId()
    },
    SubCategoryHeader = {
      default = EntityId()
    },
    SubCategoryListHolder = {
      default = EntityId()
    },
    SubCategoryListScrollBox = {
      default = EntityId()
    },
    OrderPopup = {
      default = EntityId()
    },
    ContractBrowser = {
      default = EntityId()
    }
  },
  categoryData = {},
  primaryFilterList = {},
  secondaryFilterList = {},
  filteredItemList = {},
  additionalPrimaryCategories = {},
  additionalSecondaryCategories = {},
  categoryDepths = {
    "All",
    "Category",
    "Family",
    "Group",
    "Tier"
  },
  currentDepth = 1,
  primaryCategoryIconPath = "LyShineUI\\Images\\Icons\\ItemTypes\\%s.dds",
  familyIconPath = "LyShineUI\\Images\\Icons\\Items\\Drawing\\%s.dds",
  groupIconPath = "LyShineUI\\Images\\contracts\\contracts_tier%s.dds",
  itemIconPath = "LyShineUI\\Images\\Icons\\Items_hires\\%s.dds",
  itemSmallIconPath = "LyShineUI\\Images\\Icons\\Items\\%s\\%s.dds",
  itemDescriptor = ItemDescriptor()
}
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_ItemFilter)
local isPreviewDebug = false
function ContractBrowser_ItemFilter:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  if not self.ContractBrowser or type(self.ContractBrowser) ~= table then
    local id = UiCanvasBus.Event.FindElementByName(self.canvasId, "ContractList")
    self.ContractBrowser = self.registrar:GetEntityTable(id)
  end
  self.placeSellButton = {
    text = "@ui_placesellorder",
    callbackFn = function()
      self:OpenOrderPopup(false)
    end,
    callbackSelf = self
  }
  self.placeBuyButton = {
    text = "@ui_placebuyorder",
    callbackFn = function()
      self:OpenOrderPopup(true)
    end,
    callbackSelf = self,
    ShouldBeEnabled = function()
      return contractsDataHandler:CanPlaceBuyOrder()
    end
  }
  self.additionalPrimaryCategories[0] = self.PrimaryFilterElement
  self.PrimaryFilterElement:SetImage("LyShineUI\\Images\\Icons\\ItemTypes\\itemType_all.dds")
  self.PrimaryFilterElement:SetCallback(self, self.SelectPrimaryCategory, nil)
  self.PrimaryFilterElement:SetVisible(true)
  self.OrderPopup:SetOnCloseCallback(self, self.ExecuteCallback)
  self.additionalSecondaryCategories[1] = self.SecondaryFilterElement
  self.CATEGORY_PRIORITY_DEF = {
    {},
    {
      Weapons = 1,
      Tools = 2,
      Ammos = 3,
      Apparel = 4,
      Resources = 5,
      Utilities = 6,
      Ammo = 7
    },
    {
      MeleeWeapons = 1,
      RangedWeapons = 2,
      Shields = 3,
      MagicalGaunlets = 4,
      Set1 = 1,
      Set2 = 2,
      Set3 = 3,
      Set4 = 4,
      Set5 = 5,
      Set6 = 6,
      Set7 = 7,
      Set8 = 8,
      Set9 = 9,
      Set10 = 10,
      Set11 = 11,
      Set12 = 12,
      RawResources = 1,
      RefinedResources = 2,
      NaturalResources = 3,
      SpecialResources = 4,
      Components = 5,
      Kills = 6,
      Minarals = 7,
      AlchemyResources = 8,
      FarmingResources = 9,
      Potion = 1,
      Tincture = 2,
      Coating = 3,
      CookingIngredients = 4,
      SiegeTools = 5,
      Seeds = 6,
      BasicCooking = 7
    },
    {
      ["1hSword"] = 1,
      ["1hRapier"] = 2,
      ["1hClub"] = 3,
      ["2hClub"] = 4,
      ["2hGreatAxe"] = 5,
      ["2hDemoHammer"] = 6,
      SpearA = 7,
      ["1hSwordC"] = 8,
      ["1hSwordD"] = 9
    },
    {
      ["1"] = 1,
      ["2"] = 2,
      ["3"] = 3,
      ["4"] = 4,
      ["5"] = 5
    }
  }
  self.Breadcrumbs.Category:SetTextStyle(self.UIStyle.FONT_STYLE_CONTRACTS_BACK)
  self.Breadcrumbs.Family:SetTextStyle(self.UIStyle.FONT_STYLE_CONTRACTS_BACK)
  self.Breadcrumbs.Group:SetTextStyle(self.UIStyle.FONT_STYLE_CONTRACTS_BACK)
  self.Breadcrumbs.Category:SetText("@ui_back", false, true, 30)
  self.Breadcrumbs.Family:SetText("@ui_back", false, true, 30)
  self.Breadcrumbs.Group:SetText("@ui_back", false, true, 30)
end
function ContractBrowser_ItemFilter:OnShutdown()
  local primaryElements = UiElementBus.Event.GetChildren(self.Properties.PrimaryFilterContainer)
  if primaryElements then
    for i = 2, #primaryElements do
      UiElementBus.Event.DestroyElement(primaryElements[i])
    end
  end
  local secondaryElements = UiElementBus.Event.GetChildren(self.Properties.SecondaryFilterContainer)
  if secondaryElements then
    for i = 2, #secondaryElements do
      UiElementBus.Event.DestroyElement(secondaryElements[i])
    end
  end
end
function ContractBrowser_ItemFilter:SetVisible(forceRefresh)
  if not self.hasInitialized or forceRefresh then
    self:UpdatePrimaryFilterCategories()
    self:SetFilter()
    self:SelectAllCategory()
  end
end
function ContractBrowser_ItemFilter:GetSortedCategoryList(originalList, sortDefinition)
  local sortedFilterList = {}
  for i = 1, #originalList do
    local categoryKey = originalList[i]
    local sortIndex = sortDefinition[categoryKey]
    sortIndex = sortIndex or GetMaxNum()
    table.insert(sortedFilterList, {sortIndex = sortIndex, originalListIndex = i})
  end
  table.sort(sortedFilterList, function(a, b)
    return a.sortIndex < b.sortIndex
  end)
  local toReturnList = {}
  for _, sortListData in ipairs(sortedFilterList) do
    table.insert(toReturnList, sortListData.originalListIndex)
  end
  return toReturnList
end
function ContractBrowser_ItemFilter:UpdatePrimaryFilterCategories()
  self.primaryFilterList = self:GetFilterList()
  local sortedFilterList = self:GetSortedCategoryList(self.primaryFilterList, self.CATEGORY_PRIORITY_DEF[2])
  for i = 1, #sortedFilterList do
    local categoryKey = self.primaryFilterList[sortedFilterList[i]]
    local categoryButtonTable = self.additionalPrimaryCategories[i]
    if categoryButtonTable == nil then
      categoryButtonTable = CloneUiElement(self.canvasId, self.registrar, self.Properties.PrimaryFilterElement, self.Properties.PrimaryFilterContainer, true)
      self.additionalPrimaryCategories[i] = categoryButtonTable
    end
    categoryButtonTable:SetImage(string.format(self.primaryCategoryIconPath, "itemType_" .. categoryKey))
    categoryButtonTable:SetCallback(self, self.SelectPrimaryCategory, categoryKey)
    categoryButtonTable:SetVisible(true)
  end
  for i = #self.primaryFilterList + 1, #self.additionalPrimaryCategories do
    self.additionalPrimaryCategories[i]:SetVisible(false)
  end
end
function ContractBrowser_ItemFilter:GetNumOrdersData(depth, categoryKey)
  local itemDepthToKey = {}
  itemDepthToKey[depth] = categoryKey
  local orderData = {
    itemCategory = self.categoryKey,
    itemFamily = self.familyKey,
    itemGroup = self.groupKey,
    itemTier = tonumber(self.tierKey),
    outpostIds = self.ContractBrowser:GetSelectedOutposts()
  }
  if self.currentDepth == 1 then
    orderData.itemCategory = itemDepthToKey[2]
  elseif self.currentDepth == 2 then
    orderData.itemFamily = itemDepthToKey[3]
  elseif self.currentDepth == 3 then
    orderData.itemGroup = itemDepthToKey[4]
  elseif self.currentDepth == 4 then
    orderData.itemTier = tonumber(itemDepthToKey[5])
  end
  if orderData.itemTier then
    local itemList = ItemDataManagerBus.Broadcast.GetFilteredItemList(orderData.itemCategory, orderData.itemFamily, orderData.itemGroup, itemDepthToKey[5])
    if itemList then
      orderData.itemList = itemList
    end
  end
  return orderData
end
function ContractBrowser_ItemFilter:UpdateSecondaryFilterCategories()
  local sortedFilterList = self.specificItem and {} or self:GetSortedCategoryList(self.secondaryFilterList, self.CATEGORY_PRIORITY_DEF[self.currentDepth + 1])
  local buttonIndex = 1
  self.hasImageOnList = false
  for i = 1, #sortedFilterList do
    local categoryKey = self.secondaryFilterList[sortedFilterList[i]]
    local numOrdersData = self:GetNumOrdersData(self.currentDepth + 1, categoryKey)
    local subItemCount = numOrdersData.itemList and #numOrdersData.itemList or 1
    for subItem = 1, subItemCount do
      local categoryButtonTable = self.additionalSecondaryCategories[buttonIndex]
      if categoryButtonTable == nil then
        categoryButtonTable = CloneUiElement(self.canvasId, self.registrar, self.Properties.SecondaryFilterElement, self.Properties.SecondaryFilterContainer, true)
        self.additionalSecondaryCategories[buttonIndex] = categoryButtonTable
      end
      buttonIndex = buttonIndex + 1
      local text, callbackFn, callbackParam, icon, tier, itemId
      if numOrdersData.itemList then
        local staticItemData = numOrdersData.itemList[subItem]
        text = staticItemData.displayName
        callbackFn = self.SetSpecificItem
        callbackParam = staticItemData
        icon = staticItemData.icon
        tier = staticItemData.tier
        itemId = staticItemData.id
      else
        text = self:GetFilterText(categoryKey, self.currentDepth)
        callbackFn = self.SelectSecondaryCategory
        callbackParam = categoryKey
        icon = nil
      end
      local itemData = self:GetFilterItem()
      local itemType = itemData.itemType
      local secondaryCategoryData = {
        text = text,
        imagePath = icon and string.format(self.itemSmallIconPath, itemType, icon) or nil,
        tier = tier,
        imageWidth = 0,
        numOrdersData = numOrdersData,
        subItem = subItem,
        filterId = callbackParam,
        callbackFn = callbackFn,
        callbackSelf = self,
        textStyle = self.UIStyle.FONT_STYLE_CONTRACTS_SUB_1,
        selectedOutposts = self.ContractBrowser:GetSelectedOutposts(),
        buttonHeight = 72,
        displayImage = false,
        isRectangle = false,
        itemType = itemType,
        hideItemBg = true,
        itemId = itemId,
        enabled = true
      }
      if secondaryCategoryData.imagePath ~= nil then
        self.hasImageOnList = true
      end
      if self.currentDepth == 1 then
        secondaryCategoryData.textStyle = self.UIStyle.FONT_STYLE_CONTRACTS_SUB_1
        secondaryCategoryData.imageWidth = 0
        secondaryCategoryData.buttonHeight = 72
        secondaryCategoryData.displayImage = false
        secondaryCategoryData.hideItemBg = true
      elseif self.currentDepth == 2 then
        secondaryCategoryData.textStyle = self.UIStyle.FONT_STYLE_CONTRACTS_SUB_2
        secondaryCategoryData.imageWidth = 50
        secondaryCategoryData.buttonHeight = 54
        secondaryCategoryData.displayImage = false
        secondaryCategoryData.hideItemBg = true
      elseif self.currentDepth == 3 then
        secondaryCategoryData.textStyle = self.UIStyle.FONT_STYLE_CONTRACTS_SUB_3
        secondaryCategoryData.imageWidth = 50
        secondaryCategoryData.buttonHeight = 62
        secondaryCategoryData.displayImage = false
        secondaryCategoryData.hideItemBg = true
      elseif self.currentDepth == 4 then
        secondaryCategoryData.textStyle = self.UIStyle.FONT_STYLE_CONTRACTS_SUB_4
        secondaryCategoryData.imageWidth = 50
        secondaryCategoryData.buttonHeight = 62
        secondaryCategoryData.displayImage = true
        secondaryCategoryData.hideItemBg = false
      elseif self.currentDepth == 5 then
        secondaryCategoryData.textStyle = self.UIStyle.FONT_STYLE_CONTRACTS_SUB_5
        secondaryCategoryData.imageWidth = 50
        secondaryCategoryData.buttonHeight = 54
        secondaryCategoryData.displayImage = true
        secondaryCategoryData.hideItemBg = false
      end
      categoryButtonTable:SetSubcategoryDisplay(secondaryCategoryData)
      categoryButtonTable:SetVisible(true)
      categoryButtonTable:OnUnfocus()
    end
  end
  if not self.hasImageOnList then
    local buttonIndex = 1
    for i = 1, #sortedFilterList do
      local categoryKey = self.secondaryFilterList[sortedFilterList[i]]
      local numOrdersData = self:GetNumOrdersData(self.currentDepth + 1, categoryKey)
      local subItemCount = numOrdersData.itemList and #numOrdersData.itemList or 1
      for subItem = 1, subItemCount do
        local categoryButtonTable = self.additionalSecondaryCategories[buttonIndex]
        buttonIndex = buttonIndex + 1
        categoryButtonTable:SetLabelPositionToDefault()
      end
    end
  end
  for i = buttonIndex, #self.additionalSecondaryCategories do
    self.additionalSecondaryCategories[i]:SetVisible(false)
  end
end
function ContractBrowser_ItemFilter:GetFilterImage(categoryKey, categoryDepth)
  local imagePath
  if self.specificItem then
    imagePath = string.format(self.itemIconPath, self.specificItem.icon)
  elseif self.categoryDepths[categoryDepth] == "Category" then
    imagePath = string.format(self.familyIconPath, categoryKey)
  elseif self.categoryDepths[categoryDepth] == "Family" then
    imagePath = string.format(self.familyIconPath, categoryKey)
  elseif self.categoryDepths[categoryDepth] == "Group" or self.categoryDepths[categoryDepth] == "Tier" then
    local items = ItemDataManagerBus.Broadcast.GetFilteredItemList(self.categoryKey, self.familyKey, self.groupKey, categoryKey)
    if items and items[1] then
      local itemData = items[1]
      imagePath = string.format(self.itemSmallIconPath, itemData.itemType, itemData.icon)
    else
      Log("Unknown item %s %s %s %s", tostring(self.categoryKey), tostring(self.familyKey), tostring(self.groupKey), tostring(categoryKey))
    end
  end
  if imagePath and not LyShineScriptBindRequestBus.Broadcast.IsFileExists(imagePath) then
    imagePath = nil
  end
  return imagePath
end
function ContractBrowser_ItemFilter:GetFilterText(categoryKey, categoryDepth)
  local text = categoryKey
  if self.categoryDepths[categoryDepth] == "All" or self.categoryDepths[categoryDepth] == "Category" then
    text = string.format("@CategoryData_%s", categoryKey)
  elseif self.categoryDepths[categoryDepth] == "Family" then
    text = string.format("@%s_GroupName", categoryKey)
  elseif self.categoryDepths[categoryDepth] == "Group" then
    if self.specificItem then
      text = self.specificItem.displayName
    else
      local items = ItemDataManagerBus.Broadcast.GetFilteredItemList(self.categoryKey, self.familyKey, self.groupKey, categoryKey)
      if items and items[1] then
        local itemData = items[1]
        text = itemData.displayName
      else
        Log("Unknown item %s %s %s %s", tostring(self.categoryKey), tostring(self.familyKey), tostring(self.groupKey), tostring(categoryKey))
      end
    end
  elseif self.categoryDepths[categoryDepth] == "Tier" then
  end
  return text
end
function ContractBrowser_ItemFilter:SetSpecificItem(itemData)
  self.lastScrollOffset = UiScrollBoxBus.Event.GetScrollOffset(self.Properties.SubCategoryListScrollBox)
  self.categoryKey = itemData.category
  self.familyKey = itemData.family
  self.groupKey = itemData.group
  self.tierKey = itemData.tier
  self.specificItem = itemData
  self:UpdatePrimaryCategories(self.categoryKey)
  self:UpdateBreadcrumbs()
  self:UpdateSubcategories()
  self:ExecuteCallback()
  self.ScriptedEntityTweener:Play(self.Properties.SubCategoryListHolder, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  local secondaryElements = UiElementBus.Event.GetChildren(self.Properties.SecondaryFilterContainer)
  if secondaryElements then
    for i = 1, #secondaryElements do
      local button = secondaryElements[i]
      local startDelay = 15 < i and 0.9 or i * 0.06
      self.ScriptedEntityTweener:Play(button, 0.2, {opacity = 0}, {
        opacity = 1,
        ease = "QuadOut",
        delay = startDelay
      })
    end
  end
end
function ContractBrowser_ItemFilter:SetFilter(categoryKey, familyKey, groupKey, tierKey, disallowSkipToItem, specificItem)
  self:UpdatePrimaryCategories(categoryKey)
  self.categoryKey = nil
  self.familyKey = nil
  self.groupKey = nil
  self.tierKey = nil
  self.currentDepth = 1
  if categoryKey and string.len(categoryKey) > 0 then
    self.categoryKey = categoryKey
    self.currentDepth = 2
    if familyKey and string.len(familyKey) > 0 then
      self.familyKey = familyKey
      self.currentDepth = 3
      if groupKey and string.len(groupKey) > 0 then
        self.groupKey = groupKey
        self.currentDepth = 4
        if tierKey then
          self.tierKey = tierKey
          self.currentDepth = 5
        end
      end
    end
  end
  self.specificItem = nil
  self:UpdateBreadcrumbs()
  self:UpdateSubcategories()
  self:ExecuteCallback()
  self.ScriptedEntityTweener:Play(self.Properties.SubCategoryListHolder, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  if specificItem then
    self:SetSpecificItem(specificItem)
    return
  end
  local secondaryElements = UiElementBus.Event.GetChildren(self.Properties.SecondaryFilterContainer)
  if secondaryElements then
    local numElements = #secondaryElements
    local startDelay = 0.06
    for i = 1, numElements do
      local button = secondaryElements[i]
      local startDelay = 15 < i and 0.9 or i * 0.06
      self.ScriptedEntityTweener:Play(button, 0.2, {opacity = 0}, {
        opacity = 1,
        ease = "QuadOut",
        delay = startDelay
      })
    end
    local visibleElements = 10
    local timeToShowElements = startDelay * math.min(numElements, visibleElements)
    if #self.filteredItemList == 1 and groupKey and not disallowSkipToItem then
      local itemData = secondaryElements[1].callbackInfo.filterId
      self:SetSpecificItem(itemData)
    end
    return timeToShowElements
  end
end
function ContractBrowser_ItemFilter:GetCurrentDepthKey()
  local depthToKey = {
    [1] = nil,
    [2] = self.categoryKey,
    [3] = self.familyKey,
    [4] = self.groupKey,
    [5] = self.tierKey
  }
  return depthToKey[self.currentDepth]
end
function ContractBrowser_ItemFilter:GetKeys()
  local keys = {
    [1] = "",
    [2] = 2 <= self.currentDepth and self.categoryKey or "",
    [3] = self.currentDepth >= 3 and self.familyKey or "",
    [4] = self.currentDepth >= 4 and self.groupKey or "",
    [5] = self.currentDepth >= 5 and self.tierKey or ""
  }
  return keys
end
function ContractBrowser_ItemFilter:UpdateBreadcrumbs()
  if self.familyKey then
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.BreadcrumbContainer, 60)
  else
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.BreadcrumbContainer, 0)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Category, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Family, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Group, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Arrow, false)
  if self.groupKey and self.tierKey then
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Group, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Family, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Category, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Arrow, true)
  elseif self.familyKey and self.groupKey then
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Group, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Family, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Category, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Arrow, true)
  elseif self.categoryKey and self.familyKey then
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Category, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Group, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Family, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Breadcrumbs.Arrow, true)
  end
end
function ContractBrowser_ItemFilter:OnBreadcrumbSelect(entity)
  local specificItem = self.specificItem
  local timeToSetupList = 0
  if entity == self.Breadcrumbs.All then
    timeToSetupList = self:SetFilter()
  elseif entity == self.Breadcrumbs.Category.entityId then
    timeToSetupList = self:SetFilter(self.categoryKey)
  elseif entity == self.Breadcrumbs.Family.entityId then
    timeToSetupList = self:SetFilter(self.categoryKey, self.familyKey)
  elseif entity == self.Breadcrumbs.Group.entityId then
    timeToSetupList = self:SetFilter(self.categoryKey, self.familyKey, self.groupKey, nil, true)
  end
  if specificItem and self.specificItem == nil then
    timingUtils:Delay(math.min(timeToSetupList, 0.1), self, function(self)
      UiScrollBoxBus.Event.SetScrollOffset(self.Properties.SubCategoryListScrollBox, self.lastScrollOffset)
    end)
  end
end
function ContractBrowser_ItemFilter:GetFilterItem()
  if self.specificItem then
    return self.specificItem
  end
  local itemList = ItemDataManagerBus.Broadcast.GetFilteredItemList(self.categoryKey, self.familyKey, self.groupKey, self.tierKey)
  if itemList and itemList[1] then
    return itemList[1]
  end
end
function ContractBrowser_ItemFilter:IsAtDeepestLevel()
  return not self.specificItem and self.filteredItemList and self.filteredItemList[1]
end
function ContractBrowser_ItemFilter:UpdatePrimaryCategories(newCategory)
  if newCategory == self.categoryKey then
    return
  end
  for i = 0, #self.additionalPrimaryCategories do
    if self.additionalPrimaryCategories[i].key == newCategory then
      UiRadioButtonGroupCommunicationBus.Event.RequestRadioButtonStateChange(self.Properties.PrimaryFilterContainer, self.additionalPrimaryCategories[i].entityId, true)
      break
    end
  end
end
function ContractBrowser_ItemFilter:UpdateSubcategories()
  if self.specificItem then
    self.currentDepth = 5
    self.filteredItemList = {
      self.specificItem
    }
  elseif self.tierKey and not isPreviewDebug then
    self.filteredItemList = ItemDataManagerBus.Broadcast.GetFilteredCategoryList(self.categoryKey, self.familyKey, self.groupKey, self.tierKey)
    self.secondaryFilterList = {}
  else
    self.filteredItemList = {}
    self.secondaryFilterList = self:GetFilterList(self.categoryKey, self.familyKey, self.groupKey)
  end
  self:UpdateSecondaryFilterCategories()
  local headerText = self.tierKey or self.groupKey or self.familyKey or self.categoryKey or "@ui_allItems"
  if headerText then
    local imageDepth = self.currentDepth < 5 and self.currentDepth - 1 or self.currentDepth
    local headerImagePath = self:GetFilterImage(headerText, imageDepth)
    local headerText = self:GetFilterText(headerText, self.currentDepth - 1)
    if self:IsAtDeepestLevel() then
      local itemData = self:GetFilterItem()
      local recipeData = {
        resultItemId = itemData.id,
        cb = self.SelectRecipeItem,
        cbTable = self
      }
      self.itemDescriptor.itemId = itemData.id
      local hasItem = false
      local inventoryData = contractsDataHandler:GetInventoryItemData(true, self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId"))
      for _, item in pairs(inventoryData) do
        if item.descriptor:MatchesDescriptor(self.itemDescriptor) then
          hasItem = true
          break
        end
      end
      self.placeSellButton.hasItem = hasItem
      self.SubCategoryHeader:SetHeaderData(headerImagePath, 170, headerText, self.placeSellButton, self.placeBuyButton, recipeData, true, itemData.description, self.ContractBrowser:GetSelectedOutposts(), itemData.id)
    elseif self.currentDepth == 3 then
      self.SubCategoryHeader:SetHeaderData("", 170, headerText, nil, nil, nil, false, nil, nil)
    elseif self.currentDepth == 4 then
      self.SubCategoryHeader:SetHeaderData("", 170, headerText, nil, nil, nil, false, nil, nil)
    else
      self.SubCategoryHeader:SetHeaderData(headerImagePath, 0, headerText, nil, nil, nil, false, nil, nil)
    end
    self.SubCategoryHeader:SetVisible(true)
  else
    self.SubCategoryHeader:SetVisible(false)
  end
end
function ContractBrowser_ItemFilter:SelectSecondaryCategory(secondaryKey)
  if self.groupKey then
    self:SetFilter(self.categoryKey, self.familyKey, self.groupKey, secondaryKey)
  elseif self.familyKey then
    self:SetFilter(self.categoryKey, self.familyKey, secondaryKey)
  elseif self.categoryKey then
    self:SetFilter(self.categoryKey, secondaryKey)
  else
    self:SetFilter(secondaryKey)
  end
end
function ContractBrowser_ItemFilter:SelectRecipeItem(itemId)
  local itemData = ItemDataManagerBus.Broadcast.GetItemData(itemId)
  self:SetSpecificItem(itemData)
end
function ContractBrowser_ItemFilter:SelectPrimaryCategory(categoryKey)
  self:SetFilter(categoryKey)
end
function ContractBrowser_ItemFilter:SetCallback(callerSelf, callerFn)
  self.callerSelf = callerSelf
  self.callerFn = callerFn
end
function ContractBrowser_ItemFilter:ExecuteCallback()
  if self.callerFn and self.callerSelf then
    self.callerFn(self.callerSelf)
  end
end
function ContractBrowser_ItemFilter:GetFilterList(categoryKey, familyKey, groupKey, tierKey)
  if isPreviewDebug then
    return self:DebugGetFilter(categoryKey, familyKey, groupKey, tierKey)
  else
    return ItemDataManagerBus.Broadcast.GetFilteredCategoryList(categoryKey, familyKey, groupKey, tierKey)
  end
end
function ContractBrowser_ItemFilter:OpenOrderPopup(isBuyOrder)
  local itemData = self:GetFilterItem()
  self.itemDescriptor.itemId = itemData.id
  self.OrderPopup:SetPostOrderPopupData(isBuyOrder, self.itemDescriptor)
end
function ContractBrowser_ItemFilter:SelectAllCategory()
  UiRadioButtonGroupCommunicationBus.Event.RequestRadioButtonStateChange(self.Properties.PrimaryFilterContainer, self.Properties.PrimaryFilterElement, true)
end
function ContractBrowser_ItemFilter:DebugGetFilter(categoryKey, familyKey, groupKey, tierKey)
  if not self.debugCategoryData then
    self.debugCategoryData = {
      Weapons = {
        Melee = {
          Sword = {Iron = 0, Steel = 1},
          Spear = {Iron = 0},
          GreatAxe = {Iron = 0, Oricalcum = 3}
        },
        Ranged = {
          Bow = {Iron = 0, Oricalcum = 3},
          Gun = {
            Iron = 0,
            Starmetal = 2,
            Oricalcum = 3
          }
        }
      },
      Apparel = {
        Soldier = {
          Helm = {
            Iron = 0,
            Steel = 1,
            Starmetal = 2,
            Oricalcum = 3
          },
          Breastplate = {
            Iron = 0,
            Steel = 1,
            Starmetal = 2,
            Oricalcum = 3
          },
          Boots = {
            Iron = 0,
            Steel = 1,
            Starmetal = 2,
            Oricalcum = 3
          }
        },
        Heavy = {
          Gauntlet = {Iron = 0, Oricalcum = 3}
        },
        Pathfinder = {
          Gauntlet = {Oricalcum = 3},
          Boots = {Iron = 0, Steel = 1}
        },
        Inquisitor = {
          Helm = {
            Iron = 0,
            Steel = 1,
            Starmetal = 2,
            Oricalcum = 3
          }
        }
      },
      Resources = {
        Refined = {
          Rawhide = {
            Iron = 0,
            Steel = 1,
            Starmetal = 2,
            Oricalcum = 3
          }
        },
        Raw = {
          Rawhide = {Iron = 0, Oricalcum = 3},
          Stone = {
            Iron = 0,
            Starmetal = 2,
            Oricalcum = 3
          },
          Ore = {Iron = 0, Steel = 1}
        }
      }
    }
  end
  local filterResult = {}
  local filterTable = {}
  if groupKey then
    filterTable = self.debugCategoryData[categoryKey][familyKey][groupKey]
  elseif familyKey then
    filterTable = self.debugCategoryData[categoryKey][familyKey]
  elseif categoryKey then
    filterTable = self.debugCategoryData[categoryKey]
  else
    filterTable = self.debugCategoryData
  end
  for i, v in pairs(filterTable) do
    table.insert(filterResult, i)
  end
  return filterResult
end
return ContractBrowser_ItemFilter

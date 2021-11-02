local BuildMode = {
  Properties = {
    LimitCurrentTextId = {
      default = EntityId()
    },
    LimitMaxTextId = {
      default = EntityId()
    },
    CountPanelId = {
      default = EntityId()
    },
    LimitColor = {
      default = Color(1, 0, 0, 1)
    },
    WarningColor = {
      default = Color(1, 0.5, 0, 1)
    },
    DisplayThreshold = {default = 0.9},
    StructureNavWheelContainer = {
      default = EntityId()
    },
    StructureNavWheelBg = {
      default = EntityId()
    },
    StructureNavWheel = {
      default = EntityId()
    },
    StructureNavWheelScrollBox = {
      default = EntityId()
    },
    LeftPanel = {
      default = EntityId()
    },
    StructureInfoPanel = {
      Name = {
        default = EntityId()
      },
      Tier = {
        default = EntityId()
      },
      Icon = {
        default = EntityId()
      },
      Description = {
        default = EntityId()
      },
      TaxValue = {
        default = EntityId()
      },
      Ingredients = {
        default = {
          EntityId(),
          EntityId(),
          EntityId(),
          EntityId()
        }
      },
      RecipeContainer = {
        default = EntityId()
      },
      ContainerToClone = {
        default = EntityId()
      },
      ItemLayoutToClone = {
        default = EntityId()
      },
      RequiredResources = {
        default = {
          EntityId(),
          EntityId()
        }
      },
      Container = {
        default = EntityId()
      },
      BuildRequirementContainer = {
        default = EntityId()
      },
      Reason1 = {
        default = EntityId()
      },
      Reason2 = {
        default = EntityId()
      }
    },
    TopNavBar = {
      default = EntityId()
    },
    TopNavBg = {
      default = EntityId()
    },
    BottomNavBar = {
      default = EntityId()
    },
    BottomNavBg = {
      default = EntityId()
    },
    BackButton = {
      default = EntityId()
    },
    TextTerritoryTax = {
      default = EntityId()
    },
    TextTerritoryTaxValue = {
      default = EntityId()
    },
    TextSnapGridHold = {
      default = EntityId()
    },
    TextSnapGridDesc = {
      default = EntityId()
    },
    SnapGridHint = {
      default = EntityId()
    },
    RotateShiftHint = {
      default = EntityId()
    },
    TextRotateDesc = {
      default = EntityId()
    },
    BuildingLocationStatusContainer = {
      default = EntityId()
    },
    BuildingLocationStatusBg = {
      default = EntityId()
    },
    TextBuildingLocationStatus = {
      default = EntityId()
    },
    CategoryContainer = {
      default = EntityId()
    },
    CategoryContainerBG = {
      default = EntityId()
    },
    CategoryButtonToClone = {
      default = EntityId()
    },
    ItemHeaderToClone = {
      default = EntityId()
    },
    ItemToClone = {
      default = EntityId()
    },
    ScrollWheelIcon = {
      default = EntityId()
    },
    CategoryHintContainer = {
      default = EntityId()
    },
    CategoryHint = {
      default = EntityId()
    }
  },
  SWITCH_WAIT_TIME = 0.1,
  categories = {},
  categoryButtons = {},
  currentCategory = 1,
  ctrlPressed = false,
  headers = {},
  scrollWheelIconHeight = 0,
  categoryPadding = 5,
  cryActionHandlers = {},
  recipes = {},
  currentRecipeIndex = 0,
  structureCount = 0,
  structureLimit = 0,
  containers = {},
  structureRecipes = {},
  defaultHeight = 633,
  size = 93,
  isReducedUi = false,
  isFtue = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(BuildMode)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(BuildMode)
function BuildMode:OnInit()
  BaseScreen.OnInit(self)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  self.disableGridKey = "disable_grid"
  self.enableGridKey = "enable_grid"
  self.actionMapActivators = {
    self.disableGridKey,
    self.enableGridKey,
    "switch_buildable_up",
    "switch_buildable_dn",
    "ui_lshift_down",
    "ui_lshift_up",
    "ui_lctrl"
  }
  UiImageBus.Event.SetAlpha(self.Properties.TopNavBg, self.UIStyle.BACKGROUND_ALPHA)
  UiImageBus.Event.SetAlpha(self.Properties.BottomNavBg, self.UIStyle.BACKGROUND_ALPHA)
  UiImageBus.Event.SetAlpha(self.Properties.BuildingLocationStatusBg, self.UIStyle.BACKGROUND_ALPHA)
  self:BusConnect(CryActionNotificationsBus, "toggleCraftingMode")
  self.BuildingLocationStatus = {
    VALID_LOCATION = eBuildingLocationStatus_VALID_LOCATION,
    INVALID_LOCATION = eBuildingLocationStatus_INVALID_LOCATION,
    INVALID_IN_WATER = eBuildingLocationStatus_INVALID_IN_WATER,
    INVALID_HAS_OBSTRUCTION = eBuildingLocationStatus_INVALID_HAS_OBSTRUCTION,
    INVALID_BAD_TERRAIN = eBuildingLocationStatus_INVALID_BAD_TERRAIN,
    INVALID_NOT_IN_SOCKET = eBuildingLocationStatus_INVALID_NOT_IN_SOCKET,
    INVALID_BLUEPRINT_NOT_KNOWN = eBuildingLocationStatus_INVALID_BLUEPRINT_NOT_KNOWN,
    INVALID_NOT_IN_CLAIMED_TERRITORY = eBuildingLocationStatus_INVALID_NOT_IN_CLAIMED_TERRITORY,
    INVALID_TERRITORY_NOT_MATCHING_GUILD = eBuildingLocationStatus_INVALID_TERRITORY_NOT_MATCHING_GUILD,
    INVALID_SECURITY_CONCERN = eBuildingLocationStatus_INVALID_SECURITY_CONCERN,
    INVALID_STRUCTURE_LIMIT_REACHED = eBuildingLocationStatus_INVALID_STRUCTURE_LIMIT_REACHED,
    INVALID_DEPLOYABLE_LIMIT_REACHED = eBuildingLocationStatus_INVALID_DEPLOYABLE_LIMIT_REACHED,
    INVALID_NOT_ENOUGH_PRIVILEGES = eBuildingLocationStatus_INVALID_NOT_ENOUGH_PRIVILEGES,
    INVALID_LOS_FAILED = eBuildingLocationStatus_INVALID_LOS_FAILED,
    INVALID_CAMPING_RESTRICTED = eBuildingLocationStatus_INVALID_CAMPING_RESTRICTED,
    INVALID_NOT_ENOUGH_PRIVILEGES_PLANTSEED = eBuildingLocationStatus_INVALID_NOT_ENOUGH_PRIVILEGES_PLANTSEED,
    INVALID_WAR_ATTACKERS_RESTRICTED = eBuildingLocationStatus_INVALID_WAR_ATTACKERS_RESTRICTED,
    INVALID_OUTSIDE_OF_WAR = eBuildingLocationStatus_INVALID_OUTSIDE_OF_WAR,
    INVALID_WAR_ATTACKERS_ONLY = eBuildingLocationStatus_INVALID_WAR_ATTACKERS_ONLY,
    INVALID_WAR_DEFENDERS_ONLY = eBuildingLocationStatus_INVALID_WAR_DEFENDERS_ONLY,
    INVALID_LOCATION_OUT_OF_WORLD_BOUNDS = eBuildingLocationStatus_INVALID_LOCATION_OUT_OF_WORLD_BOUNDS
  }
  self.categories = {}
  self:AddCategory({
    categoryName = "Wall",
    displayName = "@ui_buildmode_walls"
  })
  self:AddCategory({
    categoryName = "Crafting",
    displayName = "@ui_buildmode_crafting"
  })
  self:AddCategory({
    categoryName = "Refining",
    displayName = "@ui_buildmode_refining"
  })
  self.dataLayer:RegisterOpenEvent("BuildMode", self.canvasId)
  self.inBuildMode = false
  self.FONT_STYLE_BUILDMODEMENU_HEADER = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = self.UIStyle.FONT_SIZE_NAME,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  SetTextStyle(self.TextTerritoryTax, self.FONT_STYLE_BUILDMODEMENU_HEADER)
  UiTextBus.Event.SetTextWithFlags(self.TextTerritoryTax, "@ui_buildmode_territorytax", eUiTextSet_SetLocalized)
  self.FONT_STYLE_BUILDMODEMENU_VALUES = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = self.UIStyle.FONT_SIZE_NAME,
    fontColor = self.UIStyle.COLOR_YELLOW
  }
  SetTextStyle(self.TextTerritoryTaxValue, self.FONT_STYLE_BUILDMODEMENU_VALUES)
  self.FONT_STYLE_BUILDMODE_LOCATIONSTATUS = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = self.UIStyle.FONT_SIZE_BUILDMODE_REASON,
    fontColor = self.UIStyle.COLOR_BUILDMODE_RED
  }
  SetTextStyle(self.TextBuildingLocationStatus, self.FONT_STYLE_BUILDMODE_LOCATIONSTATUS)
  self.BackButton:SetText("@ui_back")
  self.BackButton:SetHint("toggleMenuComponent", true)
  self.BackButton:SetCallback("OnBackButtonClicked", self)
  self.CategoryHint:SetKeybindMapping("ui_lctrl")
  self.FONT_STYLE_BUILDMODE_NAVBARHINTS = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = self.UIStyle.FONT_SIZE_NAME,
    fontColor = self.UIStyle.COLOR_TAN
  }
  SetTextStyle(self.TextSnapGridHold, self.FONT_STYLE_BUILDMODE_NAVBARHINTS)
  UiTextBus.Event.SetTextWithFlags(self.TextSnapGridHold, "@ui_hold_text", eUiTextSet_SetLocalized)
  self.SnapGridHint:SetKeybindMapping("disable_grid")
  SetTextStyle(self.TextSnapGridDesc, self.FONT_STYLE_BUILDMODE_NAVBARHINTS)
  UiTextBus.Event.SetTextWithFlags(self.TextSnapGridDesc, "@ui_buildmode_snapHint", eUiTextSet_SetLocalized)
  self.RotateShiftHint:SetText("Shift")
  SetTextStyle(self.TextRotateDesc, self.FONT_STYLE_BUILDMODE_NAVBARHINTS)
  UiTextBus.Event.SetTextWithFlags(self.TextRotateDesc, "@ui_buildmode_rotateHint", eUiTextSet_SetLocalized)
  self.recipeDataList = {}
  local recipeIds = RecipeDataManagerBus.Broadcast.GetCraftingRecipesForTradeskill("Building")
  for i = 1, #recipeIds do
    local recipeData = RecipeDataManagerBus.Broadcast.GetCraftingRecipeData(recipeIds[i])
    if recipeData.listedByDefault and recipeData.itemTier ~= 0 then
      local category = recipeData.category
      if self.recipeDataList[category] == nil then
        self.recipeDataList[category] = {}
        local categoryData = CraftingCategoryDataManagerBus.Broadcast.GetCategoryData(category)
        self:AddCategory({
          categoryName = category,
          displayName = categoryData.displayText
        })
      end
      table.insert(self.recipeDataList[category], recipeData)
    end
  end
  local compare = function(first, second)
    if first.itemTier ~= second.itemTier then
      return first.itemTier < second.itemTier
    else
      return first.name < second.name
    end
  end
  for category, list in pairs(self.recipeDataList) do
    table.sort(list, compare)
  end
  local height = UiTransform2dBus.Event.GetLocalHeight(self.CategoryContainer)
  local itemheight = UiTransform2dBus.Event.GetLocalHeight(self.CategoryButtonToClone.entityId)
  for i = 1, #self.categories do
    local entity = self:CloneElement(self.CategoryButtonToClone.entityId, self.CategoryContainer, true)
    entity:SetText(self.categories[i].displayName, true)
    table.insert(self.categoryButtons, entity)
  end
  local totalHeight = #self.categoryButtons * (itemheight + self.categoryPadding)
  local startYPos = -math.floor(totalHeight * 0.5)
  for i = 1, #self.categoryButtons do
    UiTransformBus.Event.SetLocalPosition(self.categoryButtons[i].entityId, Vector2(0, startYPos + (itemheight + self.categoryPadding) * (i - 1)))
  end
  self.scrollWheelIconHeight = UiTransform2dBus.Event.GetLocalHeight(self.ScrollWheelIcon)
  self.defaultHeight = UiTransform2dBus.Event.GetLocalHeight(self.StructureInfoPanel.Container)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.BuilderEntityId", function(self, data)
    self.builderId = data
    self:TryRegisterBuildModeObservers()
  end)
  UiElementBus.Event.SetIsEnabled(self.StructureInfoPanel.Container, false)
  UiElementBus.Event.SetIsEnabled(self.LeftPanel, false)
end
function BuildMode:TryRegisterBuildModeObservers()
  if not self.observersRegistered and self.builderId then
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
      self.inventoryId = data
    end)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.BuildMode.BlueprintId", self.OnBlueprintIdChanged)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableBuildModeMenu", self.OnEnableBuildModeMenuChanged)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Id", self.OnPlayerGuildChanged)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.GuildId", self.OnTerritoryOwnerChanged)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.PlacedStructureCount", self.OnPlacedStructureCountChanged)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.StructureLimit", self.OnStructureLimitChanged)
    self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.BuildMode.BuildingLocationStatus", function(self, statusData)
      if statusData ~= self.statusData then
        self:OnBuildingLocationStatusChanged()
        self.statusData = statusData
      end
    end)
    self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.BuildMode.UseReducedUi", self.OnUpdateDisplayMode)
    self.observersRegistered = true
  end
end
function BuildMode:OnUpdateDisplayMode(useReducedUi)
  if useReducedUi == nil or useReducedUi == true then
    UiElementBus.Event.SetIsEnabled(self.TopNavBar, false)
    UiElementBus.Event.SetIsEnabled(self.StructureInfoPanel.Container, false)
    UiElementBus.Event.SetIsEnabled(self.LeftPanel, false)
    table.insert(self.cryActionHandlers, self:BusConnect(CryActionNotificationsBus, self.disableGridKey))
    table.insert(self.cryActionHandlers, self:BusConnect(CryActionNotificationsBus, self.enableGridKey))
    self.isReducedUi = true
  else
    UiElementBus.Event.SetIsEnabled(self.TopNavBar, true)
    UiElementBus.Event.SetIsEnabled(self.StructureInfoPanel.Container, true)
    UiElementBus.Event.SetIsEnabled(self.LeftPanel, true)
    if #self.cryActionHandlers == 0 then
      for _, v in ipairs(self.actionMapActivators) do
        table.insert(self.cryActionHandlers, self:BusConnect(CryActionNotificationsBus, v))
      end
    end
    self.isReducedUi = false
  end
end
function BuildMode:AddCategory(category)
  for i = 1, #self.categories do
    if self.categories[i].categoryName == category.categoryName then
      return
    end
  end
  table.insert(self.categories, category)
end
function BuildMode:OnTick(deltaTime, timePoint)
  self.waitTime = self.waitTime + deltaTime
  if self.waitTime >= self.SWITCH_WAIT_TIME then
    BuilderRequestBus.Event.RequestUseBlueprint(self.builderId, self.currentBlueprintId)
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function BuildMode:OnBackButtonClicked()
  LyShineManagerBus.Broadcast.ExitState(3406343509)
end
function BuildMode:OnPlacedStructureCountChanged(data)
  self.structureCount = 0
  if data then
    self.structureCount = data
  end
  self:UpdateStructureCount()
end
function BuildMode:OnStructureLimitChanged(data)
  self.structureLimit = 0
  if data then
    self.structureLimit = data
  end
  self:UpdateStructureCount()
end
function BuildMode:ReloadRecipes()
  if self.categoryType == nil then
    return
  end
  local currentTier = 0
  local oldCount = #self.recipes
  local newCount = #self.recipeDataList[self.categoryType]
  if oldCount < newCount then
    for i = 1, oldCount do
      if currentTier ~= self.recipeDataList[self.categoryType][i].itemTier then
        currentTier = self.recipeDataList[self.categoryType][i].itemTier
        self:AddHeader(currentTier, self.recipes[i].entityId)
      end
      self.recipes[i]:SetData(self.recipeDataList[self.categoryType][i], self.StructureNavWheel)
    end
    for i = oldCount + 1, newCount do
      local entity = self:CloneElement(self.ItemToClone.entityId, self.StructureNavWheel, true)
      self:OnRecipeSpawned(entity, self.recipeDataList[self.categoryType][i])
      if currentTier ~= self.recipeDataList[self.categoryType][i].itemTier then
        currentTier = self.recipeDataList[self.categoryType][i].itemTier
        self:AddHeader(currentTier, entity.entityId)
      end
    end
  else
    for i = 1, newCount do
      if currentTier ~= self.recipeDataList[self.categoryType][i].itemTier then
        currentTier = self.recipeDataList[self.categoryType][i].itemTier
        self:AddHeader(currentTier, self.recipes[i].entityId)
      end
      self.recipes[i]:SetData(self.recipeDataList[self.categoryType][i], self.StructureNavWheel)
    end
    for i = newCount + 1, oldCount do
      UiElementBus.Event.DestroyElement(self.recipes[i].entityId)
      self.recipes[i] = nil
    end
    if self.inBuildMode then
      self:ScrollToCurrentBlueprint()
    end
  end
  self:RemoveExtraHeaders()
  UiCanvasBus.Event.RecomputeChangedLayouts(self.canvasId)
end
function BuildMode:AddHeader(tier, entityAfter)
  if self.headers[tier] ~= nil then
    UiElementBus.Event.Reparent(self.headers[tier], self.StructureNavWheel, entityAfter)
  else
    local entity = self:CloneElement(self.ItemHeaderToClone, self.StructureNavWheel, true)
    UiElementBus.Event.Reparent(entity, self.StructureNavWheel, entityAfter)
    self.headers[tier] = entity
  end
  local textbox = UiElementBus.Event.FindChildByName(self.headers[tier], "HeaderText")
  local text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_structureinfo_tier", tier)
  UiTextBus.Event.SetText(textbox, text)
end
function BuildMode:RemoveExtraHeaders()
  for i = self.recipes[1].data.itemTier - 1, 1, -1 do
    if self.headers[i] then
      UiElementBus.Event.DestroyElement(self.headers[i])
      self.headers[i] = nil
    end
  end
  for i = self.recipes[#self.recipes].data.itemTier + 1, #self.headers do
    if self.headers[i] then
      UiElementBus.Event.DestroyElement(self.headers[i])
      self.headers[i] = nil
    end
  end
end
function BuildMode:OnRecipeSpawned(entity, data)
  entity:SetData(data, self.StructureNavWheel)
  table.insert(self.recipes, entity)
  if #self.recipes == #self.recipeDataList[self.categoryType] then
    self:ScrollToCurrentBlueprint()
  end
end
function BuildMode:UpdateStructureCount()
  UiTextBus.Event.SetText(self.Properties.LimitCurrentTextId, self.structureCount)
  UiTextBus.Event.SetText(self.Properties.LimitMaxTextId, "/ " .. tostring(self.structureLimit))
  local percentage = 0
  if self.structureLimit > 0 then
    percentage = self.structureCount / self.structureLimit
  end
  if self.structureCount >= self.structureLimit then
    UiTextBus.Event.SetColor(self.Properties.LimitCurrentTextId, self.Properties.LimitColor)
  elseif percentage >= self.DisplayThreshold then
    UiTextBus.Event.SetColor(self.Properties.LimitCurrentTextId, self.Properties.WarningColor)
  else
    UiTextBus.Event.SetColor(self.Properties.LimitCurrentTextId, self.UIStyle.COLOR_WHITE)
  end
end
function BuildMode:OnTransitionIn(stateName, levelName)
  self.inBuildMode = true
  UiElementBus.Event.SetIsEnabled(self.BuildingLocationStatusContainer, false)
  self.audioHelper:PlaySound(self.audioHelper.OnBuildModeOpen)
end
function BuildMode:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  self.inBuildMode = false
  self.shiftPressed = false
  self.ctrlPressed = false
  self.audioHelper:PlaySound(self.audioHelper.OnHide)
  UiElementBus.Event.SetIsEnabled(self.StructureInfoPanel.Container, false)
  UiElementBus.Event.SetIsEnabled(self.LeftPanel, false)
  BuilderRequestBus.Event.RequestCancelPlacingStructure(self.builderId)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  for i = 1, #self.cryActionHandlers do
    self:BusDisconnect(self.cryActionHandlers[i])
  end
  ClearTable(self.cryActionHandlers)
  self.audioHelper:PlaySound(self.audioHelper.OnBuildModeClose)
  if self.tickBusHandler ~= nil then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function BuildMode:OnCryAction(actionName, value)
  if self.inBuildMode then
    if actionName == "ui_lshift_down" then
      self.shiftPressed = true
    elseif actionName == "ui_lshift_up" then
      self.shiftPressed = false
    elseif actionName == "ui_lctrl" then
      self.ctrlPressed = 0 < value
    end
    if actionName == "disable_grid" then
      BuilderRequestBus.Event.EnablePlacementGrid(self.builderId, false)
    elseif actionName == "enable_grid" then
      BuilderRequestBus.Event.EnablePlacementGrid(self.builderId, true)
    elseif actionName == "toggleCraftingMode" and self.isBuildModeMenuEnabled then
      LyShineManagerBus.Broadcast.ExitState(3406343509)
      if self.isReducedUi then
        self:CheckOpenBuildMode()
      end
      return
    end
    if self.isBuildModeMenuEnabled and self.isPlacingBlueprint then
      if actionName == "switch_buildable_up" and not self.shiftPressed then
        if self.ctrlPressed then
          self:SetCategoryIndex(self.currentCategory - 1)
          self:ReloadRecipes()
        else
          self:SelectPrevStructure()
        end
      elseif actionName == "switch_buildable_dn" and not self.shiftPressed then
        if self.ctrlPressed then
          self:SetCategoryIndex(self.currentCategory + 1)
          self:ReloadRecipes()
        else
          self:SelectNextStructure()
        end
      end
    end
  elseif actionName == "toggleCraftingMode" and self.isBuildModeMenuEnabled then
    self:CheckOpenBuildMode()
  end
end
function BuildMode:CheckOpenBuildMode()
  if self.isFtue then
    return
  end
  if VitalsComponentRequestBus.Event.IsDeathsDoor(self.builderId) then
    return
  end
  if self.dataLayer:GetDataFromNode("Hud.Housing.IsWithinAPlot") then
    return
  end
  self:CheckPermissionStatus()
  if self.bCanOpen or LyShineScriptBindRequestBus.Broadcast.IsEditor() then
    if self.currentBlueprintId == nil or self.currentBlueprintId == 0 then
      BuilderRequestBus.Event.RequestUseBlueprint(self.builderId, 979463542)
    else
      BuilderRequestBus.Event.RequestUseBlueprint(self.builderId, self.currentBlueprintId)
    end
  else
    local notificationData = NotificationData()
    notificationData.contextId = self.entityId
    notificationData.type = "Minor"
    if self.buildReason == self.BuildingLocationStatus.INVALID_IN_WATER then
      notificationData.text = "@ui_buildmode_error_in_water"
    else
      notificationData.text = "@ui_buildmode_planningmode_unavailable"
    end
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function BuildMode:SelectPrevStructure()
  if self.currentRecipeIndex < 1 then
    return
  end
  if self.currentRecipeIndex == 1 then
    self:SetCategoryIndex(self.currentCategory - 1)
    self:ReloadRecipes()
    self:SetCurrentRecipe(#self.recipes)
    return
  end
  local newIndex = self.currentRecipeIndex - 1
  if newIndex > #self.recipes then
    Log("BuildMode:SelectPrevStructure - newIndex is " .. newIndex .. " which is somehow larger than our self.recipes count... this shouldn't ever happen")
    return
  end
  self:SetCurrentRecipe(newIndex)
end
function BuildMode:SelectNextStructure()
  if self.currentRecipeIndex > #self.recipes then
    return
  end
  if self.currentRecipeIndex == #self.recipes then
    self:SetCategoryIndex(self.currentCategory + 1)
    self:ReloadRecipes()
    self:SetCurrentRecipe(1)
    return
  end
  local newIndex = self.currentRecipeIndex + 1
  if newIndex < 1 then
    Log("BuildMode:SelectNextStructure - newIndex is " .. newIndex .. " which is somehow less than 1... this shouldn't ever happen")
    return
  end
  self:SetCurrentRecipe(newIndex)
end
function BuildMode:SetCurrentRecipe(newIndex)
  self.currentRecipeIndex = newIndex
  local recipe = self.recipes[newIndex]
  if recipe and recipe.data then
    self.currentBlueprintId = Math.CreateCrc32(recipe.data.resultItemId)
    self.blueprintTier = recipe.data.itemTier
    local listHeight = UiTransform2dBus.Event.GetLocalHeight(self.StructureNavWheelScrollBox)
    UiRadioButtonGroupCommunicationBus.Event.RequestRadioButtonStateChange(self.StructureNavWheel, recipe.entityId, true)
    local offsets = UiTransform2dBus.Event.GetOffsets(recipe.entityId)
    local height = offsets.bottom - offsets.top
    local posY = (newIndex - 1) * height
    UiScrollBoxBus.Event.SetScrollOffset(self.StructureNavWheelScrollBox, Vector2(0, -posY + listHeight * 0.5 - height * 0.5))
    local itempos = UiTransformBus.Event.GetViewportPosition(recipe.entityId)
    local scrollwheelpos = UiTransformBus.Event.GetViewportPosition(self.ScrollWheelIcon)
    local itemheight = UiTransform2dBus.Event.GetLocalHeight(recipe.entityId)
    UiTransformBus.Event.SetViewportPosition(self.ScrollWheelIcon, Vector2(scrollwheelpos.x, itempos.y + itemheight * 0.5 - self.scrollWheelIconHeight * 0.5))
    self:UpdateStructureInfo(recipe.data)
    if self.tickBusHandler == nil then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
    self.waitTime = 0
  end
end
function BuildMode:UpdateStructureInfo(data)
  UiTextBus.Event.SetTextWithFlags(self.StructureInfoPanel.Name, data.name, eUiTextSet_SetLocalized)
  local itemId = Math.CreateCrc32(data.resultItemId)
  local text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_structureinfo_tier", data.itemTier)
  UiTextBus.Event.SetText(self.StructureInfoPanel.Tier, text)
  local blueprintImage = ItemDataManagerBus.Broadcast.GetIconPath(itemId)
  UiImageBus.Event.SetSpritePathname(self.StructureInfoPanel.Icon, "LyShineUI/Images/icons/items_hires/" .. blueprintImage .. ".png")
  local currencyCost = tostring(ItemDataManagerBus.Broadcast.GetBlueprintCurrencyCost(itemId))
  UiTextBus.Event.SetText(self.StructureInfoPanel.TaxValue, GetLocalizedCurrency(currencyCost))
  local itemDescriptors = BuilderRequestBus.Event.GetIngredientDetailsForBlueprint(self.builderId, itemId)
  local itemData = ItemDataManagerBus.Broadcast.GetItemData(itemId)
  UiTextBus.Event.SetTextWithFlags(self.StructureInfoPanel.Description, itemData.description, eUiTextSet_SetLocalized)
  for i = 1, #itemDescriptors do
    UiElementBus.Event.SetIsEnabled(self.StructureInfoPanel.RequiredResources[i - 1].entityId, true)
    self.StructureInfoPanel.RequiredResources[i - 1]:SetData(itemDescriptors[i])
  end
  UiTransform2dBus.Event.SetLocalHeight(self.StructureInfoPanel.Container, self.defaultHeight + self.size * (#itemDescriptors - 1))
  for i = #itemDescriptors, #self.StructureInfoPanel.RequiredResources do
    UiElementBus.Event.SetIsEnabled(self.StructureInfoPanel.RequiredResources[i].entityId, false)
  end
end
function BuildMode:OnEnableBuildModeMenuChanged(data)
  self.isBuildModeMenuEnabled = data
  self:UpdateVisibility()
end
function BuildMode:OnTerritoryOwnerChanged(data)
  self:CheckPermissionStatus()
end
function BuildMode:OnPlayerGuildChanged(data)
  self:CheckPermissionStatus()
end
function BuildMode:OnBuildingLocationStatusChanged(data)
  UiElementBus.Event.SetIsEnabled(self.StructureInfoPanel.BuildRequirementContainer, false)
  if BuilderRequestBus.Event.IsStructureInValidLocation(self.builderId) then
    UiElementBus.Event.SetIsEnabled(self.BuildingLocationStatusContainer, false)
    UiImageBus.Event.SetAlpha(self.StructureInfoPanel.Icon, 1)
  else
    local statusText = "@ui_buildmode_error_invalid_location"
    local showErrorMessage = true
    if BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_CAMPING_RESTRICTED) then
      statusText = "@ui_buildmode_error_camping_restricted"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_LOCATION) then
      statusText = "@ui_buildmode_error_invalid_location"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_LOCATION_OUT_OF_WORLD_BOUNDS) then
      statusText = "@ui_buildmode_error_invalid_location_world_bounds"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_IN_WATER) then
      statusText = "@ui_buildmode_error_in_water"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_LOS_FAILED) then
      statusText = "@ui_buildmode_error_not_in_line_of_sight"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_BAD_TERRAIN) then
      statusText = "@ui_buildmode_error_bad_terrain"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_HAS_OBSTRUCTION) then
      statusText = "@ui_buildmode_error_has_obstruction"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_NOT_IN_SOCKET) then
      statusText = "@ui_buildmode_error_not_in_socket"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_NOT_ENOUGH_PRIVILEGES) then
      statusText = "@ui_buildmode_error_invalid_not_enough_privileges"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_NOT_ENOUGH_PRIVILEGES_PLANTSEED) then
      statusText = "@ui_buildmode_error_invalid_not_enough_privileges_plantseed"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_NOT_IN_CLAIMED_TERRITORY) then
      statusText = "@ui_buildmode_error_not_in_claimed_territory"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_DEPLOYABLE_LIMIT_REACHED) then
      statusText = "@ui_buildmode_error_deployable_limit_reached"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_WAR_ATTACKERS_RESTRICTED) then
      statusText = "@ui_buildmode_error_war_attackers_restricted"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_OUTSIDE_OF_WAR) then
      statusText = "@ui_buildmode_error_outside_of_war"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_WAR_ATTACKERS_ONLY) then
      statusText = "@ui_buildmode_error_war_attackers_only"
    elseif BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_WAR_DEFENDERS_ONLY) then
      statusText = "@ui_buildmode_error_war_defenders_only"
    else
      showErrorMessage = false
    end
    UiElementBus.Event.SetIsEnabled(self.BuildingLocationStatusContainer, showErrorMessage)
    UiTextBus.Event.SetTextWithFlags(self.TextBuildingLocationStatus, statusText, eUiTextSet_SetLocalized)
    UiImageBus.Event.SetAlpha(self.StructureInfoPanel.Icon, 1)
    UiElementBus.Event.SetIsEnabled(self.StructureInfoPanel.Reason1, false)
    UiElementBus.Event.SetIsEnabled(self.StructureInfoPanel.Reason2, false)
    if BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, self.BuildingLocationStatus.INVALID_BLUEPRINT_NOT_KNOWN) then
      UiImageBus.Event.SetAlpha(self.StructureInfoPanel.Icon, 0.3)
      local reqLevel = BuilderRequestBus.Event.GetRequiredLevelForBlueprint(self.builderId, self.currentBlueprintId)
      local curLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Tradeskills.Building.Spent")
      UiElementBus.Event.SetIsEnabled(self.StructureInfoPanel.BuildRequirementContainer, true)
      UiElementBus.Event.SetIsEnabled(self.StructureInfoPanel.Reason1, true)
      local keys = vector_basic_string_char_char_traits_char()
      keys:push_back("skillreq")
      keys:push_back("current")
      local values = vector_basic_string_char_char_traits_char()
      values:push_back(tostring(reqLevel))
      values:push_back(tostring(curLevel))
      UiTextBus.Event.SetText(self.StructureInfoPanel.Reason1, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_buildmode_skill_required", keys, values))
    end
  end
end
function BuildMode:DebugPrintReasons()
  for key, value in pairs(self.BuildingLocationStatus) do
    local isOn = BuilderRequestBus.Event.IsStatusReasonFlagOn(self.builderId, value)
    Log("IsStatusReasonFlagOn: " .. key .. " : " .. tostring(isOn))
  end
end
function BuildMode:OnBlueprintIdChanged(data)
  if data == nil then
    return
  end
  local newBlueprintId = Math.CreateCrc32(data)
  if self.currentBlueprintId == newBlueprintId then
    return
  end
  self.currentBlueprintId = newBlueprintId
  local recipeData = RecipeDataManagerBus.Broadcast.GetCraftingRecipeData(data)
  self.blueprintTier = recipeData.itemTier
  self.isPlacingBlueprint = recipeData.listedByDefault
  self:UpdateVisibility()
  if self.isPlacingBlueprint then
    if recipeData.category ~= self.categoryType then
      self:SetCategory(recipeData.category)
      self:ReloadRecipes()
    end
    self:ScrollToCurrentBlueprint()
  end
end
function BuildMode:SetCategoryIndex(index)
  if index < 1 then
    index = #self.categories
  elseif index > #self.categories then
    index = 1
  end
  self:SetCategory(self.categories[index].categoryName)
end
function BuildMode:SetCategory(category)
  for i = 1, #self.categories do
    if self.categories[i].categoryName == category then
      self.categoryButtons[self.currentCategory]:SetSelected(false)
      self.categoryType = category
      self.currentCategory = i
      self.categoryButtons[i]:SetSelected(true)
      return
    end
  end
  Log("BuildMode:SetCategory: Trying to set to a category that wasn't found: " .. category)
end
function BuildMode:UpdateVisibility()
  local enabled = self.isPlacingBlueprint and self.isBuildModeMenuEnabled
  UiElementBus.Event.SetIsEnabled(self.StructureNavWheelContainer, enabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.TopNavBar, enabled)
  UiElementBus.Event.SetIsEnabled(self.CategoryContainer, enabled)
  UiElementBus.Event.SetIsEnabled(self.CategoryContainerBG, enabled)
  UiElementBus.Event.SetIsEnabled(self.StructureNavWheelBg, enabled)
  UiElementBus.Event.SetIsEnabled(self.CategoryHintContainer, enabled)
  UiElementBus.Event.SetIsEnabled(self.ScrollWheelIcon, enabled)
end
function BuildMode:ScrollToCurrentBlueprint()
  if self.currentBlueprintId == nil or self.currentBlueprintId == 0 then
    return
  end
  for i = 1, #self.recipes do
    local recipe = self.recipes[i]
    if Math.CreateCrc32(recipe.data.resultItemId) == self.currentBlueprintId then
      self:SetCurrentRecipe(i)
      return
    end
  end
  self:SetCurrentRecipe(1)
end
function BuildMode:CheckPermissionStatus()
  if self.builderId then
    self.buildReason = BuilderRequestBus.Event.CanBuildHere(self.builderId)
    self.bCanOpen = self.buildReason == self.BuildingLocationStatus.VALID_LOCATION
  else
    self.buildReason = self.BuildingLocationStatus.INVALID_LOCATION
    self.bCanOpen = false
  end
  if not self.bCanOpen and self.inBuildMode and self.isPlacingBlueprint then
    LyShineManagerBus.Broadcast.ExitState(3406343509)
  end
end
function BuildMode:OnShutdown()
  BaseScreen.OnShutdown(self)
  for i = 1, #self.recipes do
    UiElementBus.Event.DestroyElement(self.recipes[i].entityId)
  end
  for i = 1, #self.categoryButtons do
    UiElementBus.Event.DestroyElement(self.categoryButtons[i].entityId)
  end
  for i = 1, #self.headers do
    UiElementBus.Event.DestroyElement(self.headers[i])
  end
  for i = 1, #self.containers do
    UiElementBus.Event.DestroyElement(self.containers[i])
  end
  for i = 1, #self.structureRecipes do
    UiElementBus.Event.DestroyElement(self.structureRecipes[i])
  end
  ClearTable(self.cryActionHandlers)
end
return BuildMode

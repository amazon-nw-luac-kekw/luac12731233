local CraftingScreenV4 = {
  Properties = {
    CraftingContainer = {
      default = EntityId()
    },
    CraftingSteps = {
      CraftingStation = {
        default = EntityId()
      },
      CraftItem = {
        default = EntityId()
      },
      CraftRoll = {
        default = EntityId()
      },
      CraftDone = {
        default = EntityId()
      }
    },
    CraftItem = {
      CraftingTreeView = {
        default = EntityId()
      },
      Filter = {
        Scrim = {
          default = EntityId()
        },
        FilterInputText = {
          default = EntityId()
        },
        FrameHeader = {
          default = EntityId()
        },
        ButtonClose = {
          default = EntityId()
        },
        PlaceholderText = {
          default = EntityId()
        },
        InputBlocker = {
          default = EntityId()
        },
        FilterSpinner = {
          default = EntityId()
        },
        FilterIndicator = {
          default = EntityId()
        },
        FilterIndicatorText = {
          default = EntityId()
        },
        SortDropdown = {
          default = EntityId()
        },
        FilterButton = {
          default = EntityId()
        },
        PopupContainer = {
          default = EntityId()
        },
        Popup = {
          default = EntityId()
        },
        PopupClear = {
          default = EntityId()
        },
        PopupConfirm = {
          default = EntityId()
        },
        CheckboxList = {
          default = EntityId()
        }
      },
      CraftingRecipePanel = {
        default = EntityId()
      },
      CraftingStatsPanel = {
        default = EntityId()
      }
    },
    CraftRoll = {
      Window = {
        default = EntityId()
      },
      Background = {
        default = EntityId()
      },
      RuneCircleA = {
        default = EntityId()
      },
      RuneCircleB = {
        default = EntityId()
      },
      BonusList = {
        default = EntityId()
      },
      MultiCraft = {
        Container = {
          default = EntityId()
        },
        CancelButton = {
          default = EntityId()
        },
        Progress = {
          default = EntityId()
        }
      }
    },
    CraftDone = {
      Window = {
        default = EntityId()
      },
      ItemName = {
        default = EntityId()
      },
      Divider1 = {
        default = EntityId()
      },
      Divider2 = {
        default = EntityId()
      },
      ContinueText = {
        default = EntityId()
      },
      ExitButtonBigParent = {
        default = EntityId()
      },
      ExitButtonBig = {
        default = EntityId()
      },
      ExitButtonIcon = {
        default = EntityId()
      },
      ExitButtonHint = {
        default = EntityId()
      },
      BlackBg = {
        default = EntityId()
      },
      EquipButton = {
        default = EntityId()
      },
      SalvageButton = {
        default = EntityId()
      },
      SalvageButtonContainer = {
        default = EntityId()
      },
      CraftingSummaryList = {
        default = EntityId()
      },
      SummaryHeaderContainer = {
        default = EntityId()
      },
      SummaryHeaderAmount = {
        default = EntityId()
      },
      SummaryHeaderLabel = {
        default = EntityId()
      }
    },
    BackgroundStep1 = {
      default = EntityId()
    },
    ClickableArea = {
      default = EntityId()
    }
  },
  craftedItemInstanceId = nil,
  EQUIPPED_DELAY = 1,
  NOT_EQUIPPED_DELAY = 0.35,
  craftItemDelay = 0.35,
  CRAFTING_SUMMARY_ITEM_HEIGHT = 68,
  currentSkipState = 0,
  skipBuffered = false,
  skipDuration = 0.1,
  STATE_STATION = 0,
  STATE_CRAFTITEM = 1,
  STATE_CRAFTROLL = 2,
  STATE_CRAFTDONE = 3,
  SKIP_STATE_NONE = 0,
  SKIP_STATE_CRAFTROLL_PRE = 1,
  SKIP_STATE_CRAFTROLL = 2,
  SKIP_STATE_CRAFTDONE_FADEIN = 3,
  SKIP_STATE_CRAFTDONE_FLIPBOOK = 4,
  SKIP_STATE_CRAFTDONE_STATS = 5,
  SKIP_STATE_CRAFTDONE_FINISHED = 6
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(CraftingScreenV4)
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local InteractCommon = require("LyShineUI.HUD.UnifiedInteractCard.InteractCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
function CraftingScreenV4:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterOpenEvent("CraftingStation", self.canvasId)
  self.CraftItem.CraftingTreeView:SetCraftingScreen(self)
  if self.Properties.CraftItem.Filter.FilterSpinner:IsValid() then
    self.ScriptedEntityTweener:StartAnimation({
      id = self.Properties.CraftItem.Filter.FilterSpinner,
      duration = 1,
      opacity = 1,
      timesToPlay = -1,
      rotation = 359
    })
  end
  local availableSorts = {
    {
      text = "@crafting_sort_name",
      id = 0
    },
    {
      text = "@crafting_sort_level",
      id = 1
    },
    {
      text = "@crafting_sort_tier",
      id = 2
    },
    {
      text = "@crafting_sort_gear_score",
      id = 3
    },
    {
      text = "@crafting_sort_xp",
      id = 4
    }
  }
  self.CraftItem.Filter.SortDropdown:SetDropdownScreenCanvasId(self.Properties.CraftingContainer)
  self.CraftItem.Filter.SortDropdown:SetCallback(self.OnSortSelected, self)
  self.CraftItem.Filter.SortDropdown:SetListData(availableSorts)
  self.CraftItem.Filter.SortDropdown:SetSelectedItemData(availableSorts[2])
  self.CraftItem.Filter.SortDropdown:SetDropdownListHeightByRows(#availableSorts)
  self.availableFilters = {
    {
      id = self.CraftItem.CraftingTreeView.FILTER_MATERIALS,
      text = "@crafting_filter_materials",
      isChecked = false
    },
    {
      id = self.CraftItem.CraftingTreeView.FILTER_SKILL,
      text = "@crafting_filter_skill",
      isChecked = false
    },
    {
      id = self.CraftItem.CraftingTreeView.FILTER_STATIONLEVEL,
      text = "@crafting_filter_station",
      isChecked = false
    },
    {
      id = self.CraftItem.CraftingTreeView.FILTER_TIER1,
      text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@cr_tier_italic", GetRomanFromNumber(1)),
      isChecked = false
    },
    {
      id = self.CraftItem.CraftingTreeView.FILTER_TIER2,
      text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@cr_tier_italic", GetRomanFromNumber(2)),
      isChecked = false
    },
    {
      id = self.CraftItem.CraftingTreeView.FILTER_TIER3,
      text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@cr_tier_italic", GetRomanFromNumber(3)),
      isChecked = false
    },
    {
      id = self.CraftItem.CraftingTreeView.FILTER_TIER4,
      text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@cr_tier_italic", GetRomanFromNumber(4)),
      isChecked = false
    },
    {
      id = self.CraftItem.CraftingTreeView.FILTER_TIER5,
      text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@cr_tier_italic", GetRomanFromNumber(5)),
      isChecked = false
    }
  }
  self.CraftItem.Filter.CheckboxList:SetLabel("")
  self.CraftItem.Filter.CheckboxList:SetCallback(self.OnFilterChanged, self)
  self.CraftItem.Filter.CheckboxList:InitCheckboxes(self.availableFilters)
  self.CraftItem.Filter.FilterButton:SetText("@ui_add_filter")
  self.CraftItem.Filter.FilterButton:SetCallback(self.OnOpenFilterPopup, self)
  self.CraftItem.Filter.PopupClear:SetText("@crafting_filter_clear_all")
  self.CraftItem.Filter.PopupClear:SetBackgroundOpacity(0.2)
  self.CraftItem.Filter.PopupClear:SetCallback(self.OnClearFilters, self)
  self.CraftItem.Filter.PopupConfirm:SetText("@ui_done")
  self.CraftItem.Filter.PopupConfirm:SetBackgroundColor(self.UIStyle.COLOR_YELLOW)
  self.CraftItem.Filter.PopupConfirm:SetBackgroundOpacity(0.9)
  self.CraftItem.Filter.PopupConfirm:SetTextStyle(self.UIStyle.FONT_STYLE_CRAFTING_FILTER_ACCEPT)
  self.CraftItem.Filter.PopupConfirm:SetCallback(self.OnCloseFilterPopup, self)
  self.CraftItem.Filter.FrameHeader:SetText("@ui_filter")
  self.CraftItem.Filter.ButtonClose:SetCallback(self.OnCloseFilterPopup, self)
  self.CraftDone.CraftingSummaryList:SetSalvageCallback(self.OnSummarySalvage, self)
  SetTextStyle(self.Properties.CraftDone.SummaryHeaderAmount, self.UIStyle.FONT_STYLE_CRAFTING_SUMMARY_AMOUNT)
  SetTextStyle(self.Properties.CraftDone.SummaryHeaderLabel, self.UIStyle.FONT_STYLE_CRAFTING_SUMMARY_HEADER)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.CraftingEntityId", function(self, craftingId)
    if craftingId then
      self:BusConnect(CraftingEventBus, craftingId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    if data then
      self:BusConnect(PlayerComponentNotificationsBus, data)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    if data then
      self.inventoryId = data
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", function(self, data)
    if data then
      self.paperdollId = data
    end
  end)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftItem, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftRoll, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftDone, false)
  self.ScriptedEntityTweener:Set(self.CraftDone.BlackBg, {opacity = 0})
  self.CraftDone.ExitButtonBig:SetCallback(self.OnExitPostCrafting, self)
  self.CraftDone.ExitButtonBig:SetTextStyle(self.UIStyle.FONT_STYLE_CRAFTDONE_BUTTONEXIT)
  self.CraftDone.ExitButtonBig:SetSoundOnPress(self.audioHelper.Crafting_Button_Select)
  self.CraftDone.EquipButton:SetCallback(self.OnEquipPressed, self)
  self.CraftDone.EquipButton:SetText("@inv_equip")
  self.CraftDone.SalvageButton:SetCallback(self.OnSalvagePressed, self)
  self.CraftDone.SalvageButton:SetText("@inv_salvage")
  self.CraftRoll.MultiCraft.CancelButton:SetCallback(self.OnStopCraft, self)
  self.CraftRoll.MultiCraft.CancelButton:SetText("@ui_cancel")
  self.CraftRoll.MultiCraft.CancelButton:SetEnabled(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.ScriptedEntityTweener:Set(self.CraftingSteps.CraftItem, {opacity = 0})
  local paperdollSlotIndexToNameMap = RequireScript("LyShineUI.Crafting.CraftingPaperdollSlotIndexToNameMap")
  self.paperdollSlotIndexToNameMap = paperdollSlotIndexToNameMap
end
function CraftingScreenV4:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  self.ScriptedEntityTweener:Play(self.Properties.CraftingContainer, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.interactKeyHandler = CryActionNotificationsBus.Connect(self, "ui_interact")
  self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  self:BusDisconnect(self.objectivesComponentBusHandler)
  self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, playerEntityId)
  DynamicBus.StationPropertiesBus.Broadcast.SetBackButtonKeybind("ui_cancel")
  DynamicBus.StationPropertiesBus.Broadcast.SetBackButtonCallback(self.OnExit, self)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_CraftingStep1", 0.5)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftRoll.MultiCraft.Container, false)
  if self.skipHandler == nil then
    self.skipHandler = self:BusConnect(CryActionNotificationsBus, "tryskip")
  end
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("crafting", true)
  self:SetState(self.STATE_CRAFTITEM, true)
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Intro)
  self.audioHelper:onUIStateChanged(self.audioHelper.UIState_Crafting)
  local stationType = string.lower(string.sub(self.currentStationName, 1, string.len(self.currentStationName) - 1))
  self.isCamp = stationType == "camp"
  self.CraftItem.CraftingRecipePanel:SetInventoryCache(self.CraftItem.CraftingTreeView.InventoryCache)
  self.CraftItem.CraftingStatsPanel:SetCurrentStation(self.currentStationName)
  self.CraftItem.CraftingTreeView:SetCurrentStation(self.currentStationName)
end
function CraftingScreenV4:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  if 2901616697 ~= toStateName then
    self.audioHelper:PlaySound(self.audioHelper.Crafting_Outro)
    self.audioHelper:onUIStateChanged(self.audioHelper.UIState_Default)
    LocalPlayerUIRequestsBus.Broadcast.SetIsLookingThroughLoadout(false)
    CraftingRequestBus.Broadcast.OnCraftingScreenHidden()
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
    JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.5)
  end
  self.currentFilterText = ""
  UiTextInputBus.Event.SetText(self.Properties.CraftItem.Filter.FilterInputText, "")
  self.CraftItem.CraftingTreeView:SetFilter(self.CraftItem.CraftingTreeView.FILTER_NAME, false, "")
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.BlackBg, 0.5, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftingSteps.CraftItem, 0.5, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.BackgroundStep1, {opacity = 0})
  self.CraftItem.CraftingRecipePanel.CategoryItemSelector:Hide()
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftRoll.MultiCraft.Container, false)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("crafting", false)
  if self.skipHandler then
    self:BusDisconnect(self.skipHandler)
    self.skipHandler = nil
  end
  local durationOut = 0.2
  TimingUtils:Delay(durationOut, self, function()
    JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
    if interactorEntity then
      UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
    end
  end)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Inventory.SuppressNotificationsWhileCrafting", false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Outro)
  self.audioHelper:PlaySound(self.audioHelper.Crafting_ProgressBar_Loop_Stop)
  if self.paperdollEventHandler then
    self:BusDisconnect(self.paperdollEventHandler)
    self.paperdollEventHandler = nil
  end
  if self.containerEventHandler then
    self:BusDisconnect(self.containerEventHandler)
    self.containerEventHandler = nil
  end
  if self.objectivesComponentBusHandler then
    self:BusDisconnect(self.objectivesComponentBusHandler)
    self.objectivesComponentBusHandler = nil
  end
  self:BusDisconnect(self.interactKeyHandler)
  self.interactKeyHandler = nil
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  if self.currentState == self.STATE_CRAFTITEM and self.CraftItem.CraftingRecipePanel:IsFlyoutOpen() then
    self.CraftItem.CraftingRecipePanel:CloseFlyouts()
  end
end
function CraftingScreenV4:OnIsLookingThroughLoadoutChanged(isLookingThroughLoadout)
  if isLookingThroughLoadout then
    local isCraftingInteraction = false
    local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
    if interactorEntity then
      isCraftingInteraction = UiInteractorComponentRequestsBus.Event.IsInCommittedInteraction(interactorEntity, eInteractionUIActions_OpenCrafting)
    end
    self.currentStationName = CraftingRequestBus.Broadcast.GetCraftingStationName()
    local isInCraftingState = LyShineManagerBus.Broadcast.IsInState(3024636726) or LyShineManagerBus.Broadcast.IsInState(2901616697)
    if isCraftingInteraction and not isInCraftingState and self.currentStationName ~= "" then
      LyShineManagerBus.Broadcast.QueueState(3024636726)
    end
  elseif LyShineManagerBus.Broadcast.IsInLevel(10) then
    LyShineManagerBus.Broadcast.ExitState(0)
  end
end
function CraftingScreenV4:UsesEquipButton()
  if self.resultItemDescriptor ~= nil and (ItemDataManagerBus.Broadcast.IsEquippable(self.recipeResultId) or self.resultIsTool) then
    local playerLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
    local levelRequirement = self.resultItemDescriptor:GetLevelRequirement()
    return playerLevel > levelRequirement
  end
  return false
end
function CraftingScreenV4:UsesSalvageButton()
  return ItemDataManagerBus.Broadcast.IsSalvageable(self.recipeResultId)
end
function CraftingScreenV4:OnEquipPressed()
  local inventorySlotId = ContainerRequestBus.Event.GetSlotIdByItemInstanceId(self.inventoryId, self.craftedItemInstanceId)
  if 0 <= inventorySlotId then
    EquipmentCommon:EquipItemToBestSlot(inventorySlotId, false, self.inventoryId)
    self:EquipItem()
  end
end
function CraftingScreenV4:OnSalvagePressed()
  local popupText = self:GetPopupText(self.slot)
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@inv_salvage", popupText, "SalvageCraftingConfirm", self, function(self, result, eventId)
    if result == ePopupResult_Yes then
      local inventorySlotId = ContainerRequestBus.Event.GetSlotIdByItemInstanceId(self.inventoryId, self.craftedItemInstanceId)
      if 0 <= inventorySlotId then
        LocalPlayerUIRequestsBus.Broadcast.SalvageItem(tonumber(inventorySlotId), 1, self.inventoryId)
        self:SalvageItem()
      end
    end
  end)
end
function CraftingScreenV4:GetPopupText(slot)
  local itemDescriptor = slot:GetItemDescriptor()
  local salvageData
  local salvageIngredientList = CraftingRequestBus.Broadcast.GetSalvageOutputFromDescriptor(itemDescriptor, 1)
  if #salvageIngredientList == 0 and itemDescriptor ~= nil then
    salvageData = RecipeDataManagerBus.Broadcast.GetSalvageDataFromLootTable(itemDescriptor)
  end
  local salvageMin, salvageMax, salvageIngredientName
  local hasSalvageData = false
  if salvageIngredientList ~= nil and 0 < #salvageIngredientList then
    local salvageIngredient = salvageIngredientList[1]
    salvageIngredientName = salvageIngredient:GetDisplayName()
    salvageMin = math.floor(LocalPlayerUIRequestsBus.Broadcast.GetMinimumSalvagePercent() * salvageIngredient.quantity)
    salvageMax = math.floor(LocalPlayerUIRequestsBus.Broadcast.GetMaximumSalvagePercent() * salvageIngredient.quantity)
    local minQuantity = LocalPlayerUIRequestsBus.Broadcast.GetMinimumSalvageQuantity()
    if salvageMin < minQuantity then
      salvageMin = minQuantity
    end
    if salvageMax < salvageMin then
      salvageMax = salvageMin
    end
    hasSalvageData = true
  end
  if salvageData ~= nil and 0 < #salvageData then
    for i = 1, #salvageData do
      if salvageData[i].roll == 0 then
        local itemData = ItemDataManagerBus.Broadcast.GetItemData(Math.CreateCrc32(salvageData[i].itemId))
        salvageIngredientName = itemData.displayName
        salvageMin = salvageData[i].minQuantity
        salvageMax = salvageData[i].maxQuantity
        hasSalvageData = true
        self.salvageGuaranteedIndex = i
        break
      end
    end
  end
  local popupText
  if not hasSalvageData then
    popupText = "@inv_salvage_confirm"
  else
    self.salvageRepairPartsQuantity = 0
    self.salvageRepairPartsToBeLost = 0
    local isRepair = false
    self.salvageRepairPartsQuantity = RecipeDataManagerBus.Broadcast.GetRepairDustQuantity(slot, isRepair)
    if 0 < self.salvageRepairPartsQuantity then
      local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
      local currentRepairParts = CategoricalProgressionRequestBus.Event.GetProgression(playerEntityId, 2817455512)
      local maxRepairParts = CategoricalProgressionRequestBus.Event.GetMaxPointsForCurrentRank(playerEntityId, 2817455512)
      local availableRepairParts = maxRepairParts - currentRepairParts
      local willLoseRepairParts = availableRepairParts < self.salvageRepairPartsQuantity
      if willLoseRepairParts then
        self.salvageRepairPartsToBeLost = self.salvageRepairPartsQuantity - availableRepairParts
      end
    end
    popupText = self:GetSalvageDescription(salvageMin, salvageMax, salvageIngredientName, itemDescriptor, salvageData)
    if 0 < self.salvageRepairPartsToBeLost then
      local atLimit = self.salvageRepairPartsToBeLost == self.salvageRepairPartsQuantity
      local salvageCount = atLimit and 0 or self.salvageRepairPartsQuantity - self.salvageRepairPartsToBeLost
      local salvageAdditionalString
      local gemMessage = ""
      if ItemDataManagerBus.Broadcast.CanSalvageResources(itemDescriptor.itemId) then
        local resourceRange = atLimit and "@inv_repairparts_resources_atlimit" or "@inv_repairparts_resources_nearlimit"
        salvageAdditionalString = GetLocalizedReplacementText(resourceRange, {
          min = salvageMin,
          max = salvageMax,
          itemName = salvageIngredientName,
          numRepairParts = salvageCount
        })
        popupText = atLimit and "@inv_repairparts_atlimit " .. salvageAdditionalString .. " " .. gemMessage or "@inv_repairparts_nearlimit" .. " " .. salvageAdditionalString .. " " .. gemMessage
      else
        salvageAdditionalString = atLimit and "@inv_repairparts_atlimit" or "@inv_repairparts_nearlimit"
        local salvageSecondaryString = GetLocalizedReplacementText("@inv_repairparts_onlyrepairparts", {numRepairParts = salvageCount})
        if atLimit then
          popupText = salvageAdditionalString .. " " .. "<font color=" .. ColorRgbaToHexString(UIStyle.COLOR_RED) .. ">" .. salvageSecondaryString .. "</font>" .. " " .. gemMessage
        else
          popupText = salvageAdditionalString .. " " .. salvageSecondaryString .. " " .. gemMessage
        end
      end
    end
  end
  return popupText
end
function CraftingScreenV4:GetSalvageDescription(minQuantity, maxQuantity, salvageIngredientName, itemDescriptor, salvageData)
  local descriptionLocTag = ""
  local descriptionReplacements = {}
  if minQuantity ~= maxQuantity then
    descriptionLocTag = "@inv_salvage_tooltip_range"
    descriptionReplacements.min = minQuantity
    descriptionReplacements.max = maxQuantity
    descriptionReplacements.itemName = salvageIngredientName
  else
    descriptionLocTag = "@inv_salvage_tooltip"
    descriptionReplacements.numItems = minQuantity
    descriptionReplacements.itemName = salvageIngredientName
  end
  if self.salvageRepairPartsQuantity > 0 then
    descriptionLocTag = descriptionLocTag .. "_withrepairparts"
    descriptionReplacements.numRepairParts = self.salvageRepairPartsQuantity
  end
  local isTrinket = ItemCommon:IsTrinket(itemDescriptor.itemId)
  local hasGem = isTrinket and itemDescriptor:GetGemPerk() ~= 0
  descriptionReplacements.gemMessage = hasGem and "@inv_salvage_tooltip_gemmessage" or ""
  if salvageData and 1 < #salvageData then
    for i = 1, #salvageData do
      if self.salvageGuaranteedIndex ~= i then
        local itemData = ItemDataManagerBus.Broadcast.GetItemData(Math.CreateCrc32(salvageData[i].itemId))
        descriptionReplacements.gemMessage = GetLocalizedReplacementText("@inv_salvage_tooltip_additional_item", {
          itemData.displayName
        })
        break
      end
    end
  end
  return GetLocalizedReplacementText(descriptionLocTag, descriptionReplacements)
end
function CraftingScreenV4:OnStopCraft()
  self.CraftRoll.MultiCraft.CancelButton:SetEnabled(false)
  self.cancelMultiCraft = true
end
function CraftingScreenV4:OnShowSummary()
  self.ScriptedEntityTweener:Stop(self.Properties.CraftRoll.Window)
  self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Window, 0.3, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftRoll.Window, false)
    end
  })
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.CraftingSummaryList, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.SummaryHeaderContainer, true)
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.SummaryHeaderContainer, 1, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.3
  })
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.CraftingSummaryList, 1, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.3
  })
end
function CraftingScreenV4:EquipItem()
  self.equippedItem = true
  self.playingEquipAnimation = true
  self:FadeOutInForWhooshAnimation()
  self.craftItemDelay = self.NOT_EQUIPPED_DELAY
  DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation("@ui_item_equipped")
end
function CraftingScreenV4:SalvageItem()
  self.equippedItem = true
  self.playingEquipAnimation = true
  DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation()
  self:FadeOutInForWhooshAnimation()
  self.craftItemDelay = self.NOT_EQUIPPED_DELAY
end
function CraftingScreenV4:OnShutdown()
  BaseScreen.OnShutdown(self)
end
function CraftingScreenV4:OnExit()
  LyShineManagerBus.Broadcast.ExitState(3024636726)
end
function CraftingScreenV4:OnExitPostCrafting()
  self:OnExit()
end
function CraftingScreenV4:OnCryAction(actionname, value)
  if actionname == "tryskip" then
    self:TrySkip()
  end
end
function CraftingScreenV4:OnEscapeKeyPressed()
  if self.currentState == self.STATE_CRAFTDONE and self.currentSkipState == self.SKIP_STATE_CRAFTDONE_FINISHED then
    if not self.playingEquipAnimation then
      self:OnExit()
    end
  elseif self.currentState == self.STATE_CRAFTROLL or self.currentState == self.STATE_CRAFTDONE then
    self:TrySkip()
  elseif self.currentState == self.STATE_CRAFTITEM and self.CraftItem.CraftingRecipePanel.CategoryItemSelector:IsVisible() then
    self.CraftItem.CraftingRecipePanel.CategoryItemSelector:Hide()
  elseif self.currentState == self.STATE_CRAFTITEM and self.CraftItem.CraftingRecipePanel:IsFlyoutOpen() then
    self.CraftItem.CraftingRecipePanel:CloseFlyouts()
  elseif self.currentState == self.STATE_CRAFTITEM then
    self:OnExit()
  end
end
function CraftingScreenV4:OnAtCraftingStationChanged(atCraftingStation)
  if not atCraftingStation then
    self:OnExit()
  end
end
function CraftingScreenV4:OnSkip()
  self:SetState(self.STATE_CRAFTDONE)
end
function CraftingScreenV4:TrySkip()
  local skipDuration = self.skipDuration
  if self.currentState == self.STATE_CRAFTROLL then
    if self.currentSkipState == self.SKIP_STATE_CRAFTROLL_PRE then
      self.currentSkipState = self.SKIP_STATE_NONE
      self.skipBuffered = true
    elseif self.currentSkipState == self.SKIP_STATE_CRAFTROLL then
      self.currentSkipState = self.SKIP_STATE_NONE
      self.CraftRoll.Window:SkipAnimation(skipDuration)
    end
  elseif self.currentState == self.STATE_CRAFTDONE then
    if self.currentSkipState == self.SKIP_STATE_CRAFTDONE_FLIPBOOK then
      self.currentSkipState = self.SKIP_STATE_NONE
      self:AnimateCraftDoneTransitionIn(skipDuration, false)
    elseif self.currentSkipState == self.SKIP_STATE_CRAFTDONE_STATS then
      self.currentSkipState = self.SKIP_STATE_NONE
      self:AnimateCraftDoneStats(skipDuration)
    elseif self.currentSkipState == self.SKIP_STATE_CRAFTROLL or self.currentSkipState == self.SKIP_STATE_CRAFTDONE_FINISHED then
      self.currentSkipState = self.SKIP_STATE_NONE
      self:CraftCompleteReturnToStation()
      if not self.equippedItem then
        local itemSlot
        local inventorySlotId = ContainerRequestBus.Event.GetSlotIdByItemInstanceId(self.inventoryId, self.craftedItemInstanceId)
        if 0 <= inventorySlotId then
          itemSlot = ContainerRequestBus.Event.GetSlotRef(self.inventoryId, inventorySlotId)
        else
          local paperdollSlotId = PaperdollRequestBus.Event.GetSlotIdByItemInstanceId(self.paperdollId, self.craftedItemInstanceId)
          itemSlot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, paperdollSlotId)
        end
        if itemSlot then
          local desc = itemSlot:GetItemDescriptor()
          DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation(nil, 0.5, desc)
        end
      end
    end
  end
end
function CraftingScreenV4:CraftCompleteReturnToStation()
  UiElementBus.Event.SetIsEnabled(self.Properties.ClickableArea, false)
  self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Background, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Window, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.Window, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.BlackBg, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.ExitButtonBig, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.ExitButtonIcon, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.ExitButtonHint, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.EquipButton, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.SalvageButton, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Window, 0, {
    scaleY = 1,
    delay = 0.3,
    onComplete = function()
      self:SetState(self.STATE_CRAFTITEM)
    end
  })
end
function CraftingScreenV4:CheckGlobalStorageBeforeCraftDone()
  self.currentSkipState = self.SKIP_STATE_NONE
  local outpostId = self.isCamp and "" or LocalPlayerUIRequestsBus.Broadcast.GetStorageKeyForGlobalStorage()
  if string.len(outpostId) == 0 then
    self:ShowCraftDone()
  else
    contractsDataHandler:RequestStorageData(outpostId, self, self.ShowCraftDone)
  end
end
function CraftingScreenV4:AnimateCraftDoneTransitionIn(durationScale, playCraftDoneEffect)
  self.currentSkipState = self.SKIP_STATE_CRAFTDONE_FLIPBOOK
  self.craftDoneDurationScale = durationScale
  UiElementBus.Event.SetIsEnabled(self.Properties.ClickableArea, true)
  if playCraftDoneEffect then
    self.ScriptedEntityTweener:Stop(self.Properties.CraftRoll.Background)
    self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Background, 0, {
      opacity = 1,
      delay = durationScale * 0.01,
      onComplete = function()
        if self.currentSkipState ~= self.SKIP_STATE_NONE then
          self:CheckGlobalStorageBeforeCraftDone()
        end
      end
    })
  else
    self:CheckGlobalStorageBeforeCraftDone()
  end
end
function CraftingScreenV4:ShowCraftDone()
  if LyShineManagerBus.Broadcast.IsInState(3024636726) == false then
    return
  end
  TimingUtils:Delay(self.craftDoneDurationScale * 0.301, self, function()
    self.currentSkipState = self.SKIP_STATE_CRAFTDONE_STATS
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftDone, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.ExitButtonBig, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.ExitButtonIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.ExitButtonHint, true)
    local numCraftingSummarySlots = #self.craftingSummarySlots
    local usesEquipButton = self:UsesEquipButton() and numCraftingSummarySlots < 1
    local usesSalvageButton = self:UsesSalvageButton() and numCraftingSummarySlots < 1
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.EquipButton, usesEquipButton)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.SalvageButton, usesSalvageButton)
    if not usesEquipButton and not usesSalvageButton then
      self.ScriptedEntityTweener:Set(self.Properties.CraftDone.ExitButtonBigParent, {y = 0})
      self.ScriptedEntityTweener:Set(self.Properties.CraftDone.ContinueText, {y = 490})
    else
      self.ScriptedEntityTweener:Set(self.Properties.CraftDone.ExitButtonBigParent, {y = -40})
      self.ScriptedEntityTweener:Set(self.Properties.CraftDone.ContinueText, {y = 444})
    end
    self.ScriptedEntityTweener:Set(self.Properties.CraftDone.Window, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.CraftDone.ItemName, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.CraftDone.BlackBg, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.CraftDone.ExitButtonBig, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.CraftDone.ExitButtonIcon, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.CraftDone.ExitButtonHint, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.CraftDone.EquipButton, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.CraftDone.SalvageButton, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.CraftRoll.RuneCircleA, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.Properties.CraftRoll.RuneCircleB, {opacity = 1})
    self.CraftDone.Divider1:Reset()
    self.CraftDone.Divider2:Reset()
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
    self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
    self.targetDOFDistance = 0
    self.targetDOFBlur = 0.95
    TimingUtils:UpdateForDuration(1.2, self, function(self, currentValue)
      self:UpdateDepthOfField(currentValue)
    end)
    self:AnimateCraftDoneStats(self.craftDoneDurationScale)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Inventory.SuppressNotificationsWhileCrafting", false)
    LocalPlayerUIRequestsBus.Broadcast.RefreshEquipLoad()
  end)
end
function CraftingScreenV4:AnimateCraftDoneStats(durationScale)
  self.currentSkipState = self.SKIP_STATE_CRAFTDONE_STATS
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftDone, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.ExitButtonBig, true)
  local numCraftingSummarySlots = #self.craftingSummarySlots
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.EquipButton, self:UsesEquipButton() and numCraftingSummarySlots < 1)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.SalvageButton, self:UsesSalvageButton() and numCraftingSummarySlots < 1)
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.BlackBg, durationScale * 1, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.Window, durationScale * 0.7, {
    opacity = 1,
    delay = durationScale * 0.55,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Stop(self.Properties.CraftDone.ItemName)
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.ItemName, durationScale * 0.7, {
    opacity = 1,
    delay = durationScale * 0.55
  })
  self.ScriptedEntityTweener:Stop(self.Properties.CraftDone.ContinueText)
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.ContinueText, durationScale * 0.7, {
    opacity = 1,
    delay = durationScale * 0.55,
    onComplete = function()
      self.currentSkipState = self.SKIP_STATE_CRAFTDONE_FINISHED
    end
  })
  self.ScriptedEntityTweener:Stop(self.Properties.CraftDone.ExitButtonBig)
  self.ScriptedEntityTweener:Stop(self.Properties.CraftDone.ExitButtonIcon)
  self.ScriptedEntityTweener:Stop(self.Properties.CraftDone.ExitButtonHint)
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.ExitButtonBig, durationScale * 0.7, {
    opacity = 1,
    delay = durationScale * 0.55
  })
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.ExitButtonIcon, durationScale * 0.7, {
    opacity = 1,
    delay = durationScale * 0.55
  })
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.ExitButtonHint, durationScale * 0.7, {
    opacity = 1,
    delay = durationScale * 0.55
  })
  self.ScriptedEntityTweener:Stop(self.Properties.CraftDone.EquipButton)
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.EquipButton, durationScale * 0.7, {
    opacity = 1,
    delay = durationScale * 0.55
  })
  self.ScriptedEntityTweener:Stop(self.Properties.CraftDone.SalvageButton)
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.SalvageButton, durationScale * 0.7, {
    opacity = 1,
    delay = durationScale * 0.55
  })
  self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.RuneCircleA, durationScale * 0.5, {opacity = 0.5, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.RuneCircleB, durationScale * 0.5, {opacity = 0.5, ease = "QuadOut"})
  self.ScriptedEntityTweener:Stop(self.Properties.CraftRoll.RuneCircleA)
  self.ScriptedEntityTweener:Stop(self.Properties.CraftRoll.RuneCircleB)
  self.CraftDone.Divider1:SetVisible(true, durationScale * 0.15, {
    delay = durationScale * 0.55
  })
  self.CraftDone.Divider2:SetVisible(true, durationScale * 0.15, {
    delay = durationScale * 0.55
  })
end
function CraftingScreenV4:FadeOutInForWhooshAnimation()
  UiElementBus.Event.SetIsEnabled(self.Properties.ClickableArea, false)
  self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Background, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Window, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.Window, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.ExitButtonBig, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.ExitButtonIcon, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.ExitButtonHint, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.EquipButton, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftDone.SalvageButton, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Window, 0, {
    scaleY = 1,
    delay = self.EQUIPPED_DELAY,
    onComplete = function()
      self:SetState(self.STATE_CRAFTITEM)
      self.craftedItemInstanceId = nil
    end
  })
end
function CraftingScreenV4:HideCraftAnimation()
  if not (self.inventoryId and self.inventoryId:IsValid()) or not self.craftedItemInstanceId then
    return
  end
  local inventorySlotId = ContainerRequestBus.Event.GetSlotIdByItemInstanceId(self.inventoryId, self.craftedItemInstanceId)
  if 0 <= inventorySlotId then
    DynamicBus.EncumbranceBus.Broadcast.HideCraftAnimation()
  else
    local paperdollSlotId = PaperdollRequestBus.Event.GetSlotIdByItemInstanceId(self.paperdollId, self.craftedItemInstanceId)
    if paperdollSlotId >= ePaperDollSlotTypes_QuickSlot1 and paperdollSlotId <= ePaperDollSlotTypes_MainHandOption3 then
      DynamicBus.QuickslotsBus.Broadcast.HideCraftAnimation(paperdollSlotId)
    else
      DynamicBus.EquipmentBus.Broadcast.HideCraftAnimation(paperdollSlotId)
    end
  end
end
function CraftingScreenV4:UpdateCameraState(nextState)
  if self.currentState == self.STATE_CRAFTITEM and nextState == self.STATE_CRAFTROLL then
    JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_CraftingStep3", 0.2)
  elseif self.currentState == self.STATE_CRAFTROLL and nextState == self.STATE_CRAFTITEM or self.currentState == self.STATE_CRAFTDONE and nextState == self.STATE_CRAFTITEM then
    JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_CraftingStep3", 0.2)
  end
end
function CraftingScreenV4:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function CraftingScreenV4:SetState(state, isOnTransitionIn)
  if isOnTransitionIn == nil then
    isOnTransitionIn = false
  end
  if not isOnTransitionIn and self.currentState == state then
    return
  end
  if LyShineManagerBus.Broadcast.IsInState(3024636726) == false then
    return
  end
  self:UpdateCameraState(state)
  self.currentState = state
  self.currentSkipState = self.SKIP_STATE_NONE
  UiElementBus.Event.SetIsEnabled(self.Properties.ClickableArea, false)
  if self.currentState == self.STATE_CRAFTITEM then
    if self.containerEventHandler then
      self:BusDisconnect(self.containerEventHandler)
      self.containerEventHandler = nil
    end
    if self.paperdollEventHandler then
      self:BusDisconnect(self.paperdollEventHandler)
      self.paperdollEventHandler = nil
    end
    self.CraftItem.CraftingTreeView:RefreshTreeView()
    self.CraftItem.CraftingRecipePanel:Refresh()
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftItem, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftRoll, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftDone, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.ExitButtonBig, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.ExitButtonIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.ExitButtonHint, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.EquipButton, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.SalvageButton, false)
    self.ScriptedEntityTweener:Play(self.Properties.BackgroundStep1, 0.35, {opacity = 0})
    self.ScriptedEntityTweener:Play(self.Properties.CraftDone.BlackBg, 0, {opacity = 0})
    self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Background, 0, {opacity = 0})
    self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Window, 0, {opacity = 0})
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
    self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
    self.targetDOFDistance = 0
    self.targetDOFBlur = 0.95
    TimingUtils:UpdateForDuration(0.5, self, function(self, currentValue)
      self:UpdateDepthOfField(currentValue)
    end)
    self.audioHelper:PlaySound(self.audioHelper.Crafting_IntroStep2)
    DynamicBus.StationPropertiesBus.Broadcast.SetVisible(true)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.CraftingSummaryList, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.SummaryHeaderContainer, false)
    self.craftingSummarySlots = {}
    self.shouldShowSummaryOption = false
    self.craftItemDelay = self.NOT_EQUIPPED_DELAY
  elseif self.currentState == self.STATE_CRAFTROLL then
    if self.containerEventHandler == nil then
      self.containerEventHandler = self:BusConnect(ContainerEventBus, self.inventoryId)
    end
    if self.paperdollEventHandler == nil then
      self.paperdollEventHandler = self:BusConnect(PaperdollEventBus, self.paperdollId)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.ClickableArea, true)
    self.CraftRoll.Window:Reset()
    self.skipBuffered = false
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftItem, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftRoll, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftDone, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftRoll.Background, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftRoll.Window, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.ExitButtonBig, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.ExitButtonIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.ExitButtonHint, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.EquipButton, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.SalvageButton, false)
    self.ScriptedEntityTweener:Set(self.Properties.CraftRoll.RuneCircleA, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.Properties.CraftRoll.RuneCircleB, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.RuneCircleA, 10, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.RuneCircleB, 10, {rotation = 0}, {timesToPlay = -1, rotation = -359})
    self.ScriptedEntityTweener:Play(self.Properties.BackgroundStep1, 0.35, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.Properties.CraftDone.BlackBg, 0, {opacity = 0})
    self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Background, 0.3, {opacity = 1, delay = 0.25})
    self.ScriptedEntityTweener:Play(self.Properties.CraftRoll.Window, 0.3, {opacity = 1, delay = 0.25})
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
    self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
    self.targetDOFDistance = 6
    self.targetDOFBlur = 0.4
    TimingUtils:UpdateForDuration(0.5, self, function(self, currentValue)
      self:UpdateDepthOfField(currentValue)
    end)
    DynamicBus.StationPropertiesBus.Broadcast.SetVisible(false)
    if ConfigProviderEventBus.Broadcast.GetBool("javelin.always-skip-craft-roll") then
      self:TrySkip()
      return
    end
  elseif self.currentState == self.STATE_CRAFTDONE then
    if 1 < self.quantityToMake and not self.cancelMultiCraft then
      self.quantityToMake = self.quantityToMake - 1
      self:OnCraftClicked()
    else
      local numPerksDisplay, perkDelay = self.CraftRoll.Window:GetNumPerks()
      local craftDoneTransitionDelay = 1
      local craftingSummaryDelay = 0.5
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftRoll.MultiCraft.Container, false)
      self.equippedItem = false
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftItem, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftingSteps.CraftRoll, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftRoll.Background, true)
      local numCraftingSummarySlots = #self.craftingSummarySlots
      if 1 < numCraftingSummarySlots then
        table.sort(self.craftingSummarySlots, function(first, second)
          return first:GetItemDescriptor():GetGearScore() > second:GetItemDescriptor():GetGearScore()
        end)
        self:SetSummaryHeader(numCraftingSummarySlots)
        self.CraftDone.CraftingSummaryList:SetItemSlots(self.craftingSummarySlots)
        self.shouldShowSummaryOption = false
        self.ScriptedEntityTweener:Set(self.Properties.CraftDone.EquipButton, {opacity = 0})
        self.ScriptedEntityTweener:Set(self.Properties.CraftDone.SalvageButton, {opacity = 0})
        TimingUtils:Delay(craftingSummaryDelay + numPerksDisplay * perkDelay, self, function()
          UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.EquipButton, false)
          UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.SalvageButton, false)
          if self.currentState == self.STATE_CRAFTDONE then
            self:OnShowSummary()
          end
        end)
      end
      self:AnimateCraftDoneTransitionIn(craftDoneTransitionDelay, true)
      self.craftItemDelay = self.EQUIPPED_DELAY
    end
  end
end
function CraftingScreenV4:SetSummaryHeader(amount)
  if 0 < amount then
    UiTextBus.Event.SetText(self.Properties.CraftDone.SummaryHeaderAmount, tostring(amount))
    UiTextBus.Event.SetTextWithFlags(self.Properties.CraftDone.SummaryHeaderLabel, "@ui_crafting_summary_header", eUiTextSet_SetLocalized)
    local summaryHeaderAmountWidth = UiTextBus.Event.GetTextWidth(self.Properties.CraftDone.SummaryHeaderAmount)
    local summaryHeaderLabelWidth = UiTextBus.Event.GetTextWidth(self.Properties.CraftDone.SummaryHeaderLabel)
    local padding = 15
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.CraftDone.SummaryHeaderContainer, summaryHeaderAmountWidth + summaryHeaderLabelWidth + padding)
    local summaryScrollboxHeight = math.min(amount * self.CRAFTING_SUMMARY_ITEM_HEIGHT, 700)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.CraftDone.CraftingSummaryList, summaryScrollboxHeight)
    local summaryHeaderPositionY = -(summaryScrollboxHeight / 2) - 50
    UiTransformBus.Event.SetLocalPositionY(self.Properties.CraftDone.SummaryHeaderContainer, summaryHeaderPositionY)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.CraftingSummaryList, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.SummaryHeaderContainer, false)
  end
end
function CraftingScreenV4:OnSummarySalvage(itemSlot)
  local slotIndex = -1
  for i, slot in ipairs(self.craftingSummarySlots) do
    if itemSlot:GetItemInstanceId() == slot:GetItemInstanceId() then
      slotIndex = i
      break
    end
  end
  if 1 <= slotIndex then
    local popupText = self:GetPopupText(itemSlot)
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@inv_salvage", popupText, "SalvageCraftingConfirm", self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        local inventorySlotId = ContainerRequestBus.Event.GetSlotIdByItemInstanceId(self.inventoryId, itemSlot:GetItemInstanceId())
        if 0 <= inventorySlotId then
          LocalPlayerUIRequestsBus.Broadcast.SalvageItem(tonumber(inventorySlotId), 1, self.inventoryId)
          table.remove(self.craftingSummarySlots, slotIndex)
          self:SetSummaryHeader(#self.craftingSummarySlots)
          self.CraftDone.CraftingSummaryList:SetItemSlots(self.craftingSummarySlots)
        end
      end
    end)
  end
end
function CraftingScreenV4:SetCraftQuantity(quantity)
  self.quantityToMake = math.floor(quantity)
  self.maxCraftingJobs = self.quantityToMake
end
function CraftingScreenV4:OnCraftClicked(entityId, actionName)
  local tutorialComponentId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  TutorialUIRequestsBus.Event.CraftButtonPressed(tutorialComponentId)
  self.playingEquipAnimation = false
  self.craftedItemInEquipment = false
  self.ScriptedEntityTweener:Stop(self.Properties.CraftRoll.Window)
  if self.CraftItem.CraftingRecipePanel == nil or self.CraftItem.CraftingRecipePanel:GetQuantityToMake() <= 0 then
    return
  end
  self.currentRecipeData = self.CraftItem.CraftingRecipePanel:GetRecipeData()
  self.craftAll = CraftingRequestBus.Broadcast.IsRecipeCraftAll(self.currentRecipeData.id)
  local jobQuantity = self.craftAll and self.quantityToMake or 1
  self.cancelMultiCraft = false
  local isSingleMultiCraft = not self.craftAll and self.quantityToMake > 1
  self.shouldShowSummaryOption = self.shouldShowSummaryOption or isSingleMultiCraft
  self.CraftRoll.Window:SetMultiCraft(isSingleMultiCraft)
  self.CraftRoll.Window:SetFixedFromProcedural(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftRoll.MultiCraft.Container, isSingleMultiCraft)
  self.resultItemDescriptor = nil
  self.recipeResultId = self.CraftItem.CraftingRecipePanel:GetResultItemId()
  self.recipeResultTier = self.CraftItem.CraftingRecipePanel:GetResultItemTier()
  local descriptor = ItemDescriptor()
  descriptor.itemId = self.recipeResultId
  local ownedAmount = ContainerRequestBus.Event.GetItemCount(self.inventoryId, descriptor, false, true, false)
  self.CraftDone.Window:SetOriginalInventoryAmount(ownedAmount)
  if self.craftAll then
    self.quantityToMake = 0
  elseif self.quantityToMake > 1 then
    local progressText = GetLocalizedReplacementText("@ui_craftprogress", {
      amount = tostring(self.maxCraftingJobs - self.quantityToMake + 1),
      maximum = tostring(self.maxCraftingJobs)
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.CraftRoll.MultiCraft.Progress, progressText, eUiTextSet_SetAsIs)
    self.CraftRoll.MultiCraft.CancelButton:SetEnabled(true)
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Inventory.SuppressNotificationsWhileCrafting", true)
  local categoryItems = self.CraftItem.CraftingRecipePanel:GetIngredients()
  self.CraftRoll.Window:SetIsQuantityCraft(self.craftAll)
  self.CraftRoll.Window:SetRollData(self.currentRecipeData, self.recipeResultId, self.recipeResultTier, categoryItems)
  self.craftedItemInstanceId = nil
  CraftingRequestBus.Broadcast.CraftRecipe(self.currentRecipeData.id, jobQuantity, self.CraftItem.CraftingRecipePanel:GetPerkItem(), self.CraftItem.CraftingRecipePanel:GetPerkUpgradeLevel(), categoryItems)
  TimingUtils:StopDelay(self)
  TimingUtils:Delay(5, self, function()
    if self.currentState == self.STATE_CRAFTROLL then
      self:OnCraftingFailed()
    end
  end)
  self:SetState(self.STATE_CRAFTROLL)
  self.currentSkipState = self.SKIP_STATE_CRAFTROLL_PRE
  if self.craftAll then
    local quantityPerCraft = CraftingRequestBus.Broadcast.GetRecipeOutputQuantity(self.currentRecipeData.id)
    self.CraftDone.Window:SetHeader("@cr_base_amount")
  else
    self.CraftDone.Window:SetHeader("@cr_rarity")
  end
end
function CraftingScreenV4:OnCraftingFailed()
  if self.containerEventHandler == nil then
    self.containerEventHandler = self:BusConnect(ContainerEventBus, self.inventoryId)
  end
  if self.paperdollEventHandler then
    self:BusDisconnect(self.paperdollEventHandler)
    self.paperdollEventHandler = nil
  end
  self:SetState(self.STATE_CRAFTITEM)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = "@crafting_failed"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function CraftingScreenV4:OnSlotUpdate(localSlotId, slot, updateReason)
  if LyShineManagerBus.Broadcast.IsInState(3024636726) == false then
    return
  end
  if updateReason == eItemContainerSync_ItemCreated then
    if self.shouldShowSummaryOption then
      table.insert(self.craftingSummarySlots, slot)
    end
    TimingUtils:StopDelay(self)
    self.slot = slot
    self.craftedItemInstanceId = slot:GetItemInstanceId()
    self.resultItemDescriptor = slot:GetItemDescriptor()
    local quantity = ContainerRequestBus.Event.GetItemCount(self.inventoryId, self.resultItemDescriptor, false, true, false)
    local skipDuration = self.skipBuffered and self.skipDuration or nil
    local quantityPerCraft = CraftingRequestBus.Broadcast.GetRecipeOutputQuantity(self.currentRecipeData.id)
    if self.craftAll then
      local expectedAmount = self.maxCraftingJobs * quantityPerCraft
      local detectedAmount = quantity - self.CraftDone.Window.oldAmt
      if expectedAmount > detectedAmount then
        return
      end
      self.CraftRoll.Window:SetQuantityCrafted(quantity - self.CraftDone.Window.oldAmt, self.maxCraftingJobs, quantityPerCraft)
      self.CraftRoll.Window:StartRefiningBarAnimation(skipDuration)
    else
      if self.recipeResultId ~= self.resultItemDescriptor.itemId then
        self.CraftRoll.Window:SetFixedFromProcedural(true)
      end
      self.CraftRoll.Window:SetSlot(slot, self.gearscoreAnimateDuration)
    end
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local inventorySlotId = ContainerRequestBus.Event.GetSlotIdByItemInstanceId(self.inventoryId, self.craftedItemInstanceId)
    local canEquip = slot:CanEquipItem(playerEntityId) and 0 <= inventorySlotId
    self.resultIsTool = slot:HasItemClass(eItemClass_UI_Tools)
    self.CraftDone.EquipButton:SetEnabled(canEquip or self.resultIsTool)
    if self.resultIsTool then
      self.CraftDone.EquipButton:SetText("@ui_tooltip_setactivetool")
      self.CraftDone.EquipButton:SetButtonStyle(1)
    elseif canEquip then
      self.CraftDone.EquipButton:SetText("@inv_equip")
      self.CraftDone.EquipButton:SetButtonStyle(1)
    end
    local canSalvage = slot:CanSalvageItem()
    self.CraftDone.SalvageButton:SetEnabled(canSalvage)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftDone.SalvageButtonContainer, canSalvage)
    self.currentSkipState = self.SKIP_STATE_CRAFTROLL
  end
end
function CraftingScreenV4:OnPaperdollSlotUpdate(localSlotId, slot, updateReason)
  if self.currentState == self.STATE_CRAFTROLL and updateReason == eItemContainerSync_ItemCreated then
    self:OnSlotUpdate(localSlotId, slot, updateReason)
  end
end
function CraftingScreenV4:OnSortSelected(listItem, listItemData)
  if listItemData.id then
    self.CraftItem.CraftingTreeView:SortItems(listItemData.id)
  end
end
function CraftingScreenV4:OnOpenFilterPopup()
  self.CraftItem.Filter.SortDropdown:OnHideDropdown()
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftItem.Filter.PopupContainer, true)
  self.ScriptedEntityTweener:Play(self.Properties.CraftItem.Filter.Scrim, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.CraftItem.Filter.Popup, 0.1, {opacity = 0, y = 19}, {
    opacity = 1,
    y = 24,
    ease = "QuadOut",
    delay = 0.1
  })
end
function CraftingScreenV4:UpdateFilterIndicator(amount, max)
  local enabled = 0 < amount
  self.ScriptedEntityTweener:Play(self.Properties.CraftItem.Filter.FilterIndicator, 0.1, {
    opacity = enabled and 1 or 0,
    ease = "QuadOut"
  })
  if enabled then
    UiTextBus.Event.SetText(self.Properties.CraftItem.Filter.FilterIndicatorText, amount)
  end
  self.CraftItem.CraftingTreeView:UpdateFilterIndicator(amount, max)
end
function CraftingScreenV4:OnFilterChanged(isChecked, index)
  self.availableFilters[index].isChecked = isChecked
  self:UpdateTotalFilters()
end
function CraftingScreenV4:UpdateTotalFilters()
  local total = 0
  local max = #self.availableFilters
  for i = 1, max do
    if self.availableFilters[i].isChecked then
      total = total + 1
    end
  end
  local filterButtonText = total == max and "@ui_remove_filters" or "@ui_add_filter"
  self.CraftItem.Filter.FilterButton:SetText(filterButtonText)
  self:UpdateFilterIndicator(total, max)
end
function CraftingScreenV4:OnClearFilters()
  for i = 1, #self.availableFilters do
    self.availableFilters[i].isChecked = false
    self.CraftItem.CraftingTreeView:SetFilter(self.availableFilters[i].id, false)
  end
  self.CraftItem.Filter.CheckboxList:SetStates(self.availableFilters)
  self.CraftItem.Filter.FilterButton:SetText("@ui_add_filter")
  self:UpdateFilterIndicator(0, #self.availableFilters)
end
function CraftingScreenV4:OnCloseFilterPopup()
  for i = 1, #self.availableFilters do
    self.CraftItem.CraftingTreeView:SetFilter(self.availableFilters[i].id, self.availableFilters[i].isChecked)
  end
  self.CraftItem.CraftingTreeView:FilterTreeView()
  self.ScriptedEntityTweener:Play(self.Properties.CraftItem.Filter.Popup, 0.1, {
    opacity = 0,
    y = 19,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftItem.Filter.PopupContainer, false)
    end
  })
end
function CraftingScreenV4:SelectRecipe(recipeData)
  self.CraftItem.CraftingRecipePanel.CategoryItemSelector:Hide()
  self.CraftItem.CraftingRecipePanel:SetRecipe(recipeData)
end
function CraftingScreenV4:UpdateFilter()
  self.currentFilterText = UiTextInputBus.Event.GetText(self.Properties.CraftItem.Filter.FilterInputText)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftItem.Filter.InputBlocker, true)
  TimingUtils:StopDelay(self)
  TimingUtils:Delay(1, self, function()
    self.CraftItem.CraftingTreeView:SetFilter(self.CraftItem.CraftingTreeView.FILTER_NAME, self.currentFilterText ~= "", self.currentFilterText)
    self.CraftItem.CraftingTreeView:FilterTreeView()
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftItem.Filter.InputBlocker, false)
  end)
end
function CraftingScreenV4:StartFilterInput()
  SetActionmapsForTextInput(self.canvasId, true)
  self.ScriptedEntityTweener:Play(self.Properties.CraftItem.Filter.PlaceholderText, 0.2, {opacity = 0, ease = "QuadOut"})
end
function CraftingScreenV4:EndFilterInput()
  SetActionmapsForTextInput(self.canvasId, false)
  local currentName = UiTextInputBus.Event.GetText(self.Properties.CraftItem.Filter.FilterInputText)
  if currentName == "" then
    self.ScriptedEntityTweener:Play(self.Properties.CraftItem.Filter.PlaceholderText, 0.2, {opacity = 1, ease = "QuadOut"})
  end
end
function CraftingScreenV4:FindProceduralRecipe(recipeName, tier)
  return self.CraftItem.CraftingTreeView:FindProceduralRecipe(recipeName, tier)
end
function CraftingScreenV4:OnObjectiveFailed(objectiveInstanceId, objectiveId, missionId)
  self.CraftItem.CraftingStatsPanel:CheckPinButton()
end
function CraftingScreenV4:OnObjectiveRemoved(removedObjectiveId)
  self.CraftItem.CraftingStatsPanel:CheckPinButton()
end
function CraftingScreenV4:OnObjectiveAdded(objectiveInstanceId)
  self.CraftItem.CraftingStatsPanel:CheckPinButton()
end
return CraftingScreenV4

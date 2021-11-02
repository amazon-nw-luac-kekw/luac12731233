local MasteryTreeWindow = {
  Properties = {
    MasteryTrees = {
      default = {
        EntityId()
      }
    },
    Level = {
      default = EntityId()
    },
    ProgressionPoints = {
      default = EntityId()
    },
    ProgressBarFill = {
      default = EntityId()
    },
    WeaponIcon = {
      default = EntityId()
    },
    WeaponTitle = {
      default = EntityId()
    },
    AbilitiesTitle = {
      default = EntityId()
    },
    AbilitySlot1 = {
      default = EntityId()
    },
    Slot1IconFlashShort = {
      default = EntityId()
    },
    Slot1IconFlashLong = {
      default = EntityId()
    },
    Slot1IconBg = {
      default = EntityId()
    },
    Slot1Icon = {
      default = EntityId()
    },
    Slot1Key = {
      default = EntityId()
    },
    AbilitySlot2 = {
      default = EntityId()
    },
    Slot2IconFlashShort = {
      default = EntityId()
    },
    Slot2IconFlashLong = {
      default = EntityId()
    },
    Slot2IconBg = {
      default = EntityId()
    },
    Slot2Icon = {
      default = EntityId()
    },
    Slot2Key = {
      default = EntityId()
    },
    AbilitySlot3 = {
      default = EntityId()
    },
    Slot3IconFlashShort = {
      default = EntityId()
    },
    Slot3IconFlashLong = {
      default = EntityId()
    },
    Slot3IconBg = {
      default = EntityId()
    },
    Slot3Icon = {
      default = EntityId()
    },
    Slot3Key = {
      default = EntityId()
    },
    PowerText = {
      default = EntityId()
    },
    PowerFromText = {
      default = EntityId()
    },
    TreeName1 = {
      default = EntityId()
    },
    TreeName2 = {
      default = EntityId()
    },
    PointsAvailableContainer = {
      default = EntityId()
    },
    PointsAvailableBg = {
      default = EntityId()
    },
    PointsAvailableRing1 = {
      default = EntityId()
    },
    PointsAvailableRing2 = {
      default = EntityId()
    },
    PointsAvailableNumber = {
      default = EntityId()
    },
    PointsAvailableLabel = {
      default = EntityId()
    },
    AbilitySelection = {
      default = EntityId()
    },
    ConfirmButton = {
      default = EntityId()
    },
    SlotOptions = {
      default = EntityId()
    },
    SlotOptionHintContainer = {
      default = EntityId()
    },
    SlotOptionHint1 = {
      default = EntityId()
    },
    SlotOptionHint2 = {
      default = EntityId()
    },
    SlotOptionHint3 = {
      default = EntityId()
    },
    RespecButton = {
      default = EntityId()
    },
    FreeText = {
      default = EntityId()
    },
    AzothTextContainer = {
      default = EntityId()
    },
    BackButton = {
      default = EntityId()
    },
    TreeTopLine = {
      default = EntityId()
    },
    TreeLeftLine = {
      default = EntityId()
    },
    TreeRightLine = {
      default = EntityId()
    },
    TreeMidLine1 = {
      default = EntityId()
    },
    TreeMidLine2 = {
      default = EntityId()
    }
  },
  LOCKED_ABILITY_ICON = "LyshineUI\\Images\\Icons\\Misc\\icon_lock_big.png",
  ABILITY_ICON_PATH = "lyShineui/images/icons/abilities/",
  abilitySlotCount = 3,
  isMasteryTutorialActive = false,
  abilitiesOnCooldown = false,
  progressionPointsChanged = false
}
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MasteryTreeWindow)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local AbilitiesCommon = RequireScript("LyShineUI._Common.AbilitiesCommon")
function MasteryTreeWindow:OnInit()
  BaseElement.OnInit(self)
  self.barWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ProgressBarFill)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    self.rootEntityId = rootEntityId
  end)
  for _, tree in pairs(self.MasteryTrees) do
    tree:SetNodeClickCallback(self.OnMasteryNodeClicked, self)
  end
  self.AbilitySelection:SetSelectionCallback(self, self.OnActiveAbilitySelected)
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_HERO)
  self.ConfirmButton:SetIsMarkupEnabled(true)
  self.ConfirmButton:SetCallback(self.OnConfirmClicked, self)
  self.ConfirmButton:SetSoundOnPress(self.audioHelper.WeaponMastery_TreeAbilitiesCommitted)
  self.RespecButton:SetText("@ui_respec")
  self.RespecButton:SetTextAlignment(self.RespecButton.TEXT_ALIGN_LEFT)
  self.RespecButton:SetCallback(self.OnRespecClicked, self)
  self.BackButton:SetText("@ui_back")
  self.BackButton:SetButtonSingleIconPath("lyshineui/images/icons/misc/icon_back.dds")
  self.BackButton:SetButtonSingleIconSize(16)
  self.BackButton:PositionButtonSingleIconToText()
  self.BackButton:SetCallback(self.BackClick, self)
  self.TreeTopLine:SetColor(self.UIStyle.COLOR_TAN)
  self.TreeLeftLine:SetColor(self.UIStyle.COLOR_TAN)
  self.TreeRightLine:SetColor(self.UIStyle.COLOR_TAN)
  self.TreeMidLine1:SetColor(self.UIStyle.COLOR_TAN)
  self.TreeMidLine2:SetColor(self.UIStyle.COLOR_TAN)
  self.isFTUE = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFTUE then
    DynamicBus.MasteryTree.Connect(self.entityId, self)
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
  local headerTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 30,
    fontColor = self.UIStyle.COLOR_TAN_MEDIUM_LIGHTER,
    characterSpacing = 75,
    textCasing = self.UIStyle.TEXT_CASING_UPPER,
    fontEffect = self.UIStyle.FONT_EFFECT_DROPSHADOW
  }
  local headerLabelTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 26,
    fontColor = self.UIStyle.COLOR_TAN,
    characterSpacing = 75,
    textCasing = self.UIStyle.TEXT_CASING_UPPER,
    fontEffect = self.UIStyle.FONT_EFFECT_DROPSHADOW
  }
  SetTextStyle(self.Properties.PointsAvailableLabel, headerTextStyle)
  SetTextStyle(self.Properties.AbilitiesTitle, headerLabelTextStyle)
  SetTextStyle(self.Properties.PowerText, headerLabelTextStyle)
  SetTextStyle(self.Properties.PowerFromText, self.UIStyle.FONT_STYLE_BODY_NEW_WHITE)
end
function MasteryTreeWindow:OnShutdown()
  if self.isFTUE then
    DynamicBus.MasteryTree.Disconnect(self.entityId, self)
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
end
function MasteryTreeWindow:IsNodeSelected(id)
  for _, tree in pairs(self.MasteryTrees) do
    for _, row in pairs(tree.Rows) do
      for _, node in pairs(row.Nodes) do
        if node.data.id == id then
          return node.STATE_SELECTED == node.state
        end
      end
    end
  end
end
function MasteryTreeWindow:GetVisible()
  return UiElementBus.Event.IsEnabled(self.entityId)
end
function MasteryTreeWindow:SetVisible(visible, masteryData)
  UiElementBus.Event.SetIsEnabled(self.entityId, visible)
  for _, tree in pairs(self.MasteryTrees) do
    tree:EnableTree(visible, masteryData and masteryData.tableNameId or "")
  end
  if visible then
    self.tableNameId = masteryData.tableNameId
    self.selectedAbilityIds = {}
    self.isFirstVisible = true
    self.progHandler = self:BusConnect(ProgressionPointsNotificationBus, self.playerEntityId)
    UiImageBus.Event.SetSpritePathname(self.Properties.WeaponIcon, masteryData.icon)
    UiTextBus.Event.SetTextWithFlags(self.Properties.WeaponTitle, masteryData.text, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TreeName1, masteryData.treeName1, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TreeName2, masteryData.treeName2, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.PowerFromText, masteryData.attribute, eUiTextSet_SetLocalized)
    local currentLevel = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, masteryData.tableNameId)
    local currentDisplayLevel = currentLevel + 1
    local maxRank = CategoricalProgressionRequestBus.Event.GetMaxRank(self.playerEntityId, masteryData.tableNameId)
    local levelText = GetLocalizedReplacementText("@ui_weapon_mastery_level", {
      level = currentDisplayLevel,
      maxLevel = maxRank + 1
    })
    UiTextBus.Event.SetText(self.Properties.Level, levelText)
    local unspentPoints = ProgressionPointRequestBus.Event.GetUnallocatedPoolPoints(self.playerEntityId, masteryData.tableNameId)
    self.totalUnspentPoints = unspentPoints
    self.availableUnspentPoints = unspentPoints
    UiTransformBus.Event.SetScale(self.Properties.PointsAvailableRing1, Vector2(1.1, 1.1))
    UiTransformBus.Event.SetScale(self.Properties.PointsAvailableRing2, Vector2(1.15, 1.15))
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PointsAvailableRing1, 105, {rotation = 0}, tweenerCommon.rotateCWInfinite)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PointsAvailableRing2, 90, {rotation = 0}, tweenerCommon.rotateCCWInfinite)
    self:UpdatePointsAvailable(true)
    self:UpdateConfirmButton()
    self:UpdateRespecButton()
    local currentProgress = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, masteryData.tableNameId)
    local requiredProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, masteryData.tableNameId, currentLevel)
    if 0 < requiredProgress then
      local barPercent = currentProgress / requiredProgress * self.barWidth
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.ProgressBarFill, barPercent)
    end
    if currentLevel < maxRank then
      local pointsText = GetLocalizedReplacementText("@ui_points_to_level", {
        points = requiredProgress - currentProgress,
        level = currentDisplayLevel + 1
      })
      UiTextBus.Event.SetText(self.Properties.ProgressionPoints, pointsText)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.ProgressionPoints, "@ui_weapon_mastered", eUiTextSet_SetLocalized)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.ProgressBarFill, self.barWidth)
    end
    self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Abilities.OnDataUpdate", function(self, onUpdate)
      self:UpdateBindedAbilities()
      self.isFirstVisible = false
    end)
    if self.Properties.AbilitySelection:IsValid() then
      self.AbilitySelection:SetVisibility(false)
    end
    self.TreeTopLine:SetVisible(false, 0)
    self.TreeTopLine:SetVisible(true, 0.6)
    self.TreeLeftLine:SetVisible(false, 0)
    self.TreeLeftLine:SetVisible(true, 0.9, {delay = 0.3})
    self.TreeRightLine:SetVisible(false, 0)
    self.TreeRightLine:SetVisible(true, 0.7, {delay = 0.4})
    self.TreeMidLine1:SetVisible(false, 0)
    self.TreeMidLine1:SetVisible(true, 1.3, {delay = 0.2})
    self.TreeMidLine2:SetVisible(false, 0)
    self.TreeMidLine2:SetVisible(true, 1.5, {delay = 0.3})
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
  else
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Abilities.OnDataUpdate")
    self:BusDisconnect(self.progHandler)
    self.progHandler = nil
    self.ScriptedEntityTweener:Stop(self.Properties.PointsAvailableRing1)
    self.ScriptedEntityTweener:Stop(self.Properties.PointsAvailableRing2)
    if self.tickBusHandler then
      self:BusDisconnect(self.tickBusHandler)
      self.tickBusHandler = nil
    end
    self.abilitiesOnCooldown = false
    self.progressionPointsChanged = false
  end
  if self.screenVisibleCallback and self.screenVisibleCallbackTable then
    self.screenVisibleCallback(self.screenVisibleCallbackTable, self, visible)
  end
end
function MasteryTreeWindow:UpdatePointsAvailable(forceAnimations)
  UiTextBus.Event.SetText(self.Properties.PointsAvailableNumber, self.availableUnspentPoints)
  local isPointsAvailableHighlighted = self.availableUnspentPoints > 0
  if self.isPointsAvailableHighlighted == isPointsAvailableHighlighted and not forceAnimations then
    return
  end
  self.isPointsAvailableHighlighted = isPointsAvailableHighlighted
  if self.isPointsAvailableHighlighted then
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableNumber, 0.3, {
      textColor = self.UIStyle.COLOR_MASTERY
    })
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableLabel, 0.3, {
      textColor = self.UIStyle.COLOR_TAN_MEDIUM_LIGHT
    })
    self.ScriptedEntityTweener:Play(self.Properties.WeaponIcon, 0.3, {
      imgColor = self.UIStyle.COLOR_TAN
    })
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableRing1, 0.45, {
      scaleX = 1,
      scaleY = 1,
      opacity = 0.16,
      ease = "QuadInOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableRing2, 0.5, {
      scaleX = 1,
      scaleY = 1,
      opacity = 0.14,
      ease = "QuadInOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableBg, 0.5, {
      imgColor = self.UIStyle.COLOR_MASTERY_DARK
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableNumber, 0.3, {
      textColor = self.UIStyle.COLOR_TAN_DARK
    })
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableLabel, 0.3, {
      textColor = self.UIStyle.COLOR_TAN
    })
    self.ScriptedEntityTweener:Play(self.Properties.WeaponIcon, 0.3, {
      imgColor = self.UIStyle.COLOR_TAN_DARK
    })
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableRing1, 0.55, {
      scaleX = 0.75,
      scaleY = 0.75,
      opacity = 0.11,
      ease = "QuadInOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableRing2, 0.5, {
      scaleX = 0.65,
      scaleY = 0.65,
      opacity = 0.1,
      ease = "QuadInOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableBg, 0.5, {
      imgColor = self.UIStyle.COLOR_GRAY_30
    })
  end
end
function MasteryTreeWindow:UpdateBindedAbilities()
  local abilities = CharacterAbilityRequestBus.Event.GetActiveAbilityMoveDataByAbilityTableId(self.playerEntityId, self.tableNameId)
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.abilityKeyBindings = {}
  local optionHintX = 0
  local optionHintMargin = 12
  for i = 1, self.abilitySlotCount do
    local slotIcon = self.Properties["Slot" .. i .. "Icon"]
    local slotIconBg = self.Properties["Slot" .. i .. "IconBg"]
    local slotIconFlashShort = self.Properties["Slot" .. i .. "IconFlashShort"]
    local slotIconFlashLong = self.Properties["Slot" .. i .. "IconFlashLong"]
    local slotBinding = self["Slot" .. i .. "Key"]
    local slotOptionHint = self["SlotOptionHint" .. i]
    if i < #abilities then
      if abilities[i] then
        self.ScriptedEntityTweener:Set(slotIcon, {opacity = 1})
        local currentIcon = string.lower(UiImageBus.Event.GetSpritePathname(slotIcon))
        local displayIcon = string.lower(self.ABILITY_ICON_PATH .. abilities[i].displayIcon .. ".dds")
        if currentIcon ~= displayIcon and not self.isFirstVisible then
          self.ScriptedEntityTweener:Stop(slotIconFlashShort)
          self.ScriptedEntityTweener:Stop(slotIconFlashLong)
          self.ScriptedEntityTweener:Play(slotIconFlashShort, 0.1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
          self.ScriptedEntityTweener:Play(slotIconFlashLong, 0.1, {opacity = 0, scaleY = 0.6}, {
            opacity = 1,
            scaleY = 1,
            ease = "QuadOut"
          })
          self.ScriptedEntityTweener:Play(slotIconFlashShort, 1, {opacity = 1}, {
            opacity = 0,
            ease = "QuadOut",
            delay = 0.1
          })
          self.ScriptedEntityTweener:Play(slotIconFlashLong, 1, {opacity = 1}, {
            opacity = 0,
            ease = "QuadOut",
            delay = 0.1
          })
        end
        UiImageBus.Event.SetSpritePathname(slotIcon, displayIcon)
        UiElementBus.Event.SetIsEnabled(slotIconBg, true)
        local bgPath = AbilitiesCommon:GetBackgroundPath(abilities[i].uiCategory)
        UiImageBus.Event.SetSpritePathname(slotIconBg, bgPath)
      else
        UiImageBus.Event.SetSpritePathname(slotIcon, AbilitiesCommon.emptyIcon)
        UiElementBus.Event.SetIsEnabled(slotIconBg, false)
      end
    else
      UiElementBus.Event.SetIsEnabled(slotIcon, true)
      self.ScriptedEntityTweener:Set(slotIcon, {opacity = 0.3})
      UiImageBus.Event.SetSpritePathname(slotIcon, self.LOCKED_ABILITY_ICON)
      UiElementBus.Event.SetIsEnabled(slotIconBg, false)
    end
    slotBinding:SetActionMap("player")
    slotBinding:SetKeybindMapping("ability" .. i)
    slotOptionHint:SetActionMap("player")
    slotOptionHint:SetKeybindMapping("ability" .. i)
    UiTransformBus.Event.SetLocalPositionX(slotOptionHint.entityId, optionHintX)
    optionHintX = optionHintX + optionHintMargin + slotOptionHint:GetWidth()
    local keybinding = LyShineManagerBus.Broadcast.GetKeybind("ability" .. i, "player")
    self.abilityKeyBindings[i] = keybinding
  end
  optionHintX = optionHintX - optionHintMargin
  UiTransformBus.Event.SetLocalPositionX(self.Properties.SlotOptionHintContainer, -optionHintX / 2)
end
function MasteryTreeWindow:OnActiveAbilitySelected(abilityId, abilityIndex)
  local abilityData = CharacterAbilityRequestBus.Event.GetAbilityData(self.playerEntityId, self.tableNameId, abilityId)
  local slotIcon = self.Properties["Slot" .. abilityIndex + 1 .. "Icon"]
  local slotIconBg = self.Properties["Slot" .. abilityIndex + 1 .. "IconBg"]
  UiElementBus.Event.SetIsEnabled(slotIcon, abilityData ~= nil)
  UiElementBus.Event.SetIsEnabled(slotIconBg, abilityData ~= nil)
  if abilityData then
    self.ScriptedEntityTweener:Set(slotIcon, {opacity = 1})
    local bgPath = AbilitiesCommon:GetBackgroundPath(abilityData.uiCategory)
    UiImageBus.Event.SetSpritePathname(slotIconBg, bgPath)
    local displayIcon = self.ABILITY_ICON_PATH .. abilityData.displayIcon .. ".png"
    UiImageBus.Event.SetSpritePathname(slotIcon, displayIcon)
    self.audioHelper:PlaySound(self.audioHelper.AbilityAssigned)
  end
end
function MasteryTreeWindow:OnAbilityClick(entityId)
  if self.isMasteryTutorialActive then
    return
  end
  local abilityIndex
  if entityId == self.Properties.AbilitySlot1 then
    abilityIndex = 0
  elseif entityId == self.Properties.AbilitySlot2 then
    abilityIndex = 1
  elseif entityId == self.Properties.AbilitySlot3 then
    abilityIndex = 2
  end
  if self.Properties.AbilitySelection:IsValid() and abilityIndex then
    self.AbilitySelection:SetAbilitySource(nil, abilityIndex, self.tableNameId)
    self.audioHelper:PlaySound(self.audioHelper.AbilitySlotClicked)
    local abilityWidth = UiTransform2dBus.Event.GetLocalWidth(entityId)
    local offset = GetOffsetFrom(entityId, self.entityId)
    offset.x = offset.x + abilityWidth
    UiTransformBus.Event.SetLocalPosition(self.Properties.AbilitySelection, offset)
  end
end
function MasteryTreeWindow:OnAbilityFocus(entityId)
  self.ScriptedEntityTweener:PlayC(entityId, 0.3, tweenerCommon.imgToWhite)
  self.audioHelper:PlaySound(self.audioHelper.AbilitySlotHovered)
end
function MasteryTreeWindow:OnAbilityUnfocus(entityId)
  self.ScriptedEntityTweener:PlayC(entityId, 0.3, tweenerCommon.imgToGray70)
end
function MasteryTreeWindow:OnMasteryNodeClicked(nodeTable, abilityIdCrc, nodeState)
  if nodeState == nodeTable.STATE_AVAILABLE and self.availableUnspentPoints > 0 then
    self.selectedAbilityIds[tostring(abilityIdCrc)] = abilityIdCrc
    self.availableUnspentPoints = self.availableUnspentPoints - 1
  elseif nodeState == nodeTable.STATE_SELECTED then
    self.selectedAbilityIds[tostring(abilityIdCrc)] = nil
    self.availableUnspentPoints = self.availableUnspentPoints + 1
  elseif nodeState == nodeTable.STATE_OWNED then
    if nodeTable:GetType() == nodeTable.TYPE_SLOTTABLE then
      self:ShowSlotOptions(nodeTable, abilityIdCrc)
    end
    return
  else
    return
  end
  for _, tree in pairs(self.MasteryTrees) do
    tree:RefreshStatus(self.availableUnspentPoints, self.selectedAbilityIds)
  end
  local numSelectedAbilities = 0
  for abilityId, _ in pairs(self.selectedAbilityIds) do
    numSelectedAbilities = numSelectedAbilities + 1
  end
  self.availableUnspentPoints = self.totalUnspentPoints - numSelectedAbilities
  self:UpdateConfirmButton()
  self:UpdatePointsAvailable()
end
function MasteryTreeWindow:OnConfirmClicked()
  local updatedAbilities = false
  for _, tree in pairs(self.MasteryTrees) do
    local treeAbilityData = tree:GetAbilityData()
    for i = 0, #treeAbilityData do
      local updatesInRow = 0
      local rowData = treeAbilityData[i]
      for j = 1, #rowData do
        local abilityIdString = tostring(rowData[j].id)
        if self.selectedAbilityIds[abilityIdString] then
          local abilityIdCrc = self.selectedAbilityIds[abilityIdString]
          CharacterAbilityRequestBus.Event.SpendPointsOnAbility(self.playerEntityId, self.tableNameId, abilityIdCrc, 1)
          updatedAbilities = true
          updatesInRow = updatesInRow + 1
        end
      end
      if 0 < updatesInRow then
        CharacterAbilityRequestBus.Event.ApplyAbilityChanges(self.playerEntityId)
      end
    end
  end
  if not updatedAbilities then
    return
  end
  self.selectedAbilityIds = {}
  self.totalUnspentPoints = self.availableUnspentPoints
  self:UpdateConfirmButton()
end
function MasteryTreeWindow:UpdateConfirmButton()
  local spentPoints = self.totalUnspentPoints - self.availableUnspentPoints
  local buttonText = "@ui_no_points_spent"
  if 1 < spentPoints then
    buttonText = GetLocalizedReplacementText("@ui_commit_points", {points = spentPoints})
  elseif spentPoints == 1 then
    buttonText = "@ui_commit_1_point"
  end
  self.ConfirmButton:SetText(buttonText)
  if CooldownTimersComponentBus.Event.AnyCooldownTimer(self.rootEntityId) then
    self.ConfirmButton:SetEnabled(false)
    self.ConfirmButton:SetTooltip("@ui_respec_cooldown_error")
  elseif 0 < spentPoints then
    self.ConfirmButton:SetTooltip("")
    self.ConfirmButton:SetEnabled(true)
  else
    self.ConfirmButton:SetTooltip("")
    self.ConfirmButton:SetEnabled(false)
  end
end
function MasteryTreeWindow:ShowSlotOptions(nodeTable, abilityIdCrc)
  if self.isSlotOptionsVisible then
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  self.isSlotOptionsVisible = true
  UiElementBus.Event.SetIsEnabled(self.Properties.SlotOptions, true)
  self.assigningAbilityId = abilityIdCrc
  local additionalYOffset = 24
  local offset = GetOffsetFrom(nodeTable.entityId, self.entityId)
  offset.y = offset.y + 24
  UiTransformBus.Event.SetLocalPosition(self.Properties.SlotOptions, offset)
  self.keyInputHandler = self:BusConnect(KeyInputNotificationBus)
  nodeTable:SetUnfocusCallback(self.CloseSlotOptions, self)
end
function MasteryTreeWindow:CloseSlotOptions(nodeTable)
  self.isSlotOptionsVisible = false
  UiElementBus.Event.SetIsEnabled(self.Properties.SlotOptions, false)
  self:BusDisconnect(self.keyInputHandler)
  if nodeTable then
    nodeTable:SetUnfocusCallback(nil, nil)
  end
  self.assigningAbilityId = nil
end
function MasteryTreeWindow:OnKeyPressed(key)
  for i = 1, #self.abilityKeyBindings do
    if key == self.abilityKeyBindings[i] then
      if CooldownTimersComponentBus.Event.AnyCooldownTimer(self.rootEntityId) then
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = "@ui_ability_cooldown_error"
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      else
        local selectedTableIndex = CharacterAbilityRequestBus.Event.GetSelectedTableIndexFromTableName(self.playerEntityId, self.tableNameId)
        CharacterAbilityRequestBus.Event.RequestChangeMappedAbility(self.playerEntityId, selectedTableIndex, i - 1, self.assigningAbilityId)
        self:OnActiveAbilitySelected(self.assigningAbilityId, i - 1)
        self:CloseSlotOptions()
        return
      end
    end
  end
end
function MasteryTreeWindow:OnProgressionPointsChanged(pointId, oldLevel, newLevel)
  self.progressionPointsChanged = true
  if not self.tickBusHandler then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function MasteryTreeWindow:OnTick()
  if self.abilitiesOnCooldown then
    self.abilitiesOnCooldown = CooldownTimersComponentBus.Event.AnyCooldownTimer(self.rootEntityId)
    if not self.progressionPointsChanged then
      return
    end
  end
  self.progressionPointsChanged = false
  self:BusDisconnect(self.tickBusHandler)
  self.tickBusHandler = nil
  self.totalUnspentPoints = ProgressionPointRequestBus.Event.GetUnallocatedPoolPoints(self.playerEntityId, self.tableNameId)
  local numSelectedAbilities = 0
  for abilityId, _ in pairs(self.selectedAbilityIds) do
    numSelectedAbilities = numSelectedAbilities + 1
  end
  self.availableUnspentPoints = self.totalUnspentPoints - numSelectedAbilities
  self:UpdatePointsAvailable()
  self:UpdateRespecButton()
  self:UpdateConfirmButton()
  for _, tree in pairs(self.MasteryTrees) do
    tree:RefreshStatus(self.availableUnspentPoints, self.selectedAbilityIds)
  end
end
function MasteryTreeWindow:UpdateRespecButton()
  self.azothCost = 0
  local ownedAzoth = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothAmount") or 0
  local currentRank = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, self.tableNameId)
  local rankData = CategoricalProgressionRequestBus.Event.GetRankData(self.playerEntityId, self.tableNameId, currentRank)
  if rankData then
    self.azothCost = rankData.azothRespecCost
  end
  self.AzothTextContainer:SetValues(ownedAzoth, self.azothCost)
  local spentPoints = ProgressionPointRequestBus.Event.GetNumAllocatedPoolPoints(self.playerEntityId, self.tableNameId)
  local showRespec = 0 < spentPoints
  self.abilitiesOnCooldown = CooldownTimersComponentBus.Event.AnyCooldownTimer(self.rootEntityId)
  local canRespec = showRespec and ownedAzoth >= self.azothCost and not self.abilitiesOnCooldown
  if self.isMasteryTutorialActive then
    showRespec = false
  end
  local errorMsg = "@ui_weapon_mastery_insufficient_azoth"
  if self.abilitiesOnCooldown then
    errorMsg = "@ui_respec_cooldown_error"
    if not self.tickBusHandler then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  end
  self.RespecButton:SetEnabled(canRespec)
  self.RespecButton:SetTooltip(canRespec and "@ui_respec_mastery" or errorMsg)
  UiElementBus.Event.SetIsEnabled(self.Properties.RespecButton, showRespec)
  UiElementBus.Event.SetIsEnabled(self.Properties.AzothTextContainer, showRespec)
  if self.azothCost == 0 and showRespec then
    UiElementBus.Event.SetIsEnabled(self.Properties.FreeText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.AzothTextContainer, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.FreeText, false)
  end
end
function MasteryTreeWindow:SetBackClick(clickTable, clickFunc)
  self.clickTable = clickTable
  self.clickFunc = clickFunc
end
function MasteryTreeWindow:BackClick()
  self.clickFunc(self.clickTable)
end
function MasteryTreeWindow:OnRespecClicked()
  local respecDesc = GetLocalizedReplacementText("@ui_weapon_mastery_respec_warning", {
    azoth = GetFormattedNumber(self.azothCost)
  })
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_respec_warning_title", respecDesc, "weapon_mastery_respec_id", self, self.OnPopupResult)
  self.AbilitySelection:SetVisibility(false)
end
function MasteryTreeWindow:OnPopupResult(result, eventId)
  if eventId == "weapon_mastery_respec_id" and result == ePopupResult_Yes then
    local selectedTableIndex = CharacterAbilityRequestBus.Event.GetSelectedTableIndexFromTableName(self.playerEntityId, self.tableNameId)
    CharacterAbilityRequestBus.Event.RequestMasteryTreeRespec(self.playerEntityId, selectedTableIndex, false)
    self:UpdateConfirmButton()
  end
end
function MasteryTreeWindow:SetScreenVisibleCallback(callbackFn, callbackTable)
  self.screenVisibleCallback = callbackFn
  self.screenVisibleCallbackTable = callbackTable
end
function MasteryTreeWindow:SetMasteryTutorialActive(isActive)
  self.isMasteryTutorialActive = isActive
  self.BackButton:SetEnabled(not isActive)
end
return MasteryTreeWindow

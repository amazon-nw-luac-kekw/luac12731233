local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local ObjectiveDetails = {
  Properties = {
    Background = {
      default = EntityId()
    },
    ObjectiveTitle = {
      default = EntityId()
    },
    RewardListContainer = {
      default = EntityId()
    },
    RewardListItems = {
      default = {
        EntityId()
      }
    },
    WideRewardListContainer = {
      default = EntityId()
    },
    WideRewardListItems = {
      default = {
        EntityId()
      }
    },
    ItemRewardContainer = {
      default = EntityId()
    },
    ItemRewardLayout = {
      default = EntityId()
    },
    ItemRewardLayoutScale = {
      default = EntityId()
    },
    ItemRewardName = {
      default = EntityId()
    },
    RecipeRewardContainer = {
      default = EntityId()
    },
    RecipeRewardLayout = {
      default = EntityId()
    },
    RecipeRewardName = {
      default = EntityId()
    },
    RewardLabel = {
      default = EntityId()
    },
    ItemRewardNameBig = {
      default = EntityId()
    },
    FlashLine1 = {
      default = EntityId()
    },
    FlashLine2 = {
      default = EntityId()
    },
    FlashGlow = {
      default = EntityId()
    },
    FlashLight = {
      default = EntityId()
    },
    FlashContainer = {
      default = EntityId()
    },
    Effect = {
      default = EntityId()
    },
    Pulse1 = {
      default = EntityId()
    },
    Pulse2 = {
      default = EntityId()
    }
  },
  isItemRewardShowing = false,
  targetHeightWithTwoItem = 166,
  targetHeightWithOneItemTall = 160,
  targetHeightWithOneItem = 128,
  targetHeightWithoutItem = 100,
  animInDelay = 0,
  animOutDelay = 0,
  showAnimLength = 2,
  hideAnimLength = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ObjectiveDetails)
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local GetTranslatedOffsets = function(offset, x, y)
  return UiOffsets(offset.left + x, offset.top + y, offset.right + x, offset.bottom + y)
end
function ObjectiveDetails:OnInit()
  self.ItemRewardLayout:SetTooltipEnabled(true)
  self.RecipeRewardLayout:SetTooltipEnabled(true)
  self.itemContainerWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ItemRewardContainer)
  self.recipeContainerWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.RecipeRewardContainer)
  SetTextStyle(self.Properties.ObjectiveTitle, self.UIStyle.FONT_STYLE_BODY)
  UiTextBus.Event.SetColor(self.Properties.ObjectiveTitle, self.UIStyle.COLOR_FLAVOR_TEXT)
  SetTextStyle(self.Properties.ItemRewardName, self.UIStyle.FONT_STYLE_BODY)
  self.recipeOffsetsWithItem = UiTransform2dBus.Event.GetOffsets(self.Properties.RecipeRewardContainer)
  self.recipeOffsetsWithoutItem = UiTransform2dBus.Event.GetOffsets(self.Properties.ItemRewardContainer)
  self.recipeOffsetsWithoutItem.right = self.recipeOffsetsWithoutItem.left + self.recipeContainerWidth
  self.rewardListOffsetsWithTwoItem = UiTransform2dBus.Event.GetOffsets(self.Properties.RewardListContainer)
  self.rewardListOffsetsWithItem = UiOffsets(0, 0, 0, 0)
  self.rewardListOffsetsWithItem.top = self.recipeOffsetsWithItem.top
  self.rewardListOffsetsWithItem.right = self.recipeOffsetsWithItem.right
  self.rewardListOffsetsWithItem.bottom = self.recipeOffsetsWithItem.bottom
  local gridMargin = 6
  self.rewardListOffsetsWithItem.left = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ItemRewardContainer) + gridMargin
  self.rewardListOffsetsWithRecipe = UiOffsets(0, 0, 0, 0)
  self.rewardListOffsetsWithRecipe.top = self.recipeOffsetsWithItem.top
  self.rewardListOffsetsWithRecipe.right = self.recipeOffsetsWithItem.right
  self.rewardListOffsetsWithRecipe.bottom = self.recipeOffsetsWithItem.bottom
  self.rewardListOffsetsWithRecipe.left = UiTransform2dBus.Event.GetLocalWidth(self.Properties.RecipeRewardContainer) + gridMargin
  self.wideRewardsListYOffset = UiTransform2dBus.Event.GetLocalHeight(self.Properties.WideRewardListContainer)
  SetTextStyle(self.Properties.RewardLabel, self.UIStyle.FONT_STYLE_OBJECTIVE_DETAILS_REWARD_LABEL)
  SetTextStyle(self.Properties.ItemRewardNameBig, self.UIStyle.FONT_STYLE_OBJECTIVE_DETAILS_REWARD_NAME)
end
function ObjectiveDetails:SetConversationState(stateData)
  local objectiveData = ObjectivesDataManagerBus.Broadcast.GetObjectiveData(stateData.dialogueId)
  if not objectiveData or objectiveData.id == "" then
    self:SetIsVisible(false)
    return
  end
  local rewards = ObjectiveDataHelper:GetRewardDataFromObjectiveData(objectiveData)
  local showRewards = 0 < #rewards and (stateData.responseType == eConversationResponseType_Proposal or stateData.responseType == eConversationResponseType_CompletionAvailable)
  if showRewards then
    UiTextBus.Event.SetTextWithFlags(self.Properties.ObjectiveTitle, stateData.responseType == eConversationResponseType_CompletionAvailable and "@objective_rewards_completion" or "@objective_rewards_proposal", eUiTextSet_SetLocalized)
    local layoutIndex = 0
    local numRewards = #rewards
    local wideRewardLayoutId = self.Properties.WideRewardListItems[0]
    local wideRewardLayout = self.registrar:GetEntityTable(wideRewardLayoutId)
    local usingWideRewards = false
    self.isItemRewardShowing = false
    self.isRecipeRewardShowing = false
    self.smallRewards = 0
    for i = 1, numRewards do
      local rewardData = rewards[i]
      local rewardLayoutId = self.Properties.RewardListItems[layoutIndex]
      local rewardLayout = self.registrar:GetEntityTable(rewardLayoutId)
      if rewardData.type == ObjectiveDataHelper.REWARD_TYPES.ITEM then
        self.isItemRewardShowing = true
        self.ItemRewardLayout:SetItemByName(rewardData.value)
        local itemLayoutWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ItemRewardLayout)
        local margin = 12
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.ItemRewardName, self.itemContainerWidth - itemLayoutWidth - margin)
        local itemName = StaticItemDataManager:GetItemName(rewardData.value)
        UiTextBus.Event.SetTextWithFlags(self.Properties.ItemRewardName, itemName, eUiTextSet_SetLocalized)
        UiTextBus.Event.SetTextWithFlags(self.Properties.ItemRewardNameBig, itemName, eUiTextSet_SetLocalized)
      elseif rewardData.type == ObjectiveDataHelper.REWARD_TYPES.RECIPE then
        self.isRecipeRewardShowing = true
        local recipeData = RecipeDataManagerBus.Broadcast.GetCraftingRecipeDataById(rewardData.value)
        local isProcedural = RecipeDataManagerBus.Broadcast.IsRecipeProcedural(recipeData.id)
        local displayName, resultItemId
        if isProcedural then
          displayName = recipeData.name
          local ingredients = vector_Crc32()
          resultItemId = CraftingRequestBus.Broadcast.GetProceduralCraftingResult(recipeData.id, vector_Crc32())
        else
          resultItemId = Math.CreateCrc32(recipeData.resultItemId)
          local itemData = ItemDataManagerBus.Broadcast.GetItemData(resultItemId)
          displayName = itemData.displayName
        end
        local displayText = GetLocalizedReplacementText("@reward_new_recipe", {name = displayName})
        UiTextBus.Event.SetTextWithFlags(self.Properties.RecipeRewardName, displayText, eUiTextSet_SetLocalized)
        local itemDescriptor = ItemDescriptor()
        itemDescriptor.itemId = resultItemId
        self.RecipeRewardLayout:SetItemByDescriptor(itemDescriptor)
        local itemLayoutWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.RecipeRewardLayout)
        local margin = 12
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.RecipeRewardName, self.recipeContainerWidth - itemLayoutWidth - margin)
      elseif rewardData.type == ObjectiveDataHelper.REWARD_TYPES.CATEGORICAL and rewardData.shouldShowAsObjectiveReward then
        UiElementBus.Event.SetIsEnabled(wideRewardLayoutId, true)
        wideRewardLayout:SetRewardType(rewardData.type, rewardData.displayName, rewardData.iconPath)
        wideRewardLayout:SetRewardValue(rewardData.displayValue .. " " .. LyShineScriptBindRequestBus.Broadcast.LocalizeText(rewardData.displayName))
        usingWideRewards = true
      elseif rewardData.type ~= ObjectiveDataHelper.REWARD_TYPES.CATEGORICAL then
        UiElementBus.Event.SetIsEnabled(rewardLayoutId, true)
        rewardLayout:SetRewardType(rewardData.type)
        rewardLayout:SetRewardValue(rewardData.value)
        layoutIndex = layoutIndex + 1
        self.smallRewards = self.smallRewards + 1
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemRewardContainer, self.isItemRewardShowing)
    UiElementBus.Event.SetIsEnabled(self.Properties.RecipeRewardContainer, self.isRecipeRewardShowing)
    for i = layoutIndex, #self.Properties.RewardListItems do
      UiElementBus.Event.SetIsEnabled(self.Properties.RewardListItems[i], false)
    end
    if not usingWideRewards then
      UiElementBus.Event.SetIsEnabled(self.Properties.WideRewardListItems[0], false)
    end
    if self.isItemRewardShowing and self.isRecipeRewardShowing then
      self.targetHeight = self.targetHeightWithTwoItem + (usingWideRewards and self.wideRewardsListYOffset or 0)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.ItemRewardContainer, 0)
      UiTransform2dBus.Event.SetOffsets(self.Properties.RecipeRewardContainer, self.recipeOffsetsWithItem)
      if usingWideRewards then
        UiTransform2dBus.Event.SetOffsets(self.Properties.WideRewardListContainer, self.rewardListOffsetsWithTwoItem)
        UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, GetTranslatedOffsets(self.rewardListOffsetsWithTwoItem, 0, self.wideRewardsListYOffset))
      else
        UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, self.rewardListOffsetsWithTwoItem)
      end
    elseif self.isItemRewardShowing or self.isRecipeRewardShowing then
      local usingExtraLineForWideRewards = false
      if self.isRecipeRewardShowing then
        UiTransform2dBus.Event.SetOffsets(self.Properties.RecipeRewardContainer, self.recipeOffsetsWithoutItem)
        if usingWideRewards and self.smallRewards < 3 then
          UiTransform2dBus.Event.SetOffsets(self.Properties.WideRewardListContainer, self.rewardListOffsetsWithRecipe)
          UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, GetTranslatedOffsets(self.rewardListOffsetsWithRecipe, 0, self.wideRewardsListYOffset))
        elseif usingWideRewards then
          local extraYOffsetForWideRewards = 0
          if self.smallRewards > 4 then
            extraYOffsetForWideRewards = self.targetHeightWithOneItemTall - self.targetHeightWithOneItem
          end
          UiTransform2dBus.Event.SetOffsets(self.Properties.WideRewardListContainer, GetTranslatedOffsets(self.rewardListOffsetsWithTwoItem, 0, extraYOffsetForWideRewards))
          UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, self.rewardListOffsetsWithRecipe)
          usingExtraLineForWideRewards = true
        elseif self.smallRewards < 3 then
          UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, self.rewardListOffsetsWithRecipe)
          UiTransformBus.Event.SetLocalPositionY(self.Properties.RewardListContainer, 14)
        else
          UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, self.rewardListOffsetsWithRecipe)
          UiTransformBus.Event.SetLocalPositionY(self.Properties.RewardListContainer, 0)
        end
      elseif usingWideRewards and self.smallRewards < 4 then
        UiTransform2dBus.Event.SetOffsets(self.Properties.WideRewardListContainer, self.rewardListOffsetsWithItem)
        UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, GetTranslatedOffsets(self.rewardListOffsetsWithItem, 0, self.wideRewardsListYOffset))
      elseif usingWideRewards then
        UiTransform2dBus.Event.SetOffsets(self.Properties.WideRewardListContainer, self.rewardListOffsetsWithTwoItem)
        UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, self.rewardListOffsetsWithItem)
        usingExtraLineForWideRewards = true
      elseif self.smallRewards < 4 then
        UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, self.rewardListOffsetsWithItem)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RewardListContainer, 14)
      else
        UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, self.rewardListOffsetsWithItem)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RewardListContainer, 0)
      end
      if self.isRecipeRewardShowing and self.smallRewards > 4 then
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RecipeRewardContainer, 14)
        self.targetHeight = self.targetHeightWithOneItemTall
      else
        UiTransformBus.Event.SetLocalPositionY(self.Properties.RecipeRewardContainer, 0)
        self.targetHeight = self.targetHeightWithOneItem
      end
      if usingExtraLineForWideRewards then
        self.targetHeight = self.targetHeight + (self.targetHeightWithTwoItem - self.targetHeightWithOneItem)
      end
    elseif usingWideRewards then
      UiTransform2dBus.Event.SetOffsets(self.Properties.WideRewardListContainer, self.rewardListOffsetsWithTwoItem)
      UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, self.rewardListOffsetsWithTwoItem)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.WideRewardListContainer, 0)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.RewardListContainer, self.wideRewardsListYOffset)
      self.targetHeight = self.targetHeightWithoutItem + self.wideRewardsListYOffset
    else
      UiTransform2dBus.Event.SetOffsets(self.Properties.RewardListContainer, self.rewardListOffsetsWithTwoItem)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.RewardListContainer, 0)
      self.targetHeight = self.targetHeightWithoutItem
    end
  end
  self:SetIsVisible(showRewards)
end
function ObjectiveDetails:SetIsVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  local height = 0
  if isVisible then
    height = self.targetHeight
  end
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, height)
  if isVisible then
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.4, {opacity = 0}, tweenerCommon.fadeInQuadOut, self.animInDelay)
    local rewardDelay = self.animInDelay
    local animStagger = 0.1
    if self.isItemRewardShowing then
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ItemRewardContainer, 0.2, {opacity = 0}, tweenerCommon.fadeInQuadOut, rewardDelay)
      rewardDelay = rewardDelay + animStagger
    end
    if self.isRecipeRewardShowing then
      self.ScriptedEntityTweener:PlayFromC(self.Properties.RecipeRewardContainer, 0.2, {opacity = 0}, tweenerCommon.fadeInQuadOut, rewardDelay)
      rewardDelay = rewardDelay + animStagger
    end
    for i = 0, #self.Properties.RewardListItems do
      local rewardLayout = self.RewardListItems[i]
      if UiElementBus.Event.IsEnabled(rewardLayout.entityId) then
        TimingUtils:Delay(self.entityId, rewardDelay, function()
          self.audioHelper:PlaySound(self.audioHelper.Mission_Reward)
        end)
        rewardLayout:AnimateIn(rewardDelay)
        rewardDelay = rewardDelay + animStagger
      end
    end
    for i = 0, #self.Properties.WideRewardListItems do
      local wideRewardLayout = self.WideRewardListItems[i]
      if UiElementBus.Event.IsEnabled(wideRewardLayout.entityId) then
        TimingUtils:Delay(self.entityId, rewardDelay, function()
          self.audioHelper:PlaySound(self.audioHelper.Mission_Reward)
        end)
        wideRewardLayout:AnimateIn(rewardDelay)
        rewardDelay = rewardDelay + animStagger
      end
    end
    TimingUtils:Delay(self.entityId, self.animInDelay + 0.4, function()
      self.audioHelper:PlaySound(self.audioHelper.ObjectiveDetails)
    end)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.Background, 0.3, {scaleX = 0}, tweenerCommon.scaleXTo1)
    self.ScriptedEntityTweener:PlayC(self.Properties.ObjectiveTitle, 0.15, tweenerCommon.fadeInQuadOut, self.animInDelay + 0.1)
  else
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.3, tweenerCommon.fadeOutQuadIn, self.animOutDelay)
  end
end
function ObjectiveDetails:PlayRewardCelebration()
  self.ScriptedEntityTweener:Play(self.entityId, 0.2, {
    layoutTargetHeight = 160,
    ease = "QuadOut",
    delay = 0.3
  })
  self.ScriptedEntityTweener:Play(self.Properties.ObjectiveTitle, 0.4, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.3
  })
  self.ScriptedEntityTweener:Play(self.Properties.RewardListContainer, 0.4, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.3
  })
  self.ScriptedEntityTweener:Play(self.Properties.WideRewardListContainer, 0.4, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.3
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemRewardName, 0.4, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.3
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemRewardLayoutScale, 0.2, {scaleY = 1, scaleX = 1}, {
    scaleY = 1.6,
    scaleX = 1.6,
    ease = "QuadOut",
    delay = 0.3
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemRewardLayoutScale, 0.2, {
    y = 17,
    ease = "QuadOut",
    delay = 0.3
  })
  UiElementBus.Event.SetIsEnabled(self.Properties.RewardLabel, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemRewardNameBig, true)
  self.ScriptedEntityTweener:Play(self.Properties.RewardLabel, 0.2, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.5
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemRewardNameBig, 0.2, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.5
  })
  self.ScriptedEntityTweener:Stop(self.Properties.FlashContainer)
  self.ScriptedEntityTweener:Stop(self.Properties.FlashLine1)
  self.ScriptedEntityTweener:Stop(self.Properties.FlashLine2)
  self.ScriptedEntityTweener:Stop(self.Properties.FlashGlow)
  self.ScriptedEntityTweener:Stop(self.Properties.FlashLight)
  self.ScriptedEntityTweener:Stop(self.Properties.Effect)
  self.ScriptedEntityTweener:Stop(self.Properties.Pulse1)
  self.ScriptedEntityTweener:Stop(self.Properties.Pulse2)
  self.ScriptedEntityTweener:PlayC(self.Properties.FlashLine1, 0, tweenerCommon.flashStart)
  self.ScriptedEntityTweener:PlayC(self.Properties.FlashLine2, 0, tweenerCommon.flashStart)
  UiElementBus.Event.SetIsEnabled(self.Properties.FlashContainer, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.Effect, false)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine1, 0.4, {x = -1200, opacity = 0}, tweenerCommon.flashEnd)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine1, 0.5, {opacity = 1}, tweenerCommon.fadeOutHalfSec, 0.4)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine1, 0.5, {scaleY = 2.5}, tweenerCommon.flashScaleUp, 0.28, function()
    self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine1, 0.5, {scaleY = 3.5}, tweenerCommon.flashScaleDown)
  end)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine2, 0.4, {x = -1200, opacity = 0}, tweenerCommon.flashEnd)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine2, 0.5, {opacity = 1}, tweenerCommon.fadeOutHalfSec, 0.4)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine2, 0.5, {scaleY = 2.5}, tweenerCommon.flashScaleUp, 0.28, function()
    self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLine2, 0.5, {scaleY = 3.5}, tweenerCommon.flashScaleDown)
  end)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashGlow, 0.1, {opacity = 0}, tweenerCommon.flashGlowIn, 0.2, function()
    self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashGlow, 0.83, {opacity = 1}, tweenerCommon.flashGlowOut)
  end)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLight, 0.1, {opacity = 0}, tweenerCommon.flashGlowIn, 0.2, function()
    self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLight, 0.83, {opacity = 1}, tweenerCommon.flashGlowOut)
  end)
  self.ScriptedEntityTweener:PlayC(self.Properties.Effect, 0.2, tweenerCommon.flashEffectPosYTo0, 0, function()
    UiElementBus.Event.SetIsEnabled(self.Properties.Effect, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.Effect, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.Effect)
  end)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.Effect, 0.65, {opacity = 1}, tweenerCommon.flashEffectOut, 0.78, function()
    UiFlipbookAnimationBus.Event.Stop(self.Properties.Effect)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.Effect, 0)
    UiElementBus.Event.SetIsEnabled(self.Properties.Effect, false)
  end)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.Pulse1, 1.2, {
    scaleX = 0,
    scaleY = 0,
    opacity = 1
  }, tweenerCommon.pulseShow, 0.2)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.Pulse2, 1.2, {
    scaleX = 0,
    scaleY = 0,
    opacity = 1
  }, tweenerCommon.pulseShow, 0.35)
  self.ScriptedEntityTweener:PlayC(self.Properties.FlashContainer, self.showAnimLength, tweenerCommon.flashContainerY, 0, function()
    UiElementBus.Event.SetIsEnabled(self.Properties.FlashContainer, false)
  end)
end
function ObjectiveDetails:HideCelebration(playWhoosh, animDuration)
  self.ScriptedEntityTweener:Stop(self.entityId)
  if animDuration == nil then
    animDuration = self.hideAnimLength
  end
  self.ScriptedEntityTweener:Play(self.entityId, animDuration, {opacity = 1}, {
    opacity = 0,
    onComplete = function()
      self:ResetObjectiveDetailsElement()
    end
  })
  if playWhoosh then
    DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation()
  end
end
function ObjectiveDetails:ResetObjectiveDetailsElement()
  self.ScriptedEntityTweener:Set(self.entityId, {
    layoutTargetHeight = self.targetHeight,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Set(self.Properties.RewardListContainer, {opacity = 1})
  self.ScriptedEntityTweener:Set(self.Properties.WideRewardListContainer, {opacity = 1})
  self.ScriptedEntityTweener:Set(self.Properties.ItemRewardName, {opacity = 1})
  self.ScriptedEntityTweener:Set(self.Properties.ItemRewardLayoutScale, {y = 0})
  self.ScriptedEntityTweener:Set(self.Properties.ItemRewardLayoutScale, {scaleX = 1, scaleY = 1})
  self.ScriptedEntityTweener:Set(self.Properties.RewardLabel, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.ItemRewardNameBig, {opacity = 0})
  UiElementBus.Event.SetIsEnabled(self.Properties.RewardLabel, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemRewardNameBig, false)
end
return ObjectiveDetails

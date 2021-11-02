local XpNumber = {
  Properties = {
    AnimContainer = {
      default = EntityId()
    },
    LabelText = {
      default = EntityId()
    },
    NumberText = {
      default = EntityId()
    },
    ProgressBar = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(XpNumber)
function XpNumber:OnInit()
  self:BusConnect(DamageNumbersNotificationBus, self.entityId)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.eventTypeToData = {
    [eXpEventType_PlayerXp] = {
      labelText = "@ui_xp",
      valueLocText = "@ui_floating_xp_val",
      yOffset = 0,
      delay = 0.25
    },
    [eXpEventType_Currency] = {
      labelText = "@ui_gold",
      valueLocText = "@ui_floating_coin_val",
      yOffset = -30,
      delay = 0.5
    },
    [eXpEventType_Standing] = {
      labelText = "@ui_territory_standing_short",
      valueLocText = "@ui_floating_standing_val",
      yOffset = -60,
      delay = 1
    },
    [eXpEventType_Tradeskill] = {
      labelText = "",
      valueLocText = "",
      yOffset = -90,
      delay = 1.5
    },
    [eXpEventType_PlayerDamage] = {
      labelText = "",
      valueLocText = "@ui_glory_update_floating_damage",
      yOffset = 30,
      delay = 0
    },
    [eXpEventType_Reputation] = {
      labelText = "",
      valueLocText = "",
      yOffset = -120,
      delay = 2
    },
    [eXpEventType_Tokens] = {
      labelText = "",
      valueLocText = "",
      yOffset = -150,
      delay = 2.5
    }
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
end
function XpNumber:OnXpDisplayed(xpAmount, goldAmount, standingAmount)
  local xpAmountText = ""
  local hasXP = xpAmount and 0 < xpAmount
  local hasGold = goldAmount and 0 < goldAmount
  local hasStanding = standingAmount and 0 < standingAmount
  if hasXP then
    xpAmountText = GetLocalizedReplacementText("@ui_glory_update_floating_xp", {amount = xpAmount})
    if hasGold or hasStanding then
      xpAmountText = xpAmountText .. "\n"
    end
  end
  if hasGold then
    xpAmountText = xpAmountText .. GetLocalizedReplacementText("@ui_glory_update_floating_gold", {
      gold = GetLocalizedCurrency(goldAmount)
    })
    if hasStanding then
      xpAmountText = xpAmountText .. "\n"
    end
  end
  if hasStanding then
    xpAmountText = xpAmountText .. GetLocalizedReplacementText("@ui_glory_update_floating_standing", {amount = standingAmount})
  end
  UiTextBus.Event.SetText(self.Properties.NumberText, xpAmountText)
  self.audioHelper:QueueSound("XPNumber", self.audioHelper.onKill_XPnumber, 0.25)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Play(self.Properties.AnimContainer, 0.3, {opacity = 0, y = -25}, {
    opacity = 1,
    y = -45,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.AnimContainer, 0.4, {
    opacity = 0,
    y = -95,
    ease = "QuadOut",
    delay = 3.8,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      DamageNumbersBus.Broadcast.OnAnimDone(self.entityId)
    end
  })
end
return XpNumber

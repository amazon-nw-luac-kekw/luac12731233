local PaperdollStatus = {
  Properties = {
    Head = {
      default = EntityId(),
      order = 1
    },
    Chest = {
      default = EntityId(),
      order = 2
    },
    Hands = {
      default = EntityId(),
      order = 3
    },
    Legs = {
      default = EntityId(),
      order = 4
    },
    Feet = {
      default = EntityId(),
      order = 5
    },
    Amulet = {
      default = EntityId(),
      order = 6
    },
    Ring = {
      default = EntityId(),
      order = 7
    },
    Token = {
      default = EntityId(),
      order = 8
    },
    Shadow = {
      default = EntityId(),
      order = 9
    }
  },
  DAMAGED_PERCENT = 0.25
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PaperdollStatus)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function PaperdollStatus:OnInit()
  self.paperdollMap = {
    [ePaperDollSlotTypes_Head] = {
      icon = self.Properties.Head,
      durability = 1,
      isPaperdoll = true
    },
    [ePaperDollSlotTypes_Chest] = {
      icon = self.Properties.Chest,
      durability = 1,
      isPaperdoll = true
    },
    [ePaperDollSlotTypes_Hands] = {
      icon = self.Properties.Hands,
      durability = 1,
      isPaperdoll = true
    },
    [ePaperDollSlotTypes_Legs] = {
      icon = self.Properties.Legs,
      durability = 1,
      isPaperdoll = true
    },
    [ePaperDollSlotTypes_Feet] = {
      icon = self.Properties.Feet,
      durability = 1,
      isPaperdoll = true
    },
    [ePaperDollSlotTypes_Amulet] = {
      icon = self.Properties.Amulet,
      durability = 1,
      isTrinket = true
    },
    [ePaperDollSlotTypes_Ring] = {
      icon = self.Properties.Ring,
      durability = 1,
      isTrinket = true
    },
    [ePaperDollSlotTypes_Token] = {
      icon = self.Properties.Token,
      durability = 1,
      isTrinket = true
    }
  }
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.OnLocalPlayerSet", function(self, isSet)
    if isSet then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", function(self, paperdollId)
        if paperdollId then
          self.paperdollId = paperdollId
          self:BusConnect(PaperdollEventBus, self.paperdollId)
          for slotId, slotInfo in pairs(self.paperdollMap) do
            local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotId)
            if slot then
              slotInfo.durability = slot:GetDurabilityPercent()
            end
          end
          self:UpdateSlots()
        end
      end)
    end
  end)
end
function PaperdollStatus:SetForceOpacity(opacity, animTime)
  self.forceOpacity = opacity
  animTime = animTime ~= nil and animTime or 0
  opacity = opacity ~= nil and opacity or 1
  self.ScriptedEntityTweener:Stop(self.entityId)
  if animTime == 0.3 and opacity == 1 then
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.3, tweenerCommon.vitalsMeterIn)
  elseif animTime == 0.3 and opacity == 0 then
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.3, tweenerCommon.vitalsMeterOut)
  else
    self.ScriptedEntityTweener:Play(self.entityId, animTime, {opacity = opacity, ease = "QuadInOut"})
  end
end
function PaperdollStatus:UpdateSlots()
  local showPaperdoll = false
  local showTrinkets = false
  for slotId, slotInfo in pairs(self.paperdollMap) do
    if slotInfo.durability <= self.DAMAGED_PERCENT then
      if slotInfo.isPaperdoll then
        showPaperdoll = true
      elseif slotInfo.isTrinket then
        showTrinkets = true
        break
      end
    end
  end
  if showPaperdoll or showTrinkets then
    UiElementBus.Event.SetIsEnabled(self.Properties.Shadow, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Shadow, false)
  end
  for slotId, slotInfo in pairs(self.paperdollMap) do
    if slotInfo.isPaperdoll and showPaperdoll or showTrinkets then
      local color = self.UIStyle.COLOR_WHITE
      local brokenIcon = UiElementBus.Event.FindChildByName(slotInfo.icon, "Broken")
      if slotInfo.durability == 0 then
        color = self.UIStyle.COLOR_RED
        UiElementBus.Event.SetIsEnabled(brokenIcon, true)
      elseif slotInfo.durability <= self.DAMAGED_PERCENT then
        color = self.UIStyle.COLOR_RED
        UiElementBus.Event.SetIsEnabled(brokenIcon, false)
      else
        UiElementBus.Event.SetIsEnabled(brokenIcon, false)
      end
      UiImageBus.Event.SetColor(slotInfo.icon, color)
      UiElementBus.Event.SetIsEnabled(slotInfo.icon, true)
    else
      UiElementBus.Event.SetIsEnabled(slotInfo.icon, false)
    end
  end
end
function PaperdollStatus:PaperdollItemDurabilityChanged(slotId, durabilityPercent)
  if self.paperdollMap[slotId] then
    self.paperdollMap[slotId].durability = durabilityPercent
    self:UpdateSlots()
  end
end
function PaperdollStatus:OnPaperdollSlotUpdate(slotId, slot, updateReason)
  if self.paperdollMap[slotId] then
    if slot then
      self.paperdollMap[slotId].durability = slot:GetDurabilityPercent()
    else
      self.paperdollMap[slotId].durability = 1
    end
    self:UpdateSlots()
  end
end
return PaperdollStatus

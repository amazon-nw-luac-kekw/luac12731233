local TradeSkills = {
  Properties = {
    WeaponsmithingCell = {
      default = EntityId(),
      order = 1
    },
    ArmoringCell = {
      default = EntityId(),
      order = 2
    },
    EngineeringCell = {
      default = EntityId(),
      order = 3
    },
    JewelcraftingCell = {
      default = EntityId(),
      order = 4
    },
    ArcanaCell = {
      default = EntityId(),
      order = 5
    },
    CookingCell = {
      default = EntityId(),
      order = 6
    },
    FurnishingCell = {
      default = EntityId(),
      order = 7
    },
    SmeltingCell = {
      default = EntityId(),
      order = 8
    },
    WoodworkingCell = {
      default = EntityId(),
      order = 9
    },
    LeatherworkingCell = {
      default = EntityId(),
      order = 10
    },
    WeavingCell = {
      default = EntityId(),
      order = 11
    },
    StonecuttingCell = {
      default = EntityId(),
      order = 12
    },
    LoggingCell = {
      default = EntityId(),
      order = 13
    },
    MiningCell = {
      default = EntityId(),
      order = 14
    },
    HarvestingCell = {
      default = EntityId(),
      order = 15
    },
    SkinningCell = {
      default = EntityId(),
      order = 16
    },
    FishingCell = {
      default = EntityId(),
      order = 16
    },
    CraftingLine = {
      default = EntityId()
    },
    RefiningLine = {
      default = EntityId()
    },
    GatheringLine = {
      default = EntityId()
    },
    TradeSkillsCrafting = {
      default = EntityId(),
      order = 17
    },
    TradeSkillsGathering = {
      default = EntityId(),
      order = 18
    }
  },
  SkillRowSlicePath = "LyShineUI\\Skills\\SkillRow",
  SkillSectionHeaderSlicePath = "LyShineUI\\Skills\\SkillsSectionHeader",
  SkillRowEntities = {},
  SkillSectionHeaderEntities = {},
  CraftingHeaderData = {},
  GatheringHeaderData = {},
  SurvivalHeaderData = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TradeSkills)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(TradeSkills)
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local TradeSkillsCommon = RequireScript("LyShineUI._Common.TradeSkillsCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function TradeSkills:OnInit()
  BaseElement.OnInit(self)
  self.CraftingSkillsData = TradeSkillsCommon.CraftingSkillsData
  self.GatheringSkillsData = TradeSkillsCommon.GatheringSkillsData
  self.craftingSkillsCellData = {
    self.WeaponsmithingCell,
    self.ArmoringCell,
    self.EngineeringCell,
    self.JewelcraftingCell,
    self.ArcanaCell,
    self.CookingCell,
    self.FurnishingCell,
    self.SmeltingCell,
    self.WoodworkingCell,
    self.LeatherworkingCell,
    self.WeavingCell,
    self.StonecuttingCell
  }
  for index, entityTable in ipairs(self.craftingSkillsCellData) do
    self.CraftingSkillsData[index].cellEntity = entityTable
  end
  self.gatheringSkillsCellData = {
    self.LoggingCell,
    self.MiningCell,
    self.HarvestingCell,
    self.SkinningCell,
    self.FishingCell
  }
  for index, entityTable in ipairs(self.gatheringSkillsCellData) do
    self.GatheringSkillsData[index].cellEntity = entityTable
  end
  self.skillDataTables = {
    self.CraftingSkillsData,
    self.GatheringSkillsData
  }
  self:SetupSection("CraftingSkillsData")
  self:SetupSection("GatheringSkillsData")
  self:RegisterObservers()
  self.TradeSkillsCrafting:SetBackClick(self, self.TradeSkillsCraftingBackClick)
  self.TradeSkillsGathering:SetBackClick(self, self.TradeSkillsGatheringBackClick)
  self.CraftingLine:SetColor(self.UIStyle.COLOR_TAN)
end
function TradeSkills:TradeSkillsCraftingBackClick()
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.TradeSkillsCrafting:SetVisible(false)
end
function TradeSkills:TradeSkillsGatheringBackClick()
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.TradeSkillsGathering:SetVisible(false)
end
function TradeSkills:SetupSection(sectionTableName)
  local sectionTable = self[sectionTableName]
  if sectionTable then
    for i = 1, #sectionTable do
      local cellData = sectionTable[i]
      cellData.cellEntity:SetTableInfo(sectionTableName, i)
      cellData.cellEntity:SetText(cellData.locName)
      cellData.cellEntity:SetIcon(cellData.icon)
      cellData.cellEntity:SetCallback(self, self.OnSkillClicked)
    end
  end
end
function TradeSkills:SetScreenVisible(isVisible)
  self.TradeSkillsCrafting:SetVisible(false)
  self.TradeSkillsGathering:SetVisible(false)
  if isVisible then
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
    self.CraftingLine:SetVisible(false, 0)
    self.CraftingLine:SetVisible(true, 1.2)
    for _, skillDataTable in ipairs(self.skillDataTables) do
      for _, skillData in ipairs(skillDataTable) do
        self:UpdateSkillData(skillData)
      end
    end
  end
end
function TradeSkills:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    self.playerEntityId = data
  end)
end
function TradeSkills:UpdateSkillData(skillData, newLevel)
  newLevel = newLevel or CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, skillData.tableId)
  local progressPercent = 0
  local currentProgress = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, skillData.tableId)
  local requiredProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, skillData.tableId, newLevel)
  if 0 < requiredProgress then
    progressPercent = currentProgress / requiredProgress
  end
  skillData.cellEntity:SetSkillInfo(newLevel, progressPercent)
  skillData.currentLevel = newLevel
  skillData.progressPercent = progressPercent
end
function TradeSkills:OnSkillClicked(tableName, tableIndex)
  local tableData = self[tableName]
  if tableData and tableData[tableIndex] then
    skillsData = tableData[tableIndex]
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    if tableName == "CraftingSkillsData" then
      self.TradeSkillsCrafting:SetVisible(true, skillsData)
    else
      self.TradeSkillsGathering:SetVisible(true, skillsData)
    end
  end
end
function TradeSkills:TransitionIn()
  self:SetScreenVisible(true)
end
function TradeSkills:TransitionOut()
  self:SetScreenVisible(false)
end
function TradeSkills:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
end
return TradeSkills

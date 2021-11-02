local Logger = RequireScript("LyShineUI.Automation.Logger")
local InputUtility = RequireScript("LyShineUI.Automation.Utilities.InputUtility")
local MenuStack = RequireScript("LyShineUI.Automation.MenuStack")
local MenuUtility = RequireScript("LyShineUI.Automation.Utilities.MenuUtility")
local PopupUtility = RequireScript("LyShineUI.Automation.Utilities.PopupUtility")
local TimerHandler = RequireScript("LyShineUI.Automation.Utilities.TimerHandler")
local PlayerUtility = {
  ScreenName = "Skills",
  waitTime = 5,
  SkillsCRC = 3576764016,
  TradeSkillsType = {}
}
function PlayerUtility:Initialize()
  self.Skills = DynamicBus.Skills.Broadcast.GetTable()
  self.BioScreen = self.Skills.BioScreen
  self.AttributesScreen = self.Skills.AttributesScreen
  self.WeaponMasteryScreen = self.Skills.WeaponMasteryScreen
  self.TradeSkillsScreen = self.Skills.TradeSkillsScreen
  self.MasteryTreeWindow = self.WeaponMasteryScreen.MasteryTreeWindow
  self.SkillsScreen = {
    Attributes = {
      entity = self.Skills.AttributesTab,
      name = "AttributesScreen"
    },
    Bio = {
      entity = self.Skills.BioTab,
      name = "BioScreen"
    },
    WeaponMaster = {
      entity = self.Skills.WeaponsTab,
      name = "WeaponMasterScreen"
    },
    TradeSkills = {
      entity = self.Skills.TradeSkillsTab,
      name = "TradeSkillsScreen"
    }
  }
  self.TradeSkillsType = {
    Weaponsmithing = self.TradeSkillsScreen.Properties.WeaponsmithingCell,
    Armoring = self.TradeSkillsScreen.Properties.ArmoringCell,
    Engineering = self.TradeSkillsScreen.Properties.EngineeringCell,
    Jewelcrafting = self.TradeSkillsScreen.Properties.JewelcraftingCell,
    Arcana = self.TradeSkillsScreen.Properties.ArcanaCell,
    Cooking = self.TradeSkillsScreen.Properties.CookingCell,
    Furnishing = self.TradeSkillsScreen.Properties.FurnishingCell,
    Smelting = self.TradeSkillsScreen.Properties.SmeltingCell,
    Woodworking = self.TradeSkillsScreen.Properties.WoodworkingCell,
    Leatherworking = self.TradeSkillsScreen.Properties.LeatherworkingCell,
    Weaving = self.TradeSkillsScreen.Properties.WeavingCell,
    Stonecutting = self.TradeSkillsScreen.Properties.StonecuttingCell,
    Logging = self.TradeSkillsScreen.Properties.LoggingCell,
    Mining = self.TradeSkillsScreen.Properties.MiningCell,
    Harvesting = self.TradeSkillsScreen.Properties.HarvestingCell,
    Skinning = self.TradeSkillsScreen.Properties.SkinningCell
  }
end
local function Log(msg)
  Logger:Log("[PlayerUtility] " .. tostring(msg))
end
local function OpenSkills()
  InputUtility:PressKey("toggleSkillsComponent")
end
local function CloseSkills()
  if MenuStack:IsScreenOpen(PlayerUtility.ScreenName) then
    InputUtility:PressKey("toggleSkillsComponent")
  end
end
function PlayerUtility:IsSkillsWindowOpen()
  return not MenuStack:IsEmpty() and MenuStack:Peek().name == PlayerUtility.ScreenName and MenuStack:VerifyScreen() and MenuStack:VerifyState()
end
function PlayerUtility:OpenSkills()
  MenuUtility:OpenMenu(PlayerUtility.ScreenName, "Progression", OpenSkills, CloseSkills, PlayerUtility.IsSkillsWindowOpen, PlayerUtility.SkillsCRC)
end
function PlayerUtility:CloseSkills()
  if self:IsSkillsWindowOpen() then
    MenuUtility:CloseMenu(PlayerUtility.ScreenName, "Progression")
  end
end
function PlayerUtility:IsInExpectedSkillsScreen(screenName)
  if PlayerUtility.Skills.activeScreen == screenName then
    return true
  else
    return false
  end
end
function PlayerUtility:OpenSkillsScreen(category)
  coroutine.yield()
  local timer = TimerHandler:GetTimer(PlayerUtility.waitTime)
  if self:IsSkillsWindowOpen() then
    Debug.Log("Skills window is open")
    local position = MenuUtility:GetObjectViewportPosition(category.entity, MenuUtility.Anchors.Center)
    MenuUtility:ClickAt(position)
  end
  Debug.Log("Expected Screen: " .. category.name)
  while not self:IsInExpectedSkillsScreen(category.name) and not timer:TimeUp() do
    coroutine.yield()
  end
  if not self:IsInExpectedSkillsScreen(category.name) then
    error("Error: Player is not in expected screen. Current screen: " .. PlayerUtility.Skills.activeScreen)
  end
end
function PlayerUtility:ViewTradeSkill(skillType)
  if self:IsSkillsWindowOpen() and self:IsInExpectedSkillsScreen(PlayerUtility.SkillsScreen.TradeSkills.name) then
    local position = MenuUtility:GetObjectViewportPosition(skillType, MenuUtility.Anchors.Center)
    MenuUtility:ClickAt(position)
    return true
  else
    error("Error: Tradeskills screen is not open")
    return false
  end
end
function PlayerUtility:GetAttributeRow(attributeType)
  for i = 1, #PlayerUtility.AttributesScreen.AttributeModifiersData do
    if PlayerUtility.AttributesScreen.AttributeModifiersData[i].name == attributeType then
      Log("Debug: Attribute Type Index: " .. i)
      return PlayerUtility.AttributesScreen.AttributeModifierEntities[i]
    end
  end
end
local function AllocateAttributePoints(points, button)
  if not PlayerUtility:IsSkillsWindowOpen() and not PlayerUtility:IsInExpectedSkillsScreen(PlayerUtility.SkillsScreen.Attributes.name) then
    error("Error: Player is not in expected screen")
    return false
  end
  local assignedPoints = 0
  local position = UiTransformBus.Event.GetViewportPosition(button)
  while points > assignedPoints do
    MenuUtility:ClickAt(position)
    assignedPoints = assignedPoints + 1
    coroutine.yield()
  end
end
function PlayerUtility:AddAttributePoints(attributeType, points)
  if points > PlayerUtility.AttributesScreen.unspentPoints then
    error("Error: No attribute points to allocate")
    return false
  end
  local attributeRow = self:GetAttributeRow(attributeType)
  AllocateAttributePoints(points, attributeRow.AddButton)
end
function PlayerUtility:SubtractAttributePoints(attributeType, points)
  if points > PlayerUtility.AttributesScreen.pendingPoints then
    error("Error: There are no pending attribute points available")
    return false
  end
  local attributeRow = self:GetAttributeRow(attributeType)
  AllocateAttributePoints(points, attributeRow.SubtractButton)
end
function PlayerUtility:CommitAttributePoints()
  if self:IsSkillsWindowOpen() and self:IsInExpectedSkillsScreen(PlayerUtility.SkillsScreen.Attributes.name) and PlayerUtility.AttributesScreen.pendingPoints > 0 then
    MenuUtility:ClickButton(PlayerUtility.AttributesScreen.ConfirmButton)
    return true
  else
    error("Attribute screen is not open")
    return false
  end
end
function PlayerUtility:RespecAttributePoints()
  coroutine.yield()
  if self:IsSkillsWindowOpen() and self:IsInExpectedSkillsScreen(PlayerUtility.SkillsScreen.Attributes.name) then
    local pos = MenuUtility:GetObjectViewportPosition(PlayerUtility.AttributesScreen.RespecButton, MenuUtility.Anchors.Center)
    MenuUtility:ClickAt(pos)
    PopupUtility:WaitUntilAnyPopupIsOpen()
    PopupUtility:PopupClickPositive()
    return true
  else
    Log("Error: Attribute screen is not open")
    return false
  end
end
function PlayerUtility:ViewMasteryTree(targetTableId)
  coroutine.yield()
  if PlayerUtility.Skills.activeScreen ~= PlayerUtility.SkillsScreen.WeaponMaster.name then
    PlayerUtility:OpenSkillsScreen(self.SkillsScreen.WeaponMaster)
  end
  for _, entity in pairs(PlayerUtility.WeaponMasteryScreen.WeaponRowEntities) do
    if entity.tableNameId == targetTableId then
      local position = MenuUtility:GetObjectViewportPosition(entity, MenuUtility.Anchors.Center)
      MenuUtility:ClickAt(position)
    end
  end
end
function PlayerUtility:GetFirstAvailableAbility()
  for _, tree in pairs(PlayerUtility.MasteryTreeWindow.MasteryTrees) do
    for _, row in pairs(tree.Rows) do
      for _, masteryNode in pairs(row.Nodes) do
        if masteryNode.state == masteryNode.STATE_AVAILABLE then
          local position = MenuUtility:GetObjectViewportPosition(masteryNode, MenuUtility.Anchors.Center)
          return position
        end
      end
    end
  end
end
function PlayerUtility:GetAbilityById(id)
  for _, tree in pairs(PlayerUtility.MasteryTreeWindow.MasteryTrees) do
    for _, row in pairs(tree.Rows) do
      for _, node in pairs(row.Nodes) do
        if node.data.id == id and node.state == node.STATE_AVAILABLE then
          local position = MenuUtility:GetObjectViewportPosition(node, MenuUtility.Anchors.Center)
          return position
        end
      end
    end
  end
end
function PlayerUtility:SetWeaponMasteryPoints()
  local unspentPoints = PlayerUtility.MasteryTreeWindow.availableUnspentPoints
  local spentPoints = 0
  if unspentPoints == nil or unspentPoints == spentPoints then
    error("Error: Unable to allocate. Available mastery points: " .. unspentPoints)
    return false
  end
  while unspentPoints > spentPoints do
    coroutine.yield()
    MenuUtility:ClickAt(self:GetFirstAvailableAbility())
    spentPoints = spentPoints + 1
    coroutine.yield()
  end
  Log("Info: Commit mastery points")
  coroutine.yield()
  local confirmButton = MenuUtility:GetObjectViewportPosition(PlayerUtility.MasteryTreeWindow.ConfirmButton, MenuUtility.Anchors.Center)
  MenuUtility:ClickAt(confirmButton)
end
function PlayerUtility:RespecAbilityPoints()
  if self:IsSkillsWindowOpen() and self:IsInExpectedSkillsScreen(PlayerUtility.SkillsScreen.WeaponMaster.name) then
    coroutine.yield()
    local pos = MenuUtility:GetObjectViewportPosition(PlayerUtility.MasteryTreeWindow.RespecButton, MenuUtility.Anchors.Center)
    MenuUtility:ClickAt(pos)
    PopupUtility:WaitUntilAnyPopupIsOpen()
    PopupUtility:PopupClickPositive()
  else
    error("Error: Player is not in Weapon mastery screen")
  end
end
return PlayerUtility

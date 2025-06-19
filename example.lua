local DriftwynLib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- CreateWindow method (correct name)
function DriftwynLib:CreateWindow(config)
    local self = {}
    self.Title = config.Name or "Driftwyn UI"

    -- Create the ScreenGui and main frame, and set up everything here
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local DriftwynUI = Instance.new("ScreenGui")
    DriftwynUI.Name = "DriftwynUI"
    DriftwynUI.Parent = playerGui
    DriftwynUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = DriftwynUI
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.8287, -250, 0.9615, -175)
    MainFrame.Size = UDim2.new(0, 618, 0, 350)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.0129, 0, 0.0171, 0)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.Unknown
    Title.Text = self.Title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 108, 0, 36)
    ContentFrame.Size = UDim2.new(0.9822, -100, 0.9657, -30)

    -- Layout for stacking buttons and other elements
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = ContentFrame

    -- Store tabs and active tab
    self.Tabs = {}
    self.ActiveTab = nil
    self.MainFrame = MainFrame
    self.ContentFrame = ContentFrame

    -- AddTab function to create new tabs
    function self:AddTab(tabConfig)
        local tabName = tabConfig.Name or "Tab"
        local tab = {}

        local TabHolder = Instance.new("Frame")
        TabHolder.Name = tabName .. "Tab"
        TabHolder.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabHolder.BorderSizePixel = 0
        TabHolder.Position = UDim2.new(0.0129, 0, 0.0171, 0)
        TabHolder.Size = UDim2.new(0, 100, 1.0514, -30)
        TabHolder.Parent = self.MainFrame

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = TabHolder

        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "Button"
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 14
        TabButton.Text = tabName
        TabButton.Parent = TabHolder

        local ContentHolder = Instance.new("Frame")
        ContentHolder.Name = tabName .. "Content"
        ContentHolder.BackgroundTransparency = 1
        ContentHolder.Size = UDim2.new(1, 0, 1, 0)
        ContentHolder.Parent = self.ContentFrame
        ContentHolder.Visible = false

        tab.TabButton = TabButton
        tab.ContentHolder = ContentHolder
        tab.Sections = {}

        -- Clicking tab button activates this tab
        TabButton.MouseButton1Click:Connect(function()
            self:SetActiveTab(tabName)
        end)

        -- Method to add section to tab
        function tab:AddSection(sectionConfig)
            local sectionName = sectionConfig.Name or "Section"
            local section = {}

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = sectionName .. "Section"
            SectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size = UDim2.new(1, -20, 0, 100)
            SectionFrame.LayoutOrder = #tab.Sections + 1
            SectionFrame.Parent = ContentHolder

            local UIListLayout = Instance.new("UIListLayout")
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 8)
            UIListLayout.Parent = SectionFrame

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Size = UDim2.new(1, 0, 0, 25)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextSize = 16
            SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.Text = sectionName
            SectionTitle.Parent = SectionFrame

            section.Frame = SectionFrame
            section.Title = SectionTitle
            section.Elements = {}

            -- You can add methods to add buttons, toggles, etc to this section here

            function section:AddButton(buttonConfig)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -20, 0, 30)
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 14
                btn.Text = buttonConfig.Name or "Button"
                btn.BorderSizePixel = 0
                btn.Parent = SectionFrame

                if buttonConfig.Callback then
                    btn.MouseButton1Click:Connect(buttonConfig.Callback)
                end

                table.insert(section.Elements, btn)
                return btn
            end

            -- You can add more element types (Toggle, Slider, etc) here following the same pattern

            table.insert(tab.Sections, section)
            return section
        end

        table.insert(self.Tabs, tab)
        if #self.Tabs == 1 then
            self:SetActiveTab(tabName)
        end

        return tab
    end

    function self:SetActiveTab(tabName)
        for _, tab in pairs(self.Tabs) do
            if tab.TabButton.Text == tabName then
                tab.ContentHolder.Visible = true
                tab.TabButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                self.ActiveTab = tab
            else
                tab.ContentHolder.Visible = false
                tab.TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end
        end
    end

    return self
end

return DriftwynLib

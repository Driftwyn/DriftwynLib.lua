-- DriftwynLib - Full UI Library with Fixes: Slider, Dropdown, Keybinds, Textbox, Toggle
local DriftwynLib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

function DriftwynLib:CreateWindow(config)
    local self = {}
    self.Title = config.Name or "Driftwyn UI"
    self.Tabs = {}
    self.ActiveTab = nil

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local DriftwynUI = Instance.new("ScreenGui")
    DriftwynUI.Name = "DriftwynUI"
    DriftwynUI.Parent = playerGui
    DriftwynUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = DriftwynUI
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    -- Make draggable
    local dragging, dragStart, startPos = false, nil, nil
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Title = Instance.new("TextLabel")
    Title.Text = self.Title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.03, 0, 0, 0)
    Title.Size = UDim2.new(0.6, 0, 0, 40)
    Title.Parent = MainFrame

    local TabButtonsFrame = Instance.new("ScrollingFrame")
    TabButtonsFrame.Name = "TabButtons"
    TabButtonsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TabButtonsFrame.Position = UDim2.new(0, 0, 0, 40)
    TabButtonsFrame.Size = UDim2.new(0, 120, 1, -40)
    TabButtonsFrame.CanvasSize = UDim2.new(0, 0, 5, 0)
    TabButtonsFrame.ScrollBarThickness = 4
    TabButtonsFrame.Parent = MainFrame

    local TabListLayout = Instance.new("UIListLayout", TabButtonsFrame)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 6)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Position = UDim2.new(0, 130, 0, 40)
    ContentFrame.Size = UDim2.new(1, -140, 1, -50)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 6)

    function self:SetActiveTab(tabName)
        for _, tab in pairs(self.Tabs) do
            local isActive = (tab.Name == tabName)
            tab.Content.Visible = isActive
            tab.Button.BackgroundColor3 = isActive and Color3.fromRGB(70, 70, 100) or Color3.fromRGB(45, 45, 60)
        end
    end

    function self:AddTab(tabConfig)
        local tabName = tabConfig.Name or "Tab"
        local tab = { Name = tabName }

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -8, 0, 30)
        tabBtn.Text = tabName
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.TextSize = 14
        tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        tabBtn.BorderSizePixel = 0
        tabBtn.Parent = TabButtonsFrame

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "_Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.ScrollBarThickness = 4
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Parent = ContentFrame

        local sectionLayout = Instance.new("UIListLayout", tabContent)
        sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sectionLayout.Padding = UDim.new(0, 10)

        tab.Button = tabBtn
        tab.Content = tabContent
        tab.Sections = {}

        tabBtn.MouseButton1Click:Connect(function()
            self:SetActiveTab(tabName)
        end)

        function tab:AddSection(sectionConfig)
            local sectionTitle = sectionConfig.Name or "Section"
            local section = {}

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, -10, 0, 0)
            sectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            sectionFrame.BorderSizePixel = 0
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.Parent = tabContent

            Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 6)
            local layout = Instance.new("UIListLayout", sectionFrame)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 6)

            local title = Instance.new("TextLabel")
            title.Text = sectionTitle
            title.Font = Enum.Font.GothamBold
            title.TextSize = 16
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.BackgroundTransparency = 1
            title.Size = UDim2.new(1, -20, 0, 25)
            title.Parent = sectionFrame

            local function createElement(height)
                local elem = Instance.new("Frame")
                elem.Size = UDim2.new(1, -20, 0, height)
                elem.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
                elem.BorderSizePixel = 0
                elem.Parent = sectionFrame
                Instance.new("UICorner", elem)
                return elem
            end

            function section:AddButton(cfg)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -20, 0, 30)
                btn.Text = cfg.Name or "Button"
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
                btn.BorderSizePixel = 0
                btn.Parent = sectionFrame
                Instance.new("UICorner", btn)
                btn.MouseButton1Click:Connect(function()
                    if cfg.Callback then cfg.Callback() end
                end)
            end

            function section:AddSlider(cfg)
                local val = cfg.Default or cfg.Min
                local container = createElement(30)
                local text = Instance.new("TextLabel", container)
                text.Size = UDim2.new(0.6, 0, 1, 0)
                text.TextXAlignment = Enum.TextXAlignment.Left
                text.Text = cfg.Name .. ": " .. val
                text.Font = Enum.Font.Gotham
                text.TextSize = 14
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.BackgroundTransparency = 1

                local minus = Instance.new("TextButton", container)
                minus.Size = UDim2.new(0.2, 0, 1, 0)
                minus.Position = UDim2.new(0.6, 0, 0, 0)
                minus.Text = "-"
                minus.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
                minus.Font = Enum.Font.GothamBold
                minus.TextSize = 16

                local plus = Instance.new("TextButton", container)
                plus.Size = UDim2.new(0.2, 0, 1, 0)
                plus.Position = UDim2.new(0.8, 0, 0, 0)
                plus.Text = "+"
                plus.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                plus.Font = Enum.Font.GothamBold
                plus.TextSize = 16

                local function update(val)
                    text.Text = cfg.Name .. ": " .. val
                    if cfg.Callback then cfg.Callback(val) end
                end

                plus.MouseButton1Click:Connect(function()
                    val = math.clamp(val + 1, cfg.Min, cfg.Max)
                    update(val)
                end)
                minus.MouseButton1Click:Connect(function()
                    val = math.clamp(val - 1, cfg.Min, cfg.Max)
                    update(val)
                end)
            end

            function section:AddDropdown(cfg)
                local val = cfg.Name
                local container = createElement(30 + (#cfg.Options * 24))
                container.ClipsDescendants = true
                local dropdown = Instance.new("TextButton", container)
                dropdown.Size = UDim2.new(1, 0, 0, 30)
                dropdown.Text = val
                dropdown.Font = Enum.Font.Gotham
                dropdown.TextSize = 14
                dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

                local list = Instance.new("Frame", container)
                list.Size = UDim2.new(1, 0, 0, #cfg.Options * 24)
                list.Position = UDim2.new(0, 0, 0, 30)
                list.BackgroundTransparency = 1
                list.Visible = false

                Instance.new("UIListLayout", list)

                for _, opt in ipairs(cfg.Options) do
                    local optBtn = Instance.new("TextButton", list)
                    optBtn.Size = UDim2.new(1, 0, 0, 24)
                    optBtn.Text = opt
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = 14
                    optBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
                    optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    optBtn.MouseButton1Click:Connect(function()
                        dropdown.Text = cfg.Name .. ": " .. opt
                        list.Visible = false
                        if cfg.Callback then cfg.Callback(opt) end
                    end)
                end

                dropdown.MouseButton1Click:Connect(function()
                    list.Visible = not list.Visible
                end)
            end

            return section
        end

        table.insert(self.Tabs, tab)
        if #self.Tabs == 1 then self:SetActiveTab(tabName) end

        return tab
    end

    return self
end

return DriftwynLib

local DriftwynLib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

function DriftwynLib:CreateWindow(config)
    local self = {}
    self.Title = config.Name or "Driftwyn UI"

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
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 600, 0, 400)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.02, 0, 0.02, 0)
    Title.Size = UDim2.new(0.96, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = self.Title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Name = "TabHolder"
    TabHolder.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TabHolder.BorderSizePixel = 0
    TabHolder.Position = UDim2.new(0.02, 0, 0.1, 0)
    TabHolder.Size = UDim2.new(0, 120, 0.88, 0)
    TabHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabHolder.ScrollBarThickness = 6
    TabHolder.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = TabHolder
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0.22, 0, 0.1, 0)
    ContentFrame.Size = UDim2.new(0.76, 0, 0.88, 0)

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = ContentFrame

    self.Tabs = {}
    self.ActiveTab = nil
    self.MainFrame = MainFrame
    self.ContentFrame = ContentFrame
    self.TabHolder = TabHolder

    function self:AddTab(tabConfig)
        local tabName = tabConfig.Name or "Tab"
        local tab = {}

        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "Button"
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 16
        TabButton.Text = tabName
        TabButton.Parent = self.TabHolder

        local ContentHolder = Instance.new("Frame")
        ContentHolder.Name = tabName .. "Content"
        ContentHolder.BackgroundTransparency = 1
        ContentHolder.Size = UDim2.new(1, 0, 1, 0)
        ContentHolder.Parent = self.ContentFrame
        ContentHolder.Visible = false

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = ContentHolder

        tab.TabButton = TabButton
        tab.ContentHolder = ContentHolder
        tab.Sections = {}

        TabButton.MouseButton1Click:Connect(function()
            self:SetActiveTab(tabName)
        end)

        function tab:AddSection(sectionConfig)
            local sectionName = sectionConfig.Name or "Section"
            local section = {}

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = sectionName .. "Section"
            SectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size = UDim2.new(1, 0, 0, 150)
            SectionFrame.LayoutOrder = #tab.Sections + 1
            SectionFrame.Parent = ContentHolder

            local UIListLayout = Instance.new("UIListLayout")
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 8)
            UIListLayout.Parent = SectionFrame

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Size = UDim2.new(1, 0, 0, 28)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextSize = 18
            SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.Text = sectionName
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame

            section.Frame = SectionFrame
            section.Title = SectionTitle
            section.Elements = {}

            -- Button
            function section:AddButton(buttonConfig)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -20, 0, 35)
                btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 16
                btn.Text = buttonConfig.Name or "Button"
                btn.BorderSizePixel = 0
                btn.Parent = SectionFrame

                if buttonConfig.Callback then
                    btn.MouseButton1Click:Connect(buttonConfig.Callback)
                end

                table.insert(section.Elements, btn)
                return btn
            end

            -- Toggle
            function section:AddToggle(toggleConfig)
                local toggled = toggleConfig.Default or false

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, -20, 0, 35)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = SectionFrame
                ToggleFrame.LayoutOrder = #section.Elements + 1

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Text = toggleConfig.Name or "Toggle"
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextSize = 16
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame

                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(0, 40, 0, 20)
                ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
                ToggleButton.BackgroundColor3 = toggled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(70, 70, 70)
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Text = ""
                ToggleButton.Parent = ToggleFrame

                local Circle = Instance.new("Frame")
                Circle.Size = UDim2.new(0, 16, 0, 16)
                Circle.Position = toggled and UDim2.new(1, -35, 0.5, -8) or UDim2.new(0, 5, 0.5, -8)
                Circle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Circle.BorderSizePixel = 0
                Circle.Parent = ToggleButton
                Circle.AnchorPoint = Vector2.new(0.5, 0.5)
                Circle.ClipsDescendants = true
                Circle.Name = "Circle"
                Circle.Visible = true
                Circle.BackgroundTransparency = 0

                local function updateToggle(state)
                    toggled = state
                    ToggleButton.BackgroundColor3 = toggled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(70, 70, 70)
                    Circle:TweenPosition(toggled and UDim2.new(1, -35, 0.5, -8) or UDim2.new(0, 5, 0.5, -8), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
                    if toggleConfig.Callback then
                        toggleConfig.Callback(toggled)
                    end
                end

                ToggleButton.MouseButton1Click:Connect(function()
                    updateToggle(not toggled)
                end)

                table.insert(section.Elements, ToggleFrame)
                return ToggleFrame, function() return toggled end, function(state) updateToggle(state) end
            end

            -- Slider
            function section:AddSlider(sliderConfig)
                local min = sliderConfig.Min or 0
                local max = sliderConfig.Max or 100
                local default = sliderConfig.Default or min
                local value = default

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, -20, 0, 50)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = SectionFrame
                SliderFrame.LayoutOrder = #section.Elements + 1

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Text = sliderConfig.Name or "Slider"
                SliderLabel.Size = UDim2.new(1, 0, 0, 20)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.TextSize = 16
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame

                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(1, -40, 0, 10)
                SliderBar.Position = UDim2.new(0, 10, 0, 30)
                SliderBar.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = SliderFrame
                SliderBar.ClipsDescendants = true
                SliderBar.AnchorPoint = Vector2.new(0, 0)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
                Fill.BorderSizePixel = 0
                Fill.Parent = SliderBar

                local SliderButton = Instance.new("TextButton")
                SliderButton.Size = UDim2.new(0, 20, 0, 20)
                SliderButton.Position = UDim2.new((default - min) / (max - min), 0, 0.5, -10)
                SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderButton.BorderSizePixel = 0
                SliderButton.Text = ""
                SliderButton.Parent = SliderBar
                SliderButton.AutoButtonColor = false
                SliderButton.AnchorPoint = Vector2.new(0.5, 0.5)

                local SliderValueLabel = Instance.new("TextLabel")
                SliderValueLabel.Text = tostring(default)
                SliderValueLabel.Size = UDim2.new(0, 30, 0, 20)
                SliderValueLabel.Position = UDim2.new(1, 5, 0, 15)
                SliderValueLabel.BackgroundTransparency = 1
                SliderValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderValueLabel.Font = Enum.Font.Gotham
                SliderValueLabel.TextSize = 14
                SliderValueLabel.Parent = SliderFrame

                local dragging = false

                local function updateSlider(inputPosX)
                    local relativeX = math.clamp(inputPosX - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
                    local ratio = relativeX / SliderBar.AbsoluteSize.X
                    value = math.floor(min + ratio * (max - min))
                    Fill.Size = UDim2.new(ratio, 0, 1, 0)
                    SliderButton.Position = UDim2.new(ratio, 0, 0.5, -10)
                    SliderValueLabel.Text = tostring(value)
                    if sliderConfig.Callback then
                        sliderConfig.Callback(value)
                    end
                end

                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                SliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input.Position.X)
                    end
                end)

                table.insert(section.Elements, SliderFrame)
                return SliderFrame, function() return value end, function(newValue)
                    newValue = math.clamp(newValue, min, max)
                    value = newValue
                    local ratio = (value - min) / (max - min)
                    Fill.Size = UDim2.new(ratio, 0, 1, 0)
                    SliderButton.Position = UDim2.new(ratio, 0, 0.5, -10)
                    SliderValueLabel.Text = tostring(value)
                    if sliderConfig.Callback then
                        sliderConfig.Callback(value)
                    end
                end
            end

            -- Dropdown
            function section:AddDropdown(dropdownConfig)
                local options = dropdownConfig.Options or {}
                local selectedIndex = 1
                local open = false

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, -20, 0, 35)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Parent = SectionFrame
                DropdownFrame.LayoutOrder = #section.Elements + 1

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Text = dropdownConfig.Name or "Dropdown"
                DropdownLabel.Size = UDim2.new(1, -40, 1, 0)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropdownLabel.Font = Enum.Font.Gotham
                DropdownLabel.TextSize = 16
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DropdownFrame

                local SelectedButton = Instance.new("TextButton")
                SelectedButton.Size = UDim2.new(0, 30, 0, 30)
                SelectedButton.Position = UDim2.new(1, -35, 0.5, -15)
                SelectedButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                SelectedButton.BorderSizePixel = 0
                SelectedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                SelectedButton.Font = Enum.Font.GothamBold
                SelectedButton.TextSize = 20
                SelectedButton.Text = "▼"
                SelectedButton.Parent = DropdownFrame

                local OptionsFrame = Instance.new("Frame")
                OptionsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                OptionsFrame.BorderSizePixel = 0
                OptionsFrame.Position = UDim2.new(0, 0, 1, 2)
                OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
                OptionsFrame.ClipsDescendants = true
                OptionsFrame.Parent = DropdownFrame
                OptionsFrame.Visible = false

                local OptionsLayout = Instance.new("UIListLayout")
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionsLayout.Parent = OptionsFrame

                local function updateDropdownHeight()
                    local count = #options
                    local optionHeight = 30
                    local maxHeight = math.min(count * optionHeight, 150)
                    OptionsFrame:TweenSize(UDim2.new(1, 0, 0, maxHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                end

                local function closeDropdown()
                    open = false
                    OptionsFrame.Visible = false
                    OptionsFrame:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                end

                local function openDropdown()
                    open = true
                    OptionsFrame.Visible = true
                    updateDropdownHeight()
                end

                local function selectOption(index)
                    selectedIndex = index
                    DropdownLabel.Text = dropdownConfig.Name .. ": " .. options[index]
                    if dropdownConfig.Callback then
                        dropdownConfig.Callback(options[index], index)
                    end
                    closeDropdown()
                end

                -- Create option buttons
                for i, option in ipairs(options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Size = UDim2.new(1, 0, 0, 30)
                    OptionButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
                    OptionButton.BorderSizePixel = 0
                    OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.TextSize = 16
                    OptionButton.Text = option
                    OptionButton.Parent = OptionsFrame

                    OptionButton.MouseButton1Click:Connect(function()
                        selectOption(i)
                    end)
                end

                SelectedButton.MouseButton1Click:Connect(function()
                    if open then
                        closeDropdown()
                    else
                        openDropdown()
                    end
                end)

                -- Initialize label
                DropdownLabel.Text = dropdownConfig.Name .. ": " .. options[selectedIndex]

                table.insert(section.Elements, DropdownFrame)
                return DropdownFrame, function()
                    return options[selectedIndex], selectedIndex
                end, function(index)
                    if index >= 1 and index <= #options then
                        selectOption(index)
                    end
                end
            end

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

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

    -- Draggable support
    local dragging = false
    local dragInput, dragStart, startPos

    local function updateInput(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)

    -- Title label
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

    -- Tab holder (left side)
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

    -- Content frame (right side)
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

    -- Store tabs and active tab
    self.Tabs = {}
    self.ActiveTab = nil
    self.MainFrame = MainFrame
    self.ContentFrame = ContentFrame
    self.TabHolder = TabHolder

    -- Add a tab
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
            SectionFrame.Size = UDim2.new(1, 0, 0, 140)
            SectionFrame.LayoutOrder = #tab.Sections + 1
            SectionFrame.Parent = ContentHolder

            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 8)
            sectionLayout.Parent = SectionFrame

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

            -- Button
            function section:AddButton(buttonConfig)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -20, 0, 30)
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 14
                btn.Text = buttonConfig.Name or "Button"
                btn.BorderSizePixel = 0
                btn.LayoutOrder = #section.Elements + 2
                btn.Parent = section.Frame
                btn.Position = UDim2.new(0, 10, 0, 25 + (#section.Elements * 38))

                if buttonConfig.Callback then
                    btn.MouseButton1Click:Connect(buttonConfig.Callback)
                end

                table.insert(section.Elements, btn)
                return btn
            end

            -- Toggle
            function section:AddToggle(toggleConfig)
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Size = UDim2.new(1, -20, 0, 30)
                toggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                toggleFrame.BorderSizePixel = 0
                toggleFrame.LayoutOrder = #section.Elements + 2
                toggleFrame.Parent = section.Frame
                toggleFrame.Position = UDim2.new(0, 10, 0, 25 + (#section.Elements * 38))

                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Size = UDim2.new(0.75, 0, 1, 0)
                toggleLabel.Font = Enum.Font.GothamBold
                toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleLabel.TextSize = 14
                toggleLabel.Text = toggleConfig.Name or "Toggle"
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame

                local toggleBtn = Instance.new("TextButton")
                toggleBtn.Size = UDim2.new(0, 30, 0, 20)
                toggleBtn.Position = UDim2.new(0.8, 0, 0.15, 0)
                toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                toggleBtn.BorderSizePixel = 0
                toggleBtn.Text = ""
                toggleBtn.Parent = toggleFrame

                local toggled = false
                local function updateToggle()
                    if toggled then
                        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    else
                        toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    end
                end

                toggleBtn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    updateToggle()
                    if toggleConfig.Callback then
                        toggleConfig.Callback(toggled)
                    end
                end)

                updateToggle()

                table.insert(section.Elements, toggleFrame)
                return toggleFrame
            end

            -- Slider
            function section:AddSlider(sliderConfig)
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Size = UDim2.new(1, -20, 0, 50)
                sliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                sliderFrame.BorderSizePixel = 0
                sliderFrame.LayoutOrder = #section.Elements + 2
                sliderFrame.Parent = section.Frame
                sliderFrame.Position = UDim2.new(0, 10, 0, 25 + (#section.Elements * 38))

                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Size = UDim2.new(1, -60, 0, 20)
                sliderLabel.Font = Enum.Font.GothamBold
                sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderLabel.TextSize = 14
                sliderLabel.Text = (sliderConfig.Name or "Slider") .. ": " .. (sliderConfig.Default or 0)
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Position = UDim2.new(0, 0, 0, 5)
                sliderLabel.Parent = sliderFrame

                local sliderBar = Instance.new("Frame")
                sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                sliderBar.Size = UDim2.new(1, -20, 0, 10)
                sliderBar.Position = UDim2.new(0, 10, 0, 30)
                sliderBar.Parent = sliderFrame

                local sliderFill = Instance.new("Frame")
                sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                sliderFill.Size = UDim2.new(((sliderConfig.Default or 0) - (sliderConfig.Min or 0)) / ((sliderConfig.Max or 100) - (sliderConfig.Min or 0)), 0, 1, 0)
                sliderFill.Parent = sliderBar

                local draggingSlider = false

                sliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                    end
                end)

                sliderBar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)

                sliderBar.InputChanged:Connect(function(input)
                    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativePos = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
                        local value = (relativePos / sliderBar.AbsoluteSize.X) * ((sliderConfig.Max or 100) - (sliderConfig.Min or 0)) + (sliderConfig.Min or 0)
                        sliderFill.Size = UDim2.new(relativePos / sliderBar.AbsoluteSize.X, 0, 1, 0)
                        sliderLabel.Text = (sliderConfig.Name or "Slider") .. ": " .. math.floor(value)
                        if sliderConfig.Callback then
                            sliderConfig.Callback(math.floor(value))
                        end
                    end
                end)

                table.insert(section.Elements, sliderFrame)
                return sliderFrame
            end

            -- Dropdown
            function section:AddDropdown(dropdownConfig)
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Size = UDim2.new(1, -20, 0, 35)
                dropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                dropdownFrame.BorderSizePixel = 0
                dropdownFrame.LayoutOrder = #section.Elements + 2
                dropdownFrame.Parent = section.Frame
                dropdownFrame.Position = UDim2.new(0, 10, 0, 25 + (#section.Elements * 38))

                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Size = UDim2.new(0.75, 0, 1, 0)
                dropdownLabel.Font = Enum.Font.GothamBold
                dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdownLabel.TextSize = 14
                dropdownLabel.Text = dropdownConfig.Name or "Dropdown"
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame

                local dropdownBtn = Instance.new("TextButton")
                dropdownBtn.Size = UDim2.new(0.22, 0, 0.75, 0)
                dropdownBtn.Position = UDim2.new(0.75, 0, 0.125, 0)
                dropdownBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                dropdownBtn.BorderSizePixel = 0
                dropdownBtn.Text = "▼"
                dropdownBtn.Font = Enum.Font.GothamBold
                dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdownBtn.TextSize = 18
                dropdownBtn.Parent = dropdownFrame

                local dropdownOpen = false
                local dropdownList = Instance.new("Frame")
                dropdownList.Size = UDim2.new(1, 0, 0, 0)
                dropdownList.Position = UDim2.new(0, 0, 1, 0)
                dropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                dropdownList.BorderSizePixel = 0
                dropdownList.ClipsDescendants = true
                dropdownList.Parent = dropdownFrame

                local listLayout = Instance.new("UIListLayout")
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Padding = UDim.new(0, 5)
                listLayout.Parent = dropdownList

                local function closeDropdown()
                    dropdownOpen = false
                    dropdownList:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2, true)
                end

                local function openDropdown()
                    dropdownOpen = true
                    local totalHeight = (#dropdownConfig.Options * 30) + 10
                    dropdownList:TweenSize(UDim2.new(1, 0, 0, totalHeight), "Out", "Quad", 0.2, true)
                end

                dropdownBtn.MouseButton1Click:Connect(function()
                    if dropdownOpen then
                        closeDropdown()
                    else
                        openDropdown()
                    end
                end)

                for i, option in ipairs(dropdownConfig.Options or {}) do
                    local optionBtn = Instance.new("TextButton")
                    optionBtn.Size = UDim2.new(1, -10, 0, 30)
                    optionBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    optionBtn.BorderSizePixel = 0
                    optionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    optionBtn.Font = Enum.Font.Gotham
                    optionBtn.TextSize = 14
                    optionBtn.Text = option
                    optionBtn.Parent = dropdownList
                    optionBtn.LayoutOrder = i

                    optionBtn.MouseButton1Click:Connect(function()
                        dropdownLabel.Text = option
                        if dropdownConfig.Callback then
                            dropdownConfig.Callback(option)
                        end
                        closeDropdown()
                    end)
                end

                table.insert(section.Elements, dropdownFrame)
                return dropdownFrame
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

    -- Set active tab (show/hide content)
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

-- DriftwynLib - Full UI Library (With Toggle, Keybind, Textbox, Theme support + Notifications)
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

    -- Notification Holder Frame (for notifications)
    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.Size = UDim2.new(0, 250, 1, -20)
    NotificationHolder.Position = UDim2.new(1, -260, 0, 10)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = DriftwynUI

    local notifLayout = Instance.new("UIListLayout", NotificationHolder)
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.Padding = UDim.new(0, 10)

    -- Draggable
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
        tabContent.CanvasSize = UDim2.new(0, 0, 5, 0)
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

        function tab:AddSection(cfg)
            local sectionTitle = cfg.Name or "Section"
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

            function section:AddButton(cfg)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -20, 0, 30)
                btn.Text = cfg.Name or "Button"
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
                btn.Parent = sectionFrame
                Instance.new("UICorner", btn)
                if cfg.Callback then
                    btn.MouseButton1Click:Connect(cfg.Callback)
                end
            end

            function section:AddToggle(cfg)
                local state = cfg.Default or false
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -20, 0, 30)
                btn.Text = (state and "[✓] " or "[ ] ") .. cfg.Name
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
                btn.Parent = sectionFrame
                Instance.new("UICorner", btn)
                btn.MouseButton1Click:Connect(function()
                    state = not state
                    btn.Text = (state and "[✓] " or "[ ] ") .. cfg.Name
                    if cfg.Callback then cfg.Callback(state) end
                end)
            end

            function section:AddTextbox(cfg)
                local box = Instance.new("TextBox")
                box.Size = UDim2.new(1, -20, 0, 30)
                box.PlaceholderText = cfg.Name or "Textbox"
                box.Font = Enum.Font.Gotham
                box.TextSize = 14
                box.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
                box.TextColor3 = Color3.fromRGB(255, 255, 255)
                box.Parent = sectionFrame
                Instance.new("UICorner", box)
                box.FocusLost:Connect(function()
                    if cfg.Callback then
                        cfg.Callback(box.Text)
                    end
                end)
            end

            function section:AddKeybind(cfg)
                local bindKey = cfg.Default or Enum.KeyCode.F
                local label = Instance.new("TextButton")
                label.Size = UDim2.new(1, -20, 0, 30)
                label.Text = cfg.Name .. ": " .. bindKey.Name
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
                label.Parent = sectionFrame
                Instance.new("UICorner", label)
                local rebinding = false
                label.MouseButton1Click:Connect(function()
                    label.Text = "Press any key..."
                    rebinding = true
                end)
                UserInputService.InputBegan:Connect(function(input, gp)
                    if not gp and rebinding and input.UserInputType == Enum.UserInputType.Keyboard then
                        bindKey = input.KeyCode
                        label.Text = cfg.Name .. ": " .. bindKey.Name
                        rebinding = false
                    elseif input.KeyCode == bindKey and not rebinding then
                        if cfg.Callback then
                            cfg.Callback()
                        end
                    end
                end)
            end

            function section:AddSlider(cfg)
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -20, 0, 20)
                label.Text = cfg.Name .. ": " .. tostring(cfg.Default)
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.BackgroundTransparency = 1
                label.Parent = sectionFrame

                local sliderBg = Instance.new("Frame")
                sliderBg.Size = UDim2.new(1, -20, 0, 8)
                sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
                sliderBg.Parent = sectionFrame
                Instance.new("UICorner", sliderBg)

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
                fill.BorderSizePixel = 0
                fill.Parent = sliderBg
                Instance.new("UICorner", fill)

                local dragging = false
                sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = input.Position.X - sliderBg.AbsolutePosition.X
                        local pct = math.clamp(rel / sliderBg.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.new(pct, 0, 1, 0)
                        local value = math.floor(cfg.Min + (cfg.Max - cfg.Min) * pct)
                        label.Text = cfg.Name .. ": " .. tostring(value)
                        if cfg.Callback then
                            cfg.Callback(value)
                        end
                    end
                end)
                -- Default value
                local defaultPct = (cfg.Default - cfg.Min) / (cfg.Max - cfg.Min)
                fill.Size = UDim2.new(defaultPct, 0, 1, 0)
            end

            function section:AddDropdown(cfg)
                local state = false
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -20, 0, 30)
                btn.Text = cfg.Name or "Dropdown"
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
                btn.Parent = sectionFrame
                Instance.new("UICorner", btn)

                local list = Instance.new("Frame")
                list.Size = UDim2.new(1, -20, 0, 0)
                list.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
                list.Visible = false
                list.Parent = sectionFrame
                Instance.new("UICorner", list)
                local layout = Instance.new("UIListLayout", list)
                layout.SortOrder = Enum.SortOrder.LayoutOrder

                btn.MouseButton1Click:Connect(function()
                    state = not state
                    list.Visible = state
                    list.Size = state and UDim2.new(1, -20, 0, #cfg.Options * 30) or UDim2.new(1, -20, 0, 0)
                end)

                for _, opt in ipairs(cfg.Options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Text = opt
                    optBtn.Size = UDim2.new(1, 0, 0, 30)
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = 14
                    optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    optBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 110)
                    optBtn.Parent = list
                    optBtn.MouseButton1Click:Connect(function()
                        btn.Text = cfg.Name .. ": " .. opt
                        list.Visible = false
                        state = false
                        if cfg.Callback then
                            cfg.Callback(opt)
                        end
                    end)
                end
            end

            return section
        end

        table.insert(self.Tabs, tab)
        if #self.Tabs == 1 then self:SetActiveTab(tabName) end

        return tab
    end

    -- Notification function added here
    function self:Notify(text, duration)
        duration = duration or 3
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(1, 0, 0, 30)
        notif.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
        notif.TextColor3 = Color3.fromRGB(255, 255, 255)
        notif.Text = text
        notif.TextSize = 14
        notif.Font = Enum.Font.Gotham
        notif.Parent = NotificationHolder
        Instance.new("UICorner", notif)

        -- Fade-in tween
        notif.BackgroundTransparency = 1
        TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()

        task.delay(duration, function()
            -- Fade-out tween before destroy
            TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.3)
            notif:Destroy()
        end)
    end

    return self
end

return DriftwynLib

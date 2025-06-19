-- DriftwynLib - UI Library
local DriftwynLib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- CreateWindow method
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

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 8)

    -- Make draggable
    local dragging, dragStart, startPos = false, nil, nil
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
    TabButtonsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
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

    local ContentCorner = Instance.new("UICorner", ContentFrame)
    ContentCorner.CornerRadius = UDim.new(0, 6)

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

        local tabContent = Instance.new("Frame")
        tabContent.Name = tabName .. "_Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
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
            sectionFrame.Size = UDim2.new(1, 0, 0, 100)
            sectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = tabContent

            local corner = Instance.new("UICorner", sectionFrame)
            corner.CornerRadius = UDim.new(0, 6)

            local title = Instance.new("TextLabel")
            title.Text = sectionTitle
            title.Font = Enum.Font.GothamBold
            title.TextSize = 16
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.BackgroundTransparency = 1
            title.Position = UDim2.new(0, 10, 0, 5)
            title.Size = UDim2.new(1, -20, 0, 25)
            title.Parent = sectionFrame

            function section:AddButton(btnCfg)
                local btn = Instance.new("TextButton")
                btn.Text = btnCfg.Name or "Button"
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.Size = UDim2.new(1, -20, 0, 30)
                btn.Position = UDim2.new(0, 10, 0, 35)
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Parent = sectionFrame
                btn.BorderSizePixel = 0

                local uic = Instance.new("UICorner", btn)
                uic.CornerRadius = UDim.new(0, 4)

                if btnCfg.Callback then
                    btn.MouseButton1Click:Connect(btnCfg.Callback)
                end
            end

            function section:AddKeybind(bindCfg)
                local key = bindCfg.Default or Enum.KeyCode.F

                local holder = Instance.new("Frame")
                holder.Size = UDim2.new(1, -20, 0, 30)
                holder.Position = UDim2.new(0, 10, 0, 70)
                holder.BackgroundTransparency = 1
                holder.Parent = sectionFrame

                local label = Instance.new("TextLabel")
                label.Text = bindCfg.Name or "Keybind"
                label.Size = UDim2.new(0.5, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = holder

                local keyBtn = Instance.new("TextButton")
                keyBtn.Size = UDim2.new(0.5, 0, 1, 0)
                keyBtn.Position = UDim2.new(0.5, 0, 0, 0)
                keyBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
                keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                keyBtn.Font = Enum.Font.Gotham
                keyBtn.TextSize = 14
                keyBtn.Text = key.Name
                keyBtn.Parent = holder

                local rebinding = false
                keyBtn.MouseButton1Click:Connect(function()
                    keyBtn.Text = "Press key..."
                    rebinding = true
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if not gpe then
                        if rebinding and input.UserInputType == Enum.UserInputType.Keyboard then
                            key = input.KeyCode
                            keyBtn.Text = key.Name
                            rebinding = false
                        elseif input.KeyCode == key and not rebinding then
                            if bindCfg.Callback then
                                bindCfg.Callback()
                            end
                        end
                    end
                end)
            end

            return section
        end

        table.insert(self.Tabs, tab)
        if #self.Tabs == 1 then
            self:SetActiveTab(tabName)
        end

        return tab
    end

    return self
end

return DriftwynLib

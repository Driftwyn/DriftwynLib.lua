local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local DriftwynLib = {}

function DriftwynLib:CreateWindow(config)
    local self = {}
    self.Title = config.Name or "Driftwyn UI"
    
    -- Create ScreenGui
    local DriftwynUI = Instance.new("ScreenGui")
    DriftwynUI.Name = "DriftwynUI"
    DriftwynUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    DriftwynUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Create Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = DriftwynUI
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.8287, -250, 0.9615, -175)
    MainFrame.Size = UDim2.new(0, 618, 0, 350)
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = MainFrame
    
    -- Border frames (top, left, bottom, right)
    local function createBorder(name, pos, size)
        local f = Instance.new("Frame")
        f.Name = name
        f.Parent = MainFrame
        f.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        f.BorderColor3 = Color3.fromRGB(0, 0, 0)
        f.BorderSizePixel = 0
        f.Position = pos
        f.Size = size
        return f
    end
    
    createBorder("TopFrame", UDim2.new(0, 0, 0, 0), UDim2.new(1, 5, 0, 6))
    createBorder("LeftFrame", UDim2.new(0, 0, 0, 6), UDim2.new(0, 8, 1, -12))
    createBorder("ButtomFrame", UDim2.new(0, 0, 1, -6), UDim2.new(1, 0, 0, 6))
    createBorder("RightFrame", UDim2.new(1, -8, 0, 6), UDim2.new(0, 8, 1, -12))
    
    -- Title label
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.013, 0, 0.017, 0)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.Unknown
    Title.Text = self.Title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    
    -- Tabs buttons holder (horizontal bar)
    local TabButtonsHolder = Instance.new("Frame")
    TabButtonsHolder.Name = "TabButtonsHolder"
    TabButtonsHolder.Parent = MainFrame
    TabButtonsHolder.BackgroundTransparency = 1
    TabButtonsHolder.Position = UDim2.new(0, 0, 0, 30)
    TabButtonsHolder.Size = UDim2.new(1, 0, 0, 30)
    
    -- Content holder for tabs
    local TabContentHolder = Instance.new("Frame")
    TabContentHolder.Name = "TabContentHolder"
    TabContentHolder.Parent = MainFrame
    TabContentHolder.BackgroundTransparency = 1
    TabContentHolder.Position = UDim2.new(0, 0, 0, 60)
    TabContentHolder.Size = UDim2.new(1, 0, 1, -60)
    
    -- Toggle button (same as original)
    local ToggleButton = Instance.new("ImageButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = DriftwynUI
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(0.0067, 0, 0.6079, 0)
    ToggleButton.Size = UDim2.new(0, 46, 0, 45)
    ToggleButton.Image = "rbxassetid://11696689778"
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 50)
    toggleCorner.Parent = ToggleButton
    
    -- Make MainFrame draggable (Improved)
    do
        local dragging = false
        local dragStart, startPos
        MainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local focused = UserInputService:GetFocusedTextBox()
                if not focused and not input.Target:IsDescendantOf(TabContentHolder) then
                    dragging = true
                    dragStart = input.Position
                    startPos = MainFrame.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    -- Tab system
    local Tabs = {}
    
    function self:AddTab(tabConfig)
        local tabName = tabConfig.Name or "Tab"
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.Text = tabName
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 14
        tabButton.Parent = TabButtonsHolder
        
        -- Position button horizontally
        local btnCount = #Tabs + 1
        tabButton.Position = UDim2.new(0, (btnCount - 1) * 100, 0, 0)
        
        -- Create content frame for this tab
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.ScrollBarThickness = 4
        tabContent.Visible = false
        tabContent.Parent = TabContentHolder
        
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Padding = UDim.new(0, 8)
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = tabContent
        
        -- Resize canvas when content changes
        UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local Sections = {}
        
        -- Section creator inside the tab
        function self:AddSectionToTab(tab, sectionConfig)
            local sectionName = sectionConfig.Name or "Section"
            
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, -20, 0, 150)
            sectionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = tab.Content
            
            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 6)
            UICorner.Parent = sectionFrame
            
            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Text = sectionName
            sectionLabel.Size = UDim2.new(1, 0, 0, 25)
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            sectionLabel.Font = Enum.Font.GothamBold
            sectionLabel.TextSize = 16
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = sectionFrame
            
            local contentFrame = Instance.new("Frame")
            contentFrame.Size = UDim2.new(1, 0, 1, -25)
            contentFrame.Position = UDim2.new(0, 0, 0, 25)
            contentFrame.BackgroundTransparency = 1
            contentFrame.Parent = sectionFrame
            
            -- Add controls container inside the section
            local controlsLayout = Instance.new("UIListLayout")
            controlsLayout.Padding = UDim.new(0, 6)
            controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            controlsLayout.Parent = contentFrame
            
            local SectionObj = {}
            SectionObj.Frame = sectionFrame
            SectionObj.Content = contentFrame
            
            -- AddButton method
            function SectionObj:AddButton(buttonConfig)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 30)
                btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Text = buttonConfig.Name or "Button"
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.BorderSizePixel = 0
                btn.Parent = contentFrame
                
                btn.MouseButton1Click:Connect(function()
                    if buttonConfig.Callback then
                        buttonConfig.Callback()
                    end
                end)
            end
            
            -- AddToggle method
            function SectionObj:AddToggle(toggleConfig)
                local holder = Instance.new("Frame")
                holder.Size = UDim2.new(1, 0, 0, 30)
                holder.BackgroundTransparency = 1
                holder.Parent = contentFrame
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.7, 0, 1, 0)
                label.Text = toggleConfig.Name or "Toggle"
                label.TextWrapped = true
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = holder
                
                local toggle = Instance.new("Frame")
                toggle.Size = UDim2.new(0, 50, 0, 22)
                toggle.Position = UDim2.new(1, -60, 0.5, -11)
                toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                toggle.BorderSizePixel = 0
                toggle.Parent = holder
                
                Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
                
                local circle = Instance.new("Frame")
                circle.Size = UDim2.new(0, 20, 0, 20)
                circle.Position = UDim2.new(0, 1, 0.5, -10)
                circle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                circle.BorderSizePixel = 0
                circle.Parent = toggle
                Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
                
                local toggled = toggleConfig.Default or false
                
                local function updateVisual(state)
                    local goalPos = state and UDim2.new(1, -21, 0.5, -10) or UDim2.new(0, 1, 0.5, -10)
                    local goalColor = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
                    local goalBg = state and Color3.fromRGB(60, 150, 60) or Color3.fromRGB(70, 70, 70)
                    
                    TweenService:Create(circle, TweenInfo.new(0.25), { Position = goalPos, BackgroundColor3 = goalColor }):Play()
                    TweenService:Create(toggle, TweenInfo.new(0.25), { BackgroundColor3 = goalBg }):Play()
                end
                
                updateVisual(toggled)
                
                toggle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        toggled = not toggled
                        updateVisual(toggled)
                        if toggleConfig.Callback then
                            toggleConfig.Callback(toggled)
                        end
                    end
                end)
            end
            
            -- AddTextbox method
            function SectionObj:AddTextbox(textboxConfig)
                local holder = Instance.new("Frame")
                holder.Size = UDim2.new(1, 0, 0, 30)
                holder.BackgroundTransparency = 1
                holder.Parent = contentFrame
                
                local label = Instance.new("TextLabel")
                label.Text = textboxConfig.Name or "Textbox"
                label.Size = UDim2.new(0.4, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = holder
                
                local textbox = Instance.new("TextBox")
                textbox.Size = UDim2.new(0.6, -10, 1, 0)
                textbox.Position = UDim2.new(0.4, 10, 0, 0)
                textbox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
                textbox.PlaceholderText = textboxConfig.Placeholder or "Enter here..."
                textbox.Font = Enum.Font.Gotham
                textbox.TextSize = 14
                textbox.ClearTextOnFocus = false
                textbox.BorderSizePixel = 0
                textbox.Parent = holder
                
                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = textbox
                
                textbox.FocusLost:Connect(function(enterPressed)
                    if enterPressed and textboxConfig.Callback then
                        textboxConfig.Callback(textbox.Text)
                    end
                end)
            end
            
            -- You can add more controls here: AddSlider, AddDropdown, AddKeybind, etc.
            
            table.insert(Sections, SectionObj)
            return SectionObj
        end
        
        -- Create tab object with AddSection method
        local TabObj = {
            Button = tabButton,
            Content = tabContent,
            Sections = Sections,
            AddSection = function(_, sectionConfig)
                return self:AddSectionToTab(TabObj, sectionConfig)
            end,
        }
        
        table.insert(Tabs, TabObj)
        
        -- On tab button click: show this tab content, hide others
        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end
            tabContent.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        end)
        
        -- Auto-select first tab on creation
        if #Tabs == 1 then
            tabButton:MouseButton1Click()
        end
        
        return TabObj
    end
    
    -- Toggle the entire UI visibility with the toggle button
    ToggleButton.MouseButton1Click:Connect(function()
        DriftwynUI.Enabled = not DriftwynUI.Enabled
    end)
    
    -- Return UI API object
    self.ScreenGui = DriftwynUI
    self.MainFrame = MainFrame
    self.ToggleButton = ToggleButton
    
    return self
end

return DriftwynLib

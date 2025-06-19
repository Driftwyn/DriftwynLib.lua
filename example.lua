-- DriftwynLib ModuleScript

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local DriftwynLib = {}
DriftwynLib.__index = DriftwynLib

-- Create the main UI once per library load
local function createMainUI(title)
    -- Create ScreenGui
    local DriftwynUI = Instance.new("ScreenGui")
    DriftwynUI.Name = "DriftwynUI"
    DriftwynUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    DriftwynUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Create MainFrame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = DriftwynUI
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 618, 0, 350)

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 6)

    -- Create Title label
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title or "Driftwyn UI"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Position = UDim2.new(0, 10, 0, 5)

    -- Create ContentFrame for buttons, toggles, etc
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 10, 0, 40)
    ContentFrame.Size = UDim2.new(1, -20, 1, -50)

    -- UIListLayout for stacking elements nicely
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = ContentFrame

    -- Dragging logic for MainFrame
    local dragging = false
    local dragStart
    local startPos

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
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    return DriftwynUI, MainFrame, ContentFrame
end

-- Window object
local Window = {}
Window.__index = Window

function Window:AddButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = name
    btn.BorderSizePixel = 0
    btn.Parent = self.ContentFrame

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

function Window:AddToggle(name, defaultState, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 30)
    holder.BackgroundTransparency = 1
    holder.Parent = self.ContentFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = name
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

    local toggleCorner = Instance.new("UICorner", toggle)
    toggleCorner.CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = UDim2.new(0, 1, 0.5, -10)
    circle.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    circle.BorderSizePixel = 0
    circle.Parent = toggle

    local circleCorner = Instance.new("UICorner", circle)
    circleCorner.CornerRadius = UDim.new(1, 0)

    local toggled = defaultState or false

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
            if callback then callback(toggled) end
        end
    end)
end

function Window:AddSlider(name, min, max, defaultValue, callback)
    local value = defaultValue or min

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 40)
    holder.BackgroundTransparency = 1
    holder.Parent = self.ContentFrame

    local label = Instance.new("TextLabel")
    label.Text = name .. ": " .. tostring(value)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0, 10)
    sliderBar.Position = UDim2.new(0, 0, 0, 25)
    sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = holder

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar

    local dragging = false

    local function update(val)
        value = math.clamp(math.floor(val + 0.5), min, max)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = name .. ": " .. tostring(value)
        if callback then callback(value) end
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X) * (max - min) + min)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X) * (max - min) + min)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Window:AddTextbox(name, placeholderText, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 30)
    holder.BackgroundTransparency = 1
    holder.Parent = self.ContentFrame

    local label = Instance.new("TextLabel")
    label.Text = name
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
    textbox.PlaceholderText = placeholderText or "Enter here..."
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 14
    textbox.ClearTextOnFocus = false
    textbox.BorderSizePixel = 0
    textbox.Parent = holder

    local UICorner = Instance.new("UICorner", textbox)
    UICorner.CornerRadius = UDim.new(0, 4)

    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(textbox.Text)
        end
    end)
end

-- You can add Dropdown and Keybind similarly here...

-- Constructor for new window
function DriftwynLib:MakeWindow(config)
    local title = config and config.Name or "Driftwyn UI"
    local gui, mainFrame, contentFrame = createMainUI(title)

    local window = setmetatable({}, Window)
    window.DriftwynUI = gui
    window.MainFrame = mainFrame
    window.ContentFrame = contentFrame

    return window
end

return DriftwynLib

--  PUPPET UI LIB

local UI = {}
UI.Tabs = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PuppetUILib"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 360)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Hide Button
local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0,30,1,0)
HideBtn.Position = UDim2.new(1,-30,0,0)
HideBtn.BackgroundTransparency = 1
HideBtn.Text = "-"
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 18
HideBtn.TextColor3 = Color3.fromRGB(255,255,255)
HideBtn.Parent = TopBar

HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Left Tab Panel
local TabFrame = Instance.new("ScrollingFrame")
TabFrame.Size = UDim2.new(0, 120, 1, -32)
TabFrame.Position = UDim2.new(0,0,1,0)
TabFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
TabFrame.BorderSizePixel = 0
TabFrame.CanvasSize = UDim2.new(0,0,2,0)
TabFrame.ScrollBarThickness = 2
TabFrame.Parent = MainFrame

-- Right Content Panel
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -120, 1, -32)
ContentFrame.Position = UDim2.new(0,120,0,32)
ContentFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
ContentFrame.CanvasSize = UDim2.new(0,0,5,0)
ContentFrame.ScrollBarThickness = 4
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- Tab Constructor
function UI:CreateWindow(Name)
    Title.Text = Name
    return UI
end

function UI:CreateTab(TabName)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1,0,0,30)
    TabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    TabBtn.Text = TabName
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextColor3 = Color3.fromRGB(220,220,220)
    TabBtn.TextSize = 13
    TabBtn.Parent = TabFrame

    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1,0,5,0)
    TabContent.BackgroundTransparency = 1
    TabContent.Parent = ContentFrame

    TabContent.Visible = false

    UI.Tabs[TabName] = TabContent

    TabBtn.MouseButton1Click:Connect(function()
        for _,v in pairs(UI.Tabs) do
            v.Visible = false
        end
        TabContent.Visible = true
    end)

    local API = {}

    function API:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Position = UDim2.new(0,5,0,TabContent:GetChildren() and #TabContent:GetChildren()*35)
        btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = TabContent

        btn.MouseButton1Click:Connect(callback)
    end

    function API:AddToggle(text, callback)
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(1, -10, 0, 30)
        ToggleBtn.Position = UDim2.new(0,5,0,TabContent:GetChildren() and #TabContent:GetChildren()*35)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        ToggleBtn.Text = text.." [ OFF ]"
        ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.TextSize = 13
        ToggleBtn.Parent = TabContent

        local state = false
        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            ToggleBtn.Text = text .. (state and " [ ON ]" or " [ OFF ]")
            callback(state)
        end)
    end

    TabContent.Visible = true
    return API
end

return UI


local PUPPET = {}
PUPPET.__index = PUPPET

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Player = game.Players.LocalPlayer

-- CreateWindow
function PUPPET:CreateWindow(props)
	props = props or {}
	local Title = props.Title or "PUPPET UI"
	local Size = props.Size or UDim2.new(0.7, 0, 0.6, 0)

	local Screen = Instance.new("ScreenGui")
	Screen.Name = "PUPPET_UI_V2"
	Screen.ResetOnSpawn = false
	Screen.Parent = CoreGui

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = Size
	MainFrame.Position = UDim2.new(0.5, -MainFrame.AbsoluteSize.X/2, 0.5, -MainFrame.AbsoluteSize.Y/2)
	MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
	MainFrame.BorderSizePixel = 0
	MainFrame.Parent = Screen

	local RoundCorner = Instance.new("UICorner")
	RoundCorner.CornerRadius = UDim.new(0,12)
	RoundCorner.Parent = MainFrame

	-- Dragging Window
	local dragging
	local dragPos

	MainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragPos = input.Position
		end
	end)

	MainFrame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragPos
			MainFrame.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset + delta.X,
				MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + delta.Y)
			dragPos = input.Position
		end
	end)

	-- TAB LIST (Left Side)
	local TabList = Instance.new("Frame")
	TabList.Name = "TabList"
	TabList.Size = UDim2.new(0.2, 0, 1, 0)
	TabList.BackgroundColor3 = Color3.fromRGB(15,15,15)
	TabList.BorderSizePixel = 0
	TabList.Parent = MainFrame

	local TabLayout = Instance.new("UIListLayout")
	TabLayout.Padding = UDim.new(0, 3)
	TabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	TabLayout.Parent = TabList

	-- Pages Holder
	local window = setmetatable({
		Screen = Screen,
		MainFrame = MainFrame,
		TabList = TabList,
		Tabs = {},
	}, PUPPET)

	return window
end

-- AddTab
function PUPPET:AddTab(name)
	local Tab = Instance.new("TextButton")
	Tab.Name = name
	Tab.Text = " " .. name
	Tab.Font = Enum.Font.Gotham
	Tab.TextSize = 14
	Tab.Size = UDim2.new(1, -10, 0, 35)
	Tab.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Tab.TextColor3 = Color3.fromRGB(255,255,255)
	Tab.Parent = self.TabList

	local Page = Instance.new("ScrollingFrame")
	Page.Name = name.."_Page"
	Page.Visible = false
	Page.Size = UDim2.new(0.8, -10, 1, -10)
	Page.Position = UDim2.new(0.2, 10, 0, 10)
	Page.CanvasSize = UDim2.new(0,0,0,0)
	Page.ScrollBarThickness = 4
	Page.BackgroundTransparency = 1
	Page.Parent = self.MainFrame

	local UIList = Instance.new("UIListLayout")
	UIList.Padding = UDim.new(0, 6)
	UIList.Parent = Page

	UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y + 20)
	end)

	Tab.MouseButton1Click:Connect(function()
		for _, v in pairs(self.Tabs) do
			v.Page.Visible = false
			v.Tab.BackgroundColor3 = Color3.fromRGB(30,30,30)
		end
		Page.Visible = true
		Tab.BackgroundColor3 = Color3.fromRGB(60,60,60)
	end)

	table.insert(self.Tabs, {Tab = Tab, Page = Page})

	if #self.Tabs == 1 then
		Page.Visible = true
		Tab.BackgroundColor3 = Color3.fromRGB(60,60,60)
	end

	return Page
end

return PUPPET


local PUPPET = {}
PUPPET.__index = PUPPET

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Default image path (uses uploaded file in conversation)
local DEFAULT_SHOW_IMAGE = "sandbox:/mnt/data/1000024637.jpg"

-- Themes
local Themes = {
    Black = {
        Main = Color3.fromRGB(15,15,15),
        Sidebar = Color3.fromRGB(18,18,18),
        Element = Color3.fromRGB(28,28,28),
        ElementHover = Color3.fromRGB(40,40,40),
        Accent = Color3.fromRGB(200,200,255),
        ToggleOn = Color3.fromRGB(0,170,140),
        ToggleOff = Color3.fromRGB(120,30,30),
        Text = Color3.fromRGB(235,235,235),
    },
    Dark = {
        Main = Color3.fromRGB(30,30,30),
        Sidebar = Color3.fromRGB(40,40,40),
        Element = Color3.fromRGB(50,50,50),
        ElementHover = Color3.fromRGB(65,65,65),
        Accent = Color3.fromRGB(170,200,255),
        ToggleOn = Color3.fromRGB(70,160,140),
        ToggleOff = Color3.fromRGB(150,60,60),
        Text = Color3.fromRGB(240,240,240),
    },
    Blossom = {
        Main = Color3.fromRGB(30,18,28),
        Sidebar = Color3.fromRGB(45,20,40),
        Element = Color3.fromRGB(65,30,60),
        ElementHover = Color3.fromRGB(85,40,80),
        Accent = Color3.fromRGB(255,160,200),
        ToggleOn = Color3.fromRGB(255,120,170),
        ToggleOff = Color3.fromRGB(120,50,80),
        Text = Color3.fromRGB(250,240,250),
    }
}

local CurrentTheme = Themes.Black

local function applyColor(obj, property, color)
    if obj and obj[property] ~= nil then
        obj[property] = color
    end
end

function PUPPET:SetTheme(name)
    if Themes[name] then
        CurrentTheme = Themes[name]
        -- update all open GUIs
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui.Name and string.find(gui.Name, "PUPPET_UI_") then
                for _, child in pairs(gui:GetDescendants()) do
                    if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                        -- naive recolor: rely on naming conventions for elements
                        if child.Name == "PU_MainFrame" then
                            applyColor(child, "BackgroundColor3", CurrentTheme.Main)
                        elseif child.Name == "PU_Sidebar" then
                            applyColor(child, "BackgroundColor3", CurrentTheme.Sidebar)
                        elseif child.Name == "PU_Element" then
                            applyColor(child, "BackgroundColor3", CurrentTheme.Element)
                        elseif child.Name == "PU_ElementHover" then
                            applyColor(child, "BackgroundColor3", CurrentTheme.ElementHover)
                        elseif child.Name == "PU_Accent" then
                            applyColor(child, "TextColor3", CurrentTheme.Accent)
                        elseif child.Name == "PU_Text" then
                            applyColor(child, "TextColor3", CurrentTheme.Text)
                        end
                    end
                end
            end
        end
    end
end

function PUPPET:Notify(title, text, duration)
    duration = duration or 5
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = tostring(title), Text = tostring(text), Duration = duration})
    end)
end

-- Internal helper: create a new ScreenGui with unique name
local function newScreenGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "PUPPET_UI_"..tostring(math.random(1000,9999))
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui
    return sg
end

-- CreateWindow: returns window object with methods AddTab, SetTheme, Notify etc.
function PUPPET:CreateWindow(props)
    props = props or {}
    local Title = props.Title or "PUPPET UI"
    local Size = props.Size or UDim2.new(0,600,0,380)
    local Corner = props.CornerRadius or 12
    local ShowImage = props.ShowImage or DEFAULT_SHOW_IMAGE

    local sg = newScreenGui()

    local Main = Instance.new("Frame")
    Main.Name = "PU_MainFrame"
    Main.Size = Size
    Main.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
    Main.BackgroundColor3 = CurrentTheme.Main
    Main.BorderSizePixel = 0
    Main.Parent = sg
    local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0, Corner) mc.Parent = Main

    -- Titlebar
    local Top = Instance.new("Frame") Top.Name = "PU_Top" Top.Size = UDim2.new(1,0,0,36) Top.Position = UDim2.new(0,0,0,0)
    Top.BackgroundTransparency = 1 Top.Parent = Main
    local TitleLabel = Instance.new("TextLabel") TitleLabel.Name = "PU_Title" TitleLabel.Size = UDim2.new(0.7,0,1,0)
    TitleLabel.Position = UDim2.new(0,12,0,0) TitleLabel.BackgroundTransparency = 1 TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16 TitleLabel.TextColor3 = CurrentTheme.Text TitleLabel.Text = Title TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Top

    -- Close button
    local Close = Instance.new("TextButton") Close.Name = "PU_Close" Close.Size = UDim2.new(0,36,0,26)
    Close.Position = UDim2.new(1,-44,0,5) Close.Text = "X" Close.Font = Enum.Font.GothamBold Close.TextColor3 = Color3.new(1,1,1)
    Close.BackgroundColor3 = Color3.fromRGB(130,20,20) Close.Parent = Top Instance.new("UICorner", Close).CornerRadius = UDim.new(0,6)

    -- Sidebar
    local Sidebar = Instance.new("Frame") Sidebar.Name = "PU_Sidebar" Sidebar.Size = UDim2.new(0,140,1,-36)
    Sidebar.Position = UDim2.new(0,0,0,36) Sidebar.BackgroundColor3 = CurrentTheme.Sidebar Sidebar.Parent = Main
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, math.max(0, Corner-4))
    local SideLayout = Instance.new("UIListLayout") SideLayout.Parent = Sidebar SideLayout.Padding = UDim.new(0,8)

    -- Pages folder
    local PagesFolder = Instance.new("Folder") PagesFolder.Name = "PU_Pages" PagesFolder.Parent = Main

    -- Resize handle
    local Resizer = Instance.new("Frame") Resizer.Name = "PU_Resizer" Resizer.Size = UDim2.new(0,18,0,18)
    Resizer.Position = UDim2.new(1,-18,1,-18) Resizer.BackgroundTransparency = 1 Resizer.Parent = Main
    local ResCorner = Instance.new("UICorner") ResCorner.Parent = Resizer

    -- Show button (floating)
    local ShowBtn = Instance.new("ImageButton") ShowBtn.Name = "PU_ShowButton" ShowBtn.Size = UDim2.new(0,48,0,48)
    ShowBtn.Position = UDim2.new(0.02,0,0.82,0) ShowBtn.Image = ShowImage ShowBtn.BackgroundColor3 = CurrentTheme.Accent
    ShowBtn.Parent = sg Instance.new("UICorner", ShowBtn).CornerRadius = UDim.new(0,24)
    ShowBtn.Visible = false

    -- Dragging main
    do
        local dragging, start, startPos
        Main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true start = input.Position startPos = Main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        Main.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement and dragging and start and startPos then
                local delta = i.Position - start
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- Resize logic
    do
        local resizing, startMouse, startSize
        Resizer.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true startMouse = input.Position startSize = Main.Size
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then resizing = false end end)
            end
        end)
        Resizer.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                Resizer._drag = input
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if resizing and input.UserInputType == Enum.UserInputType.MouseMovement and startMouse and startSize then
                local delta = input.Position - startMouse
                local newX = math.clamp(startSize.X.Offset + delta.X, 260, 1400)
                local newY = math.clamp(startSize.Y.Offset + delta.Y, 180, 1000)
                Main.Size = UDim2.new(0, newX, 0, newY)
            end
        end)
    end

    -- Close/Show behavior
    Close.MouseButton1Click:Connect(function()
        Main.Visible = false
        ShowBtn.Visible = true
    end)
    ShowBtn.MouseButton1Click:Connect(function()
        Main.Visible = true
        ShowBtn.Visible = false
    end)

    local window = setmetatable({
        _SG = sg,
        _Main = Main,
        _Sidebar = Sidebar,
        _Pages = PagesFolder,
        _Theme = CurrentTheme,
    }, PUPPET)

    -- API: AddTab
    function window:AddTab(tabName)
        local btn = Instance.new("TextButton") btn.Name = "PU_Tab" btn.Text = tabName
        btn.Size = UDim2.new(1,-16,0,36) btn.BackgroundColor3 = CurrentTheme.Element btn.TextColor3 = CurrentTheme.Text
        btn.Font = Enum.Font.GothamBold btn.TextSize = 14 btn.Parent = self._Sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,18) -- pill style

        local page = Instance.new("ScrollingFrame") page.Name = tabName.."_Page"
        page.Size = UDim2.new(1,-150,1,-24) page.Position = UDim2.new(0,150,0,12) page.BackgroundTransparency = 1
        page.ScrollBarThickness = 6 page.Parent = self._Main
        Instance.new("UIListLayout", page).Padding = UDim.new(0,8)

        btn.MouseButton1Click:Connect(function()
            for _,c in pairs(self._Main:GetChildren()) do if c:IsA("ScrollingFrame") then c.Visible = false end end
            page.Visible = true
        end)

        if #self._Pages:GetChildren() == 0 then page.Visible = true end

        page.Visible = false
        page.Parent = self._Main
        page.Name = tabName.."_Page"
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y

        table.insert(self._Pages:GetChildren(), page)
        return page
    end

    -- API: AddButton
    function window:AddButton(page, text, cb)
        cb = cb or function() end
        local b = Instance.new("TextButton") b.Name = "PU_Element" b.Text = text
        b.Size = UDim2.new(1,-24,0,38) b.BackgroundColor3 = CurrentTheme.Element b.TextColor3 = CurrentTheme.Text
        b.Font = Enum.Font.GothamBold b.TextSize = 14 b.Parent = page
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,18)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = CurrentTheme.ElementHover end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = CurrentTheme.Element end)
        b.MouseButton1Click:Connect(function() pcall(cb) end)
        return b
    end

    -- API: AddToggle (switch style)
    function window:AddToggle(page, labelText, default, cb)
        cb = cb or function() end
        local container = Instance.new("Frame") container.Name = "PU_Element" container.Size = UDim2.new(1,-24,0,44)
        container.BackgroundTransparency = 1 container.Parent = page

        local lbl = Instance.new("TextLabel") lbl.Name = "PU_Text" lbl.Size = UDim2.new(0.7,0,1,0)
        lbl.BackgroundTransparency = 1 lbl.Text = labelText lbl.Font = Enum.Font.Gotham lbl.TextSize = 14 lbl.TextColor3 = CurrentTheme.Text lbl.Parent = container

        local sw = Instance.new("Frame") sw.Name = "PU_Switch" sw.Size = UDim2.new(0,56,0,26) sw.Position = UDim2.new(1,-66,0,9)
        sw.BackgroundColor3 = default and CurrentTheme.ToggleOn or CurrentTheme.ToggleOff sw.Parent = container
        Instance.new("UICorner", sw).CornerRadius = UDim.new(0,16)

        local knob = Instance.new("Frame") knob.Name = "PU_Knob" knob.Size = UDim2.new(0,22,0,22)
        knob.Position = default and UDim2.new(1,-26,0,2) or UDim2.new(0,2,0,2) knob.BackgroundColor3 = Color3.fromRGB(255,255,255) knob.Parent = sw
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0,12)

        local state = default or false
        local function update()
            sw.BackgroundColor3 = state and CurrentTheme.ToggleOn or CurrentTheme.ToggleOff
            knob:TweenPosition(state and UDim2.new(1,-26,0,2) or UDim2.new(0,2,0,2), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.18, true)
        end
        update()

        local btn = Instance.new("TextButton") btn.Size = UDim2.new(1,0,1,0) btn.BackgroundTransparency = 1 btn.Parent = container
        btn.MouseButton1Click:Connect(function()
            state = not state update() pcall(cb, state)
        end)

        return {Container = container, Get = function() return state end, Set = function(v) state = v update() end}
    end

    -- API: AddSlider
    function window:AddSlider(page, labelText, min, max, default, cb)
        cb = cb or function() end
        min = min or 0 max = max or 100 default = default or min
        local cont = Instance.new("Frame") cont.Name = "PU_Element" cont.Size = UDim2.new(1,-24,0,58) cont.BackgroundTransparency = 1 cont.Parent = page
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1,0,0,18) lbl.BackgroundTransparency = 1 lbl.Text = (labelText..": "..tostring(default)) lbl.Font = Enum.Font.Gotham lbl.TextSize = 13 lbl.TextColor3 = CurrentTheme.Text lbl.Parent = cont
        local barBg = Instance.new("Frame") barBg.Size = UDim2.new(1,0,0,18) barBg.Position = UDim2.new(0,0,0,34) barBg.BackgroundColor3 = CurrentTheme.Element barBg.Parent = cont Instance.new("UICorner", barBg).CornerRadius = UDim.new(0,10)
        local barFill = Instance.new("Frame") barFill.Size = UDim2.new((default-min)/(max-min),0,1,0) barFill.BackgroundColor3 = CurrentTheme.Accent barFill.Parent = barBg Instance.new("UICorner", barFill).CornerRadius = UDim.new(0,10)
        local dragging = false
        barBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
        barBg.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local abs = i.Position.X local left = barBg.AbsolutePosition.X local w = barBg.AbsoluteSize.X local pct = math.clamp((abs-left)/w,0,1)
                barFill.Size = UDim2.new(pct,0,1,0) local val = min + (max-min)*pct val = math.floor(val*100)/100 lbl.Text = (labelText..": "..tostring(val)) pcall(cb,val)
            end
        end)
        pcall(cb, default)
        return cont
    end

    -- API: AddDropdown (single select)
    function window:AddDropdown(page, labelText, items, cb)
        cb = cb or function() end
        local cont = Instance.new("Frame") cont.Name = "PU_Element" cont.Size = UDim2.new(1,-24,0,40) cont.BackgroundTransparency = 1 cont.Parent = page
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0.6,0,1,0) lbl.BackgroundTransparency = 1 lbl.Text = labelText lbl.Font = Enum.Font.Gotham lbl.TextSize = 13 lbl.TextColor3 = CurrentTheme.Text lbl.Parent = cont
        local btn = Instance.new("TextButton") btn.Size = UDim2.new(0.36,0,0.8,0) btn.Position = UDim2.new(0.64,0,0.1,0) btn.Text = "Select" btn.Parent = cont Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        local list = Instance.new("Frame") list.Size = UDim2.new(1,0,0,0) list.Position = UDim2.new(0,0,1,6) list.ClipsDescendants = true list.BackgroundColor3 = CurrentTheme.Element list.Parent = cont
        local layout = Instance.new("UIListLayout") layout.Parent = list
        for i,v in ipairs(items or {}) do
            local opt = Instance.new("TextButton") opt.Size = UDim2.new(1,0,0,28) opt.Text = tostring(v) opt.BackgroundColor3 = CurrentTheme.Element opt.TextColor3 = CurrentTheme.Text opt.Parent = list Instance.new("UICorner", opt).CornerRadius = UDim.new(0,8)
            opt.MouseButton1Click:Connect(function() btn.Text = tostring(v) list.Size = UDim2.new(1,0,0,0) pcall(cb,v) end)
        end
        btn.MouseButton1Click:Connect(function() list.Size = (list.Size.Y.Offset==0) and UDim2.new(1,0,0,#items*28) or UDim2.new(1,0,0,0) end)
        return cont
    end

    -- API: AddMultiDropdown (multi select)
    function window:AddMultiDropdown(page,labelText, items, cb)
        cb = cb or function() end
        local cont = Instance.new("Frame") cont.Name = "PU_Element" cont.Size = UDim2.new(1,-24,0,40) cont.BackgroundTransparency = 1 cont.Parent = page
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0.6,0,1,0) lbl.BackgroundTransparency = 1 lbl.Text = labelText lbl.Font = Enum.Font.Gotham lbl.TextSize = 13 lbl.TextColor3 = CurrentTheme.Text lbl.Parent = cont
        local btn = Instance.new("TextButton") btn.Size = UDim2.new(0.36,0,0.8,0) btn.Position = UDim2.new(0.64,0,0.1,0) btn.Text = "Select" btn.Parent = cont Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        local list = Instance.new("Frame") list.Size = UDim2.new(1,0,0,0) list.Position = UDim2.new(0,0,1,6) list.ClipsDescendants = true list.BackgroundColor3 = CurrentTheme.Element list.Parent = cont
        local layout = Instance.new("UIListLayout") layout.Parent = list
        local selected = {}
        local function updateBtn() btn.Text = (#selected==0) and "Select" or (#selected.." selected") end
        for i,v in ipairs(items or {}) do
            local opt = Instance.new("TextButton") opt.Size = UDim2.new(1,0,0,28) opt.Text = tostring(v) opt.BackgroundColor3 = CurrentTheme.Element opt.TextColor3 = CurrentTheme.Text opt.Parent = list Instance.new("UICorner", opt).CornerRadius = UDim.new(0,8)
            opt.MouseButton1Click:Connect(function()
                local exists=false
                for idx,val in ipairs(selected) do if val==v then table.remove(selected, idx); exists=true; break end end
                if not exists then table.insert(selected, v) end updateBtn() pcall(cb, selected)
            end)
        end
        btn.MouseButton1Click:Connect(function() list.Size = (list.Size.Y.Offset==0) and UDim2.new(1,0,0,#items*28) or UDim2.new(1,0,0,0) end)
        return cont
    end

    -- API: SetTheme (per window)
    function window:SetTheme(name)
        if Themes[name] then
            CurrentTheme = Themes[name]
            -- apply immediate theme to key parts of this window
            Main.BackgroundColor3 = CurrentTheme.Main
            Sidebar.BackgroundColor3 = CurrentTheme.Sidebar
            TitleLabel.TextColor3 = CurrentTheme.Text
            ShowBtn.BackgroundColor3 = CurrentTheme.Accent
        end
    end

    -- API: Notify (window-level)
    function window:Notify(title, text, duration)
        PUPPET:Notify(title, text, duration)
    end

    return window
end

return PUPPET

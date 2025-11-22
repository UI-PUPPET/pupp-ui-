
local PUPPET = {}
PUPPET.__index = PUPPET

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local DEFAULT_SHOW_IMAGE = "sandbox:/mnt/data/1000024637.jpg"

-- Themes
local Themes = {
    Black = {
        Main = Color3.fromRGB(15,15,15), Sidebar = Color3.fromRGB(20,20,20), Element = Color3.fromRGB(35,35,35),
        Hover = Color3.fromRGB(50,50,50), Accent = Color3.fromRGB(120,160,255), Text = Color3.fromRGB(235,235,235),
        ToggleOn = Color3.fromRGB(0,170,140), ToggleOff = Color3.fromRGB(120,30,30)
    },
    Dark = {
        Main = Color3.fromRGB(28,28,30), Sidebar = Color3.fromRGB(36,36,38), Element = Color3.fromRGB(48,48,50),
        Hover = Color3.fromRGB(65,65,68), Accent = Color3.fromRGB(150,190,255), Text = Color3.fromRGB(240,240,240),
        ToggleOn = Color3.fromRGB(80,180,140), ToggleOff = Color3.fromRGB(140,50,50)
    },
    Blossom = {
        Main = Color3.fromRGB(30,18,28), Sidebar = Color3.fromRGB(46,22,38), Element = Color3.fromRGB(60,30,50),
        Hover = Color3.fromRGB(85,40,70), Accent = Color3.fromRGB(255,160,200), Text = Color3.fromRGB(250,245,250),
        ToggleOn = Color3.fromRGB(255,120,170), ToggleOff = Color3.fromRGB(120,50,80)
    }
}
local CurrentTheme = Themes.Black

local function applyColor(inst, prop, color)
    if inst and inst[prop] ~= nil then
        inst[prop] = color
    end
end

local function newScreenGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "PUPPET_UI_"..tostring(math.random(1000,9999))
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui
    return sg
end

-- translate percent-based size to UDim2
local function percentSize(sizeX, sizeY)
    sizeX = tonumber(sizeX) or 70
    sizeY = tonumber(sizeY) or 30
    return UDim2.new(sizeX/100, 0, sizeY/100, 0)
end

function PUPPET:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "PUPPET UI"
    local sizeX = opts.SizeX or 70 -- percent
    local sizeY = opts.SizeY or 40 -- percent
    local corner = opts.CornerRadius or 10
    local showImage = opts.ShowImage or DEFAULT_SHOW_IMAGE

    local sg = newScreenGui()
    local main = Instance.new("Frame") main.Name = "PU_Main" main.Size = percentSize(sizeX, sizeY)
    main.Position = UDim2.new(0.5, -math.floor((main.Size.X.Scale*workspace.CurrentCamera.ViewportSize.X)/2), 0.5, -math.floor((main.Size.Y.Scale*workspace.CurrentCamera.ViewportSize.Y)/2))
    main.BackgroundColor3 = CurrentTheme.Main main.BorderSizePixel = 0 main.Parent = sg
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, corner)

    -- top bar
    local top = Instance.new("Frame") top.Name = "PU_Top" top.Size = UDim2.new(1,0,0,34) top.Position = UDim2.new(0,0,0,0)
    top.BackgroundTransparency = 1 top.Parent = main
    local titleLbl = Instance.new("TextLabel") titleLbl.Name = "PU_Title" titleLbl.Size = UDim2.new(0.7,0,1,0) titleLbl.Position = UDim2.new(0,12,0,0)
    titleLbl.BackgroundTransparency = 1 titleLbl.Font = Enum.Font.GothamBold titleLbl.TextSize = 16 titleLbl.TextColor3 = CurrentTheme.Text
    titleLbl.Text = title titleLbl.TextXAlignment = Enum.TextXAlignment.Left titleLbl.Parent = top

    -- close button
    local closeBtn = Instance.new("TextButton") closeBtn.Name = "PU_Close" closeBtn.Size = UDim2.new(0,36,0,26) closeBtn.Position = UDim2.new(1,-44,0,5)
    closeBtn.Text = "X" closeBtn.Font = Enum.Font.GothamBold closeBtn.TextSize = 16 closeBtn.TextColor3 = Color3.new(1,1,1) closeBtn.BackgroundColor3 = Color3.fromRGB(140,30,30)
    closeBtn.Parent = top Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

    -- sidebar (20%) and content (remaining)
    local sidebar = Instance.new("Frame") sidebar.Name = "PU_Sidebar" sidebar.Size = UDim2.new(0.2, 0, 1, -34) sidebar.Position = UDim2.new(0,0,0,34)
    sidebar.BackgroundColor3 = CurrentTheme.Sidebar sidebar.Parent = main Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,6)
    local sideLayout = Instance.new("UIListLayout") sideLayout.Parent = sidebar sideLayout.Padding = UDim.new(0,6) sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local contentHolder = Instance.new("Frame") contentHolder.Name = "PU_ContentHolder" contentHolder.Size = UDim2.new(0.8,0,1,-34) contentHolder.Position = UDim2.new(0.2,0,0,34)
    contentHolder.BackgroundTransparency = 1 contentHolder.Parent = main

    local pagesFolder = Instance.new("Folder") pagesFolder.Name = "PU_Pages" pagesFolder.Parent = contentHolder

    -- show button (floating)
    local showBtn = Instance.new("ImageButton") showBtn.Name = "PU_Show" showBtn.Size = UDim2.new(0,48,0,48) showBtn.Position = UDim2.new(0.02,0,0.82,0)
    showBtn.Image = showImage showBtn.BackgroundColor3 = CurrentTheme.Accent showBtn.AutoButtonColor = true showBtn.Parent = sg Instance.new("UICorner", showBtn).CornerRadius = UDim.new(0,24)
    showBtn.Visible = false

    -- resizer bottom-right
    local resizer = Instance.new("Frame") resizer.Name = "PU_Resizer" resizer.Size = UDim2.new(0,16,0,16) resizer.Position = UDim2.new(1,-16,1,-16) resizer.BackgroundTransparency = 1 resizer.Parent = main
    Instance.new("UICorner", resizer)

    -- dragging
    do
        local dragging = false local startPos, startFrame
        main.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true startPos = inp.Position startFrame = main.Position
                inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        main.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement and dragging and startPos and startFrame then
                local delta = inp.Position - startPos
                main.Position = UDim2.new(startFrame.X.Scale, startFrame.X.Offset + delta.X, startFrame.Y.Scale, startFrame.Y.Offset + delta.Y)
            end
        end)
    end

    -- resizing
    do
        local resizing = false local startMouse, startSize
        resizer.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true startMouse = inp.Position startSize = main.Size
                inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then resizing = false end end)
            end
        end)
        resizer.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then resizer._drag = i end end)
        UIS.InputChanged:Connect(function(i)
            if resizing and i.UserInputType == Enum.UserInputType.MouseMovement and startMouse and startSize then
                local delta = i.Position - startMouse
                local newX = math.clamp(startSize.X.Offset + delta.X, 300, 1400)
                local newY = math.clamp(startSize.Y.Offset + delta.Y, 180, 1000)
                main.Size = UDim2.new(0,newX,0,newY)
            end
        end)
    end

    -- close/show behaviour
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false showBtn.Visible = true
    end)
    showBtn.MouseButton1Click:Connect(function()
        main.Visible = true showBtn.Visible = false
    end)

    local window = setmetatable({
        _SG = sg, _Main = main, _Sidebar = sidebar, _Pages = pagesFolder, _Content = contentHolder, _Show = showBtn, _Theme = CurrentTheme
    }, PUPPET)

    -- API: AddTab (returns page)
    function window:AddTab(tabName)
        local tabBtn = Instance.new("TextButton") tabBtn.Name = "PU_TabBtn" tabBtn.Text = "  "..tabName tabBtn.Font = Enum.Font.Gotham tabBtn.TextSize = 14
        tabBtn.Size = UDim2.new(1,-12,0,40) tabBtn.BackgroundColor3 = CurrentTheme.Element tabBtn.TextColor3 = CurrentTheme.Text tabBtn.Parent = window._Sidebar
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0,6)

        local page = Instance.new("ScrollingFrame") page.Name = tabName.."_Page" page.Size = UDim2.new(1,-12,1,-12) page.Position = UDim2.new(0,6,0,6)
        page.CanvasSize = UDim2.new(0,0,0,0) page.ScrollBarThickness = 6 page.BackgroundTransparency = 1 page.Parent = window._Content
        local layout = Instance.new("UIListLayout") layout.Parent = page layout.Padding = UDim.new(0,8) layout.HorizontalAlignment = Enum.HorizontalAlignment.Left

        -- auto update canvas size
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
        end)

        tabBtn.MouseButton1Click:Connect(function()
            -- hide other pages
            for _,c in pairs(window._Content:GetChildren()) do if c:IsA("ScrollingFrame") then c.Visible = false end end
            page.Visible = true
            -- visual highlight
            for _,b in pairs(window._Sidebar:GetChildren()) do if b.Name=="PU_TabBtn" then b.BackgroundColor3 = CurrentTheme.Element end end
            tabBtn.BackgroundColor3 = CurrentTheme.Hover
        end)

        if #window._Pages:GetChildren() == 0 then page.Visible = true tabBtn.BackgroundColor3 = CurrentTheme.Hover end

        page.Visible = false
        page.Parent = window._Content
        page.Name = tabName.."_Page"
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0,0,0,0)

        -- register
        local registered = {Btn = tabBtn, Page = page}
        table.insert(window._Pages:GetChildren(), page)
        return page
    end

    -- API: AddButton (rectangular with optional icon image)
    function window:AddButton(page, text, callback, icon)
        callback = callback or function() end
        local btn = Instance.new("TextButton") btn.Name = "PU_Element" btn.Size = UDim2.new(1,-12,0,40) btn.BackgroundColor3 = CurrentTheme.Element
        btn.AutoButtonColor = false btn.Text = "  "..text btn.Font = Enum.Font.GothamBold btn.TextSize = 14 btn.TextColor3 = CurrentTheme.Text btn.Parent = page
        local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,6) corner.Parent = btn
        if icon then
            local img = Instance.new("ImageLabel") img.Size = UDim2.new(0,30,0,30) img.Position = UDim2.new(0,6,0,5) img.Image = icon img.BackgroundTransparency = 1 img.Parent = btn
            btn.TextXAlignment = Enum.TextXAlignment.Left
        end
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = CurrentTheme.Hover end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = CurrentTheme.Element end)
        btn.MouseButton1Click:Connect(function() pcall(callback) end)
        return btn
    end

    -- API: AddToggle (switch)
    function window:AddToggle(page, labelText, default, cb)
        cb = cb or function() end
        local container = Instance.new("Frame") container.Name = "PU_Element" container.Size = UDim2.new(1,-12,0,48) container.BackgroundTransparency = 1 container.Parent = page
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0.7,0,1,0) lbl.BackgroundTransparency = 1 lbl.Text = labelText lbl.Font = Enum.Font.Gotham lbl.TextSize = 14 lbl.TextColor3 = CurrentTheme.Text lbl.Parent = container
        local sw = Instance.new("Frame") sw.Size = UDim2.new(0,56,0,28) sw.Position = UDim2.new(1,-70,0,10) sw.BackgroundColor3 = default and CurrentTheme.ToggleOn or CurrentTheme.ToggleOff sw.Parent = container Instance.new("UICorner", sw).CornerRadius = UDim.new(0,18)
        local knob = Instance.new("Frame") knob.Size = UDim2.new(0,22,0,22) knob.Position = default and UDim2.new(1,-24,0,3) or UDim2.new(0,6,0,3) knob.BackgroundColor3 = Color3.new(1,1,1) knob.Parent = sw Instance.new("UICorner", knob).CornerRadius = UDim.new(0,12)
        local state = default or false
        local btn = Instance.new("TextButton") btn.Size = UDim2.new(1,0,1,0) btn.BackgroundTransparency = 1 btn.Parent = container
        local function refresh()
            sw.BackgroundColor3 = state and CurrentTheme.ToggleOn or CurrentTheme.ToggleOff
            knob:TweenPosition(state and UDim2.new(1,-24,0,3) or UDim2.new(0,6,0,3), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.18, true)
        end
        refresh()
        btn.MouseButton1Click:Connect(function()
            state = not state refresh() pcall(cb, state)
        end)
        return {Get = function() return state end, Set = function(v) state = v refresh() end}
    end

    -- API: AddSlider
    function window:AddSlider(page, labelText, min, max, default, cb)
        cb = cb or function() end min = min or 0 max = max or 100 default = default or min
        local cont = Instance.new("Frame") cont.Name = "PU_Element" cont.Size = UDim2.new(1,-12,0,64) cont.BackgroundTransparency = 1 cont.Parent = page
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1,0,0,18) lbl.BackgroundTransparency = 1 lbl.Text = labelText..": "..tostring(default) lbl.Font = Enum.Font.Gotham lbl.TextSize = 13 lbl.TextColor3 = CurrentTheme.Text lbl.Parent = cont
        local bg = Instance.new("Frame") bg.Size = UDim2.new(1,0,0,18) bg.Position = UDim2.new(0,0,0,36) bg.BackgroundColor3 = CurrentTheme.Element bg.Parent = cont Instance.new("UICorner", bg).CornerRadius = UDim.new(0,10)
        local fill = Instance.new("Frame") fill.Size = UDim2.new((default-min)/(max-min),0,1,0) fill.BackgroundColor3 = CurrentTheme.Accent fill.Parent = bg Instance.new("UICorner", fill).CornerRadius = UDim.new(0,10)
        local dragging = false
        bg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging = true end end)
        bg.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging = false end end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local abs = i.Position.X local left = bg.AbsolutePosition.X local w = bg.AbsoluteSize.X local pct = math.clamp((abs-left)/w,0,1) fill.Size = UDim2.new(pct,0,1,0)
                local val = min + (max-min)*pct val = math.floor(val*100)/100 lbl.Text = labelText..": "..tostring(val) pcall(cb,val)
            end
        end)
        pcall(cb, default)
        return cont
    end

    -- API: AddDropdown
    function window:AddDropdown(page, labelText, items, cb)
        cb = cb or function() end
        local cont = Instance.new("Frame") cont.Name = "PU_Element" cont.Size = UDim2.new(1,-12,0,40) cont.BackgroundTransparency = 1 cont.Parent = page
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0.6,0,1,0) lbl.BackgroundTransparency = 1 lbl.Text = labelText lbl.Font = Enum.Font.Gotham lbl.TextSize = 13 lbl.TextColor3 = CurrentTheme.Text lbl.Parent = cont
        local btn = Instance.new("TextButton") btn.Size = UDim2.new(0.36,0,0.8,0) btn.Position = UDim2.new(0.64,0,0.1,0) btn.Text = "Select" btn.Parent = cont Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
        local list = Instance.new("Frame") list.Size = UDim2.new(1,0,0,0) list.Position = UDim2.new(0,0,1,6) list.ClipsDescendants = true list.BackgroundColor3 = CurrentTheme.Element list.Parent = cont local layout = Instance.new("UIListLayout") layout.Parent = list
        for i,v in ipairs(items or {}) do local opt = Instance.new("TextButton") opt.Size = UDim2.new(1,0,0,28) opt.Text = tostring(v) opt.BackgroundColor3 = CurrentTheme.Element opt.TextColor3 = CurrentTheme.Text opt.Parent = list Instance.new("UICorner", opt).CornerRadius = UDim.new(0,6)
            opt.MouseButton1Click:Connect(function() btn.Text = tostring(v) list.Size = UDim2.new(1,0,0,0) pcall(cb,v) end)
        end
        btn.MouseButton1Click:Connect(function() list.Size = (list.Size.Y.Offset==0) and UDim2.new(1,0,0,#items*28) or UDim2.new(1,0,0,0) end)
        return cont
    end

    -- API: AddMultiDropdown
    function window:AddMultiDropdown(page, labelText, items, cb)
        cb = cb or function() end
        local cont = Instance.new("Frame") cont.Name = "PU_Element" cont.Size = UDim2.new(1,-12,0,40) cont.BackgroundTransparency = 1 cont.Parent = page
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0.6,0,1,0) lbl.BackgroundTransparency = 1 lbl.Text = labelText lbl.Font = Enum.Font.Gotham lbl.TextSize = 13 lbl.TextColor3 = CurrentTheme.Text lbl.Parent = cont
        local btn = Instance.new("TextButton") btn.Size = UDim2.new(0.36,0,0.8,0) btn.Position = UDim2.new(0.64,0,0.1,0) btn.Text = "Select" btn.Parent = cont Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
        local list = Instance.new("Frame") list.Size = UDim2.new(1,0,0,0) list.Position = UDim2.new(0,0,1,6) list.ClipsDescendants = true list.BackgroundColor3 = CurrentTheme.Element list.Parent = cont local layout = Instance.new("UIListLayout") layout.Parent = list
        local selected = {}
        local function updateBtn() btn.Text = (#selected==0) and "Select" or (#selected.." selected") end
        for i,v in ipairs(items or {}) do local opt = Instance.new("TextButton") opt.Size = UDim2.new(1,0,0,28) opt.Text = tostring(v) opt.BackgroundColor3 = CurrentTheme.Element opt.TextColor3 = CurrentTheme.Text opt.Parent = list Instance.new("UICorner", opt).CornerRadius = UDim.new(0,6)
            opt.MouseButton1Click:Connect(function()
                local exists=false for idx,val in ipairs(selected) do if val==v then table.remove(selected, idx); exists=true; break end end
                if not exists then table.insert(selected, v) end updateBtn() pcall(cb, selected)
            end)
        end
        btn.MouseButton1Click:Connect(function() list.Size = (list.Size.Y.Offset==0) and UDim2.new(1,0,0,#items*28) or UDim2.new(1,0,0,0) end)
        return cont
    end

    -- API: SetTheme
    function window:SetTheme(name)
        if Themes[name] then
            CurrentTheme = Themes[name]
            -- apply to this window
            main.BackgroundColor3 = CurrentTheme.Main
            sidebar.BackgroundColor3 = CurrentTheme.Sidebar
            titleLbl.TextColor3 = CurrentTheme.Text
            showBtn.BackgroundColor3 = CurrentTheme.Accent
            -- update child elements colors (simple pass)
            for _,child in pairs(window._Main:GetDescendants()) do
                if child.Name == "PU_Element" and child:IsA("Frame") then
                    -- frames used as element containers
                elseif child.Name == "PU_Element" and child:IsA("TextButton") then
                    child.BackgroundColor3 = CurrentTheme.Element child.TextColor3 = CurrentTheme.Text
                end
            end
        end
    end

    --  Notify
    function window:Notify(titleTxt, body, duration)
        duration = duration or 5
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title = tostring(titleTxt), Text = tostring(body), Duration = duration})
        end)
    end

    return window
end

return PUPPET

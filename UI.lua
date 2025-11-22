
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local PuppetUI = {}

local function newScreenGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "PuppetUI_"..tostring(math.random(1000,9999))
    sg.ResetOnSpawn = false
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    return sg
end

local function makeDraggable(frame, handle)
    local dragging, dragInput, startPos, startMouse
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = frame.Position
            startMouse = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput and startPos and startMouse then
            local delta = input.Position - startMouse
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                         startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function addUICorner(inst, radius)
    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, radius or 12)
    uc.Parent = inst
    return uc
end

local function createFloatingShowButton(screenGui, mainFrame, color, imageUrl)
    local btn = Instance.new("ImageButton")
    btn.Name = "PU_ShowButton"
    btn.Size = UDim2.new(0,48,0,48)
    btn.Position = UDim2.new(0.02,0,0.82,0)
    btn.BackgroundColor3 = color or Color3.fromRGB(230,60,60)
    btn.Image = imageUrl or ""
    btn.AutoButtonColor = true
    btn.Parent = screenGui
    addUICorner(btn, 24)
    local dragging, startPos, startMouse, dragInput
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = btn.Position
            startMouse = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i == dragInput and startPos and startMouse then
            local d = i.Position - startMouse
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                     startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        btn.Visible = false
    end)
    return btn
end

function PuppetUI:CreateWindow(opts)
    assert(type(opts) == "table", "CreateWindow expects a table")
    local Name = opts.Name or "PUPPET UI"
    local Size = opts.Size or UDim2.new(0,600,0,380)
    local Corner = opts.CornerRadius or 12
    local HideColor = opts.HideButtonColor or Color3.fromRGB(220,60,60)
    local ShowImage = opts.ShowButtonImage or ""

    local sg = newScreenGui()

    local main = Instance.new("Frame")
    main.Name = "PU_Main"
    main.Size = Size
    main.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
    main.BackgroundColor3 = Color3.fromRGB(22,22,22)
    main.BorderSizePixel = 0
    main.Parent = sg
    addUICorner(main, Corner)

    local top = Instance.new("Frame")
    top.Name = "Top"
    top.Size = UDim2.new(1,0,0,36)
    top.Position = UDim2.new(0,0,0,0)
    top.BackgroundTransparency = 1
    top.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.75, -8,1,0)
    title.Position = UDim2.new(0,8,0,0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(240,240,240)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "  "..Name
    title.Parent = top

    local hideBtn = Instance.new("TextButton")
    hideBtn.Name = "PU_Hide"
    hideBtn.Size = UDim2.new(0,36,0,28)
    hideBtn.Position = UDim2.new(1,-44,0,4)
    hideBtn.BackgroundColor3 = HideColor
    hideBtn.Text = "X"
    hideBtn.Font = Enum.Font.GothamBold
    hideBtn.TextSize = 18
    hideBtn.TextColor3 = Color3.fromRGB(255,255,255)
    hideBtn.Parent = top
    addUICorner(hideBtn, Corner/2)

    local tabs = Instance.new("ScrollingFrame")
    tabs.Name = "Tabs"
    tabs.Size = UDim2.new(0,140,1,-36)
    tabs.Position = UDim2.new(0,0,0,36)
    tabs.BackgroundTransparency = 1
    tabs.ScrollBarThickness = 6
    tabs.Parent = main

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Parent = tabs
    tabsLayout.Padding = UDim.new(0,8)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local content = Instance.new("Frame")
    content.Name = "ContentHolder"
    content.Size = UDim2.new(1,-140,1,-36)
    content.Position = UDim2.new(0,140,0,36)
    content.BackgroundTransparency = 1
    content.Parent = main

    local pageFolder = Instance.new("Folder")
    pageFolder.Name = "Pages"
    pageFolder.Parent = content

    local resizer = Instance.new("Frame")
    resizer.Name = "Resizer"
    resizer.Size = UDim2.new(0,18,0,18)
    resizer.Position = UDim2.new(1,-18,1,-18)
    resizer.BackgroundTransparency = 1
    resizer.Parent = main
    local rCorner = Instance.new("UICorner") rCorner.Parent = resizer

    makeDraggable(main, top)

    do
        local dragging = false
        local startSize, startMouse, dragInput
        resizer.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                startSize = main.Size
                startMouse = input.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        resizer.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input == dragInput and startSize and startMouse then
                local delta = input.Position - startMouse
                local newX = math.clamp(startSize.X.Offset + delta.X, 250, 1200)
                local newY = math.clamp(startSize.Y.Offset + delta.Y, 180, 900)
                main.Size = UDim2.new(0, newX, 0, newY)
                main.Position = UDim2.new(0.5, -newX/2, 0.5, -newY/2)
            end
        end)
    end

    local showButton = createFloatingShowButton(sg, main, HideColor, ShowImage)
    showButton.Visible = false

    hideBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        showButton.Visible = true
    end)

    local Window = { _Pages = {}, _TabsFrame = tabs, _PagesFolder = pageFolder }

    function Window:CreateTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-12,0,34)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.fromRGB(245,245,245)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Text = name
        btn.AutoButtonColor = true
        btn.Parent = tabs
        addUICorner(btn, Corner/3)

        local page = Instance.new("ScrollingFrame")
        page.Name = name.."_Page"
        page.Size = UDim2.new(1,0,1,0)
        page.Position = UDim2.new(0,0,0,0)
        page.ScrollBarThickness = 6
        page.BackgroundColor3 = Color3.fromRGB(25,25,25)
        page.Parent = pageFolder
        addUICorner(page, math.max(0, Corner-4))

        local layout = Instance.new("UIListLayout") layout.Parent = page layout.Padding = UDim.new(0,8)

        page.Visible = false
        Window._Pages[name] = page

        btn.MouseButton1Click:Connect(function()
            for k,v in pairs(Window._Pages) do v.Visible = false end
            page.Visible = true
        end)

        local TabAPI = {}
        function TabAPI:AddLabel(txt)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-16,0,20)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextColor3 = Color3.fromRGB(230,230,230)
            lbl.Parent = page
            return lbl
        end

        function TabAPI:AddButton(text, cb)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,-16,0,34)
            b.BackgroundColor3 = Color3.fromRGB(60,60,60)
            b.Text = text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 14
            b.TextColor3 = Color3.fromRGB(255,255,255)
            b.Parent = page
            addUICorner(b, Corner/4)
            b.MouseButton1Click:Connect(function() pcall(cb) end)
            return b
        end

        function TabAPI:AddToggle(text, cb)
            local t = Instance.new("TextButton")
            t.Size = UDim2.new(1,-16,0,34)
            t.BackgroundColor3 = Color3.fromRGB(60,60,60)
            t.Font = Enum.Font.GothamBold
            t.TextSize = 14
            t.TextColor3 = Color3.fromRGB(255,255,255)
            t.Parent = page
            addUICorner(t, Corner/4)
            local state = false
            t.Text = text.."  [OFF]"
            t.MouseButton1Click:Connect(function()
                state = not state
                t.Text = text.."  ["..(state and "ON" or "OFF").."]"
                if cb then pcall(cb, state) end
            end)
            return t
        end

        function TabAPI:AddSlider(text, min, max, default, cb)
            min = min or 0; max = max or 100; default = default or min
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1,-16,0,56)
            container.BackgroundTransparency = 1
            container.Parent = page

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1,0,0,18)
            label.Position = UDim2.new(0,0,0,0)
            label.BackgroundTransparency = 1
            label.Text = text..": "..tostring(default)
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.TextColor3 = Color3.fromRGB(230,230,230)
            label.Parent = container

            local barBg = Instance.new("Frame")
            barBg.Size = UDim2.new(1,0,0,18)
            barBg.Position = UDim2.new(0,0,0,30)
            barBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
            barBg.Parent = container
            addUICorner(barBg, Corner/6)

            local barFill = Instance.new("Frame")
            barFill.Size = UDim2.new((default-min)/(max-min),0,1,0)
            barFill.Parent = barBg
            addUICorner(barFill, Corner/6)

            local dragging = false
            barBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
            barBg.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                    local abs = i.Position.X
                    local left = barBg.AbsolutePosition.X
                    local w = barBg.AbsoluteSize.X
                    local pct = math.clamp((abs-left)/w, 0, 1)
                    barFill.Size = UDim2.new(pct,0,1,0)
                    local val = min + (max-min)*pct
                    val = math.floor(val*100)/100
                    label.Text = text..": "..tostring(val)
                    if cb then pcall(cb, val) end
                end
            end)
            if cb then pcall(cb, default) end
            return container
        end

        function TabAPI:AddDropdown(text, items, cb)
            local cont = Instance.new("Frame")
            cont.Size = UDim2.new(1,-16,0,36)
            cont.BackgroundTransparency = 1
            cont.Parent = page

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6,0,1,0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.TextColor3 = Color3.fromRGB(230,230,230)
            label.Parent = cont

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.36,0,0.85,0)
            btn.Position = UDim2.new(0.64,0,0.075,0)
            btn.Text = "Select"
            btn.Font = Enum.Font.GothamBold
            btn.Parent = cont
            addUICorner(btn, Corner/6)

            local list = Instance.new("Frame")
            list.Size = UDim2.new(1,0,0,0)
            list.Position = UDim2.new(0,0,1,6)
            list.ClipsDescendants = true
            list.BackgroundColor3 = Color3.fromRGB(28,28,28)
            list.Parent = cont
            local layout = Instance.new("UIListLayout") layout.Parent = list

            for i,v in ipairs(items or {}) do
                local opt = Instance.new("TextButton")
                opt.Size = UDim2.new(1,0,0,28)
                opt.Text = tostring(v)
                opt.Font = Enum.Font.Gotham
                opt.Parent = list
                opt.MouseButton1Click:Connect(function()
                    btn.Text = tostring(v)
                    list.Size = UDim2.new(1,0,0,0)
                    if cb then pcall(cb, v) end
                end)
            end

            btn.MouseButton1Click:Connect(function()
                list.Size = (list.Size.Y.Offset==0) and UDim2.new(1,0,0, #items*28) or UDim2.new(1,0,0,0)
            end)

            return cont
        end

        function TabAPI:AddMultiDropdown(text, items, cb)
            local cont = Instance.new("Frame")
            cont.Size = UDim2.new(1,-16,0,36)
            cont.BackgroundTransparency = 1
            cont.Parent = page

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6,0,1,0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.TextColor3 = Color3.fromRGB(230,230,230)
            label.Parent = cont

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.36,0,0.85,0)
            btn.Position = UDim2.new(0.64,0,0.075,0)
            btn.Text = "Select"
            btn.Font = Enum.Font.GothamBold
            btn.Parent = cont
            addUICorner(btn, Corner/6)

            local list = Instance.new("Frame")
            list.Size = UDim2.new(1,0,0,0)
            list.Position = UDim2.new(0,0,1,6)
            list.ClipsDescendants = true
            list.BackgroundColor3 = Color3.fromRGB(28,28,28)
            list.Parent = cont
            local layout = Instance.new("UIListLayout") layout.Parent = list

            local selected = {}
            local function updateBtn()
                btn.Text = (#selected==0) and "Select" or (#selected.." selected")
            end

            for i,v in ipairs(items or {}) do
                local opt = Instance.new("TextButton")
                opt.Size = UDim2.new(1,0,0,28)
                opt.Text = tostring(v)
                opt.Font = Enum.Font.Gotham
                opt.Parent = list
                opt.MouseButton1Click:Connect(function()
                    local exists=false
                    for idx,val in ipairs(selected) do if val==v then table.remove(selected, idx); exists=true; break end end
                    if not exists then table.insert(selected, v) end
                    updateBtn()
                    if cb then pcall(cb, selected) end
                end)
            end

            btn.MouseButton1Click:Connect(function()
                list.Size = (list.Size.Y.Offset==0) and UDim2.new(1,0,0,#items*28) or UDim2.new(1,0,0,0)
            end)

            return cont
        end

        return TabAPI
    end

    return Window
end

return PuppetUI

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humRoot = char:WaitForChild("HumanoidRootPart")
local gui = Instance.new("ScreenGui", player.PlayerGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Active = true
frame.Draggable = true -- ทำให้ลากได้

local textbox = Instance.new("TextBox", frame)
textbox.Size = UDim2.new(0, 200, 0, 50)
textbox.Position = UDim2.new(0, 50, 0, 10)
textbox.PlaceholderText = "Enter Dummy Name"
textbox.TextScaled = true
textbox.BackgroundColor3 = Color3.fromRGB(200, 200, 200)

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0, 100, 0, 50)
button.Position = UDim2.new(0, 100, 0, 60)
button.Text = "Start"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

local running = false

local function teleportToDummy(dummyName)
    while running do
        local found = false
        for _, dummy in ipairs(workspace.NPCS:GetChildren()) do
            if dummy:IsA("Model") and dummy.Name:match("^" .. dummyName) then
                local humanoid = dummy:FindFirstChild("Humanoid")
                local rootPart = dummy:FindFirstChild("HumanoidRootPart")
                if humanoid and rootPart and humanoid.Health > 0 then
                    local direction = rootPart.CFrame.LookVector -- หาทิศทางที่ Dummy หันหน้าไป
                    local teleportPosition = rootPart.Position - (direction * 2) -- อยู่ห่าง 2 หน่วย
                    humRoot.CFrame = CFrame.new(teleportPosition, rootPart.Position) -- หันหน้าเข้าหา Dummy
                    found = true
                    break
                end
            end
        end
        if not found then break end -- หยุดหากไม่มี dummy ตัวไหนเหลือชีวิต
        task.wait(0.5) -- รอเวลาเล็กน้อยก่อนหาใหม่
    end
end

button.MouseButton1Click:Connect(function()
    if running then
        running = false
        button.Text = "Start"
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        running = true
        button.Text = "Stop"
        button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        teleportToDummy(textbox.Text)
    end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- สร้าง Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0.5, -110, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Active = true
frame.Draggable = true -- ทำให้ลากได้
frame.Parent = screenGui

-- สร้าง TextBox
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 200, 0, 50)
textBox.Position = UDim2.new(0, 10, 0, 10)
textBox.PlaceholderText = "Enter quest name"
textBox.Parent = frame

-- สร้างปุ่ม Auto Quest
local textButton = Instance.new("TextButton")
textButton.Size = UDim2.new(0, 200, 0, 50)
textButton.Position = UDim2.new(0, 10, 0, 70)
textButton.Text = "Auto Quest"
textButton.Parent = frame

-- สร้างปุ่ม Auto Click
local autoClickButton = Instance.new("TextButton")
autoClickButton.Size = UDim2.new(0, 200, 0, 50)
autoClickButton.Position = UDim2.new(0, 10, 0, 130)
autoClickButton.Text = "Auto Click"
autoClickButton.Parent = frame

local running = false -- ตัวแปรสถานะการทำงาน
local autoClickRunning = false -- ตัวแปรสถานะ Auto Click
local clickIndicator = nil -- ตัวแสดงผลตำแหน่งคลิก

textButton.MouseButton1Click:Connect(function()
    if running then
        running = false
        textButton.Text = "Auto Quest"
    else
        running = true
        textButton.Text = "Stop Auto Quest"
        
        while running do
            local args = {
                [1] = textBox.Text ~= "" and textBox.Text or "Thug" -- ใช้ค่าที่กรอก หรือ "Thug" เป็นค่าเริ่มต้น
            }
            
            ReplicatedStorage:WaitForChild("RS"):WaitForChild("Quest"):FireServer(unpack(args))
            wait(1) -- รอ 1 วินาทีก่อนทำซ้ำ
        end
    end
end)

-- ฟังก์ชัน Auto Click
local function autoClick()
    while autoClickRunning do
        if clickIndicator then
            local inputService = game:GetService("UserInputService")
            inputService.InputBegan:Fire({Position = clickIndicator.Position}) -- จำลองการคลิกที่จุด O
        end
        wait(0.5) -- ปรับเวลาคลิกอัตโนมัติ
    end
end

-- เมื่อกดปุ่ม Auto Click
autoClickButton.MouseButton1Click:Connect(function()
    if autoClickRunning then
        autoClickRunning = false
        autoClickButton.Text = "Auto Click"
        if clickIndicator then
            clickIndicator:Destroy()
            clickIndicator = nil
        end
    else
        autoClickRunning = true
        autoClickButton.Text = "Stop Auto Click"
        
        -- สร้างจุด O กลางหน้าจอ
        clickIndicator = Instance.new("TextLabel")
        clickIndicator.Size = UDim2.new(0, 50, 0, 50)
        clickIndicator.Position = UDim2.new(0.5, -25, 0.5, -25)
        clickIndicator.BackgroundTransparency = 1
        clickIndicator.Text = "O"
        clickIndicator.TextSize = 50
        clickIndicator.TextColor3 = Color3.fromRGB(255, 0, 0)
        clickIndicator.Parent = screenGui
        
        -- เริ่มคลิกอัตโนมัติ
        spawn(autoClick)
    end
end)

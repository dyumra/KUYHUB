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


--// OBSIDIAN - AUTO 1-700 REBIRTH
--// ONE TOGGLE
--// PLACE 3177438863 -> Bandit/Rebirth/Upgrade/Brawly -> Crimson
--// PLACE 7040546583 -> Calci Army + LockOn/Skill101 + Rebirth
--// If the game changes PlaceId, the same toggle continues automatically.

local Repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local Obsidian = loadstring(game:HttpGet(
    Repo .. "Library.lua"
))()

-- UI Settings / Theme / Config
local ThemeManager = loadstring(game:HttpGet(
    Repo .. "addons/ThemeManager.lua"
))()
local SaveManager = loadstring(game:HttpGet(
    Repo .. "addons/SaveManager.lua"
))()

local Window = Obsidian:CreateWindow({
    Title = "Auto 1-700 Rebirth",
    Footer = "Combined Farm",
    Center = true,
    AutoShow = true
})

local Tab = Window:AddTab("Farm", "home")
local Box = Tab:AddLeftGroupbox("Auto Farm")

_G.Auto1_700 = false
local MainThread = nil
local ResetThread = nil

local RESET_INTERVAL = 20 * 60 -- 20 phút

-- Anti-void: nhớ vị trí hợp lệ gần nhất để cứu nhân vật nếu tween
-- bị physics/target lỗi kéo xuống dưới map.
local SafeCFrame = nil
local AntiVoidThread = nil
local AntiFallConnection = nil
local VOID_Y = -100
local FLOAT_Y_OFFSET = 8

local function GetSafeRoot()
    local character = game.Players.LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function StartAntiVoid()
    if AntiVoidThread then return end

    AntiVoidThread = task.spawn(function()
        while _G.Auto1_700 do
            local root = GetSafeRoot()

            if root then
                local pos = root.Position
                local velocity = root.AssemblyLinearVelocity

                -- Chỉ lưu vị trí khi nhân vật còn ở vùng map hợp lệ.
                if pos.Y > VOID_Y
                    and pos.Y < 100000
                    and velocity.Magnitude < 1000 then
                    SafeCFrame = root.CFrame
                end

                -- Đã rơi xuống void -> dừng vận tốc và đưa về vị trí an toàn.
                if pos.Y <= VOID_Y then
                    local recovery = SafeCFrame

                    if not recovery then
                        if game.PlaceId == 7040546583 then
                            recovery = CFrame.new(Vector3.new(
                                -1028.61804, 66.1857834, -1514.43213
                            ))
                        else
                            recovery = CFrame.new(Vector3.new(
                                2034.02405, 1154.9751, -122.715225
                            ))
                        end
                    end

                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    root.CFrame = recovery + Vector3.new(0, 4, 0)

                    task.wait(0.2)
                end
            end

            task.wait(0.05)
        end

        AntiVoidThread = nil
    end)
end

local function StartAntiFallHold()
    if AntiFallConnection then return end
    AntiFallConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not _G.Auto1_700 then return end
        local root = GetSafeRoot()
        if not root then return end
        -- Sau khi mob chết/biến mất, giữ nhân vật ở vị trí an toàn
        -- thay vì để physics kéo rơi xuống đất/void.
        if root.Position.Y < 0 and SafeCFrame then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = SafeCFrame + Vector3.new(0, FLOAT_Y_OFFSET, 0)
        end
    end)
end

local function StopAntiFallHold()
    if AntiFallConnection then
        AntiFallConnection:Disconnect()
        AntiFallConnection = nil
    end
end

local function StopAntiVoid()
    if AntiVoidThread then
        task.cancel(AntiVoidThread)
        AntiVoidThread = nil
    end
    SafeCFrame = nil
end

-- Chờ nhân vật sống lại sau khi chết/reset.
local function WaitForCharacter()
    if not _G.Auto1_700 then return nil end

    local character = game.Players.LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid and humanoid.Health > 0 then
        return character, humanoid
    end

    character = game.Players.LocalPlayer.CharacterAdded:Wait()
    if not _G.Auto1_700 then return nil end

    humanoid = character:WaitForChild("Humanoid", 10)
    return character, humanoid
end

local function StartResetWatcher()
    if ResetThread then return end

    ResetThread = task.spawn(function()
        while _G.Auto1_700 do
            local remaining = RESET_INTERVAL

            while _G.Auto1_700 and remaining > 0 do
                local step = math.min(1, remaining)
                task.wait(step)
                remaining -= step
            end

            if not _G.Auto1_700 then break end

            local character = game.Players.LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 then
                print("🔄 Auto 1-700: Reset sau 20 phút")
                humanoid.Health = 0
            end

            -- Cho Roblox respawn xong rồi mới đếm 20 phút tiếp theo.
            if _G.Auto1_700 then
                task.wait(3)
            end
        end

        ResetThread = nil
    end)
end

local function StopResetWatcher()
    _G.Auto1_700 = false
    ResetThread = nil
end

--==================================================
-- COMMON
--==================================================

local function waitUntilEnabled(seconds)
    local finish = os.clock() + seconds
    while _G.Auto1_700 and os.clock() < finish do
        task.wait()
    end
    return _G.Auto1_700
end

--==================================================
-- PLACE 3177438863
--==================================================

local function RunPlace3177438863()
    if not _G.Auto1_700 then return end
    WaitForCharacter()
    if not _G.Auto1_700 then return end

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local LP = Players.LocalPlayer

    local SKILL_DELAY = 0.25
    local TWEEN_SPEED = 180
    local MIN_STRENGTH = 200000
    local MIN_REBIRTH = 2
    local HIGH_STRENGTH = 60000000
    local TARGET_REBIRTH = 50

    local WAIT_POS = Vector3.new(
        2034.02405,
        1149.9751,
        -122.715225
    )

    local SkillRemote = ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("SkillRemote")

    local RebirthRemote = ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.4.7")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild("PlayerLevelService")
        :WaitForChild("RF")
        :WaitForChild("RequestRebirth")

    local PromptRemote = ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.4.7")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild("PromptService")
        :WaitForChild("RE")
        :WaitForChild("Prompt")

    local Stats = LP:WaitForChild("Stats")
    local Strength = Stats:WaitForChild("Strength")
    local Rebirth = Stats:WaitForChild("Rebirth")

    local function getRoot()
        local char = LP.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getRootPart(mob)
        return mob and (
            mob:FindFirstChild("HumanoidRootPart")
            or mob.PrimaryPart
            or mob:FindFirstChildWhichIsA("BasePart")
        )
    end

    local function getHumanoid(mob)
        return mob and mob:FindFirstChildOfClass("Humanoid")
    end

    local function findMob(name)
        local folder = workspace
            :WaitForChild("World Mobs")
            :WaitForChild("Mobs")

        for _, mob in ipairs(folder:GetChildren()) do
            if not _G.Auto1_700 then return nil end

            if mob.Name == name then
                local hum = getHumanoid(mob)
                if hum and hum.Health > 0 then
                    return mob
                end
            end
        end
        return nil
    end

    local function tweenTo(cf)
        if not _G.Auto1_700 then return false end

        local root = getRoot()
        if not root then return false end

        local distance = (root.Position - cf.Position).Magnitude
        local duration = math.max(distance / TWEEN_SPEED, 0.05)

        local tween = TweenService:Create(
            root,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = cf}
        )

        tween:Play()

        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not _G.Auto1_700 then
                tween:Cancel()
                return false
            end
            task.wait()
        end

        return true
    end

    local function tweenAboveMob(mob)
        local mobRoot = getRootPart(mob)
        if not mobRoot then return false end

        -- Không tween theo mob nếu target đã nằm ngoài vùng map.
        if mobRoot.Position.Y <= VOID_Y or mobRoot.Position.Y > 100000 then
            return false
        end

        local pos = mobRoot.Position + Vector3.new(0, 8, 0)
        return tweenTo(CFrame.lookAt(pos, mobRoot.Position))
    end

    local function attackMob(mob)
        if not _G.Auto1_700 then return end

        local root = getRoot()
        local mobRoot = getRootPart(mob)
        if not root or not mobRoot then return end

        local target = mobRoot.Position
        local above = target + Vector3.new(0, 8, 0)
        local cf = CFrame.lookAt(above, target)

        root.CFrame = cf

        SkillRemote:FireServer({
            ["Camera"] = cf,
            ["SkillId"] = "1",
            ["Began"] = true,
            ["CFrame"] = cf,
            ["Typ\208\181"] = 1,
            ["Aim"] = target
        })
    end

    local function farmMob(name)
        local currentMob = nil

        while _G.Auto1_700 and game.PlaceId == 3177438863 do
            local mob = findMob(name)

            if not mob then
                return false
            end

            if currentMob ~= mob then
                currentMob = mob

                if not tweenAboveMob(mob) then
                    return false
                end
            end

            local hum = getHumanoid(mob)

            if not hum or hum.Health <= 0 then
                currentMob = nil
            else
                attackMob(mob)
                task.wait(SKILL_DELAY)
            end
        end

        return false
    end

    local function doRebirthUntil(target)
        local lastValue = Rebirth.Value
        local noChange = 0

        while _G.Auto1_700
            and game.PlaceId == 3177438863
            and Rebirth.Value < target do

            pcall(function()
                RebirthRemote:InvokeServer(true)
            end)

            task.wait(0.2)

            if Rebirth.Value == lastValue then
                noChange += 1
            else
                lastValue = Rebirth.Value
                noChange = 0
            end

            if noChange >= 10 then
                return false
            end
        end

        return Rebirth.Value >= target
    end

    local function upgrade(path)
        if not _G.Auto1_700 then return end

        PromptRemote:FireServer({
            ["Timer"] = 15,
            ["Description"] =
                "Upgrade Energy Blast>" .. path ..
                " for 1 Skill Points?",
            ["LeftButton"] = "Upgrade",
            ["PathName"] = path,
            ["Prompt"] = "UpgradeSkill",
            ["RightButton"] = "Return",
            ["SkillId"] = "101"
        }, "Upgrade")
    end

    local function upgradeOneMinute()
        local finish = os.clock() + 60

        while _G.Auto1_700
            and game.PlaceId == 3177438863
            and os.clock() < finish do

            upgrade("Path1")
            task.wait(0.5)

            upgrade("Path2")
            task.wait(0.5)
        end
    end

    local function crimson()
        if not _G.Auto1_700 then return end

        PromptRemote:FireServer({
            ["UniqueTag"] = "TeleporterGui",
            ["Description"] = "Join World [Crimson Planet]?",
            ["LeftButton"] = "Join",
            ["Timer"] = 30,
            ["Prompt"] = "TeleportDirect",
            ["RightButton"] = "Cancel",
            ["PlaceDataId"] = 2
        }, "Join")
    end

    while _G.Auto1_700 and game.PlaceId == 3177438863 do
        local str = tonumber(Strength.Value) or 0
        local reb = tonumber(Rebirth.Value) or 0

        if reb > 50 then
            crimson()
            task.wait(1)

            -- Keep the toggle ON. If the teleport changes PlaceId,
            -- the outer controller will start the Calci system.
            break

        elseif str > HIGH_STRENGTH then
            local success = doRebirthUntil(TARGET_REBIRTH)

            if success or Rebirth.Value >= TARGET_REBIRTH then
                crimson()
                task.wait(1)
                break
            end

        elseif str >= MIN_STRENGTH and reb >= MIN_REBIRTH then
            local brawly = findMob("Brawly Minion")

            if brawly then
                farmMob("Brawly Minion")
            else
                tweenTo(CFrame.new(WAIT_POS))

                while _G.Auto1_700
                    and game.PlaceId == 3177438863 do

                    brawly = findMob("Brawly Minion")
                    if brawly then break end
                    task.wait(0.25)
                end
            end

        elseif str >= MIN_STRENGTH then
            local before = Rebirth.Value
            doRebirthUntil(999999)

            if _G.Auto1_700 and Rebirth.Value == before then
                upgradeOneMinute()
            end

        else
            farmMob("Bandit")
        end

        task.wait(0.1)
    end
end

--==================================================
-- PLACE 7040546583 - CALCI ARMY
--==================================================

local function RunPlace7040546583()
    if not _G.Auto1_700 then return end
    WaitForCharacter()
    if not _G.Auto1_700 then return end

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local LP = Players.LocalPlayer

    local SKILL1_DELAY = 0.25
    local LOCK_DELAY = 0.25
    local REBIRTH_DELAY = 0.25
    local TWEEN_SPEED = 180
    local LOCK_RADIUS = 200

    local WAIT_POS = Vector3.new(
        -1028.61804,
        61.1857834,
        -1514.43213
    )

    local SkillRemote = ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("SkillRemote")

    local LockOnRemote = ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.4.7")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild("SkillManager")
        :WaitForChild("RE")
        :WaitForChild("LockedOnChanged")

    local RebirthRemote = ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.4.7")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild("PlayerLevelService")
        :WaitForChild("RF")
        :WaitForChild("RequestRebirth")

    local function getRoot()
        local char = LP.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getMobRoot(mob)
        return mob and (
            mob:FindFirstChild("HumanoidRootPart")
            or mob.PrimaryPart
            or mob:FindFirstChildWhichIsA("BasePart")
        )
    end

    local function getHumanoid(mob)
        return mob and mob:FindFirstChildOfClass("Humanoid")
    end

    local function getCalciList()
        local folder = workspace
            :WaitForChild("World Mobs")
            :WaitForChild("Mobs")

        local result = {}

        for _, mob in ipairs(folder:GetChildren()) do
            if mob.Name == "Calci Army" then
                local hum = getHumanoid(mob)
                local root = getMobRoot(mob)

                if hum and hum.Health > 0 and root then
                    table.insert(result, mob)
                end
            end
        end

        return result
    end

    local currentTweenTarget = nil

    local function getRandomLockTarget(exclude)
        local root = getRoot()
        if not root then return nil end

        local list = {}

        for _, mob in ipairs(getCalciList()) do
            if mob ~= exclude then
                local mobRoot = getMobRoot(mob)

                if mobRoot then
                    local distance =
                        (root.Position - mobRoot.Position).Magnitude

                    if distance <= LOCK_RADIUS then
                        table.insert(list, mob)
                    end
                end
            end
        end

        if #list == 0 then return nil end
        return list[math.random(1, #list)]
    end

    local function tweenAbove(mob)
        if not _G.Auto1_700 then return false end

        local root = getRoot()
        local mobRoot = getMobRoot(mob)
        if not root or not mobRoot then return false end

        -- Tránh đuổi theo target đã bị rơi/teleport xuống void.
        if mobRoot.Position.Y <= VOID_Y or mobRoot.Position.Y > 100000 then
            return false
        end

        local position =
            mobRoot.Position + Vector3.new(0, 8, 0)

        local cf =
            CFrame.lookAt(position, mobRoot.Position)

        local distance =
            (root.Position - position).Magnitude

        local duration =
            math.max(distance / TWEEN_SPEED, 0.05)

        local tween = TweenService:Create(
            root,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = cf}
        )

        tween:Play()

        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not _G.Auto1_700
                or game.PlaceId ~= 7040546583 then

                tween:Cancel()
                return false
            end
            task.wait()
        end

        return true
    end

    local function tweenWait()
        if not _G.Auto1_700 then return end

        local root = getRoot()
        if not root then return end

        local distance =
            (root.Position - WAIT_POS).Magnitude

        local duration =
            math.max(distance / TWEEN_SPEED, 0.05)

        local tween = TweenService:Create(
            root,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(WAIT_POS)}
        )

        tween:Play()

        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not _G.Auto1_700
                or game.PlaceId ~= 7040546583 then

                tween:Cancel()
                return
            end
            task.wait()
        end
    end

    local function skill1(mob)
        if not _G.Auto1_700 then return end

        local root = getRoot()
        local mobRoot = getMobRoot(mob)
        if not root or not mobRoot then return end

        local target = mobRoot.Position
        local above = target + Vector3.new(0, 8, 0)
        local cf = CFrame.lookAt(above, target)

        root.CFrame = cf

        SkillRemote:FireServer({
            ["Camera"] = cf,
            ["SkillId"] = "1",
            ["Began"] = true,
            ["CFrame"] = cf,
            ["Typ\208\181"] = 1,
            ["Aim"] = target
        })
    end

    local function lockSkill101(mob)
        if not _G.Auto1_700 then return end

        local mobRoot = getMobRoot(mob)
        local root = getRoot()

        if not mobRoot or not root then return end

        local target = mobRoot.Position
        local above = target + Vector3.new(0, 8, 0)
        local cf = CFrame.lookAt(above, target)

        LockOnRemote:FireServer(mob)

        SkillRemote:FireServer({
            ["Camera"] = cf,
            ["SkillId"] = "101",
            ["Began"] = true,
            ["CFrame"] = cf,
            ["Typ\208\181"] = 1,
            ["Aim"] = target
        })
    end

    -- One controller thread runs all three Calci systems.
    local calciRunning = true

    task.spawn(function()
        while _G.Auto1_700
            and calciRunning
            and game.PlaceId == 7040546583 do

            local list = getCalciList()

            if #list == 0 then
                currentTweenTarget = nil
                tweenWait()
                task.wait(0.1)
            else
                if not currentTweenTarget
                    or not getHumanoid(currentTweenTarget)
                    or getHumanoid(currentTweenTarget).Health <= 0
                    or not getMobRoot(currentTweenTarget) then

                    currentTweenTarget =
                        list[math.random(1, #list)]

                    if not tweenAbove(currentTweenTarget) then
                        break
                    end
                end

                if currentTweenTarget then
                    local hum = getHumanoid(currentTweenTarget)

                    if hum and hum.Health > 0 then
                        skill1(currentTweenTarget)
                    else
                        currentTweenTarget = nil
                    end
                end

                task.wait(SKILL1_DELAY)
            end
        end
    end)

    task.spawn(function()
        while _G.Auto1_700
            and calciRunning
            and game.PlaceId == 7040546583 do

            local target =
                getRandomLockTarget(currentTweenTarget)

            if target then
                pcall(function()
                    lockSkill101(target)
                end)
            end

            task.wait(LOCK_DELAY)
        end
    end)

    task.spawn(function()
        while _G.Auto1_700
            and calciRunning
            and game.PlaceId == 7040546583 do

            pcall(function()
                RebirthRemote:InvokeServer(true)
            end)

            task.wait(REBIRTH_DELAY)
        end
    end)

    -- Wait while Calci is the active PlaceId.
    while _G.Auto1_700
        and game.PlaceId == 7040546583 do
        task.wait(0.25)
    end

    calciRunning = false
end

--==================================================
-- ONE MAIN CONTROLLER
--==================================================

local function StartAuto1700()
    if MainThread then return end

    _G.Auto1_700 = true
    StartAntiVoid()
    StartAntiFallHold()

    MainThread = task.spawn(function()
        while _G.Auto1_700 do

            -- Nếu vừa chết/reset thì đợi character mới rồi farm tiếp.
            if not WaitForCharacter() then
                break
            end

            local place = game.PlaceId

            if place == 3177438863 then
                RunPlace3177438863()

            elseif place == 7040546583 then
                RunPlace7040546583()

            else
                warn("❌ Auto 1-700: PlaceId không được hỗ trợ:", place)
                task.wait(1)
            end

            task.wait(0.25)
        end

        MainThread = nil
    end)
end

local function StopAuto1700()
    _G.Auto1_700 = false
    StopAntiVoid()

    if ResetThread then
        task.cancel(ResetThread)
        ResetThread = nil
    end
    print("🛑 Auto 1-700 Rebirth OFF")
end

--==================================================
-- ONE TOGGLE ONLY
--==================================================

Box:AddToggle("Auto1700", {
    Text = "Auto 1-700 Rebirth",
    Default = false,

    Callback = function(Value)
        if Value then
            StartAuto1700()
            StartResetWatcher()
            print("✅ Auto 1-700 Rebirth ON | Reset mỗi 20 phút")
        else
            StopAuto1700()
        end
    end
})

Obsidian:Notify({
    Title = "Auto 1-700 Rebirth",
    Description = "Đã load - chỉ có 1 nút ON/OFF",
    Time = 3
})
--// ANTI FALL - OBSIDIAN
--// Toggle ON/OFF | Default ON

--==================================================
-- ANTI FALL
--==================================================

local RunService = game:GetService("RunService")
local AntiFall = true
local AntiFallConnection = nil

local function StartAntiFall()
    if AntiFallConnection then return end

    AntiFallConnection = RunService.Heartbeat:Connect(function()
        if not AntiFall then return end

        local Character = game.Players.LocalPlayer.Character
        if not Character then return end

        local Root = Character:FindFirstChild("HumanoidRootPart")
        if not Root then return end

        local Velocity = Root.AssemblyLinearVelocity

        if Velocity.Y < 0 then
            Root.AssemblyLinearVelocity = Vector3.new(
                Velocity.X,
                0,
                Velocity.Z
            )
        end
    end)
end

local function StopAntiFall()
    if AntiFallConnection then
        AntiFallConnection:Disconnect()
        AntiFallConnection = nil
    end
end

--==================================================
-- ANTI FALL TOGGLE
--==================================================

Box:AddToggle("AntiFall", {
    Text = "Anti Fall",
    Default = false,

    Callback = function(Value)
        AntiFall = Value

        if Value then
            StartAntiFall()
        else
            StopAntiFall()
        end
    end
})

-- Bật sẵn
StartAntiFall()
--==================================================
-- AUTO TOOLBAR SELECTION
--==================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolRemote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.4.7")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("ToolService")
    :WaitForChild("RE")
    :WaitForChild("UpdatePlayerToolbarSelection")

local SelectedNumber = 1
local AutoToolbar = false
local ToolbarThread = nil

local function StartToolbar()
    if ToolbarThread then return end

    ToolbarThread = task.spawn(function()
        while AutoToolbar do
            ToolRemote:FireServer(SelectedNumber)
            task.wait(0.1)
        end

        ToolbarThread = nil
    end)
end

local function StopToolbar()
    AutoToolbar = false
    ToolbarThread = nil
end

Box:AddDropdown("ToolbarNumber", {
    Values = {"1", "2", "3", "4", "5", "6"},
    Default = "1",
    Multi = false,
    Text = "Select equip",

    Callback = function(Value)
        SelectedNumber = tonumber(Value)

        -- Chọn số là tự động kích hoạt
        AutoToolbar = true
        StartToolbar()
    end
})
local BasicBox = Tab:AddRightGroupbox("Basic")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local SkillRemote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("SkillRemote")

local BasicEnabled = false
local BasicThread = nil

--==================================================
-- BASIC SKILL ARGS
--==================================================

local args = {
    [1] = {
        ["Camera"] = CFrame.new(
            1397.9259033203125,
            600.5099487304688,
            -2905.99951171875,
            -1.1920927533992653e-07,
            0.258819043636322,
            -0.965925931930542,
            0,
            0.965925931930542,
            0.258819043636322,
            1,
            3.085363076138492e-08,
            -1.1514732989326149e-07
        ),

        ["SkillId"] = "10",
        ["Began"] = true,

        ["CFrame"] = CFrame.new(
            1410,
            595.57470703125,
            -2905.99951171875,
            -1.1920927533992653e-07,
            0,
            -1,
            0,
            1,
            0,
            1,
            0,
            -1.1920927533992653e-07
        ),

        ["Typ\208\181"] = 1,

        ["Aim"] = Vector3.new(
            1460,
            595.57470703125,
            -2905.99951171875
        )
    }
}

--==================================================
-- CHECK MODE
--==================================================

local function HasMode()
    local Characters = workspace:FindFirstChild("Characters")
    local Character = Characters
        and Characters:FindFirstChild(LocalPlayer.Name)

    if not Character then
        return false
    end

    return Character:FindFirstChild("Mode") ~= nil
end

--==================================================
-- START BASIC
--==================================================

local function StartBasic()

    if BasicThread then
        return
    end

    BasicThread = task.spawn(function()

        while BasicEnabled do

            if not HasMode() then
                SkillRemote:FireServer(unpack(args))
            end

            task.wait(1.6)
        end

        BasicThread = nil
    end)
end

--==================================================
-- STOP BASIC
--==================================================

local function StopBasic()

    BasicEnabled = false

end

--==================================================
-- BASIC TOGGLE
--==================================================

BasicBox:AddToggle("Basic", {
    Text = "auto transform",
    Default = true,

    Callback = function(Value)

        BasicEnabled = Value

        if Value then
            StartBasic()
        else
            StopBasic()
        end

    end
})
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SkillRemote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("SkillRemote")

local Running = false

--// Skill 9
local function UseSkill9()
    local args = {
        [1] = {
            ["Camera"] = CFrame.new(
                1362.0875244140625,
                601.2300415039062,
                -2982.91015625,
                0.8348132967948914,
                -0.18300960958004,
                0.5192247629165649,
                0,
                0.9431307319160461,
                0.332422465085984,
                -0.55053323507309,
                -0.277510702610016,
                0.7873380184173584
            ),

            ["SkillId"] = "9",
            ["Toggle"] = true,
            ["Began"] = true,

            ["CFrame"] = CFrame.new(
                1355.59716796875,
                595.374755859375,
                -2992.751953125,
                -0.192925050854683,
                -1.74180647682931e-09,
                -0.981213510036469,
                -2.9545856872204e-09,
                1,
                -1.19422827182802e-09,
                0.981213510036468,
                2.66868283027577e-09,
                -0.192925050854683
            ),

            ["Typ\208\181"] = 1,

            ["Aim"] = Vector3.new(
                1404.6578369140625,
                595.374755859375,
                -2983.105712890625
            )
        }
    }

    SkillRemote:FireServer(unpack(args))
end

--// ON / OFF
BasicBox:AddToggle("Basic", {
    Text = "Auto fusion",
    Default = false,

    Callback = function(Value)
        Running = Value

        if Value then
            task.spawn(function()
                while Running do
                    UseSkill9()

                    --// 9 giây / lần
                    task.wait(9)
                end
            end)
        end
    end
})

Library:Toggle(true)
--// BOX PHẢI
--// Auto Skill 8
--// Có TechniqueEffect = không kích hoạt
--// Không có TechniqueEffect = kích hoạt

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local SkillRemote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("SkillRemote")

local AutoSkill8 = false

local function GetCharacter()
    local Characters = workspace:FindFirstChild("Characters")
    if not Characters then
        return nil
    end

    return Characters:FindFirstChild(LocalPlayer.Name)
end

local function ActivateSkill()
    local Character = GetCharacter()
    if not Character then
        return
    end

    -- Có TechniqueEffect thì KHÔNG kích hoạt
    if Character:FindFirstChild("TechniqueEffect") then
        return
    end

    local args = {
        [1] = {
            ["Camera"] = CFrame.new(
                1357.5260009765625,
                601.8997192382812,
                -2944.33154296875,
                -0.27307000756263733,
                -0.37132728099823,
                0.887439489364624,
                0,
                0.9224998950958252,
                0.3859974145889282,
                -0.9619942307472229,
                0.1054043173789978,
                -0.25190702080726624
            ),

            ["SkillId"] = "8",
            ["Began"] = true,

            ["CFrame"] = CFrame.new(
                1346.4329833984375,
                595.374755859375,
                -2941.1826171875,
                0.177979975938797,
                -5.2889873813910526e-08,
                -0.9840341210365295,
                7.853634187426906e-09,
                1,
                -5.2327543187402625e-08,
                0.9840341210365295,
                1.5850102341730121,
                0.177979975938797
            ),

            ["Typ\208\181"] = 1,

            ["Aim"] = Vector3.new(
                1395.6346435546875,
                595.374755859375,
                -2950.08154296875
            )
        }
    }

    SkillRemote:FireServer(unpack(args))
end


--// THÊM NÚT VÀO BOX PHẢI
BasicBox:AddToggle("Basic", {
    Text = "Auto beast [work all kaioken]",
    Default = false,

    Callback = function(Value)
        AutoSkill8 = Value
    end
})


--// LOOP
task.spawn(function()
    while task.wait(0.1) do
        if AutoSkill8 then
            ActivateSkill()
        end
    end
end)
local RightBox = Tab:AddRightGroupbox("Select")
--// RIGHT BOX - SELECT FARM + AUTO FARM
--// Tween thuần tới Mob + Dropdown tự update liên tục
--// Không ép CFrame sau tween, không lock ngẫu nhiên sang Mob khác

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local SkillRemote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("SkillRemote")

local LockOnRemote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.4.7")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("SkillManager")
    :WaitForChild("RE")
    :WaitForChild("LockedOnChanged")

local WorldMobs = workspace:WaitForChild("World Mobs")

local AutoFarm = false
local SelectedMob = nil
local TweenSpeed = 200
local FarmThread = nil
local ActiveTween = nil

--// Giới hạn an toàn cho Select Farm
--// Không tween nếu Mob thấp hơn -250 Y, cao hơn 1000 Y,
--// hoặc cách người chơi quá 1000 studs.
local MIN_MOB_Y = -250
local MAX_MOB_Y = 1000
local MAX_TWEEN_DISTANCE = 1000

--// Character
local function GetCharacter()
    local Characters = workspace:FindFirstChild("Characters")
    return Characters and Characters:FindFirstChild(LocalPlayer.Name)
end

--// Root
local function GetRoot()
    local Character = GetCharacter()
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

--// Lấy Root của Mob, hỗ trợ cả Model có PrimaryPart
local function GetMobRoot(Mob)
    if not Mob then return nil end

    return Mob:FindFirstChild("HumanoidRootPart")
        or Mob.PrimaryPart
        or Mob:FindFirstChildWhichIsA("BasePart")
end

--// Lấy Humanoid
local function GetHumanoid(Mob)
    return Mob and Mob:FindFirstChildOfClass("Humanoid")
end

--// Danh sách tên Mob hiện đang tồn tại khi script load
local function GetMobList()
    local List = {}
    local Seen = {}

    for _, Object in ipairs(WorldMobs:GetDescendants()) do
        if Object:IsA("Model") then
            local Humanoid = GetHumanoid(Object)
            local Root = GetMobRoot(Object)

            if Humanoid and Root and Humanoid.Health > 0 then
                if not Seen[Object.Name] then
                    Seen[Object.Name] = true
                    table.insert(List, Object.Name)
                end
            end
        end
    end

    table.sort(List)
    return List
end

--// Tìm Mob đang sống theo tên
local function FindMob(MobName)
    if not MobName then return nil end

    for _, Object in ipairs(WorldMobs:GetDescendants()) do
        if Object:IsA("Model") and Object.Name == MobName then
            local Humanoid = GetHumanoid(Object)
            local Root = GetMobRoot(Object)

            if Humanoid and Root and Humanoid.Health > 0 then
                -- Không nhận target nằm ngoài vùng an toàn.
                if Root.Position.Y > MIN_MOB_Y
                    and Root.Position.Y <= MAX_MOB_Y then
                    return Object
                end
            end
        end
    end

    return nil
end

--// Skill: Aim vào Mob thay vì lấy Aim = vị trí người chơi
local function FireSkill(SkillId, Mob)
    local Root = GetRoot()
    local MobRoot = GetMobRoot(Mob)

    if not Root or not MobRoot then return end

    local Target = MobRoot.Position
    local Above = Target + Vector3.new(0, 6, 0)
    local CF = CFrame.lookAt(Above, Target)

    SkillRemote:FireServer({
        ["Camera"] = workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CF,
        ["SkillId"] = tostring(SkillId),
        ["Began"] = true,
        ["CFrame"] = CF,
        ["Typ\208\181"] = 1,
        ["Aim"] = Target
    })
end

--// LOCK ON đúng Mob đang farm
local function LockMob(Mob)
    if not Mob or not Mob.Parent then return end

    pcall(function()
        LockOnRemote:FireServer(Mob)
    end)
end

--// TWEEN AN TOÀN
--// Không tween nếu:
--//  • Mob Y <= -250 (void)
--//  • Mob Y > 1000 (quá cao)
--//  • Mob cách player > 1000 studs
--// Nếu đang tween mà target vượt giới hạn thì hủy tween ngay.
local function IsSafeMob(Mob, Root)
    if not Mob or not Mob.Parent or not Root then return false end

    local MobRoot = GetMobRoot(Mob)
    local Humanoid = GetHumanoid(Mob)

    if not MobRoot or not Humanoid or Humanoid.Health <= 0 then
        return false
    end

    local Y = MobRoot.Position.Y

    if Y <= MIN_MOB_Y or Y > MAX_MOB_Y then
        return false
    end

    if (Root.Position - MobRoot.Position).Magnitude > MAX_TWEEN_DISTANCE then
        return false
    end

    return true
end

local function TweenToMob(Mob)
    if not AutoFarm then return false end

    local Root = GetRoot()
    if not Root or not IsSafeMob(Mob, Root) then
        return false
    end

    local MobRoot = GetMobRoot(Mob)
    local TargetPosition = MobRoot.Position + Vector3.new(0, 6, 0)
    local TargetCFrame = CFrame.lookAt(TargetPosition, MobRoot.Position)

    local Distance = (Root.Position - TargetPosition).Magnitude

    if Distance > MAX_TWEEN_DISTANCE then
        return false
    end

    if Distance <= 2 then
        return true
    end

    if ActiveTween then
        pcall(function()
            ActiveTween:Cancel()
        end)
        ActiveTween = nil
    end

    local Duration = math.max(
        Distance / math.max(TweenSpeed, 1),
        0.05
    )

    ActiveTween = TweenService:Create(
        Root,
        TweenInfo.new(
            Duration,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        ),
        {
            CFrame = TargetCFrame
        }
    )

    local ThisTween = ActiveTween
    ThisTween:Play()

    while AutoFarm
        and ThisTween.PlaybackState == Enum.PlaybackState.Playing do

        -- Target vượt giới hạn trong lúc tween -> hủy ngay.
        if not IsSafeMob(Mob, Root) then
            ThisTween:Cancel()
            break
        end

        task.wait()
    end

    if ActiveTween == ThisTween then
        ActiveTween = nil
    end

    return AutoFarm
        and ThisTween.PlaybackState == Enum.PlaybackState.Completed
end

--// DROPDOWN
--// Chỉ lấy danh sách 1 lần khi script được load.
--// Không tự update/refresh liên tục.
local MobDropdown = RightBox:AddDropdown("SelectFarmMob", {
    Text = "Select Farm",
    Values = GetMobList(),
    Default = nil,
    Multi = false,

    Callback = function(Value)
        SelectedMob = Value
    end
})

--// TWEEN SPEED
RightBox:AddSlider("FarmTweenSpeed", {
    Text = "Tween Speed",
    Default = 200,
    Min = 50,
    Max = 500,
    Rounding = 0,

    Callback = function(Value)
        TweenSpeed = Value
    end
})

--// AUTO FARM
RightBox:AddToggle("SelectAutoFarm", {
    Text = "Auto Farm Select",
    Default = false,

    Callback = function(Value)
        AutoFarm = Value

        if not Value then
            if ActiveTween then
                pcall(function()
                    ActiveTween:Cancel()
                end)
                ActiveTween = nil
            end
            return
        end

        if FarmThread then return end

        FarmThread = task.spawn(function()
            while AutoFarm do
                if not SelectedMob then
                    task.wait(0.2)
                    continue
                end

                local Mob = FindMob(SelectedMob)

                if not Mob then
                    task.wait(0.15)
                    continue
                end

                local Humanoid = GetHumanoid(Mob)
                local MobRoot = GetMobRoot(Mob)
                local Root = GetRoot()

                if not Humanoid or Humanoid.Health <= 0 or not MobRoot or not Root then
                    task.wait(0.1)
                    continue
                end

                --// Mob quá cao, quá thấp hoặc cách >1000 studs:
                --// không tween tới target đó.
                if not IsSafeMob(Mob, Root) then
                    task.wait(0.05)
                    continue
                end

                --// Chỉ tween tới Mob được chọn khi target an toàn.
                if not TweenToMob(Mob) then
                    task.wait(0.1)
                    continue
                end

                --// Lock + Skill 101 + Skill 1 trên CHÍNH Mob đó
                while AutoFarm
                    and SelectedMob == Mob.Name
                    and Mob.Parent do

                    Humanoid = GetHumanoid(Mob)
                    MobRoot = GetMobRoot(Mob)

                    if not Humanoid
                        or Humanoid.Health <= 0
                        or not MobRoot
                        or MobRoot.Position.Y <= MIN_MOB_Y
                        or MobRoot.Position.Y > MAX_MOB_Y
                        or not IsSafeMob(Mob, GetRoot()) then
                        break
                    end

                    -- Lock đúng target, không random target khác
                    LockMob(Mob)

                    -- Không set Root.CFrame ở đây.
                    -- Vị trí do TweenToMob quản lý hoàn toàn.
                    FireSkill(101, Mob)
                    FireSkill(1, Mob)

                    task.wait(0.1)
                end

                --// Target chết / biến mất: hủy tween và giữ nguyên vị trí 0.4s.
                --// Không tìm/tween target mới trong thời gian này.
                if AutoFarm then
                    if ActiveTween then
                        pcall(function()
                            ActiveTween:Cancel()
                        end)
                        ActiveTween = nil
                    end

                    local HoldRoot = GetRoot()
                    local HoldCFrame = HoldRoot and HoldRoot.CFrame
                    local HoldEnd = os.clock() + 0.4

                    while AutoFarm and os.clock() < HoldEnd do
                        local CurrentRoot = GetRoot()

                        if CurrentRoot and HoldCFrame then
                            CurrentRoot.CFrame = HoldCFrame
                            CurrentRoot.AssemblyLinearVelocity = Vector3.zero
                            CurrentRoot.AssemblyAngularVelocity = Vector3.zero
                        end

                        task.wait()
                    end
                end
            end

            FarmThread = nil
        end)
    end
})

--// OBSIDIAN - AUTO JOIN DUNGEON

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit =
    ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.4.7")
    :WaitForChild("knit")

local DungeonLobbyService =
    Knit:WaitForChild("Services")
    :WaitForChild("DungeonLobbyService")

local CreateLobby =
    DungeonLobbyService
    :WaitForChild("RF")
    :WaitForChild("CreateLobby")

local StartDungeon =
    DungeonLobbyService
    :WaitForChild("RF")
    :WaitForChild("StartDungeon")


--==================================================
-- OBSIDIAN
--==================================================


local Tab1 = Window:AddTab("Dungeon", "option")

local SelectBox = Tab1:AddLeftGroupbox("option")


--==================================================
-- CONFIG
--==================================================

local SelectedMode = "Mecha"
local SelectedDifficulty = "Easy"
local AutoJoin = false

local ModeID = {
    Mecha = 1,
    Atom = 2,
    Droid = 3,
    Hideout = 4
}

local DifficultyID = {
    Easy = 1,
    Normal = 2,
    Hard = 3,
    Hell = 4
}


--==================================================
-- DROPDOWN 1
--==================================================

SelectBox:AddDropdown("option", {
    Values = {
        "Mecha",
        "Atom",
        "Droid",
        "Hideout"
    },

    Default = "Mecha",

    Multi = false,

    Text = "Choose Mode",

    Callback = function(Value)
        SelectedMode = Value
    end
})


--==================================================
-- DROPDOWN 2
--==================================================

SelectBox:AddDropdown("option", {
    Values = {
        "Easy",
        "Normal",
        "Hard",
        "Hell"
    },

    Default = "Easy",

    Multi = false,

    Text = "Choose Difficulty",

    Callback = function(Value)
        SelectedDifficulty = Value
    end
})


--==================================================
-- AUTO JOIN
--==================================================

SelectBox:AddToggle("option", {
    Text = "Auto Join",
    Default = false,

    Callback = function(Value)

        AutoJoin = Value

        if not Value then
            return
        end

        task.spawn(function()

            while AutoJoin do

                --==========================================
                -- ID
                --==========================================

                local DungeonId =
                    ModeID[SelectedMode]

                local Difficulty =
                    DifficultyID[SelectedDifficulty]


                --==========================================
                -- CREATE LOBBY
                --==========================================

                local args = {
                    [1] = {
                        ["DungeonIdSelected"] = DungeonId,

                        ["DungeonStats"] = {
                            ["Difficulty"] = Difficulty
                        }
                    }
                }


                local success, result =
                    pcall(function()

                        return CreateLobby:InvokeServer(
                            unpack(args)
                        )

                    end)


                if success then

                    print(
                        "✅ CreateLobby:",
                        result
                    )

                else

                    warn(
                        "❌ CreateLobby Error:",
                        result
                    )

                end


                --==========================================
                -- WAIT 10 SECONDS
                --==========================================

                for i = 10, 1, -1 do

                    if not AutoJoin then
                        return
                    end

                    print(
                        "⏳ Start Dungeon sau",
                        i,
                        "giây..."
                    )

                    task.wait(1)

                end


                if not AutoJoin then
                    return
                end


                --==========================================
                -- START DUNGEON
                --==========================================

                local startSuccess, startResult =
                    pcall(function()

                        -- Dùng cùng dungeon settings
                        return StartDungeon:InvokeServer(
                            unpack(args)
                        )

                    end)


                if startSuccess then

                    print(
                        "🚀 StartDungeon:",
                        startResult
                    )

                else

                    warn(
                        "❌ StartDungeon Error:",
                        startResult
                    )

                end


                -- Chờ một chút trước vòng tiếp theo
                task.wait(1)

            end

        end)

    end
})


Library:Notify({
    Title = "Dungeon Auto Join",
    Description = "Đã load!",
    Time = 3
})
--// =========================================
--// AUTO SKILL - OBSIDIAN
--// =========================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SkillRemote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("SkillRemote")

local AutoSkillEnabled = false

--// =========================================
--// SKILL ID
--// =========================================

local SkillIDs = {
    ["Orange supernova"] = "113",
    ["Enenry boom"] = "104",
    ["Tri beam"] = "117",
    ["Stardust breaker"] = "116",
    ["Final enenry wave"] = "111",
    ["Blast first"] = "107",
    ["Enenry blast"] = "101",
    ["Death beam"] = "106",

    ["Death cannon"] = "109",
    ["Hellzone ge"] = "112",
    ["Shock wave blast"] = "115",
    ["Destructo disc"] = "128"
}

local SelectedSkills = {
    ["Orange supernova"] = true
}

--// =========================================
--// FIRE SKILL
--// =========================================

local function FireSkill(SkillId, Began)

    local args = {
        [1] = {
            ["Camera"] = CFrame.new(
                -527.6297607421875,
                1399.5377197265625,
                -169.34072875976562,
                -0.4275974631309509,
                0.5169754028320312,
                -0.7415503263473511,
                0,
                0.8203269839286804,
                0.5718948841094971,
                0.9039692878723145,
                0.24454079568386078,
                -0.35076969861984253
            ),

            ["SkillId"] = SkillId,

            ["Began"] = Began,

            ["CFrame"] = CFrame.new(
                -468.1554870605469,
                1351.9703369140625,
                -141.20806884765625,
                -0.9905334711074829,
                5.653752666034961e-08,
                0.1372712403535843,
                6.362779458868317e-08,
                1,
                4.726363656004651e-08,
                -0.1372712403535843,
                5.555047977168215e-08,
                -0.9905334711074829
            ),

            ["Typ\208\181"] = 1,

            ["Aim"] = Vector3.new(
                -475.01904296875,
                1351.9703369140625,
                -91.681396484375
            )
        }
    }

    SkillRemote:FireServer(unpack(args))
end

--// =========================================
--// AUTO SKILL LOOP
--// =========================================

task.spawn(function()

    while task.wait(0.05) do

        if AutoSkillEnabled then

            for SkillName, Enabled in pairs(SelectedSkills) do

                if Enabled then

                    local SkillId = SkillIDs[SkillName]

                    if SkillId then

                        --// BEGIN
                        FireSkill(SkillId, true)

                        task.wait(0.05)

                        --// END
                        FireSkill(SkillId, false)

                        task.wait(0.05)

                    end
                end
            end
        end
    end

end)

--// =========================================
--// LOAD OBSIDIAN
--// =========================================



local Box = Tab1:AddRightGroupbox(
    "Skill"
)

--// =========================================
--// AUTO SKILL DROPDOWN
--// =========================================

Box:AddDropdown("AutoSkill", {

    Values = {
        "Orange supernova",
        "Enenry boom",
        "Tri beam",
        "Stardust breaker",
        "Final enenry wave",
        "Blast first",
        "Enenry blast",
        "Death beam",
        "Death cannon",
        "Hellzone ge",
        "Shock wave blast",
        "Destructo disc"
    },

    Default = {
        "Orange supernova"
    },

    Multi = true,

    Text = "Auto skill",

    Callback = function(Value)

        SelectedSkills = {}

        for SkillName, Enabled in pairs(Value) do

            if Enabled then
                SelectedSkills[SkillName] = true
            end

        end

    end
})

--// =========================================
--// ON / OFF
--// =========================================

Box:AddToggle("AutoSkillToggle", {

    Text = "Auto skill",

    Default = false,

    Callback = function(Value)

        AutoSkillEnabled = Value

        print(
            "[Auto Skill]",
            Value and "ON" or "OFF"
        )

    end
})
    
local Box = Tab1:AddLeftGroupbox("Dungeon")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer


local TWEEN_SPEED = 290

local FOLLOW_DISTANCE = 4
local FLOAT_HEIGHT = 5

local SKILL_DELAY = 0.08
local SKILL_RANGE = 20

local TARGET_UPDATE_DISTANCE = 3
local MIN_TWEEN_TIME = 0.04

--==================================================
-- STATE
--==================================================

local AutoKillDungeon = false

local CurrentMob = nil

local CurrentTween = nil

local FollowToken = 0
local SkillToken = 0

local LastSkill = 0

local HealthConnection = nil

--==================================================
-- SERVICES / REMOTES
--==================================================

local SkillRemote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("SkillRemote")

local LockedOnChanged = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.4.7")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("SkillManager")
    :WaitForChild("RE")
    :WaitForChild("LockedOnChanged")

local EventMobs = workspace
    :WaitForChild("World Mobs")
    :WaitForChild("Event Mobs")

--==================================================
-- CHARACTER
--==================================================

local function GetCharacter()

    local Character = LP.Character

    if not Character then
        return nil
    end

    local Humanoid =
        Character:FindFirstChildOfClass("Humanoid")

    local HRP =
        Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not HRP then
        return nil
    end

    if Humanoid.Health <= 0 then
        return nil
    end

    return Character, Humanoid, HRP
end

--==================================================
-- MOB ROOT
--==================================================

local function GetMobRoot(Mob)

    if not Mob or not Mob.Parent then
        return nil
    end

    local HRP =
        Mob:FindFirstChild("HumanoidRootPart")

    if HRP and HRP:IsA("BasePart") then
        return HRP
    end

    if Mob.PrimaryPart
        and Mob.PrimaryPart:IsA("BasePart") then

        return Mob.PrimaryPart
    end

    for _, Object in ipairs(Mob:GetDescendants()) do

        if Object:IsA("BasePart") then
            return Object
        end

    end

    return nil
end

--==================================================
-- MOB ALIVE
--==================================================

local function IsMobAlive(Mob)

    if not Mob or not Mob.Parent then
        return false
    end

    local Humanoid =
        Mob:FindFirstChildOfClass("Humanoid")

    if Humanoid and Humanoid.Health <= 0 then
        return false
    end

    local Root = GetMobRoot(Mob)

    if not Root then
        return false
    end

    return true
end

--==================================================
-- FIND NEXT MOB
--==================================================

local function FindNextMob()

    if not AutoKillDungeon then
        return nil
    end

    for _, Mob in ipairs(EventMobs:GetChildren()) do

        if Mob ~= CurrentMob
            and IsMobAlive(Mob) then

            return Mob
        end
    end

    return nil
end

--==================================================
-- STOP TWEEN
--==================================================

local function StopTween()

    if CurrentTween then

        pcall(function()
            CurrentTween:Cancel()
        end)

        CurrentTween = nil
    end
end

--==================================================
-- CLEAN HEALTH
--==================================================

local function DisconnectHealth()

    if HealthConnection then
        HealthConnection:Disconnect()
        HealthConnection = nil
    end
end

--==================================================
-- SWITCH MOB
--==================================================

local function SwitchToMob(Mob)

    if not AutoKillDungeon then
        return
    end

    if not Mob or not IsMobAlive(Mob) then
        return
    end

    -- stop target cũ
    StopTween()
    DisconnectHealth()

    CurrentMob = Mob

    -- lock mob
    pcall(function()
        LockedOnChanged:FireServer(Mob)
    end)

    --==================================================
    -- WATCH HP
    --==================================================

    local Humanoid =
        Mob:FindFirstChildOfClass("Humanoid")

    if Humanoid then

        HealthConnection =
            Humanoid.HealthChanged:Connect(function(Health)

                if not AutoKillDungeon then
                    return
                end

                if CurrentMob ~= Mob then
                    return
                end

                if Health <= 0 then

                    -- chết -> đổi ngay
                    StopTween()
                    DisconnectHealth()

                    CurrentMob = nil

                    task.defer(function()

                        if not AutoKillDungeon then
                            return
                        end

                        local NextMob =
                            FindNextMob()

                        if NextMob then
                            SwitchToMob(NextMob)
                        end
                    end)
                end
            end)
    end
end

--==================================================
-- SMOOTH TWEEN FOLLOW
--==================================================

local function StartTweenFollow()

    FollowToken += 1

    local MyToken = FollowToken

    task.spawn(function()

        local LastTarget = nil

        while AutoKillDungeon
            and MyToken == FollowToken do

            local Mob = CurrentMob

            if not Mob then

                local NextMob =
                    FindNextMob()

                if NextMob then
                    SwitchToMob(NextMob)
                end

                task.wait(0.05)
                continue
            end

            if not IsMobAlive(Mob) then

                StopTween()

                CurrentMob = nil

                local NextMob =
                    FindNextMob()

                if NextMob then
                    SwitchToMob(NextMob)
                end

                task.wait(0.03)
                continue
            end

            local Character, Humanoid, HRP =
                GetCharacter()

            if not Character then
                task.wait(0.1)
                continue
            end

            local MobRoot =
                GetMobRoot(Mob)

            if not MobRoot then

                CurrentMob = nil

                local NextMob =
                    FindNextMob()

                if NextMob then
                    SwitchToMob(NextMob)
                end

                task.wait(0.05)
                continue
            end

            --==================================================
            -- TARGET POSITION
            --==================================================

            local MobPosition =
                MobRoot.Position

            local TargetPosition =
                MobPosition
                + Vector3.new(
                    0,
                    FLOAT_HEIGHT,
                    FOLLOW_DISTANCE
                )

            local Distance =
                (HRP.Position - TargetPosition).Magnitude

            -- đã gần target
            if Distance <= 1.5 then

                task.wait(0.05)
                continue
            end

            --==================================================
            -- MOB MOVED
            --==================================================

            if LastTarget then

                local TargetDifference =
                    (TargetPosition - LastTarget).Magnitude

                if TargetDifference < TARGET_UPDATE_DISTANCE then
                    task.wait(0.03)
                    continue
                end
            end

            LastTarget = TargetPosition

            --==================================================
            -- CREATE ONE TWEEN
            --==================================================

            StopTween()

            local TweenTime =
                math.max(
                    Distance / TWEEN_SPEED,
                    MIN_TWEEN_TIME
                )

            local Goal =
                CFrame.lookAt(
                    TargetPosition,
                    MobPosition
                )

            CurrentTween =
                TweenService:Create(
                    HRP,
                    TweenInfo.new(
                        TweenTime,
                        Enum.EasingStyle.Linear,
                        Enum.EasingDirection.Out
                    ),
                    {
                        CFrame = Goal
                    }
                )

            local ThisTween =
                CurrentTween

            ThisTween:Play()

            --==================================================
            -- WAIT FOR THIS TWEEN
            --==================================================

            while AutoKillDungeon
                and MyToken == FollowToken
                and CurrentMob == Mob
                and CurrentTween == ThisTween do

                if not IsMobAlive(Mob) then

                    pcall(function()
                        ThisTween:Cancel()
                    end)

                    if CurrentTween == ThisTween then
                        CurrentTween = nil
                    end

                    break
                end

                local NewRoot =
                    GetMobRoot(Mob)

                if not NewRoot then
                    break
                end

                local NewPosition =
                    NewRoot.Position
                    + Vector3.new(
                        0,
                        FLOAT_HEIGHT,
                        FOLLOW_DISTANCE
                    )

                -- nếu mob chạy quá xa khỏi target cũ
                if
                    (NewPosition - TargetPosition).Magnitude
                    >= TARGET_UPDATE_DISTANCE
                then

                    pcall(function()
                        ThisTween:Cancel()
                    end)

                    break
                end

                task.wait(0.04)
            end

            if CurrentTween == ThisTween then
                CurrentTween = nil
            end

            task.wait(0.01)
        end
    end)
end

--==================================================
-- SKILL LOOP
--==================================================

local function StartSkillLoop()

    SkillToken += 1

    local MyToken = SkillToken

    task.spawn(function()

        while AutoKillDungeon
            and MyToken == SkillToken do

            local Mob = CurrentMob

            if Mob
                and IsMobAlive(Mob) then

                local Character, Humanoid, HRP =
                    GetCharacter()

                local MobRoot =
                    GetMobRoot(Mob)

                if Character and MobRoot then

                    local Distance =
                        (HRP.Position - MobRoot.Position).Magnitude

                    if Distance <= SKILL_RANGE then

                        if os.clock() - LastSkill
                            >= SKILL_DELAY then

                            LastSkill = os.clock()

                            local Camera =
                                workspace.CurrentCamera

                            local MobPosition =
                                MobRoot.Position

                            local LookCF =
                                CFrame.lookAt(
                                    HRP.Position,
                                    MobPosition
                                )

                            local Args = {
                                [1] = {
                                    ["Camera"] =
                                        Camera
                                        and Camera.CFrame
                                        or HRP.CFrame,

                                    ["SkillId"] = "1",

                                    ["Began"] = true,

                                    ["CFrame"] = LookCF,

                                    ["Typ\208\181"] = 1,

                                    ["Aim"] = MobPosition
                                }
                            }

                            pcall(function()
                                SkillRemote:FireServer(unpack(Args))
                            end)
                        end
                    end
                end
            end

            task.wait(0.02)
        end
    end)
end

--==================================================
-- FIND INITIAL MOB
--==================================================

local function FindInitialMob()

    for _, Mob in ipairs(EventMobs:GetChildren()) do

        if IsMobAlive(Mob) then
            return Mob
        end

    end

    return nil
end

--==================================================
-- AUTO DETECT NEW MOB
--==================================================

local ChildAddedConnection = nil

local function StartDetection()

    if ChildAddedConnection then
        ChildAddedConnection:Disconnect()
    end

    ChildAddedConnection =
        EventMobs.ChildAdded:Connect(function(Mob)

            if not AutoKillDungeon then
                return
            end

            task.wait()

            if not IsMobAlive(Mob) then
                return
            end

            -- chỉ đổi nếu target hiện tại không còn
            if not CurrentMob
                or not IsMobAlive(CurrentMob) then

                SwitchToMob(Mob)
            end
        end)
end

--==================================================
-- STOP
--==================================================

local function StopEverything()

    AutoKillDungeon = false

    FollowToken += 1
    SkillToken += 1

    StopTween()

    DisconnectHealth()

    CurrentMob = nil

    if ChildAddedConnection then
        ChildAddedConnection:Disconnect()
        ChildAddedConnection = nil
    end

    local Character =
        LP.Character

    local Humanoid =
        Character
        and Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        Humanoid:Move(Vector3.zero, false)
    end
end

--==================================================
-- CHARACTER RESPAWN
--==================================================

LP.CharacterAdded:Connect(function()

    task.wait(1)

    if not AutoKillDungeon then
        return
    end

    StopTween()
    DisconnectHealth()

    CurrentMob = nil

    task.wait(0.2)

    local Mob =
        FindInitialMob()

    if Mob then
        SwitchToMob(Mob)
    end
end)

--==================================================
-- MAIN TOGGLE
--==================================================

Box:AddToggle("Dungeon", {
    Text = "auto kill Dungeon",
    Default = false,

    Callback = function(Value)

        AutoKillDungeon = Value

        if Value then

            StartDetection()

            local Mob =
                FindInitialMob()

            if Mob then
                SwitchToMob(Mob)
            end

            StartTweenFollow()
            StartSkillLoop()

        else

            StopEverything()
        end
    end
})
                        
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- OBSIDIAN
--==================================================



local AutoWalk = false
local Speed = 16

local Walking = false
local TargetVisual = nil

--==================================================
-- RANDOM MOVEMENT
--==================================================

local RandomDirection = Vector3.zero
local RandomTimer = 0
local RandomMode = "Forward"

local function NewRandomAction()

    local Roll = math.random(1, 100)

    if Roll <= 55 then

        RandomMode = "Forward"

    elseif Roll <= 75 then

        RandomMode = "Side"

        local Side =
            math.random(0, 1) == 0 and -1 or 1

        RandomDirection =
            Vector3.new(Side, 0, 0)

    elseif Roll <= 90 then

        RandomMode = "Circle"

    else

        RandomMode = "Rotate"

    end

    RandomTimer = math.random(4, 12) / 10
end

--==================================================
-- STOP WALKING
--==================================================

local function StopWalking()

    Walking = false
    TargetVisual = nil

    local Character = LocalPlayer.Character

    local Humanoid =
        Character and
        Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        Humanoid:Move(Vector3.zero, false)
    end
end

--==================================================
-- RANDOM MOVEMENT LOOP
--==================================================

RunService.RenderStepped:Connect(function(dt)

    if not AutoWalk then
        return
    end

    if not Walking or not TargetVisual then
        return
    end

    local Character = LocalPlayer.Character

    local Humanoid =
        Character and
        Character:FindFirstChildOfClass("Humanoid")

    local HRP =
        Character and
        Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not HRP then
        return
    end

    if not TargetVisual.Parent then
        StopWalking()
        return
    end

    Humanoid.WalkSpeed = Speed

    local ToTarget =
        TargetVisual.Position - HRP.Position

    local Distance =
        ToTarget.Magnitude

    if Distance <= 5 then

        Humanoid:Move(Vector3.zero, false)

        return
    end

    RandomTimer -= dt

    if RandomTimer <= 0 then
        NewRandomAction()
    end

    local Forward = ToTarget.Unit

    local Right =
        Vector3.new(
            -Forward.Z,
            0,
            Forward.X
        )

    local MoveDirection

    if RandomMode == "Forward" then

        MoveDirection = Forward

    elseif RandomMode == "Side" then

        MoveDirection = (
            Forward +
            Right *
            RandomDirection.X *
            0.7
        ).Unit

    elseif RandomMode == "Circle" then

        MoveDirection = (
            Forward +
            Right *
            math.sin(os.clock() * 3) *
            0.8
        ).Unit

    elseif RandomMode == "Rotate" then

        Humanoid:Move(Vector3.zero, false)

        HRP.CFrame =
            HRP.CFrame *
            CFrame.Angles(
                0,
                math.rad(100) * dt,
                0
            )

        return
    end

    Humanoid:Move(MoveDirection, false)

end)

--==================================================
-- MAIN AUTO WALK LOOP
--==================================================

task.spawn(function()

    while task.wait(0.1) do

        if not AutoWalk then
            StopWalking()
            continue
        end

        --==================================================
        -- CHECK SERVER PLAYER
        --==================================================

        if #Players:GetPlayers() >= 2 then

            StopWalking()

            pcall(function()
                TeleportService:Teleport(
                    game.PlaceId,
                    LocalPlayer
                )
            end)

            break
        end

        --==================================================
        -- FIND DUNGEON VISUAL
        --==================================================

        local Dungeon =
            Workspace:FindFirstChild("Dungeon")

        local Stages =
            Dungeon and
            Dungeon:FindFirstChild("Stages")

        local Stage0 =
            Stages and
            Stages:FindFirstChild("0")

        local NextArea =
            Stage0 and
            Stage0:FindFirstChild("NextArea")

        local Container =
            NextArea and
            NextArea:FindFirstChild("Container")

        local Visual =
            Container and
            Container:FindFirstChild("Visual")

        if not Visual then

            StopWalking()
            continue
        end

        --==================================================
        -- CHECK ATOM MAX
        --==================================================

        local WorldMobs =
            Workspace:FindFirstChild("World Mobs")

        local EventMobs =
            WorldMobs and
            WorldMobs:FindFirstChild("Event Mobs")

        local AtomMax =
            EventMobs and
            EventMobs:FindFirstChild("Atom Max")

        if AtomMax then

            StopWalking()
            continue
        end

        --==================================================
        -- WALK TO VISUAL
        --==================================================

        if Visual:IsA("BasePart") then

            TargetVisual = Visual
            Walking = true

            local Character =
                LocalPlayer.Character

            local HRP =
                Character and
                Character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if HRP then

                local Distance =
                    (Visual.Position - HRP.Position).Magnitude

                if Distance <= 5 then

                    Walking = false

                    local Humanoid =
                        Character:FindFirstChildOfClass(
                            "Humanoid"
                        )

                    if Humanoid then
                        Humanoid:Move(
                            Vector3.zero,
                            false
                        )
                    end

                    --// Đợi trước khi interact
                    task.wait(0.8)

                    --// Kiểm tra AutoWalk
                    if not AutoWalk then
                        TargetVisual = nil
                        continue
                    end

                    --// Kiểm tra player
                    if #Players:GetPlayers() >= 2 then

                        TargetVisual = nil

                        pcall(function()
                            TeleportService:Teleport(
                                game.PlaceId,
                                LocalPlayer
                            )
                        end)

                        break
                    end

                    --// Kiểm tra Visual
                    if not Visual.Parent then
                        TargetVisual = nil
                        continue
                    end

                    --// Kiểm tra Atom Max lần nữa
                    WorldMobs =
                        Workspace:FindFirstChild(
                            "World Mobs"
                        )

                    EventMobs =
                        WorldMobs and
                        WorldMobs:FindFirstChild(
                            "Event Mobs"
                        )

                    AtomMax =
                        EventMobs and
                        EventMobs:FindFirstChild(
                            "Atom Max"
                        )

                    if AtomMax then
                        TargetVisual = nil
                        continue
                    end

                    --==================================================
                    -- INTERACT
                    --==================================================

                    local Pad =
                        NextArea:FindFirstChild(
                            "DungeonNextAreaPad"
                        )

                    local RE =
                        Pad and
                        Pad:FindFirstChild("RE")

                    local Interact =
                        RE and
                        RE:FindFirstChild("Interact")

                    if Interact then
                        pcall(function()
                            Interact:FireServer()
                        end)
                    end

                    TargetVisual = nil
                    Walking = false
                end
            end
        end
    end
end)

--==================================================
-- CONTROL API
--==================================================

_G.AutoWalkCore = {

    SetEnabled = function(Value)

        AutoWalk = Value

        if not Value then
            StopWalking()
        else
            NewRandomAction()
        end
    end,

    SetSpeed = function(Value)

        Speed = tonumber(Value) or 16
    end,

    GetEnabled = function()

        return AutoWalk
    end,

    GetSpeed = function()

        return Speed
    end
}

--==================================================
-- OBSIDIAN TOGGLE
--==================================================

Box:AddToggle("Dungeon", {
    Text = "Auto nextarea",
    Default = false,

    Callback = function(Value)

        AutoWalk = Value

        if Value then
            NewRandomAction()
        else
            StopWalking()
        end
    end
})
--// =========================================
--// ANTI FALL SUPPORT TWEEN - OBSIDIAN
--// =========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local FloatEnabled = false
local FloatConnections = {}

--==================================================
-- REMOVE OLD FLOAT
--==================================================

local function RemoveFloat(Character)

    if not Character then
        return
    end

    local Root =
        Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        return
    end

    local BV =
        Root:FindFirstChild("ContinuousFloat")

    if BV then
        BV:Destroy()
    end
end

--==================================================
-- SETUP FLOAT
--==================================================

local function SetupFloat(Character)

    if not Character then
        return
    end

    local Root =
        Character:WaitForChild(
            "HumanoidRootPart",
            5
        )

    if not Root then
        return
    end

    -- Xóa BodyVelocity cũ nếu có
    RemoveFloat(Character)

    if not FloatEnabled then
        return
    end

    local BV = Instance.new("BodyVelocity")

    BV.Name = "ContinuousFloat"
    BV.MaxForce = Vector3.new(
        0,
        math.huge,
        0
    )

    BV.Velocity = Vector3.zero
    BV.Parent = Root

    --==================================================
    -- SUPPORT
    --==================================================

    local Connection

    Connection = RunService.Heartbeat:Connect(function()

        if not FloatEnabled
            or not BV.Parent
            or not Root.Parent then

            if Connection then
                Connection:Disconnect()
            end

            return
        end

        BV.Velocity = Vector3.zero
    end)

    table.insert(
        FloatConnections,
        Connection
    )
end

--==================================================
-- CHARACTER
--==================================================

Player.CharacterAdded:Connect(function(Character)

    task.wait(0.5)

    if FloatEnabled then
        SetupFloat(Character)
    end
end)



Box:AddToggle("Dungeon", {

    Text = "anti fallv2 click 4 time",

    Default = false,

    Callback = function(Value)

        FloatEnabled = Value

        local Character =
            Player.Character

        if Value then

            if Character then
                SetupFloat(Character)
            end

        else

            RemoveFloat(Character)
        end
    end
})
--// =========================
--// AUTO START BOX
--// =========================

local AutoStartBox = Tab1:AddRightGroupbox("Auto Start")

local AutoStartEnabled = false
local AutoStartThread = nil

local function StartAutoStart()
    if AutoStartThread then
        return
    end

    AutoStartThread = task.spawn(function()

        local started = false

        local Bosses = {
            "Garriot",
            "Great Droid",
            "Atom Max",
            "Mecha Soldier"
        }

        local PART_PATH = {
            "Dungeon",
            "Stages",
            "0",
            "NextArea",
            "Container",
            "Visual"
        }

        local function GetCheckPart()
            local obj = workspace

            for _, name in ipairs(PART_PATH) do
                obj = obj:FindFirstChild(name)

                if not obj then
                    return nil
                end
            end

            return obj
        end

        while AutoStartEnabled do
            task.wait(1)

            local WorldMobs =
                workspace:FindFirstChild("World Mobs")

            local EventMobs =
                WorldMobs and
                WorldMobs:FindFirstChild("Event Mobs")

            if not EventMobs then
                continue
            end

            for _, bossName in ipairs(Bosses) do

                if not AutoStartEnabled then
                    break
                end

                local boss =
                    EventMobs:FindFirstChild(bossName)

                if boss then

                    local humanoid =
                        boss:FindFirstChildOfClass("Humanoid")

                    if humanoid then

                        if humanoid.Health > 0 then
                            started = true
                        end

                        if started and humanoid.Health <= 0 then

                            local CheckPart =
                                GetCheckPart()

                            if CheckPart then
                                continue
                            end

                            started = false

                            task.wait(4.04)

                            if not AutoStartEnabled then
                                break
                            end

                            pcall(function()
                                game:GetService("ReplicatedStorage")
                                    :WaitForChild("Packages")
                                    :WaitForChild("_Index")
                                    :WaitForChild("sleitnick_knit@1.4.7")
                                    :WaitForChild("knit")
                                    :WaitForChild("Services")
                                    :WaitForChild("DungeonLobbyService")
                                    :WaitForChild("RF")
                                    :WaitForChild("StartDungeon")
                                    :InvokeServer()
                            end)

                            break
                        end
                    end
                end
            end
        end

        AutoStartThread = nil
    end)
end

AutoStartBox:AddToggle("AutoStart", {
    Text = "Auto Start",
    Default = false,

    Callback = function(Value)
        AutoStartEnabled = Value

        if Value then
            StartAutoStart()
            print("[Auto Start] ON")
        else
            print("[Auto Start] OFF")
        end
    end
})
local AutoReplayEnabled = false
local AutoReplayThread = nil

AutoStartBox:AddToggle("AutoReplay", {
    Text = "auto replay",
    Default = false,

    Callback = function(Value)
        AutoReplayEnabled = Value

        if Value then
            if AutoReplayThread then
                return
            end

            AutoReplayThread = task.spawn(function()
                local Triggered = false

                while AutoReplayEnabled do
                    task.wait(0.1)

                    local Character = LocalPlayer.Character
                    local Humanoid = Character
                        and Character:FindFirstChildOfClass("Humanoid")

                    if Humanoid and Humanoid.Health <= 0 then

                        if not Triggered then
                            Triggered = true

                            task.wait(13)

                            if not AutoReplayEnabled then
                                Triggered = false
                                break
                            end

                            Character = LocalPlayer.Character
                            Humanoid = Character
                                and Character:FindFirstChildOfClass("Humanoid")

                            if Humanoid and Humanoid.Health <= 0 then
                                local EventMobs =
                                    workspace["World Mobs"]["Event Mobs"]

                                for _, Mob in ipairs(EventMobs:GetChildren()) do
                                    local MobHumanoid =
                                        Mob:FindFirstChildOfClass("Humanoid")

                                    if MobHumanoid then
                                        MobHumanoid.Health = 0
                                    end
                                end
                            end
                        end

                    else
                        -- Hồi sinh trước 13 giây
                        Triggered = false
                    end
                end

                AutoReplayThread = nil
            end)
        else
            AutoReplayThread = nil
        end
    end,
})

--====================================================
--// UI SETTINGS / THEME / CONFIG
--====================================================

local SettingsTab = Window:AddTab("UI Settings", "settings")

ThemeManager:SetLibrary(Obsidian)
SaveManager:SetLibrary(Obsidian)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

ThemeManager:SetFolder("Auto1-700Rebirth")
SaveManager:SetFolder("Auto1-700Rebirth")

SaveManager:BuildConfigSection(SettingsTab)
ThemeManager:ApplyToTab(SettingsTab)

-- Load config marked as autoload, if one exists.
SaveManager:LoadAutoloadConfig()

Obsidian:Notify({
    Title = "Auto 1-700 Rebirth",
    Description = "UI Settings loaded!",
    Time = 3
})


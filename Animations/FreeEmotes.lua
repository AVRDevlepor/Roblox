-- Use /e <emote> or /emote <emote> to load the emote. Abbreviation from the beginning of the name allowed, not case-sensitive.
-- R15 Emotes (All catalog emotes are already inserted)
local Emotes = {
    agree = 4841397952,
    disagree = 4841401869,
    powerblast = 4841403964,
    happy = 4841405708,
    sad = 4841407203,
    bunnyhop = 4641985101,
    peanutbutterjellydance = 4406555273,
    pbandjdance = 4406555273,
    pbjdance = 4406555273,
    aroundtown = 3303391864,
    toprock = 3361276673,
    jumpingwave = 4940564896,
    keepingtime = 4555808220,
    fashionable = 3333331310,
    robot = 3338025566,
    twirl = 3334968680,
    jacks = 3338066331,
    tpose = 3338010159,
    shy = 3337978742,
    monkey = 3333499508,
    borocksrange = 3236842542,
    udzal = 3303161675,
    hypedance = 3695333486,
    godlike = 3337994105,
    swoosh = 3361481910,
    sneaky = 3334424322,
    sidetoside = 3333136415,
    side2side = 3333136415,
    greatest = 3338042785,
    louder = 3338083565,
    celebrate = 3338097973,
    haha = 3337966527,
    getout = 3333272779,
    waveoff = 3333272779,
    tree = 4049551434,
    fishing = 3334832150,
    fasthands = 4265701731,
    y = 4349285876,
    yawn = 4349285876,
    zombie = 4210116953,
    babydance = 4265725525,
    linedance = 4049037604,
    dizzy = 3361426436,
    shuffle = 4349242221,
    dorkydance = 4212455378,
    bodybuilder = 3333387824,
    idol = 4101966434,
    fancyfeet = 3333432454,
    curtsy = 4555816777,
    airdance = 4555782893,
    chickendance = 4841399916,
    sleep = 4686925579,
    herolanding = 5104344710,
    confused = 4940561610,
    cower = 4940563117,
    tantrum = 5104341999,
    bored = 5230599789,
    beckon = 5230598276,
    hello = 3344650532,
    salute = 3333474484,
    stadium = 3338055167,
    tilt = 3334538554,
    point2 = 3344585679,
    shrug = 3334392772,
    highwave = 5915690960,
    applaud = 5915693819,
    breakdance = 5915648917,
    rockon = 5915714366,
    dolphindance = 5918726674,
    jumpingcheer = 5895324424,
    floss = 5917459365,
    countrylinedance = 5915712534,
    paninidance = 5915713518,
    holiday = 5937558680,
    rodeo = 5918728267,
    oldtownroad = 5937560570
}

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
Player.CharacterAdded:Connect(function(C)
    Character = C
end)

local match, split, lower = string.match, string.split, string.lower

local Debris = game:GetService("Debris")
local Ver = ANIMSCR1_VER or 0
getgenv().ANIMSCR1_VER = Ver + 1
Ver = Ver + 1

local function FindInTable(T, M)
    local Va;
    table.foreach(T, function(K, V)
        if match(K, M) then
            Va = V
        end
    end)
    return Va
end

local ChatScroller = Player.PlayerGui.Chat.Frame:WaitForChild("ChatChannelParentFrame"):WaitForChild("Frame_MessageLogDisplay"):WaitForChild("Scroller")
local ChatSConn;
ChatSConn = ChatScroller.ChildAdded:Connect(function(self)
    if ANIMSCR1_VER > Ver then ChatSConn:Disconnect() end
    if self:IsA("Frame") and self:FindFirstChildOfClass("TextLabel") and self:FindFirstChildOfClass("TextLabel").Text == "You can't use that Emote." then
        self.Size = UDim2.new(1, 0, 0, 0)
        Debris:AddItem(self, 1) -- Hide the annoyances
    end
end)

local EmoteDb = false
local ChatConn;
ChatConn = Player.Chatted:Connect(function(ToChat)
    if ANIMSCR1_VER > Ver then ChatConn:Disconnect() end
    if match(ToChat, "^/e ") or match(ToChat, "^/emote ") then
        local EmoteName = split(ToChat, " ")[2]
        if EmoteName then
            EmoteName = lower(EmoteName)
            if EmoteDb == false and FindInTable(Emotes, "^"..EmoteName) and EmoteName ~= "point" then
                EmoteDb = true
                local Humanoid = Character:WaitForChild("Humanoid")

                if Character:FindFirstChild("Animate") then
                    Character.Animate.Disabled = true
                end

                for _, Track in pairs(Humanoid:GetPlayingAnimationTracks()) do
                    Track:Stop()
                end

                local Anim = Instance.new("Animation")
                Debris:AddItem(Anim, 1)
                Anim.AnimationId = "rbxassetid://"..FindInTable(Emotes, "^"..EmoteName)

                local Track = Humanoid:LoadAnimation(Anim)
                local TConn1;
                local TConn2;
                TConn2 = Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                    if Humanoid.MoveDirection ~= Vector3.new(0, 0, 0) then
                        TConn1:Disconnect() -- embrace the gc
                        TConn2:Disconnect()
                        for _, T in pairs(Humanoid:GetPlayingAnimationTracks()) do
                            T:Stop()
                        end
                        if Character:FindFirstChild("Animate") then
                            Character.Animate.Disabled = false
                        end
                        EmoteDb = false
                    end
                end)

                Track:Play()
                TConn1 = Track.Stopped:Connect(function()
                    TConn1:Disconnect() -- embrace the gc
                    TConn2:Disconnect()
                    for _, T in pairs(Humanoid:GetPlayingAnimationTracks()) do
                        T:Stop()
                    end
                    if Character:FindFirstChild("Animate") then
                        Character.Animate.Disabled = false
                    end

                    delay(1, function()
                        local IdleAnim = Instance.new("Animation")
                        Debris:AddItem(IdleAnim, 1)
                        IdleAnim.AnimationId = Character:FindFirstChild("Animate") and Character.Animate.idle.Animation1.AnimationId or "rbxassetid://2510196951" -- rthro idle
                        Humanoid:LoadAnimation(IdleAnim):Play()
                        EmoteDb = false
                    end)
                end)
            end
        end
    end
end)

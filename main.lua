--[[======================================================  XERA HUB (Obfuscated)  ======================================================]]
repeat task.wait()until game:IsLoaded()and game:GetService("Players").LocalPlayer;local a,b,c,d,e,f,g,h=unpack,loadstring,game,task,math,table,string,char;local i=j=k=l=m=n=o=p=q=r=s=t=u=v=w=x=y=z=0
local function A(B,C)D=E(F(G(H(I(J(K(L(M(N(O(P(Q(R(S(T(U(V(W(X(Y(Z(0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xA,0xB,0xC,0xD,0xE,0xF,0x10)))))))))))))))end
local function _(B)return C(D(E(F(G(H(I(J(K(L(M(N(O(P(Q(R(S(T(U(V(W(X(Y(Z(B))))))))))))))))))))))))))end
local aa=_([[Xera Hub]]);local ab=_([[by Nobody]]);local ac=_([[https://sirius.menu/rayfield]]);local ad=game:GetService("Players")
local ae=game:GetService("RunService");local af=workspace.CurrentCamera;local ag=ad.LocalPlayer;local ah=ag.Character or ag.CharacterAdded:Wait()
local ai=ah:WaitForChild("HumanoidRootPart",10);local aj=Instance.new("PointLight");aj.Name="ESP_Light";aj.Range=60;aj.Brightness=2;aj.Shadows=false;aj.Enabled=true;if ai then aj.Parent=ai end
local ak=loadstring(game:HttpGet(ac))();local al=ak:CreateWindow({Name=aa,LoadingTitle=aa,LoadingSubtitle=ab,Theme="Dark Blue",ToggleUIKeybind="U",})
local function am(an,ao,ap)local aq=_(an)local ar=ao and Color3.fromRGB(ao[1],ao[2],ao[3])or Color3.fromRGB(255,255,255)
al:Notify({Title=_([[Xera notification]]),Content=aq,Duration=ap or 3,})end
local function as(at)local au=Instance.new("Sound",ag:WaitForChild("PlayerGui"));au.SoundId="rbxassetid://"..at;au.Volume=0.1;au:Play();game.Debris:AddItem(au,3)end
local function av()as(6176997734)end;local function aw()as(4590662766)end;local ax=true;local ay=true;local az=true;local aA=true
local aB,aC,aD,aE,aF,aG,aH={},{},{},{},{},{},{}
local function aI(aJ)if aJ and aJ.Remove then pcall(aJ.Remove,aJ)end end
local function aK(aL,aM)local aN=Drawing.new("Square");aN.Filled=false;aN.Visible=false;local aO=Drawing.new("Text");aO.Center=true;aO.Size=16;aO.Font=2;aO.Outline=true;aO.Visible=false;aO.Text=aL or"Entity"
local aP=Drawing.new("Text");aP.Center=true;aP.Size=14;aP.Font=2;aP.Outline=true;aP.Visible=false;local aQ=Drawing.new("Line");aQ.Thickness=1.5;aQ.Visible=false;local aR=Drawing.new("Square");aR.Filled=true;aR.Visible=false;aR.Color=Color3.fromRGB(0,255,0)
return{Box=aN,Name=aO,Distance=aP,Tracer=aQ,Health=aR,Color=aM or Color3.fromRGB(255,255,255),Label=aL or"Entity"}end
local aS={[_([[monster]])]={label=_([[A-60]]),color=Color3.fromRGB(255,0,0)},[_([[monster2]])]={label=_([[A-120/A-200]]),color=Color3.fromRGB(255,120,0)},
[_([[Spirit]])]={label=_([[A-100]]),color=Color3.fromRGB(140,0,255)},[_([[handdebris]])]={label=_([[A-250]]),color=Color3.fromRGB(255,0,0)},
[_([[jack]])]={label=_([[A-40]]),color=Color3.fromRGB(200,200,200)}}
local function aT(aU)if aD[aU]then return end;local aV=aS[aU.Name];if not aV then return end;local aW=aK(aV.label,aV.color);aB[aU]={esp=aW,info=aV};aD[aU]=true;av();am("⚠ Monster spawned: "..aV.label,{aV.color:ToRGB()},3)end
local function aX(aU)local aY=aB[aU];if not aY then return end;local aW,aV=aY.esp,aY.info;for _,aZ in pairs(aW)do aI(aZ)end;aB[aU]=nil;aD[aU]=nil;aw();am("✅ Monster despawned: "..(aV and aV.label or"?"),{100,255,100},2)end
local function a_(a$)if aE[a$]then return end;if a$.Name~="battery"or a$.Parent.Parent.Name~="rooms"then return end;local a0=aK("Battery",Color3.fromRGB(255,143,74));aC[a$]=a0;aE[a$]=true;am("🔋 Battery spawned! Grab it!",{255,143,74},3);aw()end
local function ba(a$)local a0=aC[a$];if not a0 then return end;for _,aZ in pairs(a0)do aI(aZ)end;aC[a$]=nil;aE[a$]=nil;am("🔋 Battery gone.",{255,143,74},3);aw()end
local function bb(bc)if bc==ag then return end;if aF[bc]then return end;aF[bc]=aK(bc.Name,Color3.fromRGB(50,150,255))end
local function bd(bc)local a0=aF[bc];if a0 then for _,aZ in pairs(a0)do aI(aZ)end end;aF[bc]=nil end
for _,be in ipairs(ad:GetPlayers())do bb(be)end;ad.PlayerAdded:Connect(bb);ad.PlayerRemoving:Connect(bd)
workspace.ChildAdded:Connect(function(bf)if aS[bf.Name]then aT(bf)end end)
workspace.DescendantAdded:Connect(function(bg)if bg:IsA("Model")and bg.Name=="battery"and not aE[bg]then a_(bg)elseif bg.Name=="jack"then aT(bg)end end)
workspace.DescendantRemoving:Connect(function(bg)if aS[bg.Name]then aX(bg)elseif bg.Name=="battery"and aE[bg]then ba(bg)end end)
local bh=al:CreateTab("ESP");local bi={};bi.TracerEnabled=true;bi.NameEnabled=true;bi.DistanceEnabled=true;bi.BoxEnabled=true;bi.HealthEnabled=true
bi.BoxColor=Color3.fromRGB(50,150,255);bi.TracerColor=Color3.fromRGB(50,150,255);bi.NameColor=Color3.fromRGB(255,255,255);bi.DistanceColor=Color3.fromRGB(180,180,180);bi.HealthColor=Color3.fromRGB(0,255,0)
bh:CreateSection("Players");bh:CreateToggle({Name="Player ESP",CurrentValue=true,Callback=function(bj)aA=bj end})
bh:CreateToggle({Name="Player Box",CurrentValue=true,Callback=function(bj)bi.BoxEnabled=bj end})
bh:CreateColorPicker({Name="Player BoxColor",Color=bi.BoxColor,Callback=function(bk)bi.BoxColor=bk end})
bh:CreateToggle({Name="Player Tracer",CurrentValue=true,Callback=function(bj)bi.TracerEnabled=bj end})
bh:CreateColorPicker({Name="Player TracerColor",Color=bi.TracerColor,Callback=function(bk)bi.TracerColor=bk end})
bh:CreateToggle({Name="Player Name",CurrentValue=true,Callback=function(bj)bi.NameEnabled=bj end})
bh:CreateColorPicker({Name="Player NameColor",Color=bi.NameColor,Callback=function(bk)bi.NameColor=bk end})
bh:CreateToggle({Name="Player Distance",CurrentValue=true,Callback=function(bj)bi.DistanceEnabled=bj end})
bh:CreateColorPicker({Name="Player DistanceColor",Color=bi.DistanceColor,Callback=function(bk)bi.DistanceColor=bk end})
bh:CreateToggle({Name="Player Health Bar",CurrentValue=true,Callback=function(bj)bi.HealthEnabled=bj end})
bh:CreateColorPicker({Name="Player HealthColor",Color=bi.HealthColor,Callback=function(bk)bi.HealthColor=bk end})
bh:CreateSection("Monsters");bh:CreateToggle({Name="Monster ESP",CurrentValue=true,Callback=function(bj)ax=bj end})
for bl,bm in pairs(aS)do bh:CreateSection(bm.label);aG[bm.label]={TracerEnabled=true,NameEnabled=true,DistanceEnabled=true,BoxEnabled=true,BoxColor=bm.color,TracerColor=bm.color,NameColor=bm.color,DistanceColor=Color3.fromRGB(180,180,180)}
bh:CreateToggle({Name=bm.label.." Box",CurrentValue=true,Callback=function(bn)aG[bm.label].BoxEnabled=bn end})
bh:CreateColorPicker({Name=bm.label.." BoxColor",Color=bm.color,Callback=function(bo)aG[bm.label].BoxColor=bo end})
bh:CreateToggle({Name=bm.label.." Tracer",CurrentValue=true,Callback=function(bn)aG[bm.label].TracerEnabled=bn end})
bh:CreateColorPicker({Name=bm.label.." TracerColor",Color=bm.color,Callback=function(bo)aG[bm.label].TracerColor=bo end})
bh:CreateToggle({Name=bm.label.." Name",CurrentValue=true,Callback=function(bn)aG[bm.label].NameEnabled=bn end})
bh:CreateColorPicker({Name=bm.label.." NameColor",Color=bm.color,Callback=function(bo)aG[bm.label].NameColor=bo end})
bh:CreateToggle({Name=bm.label.." Distance",CurrentValue=true,Callback=function(bn)aG[bm.label].DistanceEnabled=bn end})
bh:CreateColorPicker({Name=bm.label.." DistanceColor",Color=aG[bm.label].DistanceColor,Callback=function(bo)aG[bm.label].DistanceColor=bo end})end
local bp=al:CreateTab("Battery ESP");bp:CreateSection("Battery Settings");local bq={TracerEnabled=true,NameEnabled=true,DistanceEnabled=true,BoxEnabled=true,Color=Color3.fromRGB(255,143,74),DistanceColor=Color3.fromRGB(180,180,180)}
bp:CreateToggle({Name="Battery ESP Enabled",CurrentValue=true,Callback=function(br)ay=br end})
bp:CreateToggle({Name="Box",CurrentValue=true,Callback=function(br)bq.BoxEnabled=br end})
bp:CreateToggle({Name="Tracer",CurrentValue=true,Callback=function(br)bq.TracerEnabled=br end})
bp:CreateToggle({Name="Name",CurrentValue=true,Callback=function(br)bq.NameEnabled=br end})
bp:CreateToggle({Name="Distance",CurrentValue=true,Callback=function(br)bq.DistanceEnabled=br end})
bp:CreateColorPicker({Name="Battery Color",Color=bq.Color,Callback=function(bs)bq.Color=bs end})
bp:CreateColorPicker({Name="Battery DistanceColor",Color=bq.DistanceColor,Callback=function(bs)bq.DistanceColor=bs end})
local bt=al:CreateTab("Lighting");bt:CreateSection("PointLight")
bt:CreateToggle({Name="Enable Light",CurrentValue=true,Callback=function(bu)az=bu;aj.Enabled=bu end})
bt:CreateSlider({Name="Light Brightness",Range={0,5},Increment=0.1,CurrentValue=2,Callback=function(bu)aj.Brightness=bu end})
bt:CreateSlider({Name="Light Range",Range={10,100},Increment=5,CurrentValue=60,Callback=function(bu)aj.Range=bu end})
ae.RenderStepped:Connect(function()
for bv,bw in pairs(aF)do local bx=bv.Character;if not aA or not bx or not bx:FindFirstChild("HumanoidRootPart")then for _,by in pairs(bw)do by.Visible=false end continue end;local bz=bx.HumanoidRootPart;local bA,bB=af:WorldToViewportPoint(bz.Position);if not bB then for _,by in pairs(bw)do by.Visible=false end continue end
local bC=2500/math.max(bA.Z,1);local bD=Vector2.new(bA.X-bC/4,bA.Y-bC/2);bw.Box.Size=Vector2.new(bC/2,bC);bw.Box.Position=bD;bw.Box.Color=bi.BoxColor;bw.Box.Visible=bi.BoxEnabled
local bE=bx:FindFirstChildOfClass("Humanoid");local bF=1;if bE and bE.MaxHealth>0 then bF=math.clamp(bE.Health/bE.MaxHealth,0,1)end
if bw.Health then local bG=bC*bF;bw.Health.Size=Vector2.new(3,bG);bw.Health.Position=Vector2.new(bD.X-6,bD.Y+(bC-bG));bw.Health.Color=bi.HealthColor;bw.Health.Visible=bi.HealthEnabled end
bw.Name.Text=bv.Name;bw.Name.Position=Vector2.new(bA.X,bA.Y+bC/2+10);bw.Name.Color=bi.NameColor;bw.Name.Visible=bi.NameEnabled
if ag.Character and ag.Character:FindFirstChild("HumanoidRootPart")then local bH=(ag.Character.HumanoidRootPart.Position-bz.Position).Magnitude;bw.Distance.Text=string.format("[%.1f m]",bH);bw.Distance.Position=Vector2.new(bA.X,bA.Y+bC/2+25);bw.Distance.Color=bi.DistanceColor;bw.Distance.Visible=bi.DistanceEnabled end
local bI=Vector2.new(af.ViewportSize.X/2,af.ViewportSize.Y-50);bw.Tracer.From=bI;bw.Tracer.To=Vector2.new(bA.X,bA.Y);bw.Tracer.Color=bi.TracerColor;bw.Tracer.Visible=bi.TracerEnabled end
for bJ,bK in pairs(aB)do local bL=bK.esp;if not bJ or not bJ.Parent then aX(bJ)continue end;local bM;if bJ:IsA("BasePart")then bM=bJ.Position elseif bJ:IsA("Model")then bM=(bJ.PrimaryPart and bJ.PrimaryPart.Position)or(bJ:FindFirstChild("torso")and bJ.torso.Position)end
if bL.Label=="A-40"then pcall(function()if bJ.Parent.PrimaryPart then bM=bJ.Parent.PrimaryPart.Position end end)end;if not bM then continue end;local bN,bO=af:WorldToViewportPoint(bM);local bP=bO and ax
local bQ=aG[bL.Label]or{};bL.Box.Visible=bP and bQ.BoxEnabled;bL.Name.Visible=bP and bQ.NameEnabled;bL.Distance.Visible=bP and bQ.DistanceEnabled;bL.Tracer.Visible=bP and bQ.TracerEnabled;if not bP then continue end
local bC=2500/math.max(bN.Z,1);bL.Box.Size=Vector2.new(bC/2,bC);bL.Box.Position=Vector2.new(bN.X-bC/4,bN.Y-bC/2);bL.Box.Color=bQ.BoxColor or bK.info.color
bL.Name.Text=bL.Label;bL.Name.Position=Vector2.new(bN.X,bN.Y+bC/2+10);bL.Name.Color=bQ.NameColor or bK.info.color
if ag.Character and ag.Character:FindFirstChild("HumanoidRootPart")then local bH=(ag.Character.HumanoidRootPart.Position-bM).Magnitude;bL.Distance.Text=string.format("[%.1f m]",bH);bL.Distance.Position=Vector2.new(bN.X,bN.Y+bC/2+25);bL.Distance.Color=bQ.DistanceColor or Color3.fromRGB(180,180,180)end
local bI=Vector2.new(af.ViewportSize.X/2,af.ViewportSize.Y-50);bL.Tracer.From=bI;bL.Tracer.To=Vector2.new(bN.X,bN.Y);bL.Tracer.Color=bQ.TracerColor or bK.info.color end
for bR,bS in pairs(aC)do if not bR or not bR.Parent then continue end;local bM=bR:IsA("BasePart")and bR.Position or(bR.PrimaryPart and bR.PrimaryPart.Position);if not bM then continue end
local bN,bO=af:WorldToViewportPoint(bM);local bP=bO and ay;bS.Box.Visible=bP and bq.BoxEnabled;bS.Name.Visible=bP and bq.NameEnabled;bS.Distance.Visible=bP and bq.DistanceEnabled;bS.Tracer.Visible=bP and bq.TracerEnabled;if not bP then continue end
local bT=800/math.max(bN.Z,1);bS.Box.Size=Vector2.new(bT/2,bT/2);bS.Box.Position=Vector2.new(bN.X-bT/4,bN.Y-bT/4);bS.Box.Color=bq.Color
bS.Name.Text="Battery";bS.Name.Position=Vector2.new(bN.X,bN.Y+bT/2+8);bS.Name.Color=bq.Color
if ag.Character and ag.Character:FindFirstChild("HumanoidRootPart")then local bH=(ag.Character.HumanoidRootPart.Position-bM).Magnitude;bS.Distance.Text=string.format("[%.1f m]",bH);bS.Distance.Position=Vector2.new(bN.X,bN.Y+bT/2+20);bS.Distance.Color=bq.DistanceColor end
local bI=Vector2.new(af.ViewportSize.X/2,af.ViewportSize.Y-50);bS.Tracer.From=bI;bS.Tracer.To=Vector2.new(bN.X,bN.Y);bS.Tracer.Color=bq.Color end end)

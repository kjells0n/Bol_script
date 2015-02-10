if myHero.charname ~= "Anivia" then return end

Require "VPrediction"
Require "SXOrbwalk"

local Qmiss = nil
local Rmiss = nil
local myQ = myhero:getspelldata(_Q)
local myW = myhero:getspelldata(_W)
local myE = myHero:GetSpellData(_E)
local myR = myHero:GetSpellData(_R)
local Target = nil
local ignite, iDMG = nil, 0


function Onload ()

				Printchat ("Toshi Anivia loaded")

 function menu()
		Config = Scriptconfig ("TAnivia", "Anivia")
		
		Config:addSubMenu("Key Settings", "Keys")
			Config.keys:addParam("combokey", "combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			
		Config:addsubmenu("combo settings", "Combo")
			Config.cobmo:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
			Config.combo:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, false)
			Config.combo:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
			Config.combo:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, true)
			Config.combo:addParam("useI", "Use Ignite", SCRIPT_PARAM_ONOFF, false)
			
			Config:addSubMenu("Orbwalker", "SxOrb")
				SxOrb:LoadToMenu(Config.SxOrb) 
				
			config:AddSubMenu("Target Selector", "TS")
				Condig.TS:addTS(ts) 
			
end

function Ontick()
				check()
				
				if ValidTarget(target) then
						if Config.Misc.KS then
										KS(target)
							end
							if Config.Misc.IKS then
											AutoIgnite(target)
							end
				end
				
				if Config.Keys.Combokey then
							Combo()
							
				end

end

function Checks()
					ts:update()
					target = ts.target
					SxOrb:ForceTarget (target)
					QREADY = (myHero:CanUseSpell(_Q) == READY)
					WREADY = (myHero:CanUseSpell(_W) == READY)
					EREADY = (myHero:CanUseSpell(_E) == READY)
					RREADY = (myHero:CanUseSpell(_R) == READY)
					IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
					if Qmiss ~=nil then
		DetQ()
	end
	if Rmiss ~= nil and JAnivia.SSettings.Rset.cancelR then
		if JAnivia.SSettings.Rset.keepR and not JAnivia.LaneClear then
			if not ValidR() then castR(nil) end
		end
	end
end

function Combo()
					if JAnivia.CSettings.useQ and Qrdy then
		local qcheck, qtype = Qchecks(Target)
		if qtype ~= nil then
			if qtype == "vpred" then
				castQ(qcheck)
			end
			if qtype == "free" then
				castQ(Target)
			end
		end
	end
	if JAnivia.CSettings.useE and Erdy then
		local echeck = Echecks(Target)
		if echeck == true then
			castE(Target)
		end
	end
	if JAnivia.CSettings.useW and Wrdy then
		local wcheck = Wchecks(Target)
		if wcheck ~= nil then
			castW(wcheck)
		end
	end
	if JAnivia.CSettings.useR and Rrdy then
		local rtype, rcheck = Rchecks(Target)
		if rtype ~= nil then
			if rtype == "vpred" then
				castR(rcheck)
			end
			if rtype == "free" then
				castR(Target)
			end
		end
	end
end

function DetQ()
	if JAnivia.SSettings.Qset.Qdet then
		for i=1, heroManager.iCount, 1 do
			local champ = heroManager:GetHero(i)
			if champ.team ~= myHero.team then
				if GetDistance(champ, Qmiss) < 150 then
					castQ(nil)
				end
			end
		end
	else
		if GetDistance(Target, Qmis) < 150 then
			castQ(nil)
		end
	end
end

function castQ(targ)
	if targ == nil and Qmiss ~= nil then
		if VIP_USER then
			Packet("S_CAST", {spellId = _Q}):send()
		else
			CastSpell(_Q)
		end
	end
	if targ ~= nil and Qmiss == nil then
		if VIP_USER then
				Packet('S_CAST', { spellId = _Q, toX = targ.x, toY = targ.z , fromX = targ.x , fromY = targ.z }):send()		
		else
				CastSpell(_Q, targ.x, targ.z)
		end
	end
end

function castE(targ)
	if VIP_USER then
		Packet("S_CAST", {spellId = _E,targetNetworkId = targ.networkID}):send()
	else
		CastSpell(_E, targ)
	end
end

function castW(targ)
	if VIP_USER then
		Packet("S_CAST", {spellId = _W, toX = targ.x, toY = targ.z , fromX = targ.x , fromY = targ.z }):send()	
	else
		CastSpell(_W, targ.x, targ.z)
	end
end

function castR(targ)
	if targ == nil and Rmiss ~= nil then
		if VIP_USER then
			Packet("S_CAST", {spellId = _R}):send()
		else
			CastSpell(_R)
		end
	end
	if targ ~= nil and Rmiss == nil then
		if VIP_USER then
			Packet('S_CAST', { spellId = _R, toX = targ.x, toY = targ.z , fromX = targ.x , fromY = targ.z }):send()		
		else
			CastSpell(_R, targ.x, targ.z)
		end
	end
end

function Qchecks(targ)
	if targ == nil then return nil, nil end
	local CastPosition = nil
	local HitChance = nil
	local Position = nil
	local retval = nil
	local rettype = nil
	if Qmis ~= nil then return nil, nil end
	if GetDistance(Target, myHero) < 1100 then
		if JAnivia.SSettings.Vpred then
			CastPosition, HitChance = VP:GetLineCastPosition(targ, 0.250, 150, 1100, 850)
			if HitChance == 2 or HitChance == 4 or HitChance == 5 and GetDistance(CastPosition, myHero) < 1100 then
				retval = CastPosition
				rettype = "vpred"
			end
		end
		if not JAnivia.SSettings.Vpred then
			retval = "free"
			rettype = "free"
		end
	end
	return retval, rettype
end


function Echecks(targ)
	if targ == nil then return false end
	if GetDistance(targ, myHero) < 650 then
		if JAnivia.SSettings.Eset.Echilled then
			if TargetHaveBuff("chilled", targ) then return true end
		else
			return true
		end
	end
	return false
end

function autoE()
	for i=1, heroManager.iCount, 1 do
		local champ = heroManager:GetHero(i)
		if champ.team ~= myHero.team then
			if Echecks(champ) == true then castE(champ) end
		end
	end
end

function Rchecks(targ)
	local rettype = nil
	local retval = nil
	if GetDistance(targ, myHero) < 650 then
		--[[if JAnivia.SSettings.Vpred then
			CastPosition, HitChance = VP:GetCircularCastPosition(targ, 0.250, 210, 650, 3000)
			if HitChance == 2 or HitChance == 4 or HitChance == 5 and GetDistance(CastPosition, myHero) < 650 then
				PrintChat("Should have cast R")
				retval = CastPosition
				rettype = "vpred"
			end
		end]]--
		--if not JAnivia.SSettings.Vpred then 
			retval = "free"
			rettype = "free"
	--	end
	end
	return rettype,retval
end

function KS(enemy)
				if QREADY and getDmg("Q", enemy, myHero) > enemy.health then 
							if GetDistance(enemy) <= Qrange then 
									CastSpell(_Q, enemy)
									end
				end
		end
end
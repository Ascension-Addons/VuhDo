
VUHDO_MANUAL_ROLES = { };
local VUHDO_FIX_ROLES = { };
local VUHDO_INSPECTED_ROLES = { };
local VUHDO_DF_TOOL_ROLES = { };
local VUHDO_INSPECT_TIMEOUT = 5;

local tPoints1, tPoints2, tPoints3, tRank;
VUHDO_NEXT_INSPECT_UNIT = nil;
VUHDO_NEXT_INSPECT_TIME_OUT = nil;



--------------------------------------------------------------
local twipe = table.wipe;
local CheckInteractDistance = CheckInteractDistance;
local UnitIsUnit = UnitIsUnit;
local NotifyInspect = NotifyInspect;
local GetActiveTalentGroup = GetActiveTalentGroup;
local GetTalentTabInfo = GetTalentTabInfo;
local ClearInspectPlayer = ClearInspectPlayer;
local UnitBuff = UnitBuff;
local UnitStat = UnitStat;
local UnitDefense = UnitDefense;
local UnitGroupRolesAssigned = UnitGroupRolesAssigned;
local UnitLevel = UnitLevel;
local UnitPowerType = UnitPowerType;
local VUHDO_isUnitInModel;
local pairs = pairs;

local VUHDO_MANUAL_ROLES;
local VUHDO_RAID_NAMES;
local VUHDO_RAID;
--local sIsRolesConfigured;

function VUHDO_roleCheckerInitBurst()
	VUHDO_MANUAL_ROLES = VUHDO_GLOBAL["VUHDO_MANUAL_ROLES"];
	VUHDO_RAID_NAMES = VUHDO_GLOBAL["VUHDO_RAID_NAMES"];
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
--[[	sIsRolesConfigured =
		VUHDO_isModelConfigured(VUHDO_ID_MELEE_TANK)
		or VUHDO_isModelConfigured(VUHDO_ID_MELEE_DAMAGE)
		or VUHDO_isModelConfigured(VUHDO_ID_RANGED_DAMAGE)
		or VUHDO_isModelConfigured(VUHDO_ID_RANGED_HEAL)
		or VUHDO_isModelConfigured(VUHDO_ID_MELEE)
		or VUHDO_isModelConfigured(VUHDO_ID_RANGED)
		or VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_ROLE); ]]

		VUHDO_isUnitInModel = VUHDO_GLOBAL["VUHDO_isUnitInModel"];
end
--------------------------------------------------------------



-- Reset if spec changed or slash command
function VUHDO_resetTalentScan(aUnit)
	if (aUnit == nil) then
		twipe(VUHDO_INSPECTED_ROLES);
		twipe(VUHDO_FIX_ROLES);
	else
		if (VUHDO_PLAYER_RAID_ID == aUnit) then
			aUnit = "player";
		end

		local tInfo = VUHDO_RAID[aUnit];
		if (tInfo ~= nil) then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = nil;
			VUHDO_FIX_ROLES[tInfo["name"]] = nil;
		end
	end
end



--
local tName;
function VUHDO_trimInspected()
	for tName, _ in pairs(VUHDO_INSPECTED_ROLES) do
		if (VUHDO_RAID_NAMES[tName] == nil) then
			VUHDO_INSPECTED_ROLES[tName] = nil;
			VUHDO_FIX_ROLES[tName] = nil;
		end
	end
end



-- If timeout after talent tree server request
function VUHDO_setRoleUndefined(aUnit)
	local tInfo = VUHDO_RAID[aUnit];
	if (tInfo ~= nil) then
		VUHDO_INSPECTED_ROLES[tInfo["name"]] = nil;
	end
end



--
local tInfo;
local tClass, tName;
local function VUHDO_shouldBeInspected(aUnit)
	if ("focus" == aUnit or "target" == aUnit) then
		return false;
	end

	tInfo = VUHDO_RAID[aUnit];
	if (tInfo["isPet"] or not tInfo["connected"]) then
		return false;
	end
  -- Determined by role or can't tell by talent trees (dk)?
	tClass = tInfo["classId"];
	if (21 == tClass -- VUHDO_ID_ROGUES
		or 22 == tClass -- VUHDO_ID_HUNTERS
		or 24 == tClass -- VUHDO_ID_MAGES
		or 25 == tClass -- VUHDO_ID_WARLOCKS
		or 29 == tClass) then -- VUHDO_ID_DEATH_KNIGHT
		return false;
	end
  -- Already inspected or manually overridden?
  -- or assigned tank or heal via dungeon finder? (in case of DPS inspect anyway)
	tName = tInfo["name"];
	if (VUHDO_INSPECTED_ROLES[tName] ~= nil or VUHDO_MANUAL_ROLES[tName] ~= nil
		or VUHDO_DF_TOOL_ROLES[tName] == 60 or VUHDO_DF_TOOL_ROLES[tName] == 63) then -- VUHDO_ID_MELEE_TANK -- VUHDO_ID_RANGED_HEAL
		return false;
	end
  -- Too far away?
	if (not CheckInteractDistance(aUnit, 1)) then
		return false;
	end

	return true;
end



--
local tUnit;
function VUHDO_tryInspectNext()
	for tUnit, _ in pairs(VUHDO_RAID) do
		if (VUHDO_shouldBeInspected(tUnit)) then
			VUHDO_NEXT_INSPECT_TIME_OUT = GetTime() + VUHDO_INSPECT_TIMEOUT;
			VUHDO_NEXT_INSPECT_UNIT = tUnit;
			if ("player" == tUnit) then
				VUHDO_inspectLockRole();
			else
				NotifyInspect(tUnit);
			end

			return;
		end
	end
end



--
local tIcon1, tIcon2, tIcon3;
local tActiveTree;
local tIsInspect;
local tInfo;
local tClassId;
function VUHDO_inspectLockRole()
	tInfo = VUHDO_RAID[VUHDO_NEXT_INSPECT_UNIT];

	if (tInfo == nil) then
		VUHDO_NEXT_INSPECT_UNIT = nil;
		return;
	end

	tIsInspect = "player" ~= VUHDO_NEXT_INSPECT_UNIT;

	tActiveTree = GetActiveTalentGroup(tIsInspect);
	_, tIcon1, tPoints1, _ = GetTalentTabInfo(1, tIsInspect, false, tActiveTree); -- TODO: Add Ascension talents here
	_, tIcon2, tPoints2, _ = GetTalentTabInfo(2, tIsInspect, false, tActiveTree);
	_, tIcon3, tPoints3, _ = GetTalentTabInfo(3, tIsInspect, false, tActiveTree);

	tClassId = tInfo["classId"];

	if (VUHDO_ID_PRIESTS == tClassId) then
		-- 1 = Disc, 2 = Holy, 3 = Shadow
		if (tPoints1 > tPoints3
		or tPoints2 > tPoints3)	 then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 63; -- VUHDO_ID_RANGED_HEAL
		else
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 62; -- VUHDO_ID_RANGED_DAMAGE
		end

	elseif (VUHDO_ID_WARRIORS == tClassId) then
		-- 1 = Waffen, 2 = Furor, 3 = Schutz
		if (tPoints1 > tPoints3
		or tPoints2 > tPoints3)	 then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 61; -- VUHDO_ID_MELEE_DAMAGE
		else
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 60; -- VUHDO_ID_MELEE_TANK
		end

	elseif (VUHDO_ID_DRUIDS == tClassId) then
		-- 1 = Gleichgewicht, 2 = Wilder Kampf, 3 = Wiederherstellung
		if (tPoints1 > tPoints2 and tPoints1 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 62; -- VUHDO_ID_RANGED_DAMAGE
		elseif(tPoints3 > tPoints2) then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 63; -- VUHDO_ID_RANGED_HEAL
		else
			-- "Nat�rliche Reaktion" geskillt => Wahrsch. Tank?
			_, _, _, _, tRank, _, _, _ = GetTalentInfo(2, 16, tIsInspect, false, tActiveTree);
			if (tRank > 0) then
				VUHDO_INSPECTED_ROLES[tInfo.name] = 60; -- VUHDO_ID_MELEE_TANK
			else
				VUHDO_INSPECTED_ROLES[tInfo.name] = 61; -- VUHDO_ID_MELEE_DAMAGE
			end
		end

	elseif (VUHDO_ID_PALADINS == tClassId) then
		-- 1 = Heilig, 2 = Schutz, 3 = Vergeltung
		if (tPoints1 > tPoints2 and tPoints1 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 63; -- VUHDO_ID_RANGED_HEAL
		elseif (tPoints2 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 60; -- VUHDO_ID_MELEE_TANK
		else
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 61; -- VUHDO_ID_MELEE_DAMAGE
		end
		
	elseif (VUHDO_ID_SHAMANS == tClassId) then
		-- 1 = Elementar, 2 = Verst�rker, 3 = Wiederherstellung
		if (tPoints1 > tPoints2 and tPoints1 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 62; -- VUHDO_ID_RANGED_DAMAGE
		elseif (tPoints2 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 61; -- VUHDO_ID_MELEE_DAMAGE
		else
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 63; -- VUHDO_ID_RANGED_HEAL
		end

	elseif (VUHDO_ID_HERO == tClassId) then
		-- 1 = Heilig, 2 = Schutz, 3 = Vergeltung
		if (tPoints1 > tPoints2 and tPoints1 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 63; -- VUHDO_ID_RANGED_HEAL
		elseif (tPoints2 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 60; -- VUHDO_ID_MELEE_TANK
		else
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = 61; -- VUHDO_ID_MELEE_DAMAGE
		end
	end
	
	ClearInspectPlayer();
	VUHDO_NEXT_INSPECT_UNIT = nil;
--	if (sIsRolesConfigured) then
		VUHDO_normalRaidReload();
--[[	else
		VUHDO_refreshRaidMembers();
	end]]
end



--
local tIsTank, tIsHeal, tIsDps;
local function VUHDO_determineDfToolRole(anInfo)
  tIsTank, tIsHeal, tIsDps = UnitGroupRolesAssigned(anInfo["unit"]);

  if (tIsTank) then
  	VUHDO_DF_TOOL_ROLES[anInfo["name"]] = 60; -- VUHDO_ID_MELEE_TANK
  	return 60; -- VUHDO_ID_MELEE_TANK
  elseif (tIsHeal) then
  	VUHDO_DF_TOOL_ROLES[anInfo["name"]] = 63; -- VUHDO_ID_RANGED_HEAL
  	return 63; -- VUHDO_ID_RANGED_HEAL
  elseif (tIsDps) then
  	VUHDO_DF_TOOL_ROLES[anInfo["name"]] = 61; -- VUHDO_ID_MELEE_DAMAGE
  	-- Do return "nil", cause we don't know if melee or ranged dps, mark as indicator
  end

  return nil;
end



--
local tName;
local tInfo;
local tDefense;
local tPowerType;
local tBuffExist;
local tFixRole;
local tIntellect, tStrength, tAgility;
local tClassId, tName;
function VUHDO_determineRole(aUnit)
	tInfo = VUHDO_RAID[aUnit];

	if (tInfo == nil or tInfo["isPet"]) then
		return nil;
	end

	-- tClassId = tInfo["classId"];

--   -- Role determined by non-hybrid class?
-- 	if (21 == tClassId) then -- VUHDO_ID_ROGUES
-- 		return 61; -- VUHDO_ID_MELEE_DAMAGE
-- 	elseif (22 == tClassId) then -- VUHDO_ID_HUNTERS
-- 		return 62; -- VUHDO_ID_RANGED_DAMAGE
-- 	elseif (24 == tClassId) then -- VUHDO_ID_MAGES
-- 		return 62; -- VUHDO_ID_RANGED_DAMAGE
-- 	elseif (25 == tClassId) then -- VUHDO_ID_WARLOCKS
-- 		return 62; -- VUHDO_ID_RANGED_DAMAGE
-- 	end

	tName = tInfo["name"];
	-- Manual role override oder dungeon finder role?
	tFixRole = VUHDO_MANUAL_ROLES[tName] or VUHDO_determineDfToolRole(tInfo);
	if (tFixRole ~= nil) then
		return tFixRole;
	end
	-- Assigned for MT?
 	if (VUHDO_isUnitInModel(aUnit, 41)) then -- VUHDO_ID_MAINTANKS
		return 60; -- VUHDO_ID_MELEE_TANK
 	end
	-- -- Talent tree inspected?
	-- if (VUHDO_INSPECTED_ROLES[tName] ~= nil) then
	-- 	return VUHDO_INSPECTED_ROLES[tName];
	-- end
  -- Estimated role fixed?
  	local _, tDefense = UnitDefense(aUnit);
	local _, _, tBuffExist_RF = UnitBuff(aUnit, VUHDO_SPELL_ID_BUFF_RIGHTEOUS_FURY);
	local _, _, tBuffExist_AotM = UnitBuff(aUnit, VUHDO_SPELL_ID_BUFF_ASPECT_OF_THE_MONKEY);
	local _, _, tBuffExist_BF = UnitBuff(aUnit, VUHDO_SPELL_ID_BUFF_BEAR_FORM);
	local _, _, tBuffExist_DBF = UnitBuff(aUnit, VUHDO_SPELL_ID_BUFF_DIRE_BEAR_FORM);
	local _, _, tBuffExist_ToL = UnitBuff(aUnit, VUHDO_SPELL_ID_TREE_OF_LIFE);
	local _, _, tBuffExist_SF = UnitBuff(aUnit, VUHDO_SPELL_ID_SHADOWFORM);
	local _, _, tBuffExist_MKF = UnitBuff(aUnit, VUHDO_SPELL_ID_MOONKIN_FORM);
	local _, _, tBuffExist_AotH = UnitBuff(aUnit, VUHDO_SPELL_ID_BUFF_ASPECT_OF_THE_HAWK);
	local _, _, tBuffExist_CC = UnitBuff(aUnit, VUHDO_SPELL_ID_BUFF_CRIMSON_CHAMPION);
	local _, _, tBuffExist_MFB = UnitBuff(aUnit, VUHDO_SPELL_ID_BUFF_MANAFORGED_BARRIER);

	if (VUHDO_FIX_ROLES[tName] ~= nil) then -- TODO: Add Ascension talent check here
		return VUHDO_FIX_ROLES[tName];
	elseif (tBuffExist_RF or tBuffExist_AotM or tBuffExist_BF or tBuffExist_DBF or tBuffExist_CC or tDefense>20 or tBuffExist_MFB) then
		VUHDO_FIX_ROLES[tName] = 60; -- VUHDO_ID_MELEE_TANK
		return 60; -- VUHDO_ID_MELEE_TANK
	elseif (tBuffExist_ToL) then
		VUHDO_FIX_ROLES[tName] = 63; -- VUHDO_ID_RANGED_HEAL
		return 63;
	elseif (tBuffExist_SF or tBuffExist_MKF or tBuffExist_AotH) then
		VUHDO_FIX_ROLES[tName] = 62; -- VUHDO_ID_RANGED_DAMAGE
		return 62;
	else
		VUHDO_FIX_ROLES[tName] = 61; -- VUHDO_ID_MELEE_DAMAGE
		return 61;
	end


	-- if (29 == tClassId) then -- VUHDO_ID_DEATH_KNIGHT
	-- 	_, _, tBuffExist = UnitBuff(aUnit, VUHDO_SPELL_ID_BUFF_FROST_PRESENCE);
	-- 	if (tBuffExist) then
	-- 		VUHDO_FIX_ROLES[tName] = 60; -- VUHDO_ID_MELEE_TANK
	-- 		return 60; -- VUHDO_ID_MELEE_TANK
	-- 	else
	-- 		VUHDO_FIX_ROLES[tName] = 61; -- VUHDO_ID_MELEE_DAMAGE
	-- 		return 61; -- VUHDO_ID_MELEE_DAMAGE
	-- 	end

	-- elseif (28 == tClassId) then -- VUHDO_ID_PRIESTS
	-- 	_, _, tBuffExist = UnitBuff(aUnit, VUHDO_SPELL_ID_SHADOWFORM);
	-- 	if (tBuffExist) then
	-- 		VUHDO_FIX_ROLES[tName] = 62; -- VUHDO_ID_RANGED_DAMAGE
	-- 		return 62; -- VUHDO_ID_RANGED_DAMAGE
	-- 	else
	-- 		return 63; -- VUHDO_ID_RANGED_HEAL
	-- 	end

	-- elseif (20 == tClassId) then -- VUHDO_ID_WARRIORS
	-- 	_, tDefense = UnitDefense(aUnit);
	-- 	tDefense = tDefense / UnitLevel(aUnit);

	-- 	if (tDefense > 2 or VUHDO_isUnitInModel(aUnit, VUHDO_ID_MAINTANKS)) then
	-- 		return 60; -- VUHDO_ID_MELEE_TANK
	-- 	else
	-- 		return 61; -- VUHDO_ID_MELEE_DAMAGE
	-- 	end

	-- elseif (27 == tClassId) then -- VUHDO_ID_DRUIDS
	-- 	tPowerType = UnitPowerType(aUnit);
	-- 	if (VUHDO_UNIT_POWER_MANA == tPowerType) then
	-- 		_, _, tBuffExist = UnitBuff(aUnit, VUHDO_SPELL_ID_MOONKIN_FORM);
	-- 		if (tBuffExist) then
	-- 			VUHDO_FIX_ROLES[tName] = 62; -- VUHDO_ID_RANGED_DAMAGE
	-- 			return 62; -- VUHDO_ID_RANGED_DAMAGE
	-- 		else
	-- 			_, _, tBuffExist = UnitBuff(aUnit, VUHDO_SPELL_ID_TREE_OF_LIFE);
	-- 			if (tBuffExist) then
	-- 				VUHDO_FIX_ROLES[tName] = 63; -- VUHDO_ID_RANGED_HEAL
	-- 			end

	-- 			return 63; -- VUHDO_ID_RANGED_HEAL
	-- 		end
	-- 	elseif (VUHDO_UNIT_POWER_RAGE == tPowerType) then
	-- 		VUHDO_FIX_ROLES[tName] = 60; -- VUHDO_ID_MELEE_TANK
	-- 		return 60; -- VUHDO_ID_MELEE_TANK
	-- 	elseif (VUHDO_UNIT_POWER_ENERGY == tPowerType) then
	-- 		VUHDO_FIX_ROLES[tName] = 61; -- VUHDO_ID_MELEE_DAMAGE
	-- 		return 61; -- VUHDO_ID_MELEE_DAMAGE
	-- 	end

	-- elseif (23 == tClassId) then -- VUHDO_ID_PALADINS
	-- 	_, tDefense = UnitDefense(aUnit);
	-- 	tDefense = tDefense / UnitLevel(aUnit);

	-- 	if (tDefense > 2) then
	-- 		return 60; -- VUHDO_ID_MELEE_TANK
	-- 	else
	-- 		tIntellect = UnitStat(aUnit, 4);
	-- 		tStrength = UnitStat(aUnit, 1);

	-- 		if (tIntellect > tStrength) then
	-- 			return 63; -- VUHDO_ID_RANGED_HEAL
	-- 		else
	-- 			return 61; -- VUHDO_ID_MELEE_DAMAGE
	-- 		end
	-- 	end

	-- elseif (26 == tClassId) then -- VUHDO_ID_SHAMANS
	-- 	tIntellect = UnitStat(aUnit, 4);
	-- 	tAgility = UnitStat(aUnit, 2);

	-- 	if (tAgility > tIntellect) then
	-- 		return 61; -- VUHDO_ID_MELEE_DAMAGE
	-- 	else
	-- 		if (VUHDO_DF_TOOL_ROLES[tName] == 61) then -- VUHDO_ID_MELEE_DAMAGE
	-- 			return 62; -- VUHDO_ID_RANGED_DAMAGE
	-- 		else
	-- 			return 63; -- Can't tell, assume its a healer -- VUHDO_ID_RANGED_HEAL
	-- 		end
	-- 	end
	-- end

	return nil;
end

--- COA W.I.P. ---
local COA_ROLE_BY_SPEC = {}
local COA_ROLE_BY_CLASS = {}

-- PURE ROLE CLASSES
COA_ROLE_BY_CLASS[VUHDO_ID_NECROMANCER] =	VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_CLASS[VUHDO_ID_RANGER] =		VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_CLASS[VUHDO_ID_STORMBRINGER] =	VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_CLASS[VUHDO_ID_PYROMANCER] =	VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_CLASS[VUHDO_ID_BARBARIAN] =		VUHDO_ID_MELEE_DAMAGE

-- HYBRID CLASSES
COA_ROLE_BY_CLASS[VUHDO_ID_WITCHHUNTER] =	VUHDO_ID_TYPE_SPECIAL -- DONE
COA_ROLE_BY_CLASS[VUHDO_ID_STARCALLER] =	VUHDO_ID_TYPE_SPECIAL -- DONE
COA_ROLE_BY_CLASS[VUHDO_ID_SPIRITMAGE] =	VUHDO_ID_TYPE_SPECIAL -- DONE
COA_ROLE_BY_CLASS[VUHDO_ID_CULTIST] =		VUHDO_ID_TYPE_SPECIAL
COA_ROLE_BY_CLASS[VUHDO_ID_TINKER] =		VUHDO_ID_TYPE_SPECIAL -- DONE
COA_ROLE_BY_CLASS[VUHDO_ID_SUNCLERIC] =		VUHDO_ID_TYPE_SPECIAL
COA_ROLE_BY_CLASS[VUHDO_ID_WILDWALKER] =	VUHDO_ID_TYPE_SPECIAL -- DONE
COA_ROLE_BY_CLASS[VUHDO_ID_CHRONOMANCER] =	VUHDO_ID_TYPE_SPECIAL
COA_ROLE_BY_CLASS[VUHDO_ID_PROPHET] =		VUHDO_ID_TYPE_SPECIAL -- DONE
COA_ROLE_BY_CLASS[VUHDO_ID_FLESHWARDEN] =	VUHDO_ID_TYPE_SPECIAL
COA_ROLE_BY_CLASS[VUHDO_ID_SONOFARUGAL] =	VUHDO_ID_TYPE_SPECIAL -- DONE
COA_ROLE_BY_CLASS[VUHDO_ID_REAPER] =		VUHDO_ID_TYPE_SPECIAL -- DONE
COA_ROLE_BY_CLASS[VUHDO_ID_GUARDIAN] =		VUHDO_ID_TYPE_SPECIAL
COA_ROLE_BY_CLASS[VUHDO_ID_MONK] =			VUHDO_ID_TYPE_SPECIAL -- DONE
COA_ROLE_BY_CLASS[VUHDO_ID_WITCHDOCTOR] =	VUHDO_ID_TYPE_SPECIAL
COA_ROLE_BY_CLASS[VUHDO_ID_DEMONHUNTER] =	VUHDO_ID_TYPE_SPECIAL

-- PRIMALIST
COA_ROLE_BY_SPEC["GEOMANCY"] = VUHDO_ID_TYPE_SPECIAL -- HYBRID BY TALENTS
COA_ROLE_BY_SPEC["PRIMAL"] = VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_SPEC["LIFE"] = VUHDO_ID_RANGED_HEAL

-- SON OF ARUGAL
COA_ROLE_BY_SPEC["PACKLEADER"] = VUHDO_ID_MELEE_TANK
COA_ROLE_BY_SPEC["BLOOD"] = VUHDO_ID_TYPE_SPECIAL	-- HYBRID BY TALENTS
COA_ROLE_BY_SPEC["FEROCITY"] = VUHDO_ID_MELEE_DAMAGE

-- STARCALLER
COA_ROLE_BY_SPEC["ASTRALWARFARE"] = VUHDO_ID_TYPE_SPECIAL -- HYBRID BY TALENTS
COA_ROLE_BY_SPEC["TIDES"] = VUHDO_ID_RANGED_HEAL
COA_ROLE_BY_SPEC["MOONBOW"] = VUHDO_ID_TYPE_SPECIAL -- HYBRID BY TALENTS

-- TINKER
COA_ROLE_BY_SPEC["MECHANICS"] = VUHDO_ID_MELEE_TANK -- or VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_SPEC["INVENTION"] = VUHDO_ID_RANGED_HEAL
COA_ROLE_BY_SPEC["FIREARMS"] = VUHDO_ID_MELEE_DAMAGE

-- VENOMANCER

COA_ROLE_BY_SPEC["FORTITUDE"] = VUHDO_ID_TYPE_SPECIAL -- HYBRID BY TALENT 704264 -- DONE
COA_ROLE_BY_SPEC["VENOM"] = VUHDO_ID_TYPE_SPECIAL -- HYBRID BY TALENT 804980 -- DONE
COA_ROLE_BY_SPEC["STALKING"] = VUHDO_ID_MELEE_DAMAGE

-- MONK 
COA_ROLE_BY_SPEC["DISCIPLINE"] = VUHDO_ID_MELEE_TANK
COA_ROLE_BY_SPEC["FIGHTING"] = VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_SPEC["RUNES"] = VUHDO_ID_MELEE_DAMAGE
-- WITCH HUNTER
COA_ROLE_BY_SPEC["BOLTSLINGER"] = VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_SPEC["DARKNESS"] = VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_SPEC["INQUISITION"] = VUHDO_ID_MELEE_TANK

-- REAPER
COA_ROLE_BY_SPEC["DOMINATION"] = VUHDO_ID_MELEE_TANK
COA_ROLE_BY_SPEC["SOUL"] = VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_SPEC["REAPING"] = VUHDO_ID_MELEE_DAMAGE

-- SPIRITMAGE (RUNEMASTER)
COA_ROLE_BY_SPEC["RIFTBLADE"] = VUHDO_ID_TYPE_SPECIAL -- HYBRID BY STANCE
COA_ROLE_BY_SPEC["ARCANE"] = VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_SPEC["RUNIC"] = VUHDO_ID_MELEE_DAMAGE

-- CHRONOMANCER
COA_ROLE_BY_SPEC["DUALITY"] = VUHDO_ID_RANGED_HEAL
COA_ROLE_BY_SPEC["TIME"] = VUHDO_ID_MELEE_DAMAGE
COA_ROLE_BY_SPEC["DISPLACEMENT"] = VUHDO_ID_MELEE_TANK





local function CoA_GetTalentList()
	local TALENTS_LIST ={}
	for i=1,#SpellKitAdvanced.BuildSelectMenu.cards do
		local tab = _G["SpellKitAdvanced.spellTree.tab"..i]
		for tier,tier_data in pairs(tab.specData.Tiers) do
			for node, node_data in pairs(tier_data) do
				if node_data then
					local CA_ID = node_data.ID
					local spell_ID = CA_GetIDInfo(CA_ID).Spells
					local name,_ = GetSpellInfo(spell_ID)
					TALENTS_LIST[spell_ID] = {}
					TALENTS_LIST[spell_ID]["name"] = name
					TALENTS_LIST[spell_ID]["isKnown"] = IsSpellKnown(spell_ID)
				end
			end
		end
	end
	return TALENTS_LIST
end


local function CoA_Determine_Role_By_Talents(anInfo)
	-- LOGIC FOR PLAYER INSPECTION
	if anInfo["unit"] == "player" and SpellKitAdvanced.BuildSelectMenu.currentSpec then

		local primarySpec = CA_GetIDInfo(SpellKitAdvanced.BuildSelectMenu.currentSpec).Tab
		local talents = CoA_GetTalentList()
		local class = anInfo["classId"]

		if class == VUHDO_ID_PROPHET then
			if primarySpec == "FORTITUDE" then
				if CoA_GetTalentList()[704264]["isKnown"] then
					VUHDO_DF_TOOL_ROLES[anInfo["name"]] = VUHDO_ID_MELEE_DAMAGE
					return VUHDO_ID_MELEE_DAMAGE
				else
					VUHDO_DF_TOOL_ROLES[anInfo["name"]] = VUHDO_ID_MELEE_TANK
					return VUHDO_ID_MELEE_TANK
				end
			elseif primarySpec == "VENOM" then
				if CoA_GetTalentList()[804980]["isKnown"] then
					VUHDO_DF_TOOL_ROLES[anInfo["name"]] = VUHDO_ID_MELEE_DAMAGE
					return VUHDO_ID_MELEE_DAMAGE
				else
					VUHDO_DF_TOOL_ROLES[anInfo["name"]] = VUHDO_ID_RANGED_HEAL
					return VUHDO_ID_RANGED_HEAL
				end
			end
		end

		if class == VUHDO_ID_WILDWALKER then
			if primarySpec == "GEOMANCY" then
				-- BODY OF STONE + MOUNTAIN MOVER + EARTHEN AEGIS													
				if IsSpellKnown(803975) and ( CoA_GetTalentList()[805643]["isKnown"] or CoA_GetTalentList()[805634]["isKnown"])	then
					VUHDO_DF_TOOL_ROLES[anInfo["name"]] = VUHDO_ID_MELEE_TANK
					return VUHDO_ID_MELEE_TANK
				else
					VUHDO_DF_TOOL_ROLES[anInfo["name"]] = VUHDO_ID_MELEE_DAMAGE
					return VUHDO_ID_MELEE_DAMAGE
				end
			end
		end
	else
		-- LOGIC FOR UNIT INSPECTION ( NOT YET IMPLEMENTED BY ASCENSION )
	end
end

local function CoA_Determine_Role_By_Specialization(anInfo)
	local activeSpec
	if SpellKitAdvanced.BuildSelectMenu.currentSpec then
		activeSpec = CA_GetIDInfo(SpellKitAdvanced.BuildSelectMenu.currentSpec).Tab

		if COA_ROLE_BY_SPEC[activeSpec] == nil then
			CA_debug_from("CoA_RoleDeterminator","Specialization "..activeSpec.." is Unknown","ce7e00")
		elseif COA_ROLE_BY_SPEC[activeSpec] == VUHDO_ID_TYPE_SPECIAL then
				CA_debug_from("CoA_RoleDeterminator","Specialization "..activeSpec.." requires talent check.","ce7e00")
		else
			VUHDO_DF_TOOL_ROLES[anInfo["name"]] = COA_ROLE_BY_SPEC[activeSpec]
			return COA_ROLE_BY_SPEC[activeSpec]
		end
	else
		CA_debug_from("CoA_RoleDeterminator","Player has not selected a Primary Specialization","ce7e00")
	end

end

local function CoA_Determine_Role_By_Class(anInfo)
	local uniClass = anInfo["classId"]

	-- CA_debug_from("CoA_RoleDeterminator","Checking "..VUHDO_ID_CLASSES[uniClass],"ce7e00")
	if COA_ROLE_BY_CLASS[uniClass] == nil then
			CA_debug_from("CoA_RoleDeterminator","Class "..VUHDO_ID_CLASSES[uniClass].. " is Unknown","ce7e00")
	elseif COA_ROLE_BY_CLASS[uniClass] == VUHDO_ID_TYPE_SPECIAL then
			CA_debug_from("CoA_RoleDeterminator","Class "..VUHDO_ID_CLASSES[uniClass].. " requires specialization check.","ce7e00")
	else
		VUHDO_DF_TOOL_ROLES[anInfo["name"]] = COA_ROLE_BY_CLASS[uniClass]
		return COA_ROLE_BY_CLASS[uniClass]
	end
end

function CoA_Determine_Role(anInfo)
	if not IsCustomClass(anInfo["unit"]) then return end

	local results = (CoA_Determine_Role_By_Class(anInfo) or CoA_Determine_Role_By_Specialization(anInfo) or CoA_Determine_Role_By_Talents(anInfo))


	if tostring((results and results>=60) or false) then
		CA_debug_from("CoA_RoleDeterminator","Valid Role Found","ce7e00")
	else
		CA_debug_from("CoA_RoleDeterminator","Valid Role Not Found","ce7e00")
	end
	return results
end






----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Taerar", "Ashenvale")

module.revision = 20008 -- To be overridden by the module!
module.enabletrigger = module.translatedName -- string or table {boss, add1, add2}
module.toggleoptions = {"noxious", "fear", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Ashenvale"],
	AceLibrary("Babble-Zone-2.2")["Duskwood"],
	AceLibrary("Babble-Zone-2.2")["The Hinterlands"],
	AceLibrary("Babble-Zone-2.2")["Feralas"]
}

---------------------------------
--      Module specific Locals --
---------------------------------

local timer = {
	firstBreath = 7,
	breath = 9,
	banish = 120,
	firstFear = 27,
	fear = 25,
}
local icon = {
	breath = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
	fear = "Interface\\Icons\\Spell_Shadow_PsychicScream",
	banish = "Interface\\Icons\\Spell_Nature_Sleep",
}
local syncName = {
}

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Taerar",

	noxious_cmd = "noxious",
	noxious_name = "Noxious breath alert",
	noxious_desc = "Warn for noxious breath",

	fear_cmd = "fear",
	fear_name = "Fear",
	fear_desc = "Warn for Bellowing Roar",

	fear_trigger = "Taerar begins to cast Bellowing Roar.",
	breath_trigger = "afflicted by Noxious Breath",
	engage_trigger = "Peace is but a fleeting dream! Let the NIGHTMARE reign!",
	shades_trigger = "Children of Madness - I release you upon this world!",

	shades_warn = "Taerar banished! Kill Shades!",
	fearCast_warn = "Fear in 1.5sec!",
	breathSoon_warn = "Noxious Breath soon!",
	breath_warn = "Noxious Breath!",
	fear_warn = "AoE Fear soon!",

	breath_bar = "Noxious Breath",
	banish_bar = "Banish",
	fear_bar = "AoE Fear",

} end )

------------------------------
--      Initialization      --
------------------------------

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
end

-- called after module is enabled and after each wipe
function module:OnSetup()
end

-- called after boss is engaged
function module:OnEngage()
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end

------------------------------
--      Event Handlers      --
------------------------------

function module:Event( msg )
	if string.find(msg, L["breath_trigger"]) then
		if self.db.profile.noxious then 
			self:Message(L["breath_warn"], "Important")
			self:CancelDelayedMessage(L["breathSoon_warn"])
			self:DelayedMessage(timer.breath-3, L["breathSoon_warn"], "Important", true, "Alert")
			self:RemoveBar(L["breath_bar"])
			self:Bar(L["breath_bar"], timer.breath, icon.breath)
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L["engage_trigger"]) then
		if self.db.profile.noxious then
			self:CancelDelayedMessage(L["breathSoon_warn"])
			self:DelayedMessage(timer.firstBreath-3, L["breathSoon_warn"], "Important", true, "Alert")
			self:RemoveBar(L["breath_bar"])
			self:Bar(L["breath_bar"], timer.firstBreath, icon.breath)
		end
		if self.db.profile.fear then
			self:CancelDelayedMessage(L["fear_warn"])
			self:DelayedMessage(timer.firstFear-3, L["fear_warn"], "Important", true, "Alert")
			self:RemoveBar(L["fear_bar"])
			self:Bar(L["fear_bar"], timer.firstFear, icon.fear)
		end
	elseif (string.find(msg, L["shades_trigger"])) then
		 self:Message(L["shades_warn"], "Important")
		 self:RemoveBar(L["banish_bar"])
		 self:Bar(L["banish_bar"], timer.banish, icon.banish)
	end
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if msg == L["fear_trigger"] and self.db.profile.fear then
		self:Message(L["fearCast_warn"], "Important", "Alert")
		self:CancelDelayedMessage(L["fear_warn"])
		self:DelayedMessage(timer.fear-3, L["fear_warn"], "Important", true, "Alert")
		self:RemoveBar(L["fear_bar"])
		self:Bar(L["fear_bar"], timer.fear, icon.fear)
	end
end

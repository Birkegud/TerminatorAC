Term = {}

Term.MainWebhook = "https://canary.discord.com/api/webhooks/807299569331339354/KWwmwTBa05OGBpTkmH8ybMoJrLOCrmYC7MAX8KhJ1SGwGTO-OaU_FBDcdMmA-M3lORBf"

Term.BypassWebhook = "https://canary.discord.com/api/webhooks/807299569331339354/KWwmwTBa05OGBpTkmH8ybMoJrLOCrmYC7MAX8KhJ1SGwGTO-OaU_FBDcdMmA-M3lORBf"

-- Term.ServerName = GetConvar("sv_hostname", "")
Term.ServerName = "Dev Server"

Term.Version = "0.2"

Term.Color = "^6"

Term.BanReason = "Bye"

Term.DisguisedResource = true

--//Detections//--
Term.ResourceStopDetection = true

Term.RunCode = false

Term.TazeDetection = true

Term.ScramblerInjectionDetection = true

Term.PlankeCkDetection = true

Term.StaminaDetection = true

Term.GetResourceDetection = true

Term.GiveWeaponDetection = true

Term.RemoveWeaponDetection = true

Term.ClearPedTaskDetection = true

Term.SpawnPedsDetection = true

Term.NukeDetection = true

Term.SpawnVehiclesDetection = true

Term.AntiVPN = false

Term.ExplosionDetection = true

Term.ForceDiscord = false

Term.ExplosionsList = {
    [0] = "Grenade",
    [1] = "GrenadeLauncher",
    [2] = "C4",
    [3] = "Molotov",
    [4] = "Rocket",
    [5] = "TankShell",
    [6] = "Hi_Octane",
    -- [7] = "Car",
    [8] = "Plance",
    -- [9] = "PetrolPump",
    [10] = "Bike",
    -- [11] = "Dir_Steam",
    [12] = "Dir_Flame",
    -- [13] = "Dir_Water_Hydrant",
    -- [14] = "Dir_Gas_Canister",
    [15] = "Boat",
    [16] = "Ship_Destroy",
    -- [17] = "Truck",
    -- [18] = "Bullet",
    [19] = "SmokeGrenadeLauncher",
    [20] = "SmokeGrenade",
    [21] = "BZGAS",
    [22] = "Flare",
    [23] = "Gas_Canister",
    -- [24] = "Extinguisher",
    [25] = "Programmablear",
    [26] = "Train",
    -- [27] = "Barrel",
    -- [28] = "PROPANE",
    [29] = "Blimp",
    [30] = "Dir_Flame_Explode",
    [31] = "Tanker",
    [32] = "PlaneRocket",
    [33] = "VehicleBullet",
    -- [34] = "Gas_Tank",
    [35] = "FireWork",
    -- [36] = "SnowBall",
    [37] = "ProxMine",
    [38] = "Valkyrie_Cannon",
    [70] = "AutoMizer"
}

Term.BlacklistedVehicles = {
	"cargoplane",
	"cerberus",
	"cerberus2",
	"cerberus3",
	"hauler2",
	"phantom2",
	"terbyte",
	"issi4",
	"issi5",
	"issi6",
	"akula",
	"annihilator",
	"buzzard",
	"hunter",
	"savage",
	"apc",
	"barrage",
	"chernobog",
	"halftrack",
	"khanjali",
	"minitank",
	"rhino",
	"scarab",
	"scarab2",
	"scarab3",
	"thruster",
	"trailersmall2",
	"oppressor",
	"oppressor2",
	"dominator4",
	"dominator5",
	"dominator6",
	"dukes2",
	"impaler2",
	"impaler3",
	"impaler4",
	"imperator",
	"imperator2",
	"imperator3",
	"bruiser",
	"bruiser2",
	"bruiser3",
	"brutus",
	"brutus2",
	"brutus3",
	"caracara",
	"dune4",
	"dune5",
	"insurgent",
	"insurgent3",
	"menacer",
	"nightshark",
	"technical",
	"technical2",
	"technical3",
	"zhaba",
	"avenger",
	"avenger2",
	"besra",
	"blimp",
	"blimp2",
	"blimp3",
	"jet",
	"hydra",
	"strikeforce",
	"titan",
	"volatol",
	"limo2",
	"zr380",
	"zr3802",
	"zr3803",
	"deluxo",
	"vigilante",
	"boxville5",
	"kuruma2",
	"scramjet",
}

Term.NukeBlacklistedPeds = {
    "a_m_m_acult_01",
    "a_m_y_acult_02",
    "a_m_o_acult_01",
    "a_m_y_acult_01",
    "u_m_y_juggernaut_01",
    "u_f_m_drowned_01",
    "s_m_y_swat_01",
    "a_c_sharktiger",
    "a_c_chimp",
    "a_c_humpback",
    "a_c_rhesus",
    "u_m_y_zombie_01",
    "ig_wade",
    "s_m_m_paramedic_01",
    "s_m_y_fireman_01"
}

Term.NukeBlacklistedObjects = {
    "p_crahsed_heli_s",
	"prop_rock_4_big2",
	"prop_beachflag_le",
	"prop_fnclink_05crnr1",
	"xm_prop_x17_sub",
	"xs_prop_hamburgher_wl",
	"xs_prop_plastic_bottle_wl",
	"prop_windmill_01",
	"prop_windmill_01_I1",
	"prop_windmill_01_slod",
	"prop_windmill_01_slod2",
	"p_spinning_anus_s",
	"stt_prop_ramp_adj_flip_m",
	"stt_prop_ramp_adj_flip_mb",
	"stt_prop_ramp_adj_flip_s",
	"stt_prop_ramp_adj_flip_sb",
	"stt_prop_ramp_adj_hloop",
	"stt_prop_ramp_adj_loop",
	"stt_prop_ramp_jump_l",
	"stt_prop_ramp_jump_m",
	"stt_prop_ramp_jump_s",
	"stt_prop_ramp_jump_xl",
	"stt_prop_ramp_jump_xs",
	"stt_prop_ramp_jump_xxl",
	"stt_prop_ramp_multi_loop_rb",
	"stt_prop_ramp_spiral_l",
	"stt_prop_stunt_soccer_ball",
	"stt_prop_ramp_spiral_l_l",
	"stt_prop_ramp_spiral_l_m",
	"stt_prop_ramp_spiral_l_s",
	"stt_prop_ramp_spiral_l_xxl",
	"stt_prop_ramp_spiral_m",
	"stt_prop_ramp_spiral_s",
	"stt_prop_ramp_spiral_xxl",
	"prop_container_01a",
	"stt_prop_stunt_domino",
	"stt_prop_stunt_jump15",
	"stt_prop_stunt_jump30",
	"stt_prop_stunt_jump45",
	"stt_prop_stunt_jump_l",
	"stt_prop_stunt_jump_lb",
	"stt_prop_stunt_jump_loop",
	"stt_prop_stunt_jump_m",
	"stt_prop_stunt_jump_mb",
	"stt_prop_stunt_jump_s",
	"stt_prop_stunt_jump_sb",
	"stt_prop_stunt_landing_zone_01",
	"stt_prop_stunt_ramp",
	"stt_prop_stunt_soccer_goal",
	"stt_prop_stunt_soccer_lball",
	"stt_prop_stunt_soccer_sball",
	"stt_prop_stunt_target",
	"stt_prop_stunt_small",
	"stt_prop_stunt_track_start",
	"stt_prop_stunt_track_slope45",
	"stt_prop_stunt_track_slope30",
	"stt_prop_stunt_track_slope15",
	"stt_prop_stunt_track_short",
	"stt_prop_stunt_track_dwuturn",
	"stt_prop_stunt_track_dwslope45",
	"stt_prop_stunt_track_funlng",
	"stt_prop_stunt_bowling_ball",
	"stt_prop_stunt_bowling_pin"
}

Term.GoldK1dsCrash = true
Term.GoldK1dsMessage = {
    'https',
    'discord',
    '/',
    'BØJ FOR G0LD K1DS SMÅ LORTE UNGER. SUT DIN EGEN MOR',
    'ø',
    'G0LD K1DS',
    'lavet',
    'SMÅ BØRN',
    'SUT PIK',
    'pik',
    'Av9Edvk',
    'ふりがな読み仮名濁点半濁点音読み, おんよみ訓読み',
    'SCRIPTERS',
    'OVERGIV',
    'SKIDDS',
    'LORTE UNGER'
}

Term.BlacklistedTriggers = {

}

Term.ForbiddenCrashes = {
	'gta-streaming-five.dll+4AE92',
	'citizen-scripting-lua.dll+3FA40B',
	'citizen-scripting-lua.dll+3FB324',
	'kernelbase.dll+3A799',
	'ntdll.dll+1E312',
	'ntdll.dll+FBF18',
}
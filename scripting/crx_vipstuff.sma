#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>

#define PLUGIN_NAME "VIP Extras"
#define PLUGIN_VERSION "2.2.1"
#define PLUGIN_AUTHOR "OciXCrom"

#define MODELS_PATH "models/player"
#define SOUND_MENU "items/gunpickup2.wav"

new flag_vip, flag_skin, wait, maxhealth, maxmoney, menu_enabled, menu_maxuses, menu_spawn
new get_health, get_armor, health_amount, armor_amount, get_deagle, he_amount, flash_amount, smoke_amount, get_transparency, transparency_amount
new get_m4a1, get_ak47, get_awp, get_g3sg1, get_sg550, menu_m4a1, menu_ak47, menu_awp, menu_g3sg1, menu_sg550
new menu_health, menu_armor, menu_deagle, menu_transparency, menu_speed, menu_gravity, menu_moredamage
new get_skin_t, get_skin_ct, skin_name_t, skin_name_ct, get_speed, speed_amount, get_gravity, gravity_amount, get_moredamage, moredamage_multiplier
new killbonus_health_normal, killbonus_health_headshot, killbonus_money_normal, killbonus_money_headshot
new skin_t[32], skin_ct[32], menu_uses[33]
new bool:user_moredamage[33]

new bool:skin_t_active
new bool:skin_ct_active

new const szPrefix[] = "^4[^3VIP Extras^4]"

enum Color
{
	NORMAL = 1, // clients scr_concolor cvar color
	GREEN, // Green Color
	TEAM_COLOR, // Red, grey, blue
	GREY, // grey
	RED, // Red
	BLUE, // Blue
}

new TeamName[][] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_cvar("CustomVIPExtras", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1)
	RegisterHam(Ham_TakeDamage, "player", "player_damage")
	register_event("DeathMsg", "player_killed", "a")
	register_event("CurWeapon", "change_weapon", "be", "1=1")
	
	register_clcmd("say /vm", "vip_menu")
	register_clcmd("say_team /vm", "vip_menu")
	register_clcmd("say /vipmenu", "vip_menu")
	register_clcmd("say_team /vipmenu", "vip_menu")
	
	wait = register_cvar("ve_wait", "0.5")
	flag_vip = register_cvar("ve_vipflag", "o")
	flag_skin = register_cvar("ve_skinflag", "b")
	menu_enabled = register_cvar("ve_menu_enabled", "0")
	menu_maxuses = register_cvar("ve_menu_maxuses", "1")
	menu_spawn = register_cvar("ve_menu_spawn", "1")
	
	get_health = register_cvar("ve_get_health", "1")
	get_armor = register_cvar("ve_get_armor", "1")
	get_deagle = register_cvar("ve_get_deagle", "1")
	get_transparency = register_cvar("ve_get_transparency", "0")
	get_speed = register_cvar("ve_get_speed", "0")
	get_gravity = register_cvar("ve_get_gravity", "0")
	get_m4a1 = register_cvar("ve_get_m4a1", "0")
	get_ak47 = register_cvar("ve_get_ak47", "0")
	get_awp = register_cvar("ve_get_awp", "0")
	get_g3sg1 = register_cvar("ve_get_g3sg1", "0")
	get_sg550 = register_cvar("ve_get_sg550", "0")
	get_moredamage = register_cvar("ve_get_moredamage", "0")
	
	menu_health = register_cvar("ve_menu_health", "1")
	menu_armor = register_cvar("ve_menu_armor", "1")
	menu_deagle = register_cvar("ve_menu_deagle", "1")
	menu_transparency = register_cvar("ve_menu_transparency", "1")
	menu_speed = register_cvar("ve_menu_speed", "1")
	menu_gravity = register_cvar("ve_menu_gravity", "1")
	menu_m4a1 = register_cvar("ve_menu_m4a1", "1")
	menu_ak47 = register_cvar("ve_menu_ak47", "1")
	menu_awp = register_cvar("ve_menu_awp", "1")
	menu_g3sg1 = register_cvar("ve_menu_g3sg1", "1")
	menu_sg550 = register_cvar("ve_menu_sg550", "1")
	menu_moredamage = register_cvar("ve_menu_moredamage", "1")
	
	health_amount = register_cvar("ve_health_amount", "150")
	armor_amount = register_cvar("ve_armor_amount", "100")
	he_amount = register_cvar("ve_he_amount", "1")
	flash_amount = register_cvar("ve_flash_amount", "2")
	smoke_amount = register_cvar("ve_smoke_amount", "1")
	transparency_amount = register_cvar("ve_transparency_amount", "75")
	speed_amount = register_cvar("ve_speed_amount", "300.0")
	gravity_amount = register_cvar("ve_gravity_amount", "0.5")
	moredamage_multiplier = register_cvar("ve_moredamage_multiplier", "2")
	
	killbonus_health_normal = register_cvar("ve_killbonus_health_normal", "5")
	killbonus_health_headshot = register_cvar("ve_killbonus_health_headshot", "10")
	killbonus_money_normal = register_cvar("ve_killbonus_money_normal", "300")
	killbonus_money_headshot = register_cvar("ve_killbonus_money_headshot", "500")
	maxhealth = register_cvar("ve_max_health", "200")
	maxmoney = register_cvar("ve_max_money", "16000")
}

public change_weapon(id)
	if(user_has_flag(id, flag_vip) && get_pcvar_num(get_speed) == 1) set_user_maxspeed(id, get_pcvar_float(speed_amount))

public player_spawn(id)
{
	if(is_user_alive(id))
	{
		menu_uses[id] = 0
		user_moredamage[id] = false
		cs_reset_user_model(id)
		set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
		
		if(get_pcvar_num(menu_enabled) > 0 && get_pcvar_num(menu_spawn) == 1)
			vip_menu(id)
	}
	
	set_task(get_pcvar_float(wait), "vip_set", id)
}

public vip_set(id)
{
	if(!is_user_alive(id))
		return
	
	if(user_has_flag(id, flag_skin))
	{
		switch(get_user_team(id))
		{
			case 1: if(skin_t_active) cs_set_user_model(id, skin_t)
			case 2: if(skin_ct_active) cs_set_user_model(id, skin_ct)
		}
	}
	
	if(get_pcvar_num(menu_enabled) == 1)
		return
	
	if(user_has_flag(id, flag_vip))
	{
		if(get_pcvar_num(get_health) == 1)
			vip_equip(id, 0)
			
		if(get_pcvar_num(get_armor) == 1)
			vip_equip(id, 1)
		
		if(get_pcvar_num(get_deagle) == 1)
			vip_equip(id, 2)
			
		new he = get_pcvar_num(he_amount)
		new flash = get_pcvar_num(flash_amount)
		new smoke = get_pcvar_num(smoke_amount)
		
		if(he > 0)
			vip_equip(id, 3)
			
		if(flash > 0)
			vip_equip(id, 4)
		
		if(smoke > 0)
			vip_equip(id, 5)
		
		if(get_pcvar_num(get_transparency) == 1)
			vip_equip(id, 6)
		
		if(get_pcvar_num(get_speed) == 1)
			vip_equip(id, 7)
			
		if(get_pcvar_num(get_gravity) == 1)
			vip_equip(id, 8)
		
		if(get_pcvar_num(get_m4a1) == 1)
			vip_equip(id, 9)
		
		if(get_pcvar_num(get_ak47) == 1)
			vip_equip(id, 10)
			
		if(get_pcvar_num(get_awp) == 1)
			vip_equip(id, 11)
			
		if(get_pcvar_num(get_g3sg1) == 1)
			vip_equip(id, 12)
		
		if(get_pcvar_num(get_sg550) == 1)
			vip_equip(id, 13)
		
		if(get_pcvar_num(get_moredamage) == 1)
			vip_equip(id, 14)
	}
}

public vip_equip(id, item)
{
	switch(item)
	{
		case 0: set_user_health(id, get_pcvar_num(health_amount))
		case 1: set_user_armor(id, get_pcvar_num(armor_amount))
		case 2:
		{
			give_item(id, "weapon_deagle")
			cs_set_user_bpammo(id, CSW_DEAGLE, 35)
		}
		case 3:
		{
			give_item(id, "weapon_hegrenade")
			cs_set_user_bpammo(id, CSW_HEGRENADE, get_pcvar_num(he_amount))
		}
		case 4:
		{
			give_item(id, "weapon_flashbang")
			cs_set_user_bpammo(id, CSW_FLASHBANG, get_pcvar_num(flash_amount))
		}
		case 5:
		{
			give_item(id, "weapon_smokegrenade")
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, get_pcvar_num(smoke_amount))
		}
		case 6: set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_pcvar_num(transparency_amount))
		case 7: set_user_maxspeed(id, get_pcvar_float(speed_amount))
		case 8: set_user_gravity(id, get_pcvar_float(gravity_amount))
		case 9:
		{
			give_item(id, "weapon_m4a1")
			cs_set_user_bpammo(id, CSW_M4A1, 90)
		}
		case 10:
		{
			give_item(id, "weapon_ak47")
			cs_set_user_bpammo(id, CSW_AK47, 90)
		}
		case 11:
		{
			give_item(id, "weapon_awp")
			cs_set_user_bpammo(id, CSW_AWP, 30)
		}
		case 12:
		{
			give_item(id, "weapon_g3sg1")
			cs_set_user_bpammo(id, CSW_G3SG1, 90)
		}
		case 13:
		{
			give_item(id, "weapon_sg550")
			cs_set_user_bpammo(id, CSW_SG550, 90)
		}
		case 14:
			user_moredamage[id] = true
	}
}

public vip_menu(id)
{
	if(get_pcvar_num(menu_enabled) == 0)
	{
		ColorChat(id, TEAM_COLOR, "%s ^1The ^4VIP Menu ^1is currently ^3disabled^1.", szPrefix)
		return PLUGIN_HANDLED
	}
	
	if(!user_has_flag(id, flag_vip))
	{
		ColorChat(id, TEAM_COLOR, "%s ^1You have ^3no access ^1to this command.", szPrefix)
		return PLUGIN_HANDLED
	}
	
	if(!is_user_alive(id))
	{
		ColorChat(id, TEAM_COLOR, "%s ^1You need to be ^3alive^1!", szPrefix)
		return PLUGIN_HANDLED
	}
	
	if(menu_uses[id] == get_pcvar_num(menu_maxuses))
	{
		ColorChat(id, TEAM_COLOR, "%s ^1You can use the menu only ^4%i ^1time(s).", szPrefix, get_pcvar_num(menu_maxuses))
		return PLUGIN_HANDLED
	}
	
	new title[100], item[50]
	formatex(title, charsmax(title), "\yOciXCrom's \rCustom VIP Extras\d")
	
	new vipmenu = menu_create(title, "vipmenu_handler")
	
	if(get_pcvar_num(menu_health) == 1)
	{
		formatex(item, charsmax(item), "Health Points \y(+%i)", get_pcvar_num(health_amount))
		menu_additem(vipmenu, item, "0", 0)
	}
	
	if(get_pcvar_num(menu_armor) == 1)
	{
		formatex(item, charsmax(item), "Armor Points \y(+%i)", get_pcvar_num(armor_amount))
		menu_additem(vipmenu, item, "1", 0)
	}
	
	if(get_pcvar_num(menu_deagle) == 1)
	{
		formatex(item, charsmax(item), "Deagle \y(Full Ammo)")
		menu_additem(vipmenu, item, "2", 0)
	}
	
	if(get_pcvar_num(he_amount) > 0)
	{
		formatex(item, charsmax(item), "He Grenade \y(%ix)", get_pcvar_num(he_amount))
		menu_additem(vipmenu, item, "3", 0)
	}
	
	if(get_pcvar_num(flash_amount) > 0)
	{
		formatex(item, charsmax(item), "Flash Grenade \y(%ix)", get_pcvar_num(flash_amount))
		menu_additem(vipmenu, item, "4", 0)
	}
	
	if(get_pcvar_num(smoke_amount) > 0)
	{
		formatex(item, charsmax(item), "Smoke Grenade \y(%ix)", get_pcvar_num(smoke_amount))
		menu_additem(vipmenu, item, "5", 0)
	}
	
	if(get_pcvar_num(menu_transparency) == 1)
	{
		formatex(item, charsmax(item), "Transparency \y(%i%)", get_pcvar_num(transparency_amount))
		menu_additem(vipmenu, item, "6", 0)
	}
	
	if(get_pcvar_num(menu_speed) == 1)
	{
		formatex(item, charsmax(item), "Faster Speed \y(%i)", get_pcvar_num(speed_amount))
		menu_additem(vipmenu, item, "7", 0)
	}
	
	if(get_pcvar_num(menu_gravity) == 1)
	{
		formatex(item, charsmax(item), "Low Gravity \y(%f)", get_pcvar_float(gravity_amount))
		menu_additem(vipmenu, item, "8", 0)
	}
	
	if(get_pcvar_num(menu_m4a1) == 1)
	{
		formatex(item, charsmax(item), "M4A1 \y(Full Ammo)")
		menu_additem(vipmenu, item, "9", 0)
	}
	
	if(get_pcvar_num(menu_ak47) == 1)
	{
		formatex(item, charsmax(item), "AK47 \y(Full Ammo)")
		menu_additem(vipmenu, item, "10", 0)
	}
	
	if(get_pcvar_num(menu_awp) == 1)
	{
		formatex(item, charsmax(item), "AWP \y(Sniper)")
		menu_additem(vipmenu, item, "11", 0)
	}
	
	if(get_pcvar_num(menu_g3sg1) == 1)
	{
		formatex(item, charsmax(item), "G3SG1 \y(Automatic Sniper)")
		menu_additem(vipmenu, item, "12", 0)
	}
	
	if(get_pcvar_num(menu_sg550) == 1)
	{
		formatex(item, charsmax(item), "SG550 \y(Automatic Sniper)")
		menu_additem(vipmenu, item, "13", 0)
	}
	
	if(get_pcvar_num(menu_moredamage) == 1)
	{
		formatex(item, charsmax(item), "More Damage \y(%ix)", get_pcvar_num(moredamage_multiplier))
		menu_additem(vipmenu, item, "14", 0)
	}
	
	menu_setprop(vipmenu, MPROP_EXITNAME, "\rClose the Menu")
	menu_setprop(vipmenu, MPROP_BACKNAME, "\rGo to the \yPrevious \rPage")
	menu_setprop(vipmenu, MPROP_NEXTNAME, "\rGo to the \yNext \rPage")
	menu_setprop(vipmenu, MPROP_EXIT, MEXIT_ALL)
	
	menu_display(id, vipmenu, 0)
	return PLUGIN_HANDLED
}

public vipmenu_handler(id, vipmenu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(vipmenu)
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[64], access, callback
	menu_item_getinfo(vipmenu, item, access, data, charsmax(data), iName, charsmax(iName), callback)

	new key = str_to_num(data)
	vip_equip(id, key)
	menu_uses[id]++
	
	ColorChat(id, TEAM_COLOR, "%s ^1You have successfully used the ^3VIP Menu^1 (^4%i^1/^4%i^1)", szPrefix, menu_uses[id], get_pcvar_num(menu_maxuses))
	emit_sound(id, CHAN_ITEM, SOUND_MENU, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	menu_destroy(vipmenu)
	return PLUGIN_HANDLED
}

public player_killed()
{
	new attacker = read_data(1)
	new victim = read_data(2)
	
	if(!is_user_connected(attacker) || !is_user_connected(victim) || attacker == victim || !user_has_flag(attacker, flag_vip))
		return
	
	new headshot = read_data(3)
	
	new health = get_user_health(attacker)
	new money = cs_get_user_money(attacker)
	
	new reward_health = headshot ? get_pcvar_num(killbonus_health_headshot) : get_pcvar_num(killbonus_health_normal)
	new reward_money = headshot ? get_pcvar_num(killbonus_money_headshot) : get_pcvar_num(killbonus_money_normal)
	
	new health_max = get_pcvar_num(maxhealth)
	new money_max = get_pcvar_num(maxmoney)
	
	set_user_health(attacker, health + reward_health)
	cs_set_user_money(attacker, money + reward_money)
	
	if(get_user_health(attacker) > health_max) set_user_health(attacker, health_max)
	if(cs_get_user_money(attacker) > money_max) cs_set_user_money(attacker, money_max)
}

public player_damage(victim, inflictor, attacker, Float:damage, damage_bits)
{
	if(is_user_connected(attacker))
		if(user_moredamage[attacker] && attacker != victim)
			SetHamParamFloat(4, damage * get_pcvar_float(moredamage_multiplier))
}

public plugin_precache()
{
	get_skin_t = register_cvar("ve_get_skin_t", "0")
	get_skin_ct = register_cvar("ve_get_skin_ct", "0")
	
	skin_name_t = register_cvar("ve_skin_name_t", "vip")
	skin_name_ct = register_cvar("ve_skin_name_ct", "smith")

	skin_t_active = (get_pcvar_num(get_skin_t) == 1) ? true : false
	skin_ct_active = (get_pcvar_num(get_skin_ct) == 1) ? true : false
	
	if(skin_t_active)
	{
		new skin1[50]
		get_pcvar_string(skin_name_t, skin_t, charsmax(skin_t))
		formatex(skin1, charsmax(skin1), "%s/%s/%s.mdl", MODELS_PATH, skin_t, skin_t)
		precache_model(skin1)
	}
	
	if(skin_ct_active)
	{
		new skin2[50]
		get_pcvar_string(skin_name_ct, skin_ct, charsmax(skin_ct))
		formatex(skin2, charsmax(skin2), "%s/%s/%s.mdl", MODELS_PATH, skin_ct, skin_ct)
		precache_model(skin2)
	}
	
	precache_sound(SOUND_MENU)
}

stock user_has_flag(id, cvar)
{
	new flags[32]
	get_flags(get_user_flags(id), flags, charsmax(flags))
	
	new vip_flag[2]
	get_pcvar_string(cvar, vip_flag, charsmax(vip_flag))
	
	return (contain(flags, vip_flag) != -1) ? true : false
}

/* ======================================================================================================= */
/* ColorChat */
/* ======================================================================================================= */
ColorChat(id, Color:type, const msg[], {Float,Sql,Result,_}:...)
{
	if( !get_playersnum() ) return;
	
	new message[256];

	switch(type)
	{
		case NORMAL: // clients scr_concolor cvar color
		{
			message[0] = 0x01;
		}
		case GREEN: // Green
		{
			message[0] = 0x04;
		}
		default: // White, Red, Blue
		{
			message[0] = 0x03;
		}
	}

	vformat(message[1], 251, msg, 4);

	replace_all(message, 191, "!n", "^x01")
	replace_all(message, 191, "!t", "^x03")
	replace_all(message, 191, "!g", "^x04")
	
	// Make sure message is not longer than 192 character. Will crash the server.
	message[192] = '^0';

	new team, ColorChange, index, MSG_Type;
	
	if(id)
	{
		MSG_Type = MSG_ONE;
		index = id;
	} else {
		index = FindPlayer();
		MSG_Type = MSG_ALL;
	}
	
	team = get_user_team(index);
	ColorChange = ColorSelection(index, MSG_Type, type);

	ShowColorMessage(index, MSG_Type, message);
		
	if(ColorChange)
	{
		Team_Info(index, MSG_Type, TeamName[team]);
	}
}

ShowColorMessage(id, type, message[])
{
	static bool:saytext_used;
	static get_user_msgid_saytext;
	if(!saytext_used)
	{
		get_user_msgid_saytext = get_user_msgid("SayText");
		saytext_used = true;
	}
	message_begin(type, get_user_msgid_saytext, _, id);
	write_byte(id)		
	write_string(message);
	message_end();	
}

Team_Info(id, type, team[])
{
	static bool:teaminfo_used;
	static get_user_msgid_teaminfo;
	if(!teaminfo_used)
	{
		get_user_msgid_teaminfo = get_user_msgid("TeamInfo");
		teaminfo_used = true;
	}
	message_begin(type, get_user_msgid_teaminfo, _, id);
	write_byte(id);
	write_string(team);
	message_end();

	return 1;
}

ColorSelection(index, type, Color:Type)
{
	switch(Type)
	{
		case RED:
		{
			return Team_Info(index, type, TeamName[1]);
		}
		case BLUE:
		{
			return Team_Info(index, type, TeamName[2]);
		}
		case GREY:
		{
			return Team_Info(index, type, TeamName[0]);
		}
	}

	return 0;
}

FindPlayer()
{
	new i = -1;

	while(i <= get_maxplayers())
	{
		if(is_user_connected(++i))
			return i;
	}

	return -1;
}
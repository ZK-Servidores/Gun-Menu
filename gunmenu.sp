#pragma semicolon 1
#pragma newdecls required

#include <sdkhooks>
#include <sdktools_functions>
#include <sdktools_entinput>

enum {
	Slot_Primary = 0,
	Slot_Secondary,
	Slot_Knife,
	Slot_Grenade,
	Slot_C4,
	Slot_None
};

enum {
	Team_None = 0,
	Team_Spec,
	Team_T,
	Team_CT
};

bool bAllowAWP[] = {true, true};

int iWpnChoice[2][MAXPLAYERS+1],
	iMenuSize[2];
	
Menu hPrimaryMenu,
	hSecondaryMenu;

static const char	sPrimaryWeapons[][][] = {
		{"",					"Random"},
		{"weapon_awp",			"AWP"},
		{"weapon_ssg08",		"SSG 08"},
		{"weapon_ak47",			"AK-47"},
		{"weapon_m4a1",			"M4A4"},
		{"weapon_m4a1_silencer","M4A1-S"},
		{"weapon_sg556",		"SG 553"},
		{"weapon_aug",			"AUG"},
		{"weapon_galilar",		"Galil AR"},
		{"weapon_famas",		"FAMAS"}},
					
					sSecondaryWeapons[][][] = {
		{"",					"Random"},
		{"weapon_glock",		"Glock-18"},
		{"weapon_usp_silencer",	"USP-S"},
		{"weapon_hkp2000",		"P2000"},
		{"weapon_p250",			"P250"},
		{"weapon_deagle",		"Desert Eagle"},
		{"weapon_fiveseven",	"Five-SeveN"},
		{"weapon_elite",		"Dual Berettas"},
		{"weapon_tec9",			"Tec-9"},
		{"weapon_cz75a",		"CZ75-Auto"},
		{"weapon_revolver",		"R8 Revolver"}};

public Plugin myinfo =
{
	name		= "[CSGO] Gun Menu",
	author		= "Potatoz (Rewritten by Grey83, crashzk)",
	description	= "Gun Menu for gamemodes such as Retake, Deathmatch etc",
	version		= "1.1",
	url			= "https://forums.alliedmods.net/showthread.php?t=294225"
};

public void OnPluginStart()
{
	iMenuSize[0]	= sizeof(sPrimaryWeapons) - 1;
	PrintToServer("\nPrimary weapons num: %i", iMenuSize[0]);
	iMenuSize[1]	= sizeof(sSecondaryWeapons) - 1;
	PrintToServer("Secondary weapons num: %i\n", iMenuSize[1]);

	hPrimaryMenu = new Menu(Handler_PrimaryMenu);
	hPrimaryMenu.SetTitle("Escolha a Arma Principal:");
	for(int i; i <= iMenuSize[0]; i++)	hPrimaryMenu.AddItem(sPrimaryWeapons[i][0], sPrimaryWeapons[i][1]);

	hSecondaryMenu = new Menu(Handler_SecondaryMenu);
	hSecondaryMenu.SetTitle("Escolha a Arma Secundária:");
	for(int i; i <= iMenuSize[1]; i++)	hSecondaryMenu.AddItem(sSecondaryWeapons[i][0], sSecondaryWeapons[i][1]);

	RegConsoleCmd("sm_guns", Menu_PrimaryWeapon);

	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn",Event_Spawn);

	ToggleBuyZones();
}

public void OnPluginEnd()
{
	ToggleBuyZones(true);
}

public Action Menu_PrimaryWeapon(int client, int args)
{
	if(client) hPrimaryMenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int Handler_PrimaryMenu(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select)
	{
		iWpnChoice[0][client] = param;
		hSecondaryMenu.Display(client, MENU_TIME_FOREVER);
	}
	return 0;
}

public int Handler_SecondaryMenu(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_Select) iWpnChoice[1][client] = param;
	return 0;
}

public void OnClientPutInServer(int client)
{
	iWpnChoice[0][client] = iWpnChoice[1][client] = 0;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	bAllowAWP[0] = bAllowAWP[1] = true;
}

public void Event_Spawn(Event event, const char[] name, bool dontBroadcast)
{
	RequestFrame(RequestFrame_Callback, event.GetInt("userid"));
}

public void RequestFrame_Callback(int client)
{
	if(!(client = GetClientOfUserId(client))) return;

	StripWeapons(client);

	GivePlayerItem(client, "weapon_knife");
	GivePlayerItem(client, "item_assaultsuit");

	static int wpn;
	if(!(wpn = iWpnChoice[0][client])) wpn = GetRandomInt(1, iMenuSize[0]);
	if(wpn == 1)
	{
		switch(GetClientTeam(client))
		{
			case Team_T:
			{
				if(bAllowAWP[0])
				{
					bAllowAWP[0] = false;
					GivePlayerItem(client, "weapon_awp");
				}
				else
				{
					GivePlayerItem(client, "weapon_ak47");
					PrintToChat(client, "[ \x02ZK Servidores™ \x01] \x04AWP é limitada a 1 player em cada equipe por round.");
					PrintToChat(client, "[ \x02ZK Servidores™ \x01] \x04Você estará recebendo o kit default.");
				}
			}
			case Team_CT:
			{
				if(bAllowAWP[1])
				{
					bAllowAWP[1] = false;
					GivePlayerItem(client, "weapon_awp");
				}
				else
				{
					GivePlayerItem(client, "weapon_m4a1_silencer");
					PrintToChat(client, "[ \x02ZK Servidores™ \x01] \x04AWP é limitada a 1 player em cada equipe por round.");
					PrintToChat(client, "[ \x02ZK Servidores™ \x01] \x04Você estará recebendo o kit default.");
				}
			}
		}
	}
	else GivePlayerItem(client, sPrimaryWeapons[wpn][0]);

	wpn = iWpnChoice[1][client];
	if(!wpn) wpn = GetRandomInt(1, iMenuSize[1]);
	GivePlayerItem(client, sSecondaryWeapons[wpn][0]);
	
	switch(GetRandomInt(0, 10))
	{
		case 2:	GivePlayerItem(client, "weapon_smokegrenade");
		case 9:	GivePlayerItem(client, "weapon_hegrenade");		
	}
		
	switch(GetRandomInt(0, 1))
	{
		case 1:	GivePlayerItem(client, "weapon_flashbang");
	}

	switch(GetRandomInt(0, 2))
	{		
		case 2: 
		{
			switch(GetClientTeam(client)) 
			{
				case Team_T:	GivePlayerItem(client, "weapon_molotov");
				case Team_CT:	GivePlayerItem(client, "weapon_incgrenade");
			}
		}
	}
}

stock void StripWeapons(int client)
{
	RemoveWeaponBySlot(client, Slot_Primary);
	RemoveWeaponBySlot(client, Slot_Secondary);
	RemoveWeaponBySlot(client, Slot_Knife);
	while(RemoveWeaponBySlot(client)) {}
}

stock bool RemoveWeaponBySlot(int client, int slot = Slot_Grenade)
{
	int ent = GetPlayerWeaponSlot(client, slot);
	return ent > MaxClients && RemovePlayerItem(client, ent) && AcceptEntityInput(ent, "Kill");
}

stock void ToggleBuyZones(bool enable = false)
{
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "func_buyzone")) != -1)
	AcceptEntityInput(entity, enable ? "Enable" : "Disable");
}

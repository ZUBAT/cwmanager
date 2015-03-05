new Handle:bd = INVALID_HANDLE;
new String:szSteamId[MAXPLAYERS+1][32];
new String:szUserId[32];
new Handle:sm_cw_sid = INVALID_HANDLE;
new Handle:sm_cw_url = INVALID_HANDLE;
#undef REQUIRE_PLUGIN
#include <updater>
#include <timers>
#define CHAT_PREFIX   "CW Manager"
#define UPDATE_URL    "https://raw.githubusercontent.com/ZUBAT/cwmanager/master/updatefile.txt"
#define VER "2.7.9"
#pragma semicolon 1

public Plugin:myinfo =
{
	name = "[CW Manager]",
	author = "ZUBAT",
	version = VER,
	url = "podval.pro"
};

public OnPluginStart()
{
	RegAdminCmd("d2", Dust2, ADMFLAG_CUSTOM1, "change map for Dust2");
	RegAdminCmd("inf", Inferno, ADMFLAG_CUSTOM1,"change map for inferno");
	RegAdminCmd("mirage", Mirage, ADMFLAG_CUSTOM1,"change map for mirage");
	RegAdminCmd("cache", Cache, ADMFLAG_CUSTOM1,"change map for mirage");
	RegAdminCmd("over", Overpass, ADMFLAG_CUSTOM1,"change map for mirage");
	RegAdminCmd("nuke", Nuke, ADMFLAG_CUSTOM1,"change map for mirage");
	RegConsoleCmd("cw_version", PrintVersion);
	sm_cw_sid = CreateConVar("sm_cw_sid", "0", "Number CW SERVER 0-MIX SERVER >=1 CW SERVER ");
	sm_cw_url = CreateConVar("sm_cw_url", "http://csgoirk.ru", "Web server CW Manager");
	CreateConVar("sm_cw_version", VER, "Version plugin");
	AutoExecConfig(true, "plugin_cwmanager");
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 Loaded! version %s By ZUBAT", CHAT_PREFIX ,VER);
	ServerCommand("sv_damage_print_enable 0");
	ServerCommand("motdfile imotd.txt");
	decl String:szError[255];
	bd = SQL_Connect("cwmanager", false, szError, 255);
	if(bd == INVALID_HANDLE) SetFailState("Ошибка подключения к базе данных (%s)", szError);
	if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}
public Action:PrintVersion(client, args)
{
	PrintToServer("%s", VER);
	
	
}
public Action:Dust2(client, args)
{
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s", CHAT_PREFIX, "Change Map de_dust2");
	CreateTimer(5.0, dd2);
	
}
public Action:dd2(Handle:timer)
{
	ServerCommand("changelevel de_dust2");
}
public Action:Inferno(client, args)
{
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s", CHAT_PREFIX, "Change Map de_inferno");
	CreateTimer(5.0, inf);
	
}
public Action:inf(Handle:timer)
{
	ServerCommand("changelevel de_inferno");
}
public Action:Mirage(client, args)
{
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s", CHAT_PREFIX, "Change Map de_mirage");
	CreateTimer(5.0, mir);
	
}
public Action:mir(Handle:timer)
{
	ServerCommand("changelevel de_mirage");
}
public Action:Cache(client, args)
{
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s", CHAT_PREFIX, "Change Map de_cache");
	CreateTimer(5.0, cache);
	
}
public Action:cache(Handle:timer)
{
	ServerCommand("changelevel de_cache");
}
public Action:Nuke(client, args)
{
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s", CHAT_PREFIX, "Change Map de_nuke");
	CreateTimer(5.0, nuke);
	
}
public Action:nuke(Handle:timer)
{
	ServerCommand("changelevel de_nuke");
}
public Action:Overpass(client, args)
{
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s", CHAT_PREFIX, "Change Map de_overpass");
	CreateTimer(5.0, over);
	
}
public Action:over(Handle:timer)
{
	ServerCommand("changelevel de_overpass");
}
 //old work
//public OnClientPutInServer(iClient)
//public OnClientPostAdminCheck(iClient) 
public OnClientPostAdminCheck(iClient)
{
	if(!IsFakeClient(iClient))
	{	new iServer = GetConVarInt(sm_cw_sid);
		decl String:szQuery[150];
		//GetClientAuthString(iClient, szSteamId[iClient], 32);
		new String:sID[32];
		GetClientAuthId(iClient, AuthId_Steam2, sID, sizeof(sID));
		szSteamId[iClient]=sID;
		decl String:buf[4][10], nuM;
		if ((nuM = ExplodeString(szSteamId[iClient], ":", buf, 4, 10)) > 1) 
		{ 
			for (new i = 2; i < nuM; i++) 
			{ 
				TrimString(buf[i]); 
				szUserId=buf[i]; 
			} 
		}
		FormatEx(szQuery, 150, "SELECT *  FROM `all` WHERE `stid` = '%s' AND `server` = %i OR  `stid` = '%s' AND `teamid` = -1", szUserId, iServer, szUserId);
		SQL_TQuery(bd, SQL_SelectPlayerCallback, szQuery, iClient);
	}
}

public SQL_SelectPlayerCallback(Handle:owner, Handle:hndl, const String:error[], any:iClient)
{
	if(hndl == INVALID_HANDLE) LogError("Ошибка при получении данных (%s)", error);	
	else
	{
		if(IsClientInGame(iClient))
		{
			if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
			{
				new iServer = GetConVarInt(sm_cw_sid);
				decl String:query[512]; 	
				decl String:buf[4][10], nuM; 
				if ((nuM = ExplodeString(szSteamId[iClient], ":", buf, 4, 10)) > 1) 
				{ 
			  	   for (new i = 2; i < nuM; i++) 
				   { 
					   TrimString(buf[i]); 
					   szUserId=buf[i]; 
				   } 
				} 
				FormatEx(query, 512, "SELECT *  FROM `all` WHERE `stid` = '%s' AND `server` = %i OR  `stid` = '%s' AND `teamid` = -1", szUserId, iServer, szUserId);
				new Handle:hquery = SQL_Query(bd, szSteamId[iClient]);    
				if (hquery != INVALID_HANDLE && SQL_FetchRow(hquery)) if(!SQL_FetchInt(hquery, 0)) Kick(iClient);
				decl String:nick[64]; 
				SQL_FetchString(hndl, 1, nick, sizeof(nick));
				new teamid = SQL_FetchInt(hndl, 5); 
				if (teamid==-1)
				{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 Администратор %s подключился!", CHAT_PREFIX, nick);
				PrintToServer("\x01 \x09[\x04%s\x09]\x01 Администратор %s подключился!", CHAT_PREFIX, nick);
				}
				else
				{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 Игрок с ником %s прошел валидацию!", CHAT_PREFIX, nick);
				PrintToServer("\x01 \x09[\x04%s\x09]\x01 Игрок с ником %s прошел валидацию!", CHAT_PREFIX, nick);
				}
				if (hquery != INVALID_HANDLE) CloseHandle(hquery); 
			}
			else Kick(iClient);
		}
	}
}

	Kick(iClient) 
	{	
		decl String:cw_url[255];
		GetConVarString(sm_cw_url, cw_url, sizeof(cw_url));
		KickClient(iClient, "Вы не зарегистрированы в системе CW/MIX\nЗарегестрируйтесь %s \n Ваш STEAM_ID %s", cw_url, szSteamId[iClient]);
	}
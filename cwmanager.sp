new Handle:bd = INVALID_HANDLE;
new String:szSteamId[MAXPLAYERS+1][32];
new String:szUserId[32];
new Handle:sm_server_number = INVALID_HANDLE;

#pragma semicolon 1

public Plugin:myinfo =
{
	name = "[CW Manager]",
	author = "ZUBAT",
	version = "2.5.1-dev",
	url = "podval.pro"
};

public OnPluginStart()
{
	sm_server_number = CreateConVar("sm_server_number", "1", "Number CW SERVER");
	AutoExecConfig(true, "plugin_cwmanager");
	PrintToChatAll("[CW Manager] Loaded! version 2.0 By ZUBAT");
	decl String:szError[255];
	bd = SQL_Connect("cwmanager", false, szError, 255);
	if(bd == INVALID_HANDLE) SetFailState("Ошибка подключения к базе данных (%s)", szError);
}

//public OnClientPostAdminCheck(iClient)
public OnClientConnected(iClient)
{
	if(!IsFakeClient(iClient))
	{	new iServer = GetConVarInt(sm_server_number);
		decl String:szQuery[150];
		GetClientAuthString(iClient, szSteamId[iClient], 32);
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
				new iServer = GetConVarInt(sm_server_number);
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
				PrintToChatAll("[CW Manager] Администратор %s подключился!", nick);
				PrintToServer("[CW Manager] Администратор %s подключился!", nick);
				}
				else
				{
				PrintToChatAll("[CW Manager] Игрок с ником %s прошел валидацию!", nick);
				PrintToServer("[CW Manager] Игрок с ником %s прошел валидацию!", nick);
				}
				if (hquery != INVALID_HANDLE) CloseHandle(hquery); 
			}
			else Kick(iClient);
		}
	}
}

Kick(iClient) KickClient(iClient, "Вы не зарегестрированы в системе CW/MIX\nЗарегестрируйтесь http://podval.pro/ \n Ваш STEAM_ID %s", szSteamId[iClient]);
//Kick1(iClient) KickClient(iClient, "Ваша команда не зарегестрированна на матч");
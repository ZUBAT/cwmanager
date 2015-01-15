#pragma semicolon 1
#include <sourcemod>

new bool:g_bIsAdmin[MAXPLAYERS+1];
new String:error[255]
new Handle:db = SQL_DefConnect(error, sizeof(error))

public Plugin:myinfo = 
{
	name = "cwmanager",
	author = "ZUBAT",
	version = "0.1",
	url = "http://vk.com/ccpodval"
};

public OnPluginStart() HookEvent("player_disconnect", Event_PlayerDisconnect);

public OnClientPostAdminCheck(iClient)
{
	if (iClient > 0 && !IsFakeClient(iClient))
	{
		g_bIsAdmin[iClient] = GetUserAdmin(iClient) != INVALID_ADMIN_ID ? true:false;
		PrintConnect(iClient, true);
	}
}

public Event_PlayerDisconnect(Handle:hEvent, const String:sName[], bool:dontBroadcast)
{
	if (!dontBroadcast) SetEventBroadcast(hEvent, true);
	new iClient = GetClientOfUserId(GetEventInt(hEvent,"userid"));
	if (iClient > 0 && !IsFakeClient(iClient)) PrintConnect(iClient, false);
}
/*CheckSteamID(userid, const String:auth[])
{
	decl String:query[255];
	Format(query, sizeof(query), "SELECT userid FROM users WHERE steamid = '%s'", auth);
	SQL_TQuery(hdatabase, T_CheckSteamID, query, userid)
}*/
 
public T_CheckSteamID(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client;
 
	/* Make sure the client didn't disconnect while the thread was running */
	if ((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
 
	if (hndl == INVALID_HANDLE)
	{
		LogError("Query failed! %s", error);
		KickClient(client, "Authorization failed");
	} else if (!SQL_GetRowCount(hndl)) {
		KickClient(client, "You are not a member");
	}
}

stock PrintConnect(iClient, bool:IsConnect)
{	
decl String:sAuth[32], String:sIp[32], String:sAdmMsg[255], String:sMsg[255];
	GetClientAuthString(iClient, sAuth, sizeof(sAuth));
	GetClientIP(iClient, sIp, sizeof(sIp));
	/////////////////////////////////////
	/*if (db == INVALID_HANDLE)
	{
		PrintToServer("Could not connect: %s", error)
	} 
	else 
	{
	Format(query, sizeof(query), "SELECT name FROM now WHERE steamid = '%s'", sAuth)
	new Handle:query = SQL_Query(db, query)
	
	if (query == INVALID_HANDLE)
	{
		new String:error[255]
		SQL_GetError(db, error, sizeof(error))
		PrintToServer("Failed to query (error: %s)", error)
	} else {
		/* Process results here!
		*/
	
		/* Free the Handle *//*
		CloseHandle(query)
	}

		CloseHandle(db)
	}
	*/
	/////////////////////////////////////
	decl String:query[255];
	Format(query, sizeof(query), "SELECT name FROM now WHERE steamid = '%s'", auth);
	SQL_TQuery(hdatabase, T_CheckSteamID, query, userid)
	
	FormatEx(sAdmMsg, sizeof(sAdmMsg), "\x03• \x01Игрок \x04%N \x01| \x04%s \x01| \x04%s \x01%s.", iClient, sAuth, sIp, (IsConnect) ? "подключился":"отключился");
	FormatEx(sMsg, sizeof(sMsg), "\x03• \x01Игрок \x04%N \x01| \x04%s \x01%s.", iClient, sAuth, (IsConnect) ? "подключился":"отключился");

	for(new i=1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i)) PrintToChat(i, (g_bIsAdmin[i]) ? sAdmMsg:sMsg);
	}
}
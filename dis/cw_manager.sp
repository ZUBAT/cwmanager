#pragma semicolon 1
#include <sourcemod>
#include <socket>

#define SITE    "podval.pro" 
#define PHP    "check.php" //Путь до скрипта 
#define PHP_GET   "steamid" // Имя get переменной 

public Plugin:myinfo =
{
    name = "СW_Manager",
    author = "ZUBAT",
    description = "Check Client for CW",
}

public OnPluginStart() 
{
	// create a new tcp socket
	
	
	RegConsoleCmd("sm_steamid", Command_steamid, "This lets players see there steamid");
	PrintToChatAll("[CW Manager] Loaded!");


	
}

public Action:Command_steamid(client, argc)
{
    decl String:id[64];
    GetClientAuthString(client, id, 64);
    PrintToChat(client, "[CW Manager] Ваш SteamID %s", id);
    return Plugin_Handled;
}

public OnClientAuthorized(client)
{
	decl String:id[32];
    GetClientAuthString(client, id, 32);
    PrintToChatAll("[CW Manager] Connected User  %s", id);
	//return Plugin_Handled;
}
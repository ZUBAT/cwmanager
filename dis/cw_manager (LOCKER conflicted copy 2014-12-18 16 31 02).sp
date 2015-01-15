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
	new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, SITE, 80);
    //return Plugin_Handled;
}
public OnSocketConnected(Handle:socket, client, any:arg)  
{ 
 new String:szRequest[128]; 
   decl String:id[32];
    GetClientAuthString(client, id, 32);
 Format(szRequest, sizeof(szRequest), "GET /%s?%s=%s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", PHP, PHP_GET, id, SITE); 
 SocketSend(socket, szRequest); 
} 
  
public OnSocketReceive(Handle:socket, String:receiveData[], const dataSize, any:arg)  
{ 
 decl String:szTheContent[1024], 
    String:szTheNew[1024]; 
   
 if(dataSize > 0) 
    { 
  strcopy(szTheContent, sizeof(szTheContent), receiveData); 
      
  SplitString(szTheContent, "\r\n\r\n", szTheNew, sizeof(szTheNew)); 
  ReplaceString(szTheContent, sizeof(szTheContent), szTheNew, ""); 
    
  if(StrEqual(szTheContent, "\r\n\r\ntrue", false)) //CraZy 
  { 
   PrintToServer("[%s] Access is allowed!"); 
  } else 
  { 
   PrintToServer("[%s] Access denied! Contact the author."); 
  } 
 } 
} 
  
public OnSocketDisconnected(Handle:socket, any:arg)  
{ 
 CloseHandle(socket); 
 #if defined DEBUG 
 PrintToServer("[%s] Socket Disconnected"); 
 #endif 
} 
  
public OnSocketError(Handle:socket, const errorType, const errorNum, any:arg)  
{ 
 PrintToServer("[%s] Socket error %d (errno %d)" , errorType, errorNum); 
 LogError("[%s] Socket error %d (errno %d)", errorType, errorNum); 
 CloseHandle(socket); 
}
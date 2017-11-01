//============================================//
//=====[ CNT USAGE SECTION ]=====//
//============================================//
public OnPlayerConnect(playerid)
{
    if(IsPlayerNPC(playerid))
    {
    	SetPlayerColor(playerid, COLOR_WHITE);
    	return 1;
    }

    if(GetPVarInt(playerid, "StopRemoveBuildings") != 1)
    {
    	RemoveBuildings(playerid);
    }

    SetPVarInt(playerid, "Delay", 0);

    new query[500],
		ip[50],
		dateString[2][15],
		year, hour, month, minute, day, second;
		
    GetPlayerName(playerid, PlayerInfo[playerid][pUsername], MAX_PLAYER_NAME);
	format(PlayerInfo[playerid][pName], MAX_PLAYER_NAME, "%s", PlayerInfo[playerid][pUsername]);
	GiveNameSpace(PlayerInfo[playerid][pName]);
	getdate(year, month, day);
	gettime(hour, minute, second);
    format(dateString[0], sizeof(dateString[]), "%d-%d-%d", year, month, day);
    format(dateString[1], sizeof(dateString[]), "%d:%d:%d", hour, minute, second);
    GetPlayerIp(playerid, ip, sizeof(ip));

	mysql_format(handlesql, query, sizeof(query), "INSERT INTO `logs_login` (`name`, `ip`, `date`, `time`) VALUES ('%e', '%e', '%e', '%e');", PlayerInfo[playerid][pUsername], ip, dateString[0], dateString[1]);
	mysql_pquery(handlesql, query);

    if(strfind(PlayerInfo[playerid][pUsername], "Bot", true) != -1) // Prevent showing bots as Online
    {
	    mysql_format(handlesql, query, sizeof(query), "UPDATE `accounts` SET `Online` = 1 WHERE `Name`='%e'", PlayerInfo[playerid][pUsername]);
	    mysql_pquery(handlesql, query);
	}

    SetPlayerColor(playerid, COLOR_GREY);
    ResetPlayerWeapons(playerid);
    CancelSelectTextDraw(playerid);
    
    if(IsIPWhitelisted(ip))
	{
		SetPVarInt(playerid, "Bot", 1);
	}
	else
	{
		SetPVarInt(playerid, "Bot", 0);
	}

    //==============================//
    if(!NameIsRP(PlayerInfo[playerid][pUsername]))
    {
		KickPlayer(playerid, "Your name is not acceptable, please use the format: Firstname_Lastname!");
		scm(playerid, COLOR_ERROR, "This name is not acceptable.");
		scm(playerid, COLOR_ERROR, "Please login with your created characters name via UCP.");
		return 1;
	}
	
	new num = NumOccurences(PlayerInfo[playerid][pUsername], '_');
	if(num >= 2)
	{
		KickPlayer(playerid, "Your name is not acceptable, please use the format: Firstname_Lastname!");
		scm(playerid, COLOR_ERROR, "This name is not acceptable.");
		scm(playerid, COLOR_ERROR, "Please login with your created characters name via UCP.");
		return 1;
	}


	
	SetPVarInt(playerid, "InviteOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "RefillOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "RepairOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "ShakeOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "BlindOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "VehicleOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "Drag", INVALID_MAXPL);
	SetPVarInt(playerid, "Mobile", INVALID_MAXPL);
	SetPVarInt(playerid, "HouseOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "BizOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "LiveOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "DragOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "RentOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "DivorceOffer", INVALID_MAXPL);
	SetPVarInt(playerid, "SeePM", INVALID_MAXPL);
	SetPVarInt(playerid, "SpecID", INVALID_MAXPL);
	SetPVarInt(playerid, "Reviewing", INVALID_MAXPL);
	strmid(PlayerInfo[playerid][pPMMsg], "None", 0, strlen("None"), 255);
	strmid(PlayerInfo[playerid][pSec], "None", 0, strlen("None"), 255);
	strmid(PlayerInfo[playerid][pMarriedTo], "None", 0, strlen("None"), 255);
	strmid(PlayerInfo[playerid][pHost], "None", 0, strlen("None"), 255);
	strmid(PlayerInfo[playerid][pAccent], "None", 0, strlen("None"), 255);
    PlayerInfo[playerid][pLiveOffer][0] = 0;
	PlayerInfo[playerid][pLiveOffer][1] = 0;
	PlayerInfo[playerid][pPosa][0]=0;
	PlayerInfo[playerid][pPosa][1]=0;
	PlayerInfo[playerid][pPosa][2]=0;
	PlayerInfo[playerid][pPosa][3]=0;
	PlayerInfo[playerid][pPosa][4]=0;
	PlayerInfo[playerid][pPosa][5]=0;
	PlayerInfo[playerid][pPaymentTD]=0;
	//==============================//
    for(new i = 0; i < MAX_INV_SLOTS; i++)
	{
		PlayerInfo[playerid][pInvItem][i]=0;
		PlayerInfo[playerid][pInvQ][i]=0;
		PlayerInfo[playerid][pInvEx][i]=0;
		PlayerInfo[playerid][pInvS][i]=0;
	}
	PlayerInfo[playerid][pPlayerWeapon]=0;
	PlayerInfo[playerid][pPlayerAmmo]=0;
	PlayerInfo[playerid][pAmmoType]=0;
	PlayerInfo[playerid][pPlayerSerial]=0;
	PlayerInfo[playerid][pHacker]=0;
	PlayerInfo[playerid][pSpeedDelay]=0;
	PlayerInfo[playerid][pJobStatus] = 0;
	PlayerInfo[playerid][pJobProgress] = 0;
	PlayerInfo[playerid][pJobVehicleID] = 0;
	PlayerInfo[playerid][pJobExtraVehicleID] = 0;

	PlayerInfo[playerid][pDialogOpen] = 0;
	PlayerInfo[playerid][pTogName] = 0;
	PlayerInfo[playerid][pTogAdminChat] = 0;

	for(new i = 0; i < MAX_DELAY_SLOTS + 1; i++) {
	    PlayerInfo[playerid][pDelay][i]=0; }
	for(new i = 0; i < MAX_ACHIEVEMENTS; i++) {
	    PlayerInfo[playerid][pAch][i]=0; }
	for(new i = 0; i < 3; i++) {
	    PlayerInfo[playerid][pPos][i]=0.0;
		PlayerInfo[playerid][pPosI][i]=0.0; }
	for(new i = 0; i < MAX_LSPD_DIVISIONS; i++) {
	    PlayerInfo[playerid][pDivision][i]=0; }
	PlayerInfo[playerid][pIdleTime]=0;
	
	for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
		RemovePlayerAttachedObject(playerid, i);
	}
	
	for(new i = 0; i < MAX_PLAYER_TOYS; i++)
	{
	    ToyInfo[playerid][i][tBone] = 0;
	    ToyInfo[playerid][i][tModel] = 0;
	    ToyInfo[playerid][i][toX] = 0.0;
	    ToyInfo[playerid][i][toY] = 0.0;
	    ToyInfo[playerid][i][toZ] = 0.0;
	    ToyInfo[playerid][i][trX] = 0.0;
	    ToyInfo[playerid][i][trY] = 0.0;
	    ToyInfo[playerid][i][trZ] = 0.0;
	    ToyInfo[playerid][i][tsX] = 0.0;
	    ToyInfo[playerid][i][tsY] = 0.0;
	    ToyInfo[playerid][i][tsZ] = 0.0;
	    ToyInfo[playerid][i][tEquipped] = 0;
	}
	
	for(new i = 0; i < 35; i++)
	{
	    HolsterInfo[playerid][i][hBone]=0;
	    HolsterInfo[playerid][i][hoX]=0.0;
	    HolsterInfo[playerid][i][hoY]=0.0;
	    HolsterInfo[playerid][i][hoZ]=0.0;
	    HolsterInfo[playerid][i][hrX]=0.0;
	    HolsterInfo[playerid][i][hrY]=0.0;
	    HolsterInfo[playerid][i][hrZ]=0.0;
	    HolsterInfo[playerid][i][hHide]=0;
	}
	PlayerInfo[playerid][pScanner]=0;

	PlayerInfo[playerid][pSelectedFurnitureID] = 0;

	strmid(PlayerInfo[playerid][pIP], "NULL", 0, strlen("NULL"), 255);
    //==============================//
    strmid(PlayerInfo[playerid][pAudioUrl], "NULL", 0, strlen("NULL"), 255);

    for(new i = 0; i < MAX_PLAYER_CONTACTS; i++)
    {
    	PlayerContacts[playerid][i][pContactName] = 0;
    	PlayerContacts[playerid][i][pContactNumber] = 0;
    }

    for(new i = 0; i < 50; i++)
    {
    	MDCinfo[playerid][i][mVID] = 0;
    	MDCinfo[playerid][i][mTime] = 0;
    	MDCinfo[playerid][i][mSuspect] = 0;
    	MDCinfo[playerid][i][mOfficer] = 0;
    	MDCinfo[playerid][i][mChecking] = 0;
    }

	foreach(new i : Player) {
		if(GetPVarInt(i, "connectmessages") != 0 && (GetPVarInt(i, "Admin") != 0 || GetPVarInt(i, "Helper") != 0)) {
			format(query, sizeof(query), "%s (ID: %i) connected to the server.", PlayerInfo[playerid][pName], playerid);
			SendClientMessage(i, COLOR_GREY, query);
		}
	}
	
	// Load MDC TextDraws:
	mdc_LoadPlayerTextdraws(playerid);

	// Load Cellphone TextDraws
	LoadPlayerCellphoneTextDraws(playerid);

	SetPlayerTime(playerid, GMHour, GMMin);
	SetPlayerWeather(playerid, GMWeather);
	return 1;
}
//============================================//
public OnPlayerDisconnect(playerid, reason)
{
	SetPVarInt(playerid, "StopRemoveBuildings", 0);

    if(IsPlayerNPC(playerid)) return 1;
	new sendername[MAX_PLAYER_NAME], query[220];

    EnablePlayerCameraTarget(playerid, 0);

    ServerLog(LOG_DISCONNECT, PlayerInfo[playerid][pUsername]);

    mysql_format(handlesql, query, sizeof(query), "UPDATE `accounts` SET `Online` = 0 WHERE `Name` = '%e';", PlayerInfo[playerid][pUsername]);
	mysql_pquery(handlesql, query);

	if(PlayerInfo[playerid][pHasBasketball] == 1)
	{		
		new Float:player_pos[3];
		GetPlayerPos(playerid, player_pos[0], player_pos[1], player_pos[2]);
		GetXYInFrontOfPlayer(playerid, player_pos[0], player_pos[1], 1.0);

		MoveObject(Basketball[PlayerInfo[playerid][pBasketballID]][bID], player_pos[0], player_pos[1], player_pos[2], 4);

		Basketball[PlayerInfo[playerid][pBasketballID]][bBounce] = 1;
		Basketball[PlayerInfo[playerid][pBasketballID]][bState] = 2;
		Basketball[PlayerInfo[playerid][pBasketballID]][bBaller] = INVALID_MAXPL;
		PlayerInfo[playerid][pHasBasketball] = 0;
		PlayerInfo[playerid][pBasketballID] = 0;
	}

    // Despawn vehicle 10 minutes after the player has logged off.
    for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
	{
		new temp_vehicleid = GetSpawnedVehicle(playerid, i);
		VehicleInfo[temp_vehicleid][vDespawnTimer] = SetTimerEx("DespawnPlayerVehicle", VEHICLE_DESPAWN_TIMER, false, "i", temp_vehicleid);
	}
		
	foreach(new i : Player)
	{
		if(GetPVarInt(i, "VehicleOffer") == playerid)
		{
            SetPVarInt(i, "VehicleOffer", INVALID_MAXPL);
			DeletePVar(i, "VehicleOfferPrice");
			DeletePVar(i, "VehicleOfferID");
		}
	}
	
	for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
		RemovePlayerAttachedObject(playerid, i);
	}
	
	if(GetPVarInt(playerid, "Mobile") != INVALID_MAXPL)
	{
	    if(IsPlayerConnected(GetPVarInt(playerid, "Mobile")) && GetPVarInt(GetPVarInt(playerid, "Mobile"), "Mobile") == playerid)
	    {
		    CallRemoteFunction("LoadRadios", "i", GetPVarInt(playerid, "Mobile"));
		    SendClientMessage(GetPVarInt(playerid, "Mobile"), COLOR_ERROR, "The phone line went dead...");
			if(GetPlayerSpecialAction(GetPVarInt(playerid, "Mobile")) == SPECIAL_ACTION_USECELLPHONE) CellphoneState(GetPVarInt(playerid, "Mobile"), 2);
			SetPVarInt(GetPVarInt(playerid, "Mobile"), "Mobile", INVALID_MAXPL);
	    }
	    
        SetPVarInt(playerid, "Mobile", INVALID_MAXPL);
	}
	
	SetPVarInt(playerid, "DragOffer", INVALID_MAXPL);
	
	if(GetPVarInt(playerid, "PlayerLogged") == 1)
	{
		if(GetPVarInt(playerid, "Admin") > 0 || GetPVarInt(playerid, "Helper") > 0)
		{
			mysql_format(handlesql, query, sizeof(query), "INSERT INTO `staff_activity` (`pID`, `from`, `until`, `assists`, `reports`, `helpmes`, `reviews`, `ForumName`) VALUES \
			   (%i, DATE_SUB(NOW(), INTERVAL %i SECOND), NOW(), %i, %i, %i, %i, '%s');", PlayerInfo[playerid][pID],
			   GetPVarInt(playerid, "sa_counter"), GetPVarInt(playerid, "sa_assists"), GetPVarInt(playerid, "sa_reports"),
			   GetPVarInt(playerid, "sa_helpmes"), GetPVarInt(playerid, "sa_reviews"),
			   AdminName(playerid));
			mysql_pquery(handlesql, query);
		}

	    format(sendername, sizeof(sendername), "%s", PlayerInfo[playerid][pUsername]);
        GiveNameSpace(sendername);

        switch(reason)
        {
            case 0:
            {
                format(query, sizeof(query), "%s has left the server. (Crashed)", sendername);
                SetPVarInt(playerid, "Crash", 1);
				SetPVarInt(playerid, "Crashes", GetPVarInt(playerid, "Crashes") + 1);
            }
            case 1:
            {
			    format(query, sizeof(query), "%s has left the server. (Disconnected)", sendername);
			    if(GetPVarInt(playerid, "Cuffed") == 0)
			    {
			        SetPVarInt(playerid, "SpawnLocation", 1);
			    }
			}
            default:
            {
				format(query, sizeof(query), "%s has left the server. (Kicked/Banned)", sendername);
			}
        }
	        
        if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
        {
			ProxDetector(20.0, playerid, query, COLOR_WHITE);
		}
		
    	//==========//
		if(GetPVarInt(playerid, "RentKey") > 0)
		{
			VehicleInfo[GetPVarInt(playerid, "RentKey")][vDespawnTimer] = SetTimerEx("DespawnRentalVehicle", VEHICLE_RENTAL_DESPAWN_TIMER, false, "i", GetPVarInt(playerid, "RentKey"));
		}

		foreach(new i : VehicleIterator)
		{
			if(IsValidVehicle(i))
			{
				if(VehicleInfo[i][vType] == VEHICLE_LSPD && strcmp(CopInfo[i][Owner], PlayerInfo[playerid][pUsername]) == 0)
				{
					VehicleInfo[i][vDespawnTimer] = SetTimerEx("DespawnFactionVehicle", VEHICLE_FACTION_DESPAWN_TIMER, false, "i", i);
					break;
				}
			}
		}

		if(GetPVarInt(playerid, "RouteVeh") >= 1)
		{
	        if(VehicleInfo[GetPVarInt(playerid, "RouteVeh")][vType] == VEHICLE_JOB)
	        {
				DespawnVehicle(GetPVarInt(playerid, "RouteVeh"));
			}
		}

		if(GetPVarInt(playerid, "TakeTest") >= 1 && GetPVarInt(playerid, "TestVeh") >= 1)
		{
			DespawnVehicle(GetPVarInt(playerid, "TestVeh"));
		}

		if(GetPVarInt(playerid, "MaskUse") == 1)
		{
			Delete3DTextLabel(PlayerTag[playerid]);
		}

		if(GetPVarInt(playerid, "LSPD_Ta") == 1)
		{
       		PlayerInfo[playerid][pPlayerWeapon]=0;
       		PlayerInfo[playerid][pPlayerAmmo]=0;
       		PlayerInfo[playerid][pPlayerSerial]=0;
       		PlayerInfo[playerid][pAmmoType]=0;
   		}

		DespawnVehicle(PlayerInfo[playerid][pJobVehicleID]);
		DespawnVehicle(PlayerInfo[playerid][pJobExtraVehicleID]);
		DestroyDynamicRaceCP(PlayerInfo[playerid][pJobCP]);

		PlayerInfo[playerid][pJobCP] = 0;
		PlayerInfo[playerid][pJobStatus] = 0;
		PlayerInfo[playerid][pJobProgress] = 0;
		PlayerInfo[playerid][pJobVehicleID] = 0;
		PlayerInfo[playerid][pJobExtraVehicleID] = 0;
		PlayerInfo[playerid][pJobHouseID] = 0;
		PlayerInfo[playerid][pMechCall] = 0;

		DestroyDynamicCP(PlayerInfo[playerid][pAddressCP]);
		PlayerInfo[playerid][pAddressCP] = 0;

		DestroyDynamicCP(PlayerInfo[playerid][pLocationsCP]);
		PlayerInfo[playerid][pLocationsCP] = 0;

		DisablePlayerCheckpoint(playerid);

   		OnPlayerDataSave(playerid);

   		DestroyDynamic3DTextLabel(PlayerInfo[playerid][pInjuriesText]);
	}
	
	PlayerInfo[playerid][pID] = 0;

	UpdateSpectator(playerid);
	return 1;
}
//============================================//

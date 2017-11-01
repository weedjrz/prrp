//============================================//
//=====[ ACC USAGE SECTION ]=====//
//============================================//
public OnPlayerRequestClass(playerid, classid)
{
    SetPVarInt(playerid, "BeingBanned", 0);
    if(IsPlayerNPC(playerid))
	{
	    return 1;
	}
    else
    {
    	SetPlayerTime(playerid, GMHour, GMMin);
		SetPlayerWeather(playerid, GMWeather);

        SpawnPlayer(playerid);
        if(GetPVarInt(playerid, "PlayerLogged") == 1) return SpawnPlayer(playerid);
        //PlayAudioStreamForPlayerEx(playerid, "http://pr-rp.com/beat.mp3");
		ClearChatbox(playerid, 50);
		//==============================//
		TogglePlayerSpectating(playerid, 1);
	    //==============================//
	    TextDrawShowForPlayer(playerid, SideBar1);
	    TextDrawShowForPlayer(playerid, SideBar2);
	    //==============================//
	    /*if(GetPVarInt(playerid, "AccountExist") != 0)
	    {
		    cache_get_data(rows, fields, handlesql);
		    cache_get_row(0,1,PlayerInfo[playerid][pPass],handlesql, 128);
	        ShowPlayerDialogEx(playerid,1,DIALOG_STYLE_PASSWORD,"Server Account","An existing account is using your playername, please login to the account!","Login", "");
	        new ip[128];
	        GetPlayerIp(playerid, ip, 128);
	        if(strcmp(DOF2_GetString(string, "IP"), ip, true) == 0)
	        {
	            new sendername[MAX_PLAYER_NAME], strex[128];
	            format(sendername, sizeof(sendername), "%s", PlayerInfo[playerid][pUsername]), GiveNameSpace(sendername);
	            format(strex, sizeof(strex), "~w~welcome back ~b~~h~%s ~w~!", sendername);
	            GameTextForPlayer(playerid, strex, 3000, 5);
	            //==============================//
	            SetTimerEx("OnPlayerLogin", 1000, false, "isi", playerid, DOF2_GetString(string, "Key"), 1);
	            return true; // Block any breaks....
	        }
	        else ShowPlayerDialogEx(playerid,1,DIALOG_STYLE_PASSWORD,"Server Account","An existing account is using your playername, please login to the account!","Login", "");
		}
	    else ShowPlayerDialogEx(playerid,2,DIALOG_STYLE_PASSWORD,"Server Account","There is no existing account using your playername, please create a new account!","Register", "");*/
	    CheckAccount(playerid, 1);
	    //==============================//
	    SetTimerEx("LoginCamera", 500, false, "i", playerid);
	    //==============================//
    }
	return 1;
}
//============================================//
sqlconnect()
{
	handlesql = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASS);
	return 1;
}
//============================================//
stock CheckAccount(playerid, type)
{
    new query[82];
	mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `accounts` WHERE `Name` = '%e'", PlayerInfo[playerid][pUsername]);
	mysql_pquery(handlesql, query, "OnAccountCheck", "dd", playerid, type);
	return 1;
}
//============================================//
forward LogUserIn(playerid);
public LogUserIn(playerid)
{
    SetPVarInt(playerid, "VehicleLoaded", 1);
	new string[128];
    new fields, rows;
    cache_get_data(rows, fields);
    if(rows)
	{
     	CallRemoteFunction("OnPlayerLogin", "ii", playerid, 0);
	}
    else
    {
        if(GetPVarInt(playerid, "WrongPassword") >= 5) { return KickPlayer(playerid, "You have been kicked for entering the wrong password over (5) times!"); }
	    SetPVarInt(playerid, "WrongPassword", 1+GetPVarInt(playerid, "WrongPassword"));
	    new amount = 5 - GetPVarInt(playerid, "WrongPassword");
	    format(string, sizeof(string),"Invalid password (%d tries left).", amount);
	    SendClientMessage(playerid,COLOR_ERROR, string);
	    ShowPlayerDialogEx(playerid,1,DIALOG_STYLE_PASSWORD, 
	    	""EMBED_COLOR_WHITE"Server Account", 
	    	""EMBED_COLOR_WHITE"An existing account is using your playername, please login to the account!",
	    	""EMBED_COLOR_WHITE"Login", 
	    	""EMBED_COLOR_WHITE"");
	    CheckAccount(playerid, 1);
    }
    return 1;
}
//============================================//
public OnAccountCheck(playerid, type)
{
	if(playerid != INVALID_PLAYER_ID)
	{
		new rows, fields;
		cache_get_data(rows, fields, handlesql);
		if(rows)
		{
			new fetch[24], query[256];
			cache_get_field_content(0, "ConnectTime", fetch);

			mysql_format(handlesql, query, sizeof(query), "SELECT `deleted` FROM `accounts` WHERE `Name` = '%s'", PlayerInfo[playerid][pUsername]);
			mysql_pquery(handlesql, query, "OnDeletedCheck", "d", playerid);
			
			//==========//
		    cache_get_field_content(0, "Tut", fetch);
		    SetPVarInt(playerid, "Tut", strval(fetch));
		    SetPVarInt(playerid, "AccountExist", 1);
		    if(type == 1)
		    {
  				SetPVarInt(playerid, "AccountExist", 1);
  				cache_get_row(0,2,PlayerInfo[playerid][pPass],handlesql, 128);
	            ShowPlayerDialogEx(playerid,1,DIALOG_STYLE_PASSWORD,"Server Account","An existing account is using your playername, please login to the account!","Login", "");
	            CheckIfBanned(playerid);
	        }
		}
		else
		{
		    SetPVarInt(playerid, "AccountExist", 0);
		    ShowPlayerDialogEx(playerid,2,DIALOG_STYLE_PASSWORD,"Server Account","There are no existing account using your playername, please create a new account!","Register", "");
		}
	}
	return 1;
}
//============================================//
public OnPlayerLogin(playerid, type)
{
	new query[256];
	mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `accounts` WHERE `Name` = '%e'", PlayerInfo[playerid][pUsername]);
	mysql_pquery(handlesql, query, "OnSecurityCheck", "d", playerid);
    new ip[128], datum[50],hour,minute,second,year,month,day,tijd[50];
	getdate(year, month, day);
	gettime(hour,minute,second);
    format(datum, sizeof(datum), "%d-%d-%d", year, month, day);
    format(tijd, sizeof(tijd), "%d:%d:%d", hour, minute, second);
    GetPlayerIp(playerid, ip, sizeof(ip));
    mysql_format(handlesql, query, sizeof(query),"INSERT INTO `logs_login`(`name`, `ip`, `date`, `time`) VALUES ('%e','%e','%e','%e')",
    PlayerInfo[playerid][pUsername], ip, datum, tijd);
    mysql_pquery(handlesql, query);
	return 1;
}
//============================================//
public OnAccountLoad(playerid, type)
{
	printf("LOADING PLAYER... (%s [DBID: %i] [ID: %i])", PlayerInfo[playerid][pUsername], cache_get_field_content_int(0, "ID"), playerid);
	// LOAD ACCOUNT DATA //
	if(type == 0)
	{
	    new forum_name[64];
	    cache_get_field_content(0, "ForumName", forum_name);
	    SetPVarString(playerid, "ForumName", forum_name);

		SetPVarInt(playerid, "Cash", cache_get_field_content_int(0, "Cash"));
		SetPVarInt(playerid, "Bank", cache_get_field_content_int(0, "Bank"));
		SetPVarInt(playerid, "Model", cache_get_field_content_int(0, "Model"));
		SetPVarInt(playerid, "Interior", cache_get_field_content_int(0, "Interior"));
		SetPVarInt(playerid, "World", cache_get_field_content_int(0, "World"));
		SetPVarInt(playerid, "Tut", cache_get_field_content_int(0, "Tut"));
		SetPVarInt(playerid, "Age", cache_get_field_content_int(0, "Age"));
		SetPVarInt(playerid, "Sex", cache_get_field_content_int(0, "Sex"));
		SetPVarFloat(playerid, "PosX", cache_get_field_content_float(0, "PosX"));
		SetPVarFloat(playerid, "PosY", cache_get_field_content_float(0, "PosY"));
		SetPVarFloat(playerid, "PosZ", cache_get_field_content_float(0, "PosZ"));
		SetPVarFloat(playerid, "Health", cache_get_field_content_float(0, "Health"));
		SetPVarFloat(playerid, "Armour", cache_get_field_content_float(0, "Armour"));
		SetPVarInt(playerid, "Admin", cache_get_field_content_int(0, "Admin"));
		SetPVarInt(playerid, "Helper", cache_get_field_content_int(0, "Helper"));
		SetPVarInt(playerid, "Developer", cache_get_field_content_int(0, "Developer"));
		SetPVarInt(playerid, "Jailed", cache_get_field_content_int(0, "Jailed"));
		SetPVarInt(playerid, "Jailtime", cache_get_field_content_int(0, "Jailtime"));
		SetPVarInt(playerid, "ConnectTime", cache_get_field_content_int(0, "ConnectTime"));
		SetPVarInt(playerid, "DriveLic", cache_get_field_content_int(0, "DriveLic"));
		SetPVarInt(playerid, "GunLic", cache_get_field_content_int(0, "GunLic"));
		SetPVarInt(playerid, "MedLic", cache_get_field_content_int(0, "MedLic"));
		SetPVarInt(playerid, "helpmes", cache_get_field_content_int(0, "helpme"));
		SetPVarInt(playerid, "Member", cache_get_field_content_int(0, "Member"));
		SetPVarInt(playerid, "Rank", cache_get_field_content_int(0, "Rank"));
		SetPVarInt(playerid, "LockerRights", cache_get_field_content_int(0, "LockerRights"));
		SetPVarInt(playerid, "JobReduce", cache_get_field_content_int(0, "JobReduce"));
		SetPVarInt(playerid, "Job", cache_get_field_content_int(0, "JobID"));
		SetPVarInt(playerid, "DonateRank", cache_get_field_content_int(0, "DonateRank"));
		SetPVarInt(playerid, "Fightstyle", cache_get_field_content_int(0, "Fightstyle"));
		SetPVarInt(playerid, "HouseKey", cache_get_field_content_int(0, "HouseKey"));
		SetPVarInt(playerid, "BizKey", cache_get_field_content_int(0, "BizKey"));
		SetPVarInt(playerid, "RentKey", cache_get_field_content_int(0, "RentKey"));
		SetPVarInt(playerid, "WalkieFreq", cache_get_field_content_int(0, "WalkieFreq"));
		SetPVarInt(playerid, "PhoneNum", cache_get_field_content_int(0, "PhoneNum"));
		SetPVarInt(playerid, "PayDay", cache_get_field_content_int(0, "PayDay"));
		SetPVarInt(playerid, "PayCheck", cache_get_field_content_int(0, "PayCheck"));
		SetPVarInt(playerid, "CheckEarn", cache_get_field_content_int(0, "CheckEarn"));
		SetPVarInt(playerid, "CarTicket", cache_get_field_content_int(0, "CarTicket"));
		SetPVarInt(playerid, "Changes", cache_get_field_content_int(0, "Changes"));
        SetPVarInt(playerid, "ChatStyle", cache_get_field_content_int(0, "ChatStyle"));
		SetPVarInt(playerid, "MaskID", cache_get_field_content_int(0, "MaskID"));
		SetPVarInt(playerid, "Dead", cache_get_field_content_int(0, "Dead"));
		SetPVarInt(playerid, "PaidRent", cache_get_field_content_int(0, "PaidRent"));
		SetPVarInt(playerid, "LicTime", cache_get_field_content_int(0, "LicTime"));
		SetPVarInt(playerid, "LicGuns", cache_get_field_content_int(0, "LicGuns"));
		SetPVarInt(playerid, "MonthDon", cache_get_field_content_int(0, "MonthDon"));
		SetPVarInt(playerid, "MonthDonT", cache_get_field_content_int(0, "MonthDonT"));
		SetPVarInt(playerid, "DrugTime", cache_get_field_content_int(0, "DrugTime"));
		SetPVarInt(playerid, "DrugHigh", cache_get_field_content_int(0, "DrugHigh"));
		SetPVarInt(playerid, "Addiction", cache_get_field_content_int(0, "Addiction"));
		SetPVarInt(playerid, "AddictionID", cache_get_field_content_int(0, "AddictionID"));
		SetPVarInt(playerid, "AutoReload", cache_get_field_content_int(0, "AutoReload"));
		SetPVarInt(playerid, "AudioT", cache_get_field_content_int(0, "AudioT"));
		SetPVarInt(playerid, "Frights", cache_get_field_content_int(0, "Frights"));
		SetPVarInt(playerid, "HudCol", cache_get_field_content_int(0, "HudCol"));
		SetPVarInt(playerid, "PrimHol", cache_get_field_content_int(0, "PrimHol"));
		SetPVarInt(playerid, "SecHol", cache_get_field_content_int(0, "SecHol"));
		SetPVarInt(playerid, "Bonus", cache_get_field_content_int(0, "Bonus"));
		SetPVarInt(playerid, "SpawnLocation", cache_get_field_content_int(0, "SpawnLocation"));
		SetPVarInt(playerid, "HouseEnter", cache_get_field_content_int(0, "HouseEnter"));
		SetPVarInt(playerid, "BizEnter", cache_get_field_content_int(0, "BizEnter"));
		SetPVarInt(playerid, "IntEnter", cache_get_field_content_int(0, "IntEnter"));
		SetPVarInt(playerid, "GarageEnter", cache_get_field_content_int(0, "GarageEnter"));
		SetPVarInt(playerid, "PaintUse", cache_get_field_content_int(0, "PaintUse"));
		SetPVarInt(playerid, "WepSerial", cache_get_field_content_int(0, "WepSerial"));
		SetPVarInt(playerid, "Wound_T", cache_get_field_content_int(0, "Wound_T"));
		SetPVarInt(playerid, "Wound_A", cache_get_field_content_int(0, "Wound_A"));
		SetPVarInt(playerid, "Wound_L", cache_get_field_content_int(0, "Wound_L"));
		SetPVarInt(playerid, "Kills", cache_get_field_content_int(0, "Kills"));
		SetPVarInt(playerid, "Deaths", cache_get_field_content_int(0, "Deaths"));
		SetPVarInt(playerid, "UpgDelay", cache_get_field_content_int(0, "UpgDelay"));
		SetPVarInt(playerid, "Forbid", cache_get_field_content_int(0, "Forbid"));
		SetPVarInt(playerid, "Suspend", cache_get_field_content_int(0, "Suspend"));
		SetPVarInt(playerid, "TogUnhol", cache_get_field_content_int(0, "TogUnhol"));
		SetPVarInt(playerid, "WalkStyle", cache_get_field_content_int(0, "WalkStyle"));

		PlayerInfo[playerid][pID] = cache_get_field_content_int(0, "ID");
		PlayerInfo[playerid][pPlayerWeapon] = cache_get_field_content_int(0, "PlayerWeapon");
		PlayerInfo[playerid][pPlayerAmmo] = cache_get_field_content_int(0, "PlayerAmmo");
		PlayerInfo[playerid][pPlayerSerial] = cache_get_field_content_int(0, "PlayerSerial");
		PlayerInfo[playerid][pAmmoType] = cache_get_field_content_int(0, "AmmoType");

		new fetch[128];

		cache_get_field_content(0, "JailedUntil", fetch);
		format(PlayerInfo[playerid][pJailedUntil], 128, "%s", fetch);

		cache_get_field_content(0, "Describe1", fetch);
		format(PlayerInfo[playerid][pDescribe], 128, "%s", fetch);

		cache_get_field_content(0, "Describe2", fetch);
		format(PlayerInfo[playerid][pDescribe2], 128, "%s", fetch);

		cache_get_field_content(0, "MarriedTo", fetch);
		format(PlayerInfo[playerid][pMarriedTo], MAX_PLAYER_NAME + 1, "%s", fetch);

		cache_get_field_content(0, "Accent", fetch);
		format(PlayerInfo[playerid][pAccent], 64, "%s", fetch);

		cache_get_field_content(0, "FDSubRank", fetch);
		format(PlayerInfo[playerid][pFDSubRank], 20, "%s", fetch);

		if(strlen(PlayerInfo[playerid][pMarriedTo]) == 0)
		{
		    format(PlayerInfo[playerid][pMarriedTo], MAX_PLAYER_NAME + 1, "None");
		}
		
		if(strlen(PlayerInfo[playerid][pAccent]) == 0)
		{
			format(PlayerInfo[playerid][pAccent], 64, "None");
		}
		
		new string[32];
		for(new i = 0; i < MAX_LSPD_DIVISIONS; i++)
		{
			new i2 = i + 1;
			format(string, sizeof(string), "Division%d", i2);
			PlayerInfo[playerid][pDivision][i] = cache_get_field_content_int(0, string);
		}

		// Load inventory
		new InventoryFetch[1024];
		new InventoryItemID[MAX_INV_SLOTS][5];
		new InventoryItemQuantity[MAX_INV_SLOTS][5];
		new InventoryItemEx[MAX_INV_SLOTS][5];
		new InventoryItemSerial[MAX_INV_SLOTS][11];

		cache_get_field_content(0, "InventoryItemID", InventoryFetch);
		split(InventoryFetch, InventoryItemID, ',');

		cache_get_field_content(0, "InventoryItemQuantity", InventoryFetch);
		split(InventoryFetch, InventoryItemQuantity, ',');

		cache_get_field_content(0, "InventoryItemEx", InventoryFetch);
		split(InventoryFetch, InventoryItemEx, ',');

		cache_get_field_content(0, "InventoryItemSerial", InventoryFetch);
		split(InventoryFetch, InventoryItemSerial, ',');

		for(new i = 0; i < MAX_INV_SLOTS; i++)
		{
			if(strval(InventoryItemID[i]) != 0)
			{
				GiveInvItem(playerid, strval(InventoryItemID[i]), strval(InventoryItemQuantity[i]), strval(InventoryItemEx[i]), strval(InventoryItemSerial[i]));
			}
		}

		// Player Contacts
		new ContactFetch[MAX_PLAYER_CONTACTS * 32 + MAX_PLAYER_CONTACTS];
		new ContactNameSplit[MAX_PLAYER_CONTACTS][32];
		new ContactNumberSplit[MAX_PLAYER_CONTACTS][32];

		cache_get_field_content(0, "ContactNames", ContactFetch);
		split(ContactFetch, ContactNameSplit, ',');

		cache_get_field_content(0, "ContactNumbers", ContactFetch);
		split(ContactFetch, ContactNumberSplit, ',');

		for(new i = 0; i < MAX_PLAYER_CONTACTS; i++)
		{
			format(PlayerContacts[playerid][i][pContactName], 32, "%s", ContactNameSplit[i]);
			format(PlayerContacts[playerid][i][pContactNumber], 32, "%s", ContactNumberSplit[i]);
		}

		// Achievement Loading
		new AchievementFetch[MAX_ACHIEVEMENTS * 3 + MAX_ACHIEVEMENTS];
		new Achievements[MAX_ACHIEVEMENTS][8];

		cache_get_field_content(0, "Achievements", AchievementFetch);
		split(AchievementFetch, Achievements, ',');

		for(new i = 0; i < MAX_ACHIEVEMENTS; i++)
		{
		    PlayerInfo[playerid][pAch][i] = strval(Achievements[i]);
		}
	}
	//==========//
	SetPVarInt(playerid,"PlayerLogged", 2);

	CallRemoteFunction("OnLoginInit", "ii", playerid, 1);
	SetSlidedMoneyBar(playerid);

	CheckIfBanned(playerid);
	return 1;
}
//============================================//
public OnPlayerDataSave(playerid)
{
	if(IsPlayerNPC(playerid)) return true;
    if(GetPVarInt(playerid, "PlayerLogged") != 1) return true;
    if(PlayerInfo[playerid][pArcade] != 0) return 1;

    printf("SAVING PLAYER DATA... (%s [ID: %i])", PlayerInfo[playerid][pUsername], playerid);

   	if(GetPVarInt(playerid, "Model") == 0 && GetPVarInt(playerid, "Sex") == 0 && GetPVarInt(playerid, "Age") == 0 && GetPVarInt(playerid, "Tut") == 1)
   	{
   	    KickPlayer(playerid, "There is something wrong with your account, please contact an administrator.");
   	}
   	else
   	{
		new savename[24];
		GetPlayerName(playerid, savename, 24);

		new query[4096];
		new Float:health;
		new Float:armour,
		Float:x,
		Float:y,
		Float:z,
		world = GetPlayerVirtualWorld(playerid),
		interior = GetPlayerInterior(playerid);
		//==========//
		GetPlayerPos(playerid,x,y,z); GetPlayerHealth(playerid,health); GetPlayerArmourEx(playerid,armour);
		if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
	    {
	        SetPVarFloat(playerid, "PosX", x); SetPVarFloat(playerid, "PosY", y); SetPVarFloat(playerid, "PosZ", z);
			SetPVarFloat(playerid, "Health", health); SetPVarFloat(playerid, "Armour", armour);
	        SetPVarInt(playerid, "Interior", interior); SetPVarInt(playerid, "World", world);
	    }

	    new forum_name[64];
	   	GetPVarString(playerid, "ForumName", forum_name, sizeof(forum_name));

		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET ForumName='%e' WHERE ID=%i",
		forum_name,
		PlayerInfo[playerid][pID]);
	    mysql_pquery(handlesql, query);


		//==========//
		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET Cash=%i, Bank=%i, Model=%i, Interior=%i, World=%i, Tut=%i, Age=%i, Sex=%i, PosX=%f, PosY=%f, PosZ=%f, Health=%f, Armour=%f WHERE ID=%i",
		GetPVarInt(playerid, "Cash"), GetPVarInt(playerid, "Bank"), GetPVarInt(playerid, "Model"),
		GetPVarInt(playerid, "Interior"), GetPVarInt(playerid, "World"),
	    GetPVarInt(playerid, "Tut"), GetPVarInt(playerid, "Age"), GetPVarInt(playerid, "Sex"),
	    GetPVarFloat(playerid, "PosX"), GetPVarFloat(playerid, "PosY"), GetPVarFloat(playerid, "PosZ"),
	    GetPVarFloat(playerid, "Health"), GetPVarFloat(playerid, "Armour"),
		PlayerInfo[playerid][pID]);
	    mysql_pquery(handlesql, query);

		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET Admin=%i, Helper=%i, Developer=%i, Reg=%i, Jailed=%i, Jailtime=%i, JailedUntil='%s', helpme=%d, ConnectTime=%i, ChatStyle=%i, HudCol=%d,PrimHol=%d,SecHol=%d,Bonus=%d WHERE ID=%i",
		GetPVarInt(playerid, "Admin"), GetPVarInt(playerid, "Helper"), GetPVarInt(playerid, "Developer"), GetPVarInt(playerid, "Reg"),
		GetPVarInt(playerid, "Jailed"), GetPVarInt(playerid, "Jailtime"), PlayerInfo[playerid][pJailedUntil], GetPVarInt(playerid, "helpmes"), GetPVarInt(playerid, "ConnectTime"), GetPVarInt(playerid, "ChatStyle"),
		GetPVarInt(playerid, "HudCol"),GetPVarInt(playerid, "PrimHol"),GetPVarInt(playerid, "SecHol"),GetPVarInt(playerid, "Bonus"),
		PlayerInfo[playerid][pID]);
		mysql_pquery(handlesql, query);

		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET DriveLic=%d, GunLic=%d, Medlic=%d, MaskID=%d, PlayerWeapon=%d, PlayerAmmo=%d, PlayerSerial=%d, AmmoType=%d WHERE ID=%i",
		GetPVarInt(playerid, "DriveLic"), GetPVarInt(playerid, "GunLic"), GetPVarInt(playerid, "MedLic"), GetPVarInt(playerid, "MaskID"),
		PlayerInfo[playerid][pPlayerWeapon], PlayerInfo[playerid][pPlayerAmmo], PlayerInfo[playerid][pPlayerSerial], PlayerInfo[playerid][pAmmoType],
		PlayerInfo[playerid][pID]);
		mysql_pquery(handlesql, query);

		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET Member=%d, Rank=%d, LockerRights=%d, JobReduce=%d, DonateRank=%d, Fightstyle=%d, HouseKey=%d, BizKey=%d, RentKey=%i, JobID=%d WHERE ID=%i",
		GetPVarInt(playerid, "Member"),GetPVarInt(playerid, "Rank"),GetPVarInt(playerid, "LockerRights"),GetPVarInt(playerid, "JobReduce"),GetPVarInt(playerid, "DonateRank"),GetPVarInt(playerid, "Fightstyle"),
		GetPVarInt(playerid, "HouseKey"),GetPVarInt(playerid, "BizKey"), GetPVarInt(playerid, "RentKey"), GetPVarInt(playerid, "Job"), 
		PlayerInfo[playerid][pID]);
		mysql_pquery(handlesql, query);

		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET WalkieFreq=%d,PhoneNum=%d,PayDay=%d,PayCheck=%d,CheckEarn=%d, Dead=%d, PaidRent=%d, Changes=%d, CarTicket=%d WHERE ID=%i",
		GetPVarInt(playerid, "WalkieFreq"),GetPVarInt(playerid, "PhoneNum"),GetPVarInt(playerid, "PayDay"),GetPVarInt(playerid, "PayCheck"),
		GetPVarInt(playerid, "CheckEarn"), GetPVarInt(playerid, "Dead"), GetPVarInt(playerid, "PaidRent"), GetPVarInt(playerid, "Changes"), GetPVarInt(playerid, "CarTicket"),
		PlayerInfo[playerid][pID]);
		mysql_pquery(handlesql, query);
		
		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET `Describe1`='%e', `Describe2`='%e', MonthDon=%d, MonthDonT=%d, AudioT=%d, Frights=%d, SpawnLocation=%d WHERE ID=%i",
		PlayerInfo[playerid][pDescribe], PlayerInfo[playerid][pDescribe2], GetPVarInt(playerid, "MonthDon"), GetPVarInt(playerid, "MonthDonT"),
		GetPVarInt(playerid, "AudioT"), GetPVarInt(playerid, "Frights"), GetPVarInt(playerid, "SpawnLocation"),
		PlayerInfo[playerid][pID]);
		mysql_pquery(handlesql, query);

		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET LicTime=%d, LicGuns=%d, Addiction=%d, DrugTime=%d, DrugHigh=%d, AutoReload=%d, AddictionID=%d, HouseEnter=%d, BizEnter=%d, IntEnter=%d, GarageEnter=%d, PaintUse=%d, WepSerial=%d WHERE ID=%i",
		GetPVarInt(playerid, "LicTime"), GetPVarInt(playerid, "LicGuns"),
    	GetPVarInt(playerid, "Addiction"), GetPVarInt(playerid, "DrugTime"), GetPVarInt(playerid, "DrugHigh"), GetPVarInt(playerid, "AutoReload"),GetPVarInt(playerid, "AddictionID"),
    	GetPVarInt(playerid, "HouseEnter"), GetPVarInt(playerid, "BizEnter"), GetPVarInt(playerid, "IntEnter"), GetPVarInt(playerid, "GarageEnter"), GetPVarInt(playerid, "PaintUse"), GetPVarInt(playerid, "WepSerial"), 
    	PlayerInfo[playerid][pID]);
		mysql_pquery(handlesql, query);

        mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET Wound_T=%d, Wound_A=%d, Wound_L=%d, Kills=%d, Deaths=%d, UpgDelay=%d, Forbid=%d WHERE ID=%i",
		GetPVarInt(playerid, "Wound_T"), GetPVarInt(playerid, "Wound_A"), GetPVarInt(playerid, "Wound_L"),
		GetPVarInt(playerid, "Kills"), GetPVarInt(playerid, "Deaths"), GetPVarInt(playerid, "UpgDelay"), GetPVarInt(playerid, "Forbid"), 
		PlayerInfo[playerid][pID]);
		mysql_pquery(handlesql, query);
		
		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET MarriedTo='%e', Suspend=%d, Accent='%e', FDSubRank='%e', TogUnhol=%d, WalkStyle=%i WHERE ID=%i", PlayerInfo[playerid][pMarriedTo],
		GetPVarInt(playerid, "Suspend"),
		PlayerInfo[playerid][pAccent],
		PlayerInfo[playerid][pFDSubRank],
		GetPVarInt(playerid, "TogUnhol"),
		GetPVarInt(playerid, "WalkStyle"),
		PlayerInfo[playerid][pID]);
		mysql_pquery(handlesql, query);
		
		for(new i = 0; i < MAX_LSPD_DIVISIONS; i++)
		{
		    mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET Division%d=%d WHERE ID=%i",
				i + 1, PlayerInfo[playerid][pDivision][i], 
				PlayerInfo[playerid][pID]);
			mysql_pquery(handlesql, query);
	    }

	    // Saving inventory
		new InventoryItemID[MAX_INV_SLOTS * 5];
		new InventoryItemQuantity[MAX_INV_SLOTS * 5];
		new InventoryItemEx[MAX_INV_SLOTS * 5];
		new InventoryItemSerial[MAX_INV_SLOTS * 11];

		new count = 0;
		for(new i = 0; i < MAX_INV_SLOTS; i++)
		{
			if(PlayerInfo[playerid][pInvItem][i] != 0)
			{
				if(count == 0)
				{
			    	format(InventoryItemID, sizeof(InventoryItemID), "%d", PlayerInfo[playerid][pInvItem][i]);
			    	format(InventoryItemQuantity, sizeof(InventoryItemQuantity), "%d", PlayerInfo[playerid][pInvQ][i]);
			    	format(InventoryItemEx, sizeof(InventoryItemEx), "%d", PlayerInfo[playerid][pInvEx][i]);
			    	format(InventoryItemSerial, sizeof(InventoryItemSerial), "%d", PlayerInfo[playerid][pInvS][i]);
			    }
			    else
			    {
			    	format(InventoryItemID, sizeof(InventoryItemID), "%s,%d", InventoryItemID, PlayerInfo[playerid][pInvItem][i]);
			    	format(InventoryItemQuantity, sizeof(InventoryItemQuantity), "%s,%d", InventoryItemQuantity, PlayerInfo[playerid][pInvQ][i]);
			    	format(InventoryItemEx, sizeof(InventoryItemEx), "%s,%d", InventoryItemEx, PlayerInfo[playerid][pInvEx][i]);
			    	format(InventoryItemSerial, sizeof(InventoryItemSerial), "%s,%d", InventoryItemSerial, PlayerInfo[playerid][pInvS][i]);
				}
				count++;
			}
		}

		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET InventoryItemID='%e', InventoryItemQuantity='%e', InventoryItemEx='%e', InventoryItemSerial='%e' WHERE ID=%i",
		InventoryItemID, InventoryItemQuantity, InventoryItemEx, InventoryItemSerial, 
		PlayerInfo[playerid][pID]);
 		mysql_pquery(handlesql, query);
		
		// Save Achievements
		new coordsstring[256];
		for(new i = 0; i < MAX_ACHIEVEMENTS; i++)
		{
			if(i == 0)
			{
		    	format(coordsstring, 256, "%d", PlayerInfo[playerid][pAch][i]);
		    }
		    else
		    {
		    	format(coordsstring, 256, "%s,%d", coordsstring, PlayerInfo[playerid][pAch][i]);
		    }
		}
		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET Achievements='%e' WHERE ID=%i", coordsstring, 
		PlayerInfo[playerid][pID]);
		mysql_pquery(handlesql, query);
		
		// Save contacts
		new ContactNames[MAX_PLAYER_CONTACTS * 32 + MAX_PLAYER_CONTACTS];
		new ContactNumbers[MAX_PLAYER_CONTACTS * 32 + MAX_PLAYER_CONTACTS];

		count = 0;
		for(new i = 0; i < MAX_PLAYER_CONTACTS; i++)
		{
			if(strlen(PlayerContacts[playerid][i][pContactNumber]) != 0 || strlen(PlayerContacts[playerid][i][pContactName]) != 0)
			{
				if(count == 0)
				{
			    	format(ContactNames, sizeof(ContactNames), "%s", PlayerContacts[playerid][i][pContactName]);
			    	format(ContactNumbers, sizeof(ContactNumbers), "%s", PlayerContacts[playerid][i][pContactNumber]);
			    }
			    else
			    {
			    	format(ContactNames, sizeof(ContactNames), "%s,%s", ContactNames, PlayerContacts[playerid][i][pContactName]);
			    	format(ContactNumbers, sizeof(ContactNumbers), "%s,%s", ContactNumbers, PlayerContacts[playerid][i][pContactNumber]);
				}
				count++;
			}
		}

		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET ContactNames='%e', ContactNumbers='%e' WHERE ID=%i", ContactNames, ContactNumbers, PlayerInfo[playerid][pID]);
 		mysql_pquery(handlesql, query);
		//==========//
		SaveToys(playerid);
		//SetSpawnInfo(playerid, 0, GetPVarInt(playerid,"Model"), GetPVarFloat(playerid, "PosX"),GetPVarFloat(playerid, "PosY"),GetPVarFloat(playerid, "PosZ"), 0.0, 0, 0, 0, 0, 0, 0);
	}
	return 1;
}
//============================================//
forward OnPlayerRegister(playerid, password[]);
public OnPlayerRegister(playerid, password[])
{
	new query[2048];
	if(IsPlayerConnected(playerid))
	{
	    if(GetPVarInt(playerid, "AccountExist") == 0)
	    {
	    	new hashpass[129], input[129];
			format(hashpass, sizeof(hashpass), "%s3ca827d65b48291545b", password);
			mysql_escape_string(hashpass, input);
			WP_Hash(hashpass, sizeof(hashpass), input);

			new forum_name[64];
			GetPVarString(playerid, "ForumName", forum_name, sizeof(forum_name));

	    	mysql_format(handlesql, query, sizeof(query), "INSERT INTO accounts (Name, ForumName, Pass, Cash, Bank, Model, Age, Sex, PosX, PosY, PosZ, Health) VALUES ('%s', '%s', '%s', 300, 0, 26, %i, %i, 1642.7285, -2240.5591, 13.4945, 50.0)", 
	    		PlayerInfo[playerid][pUsername], forum_name, hashpass, GetPVarInt(playerid, "Age"), GetPVarInt(playerid, "Sex"));
	        mysql_pquery(handlesql, query, "OnPlayerRegistered", "i", playerid);
	    }
	    else KickPlayer(playerid, "Unable to register, account exists!");
	}
	return 1;
}

forward OnPlayerRegistered(playerid);
public OnPlayerRegistered(playerid)
{
	//DeletePVar(playerid, "Registering");
	//DeletePVar(playerid, "RegistrationQuestion");

	SetPVarInt(playerid, "AccountExist", 1);
	CallRemoteFunction("OnPlayerLogin", "ii", playerid, 1);
	return 1;
}
//============================================//
/*public OnPlayerLogin(playerid, password[], type)
{
	if(GetPVarInt(playerid, "PlayerLogged") != 0) return true;
    new string[128];
	format(string, sizeof(string), "%s/%s.ini", ACC_DB, PlayerInfo[playerid][pUsername]);
	if(type == 0) Hash(password);
    if(strcmp(DOF2_GetString(string, "Key"), password, true) == 0)
    {
        new ip[128];
	    GetPlayerIp(playerid, ip, 128);
	    DOF2_SetString(string, "IP", ip);
		// Load Ints //
		SetPVarInt(playerid, "Cash", DOF2_GetInt(string, "Cash"));
		SetPVarInt(playerid, "Bank", DOF2_GetInt(string, "Bank"));
		SetPVarInt(playerid, "Model", DOF2_GetInt(string, "Model"));
		SetPVarInt(playerid, "Int", DOF2_GetInt(string, "Int"));
		SetPVarInt(playerid, "World", DOF2_GetInt(string, "World"));
		SetPVarInt(playerid, "Tut", DOF2_GetInt(string, "Tut"));
		SetPVarInt(playerid, "Age", DOF2_GetInt(string, "Age"));
		SetPVarInt(playerid, "Sex", DOF2_GetInt(string, "Sex"));
		// Load Floats //
		SetPVarFloat(playerid, "PosX", DOF2_GetFloat(string, "PosX"));
		SetPVarFloat(playerid, "PosY", DOF2_GetFloat(string, "PosY"));
		SetPVarFloat(playerid, "PosZ", DOF2_GetFloat(string, "PosZ"));
		SetPVarFloat(playerid, "Health", DOF2_GetFloat(string, "Health"));
		SetPVarFloat(playerid, "Armour", DOF2_GetFloat(string, "Armour"));
		// Load Strings //
		//strmid(PlayerInfo[playerid][pAdmName], DOF2_GetString(string, "AdmName"), 0, strlen(DOF2_GetString(string, "AdmName")), 255);
		//==============//
		SetPVarInt(playerid,"PlayerLogged", 2);
		if(GetPVarInt(playerid, "Tut") == 0)
	    {
	        CallRemoteFunction("CharCreation", "i", playerid);
	        return true; // Block any leaks/scripting problems...
	    }
	    CallRemoteFunction("FadeScreen","ii",playerid, 1);
    }
    else
    {
	    if(GetPVarInt(playerid, "WrongPassword") >= 5)
	    {
		    Kick(playerid);
	    }
	    else
	    {
	        SetPVarInt(playerid, "WrongPassword", 1+GetPVarInt(playerid, "WrongPassword"));
	        new amount = 5 - GetPVarInt(playerid, "WrongPassword");
	        format(string, sizeof(string),"Invalid password (%d tries left).", amount);
	        SendClientMessage(playerid,COLOR_ERROR,string);
	        ShowPlayerDialogEx(playerid,1,DIALOG_STYLE_PASSWORD,"Server Account","An existing account is using your playername, please login to the account!","Login", "");
	    }
    }
	return 1;
}*/
//============================================//
/*public OnPlayerRegister(playerid, password[])
{
	if(IsPlayerConnected(playerid))
	{
	    new string[128], passwordex[128];
	    format(string, sizeof(string), "%s/%s.ini", ACC_DB, PlayerInfo[playerid][pUsername]);
		if(!DOF2_FileExists(string))
		{
		    DOF2_CreateFile(string);
		    format(passwordex, 128, "%s", password);
		    Hash(passwordex);
		    DOF2_SetString(string, "Key", passwordex);
		    DOF2_SetInt(string, "Cash", 500);
	    	DOF2_SetInt(string, "Bank", 0);
	    	DOF2_SetInt(string, "Model", 26);
	    	DOF2_SetInt(string, "Tut", 0);
	    	DOF2_SetInt(string, "Age", 18);
	    	DOF2_SetInt(string, "Sex", 1);
    		DOF2_SetFloat(string, "Health", 50.0);
		    DOF2_SetFloat(string, "PosX", 1642.7285);
    		DOF2_SetFloat(string, "PosY", -2240.5591);
    		DOF2_SetFloat(string, "PosZ", 13.4945);
    		DOF2_WriteFile();
		    CallRemoteFunction("OnPlayerLogin","isi",playerid,password,0);
		}
		else
		{
		    SendClientMessage(playerid, COLOR_ERROR, "Unable to register, account exists.");
		    Kick(playerid);
		}
	}
	return 1;
}*/
//============================================//
/*public OnPlayerDataSave(playerid)
{
    if(IsPlayerConnected(playerid) && GetPVarInt(playerid, "PlayerLogged") == 1)
    {
	    new string[128];
	    format(string, sizeof(string), "%s/%s.ini", ACC_DB, PlayerInfo[playerid][pUsername]);
		if(DOF2_FileExists(string))
		{
			new Float:health,
			Float:armour,
			Float:x,
			Float:y,
			Float:z,
			world = GetPlayerVirtualWorld(playerid),
			interior = GetPlayerInterior(playerid),
			Float:angle;
			//===================================//
            GetPlayerPos(playerid,x,y,z); GetPlayerHealth(playerid,health); GetPlayerArmourEx(playerid,armour);
            if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
            {
                SetPVarFloat(playerid, "PosX", x); SetPVarFloat(playerid, "PosY", y); SetPVarFloat(playerid, "PosZ", z);
			    SetPVarFloat(playerid, "Health", health); SetPVarFloat(playerid, "Armour", armour);
                SetPVarInt(playerid, "Int", interior); SetPVarInt(playerid, "World", world);
            }
            GetPlayerFacingAngle(playerid,angle);
            SetPVarFloat(playerid, "Angle", angle);
			for(new slot = 0; slot < 13; slot++)
			{
   				GetPlayerWeaponData(playerid, slot, wep[slot], ammo[slot]);
     			if(wep[slot] != 0 && ammo[slot] != 0 && PlayerWeapons[playerid][wep[slot]] == 1)
      			{
       			    PlayerInfo[playerid][pWeapon][slot]=wep[slot];
					PlayerInfo[playerid][pAmmo][slot]=ammo[slot];
        		}
        		else
        		{
        		    PlayerInfo[playerid][pWeapon][slot]=0;
					PlayerInfo[playerid][pAmmo][slot]=0;
        		}
			}
			// Ints //
	    	DOF2_SetInt(string, "Cash", GetPVarInt(playerid, "Cash"));
	    	DOF2_SetInt(string, "Bank", GetPVarInt(playerid, "Bank"));
	    	DOF2_SetInt(string, "Model", GetPVarInt(playerid, "Model"));
	    	DOF2_SetInt(string, "Tut", GetPVarInt(playerid, "Tut"));
	    	DOF2_SetInt(string, "Age", GetPVarInt(playerid, "Age"));
	    	DOF2_SetInt(string, "Sex", GetPVarInt(playerid, "Sex"));
            // Floats //
            DOF2_SetFloat(string, "PosX", GetPVarFloat(playerid, "PosX"));
    		DOF2_SetFloat(string, "PosY", GetPVarFloat(playerid, "PosY"));
    		DOF2_SetFloat(string, "PosZ", GetPVarFloat(playerid, "PosZ"));
    		DOF2_SetFloat(string, "Health", GetPVarFloat(playerid, "Health"));
    		DOF2_SetFloat(string, "Armour", GetPVarFloat(playerid, "Armour"));
    		// Strings //
    		//DOF2_SetString(string,  "AdmName", PlayerInfo[playerid][pAdmName]);
		}
    }
	return 0;
}*/
//============================================//
public OnLoginInit(playerid, type)
{
	new string[128], query[256];
	switch(type)
	{
	    case 1:
	    {
	        if(GetPVarInt(playerid,"Jailed") == 0)
	        {
	            if(GetPVarInt(playerid,"Dead") == 0)
	            {
			        if(GetPVarInt(playerid,"SpawnLocation") == 1)
			        {
			            new count = 0;
			            if(GetPVarInt(playerid,"HouseKey") != 0 || GetPVarInt(playerid,"BizKey") != 0)
			            {
			            	count++;
			            }
	                    
	                    if(GetPVarInt(playerid,"Member") == FACTION_LSPD || GetPVarInt(playerid,"Member") == FACTION_LSFD || GetPVarInt(playerid,"Member") == FACTION_LSG)
	                    {
	                    	count ++;
	                    }

	                    if(count != 0)
	                    {
			                CallRemoteFunction("SelectSpawnpoint","i", playerid);
			                TextDrawShowForPlayer(playerid, SpawnDraw[4]);
			                TextDrawShowForPlayer(playerid, SpawnDraw[5]);
			                return 1;
			            }
			        }
			    }
			}

	    	TextDrawHideForPlayer(playerid, SideBar1);
	        TextDrawHideForPlayer(playerid, SideBar2);
	        ClearChatbox(playerid, 50);
	        TogglePlayerSpectating(playerid, 0);

	        SetSpawnInfo(playerid, 0, GetPVarInt(playerid,"Model"), GetPVarFloat(playerid, "PosX"),GetPVarFloat(playerid, "PosY"),GetPVarFloat(playerid, "PosZ"), 0.0, 0, 0, 0, 0, 0, 0);
	        SpawnPlayer(playerid);

	        TogglePlayerControllable(playerid, false);
			Streamer_Update(playerid);

	        SetPlayerSkinEx(playerid, GetPVarInt(playerid,"Model"));
            SetPlayerPosEx(playerid, GetPVarFloat(playerid, "PosX"), GetPVarFloat(playerid, "PosY"), GetPVarFloat(playerid, "PosZ"));
            SetPlayerInterior(playerid, GetPVarInt(playerid, "Interior"));
	        SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "World"));
	        SetPlayerScore(playerid, GetPVarInt(playerid, "ConnectTime"));

            mysql_format(handlesql, string, sizeof(string), "SELECT * FROM `adjust` WHERE `name`='%e'", PlayerInfo[playerid][pUsername]);
			mysql_pquery(handlesql, string, "LoadHolsterSQL", "d", playerid);

            foreach(new i : Player)
    		{
			    PlayerInfo[playerid][pBlockPM][i] = 0;
			}

            for(new i = 0; i < 6; i++)
			{
			    TextDrawHideForPlayer(playerid, WoundDraw[i]);
			}

            for(new i = 0; i < 9; i++)
            {
                if(IsPlayerAttachedObjectSlotUsed(playerid, i))
				{
				    RemovePlayerAttachedObject(playerid, i);
				}
            }

            for(new o = 0; o < 4; o++)
	        {
	            PlayerTextDrawHide(playerid, PGBar[o][playerid]);
            }

            if(GetPVarInt(playerid, "WepSerial") == 0)
			{
			    new rands = 1000 + random(999999);
	            SetPVarInt(playerid, "WepSerial", rands);
			}

            SetTimerEx("OnLoginInit", 1000, false, "ii", playerid, 2);
	    }
	    case 2:
	    {
    	    SetCameraBehindPlayer(playerid);
    	    new Float:x, Float:y, Float:z;

            GetPlayerCameraPos(playerid, x, y, z);
            if(z > 15.3)
            {
                PlayerInfo[playerid][pHacker]=1;
            }

    	    StopAudioStreamForPlayerEx(playerid);
    	    SetPlayerColor(playerid, COLOR_WHITE);
    	    if(GetPVarFloat(playerid, "Health") > 0.0) SetPlayerHealthEx(playerid,GetPVarFloat(playerid, "Health"));
    	    if(GetPVarFloat(playerid, "Armour") > 0.0) SetPlayerArmourEx(playerid,GetPVarFloat(playerid, "Armour"));
    	    //==============================//}
    	    PreloadAnimLib(playerid,"CRACK"); PreloadAnimLib(playerid,"CARRY");
		    PreloadAnimLib(playerid,"SWEET"); PreloadAnimLib(playerid,"PED");
		    PreloadAnimLib(playerid,"RAPPING"); PreloadAnimLib(playerid,"COP_AMBIENT");
		    PreloadAnimLib(playerid,"DEALER"); PreloadAnimLib(playerid,"BEACH");
		    PreloadAnimLib(playerid,"ON_LOOKERS"); PreloadAnimLib(playerid,"SUNBATHE");
		    PreloadAnimLib(playerid,"RIOT"); PreloadAnimLib(playerid,"SHOP");
		    PreloadAnimLib(playerid,"PARACHUTE"); PreloadAnimLib(playerid,"GHANDS");
		    PreloadAnimLib(playerid,"MEDIC"); PreloadAnimLib(playerid,"MISC");
		    PreloadAnimLib(playerid,"SWAT"); PreloadAnimLib(playerid,"GANGS");
		    PreloadAnimLib(playerid,"BOMBER"); PreloadAnimLib(playerid,"FOOD");
		    PreloadAnimLib(playerid,"PARK"); PreloadAnimLib(playerid,"GRAVEYARD");
		    PreloadAnimLib(playerid,"KISSING"); PreloadAnimLib(playerid,"KNIFE");
		    PreloadAnimLib(playerid,"FINALE"); PreloadAnimLib(playerid,"SMOKING");
		    PreloadAnimLib(playerid,"BLOWJOBZ"); PreloadAnimLib(playerid,"SNM");
		    PreloadAnimLib(playerid,"LOWRIDER"); PreloadAnimLib(playerid,"DANCING");
		    PreloadAnimLib(playerid,"ROB_BANK"); PreloadAnimLib(playerid,"POLICE");
		    PreloadAnimLib(playerid,"SILENCED"); PreloadAnimLib(playerid,"BD_FIRE");
		    //==============================//
		    SetPlayerSkillLevel(playerid,WEAPONSKILL_PISTOL,200);
	        SetPlayerSkillLevel(playerid,WEAPONSKILL_SAWNOFF_SHOTGUN,200);
	        SetPlayerSkillLevel(playerid,WEAPONSKILL_MICRO_UZI,200);
	        //==============================//}
		    //TextDrawShowForPlayer(playerid,MoneyDraw2);
		    TextDrawShowForPlayer(playerid,ServerDraw);
		    //==============================//
		    MoneyDraw[playerid] = CreatePlayerTextDraw(playerid, 497.000000,77.000000,"~g~$00000000");
		    PlayerTextDrawAlignment(playerid, MoneyDraw[playerid],0);
		    PlayerTextDrawBackgroundColor(playerid, MoneyDraw[playerid],0x000000ff);
		    PlayerTextDrawFont(playerid, MoneyDraw[playerid],3);
		    PlayerTextDrawLetterSize(playerid, MoneyDraw[playerid],0.599999,2.200000);
		    PlayerTextDrawColor(playerid, MoneyDraw[playerid],0xffffffff);
		    PlayerTextDrawSetOutline(playerid, MoneyDraw[playerid],1);
		    PlayerTextDrawSetProportional(playerid, MoneyDraw[playerid],1);
		    PlayerTextDrawSetShadow(playerid, MoneyDraw[playerid],1);
		    //PlayerTextDrawShow(playerid,MoneyDraw[playerid]);
		    LocationDraw[playerid] = CreatePlayerTextDraw(playerid, 38.000000, 329.000000, " ");
		    PlayerTextDrawBackgroundColor(playerid, LocationDraw[playerid], 255);
		    PlayerTextDrawFont(playerid, LocationDraw[playerid], 2);
		    PlayerTextDrawLetterSize(playerid, LocationDraw[playerid], 0.280000, 1.000000);
		    PlayerTextDrawColor(playerid, LocationDraw[playerid], -1);
		    PlayerTextDrawSetOutline(playerid, LocationDraw[playerid], 0);
		    PlayerTextDrawSetProportional(playerid, LocationDraw[playerid], 1);
		    PlayerTextDrawSetShadow(playerid, LocationDraw[playerid], 1);
		    format(string, sizeof(string),"~w~%s", GetPlayerArea(playerid));
		    PlayerTextDrawSetString(playerid, PlayerText:LocationDraw[playerid], string);
		    PlayerTextDrawShow(playerid, LocationDraw[playerid]);
		    //==============================//
		    CallRemoteFunction("PrintHud","i",playerid);
		    //==============================//
		    mysql_format(handlesql, query, sizeof(query), "UPDATE `accounts` SET `Online` = 1 WHERE `Name`='%e'", PlayerInfo[playerid][pUsername]);
            mysql_pquery(handlesql, query);
		    //==============================//
		    if(PlayerInfo[playerid][pPlayerWeapon] > 0 && PlayerInfo[playerid][pPlayerAmmo] > 0)
		    {
		        GivePlayerWeaponEx(playerid, PlayerInfo[playerid][pPlayerWeapon], PlayerInfo[playerid][pPlayerAmmo]);
		    }
		    //==============================//
		    new mem = GetPVarInt(playerid, "Member");
		    if(mem > 0)
		    {
				format(string, sizeof(string),"FACTION MOTD: %s", FactionInfo[mem][fMOTD]);
				if(strlen(FactionInfo[mem][fMOTD]) >= 2) SCM(playerid, 0xE65A5AAA, string);
		    }
		    //==============================//
		    switch(GetPVarInt(playerid, "FightStyle"))
            {
                case 0: SetPlayerFightingStyle(playerid,FIGHT_STYLE_NORMAL);
                case 1: SetPlayerFightingStyle(playerid,FIGHT_STYLE_BOXING);
                case 2: SetPlayerFightingStyle(playerid,FIGHT_STYLE_KUNGFU);
                case 3: SetPlayerFightingStyle(playerid,FIGHT_STYLE_KNEEHEAD);
                case 4: SetPlayerFightingStyle(playerid,FIGHT_STYLE_GRABKICK);
                case 5: SetPlayerFightingStyle(playerid,FIGHT_STYLE_ELBOW);
            }
		    //==============================//
		    if(GetPVarInt(playerid, "Dead") == 1 || GetPVarInt(playerid, "Dead") == 2)
		    {
			    ResetPlayerWeapons(playerid);
			    TogglePlayerControllableEx(playerid, false);
			    SetPVarInt(playerid, "Dead", 2);
			    SetPlayerPosEx(playerid,GetPVarFloat(playerid, "PosX"),GetPVarFloat(playerid, "PosY"),GetPVarFloat(playerid, "PosZ"));
				SetPlayerFacingAngle(playerid,GetPVarFloat(playerid, "Angle"));
				SetPlayerInterior(playerid,GetPVarInt(playerid, "Interior"));
				SetPlayerVirtualWorld(playerid,GetPVarInt(playerid, "World"));
				SetCameraBehindPlayer(playerid);
	            SendClientMessage(playerid,COLOR_WHITE,"Type (/accept death) to continue.");
	            SetPlayerHealthEx(playerid,1.0);
	            GivePlayerWeaponEx(playerid, PlayerInfo[playerid][pPlayerWeapon], PlayerInfo[playerid][pPlayerAmmo]);
	            new rand = random(5);
				switch(rand)
				{
				    case 0: ApplyAnimationEx(playerid, "ped", "FLOOR_hit", 4.0, 0, 1, 1, 1, -1);
			        case 1: ApplyAnimationEx(playerid, "ped", "FLOOR_hit_f", 4.0, 0, 1, 1, 1, -1);
			        case 2: ApplyAnimationEx(playerid, "ped", "KO_shot_front", 4.0, 0, 1, 1, 1, -1);
			        case 3: ApplyAnimationEx(playerid, "ped", "KO_shot_stom", 4.0, 0, 1, 1, 1, -1);
	                case 4: ApplyAnimationEx(playerid, "ped", "BIKE_fall_off", 4.0, 0, 1, 1, 1, -1);
				    default: ApplyAnimationEx(playerid, "FINALE", "FIN_Land_Die", 4.0, 0, 1, 1, 1, -1);
				}
				if(GetPVarInt(playerid, "Admin") != 10) SetPVarInt(playerid, "DeathTime", GetCount()+60000);
			}
			else if(GetPVarInt(playerid, "Dead") == 3)
			{
			    DeathPlayer(playerid, "You need to rest to regain consciousness.");
			}
			else
			{
				TogglePlayerControllable(playerid, true);
			}
			//==============================//
			if(GetPVarInt(playerid, "Jailed") == 3)
			{
				new date[64], year, month, day, hour, minute, second;
				format(date, sizeof(date), PlayerInfo[playerid][pJailedUntil]);

				new temp_date[32];

				strmid(temp_date, date, 0, 4);
				year = strval(temp_date);

				strmid(temp_date, date, 5, 7);
				month = strval(temp_date);

				strmid(temp_date, date, 8, 10);
				day = strval(temp_date);

				strmid(temp_date, date, 13, 15);
				hour = strval(temp_date);

				strmid(temp_date, date, 16, 18);
				minute = strval(temp_date);

				strmid(temp_date, date, 19, 21);
				second = strval(temp_date);

				new year2, month2, day2;
				new hour2, minute2, second2;
				getdate(year2, month2, day2);
				gettime(hour2, minute2, second2);

				new bool:unjail = false;
				if(year2 > year)
				{
					unjail = true;
				}
				else if(year2 == year)
				{
					if(month2 > month)
					{
						unjail = true;
					}
					else if(month2 == month)
					{
						if(day2 > day)
						{
							unjail = true;
						}
						else if(day2 == day)
						{
							if(hour2 > hour)
							{
								unjail = true;
							}
							else if(hour2 == hour)
							{
								if(minute2 > minute)
								{
									unjail = true;
								}
								else if(minute2 == minute)
								{
									if(second2 >= second)
									{
										unjail = true;
									}
								}
							}
						}
					}
				}

				if(unjail == true)
				{
					SetPlayerPosEx(playerid, 1552.7952,-1675.5333,16.1953);
		    		SetPlayerInterior(playerid, 0);
		    		SendClientMessage(playerid, COLOR_WHITE,"You have paid your debt to society.");
		    		GameTextForPlayer(playerid, "~g~Freedom~n~~w~Try to be a better citizen", 5000, 1);
		    		TogglePlayerControllable(playerid, false);
		    		SetPlayerVirtualWorld(playerid, 0);
		    		SetPVarInt(playerid, "Jailed", 0);
		    		SetPVarInt(playerid, "Mute", 0);
		    		SetPVarInt(playerid, "Bail", 0);
		    		SetTimerEx("TogglePlayerControllableEx", 1500, false, "ii", playerid, true);
		    		Streamer_Update(playerid);

		    		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET JailedUntil='None' WHERE ID=%i", 
						PlayerInfo[playerid][pID]);
					mysql_pquery(handlesql, query);
				}
			}

			switch(GetPVarInt(playerid, "Jailed"))
			{
			    case 1:
			    {
			        SetPlayerPosEx(playerid, -1406.7714,1245.1904,1029.8984);
			        SetPlayerFacingAngle(playerid, 177.0008);
			        SetPlayerInterior(playerid, 16);
			        SetPlayerVirtualWorld(playerid, playerid + 1);
			        format(string, sizeof(string),"[JAILED] You are in admin-jail for %i minute(s) and %i second(s).", floatround(GetPVarInt(playerid, "JailTime") / 60, floatround_floor), GetPVarInt(playerid, "JailTime") % 60);
			        SCM(playerid, 0xE65A5AAA, string);
			        SetPVarInt(playerid, "Mute", 1);
			    }
			    case 2:
			    {
			    	TogglePlayerControllableEx(playerid, false);
					SetTimerEx("TogglePlayerControllableEx", 1500, false, "ii", playerid, true);

			        new ran = random(23) + 1;
					switch(ran)
					{
						case 1: SetPlayerPosEx(playerid, 1827.7781,-1731.1105,1002.5859);
						case 2: SetPlayerPosEx(playerid, 1830.8279,-1731.3368,1002.5859);
						case 3: SetPlayerPosEx(playerid, 1834.0068,-1731.9955,1002.5859);
						case 4: SetPlayerPosEx(playerid, 1837.2377,-1731.4010,1002.5859);
						case 5: SetPlayerPosEx(playerid, 1840.6808,-1732.0594,1002.5859);
						case 6: SetPlayerPosEx(playerid, 1843.5640,-1732.1567,1002.5859);
						case 7: SetPlayerPosEx(playerid, 1843.6758,-1711.5168,1002.5859);
						case 8: SetPlayerPosEx(playerid, 1840.5532,-1712.0255,1002.5859);
						case 9: SetPlayerPosEx(playerid, 1837.4333,-1712.2550,1002.5859);
						case 10: SetPlayerPosEx(playerid, 1834.1997,-1712.3615,1002.5859);
						case 11: SetPlayerPosEx(playerid, 1830.8928,-1712.3453,1002.5859);
						case 12: SetPlayerPosEx(playerid, 1827.8674,-1711.8103,1002.5859);
						case 13: SetPlayerPosEx(playerid, 1830.7412,-1731.9961,1006.1860);
						case 14: SetPlayerPosEx(playerid, 1827.4778,-1731.5767,1006.1860);
						case 15: SetPlayerPosEx(playerid, 1834.1556,-1731.6372,1006.1860);
						case 16: SetPlayerPosEx(playerid, 1837.2511,-1731.3159,1006.1860);
						case 17: SetPlayerPosEx(playerid, 1840.3973,-1731.7581,1006.1860);
						case 18: SetPlayerPosEx(playerid, 1843.6770,-1731.4130,1006.1860);
						case 19: SetPlayerPosEx(playerid, 1843.7390,-1711.2112,1006.1860);
						case 20: SetPlayerPosEx(playerid, 1840.5001,-1711.6290,1006.1860);
						case 21: SetPlayerPosEx(playerid, 1837.4194,-1711.3104,1006.1860);
						case 22: SetPlayerPosEx(playerid, 1834.2599,-1711.4907,1006.1860);
						case 23: SetPlayerPosEx(playerid, 1830.8385,-1711.5261,1006.1860);
						case 24: SetPlayerPosEx(playerid, 1827.8015,-1711.8590,1006.1860);
					}

			        SetPlayerInterior(playerid, 1);
			        SetPlayerVirtualWorld(playerid, 1);
			        
			        format(string, sizeof(string),"[JAILED] You are in prison for %i minute(s) and %i second(s).", floatround(GetPVarInt(playerid, "JailTime") / 60, floatround_floor), GetPVarInt(playerid, "JailTime") % 60);
			        SCM(playerid, 0xE65A5AAA, string);
			    }
			    case 3:
			    {
			    	TogglePlayerControllableEx(playerid, false);
					SetTimerEx("TogglePlayerControllableEx", 1500, false, "ii", playerid, true);

			        new ran = random(23) + 1;
					switch(ran)
					{
						case 1: SetPlayerPosEx(playerid, 1827.7781,-1731.1105,1002.5859);
						case 2: SetPlayerPosEx(playerid, 1830.8279,-1731.3368,1002.5859);
						case 3: SetPlayerPosEx(playerid, 1834.0068,-1731.9955,1002.5859);
						case 4: SetPlayerPosEx(playerid, 1837.2377,-1731.4010,1002.5859);
						case 5: SetPlayerPosEx(playerid, 1840.6808,-1732.0594,1002.5859);
						case 6: SetPlayerPosEx(playerid, 1843.5640,-1732.1567,1002.5859);
						case 7: SetPlayerPosEx(playerid, 1843.6758,-1711.5168,1002.5859);
						case 8: SetPlayerPosEx(playerid, 1840.5532,-1712.0255,1002.5859);
						case 9: SetPlayerPosEx(playerid, 1837.4333,-1712.2550,1002.5859);
						case 10: SetPlayerPosEx(playerid, 1834.1997,-1712.3615,1002.5859);
						case 11: SetPlayerPosEx(playerid, 1830.8928,-1712.3453,1002.5859);
						case 12: SetPlayerPosEx(playerid, 1827.8674,-1711.8103,1002.5859);
						case 13: SetPlayerPosEx(playerid, 1830.7412,-1731.9961,1006.1860);
						case 14: SetPlayerPosEx(playerid, 1827.4778,-1731.5767,1006.1860);
						case 15: SetPlayerPosEx(playerid, 1834.1556,-1731.6372,1006.1860);
						case 16: SetPlayerPosEx(playerid, 1837.2511,-1731.3159,1006.1860);
						case 17: SetPlayerPosEx(playerid, 1840.3973,-1731.7581,1006.1860);
						case 18: SetPlayerPosEx(playerid, 1843.6770,-1731.4130,1006.1860);
						case 19: SetPlayerPosEx(playerid, 1843.7390,-1711.2112,1006.1860);
						case 20: SetPlayerPosEx(playerid, 1840.5001,-1711.6290,1006.1860);
						case 21: SetPlayerPosEx(playerid, 1837.4194,-1711.3104,1006.1860);
						case 22: SetPlayerPosEx(playerid, 1834.2599,-1711.4907,1006.1860);
						case 23: SetPlayerPosEx(playerid, 1830.8385,-1711.5261,1006.1860);
						case 24: SetPlayerPosEx(playerid, 1827.8015,-1711.8590,1006.1860);
					}

			        SetPlayerInterior(playerid, 1);
			        SetPlayerVirtualWorld(playerid, 1);

			        format(string, sizeof(string),"[JAILED] You are in prison until %s.", PlayerInfo[playerid][pJailedUntil]);
			        SCM(playerid, 0xE65A5AAA, string);
			    }
			}
			//==============================//
			if(IsPlayerInRangeOfPoint(playerid, 15.0, 2233.0278,2457.1990,-7.4531+10.0)) // UNBUG DEALERSHIP SYSTEM
			{
		    	SetPlayerPosEx(playerid, 1529.6,-1691.2,13.3);
			    SetPlayerInterior(playerid,0);
			    SetPlayerVirtualWorld(playerid,0);
		        SendClientMessage(playerid, 0xFF000000, "You have been sent to Los Santos!.");
			}
			//==============================//
			LoadRadios(playerid);
			CallRemoteFunction("LoadHolsters","i",playerid);
			//==============================//
			if(GetPVarInt(playerid, "MonthDon") != 0)
			{
			    if(GetPVarInt(playerid, "MonthDonT") <= 0)
			    {
			        SetPVarInt(playerid, "MonthDon", 0);
			        SetPVarInt(playerid, "MonthDonT", 0);
			        scm(playerid, COLOR_ERROR, "Your monthly subscription has expired!");
			    }
			}
			if(GetPVarInt(playerid, "HouseEnter") != 0)
			{
			    HouseLights(GetPVarInt(playerid, "HouseEnter"));
			}

			if(GetPVarInt(playerid, "GarageEnter") != 0)
			{
            	mysql_format(handlesql, query, sizeof(query), "SELECT `ID` FROM `vehicles` WHERE `VirtualWorld`=%i AND `Interior`=%i", 
            		GetPVarInt(playerid, "GarageEnter"), HouseInfo[GetPVarInt(playerid, "GarageEnter")][gInterior]);
				mysql_pquery(handlesql, query, "vs_OnPlayerEnterGarage", "i", playerid);
			}
			//==============================//
			if(GetPVarInt(playerid, "Wound_T") > 0) PlayerWound(playerid, 1, 1);
			if(GetPVarInt(playerid, "Wound_A") > 0) PlayerWound(playerid, 2, 1);
			if(GetPVarInt(playerid, "Wound_L") > 0) PlayerWound(playerid, 3, 1);
			//==============================//
			SetPlayerTime(playerid, GMHour, GMMin);
			//==============================//

			SetPVarInt(playerid, "PlayerLogged", 1);
			SetSlidedMoneyBar(playerid);
			LoadPlayerToys(playerid);
			Streamer_Update(playerid);

			new laston[64];

			new Year, Month, Day;
			getdate(Year, Month, Day);

			format(laston, sizeof(laston), "%d-%02d-%02d", Year, Month, Day);

			mysql_format(handlesql, query, sizeof(query), "UPDATE `accounts` SET `LastOnDate`='%s' WHERE Name='%e'", laston, PlayerInfo[playerid][pUsername]);
			mysql_pquery(handlesql, query);

			new Hour, Minute, Second;
			gettime(Hour, Minute, Second);

			format(laston, sizeof(laston), "%02d:%02d:%02d", Hour, Minute, Second);

			mysql_format(handlesql, query, sizeof(query), "UPDATE `accounts` SET `LastOnTime`='%s' WHERE Name='%e'", laston, PlayerInfo[playerid][pUsername]);
			mysql_pquery(handlesql, query);

			// Kill the player vehicle despawn timer
		    for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
			{
				new temp_vehicleid = GetSpawnedVehicle(playerid, i);
				KillTimer(VehicleInfo[temp_vehicleid][vDespawnTimer]);
			}

			if(GetPVarInt(playerid, "RentKey") != 0)
			{
				KillTimer(VehicleInfo[GetPVarInt(playerid, "RentKey")][vDespawnTimer]);
			}

			foreach(new i : VehicleIterator)
			{
				if(VehicleInfo[i][vType] == VEHICLE_LSPD && strcmp(CopInfo[i][Owner], PlayerInfo[playerid][pUsername]) == 0)
				{
					KillTimer(VehicleInfo[i][vDespawnTimer]);
					break;
				}
			}

			new ip[16];
    		GetPlayerIp(playerid, PlayerInfo[playerid][pIP], 16);

    		foreach(new i : Player)
    		{
    			if(i != playerid)
    			{
	    			GetPlayerIp(i, ip, sizeof(ip));
	    			if(!strcmp(PlayerInfo[playerid][pIP], ip))
	    			{
	    				if(GetPVarInt(playerid, "Bot") != 1)
						{
		    				format(string, sizeof(string), "AdmWarn: %s (ID: %i) has connected to the server with the same IP as %s (ID: %i)", 
		    					PlayerInfo[playerid][pName], playerid, PlayerInfo[i][pName], i);
	                	    SendAdminMessage(COLOR_YELLOW,string);
                		}
	    			}
    			}
    		}

			if(GetPVarInt(playerid, "Tut") == 0)
			{
				if(GetPVarInt(playerid, "Bot") == 1)
				{
					SendClientMessage(playerid, COLOR_WHITE, "Logged in as a bot.");

					SetPlayerInterior(playerid, 1);
					SetPlayerPosEx(playerid, 167.5987,1120.2710,1080.9995);
					SetPlayerVirtualWorld(playerid, 5000+playerid);
					SetPlayerScore(playerid, random(200));

					new randphone = 1000 + random(9999999);
					SetPVarInt(playerid, "PhoneNum", randphone);

					GivePlayerMoneyEx(playerid, random(2500));
					SetPVarInt(playerid, "Bank", random(20000));

					SetPVarString(playerid, "ForumName", PlayerInfo[playerid][pName]);

					SetPlayerSkinEx(playerid, random(73)+1);
				}
				else
				{
					SetPVarInt(playerid, "Cash", 0);
					SetPVarInt(playerid, "Bank", 5000);
					SetPVarInt(playerid, "Interior", 0);
					SetPVarInt(playerid, "World", 0);
					SetPVarInt(playerid, "Tut", 1);
					SetPVarFloat(playerid, "PosX", 1642.7285);
					SetPVarFloat(playerid, "PosY", -2240.5591);
					SetPVarFloat(playerid, "PosZ", 13.4945);
					SetPVarFloat(playerid, "Health", 50.0);
					SetPVarFloat(playerid, "Armour", 0.0);
					GiveInvItem(playerid, 405, 1, 1);
					new randphone = 1000 + random(9999999);
					SetPVarInt(playerid, "PhoneNum", randphone);
					new randmask = 1 + random(999999);
					SetPVarInt(playerid, "MaskID", randmask);
					SendClientMessage(playerid, COLOR_WHITE, "Welcome to Project Reality Roleplay!");
					SendClientMessage(playerid, COLOR_WHITE, "All the information about the commands available to you are listed in /help.");
					SendClientMessage(playerid, COLOR_WHITE, "For any questions regarding the server use /helpme along with /ra to request");
					SendClientMessage(playerid, COLOR_WHITE, "any administrative assistance.");
					GivePlayerMoneyEx(playerid, 2000);

					SetPlayerSkinEx(playerid, PlayerInfo[playerid][pRegisterSkin]);
					DeletePVar(playerid, "Registering");
				}
			}

			if(GetPVarInt(playerid, "Admin") > 0 || GetPVarInt(playerid, "Helper") > 0)
			{
				new waiting = 0;

				foreach(new i : Player)
				{
					if(GetPVarInt(i, "Submitted") == 1)
					{
						waiting++;
					}
				}

				if(waiting > 0)
				{
					SendClientMessage(playerid, COLOR_WHITE, "Player(s) waiting to be reviewed:");
					foreach(new i : Player)
					{
						if(GetPVarInt(i, "Submitted") == 1)
						{
							format(string, sizeof(string), "REGISTRATON: %s [%s] (ID %i) has a submitted registration ticked. (/review %i)",
								GiveNameSpaceEx(PlayerInfo[i][pUsername]), GetLowercase(PlayerInfo[i][pUsername]), i, i);

							if(GetPVarInt(playerid, "Admin") > 0)
							{
								if(GetHelperCount() == 0)
								{
									SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
								}
							}
							else
							{
								SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							}
						}
					}
				}
			}

			ServerLog(LOG_LOG_IN, PlayerInfo[playerid][pUsername]);
		}
	}
	return 1;
}
//============================================//
forward OnSecurityCheck(playerid);
public OnSecurityCheck(playerid)
{
	if(playerid != INVALID_PLAYER_ID)
	{
		new rows, fields;
		cache_get_data(rows, fields, handlesql);
		if(rows)
		{
		    new fetch[256], ip[128];
		    GetPlayerIp(playerid, ip, 128);
		    cache_get_field_content(0, "SecPass", fetch);
		    strmid(PlayerInfo[playerid][pSec], fetch, 0, strlen(fetch), 255);
		    if(strlen(PlayerInfo[playerid][pSec]) <= 5) {
		    ShowPlayerDialogEx(playerid,460,DIALOG_STYLE_PASSWORD,"Security Password","For security purposes we are asking you to create a security password\npassword minimum length is 5-30 characters.","Register", "");
		    } else {
		        cache_get_field_content(0, "IP", fetch);
		        if(strcmp(fetch, ip, true) == 0) {
				LoadAccEx(playerid);
			    } else {
			    ShowPlayerDialogEx(playerid,461,DIALOG_STYLE_PASSWORD,"Security Login","You are logged in with a different IP address, please enter your security password!","Login", ""); }
			}
		}
	}
	return 1;
}
//============================================//
forward LoadAccEx(playerid);
public LoadAccEx(playerid)
{
	new query[256];
	mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `accounts` WHERE `Name`='%e'", PlayerInfo[playerid][pUsername]);
	mysql_pquery(handlesql, query, "OnAccountLoad", "dd", playerid, 0);
	return 1;
}
//============================================//
forward OnDeletedCheck(playerid);
public OnDeletedCheck(playerid)
{
	if(playerid != INVALID_PLAYER_ID)
	{
		new rows, fields;
		cache_get_data(rows, fields, handlesql);
		if(rows)
		{
		    if(cache_get_field_content_int(0, "deleted") != 0)
			{
			    scm(playerid, COLOR_ERROR, "ERROR: This character has been deleted.");
                KickPlayer(playerid, "Character deleted.");
		        return 1;
		    }
		}
	}
	return 1;
}
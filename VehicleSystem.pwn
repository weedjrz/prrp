/* === General Information ===

	1. Use the Iterator VehicleIterator in combination with foreach to loop through all spawned vehicles.
	2. Use VehicleInfo to access data of spawned vehicles.
	3. Differentiate VehicleID (SA:MP ID of vehicle in the list of all spawned vehicles) and DatabaseID (The automatically assigned ID used
	   to identify a vehicle in the set of all available vehicles - vID in enumerator vInfo)

*/

/* === Commands === */

COMMAND:v(playerid, params[]) {
    if(GetPVarInt(playerid, "PlayerLogged") == 0) return SendClientMessage(playerid, COLOR_WHITE, "You must be logged in to use this.");
    new type[30],
	    user,
	    price;

	if(sscanf(params, "s[30]I(-1)I(-1)", type, user, price))
	{
		SendClientMessage(playerid, COLOR_ERROR, "/v [usage]");
		SendClientMessage(playerid, COLOR_ERROR, "Spawn | Stats | Despawn | Repair | Park | Sell");
		SendClientMessage(playerid, COLOR_ERROR, "Sellto | Radio | Find | Lock | Corpse | Lights");
		SendClientMessage(playerid, COLOR_ERROR, "Breakin | Payinsurance | Trunk | Bomb");
		return 1;
	}
	
	if(strcmp(type, "spawn", true) == 0) {
  		//new vehicleID = IsPlayerVehicleSpawned(playerid);
        //if(vehicleID != -1) return SendClientMessage(playerid, COLOR_ERROR, "You already have a vehicle spawned.");
		new query[100];
		mysql_format(handlesql, query, sizeof(query), "SELECT `Model`, `Donate`, `Value` FROM `vehicles` WHERE `Owner` = '%e';", PlayerInfo[playerid][pUsername]);
		mysql_pquery(handlesql, query, "vs_OnPlayerSpawnsVehicle", "i", playerid);
	} 
	else if(strcmp(type, "stats", true) == 0)
	{
        if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_ERROR, "You have to be in a vehicle in order to do this.");
	    if(PlayerSpawnedVehicles(playerid) == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have a vehicle spawned.");

		new vehicleID = -1;
		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
		{
			new veh = GetSpawnedVehicle(playerid, i);
			if(GetPlayerVehicleID(playerid) == veh)
			{
				vehicleID = veh;
			}
		}

		if(vehicleID == -1) return SendClientMessage(playerid, COLOR_ERROR, "You have to be in your vehicle in order to do this.");

        new msg[256];

        SendClientMessage(playerid, -1, "_____________________________________________________");
        format(msg, sizeof(msg), "                                      {3366FF}%s", VehicleName[GetVehicleModel(vehicleID) - 400]);
        SendClientMessage(playerid, -1, msg);
        if(!IsNotAEngineCar(vehicleID))
        {
            format(msg, sizeof(msg), "Mileage: %.1f km | Battery Life: %d/%d | Engine Life: %d/%d | Fuel: %d/100", float(VehicleInfo[vehicleID][vMileage][1]) / 1000, VehicleInfo[vehicleID][vBattery][1], GetPerkMax(vehicleID, 2), VehicleInfo[vehicleID][vEngineStats][1], GetPerkMax(vehicleID, 1), VehicleInfo[vehicleID][vFuel]);
            SendClientMessage(playerid, -1, msg);
            format(msg, sizeof(msg), "Insurance: %d/3 | Lock Level: %d/3 | Alarm Level: %d/3 | License Plate: %s", VehicleInfo[vehicleID][vInsurance], VehicleInfo[vehicleID][vLockLvl], VehicleInfo[vehicleID][vAlarmLvl], VehicleInfo[vehicleID][vPlate]);
            SendClientMessage(playerid, -1, msg);
            format(msg, sizeof(msg), "Battery Upgrade: %s | Engine Upgrade: %s | Value: %s", YesNo(VehicleInfo[vehicleID][vBatLvl]), YesNo(VehicleInfo[vehicleID][vEngLvl]), FormatMoney(VehicleInfo[vehicleID][vValue]));
        	SendClientMessage(playerid, -1, msg);
            format(msg, sizeof(msg), "Locked: %s | Colors: %d/%d | Paint Job: %d", YesNo(VehicleInfo[vehicleID][vLock]), VehicleInfo[vehicleID][vColorOne], VehicleInfo[vehicleID][vColorTwo], VehicleInfo[vehicleID][vPaintJob]);
        	SendClientMessage(playerid, -1, msg);
        }
        else
        {
        	format(msg, sizeof(msg), "Locked: %s | Value: %s | Colors: %d - %d", YesNo(VehicleInfo[vehicleID][vLock]), FormatMoney(VehicleInfo[vehicleID][vValue]), VehicleInfo[vehicleID][vColorOne], VehicleInfo[vehicleID][vColorTwo], VehicleInfo[vehicleID][vPaintJob]);
        	SendClientMessage(playerid, -1, msg);
        }
		SendClientMessage(playerid, -1, "_____________________________________________________");
	}
	else if(strcmp(type, "lock", true) == 0)
	{
	    new Float:distance = VEHICLE_LOCK_RANGE;
		new vehicleID = -1;

		foreach(new i : VehicleIterator)
    	{
    		if(DoesPlayerHaveVehicleKey(playerid, VehicleInfo[i][vID]))
    		{
				new Float:pos[3];
				GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

				new temp_vehicleid = i;

				if(GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]) < VEHICLE_LOCK_RANGE)
				{
					if(distance > GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]))
					{
						distance = GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]);
						vehicleID = temp_vehicleid;
					}
				}
    		}
    	}

		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
    	{
    		new Float:pos[3];
    		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

    		new temp_vehicleid = GetSpawnedVehicle(playerid, i);

    		if(GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]) < VEHICLE_LOCK_RANGE)
    		{
    			if(distance > GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]))
	    		{
	    			distance = GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]);
	    			vehicleID = temp_vehicleid;
	    		}
    		}
    	}

    	if(vehicleID == -1) return SendClientMessage(playerid, COLOR_ERROR, "You have to be around one of your vehicles in order to lock it.");

    	switch(VehicleInfo[vehicleID][vLock])
    	{
			case 0:
			{
		    	foreach(new i2 : Player)
		    	{
			    	SetVehicleParamsForPlayer(vehicleID, i2, 0, 1);

       				if(GetPlayerVehicleID(i2) == vehicleID)
       				{
       					if(VehicleInfo[vehicleID][vModel] == 481 || VehicleInfo[vehicleID][vModel] == 509 || VehicleInfo[vehicleID][vModel] == 510)
       					{
           					RemovePlayerFromVehicle(i2);
               				SendClientMessage(i2, COLOR_ERROR, "You can't ride a bike if it's locked.");
	                    }
           			}
	       		}

       			VehicleInfo[vehicleID][vLock] = 1;
	            PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
	            GameTextForPlayer(playerid, "~w~Vehicle~n~~r~Locked", 4000, 3);

	            new engine, lights, alarm, lock, bonnet, boot, objective;
  				GetVehicleParamsEx(vehicleID, engine, lights, alarm, lock, bonnet, boot, objective);
	            SetVehicleParamsEx(vehicleID, engine, lights, alarm, VehicleInfo[vehicleID][vLock], bonnet, boot, objective);
        	}
	        case 1:
	        {
				VehicleInfo[vehicleID][vLock] = 0;
				PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
  				GameTextForPlayer(playerid, "~w~Vehicle~n~~g~Unlocked", 4000, 3);

  				new engine, lights, alarm, lock, bonnet, boot, objective;
  				GetVehicleParamsEx(vehicleID, engine, lights, alarm, lock, bonnet, boot, objective);
  				SetVehicleParamsEx(vehicleID, engine, lights, alarm, VehicleInfo[vehicleID][vLock], bonnet, boot, objective);
	        }
    	}
	}
	else if(strcmp(type, "park", true) == 0)
	{
		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_ERROR, "You have to be in a vehicle in order to do this.");
	    if(PlayerSpawnedVehicles(playerid) == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have a vehicle spawned.");

		new vehicleID = -1;
		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
    	{
    		new veh = GetSpawnedVehicle(playerid, i);
    		if(GetPlayerVehicleID(playerid) == veh)
    		{
    			vehicleID = veh;
    		}
    	}

    	new msg[160], parkingPrice = 250;

    	if(vehicleID == -1) return SendClientMessage(playerid, COLOR_ERROR, "You have to be in your vehicles in order to park it.");
		if(GetPlayerInterior(playerid) != 0 && GetPVarInt(playerid, "GarageEnter") == 0) return SendClientMessage(playerid, COLOR_ERROR, "You cannot park your vehicle inside an interior.");
		
		if(GetPVarInt(playerid, "GarageEnter") != 0)
		{
			parkingPrice = 0;
		}

		if(GetPVarInt(playerid, "MonthDon") != 0)
		{
		    parkingPrice = 0;
		}

		if(parkingPrice != 0 && GetPlayerMoneyEx(playerid) < parkingPrice)
		{
		    format(msg, sizeof(msg), "You do not have enough money to park your vehicle (%s).", FormatMoney(parkingPrice));
			return SendClientMessage(playerid, COLOR_ERROR, msg);
		}

		GetVehiclePos(vehicleID, VehicleInfo[vehicleID][vX], VehicleInfo[vehicleID][vY], VehicleInfo[vehicleID][vZ]);
		GetVehicleZAngle(vehicleID, VehicleInfo[vehicleID][vAngle]);
		VehicleInfo[vehicleID][vVirtualWorld] = GetVehicleVirtualWorld(vehicleID);
		VehicleInfo[vehicleID][vInterior] = GetPlayerInterior(playerid);
		GivePlayerMoneyEx(playerid, -parkingPrice);
		format(msg, sizeof(msg), "Vehicle parking spot updated for %s, the vehicle will spawn here from now on.", FormatMoney(parkingPrice));
		SendClientMessage(playerid, -1, msg);
		mysql_format(handlesql, msg, sizeof(msg), "UPDATE `vehicles` SET `X` = %f, `Y` = %f, `Z` = %f, `Angle` = %f, `VirtualWorld` = %i, `Interior` = %i WHERE `ID` = %i;", VehicleInfo[vehicleID][vX], VehicleInfo[vehicleID][vY], VehicleInfo[vehicleID][vZ], VehicleInfo[vehicleID][vAngle], VehicleInfo[vehicleID][vVirtualWorld], VehicleInfo[vehicleID][vInterior], VehicleInfo[vehicleID][vID]);
		mysql_pquery(handlesql, msg);
	}
	else if(strcmp(type, "despawn", true) == 0)
	{
		if(PlayerSpawnedVehicles(playerid) == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have a vehicle spawned.");

		new vehicleID = -1, Float:distance = VEHICLE_DESPAWN_RANGE;
		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
    	{
    		new Float:pos[3];
    		new temp_vehicleid = GetSpawnedVehicle(playerid, i);

    		pos[0] = VehicleInfo[temp_vehicleid][vX];
    		pos[1] = VehicleInfo[temp_vehicleid][vY];
    		pos[2] = VehicleInfo[temp_vehicleid][vZ];

    		if(GetPlayerDistanceFromPoint(playerid, pos[0], pos[1], pos[2]) < VEHICLE_DESPAWN_RANGE)
    		{
    			if(distance > GetPlayerDistanceFromPoint(playerid, pos[0], pos[1], pos[2]))
	    		{
	    			distance = GetPlayerDistanceFromPoint(playerid, pos[0], pos[1], pos[2]);
	    			vehicleID = temp_vehicleid;
	    		}
	    	}
    	}

    	if(vehicleID == -1) return SendClientMessage(playerid, COLOR_ERROR, "You are not close to any of your vehicle parking spots.");
        //if(VehicleInfo[vehicleID][vInt] > 0) return SendClientMessage(playerid, COLOR_ERROR, "Your vehicle can only be despawned in your house's garage.");
        if(VehicleInfo[vehicleID][vCorp] > 0 && CorpInfo[VehicleInfo[vehicleID][vCorp]][cUsed] == 1) return SendClientMessage(playerid, COLOR_ERROR, "You can't despawn a vehicle with a corpse inside (/v corpse).");

        if(IsPlayerInRangeOfPoint(playerid, VEHICLE_DESPAWN_RANGE, VehicleInfo[vehicleID][vX], VehicleInfo[vehicleID][vY], VehicleInfo[vehicleID][vZ]))
        {
	      	foreach(new i : Player)
	      	{
				if(IsPlayerInVehicle(i, vehicleID) && i != playerid)
				{
					return SendClientMessage(playerid, COLOR_ERROR, "Your vehicle is still occupied!");
			    }
       		}

			foreach(new i : VehicleIterator)
			{
				if(GetVehicleTrailer(i) == vehicleID)
				{
					return SendClientMessage(playerid, COLOR_ERROR, "Your vehicle is currently being towed by a TowTruck.");
				}
			}

   			/*for(new i = 1; i < 9; i++) {
		    	if(VehicleInfo[vehicleID][cObject][i] > 0) {
			    	if(IsValidDynamicObject(VehicleInfo[vehicleID][cObject][i])) {
						DestroyDynamicObject(VehicleInfo[vehicleID][cObject][i]);
				    	VehicleInfo[vehicleID][cObject][i] = 0;
		        	}
	        	}
            }*/

			ServerLog(LOG_VEHICLE_DESPAWN, PlayerInfo[playerid][pUsername], VehicleName[GetVehicleModel(vehicleID)-400]);

			GameTextForPlayer(playerid, "~w~Vehicle ~r~Despawned", 5000, 1);
			SaveVehicleData(vehicleID);
            DespawnVehicle(vehicleID);
		}
		else
		{
			SendClientMessage(playerid, COLOR_ERROR, "You are not close to any of your vehicle parking spots.");
		}
	}
	else if(strcmp(type, "sell", true) == 0)
	{
		if(PlayerSpawnedVehicles(playerid) == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have a vehicle spawned.");

		new vehicleID = -1;
		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
    	{
    		new veh = GetSpawnedVehicle(playerid, i);
    		if(GetPlayerVehicleID(playerid) == veh)
    		{
    			vehicleID = veh;
    		}
    	}

    	if(vehicleID == -1) return SendClientMessage(playerid, COLOR_ERROR, "You have to be in your vehicle in order to sell it.");

        if(VehicleInfo[vehicleID][vDonate] != 0) return SendClientMessage(playerid, COLOR_ERROR, "You cannot sell a donator vehicle.");
   		new msg[70],
			sellPrice = VehicleInfo[vehicleID][vValue] / 2; // Divide by 2.

		SetPVarInt(playerid, "vs_SellVehicle", sellPrice);
		format(msg, sizeof(msg), "Would you like to sell your vehicle for {ffffff}%s{a9c4e4}?", FormatMoney(sellPrice));
	    ShowPlayerDialogEx(playerid, DIALOG_VEHICLE_SELL, DIALOG_STYLE_MSGBOX, "Sell Vehicle", msg, "Sell", "Cancel");
	}
	else if(strcmp(type, "radio", true) == 0)
	{
		new vehicleID = GetPlayerVehicleID(playerid);
		if(vehicleID == 0) return SendClientMessage(playerid, COLOR_ERROR, "You have to be in a vehicle with a radio installed.");
        if(IsNotAEngineCar(vehicleID)) return SendClientMessage(playerid, COLOR_ERROR, "This vehicle does not have a radio installed.");
        if(GetPlayerVehicleID(playerid) != vehicleID && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_ERROR, "You have to be in the driver seat of your vehicle in order to set the radio station.");
        ShowPlayerDialogEx(playerid, DIALOG_RADIO, DIALOG_STYLE_LIST, "Vehicle Radio", "Radio Stations\nDirect URL\nTurn Off", "Select", "Exit");
	}
	else if(strcmp(type, "find", true) == 0)
	{
		if(PlayerSpawnedVehicles(playerid) == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have a vehicle spawned.");

		new vehicleID = -1;
		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
    	{
    		vehicleID = GetSpawnedVehicle(playerid, i);

    		new count = 0;
	        foreach(new i2 : Player)
	        {
	        	if(GetPlayerVehicleID(i2) == vehicleID)
	        	{
					count++;
				}
			}

			for(new i2 = 0; i2 < count; i2++)
    		{
    			SendClientMessage(playerid, COLOR_ERROR, "You can't locate one of your vehicles because there is someone driving it.");
    		}

			if(GetPlayerMoneyEx(playerid) >= 200)
			{
			    new msg[75],
		   			Float:pos[3];

				GivePlayerMoneyEx(playerid, -200);
				GetVehiclePos(vehicleID, pos[0], pos[1], pos[2]);
				format(msg, sizeof(msg), "One of your vehicles is currently in the area '%s'.", GetZone(pos[0], pos[1], pos[2]));
				SendClientMessage(playerid, COLOR_WHITE, msg);
				GameTextForPlayer(playerid, "~r~-$200", 5000, 1);
				PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);
			}
			else
			{
				SendClientMessage(playerid, COLOR_ERROR, "You do not have enough money ($200).");
				return 1;
			}
		}
	}
	else if(strcmp(type, "breakin", true) == 0)
	{
	    if(!CheckInvItem(playerid, 406)) return SendClientMessage(playerid, COLOR_ERROR, "You need a toolkit to use this.");
	    new vehicleID = PlayerToCar(playerid, 2, 4.0), Float:x, Float:y, Float:z, string[128];
	    if(VehicleInfo[vehicleID][vID] == 0) return SendClientMessage(playerid, COLOR_ERROR, "You cannot use your toolkit on this vehicle.");
	    if(IsNotAEngineCar(vehicleID)) return SendClientMessage(playerid, COLOR_ERROR, "This vehicle does not have an engine.");
	    if(IsHelmetCar(vehicleID)) return SendClientMessage(playerid, COLOR_ERROR, "This vehicle doesn't have a door.");
	    if(VehicleInfo[vehicleID][vLock] == 0) return SendClientMessage(playerid, COLOR_ERROR, "This vehicle is not locked.");
	    new msg[75],
	        time;

	    format(msg, sizeof(msg), "You are now attempting to break into the %s!", VehicleName[VehicleInfo[vehicleID][vModel] - 400]);
       	SendClientMessage(playerid, COLOR_WHITE, msg);
        SetPVarInt(playerid, "RamVehicle", 1);
       	SetPVarInt(playerid, "RamVehID", vehicleID);
       	switch(VehicleInfo[vehicleID][vLockLvl]) {
       	    case 0: time = 30;
       	    case 1: time = 60;
       	    case 2: time = 120;
       	    case 3: time = 300;
       	}

        if(VehicleInfo[vehicleID][vAlarmLvl] >= 3)
		{
            VehicleInfo[vehicleID][vAlarm]=1;
            GetPlayerPos(playerid, x, y, z);
        	new found;
			if(x > 46.7115 && y > -2755.979 && x < 2931.147 && y < -548.8602)
			{
			    SendFactionMessage(1, COLOR_BLUE, "HQ: All Units - HQ: House Burglary.");
				format(string, sizeof(string), "HQ: Location: %s", GetPlayerArea(playerid));
				SendFactionMessage(1, COLOR_BLUE, string);
				PlaySoundInArea(3401, x, y, z, 20.0);
				found++;
			}
			if(found != 0) {
			SendBurg(vehicleID, 2); }
        }

       	ProgressBar(playerid, "Unlocking Car...", time, 1);
       	AddPlayerTag(playerid, "(unlocking car)");
       	SetPVarInt(playerid, "RamVehTime", time);
		for(new p = 0; p < MAX_INV_SLOTS; p++) {
		    if(PlayerInfo[playerid][pInvItem][p] == 406)
		    {
			    PlayerInfo[playerid][pInvItem][p]=0;
			    PlayerInfo[playerid][pInvQ][p]=0;
			    PlayerInfo[playerid][pInvEx][p]=0;
			    PlayerInfo[playerid][pInvS][p]=0;
			    break;
		    }
	    }

	    GiveAchievement(playerid, 6);
  	}
  	else if(strcmp(type, "corpse", true) == 0)
  	{
	    if(PlayerSpawnedVehicles(playerid) == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have a vehicle spawned.");

	    new vehicleID = -1;
		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
    	{
    		vehicleID = GetSpawnedVehicle(playerid, i);
    		
    		new Float:pos[3];
			GetVehiclePos(vehicleID, pos[0], pos[1], pos[2]);
			if(IsPlayerInRangeOfPoint(playerid, 10.0, pos[0], pos[1], pos[2]))
			{
	  			new id = -1;
			    for(new i2 = 0; i2 < sizeof(CorpInfo); i2++)
			    {
	               	if(CorpInfo[i2][cUsed] == 1)
	               	{
	                   	if(CorpInfo[i2][cVeh] == vehicleID)
	                   	{
	                       	id = i2;
							break;
	                    }
	                }
	            }

	            if(id == -1) return SendClientMessage(playerid, COLOR_ERROR, "There is no corpse in your vehicle.");
				GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		        CorpInfo[id][cText] = CreateDynamic3DTextLabel("| Corpse |\nPress'~k~~CONVERSATION_YES~' to examine!", 0x33CCFFFF, pos[0], pos[1], pos[2]-0.8, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), -1, 50.0);
		        //CorpInfo[id][cObj]=CreateDynamicObject(19944, pos[0], pos[1], pos[2]-1, 0.0, 0.0, 0.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
		        new rand = random(180), Float:FloatValue;
		        FloatValue = float(rand);
		        CorpInfo[id][cActor]=CreateActor(CorpInfo[id][cSkin], pos[0], pos[1], pos[2], FloatValue);
		        SetActorVirtualWorld(CorpInfo[id][cActor], GetPlayerVirtualWorld(playerid));
		        ApplyActorAnimation(CorpInfo[id][cActor], "ped", "FLOOR_hit_f", 4.0, 0, 1, 1, 1, -1);
			    CorpInfo[id][cX] = pos[0];
		        CorpInfo[id][cY] = pos[1];
		        CorpInfo[id][cZ] = pos[2];
		        CorpInfo[id][cVeh] = 0;
		        VehicleInfo[vehicleID][vCorp] = 0;
		        SendClientMessage(playerid, COLOR_WHITE, "Corpse unloaded!");
		        return 1;
			}
    	}

    	SendClientMessage(playerid, COLOR_ERROR, "You are not around any of your vehicles.");
    	return 1;
	}
	else if(strcmp(type, "sellto", true) == 0)
	{
		if(PlayerSpawnedVehicles(playerid) == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have a vehicle spawned.");

		new vehicleID = -1;
		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
    	{
    		new veh = GetSpawnedVehicle(playerid, i);
    		if(GetPlayerVehicleID(playerid) == veh)
    		{
    			vehicleID = veh;
    		}
    	}

    	if(vehicleID == -1) return SendClientMessage(playerid, COLOR_ERROR, "You have to be inside of one of your vehicles in order to use this.");

	    if(user == -1 || price == -1) return SendClientMessage(playerid, COLOR_ERROR, "USAGE: /v sellto [PlayerID] [Price]");
	    if(GetPVarInt(playerid, "ConnectTime") < 8) return SendClientMessage(playerid, COLOR_ERROR, "You need at least 8 Time-In-LS to perform this action.");
	    if(!Iter_Contains(Player, user)) return SendClientMessage(playerid, COLOR_ERROR, "This player is not connected or points to a NPC.");
	    if(playerid == user) return SendClientMessage(playerid, COLOR_ERROR, "You cannot sell a vehicle to yourself.");
	    if(GetPVarInt(user, "ConnectTime") < 8) return SendClientMessage(playerid, COLOR_ERROR, "The player you are trying to sell your vehicle to has less than 8 Time-In-LS.");
        if(VehicleInfo[vehicleID][vDonate] != 0) return SendClientMessage(playerid, COLOR_ERROR, "You cannot sell a donator vehicle.");
        if(VehicleInfo[vehicleID][vModel] == 522) return SendClientMessage(playerid, COLOR_ERROR, "You cannot sell a NRG-500.");
        if(price < 1 || price > 2500000) return SendClientMessage(playerid, COLOR_ERROR, "You can only sell this vehicle for price within the following range: 1 - 2500000");
		if(PlayerToPlayer(playerid, user, VEHICLE_SELL_RANGE)) {
		    new query[75];
		    mysql_format(handlesql, query, sizeof(query), "SELECT NULL FROM `vehicles` WHERE `Owner` = '%e';", PlayerInfo[user][pUsername]);
		    mysql_pquery(handlesql, query, "vs_PlayerSellsVehicleToPlayer", "iii", playerid, user, price);
		} else {
			SendClientMessage(playerid, COLOR_ERROR, "You are not close enough to this player.");
   		}
	}
	else if(strcmp(type, "color", true) == 0)
	{
		if(PlayerSpawnedVehicles(playerid) == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have a vehicle spawned.");

	    if(user == -1 || price == -1)
	    {
		    SendClientMessage(playerid, COLOR_GREEN, "USAGE: /v [color 1] [color 2]");
		    //SendClientMessage(playerid, COLOR_ERROR, "NOTE: Color IDs 0 and 1 are free.");
		    return true;
		}
		else
		{
			if(GetPVarInt(playerid, "ColorDelay") > GetCount()) return scm(playerid, COLOR_ERROR, "You can change your vehicle's color once every 5 minutes.");

			new string[128];

			new vehicleID = -1;
			for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
	    	{
	    		vehicleID = GetSpawnedVehicle(playerid, i);
	    		if(GetPlayerVehicleID(playerid) == vehicleID)
	    		{
	    			break;
	    		}
	    		vehicleID = -1;
	    	}

        	if(vehicleID == -1) return SendClientMessage(playerid, COLOR_ERROR, "You have to be inside of one of your vehicles in order to use this.");
	   	    if(user < 0 || user > 500) return SendClientMessage(playerid, COLOR_ERROR, "Cannot go under 0 or above 500.");
	   	    if(price < 0 || price > 500) return SendClientMessage(playerid, COLOR_ERROR, "Cannot go under 0 or above 500.");
	   	    
	   	    new cost = 0;

	   	    if(user >= 0) cost += 500;
	   	    if(price >= 0) cost += 500;

	   	    if(GetPVarInt(playerid, "MonthDon") > 0) cost = 0;

	   	    if(GetPlayerMoneyEx(playerid) >= cost)
	   	    {
	   	        format(string, sizeof(string),"~r~-%s", FormatMoney(cost));
	          	GameTextForPlayer(playerid, string, 5000, 1);
	          	format(string, sizeof(string),"%s's color has been changed for %s!", VehicleName[GetVehicleModel(vehicleID)-400], FormatMoney(cost));
	          	scm(playerid, -1, string);
	            GivePlayerMoneyEx(playerid, -cost);
	            ChangeVehicleColor(vehicleID, user, price);
	            VehicleInfo[vehicleID][vColorOne]=user;
	            VehicleInfo[vehicleID][vColorTwo]=price;
	            SaveVehicleData(vehicleID, 0);
	            SetPVarInt(playerid, "ColorDelay" , GetCount()+300000); // 5 min delay
	   	    }
	   	    else
	   	    {
	   	    	SendClientMessage(playerid, COLOR_ERROR, "Insufficient funds!");
   			}
   		}
    }
    /*else if(strcmp(type, "repair", true) == 0)
    {
	    if(PlayerSpawnedVehicles(playerid) == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have a vehicle spawned.");

	    new Float:distance = VEHICLE_INVENTORY_RANGE;
		new vehicleID = -1;

		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
    	{
    		new Float:pos[3];
    		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

    		new temp_vehicleid = GetSpawnedVehicle(playerid, i);

    		if(GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]) < VEHICLE_INVENTORY_RANGE)
    		{
    			if(distance > GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]))
	    		{
	    			distance = GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]);
	    			vehicleID = temp_vehicleid;
	    		}
    		}
    	}

    	if(vehicleID == -1) return SendClientMessage(playerid, COLOR_ERROR, "You have to be around one of your vehicles in order to use this.");

	    new Float:pos[3];

	    for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
        {
        	vehicleID = GetSpawnedVehicle(playerid, i);
        	GetVehiclePos(vehicleID, pos[0], pos[1], pos[2]);
        	if(IsPlayerInRangeOfPoint(playerid, 10.0, pos[0], pos[1], pos[2]))
			{
				if(IsNotAEngineCar(vehicleID)) return SendClientMessage(playerid, COLOR_ERROR, "This vehicle does not support this command.");

				ShowPlayerDialogEx(playerid, 430, DIALOG_STYLE_LIST, "Repair Options", "Replace Engine\nReplace Battery\nReplace Tires", "Select", "Cancel");
	        	SCM(playerid, COLOR_ERROR, "NOTE: You need the spare part in your vehicles inventory, you can purchase them at any warehouse.");
				return 1;
			}
        }
        return 1;
    }*/
    else if(strcmp(type, "payinsurance", true) == 0)
    {
        if(PlayerSpawnedVehicles(playerid) == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have a vehicle spawned.");

        new string[128];

		new vehicleID = -1;
		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
    	{
    		new veh = GetSpawnedVehicle(playerid, i);
    		if(GetPlayerVehicleID(playerid) == veh)
    		{
    			vehicleID = veh;
    		}
    	}

	    if(vehicleID == -1) return SendClientMessage(playerid, COLOR_ERROR, "You have to be inside of one of your vehicles in order to use this.");

		price = VehicleInfo[vehicleID][vInsuranceC];

		if(VehicleInfo[vehicleID][vInsurance] == 0) return SendClientMessage(playerid, COLOR_ERROR, "Your vehicle does not have insurance.");
		if(price == 0) return SendClientMessage(playerid, COLOR_ERROR, "Your vehicle is not in any insurance debt.");
		if(GetPlayerMoneyEx(playerid) >= price)
		{
			format(string, sizeof(string),"~r~-%s", FormatMoney(price));
			GameTextForPlayer(playerid, string, 5000, 1);
			GivePlayerMoneyEx(playerid, -price);
			format(string, 128, "The insurance debt of %s has been cleared off your %s!", FormatMoney(price), PrintVehName(vehicleID));
			scm(playerid, -1, string);
			VehicleInfo[vehicleID][vInsuranceC] = 0;
		}
		else SendClientMessage(playerid, COLOR_ERROR, "Insufficient funds!");
    }
    else if(strcmp(type, "lights", true) == 0)
    {
        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_ERROR, "You have to be inside a vehicle's driver seat to toggle the lights of a vehicle.");
        if(IsNotAEngineCar(GetPlayerVehicleID(playerid))) return SendClientMessage(playerid, COLOR_ERROR, "This vehicle does not have lights.");

		CarLights(GetPlayerVehicleID(playerid));
        PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
    }
    else if(strcmp(type, "trunk", true) == 0) 
    {
        new string[128];
        new sendername[MAX_PLAYER_NAME];
	    new Float:distance = VEHICLE_INVENTORY_RANGE;
		new vehicleID = -1;

		foreach(new i : VehicleIterator)
    	{
    		if(DoesPlayerHaveVehicleKey(playerid, VehicleInfo[i][vID]))
    		{
				new Float:pos[3];
				GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

				new temp_vehicleid = i;

				if(GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]) < VEHICLE_INVENTORY_RANGE)
				{
					if(distance > GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]))
					{
						distance = GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]);
						vehicleID = temp_vehicleid;
					}
				}
    		}
    	}

		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
    	{
    		new Float:pos[3];
    		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

    		new temp_vehicleid = GetSpawnedVehicle(playerid, i);

    		if(GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]) < VEHICLE_INVENTORY_RANGE)
    		{
    			if(distance > GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]))
	    		{
	    			distance = GetVehicleDistanceFromPoint(temp_vehicleid, pos[0], pos[1], pos[2]);
	    			vehicleID = temp_vehicleid;
	    		}
    		}
    	}

    	if(GetPVarInt(playerid, "Member") == 1 && GetPVarInt(playerid, "Rank") >= 8)
    	{
			foreach(new i : VehicleIterator)
			{
				new Float:x, Float:y, Float:z;
				GetVehiclePos(i, x, y, z);
				if(IsPlayerInRangeOfPoint(playerid, VEHICLE_INVENTORY_RANGE, x, y, z))
				{
					vehicleID = i;
					break;
				}
			}
    	}

    	if(vehicleID == -1) return SendClientMessage(playerid, COLOR_ERROR, "You have to be next to a vehicle in order to use this.");
    	if(IsNotAEngineCar(vehicleID)) return SendClientMessage(playerid, COLOR_ERROR, "This vehicle does not have a trunk.");

        format(sendername, sizeof(sendername), "%s", PlayerNameEx(playerid));
		GiveNameSpace(sendername);
        switch(VehicleInfo[vehicleID][vTrunk])
		{
		    case 0: 
		    {
		        VehicleInfo[vehicleID][vTrunk]=1;
		        format(string, sizeof(string), "* %s opens the %s's trunk.", sendername, PrintVehName(vehicleID));
		    }
		    case 1: 
		    {
		        VehicleInfo[vehicleID][vTrunk]=0;
		        format(string, sizeof(string), "* %s closes the %s's trunk.", sendername, PrintVehName(vehicleID));
		    }
		}
		ProxDetector(30.0, playerid, string, COLOR_PURPLE);
        VehicleTrunk(vehicleID, VehicleInfo[vehicleID][vTrunk]);
	} 
	else if(strcmp(type, "bomb", true) == 0)
	{
        if(!CheckInvItem(playerid, 413)) return scm(playerid, COLOR_ERROR, "You don't have a bomb in your inventory!");
        if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendClientMessage(playerid, COLOR_ERROR, "You must be on-foot.");
        new carid = PlayerToCar(playerid, 2, 4.0), string[128];
        if(VehicleInfo[carid][vType] != VEHICLE_PERSONAL) return SendClientMessage(playerid,COLOR_ERROR,"This is not a personal vehicle.");
	    if(IsNotAEngineCar(carid)) return SendClientMessage(playerid, COLOR_ERROR, "This vehicle dosent have an engine.");
	    if(IsHelmetCar(carid)) return SendClientMessage(playerid, COLOR_ERROR, "This vehicle is a bike not a car.");
	    if(VehicleInfo[carid][vEngine] != 0) return SendClientMessage(playerid,COLOR_ERROR,"This vehicles engine is not turned off.");
	    if(VehicleInfo[carid][vBomb] != 0) return SendClientMessage(playerid,COLOR_ERROR,"This vehicle already contains a bomb charge.");
        PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
        format(string, sizeof(string),"Bomb wired to the %s's ignition!", VehicleName[GetVehicleModel(carid)-400]);
        SendClientMessage(playerid, COLOR_WHITE, string);
        GameTextForPlayer(playerid, "~w~Bomb~n~~b~Wired", 4000, 3);
        VehicleInfo[carid][vBomb] = 1;
        RemoveInvItem(playerid, GetInvSlotFromID(playerid, 413));
	}
	else
	{
        cmd_v(playerid, "");
	}

	return 1;
}

COMMAND:vehicledata(playerid, params[]) {
	if(GetPVarInt(playerid, "Admin") == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have access to this command!");
	new vehicleID;
	if(sscanf(params, "i", vehicleID)) return SendClientMessage(playerid, COLOR_ERROR, "USAGE: /vehicledata [vehicleID]");
	if(!Iter_Contains(VehicleIterator, vehicleID)) return SendClientMessage(playerid, COLOR_ERROR, "A vehicle with this vehicleID is not spawned.");
	new msg[MAX_MSG_LENGTH],
		Float:health,
		Float:pos[4];
		
	GetVehicleHealth(vehicleID, health);
	GetVehiclePos(vehicleID, pos[0], pos[1], pos[2]);
	GetVehicleZAngle(vehicleID, pos[3]);
	format(msg, sizeof(msg), "Vehicle Data ({FF3333}VehicleID: %i, Database ID: %i, X: %.2f, Y: %.2f, Z: %.2f, Angle: %.2f{FFFFFF}):", vehicleID, VehicleInfo[vehicleID][vID], pos[0], pos[1], pos[2], pos[3]);
	SendClientMessage(playerid, -1, msg);
	format(msg, sizeof(msg), "ModelID: %i, Saved ModelID: %i, Park X: %.2f, Park Y: %.2f, Park Z: %.2f, Park Angle: %.2f, Color 1: %i, Color 2: %i", GetVehicleModel(vehicleID), VehicleInfo[vehicleID][vModel], VehicleInfo[vehicleID][vX], VehicleInfo[vehicleID][vY], VehicleInfo[vehicleID][vZ], VehicleInfo[vehicleID][vAngle], VehicleInfo[vehicleID][vColorOne], VehicleInfo[vehicleID][vColorTwo]);
	SendClientMessage(playerid, -1, msg);
	if(isnull(VehicleInfo[vehicleID][vOwner])) {
		format(msg, sizeof(msg), "Engine: %i, Windows: %i, Type: %i, Lights: %i, Created: %i, Job: %i, WireTime: %i, Owner: Noone", VehicleInfo[vehicleID][vEngine], VehicleInfo[vehicleID][vWindows], VehicleInfo[vehicleID][vType], VehicleInfo[vehicleID][vLights], VehicleInfo[vehicleID][vCreated], VehicleInfo[vehicleID][vJob], VehicleInfo[vehicleID][vWireTime]);
	} else {
		format(msg, sizeof(msg), "Engine: %i, Windows: %i, Type: %i, Lights: %i, Created: %i, Job: %i, WireTime: %i, Owner: %s", VehicleInfo[vehicleID][vEngine], VehicleInfo[vehicleID][vWindows], VehicleInfo[vehicleID][vType], VehicleInfo[vehicleID][vLights], VehicleInfo[vehicleID][vCreated], VehicleInfo[vehicleID][vJob], VehicleInfo[vehicleID][vWireTime], VehicleInfo[vehicleID][vOwner]);
	}
	
    SendClientMessage(playerid, -1, msg);
    format(msg, sizeof(msg), "Value: %s, Fuel: %i, Lock: %i, Donator Vehicle: %i, Plate: %s, PlateV: %i, Insurance: %i, InsuranceC: %i", FormatMoney(VehicleInfo[vehicleID][vValue]), VehicleInfo[vehicleID][vFuel], VehicleInfo[vehicleID][vLock], VehicleInfo[vehicleID][vDonate], VehicleInfo[vehicleID][vPlate], VehicleInfo[vehicleID][vPlateV], VehicleInfo[vehicleID][vInsurance], VehicleInfo[vehicleID][vInsuranceC]);
    SendClientMessage(playerid, -1, msg);
    format(msg, sizeof(msg), "GPS: %i, Mileage1: %i, Mileage2: %i, Engine1: %i, Engine2: %i, Battery1: %i, Battery2: %i, Interior: %i", VehicleInfo[vehicleID][vGPS], VehicleInfo[vehicleID][vMileage][1], VehicleInfo[vehicleID][vMileage][2], VehicleInfo[vehicleID][vEngineStats][1], VehicleInfo[vehicleID][vEngineStats][2], VehicleInfo[vehicleID][vBattery][1], VehicleInfo[vehicleID][vBattery][2], VehicleInfo[vehicleID][vInt]);
    SendClientMessage(playerid, -1, msg);
    format(msg, sizeof(msg), "Virtual World: %i, Saved Virtual World: %i, Engine Level: %i, Battery Level: %i, Lock Level: %i, Alarm Level: %i", GetVehicleVirtualWorld(vehicleID), VehicleInfo[vehicleID][vVirtualWorld], VehicleInfo[vehicleID][vEngLvl], VehicleInfo[vehicleID][vBatLvl], VehicleInfo[vehicleID][vLockLvl], VehicleInfo[vehicleID][vAlarmLvl]);
    SendClientMessage(playerid, -1, msg);
    format(msg, sizeof(msg), "Health: %.2f, Saved Health: %.2f, Modification 1: %i, Modification 2: %i, Modification 3: %i, Modification 4: %i", health, VehicleInfo[vehicleID][vHealth], VehicleInfo[vehicleID][vMod][0], VehicleInfo[vehicleID][vMod][1], VehicleInfo[vehicleID][vMod][2], VehicleInfo[vehicleID][vMod][3]);
    SendClientMessage(playerid, -1, msg);
    format(msg, sizeof(msg), "Modification 5: %i, Modification 6: %i, Modification 7: %i, Modification 8: %i, Modification 9: %i, Modification 10: %i", VehicleInfo[vehicleID][vMod][4], VehicleInfo[vehicleID][vMod][5], VehicleInfo[vehicleID][vMod][6], VehicleInfo[vehicleID][vMod][7], VehicleInfo[vehicleID][vMod][8], VehicleInfo[vehicleID][vMod][9]);
    SendClientMessage(playerid, -1, msg);
	if(isnull(VehicleInfo[vehicleID][vRadio])) {
    	format(msg, sizeof(msg), "Modification 11: %i, Radio URL: None", VehicleInfo[vehicleID][vMod][10]);
	} else {
        format(msg, sizeof(msg), "Modification 11: %i, Radio URL: %s", VehicleInfo[vehicleID][vMod][10], VehicleInfo[vehicleID][vRadio]);
	}

	SendClientMessage(playerid, -1, msg);
	return 1;
}

/* === MySQL === */

forward vs_OnVehicleDataLoaded(dbID, playerid);
public vs_OnVehicleDataLoaded(dbID, playerid) {
	if(cache_get_row_count(handlesql) != 0) {

		for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
    	{
    		new vehicleid = GetSpawnedVehicle(playerid, i);

    		if(VehicleInfo[vehicleid][vID] == dbID)
    		{
    			return 1;
    		}
    	}

	    new model = cache_get_field_content_int(0, "Model"),
			Float:pos[4],
			color[2],
			vehicleID,
			string[128];

		pos[0] = cache_get_field_content_float(0, "X");
		pos[1] = cache_get_field_content_float(0, "Y");
		pos[2] = cache_get_field_content_float(0, "Z");
		pos[3] = cache_get_field_content_float(0, "Angle");
		color[0] = cache_get_field_content_int(0, "ColorOne");
		color[1] = cache_get_field_content_int(0, "ColorTwo");
		vehicleID = CreateVehicle(model, pos[0], pos[1], pos[2], pos[3], color[0], color[1], -1);

		VehicleInfo[vehicleID][vMileagePosition][0] = pos[0];
		VehicleInfo[vehicleID][vMileagePosition][1] = pos[1];
		VehicleInfo[vehicleID][vMileagePosition][2] = pos[2];

		if(vehicleID != INVALID_VEHICLE_ID)
		{
		    if(!Iter_Contains(VehicleIterator, vehicleID))
		    {
				Iter_Add(VehicleIterator, vehicleID);
			}

		    VehicleInfo[vehicleID][vEngine] = 0;
    		VehicleInfo[vehicleID][vWindows] = 0;
    		VehicleInfo[vehicleID][vCorp]=0;
    		VehicleInfo[vehicleID][vType] = VEHICLE_PERSONAL;
			VehicleInfo[vehicleID][vLights] = 0;
    		VehicleInfo[vehicleID][vCreated] = 1;
			VehicleInfo[vehicleID][vJob] = 0;
			VehicleInfo[vehicleID][vWireTime] = 0;
		    VehicleInfo[vehicleID][vID] = dbID;
		    VehicleInfo[vehicleID][vModel] = model;
		    VehicleInfo[vehicleID][vX] = pos[0];
		    VehicleInfo[vehicleID][vY] = pos[1];
		    VehicleInfo[vehicleID][vZ] = pos[2];
		    VehicleInfo[vehicleID][vAngle] = pos[3];
		    VehicleInfo[vehicleID][vColorOne] = color[0];
		    VehicleInfo[vehicleID][vColorTwo] = color[1];
			cache_get_field_content(0, "Owner", VehicleInfo[vehicleID][vOwner], handlesql, MAX_PLAYER_NAME);
			VehicleInfo[vehicleID][vValue] = cache_get_field_content_int(0, "Value");
			VehicleInfo[vehicleID][vLock] = cache_get_field_content_int(0, "Locked");
			VehicleInfo[vehicleID][vFuel] = cache_get_field_content_int(0, "Fuel");
			VehicleInfo[vehicleID][vDonate] = cache_get_field_content_int(0, "Donate");
			cache_get_field_content(0, "Plate", VehicleInfo[vehicleID][vPlate], handlesql, VEHICLE_PLATE_MAX_LENGTH);
			
			if(isnull(VehicleInfo[vehicleID][vPlate]))
			{
			    format(VehicleInfo[vehicleID][vPlate], VEHICLE_PLATE_MAX_LENGTH, "%s", GenerateRandomVehiclePlate());
			}

			SetVehicleNumberPlate(vehicleID, PrintVehiclePlate(VehicleInfo[vehicleID][vPlate]));
			VehicleInfo[vehicleID][vPlateV] = cache_get_field_content_int(0, "PlateV");
			VehicleInfo[vehicleID][vInsurance] = cache_get_field_content_int(0, "Insurance");
			VehicleInfo[vehicleID][vInsuranceC] = cache_get_field_content_int(0, "InsuranceC");
			VehicleInfo[vehicleID][vHealth] = cache_get_field_content_float(0, "Health");
			VehicleInfo[vehicleID][vGPS] = cache_get_field_content_int(0, "GPS");

			new InventoryFetch[1024];

			// Load inventory
			new InventoryItemID[MAX_VEH_SLOTS][5];
			new InventoryItemQuantity[MAX_VEH_SLOTS][5];
			new InventoryItemEx[MAX_VEH_SLOTS][5];
			new InventoryItemSerial[MAX_VEH_SLOTS][11];

			cache_get_field_content(0, "InventoryItemID", InventoryFetch);
			split(InventoryFetch, InventoryItemID, ',');

			cache_get_field_content(0, "InventoryItemQuantity", InventoryFetch);
			split(InventoryFetch, InventoryItemQuantity, ',');

			cache_get_field_content(0, "InventoryItemEx", InventoryFetch);
			split(InventoryFetch, InventoryItemEx, ',');

			cache_get_field_content(0, "InventoryItemSerial", InventoryFetch);
			split(InventoryFetch, InventoryItemSerial, ',');

			for(new i = 0; i < MAX_VEH_SLOTS; i++)
			{
				if(strval(InventoryItemID[i]) != 0)
				{
					VehicleInfo[vehicleID][vInvID][i] = strval(InventoryItemID[i]);
					VehicleInfo[vehicleID][vInvQ][i] = strval(InventoryItemQuantity[i]);
					VehicleInfo[vehicleID][vInvE][i] = strval(InventoryItemEx[i]);
					VehicleInfo[vehicleID][vInvS][i] = strval(InventoryItemSerial[i]);
				}
			}

			// Load glove box
			new GloveBoxItemID[MAX_GLOVE_BOX_SLOTS][5];
			new GloveBoxItemQuantity[MAX_GLOVE_BOX_SLOTS][5];
			new GloveBoxItemEx[MAX_GLOVE_BOX_SLOTS][5];
			new GloveBoxItemSerial[MAX_GLOVE_BOX_SLOTS][11];

			cache_get_field_content(0, "GloveBoxItemID", InventoryFetch);
			split(InventoryFetch, GloveBoxItemID, ',');

			cache_get_field_content(0, "GloveBoxItemQuantity", InventoryFetch);
			split(InventoryFetch, GloveBoxItemQuantity, ',');

			cache_get_field_content(0, "GloveBoxItemEx", InventoryFetch);
			split(InventoryFetch, GloveBoxItemEx, ',');

			cache_get_field_content(0, "GloveBoxItemSerial", InventoryFetch);
			split(InventoryFetch, GloveBoxItemSerial, ',');

			for(new i = 0; i < MAX_GLOVE_BOX_SLOTS; i++)
			{
				if(strval(GloveBoxItemID[i]) != 0)
				{
					VehicleInfo[vehicleID][vgbInvID][i] = strval(GloveBoxItemID[i]);
					VehicleInfo[vehicleID][vgbInvQ][i] = strval(GloveBoxItemQuantity[i]);
					VehicleInfo[vehicleID][vgbInvE][i] = strval(GloveBoxItemEx[i]);
					VehicleInfo[vehicleID][vgbInvS][i] = strval(GloveBoxItemSerial[i]);
				}
			}

			VehicleInfo[vehicleID][vMileage][1] = cache_get_field_content_int(0, "Mileage01");
			VehicleInfo[vehicleID][vMileage][2] = cache_get_field_content_int(0, "Mileage02");
			VehicleInfo[vehicleID][vEngineStats][1] = cache_get_field_content_int(0, "Engine1");
			VehicleInfo[vehicleID][vEngineStats][2] = cache_get_field_content_int(0, "Engine2");
			VehicleInfo[vehicleID][vBattery][1] = cache_get_field_content_int(0, "Battery1");
			VehicleInfo[vehicleID][vBattery][2] = cache_get_field_content_int(0, "Battery2");
			VehicleInfo[vehicleID][vStats][1] = cache_get_field_content_int(0, "Stats1");
			VehicleInfo[vehicleID][vStats][2] = cache_get_field_content_int(0, "Stats2");
			VehicleInfo[vehicleID][vStats][3] = cache_get_field_content_int(0, "Stats3");
			VehicleInfo[vehicleID][vEngLvl] = cache_get_field_content_int(0, "EngLvl");
			VehicleInfo[vehicleID][vBatLvl] = cache_get_field_content_int(0, "BatLvl");
			VehicleInfo[vehicleID][vLockLvl] = cache_get_field_content_int(0, "LockLvl");
			VehicleInfo[vehicleID][vAlarmLvl] = cache_get_field_content_int(0, "AlarmLvl");
			VehicleInfo[vehicleID][vVirtualWorld] = cache_get_field_content_int(0, "VirtualWorld");
			VehicleInfo[vehicleID][vInterior] = cache_get_field_content_int(0, "Interior");
			VehicleInfo[vehicleID][vBomb] = cache_get_field_content_int(0, "Bomb");
			VehicleInfo[vehicleID][vImpound] = cache_get_field_content_int(0, "Impound");
			VehicleInfo[vehicleID][vMod][0] = cache_get_field_content_int(0, "Mod1");
			VehicleInfo[vehicleID][vMod][1] = cache_get_field_content_int(0, "Mod2");
			VehicleInfo[vehicleID][vMod][2] = cache_get_field_content_int(0, "Mod3");
			VehicleInfo[vehicleID][vMod][3] = cache_get_field_content_int(0, "Mod4");
			VehicleInfo[vehicleID][vMod][4] = cache_get_field_content_int(0, "Mod5");
			VehicleInfo[vehicleID][vMod][5] = cache_get_field_content_int(0, "Mod6");
			VehicleInfo[vehicleID][vMod][6] = cache_get_field_content_int(0, "Mod7");
			VehicleInfo[vehicleID][vMod][7] = cache_get_field_content_int(0, "Mod8");
			VehicleInfo[vehicleID][vMod][8] = cache_get_field_content_int(0, "Mod9");
			VehicleInfo[vehicleID][vMod][9] = cache_get_field_content_int(0, "Mod10");
			VehicleInfo[vehicleID][vMod][10] = cache_get_field_content_int(0, "Mod11");
			VehicleInfo[vehicleID][vPaintJob] = cache_get_field_content_int(0, "PaintJob");

			VehicleInfo[vehicleID][vInt] = VehicleInfo[vehicleID][vInterior];

			strmid(VehicleInfo[vehicleID][vRadio], "None", 0, strlen("None"), VEHICLE_RADIO_URL_MAX_LENGTH);
		    if(!(VehicleInfo[vehicleID][vInsurance] <= 2 || VehicleInfo[vehicleID][vInsuranceC] > 250)) {
      			VehicleInfo[vehicleID][vHealth] = 950.0;
			}


			
            VehicleInfo[vehicleID][vWipers] = 0;

            if(!IsNotAEngineCar(vehicleID)) {
			    if(VehicleInfo[vehicleID][vHealth] <= 300.0)
			    {
			        new price = 500;
			        if(GetPlayerMoneyEx(playerid) >= price)
				    {
				        GivePlayerMoneyEx(playerid,-price);
					    format(string, sizeof(string),"-%s was taken to repair your destroyed %s!", FormatMoney(price), PrintVehName(vehicleID));
					    SendClientMessage(playerid,COLOR_WHITE,string);
					    VehicleInfo[vehicleID][vHealth] = 1000.0;
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
				    }
				    else
				    {
				        format(string, sizeof(string),"You cannot spawn your %s as it's destroyed, cost: %s!", PrintVehName(vehicleID), FormatMoney(price));
					    SendClientMessage(playerid, COLOR_ERROR, string);
					    DespawnVehicle(vehicleID);
					    return 1;
				    }
			    }
			    
			    if(VehicleInfo[vehicleID][vImpound] > 0) {
			        format(string, sizeof(string),"Your %s has been impounded by LSPD for %s!", PrintVehName(vehicleID), FormatMoney(VehicleInfo[vehicleID][vImpound]));
					SendClientMessage(playerid, COLOR_ERROR, string);
			        DespawnVehicle(vehicleID);
			        return 1;
			    }
			}

			SetVehicleHealth(vehicleID, VehicleInfo[vehicleID][vHealth]);
			SetVehicleVirtualWorld(vehicleID, VehicleInfo[vehicleID][vVirtualWorld]);
			LinkVehicleToInteriorEx(vehicleID, VehicleInfo[vehicleID][vInterior]);
   			if(!IsNotAEngineCar(vehicleID)) {
     			for(new i = 0; i < 11; i++) {
	 				LoadOwnableMods(vehicleID, i);
		 		}

   	            if(VehicleInfo[vehicleID][vInsurance] <= 1 || VehicleInfo[vehicleID][vInsuranceC] > 250) {
			        UpdateVehicleDamageStatus(vehicleID, VehicleInfo[vehicleID][vStats][1], VehicleInfo[vehicleID][vStats][2], 0, VehicleInfo[vehicleID][vStats][3]);
			    }
       		}
       		
       		if(IsPaintCar(vehicleID)) {
       		    if(VehicleInfo[vehicleID][vPaintJob] > 0) {
       		        ChangeVehiclePaintjob(vehicleID, VehicleInfo[vehicleID][vPaintJob]-1);
       		        ChangeVehicleColor(vehicleID, VehicleInfo[vehicleID][vColorOne], VehicleInfo[vehicleID][vColorTwo]);
       		    }
       		}

			if(VehicleInfo[vehicleID][vValue] == 0) {
				VehicleInfo[vehicleID][vDonate] = 1;
			}

			if(VehicleInfo[vehicleID][vValue] < 0) {
				VehicleInfo[vehicleID][vValue] = 0;
			}

			if(playerid != -1) {
			    new msg[90];

		    	if(GetVehicleVirtualWorld(vehicleID) != 0)
				{
					format(msg, sizeof(msg), "%s has been spawned at it's designated location, (Garage).", VehicleName[GetVehicleModel(vehicleID)-400]);
					SendClientMessage(playerid, COLOR_WHITE, msg);
					format(msg, sizeof(msg), "~w~%s ~g~Spawned", VehicleName[GetVehicleModel(vehicleID)-400]);
					GameTextForPlayer(playerid, msg, 5000, 1);

					ServerLog(LOG_VEHICLE_SPAWN, PlayerInfo[playerid][pUsername], VehicleName[GetVehicleModel(vehicleID)-400]);
				}
				else
				{
					format(msg, sizeof(msg), "%s has been spawned at it's designated location, (Area: %s).", VehicleName[GetVehicleModel(vehicleID)-400], GetZone(VehicleInfo[vehicleID][vX], VehicleInfo[vehicleID][vY], VehicleInfo[vehicleID][vZ]));
					SendClientMessage(playerid, COLOR_WHITE, msg);
					format(msg, sizeof(msg), "~w~%s ~g~Spawned", VehicleName[GetVehicleModel(vehicleID)-400]);
					GameTextForPlayer(playerid, msg, 5000, 1);

					ServerLog(LOG_VEHICLE_SPAWN, PlayerInfo[playerid][pUsername], VehicleName[GetVehicleModel(vehicleID)-400]);
				}
			}
		} else {
			if(playerid != -1) {
				SendClientMessage(playerid, COLOR_ERROR, "An error occured whilst attempting to spawn the vehicle, please try again.");
			}
		}
	} else {
		if(playerid != -1) {
			SendClientMessage(playerid, COLOR_ERROR, "The requested vehicle could not be found in the database, please try again.");
		}
	}
	return 1;
}

forward vs_OnPlayerSpawnsVehicle(playerid);
public vs_OnPlayerSpawnsVehicle(playerid) {
	new rows = cache_get_row_count(handlesql);
	if(rows > 0) {
	    new dialogMsg[400],
	        addition[20],
	        value;
	        
	    for(new i = 0; i < rows; i++) {
	        value = cache_get_field_content_int(i, "Value");
	        if(cache_get_field_content_int(i, "Donate") != 0 || value == 0) {
	        	format(addition, sizeof(addition), "Donator Vehicle, ");
	        } else {
				format(addition, sizeof(addition), "%s", EOS);
			}
	        
	        if(isnull(dialogMsg)) {
	    		format(dialogMsg, sizeof(dialogMsg), "Model: %s (%sValue: %s)", VehicleName[cache_get_field_content_int(i, "Model") - 400], addition, FormatMoney(value));
			} else {
				format(dialogMsg, sizeof(dialogMsg), "%s\nModel: %s (%sValue: %s)", dialogMsg, VehicleName[cache_get_field_content_int(i, "Model") - 400], addition, FormatMoney(value));
			}
		}
		
		ShowPlayerDialogEx(playerid, DIALOG_VEHICLE_SPAWN, DIALOG_STYLE_LIST, "Spawn Vehicle", dialogMsg, "Spawn", "Cancel");
	} else {
		SendClientMessage(playerid, COLOR_ERROR, "You do not have any vehicles.");
	}
}

forward vs_OnPlayerVehicleSpawnSelected(playerid);
public vs_OnPlayerVehicleSpawnSelected(playerid) 
{
	if(cache_get_row_count(handlesql) > 0) 
	{
		for(new i = 0; i < cache_get_row_count(handlesql); i++)
		{
			new vehicleID = -1;
			for(new i2 = 0; i2 < PlayerSpawnedVehicles(playerid); i2++)
			{
				vehicleID = GetSpawnedVehicle(playerid, i2);

				if(VehicleInfo[vehicleID][vID] == cache_get_field_content_int(i, "ID"))
				{
					SendClientMessage(playerid, COLOR_ERROR, "This vehicle is already spawned.");
					return 1;
				}
			}

			new count = 0;
			for(new i2 = 0; i2 < PlayerSpawnedVehicles(playerid); i2++)
			{
				vehicleID = GetSpawnedVehicle(playerid, i2);

				if(GetVehicleVirtualWorld(vehicleID) == 0 && VehicleInfo[vehicleID][vInt] == 0)
				{
					count++;
				}
			}

			if(count < MAX_SPAWNED_VEHICLES)
			{
				SpawnVehicle(cache_get_field_content_int(i, "ID"), playerid);
			}
			else
			{
				return SendClientMessage(playerid, COLOR_ERROR, "You already have two vehicles spawned.");
			}
		}
	}
	return 1;
}

forward vs_OnAdminVehicleSpawnSelected(playerid);
public vs_OnAdminVehicleSpawnSelected(playerid) 
{
	if(cache_get_row_count(handlesql) > 0) 
	{
		for(new i = 0; i < cache_get_row_count(handlesql); i++)
		{
			new vehicleID = -1;
			for(new i2 = 0; i2 < PlayerSpawnedVehicles(playerid); i2++)
			{
				vehicleID = GetSpawnedVehicle(playerid, i2);

				if(VehicleInfo[vehicleID][vID] == cache_get_field_content_int(i, "ID"))
				{
					SendClientMessage(playerid, COLOR_ERROR, "This vehicle is already spawned.");
					return 1;
				}
			}

			SpawnVehicle(cache_get_field_content_int(i, "ID"), playerid);
		}
	}
	return 1;
}

/*
forward vs_OnPlayerEnterGarage(playerid);
public vs_OnPlayerEnterGarage(playerid)
{
	if(cache_get_row_count(handlesql) > 0)
	{
		for(new i = 0; i < cache_get_row_count(handlesql); i++)
		{
			new vehicleID = -1;
			for(new i2 = 0; i2 < PlayerSpawnedVehicles(playerid); i2++)
			{
				vehicleID = GetSpawnedVehicle(playerid, i2);

				if(VehicleInfo[vehicleID][vID] == cache_get_field_content_int(i, "ID"))
				{
					if(VehicleInfo[vehicleID][vVirtualWorld] == 0 && VehicleInfo[vehicleID][vInterior] == 0)
					{
						return 1;
					}
				}
			}

			SpawnVehicle(cache_get_field_content_int(i, "ID"), playerid);
		}
	}
	return 1;
}
*/

forward vs_PlayerSellsVehicleToPlayer(playerid, user, price);
public vs_PlayerSellsVehicleToPlayer(playerid, user, price) {
	// Checking everything twice in case of massive lag or intervening/unexpected behaviour  - Double-Check because of sensitive money-related feature.

	if(PlayerSpawnedVehicles(playerid) == 0) return SendClientMessage(playerid, COLOR_ERROR, "You do not have a vehicle spawned.");

	new vehicleID = -1;
	for(new i = 0; i < PlayerSpawnedVehicles(playerid); i++)
	{
		new veh = GetSpawnedVehicle(playerid, i);
		if(GetPlayerVehicleID(playerid) == veh)
		{
			vehicleID = veh;
		}
	}

	if(vehicleID == -1) return SendClientMessage(playerid, COLOR_ERROR, "You have to be inside of one of your vehicles in order to use this.");

    if(GetPVarInt(playerid, "ConnectTime") < 8) return SendClientMessage(playerid, COLOR_ERROR, "You need at least 8 Time-In-LS to perform this action.");
    if(!Iter_Contains(Player, user)) return SendClientMessage(playerid, COLOR_ERROR, "This player is not connected or points to a NPC.");
    if(playerid == user) return SendClientMessage(playerid, COLOR_ERROR, "You cannot sell a vehicle to yourself.");
    if(GetPVarInt(user, "ConnectTime") < 8) return SendClientMessage(playerid, COLOR_ERROR, "The player you are trying to sell your vehicle to has less than 8 Time-In-LS.");
    if(VehicleInfo[vehicleID][vDonate] != 0) return SendClientMessage(playerid, COLOR_ERROR, "You cannot sell a donator vehicle.");
    if(VehicleInfo[vehicleID][vModel] == 522) return SendClientMessage(playerid, COLOR_ERROR, "You cannot sell a NRG-500.");

	if(price < 1 || price > 2500000)
	{
	    SendClientMessage(playerid, COLOR_ERROR, "You can only sell this vehicle for a price within the following range: 1 - 2500000");
	}
	else
	{
		if(PlayerToPlayer(playerid, user, VEHICLE_SELL_RANGE))
		{
		    if(cache_get_row_count() < VEHICLE_MAX_AMOUNT)
		    {

		    	if(GetPVarInt(user, "MonthDon") != 0 || GetPVarInt(user, "DonateRank") > 2)
				{
					if(cache_get_row_count() >= VEHICLE_DONATOR_MAX_AMOUNT)
					{
						SendClientMessage(playerid, COLOR_ERROR, "This player already holds the maximum amount of ownerships of vehicles per-player.");
						return 1;
					}
				}
				else
				{
					if(cache_get_row_count() >= VEHICLE_REGULAR_MAX_AMOUNT)
					{
						SendClientMessage(playerid, COLOR_ERROR, "This player already holds the maximum amount of ownerships of vehicles per-player.");
						return 1;
					}
				}

		        new msg[100];
		        format(msg, sizeof(msg), "You offered %s to purchase your vehicle for %s.", PlayerInfo[user][pName], FormatMoney(price));
				SendClientMessage(playerid, COLOR_ERROR, msg);
				format(msg, sizeof(msg), "%s offered you to purchase his vehicle for %s (/accept sellto).", PlayerInfo[playerid][pName], FormatMoney(price));
				SendClientMessage(user, COLOR_ERROR, msg);
				SetPVarInt(user, "VehicleOffer", playerid);
				SetPVarInt(user, "VehicleOfferPrice", price);
				SetPVarInt(user, "VehicleOfferID", VehicleInfo[vehicleID][vID]);
		    }
		    else
		    {
				SendClientMessage(playerid, COLOR_ERROR, "This player already holds the maximum amount of ownerships of vehicles per-player.");
			}
		}
		else
		{
			SendClientMessage(playerid, COLOR_ERROR, "You are not close enough to this player.");
	    }
	}
	return 1;
}

/* === Functions === */

SpawnVehicle(dbID, playerid = -1) {
	if(Iter_Free(VehicleIterator) != -1) {
		foreach(new i : VehicleIterator) {
			if(VehicleInfo[i][vID] == dbID) {
				return -1;
			}
		}

		new query[256];
		mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `vehicles` WHERE `ID`=%i", dbID);
		mysql_pquery(handlesql, query, "vs_OnVehicleDataLoaded", "ii", dbID, playerid);
	} else {
		if(playerid != -1) {
			SendClientMessage(playerid, COLOR_ERROR, "Vehicle could not be spawned as the maximum amount of spawned vehicles has been reached, please contact an administrator.");
		}
		
		return 0;
	}
	
	return 1;
}

stock IsPlayerVehicleSpawned(playerid) {
	if(Iter_Contains(Player, playerid)) {
	    foreach(new i : VehicleIterator) {
			if(!isnull(VehicleInfo[i][vOwner]) && strcmp(VehicleInfo[i][vOwner], PlayerInfo[playerid][pUsername], false) == 0) {
				return i;
			}
		}
	}
	
	return -1;
}

stock IsPlayerVehicle(playerid, vehicleid)
{
	if(strcmp(VehicleInfo[vehicleid][vOwner], PlayerInfo[playerid][pUsername], false) == 0)
	{
		return 1;
	}
	return 0;
}

stock PlayerSpawnedVehicles(playerid)
{
	new count = 0;
	foreach(new i : VehicleIterator)
	{
		if(!isnull(VehicleInfo[i][vOwner]) && strcmp(VehicleInfo[i][vOwner], PlayerInfo[playerid][pUsername], false) == 0)
		{
			count++;
		}
	}
	return count;
}

stock PlayerNameSpawnedVehicles(name[])
{
	new count = 0;
	foreach(new i : VehicleIterator)
	{
		if(!isnull(VehicleInfo[i][vOwner]) && strcmp(VehicleInfo[i][vOwner], name, false) == 0)
		{
			count++;
		}
	}
	return count;
}

stock GetSpawnedVehicle(playerid, number)
{
	new count = -1;
	new id = -1;

	
	foreach(new i : VehicleIterator)
	{
		if(!isnull(VehicleInfo[i][vOwner]) && strcmp(VehicleInfo[i][vOwner], PlayerInfo[playerid][pUsername], false) == 0)
		{
			if(number > count)
			{
				id = i;
				count++;
			}
		}
	}
	return id;
}

stock GetNameSpawnedVehicle(name[], number)
{
	new count = -1;
	new id = -1;
	foreach(new i : VehicleIterator)
	{
		if(!isnull(VehicleInfo[i][vOwner]) && strcmp(VehicleInfo[i][vOwner], name, false) == 0)
		{
			if(number > count)
			{
				id = i;
				count++;
			}
		}
	}
	return id;
}

stock ResetVehicleData(vehicleID)
{
	new playerid = GetPlayerID(VehicleInfo[vehicleID][vOwner]);
	if(playerid != -1)
	{
		foreach(new i : Player)
		{
			if(GetPVarInt(i, "VehicleOffer") == playerid)
			{
				SetPVarInt(i, "VehicleOffer", INVALID_MAXPL);
				DeletePVar(i, "VehicleOfferPrice");
				DeletePVar(i, "VehicleOfferID");
			}
		}
	}

	if(VehicleInfo[vehicleID][vType] == VEHICLE_RENTAL)
	{
		foreach(new i : Player)
		{
			if(GetPVarInt(i, "RentKey") == vehicleID)
			{
				SetPVarInt(i, "RentKey", 0);
			}
		}

		new query[256];
		mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET RentKey=0 WHERE RentKey=%i", vehicleID);
		mysql_pquery(handlesql, query);
	}

	for(new i = 0; i < MAX_VEHICLE_SIREN_OBJECTS; i++)
	{
		if(IsValidDynamicObject(VehicleInfo[vehicleID][vSirenObjectID][i]))
		{
			if(VehicleInfo[vehicleID][vSirenObjectID][i] != 0)
			{
	  		    DestroyDynamicObject(VehicleInfo[vehicleID][vSirenObjectID][i]);
	  		    VehicleInfo[vehicleID][vSirenObject][i] = 0;
	  		    VehicleInfo[vehicleID][vSirenObjectID][i] = 0;
	  		    VehicleInfo[vehicleID][vSirenX][i] = 0;
	  		    VehicleInfo[vehicleID][vSirenY][i] = 0;
	  		    VehicleInfo[vehicleID][vSirenZ][i] = 0;
	  		    VehicleInfo[vehicleID][vSirenXr][i] = 0;
	  		    VehicleInfo[vehicleID][vSirenYr][i] = 0;
	  		    VehicleInfo[vehicleID][vSirenZr][i] = 0;
	  		}
	 	}
	}
 	
 	if(VehicleInfo[vehicleID][vUText] > 0)
 	{
 		Delete3DTextLabel(VehicleInfo[vehicleID][vCText]);
		VehicleInfo[vehicleID][vUText] = 0;
	}

	for(new i = 0; i < sizeof(VehicleInfo[]); i++)
	{
		VehicleInfo[vehicleID][vInfo:i] = 0;
	}

	Iter_Remove(VehicleIterator, vehicleID);
}

stock DespawnVehicle(vehicleID)
{
    DestroyVehicle(vehicleID);
    ResetVehicleData(vehicleID);
}

stock SaveVehicleData(id, saveowner = 0) {
	// Yet to be improved!
	if(VehicleInfo[id][vType] != VEHICLE_PERSONAL) return 1;
	//==========//
	new query[500], Float:health, panels,doors,lights,tires;
	GetVehicleHealth(id, health);
	VehicleInfo[id][vHealth]=health;
    GetVehicleDamageStatus(id,panels,doors,lights,tires);
    VehicleInfo[id][vStats][1]=panels;
    VehicleInfo[id][vStats][2]=doors;
    VehicleInfo[id][vStats][3]=tires;
    //=========//
	if(saveowner == 1)
	{
 		mysql_format(handlesql, query, sizeof(query), "UPDATE vehicles SET Model=%d, X=%f, Y=%f, Z=%f, Angle=%f, ColorOne=%d, ColorTwo=%d, Owner='%e', Value=%d WHERE ID=%d",
  		VehicleInfo[id][vModel], VehicleInfo[id][vX], VehicleInfo[id][vY], VehicleInfo[id][vZ], VehicleInfo[id][vAngle],
		VehicleInfo[id][vColorOne], VehicleInfo[id][vColorTwo], VehicleInfo[id][vOwner], VehicleInfo[id][vValue], VehicleInfo[id][vID]);
		mysql_pquery(handlesql, query);
	}
	else
	{
	    mysql_format(handlesql, query, sizeof(query), "UPDATE vehicles SET Model=%d, X=%f, Y=%f, Z=%f, Angle=%f, ColorOne=%d, ColorTwo=%d, Value=%d WHERE ID=%d",
  		VehicleInfo[id][vModel], VehicleInfo[id][vX], VehicleInfo[id][vY], VehicleInfo[id][vZ], VehicleInfo[id][vAngle],
		VehicleInfo[id][vColorOne], VehicleInfo[id][vColorTwo], VehicleInfo[id][vValue], VehicleInfo[id][vID]);
		mysql_pquery(handlesql, query);
	}
    //==========//
	mysql_format(handlesql, query, sizeof(query), "UPDATE vehicles SET Locked=%d, Fuel=%d, Donate=%d, Plate='%e', PlateV=%d, GPS=%d, Insurance=%d, InsuranceC=%d, Health=%f, VirtualWorld=%d, Interior=%d WHERE ID=%d",
	VehicleInfo[id][vLock], VehicleInfo[id][vFuel], VehicleInfo[id][vDonate], VehicleInfo[id][vPlate], VehicleInfo[id][vPlateV],
	VehicleInfo[id][vGPS], VehicleInfo[id][vInsurance], VehicleInfo[id][vInsuranceC], VehicleInfo[id][vHealth],VehicleInfo[id][vVirtualWorld], VehicleInfo[id][vInterior], VehicleInfo[id][vID]);
	mysql_pquery(handlesql, query);
	
	mysql_format(handlesql, query, sizeof(query), "UPDATE vehicles SET PaintJob=%d WHERE ID=%d",
	VehicleInfo[id][vPaintJob], VehicleInfo[id][vID]);
	mysql_pquery(handlesql, query);
	//==========//

	// Saving inventory
	new InventoryItemID[MAX_VEH_SLOTS * 5];
	new InventoryItemQuantity[MAX_VEH_SLOTS * 5];
	new InventoryItemEx[MAX_VEH_SLOTS * 5];
	new InventoryItemSerial[MAX_VEH_SLOTS * 11];

	for(new i = 0; i < MAX_VEH_SLOTS; i++)
	{
		if(VehicleInfo[id][vInvID][i] != 0)
		{
			if(i == 0)
			{
		    	format(InventoryItemID, sizeof(InventoryItemID), "%d", VehicleInfo[id][vInvID][i]);
		    	format(InventoryItemQuantity, sizeof(InventoryItemQuantity), "%d", VehicleInfo[id][vInvQ][i]);
		    	format(InventoryItemEx, sizeof(InventoryItemEx), "%d", VehicleInfo[id][vInvE][i]);
		    	format(InventoryItemSerial, sizeof(InventoryItemSerial), "%d", VehicleInfo[id][vInvS][i]);
		    }
		    else
		    {
		    	format(InventoryItemID, sizeof(InventoryItemID), "%s,%d", InventoryItemID, VehicleInfo[id][vInvID][i]);
		    	format(InventoryItemQuantity, sizeof(InventoryItemQuantity), "%s,%d", InventoryItemQuantity, VehicleInfo[id][vInvQ][i]);
		    	format(InventoryItemEx, sizeof(InventoryItemEx), "%s,%d", InventoryItemEx, VehicleInfo[id][vInvE][i]);
		    	format(InventoryItemSerial, sizeof(InventoryItemSerial), "%s,%d", InventoryItemSerial, VehicleInfo[id][vInvS][i]);
			}
		}
	}

	mysql_format(handlesql, query, sizeof(query), "UPDATE `vehicles` SET `InventoryItemID`='%s', `InventoryItemQuantity`='%s', `InventoryItemEx`='%s', `InventoryItemSerial`='%s' WHERE `ID`=%i",
	InventoryItemID, InventoryItemQuantity, InventoryItemEx, InventoryItemSerial, 
	VehicleInfo[id][vID]);
	mysql_pquery(handlesql, query);

	// Saving glove box
	new GloveBoxItemID[MAX_GLOVE_BOX_SLOTS * 5];
	new GloveBoxItemQuantity[MAX_GLOVE_BOX_SLOTS * 5];
	new GloveBoxItemEx[MAX_GLOVE_BOX_SLOTS * 5];
	new GloveBoxItemSerial[MAX_GLOVE_BOX_SLOTS * 11];

	for(new i = 0; i < MAX_GLOVE_BOX_SLOTS; i++)
	{
		if(VehicleInfo[id][vgbInvID][i] != 0)
		{
			if(i == 0)
			{
		    	format(GloveBoxItemID, sizeof(GloveBoxItemID), "%d", VehicleInfo[id][vgbInvID][i]);
		    	format(GloveBoxItemQuantity, sizeof(GloveBoxItemQuantity), "%d", VehicleInfo[id][vgbInvQ][i]);
		    	format(GloveBoxItemEx, sizeof(GloveBoxItemEx), "%d", VehicleInfo[id][vgbInvE][i]);
		    	format(GloveBoxItemSerial, sizeof(GloveBoxItemSerial), "%d", VehicleInfo[id][vgbInvS][i]);
		    }
		    else
		    {
		    	format(GloveBoxItemID, sizeof(GloveBoxItemID), "%s,%d", GloveBoxItemID, VehicleInfo[id][vgbInvID][i]);
		    	format(GloveBoxItemQuantity, sizeof(GloveBoxItemQuantity), "%s,%d", GloveBoxItemQuantity, VehicleInfo[id][vgbInvQ][i]);
		    	format(GloveBoxItemEx, sizeof(GloveBoxItemEx), "%s,%d", GloveBoxItemEx, VehicleInfo[id][vgbInvE][i]);
		    	format(GloveBoxItemSerial, sizeof(GloveBoxItemSerial), "%s,%d", GloveBoxItemSerial, VehicleInfo[id][vgbInvS][i]);
			}
		}
	}

	mysql_format(handlesql, query, sizeof(query), "UPDATE `vehicles` SET `GloveBoxItemID`='%s', `GloveBoxItemQuantity`='%s', `GloveBoxItemEx`='%s', `GloveBoxItemSerial`='%s' WHERE `ID`=%i",
	GloveBoxItemID, GloveBoxItemQuantity, GloveBoxItemEx, GloveBoxItemSerial, 
	VehicleInfo[id][vID]);
	mysql_pquery(handlesql, query);

	//==========//
	mysql_format(handlesql, query, sizeof(query), "UPDATE `vehicles` SET `Mileage01`=%d,`Mileage02`=%d,`Engine1`=%d,`Engine2`=%d,`Battery1`=%d,`Battery2`=%d,`Stats1`=%d,`Stats2`=%d,`Stats3`=%d WHERE ID=%d",
	VehicleInfo[id][vMileage][1], VehicleInfo[id][vMileage][2], VehicleInfo[id][vEngineStats][1], VehicleInfo[id][vEngineStats][2],
	VehicleInfo[id][vBattery][1], VehicleInfo[id][vBattery][2], VehicleInfo[id][vStats][1], VehicleInfo[id][vStats][2],
	VehicleInfo[id][vStats][3], VehicleInfo[id][vID]);
	mysql_pquery(handlesql, query);
	
	//==========//
	mysql_format(handlesql, query, sizeof(query), "UPDATE `vehicles` SET `EngLvl`=%d,`BatLvl`=%d,`LockLvl`=%d,`AlarmLvl`=%d,`Bomb`=%d,`Impound`=%d WHERE ID=%d",
	VehicleInfo[id][vEngLvl], VehicleInfo[id][vBatLvl], VehicleInfo[id][vLockLvl], VehicleInfo[id][vAlarmLvl], VehicleInfo[id][vBomb], VehicleInfo[id][vImpound], VehicleInfo[id][vID]);
	mysql_pquery(handlesql, query);
	for(new i = 0; i < 11; i++) {
		mysql_format(handlesql, query, sizeof(query), "UPDATE `vehicles` SET Mod%d = %d WHERE ID = %d", i + 1, VehicleInfo[id][vMod][i], VehicleInfo[id][vID]);
		mysql_pquery(handlesql, query);
	}
	return 1;
}

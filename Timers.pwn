//============================================//
//=====[ TIMER USAGE SECTION ]=====//
//============================================//
forward TenMinuteTimer();
public TenMinuteTimer()
{
	// Reset basketballs and prevent players from hiding the ball and going AFK
	for(new i = 0; i < sizeof(Basketballs); i++)
	{
		if(Basketball[i][bBaller] == INVALID_MAXPL)
		{
			DestroyObject(Basketball[i][bID]);

			for(new i2 = 0; i2 < sizeof(Basketball[]); i2++)
			{
				Basketball[i][basketball:i2] = 0;
				Basketball[i][bBaller] = INVALID_MAXPL;
			}

			Basketball[i][bID] = CreateObject(2114, Basketballs[i][bsX], Basketballs[i][bsY], Basketballs[i][bsZ] - 0.8, 0, 0, 0);
			Basketball[i][bX] = Basketballs[i][bsX];
			Basketball[i][bY] = Basketballs[i][bsY];
			Basketball[i][bZ] = Basketballs[i][bsZ];
		}
		else
		{
			if(PlayerInfo[Basketball[i][bBaller]][pIdleTime] > 0 || GetPVarInt(Basketball[i][bBaller], "AFKTime") > 60)
			{
				DestroyObject(Basketball[i][bID]);

				if(Basketball[i][bBaller] != INVALID_MAXPL)
				{
					Basketball[i][bBounce] = 0;
					Basketball[i][bState] = 0;
					PlayerInfo[Basketball[i][bBaller]][pHasBasketball] = 0;
					PlayerInfo[Basketball[i][bBaller]][pBasketballID] = 0;

					ClearAnimationsEx(Basketball[i][bBaller]);

					Basketball[i][bBaller] = INVALID_MAXPL;
				}

				for(new i2 = 0; i2 < sizeof(Basketball[]); i2++)
				{
					Basketball[i][basketball:i2] = 0;
					Basketball[i][bBaller] = INVALID_MAXPL;
				}

				Basketball[i][bID] = CreateObject(2114, Basketballs[i][bsX], Basketballs[i][bsY], Basketballs[i][bsZ] - 0.8, 0, 0, 0);
				Basketball[i][bX] = Basketballs[i][bsX];
				Basketball[i][bY] = Basketballs[i][bsY];
				Basketball[i][bZ] = Basketballs[i][bsZ];
			}
		}
	}

	new string[128], Float:health;
	foreach(new i : Player)
    {
	    if(GetPVarInt(i, "PlayerLogged") == 1)
	    {
	        if(GetPVarInt(i, "DrugTime") == 0)
	        {
	            if(GetPVarInt(i, "Addiction") > 0 && GetPVarInt(i, "AFKTime") < 600)
	            {
	                if(GetPlayerState(i) != PLAYER_STATE_SPECTATING && GetPVarInt(i, "JailTime") <= 0)
	                {
	                    SetPVarInt(i, "Addiction", GetPVarInt(i, "Addiction")-2);
	                    format(string, 128, "You are experiencing withdrawal symptoms from '%s'!", PrintIName(GetPVarInt(i, "AddictionID")));
	                    SCM(i, COLOR_ERROR, string);
	                    GetPlayerHealth(i, health);

	                    if(health > 6)
	                    {
	                	    SetPlayerHealthEx(i, health -5.0);
					    }
					    else
					    {
					        SetPlayerHealthEx(i, 1.0);
	    				    SetPVarInt(i, "Cuffed", 1);
    	    			    SetPVarInt(i, "CuffedTime", 120);
    	    			    ApplyAnimationEx(i, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0);
					    }
		    		    if(GetPVarInt(i, "Addiction") == 0)
					    {
					        format(string, 128, "Your addiction from '%s' is clean!", PrintIName(GetPVarInt(i, "AddictionID")));
	                        SCM(i, COLOR_ERROR, string);
					        SetPVarInt(i, "Addiction", 0);
					        SetPVarInt(i, "AddictionID", 0);
					    }
					}
	            }
	        }
	    }
	}
	return 1;
}
//============================================//
public BuildingFireTimer()
{
	new bool:allow = false;
	foreach(new i : Player)
    {
		if(GetPVarInt(i, "Member") == FACTION_LSFD && GetPVarInt(i, "Duty") == 1)
		{
			allow = true;
			break;
		}
	}

	
	if(allow == true)
	{
		new owned_houses[MAX_HOUSES];
		new owned_house_count = 0;

		foreach(new i : HouseIterator)
		{
			if(HouseInfo[i][hOwned] == 1)
			{
				foreach(new i2 : HouseIterator)
				{
					if(owned_houses[i2] == 0)
					{
						owned_houses[i2] = i;
						owned_house_count++;
						break;
					}
				}
			}
		}

		new random_house = random(owned_house_count);
		new house_fire_houseid = owned_houses[random_house];

		new string[128];
		format(string, sizeof(string), "Dispatch: A property has caught fire, all available units respond immediately.");
		SendFactionMessage(2, COLOR_PINK, string);
		format(string, sizeof(string), "Dispatch: Location: Property No.%i", house_fire_houseid);
		SendFactionMessage(2, COLOR_PINK, string);

		CreateFire(HouseInfo[house_fire_houseid][hXo], HouseInfo[house_fire_houseid][hYo], HouseInfo[house_fire_houseid][hZo], HouseInfo[house_fire_houseid][hVwOut], HouseInfo[house_fire_houseid][hIntOut], 2.0);

		// Add a fire to every other house furniture object.
		new bool:skip = false;
		for(new i = 0; i < MAX_HOUSE_OBJ; i++)
		{
			if(HouseInfo[house_fire_houseid][hObject][i] != 0)
			{
				if(skip == false)
				{
					CreateFire(HouseInfo[house_fire_houseid][hoX][i], HouseInfo[house_fire_houseid][hoY][i], HouseInfo[house_fire_houseid][hoZ][i], HouseInfo[house_fire_houseid][hVwIn], HouseInfo[house_fire_houseid][hIntIn], 1.5);
					skip = true;
				}
				else
				{
					skip = false;
				}
			}
		}
	}
}
//============================================//
forward SpeedometerTimer();
public SpeedometerTimer()
{
	foreach(new i : Player)
    {
    	if(!IsPlayerConnected(i) || IsPlayerNPC(i)) continue;

		if(IsPlayerInAnyVehicle(i))
		{
			new vehicleid = GetPlayerVehicleID(i);

		    if(!IsNotAEngineCar(vehicleid))
			{
			    if(GetPVarInt(i, "VD") == 1)
			    {
			    	new Float:speed = GetPlayerSpeed(i, true);
			    	PrintSpeedo(i, speed);
				}
			}
		}
	}
}
//============================================//
forward ELMTimer();
public ELMTimer()
{
	foreach(new i : VehicleIterator)
	{
		if(VehicleInfo[i][vELM] == 1)
		{

			new panels, doors, lights, tires;
        	GetVehicleDamageStatus(i, panels, doors, lights, tires);

			switch(VehicleInfo[i][vELMFlash])
	        {
	        	case 0: UpdateVehicleDamageStatus(i, panels, doors, 2, tires);
	            case 1: UpdateVehicleDamageStatus(i, panels, doors, 5, tires);
	            case 2: UpdateVehicleDamageStatus(i, panels, doors, 2, tires);
	            case 3: UpdateVehicleDamageStatus(i, panels, doors, 4, tires);
	            case 4: UpdateVehicleDamageStatus(i, panels, doors, 5, tires);
	            case 5: UpdateVehicleDamageStatus(i, panels, doors, 4, tires);
	        }

	        if(VehicleInfo[i][vELMFlash] >=5)
	        {
	        	VehicleInfo[i][vELMFlash] = 0;
	        }
			else
			{
				VehicleInfo[i][vELMFlash]++;
			}

			//CarLights(i);
		}
	}
}
//============================================//
public OneSecondTimer()
{
	GMTime();

	new string[128],
		vehicleid;

	if(ra > 0)
	{
		ra--;
	}

	for(new i = 0; i < MAX_FIRES; i++)
	{
	    if(FireInfo[i][fiObject] != 0)
	    {
	    	if(FireInfo[i][fiTime] > 0)
	    	{
	    		FireInfo[i][fiTime]--;
	    	}
	    	else
	    	{
	    		if(IsValidDynamicObject(FireInfo[i][fiObject]))
				{
					DestroyDynamicObject(FireInfo[i][fiObject]);
				}

				FireInfo[i][fiObject] = 0;
				FireInfo[i][fiX] = 0.0;
				FireInfo[i][fiY] = 0.0;
				FireInfo[i][fiZ] = 0.0;
				FireInfo[i][fiWorld] = 0;
				FireInfo[i][fiInt] = 0;
				FireInfo[i][fiTime] = 0;
				FireInfo[i][fiHealth] = 0;
	    	}
	    }
	}

	new Float:vehicle_health;
	foreach(new i : VehicleIterator)
	{
		GetVehicleHealth(i, vehicle_health);

		if(vehicle_health < 301.0)
		{
			SetVehicleHealth(i, 301.0);
		}

	    if(!IsNotAEngineCar(i))
		{
		    if(VehicleInfo[i][vAlarm] != 0)
		    {
		    	new Float:x, Float:y, Float:z;
                GetVehiclePos(i, x, y, z);

		        PlaySoundInArea(1147, x, y, z, 20.0);
				CarLights(i);
		    }

		    if(VehicleInfo[i][vEngine] == 1)
		    {
		    	if(vehicle_health <= 301)
		    	{
		    		VehicleInfo[i][vEngine] = 0;
		    		CarEngine(i, VehicleInfo[i][vEngine]);

		    		if(VehicleInfo[i][vType] == VEHICLE_PERSONAL)
		    		{
						if(VehicleInfo[i][vEngineStats][1] < 0)
						{
							VehicleInfo[i][vEngineStats][1] = 0;
						}

						if(VehicleInfo[i][vBattery][1] < 0)
						{
							VehicleInfo[i][vBattery][1] = 0;
						}
		    		}

		    		foreach(new i2 : Player)
		    		{
		    			if(GetPlayerVehicleID(i2) == i)
		    			{
		    				SendClientMessage(i2, COLOR_WHITE, "The vehicle's engine has stalled and requires a mechanic to fix it. (/call 311)");
		    			}
		    		}

		    		/*
		    		new chance = random(2);
					if(chance == 0)
					{
						new Float:x, Float:y, Float:z;
						GetVehiclePos(i, x, y, z);

						SendFactionMessage(2, COLOR_PINK, "Dispatch: A vehicle has caught fire, all available units respond immediately.");
						format(string, sizeof(string), "Dispatch: Location: %s", GetZone(x, y, z));
						SendFactionMessage(2, COLOR_PINK, string);
						CreateFire(x, y, z, 0, 0, 3.0);
					}
					*/
		    	}

		    	if(VehicleInfo[i][vFuel] <= 1)
		        {
				    VehicleInfo[i][vEngine] = 0;
				    VehicleInfo[i][vFuel] = 0;
	                CarEngine(i, VehicleInfo[i][vEngine]);
		        }

		        if(VehicleInfo[i][vType] == VEHICLE_PERSONAL)
				{
					new Float:dist = GetVehicleDistanceFromPoint(i, VehicleInfo[i][vMileagePosition][0], VehicleInfo[i][vMileagePosition][1], VehicleInfo[i][vMileagePosition][2]);
					VehicleInfo[i][vMileage][1] += floatround(dist);

					GetVehiclePos(i, VehicleInfo[i][vMileagePosition][0], VehicleInfo[i][vMileagePosition][1], VehicleInfo[i][vMileagePosition][2]);
				}
		    }
	    }
	}

    foreach(new i : Player)
    {
		switch(GetPVarInt(i, "PlayerLogged"))
		{
		    case 0:
		    {
		        SetPVarInt(i, "LoginTime", GetPVarInt(i, "LoginTime") + 1);
		        SetPVarInt(i, "CamTime", GetPVarInt(i, "CamTime") + 1);
		       
		        if(GetPVarInt(i, "CamTime") >= 60)
		        {
		            SetPVarInt(i, "CamTime", 0);
		            CallRemoteFunction("LoginCamera","i", i);
		        }

		        if(GetPVarInt(i, "Bot") == 1 && GetPVarInt(i, "LoginTime") > 60)
		        {
		        	cmd_botspawn(i, ""); // spawn the bot if he has reconnected
		        }

		        if(GetPVarInt(i, "LoginTime") >= 640 && GetPVarInt(i, "Registering") != 1)
		        {
		            KickPlayer(i, "You have been kicked for not logging in for over 10 minutes.");
		        }
		    }
		    case 1:
		    {
		    	new Float:health;
		    	GetPlayerHealth(i, health);

		    	new Float:armour;
				GetPlayerArmourEx(i, armour);

				if(GetPVarInt(i, "Admin") < 1 && GetPVarInt(i, "PlayTime") >= 5)
				{
					// Anti CJ skin
			    	if(GetPlayerSkin(i) == 0)
			    	{
			    		SetPlayerSkin(i, 1);
			    	}

			    	// Anti Jet-Pack Hack
					if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_USEJETPACK)
					{
						if(GetPVarInt(i, "BeingBanned") == 0)
						{
							format(string, sizeof(string), "AdmCmd: %s was banned by the server. (Reason: Jetpack Hack)", PlayerInfo[i][pName]);
							SendClientMessageToAll(COLOR_PUBLIC_ADMIN, string);
							BanPlayer(i, "Jetpack Hack", "Server");
						}
					}

					// Anti Armour Hack
					new Float:player_side_armour;
					GetPlayerArmour(i, player_side_armour);
					if(player_side_armour > GetPVarFloat(i, "Armour") && PlayerInfo[i][pArcade] == 0)
					{
						format(string, sizeof(string), "AdmWarn: %s(ID: %d) is possibly armour hacking. (%f armour)", PlayerInfo[i][pName], i, armour);
						SendAdminMessage(COLOR_YELLOW,string);
						SetPlayerArmour(i, GetPVarFloat(i, "Armour"));
					}

					// Anti Speed Hack
					if(IsPlayerInAnyVehicle(i))
					{
						new Float:speed = GetPlayerSpeed(i, true);
						if(ReturnSpeedHack(i, speed))
						{
							format(string, sizeof(string), "AdmWarn: %s(ID: %i) is possibly speed hacking. (%f KM/H)", PlayerInfo[i][pName], i, speed);
							SendAdminMessage(COLOR_YELLOW,string);
						}
					}

					// Anti Ammo Hack
					if(GetPlayerWeapon(i) == PlayerInfo[i][pPlayerWeapon])
					{
						if(GetPlayerWeapon(i) >= 16 && GetPlayerWeapon(i) <= 38)
						{
							new ammo = GetPlayerAmmo(i);
							if(ammo > PlayerInfo[i][pPlayerAmmo] && PlayerInfo[i][pArcade] == 0)
							{
								format(string, sizeof(string), "AdmWarn: %s(ID: %d) is possibly ammo hacking. (%i ammo)", PlayerInfo[i][pName], i, ammo);
								SendAdminMessage(COLOR_YELLOW,string);
								SetPlayerAmmo(i, GetPlayerWeapon(i), PlayerInfo[i][pPlayerAmmo]);
							}
						}
					}

					if(PlayerInfo[i][pDialogOpen] == 1)
					{
						if(IsPlayerRunning(i))
						{
							format(string, sizeof(string), "AdmWarn: %s(ID: %i) is possibly dialog hacking.", PlayerInfo[i][pName], i);
							SendAdminMessage(COLOR_YELLOW, string);
						}
					}
				}

				if(IsPlayerInAnyVehicle(i) && GetPlayerState(i) == PLAYER_STATE_DRIVER)
				{
					if(GetPVarInt(i, "Wound_T") != 0 ||
						GetPVarInt(i, "Wound_A") != 0 ||
						GetPVarInt(i, "Wound_L") != 0)
					{
						SetPlayerDrunkLevel(i, 4500);
					}
				}

				if(GetPVarInt(i, "Job") == JOB_TRUCKER && PlayerInfo[i][pJobStatus] == 2)
		    	{
			    	if(IsTrailerAttachedToVehicle(GetPlayerVehicleID(i)) && PlayerInfo[i][pJobExtraVehicleID] == GetVehicleTrailer(GetPlayerVehicleID(i)))
			    	{
						vehicleid = GetPlayerVehicleID(i);

						if(PlayerInfo[i][pJobProgress] == 0)
						{
							SendClientMessage(i, COLOR_JOB, "The trailer is attached, meaning you can start your route now.");
							PlayerInfo[i][pJobStatus] = 3;
							PlayerInfo[i][pJobProgress] = 0;

							new TruckingCP = random(11);

							PlayerInfo[i][pJobCP] = CreateDynamicRaceCP(2, 
								TruckerRoute[TruckingCP][0],
								TruckerRoute[TruckingCP][1],
								TruckerRoute[TruckingCP][2],
								0.0,0.0,0.0, 3, -1, -1, i, -1);

							format(string, sizeof(string), "Deliver the goods to {FFFFFF}%s{B56AFF}.", GetZone(TruckerRoute[TruckingCP][0],
								TruckerRoute[TruckingCP][1],
								TruckerRoute[TruckingCP][2]));
							SendClientMessage(i, COLOR_JOB, string);
						}
					}
				}

				if(GetPVarInt(i, "ModShopReduce") > 0)
				{
					SetPVarInt(i, "ModShopReduce", GetPVarInt(i, "ModShopReduce") - 1000);
				}

				if(GetPVarInt(i, "GunReduce") > 0)
				{
					SetPVarInt(i, "GunReduce", GetPVarInt(i, "GunReduce") - 1000);
				}

		    	SetPVarInt(i, "Delay", GetPVarInt(i, "Delay") - 1000); // Command delay

		    	if(PlayerInfo[i][pPlantRadio] == 0)
		    	{
		    		for(new i2 = 0; i2 < MAX_BOOM_BOXES; i2++)
		    		{
		    			if(IsPlayerInRangeOfPoint(i, MAX_BOOM_BOX_RANGE, RadioInfo[i2][rX], RadioInfo[i2][rY], RadioInfo[i2][rZ]) &&
		    				RadioInfo[i2][rStatus] == 1 &&
		    				!IsPlayerInAnyVehicle(i))
						{
							PlayerInfo[i][pPlantRadioID] = i2;
							PlayerInfo[i][pPlantRadio] = 1;

							PlayAudioStreamForPlayerEx(i, RadioInfo[i2][rURL], RadioInfo[i2][rX], RadioInfo[i2][rY], RadioInfo[i2][rZ], MAX_BOOM_BOX_RANGE, 1);
						}
		    		}
		    	}

		    	if(PlayerInfo[i][pPlantRadio] == 1)
		    	{
	    			if(!IsPlayerInRangeOfPoint(i, MAX_BOOM_BOX_RANGE, 
	    				RadioInfo[PlayerInfo[i][pPlantRadioID]][rX], 
	    				RadioInfo[PlayerInfo[i][pPlantRadioID]][rY], 
	    				RadioInfo[PlayerInfo[i][pPlantRadioID]][rZ]))
					{
						PlayerInfo[i][pPlantRadio] = 0;
						PlayerInfo[i][pPlantRadioID] = 0;

						StopAudioStreamForPlayerEx(i);
					}
		    	}


				if(PlayerInfo[i][pCmdSpam] > 0)
				{
					PlayerInfo[i][pCmdSpam]--;
				}

				if(PlayerInfo[i][pCmdTime] > 0)
				{
					PlayerInfo[i][pCmdTime]--;

					if(PlayerInfo[i][pCmdTime] <= 0)
					{
						PlayerInfo[i][pCmdTime] = 0;
						PlayerInfo[i][pCmdSpam] = 0;
						PlayerInfo[i][pMute] = 0;
						SendClientMessage(i, COLOR_ERROR, "You are no longer muted.");
					}
				}

	    	    if(IsPlayerInAnyVehicle(i))
				{
					vehicleid = GetPlayerVehicleID(i);

					// Fire Truck script
					if(GetPlayerState(i) == PLAYER_STATE_DRIVER && GetVehicleModel(vehicleid) == 407)
				    {
				    	new keys, ud, lr;
		    			GetPlayerKeys(i, keys, ud, lr);

				    	if(keys & KEY_FIRE)
						{
					    	for(new fi = 0; fi < MAX_FIRES; fi++)
					    	{
					    		if(FireInfo[fi][fiObject] != 0)
					    		{
					    			if(IsPlayerAimObjectID(i, FireInfo[fi][fiObject], 50.0))
					    			{
										FireInfo[fi][fiHealth] -= 5;
								    	if(FireInfo[fi][fiHealth] == 0)
								    	{
								        	if(IsValidDynamicObject(FireInfo[fi][fiObject]))
								        	{
								        		DestroyDynamicObject(FireInfo[fi][fiObject]);
								        	}

								        	FireInfo[fi][fiObject] = 0;
						                	FireInfo[fi][fiX] = 0.0;
						                	FireInfo[fi][fiY] = 0.0;
						                	FireInfo[fi][fiZ] = 0.0;
						                	FireInfo[fi][fiWorld] = 0;
						                	FireInfo[fi][fiInt] = 0;
						                	FireInfo[fi][fiTime] = 0;
						                	FireInfo[fi][fiHealth] = 0;
								    	}
					    			}
					    		}
					    	}
				    	}
				    }
				}

				// Fire extinguishing script
				if(IsAroundFire(i, 1, 2.5) && GetPlayerState(i) == PLAYER_STATE_ONFOOT)
			    {
					if(GetPVarInt(i, "Dead") == 0 && GetPVarInt(i, "Control") == 0 && GetPVarInt(i, "FDDUTY") == 0)
					{
						GetPlayerHealth(i, health);
						SetPlayerHealthEx(i, health - 5);
					}
					else
					{
						new id = IsAroundFire(i, 2, 2.5);

						new keys, ud, lr;
						GetPlayerKeys(i, keys, ud, lr);

						if(keys & KEY_FIRE && GetPlayerWeapon(i) == 42 && IsPlayerAimObjectID(i, FireInfo[id][fiObject], 2.5))
						{
							FireInfo[id][fiHealth] -= 5;
							if(FireInfo[id][fiHealth] == 0)
							{
						    	if(IsValidDynamicObject(FireInfo[id][fiObject]))
						    	{
						    		DestroyDynamicObject(FireInfo[id][fiObject]);
						    	}

						    	FireInfo[id][fiObject] = 0;
						    	FireInfo[id][fiX] = 0.0;
						    	FireInfo[id][fiY] = 0.0;
						    	FireInfo[id][fiZ] = 0.0;
						    	FireInfo[id][fiWorld] = 0;
						    	FireInfo[id][fiInt] = 0;
						    	FireInfo[id][fiTime] = 0;
						    	FireInfo[id][fiHealth] = 0;
							}
						}
					}
			    }

			    // Prevent the payer from running with handcuffs on.
			    if(GetPlayerState(i) == PLAYER_STATE_ONFOOT && GetPVarInt(i, "Control") == 0)
			    {
			    	new Float:speed = GetPlayerSpeed(i, true);
			        if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_CUFFED && speed >= 7.0)
			        {
				        ClearAnimationsEx(i);
		                ApplyAnimationEx(i, "ped", "FLOOR_hit_f", 4.0, 0, 1, 1, 1, -1);
			            SetTimerEx("PlayerGetup", 5000, false, "i", i);
			        }

					new animlib[32];
					new animname[32];
					GetAnimationName(GetPlayerAnimationIndex(i), animlib, sizeof(animlib), animname, sizeof(animname));

					if(strcmp(animname, "JUMP_GLIDE", true) == 0 && speed >= 12.0)
					{
						SetPVarInt(i, "JumpCount", GetPVarInt(i, "JumpCount") + 1);
					}

					SetPVarInt(i, "JumpTime", GetPVarInt(i, "JumpTime") - 1000);
					if(GetPVarInt(i, "JumpTime") <= 0)
			        {
			        	if(GetPVarInt(i, "JumpCount") >= 45 && GetPVarInt(i, "AFKTime") < 5) // 7 jumps per 10 seconds
				        {
							format(string, sizeof(string), "AdmWarn: %s (ID: %i) has been detected as a bunny-hopper.", PlayerInfo[i][pName], i);
							SendAdminMessage(COLOR_YELLOW, string);
				        }

			        	SetPVarInt(i, "JumpCount", 0);
			        	SetPVarInt(i, "JumpTime", 60000);
			        }

			        if(GetPVarInt(i, "Wound_L") == 1)
			        {
			        	new keys, ud, lr;
    					GetPlayerKeys(i, keys, ud, lr);

			            if(ud == KEY_UP || ud == KEY_DOWN || lr == KEY_LEFT || lr == KEY_RIGHT)
			            {
			                if(speed >= 10.0)
			                {
			                    if(strcmp(animname, "HIT_behind", true) != 0)
							    {
							        if(GetCount() > GetPVarInt(i, "LegDelay"))
							        {
			                        	ApplyAnimationEx(i, "PED", "HIT_behind", 3.0, 0, 0, 0, 0, 0);
			                        	SetPVarInt(i, "LegDelay", GetCount()+1000);
			                    	}
			                    }
					        }
					    }
			        }
			    }

		    	if(IsPlayerInAnyVehicle(i) && GetPlayerState(i) == PLAYER_STATE_DRIVER)
				{
				    if(!IsNotAEngineCar(GetPlayerVehicleID(i)))
				    {
			    		if(GetPlayerSpeed(i, true) >= 110.0)
			    		{
							for(new h = 0; h < sizeof(SpeedCamera); h++)
							{
	        				    if(IsPlayerInRangeOfPoint(i, 10.0, SpeedCamera[h][0], SpeedCamera[h][1], SpeedCamera[h][2]))
	        				    {
	            				    if(PlayerInfo[i][pSpeedDelay] < GetCount())
	            				    {
		            				    if(VehicleInfo[GetPlayerVehicleID(i)][vType] != VEHICLE_LSPD &&
											VehicleInfo[GetPlayerVehicleID(i)][vType] != VEHICLE_LSFD &&
											VehicleInfo[GetPlayerVehicleID(i)][vType] != VEHICLE_GOV)
										{
		                    				PlayerInfo[i][pSpeedDelay] = GetCount() + 10000;
		                    				format(string, sizeof(string), "You have been caught on the %s speed camera.", GetZone(SpeedCamera[h][0], SpeedCamera[h][1], SpeedCamera[h][2]));
		                    				SendClientMessage(i,COLOR_BLUE,string);
				            				PlayerPlaySound(i, 1132, 0.0, 0.0, 0.0);

				            				new query[516], year, month, day, hour, minute, second;
				            				getdate(year, month, day);
				            				gettime(hour,minute,second);

				            				new datum[64], timel[64];
				            				format(timel, sizeof(timel), "%d:%d:%d", hour, minute, second);
					            			format(datum, sizeof(datum), "%d-%d-%d", year, month, day);

				            				mysql_format(handlesql, query, sizeof(query), "INSERT INTO `tickets`(`player`, `officer`, `time`, `date`, `amount`, `reason`) VALUES ('%e','%e','%e','%e',%d,'%e')",
				            					PlayerInfo[i][pUsername], "LS-Speed-Camera",
				            					timel,datum, 250, "Speeding");
				            				mysql_pquery(handlesql, query);
										}
	                        		}
	                    		}
							}
						}
					}
				}

	    		if(PlayerInfo[i][pBeanbaggedTime] > 0)
	    		{
	    			PlayerInfo[i][pBeanbaggedTime]--;

		    		if(PlayerInfo[i][pBeanbaggedTime] == 0 && PlayerInfo[i][pBeanbagged] != 0)
		    		{
		    			if(PlayerInfo[i][pBeanbagged] >= 3)
		    			{
		    				PlayerInfo[i][pBeanbagged] = 0;
		    			}

		    			TogglePlayerControllableEx(i, true);
		    			ApplyAnimationEx(i,"PED","getup",4.0,0,0,0,0,0);
		    		}
	    		}

	    		new animlib[32];
        		new animname[32];
	    		GetAnimationName(GetPlayerAnimationIndex(i), animlib, 32, animname, 32);

		        if(PlayerInfo[i][pBeanbaggedTime] > 0)
		        {
		        	if(strcmp(animlib, "PED") || strcmp(animname, "FLOOR_HIT"))
		        	{
		        		ApplyAnimationEx(i, "PED", "FLOOR_HIT", 4.0, 0, 1, 1, 1, -1);
		        	}
		        }

				if(GetPVarInt(i, "AFKTime") < 10) {
					SetPVarInt(i, "sa_counter", GetPVarInt(i, "sa_counter") + 1);
				}
				
				//CheckIfBanned(i);

				if(GetPlayerVirtualWorld(i) == 0 && GetPlayerInterior(i) == 0)
				{
					if(GetPVarInt(i, "DrugTime") == 0)
					{
						SetPlayerTime(i, GMHour, GMMin);
						new allow = 0;

						if(IsPlayerInAnyVehicle(i))
						{
						    if(!IsNotAEngineCar(GetPlayerVehicleID(i)))
						    {
						        if(VehicleInfo[GetPlayerVehicleID(i)][vWipers] == 1)
						        {
									if(GMWeather == 8)
									{
						            	SetPlayerWeather(i, 9);
						        	}
						        }
						    }
						}

						if(allow == 0)
						{
							SetPlayerWeather(i, GMWeather);
						}
					}
				}
				else if(GetPlayerVirtualWorld(i) != 0 || GetPlayerInterior(i) != 0)
				{
					if(GetPVarInt(i, "DrugTime") == 0)
					{
						//SetPlayerTime(i, 12, 0);
						//SetPlayerWeather(i, 0);
					}
				}

				if(GetPVarInt(i, "RammingHouse") != 0)
				{
				    if(GetPVarInt(i, "RammingTime") > 0)
				    {
				        SetPVarInt(i, "RammingTime", GetPVarInt(i, "RammingTime") - 1);
	        	  		format(string, sizeof(string),"~b~%d",GetPVarInt(i, "RammingTime"));
	    				GameTextForPlayer(i,string, 1000, 5);
				    }
                    else if(GetPVarInt(i, "RammingTime") == 0)
					{
						new chance = random(2);

						switch(chance)
						{
							case 0:
							{
								PlayerPlaySound(i, 1145, 0.0, 0.0, 0.0);
						 		GameTextForPlayer(i, "~w~House~n~~g~Unlocked", 2000, 3);

						 		HouseInfo[GetPVarInt(i, "RammingHouse")][hLocked] = 0;

						 		SendClientMessage(i, COLOR_WHITE, "Door has been rammed open.");
							}

							case 1:
							{
								GameTextForPlayer(i, "~r~Failed!", 2000, 3);
							}
						}

						DeletePVar(i, "RammingTime");
						DeletePVar(i, "RammingHouse");
					}
				}
				if(GetPVarInt(i, "RammingBiz") != 0)
				{
				    if(GetPVarInt(i, "RammingTime") > 0)
				    {
				        SetPVarInt(i, "RammingTime", GetPVarInt(i, "RammingTime") - 1);
	        	  		format(string, sizeof(string),"~b~%d",GetPVarInt(i, "RammingTime"));
	    				GameTextForPlayer(i,string, 1000, 5);
				    }
                    else if(GetPVarInt(i, "RammingTime") == 0)
					{
						new chance = random(2);

						switch(chance)
						{
							case 0:
							{
								PlayerPlaySound(i, 1145, 0.0, 0.0, 0.0);
						 		GameTextForPlayer(i, "~w~Business~n~~g~Unlocked", 2000, 3);

						 		BizInfo[GetPVarInt(i, "RammingBiz")][Locked] = 0;

						 		SendClientMessage(i, COLOR_WHITE, "Door has been rammed open.");
							}
							case 1:
							{
								GameTextForPlayer(i, "~r~Failed!", 2000, 3);
							}
						}

						DeletePVar(i, "RammingTime");
						DeletePVar(i, "RammingBiz");
					}
				}
				for(new h = 0; h < sizeof(PayPhone); h++)
	            {
	                if(IsPlayerInRangeOfPoint(i,1.0,PayPhone[h][0], PayPhone[h][1], PayPhone[h][2]))
	                {
	                    CreateLableText(i,"Payphone"," ~w~Type ~b~/payphone ~w~to call.");
	                }
	            }
				if(GetPVarInt(i, "Mobile") != INVALID_MAXPL)
				{
				    SetPVarInt(i, "OnPhone", GetPVarInt(i, "OnPhone") + 1);
				}
				else
				{
				    SetPVarInt(i, "OnPhone", 0);
				}
		        if(IsPlayerInAnyVehicle(i) && !IsNotAEngineCar(GetPlayerVehicleID(i)))
	            {
                    // TAXI FARE SCRIPT //
                    new driver = GetPVarInt(i, "TaxiBoss");
                    vehicleid = GetPlayerVehicleID(i);
                    if(GetPlayerState(i) == PLAYER_STATE_PASSENGER)
                    {
                        if(IsJobVehicle(driver))
                        {
                            if(GetPVarInt(i, "TaxiAM") > 0)
                            {
                                if(IsPlayerConnected(driver))
                                {
                                    if(vehicleid == GetPlayerVehicleID(driver))
                                    {
                                        if(GetPVarInt(driver, "OnRoute") != 0 && GetPVarInt(driver, "Job") == 5)
                                        {
											if(GetPlayerMoneyEx(i) >= GetPVarInt(i, "TaxiAm"))
											{
												if(GetPVarInt(i, "TaxiStep") <= 9) { format(string, 128, "~r~Taxifare:~n~rate: ~g~%s~n~~b~0%d ~w~| ~g~%s", FormatMoney(GetPVarInt(i, "TaxiCost")), GetPVarInt(i, "TaxiStep"), FormatMoney(GetPVarInt(i, "TaxiAm"))); }
												if(GetPVarInt(i, "TaxiStep") >= 10) { format(string, 128, "~r~Taxifare~n~rate: ~g~%s~n~~b~%d ~w~| ~g~%s", FormatMoney(GetPVarInt(i, "TaxiCost")), GetPVarInt(i, "TaxiStep"), FormatMoney(GetPVarInt(i, "TaxiAm"))); }
												GameTextForPlayer(i, string, 1000, 5);
												//==========//
                                                SetPVarInt(i, "TaxiStep", GetPVarInt(i, "TaxiStep")+1);
                                                if(GetPVarInt(i, "TaxiStep") >= 10)
                                                {
                                                    SetPVarInt(i, "TaxiStep", 0);
                                                    SetPVarInt(i, "TaxiAm", GetPVarInt(i, "TaxiAm")+GetPVarInt(i, "TaxiCost"));
                                                }
                                                //==========//
                                            }
                                            else
                                            {
                                                TaxiPayment(i);
                                                RemovePlayerFromVehicle(i);
                                            }
                                        }
                                        else
                                        {
                                            DeletePVar(i, "TaxiBoss"), DeletePVar(i, "TaxiCost");
	                                        DeletePVar(i, "TaxiStep"), DeletePVar(i, "TaxiAm");
                                        }
                                    }
                                    else
                                    {
                                        DeletePVar(i, "TaxiBoss"), DeletePVar(i, "TaxiCost");
	                                    DeletePVar(i, "TaxiStep"), DeletePVar(i, "TaxiAm");
                                    }
                                }
                                else
                                {
                                    DeletePVar(i, "TaxiBoss"), DeletePVar(i, "TaxiCost");
	                                DeletePVar(i, "TaxiStep"), DeletePVar(i, "TaxiAm");
                                }
                            }
                        }
                    }
	            }

		        new Float:x, Float:y, Float:z;
		        GetPlayerPos(i, x, y, z);

		        PlayerInfo[i][pPos][0]=x;
                PlayerInfo[i][pPos][1]=y;
                PlayerInfo[i][pPos][2]=z;

	            if(GetPVarInt(i, "JobReduce") > 0)
				{
				    SetPVarInt(i, "JobReduce", GetPVarInt(i, "JobReduce")-1);
				    if(GetPVarInt(i, "JobReduce") == 0) { SCM(i, COLOR_LIGHTBLUE, "Timer expired, you may now continue your job route!"); }
				}

	    	    if(GetPVarInt(i, "CuffedTime") > 0)
				{
		    		SetPVarInt(i, "CuffedTime", GetPVarInt(i, "CuffedTime")-1);
		    		if(GetPVarInt(i, "CuffedTime") == 0)
					{
					    SetPVarInt(i, "Cuffed", 0);
					    SetPVarInt(i, "Tazed", 0);
					    TogglePlayerControllableEx(i,true);
					}
				}
				if(GetPVarInt(i, "ShotTime") > 0)
				{
		    		SetPVarInt(i, "ShotTime", GetPVarInt(i, "ShotTime")-1);
		    		if(GetPVarInt(i, "ShotTime") == 0) {
					    ShotFired(i); }
				}
				if(GetPVarInt(i, "Drag") != INVALID_MAXPL)
				{
		    		SetPlayerVirtualWorld(i,GetPlayerVirtualWorld(GetPVarInt(i, "Drag")));
		    		SetPlayerInterior(i,GetPlayerInterior(GetPVarInt(i, "Drag")));
		    		GetPlayerPos(GetPVarInt(i, "Drag"),x,y,z);
		    		SetPlayerPosEx(i,x+1,y,z);
		    		SetCameraBehindPlayer(i);
		    		if(GetPVarInt(GetPVarInt(i, "Drag"), "Member") == FACTION_FOX_ENTERPRISE) { ApplyAnimationEx(i, "INT_HOUSE","BED_Loop_R", 4.0,1,1,1,1,1); }
				}
	    	    if(GetPVarInt(i, "HitMark") > 0)
				{
				    SetPVarInt(i, "HitMark", GetPVarInt(i, "HitMark")-1);
				    if(GetPVarInt(i, "HitMark") == 0)
				    {
				        TextDrawHideForPlayer(i,HitMark);
				    }
				}
	    	    if(GetPVarInt(i, "LableDraw") > 0)
				{
				    SetPVarInt(i, "LableDraw", GetPVarInt(i, "LableDraw")-1);
				    if(GetPVarInt(i, "LableDraw") == 0)
				    {
				        PlayerTextDrawDestroy(i, LableDraw[i]);
						PlayerTextDrawDestroy(i, UsedDraw[i]);
                        DeletePVar(i,"LableDraw");
				    }
				}
				if(GetPVarInt(i, "OnRoute") != 0)
				{
					if(GetPVarInt(i, "OnRouteTime") > 0)
					{
						SetPVarInt(i, "OnRouteTime", GetPVarInt(i, "OnRouteTime")+1);
					}
					
				    if(GetPVarInt(i, "RouteOT") > 0)
				    {
						if(GetPlayerState(i) != PLAYER_STATE_DRIVER)
						{
				            SetPVarInt(i, "RouteOT", GetPVarInt(i, "RouteOT")-1);
				            format(string, sizeof(string), "~n~~n~~w~you have ~r~%d ~w~seconds to get back in your ~y~vehicle ~w~!", GetPVarInt(i, "RouteOT"));
				            GameTextForPlayer(i, string, 1000, 4);
				            if(GetPVarInt(i, "RouteOT") == 0)
				            {
				                DeletePVar(i, "OnRoute");
	                            if(GetPVarInt(i, "RouteVeh") >= 1) {
	                                if(VehicleInfo[GetPVarInt(i, "RouteVeh")][vType] == VEHICLE_JOB) {
					                DespawnVehicle(GetPVarInt(i, "RouteVeh")); }
					            }
	                            DeletePVar(i, "RouteVeh");
	                            DeletePVar(i, "PizzaTime");
	                            SendClientMessage(i, COLOR_WHITE, "Your job route has ended, as you left your vehicle!");
	                            DisablePlayerCheckpoint(i);
	                            TogglePlayerAllDynamicCPs(i, true);
				                DeletePVar(i, "RouteOT");
				            }
				        }
				    }
				}

				if (GetPVarInt(i, "Dead") == 3)
        		{
        		    SetPVarInt(i, "DT", GetPVarInt(i, "DT")+1);
					SetPlayerDrunkLevel(i, 4000);
					if(GetPVarInt(i, "DT") >= GetPVarInt(i, "DeadT"))
					{
					    SetPlayerDrunkLevel(i, 1000);
					    AfterSpawnHos(i);
					    SetPVarInt(i, "DT", 0);
					}
        		}

				if (GetPVarInt(i, "PizzaTime") >= 1 && GetPVarInt(i, "OnRoute") == 2 && GetPVarInt(i, "Job") == 4)
	            {
	                SetPVarInt(i, "PizzaTimeEx", GetPVarInt(i, "PizzaTimeEx")+1);
	        	    SetPVarInt(i, "PizzaTime", GetPVarInt(i, "PizzaTime")-1);
				    format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~w~%s",PrintTime(GetPVarInt(i, "PizzaTime"),5));
		    		GameTextForPlayer(i, string, 1000, 5);
		    		
		    		new v = GetPlayerVehicleID(i);
		    		new Float:vh;
					GetVehicleHealth(v, vh);

					if(vh < 950)
					{
			    	    SendClientMessage(i, COLOR_ERROR, "FAILED: The food got messed up because of your reckless driving!");
			    	    SetPVarInt(i, "OnRoute", 1);
			    	    SetPlayerCheckpoint(i, 2111.6963, -1788.6849, 13.5608, 2.0);
					}
				    if(GetPVarInt(i, "PizzaTime") == 0)
				    {
			    	    SendClientMessage(i, COLOR_ERROR, "FAILED: The pizza was too cold!");
			    	    SetPVarInt(i, "OnRoute", 1);
			    	    SetPlayerCheckpoint(i, 2111.6963, -1788.6849, 13.5608, 2.0);
				    }
	    	    }
        		if(GetPVarInt(i, "Jailed") > 0 && GetPVarInt(i, "Jailed") != 3)
        		{
		    		if(GetPVarInt(i, "JailTime") > 0)
		    		{
						if(GetPVarInt(i, "AdmWrnJail") == 0 && GetPVarInt(i, "Jailed") == 1 && !IsPlayerInRangeOfPoint(i, 100.0, -1406.7714, 1245.1904, 1029.8984))
						{
							format(string, sizeof(string), "AdmWarn: %s (ID: %i) is admin jailed but not at the right coordinates.", PlayerInfo[i][pName], i);
					        SendAdminMessage(COLOR_YELLOW, string);
							SetPVarInt(i, "AdmWrnJail", 1);
							SetTimerEx("AdmWrnJailTimer", 30000, false, "i", i);
						}

		        		SetPVarInt(i, "JailTime", GetPVarInt(i, "JailTime") - 1);
		    		}
					
		    		if(GetPVarInt(i, "JailTime") == 0) {
		        		SetPlayerPosEx(i, 1552.7952,-1675.5333,16.1953);
		        		SetPlayerInterior(i,0);
		        		SendClientMessage(i, COLOR_WHITE,"You have paid your debt to society.");
                		GameTextForPlayer(i, "~g~Freedom~n~~w~Try to be a better citizen", 5000, 1);
		        		TogglePlayerControllable(i,true);
	            		SetPlayerVirtualWorld(i,0);
	            		SetPVarInt(i, "Jailed", 0);
	            		PlayerInfo[i][pMute]=0;
	            		SetPVarInt(i, "Bail", 0);
	            		SetPVarInt(i, "Cuffed", 0);
	            		SetPVarInt(i, "CuffedTime", 0);
	            		SetPVarInt(i, "Mute", 0);
	        		}
				}
        		if(GetPVarInt(i, "TakeTest") >= 2)
				{
					new Float:speed = GetPlayerSpeed(i, true);
					if(GetPVarFloat(i,"TestSpeed") < speed)
					{
						SetPVarFloat(i,"TestSpeed",speed);
					}

		    		format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~w~%s", PrintTime(GetPVarInt(i, "TestTime"), 20));
		    		GameTextForPlayer(i, string, 1000, 5);
		    		SetPVarInt(i, "TestTime", GetPVarInt(i, "TestTime")+1);
				}
				if(GetPVarInt(i, "RingTone") > 0)
				{
					switch(GetPVarInt(i, "RingTone"))
					{
			    		case 1:
			    		{
			    			new sendername[MAX_PLAYER_NAME + 1];
                    		format(sendername, sizeof(sendername), "%s", PlayerNameEx(i));
                    		GiveNameSpace(sendername);
			        		format(string, sizeof(string), "*** Phone rings (( %s ))", sendername);
			        		ProxDetector(30.0, i, string, COLOR_PURPLE);
			        		SetPVarInt(i, "RingTone", 2);
			        		PlaySoundPlyRadius(i, 20600, 10.0);
			    		}
			    		case 2:
			    		{
			    			SetPVarInt(i, "RingTone", 3);
			    		}
			    		case 3:
			    		{
			    			SetPVarInt(i, "RingTone", 4);
			    		}
			    		case 4:
			    		{
			    			SetPVarInt(i, "RingTone", 5);
			    		}
			    		case 5:
			    		{
			    			SetPVarInt(i, "RingTone", 1);
			    		}
					}
				}
				if(GetPVarInt(i, "RingPhone") > 0)
				{
					switch(GetPVarInt(i, "RingPhone"))
					{
			    		case 1:
			    		{
			        		SetPVarInt(i, "RingPhone", 2);
			        		//PlayAudioStreamForPlayerEx(i,"http://k007.kiwi6.com/hotlink/gnmhctmzbt/dial-tone.mp3");
			    		}
			    		case 2: { SetPVarInt(i, "RingPhone", 3); }
			    		case 3: { SetPVarInt(i, "RingPhone", 4); }
			    		case 4: { SetPVarInt(i, "RingPhone", 5); }
			    		case 5: { SetPVarInt(i, "RingPhone", 1); }
					}
				}
				if(GetPVarInt(i, "TagUse") > 0)
				{
				    SetPlayerChatBubble(i, PlayerInfo[i][pTagMsg], COLOR_WHITE, 10.0, 1000);
				}
				if(GetPVarInt(i, "DrugTime") > 0)
				{
		    		SetPVarInt(i, "DrugTime", GetPVarInt(i, "DrugTime")-1);
		    		switch(GetPVarInt(i, "DrugHigh"))
		    		{
		    		    case 501: // cocaine
		    		    {
		    		    	GetPlayerArmourEx(i, armour);
		    		    	SetPlayerArmourEx(i, armour + (10.0 / (DRUG_TIME_COCAINE)));
		    		    }
		    		    case 502: // crack
		    		    {
		    		    	GetPlayerArmourEx(i, armour);
		    		    	SetPlayerArmourEx(i, armour + (12.5 / (DRUG_TIME_CRACK)));
		    		    }
		    		    case 506: // weed
		    		    {
		    		    	if(health <= 98.9)
		    		    	{
		    		    		GetPlayerHealthEx(i, health);
		    		    		SetPlayerHealthEx(i, health + 0.10);
		    		    	}
		    		    	
		    		    	GetPlayerArmourEx(i, armour);
		    		    	SetPlayerArmourEx(i, armour + (5.0 / (DRUG_TIME_CANNABIS)));
		    		    }
		    		}

		    		if(armour > MAX_PLAYER_ARMOUR)
		    		{
		    			SetPlayerArmourEx(i, MAX_PLAYER_ARMOUR);
		    		}

            		if(GetPVarInt(i, "DrugTime") == 0)
					{
					    GameTextForPlayer(i, "~w~Drug Effect~n~~p~Gone", 4000, 1);
					    DeletePVar(i,"DrugHigh");
					    SetPVarInt(i, "Hunger", 3);
					}
				}
	    	    if(GetPlayerState(i) != PLAYER_STATE_SPECTATING)
				{
				    SetPVarInt(i, "PlayTime", GetPVarInt(i, "PlayTime")+1);
					if(GetPVarInt(i, "PlayTime") >= 60 && GetPVarInt(i, "Crash") > 0) { SetPVarInt(i, "Crash", 0); }
				    if(GetPVarInt(i, "PlayTime") >= 120 && GetPVarInt(i, "Crashes") > 0) { SetPVarInt(i, "Crashes", 0); }
				    if(GetPVarInt(i, "PlayTime") >= 28800) {
				    GiveAchievement(i, 14); }
				}

				if(GetPVarInt(i, "AFKTime") < 10)
				{
					SetPVarInt(i, "AFKTime", GetPVarInt(i, "AFKTime") + 1);
					if(PlayerInfo[i][pIdleTime] > 30 && GetPVarInt(i, "Bot") != 1) // Idle for over thirty minutes
					{
					    format(string, sizeof(string),"Idle - %d Minutes", PlayerInfo[i][pIdleTime]);
                        SetPlayerChatBubble(i, string, COLOR_WHITE, 10.0, 2000);
					}
				}
                else
                {
                    SetPVarInt(i, "AFKTime", GetPVarInt(i, "AFKTime") + 1);

                    if(GetPVarInt(i, "Bot") == 1 && GetPVarInt(i, "AFKTime") >= 1000)
                    {
                    	SetPVarInt(i, "AFKTime", 13);
                    }

					format(string, sizeof(string),"AFK - %d Seconds", GetPVarInt(i, "AFKTime"));
                    SetPlayerChatBubble(i, string, COLOR_WHITE, 10.0, 2000);
                    SetPVarInt(i, "EnterVehicle" , GetCount()+5000);
                }

                if(GetPVarInt(i, "Hotwire") > 0)
				{
		    		SetPVarInt(i, "Hotwire", GetPVarInt(i, "Hotwire")+1);

				    if(GetPVarInt(i, "Hotwire") >= 61)
				    {
				        DeletePVar(i,"HotWire");
				        TogglePlayerControllableEx(i,true);

				        new sendername[MAX_PLAYER_NAME + 1];
				        format(sendername, sizeof(sendername), "%s", PlayerNameEx(i));
					    GiveNameSpace(sendername);
				        new rand = random(6)+1;
						switch(rand)
						{
						    case 1,3,5:
						    {
    				            format(string, sizeof(string), "*** Hotwire attempt successful. (( %s ))", sendername);
    				            ProxDetector(30.0, i, string, COLOR_PURPLE);
    				            VehicleInfo[GetPlayerVehicleID(i)][vEngine]=1;
    				            VehicleInfo[GetPlayerVehicleID(i)][vLights]=1;
    				            CarLights(GetPlayerVehicleID(i));
	                            CarEngine(GetPlayerVehicleID(i),1);
			    			    SendFactionMessage(1, COLOR_BLUE, "HQ: All Units - HQ: Vehicle Theft.");
			    			    format(string, sizeof(string), "HQ: %s - Plate: %s.", VehicleName[GetVehicleModel(GetPlayerVehicleID(i))-400], VehicleInfo[GetPlayerVehicleID(i)][vPlate]);
			    			    SendFactionMessage(1, COLOR_BLUE, string);
							    format(string, sizeof(string), "HQ: Location: %s",GetPlayerArea(i));
							    SendFactionMessage(1, COLOR_BLUE, string);
							    StopProgress(i);
							    TriggerBomb(GetPlayerVehicleID(i));
						    }
						    case 2,4,6:
						    {
						        format(string, sizeof(string), "*** Hotwire attempt failed. (( %s ))", sendername);
    				            ProxDetector(30.0, i, string, COLOR_PURPLE);
	                            RemovePlayerFromVehicle(i);
	                            StopProgress(i);
						    }
						}
				    }
				}
				if(GetPVarInt(i, "RamHouse") > 0)
				{
				    if(IsPlayerInRangeOfPoint(i,2.0, HouseInfo[GetPVarInt(i, "RamHouseID")][hXo], HouseInfo[GetPVarInt(i, "RamHouseID")][hYo], HouseInfo[GetPVarInt(i, "RamHouseID")][hZo]))
				    {
				        SetPVarInt(i, "RamHouse", GetPVarInt(i, "RamHouse")-1);
				        if(GetPVarInt(i, "RamHouse") == 0)
				        {
					        new rand, hid = GetPVarInt(i, "RamHouseID"), found = 0;
					        switch(HouseInfo[hid][hLockLvl])
					        {
					            case 0 .. 1:
					            {
					                rand = random(2)+1;
					            }
					            case 2 .. 3:
					            {
					                rand = random(4)+1;
					            }
					        }
						    switch(rand)
						    {
						        case 1:
						        {
    				                SendClientMessage(i, COLOR_WHITE, "The house door broke down and is now enterable.");
    				                HouseInfo[hid][hLocked]=0;
    				                DeletePVar(i,"RamHouse");
						            DeletePVar(i,"RamHouseID");
						            StopProgress(i);
						            if(GetPVarInt(i, "Member") == FACTION_LSPD)
	    				            {
									    if(x > 46.7115 && y > -2755.979 && x < 2931.147 && y < -548.8602)
									    {
									        if(HouseInfo[hid][hAlarm] == 1 && HouseInfo[hid][hBasic] == 1)
									        {
			    					            SendFactionMessage(1, COLOR_BLUE, "HQ: All Units - HQ: House Burglary.");
									            format(string, sizeof(string), "HQ: Location: %s",GetPlayerArea(i));
									            SendFactionMessage(1, COLOR_BLUE, string);
									            HouseAlarm(GetPVarInt(i, "RamHouseID"), 1);
									            PlaySoundInArea(3401, x, y, z, 20.0);
									            found++;
									        }
								        }

								        if(found != 0)
								        {
								        	SendBurg(hid, 1);
								    	}
						            }
						        }
						        default:
						        {
						            SendClientMessage(i, COLOR_WHITE, "Attempt failed on breaking the house door.");
    				                DeletePVar(i,"RamHouse");
						            DeletePVar(i,"RamHouseID");
						            StopProgress(i);
						        }
							}
				        }
				    }
				    else
				    {
				        DeletePVar(i,"RamHouse");
						DeletePVar(i,"RamHouseID");
						SendClientMessage(i,COLOR_ERROR, "Attempt failed, REASON:[left the door].");
						StopProgress(i);
				    }
				}
				if(GetPVarInt(i, "RamVehicle") > 0) {
				    new carid = PlayerToCar(i, 2, 4.0), found = 0;
				    if(GetPVarInt(i, "RamVehID") == carid) {
				        SetPVarInt(i, "RamVehicle", GetPVarInt(i, "RamVehicle") + 1);
				        if(GetPVarInt(i, "RamVehicle") >= GetPVarInt(i, "RamVehTime")) {
					        new rand;
					        switch(VehicleInfo[carid][vLockLvl]) {
					            case 0 .. 1: { rand = random(2)+1; }
					            case 2: { rand = random(3)+1; }
					            case 3: { rand = random(4)+1; }
					        }
						    switch(rand)
						    {
						        case 1:
						        {
						            foreach(new i2 : Player)
    								{
					                    SetVehicleParamsForPlayer(carid, i2, 0, 0);
					                }

                                    VehicleInfo[carid][vLock] = 0;
                                    
                                    new engine, lights, alarm, lock, bonnet, boot, objective;
					  				GetVehicleParamsEx(carid, engine, lights, alarm, lock, bonnet, boot, objective);
						            SetVehicleParamsEx(carid, engine, lights, alarm, VehicleInfo[carid][vLock], bonnet, boot, objective);

                                    format(string, sizeof(string),"The %s's door broke open.", VehicleName[GetVehicleModel(carid)-400]);
    				                SendClientMessage(i, COLOR_WHITE, string);
    				                DeletePVar(i,"RamVehicle");
						            DeletePVar(i,"RamHouseID");
						            StopProgress(i);
						            if(VehicleInfo[carid][vAlarmLvl] >= 1)
						            {
						                VehicleInfo[carid][vAlarm]=1;
						                if(GetPVarInt(i, "Member") == FACTION_LSG)
	    				                {
	    				                    GetPlayerPos(i, x, y, z);
									        if(x > 46.7115 && y > -2755.979 && x < 2931.147 && y < -548.8602)
									        {
			    					            SendFactionMessage(1, COLOR_BLUE, "HQ: All Units - HQ: Vehicle Burglary.");
									            format(string, sizeof(string), "HQ: Location: %s",GetPlayerArea(i));
									            SendFactionMessage(1, COLOR_BLUE, string);
									            found++;
								            }
						                }
						                if(found != 0) {
						                SendBurg(carid, 2); }
						            }
						        }
						        default:
						        {
						            SendClientMessage(i, COLOR_ERROR, "Attempt failed!");
    				                DeletePVar(i,"RamVehicle");
						            DeletePVar(i,"RamVehID");
						            StopProgress(i);
						            if(VehicleInfo[carid][vAlarmLvl] >= 2) { VehicleInfo[carid][vAlarm]=1; }
						        }
							}
				        }
				    }
				    else
				    {
				        DeletePVar(i,"RamVehicle");
						DeletePVar(i,"RamVehID");
						SendClientMessage(i,COLOR_ERROR, "Attempt failed, REASON:[left the vehicle]!");
						StopProgress(i);
						if(VehicleInfo[carid][vAlarmLvl] >= 2) { VehicleInfo[carid][vAlarm]=1; }
				    }
				}
		    	//============//
		    	// Weapon Hack//
		    	//============//
		    	new sweapon, sammo, founda = GetAdminCount(2), gunname[128];
		    	if(GetPVarInt(i, "Admin") == 0 && GetPlayerState(i) != PLAYER_STATE_WASTED && GetPlayerState(i) != PLAYER_STATE_SPECTATING)
		    	{
		    	    new found[3];
		            for (new w = 0; w < 9; w++)
			        {
				        GetPlayerWeaponData(i, w, sweapon, sammo);
				        if(DisabledWeapon(GetPVarInt(i, "ConnectTime"), sweapon, GetPVarInt(i, "Member")))
				        {
				            if(GetPVarInt(i, "BeingBanned") == 0)
				            {
				                GetWeaponName(sweapon, gunname, sizeof(gunname));
					            format(string, sizeof(string), "AdmCmd: %s was banned by the server Reason:[Forbidden Weapons (%s)].", PlayerInfo[i][pName], gunname);
					            SendClientMessageToAll(COLOR_PUBLIC_ADMIN, string);
					            format(string, sizeof(string), "Forbidden Weapon: %s", gunname);
		                        BanPlayer(i, string, "Server");
		                    }
		                    return 1;
				        }
				    }
				    if(found[1] >= 1 && found[2] == 0) // Found Weapon!
				    {
				        switch(GetPVarInt(i, "GUNHCKWARN"))
				        {
				            case 0, 1:
				            {
				                SetPVarInt(i, "GUNHCKWARN", GetPVarInt(i, "GUNHCKWARN")+1);
				            }
				            case 2:
				            {
				                if(GetPVarInt(i, "LSPD_Ta") == 0) { ResetPlayerWeaponsEx(i); }
				                SetPVarInt(i, "GUNHCKWARN", 0);
				                if(founda == 0)
				                {
				                    if(GetPVarInt(i, "BeingBanned") == 0)
				                    {
				                        if(GetPVarInt(i, "LSPD_Ta") == 0)
				                        {
				                            /*PlayerInfo[i][pPlayerWeapon]=0, PlayerInfo[i][pPlayerAmmo]=0;
					                        format(string, sizeof(string), "AdmCmd: %s was banned by the server Reason:[Weapon Hacks].", PlayerInfo[i][pName]);
					                        SendClientMessageToAll(COLOR_PUBLIC_ADMIN, string);
		                                    BanPlayer(i, "Weapon Hacks", "Server");*/
		                                    KickPlayer(i, "You have been kicked due to supposedly weapon hacking.");
		                                }
		                            }
		                        }
		                        else
		                        {
		                            if(GetPVarInt(i, "LSPD_Ta") == 0 && GetPVarInt(i, "AdmWrnWeapon") == 0)
					                {
		                                format(string, sizeof(string), "AdmWarn: %s (ID: %i) is possibly weapon hacking.", PlayerInfo[i][pName], i);
					                    SendAdminMessage(COLOR_YELLOW,string);
					                    ResetPlayerWeaponsEx(i);
								        PlayerInfo[i][pPlayerWeapon]=0, PlayerInfo[i][pPlayerAmmo]=0;
								        SetPVarInt(i, "AdmWrnWeapon", 1);
										SetTimerEx("AdmWrnWeaponTimer", 30000, false, "i", i);
								    }
					                
		                        }
				            }
						}
				    }
				}
			}
		}
	}

	if(CountDown > 0)
	{
	    CountDown--;
	    format(string, sizeof(string),"~b~%d",CountDown);
	    GameTextForAll(string, 3000, 5);
	}
	return 1;
}
//============================================//
public OneMinuteTimer()
{
	new query[512];

    SetWorldTimeEx();

    mysql_format(handlesql, query, sizeof(query), "SELECT * FROM bans WHERE BannedUntil!='Permanent'");
    mysql_pquery(handlesql, query, "OnTempBannedPlayersLoaded");

    mysql_format(handlesql, query, sizeof(query), "SELECT * FROM accounts WHERE Jailed=3");
    mysql_pquery(handlesql, query, "OnJailedPlayersLoaded");

	new year, month, day, Float:x, Float:y, Float:z;
	getdate(year, month, day);
	if(day > gday)
	{
	    gday=day;

		foreach(new i : Player)
    	{
		    if(GetPVarInt(i, "MonthDon") > 0)
		    {
			    SetPVarInt(i, "MonthDonT", GetPVarInt(i, "MonthDonT") - 1);
				if(GetPVarInt(i, "MonthDonT") == 0)
				{
				    SetPVarInt(i, "MonthDon", 0);
					SetPVarInt(i, "MonthDonT", 0);
				    SendClientMessage(i, -1, "Your monthly donation has expired. Renew it at www.pr-rp.com!");
			    }
		    }
		}

		mysql_pquery(handlesql, "SELECT ID, Online, MonthDon, MonthDonT FROM accounts WHERE MonthDon > 0 AND Online = 0", "CheckSub", ""); //Setting it for offline players.
	}

	foreach(new i : BizIterator)
	{
		mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `businesses` WHERE `ID`=%d",i);
		mysql_pquery(handlesql, query, "UpdateBizNames", "i",i);
		if(BizInfo[i][UD] > 0)
		{
			BizInfo[i][UD]--;
		}
	}
	
	foreach(new i : HouseIterator)
	{
		mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `houses` WHERE `ID`=%i", i);
		mysql_pquery(handlesql, query, "UpdateHouseNames", "i", i);
		if(HouseInfo[i][hUD] > 0)
		{
			HouseInfo[i][hUD]--;
		}
	}

	foreach(new v : VehicleIterator)
	{
	    if(VehicleInfo[v][vEngine] == 1 && !IsNotAEngineCar(v))
		{
		    if(VehicleInfo[v][vFuel] > 0)
		    {
				switch(GetVehicleModel(v))
				{
				    case 400, 408, 413, 422, 440, 459, 470, 478, 482, 489, 495, 500, 505, 522, 531, 543, 552, 554, 579, 582, 605:
				    {
					    VehicleInfo[v][vFuel]-=1;
					}
					case 414, 455, 456, 498, 499, 524, 578, 609:
					{
					    VehicleInfo[v][vFuel]-=2;
					}
					case 403, 443, 514, 515:
					{
					    VehicleInfo[v][vFuel]-=3;
					}
				    default:
				    {
					    VehicleInfo[v][vFuel]-=1;
					}
				}
		    }
		    CallRemoteFunction("AddBattery","ii", v);
		    CallRemoteFunction("AddEngine","ii", v);
	    }

	    if(VehicleInfo[v][vID] != 0)
	    {
	    	mysql_format(handlesql, query, sizeof(query), "SELECT `Owner` FROM `vehicles` WHERE `ID`=%i;", VehicleInfo[v][vID]);
			mysql_pquery(handlesql, query, "UpdateVehicleNames", "i", v);
	    }
	}

	for(new o = 0; o < sizeof(Shells); o++)
	{
	    if(Shells[o][sUsed] == 1)
	    {
	        if(Shells[o][sTime] >= 1) { Shells[o][sTime]--; }
	        else
	        {
	            Shells[o][sTime]=0;
	            Shells[o][sUsed]=0;
	            Shells[o][sX]=0.0;
	            Shells[o][sY]=0.0;
	            Shells[o][sZ]=0.0;
	            DestroyDynamic3DTextLabel(Shells[o][sText]);
	        }
	    }
	}

	for(new ol = 0; ol < MAX_LOOT; ol++)
	{
	    if(LootInfo[ol][lUsed] == 1)
	    {
	        if(LootInfo[ol][lTime] >= 1) { LootInfo[ol][lTime]--; }
	        else
	        {
	            LootInfo[ol][lTime]=0;
	            LootInfo[ol][lUsed]=0;
	            LootInfo[ol][lX]=0.0;
	            LootInfo[ol][lY]=0.0;
	            LootInfo[ol][lZ]=0.0;
	            DestroyDynamic3DTextLabel(LootInfo[ol][lText]);
	            if(IsValidDynamicObject(LootInfo[ol][lObject])) { DestroyDynamicObject(LootInfo[ol][lObject]); }
	            LootInfo[ol][lObject]=0;
	        }
	    }
	}

	for(new weed = 0; weed < sizeof(WeedInfo); weed++)
    {
        if(WeedInfo[weed][wPlanted] == 1 && WeedInfo[weed][wTime] > 0)
        {
            WeedInfo[weed][wTime]--;
            new Float:adjust;
            switch(WeedInfo[weed][wTime])
            {
                case 0 .. 4: { adjust=1.2; }
                case 5 .. 9: { adjust=1.3; }
                case 10 .. 14: { adjust=1.4; }
                case 15 .. 19: { adjust=1.5; }
                case 20 .. 24: { adjust=1.6; }
                case 25 .. 29: { adjust=1.7; }
                case 30 .. 34: { adjust=1.8; }
                case 35 .. 39: { adjust=1.9; }
                case 40 .. 44: { adjust=2.1; }
                case 45 .. 49: { adjust=2.2; }
                case 50 .. 54: { adjust=2.3; }
                case 55 .. 60: { adjust=2.5; }
            }
            if(WeedInfo[weed][wObject] > 0 && IsValidDynamicObject(WeedInfo[weed][wObject]))
            {
            	MoveDynamicObject(WeedInfo[weed][wObject], WeedInfo[weed][wX], WeedInfo[weed][wY], WeedInfo[weed][wZ]-adjust, 5.0);
            }
        }
	}

	for(new crack = 0; crack < sizeof(CrackInfo); crack++)
    {
        if(CrackInfo[crack][cPlanted] == 1 && CrackInfo[crack][cTime] > 0)
        {
            CrackInfo[crack][cTime]--;
        }
	}

	for(new o = 0; o < sizeof(CorpInfo); o++)
    {
        if(CorpInfo[o][cUsed] == 1)
        {
            if(CorpInfo[o][cTime] > 0)
			{
                CorpInfo[o][cTime]--;
                if(CorpInfo[o][cTime] == 0)
                {
                    RemoveCorpse(o);
                }
			}
			else
			{
				RemoveCorpse(o);
			}
        }
	}

	foreach(new i : Player)
    {
		//format(query, sizeof(query), "SELECT * FROM applications WHERE Accepted=0");
		//mysql_function_query(handlesql, query, true, "CheckAppsSQL", "d", i);

    	new bool:being_reviewed = false;
		if(GetPVarInt(i, "Submitted") == 1)
		{
			foreach(new i2 : Player)
    		{
    			if(GetPVarInt(i2, "Reviewing") == i)
    			{
    				being_reviewed = true;
    			}
    		}

    		if(being_reviewed == false)
			{
				new string[256];
				format(string, sizeof(string), "REGISTRATON: %s (ID: %i) is waiting for his registration ticket to be reviewed. (/review %i)",
					GiveNameSpaceEx(PlayerInfo[i][pUsername]), i, i);

				if(GetHelperCount() > 0)
				{
					SendHelperMessage(COLOR_LIGHTBLUE, string);
				}
				else
				{
					SendAdminMessage(COLOR_LIGHTBLUE, string);
				}
			}
		}

	    SetPVarInt(i, "Hunger", GetPVarInt(i, "Hunger") + 1);

	    if(GetPVarInt(i, "AFKTime") < 1800) SetPVarInt(i, "PayDay", GetPVarInt(i, "PayDay") + 1);

        if(GetPVarInt(i, "Hunger") >= 3 && GetPVarInt(i, "Control") == 0 && GetPVarInt(i, "Dead") == 0 && GetPVarInt(i, "Cuffed") == 0 && GetPVarInt(i, "Jailed") == 0)
	    {
	        if(GetPlayerState(i) != PLAYER_STATE_SPECTATING)
	        {
	            SetPVarInt(i, "Hunger", 0);
	            new Float:health;
	            GetPlayerHealth(i,health);
	            if(health >= 11.0)
	            {
	            	//SetPlayerHealthEx(i, health-1.0);
	            }
	        }
	    }

	    if(GetPVarInt(i, "Wound_T") == 1 || GetPVarInt(i, "Wound_A") == 1 || GetPVarInt(i, "Wound_L") == 1)
	    {
			if(GetPlayerState(i) != PLAYER_STATE_SPECTATING)
			{
	            if(GetPVarInt(i, "Cuffed") == 0 && GetPVarInt(i, "Control") == 0 && GetPVarInt(i, "Dead") == 0)
	            {
	                new Float:health;
	                GetPlayerHealth(i,health);
	                SetPlayerHealthEx(i, health-5.0);
	                CallRemoteFunction("ShowBlood", "i", i);
	            }
	        }
	    }

	    if(GetPVarInt(i, "UpgDelay") > 0)
	    {
		    SetPVarInt(i, "UpgDelay", GetPVarInt(i, "UpgDelay")-1);
		}
	    if(GetPVarInt(i, "JobTime") > 0)
	    {
		    SetPVarInt(i,"JobTime",GetPVarInt(i, "JobTime")-1);
		}

		CallRemoteFunction("PayDay", "i", i);
		//==========//
	    GetPlayerPos(i, x, y, z);
	    if(GetPVarInt(i, "AFKTime") < 60 && GetPVarInt(i, "PlayTime") > 10)
	    {
	        if(IsPlayerInRangeOfPoint(i, 1.0, PlayerInfo[i][pPosI][0], PlayerInfo[i][pPosI][1], PlayerInfo[i][pPosI][2]))
	        {
	            PlayerInfo[i][pIdleTime]++;
	            /*if(PlayerInfo[i][pIdleTime] > 10) { // AFK for ten minutes.
				    if(GetPlayerInterior(i) == 0 && GetPlayerVirtualWorld(i) == 0) {
				    KickPlayer(i, "You have been kicked, reason: being idle for over ten minutes."); }
	            }*/
	        }
	        else
	        {
	            PlayerInfo[i][pIdleTime] = 0;
	        }
	    }
	    else
	    {
	    	PlayerInfo[i][pIdleTime] = 0;
		}

	    PlayerInfo[i][pPosI][0]=x;
	    PlayerInfo[i][pPosI][1]=y;
	    PlayerInfo[i][pPosI][2]=z;
	}
	return 1;
}
//============================================//
public OnPlayerUpdate(playerid)
{
    if(IsPlayerConnected(playerid) && !IsPlayerNPC(playerid))
    {
    	SetPVarInt(playerid, "AFKTime", 0);
    	SetPVarInt(playerid, "Delay", 0);

        if(PlayerInfo[playerid][pPlayerWeapon] > 0)
        {
		    if(PlayerInfo[playerid][pPlayerAmmo] == 0)
		    {
		        if(!IsPlayerAttachedObjectSlotUsed(playerid, HOLDOBJECT_GUN3))
		        {
		        	SetPlayerAttachedObject(playerid, HOLDOBJECT_GUN3, PrintIid(PlayerInfo[playerid][pPlayerWeapon]), 6, 0.0, 0.0, 0.0);
		        }
		    }
		    else
		    {
		        if(GetPVarInt(playerid, "Forbid") > 0)
		        {
					SetPlayerArmedWeapon(playerid, 0);
				}

		        if(GetPlayerWeapon(playerid) != PlayerInfo[playerid][pPlayerWeapon] && !IsPlayerInAnyVehicle(playerid))
		        {
		            if(GetPVarInt(playerid, "Forbid") == 0)
		            {
		                if(GetPVarInt(playerid, "LSPD_Ta") == 1 && GetPlayerWeapon(playerid) == 23)
		                {
		                    if(GetPVarInt(playerid, "LSPD_Delay") > GetCount())
		                    {
								SetPlayerArmedWeapon(playerid, 0);
							}
		                }
		                else
		                {
			                SetPlayerArmedWeapon(playerid, PlayerInfo[playerid][pPlayerWeapon]);

			                if(IsPlayerAttachedObjectSlotUsed(playerid, HOLDOBJECT_GUN3))
			                {
								RemovePlayerAttachedObject(playerid, HOLDOBJECT_GUN3);
							}
			            }
			        }
			    }
		    }
        }

    	// LSPD SCUBA GEAR //
		if(GetPVarInt(playerid, "FDDUTY") == 1 && GetPVarInt(playerid, "SubaGear") == 1 && PlayerInWater(playerid))
		{
			SetPlayerHealthEx(playerid, 99.0);
		}

		if(GetPVarInt(playerid, "WalkStyleWalking") == 1)
		{
			new Keys,ud,lr;
    		GetPlayerKeys(playerid,Keys,ud,lr);

    		if(Keys != KEY_WALK)
    		{
    			ClearAnimationsEx(playerid);
    			SetPVarInt(playerid, "WalkStyleWalking", 0);
    		}
		}
		else
		{
			new Keys,ud,lr;
    		GetPlayerKeys(playerid,Keys,ud,lr);

    		if(Keys == KEY_WALK)
    		{
				if (GetPVarInt(playerid, "Dead") == 0 && GetPVarInt(playerid, "Mute") == 0 && GetPVarInt(playerid, "Cuffed") == 0)
			    {
			        if(GetPlayerWalkStyle(playerid) > 0)
				    {
				    	StopTalking(playerid);
				    	KillTimer(PlayerInfo[playerid][pStopTalkingTimer]);
				    	SetPVarInt(playerid, "WalkStyleWalking", 1);
				        switch(GetPlayerWalkStyle(playerid))
						{
				    	    case WALKSTYLE_GANG1: ApplyAnimationEx(playerid,"PED","WALK_gang1",4.1,1,1,1,1,1,1);
				    	    case WALKSTYLE_GANG2: ApplyAnimationEx(playerid,"PED","WALK_gang2",4.1,1,1,1,1,1,1);
				    	    case WALKSTYLE_NORMAL: ApplyAnimationEx(playerid,"ped","WALK_player",4.1,1,1,1,1,1,1);
				    	    case WALKSTYLE_SEXY: ApplyAnimationEx(playerid,"ped","WOMAN_walksexy",4.1,1,1,1,1,1,1);
				    	    case WALKSTYLE_OLD: ApplyAnimationEx(playerid,"PED","WALK_old",4.1,1,1,1,1,1,1);
				    	    case WALKSTYLE_SNEAK: ApplyAnimationEx(playerid,"PED","Player_Sneak",4.1,1,1,1,1,1,1);
				    	    case WALKSTYLE_BLIND: ApplyAnimationEx(playerid,"PED","Walk_Wuzi",4.1,1,1,1,1,1,1);
				    	    case WALKSTYLE_ARMED: ApplyAnimationEx(playerid,"PED","WALK_armed",4.1,1,1,1,1,1,1);
				    	    case WALKSTYLE_POLICE: ApplyAnimationEx(playerid,"POLICE","Cop_move_FWD",4.1,1,1,1,1,1,1);
				    	    case WALKSTYLE_FEMALE: ApplyAnimationEx(playerid,"PED","WOMAN_walknorm",4.1,1,1,1,1,1,1);
				    	    case WALKSTYLE_FAT: ApplyAnimationEx(playerid,"FAT","FatWalk",4.1,1,1,1,1,1,1);
				    	    case WALKSTYLE_MUSCLE: ApplyAnimationEx(playerid,"MUSCULAR","MuscleWalk",4.1,1,1,1,1,1,1);
					    }
				    }
			    }
			}
		}
    }
	return 1;
}
//============================================//

forward AdmWrnJailTimer(playerid);
public AdmWrnJailTimer(playerid) {
	SetPVarInt(playerid, "AdmWrnJail", 0);
}

forward AdmWrnWeaponTimer(playerid);
public AdmWrnWeaponTimer(playerid) {
	SetPVarInt(playerid, "AdmWrnWeapon", 0);
}

forward ResetPlayerRadio(playerid);
public ResetPlayerRadio(playerid)
{
	LoadRadios(playerid);
}

forward PoliceCall(playerid);
public PoliceCall(playerid)
{
	new string[128];
	format(string, sizeof(string), "HQ: All Units - HQ: Shots fired | Location: %s.", shots_fired[playerid]);
	SendFactionMessage(1, COLOR_BLUE, string);
	format(shots_fired[playerid], 32, "");
}

forward EnterGarage(playerid, h);
public EnterGarage(playerid, h)
{
	SetVehiclePosEx(GetPlayerVehicleID(playerid), HouseInfo[h][hgXi], HouseInfo[h][hgYi], HouseInfo[h][hgZi] + 0.5);
	SetVehicleZAngle(GetPlayerVehicleID(playerid), HouseInfo[h][hgAi]);
}

forward CloseGate(objectid, Float:object_x, Float:object_y, Float:object_z, Float:object_rx, Float:object_ry, Float:object_rz, Float:speed);
public CloseGate(objectid, Float:object_x, Float:object_y, Float:object_z, Float:object_rx, Float:object_ry, Float:object_rz, Float:speed)
{
	MoveDynamicObject(objectid, object_x, object_y, object_z, speed, object_rx, object_ry, object_rz);
}

forward CloseDoor(objectid, Float:object_x, Float:object_y, Float:object_z, Float:object_rx, Float:object_ry, Float:object_rz, Float:speed);
public CloseDoor(objectid, Float:object_x, Float:object_y, Float:object_z, Float:object_rx, Float:object_ry, Float:object_rz, Float:speed)
{
	MoveDynamicObject(objectid, object_x, object_y, object_z, speed, object_rx, object_ry, object_rz);
}

forward DespawnPlayerVehicle(vehicleid);
public DespawnPlayerVehicle(vehicleid)
{
	foreach(new i : Player)
    {
		if(IsPlayerInVehicle(i, vehicleid))
		{
			VehicleInfo[vehicleid][vDespawnTimer] = SetTimerEx("DespawnPlayerVehicle", VEHICLE_DESPAWN_TIMER, false, "i", vehicleid);
			return 1;
		}
	}

	SaveVehicleData(vehicleid);
    DespawnVehicle(vehicleid);
    return 1;
}

forward DespawnRentalVehicle(vehicleid);
public DespawnRentalVehicle(vehicleid)
{
	foreach(new i : Player)
    {
		if(IsPlayerInVehicle(i, vehicleid))
		{
			VehicleInfo[vehicleid][vDespawnTimer] = SetTimerEx("DespawnRentalVehicle", VEHICLE_RENTAL_DESPAWN_TIMER, false, "i", vehicleid);
			return 1;
		}
	}

    DespawnVehicle(vehicleid);

    new query[256];
	mysql_format(handlesql, query, sizeof(query), "UPDATE accounts SET RentKey=0 WHERE RentKey=%i", vehicleid);
	mysql_pquery(handlesql, query);
    return 1;
}

forward DespawnFactionVehicle(vehicleid);
public DespawnFactionVehicle(vehicleid)
{
	foreach(new i : Player)
    {
		if(IsPlayerInVehicle(i, vehicleid))
		{
			VehicleInfo[vehicleid][vDespawnTimer] = SetTimerEx("DespawnRentalVehicle", VEHICLE_FACTION_DESPAWN_TIMER, false, "i", vehicleid);
			return 1;
		}
	}

    DespawnVehicle(vehicleid);
    return 1;
}

forward DestroyCampfire(campfireid);
public DestroyCampfire(campfireid)
{
	DestroyDynamicObject(Campfire[campfireid][cID]);
	Campfire[campfireid][cID] = 0;
	return 1;
}

forward ClearAnimationsTimer(playerid);
public ClearAnimationsTimer(playerid)
{
	ClearAnimationsEx(playerid);
	return 1;
}
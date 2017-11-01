//============================================//
//==============[ Checkpoint ]================//
//============================================//
public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	if(IsPlayerNPC(playerid)) return 1;
    if(GetPVarInt(playerid, "Dead") == 1 || GetPVarInt(playerid, "Dead") == 2) return 1;

    new string[128], result[2048], found = 0, foundid = 0;

	if(checkpointid == PlayerInfo[playerid][pAddressCP])
	{
		DestroyDynamicCP(PlayerInfo[playerid][pAddressCP]);
		PlayerInfo[playerid][pAddressCP] = 0;
		return 1;
	}

	if(checkpointid == PlayerInfo[playerid][pLocationsCP])
	{
		DestroyDynamicCP(checkpointid);
		PlayerInfo[playerid][pLocationsCP] = 0;
		SendClientMessage(playerid, COLOR_WHITE, "You have arrived at your destination!");
		return 1;
	}

	if(GetPlayerVirtualWorld(playerid) == 0 && GetPlayerInterior(playerid) == 0 && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
	    for(new i = 0; i < sizeof(ATMs); i++)
	    {
	        if(IsPlayerInRangeOfPoint(playerid,3.0,ATMs[i][0],ATMs[i][1],ATMs[i][2]))
	        {
			    SendBankDialog(playerid, 3);
	            return 1;
            }
        }
    }

    if(GetPlayerVirtualWorld(playerid) == 0 && GetPlayerInterior(playerid) == 0)
    {
        for(new i = 0; i < sizeof(DriveThru); i++)
	    {
	        if(IsPlayerInRangeOfPoint(playerid,3.0, DriveThru[i][dX], DriveThru[i][dY], DriveThru[i][dZ]))
	        {
	            if(IsPlayerInAnyVehicle(playerid)) {
	                switch(DriveThru[i][dType]){
	                    case 1: {
	                        for(new i1 = 0; i1 < sizeof(CluckItems); i1++)
			                {
			                    if(i == 0) { format(result, 2000, "%s | %s", PrintIName(CluckItems[i1][0]), FormatMoney(CluckItems[i1][1])); }
			                    else { format(result, 2000, "%s\n%s | %s", result, PrintIName(CluckItems[i1][0]), FormatMoney(CluckItems[i1][1])); }
			                }
			                ShowPlayerDialogEx(playerid, 10, DIALOG_STYLE_LIST, "Cluckin Bell - Drivethru", result, "Purchase", "Close");
	                    }
	                    case 2: {
	                        for(new i1 = 0; i1 < sizeof(BurgerItems); i1++)
			                {
			                    if(i == 0) { format(result, 2000, "%s | %s", PrintIName(BurgerItems[i1][0]), FormatMoney(BurgerItems[i1][1])); }
			                    else { format(result, 2000, "%s\n%s | %s", result, PrintIName(BurgerItems[i1][0]), FormatMoney(BurgerItems[i1][1])); }
			                }
			                ShowPlayerDialogEx(playerid, 8, DIALOG_STYLE_LIST, "Burger Shot - Drivethru", result, "Purchase", "Close");
	                    }
	                }
		        } else {
		        scm(playerid, COLOR_ERROR, "You need to be in a vehicle to use the drive-thru."); }
		        return 1;
	        }
	    }
    }

	for(new i = 1; i < MAX_FACTIONS; i++)
	{
		if(checkpointid == FactionCP[i])
		{
			if(GetPVarInt(playerid, "Member") != i) return SendClientMessage(playerid, COLOR_ERROR, "You don't have access to this warehouse.");
			if(GetPVarInt(playerid, "Frights") == 0) return SendClientMessage(playerid, COLOR_ERROR, "You haven't been granted access to your faction's warehouse.");

			if(FactionInfo[i][fRights] == 0)
			{
				SendClientMessage(playerid, COLOR_ERROR, "Your faction has no special rights set.");
				return 1;
			}
			else if(FactionInfo[i][fRights] == 1)
			{
				for(new i2 = 0; i2 < sizeof(FactGuns); i2++)
				{
					if(i2 == 0)
					{
						format(result, 2048, "{99CCFF}%s - %s", PrintIName(FactGuns[i2][0]), FormatMoney(FactGuns[i2][1]));
					}
					else
					{
						format(result, 2048, "%s\n{99CCFF}%s - %s", result, PrintIName(FactGuns[i2][0]), FormatMoney(FactGuns[i2][1]));
					}
				}

				new title[64];
				format(title, sizeof(title), "Faction Warehouse - %i packages", FactionInfo[i][fAvailablePackages]);

				ShowPlayerDialogEx(playerid, 92, DIALOG_STYLE_LIST, title, result, "Purchase", "Close");
			}
			else if(FactionInfo[i][fRights] == 2)
			{
				for(new i2 = 0; i2 < sizeof(FactDrug1); i2++)
				{
					if(i2 == 0)
					{
						format(result, 2048, "{99CCFF}%s Package - %s", PrintIName(FactDrug1[i2][0]), FormatMoney(FactDrug1[i2][1]));
					}
					else
					{
						format(result, 2048, "%s\n{99CCFF}%s Package - %s", result, PrintIName(FactDrug1[i2][0]), FormatMoney(FactDrug1[i2][1]));
					}
				}

				new title[64];
				format(title, sizeof(title), "Faction Warehouse - %i packages", FactionInfo[i][fAvailablePackages]);

				ShowPlayerDialogEx(playerid, 93, DIALOG_STYLE_LIST, title, result, "Purchase", "Close");
			}
			else if(FactionInfo[i][fRights] == 3)
			{
				for(new i2 = 0; i2 < sizeof(FactDrug2); i2++)
				{
					if(i2 == 0)
					{
						format(result, 2048, "{99CCFF}%s Package - %s", PrintIName(FactDrug2[i2][0]), FormatMoney(FactDrug2[i2][1]));
					}
					else
					{
						format(result, 2048, "%s\n{99CCFF}%s Package - %s", result, PrintIName(FactDrug2[i2][0]), FormatMoney(FactDrug2[i2][1]));
					}
				}

				new title[64];
				format(title, sizeof(title), "Faction Warehouse - %i packages", FactionInfo[i][fAvailablePackages]);
				
				ShowPlayerDialogEx(playerid, 94, DIALOG_STYLE_LIST, title, result, "Purchase", "Close");
			}
			return 1;
		}
	}

    for(new i = 0; i < sizeof(CheckpointAreas); i++)
	{
        if(IsPlayerInRangeOfPoint(playerid,20.0,CheckpointAreas[i][cXe],CheckpointAreas[i][cYe],CheckpointAreas[i][cZe]))
        {
            if(found == 0)
            {
                found++;
                foundid=i;
            }
        }
    }

    if(found != 0)
    {
		if(!IsPlayerInRangeOfPoint(playerid,5.0,CheckpointAreas[foundid][cXe],CheckpointAreas[foundid][cYe],CheckpointAreas[foundid][cZe])) return true;
        switch(CheckpointAreas[foundid][cType])
        {
            case CHECKPOINT_GUN:
			{
				if(GetPVarInt(playerid, "ConnectTime") <= 7) return SendClientMessage(playerid, COLOR_ERROR, "Insufficient TLS!");
				if(GetPVarInt(playerid, "GunLic") == 0) return SendClientMessage(playerid, COLOR_ERROR, "You need a weapon license!");
			    for(new i = 0; i < sizeof(AmmuItems); i++)
			    {
			        if(i == 0) { format(result, 2000, "%s | %s", PrintIName(AmmuItems[i][0]), FormatMoney(AmmuItems[i][1])); }
			        else { format(result, 2000, "%s\n%s | %s", result, PrintIName(AmmuItems[i][0]), FormatMoney(AmmuItems[i][1])); }
			    }
			    ShowPlayerDialogEx(playerid, 20, DIALOG_STYLE_LIST, "Ammunation", result, "Purchase", "Close");
			}
			case CHECKPOINT_AMMO:
			{
				if(GetPVarInt(playerid, "ConnectTime") <= 7) return SendClientMessage(playerid, COLOR_ERROR, "Insufficient TLS!");
				//if(GetPVarInt(playerid, "GunLic") == 0) return SendClientMessage(playerid, COLOR_ERROR, "You need a weapon license!");
			    for(new i = 0; i < sizeof(AmmoItems); i++)
			    {
			        if(i == 0) { format(result, 2000, "%s | %s", PrintIName(AmmoItems[i][0]), FormatMoney(AmmoItems[i][1])); }
			        else { format(result, 2000, "%s\n%s | %s", result, PrintIName(AmmoItems[i][0]), FormatMoney(AmmoItems[i][1])); }
			    }
			    ShowPlayerDialogEx(playerid, DIALOG_AMMO_STORE, DIALOG_STYLE_LIST, "Ammo Store", result, "Purchase", "Close");
			}
            case CHECKPOINT_BAR:
			{
			    //if(BizProductC(GetPVarInt(playerid, "BizEnter")) && GetPVarInt(playerid, "BizEnter") != 0) return SendClientMessage(playerid,COLOR_ERROR,"There are no products available in this business!");
			    for(new i = 0; i < sizeof(BarItems); i++)
			    {
			        if(i == 0) { format(result, 2000, "%s | %s", PrintIName(BarItems[i][0]), FormatMoney(BarItems[i][1])); }
			        else { format(result, 2000, "%s\n%s | %s", result, PrintIName(BarItems[i][0]), FormatMoney(BarItems[i][1])); }
			    }
			    ShowPlayerDialogEx(playerid, 22, DIALOG_STYLE_LIST, "Bar Menu", result, "Purchase", "Close");
			}
            case CHECKPOINT_REST: {}
            case CHECKPOINT_STORE:
			{
			    //if(BizProductC(GetPVarInt(playerid, "BizEnter")) && GetPVarInt(playerid, "BizEnter") != 0) return SendClientMessage(playerid,COLOR_ERROR,"There are no products available in this business!");
			    for(new i = 0; i < sizeof(StoreItems); i++)
			    {
			        if(i == 0)
					{
						format(result, 2000, "%s | %s", PrintIName(StoreItems[i][0]), FormatMoney(StoreItems[i][1]));
					}
			        else
					{
						format(result, 2000, "%s\n%s | %s", result, PrintIName(StoreItems[i][0]), FormatMoney(StoreItems[i][1]));
					}
			    }
			    ShowPlayerDialogEx(playerid, 7, DIALOG_STYLE_LIST, "Store Dialog", result, "Purchase", "Close");
			}
            case CHECKPOINT_BANK:
			{
			    new string2[128];
			    format(string, sizeof(string), "Bank Account: %s", FormatMoney(GetPVarInt(playerid, "Bank")));
			    format(string2, sizeof(string2), "{33FF66}Deposit\n{33FF66}Withdraw");
			    //format(string2, sizeof(string2), "{33FF66}Deposit\n{33FF66}Withdraw\n{33FF66}Cash A Check ($%d)", GetPVarInt(playerid, "CheckEarn"));
			    ShowPlayerDialogEx(playerid, 11, DIALOG_STYLE_LIST, string, string2, "Continue", "Exit");
			}
            case CHECKPOINT_CLUCK:
            {
                //if(BizProductC(GetPVarInt(playerid, "BizEnter")) && GetPVarInt(playerid, "BizEnter") != 0) return SendClientMessage(playerid,COLOR_ERROR,"There is no products available in this business!");
			    for(new i = 0; i < sizeof(CluckItems); i++)
			    {
			        if(i == 0) { format(result, 2000, "%s | %s", PrintIName(CluckItems[i][0]), FormatMoney(CluckItems[i][1])); }
			        else { format(result, 2000, "%s\n%s | %s", result, PrintIName(CluckItems[i][0]), FormatMoney(CluckItems[i][1])); }
			    }
			    ShowPlayerDialogEx(playerid, 10, DIALOG_STYLE_LIST, "Cluckin Bell", result, "Purchase", "Close");
			}
            case CHECKPOINT_PIZZA:
			{
			    for(new i = 0; i < sizeof(PizzaItems); i++)
			    {
			        if(i == 0) { format(result, 2000, "%s | %s", PrintIName(PizzaItems[i][0]), FormatMoney(PizzaItems[i][1])); }
			        else { format(result, 2000, "%s\n%s | %s", result, PrintIName(PizzaItems[i][0]), FormatMoney(PizzaItems[i][1])); }
			    }
			    ShowPlayerDialogEx(playerid, 9, DIALOG_STYLE_LIST, "Pizza Stack", result, "Purchase", "Close");
			}
            case CHECKPOINT_BURGER:
			{
			    for(new i = 0; i < sizeof(BurgerItems); i++)
			    {
			        if(i == 0) { format(result, 2000, "%s | %s", PrintIName(BurgerItems[i][0]), FormatMoney(BurgerItems[i][1])); }
			        else { format(result, 2000, "%s\n%s | %s", result, PrintIName(BurgerItems[i][0]), FormatMoney(BurgerItems[i][1])); }
			    }
			    ShowPlayerDialogEx(playerid, 8, DIALOG_STYLE_LIST, "Burger Shot", result, "Purchase", "Close");
			}
            case CHECKPOINT_SEXSHOP:
			{
			    //if(BizProductC(GetPVarInt(playerid, "BizEnter")) && GetPVarInt(playerid, "BizEnter") != 0) return SendClientMessage(playerid,COLOR_ERROR,"There is no products available in this business!");
			    for(new i = 0; i < sizeof(SexItems); i++)
			    {
			        if(i == 0) { format(result, 2000, "%s | %s", PrintIName(SexItems[i][0]), FormatMoney(SexItems[i][1])); }
			        else { format(result, 2000, "%s\n%s | %s", result, PrintIName(SexItems[i][0]), FormatMoney(SexItems[i][1])); }
			    }
			    ShowPlayerDialogEx(playerid, 66, DIALOG_STYLE_LIST, "Sex Shop", result, "Purchase", "Close");
			}
            case CHECKPOINT_WARESHOP:
            {
                //if(BizProductC(GetPVarInt(playerid, "BizEnter")) && GetPVarInt(playerid, "BizEnter") != 0) return SendClientMessage(playerid,COLOR_ERROR,"There is no products available in this business!");
			    for(new i = 0; i < sizeof(WarItems); i++)
			    {
			        if(i == 0) { format(result, 2000, "%s | %s", PrintIName(WarItems[i][0]), FormatMoney(WarItems[i][1])); }
			        else { format(result, 2000, "%s\n%s | %s", result, PrintIName(WarItems[i][0]), FormatMoney(WarItems[i][1])); }
			    }
			    format(result, 2000, "%s\n{5CB8E6}Pawn a Watch $125\n{5CB8E6}Pawn a Cellphone $210\n{5CB8E6}Pawn a MP3 player $75", result);
			    ShowPlayerDialogEx(playerid, 67, DIALOG_STYLE_LIST, "Warehouse", result, "Purchase", "Close");
			}
            case CHECKPOINT_LSPD:
			{
		    	if(GetPVarInt(playerid, "Member") != FACTION_LSPD) return true;
			    if(GetPVarInt(playerid, "Duty") != 1) return SendClientMessage(playerid, COLOR_WHITE, "You are not on duty!");
			    if(GetPVarInt(playerid, "Suspend") == 1) return scm(playerid, COLOR_ERROR, "You are currently suspended from the LSPD.");
			    for(new i = 0; i < sizeof(PDItems); i++)
			    {
			        if(i == 0)
					{
						format(result, 2000, "%s | Rank: %d", PrintIName(PDItems[i][0]), PDItems[i][1]);
					}
			        else
					{
						format(result, 2000, "%s\n%s | Rank: %d", result, PrintIName(PDItems[i][0]), PDItems[i][1]);
					}
			    }
			    format(result, 2000, "%s\n{33FF66}Disarm", result);
			    ShowPlayerDialogEx(playerid, 35, DIALOG_STYLE_LIST, "LSPD Armoury", result, "Select", "Close");
			}
            case CHECKPOINT_GYM:
			{
			    ShowPlayerDialogEx(playerid,19,DIALOG_STYLE_LIST,"Fightstyle Guide","Normal $50\nBoxing $500\nKung Fu $3,000\nKneeHead $6,000\nGrabKick $8,000\nElbow 10,000$","Learn", "Cancel");
			}
			case CHECKPOINT_HOSPITAL:
            {
                CreateLableText(playerid,"Hospital"," ~w~Type ~b~/treatwound ~w~to ~n~ heal any wounds.");
            }
            case CHECKPOINT_CHURCH:
            {
                GameTextForPlayer(playerid, "~p~Marriage~n~~w~Price: ~g~$20,000~n~~r~/marriage", 3000, 5);
            }
            case CHECKPOINT_DONUT:
			{
			    //if(BizProductC(GetPVarInt(playerid, "BizEnter")) && GetPVarInt(playerid, "BizEnter") != 0) return SendClientMessage(playerid,COLOR_ERROR,"There is no products available in this business!");
			    for(new i = 0; i < sizeof(DonutItems); i++)
			    {
			        if(i == 0) { format(result, 2000, "%s | %s", PrintIName(DonutItems[i][0]), FormatMoney(DonutItems[i][1])); }
			        else { format(result, 2000, "%s\n%s | %s", result, PrintIName(DonutItems[i][0]), FormatMoney(DonutItems[i][1])); }
			    }
			    ShowPlayerDialogEx(playerid, 507, DIALOG_STYLE_LIST, "Donut Shop", result, "Purchase", "Close");
			}
			case CHECKPOINT_FISH:
			{
				format(result, 2000, "Item\tPrice\n");
				for(new i = 0; i < sizeof(FishItems); i++)
				{
					format(result, 2000, "%s\n%s\t%s\n", result, PrintIName(FishItems[i][0]), FormatMoney(FishItems[i][1]));
				}
				format(result, 2000, "%s\n{5CB8E6}Sell fish", result);
			    ShowPlayerDialogEx(playerid, 71, DIALOG_STYLE_TABLIST_HEADERS, "Fish Store", result, "Purchase", "Close");
			}
        }
        return 1;
    }

	foreach(new h : HouseIterator)
	{
		if(checkpointid == HouseInfo[h][hIcon])
		{
			if(HouseInfo[h][hOwned] == 0) // For Sale
            {
            	new class[32];

            	switch(HouseInfo[h][hClass])
            	{
            		case 1: format(class, sizeof(class), "Small");
            		case 2: format(class, sizeof(class), "Medium");
            		case 3: format(class, sizeof(class), "Large");
            		case 4: format(class, sizeof(class), "Mansion");
            	}

				format(string, sizeof(string), " ~w~Price: ~g~~h~ %s ~n~ ~w~Class: ~g~~h~%s ~n~~n~ ~w~Press ~r~~h~ 'H' ~w~to buy. ", FormatMoney(HouseInfo[h][hValue]), class);
	            CreateLableText(playerid, "Property", string);
	            return 1;
			}
			else // Bought
			{
				format(string, sizeof(string), " ~w~Owned by: ~n~~g~ %s ~w~ ~n~~n~ ~w~Press ~r~~h~ 'H' ~w~to enter. ", HouseInfo[h][hOwner]);
            	CreateLableText(playerid, "Property", string);
            	return 1;
			}
		}
		else if(checkpointid == HouseInfo[h][gIcon])
		{
			if(IsPlayerInAnyVehicle(playerid))
		    {
		        GameTextForPlayer(playerid, "~n~~n~~n~~n~~w~Press ~r~~h~~k~~VEHICLE_HANDBRAKE~ ~w~to enter the garage.", 2000, 4);
		        return 1;
		    }
		    else
		    {
			    CreateLableText(playerid, "~w~Garage", " ~w~Press ~r~~h~ 'H' ~w~to enter.");
			    return 1;
			}
		}
		else if(checkpointid == HouseInfo[h][hbdoIcon] || checkpointid == HouseInfo[h][hbdiIcon])
		{
			CreateLableText(playerid, "~w~Back Door", " ~w~Press ~r~~h~ 'H' ~w~to enter.");
			return 1;
		}
	}

	foreach(new h : BizIterator)
	{
		if(checkpointid == BizInfo[h][bCP])
		{
			switch(BizInfo[h][cT])
			{
			    case 1:
			    {
			        //if(BizProductC(GetPVarInt(playerid, "BizEnter")) && GetPVarInt(playerid, "BizEnter") != 0) return SendClientMessage(playerid,COLOR_ERROR,"There are no products available in this business!");
		            for(new i = 0; i < sizeof(BarItems); i++)
		            {
		                if(i == 0) { format(result, 2000, "%s | %s", PrintIName(BarItems[i][0]), FormatMoney(BarItems[i][1])); }
		                else { format(result, 2000, "%s\n%s | %s", result, PrintIName(BarItems[i][0]), FormatMoney(BarItems[i][1])); }
		            }
		            ShowPlayerDialogEx(playerid, 22, DIALOG_STYLE_LIST, "Bar Menu", result, "Purchase", "Close");
			    }
			    case 2:
			    {
		            //if(BizProductC(GetPVarInt(playerid, "BizEnter")) && GetPVarInt(playerid, "BizEnter") != 0) return SendClientMessage(playerid,COLOR_ERROR,"There is no products available in this business!");
		            for(new i = 0; i < sizeof(StoreItems); i++)
		            {
		                if(i == 0) {
					        format(result, 2000, "%s | %s", PrintIName(StoreItems[i][0]), FormatMoney(StoreItems[i][1]));
						} else {
					        format(result, 2000, "%s\n%s | %s", result, PrintIName(StoreItems[i][0]), FormatMoney(StoreItems[i][1])); }
		            }
		            ShowPlayerDialogEx(playerid, 7, DIALOG_STYLE_LIST, "Store Dialog", result, "Purchase", "Close");
		        }
			    case 3:
			    {
			        //if(BizProductC(GetPVarInt(playerid, "BizEnter")) && GetPVarInt(playerid, "BizEnter") != 0) return SendClientMessage(playerid,COLOR_ERROR,"There is no products available in this business!");
		            for(new i = 0; i < sizeof(WarItems); i++)
		            {
		                if(i == 0) { format(result, 2000, "%s | %s", PrintIName(WarItems[i][0]), FormatMoney(WarItems[i][1])); }
		                else { format(result, 2000, "%s\n%s | %s", result, PrintIName(WarItems[i][0]), FormatMoney(WarItems[i][1])); }
		            }
		            format(result, 2000, "%s\n{5CB8E6}Pawn a Watch $125\n{5CB8E6}Pawn a Cellphone $210\n{5CB8E6}Pawn a MP3 player $75", result);
		            ShowPlayerDialogEx(playerid, 67, DIALOG_STYLE_LIST, "Warehouse", result, "Purchase", "Close");
			    }
			    case 4:
			    {
			        ShowPlayerDialogEx(playerid, 19, DIALOG_STYLE_LIST,"Fightstyle Guide","Normal $50\nBoxing $500\nKung Fu $3,000\nKneeHead $6,000\nGrabKick $8,000\nElbow 10,000$","Learn", "Cancel");
			    }
			}
			return 1;
		}
		else if(checkpointid == BizInfo[h][bbdoIcon] || checkpointid == BizInfo[h][bbdiIcon])
		{
			CreateLableText(playerid, "~w~Back Door", " ~w~Press ~r~~h~ 'H' ~w~to enter.");
			return 1;
		}
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
    if(GetPVarInt(playerid, "Dead") == 1 || GetPVarInt(playerid, "Dead") == 2) return 1;

	new string[128], found = 0;

	if(GetPVarInt(playerid, "OnRoute") != 0)
    {
        if(GetPlayerVehicleID(playerid) != GetPVarInt(playerid, "RouteVeh")) return true;
		new id = GetPVarInt(playerid, "OnRoute");

		DisablePlayerCheckpoint(playerid);

        switch(GetPVarInt(playerid, "Job"))
		{
		    case 2: // GARBAGE MAN ROUTE
		    {
		        if(id != sizeof(TrashRoute))
		        {
		            if(IsPlayerInRangeOfPoint(playerid, 15.0, TrashRoute[id-1][0], TrashRoute[id-1][1], TrashRoute[id-1][2]))
				    {
					    SetPVarInt(playerid, "OnRoute", id+1);
				        TogglePlayerControllable(playerid, false);
		                GameTextForPlayer(playerid,"~w~~n~~n~~n~~n~~n~~n~~n~~n~~n~Picking trash up...",5000,3);
		                SetTimerEx("NextRoute", 5000, false, "ifffi", playerid, TrashRoute[id][0],TrashRoute[id][1],TrashRoute[id][2], 1);
		            }
		        }
		        else CallRemoteFunction("EndRoute","ii", playerid, JOB_GARBAGE_MAN_PAY);
		    }
		    case 3: // SWEEPER ROUTE
		    {
		        if(id != sizeof(SweepRoute))
		        {
		            if(IsPlayerInRangeOfPoint(playerid, 15.0, SweepRoute[id-1][0], SweepRoute[id-1][1], SweepRoute[id-1][2]))
				    {
					    SetPVarInt(playerid, "OnRoute", id+1);
					    CallRemoteFunction("NextRoute","ifffi", playerid, SweepRoute[id][0], SweepRoute[id][1], SweepRoute[id][2], 1);
		            }
		        }
		        else CallRemoteFunction("EndRoute","ii", playerid, JOB_STREETSWEEPER_PAY);
		    }
		    case 4: // PIZZA BOY
		    {
		        switch(id)
		        {
		            case 1:
		            {
		                new rand, Float:radius;
                        rand = random(sizeof(gPizzaCheckpoints));
                        CallRemoteFunction("NextRoute","ifffi", playerid, gPizzaCheckpoints[rand][0], gPizzaCheckpoints[rand][1], gPizzaCheckpoints[rand][2], 0);
                        radius = GetVehicleDistanceFromPoint(GetPlayerVehicleID(playerid), gPizzaCheckpoints[rand][0], gPizzaCheckpoints[rand][1], gPizzaCheckpoints[rand][2]);
		                new reward = floatround(radius/10);
                        SetPVarInt(playerid, "PizzaTime", reward);
                        SetPVarInt(playerid, "PizzaTimeEx", 0);
                        SetPVarInt(playerid, "OnRoute", 2);
		            }
		            case 2:
		            {
		                if(GetPVarInt(playerid, "PizzaTimeEx") <= 15)
		                {
		                    SendClientMessage(playerid, COLOR_ERROR, "You drove too fast, the pizza got messed up!");
		                }
		                else
		                {
			                new Float:radius;
			                radius = GetVehicleDistanceFromPoint(GetPlayerVehicleID(playerid), 2111.6963, -1788.6849, 13.5608);
	                        new reward = floatround(radius/JOB_PIZZA_BOY_DIVIDER);
	                        format(string, sizeof(string), "Pizza delivered, you have received %s!", FormatMoney(reward));
	                        SendClientMessage(playerid,COLOR_WHITE,string);
	                        GivePlayerMoneyEx(playerid, reward);
                        }
                        SendClientMessage(playerid,COLOR_WHITE,"To continue your deliveries, proceed to the checkpoint.");
                        SetPlayerCheckpoint(playerid, 2111.6963, -1788.6849, 13.5608, 2.0);
                        SetPVarInt(playerid, "OnRoute", 1);
		            }
		        }
		    }
		    case 6: // TRUCKER
		    {
		        switch(id)
		        {
		            case 1:
		            {
						new Float:Pos[6];
		                switch(GetPVarInt(playerid, "TruckerRoute"))
		                {
		                    case 1:
		                    {
		                        found = 0, id = 0;
								foreach(new b : BizIterator)
								{
		                            if(BizInfo[b][bReq] == 1)
		        	                {
		        	                    found++;
		        	                    id = b;
		                            }
			                    }
			                    if(found == 0)
			                    {
						            RemovePlayerFromVehicle(playerid);
						            SCM(playerid, COLOR_ERROR, "There is no business requesting products!");
						            return true;
						        }
			                    SetPlayerCheckpoint(playerid, BizInfo[id][Xo], BizInfo[id][Yo], BizInfo[id][Zo], 10.0);
			                    SetPVarInt(playerid, "TruckBiz", id);
			                    format(string, sizeof(string), "Deliver the products to the %s in %s.", BizInfo[id][Name], GetZone(BizInfo[id][Xo], BizInfo[id][Yo], BizInfo[id][Zo]));
			                    SendClientMessage(playerid, COLOR_WHITE, string);
			                    ProgressBar(playerid, "Loading Products...", 10, 0);
		                    }
		                    case 2: // Gas
		                    {
		                        new rand = rand = random(2)+1;
		                        switch(rand)
		                        {
		                            case 1:
		                            {
		                                Pos[3]=1935.9091;
		                                Pos[4]-=1774.6240;
		                                Pos[5]=13.3828;
		                            }
		                            default:
		                            {
		                                Pos[3]=1005.9490;
		                                Pos[4]-=941.2861;
		                                Pos[5]=42.0975;
		                            }
		                        }
		                        format(string, sizeof(string), "Deliver the fuel to the Gas Station in %s.", GetZone(Pos[3], Pos[4], Pos[5]));
			                    SendClientMessage(playerid, COLOR_WHITE, string);
			                    SetPlayerCheckpoint(playerid, Pos[3], Pos[4], Pos[5], 10.0);
			                    ProgressBar(playerid, "Loading Fuel...", 10, 0);
		                    }
		                    case 3: // Supplies
		                    {
		                        new rand = rand = random(2)+1;
		                        switch(rand)
		                        {
		                            case 1:
		                            {
		                                Pos[3]=883.4844;
		                                Pos[4]-=1239.0375;
		                                Pos[5]=16.0829;
		                            }
		                            default:
		                            {
		                                Pos[3]=2453.4060;
		                                Pos[4]-=2487.9009;
		                                Pos[5]=13.6440;
		                            }
		                        }
		                        format(string, sizeof(string), "Deliver the products to the Factory in %s.", GetZone(Pos[3], Pos[4], Pos[5]));
			                    SendClientMessage(playerid, COLOR_WHITE, string);
			                    SetPlayerCheckpoint(playerid, Pos[3], Pos[4], Pos[5], 10.0);
			                    ProgressBar(playerid, "Loading Supplies...", 10, 0);
		                    }
		                }
		                TogglePlayerControllable(playerid, false);
			            SetPVarInt(playerid, "OnRoute", 2);
		            }
		            case 2:
		            {
		                switch(GetPVarInt(playerid, "TruckerRoute"))
		                {
		                    case 1:
							{
   	                            new biz = GetPVarInt(playerid, "TruckBiz"), amount = 150;
   	                            switch(BizInfo[biz][Stor])
   	                            {
   	                                case 1: amount=250;
   	                                case 2: amount=500;
   	                                case 3: amount=1000;
   	                            }
   	                            if(biz >= 0 && biz <= MAX_BUSINESSES+1)
   	                            {
   	                                BizInfo[biz][bProd]=amount;
   	                                BizInfo[biz][bReq]=0;
   	                                SaveBizID(biz);
   	                            }
   	                            ProgressBar(playerid, "Unloading Products...", 10, 0);
							}
   	                        case 2:
							{
   	                            ProgressBar(playerid, "Unloading Fuel...", 10, 0);
   	                        }
   	                        case 3:
							{
   	                            ProgressBar(playerid, "Unloading Supplies...", 10, 0);
   	                        }
   	                    }
   	                    TogglePlayerControllableEx(playerid,false);
   	                    SetPlayerCheckpoint(playerid, 2472.5923, -2089.7461, 13.5469, 10.0);
		                SetPVarInt(playerid, "OnRoute", 3);
		            }
		            case 3: CallRemoteFunction("EndRoute","ii", playerid, JOB_TRUCKER_PAY);
		        }
			}
		    case 7: // FARMER
		    {
		        if(id != sizeof(FarmerRoute))
		        {
		            if(IsPlayerInRangeOfPoint(playerid, 15.0, FarmerRoute[id-1][0], FarmerRoute[id-1][1], FarmerRoute[id-1][2]))
				    {
					    SetPVarInt(playerid, "OnRoute", id+1);
					    CallRemoteFunction("NextRoute","ifffi", playerid, FarmerRoute[id][0], FarmerRoute[id][1], FarmerRoute[id][2], 1);
		            }
		        }
		        else CallRemoteFunction("EndRoute","ii", playerid, JOB_FARMER_PAY);
		    }
		    default:
		    {
		        DisablePlayerCheckpoint(playerid);
		    }
        }
        return true;
    }
	return 1;
}

//============================================//
public OnPlayerEnterRaceCheckpoint(playerid)
{
    if(IsPlayerNPC(playerid)) return 1;
    if(GetPVarInt(playerid, "Dead") == 1 || GetPVarInt(playerid, "Dead") == 2) return 1;
	if(GetPVarInt(playerid, "TakeTest") >= 1)
    {
        new id = GetPVarInt(playerid, "TakeTest");
        if(id != sizeof(DMVRoute))
		{
		    if(IsPlayerInRangeOfPoint(playerid, 20.0, DMVRoute[id-1][0], DMVRoute[id-1][1], DMVRoute[id-1][2]))
		    {
			    SetPVarInt(playerid, "TakeTest", id+1);
			    if(id+1 == sizeof(DMVRoute)) SetPlayerRaceCheckpoint(playerid, 1, DMVRoute[id][0], DMVRoute[id][1], DMVRoute[id][2], DMVRoute[id][0], DMVRoute[id][1], DMVRoute[id][2], 5.0);
			    else SetPlayerRaceCheckpoint(playerid, 0, DMVRoute[id][0], DMVRoute[id][1], DMVRoute[id][2], DMVRoute[id+1][0], DMVRoute[id+1][1], DMVRoute[id+1][2], 5.0);
		    }
		}
		else
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    new Float:health;
            GetVehicleHealth(GetPlayerVehicleID(playerid),health);
            if(health <= 500.0) PrintTestResult(playerid, 2, "Vehicle Is Too Damaged");
            else if(GetPVarInt(playerid, "TestTime") >= 301) PrintTestResult(playerid, 2, "Too Slow");
            else if(GetPVarInt(playerid, "TestTime") <= 90) PrintTestResult(playerid, 2, "Too Fast");
            else if(GetPVarFloat(playerid,"TestSpeed") >= 95.0) PrintTestResult(playerid, 2, "Broke Speed Limit");
            else
            {
                //PlayAudioStreamForPlayer(playerid, "http://k007.kiwi6.com/hotlink/jsprrwci5z/tone");
                PrintTestResult(playerid, 1, "All Qualifications Correct");
                SetPVarInt(playerid, "DriveLic", 1);
            }
			if(GetPVarInt(playerid, "TestVeh") >= 1) { DespawnVehicle(GetPVarInt(playerid, "TestVeh")); }
			DeletePVar(playerid, "TakeTest"), DeletePVar(playerid, "TestVeh");
		}
    }
	return true;
}

public OnPlayerEnterDynamicRaceCP(playerid, checkpointid)
{
	if(checkpointid == PlayerInfo[playerid][pJobCP])
	{
		if(GetPVarInt(playerid, "Job") == JOB_FARMER)
		{
			if(PlayerInfo[playerid][pJobStatus] == 3 || PlayerInfo[playerid][pJobStatus] == 6)
			{
				if(GetPlayerVehicleID(playerid) != PlayerInfo[playerid][pJobVehicleID]) return SendClientMessage(playerid, COLOR_ERROR, "You must be inside of your job vehicle to continue.");
				if(PlayerInfo[playerid][pJobStatus] == 3 && GetVehicleTrailer(GetPlayerVehicleID(playerid)) != PlayerInfo[playerid][pJobExtraVehicleID]) return SendClientMessage(playerid, COLOR_ERROR, "You must be towing your fertilizer in order to continue.");

				DestroyDynamicRaceCP(PlayerInfo[playerid][pJobCP]);
				PlayerInfo[playerid][pJobCP] = 0;

				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);

				if(PlayerInfo[playerid][pJobProgress] >= 1 && PlayerInfo[playerid][pJobProgress] < sizeof(FarmerRoute) - 1)
				{
					PlayerInfo[playerid][pJobCP] = CreateDynamicRaceCP(2, 
						FarmerRoute[PlayerInfo[playerid][pJobProgress]][0],
						FarmerRoute[PlayerInfo[playerid][pJobProgress]][1],
						FarmerRoute[PlayerInfo[playerid][pJobProgress]][2],
						0.0,0.0,0.0, 3, -1, -1, playerid);
					PlayerInfo[playerid][pJobProgress]++;
				}
				else if(PlayerInfo[playerid][pJobProgress] >= 1 && PlayerInfo[playerid][pJobProgress] == sizeof(FarmerRoute) - 1)
				{
					if(PlayerInfo[playerid][pJobStatus] == 3)
					{
						PlayerInfo[playerid][pJobCP] = CreateDynamicRaceCP(2, -368.1157,-1439.5592,25.6909, 0.0,0.0,0.0, 3, -1, -1, playerid);
						SendClientMessage(playerid, COLOR_JOB, "All crops have been fertilized, now head back to the farm.");
					}
					else if(PlayerInfo[playerid][pJobStatus] == 6)
					{
						PlayerInfo[playerid][pJobCP] = CreateDynamicRaceCP(2, -377.6374,-1420.5276,26.7031, 0.0,0.0,0.0, 3, -1, -1, playerid);
						SendClientMessage(playerid, COLOR_JOB, "All crops have been collected, now head back to the farm to collect your payment.");
					}
					PlayerInfo[playerid][pJobProgress]++;
				}
				else
				{
					if(PlayerInfo[playerid][pJobStatus] == 3)
					{
						PlayerInfo[playerid][pJobStatus] = 4;
						SendClientMessage(playerid, COLOR_JOB, "You have delivered both the Tractor and the Fertilizer back to your job.");
						SendClientMessage(playerid, COLOR_JOB, "Exit the vehicle to continue.");
					}
					else if(PlayerInfo[playerid][pJobStatus] == 6)
					{
						PlayerInfo[playerid][pJobStatus] = 7;
						SendClientMessage(playerid, COLOR_JOB, "Exit the vehicle to collect your payment.");
					}
				}
				Streamer_Update(playerid);
			}
		}
		else if(GetPVarInt(playerid, "Job") == JOB_PIZZA)
		{
			if(PlayerInfo[playerid][pJobStatus] == 2)
			{
				DestroyDynamicRaceCP(PlayerInfo[playerid][pJobCP]);
				PlayerInfo[playerid][pJobCP] = 0;
				
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
				PlayerInfo[playerid][pJobStatus] = 3;
				RemovePlayerAttachedObject(playerid, 9);
			}
			else if(PlayerInfo[playerid][pJobStatus] == 5)
			{
				if(!IsPlayerInAnyVehicle(playerid))
				{
					if(GetVehicleDistanceFromPoint(PlayerInfo[playerid][pJobVehicleID],
						HouseInfo[PlayerInfo[playerid][pJobHouseID]][hXo],
						HouseInfo[PlayerInfo[playerid][pJobHouseID]][hYo],
						HouseInfo[PlayerInfo[playerid][pJobHouseID]][hZo]) < 2)
					{
						SendClientMessage(playerid, COLOR_ERROR, "Get on your Pizza Bike and park it further away from the door.");
						SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
						RemovePlayerAttachedObject(playerid, 9);
						PlayerInfo[playerid][pJobStatus] = 4;
						return 1;
					}

					new string[128];
					new payment = floatround(GetPlayerDistanceFromPoint(playerid, 2101.1313,-1803.7959,13.1540), floatround_ceil) / 7;
					format(string, sizeof(string), "Goods delivered: %s has been added to your paycheck.", FormatMoney(payment));
					SendClientMessage(playerid, COLOR_GREEN, string);
					SendClientMessage(playerid, COLOR_JOB, "You can now head back to Idlewood Pizza Stack and collect another package to deliver.");

					SetPVarInt(playerid, "CheckEarn", payment + GetPVarInt(playerid, "CheckEarn"));
					SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
					RemovePlayerAttachedObject(playerid, 9);
					PlayerInfo[playerid][pJobProgress]++;
					PlayerInfo[playerid][pJobStatus] = 1;

					DestroyDynamicRaceCP(PlayerInfo[playerid][pJobCP]);
					PlayerInfo[playerid][pJobCP] = 0;
				}
			}
		}
		else if(GetPVarInt(playerid, "Job") == JOB_TRUCKER)
		{
			if(PlayerInfo[playerid][pJobStatus] == 3)
			{
				if(GetPlayerVehicleID(playerid) != PlayerInfo[playerid][pJobVehicleID]) return SendClientMessage(playerid, COLOR_ERROR, "You must be inside of your job vehicle to continue.");
				if(GetVehicleTrailer(GetPlayerVehicleID(playerid)) != PlayerInfo[playerid][pJobExtraVehicleID]) return SendClientMessage(playerid, COLOR_ERROR, "You must be towing your trailer in order to continue.");
			
				DestroyDynamicRaceCP(PlayerInfo[playerid][pJobCP]);
				PlayerInfo[playerid][pJobCP] = 0;

				ProgressBar(playerid, "Unloading Goods...", 10, 8);
				TogglePlayerControllable(playerid, false);
			}
		}
		if(GetPVarInt(playerid, "Job") == JOB_MECHANIC)
		{
			DestroyDynamicRaceCP(PlayerInfo[playerid][pJobCP]);
			PlayerInfo[playerid][pJobCP] = 0;
		}
	}

	if(checkpointid == PlayerInfo[playerid][pArcadeRaceCP])
	{
		DestroyDynamicRaceCP(PlayerInfo[playerid][pArcadeRaceCP]);

		new cp_count = PlayerInfo[playerid][pArcadeRaceCount];

		if(PlayerInfo[playerid][pArcadeRaceCount] <= sizeof(RaceCP))
		{
			if(PlayerInfo[playerid][pArcadeRaceCount] == sizeof(RaceCP))
			{
				if(PlayerInfo[playerid][pArcadeLaps] > 1)
				{
					PlayerInfo[playerid][pArcadeLaps]--;

					new string[128];
					if(PlayerInfo[playerid][pArcadeLaps] == 1)
					{
						format(string, sizeof(string), "You have %i lap remaining!", PlayerInfo[playerid][pArcadeLaps]);
					}
					else if(PlayerInfo[playerid][pArcadeLaps] > 1)
					{
						format(string, sizeof(string), "You have %i laps remaining!", PlayerInfo[playerid][pArcadeLaps]);
					}
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

					PlayerInfo[playerid][pArcadeRaceCP] = CreateDynamicRaceCP(0, RaceCP[0][rcX], RaceCP[0][rcY], RaceCP[0][rcZ],
						RaceCP[1][rcX], RaceCP[1][rcY], RaceCP[1][rcZ], 10.0, -1, -1, playerid, 4000);

	        		PlayerInfo[playerid][pArcadeRaceCount] = 1;

	        		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
					return 1;
				}
				else if(PlayerInfo[playerid][pArcadeLaps] <= 1)
				{
					for(new i = 0; i < MAX_ARCADES; i++)
					{
						if(Arcade[i][aType] == PlayerInfo[playerid][pArcade] && Arcade[i][aX] != 0.0)
						{
							Arcade[i][aFinished]++;
							Arcade[i][aStarted] = 0;
						}
					}

					for(new i = 0; i < MAX_ARCADES; i++)
					{
						if(Arcade[i][aType] == PlayerInfo[playerid][pArcade] && Arcade[i][aX] != 0.0)
						{
							new string[128];
							if(Arcade[i][aFinished] == 1)
							{
								format(string, sizeof(string), "%s has finished %ist!", GiveNameSpaceEx(PlayerInfo[playerid][pUsername]), Arcade[i][aFinished]);
							}
							else if(Arcade[i][aFinished] == 2)
							{
								format(string, sizeof(string), "%s has finished %ind!", GiveNameSpaceEx(PlayerInfo[playerid][pUsername]), Arcade[i][aFinished]);
							}
							else if(Arcade[i][aFinished] == 3)
							{
								format(string, sizeof(string), "%s has finished %ird!", GiveNameSpaceEx(PlayerInfo[playerid][pUsername]), Arcade[i][aFinished]);
							}
							else if(Arcade[i][aFinished] > 3)
							{
								format(string, sizeof(string), "%s has finished %ith!", GiveNameSpaceEx(PlayerInfo[playerid][pUsername]), Arcade[i][aFinished]);
							}

							SendClientMessageToAll(COLOR_LIGHTBLUE, string);
							break;
						}
					}

					DespawnVehicle(GetPlayerVehicleID(playerid));

					PlayerInfo[playerid][pArcade] = 0;
					PlayerInfo[playerid][pArcadeLaps] = 0;
					PlayerInfo[playerid][pArcadeRaceCP] = 0;
					PlayerInfo[playerid][pArcadeRaceCount] = 0;

					SetPlayerPosEx(playerid, GetPVarFloat(playerid, "PosX"), GetPVarFloat(playerid, "PosY"), GetPVarFloat(playerid, "PosZ"));
					SetPlayerInterior(playerid, GetPVarInt(playerid, "Interior"));
					SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "World"));

					OnPlayerDataSave(playerid);
					return 1;
				}
			}
			else if(PlayerInfo[playerid][pArcadeRaceCount] == sizeof(RaceCP) - 1)
			{
				if(PlayerInfo[playerid][pArcadeLaps] > 1)
				{
					PlayerInfo[playerid][pArcadeRaceCP] = CreateDynamicRaceCP(0, RaceCP[cp_count][rcX], RaceCP[cp_count][rcY], RaceCP[cp_count][rcZ],
						RaceCP[0][rcX], RaceCP[0][rcY], RaceCP[0][rcZ], 10.0, -1, -1, playerid);
				}
				else
				{
					PlayerInfo[playerid][pArcadeRaceCP] = CreateDynamicRaceCP(1, RaceCP[cp_count][rcX], RaceCP[cp_count][rcY], RaceCP[cp_count][rcZ],
						RaceCP[0][rcX], RaceCP[0][rcY], RaceCP[0][rcZ], 10.0, -1, -1, playerid);
				}

				PlayerInfo[playerid][pArcadeRaceCount]++;
			}
			else
			{
				PlayerInfo[playerid][pArcadeRaceCP] = CreateDynamicRaceCP(0, RaceCP[cp_count][rcX], RaceCP[cp_count][rcY], RaceCP[cp_count][rcZ],
					RaceCP[cp_count + 1][rcX], RaceCP[cp_count + 1][rcY], RaceCP[cp_count + 1][rcZ], 10.0, -1, -1, playerid);

				PlayerInfo[playerid][pArcadeRaceCount]++;
			}
		}
	}
	return 1;
}
//============================================//
/////////////////////////////////////////////////
// PROJECT REALITY ROLEPLAY CONFIGURATION FILE //
/////////////////////////////////////////////////
#define CFG_IP "127.0.0.1"
#define CFG_VERSION "0.3.7-R2"
#define CFG_MODE "PR-RP R18.217"
#define CFG_MAPNAME "Los Santos"
#define CFG_WEBSITE "forum.pr-rp.com"
#define CFG_LANGUAGE "English"
/////////////////////////////////////////////////
#define DEVELOPER_SERVER false

#if DEVELOPER_SERVER == true
#define MYSQL_HOST "127.0.0.1"
#define MYSQL_USER "root"
#define MYSQL_DB "rpgtest"
#define MYSQL_PASS ""
#else
#define MYSQL_HOST "127.0.0.1"
#define MYSQL_USER "root"
#define MYSQL_DB "rpgtest"
#define MYSQL_PASS ""
#endif
/////////////////////////////////////////////////
#undef 	MAX_PLAYERS
#define MAX_PLAYERS 					200	// Defines the maximum amount of players that should be able to connect to the server.
#define FOREACH_NO_BOTS
#define SERVER_DEBUG 0
#define SERVER_GMT 1
//============================================//
#define MAX_MSG_LENGTH					144	// Defines the chat's maximum amount of characters in one message.
#define MAX_DOUBLE_MSG_LENGTH           288 // 2 * MAX_MSG_LENGTH (For two chat lines)
//============================================//
#define SCRIPT_ANIMDELAY 500 // half a second before performing another animation.
#define SCRIPT_MILEDELAY 2500 // Two and a half seconds before allowing mileage check.
//============================================//
#define BCRYPT_COST 12
//============================================//
#define HOLDOBJECT_CLOTH1 0
#define HOLDOBJECT_CLOTH2 1
#define HOLDOBJECT_CLOTH3 2
#define HOLDOBJECT_CLOTH4 3
#define HOLDOBJECT_ITEM 4
#define HOLDOBJECT_ITEM2 5
#define HOLDOBJECT_PHONE 6
#define HOLDOBJECT_GUN1 7
#define HOLDOBJECT_GUN2 8
#define HOLDOBJECT_GUN3 9
//============================================//
#define WALKSTYLE_GANG1 1
#define WALKSTYLE_GANG2 2
#define WALKSTYLE_NORMAL 3
#define WALKSTYLE_SEXY 4
#define WALKSTYLE_OLD 5
#define WALKSTYLE_SNEAK 6
#define WALKSTYLE_BLIND 7
#define WALKSTYLE_ARMED 8
#define WALKSTYLE_POLICE 9
#define WALKSTYLE_FEMALE 10
#define WALKSTYLE_FAT 11
#define WALKSTYLE_MUSCLE 12
//============================================//
#define LOADBOT_TIME 500
#define NPC_TYPE_NORMAL 0
#define NPC_TYPE_STRIPPER 1
#define NPC_TYPE_BOXER 2
#define NPC_TYPE_DANCER 3
#define NPC_TYPE_BUS_1 4
#define NPC_TYPE_BUS_2 5
#define NPC_TYPE_TRAIN 6
#define NPC_TYPE_COP 7
#define NPC_TYPE_TRAINER 8
//============================================//
#define MAX_PLAYER_TOYS 6
#define MAX_VEH_SLOTS 24
#define DEFAULT_VEHICLE_SLOTS 16
#define SMALL_VEHICLE_SLOTS 8
#define MAX_GLOVE_BOX_SLOTS 4
#define MAX_VEHICLE_SIREN_OBJECTS 5
#define MAX_FIRES 1000
#define MAX_LOOT 100
#define MAX_JOBS 7
#define MAX_INV_SLOTS 15
#define MAX_HOUSE_SLOTS 12
#define MAX_HOUSE_SKINS 3
#define MAX_BUSINESS_SLOTS 12
#define INVALID_MAXPL MAX_PLAYERS + 1
#define MAX_DELAY_SLOTS 5
#define MAX_DELAY_SLOTS 5
#define MAX_BUSINESSES 500
#define MAX_HOUSES 1000
#define MAX_INTS 150
#define MAX_FACTIONS 20 + 1
#define MAX_FACTION_RANKS 20 + 1
#define MAX_HOUSE_OBJ 1000
#define MAX_OBJECT_ARRAY 200000
#define MAX_ACHIEVEMENTS 16
#define MAX_VOTING_BOOTHS 50
#define MAX_SPAWNED_VEHICLES 2
#define MAX_ARCADES 50
#define MAX_PLAYER_ARMOUR 50.0
#define MAX_PLAYER_WEED_PLANTS 2
#define MAX_LSPD_DIVISIONS 4
#define MAX_PLAYER_CONTACTS 20
#define MAX_CAMPFIRES 100
#define MAX_BOOM_BOXES 50
#define MAX_BOOM_BOX_RANGE 35.0
#define MAX_WALKIE_TALKIE_DISTANCE 750.0
#define MAX_SPIKES 10
#define MAX_NPC 50
#define MAX_ROADBLOCKS 50
#define MAX_TAGS 50
#define MAX_PRESENTS 50
#define MAX_CORPSES 50
#define MAX_WEED 50
#define MAX_CRACK 50
#define MAX_SHELLS 100
#define MAX_TRACERS 10
#define MAX_DOORS 100
#define MAX_GATES 100
#define MAX_MAP_OBJECTS 50000
#define MAX_SCENES 75
//============================================//
#define DAMAGE_COLT 35
#define DAMAGE_SILENCER 35
#define DAMAGE_DEAGLE 60
#define DAMAGE_SHOTGUN 40
#define DAMAGE_SAWNOFF 35
#define DAMAGE_UZI 35
#define DAMAGE_MP5 35
#define DAMAGE_AK47 45
#define DAMAGE_RIFLE 40
#define DAMAGE_TEC9 35
#define DAMAGE_M4 45
#define DAMAGE_SNIPER 155
//============================================//
#define DIALOG_VEHICLE_SPAWN            5000 // Until all dialogIDs have been defined in preprocessor, use high numbers instead of enumerator.
#define DIALOG_VEHICLE_SELL             5001
#define DIALOG_RADIO           			5002
#define DIALOG_RADIO_STATION            5003
#define DIALOG_RADIO_CUSTOM          	5004
#define DIALOG_CLOSE                    5005
#define DIALOG_MDC_SEARCH_CITIZEN       5006
#define DIALOG_MDC_SEARCH_SERIAL        5007
#define DIALOG_MDC_SEARCH_PHONE_NUMBER  5008
#define DIALOG_MDC_SEARCH_PLATE			5009
#define DIALOG_HOUSE_CLOTHING           5010
#define DIALOG_SAN_NEWS_SPAWN           5011
#define DIALOG_HOUSE_REMOVEALL          5012
#define DIALOG_BIZ_REMOVEALL            5013
#define DIALOG_INVENTORY_DIVIDE         5014
#define DIALOG_LSFD_HELIPAD_ELEVATOR    5015
#define DIALOG_LSFD_GROUND_ELEVATOR     5016
#define DIALOG_SIREN_EDITOR             5017
#define DIALOG_SIREN_EDITOR_REMOVE      5019
#define DIALOG_EVENT_CLOTHING           5020
#define DIALOG_CELLPHONE_DIAL           5021
#define DIALOG_REGISTER_AGE             2022
#define DIALOG_REGISTER_GENDER          2023
#define DIALOG_REGISTER_FORUMNAME       2024
#define DIALOG_REGISTER_REVIEW          2025
#define DIALOG_REGISTER_REVIEW_DENY     2026
#define DIALOG_AMMO_STORE               2027
#define DIALOG_TAKE_INVENTORY           2028
#define DIALOG_DOC_SPAWN                2029
#define DIALOG_HOUSE_EXIT               2030
#define DIALOG_RADIO_YOUTUBE            2031
#define DIALOG_LOG_NAME                 2032
#define DIALOG_LOG_SELECT               2033
#define DIALOG_LOG_DISPLAY              2034
#define DIALOG_WAREHOUSE_VEHICLE        2035
#define DIALOG_INJURIES                 2036
//============================================//
#define ZONE_NAME_MAX_LENGTH            30
//============================================//
#define HASHTYPE_WHIRLPOOL 1
#define HASHTYPE_BCYRPT 2
//============================================//
#define MAX_CRIMINAL_RECORDS            50
#define MDC_DESCRIPTION_MAX_LENGTH      200
#define MDC_DEFAULT_ACCESS_RANGE        3.0
//============================================//
#define VEHICLE_RESPAWN_DELAY			-1
#define VEHICLE_PLATE_MAX_LENGTH    	33
#define VEHICLE_RADIO_URL_MAX_LENGTH    256
#define VEHICLE_MAX_AMOUNT              10
#define VEHICLE_DONATOR_MAX_AMOUNT      10
#define VEHICLE_REGULAR_MAX_AMOUNT      5
#define VEHICLE_LOCK_RANGE              20.0
#define VEHICLE_DESPAWN_RANGE           20.0
#define VEHICLE_INVENTORY_RANGE         4.0
#define VEHICLE_SELL_RANGE              5.0
#define VEHICLE_DESPAWN_TIMER           600000
#define VEHICLE_RENTAL_DESPAWN_TIMER    600000
#define VEHICLE_FACTION_DESPAWN_TIMER   600000
// VEHICLE_DESPAWN_TIMER takes milliseconds, not seconds!
//============================================//
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_FADE 0xC8C8C8C8
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_LIGHTRED 0xFF0000FF
#define COLOR_PURPLE 0xC2A2DAAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_YELLOW 0xDABB3E00
#define COLOR_BLUE 0x2641FEAA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_DARKBLUE 0x000040FF
#define COLOR_PINK 0xFF8282FF
#define COLOR_ORANGE 0xFFCC33AA
#define COLOR_RED 0xCD5C5CFF
#define COLOR_BROWN 0xC46816FF
#define COLOR_LIME 0x10F441AA

#define COLOR_HELPER 0x00808000
#define COLOR_ADMIN 0x00751DFF
#define COLOR_SENIOR_ADMIN 0x669965FF
#define COLOR_LEAD_ADMIN 0xC60B0BFF

#define COLOR_SUCCESS 0x91C8FFFF
#define COLOR_ERROR 0xFF5A3EFF
#define COLOR_JOB 0xB5B56AFF
#define COLOR_PUBLIC_ADMIN 0xD90000FF
#define COLOR_PHONE 0xFFFF80FF
#define COLOR_MAP 0xD20DCDFF

#define EMBED_COLOR_WHITE "{FFFFFF}"
#define EMBED_COLOR_RED "{FF0000}"
#define EMBED_COLOR_BLUE "{41FEAA}"
//============================================//
#define HOLDING(%0) \
    ((newkeys & (%0)) == (%0))
#define RELEASED(%0) \
    (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#define PRESSED(%0) \
    (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
//============================================//
#if !defined isnull
    #define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif
//============================================//
#if !defined INFINITY
#define INFINITY (Float:0x7F800000)
//============================================//
#define scm SendClientMessage
#define SCM SendClientMessage
//============================================//
#define CHECKPOINT_GUN 1
#define CHECKPOINT_BAR 2
#define CHECKPOINT_REST 3
#define CHECKPOINT_STORE 4
#define CHECKPOINT_BANK 5
#define CHECKPOINT_CLUCK 6
#define CHECKPOINT_PIZZA 7
#define CHECKPOINT_BURGER 8
#define CHECKPOINT_SEXSHOP 9
#define CHECKPOINT_WARESHOP 10
#define CHECKPOINT_LSPD 11
#define CHECKPOINT_GYM 12
#define CHECKPOINT_HOSPITAL 13
#define CHECKPOINT_FACTION 14
#define CHECKPOINT_CHURCH 15
#define CHECKPOINT_DONUT 16
#define CHECKPOINT_AMMO 17
#define CHECKPOINT_FISH 18
//============================================//
enum {
	VEHICLE_NONE,
	VEHICLE_PERSONAL,
	VEHICLE_RENTAL,
	VEHICLE_LSPD,
	VEHICLE_LSFD,
	VEHICLE_GOV,
	VEHICLE_JOB,
	VEHICLE_DMV,
	VEHICLE_SAN,
	VEHICLE_RLS,
	VEHICLE_ADMIN,
	VEHICLE_NPC
}
//============================================//
enum {
	RECORD_TICKET,
	RECORD_CHARGE
}
//============================================//
#define GARAGE_ENTRANCE_COST 5000
#define GARAGE_EXIT_COST 5000
#define GARAGE_BARESWITCH_COST 5000
//============================================//
#define HOUSE_AUTO_SELL_DAYS 30 // houses will be auto sold after 14 days for inactivity

#define HOUSE_BACKDOOR_DISTANCE 35.0
#define HOUSE_PLANT_DISTANCE 35.0
#define HOUSE_GARAGE_DISTANCE 35.0
#define HOUSE_OUTDOOR_OBJECTS 30
#define HOUSE_OBJECT_MATERIALS 10
//============================================//
#define BUSINESS_BACKDOOR_DISTANCE 35.0
#define BUSINESS_PLANT_DISTANCE 35.0
#define BUSINESS_OUTDOOR_OBJECTS 30
#define BUSINESS_OBJECT_MATERIALS 10
//============================================//
#define JOB_MECHANIC 1
#define JOB_GARBAGE 2
#define JOB_STREET 3
#define JOB_PIZZA 4
#define JOB_TAXI 5
#define JOB_TRUCKER 6
#define JOB_FARMER 7

#define JOB_PIZZA_BOY_DIVIDER 4
#define JOB_TRUCKER_PAY 900
#define JOB_GARBAGE_MAN_PAY 1200
#define JOB_STREETSWEEPER_PAY 1000
#define JOB_FARMER_PAY 1300
#define JOB_FISHING_MULTIPLIER 2
#define JOB_TRUCKER_MULTIPLIER 0.35
//============================================//
#define FACTION_LSPD 1
#define FACTION_LSFD 2
#define FACTION_RLS 3
#define FACTION_FOX_ENTERPRISE 4
#define FACTION_LSG 5
//============================================//
#define LOTTERY_BASE_WINNING 25000
//============================================//
#define LOG_DISPLAY_DAYS 14 // /logs will display logs from last 14 days
#define LOG_CLEAR_DAYS 14 // server logs will be cleared in 14 days
//============================================//
#define LOG_GUN_BUY "LOG_GUN_BUY"
#define LOG_AMMO_BUY "LOG_AMMO_BUY"
#define LOG_PAY "LOG_PAY"
#define LOG_LOG_IN "LOG_LOG_IN"
#define LOG_DISCONNECT "LOG_DISCONNECT"
#define LOG_ITEM_PICK_UP "LOG_ITEM_PICK_UP"
#define LOG_ITEM_DROP "LOG_ITEM_DROP"
#define LOG_ITEM_USE "LOG_ITEM_USE"
#define LOG_STORE_HOUSE_ITEM "LOG_STORE_HOUSE_ITEM"
#define LOG_STORE_BIZ_ITEM "LOG_STORE_BIZ_ITEM"
#define LOG_STORE_VEHICLE_ITEM "LOG_STORE_VEHICLE_ITEM"
#define LOG_STORE_GLOVEBOX_ITEM "LOG_STORE_GLOVEBOX_ITEM"
#define LOG_ADMIN_SPAWN_ITEM "LOG_ADMIN_SPAWN_ITEM"
#define LOG_VEHICLE_SPAWN "LOG_VEHICLE_SPAWN"
#define LOG_VEHICLE_DESPAWN "LOG_VEHICLE_DESPAWN"
#define LOG_WEAPON_STORE "LOG_WEAPON_STORE"
#define LOG_WEAPON_EQUIP "LOG_WEAPON_EQUIP"
#define LOG_WEAPON_STORE_AMMO "LOG_WEAPON_STORE_AMMO"
#define LOG_WEAPON_GIVE "LOG_WEAPON_GIVE"
#define LOG_WEAPON_DROP "LOG_WEAPON_DROP"
#define LOG_COMMAND "LOG_COMMAND"
#define LOG_PLAYER_DEATH "LOG_PLAYER_DEATH"
#define LOG_WAREHOUSE_BUY "LOG_WAREHOUSE_BUY"
//============================================//
#define STREAM_TYPE_BUSINESS 1
#define STREAM_TYPE_HOUSE 2
#define STREAM_TYPE_PLANT_RADIO 3
#define STREAM_TYPE_VEHICLE 4
//============================================//
#define DRUG_TIME_COCAINE 20 * 60
#define DRUG_TIME_CRACK 15 * 60
#define DRUG_TIME_CANNABIS 10 * 60
//============================================//
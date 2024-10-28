class_name MemberChecker extends Node

@export var packets : PacketManager
@export var ui : Label
@export var anim_fade : AnimationPlayer
@export var instance_handler : MP_UserInstanceHandler

var checking = false
var amountOfPlayers_here = 1
var membersHere_list = []

func _ready():
	if (!GlobalVariables.mp_debugging): InitialCheck(); print("starting member check")

func InitialCheck():
	ui.visible = true
	amountOfPlayers_here = 1
	
	if (GlobalSteam.STEAM_ID == GlobalSteam.HOST_ID):
		membersHere_list.append(GlobalSteam.HOST_ID)
		CheckMembers()
		UpdateMemberList()
		var packet = {
			"packet category": "lobby",
			"packet alias": "host arrived in main scene",
			"packet_id": 3,
		}
		packets.send_p2p_packet(0, packet)

	if (GlobalSteam.STEAM_ID != GlobalSteam.HOST_ID):
		var packet = {
			"packet category": "lobby",
			"packet alias": "member joined list",
			"packet_id": 4,
			"steam_id": GlobalSteam.STEAM_ID,
		}
		packets.send_p2p_packet(GlobalSteam.HOST_ID, packet)

func CheckMembers():
	checking = true

var fs = false
func _process(delta):
	if (checking && !fs):
		if (amountOfPlayers_here == GlobalSteam.LOBBY_MEMBERS.size()):
			MembersArrived()
			var packet = {
				"packet category": "lobby",
				"packet alias": "all members arrived",
				"packet_id": 5,
			}
			packets.send_p2p_packet(0, packet)
			fs = true

func MemberJoinedList(steam_id : int):
	membersHere_list.append(steam_id)
	amountOfPlayers_here += 1
	UpdateMemberList()
	var packet = {
		"packet category": "lobby",
		"packat alias": "update member list",
		"number of players here": amountOfPlayers_here
	}
	for id in membersHere_list:
		if (id != GlobalSteam.HOST_ID):
			packets.send_p2p_packet(id, packet)
	

func UpdateMemberList():
	print("incrementing list")
	ui.text = tr("MP_UI WAITING FOR PLAYERS") + " (" + str(amountOfPlayers_here) + "/" + str(GlobalSteam.LOBBY_MEMBERS.size()) + ")"

func MembersArrived():
	anim_fade.play("fade")
	await get_tree().create_timer(2.7, false).timeout
	instance_handler.StartMainGame()
































class_name MP_Matchmaking extends Node

@export var result_instance : PackedScene
@export var result_parent : VBoxContainer
@export var label_satellite : Label
@export var search_console : Label
@export var label_search_range : Label
@export var animator_globe : AnimationPlayer
@export var animator_pan : AnimationPlayer
@export var lobby_ui : MP_LobbyUI
@export var animator_fader : AnimationPlayer
@export var lobby : LobbyManager
@export var feed : TextureRect

@export var speaker_relay_loop : AudioStreamPlayer2D
@export var speaker_relay_end : AudioStreamPlayer2D

var range_array = ["near", "far", "worldwide"]
var range_index = 0
var search_range = "near"

var origspeed_globe = 0
var origspeed_pan = 0

func _ready():
	origspeed_globe = animator_globe.speed_scale
	origspeed_pan = animator_pan.speed_scale
	FindSatellite()
	UpdateSearchRange()
	Steam.lobby_match_list.connect(OnLobbyList)
	Steam.addRequestLobbyListResultCountFilter(50)

func RefreshList():
	animator_globe.speed_scale = animator_globe.speed_scale / 2
	animator_pan.speed_scale = animator_pan.speed_scale / 2
	speaker_relay_loop.play()
	feed.modulate.a = .5
	for child in result_parent.get_children():
		child.queue_free()
	search_console.text = tr("MP_SEARCHING FOR LOBBIES")
	UpdateSearchRange()
	Get()

func OnLobbySearchEnter():
	animator_globe.stop(true)
	animator_globe.play("spin")
	animator_pan.stop(true)
	animator_pan.play("pan")
	RefreshList()

func ToggleSearchRange():
	if range_index != 2:
		range_index += 1
	else:
		range_index = 0
	search_range = range_array[range_index]
	UpdateSearchRange()
	RefreshList()

func UpdateSearchRange(): 
	match search_range:
		"near":
			Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_CLOSE)
		"far":
			Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_FAR)
		"worldwide":
			Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	label_search_range.text = tr("MP_SET RANGE") % tr("MP_RANGE " + search_range.to_upper())

func Get():
	Steam.requestLobbyList()
	print("getting lobby list")

func JoinLobbyFromSearch(lobby_id : int):
	lobby.interaction_enabled = false
	animator_fader.play("fade in")
	await get_tree().create_timer(.4, false).timeout
	lobby_ui.ExitLobbySearch()
	animator_fader.play("fade out")
	await get_tree().create_timer(.4, false).timeout
	lobby.join_lobby(lobby_id)
	lobby.interaction_enabled = true

func OnLobbyList(list):
	speaker_relay_loop.stop()
	speaker_relay_end.play()
	animator_globe.speed_scale = origspeed_globe
	animator_pan.speed_scale = origspeed_pan
	feed.modulate.a = 1
	print("lobbies found: ", list)
	var index = 0
	var invalid_list_array = []
	for lobby in list:
		if Steam.getLobbyData(lobby, "member_count") == "" or Steam.getLobbyData(lobby, "player_limit") == "":
			print("found invalid lobby, skipping")
			invalid_list_array.append(0)
			continue
		index += 1
		print("result: ", index, " - ", lobby, " with member count: ", Steam.getLobbyData(lobby, "member_count"), " and player limit: ", Steam.getLobbyData(lobby, "player_limit"))
		var result = result_instance.instantiate()
		result_parent.add_child(result)
		var result_branch : MP_Matchmaking_Result = result.get_child(0)
		result_branch.Set(index, Steam.getLobbyData(lobby, "member_count"), Steam.getLobbyData(lobby, "player_limit"))
		result_branch.AssignLobbyID(lobby)
	if list == [] or invalid_list_array.size() == list.size():
		search_console.text = tr("MP_NO LOBBIES FOUND")
	else:
		search_console.text = ""

func FindSatellite():
	var prefix = GetLetter() + GetLetter()
	var serial_number = str(randi_range(4000, 4999))
	var launch_index = str(randi_range(1, 9))
	label_satellite.text = prefix + "_" + serial_number + " NO. " + launch_index

func GetLetter():
	var letters = ["a", "d", "o", "x", "z", "i", "j", "h", "f", "k", "m", "y", "b", "c", "u", "w"]
	return letters[randi_range(0, letters.size() - 1)]

func Trial():
	var list = []
	for i in 50: list.append(0)
	var index = 0
	for lobby in list:
		var member_count = randi_range(1, 3)
		var player_limit = randi_range(member_count + 1, 4)
		index += 1
		var result = result_instance.instantiate()
		result_parent.add_child(result)
		var result_branch : MP_Matchmaking_Result = result.get_child(0)
		result_branch.Set(index, str(member_count), str(player_limit))

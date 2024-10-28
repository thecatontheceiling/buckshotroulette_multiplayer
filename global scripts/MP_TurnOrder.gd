class_name MP_TurnOrder extends Node

@export var game_state : MP_GameStateManager
@export var parent : Node3D
@export var animator_indicator : AnimationPlayer
@export var speaker_turn_order_bootup : AudioStreamPlayer2D

var default_animation_speed : float

func _ready():
	default_animation_speed = animator_indicator.speed_scale

func StartIndicator(direction : String):
	animator_indicator.speed_scale = 0
	await get_tree().create_timer(.5, false).timeout
	speaker_turn_order_bootup.play()
	parent.visible = true
	animator_indicator.speed_scale = default_animation_speed
	if direction == "CW":
		animator_indicator.play("loop clockwise")
	else:
		animator_indicator.play_backwards("loop clockwise")

func FlipTurnOrder():
	if game_state.MAIN_active_turn_order == "CW": game_state.MAIN_active_turn_order = "CCW"
	else: game_state.MAIN_active_turn_order = "CW"

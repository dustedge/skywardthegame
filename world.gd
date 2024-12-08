extends Node2D
class_name World

var cam_height = 99999
@onready var cam = $Camera2D
@onready var player = $Player
@onready var score_label = $UI/ScoreLabel
@onready var platform_spawner = $Camera2D/PlatformSpawner
@onready var platform_root = $Camera2D/PlatformSpawner/PlatformRoot
@onready var death_screen = $UI/DeathScreen
@onready var ui : UI = $UI

var final_score : int = 0
var target_platforms := 20
var platforms_count := 0
var cam_speed = 1200.0
var cam_start : Vector2
var cam_margin = 100.0
var difficulty_score_step := 15000
var score_to_next_difficulty := difficulty_score_step
var player_score : int = 0
var stage := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	DiscordManager.set_state(DiscordManager.State.IN_GAME)
	DiscordManager.current_layer = ui.get_layer_name(stage)
	DiscordManager.current_score = player_score
	DiscordManager.update_rpc()
	
	Globals.current_difficulty = Globals.Difficulty.BREEZE
	death_screen.hide()
	player.connect("player_died", _on_player_died)
	player.connect("player_received_damage", _on_player_received_damage)
	
	cam_start = cam.position
	ui.display_stage_text(stage)
	SoundManager.start_world_playlist()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	score_label.text = "SCORE: " + str(player_score).pad_zeros(9) + " DIFF: " + str(Globals.current_difficulty)
	score_label.text += "\nPLATFORMS: " + str(platform_root.get_child_count())
	target_platforms = Globals.diff_target_plat[Globals.current_difficulty]
	
	if player_score >= score_to_next_difficulty:
		score_to_next_difficulty += difficulty_score_step
		Globals.increase_difficulty()
		stage += 1
		
		DiscordManager.current_layer = ui.get_layer_name(stage)
		DiscordManager.update_rpc()
		
		$BGCanvasLayer.change_parallax_to(stage)
		ui.display_stage_text(stage)
		if stage >= 4:
			player.flashlight_on()
	update_parralax()
	pass

func _physics_process(delta: float) -> void:
	if player.position.y < cam_height:
		cam_height = player.position.y
		 
	if cam.position.y > cam_height + cam_margin:
		cam.position.y = move_toward(cam.position.y, cam_height + cam_margin, (cam_speed * delta))
	
	if abs(cam_height - cam_start.y) > player_score:
		player_score = abs(cam_height - cam_start.y)
	
	update_platforms()

func update_platforms():
	pass

func _on_player_died():
	final_score = player_score
	death_screen.set_score(player_score)
	Globals.save_score("Main", Globals.player_name, final_score)
	death_screen.update_saved_scores()
	death_screen.show()
	
func _on_player_received_damage(damage):
	$UI/HeartsContainer.update_health(player.health)
	
func update_parralax():
	pass

func map_value(value: float, input_min: float, input_max: float, output_min: float = 0.0, output_max: float = 1.0) -> float:
	return (value - input_min) / (input_max - input_min) * (output_max - output_min) + output_min


func _on_rpc_timer_timeout() -> void:
	DiscordManager.current_score = player_score
	DiscordManager.update_rpc()

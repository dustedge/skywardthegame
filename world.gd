extends Node2D
class_name World

var cam_height = 99999
@onready var cam = $Camera2D
@onready var player = $Player
@onready var score_label = $UI/ScoreLabel
@onready var platform_spawner = $Camera2D/PlatformSpawner
@onready var platform_root = $Camera2D/PlatformSpawner/PlatformRoot
@onready var death_screen = $UI/DeathScreen

var final_score : int = 0
var target_platforms := 20
var platforms_count := 0
var cam_speed = 400.0
var cam_start : Vector2
var cam_margin = 100.0
var difficulty_score_step := 10000
var score_to_next_difficulty := difficulty_score_step
var player_score : int = 0
var stage := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.current_difficulty = Globals.Difficulty.BREEZE
	death_screen.hide()
	player.connect("player_died", _on_player_died)
	cam_start = cam.position
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

func update_parralax():
	if stage == 1 and player_score < score_to_next_difficulty:
		$BGCanvasLayer/Parallax/SkySunsetLayer.modulate.a = map_value(player_score,\
		difficulty_score_step * stage, score_to_next_difficulty)
		$DirectionalLight2D.color = Color.from_hsv(0, 0, map_value(player_score,\
		difficulty_score_step * stage, score_to_next_difficulty, 1.0, 0.0))
	
	elif stage == 2 and player_score < score_to_next_difficulty:
		$BGCanvasLayer/Parallax/SkyNightLayer.modulate.a = map_value(player_score,\
		difficulty_score_step * stage, score_to_next_difficulty)

func map_value(value: float, input_min: float, input_max: float, output_min: float = 0.0, output_max: float = 1.0) -> float:
	return (value - input_min) / (input_max - input_min) * (output_max - output_min) + output_min

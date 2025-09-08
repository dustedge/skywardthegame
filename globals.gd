extends Node

enum Difficulty {
	BREEZE,
	EASY,
	NORMAL,
	HARD,
	HARDEST,
	IMPOSSIBLE
}

var diff_target_plat : Dictionary = {
	Difficulty.BREEZE : 16,  #20
	Difficulty.EASY : 14,    #18
	Difficulty.NORMAL : 12,  #14
	Difficulty.HARD : 10,    #12
	Difficulty.HARDEST: 8,   #8
	Difficulty.IMPOSSIBLE: 5 #5
}

enum EffectType {
	LOW_GRAVITY,
	HEAVY,
	JUMP_BOOST,
	MULTISHOT,
	INVULNERABLE
}

var current_difficulty := Difficulty.BREEZE

func increase_difficulty():
	if current_difficulty < Difficulty.keys().size() - 1:
		current_difficulty += 1

var current_stage := 0
var player_name := "Unnamed"
var player_coins := 0
var current_player_upgrades := {}
var player_data := {}
var savefile = ConfigFile.new()
var scores : Array[Dictionary] = []
var current_save := "file_01"
var settings_file := ConfigFile.new()
var world_camera : WorldCamera
var current_player : Player = null


func _ready() -> void:
	
	var err = settings_file.load("user://config.ini")
	if err != OK:
		print("config loading error: ", err)
		return
	else:
		load_config()
	
	
	err = savefile.load("user://savedata.sav")
	if err != OK:
		print("save loading error: ", err)
		return
		
	
	
	update_player_data(current_save)


func load_save(slot : String):
	current_save = slot
	update_player_data(current_save)
	
func save_config():
	print("save conf")
	settings_file.set_value("Sound", "volume_bgm", SoundManager.volume_bgm)
	settings_file.set_value("Sound", "volume_sfx", SoundManager.volume_sfx)
	settings_file.save("user://config.ini")
	pass

func load_config():
	var volume_bgm = settings_file.get_value("Sound", "volume_bgm", -24.0)
	var volume_sfx = settings_file.get_value("Sound", "volume_sfx", -24.0)
	SoundManager.set_volume("BGM", volume_bgm)
	SoundManager.set_volume("SFX", volume_sfx)
	pass

func save_game(score : int = 0, owned_upgrades : Dictionary = current_player_upgrades, owned_coins : int = player_coins, save_id = current_save):
	var current_max_score = savefile.get_value(current_save, "max_score", 0)
	savefile.set_value(save_id, "player_name", player_name)
	savefile.set_value(save_id, "max_score", max(score, current_max_score))
	savefile.set_value(save_id, "upgrades", owned_upgrades)
	savefile.set_value(save_id, "coins", owned_coins)
	savefile.set_value(save_id, "volume_bgm", SoundManager.volume_bgm)
	savefile.set_value(save_id, "volume_sfx", SoundManager.volume_sfx)
	savefile.save("user://savedata.sav")
	update_player_data(save_id)

func update_player_data(from_section):
	
	for save in savefile.get_sections():
		var _player_name = savefile.get_value(save, "player_name")
		var max_score = savefile.get_value(save, "max_score")
		var upgrades = savefile.get_value(save, "upgrades")
		var coins = savefile.get_value(save, "coins")
	
		if not _player_name in player_data.keys():
			player_data[_player_name] = {}
		
		player_data[_player_name]["max_score"] = max_score
		player_data[_player_name]["upgrades"] = upgrades
		player_data[_player_name]["coins"] = coins
		
		# on currently used save data
		if save == from_section:
			current_player_upgrades = upgrades
			player_name = _player_name
			player_coins = coins
	
	if not from_section in savefile.get_sections():
		current_player_upgrades = {}
		player_name = "Unnamed"
		player_coins = 0

func shake_camera(strength : float = 1.0):
	if not world_camera:
		return
	world_camera.shake(strength)
	
func get_player_node() -> Player:
	return current_player

func reset():
	# Reset all values to default
	current_stage = 0
	player_name = "Unnamed"
	player_coins = 0
	current_player_upgrades = {}
	player_data = {}
	scores = []
	current_save = "file_01"
	current_player = null
	print("GLOBALS: Values reset.")

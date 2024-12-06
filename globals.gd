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
	Difficulty.BREEZE : 20,  #20
	Difficulty.EASY : 18,    #18
	Difficulty.NORMAL : 14,  #14
	Difficulty.HARD : 12,    #12
	Difficulty.HARDEST: 8,   #8
	Difficulty.IMPOSSIBLE: 5 #5
}

var current_difficulty := Difficulty.BREEZE

func increase_difficulty():
	if current_difficulty < Difficulty.keys().size() - 1:
		current_difficulty += 1

var player_name := ""
var score_data := {}
var savefile = ConfigFile.new()
var scores : Array[Dictionary] = []

func _ready() -> void:
	
	var err = savefile.load("user://scores.sav")
	if err != OK:
		print("save loading error: ", err)
		return
	
	update_score_data()
		
	if score_data.keys().size() > 0:
		player_name = score_data.keys().front()

func save_score(player, player_name, score : int):
	
	if score < int(savefile.get_value(player, "player_score", 0)):
		return
	savefile.set_value(player, "player_name", player_name)
	savefile.set_value(player, "player_score", score)
	savefile.save("user://scores.sav")
	update_score_data()

func update_score_data():
	for player in savefile.get_sections():
		var player_name = savefile.get_value(player, "player_name")
		var player_score = savefile.get_value(player, "player_score")
		score_data[player_name] = player_score

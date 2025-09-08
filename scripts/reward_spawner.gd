extends Node
class_name RewardSpawner

var player : Player = null
var reward_coin_scene := preload("res://objects/reward_coin.tscn")

func _ready() -> void:
	player = null

func spawn_reward(coins_amount : int, where : Vector2):
	if not player and Globals.get_player_node():
		player = Globals.get_player_node()
		
	if not player:
		return
	
	for i in range(coins_amount):
		var coin : RewardCoin = reward_coin_scene.instantiate()
		self.add_child(coin)
		coin.global_position = where
		await coin._setup(player)
		coin.z_index = 10
		coin.go()

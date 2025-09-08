extends Node2D

@onready var spawn_area_shape : CollisionShape2D = $Area2D/spawn_area
var spring_scene = preload("res://spring.tscn")
var platform_scene = preload("res://platform.tscn")
var enemy_eye_scene = preload("res://entities/flying_eye.tscn")
var pickup_scene = preload("res://objects/pickup.tscn")
var multishot_scene = preload("res://objects/multi_shot_pickup.tscn")

@onready var platform_root = $PlatformRoot
@onready var object_root = $ObjectRoot
@onready var enemy_spawner : EnemySpawner = get_parent().get_node("EnemySpawner")
var max_player_reach_x = 500
var vertical_spacing = 0.0
var last_spawn_y = 640
var target_platforms = 0

var spawn_chances = {
	"coin" : 5,
	"health" : 1,
	"feather" : 1,
	"bear_trap" : 1,
	"multishot" : 0.5,
	"spring" : 5,
	"moving_platform" : 5,
	"invulnerability" : 0.5,
	"skeleton" : 0.1,
}

func _ready() -> void:
	last_spawn_y = spawn_area_shape.global_position.y + spawn_area_shape.shape.get_rect().size.y/2
	
	var upgrades = Globals.current_player_upgrades
	
	if upgrades.has(Upgrade.UpgradeType.COIN_CHANCE):
		spawn_chances["coin"] += upgrades[Upgrade.UpgradeType.COIN_CHANCE]["level"] / 10.0
		print("coin chance: ", spawn_chances["coin"])
		
	if upgrades.has(Upgrade.UpgradeType.FEATHER_CHANCE):
		spawn_chances["feather"] += upgrades[Upgrade.UpgradeType.COIN_CHANCE]["level"] / 10.0
		print("feather chance: ", spawn_chances["feather"])
		
	if upgrades.has(Upgrade.UpgradeType.HEAL_CHANCE):
		spawn_chances["health"] += upgrades[Upgrade.UpgradeType.COIN_CHANCE]["level"] / 10.0
		print("health chance: ", spawn_chances["health"])
		
	if upgrades.has(Upgrade.UpgradeType.SHIELD_CHANCE):
		spawn_chances["invulnerability"] += upgrades[Upgrade.UpgradeType.SHIELD_CHANCE]["level"] / 10.0
		print("invulnerability chance: ", spawn_chances["invulnerability"])
	
	if upgrades.has(Upgrade.UpgradeType.MULTISHOT_CHANCE):
		spawn_chances["multishot"] += upgrades[Upgrade.UpgradeType.MULTISHOT_CHANCE]["level"] / 10.0
		print("multishot chance: ", spawn_chances["multishot"])
	
var platforms : Array[Platform] = []	

func _physics_process(delta: float) -> void:
	target_platforms = Globals.diff_target_plat[Globals.current_difficulty]
	if platforms.size() < target_platforms and platform_root.get_child_count() < target_platforms*3:
		if randi() % 100 > 95:
			spawn_platform(true)
		spawn_platform()

func spawn_platform(is_breakable := false):
	
	# get vertical spacing between platforms
	vertical_spacing = spawn_area_shape.shape.get_rect().size.y / Globals.diff_target_plat[Globals.current_difficulty]
	
	var new_plat : Platform = platform_scene.instantiate()
	platform_root.add_child(new_plat)
	new_plat.is_breakable = is_breakable
	
	new_plat.call_deferred("set_stage", Globals.current_stage)
	var halfx = spawn_area_shape.shape.get_rect().size.x/2
	var halfy = spawn_area_shape.shape.get_rect().size.y/2
	var x = randi_range(-halfx, halfx)
	var y = (last_spawn_y - vertical_spacing) - randf_range(-20.0, 20.0)
	new_plat.top_level = true
	new_plat.global_position = Vector2(spawn_area_shape.global_position.x + x, y)
	
	if !is_breakable:
		last_spawn_y = new_plat.global_position.y 
	
	if randf_range(0, 100) <= spawn_chances["spring"]:
		add_spring(new_plat.global_position)
		
	elif randf_range(0, 100) <= spawn_chances["health"]:
		add_pickup(new_plat.global_position, Pickup.Type.HEALTH)
		
	elif randf_range(0, 100) <= spawn_chances["feather"]:
		add_pickup(new_plat.global_position, Pickup.Type.LOW_GRAVITY)
		
	elif randf_range(0, 100) <= spawn_chances["bear_trap"]:
		add_pickup(new_plat.global_position, Pickup.Type.BEAR_TRAP)
		
	elif randf_range(0, 100) <= spawn_chances["coin"]:
		add_pickup(new_plat.global_position, Pickup.Type.COIN)
		
	elif randf_range(0, 100) <= spawn_chances["moving_platform"]:
		new_plat.anchor_point = new_plat.global_position
		new_plat.is_moving = true
		
	elif randf_range(0, 100) <= spawn_chances["multishot"]:
		add_pickup(new_plat.global_position, Pickup.Type.MULTISHOT)
		
	elif randf_range(0, 100) <= spawn_chances["skeleton"] + Globals.current_stage:
		if enemy_spawner:
			enemy_spawner.spawn_enemy(enemy_spawner.enemy_skeleton_scene, new_plat.global_position + Vector2(0, -100.0))
	
	elif randf_range(0, 100) <= spawn_chances["invulnerability"]:
		add_pickup(new_plat.global_position, Pickup.Type.INVULNERABLE)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Platform and not body in platforms and !body.is_breakable:
		platforms.append(body)
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Platform and body in platforms:
		platforms.erase(body)
	pass # Replace with function body.

func add_spring(pos):
	var new_spring = spring_scene.instantiate()
	object_root.add_child(new_spring)
	new_spring.global_position = pos + (Vector2.UP * 25)
	
func add_pickup(where, type : Pickup.Type):
	var new_pickup : Pickup
	
	if type == Pickup.Type.MULTISHOT:
		new_pickup = multishot_scene.instantiate()
	else:
		new_pickup = pickup_scene.instantiate()
	
	new_pickup.type = type
	new_pickup.update()
	
	new_pickup.top_level = true
	object_root.add_child(new_pickup)
	new_pickup.global_position =  where + (Vector2.UP * 30)
	if type == Pickup.Type.BEAR_TRAP:
		new_pickup.global_position =  where + (Vector2.UP * 25)
	
	

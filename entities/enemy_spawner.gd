extends Node2D
class_name EnemySpawner

var enemy_eye_scene := preload("res://entities/flying_eye.tscn")
var enemy_skeleton_scene := preload("res://entities/skeleton.tscn")
@onready var allowed_area := $AllowedArea
@onready var spawn_area := $SpawnArea
@onready var spawn_area_shape := $SpawnArea/SpawnAreaShape
@onready var allowed_area_shape : CollisionShape2D = $AllowedArea/AllowedAreaShape
@onready var enemy_root := $EnemyRoot
@onready var reward_spawner := $RewardSpawner
var spawn_interval := 15.0
var spawn_offset := 5.0
var time_to_spawn := 5.0

var dif_spawn_times := {
	Globals.Difficulty.BREEZE : 20.0,  
	Globals.Difficulty.EASY : 16.0,    
	Globals.Difficulty.NORMAL : 14.0, 
	Globals.Difficulty.HARD : 12.0,    
	Globals.Difficulty.HARDEST: 10.0,
	Globals.Difficulty.IMPOSSIBLE: 8.0
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spawn_interval = dif_spawn_times[Globals.current_difficulty]
	if time_to_spawn <= 0.0:
		spawn_enemy(enemy_eye_scene)
		time_to_spawn = (spawn_interval + randf_range(-spawn_offset, spawn_offset))
	else:
		time_to_spawn = move_toward(time_to_spawn, 0.0, delta)	
	pass

func spawn_enemy(scene : PackedScene, position_override := Vector2.INF):
	var new_enemy : Enemy = scene.instantiate()
	new_enemy.nav_area_shape = allowed_area_shape
	enemy_root.add_child(new_enemy)
	new_enemy.global_position = get_random_point(spawn_area_shape)
	
	new_enemy.spawn_reward.connect(reward_spawner.spawn_reward)
	
	if position_override != Vector2.INF:
		new_enemy.global_position = position_override

func get_random_point(shape : CollisionShape2D) -> Vector2:
	var point := Vector2(0, 0)
	var extents : Rect2 = shape.shape.get_rect()
	
	var random_x = randf_range(0, extents.size.x)
	var random_y = randf_range(0, extents.size.y)
	
	point = shape.to_global(Vector2(random_x, random_y))
	return point

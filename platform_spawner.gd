extends Node2D

@onready var spawn_area_shape : CollisionShape2D = $Area2D/spawn_area
var platform_scene = preload("res://platform.tscn")
@onready var platform_root = $PlatformRoot
var max_player_reach_x = 500
var vertical_spacing = 0.0
var last_spawn_y = 640
var target_platforms = 0

func _ready() -> void:
	last_spawn_y = spawn_area_shape.global_position.y + spawn_area_shape.shape.get_rect().size.y/2
	
var platforms : Array[Platform] = []	

func _physics_process(delta: float) -> void:
	target_platforms = Globals.diff_target_plat[Globals.current_difficulty]
	if platforms.size() < target_platforms and platform_root.get_child_count() < target_platforms*3:
		spawn_platform()


func spawn_platform():
	
	# get vertical spacing between platforms
	vertical_spacing = spawn_area_shape.shape.get_rect().size.y / Globals.diff_target_plat[Globals.current_difficulty]
	
	var new_plat : Platform = platform_scene.instantiate()
	platform_root.add_child(new_plat)
	var halfx = spawn_area_shape.shape.get_rect().size.x/2
	var halfy = spawn_area_shape.shape.get_rect().size.y/2
	var x = randi_range(-halfx, halfx)
	var y = (last_spawn_y - vertical_spacing) - randf_range(-20.0, 20.0)
	new_plat.top_level = true
	new_plat.global_position = Vector2(spawn_area_shape.global_position.x + x, y)
	last_spawn_y = new_plat.global_position.y 


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Platform and not body in platforms:
		platforms.append(body)
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Platform and body in platforms:
		platforms.erase(body)
	pass # Replace with function body.

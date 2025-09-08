extends Area2D
class_name EnemyDetector

var closest_target : Node2D = null 
@onready var crosshair = $TargetCrosshair
@onready var arrow = $Arrow

var crosshair_speed = 1200.0
var crosshair_rot_speed = 1.0
var targets : Array = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	for target in targets:
		if !is_instance_valid(closest_target) or\
		self.global_position.distance_to(target.global_position) < \
		self.global_position.distance_to(closest_target.global_position):
			closest_target = target
	
	if is_instance_valid(crosshair) and is_instance_valid(closest_target):
		
		crosshair.show()
		crosshair.rotation += (crosshair_rot_speed * delta)
		if crosshair.global_position.distance_to(closest_target.global_position) > 2.0:
			crosshair.global_position = crosshair.global_position.move_toward(\
			closest_target.global_position, crosshair_speed * delta)
		
		if is_instance_valid(arrow):
			arrow.show()
			arrow.look_at(closest_target.global_position)
			arrow.rotation_degrees += 90
			
			
	else: 
		arrow.hide()
		crosshair.hide()
		crosshair.position = Vector2(0, 0)
		
func _on_body_entered(body: Node2D) -> void:
	if not body in targets:
		if !is_instance_valid(closest_target):
			closest_target = body
		targets.append(body)


func _on_body_exited(body: Node2D) -> void:
	if body in targets:
		targets.erase(body)
		if body == closest_target:
			closest_target = null

extends Node2D
class_name RewardCoin
## coin that chases its target and dissapears when close
	
var target : Node2D = null	
var speed = 900.0
var distance_threshold := 10.0
var spawn_spread = 20.0
var spread_radius := 40.0

var pre_target : Vector2
var reached_pre := false
var active := false

func _setup(coin_target : Node2D, pre : Vector2 = Vector2.INF, speed_override = null):
	self.target = coin_target
	if speed_override:
		self.speed = speed_override
	if not pre == Vector2.INF:
		pre_target = pre
	else:
		var angle = (randf()*2*PI)
		var off_x = (sin(angle)*spread_radius) + randi_range(-spawn_spread, spawn_spread)
		var off_y = (cos(angle)*spread_radius) + randi_range(-spawn_spread, spawn_spread)
		pre_target = self.global_position + Vector2(off_x, off_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		if not reached_pre and pre_target != Vector2.INF:
			self.global_position = lerp(self.global_position, pre_target, delta)
			self.look_at(pre_target)
		
		if self.global_position.distance_to(pre_target) < distance_threshold and not reached_pre:
			reached_pre = true
		
		if not reached_pre: return
			
		if not target:
			self.queue_free()
			return
			
		self.global_position = self.global_position.move_toward(target.global_position, delta * speed)
		self.look_at(target.global_position)
		if self.global_position.distance_to(target.global_position) < distance_threshold: 
			if target.has_method("add_coins"):
				target.add_coins(1)
			SoundManager.playSFXAtPosition("res://sounds/coin_pickup.wav", self.global_position, -9.0)
			self.queue_free()

func go():
	if active:
		return
	self.active = true

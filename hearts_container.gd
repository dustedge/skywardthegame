extends HBoxContainer

var bpm = SoundManager.current_bpm

@onready var hearts = [$heart1, $heart2, $heart3, $heart4, 
$heart5, $heart6, $heart7, $heart8, $heart9, $heart10]

var bounce_scale := 3.0
var default_scale := 2.0
var current_scale := default_scale

func _ready() -> void:
	SoundManager.connect("music_beat_occured", beat)
	pass

func _process(delta: float) -> void:
	if current_scale > default_scale:
		current_scale -= (delta*2)
	elif current_scale < default_scale:
		current_scale = default_scale
	
	for child in self.get_children():
		child.set_deferred("scale", Vector2(current_scale, current_scale))
	pass
	#if bpm != 0

func beat():
	current_scale = bounce_scale

func update_health(health, max_health):
	var mx = max_health
	for heart : Sprite2D in hearts:
		if mx >= 2:
			mx -= 2
			heart.show()
		elif mx >= 1:
			mx -= 1
			heart.show()
		else:
			heart.hide()
	
	
	for heart : Sprite2D in hearts:
		if health >= 2:
			heart.frame = 0
			health -= 2
			continue
		elif health >= 1:
			heart.frame = 1
			health -= 1
		else:
			heart.frame = 2

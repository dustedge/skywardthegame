extends HBoxContainer

var bpm = SoundManager.current_bpm

@onready var hearts = [$heart1, $heart2, $heart3]

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

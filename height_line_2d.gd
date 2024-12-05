extends Line2D

@onready var label = $HeightLineLabel

func _process(delta: float) -> void:
	if self.position.y != get_parent().cam_height:
		self.position.y = get_parent().cam_height
		label.text = str(get_parent().player_score).pad_zeros(7)
	pass

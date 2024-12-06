extends CanvasLayer
class_name UI

@onready var stage_label : Label = $StageLabel
@onready var stage_label_player : AnimationPlayer = $StageLabel/AnimationPlayer

func display_stage_text(stage):
	var stage_str := ""
	match stage:
		0:
			stage_str = "Layer Zero\n~ Underground Shelter ~"
		1:
			stage_str = "Layer One\n~ Climb of Titans ~"
		2:
			stage_str = "Layer Two\n~ The Redwood Forest ~"
		3:
			stage_str = "Layer Three\n~ The Tower of Babel ~"
		4:
			stage_str = "Layer Four\n~ The Lower Skies ~"
		5:
			stage_str = "Layer Five\n~ Sunset ~"
		6:
			stage_str = "Layer Six\n~ Full Moon ~"
		7:
			stage_str = "Layer Seven\n~ The Gates of Heaven ~"
		_:
			stage_str = "Layer ???\n~ ??? ~"
	stage_label.text = stage_str
	stage_label_player.play("show_stage")
	

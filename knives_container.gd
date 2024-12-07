extends HBoxContainer

@onready var knife_template = $knife_template

func set_knives_amount(amount : int):
		
	for child in get_children():
		if child.name.ends_with("template"):
			continue
		else:
			child.name = child.name + "_removed" 
			child.queue_free()
	
	for i in range(amount):
		var new_knife = knife_template.duplicate()
		new_knife.show()
		self.add_child(new_knife)

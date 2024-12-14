extends Control

@onready var upgrade_buttons : GridContainer = $CenterContainer/BoxContainer/UpgradeButtons
@onready var upgrade_button_template : Button = $CenterContainer/BoxContainer/UpgradeButtons/UpgradeButton_TEMPLATE
@onready var player_coins_label : Label = $CenterContainer/BoxContainer/PlayerCoinsContainer/PlayerCoinsLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refill_grid()

func refill_grid():
	#clean up
	for child in upgrade_buttons.get_children():
		if not child.name.ends_with("TEMPLATE"):
			child.name = child.name + "_removed"
			child.queue_free()
	
	# fill grid with available upgrades
	for upgrade : Upgrade in Upgrade.get_all_upgrades():
		add_upgrade_button(upgrade)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if is_instance_valid(player_coins_label):
		if not player_coins_label.text == str(Globals.player_coins):
			player_coins_label.text = str(Globals.player_coins)
	pass

func add_upgrade_button(upgrade : Upgrade):
	var new_button : Button = upgrade_button_template.duplicate()
	
	# check if player owns and update accordingly
	if Globals.current_player_upgrades.has(upgrade.type):
		var upinfo = Globals.current_player_upgrades[upgrade.type]
		upgrade.price = upgrade.price + (upinfo["level"] * upgrade.level_price_increase)
		upgrade.level = upinfo["level"]
	
	new_button.icon = upgrade.icon
	new_button.name = str(upgrade.type)
	new_button.get_node("Container/PriceLabel").text = str(upgrade.price)
	new_button.get_node("Container/LevelLabel").text = "{0}/{1}".format([upgrade.level, upgrade.max_level])
	upgrade_buttons.add_child(new_button)
	new_button.show()
	
	new_button.connect("pressed", buy_upgrade.bind(upgrade.type, upgrade.level + 1, upgrade.price))
	
	return new_button


func buy_upgrade(type : Upgrade.UpgradeType, level : int, price : int) -> bool:
	
	SoundManager.playSFX("res://sounds/button_click.wav", false)
	
	if level > Upgrade.get_upgrade(type).max_level:
		return false
	
	if Globals.player_coins < price:
		return false
		
	Globals.player_coins -= price
	
	if not type in Globals.current_player_upgrades.keys():
		Globals.current_player_upgrades[type] = {}
	
	Globals.current_player_upgrades[type]["level"] = level
	print(Globals.current_player_upgrades)
	Globals.save_game()
	refill_grid()
	SoundManager.playSFX("res://sounds/coin_pickup.wav")
	return true

func _on_play_button_pressed() -> void:
	SoundManager.playSFX("res://sounds/button_click.wav", false)
	get_tree().change_scene_to_file("res://world.tscn")
	pass # Replace with function body.


func _on_main_menu_button_pressed() -> void:
	SoundManager.playSFX("res://sounds/button_click.wav", false)
	get_tree().change_scene_to_file("res://main_menu.tscn")
	pass # Replace with function body.

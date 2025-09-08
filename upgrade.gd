extends Object
class_name Upgrade

enum UpgradeType {
	MAX_HEALTH,
	MAX_AMMO,
	RELOAD_TIME,
	AIR_CONTROL,
	JUMP_HEIGHT,
	COIN_CHANCE,
	FEATHER_CHANCE,
	HEAL_CHANCE,
	SHIELD_CHANCE,
	MULTISHOT_CHANCE
}

var type : UpgradeType
var icon: Texture2D
var level : int = 0
var max_level : int = 3
var price : int = 0
var level_price_increase : int = 0

func increase_level() -> bool:
	if self.level >= max_level: return false
	self.level = min(self.level+1, self.max_level)
	self.price += level_price_increase
	return true
	
static func get_upgrade(type : UpgradeType) -> Upgrade:
	
	var upgrade = Upgrade.new()
	upgrade.type = type
	
	match type:
		UpgradeType.MAX_HEALTH:
			upgrade.price = 500
			upgrade.max_level = 3
			upgrade.icon = preload("res://sprites/icons/icon_1.png")

		UpgradeType.MAX_AMMO:
			upgrade.price = 500
			upgrade.max_level = 3
			upgrade.icon = preload("res://sprites/icons/icon_3.png")

		UpgradeType.RELOAD_TIME:
			upgrade.price = 350
			upgrade.max_level = 5
			upgrade.icon = preload("res://sprites/icons/icon_4.png")

		UpgradeType.AIR_CONTROL:
			upgrade.price = 150
			upgrade.max_level = 10
			upgrade.icon = preload("res://sprites/icons/icon_6.png")

		UpgradeType.JUMP_HEIGHT:
			upgrade.price = 200
			upgrade.max_level = 9
			upgrade.icon = preload("res://sprites/icons/icon_2.png")
			
		UpgradeType.COIN_CHANCE:
			upgrade.price = 190
			upgrade.max_level = 9
			upgrade.icon = preload("res://sprites/icons/icon_8.png")
		
		UpgradeType.FEATHER_CHANCE:
			upgrade.price = 170
			upgrade.max_level = 9
			upgrade.icon = preload("res://sprites/icons/icon_9.png")
		
		UpgradeType.HEAL_CHANCE:
			upgrade.price = 250
			upgrade.max_level = 9
			upgrade.icon = preload("res://sprites/icons/icon_10.png")
		
		UpgradeType.SHIELD_CHANCE:
			upgrade.price = 140
			upgrade.max_level = 5
			upgrade.icon = preload("res://sprites/icons/icon_11.png")
		
		UpgradeType.MULTISHOT_CHANCE:
			upgrade.price = 210
			upgrade.max_level = 5
			upgrade.icon = preload("res://sprites/icons/icon_12.png")

	upgrade.price = upgrade.price 
		
	upgrade.level_price_increase = upgrade.price
	return upgrade

static func get_all_upgrades() -> Array[Upgrade]:
	var arr : Array[Upgrade] = []
	for key in UpgradeType.values():
		arr.append(get_upgrade(key))
	return arr
		

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
	HEAL_CHANCE
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
			upgrade.price = 1000
			upgrade.max_level = 8
			upgrade.icon = preload("res://sprites/icons/icon_1.png")

		UpgradeType.MAX_AMMO:
			upgrade.price = 1000
			upgrade.max_level = 3
			upgrade.icon = preload("res://sprites/icons/icon_3.png")

		UpgradeType.RELOAD_TIME:
			upgrade.price = 650
			upgrade.max_level = 4
			upgrade.icon = preload("res://sprites/icons/icon_4.png")

		UpgradeType.AIR_CONTROL:
			upgrade.price = 800
			upgrade.max_level = 10
			upgrade.icon = preload("res://sprites/icons/icon_6.png")

		UpgradeType.JUMP_HEIGHT:
			upgrade.price = 600
			upgrade.max_level = 9
			upgrade.icon = preload("res://sprites/icons/icon_2.png")
			
		UpgradeType.COIN_CHANCE:
			upgrade.price = 450
			upgrade.max_level = 9
			upgrade.icon = preload("res://sprites/icons/icon_8.png")
		
		UpgradeType.FEATHER_CHANCE:
			upgrade.price = 300
			upgrade.max_level = 9
			upgrade.icon = preload("res://sprites/icons/icon_9.png")
		
		UpgradeType.HEAL_CHANCE:
			upgrade.price = 300
			upgrade.max_level = 9
			upgrade.icon = preload("res://sprites/icons/icon_10.png")

	# for testing, remove later
	upgrade.price = int(upgrade.price / 10) 
		
	upgrade.level_price_increase = upgrade.price
	return upgrade

static func get_all_upgrades() -> Array[Upgrade]:
	var arr : Array[Upgrade] = []
	for key in UpgradeType.values():
		arr.append(get_upgrade(key))
	return arr
		

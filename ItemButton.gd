extends Button

export var price := 0
export var description := ""
export var item_name := ""

onready var popup = $"/root/MainMenu/PopUp"


func _ready():
	# Check if save game has items
	if Data.items.has(item_name):
		if Data.items[item_name] == true:
			# disabled button if player already bought the item
			$".".disabled = true
	else:
		Data.items[item_name] = false

	# Data.items[item_name] = true

	$".".text = "$%s"%price


func _on_ItemButton_pressed():
	# show description
	if item_name == "bazooka":
		for item in Data.items.keys():
			if item != "bazooka":
				if Data.items[item] == false:
					popup.popup(description, price, $".", item_name)
					return
		popup.popup(description, 0, $".", item_name)
		print(Data.items.keys())
	else:
		popup.popup(description, price, $".", item_name)

extends Control


var item_button = null
var description := ""
var price := 0
var item_name := ""

onready var SCORE_DOWN = load("res://ScoreDown.tscn")


func _ready():
	self.visible = false


func popup(_des: String, _price: int, _item_button: Object, _item_name: String):
	# Not enough cash! Stranger...
	if _price > Data.money:
		$BuyButton.disabled = true
	else:
		$BuyButton.disabled = false

	$Label.text = _des
	price = _price
	item_button = _item_button
	item_name = _item_name
	$".".visible = true


func spawn_score_down(_amount: String):
	var score_down = SCORE_DOWN.instance()
	score_down.set_score(_amount)
	score_down.position += Vector2(0, 100)
	$"../HBoxContainer/VBoxContainer2/MoneyLabel".add_child(score_down)


func _on_BuyButton_pressed():
	# update money and item
	Data.money -= price
	Data.prevent_cheat_money -= price
	Data.items[item_name] = true
	$"..".update_money()
	item_button.disabled = true
	$".".visible = false
	Data.save_game()
	print("=====item_name: %s======="%item_name)
	
	spawn_score_down(str(price))
	$AnimationPlayer.play("buy")

	# Change bazooka price to 0 if all items has been bought
	for item in Data.items.keys():
		if item != "bazooka":
			if Data.items[item] == false:
				return
	$"../HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/ItemButton6".text = "$0"
	

func _on_NoButton_pressed():
	price = 0
	description = ""
	$".".visible = false
	$AnimationPlayer.play("cancel")

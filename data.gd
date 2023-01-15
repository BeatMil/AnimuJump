extends Node


var money := 0
var prevent_cheat_money := 0
var current_skin := "default"
var is_bazooka = false
var can_skip_boss_gura_cutscene = true # default: false
var pass_tutorial = false
var gurara_fight_ded_count = 0
var flash_customize_button = false

const save_path = "user://savegame.save"

# inventory data
var items = {"default": true}


func _ready():
	load_game()
	CheatTimer.connect("timeout", self, "cheattimer_timout")


func _input(event):
	if event.is_action_pressed("fullscreen_toggle"):
		OS.window_fullscreen = not OS.is_window_fullscreen()


func save():
	var save_dict = {
		"money": money,
		"prevent_cheat_money": prevent_cheat_money,
		"items": items
	}
	return save_dict


func save_game():
	var save_game = File.new()
	save_game.open(save_path, File.WRITE)
	save_game.store_line(to_json(save()))
	save_game.close()


func load_game():
	var save_game = File.new()

	# check if file exists
	if not save_game.file_exists(save_path):
		print("save file not found")
		return

	print("=========LOADGAME=========")
	save_game.open(save_path, File.READ)
	while save_game.get_position() < save_game.get_len():
		var data = parse_json(save_game.get_line())
		print("data: %s"%data)
		prevent_cheat_money = data["prevent_cheat_money"]
		money = data["money"]
		items = data["items"]

	save_game.close()

	print("load game\nprevent: %s\nmoney: %s"%[prevent_cheat_money, money])
	print("=========LOADGAME=========")

	# parry negative money
	if money < 0:
		money = 0


func add_to_money(_value: int) -> void:
	money += _value
	prevent_cheat_money += _value


func cheattimer_timout():
	if money != prevent_cheat_money:
		get_tree().change_scene("res://catchCheater.tscn")


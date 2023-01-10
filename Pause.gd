extends Control


# export var is_pause := false
onready var player = $"../../Player"


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") and not player.is_ded:
		toggle_run_pause()


func show_menu(): # Used in AnimationPlayer then in works ...??
	$VBoxContainer/ResumeButton.grab_focus()


func toggle_run_pause():
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		$AnimationPlayer.play("pause")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		$AnimationPlayer.play("unpause")
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_ResumeButton_pressed():
	toggle_run_pause()


func _on_RestartButton_pressed():
	restart()


func restart():
	toggle_run_pause()

	# save money
	Data.money += $"../../Score".score
	Data.prevent_cheat_money += $"../../Score".score
	Data.save_game()

	var _ok = get_tree().change_scene("res://Stage01.tscn")


func _on_MenuButton_pressed():
	toggle_run_pause()

	# save money
	Data.money += $"../../Score".score
	Data.prevent_cheat_money += $"../../Score".score
	Data.save_game()

	var _ok = get_tree().change_scene("res://MainMenu.tscn")

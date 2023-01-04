extends Control


func _on_RestartButton_pressed():
	var _ok = get_tree().change_scene("res://Stage01.tscn")


func _on_MenuButton_pressed():
	var _ok = get_tree().change_scene("res://MainMenu.tscn")


func show_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer3/RestartButton.grab_focus()

extends Control


func _ready():
	# display mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	$HBoxContainer/VBoxContainer/MarginContainer/Button.grab_focus()
	$AnimationPlayer.play("start")
	$Background3/AnimationPlayer.play("moving_background")
	$SongPlayer.play("menu_song_better")
	$KaisoukoLook/AnimationPlayer.play("main_start")
	$KaisoukoLook/AnimationPlayer.queue("main_idle")

	update_money()


func update_money():
	$HBoxContainer/VBoxContainer2/MoneyLabel.text = "$%s"%Data.money


func _on_Button_pressed():
	var _ok = get_tree().change_scene("res://Stage01.tscn")


func _on_ItemButton_pressed():
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	$HBoxContainer/VBoxContainer2/MoneyLabel/AnimationPlayer.play("shining")
	$Banner/AnimationPlayer.play("start")

extends Control


func _ready():
	self.visible = false


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_visible()


func choose_skin(_skin: Object) -> void:
	for child in $VBoxContainer.get_children():
		if _skin.name == child.name:
			_skin.pressed = true
		else:
			_skin.pressed = false


func arrow_point_to_current_skin(_current_skin: String) -> void:
	for child in $VBoxContainer2/Arrow.get_children():
		if _current_skin == child.name:
			child.modulate = Color(0.4, 1, 0.2)
		else:
			child.modulate = Color(0, 0, 0, 0)


func check_purchased_skin_all() -> void:
	# run check_purchased_skin for all skins (button)
	for child in $VBoxContainer2/VBoxContainer.get_children():
		child.check_purchased_skin()


func toggle_visible() -> void:
	self.visible = not self.visible
	if Data.is_bazooka == true:
		$BazookaButton.pressed = true
	else:
		$BazookaButton.pressed = false
	if self.visible == true:
		$AnimationPlayer.play("open")
	else:
		$AnimationPlayer.play("close")

	if Data.items.has("bazooka"):
		if Data.items["bazooka"] == true:
			$BazookaButton.disabled = false
			$BazookaButton.modulate = Color(1, 1, 1, 1)
			if self.visible:
				$BazookaButton/AnimationPlayer.play("bazooka_shine")
				if $BazookaButton.pressed:
					$BazookaButton/AnimationPlayer.play("bazooka_on")
		else:
			$BazookaButton.disabled = true
			$BazookaButton.modulate = Color(0.203922, 0.203922, 0.203922, 0.890196)
	check_purchased_skin_all()
	arrow_point_to_current_skin(Data.current_skin)


func _on_Button_pressed():
	toggle_visible()


func _on_TouchScreenButton_pressed():
	toggle_visible()


func _on_ToggleVisibilityButton_pressed():
	toggle_visible()


func _on_BazookaButton_toggled(button_pressed):
	if button_pressed:
		Data.is_bazooka = true
		$BazookaButton/AnimationPlayer.play("bazooka_on")
		$AnimationPlayer.play("bazooka_on")
	else:
		Data.is_bazooka = false
		$BazookaButton/AnimationPlayer.play("bazooka_off")
		# $AnimationPlayer.play("bazooka_off")


func _on_TextureButton_pressed():
	toggle_visible()

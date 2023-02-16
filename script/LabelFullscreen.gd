extends Label


func _input(event):
	if event.is_action_pressed("fullscreen_toggle"):
		queue_free()

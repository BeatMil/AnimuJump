extends TextureProgress


export var is_active = false
export var mash_power = 500
onready var player = $"../Player"


func decrease(amount):
	value -= amount


func increase(amount):
	value += amount


func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		if player.is_mario_star:
			increase(mash_power)
			play2("increase_sound")


func play(anim_name):
	$AnimationPlayer.stop()
	$AnimationPlayer.play(anim_name)


func play2(anim_name):
	$AnimationPlayer2.stop()
	$AnimationPlayer2.play(anim_name)


func _on_Mashbar_value_changed(value):
	if is_active:
		if value <= 0:
			player.stop_mario_star()
			player.is_delay_spawn = true
			play("finish")
			$Timer.start()
		else:
			play("hit")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "start":
		is_active = true
	elif anim_name == "finish":
		is_active = false


func _on_Timer_timeout():
	player.is_delay_spawn = false

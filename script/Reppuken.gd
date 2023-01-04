extends RigidBody2D


# Signal
signal finish


func _ready():
	reppuken(Vector2(-3000, 0))
	$AnimationPlayer.play("reppuken")


func reppuken(force: Vector2) -> void:
	apply_central_impulse(force)


func turn_hit_boss_collision():
	# collision_layer = 0b00000000001000000000
	collision_mask = 0b00000000101000000000


func turn_off_collision_for_real_XD(): # wtf is this function name!!
	# collision_layer = 0b00000000000000000000
	collision_mask = 0b00000000000000000000


func _on_Reppuken_body_entered(body):
	if body.is_in_group("parry"):
		# apply_central_impulse(Vector2(3000, 200))
		apply_impulse(Vector2.ZERO, -(Vector2(-3000, 200) * 0.5))
		$"/root/Stage01/Camera2D".play("shake")
		turn_off_collision_for_real_XD()
		$AnimationPlayer.play("stagger")
		body.get_parent().play("parry_big_laser_red")
		$DelayDedTimer.start()
	elif body.is_in_group("Player"):
		# push self and player for dramatic impact)
		apply_impulse(Vector2.ZERO, -(Vector2(-3000, 200) * 0.5))
		apply_torque_impulse(100000)
		$AnimationPlayer.play("stagger")
		body.push(-1000, 200)
		$"/root/Stage01/Camera2D".play("shake")
		$DelayDedTimer.start()


func _on_DelayDedTimer_timeout():
	emit_signal("finish")
	queue_free()

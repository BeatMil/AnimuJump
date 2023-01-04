extends RigidBody2D


export var speed = 10
export var normal_speed = 1000
export var super_speed = 3000
export var impulse_power = 10000
export var torque_power = 100000
export var is_sliding = true
export var attack_power = 80
export var is_jumping = false
# export var count = 0

var bounce_helper = false
const EXPLODE_PARTICLE = preload("res://explodeParticle2.tscn")


signal ded


func _ready():
	# mode = MODE_CHARACTER
	$Barrier.visible = false
	if speed == super_speed:
		$Barrier.visible = true
		if is_jumping:
			$barrierPlayer.play("jump")
		else:
			$barrierPlayer.play("normal")


func _physics_process(_delta):
	# add_central_force(Vector2(-speed * _delta, 0))
	# apply_central_impulse(Vector2(-speed * _delta, 0))
	pass


func _integrate_forces(_state):
	if is_sliding:
		linear_velocity = Vector2(-speed, linear_velocity.y)


func respawn():
	applied_force = Vector2.ZERO
	applied_torque = 0
	rotation_degrees = 0
	is_sliding = true
	set_deferred("mode", MODE_CHARACTER)
	# if count%3 == 0:
	# 	speed = super_speed
	# 	# $Sprite.modulate = Color(1, 0.96, 0.04)
	# 	$AnimationPlayer.play("charge")
	# else:
	# 	speed = normal_speed
	# 	# $Sprite.modulate = Color(1, 1, 1)
	# 	$AnimationPlayer.play("normal")
	global_position = $"/root/Stage01/SpawnPosition".global_position
	# count += 1


func _on_Sago_body_entered(body):
	if body.is_in_group("Player"):
		set_deferred("mode", MODE_RIGID)
		is_sliding = false
		turn_off_collision()

		if ($RayCast2DL.is_colliding() or $RayCast2DR.is_colliding()) \
			and not body.is_mario_star and body.linear_velocity.y > 0:
			if speed == super_speed:
				body.mario_star()
				$"..".spawn_sago_mob()

			apply_central_impulse(Vector2(1000, 0))
			$"../Score".increase_score(10)
			playSfx("coin")

		elif body.is_mario_star:
			# this part is weirdly hard to understand XD
			# I'll fix the variable name later
			linear_velocity = Vector2.ZERO

			var how_high = $"..".sago_bounce_helper()
			if how_high:
				apply_central_impulse(Vector2(impulse_power, -2000))
			else:
				apply_central_impulse(Vector2(impulse_power, -1000))

			body.play2("tank") # body is in static mode which means it cannot detect collision
			$"../Mashbar".decrease(attack_power)
			$"../Score".increase_score(10)

		else:
			# linear_velocity = Vector2.ZERO
			apply_central_impulse(Vector2(impulse_power, -1000))
			if speed == super_speed:
				$"../Camera2D/AnimationPlayer2".stop()
				$"../Camera2D/AnimationPlayer2".play("big_hit")


		$"../Camera2D/AnimationPlayer".stop()
		$"../Camera2D/AnimationPlayer".play("shake")
		# $"../Camera2D".shake()
		$AnimationPlayer.play("crash")
		$SpinnyTiimer.start()


func _on_SpinnyTiimer_timeout():
	if is_jumping:
		apply_torque_impulse(-torque_power * 2)
	else:
		apply_torque_impulse(torque_power)


func _on_VisibilityNotifier2D_screen_exited():
	emit_signal("ded")
	ded()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "crash" or anim_name == "explode":
		ded()


func turn_off_collision():
	collision_layer = 0b00000000000000000000
	collision_mask = 0b00000000000000000000


func turn_on_collision():
	collision_layer = 0b00000000000000000001
	collision_mask = 0b00000000000000000001


func play(_anim):
	$AnimationPlayer.play(_anim)
	

func playSfx(_anim):
	$SfxPlayer.play(_anim)


func playSfx2(_anim):
	$SfxPlayer2.play(_anim)


func changeSprite(_anim):
	$SpritePlayer.play(_anim)


func ded():
	queue_free()


func jump():
	if speed == super_speed:
		apply_central_impulse(Vector2(0, -1200))
	elif speed == normal_speed:
		apply_central_impulse(Vector2(0, -1000))
		speed = 1800


func explode_mid_air():
	var explode_particle = EXPLODE_PARTICLE.instance()
	explode_particle.global_position = $".".global_position
	$"..".add_child(explode_particle)
	is_sliding = false
	set_deferred("mode", MODE_RIGID)
	turn_off_collision()
	linear_velocity = Vector2.ZERO
	apply_central_impulse(Vector2(500, -1000))
	$SpinnyTiimer.start()
	# apply_torque_impulse(torque_power)

	$"../Camera2D/AnimationPlayer".stop()
	$"../Camera2D/AnimationPlayer".play("shake")
	$"../Score".increase_score(50)


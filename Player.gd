extends RigidBody2D


var jump_power = 1400
var is_on_ground = false
var is_mario_star = false
var is_delay_spawn = false # prevent spawn sago after fail mario star
var can_auto_walk = true
var can_jump = true
onready var auto_walk_wait_time = $AutoWalkTimer.wait_time

var release_space = false
const JUMP_PARTICLE = preload("res://JumpParticle.tscn")
const JUMP2_PARTICLE = preload("res://jump2Particle.tscn")
const HADOKEN_PARTICLE = preload("res://hadokenParticle.tscn")
const DED_PARTICLE = preload("res://explodeParticle5.tscn")
const TRI_ATTACK = preload("res://enemy/boss_gura_attack/triangle_attack.tscn")

var is_ded = false

# gurara fight
var is_skip_cutscene = false
var is_gurara_fight = false
var is_smashing_meteo = false
var is_blocking = false
var is_parrying = false
var is_dodging = false # prevent blocking while dodging
var is_victorious = false # stop player actions
var dynamic_difficulty_adjustment = false # change parry to 10f instead of 6


func _ready():
	# display skin
	$SkinPlayer.play(Data.current_skin)

	$AutoWalkBar.visible = false
	$AutoWalkBar.max_value = auto_walk_wait_time
	$SpritePlayer.queue("normal")
	if Data.is_bazooka:
		self.mass = 2
		can_jump = false
		$CollisionPlayer.play("boss_gura_fight")
		$AnimationPlayer.play("boss_gura_intro")
		if Data.gurara_fight_ded_count > 10:
			dynamic_difficulty_adjustment = true
	else:
		can_jump = true
		position += Vector2(0, -1000)
		apply_central_impulse(Vector2(0, 1000))


func _process(_delta):
	# AutoWolkBar always update according to AutoWalkTimer
	$AutoWalkBar.value =  auto_walk_wait_time - $AutoWalkTimer.time_left

	if Input.is_action_just_pressed("ui_accept") and not can_jump and not is_ded:
		if $AnimationPlayer.is_playing(): # skip boss_gura_intro cutscene
			if $AnimationPlayer.current_animation == "boss_gura_intro":
				if Data.can_skip_boss_gura_cutscene:
					if $AnimationPlayer.current_animation_position < 3:
						$AnimationPlayer.seek(7.5)
						is_skip_cutscene = true
						$"..".spawn_boss_gura()
		if is_gurara_fight and not is_blocking and not is_dodging and not is_smashing_meteo:
			is_blocking = true
			is_parrying = true
			$DodgeArea2D.monitoring = false
			turn_on_parry_collision()
			turn_off_player_collision()
			if dynamic_difficulty_adjustment == true:
				$SpritePlayer.play("block_10f")
			else:
				$SpritePlayer.play("block")
		elif is_smashing_meteo and not is_victorious:
			play("smash_meteo")


func _physics_process(_delta):
	pass


func _integrate_forces(_state):
	if is_ded:
		# Player is ded
		# Remove all control
		return

	if Input.is_action_just_pressed("ui_accept") and can_jump:
		if is_on_ground:
			jump()

	if Input.is_action_just_released("ui_accept"):
		# if not is_on_ground:
		# not checking is_on_ground to prevent just frame jump
		if not release_space:
			release_space = true
			apply_central_impulse(Vector2(0, jump_power))
			# applied_force = Vector2.ZERO
	
	if is_mario_star and is_on_ground:
		linear_velocity = Vector2(0, linear_velocity.y)
		set_deferred("mode", MODE_STATIC)

	if is_mario_star and not is_on_ground:
		linear_velocity = Vector2(0, linear_velocity.y)

	# Auto walk to default position
	if linear_velocity.x == 0:
		if is_behind_default_pos():
			apply_central_impulse(Vector2(100, 0))
			# if can_auto_walk:
			# 	$AutoWalkBar.visible = true
			# 	can_auto_walk = false
			# 	$AutoWalkTimer.start()


func is_behind_default_pos() -> bool:
	return $".".global_position.x < $"../PlayerDefaultPos".global_position.x


func toggle_smashing_meteo():
	is_smashing_meteo = not is_smashing_meteo
	turn_off_parry_collision()
	turn_off_dodge_detection()


func set_parry(_bool: bool) -> void:
	is_parrying = _bool
	if _bool == false:
		# Tri_attack hits player; result in block
		# Tri_attack hits Parry; result in parry
		# Tri_attack can hit both player and parry, so turn off player when parry
		turn_off_parry_collision()
		turn_on_player_collision()


func _on_Player_body_entered(body):
	if body.is_in_group("Ground"):
		is_on_ground = true
	elif body.is_in_group("tri_attack"):
		pass
		# $"%Camera2D".play2("big_hit")
	# elif body.is_in_group("big_laser_blue"):
	# 	$SpritePlayer.play("hurt")
	# 	body.play("parried")



	if body.is_in_group("Sago"):
		if is_mario_star:
			pass
		else:
			if linear_velocity.y > 0:
				pass
			else:
				$AnimationPlayer.stop()
				$AnimationPlayer.play("crash")


func _on_Player_body_exited(body):
	if body.is_in_group("Ground"):
		is_on_ground = false


func _on_VisibilityNotifier2D_screen_exited():
#	ded()
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "boss_gura_intro":
		is_gurara_fight = true
		Data.can_skip_boss_gura_cutscene = true

	if anim_name == "star":
		stop_mario_star()
	
	if anim_name == "ded":
		is_ded = true
		turn_off_parry_collision()
		turn_off_player_collision()
		$"../TotalMoney".start_adding_money()
		# get_tree().paused = not get_tree().paused
		# var _ok = get_tree().change_scene("res://Stage01.tscn")
	
	if anim_name == "crash" or anim_name == "parry_big_laser_red":
		if can_jump:
			playSprite("normal")
		else:
			playSprite("look")


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "ded":
		# stop spawning sago immediately by is_ded at animation_started signal
		is_ded = true 
		turn_off_parry_collision()
		turn_off_player_collision()
	elif anim_name == "parry_big_laser_red":
		is_blocking = false


func sago_bounce_up():
	apply_central_impulse(Vector2(0, -1000))


func mario_star():
	$"../AnimationPlayer".stop()
	$AnimationPlayer.play("star")
	$"../Background/AnimationPlayer".play("mario_star")
	$"../Mashbar".play("start")
	$"../Spacebar".fast_boi()
	is_mario_star = true
	linear_velocity = Vector2(0, linear_velocity.y)


func stop_mario_star():
	$AnimationPlayer.play("RESET")
	$"../Background/AnimationPlayer".play("RESET")
	$"../MobTimer".stop()
	$"../Mashbar".play("finish")
	$"../Spacebar".fast_boi()
	is_mario_star = false
	set_deferred("mode", MODE_CHARACTER)


func play(anim_name):
	$AnimationPlayer.stop()
	$AnimationPlayer.play(anim_name)


func play2(anim_name):
	$AnimationPlayer2.stop()
	$AnimationPlayer2.play(anim_name)


func playSprite(anim_name):
	$SpritePlayer.stop()
	$SpritePlayer.play(anim_name)


func playSkin(anim_name):
	$SkinPlayer.stop()
	$SkinPlayer.play(anim_name)


func ded():
	$"../TotalMoney".total_money = Data.money # Fix bug where stack money scene would show double amount of money
	Data.money += $"../Score".score
	Data.prevent_cheat_money += $"../Score".score
	Data.save_game()
	Data.gurara_fight_ded_count += 1
	play("ded")
	$"../Explosion/Explosion/AnimationPlayer".play("dim")
	$"../TotalMoney/Label/AnimationPlayer".play("start")
	

func set_mode_to_static():
	set_deferred("mode", MODE_STATIC)


func set_mode_to_character():
	set_deferred("mode", MODE_CHARACTER)


func _on_AutoWalkTimer_timeout():
	can_auto_walk = true
	$AutoWalkBar.visible = false
	$AutoWalkTimer.stop()
	apply_central_impulse(Vector2(500, 0))


func jump():
	apply_central_impulse(Vector2(0, -jump_power))
	release_space = false
	play2("jump")
	spawn_jump_particle()


func spawn_jump_particle():
	# var jump_particle = JUMP_PARTICLE.instance()
	var jump_particle = JUMP2_PARTICLE.instance()
	jump_particle.global_position = $JumpParticlePosition2D.global_position
	$"..".add_child(jump_particle)


func spawn_hadoken_particle():
	var hadoken_particle = HADOKEN_PARTICLE.instance()
	hadoken_particle.global_position = $HadokenPosition2D.global_position
	$"..".add_child(hadoken_particle)


func spawn_ded_particle(): # Used by AnimationPlayer
	var ded_particle = DED_PARTICLE.instance()
	ded_particle.position = $"../PlayerDedPraticlePos".position
	$"..".add_child(ded_particle)


func spawn_smash_meteo(): # Used by AnimationPlayer
	var smash_meteo = TRI_ATTACK.instance()
	smash_meteo.position = $"../Player".position + Vector2(150, -150)
	smash_meteo.player_peww(Vector2(600, -600))
	$"../PlayerTriAttack".add_child(smash_meteo)


func _on_ShootArea2D_body_entered(body):
	if body.is_in_group("Sago"):
		if body.speed == body.super_speed:
			mario_star()
			$"..".spawn_sago_mob()

		body.play("explode") # call explode_mid_air from animationPlayer
		playSprite("shoot")
		$SpritePlayer.queue("normal")
		spawn_hadoken_particle()


func turn_off_parry_collision():
	$ParryBody2D.collision_layer = 0b00000000000000000000
	$ParryBody2D.collision_mask = 0b00000000000000000000


func turn_on_parry_collision():
	$ParryBody2D.collision_layer = 0b00000000000000100000
	$ParryBody2D.collision_mask = 0b00000000000000100000


func turn_off_player_collision() -> void: # player
	collision_layer = 0b00000000100000000000
	collision_mask = 0b00000000100000000000


func turn_on_player_collision() -> void: # player
	collision_layer = 0b00000000000000000001
	collision_mask = 0b00000000000000000010


func turn_off_dodge_detection() -> void:
	$DodgeArea2D.monitoring = false
	$DodgeArea2D.monitorable = false


func remove_dodge_parry_body() -> void:
	$DodgeArea2D.queue_free()
	$ParryBody2D.queue_free()


func push(power_x: int, power_y: int):
	apply_central_impulse(Vector2(power_x, power_y))
	play("crash")


# push player without crash animation
func push_without_crash(power_x: int, power_y: int):
	apply_central_impulse(Vector2(power_x, power_y))


func _on_SpritePlayer_animation_finished(anim_name):
	if anim_name == "block":
		$SpritePlayer.play("look")
	elif anim_name == "dodge":
		is_dodging = false
	elif anim_name == "look":
		is_dodging = false

	is_blocking = false
	is_parrying = false
	$DodgeArea2D.monitoring = true
	turn_off_parry_collision()
	turn_on_player_collision()


func _on_DodgeArea2D_body_entered(body):
	if body.is_in_group("tri_tank"):
		pass
	elif body.is_in_group("reppuken"):
		pass
	elif body.is_in_group("tri_attack"):
		is_dodging = true
		body.turn_off_collision_for_real_XD()
		playSprite("dodge")
		$SpritePlayer.queue("look")


func _on_DodgeArea2D_area_entered(area):
	if area.is_in_group("big_laser_blue"):
		is_dodging = true
		playSprite("dodge")
		$SpritePlayer.queue("look")
	print("===Player.gd DodgeArea2D===")
	print("area: %s"%area.name)
	print("===============")


func _on_ParryBody2D_body_entered(body):
	if body.is_in_group("tri_attack"):
		turn_off_parry_collision()
		$SpritePlayer.play("parry")
		body.play("parried")

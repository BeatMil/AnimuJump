extends RigidBody2D


# Scence
const TRI_ATTACK = preload("res://enemy/boss_gura_attack/triangle_attack.tscn")
const BIG_LASER_BLUE = preload("res://enemy/boss_gura_attack/big_laser_blue.tscn")
const BIG_LASER_RED = preload("res://enemy/boss_gura_attack/big_laser_red.tscn")
const REPPUKEN = preload("res://enemy/boss_gura_attack/Reppuken.tscn")
const METEO = preload("res://enemy/boss_gura_attack/meteo.tscn")
const EXPLODE_PARTICLE = preload("res://explodeParticle4.tscn")


# Config
export var intro_walk_speed := 2000
var is_start := false
var attack_index := 1 # default: 1
var tri_attack_force := Vector2(-2500, 800)
var tri_attack_force2 := Vector2(-2500, 300)
var tri_attack_force3 := Vector2(-2500, -100)
# used to multiply with tri_attack_force to create faster tri_attack
var tri_attack_force_amplifier := 1.5
var rng = RandomNumberGenerator.new()
var learn_big_laser := 0 # Let player learn blue laser 2 times then spawn red
var had_laugh := 0 # laugh before using big_laser then no laugh
var push_player_to_default_pos_count = 0
var tri_attack_count = 0 # do tri_attack every 3rd move


func _ready():
	if Data.pass_tutorial:
		attack_index = 8
	$FloatPlayer.play("float")
	rng.randomize()


func _integrate_forces(_state):
	if not is_start:
		linear_velocity = Vector2(-intro_walk_speed, linear_velocity.y)


# When boss_gura enterned bossStartArea2D
func start():
	is_start = true
	linear_velocity = Vector2.ZERO
	if $"../Player".is_skip_cutscene: 
		# spawn tri_attack immidately if player skip cutscene
		attack_spawner()
		# $LaserUltPlayer.play("ult_laser")
		# $AnimationPlayer.play("ult_meteo")
		# $AnimationPlayer.queue("ult_tri_attack")
		# $AnimationPlayer.queue("ult_reppuken")
		# $AnimationPlayer.queue("ult_tri_attack")
		# $AnimationPlayer.play("big_laser_blue")
	else:
		$AnimationPlayer.play("wait_2s") # wait for boss_gura_intro from Player
	set_deferred("mode", RigidBody2D.MODE_STATIC)


# Used in AnimationPlayer
func tri_attack_AnimationPlayer_helper_normal():
	spawn_tri_attack()


# Used in AnimationPlayer
func tri_attack_AnimationPlayer_helper_fast():
	spawn_tri_attack()


# Play animation from other script
func play(anim_name: String) -> void:
	$AnimationPlayer.play(anim_name)



# Spawn fast tri_attack
# Used in AnimationPlayer
func spawn_tri_attack_ult(is_last: bool) -> void:
	var tri_attack = TRI_ATTACK.instance()
	if is_last:
		tri_attack.connect("finish", self, "attack_spawner")
	tri_attack.is_tank = true
	var rand_int = rng.randi_range(1, 3)
	if rand_int == 1:
		tri_attack.position = $"../TriAttackSpawnPosition".position
		tri_attack.peww(tri_attack_force * tri_attack_force_amplifier)
	elif rand_int == 2:
		tri_attack.position = $"../TriAttackSpawnPosition2".position
		tri_attack.peww(tri_attack_force2 * tri_attack_force_amplifier)
	elif rand_int == 3:
		tri_attack.position = $"../TriAttackSpawnPosition3".position
		tri_attack.peww(tri_attack_force3 * tri_attack_force_amplifier)
	$"..".add_child(tri_attack)


# Spawn tri_attack
func spawn_tri_attack() -> void:
	var tri_attack = TRI_ATTACK.instance()
	tri_attack.connect("finish", self, "attack_spawner")
	var rand_type = rng.randi_range(1, 3) # random number for types
	if rand_type > 2 and attack_index > 7: # random explode type
		tri_attack.is_explode = true
	elif rand_type > 1 and attack_index > 7: # random tank type
		tri_attack.is_tank = true
	var rand_int = rng.randi_range(1, 3)
	var rand_speed = rng.randi_range(1, 2)
	if rand_int == 1:
		tri_attack.position = $"../TriAttackSpawnPosition".position
		if rand_speed < 2:
			tri_attack.peww(tri_attack_force)
		else:
			tri_attack.peww(tri_attack_force * tri_attack_force_amplifier)
	elif rand_int == 2:
		tri_attack.position = $"../TriAttackSpawnPosition2".position
		if rand_speed < 2:
			tri_attack.peww(tri_attack_force2)
		else:
			tri_attack.peww(tri_attack_force2 * tri_attack_force_amplifier)
	elif rand_int == 3:
		tri_attack.position = $"../TriAttackSpawnPosition3".position
		if rand_speed < 2:
			tri_attack.peww(tri_attack_force3)
		else:
			tri_attack.peww(tri_attack_force3 * tri_attack_force_amplifier)
	print("rand_type: %s"%rand_type)
	print("rand_int: %s"%rand_int)
	print("rand_speed: %s"%rand_speed)
	$"..".add_child(tri_attack)


# Spawn big laser blue
func spawn_big_laser_blue() -> void:
	var big_laser = BIG_LASER_BLUE.instance()
	big_laser.connect("finish", self, "attack_spawner")
	big_laser.connect("player_parry", self, "player_dodge_blue_laser")
	big_laser.position = $"../BigLaserSpawnPosition".position
	$"..".call_deferred("add_child", big_laser)


# Spawn big laser red
func spawn_big_laser_red() -> void:
	var big_laser = BIG_LASER_RED.instance()
	big_laser.connect("finish", self, "attack_spawner")
	big_laser.connect("player_parry", self, "player_parry_red_laser")
	big_laser.position = $"../BigLaserSpawnPosition".position
	$"..".call_deferred("add_child", big_laser)


func player_parry_red_laser():
	learn_big_laser += 1


func player_dodge_blue_laser():
	learn_big_laser += 1


# Spawn reppuken
func spawn_reppuken(is_last: bool) -> void:
	var reppuken = REPPUKEN.instance()
	if is_last:
		reppuken.connect("finish", self, "attack_spawner")
	reppuken.position = $"../SpawnPosition".position
	$"..".call_deferred("add_child", reppuken)


# Used in AnimationPlayer
func ult_laser(is_last: bool) -> void:
	var type = rng.randi_range(1, 2)
	if type == 2:
		if is_last:
			$AnimationPlayer.play("ult_laser_blue_last")
		else:
			$AnimationPlayer.play("ult_laser_blue")
	else:
		if is_last:
			$AnimationPlayer.play("ult_laser_red_last")
		else:
			$AnimationPlayer.play("ult_laser_red")



# Helper
# Spawn big laser red
# Used in AnimationPlayer
func spawn_big_laser_red_ult(is_last: bool) -> void:
	var big_laser = BIG_LASER_RED.instance()
	if is_last:
		big_laser.connect("finish", self, "attack_spawner")
		big_laser.connect("player_parry", self, "player_parry_red_laser")
	big_laser.position = $"../BigLaserSpawnPosition".position
	$"..".call_deferred("add_child", big_laser)


# Helper
# Spawn big laser blue
# Used in AnimationPlayer
func spawn_big_laser_blue_ult(is_last: bool) -> void:
	var big_laser = BIG_LASER_BLUE.instance()
	if is_last:
		big_laser.connect("finish", self, "attack_spawner")
		big_laser.connect("player_parry", self, "player_parry_red_laser")
	big_laser.position = $"../BigLaserSpawnPosition".position
	$"..".call_deferred("add_child", big_laser)


# Used in AnimationPlayer
func spawn_meteo_ult() -> void:
	# VFX Setup 
	$"../Gurara_meteo_splash/AnimationPlayer".play("start")
	$"../Background/AnimationPlayer".play("meteo_star")
	$"../Camera2D/AnimationPlayer".play("meteo_shake")
	$"../Spacebar".fast_boi()

	# Tell players to smash meteo
	$"../Player".toggle_smashing_meteo()

	# Spawn meteo
	var meteo = METEO.instance()
	meteo.position = $"../MeteoSpawnPosition".position
	$"..".call_deferred("add_child", meteo)


"""
Attack spawner
Controls which attack would boss gura used next
First
	spawn tri_attack 5 times
then
	spawn blue laser 3 times to let player learns
then
	spawn red laser 3 times to let player learns
then
	randomly spawns XD
"""
func attack_spawner() -> void:
	if $"../Player".is_ded == true: # stop spawning when player is ded
		$AnimationPlayer.play("laugh")
		return

	if $"../Player".is_behind_default_pos() == true:
		push_player_to_default_pos_count += 1
	
	if push_player_to_default_pos_count > 3 and $"../Player".linear_velocity.y <= 0:
		push_player_to_default_pos_count = 0
		$"../Player".push_without_crash(1200, 0)


	if attack_index > 36: # honban no kougeki
		$AnimationPlayer.play("ult_meteo")
	elif attack_index > 7: # honban no kougeki
		Data.pass_tutorial = true # player start at phase2
		tri_attack_count += 1

		if tri_attack_count >= 3: # do tanks every 4th attacks NEED FIX
			$AnimationPlayer.play("tri_attacks")
			tri_attack_count = 0
			return

		var rand_int = rng.randi_range(1, 5) # big_laser or tri_attack or ult
		var rand_int2 = rng.randi_range(1, 2)
		if rand_int == 5:
			$AnimationPlayer.play("ult_reppuken")
		elif rand_int == 4:
			$LaserUltPlayer.play("ult_laser")
		elif rand_int == 3:
			$AnimationPlayer.play("tri_attack_normal")
		elif rand_int == 2:
			if rand_int2 > 1:
				$AnimationPlayer.play("big_laser_blue")
			else:
				$AnimationPlayer.play("big_laser_red")
		else:
			$AnimationPlayer.play("tri_attacks")
	elif attack_index > 5: # teaching player about laser attacks
		if had_laugh == 0: # gurara laughs before using her new attack (laser)
			$AnimationPlayer.play("laugh")
			$AnimationPlayer.queue("big_laser_blue")
			had_laugh += 1
		else:
			if learn_big_laser < 3:
				$AnimationPlayer.play("big_laser_blue")
			elif learn_big_laser < 7:
				if had_laugh < 2: # gurara laughs before using her new attack (laser)
					$AnimationPlayer.play("laugh")
					$AnimationPlayer.queue("big_laser_red")
					had_laugh += 1
				else:
					$AnimationPlayer.play("big_laser_red")
			else:
				if rng.randi_range(1, 2) > 1:
					$AnimationPlayer.play("big_laser_blue")
				else:
					$AnimationPlayer.play("big_laser_red")
				attack_index += 1
	else:
		$AnimationPlayer.play("tri_attack_normal")
	

func spawn_explode_particle() -> void:
	var explode_particle = EXPLODE_PARTICLE.instance()
	explode_particle.position = $".".position
	explode_particle.position += Vector2(rng.randi_range(-100, 100), rng.randi_range(-200, 200))
	
	$"..".add_child(explode_particle)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "wait_2s" or anim_name == "wait_weebit":
		spawn_tri_attack()
	elif anim_name == "ult_ded":
		$"../Player".play2("win_look2")
		queue_free()


func _on_AnimationPlayer_animation_started(anim_name):
	# attack_index increases when player damage gurara
	if anim_name == "hurt":
		attack_index += 1

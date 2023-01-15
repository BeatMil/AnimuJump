extends Node

export var sago_mob_amount = 0


var mob_sago_count_helper = 0
var sago_index: int = 1
var is_spawning_mob := false
onready var player = $"Player"
var bounce_helper = false
var rng = RandomNumberGenerator.new()


onready var SAGO = load("res://Sago.tscn")
onready var BOSS_CHOLE = load("res://boss_chole.tscn")
onready var BOSS_GURA = load("res://enemy/boss_gura.tscn")


func _ready():
	# hide mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# flash customize button
	Data.flash_customize_button = true

	$ExplosionTimer.wait_time = $ClearMobTimer.wait_time / 2
	$TotalMoney/Label.text = "$%s"%Data.money
	sago_index = 1 # reset sago_index after ded

	# debug purpose
	# $Camera2D.zoom = Vector2(2, 2)

	# uncomment to spawn mob or boss
	if Data.is_bazooka == true:
		$Score.visible = false
		print("====Stage01.gd=====")
		print("boss_gura_intro")
		print("===================")
		# spawn_boss_gura()
	else:
		$AnimationPlayer.play("forest_theme")
		spawn_sago()
		# spawn_sago_mob()
		# spawn_boss_chole()


func spawn_sago():
	if player.is_ded or player.is_delay_spawn: # don't spawn when player is ded
		return

	var sago = SAGO.instance()
	var is_mario_star = player.is_mario_star
	sago.position = $SpawnPosition.position
	sago.connect("ded", self, "sago_ded")

	if sago_index%7 == 0 and not is_mario_star: # prevent spawning boss on mario_star
		spawn_boss_chole()
	else:
		if sago_index %3 == 0 and not is_mario_star:
			sago.speed = sago.super_speed
			sago.changeSprite("speed_sago")
		else:
			sago.speed = sago.normal_speed
			sago.changeSprite("normal_sago")
		sago.play("normal")

		if random_spawn_jumper() and sago_index > 3 and not is_mario_star:
		# if random_spawn_jumper() and not is_mario_star:
		# if false and sago_index > 5 and not is_mario_star:
		# if true and not is_mario_star:
			sago.is_jumping = true
			sago.playSfx("preJump")
		else:
			if sago.speed == sago.super_speed:
				sago.playSfx2("charge")

		call_deferred("add_child", sago) # godot told me to do this XD
	if not is_mario_star:
		sago_index += 1
	# print("SPAWN: %s"%sago_index)


func spawn_boss_chole():
	var boss = BOSS_CHOLE.instance()
	boss.connect("ded", self, "boss_chole_ded")
	boss.position = $BossSpawnPosition.position
	call_deferred("add_child", boss) # godot told me to do this XD
	# sago.position = $SpawnPosition.position


func spawn_boss_gura():
	var boss = BOSS_GURA.instance()
	boss.position = $BossSpawnPosition.position
	call_deferred("add_child", boss) # godot told me to do this XD
	# sago.position = $SpawnPosition.position


func sago_ded():
	if not is_spawning_mob and not player.is_ded:
		spawn_sago()


func boss_chole_ded():
	player.playSprite("normal")
	player.can_jump = true

	$"Background/AnimationPlayer".play("undim")
	$Camera2D.play2("unzoom1")
	spawn_sago()


func spawn_sago_mob():
	is_spawning_mob = true
	spawn_sago()
	$MobTimer.start()
	$MobTimer.start()


func the_end():
	$"TotalMoney/Label/AnimationPlayer".play("start")
	$"Explosion/Explosion/AnimationPlayer".play("dim")
	$TotalMoney.adding_money = 1000000
	$TotalMoney.start_adding_money()


func _on_MobTimer_timeout():
	spawn_sago()
	mob_sago_count_helper += 1
	if mob_sago_count_helper >= sago_mob_amount:
		$MobTimer.stop()
		$ClearMobTimer.start()
		$ExplosionTimer.start()
		mob_sago_count_helper = 0
		$AnimationPlayer.play("forest_theme")
	# print("mod_count_helper: %s"%mob_sago_count_helper)


func _on_ClearMobTimer_timeout():
	is_spawning_mob = false
	spawn_sago()


func sago_bounce_helper():
	if bounce_helper == false:
		bounce_helper = true
		return bounce_helper
	elif bounce_helper == true:
		bounce_helper = false
		return bounce_helper


func _on_ExplosionTimer_timeout():
	$Explosion/Explosion/AnimationPlayer.play("explosion")


func _on_JumpArea2D_body_entered(body):
	if body.is_in_group("Sago"):
		if body.is_jumping == true:
			body.jump()
			body.playSfx("jump")


func random_spawn_jumper():
	rng.randomize()
	var my_random_number = rng.randi_range(0, 10)
	if my_random_number > 5:
		return true
	else:
		return false


func _on_BossStart_body_entered(body):
	if body.is_in_group("boss"):
		# start boss_chole sequence
		body.start()
		body.mode = RigidBody2D.MODE_STATIC

		$"Background/AnimationPlayer".play("dim")
		$Camera2D.play2("zoom1")

		player.can_jump = false
		player.playSprite("look")

		# push kaisouko into cinematic boss fight
		if player.is_behind_default_pos():
			player.push_without_crash(1000, 0)
	elif body.is_in_group("boss_gura"):
		player.is_gurara_fight = true # fix player can't block while fighting gurara
		body.start()

extends Node2D


export var is_osu = false
export var can_be_pressed = false
export var next_osu_interval = 0.5
var next_osu: Object = null
var boss_owner: Object = null
var is_first_one = false
var is_last_one = false
var is_combo = false
var timmer = null
var circle_speed: float = 1
var sequence_index := 0

const EXPLODE_PARTICLE2 = preload("res://explodeParticle.tscn")

signal sequence_over


func _input(event):
	if event.is_action_pressed("ui_accept"):
		if can_be_pressed:
			can_be_pressed = false
			if next_osu:
				next_osu.can_be_pressed = true
			if is_osu:
				# check chain combo to defeat boss
				# If player miss an osu is_combo will be false
				# therefore won't kill the boss
				if is_combo:
					if next_osu:
						next_osu.is_combo = true
				$AnimationPlayer.stop()
				$AnimationPlayer.play("osu!")
			else:
				$AnimationPlayer.stop()
				$AnimationPlayer.play("miss!")


func start():
	if is_first_one:
		can_be_pressed = true
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("start", -1, circle_speed)


func start_osu(): # confusing name for AnimationPlayer
	is_osu = true
	$WindowTimer.start()


func explode_particle():
	var explode_particle = EXPLODE_PARTICLE2.instance()
	explode_particle.global_position = $".".global_position
	$"..".add_child(explode_particle)


func _on_WindowTimer_timeout():
	is_osu = false


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "miss!":
		can_be_pressed = false
		if next_osu:
			next_osu.can_be_pressed = true

		# Push player
		if sequence_index == 0:
			$"../Player".push(-100, -200)
		else:
			$"../Player".push(-1000, -200)
		# $"../Player".playSprite("look")

		# Shake Camera
		$"../Camera2D/AnimationPlayer".stop()
		$"../Camera2D/AnimationPlayer".play("shake")

		# emit_signal("sequence_over", false)
		# print("sequence_over: false")

	if anim_name == "osu!":
		explode_particle()
		if is_last_one and is_combo:
			# boss_owner.play2("hurt")
			emit_signal("sequence_over", true)
			print("sequence_over: true")
			# boss_owner.push_away_ded()

			# Shake Camera
			$"../Camera2D/AnimationPlayer".stop()
			$"../Camera2D/AnimationPlayer".play("shake")
		elif is_last_one and not is_combo:
			emit_signal("sequence_over", false)
			print("sequence_over: false")
		else:
			boss_owner.play2("hurt")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "start":
		$AnimationPlayer.play("miss!")
	
	if anim_name == "miss!":
		if is_last_one:
			emit_signal("sequence_over", false)
			print("sequence_over: false<<<<")
		queue_free()
	# elif anim_name == "osu!":
	# 	if is_last_one and is_combo:
	# 		emit_signal("sequence_over", true)
	# 		print("sequence_over: false<<<<")
	# 	queue_free()

	# if anim_name == "osu!" or anim_name == "miss!":
	# 	if is_last_one and not is_combo: # redo sequence if combo drops
	# 		pass
	# 		emit_signal("sequence_over", false)
	# 		print("sequence_over: false<<<<")
	# 	queue_free()

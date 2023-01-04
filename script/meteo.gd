extends RigidBody2D

var hp = 50 # 50


func _ready():
	$AnimationPlayer.play("meteo")
	peww(Vector2(-80, 80))


func peww(force: Vector2) -> void:
	# current_force = force
	# self.rotation_degrees = rad2deg(force.angle()) # calculate rotation XD
	apply_central_impulse(force)


func _on_Area2D_body_entered(body):
	if body.is_in_group("tri_attack"):
		body.play("meteo_stagger")
		hp -= 1
		if hp <= 0:
			body.queue_free()
			$"/root/Stage01/Player/AnimationPlayer".stop()
			$"/root/Stage01/Player".is_victorious = true
			$"/root/Stage01/Player".remove_dodge_parry_body()
			$"/root/Stage01/Player".play2("black")
			$"/root/Stage01/Camera2D".play("white_ride")
			$"/root/Stage01/Spacebar".fast_boi()
			linear_velocity = Vector2(0, 0)
			$AnimationPlayer.play("black")
			$"/root/Stage01/Background/AnimationPlayer".play("white")
			$"/root/Stage01/BossGura/FloatPlayer".play("RESET")
			$"/root/Stage01/BossGura/AnimationPlayer".stop()
			$"/root/Stage01/BossGura/BlackPlayer".play("black")
			$"/root/Stage01/PlayerTriAttack".queue_free()

			$CutsceneTimer.start()
			# get_tree().paused = not get_tree().paused
			# queue_free()
	elif body.is_in_group("Player"):
		body.push(-5000, 200)


func _on_CutsceneTimer_timeout():
	$"/root/Stage01/Camera2D".play("RESET")
	$"/root/Stage01/Background/AnimationPlayer".play("un_gurara_boss")
	$"/root/Stage01/BossGura/AnimationPlayer".play("ult_ded")
	$"/root/Stage01/Player".play2("win_look")

	queue_free()

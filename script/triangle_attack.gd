extends RigidBody2D


# Configs
var current_force := Vector2.ZERO
var is_explode := false # dodge only
var is_tank := false # parry only
var is_ := false


# Signal
signal finish


func _ready():
	$Particles2D.one_shot = true


func peww(force: Vector2) -> void:
	current_force = force
	self.rotation_degrees = rad2deg(force.angle()) # calculate rotation XD
	apply_central_impulse(force)
	if is_explode:
		$PolygonPlayer.play("tri_explode")
		$AnimationPlayer.play("explosion")
	elif is_tank:
		$PolygonPlayer.play("tri_tank")
		$AnimationPlayer.play("tank")
		add_to_group("tri_tank")
	else:
		$PolygonPlayer.play("tri_attack")
		$AnimationPlayer.play("peww")


func player_peww(force: Vector2) -> void:
	current_force = force
	self.rotation_degrees = rad2deg(force.angle()) # calculate rotation XD
	apply_central_impulse(force)
	$PolygonPlayer.play("tri_attack")
	$AnimationPlayer.play("player_peww")


func turn_hit_boss_collision():
	collision_layer = 0b00000000000000000000
	collision_mask = 0b00000000101000000000


func turn_off_collision_for_real_XD(): # wtf is this function name!!
	# collision_layer = 0b00000000000000000000
	collision_mask = 0b00000000000000000000


func turn_on_collision():
	# collision_layer = 0b00000000000000000001
	collision_mask = 0b00000000000000000001


func play(anim_name: String) -> void:
	$AnimationPlayer.play(anim_name)


func _on_TriAttack_body_entered(body):
	if is_explode:
		if body.is_in_group("parry"):
			linear_velocity = Vector2.ZERO
			body.get_parent().push(-2000, 200)
			turn_off_collision_for_real_XD()
			$"/root/Stage01/Camera2D".play("shake")
			$AnimationPlayer.play("explode")
			$Particles2D.emitting = false
			$DelaySpawnTimer.start()
			$QueueFreeTimer.start()
		elif body.is_in_group("Player"):
			linear_velocity = Vector2.ZERO
			body.push(-2000, 200)
			turn_off_collision_for_real_XD()
			$"/root/Stage01/Camera2D".play("shake")
			$AnimationPlayer.play("explode")
			$Particles2D.emitting = false
			$DelaySpawnTimer.start()
			$QueueFreeTimer.start()
	else:
		if body.is_in_group("parry"):
			apply_central_impulse(-current_force)
			$"/root/Stage01/Camera2D".play("shake")
			turn_hit_boss_collision()
		elif body.is_in_group("Player"):
			# push self and player for dramatic impact)
			apply_impulse(Vector2.ZERO, -(current_force * 0.5))
			apply_torque_impulse(100000)
			turn_off_collision_for_real_XD()
			$AnimationPlayer.play("stagger")
			body.push(-1000, 200)
			$"/root/Stage01/Camera2D".play("shake")
			$DelaySpawnTimer.start()
			$QueueFreeTimer.start()
		elif body.is_in_group("boss_gura"):
			$AnimationPlayer.play("stagger")
			$"/root/Stage01/Camera2D".play("shake")
			body.play("hurt")
			turn_off_collision_for_real_XD()
			apply_central_impulse(Vector2(-500, 0))
			apply_torque_impulse(-100000)
			$DelaySpawnTimer.start()
			$QueueFreeTimer.start()
		elif body.is_in_group("tri_attack"):
			return
		elif body.is_in_group("Ground"):
			return
	
	# queue_freeing itself after touching player or ground
	if $VisibilityNotifier2D.is_connected("screen_exited", self, "_on_VisibilityNotifier2D_screen_exited"):
		$VisibilityNotifier2D.disconnect("screen_exited", self, "_on_VisibilityNotifier2D_screen_exited")

	print("======TriBodyEntered======")
	print("body entered: %s"%body.name)
	print("==========================")
	
	
func _on_VisibilityNotifier2D_screen_exited():
	# linear_velocity = Vector2.ZERO
	$DelaySpawnTimer.start()
	$QueueFreeTimer.start()


func _on_QueueFreeTimer_timeout():
	queue_free()


func _on_DelaySpawnTimer_timeout():
	emit_signal("finish")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "stagger" or anim_name == "meteo_stagger":
		queue_free()

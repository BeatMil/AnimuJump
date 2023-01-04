extends Sprite

signal finish
signal player_parry


func _ready():
	pass
	$AnimationPlayer.play("start")


func camera_shake_helper():
	$"/root/Stage01/Camera2D".play("shake")


func turn_off_collision_for_real_XD(): # wtf is this function name!!
	$BigLaserArea2D.collision_layer = 0b00000000000000000000
	$BigLaserArea2D.collision_mask = 0b00000000000000000000


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "start":
		emit_signal("finish")
		queue_free()


func _on_BigLaserArea2D_body_entered(body):
	if body.is_in_group("Player") and body.is_blocking:
		body.push(-3000, 200)
		$"/root/Stage01/Camera2D".play("big_shake")
		turn_off_collision_for_real_XD()
	elif body.is_in_group("Player"):
		emit_signal("player_parry")

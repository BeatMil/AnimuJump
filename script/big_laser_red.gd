extends Sprite


# Config
var push_player_force_x = -2000
var push_player_force_y = 200


# Signal
signal finish
signal player_parry


# Ready
func _ready():
	pass
	$AnimationPlayer.play("start")


# Stage01/Camera2D
func camera_shake_helper():
	$"/root/Stage01/Camera2D".play("shake")


# Turn off collision 0b00000000000000000000
func turn_off_collision_for_real_XD(): # wtf is this function name!!
	$BigLaserArea2D.collision_layer = 0b00000000000000000000
	$BigLaserArea2D.collision_mask = 0b00000000000000000000


# AnimationPlayer_finished
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "start":
		emit_signal("finish")
		queue_free()


# BigLaserArea2D area entered
func _on_BigLaserArea2D_area_entered(area):
	if area.is_in_group("dodge"):
		var player = area.get_parent()
		if player.is_parrying:
			player.play("parry_big_laser_red")
			emit_signal("player_parry")
		else:
			player.push(push_player_force_x, push_player_force_y)

		$"/root/Stage01/Camera2D".play("big_shake")
		turn_off_collision_for_real_XD()

		print("▦▦▦▦▦▦▦▦▦▦▦▦▦▦big_laser_red.gd:BigLaserArea2D_body_entered▦▦▦▦▦▦▦▦▦▦▦▦▦") 
		print("area: %s"%area.name) 
		print("▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦") 

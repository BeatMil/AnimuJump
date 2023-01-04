extends Camera2D


onready var tween = $Tween
var shake_index := 0
var is_shake_complete = false


func _ready():
	# shake()
	pass


func play(anim: String):
	$AnimationPlayer.stop()
	$AnimationPlayer.play(anim)


func play2(anim: String):
	$AnimationPlayer2.stop()
	$AnimationPlayer2.play(anim)


func shake():
	is_shake_complete = false
	shake_down()


func shake_down():
	tween.interpolate_property($".", "offset",
		Vector2(0, 0), Vector2(0, 10), 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func shake_up():
	tween.interpolate_property($".", "offset",
		Vector2(0, 10), Vector2(0, 0), 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_Tween_tween_completed(object, key):
	if object is Camera2D and not is_shake_complete:
		shake_up()
		is_shake_complete = true
		shake_index += 1
		if shake_index < 5:
			shake()

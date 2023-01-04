extends Label



func _ready():
	if $"..".is_in_group("big"):
		$AnimationPlayer.play("big_increase_score")
	else:
		$AnimationPlayer.play("increase_score")


func _on_AnimationPlayer_animation_finished(anim_name):
	$"..".queue_free()


func set_score(score: String):
	text = score

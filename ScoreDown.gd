extends Node2D


func _ready():
	$AnimationPlayer.play("decrease_score")
	


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "decrease_score":
		queue_free()


func set_score(amount: String):
	$Label.text = "-%s"%amount

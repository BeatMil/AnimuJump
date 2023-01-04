extends Area2D


func _on_DedArea2D_body_entered(body):
	if body.is_in_group("Player"):
		body.ded()
	elif body.is_in_group("reppuken"):
		body._on_DelayDedTimer_timeout()

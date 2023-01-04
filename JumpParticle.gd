extends Node2D


func _ready():
	$Timer.wait_time = $Particles2D.lifetime
	$Particles2D.one_shot = true
	$Particles2D.emitting = true
	$Timer.start()
	
	if $".".is_in_group("hadoken"): # Player anti-air sagos
		$AnimationPlayer.play("shoot_up")


func _on_Timer_timeout():
	queue_free()

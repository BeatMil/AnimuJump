extends Node2D


export var score: int = 0
onready var LABEL_SCORE_UP = load("res://Label_score_up.tscn")
const EXPLODE_PARTICLE = preload("res://explodeParticle3.tscn")


func _ready():
	update_score()


func update_score():
	$Label.text = str(score)


func increase_score(amount: int):
	score += amount
	run_score_up_animation(amount)
	if amount >= 1000:
		pass
	else:
		update_score()


func decrease_score(amount: int):
	score -= amount
	update_score()


func run_score_up_animation(amount: int):
	var score_up = LABEL_SCORE_UP.instance()
	if amount >= 1000:
		score_up.add_to_group("big")
		$Timer.start()
	score_up.get_node("Label_score_up").set_score("+%s"%str(amount))
	score_up.position = $Position2D.position
	add_child(score_up)


func play(anim_name):
	$AnimationPlayer.play(anim_name)


func spawn_particle(): # Used by AnimationPlayer
	var explode_particle = EXPLODE_PARTICLE.instance()
	explode_particle.global_position = $".".global_position + Vector2(200, 0)
	$"..".add_child(explode_particle)
	$"../Camera2D/AnimationPlayer".stop()
	$"../Camera2D/AnimationPlayer".play("shake")


func _on_Timer_timeout():
	update_score()
	play("big_score")


func _on_AnimationPlayer_animation_started(anim_name):
	pass

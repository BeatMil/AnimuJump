extends Node2D

export var total_money := 0 # player.ded() give total_money
export var adding_money := 0
export var step := 10
onready var score = $"../Score"
onready var LABEL_SCORE_UP = load("res://Label_score_up.tscn")
export var is_adding_money = false


func _input(event):
	if event.is_action_pressed("ui_accept") and is_adding_money:
		skip_adding_money_animation()


func start_adding_money():
	is_adding_money = true
	adding_money = score.score
	$Timer.start()
	$Label/AnimationPlayer.play("count")


func run_score_up_animation(amount: int):
	var score_up = LABEL_SCORE_UP.instance()
	if amount >= 1000:
		score_up.add_to_group("big")
		$Timer.start()
	score_up.get_node("Label_score_up").set_score("+%s"%str(amount))
	# score_up.global_position = $".".global_position + Vector2(200, 0)
	# score_up.position = $Position2D.position
	add_child(score_up)


func skip_adding_money_animation():
	# stop everything
	stop_adding_money()

	# then add the rest
	total_money += adding_money
	$Label.text = "$%s"%total_money

func stop_adding_money():
	$Timer.stop()
	$"../Score".queue_free()
	$Label/AnimationPlayer.play("move_up")
	$"../CanvasLayer/DedMenu/AnimationPlayer".play("show_menu")
	is_adding_money = false


func _on_Timer_timeout():
	if adding_money > 0:
		total_money += step
		adding_money -= step
		score.decrease_score(10)
		run_score_up_animation(10)
		$Label.text = "$%s"%total_money
	else:
		stop_adding_money()

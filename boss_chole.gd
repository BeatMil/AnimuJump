extends RigidBody2D


export var speed = 1000
export var is_start = false
export var sequence_index = 0
var boss_money_reward = 2000

onready var player = $"../Player"

var rng = RandomNumberGenerator.new()

onready var CIRCLE = load("res://timed_circles.tscn")
const EXPLODE_PARTICLE = preload("res://explodeParticle4.tscn")

var circles = []


signal ded
signal pre_ded


func _ready():
	rng.randomize()


func _integrate_forces(_state):
	if not is_start:
		linear_velocity = Vector2(-speed, linear_velocity.y)


func start():
	is_start = true
	linear_velocity = Vector2.ZERO
	$AnimationPlayer.play("start")
	$AnimationPlayerOST.play("song")
	$"../AnimationPlayer".stop()
	spawn_circles(false)


func spawn_circles(is_combo: bool):
	"""
	This functions work together with timed_circles.gd
	"""
	print("spawn_circles<<<<")
	print(circles)
	print("spawn_circles<<<<")
	# if player dies, stop spawning
	if player.is_ded:
		return

	if sequence_index > 2 and is_combo:
		push_away_ded()
		return

	if sequence_index > 2 or not is_combo:
		sequence_index = 0

	var circle1 = CIRCLE.instance()
	var circle2 = CIRCLE.instance()
	var circle3 = CIRCLE.instance()
	
	circle3.connect("sequence_over", self, "spawn_circles")

	circle1.is_first_one = true # fixing circle is destroyed before calling start()
	circle3.is_last_one = true

	circle1.is_combo = true

	circle1.boss_owner = $"."
	circle2.boss_owner  = $"."
	circle3.boss_owner = $"."


	
	# Make circles position spread wider each time
	if sequence_index == 0:
		circle1.position = $"../circles_pos/pos1".position
		circle2.position = $"../circles_pos/pos2".position
		circle3.position = $"../circles_pos/pos3".position
		circle1.sequence_index = sequence_index
		circle2.sequence_index = sequence_index
		circle3.sequence_index = sequence_index
		$AnimationPlayer.play("sus1")
	elif sequence_index == 1:
		circle1.position = $"../circles_pos/pos1".position + get_random_offset_pos(-200, 200, 50, -200)
		circle2.position = $"../circles_pos/pos2".position + get_random_offset_pos(-200, 200, -100, 200)
		circle3.position = $"../circles_pos/pos3".position + get_random_offset_pos(-200, 200, -200, 100)
		circle1.circle_speed = 1.5
		circle2.circle_speed = 1.5
		circle3.circle_speed = 1.5
		circle1.sequence_index = sequence_index
		circle2.sequence_index = sequence_index
		circle3.sequence_index = sequence_index
		$CircleIntervalTimer.wait_time = 0.4
		$AnimationPlayer.play("sus2")
	elif sequence_index == 2:
		circle1.position = $"../circles_pos/pos1".position + get_random_offset_pos(-200, 200, 50, -200)
		circle2.position = $"../circles_pos/pos2".position + get_random_offset_pos(-200, 200, -100, 200)
		circle3.position = $"../circles_pos/pos3".position + get_random_offset_pos(-200, 200, -200, 100)
		circle1.circle_speed = 2
		circle2.circle_speed = 2
		circle3.circle_speed = 2
		circle1.sequence_index = sequence_index
		circle2.sequence_index = sequence_index
		circle3.sequence_index = sequence_index
		$CircleIntervalTimer.wait_time = 0.4
		$AnimationPlayer.play("sus3")

	circle1.next_osu = circle2
	circle2.next_osu = circle3

	circles.append(circle1)
	circles.append(circle2)
	circles.append(circle3)

	$"..".call_deferred("add_child", circle1)
	$"..".call_deferred("add_child", circle2)
	$"..".call_deferred("add_child", circle3)

	$CircleIntervalTimer.start()

	sequence_index += 1


func get_random_offset_pos(from_x: int, to_x: int, from_y: int, to_y: int):
	var random_offset_pos = Vector2(rng.randi_range(from_x, to_x), rng.randi_range(from_y, to_y))
	return random_offset_pos


func play(anim: String):
	$AnimationPlayer.stop()
	$AnimationPlayer.play(anim)


func play2(anim: String):
	$AnimationPlayer2.stop()
	$AnimationPlayer2.play(anim)


func push_away_ded():
	$AnimationPlayer.play("explode")
	# apply_central_impulse(Vector2(1000, -1000))


func spawn_particle(): # Used by AnimationPlayer
	var explode_particle = EXPLODE_PARTICLE.instance()
	explode_particle.global_position = $".".global_position
	$"..".add_child(explode_particle)


func _on_CircleIntervalTimer_timeout():
	if circles.size() > 0:
		if is_instance_valid(circles[0]):
			circles[0].start()
		circles.remove(0)


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "explode":
		emit_signal("pre_ded")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "explode":
		$"../Score".increase_score(boss_money_reward)
		$DelayTimer.start()


func _on_DelayTimer_timeout():
	emit_signal("ded")
	$"../AnimationPlayer".play("forest_theme")
	queue_free()

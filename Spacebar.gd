extends AnimatedSprite


var is_closed = false


func _ready():
	if Data.is_bazooka == true:
		self.visible = false


func _input(_event):
	if Input.is_action_just_pressed("ui_accept") and not is_closed:
		$".".visible = false
		is_closed = true


# toggle visibility with speed 3
func fast_boi():
	$".".visible = not $".".visible
	speed_scale = 3

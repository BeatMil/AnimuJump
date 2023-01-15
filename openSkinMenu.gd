extends Sprite


func _ready():
	$SpritePlayer.play(Data.current_skin)
	
	if Data.flash_customize_button:
		$AnimationPlayer2.play("flash")

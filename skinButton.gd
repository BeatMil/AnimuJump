extends Button


func _ready():
	connect("button_down", self, "i_got_pressed")
	# if player already choose this skin, press this button
#	if Data.current_skin == self.name:
#		self.pressed = true
#		self.modulate = Color(1, 1, 1)
#	else:
#		self.pressed = false
#		self.modulate = Color(0.7, 0.7, 0.7)

	check_purchased_skin()


func i_got_pressed() -> void:
	$"../../..".arrow_point_to_current_skin(self.name)
	Data.current_skin = self.name
	$"/root/MainMenu/KaisoukoLook".texture = self.icon
	
#	if button_pressed:
#		self.modulate = Color(1, 1, 1)
#		Data.current_skin = self.name
##		$"../..".choose_skin(self)
#	else:
#		if Data.current_skin == self.name:
#			return
#		self.modulate = Color(0.7, 0.7, 0.7)
#	pass


func check_purchased_skin():
	# Check if player has the skin
	# if player doesn't have the skin, disable the button
	if Data.items.has(self.name):
		if Data.items[self.name] == false:
			self.disabled = true
			self.modulate = Color(0.1, 0.1, 0.1)
		else:
			self.disabled = false
			self.modulate = Color(1, 1, 1)
	elif self.name == "default":
		self.disabled = false
		self.modulate = Color(1, 1, 1)
	else:
		self.disabled = true
		self.modulate = Color(0.1, 0.1, 0.1)

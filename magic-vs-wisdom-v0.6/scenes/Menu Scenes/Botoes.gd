extends Button

func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("pressed", Callable(self, "_on_pressed"))

func _on_mouse_entered():
	if UIAudio:
		UIAudio.play_hover()

func _on_pressed():
	if UIAudio:
		UIAudio.play_click()

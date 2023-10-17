extends Control

func _ready() -> void:
	pass
	
func addPlayer(id) -> void:
	var a = Label.new()
	a.add_font_override("font", load("res://assets/Font Resources/ButtonFont.tres"))
	a.text = str(id)
	$VBoxContainer/MarginContainer/VBoxContainer.add_child(a)

func removePlayer(id) -> void:
	for child in $VBoxContainer/MarginContainer/VBoxContainer.get_children():
		if child.text == str(id):
			child.queue_free()

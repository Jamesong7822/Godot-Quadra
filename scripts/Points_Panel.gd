extends Control

func _ready():
	$HBoxContainer/Label.text=str(Globals.points)
	Globals.connect("update_points",self,"update_points")

func update_points():
	$HBoxContainer/Label.text=str(Globals.points)

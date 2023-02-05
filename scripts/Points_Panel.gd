extends Control

func _ready():
	$HBoxContainer/Label.text=str(Globals.points)
	Globals.connect("add_points",self,"add_points")

func add_points():
	$HBoxContainer/Label.text=str(Globals.points)

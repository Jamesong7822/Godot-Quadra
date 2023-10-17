extends Control

const COMBO1 = "COOL"
const COMBO2 = "GREAT"
const COMBO3 = "AWESOME"
const COMBO4 = "FANTASTIC"
const LIFETIME = 1.0
const LIFETIME_OFFSET = 0.25
const X_OFFSET = 100
const Y_OFFSET = 300

var rng = RandomNumberGenerator.new()
var color = null

func _ready() -> void:
	rng.randomize()
	# randomize label position
	$Label.rect_position.x = $Label.rect_position.x + (rng.randf()*2-1)*X_OFFSET
	$Label.rect_position.y = $Label.rect_position.y + (rng.randf()*2-1)*Y_OFFSET
	# randomize font colors
	var randomHue = rng.randf_range(0, 1.0)
	color = Color.from_hsv(randomHue, 1.0, 1.0)
	$Label.add_color_override("font_color", color)
	# Tween
	var tween = Tween.new()
	tween.connect("tween_completed", self, "onTweenCompleted")
	var finalCol = color
	var lifetime = LIFETIME + (rng.randf()*2-1) * LIFETIME_OFFSET
	finalCol.a = 0
	tween.interpolate_property($Label, 
							   "custom_colors/font_color", color, finalCol, 
							   lifetime)
	var finalPos = $Label.rect_position
	finalPos.y -= 300
	tween.interpolate_property($Label, "rect_position", $Label.rect_position, finalPos, lifetime)
	add_child(tween)
	tween.start()
	
func setCombo(comboNum) -> void:
	if comboNum == 1:
		$Label.text = COMBO1
	elif comboNum == 2:
		$Label.text = COMBO2
	elif comboNum == 3:
		$Label.text = COMBO3
	else:
		$Label.text = COMBO4

func onTweenCompleted(_a, _b) -> void:
	queue_free()

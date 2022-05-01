extends Node2D


onready var special_lines = $Special.get_children()
onready var consonant_lines = $Consonants.get_children()
onready var vowel_lines = $Vowels.get_children()
onready var invalid_points = $InvalidPoints.get_children()
onready var overlay = $Overlay
onready var label = $Overlay/ZSet/Label


var lines: Array
var parse_result: Runes.RuneParseResult = null


func _ready():
	lines = []
	lines.append_array(special_lines)
	lines.append_array(consonant_lines)
	lines.append_array(vowel_lines)


func detect(img: Image):
	var is_invalid = false
	for invalid_point in invalid_points:
		if ImgUtil.get_value_at(img, invalid_point.global_position) < 0.5:
			is_invalid = true

	for line in lines:
		if is_invalid:
			line.status = RuneLine.Status.DEFAULT
		else:
			line.detect(img)
	
	parse_result = Runes.parse(detected_lines())


func show_parse_result():
	if parse_result != null:
		overlay.visible = true
		label.text = str(parse_result)

func hide_parse_result():
	overlay.visible = false


func detected_lines(set = lines):
	var line_names = []
	for line in set:
		if line.status == RuneLine.Status.DETECTED:
			line_names.append(line.get_name())
	return line_names


func detected_line_count(set = lines):
	return detected_lines(set).size()


func any_line_detected(set = lines):
	return detected_line_count(set) > 0


func is_valid_rune():
	# TODO
	return any_line_detected()

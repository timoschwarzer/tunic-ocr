extends Node2D


enum State {
	SELECT_FILE,
	PROCESSING_IMAGE,
	SELECT_BASELINE_START,
	SELECT_BOUND,
	SELECT_BACKGROUND_COLOR,
	SELECT_FONT_COLOR,
	DETECTING_RUNES,
}

enum DetectMode {
	LINE,
	WORD,
	RUNE,
}


const INSTRUCTIONS = {
	State.SELECT_FILE: 'Select file',
	State.PROCESSING_IMAGE: 'Processing image...',
	State.SELECT_BASELINE_START: 'Select baseline start',
	State.SELECT_BOUND: 'Select upper or lower bound',
	State.SELECT_BACKGROUND_COLOR: 'Select background color',
	State.SELECT_FONT_COLOR: 'Select font color',
	State.DETECTING_RUNES: 'Detecting runes...',
}

const DETECT_MODE_NAMES = {
	DetectMode.LINE: 'Line',
	DetectMode.WORD: 'Word',
	DetectMode.RUNE: 'Rune',
}


const Rune = preload('res://Rune.tscn')
const Dot = preload('res://Dot.tscn')


const RUNE_WIDTH = 60
const RUNE_HEIGHT = 100


onready var canvas = $Canvas
onready var camera = $Camera
onready var ui = $CanvasLayer/UI
onready var open_dialog = $CanvasLayer/UI/OpenDialog
onready var show_hide_button = $CanvasLayer/UI/HBoxContainer/ShowHideButton
onready var status_label = $CanvasLayer/UI/StatusLabel
onready var toggle_processed_image_button = $CanvasLayer/UI/HBoxContainer/ToggleProcessedImageButton
onready var toggle_slow_ocr_button = $CanvasLayer/UI/HBoxContainer/ToggleSlowOCRButton
onready var detect_mode_button = $CanvasLayer/UI/HBoxContainer/DetectModeButton


var runes = []
var dots = []
var rune_base_pos = null
var rune_bottom_pos = null
var rune_scale = 1.0
var image: Image = null
var original_image: Image = null
var mouse_down_global_pos = null
var mouse_down_camera_pos = null
var mouse_dragging = false
var show_translation = false
var threshold = 0.5
var background_color = Color.white
var state = null
var status_text_override = null
var status_text_override_timeout = 0
var display_processed_image = false
var slow_ocr = false
var detect_mode = DetectMode.LINE


func _ready():
	open_file()


func make_rune():
	var rune = Rune.instance()
	rune.scale = Vector2(rune_scale, rune_scale)
	# rune.modulate.a = 0.5
	return rune


func _process(delta):
	if status_text_override_timeout > 0:
		status_text_override_timeout -= delta
		status_label.text = status_text_override

		if status_text_override_timeout <= 0:
			update_status_label()


func set_status_text_override(value, time = 2.0):
	status_text_override = value
	status_text_override_timeout = time


func set_state(value):
	state = value
	if status_text_override_timeout <= 0:
		update_status_label()


func update_status_label():
	status_label.text = INSTRUCTIONS[state]


func _unhandled_input(event):
	if image == null:
		return

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				mouse_down_global_pos = get_viewport().get_mouse_position()
				mouse_down_camera_pos = camera.global_position
			else:
				mouse_down_global_pos = null
				
				if mouse_dragging:
					mouse_dragging = false
				elif state == State.SELECT_BASELINE_START:
					rune_base_pos = get_local_mouse_position()
					var dot = Dot.instance()
					dot.global_position = rune_base_pos
					add_child(dot)
					dots.append(dot)
					set_state(State.SELECT_BOUND)
				elif state == State.SELECT_BOUND:
					rune_bottom_pos = get_local_mouse_position()
					var standard_distance = Vector2(RUNE_WIDTH / 2.0, RUNE_HEIGHT / 2.0).length()
					rune_scale = (rune_bottom_pos - rune_base_pos).length() / standard_distance
					yield(detect_runes_in_line(), 'completed')
					rune_base_pos = null
					rune_bottom_pos = null
					free_and_clear(dots)
					set_state(State.SELECT_BASELINE_START)
				elif state == State.SELECT_BACKGROUND_COLOR:
					background_color = ImgUtil.get_value_at(original_image, get_local_mouse_position())
					set_state(State.SELECT_FONT_COLOR)
				elif state == State.SELECT_FONT_COLOR:
					set_state(State.PROCESSING_IMAGE)
					yield(get_tree(), 'idle_frame')
					yield(get_tree(), 'idle_frame')

					var font_color = ImgUtil.get_value_at(original_image, get_local_mouse_position())
					
					threshold = lerp(background_color, font_color, 0.5)

					var invert = background_color < font_color
					image = ImgUtil.calculate_threshold(original_image, threshold, invert)
					update_canvas()
					
					set_status_text_override('Calibrated threshold to %s (inverted=%s)' % [threshold, invert])
					yield(get_tree(), 'idle_frame')
					set_state(State.SELECT_BASELINE_START)
			get_tree().set_input_as_handled()
		elif event.button_index == BUTTON_WHEEL_UP:
			camera.zoom *= 1.03
			get_tree().set_input_as_handled()
		elif event.button_index == BUTTON_WHEEL_DOWN:
			camera.zoom /= 1.03
			get_tree().set_input_as_handled()
	elif event is InputEventMouseMotion:
		if mouse_down_global_pos != null:
			if mouse_dragging:
				var delta = (get_viewport().get_mouse_position() - mouse_down_global_pos)
				camera.global_position = mouse_down_camera_pos - delta * camera.zoom.x
				get_tree().set_input_as_handled()
			elif get_local_mouse_position().distance_squared_to(mouse_down_global_pos) > 25:
				mouse_dragging = true
				get_tree().set_input_as_handled()


func detect_runes_in_line():
	set_state(State.DETECTING_RUNES)

	var x_offset = 0
	var rune_width = RUNE_WIDTH * rune_scale
	var dot = Dot.instance()
	add_child(dot)

	image.lock()

	var last_rune_x_offset = 0
	while x_offset + rune_base_pos.x < image.get_width():
		var pos = rune_base_pos + Vector2(x_offset, 0)
		dot.global_position = pos

		var rune_does_not_fit = false
		for detect_offset in range(rune_width * 0.7):
			if ImgUtil.get_value_at(image, pos + Vector2(detect_offset, 0)) > 0.5:
				x_offset += detect_offset + 1
				rune_does_not_fit = true
				break

		if rune_does_not_fit:
			if x_offset - last_rune_x_offset > rune_width * 4 || detect_mode == DetectMode.WORD:
				break
			else:
				continue
		
		var x_correct_offset = 0

		var rune = make_rune()
		rune.global_position = pos
		add_child(rune)
		rune.detect(image)

		var optimal_offset = 0
		var optimal_scale_multiplier = 1.0
		var optimal_count = 0
		for abs_offset in range(1, rune_width * 0.2):
			for offset in [-abs_offset, abs_offset]:
				rune.global_position = pos + Vector2(offset, 0)
				
				for abs_scale_multiplier in [1.02, 1.04, 1.06, 1.08, 1.1]:
					for scale_multiplier in [abs_scale_multiplier, 1.0 / abs_scale_multiplier]:
						var scale = rune_scale * scale_multiplier
						rune.scale = Vector2(scale, scale)
						rune.detect(image)

						var line_count = rune.detected_line_count()
						if line_count > optimal_count && rune.parse_result != null:
							optimal_offset = offset
							optimal_scale_multiplier = scale_multiplier
							optimal_count = line_count
						
						if slow_ocr:
							yield(get_tree(), 'idle_frame')
		yield(get_tree(), 'idle_frame')
		
		x_correct_offset = optimal_offset
		rune.global_position = pos + Vector2(optimal_offset, 0)
		var scale = rune_scale * optimal_scale_multiplier
		rune.scale = Vector2(scale, scale)
		rune.detect(image)
		
		if !rune.is_valid_rune():
			rune.queue_free()
		else:
			runes.append(rune)
			last_rune_x_offset = x_offset
		
			if show_translation:
				rune.show_parse_result()

			if detect_mode == DetectMode.RUNE:
				break

		x_offset += rune_width + x_correct_offset

	yield(get_tree(), 'idle_frame')
	image.unlock()

	dot.queue_free()

	set_state(State.SELECT_BASELINE_START)
		

func open_file():
	set_state(State.SELECT_FILE)

	open_dialog.popup_centered()
	
	yield(open_dialog, 'popup_hide')
	
	if (open_dialog.current_path != ''):
		set_state(State.PROCESSING_IMAGE)
		yield(get_tree(), 'idle_frame')
		yield(get_tree(), 'idle_frame')

		original_image = Image.new()
		original_image.load(open_dialog.current_path)
		image = ImgUtil.calculate_threshold(original_image)
		update_canvas()
		open_dialog.current_path = ''
		camera.zoom = Vector2.ONE
		camera.global_position = image.get_size() / 2

		free_and_clear(runes)
		free_and_clear(dots)
			
		rune_base_pos = null
		rune_bottom_pos = null
		mouse_down_global_pos = null
		mouse_down_camera_pos = null
		mouse_dragging = false

		yield(get_tree(), 'idle_frame')
		set_state(State.SELECT_BASELINE_START)


func free_and_clear(nodes):
	for node in nodes:
		node.queue_free()
	nodes.clear()


func update_canvas():
	canvas.texture = ImgUtil.texture_from(image if display_processed_image else original_image)


func _on_ParseButton_pressed():
	for rune in runes:
		rune.show_parse_result()


func _on_OpenButton_pressed():
	open_file()


func _on_ShowHideButton_pressed():
	show_translation = !show_translation
	
	show_hide_button.text = 'Hide Translation' if show_translation else 'Show Translation'
	
	for rune in runes:
		if show_translation:
			rune.show_parse_result()
		else:
			rune.hide_parse_result()


func _on_DetectModeButton_pressed():
	detect_mode = wrapi(detect_mode + 1, 0, DetectMode.size())
	detect_mode_button.text = 'OCR Mode: %s' % DETECT_MODE_NAMES[detect_mode]


func _on_ClearButton_pressed():
	free_and_clear(runes)
	free_and_clear(dots)
	rune_base_pos = null
	rune_bottom_pos = null


func _on_CalibrateContrastButton_pressed():
	set_state(State.SELECT_BACKGROUND_COLOR)


func _on_ToggleProcessedImageButton_pressed():
	display_processed_image = !display_processed_image
	toggle_processed_image_button.text = 'Show Original' if display_processed_image else 'Show Processed'
	update_canvas()


func _on_ToggleSlowOCRButton_pressed():
	slow_ocr = !slow_ocr
	toggle_slow_ocr_button.text = 'Disable Slow OCR' if slow_ocr else 'Enable Slow OCR'

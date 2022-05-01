extends Line2D
class_name RuneLine
tool


enum Status {
	DEFAULT = 0,
	DETECTED = 1,
}


export (Status) var status = Status.DEFAULT setget set_status


func _ready():
	update_color()


func set_status(value):
	status = value
	if is_inside_tree():
		update_color()


func update_color():
	if status == Status.DEFAULT:
		default_color = Color(1, 0, 0, 0.1)
	elif status == Status.DETECTED:
		default_color = Color.blue


func detect(img: Image):
	img.lock()

	var detected = true
	for i in range(10):
		var detector = get_node_or_null('Detector%s' % i)
		if detector != null:
			if ImgUtil.get_value_at(img, detector.global_position) > 0.5:
				detected = false
				break

	img.unlock()

	set_status(Status.DETECTED if detected else Status.DEFAULT)
	z_index = 1 if detected else 0

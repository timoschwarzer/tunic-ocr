extends Node


func texture_from(image: Image):
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture


func calculate_threshold(src: Image, threshold: float = 0.5, invert = false):
	var dst = Image.new()
	dst.create(src.get_width(), src.get_height(), false, Image.FORMAT_L8)

	src.lock()
	dst.lock()

	var foreground = Color.black if invert else Color.white
	var background = Color.white if invert else Color.black
	
	for x in range(src.get_width()):
		for y in range(src.get_height()):
			var pixel = src.get_pixel(x, y)
			dst.set_pixel(x, y, foreground if pixel.v > threshold else background)
			
	src.unlock()
	dst.unlock()
	return dst


func get_value_at(img: Image, pos: Vector2, neighbors = 2):
	var values = PoolRealArray()
	var x = pos.x
	var y = pos.y
	
	img.lock()
	for x_offset in range(-neighbors, neighbors):
		for y_offset in range(-neighbors, neighbors):
			var coords = Vector2(x + x_offset, y + y_offset)
			var size = img.get_size()

			if coords.x < 0 || coords.y < 0 || coords.x >= size.x || coords.y >= size.y:
				continue
			
			values.append(img.get_pixelv(coords).v)
	img.unlock()

	if values.size() == 0:
		return 0

	var total = 0.0
	for value in values:
		total += value
	return total / values.size()
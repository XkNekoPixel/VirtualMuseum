extends Panel

signal closed

func _ready():
	visible = false
	modulate.a = 0.0

func _get_screen() -> Vector2:
	return Vector2(DisplayServer.window_get_size())

func _is_portrait() -> bool:
	var screen = _get_screen()
	return screen.x < screen.y

func _setup_layout():
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame

	var screen = _get_screen()
	if _is_portrait():
		_build_portrait(screen)
	else:
		_build_landscape(screen)

	_add_close_button(screen)

func _add_close_button(screen: Vector2):
	var btn = Button.new()
	btn.name = "CloseButton"
	btn.text = "✕"
	var size = clamp(max(screen.x, screen.y) * 0.06, 36, 80)
	btn.custom_minimum_size = Vector2(size, size)
	btn.add_theme_font_size_override("font_size", int(size * 0.5))
	btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	btn.offset_left   = -size - 8
	btn.offset_top    = 8
	btn.offset_right  = -8
	btn.offset_bottom = size + 8
	btn.pressed.connect(_on_close)
	add_child(btn)

func _build_portrait(screen: Vector2):
	# Полный экран в портрете
	anchor_left   = 0.0
	anchor_top    = 0.0
	anchor_right  = 1.0
	anchor_bottom = 1.0
	offset_left   = 0.0
	offset_top    = 0.0
	offset_right  = 0.0
	offset_bottom = 0.0

	var dpi = clamp(screen.x / 400.0, 0.8, 2.5)

	var scroll = ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 0)
	scroll.add_child(vbox)

	# Картинка сверху — с полями по бокам, не обрезается
	var img_margin = MarginContainer.new()
	img_margin.add_theme_constant_override("margin_left",   int(screen.x * 0.04))
	img_margin.add_theme_constant_override("margin_right",  int(screen.x * 0.04))
	img_margin.add_theme_constant_override("margin_top",    int(screen.y * 0.02))
	img_margin.add_theme_constant_override("margin_bottom", 0)
	vbox.add_child(img_margin)

	var img = TextureRect.new()
	img.name = "Image"
	img.custom_minimum_size = Vector2(0, screen.y * 0.38)
	img.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT  # не обрезает
	img_margin.add_child(img)

	var pad = int(screen.x * 0.05)

	var title_margin = MarginContainer.new()
	title_margin.add_theme_constant_override("margin_left",   pad)
	title_margin.add_theme_constant_override("margin_right",  pad)
	title_margin.add_theme_constant_override("margin_top",    int(screen.y * 0.025))
	title_margin.add_theme_constant_override("margin_bottom", int(screen.y * 0.01))
	vbox.add_child(title_margin)

	var title = Label.new()
	title.name = "Title"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", int(22 * dpi))
	title_margin.add_child(title)

	var desc_margin = MarginContainer.new()
	desc_margin.add_theme_constant_override("margin_left",   pad)
	desc_margin.add_theme_constant_override("margin_right",  pad)
	desc_margin.add_theme_constant_override("margin_top",    int(screen.y * 0.01))
	desc_margin.add_theme_constant_override("margin_bottom", int(screen.y * 0.06))
	vbox.add_child(desc_margin)

	var desc = RichTextLabel.new()
	desc.name = "Description"
	desc.bbcode_enabled = true
	desc.fit_content = true
	desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc.add_theme_font_size_override("normal_font_size", int(16 * dpi))
	desc_margin.add_child(desc)

func _build_landscape(screen: Vector2):
	var dpi = clamp(screen.x / 1280.0, 0.7, 2.0)

	# Большая панель — 85% экрана
	var w = clamp(screen.x * 0.85, 500.0, 1200.0)
	var h = clamp(screen.y * 0.85, 350.0, 800.0)

	anchor_left   = 0.5
	anchor_top    = 0.5
	anchor_right  = 0.5
	anchor_bottom = 0.5
	offset_left   = -w * 0.5
	offset_top    = -h * 0.5
	offset_right  =  w * 0.5
	offset_bottom =  h * 0.5

	var margin = MarginContainer.new()
	margin.name = "Margin"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   int(w * 0.04))
	margin.add_theme_constant_override("margin_top",    int(h * 0.1))
	margin.add_theme_constant_override("margin_right",  int(w * 0.04))
	margin.add_theme_constant_override("margin_bottom", int(h * 0.04))
	add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.name = "HBox"
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", int(w * 0.03))
	margin.add_child(hbox)

	# Текст слева
	var scroll = ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	hbox.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", int(h * 0.03))
	scroll.add_child(vbox)

	var title = Label.new()
	title.name = "Title"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", int(24 * dpi))
	vbox.add_child(title)

	var desc = RichTextLabel.new()
	desc.name = "Description"
	desc.bbcode_enabled = true
	desc.fit_content = true
	desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc.add_theme_font_size_override("normal_font_size", int(16 * dpi))
	vbox.add_child(desc)

	# Картинка справа — не обрезается
	var img_margin = MarginContainer.new()
	img_margin.add_theme_constant_override("margin_top",    int(h * 0.02))
	img_margin.add_theme_constant_override("margin_bottom", int(h * 0.02))
	img_margin.add_theme_constant_override("margin_right",  int(w * 0.01))
	img_margin.size_flags_horizontal = Control.SIZE_SHRINK_END
	img_margin.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	hbox.add_child(img_margin)

	var img = TextureRect.new()
	img.name = "Image"
	img.custom_minimum_size = Vector2(w * 0.38, 0)
	img.size_flags_horizontal = Control.SIZE_SHRINK_END
	img.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	img.expand_mode  = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT  # не обрезает
	img_margin.add_child(img)

func show_info(title: String, description: String, image: Texture2D):
	_setup_layout()
	await get_tree().process_frame
	await get_tree().process_frame

	var title_node = find_child("Title",       true, false)
	var desc_node  = find_child("Description", true, false)
	var img_node   = find_child("Image",       true, false)

	if title_node:
		title_node.text = title
	if desc_node:
		desc_node.text = description
		desc_node.visible = description != ""
	if img_node:
		if image:
			img_node.texture = image
			img_node.visible = true
		else:
			img_node.visible = false

	visible = true
	# Плавное появление
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)

func _on_close():
	# Плавное исчезновение
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		visible = false
		modulate.a = 1.0
		emit_signal("closed")
	)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if visible:
			_on_close()

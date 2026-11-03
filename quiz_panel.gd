class_name QuizPanel
extends Control

const SpaceTheme = preload("res://space_theme.gd")
const QuizBank = preload("res://quiz_bank.gd")
# Pop-up modal kuis hidup-lagi bertema luar angkasa.
# Dibuat 100% via kode, responsif terhadap berbagai rasio layar,
# dan berjalan saat game di-pause (PROCESS_MODE_ALWAYS).

signal quiz_passed
signal quiz_failed

# Konstanta batas waktu dan animasi
const TIME_LIMIT = 30.0          # Batas waktu pengerjaan (detik)
const INPUT_LOCK_TIME = 0.8      # Jeda kunci input awal (detik)
const CARD_MAX_WIDTH = 420.0     # Lebar kartu maksimum (px)
const CARD_MAX_HEIGHT_RATIO = 0.88 # Rasio tinggi kartu maksimum terhadap viewport
const ANIM_IN_DURATION = 0.25    # Durasi kartu membesar saat muncul

# Node referensi UI
var _dim_rect: ColorRect
var _center_container: CenterContainer
var _card_panel: PanelContainer
var _scroll_container: ScrollContainer
var _content_box: VBoxContainer

var _title_label: Label
var _chip_panel: PanelContainer
var _chip_label: Label
var _sub_header_label: Label

var _progress_bar: ProgressBar
var _time_label: Label
var _question_label: Label
var _code_box: PanelContainer
var _code_label: Label

var _options_box: VBoxContainer
var _option_buttons: Array[Button] = []

var _result_box: VBoxContainer
var _result_label: Label
var _explain_label: Label
var _action_button: Button

# State pengerjaan kuis
var _current_wave: int = 1
var _time_remaining: float = TIME_LIMIT
var _is_active: bool = false
var _is_answered: bool = false
var _input_locked: bool = false
var _correct_option_index: int = 0
var _quiz_result_passed: bool = false
var _result_emitted: bool = false
var _anim_tween: Tween


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()

	_build_ui()
	get_viewport().size_changed.connect(_update_card_size)
	_update_card_size()


func _process(delta):
	if not _is_active or _is_answered:
		return

	_time_remaining -= delta
	if _time_remaining <= 0.0:
		_time_remaining = 0.0
		_on_timeout()
	_update_timer_display()


func _notification(what):
	# Mengabaikan tombol Back bawaan Android saat kuis tampil
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _is_active and visible:
			get_viewport().set_input_as_handled()


func _unhandled_input(event):
	if not _is_active or not visible or _is_answered or _input_locked:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var key_idx = -1
		match event.keycode:
			KEY_1, KEY_KP_1:
				key_idx = 0
			KEY_2, KEY_KP_2:
				key_idx = 1
			KEY_3, KEY_KP_3:
				key_idx = 2
			KEY_4, KEY_KP_4:
				key_idx = 3

		if key_idx >= 0 and key_idx < _option_buttons.size():
			get_viewport().set_input_as_handled()
			_on_option_selected(key_idx)


# Menampilkan modal kuis dengan soal acak dari QuizBank
func show_quiz(wave_number: int):
	_current_wave = wave_number
	_is_active = true
	_is_answered = false
	_input_locked = true
	_result_emitted = false
	_time_remaining = TIME_LIMIT

	# Ambil soal dari QuizBank
	var question_data = QuizBank.get_random_question()
	_populate_question(question_data)

	# Reset visual kartu & tombol hasil
	_result_box.hide()
	_options_box.show()
	_update_card_size()

	show()
	_play_open_animation()

	# Jeda kunci input 0,8 detik agar sentuhan saat mati tidak memicu jawaban
	_set_options_interactive(false)
	get_tree().create_timer(INPUT_LOCK_TIME, true, false, true).timeout.connect(func():
		if _is_active and not _is_answered:
			_input_locked = false
			_set_options_interactive(true)
	)


func _populate_question(data: Dictionary):
	var category = data.get("cat", "Logika")
	var q_text = data.get("q", "")
	var code_text = data.get("code", "")
	var raw_options = data.get("options", []).duplicate()
	var raw_answer_idx = data.get("answer", 0)
	var correct_answer_text = raw_options[raw_answer_idx]

	# Update header & chip
	_chip_label.text = category.to_upper()
	var chip_color = SpaceTheme.get_category_color(category)
	var chip_sb = SpaceTheme.create_button_style(chip_color, Color.TRANSPARENT, 6, 0)
	_chip_panel.add_theme_stylebox_override("panel", chip_sb)
	_sub_header_label.text = "Wave %d · Kesempatan 1x" % _current_wave

	# Update pertanyaan
	_question_label.text = q_text

	# Update kotak kode monospace jika ada
	if code_text != "":
		_code_label.text = code_text
		_code_box.show()
	else:
		_code_box.hide()

	# Acak urutan 4 opsi jawaban dan catat indeks jawaban benar
	var indices = [0, 1, 2, 3]
	indices.shuffle()
	_correct_option_index = indices.find(raw_answer_idx)

	for i in range(4):
		var orig_idx = indices[i]
		var opt_text = raw_options[orig_idx]
		var btn = _option_buttons[i]
		btn.text = "%d.  %s" % [i + 1, opt_text]
		btn.set_meta("original_index", orig_idx)
		btn.set_meta("is_correct", (orig_idx == raw_answer_idx))
		_reset_button_style(btn)

	# Simpan data penjelasan untuk akhir
	_explain_label.text = "Penjelasan: %s" % data.get("explain", "")


func _on_option_selected(button_index: int):
	if _is_answered or _input_locked:
		return
	_is_answered = true
	_set_options_interactive(false)

	var selected_btn = _option_buttons[button_index]
	var is_correct = selected_btn.get_meta("is_correct", false)
	_quiz_result_passed = is_correct

	# Warnai tombol: benar = hijau, salah = merah
	for i in range(_option_buttons.size()):
		var btn = _option_buttons[i]
		if btn.get_meta("is_correct", false):
			_set_button_state_style(btn, SpaceTheme.COLOR_CORRECT, Color(0.1, 0.4, 0.2, 0.95))
		elif i == button_index:
			_set_button_state_style(btn, SpaceTheme.COLOR_WRONG, Color(0.4, 0.1, 0.1, 0.95))

	_show_result_section(is_correct, false)


func _on_timeout():
	if _is_answered:
		return
	_is_answered = true
	_set_options_interactive(false)
	_quiz_result_passed = false

	# Tunjukkan jawaban yang benar saat waktu habis
	for btn in _option_buttons:
		if btn.get_meta("is_correct", false):
			_set_button_state_style(btn, SpaceTheme.COLOR_CORRECT, Color(0.1, 0.4, 0.2, 0.95))

	_show_result_section(false, true)


func _show_result_section(is_correct: bool, is_timeout: bool):
	if is_correct:
		_result_label.text = "Jawaban Benar! Anda kembali ke medan tempur."
		_result_label.add_theme_color_override("font_color", SpaceTheme.COLOR_CORRECT)
		_action_button.text = "Lanjut Main!"
		var action_sb = SpaceTheme.create_button_style(Color(0.1, 0.45, 0.25, 0.95), SpaceTheme.COLOR_CORRECT, 12, 2)
		_action_button.add_theme_stylebox_override("normal", action_sb)
		_play_success_feedback()
	else:
		if is_timeout:
			_result_label.text = "Waktu Habis! Kesempatan hidup lagi gagal."
		else:
			_result_label.text = "Jawaban Kurang Tepat!"
		_result_label.add_theme_color_override("font_color", SpaceTheme.COLOR_WRONG)
		_action_button.text = "Game Over"
		var action_sb = SpaceTheme.create_button_style(Color(0.45, 0.12, 0.12, 0.95), SpaceTheme.COLOR_WRONG, 12, 2)
		_action_button.add_theme_stylebox_override("normal", action_sb)
		_play_shake_feedback()

	_result_box.show()
	# Scroll ke bagian bawah agar tombol lanjut terlihat
	await get_tree().process_frame
	_scroll_container.scroll_vertical = int(_content_box.size.y)


func _on_action_button_pressed():
	if _result_emitted:
		return
	_result_emitted = true
	_play_close_animation()


func _finish_quiz():
	hide()
	_is_active = false
	if _quiz_result_passed:
		quiz_passed.emit()
	else:
		quiz_failed.emit()


# --- ANIMASI & FEEDBACK ---

func _play_open_animation():
	if _anim_tween:
		_anim_tween.kill()

	_anim_tween = create_tween().set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_dim_rect.modulate.a = 0.0
	_anim_tween.tween_property(_dim_rect, "modulate:a", 1.0, 0.15)

	_card_panel.scale = Vector2(0.85, 0.85)
	_card_panel.modulate.a = 0.0
	_anim_tween.tween_property(_card_panel, "scale", Vector2.ONE, ANIM_IN_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_anim_tween.tween_property(_card_panel, "modulate:a", 1.0, 0.2)


func _play_close_animation():
	if _anim_tween:
		_anim_tween.kill()

	_anim_tween = create_tween().set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_anim_tween.tween_property(_dim_rect, "modulate:a", 0.0, 0.15)
	_anim_tween.tween_property(_card_panel, "scale", Vector2(0.9, 0.9), 0.15)
	_anim_tween.tween_property(_card_panel, "modulate:a", 0.0, 0.15)
	_anim_tween.chain().tween_callback(_finish_quiz)


func _play_success_feedback():
	# Kilau hijau singkat pada kartu
	var flash_sb = SpaceTheme.create_card_style()
	flash_sb.border_color = SpaceTheme.COLOR_CORRECT
	flash_sb.set_border_width_all(3)
	_card_panel.add_theme_stylebox_override("panel", flash_sb)


func _play_shake_feedback():
	# Getaran horizontal kartu (±8 px)
	var orig_x = _card_panel.position.x
	var shake_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for offset in [8.0, -8.0, 6.0, -6.0, 3.0, 0.0]:
		shake_tween.tween_property(_card_panel, "position:x", orig_x + offset, 0.05)


func _update_timer_display():
	var ratio = _time_remaining / TIME_LIMIT
	_progress_bar.value = ratio * 100.0
	_time_label.text = "%ds" % int(ceil(_time_remaining))

	var fill_sb = StyleBoxFlat.new()
	fill_sb.set_corner_radius_all(3)

	if _time_remaining <= 5.0:
		# Berkedip merah di 5 detik terakhir
		var blink = (sin(Time.get_ticks_msec() * 0.015) + 1.0) * 0.5
		fill_sb.bg_color = SpaceTheme.COLOR_WRONG.lerp(Color.WHITE, blink * 0.4)
		_time_label.add_theme_color_override("font_color", SpaceTheme.COLOR_WRONG)
	elif _time_remaining <= 12.0:
		fill_sb.bg_color = SpaceTheme.COLOR_WARNING
		_time_label.add_theme_color_override("font_color", SpaceTheme.COLOR_WARNING)
	else:
		fill_sb.bg_color = SpaceTheme.COLOR_CORRECT
		_time_label.add_theme_color_override("font_color", SpaceTheme.COLOR_TEXT_PRIMARY)

	_progress_bar.add_theme_stylebox_override("fill", fill_sb)


func _update_card_size():
	var vp_size = get_viewport().get_visible_rect().size
	var target_w = min(vp_size.x - 32.0, CARD_MAX_WIDTH)
	var max_h = vp_size.y * CARD_MAX_HEIGHT_RATIO

	if _card_panel:
		_card_panel.custom_minimum_size = Vector2(target_w, 0)
	if _scroll_container:
		_scroll_container.custom_minimum_size = Vector2(target_w - 40.0, 0)
		_scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Letakkan pivot di tengah kartu untuk animasi scale
	if _card_panel:
		_card_panel.pivot_offset = Vector2(target_w * 0.5, _card_panel.size.y * 0.5)


func _set_options_interactive(enable: bool):
	for btn in _option_buttons:
		btn.disabled = not enable
		btn.modulate.a = 1.0 if enable else 0.55


func _reset_button_style(btn: Button):
	var normal_sb = SpaceTheme.create_button_style(Color(0.10, 0.14, 0.25, 0.90), SpaceTheme.COLOR_ACCENT_CYAN, 12, 1)
	var hover_sb = SpaceTheme.create_button_style(Color(0.15, 0.22, 0.38, 0.95), SpaceTheme.COLOR_ACCENT_CYAN, 12, 2)
	var pressed_sb = SpaceTheme.create_button_style(Color(0.08, 0.35, 0.45, 0.98), SpaceTheme.COLOR_ACCENT_CYAN, 12, 2)
	var disabled_sb = SpaceTheme.create_button_style(Color(0.08, 0.10, 0.18, 0.60), Color(0.2, 0.25, 0.35, 0.4), 12, 1)

	btn.add_theme_stylebox_override("normal", normal_sb)
	btn.add_theme_stylebox_override("hover", hover_sb)
	btn.add_theme_stylebox_override("pressed", pressed_sb)
	btn.add_theme_stylebox_override("focus", hover_sb)
	btn.add_theme_stylebox_override("disabled", disabled_sb)
	btn.add_theme_color_override("font_color", SpaceTheme.COLOR_TEXT_PRIMARY)
	btn.add_theme_color_override("font_hover_color", SpaceTheme.COLOR_GOLD)
	btn.add_theme_color_override("font_disabled_color", SpaceTheme.COLOR_TEXT_MUTED)


func _set_button_state_style(btn: Button, border_color: Color, bg_color: Color):
	var sb = SpaceTheme.create_button_style(bg_color, border_color, 12, 2)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("disabled", sb)
	btn.add_theme_color_override("font_disabled_color", SpaceTheme.COLOR_TEXT_PRIMARY)
	btn.modulate.a = 1.0


# --- MEMBANGUN STRUKTUR UI SECARA KODIFIKASI ---

func _build_ui():
	# 1. Lapisan Dim (Semi-transparan hitam pekat)
	_dim_rect = ColorRect.new()
	_dim_rect.name = "DimLayer"
	_dim_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim_rect.color = Color(0.0, 0.0, 0.0, 0.60)
	_dim_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim_rect)

	# 2. Container Tengah
	_center_container = CenterContainer.new()
	_center_container.name = "CenterWrapper"
	_center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_center_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_center_container)

	# 3. Kartu Dialog (PanelContainer)
	_card_panel = PanelContainer.new()
	_card_panel.name = "CardPanel"
	_card_panel.add_theme_stylebox_override("panel", SpaceTheme.create_card_style())
	_card_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_center_container.add_child(_card_panel)

	# 4. ScrollContainer
	_scroll_container = ScrollContainer.new()
	_scroll_container.name = "CardScroll"
	_scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_card_panel.add_child(_scroll_container)

	# 5. VBox Isi Kartu
	_content_box = VBoxContainer.new()
	_content_box.name = "ContentBox"
	_content_box.add_theme_constant_override("separation", 12)
	_content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll_container.add_child(_content_box)

	# Header: Judul + Chip Kategori
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)

	_title_label = Label.new()
	_title_label.text = "Hidup Lagi?"
	_title_label.add_theme_font_override("font", preload("res://fonts/Xolonium-Regular.ttf"))
	_title_label.add_theme_font_size_override("font_size", 20)
	_title_label.add_theme_color_override("font_color", SpaceTheme.COLOR_GOLD)
	header_hbox.add_child(_title_label)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	_chip_panel = PanelContainer.new()
	_chip_label = Label.new()
	_chip_label.add_theme_font_override("font", preload("res://fonts/Xolonium-Regular.ttf"))
	_chip_label.add_theme_font_size_override("font_size", 12)
	_chip_label.add_theme_color_override("font_color", Color.WHITE)
	_chip_panel.add_child(_chip_label)
	header_hbox.add_child(_chip_panel)
	_content_box.add_child(header_hbox)

	_sub_header_label = Label.new()
	_sub_header_label.text = "Wave 1 · Kesempatan 1x"
	_sub_header_label.add_theme_font_override("font", preload("res://fonts/Xolonium-Regular.ttf"))
	_sub_header_label.add_theme_font_size_override("font_size", 13)
	_sub_header_label.add_theme_color_override("font_color", SpaceTheme.COLOR_TEXT_MUTED)
	_content_box.add_child(_sub_header_label)

	# Timer Bar HBox
	var timer_hbox = HBoxContainer.new()
	timer_hbox.add_theme_constant_override("separation", 8)

	_progress_bar = ProgressBar.new()
	_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress_bar.custom_minimum_size.y = 8.0
	_progress_bar.show_percentage = false
	var bg_sb = StyleBoxFlat.new()
	bg_sb.bg_color = Color(0.12, 0.15, 0.25, 0.8)
	bg_sb.set_corner_radius_all(3)
	_progress_bar.add_theme_stylebox_override("background", bg_sb)
	timer_hbox.add_child(_progress_bar)

	_time_label = Label.new()
	_time_label.text = "30s"
	_time_label.add_theme_font_override("font", preload("res://fonts/Xolonium-Regular.ttf"))
	_time_label.add_theme_font_size_override("font_size", 14)
	timer_hbox.add_child(_time_label)
	_content_box.add_child(timer_hbox)

	# Pertanyaan
	_question_label = Label.new()
	_question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_question_label.add_theme_font_override("font", preload("res://fonts/Xolonium-Regular.ttf"))
	_question_label.add_theme_font_size_override("font_size", 18)
	_question_label.add_theme_color_override("font_color", SpaceTheme.COLOR_TEXT_PRIMARY)
	_content_box.add_child(_question_label)

	# Kotak Kode Monospace
	_code_box = PanelContainer.new()
	_code_box.add_theme_stylebox_override("panel", SpaceTheme.create_code_box_style())
	_code_label = Label.new()
	_code_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var sys_font = SystemFont.new()
	sys_font.font_names = PackedStringArray(["Menlo", "Courier New", "monospace"])
	_code_label.add_theme_font_override("font", sys_font)
	_code_label.add_theme_font_size_override("font_size", 15)
	_code_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	_code_box.add_child(_code_label)
	_content_box.add_child(_code_box)

	# Opsi Jawaban (4 Tombol)
	_options_box = VBoxContainer.new()
	_options_box.add_theme_constant_override("separation", 8)
	for i in range(4):
		var btn = Button.new()
		btn.custom_minimum_size.y = 52.0
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_override("font", preload("res://fonts/Xolonium-Regular.ttf"))
		btn.add_theme_font_size_override("font_size", 15)
		var idx = i
		btn.pressed.connect(func(): _on_option_selected(idx))
		_options_box.add_child(btn)
		_option_buttons.append(btn)
	_content_box.add_child(_options_box)

	# Bagian Hasil & Tombol Lanjut
	_result_box = VBoxContainer.new()
	_result_box.add_theme_constant_override("separation", 10)

	_result_label = Label.new()
	_result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_result_label.add_theme_font_override("font", preload("res://fonts/Xolonium-Regular.ttf"))
	_result_label.add_theme_font_size_override("font_size", 16)
	_result_box.add_child(_result_label)

	_explain_label = Label.new()
	_explain_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_explain_label.add_theme_font_override("font", preload("res://fonts/Xolonium-Regular.ttf"))
	_explain_label.add_theme_font_size_override("font_size", 14)
	_explain_label.add_theme_color_override("font_color", SpaceTheme.COLOR_TEXT_MUTED)
	_result_box.add_child(_explain_label)

	_action_button = Button.new()
	_action_button.custom_minimum_size.y = 52.0
	_action_button.add_theme_font_override("font", preload("res://fonts/Xolonium-Regular.ttf"))
	_action_button.add_theme_font_size_override("font_size", 18)
	_action_button.pressed.connect(_on_action_button_pressed)
	_result_box.add_child(_action_button)

	_content_box.add_child(_result_box)

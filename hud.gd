extends CanvasLayer

signal start_game

# Label indikator wave (dibuat via kode)
var wave_label: Label

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$MessageTimer.process_mode = Node.PROCESS_MODE_PAUSABLE
	_setup_wave_label()
	# Saat game dibuka, tampilkan high score yang tersimpan di layar judul.
	update_high_score(SaveManager.highest_score)


func _setup_wave_label():
	wave_label = Label.new()
	wave_label.name = "WaveLabel"
	wave_label.offset_left = 20.0
	wave_label.offset_top = 20.0
	wave_label.offset_right = 200.0
	wave_label.offset_bottom = 60.0
	wave_label.add_theme_font_override("font", preload("res://fonts/Xolonium-Regular.ttf"))
	wave_label.add_theme_font_size_override("font_size", 24)
	wave_label.hide()
	add_child(wave_label)


func update_wave(current_wave, max_wave = 10):
	if current_wave > 0:
		wave_label.text = "Wave %d/%d" % [current_wave, max_wave]
		wave_label.show()
	else:
		wave_label.hide()

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()


func show_game_over(new_record = false):
	update_wave(0)
	show_message("High Score\nBaru!" if new_record else "Game Over")
	await $MessageTimer.timeout
	$MessageLabel.text = "Dodge 'em\nAll"
	$MessageLabel.show()
	$HighScoreLabel.show()  # tampil lagi di layar judul
	await get_tree().create_timer(1).timeout
	$StartButton.show()


func update_score(score):
	$ScoreLabel.text = str(score)

func update_high_score(value):
	$HighScoreLabel.text = "Best: %d" % value

func _on_StartButton_pressed():
	$StartButton.hide()
	$HighScoreLabel.hide()  # sembunyikan selama bermain supaya layar bersih
	start_game.emit()


func _on_MessageTimer_timeout():
	$MessageLabel.hide()

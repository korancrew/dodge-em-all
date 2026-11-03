extends CanvasLayer

signal start_game
signal game_resumed
signal quit_to_menu

var playing = false
var _message_was_visible = false
const TITLE_TEXT = "Dodge 'em\nAll"


func _ready():
	# Saat game dibuka, tampilkan high score yang tersimpan di layar judul.
	update_high_score(SaveManager.highest_score)
	$PauseButton.hide()
	$PausePanel.hide()
	$CreditsPanel.hide()
	$CreditsButton.show()


func show_message(text, duration = 1.0):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start(duration)


func show_game_over(new_record = false):
	playing = false
	$PauseButton.hide()
	$PausePanel.hide()
	show_message("High Score\nBaru!" if new_record else "Game Over")
	await $MessageTimer.timeout
	show_title()


func show_title():
	playing = false
	$PauseButton.hide()
	$PausePanel.hide()
	$CreditsPanel.hide()
	$MessageTimer.stop()
	$MessageLabel.text = TITLE_TEXT
	$MessageLabel.show()
	$HighScoreLabel.show()  # tampil lagi di layar judul
	$CreditsButton.hide()
	await get_tree().create_timer(1, false).timeout
	if not playing:
		$StartButton.show()
		$CreditsButton.show()


func update_score(score):
	$ScoreLabel.text = str(score)


func update_high_score(value):
	$HighScoreLabel.text = "Best: %d" % value


func _on_StartButton_pressed():
	$StartButton.hide()
	$CreditsButton.hide()
	$HighScoreLabel.hide()  # sembunyikan selama bermain supaya layar bersih
	$PauseButton.show()
	playing = true
	start_game.emit()


func _on_CreditsButton_pressed():
	$StartButton.hide()
	$CreditsButton.hide()
	$HighScoreLabel.hide()
	$MessageLabel.hide()
	$CreditsPanel.play()


func _on_credits_finished():
	if not playing:
		$MessageLabel.show()
		$HighScoreLabel.show()
		$StartButton.show()
		$CreditsButton.show()


func _on_MessageTimer_timeout():
	$MessageLabel.hide()


# ---------------- Pause ----------------
func pause_game():
	if not playing or get_tree().paused or $CreditsPanel.visible:
		return
	get_tree().paused = true
	_message_was_visible = $MessageLabel.visible
	$MessageLabel.hide()
	$PauseButton.hide()
	$PausePanel.show()


func resume_game():
	if not $PausePanel.visible:
		return
	get_tree().paused = false
	$PausePanel.hide()
	if playing:
		$PauseButton.show()
		$MessageLabel.visible = _message_was_visible
	game_resumed.emit()


func _toggle_pause():
	if $PausePanel.visible:
		resume_game()
	else:
		pause_game()


func _on_pause_button_pressed():
	pause_game()


func _on_resume_button_pressed():
	resume_game()


func _on_quit_button_pressed():
	get_tree().paused = false
	$PausePanel.hide()
	playing = false
	quit_to_menu.emit()


func _unhandled_input(event):
	# Esc (keyboard) atau tombol Start (gamepad): pause / lanjut / tutup credit.
	if event.is_action_pressed(&"pause"):
		if $CreditsPanel.visible:
			$CreditsPanel.skip()
		else:
			_toggle_pause()
		get_viewport().set_input_as_handled()


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		# Tombol Back Android:
		if $CreditsPanel.visible:
			$CreditsPanel.skip()
		elif get_tree().paused:
			resume_game()
		elif playing:
			pause_game()
		else:
			get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		# Pause otomatis saat aplikasi kehilangan fokus.
		pause_game()

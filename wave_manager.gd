class_name WaveManager
extends Node
# Pengatur sistem wave minimal untuk Dodge 'em All.
# Mengatur 10 wave, 3 sub-wave per wave, interval spawn dinamis,
# dan komposisi musuh Walker vs Swimmer.

signal wave_started(wave)
signal subwave_started(wave, subwave)
signal subwave_ended(wave, subwave)
signal wave_cleared(wave)
signal game_won

# Konstanta aturan permainan
const MAX_WAVES = 10
const SUBWAVES_PER_WAVE = 3
const SUBWAVE_DURATION = 20.0       # durasi aktif musuh muncul per sub-wave (detik)
const SUBWAVE_REST_DURATION = 2.0  # jeda istirahat antar sub-wave (detik)
const WAVE_TRANSITION_DELAY = 2.0  # jeda pengumuman wave baru / selesai (detik)

# Scene musuh
@export var walker_scene: PackedScene = preload("res://enemies/walker.tscn")
@export var swimmer_scene: PackedScene = preload("res://enemies/swimmer.tscn")

var wave = 1
var max_wave = MAX_WAVES
var subwave = 1
var is_running = false

# Internal state: "idle", "wave_prepare", "subwave_active", "subwave_rest", "wave_cleared", "game_won"
var _state = "idle"
var _timer = 0.0


func start_waves():
	wave = 1
	subwave = 1
	is_running = true
	_prepare_wave()


func stop():
	is_running = false
	_state = "idle"
	_timer = 0.0


func _prepare_wave():
	_state = "wave_prepare"
	_timer = WAVE_TRANSITION_DELAY
	wave_started.emit(wave)


func _process(delta):
	if not is_running:
		return

	_timer -= delta
	if _timer <= 0:
		_on_timer_finished()


func _on_timer_finished():
	match _state:
		"wave_prepare":
			_start_subwave(1)
		"subwave_active":
			subwave_ended.emit(wave, subwave)
			if subwave < SUBWAVES_PER_WAVE:
				_state = "subwave_rest"
				_timer = SUBWAVE_REST_DURATION
			else:
				_state = "wave_cleared"
				_timer = WAVE_TRANSITION_DELAY
				wave_cleared.emit(wave)
		"subwave_rest":
			subwave += 1
			_start_subwave(subwave)
		"wave_cleared":
			if wave < MAX_WAVES:
				wave += 1
				subwave = 1
				_prepare_wave()
			else:
				_state = "game_won"
				is_running = false
				game_won.emit()


func _start_subwave(sw):
	subwave = sw
	_state = "subwave_active"
	_timer = SUBWAVE_DURATION
	subwave_started.emit(wave, subwave)


# Interval spawn = max(0,2; 0,6 × 0,9^(wave−1)) detik
func get_spawn_interval() -> float:
	return max(0.2, 0.6 * pow(0.9, wave - 1))


# Kecepatan musuh = acak(150, 250) × (1 + 0,1 × (wave−1))
func get_enemy_speed() -> float:
	var base_speed = randf_range(150.0, 250.0)
	var multiplier = 1.0 + 0.1 * (wave - 1)
	return base_speed * multiplier


# Rasio Swimmer vs Walker per wave (Wave 1: 15% Swimmer, bertahap hingga Wave 10: 80% Swimmer)
func get_swimmer_chance() -> float:
	return clamp(0.15 + (wave - 1) * 0.072, 0.15, 0.8)


# Membuat instance musuh sesuai proporsi wave
func create_enemy() -> Mob:
	var use_swimmer = randf() < get_swimmer_chance()
	var scene = swimmer_scene if use_swimmer else walker_scene
	return scene.instantiate()

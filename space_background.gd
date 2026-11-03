class_name SpaceBackground
extends CanvasLayer
# Latar luar angkasa prosedural untuk Dodge 'em All.
# Memiliki lapisan gradien langit, awan nebula halus,
# 3 lapis partikel bintang parallax, planet/bulan jauh, dan asteroid melintas lambat.

# Sakelar performa untuk perangkat low-end / Android
const ENABLE_NEBULA_SHADER = true
const ENABLE_CELESTIAL_BODIES = true

# Konfigurasi partikel bintang parallax (jauh, tengah, dekat)
# Total bintang = 40 + 30 + 20 = 90 partikel (di bawah batas 100)
const STAR_COUNTS = [40, 30, 20]
const PARALLAX_SPEEDS = [15.0, 35.0, 70.0]  # kecepatan scroll turun (px/detik)

# Warna tema dasar (Wave 1-3: Biru-Ungu tenang)
const DEFAULT_TOP_COLOR = Color(0.02, 0.02, 0.08, 1.0)
const DEFAULT_BOTTOM_COLOR = Color(0.06, 0.05, 0.16, 1.0)
const DEFAULT_NEBULA_1 = Color(0.18, 0.06, 0.28, 0.16)
const DEFAULT_NEBULA_2 = Color(0.04, 0.20, 0.26, 0.14)

# Node referensi internal
var _gradient_rect: ColorRect
var _gradient_material: ShaderMaterial
var _nebula_rect: ColorRect
var _nebula_material: ShaderMaterial
var _star_layers: Array[CPUParticles2D] = []
var _celestial_node: Node2D
var _asteroid_node: Node2D

# State posisi benda langit & asteroid
var _planet_pos = Vector2(370, 160)
var _moon_pos = Vector2(85, 430)
var _asteroid_pos = Vector2(100, -50)
var _asteroid_rot = 0.0
var _asteroid_vel = Vector2(12.0, 24.0)


func _ready():
	layer = -1
	_build_gradient_layer()
	_build_nebula_layer()
	_build_star_layers()
	_build_celestial_layer()
	_build_asteroid_layer()

	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()


func _process(delta):
	# Pergerakan sangat lambat planet & bulan
	_planet_pos += Vector2(-1.0, 2.0) * delta
	_moon_pos += Vector2(0.8, 1.5) * delta

	var vp_size = get_viewport().get_visible_rect().size
	if _planet_pos.y > vp_size.y + 100:
		_planet_pos.y = -100
		_planet_pos.x = randf_range(100, vp_size.x - 50)
	if _moon_pos.y > vp_size.y + 60:
		_moon_pos.y = -60
		_moon_pos.x = randf_range(40, vp_size.x - 40)

	# Pergerakan asteroid melintas lambat
	_asteroid_pos += _asteroid_vel * delta
	_asteroid_rot += 0.4 * delta
	if _asteroid_pos.y > vp_size.y + 60 or _asteroid_pos.x > vp_size.x + 60:
		_asteroid_pos = Vector2(randf_range(20, vp_size.x * 0.7), -40)
		_asteroid_vel = Vector2(randf_range(8.0, 18.0), randf_range(20.0, 35.0))

	if _celestial_node:
		_celestial_node.queue_redraw()
	if _asteroid_node:
		_asteroid_node.queue_redraw()


func _on_viewport_size_changed():
	var vp_size = get_viewport().get_visible_rect().size
	if _gradient_rect:
		_gradient_rect.size = vp_size
	if _nebula_rect:
		_nebula_rect.size = vp_size

	for i in range(_star_layers.size()):
		var layer_node = _star_layers[i]
		if is_instance_valid(layer_node):
			layer_node.position = vp_size * 0.5
			layer_node.emission_rect_extents = vp_size * 0.5
			var speed = PARALLAX_SPEEDS[i]
			layer_node.lifetime = max(4.0, vp_size.y / speed)


func _build_gradient_layer():
	_gradient_rect = ColorRect.new()
	_gradient_rect.name = "SkyGradient"
	_gradient_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;
	render_mode unshaded;

	uniform vec4 top_color : source_color = vec4(0.02, 0.02, 0.08, 1.0);
	uniform vec4 bottom_color : source_color = vec4(0.06, 0.05, 0.16, 1.0);

	void fragment() {
		COLOR = mix(top_color, bottom_color, UV.y);
	}
	"""
	_gradient_material = ShaderMaterial.new()
	_gradient_material.shader = shader
	_gradient_material.set_shader_parameter("top_color", DEFAULT_TOP_COLOR)
	_gradient_material.set_shader_parameter("bottom_color", DEFAULT_BOTTOM_COLOR)
	_gradient_rect.material = _gradient_material
	add_child(_gradient_rect)


func _build_nebula_layer():
	if not ENABLE_NEBULA_SHADER:
		return

	_nebula_rect = ColorRect.new()
	_nebula_rect.name = "NebulaLayer"
	_nebula_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;
	render_mode unshaded;

	uniform vec4 nebula_color1 : source_color = vec4(0.18, 0.06, 0.28, 0.16);
	uniform vec4 nebula_color2 : source_color = vec4(0.04, 0.20, 0.26, 0.14);
	uniform float time_speed = 0.035;

	void fragment() {
		vec2 uv = UV * 2.5;
		float t = TIME * time_speed;
		float n1 = sin(uv.x * 2.8 + t * 0.7) * cos(uv.y * 2.2 - t * 0.5);
		float n2 = sin(uv.x * 1.5 - t * 0.4) * cos(uv.y * 3.4 + t * 0.8);
		float shape = smoothstep(-0.35, 0.65, n1 + n2 * 0.5);
		vec4 col = mix(nebula_color1, nebula_color2, sin(uv.y * 1.8 + t) * 0.5 + 0.5);
		COLOR = vec4(col.rgb, col.a * shape);
	}
	"""
	_nebula_material = ShaderMaterial.new()
	_nebula_material.shader = shader
	_nebula_material.set_shader_parameter("nebula_color1", DEFAULT_NEBULA_1)
	_nebula_material.set_shader_parameter("nebula_color2", DEFAULT_NEBULA_2)
	_nebula_rect.material = _nebula_material
	add_child(_nebula_rect)


func _build_star_layers():
	var star_tex = _generate_star_texture(6)
	var sizes = [1.2, 1.8, 2.6]
	var alphas = [0.45, 0.70, 0.95]

	for i in range(3):
		var p = CPUParticles2D.new()
		p.name = "StarField_%d" % i
		p.texture = star_tex
		p.amount = STAR_COUNTS[i]
		p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		p.direction = Vector2(0, 1) # Turun ke bawah
		p.spread = 0.0
		p.gravity = Vector2.ZERO
		p.initial_velocity_min = PARALLAX_SPEEDS[i] * 0.9
		p.initial_velocity_max = PARALLAX_SPEEDS[i] * 1.1
		p.scale_amount_min = sizes[i] * 0.7
		p.scale_amount_max = sizes[i] * 1.3
		p.color = Color(1.0, 1.0, 1.0, alphas[i])

		# Ramp alpha untuk efek kelap-kelip halus (twinkle)
		var gradient = Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, alphas[i] * 0.3))
		gradient.add_point(0.25, Color(1, 1, 1, alphas[i] * 1.0))
		gradient.add_point(0.50, Color(1, 1, 1, alphas[i] * 0.4))
		gradient.add_point(0.75, Color(1, 1, 1, alphas[i] * 0.9))
		gradient.set_color(1, Color(1, 1, 1, alphas[i] * 0.3))
		p.color_ramp = gradient

		p.lifetime = 12.0
		p.preprocess = 12.0
		add_child(p)
		_star_layers.append(p)


func _build_celestial_layer():
	if not ENABLE_CELESTIAL_BODIES:
		return

	_celestial_node = Node2D.new()
	_celestial_node.name = "CelestialBodies"
	_celestial_node.draw.connect(_on_draw_celestial)
	add_child(_celestial_node)


func _on_draw_celestial():
	# Gambar Planet besar (redup, kontras rendah agar tidak mengganggu gameplay)
	var p_rad = 54.0
	# Lingkaran dasar gelap
	_celestial_node.draw_circle(_planet_pos, p_rad, Color(0.10, 0.12, 0.22, 0.55))
	# Sisi highlight lembut bulan sabit
	_celestial_node.draw_circle(_planet_pos + Vector2(-8, -8), p_rad * 0.85, Color(0.16, 0.22, 0.38, 0.35))
	# Cincin tipis miring pudar
	var ring_color = Color(0.25, 0.35, 0.50, 0.22)
	for r in range(2):
		_celestial_node.draw_arc(_planet_pos, p_rad + 18.0 + r * 6.0, -0.6, 2.5, 32, ring_color, 2.0)

	# Gambar Bulan kecil pudar
	var m_rad = 18.0
	_celestial_node.draw_circle(_moon_pos, m_rad, Color(0.18, 0.14, 0.25, 0.45))
	_celestial_node.draw_circle(_moon_pos + Vector2(-3, -3), m_rad * 0.75, Color(0.28, 0.22, 0.38, 0.25))


func _build_asteroid_layer():
	_asteroid_node = Node2D.new()
	_asteroid_node.name = "DistantAsteroids"
	_asteroid_node.draw.connect(_on_draw_asteroids)
	add_child(_asteroid_node)


func _on_draw_asteroids():
	# Siluet asteroid kecil buram melintas lambat (kontras rendah)
	var poly = PackedVector2Array([
		Vector2(-10, -5), Vector2(-4, -12), Vector2(6, -9),
		Vector2(12, -2), Vector2(9, 8), Vector2(-2, 11), Vector2(-11, 4)
	])
	# Transform rotasi dan translasi
	var transformed_poly = PackedVector2Array()
	var cos_a = cos(_asteroid_rot)
	var sin_a = sin(_asteroid_rot)
	for pt in poly:
		var rotated = Vector2(pt.x * cos_a - pt.y * sin_a, pt.x * sin_a + pt.y * cos_a)
		transformed_poly.append(_asteroid_pos + rotated)

	_asteroid_node.draw_colored_polygon(transformed_poly, Color(0.16, 0.15, 0.24, 0.35))


# Menghasilkan tekstur lingkaran lembut prosedural untuk bintang tanpa aset eksternal
func _generate_star_texture(radius: int) -> ImageTexture:
	var diameter = radius * 2
	var img = Image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
	var center = Vector2(radius, radius)
	for y in range(diameter):
		for x in range(diameter):
			var dist = center.distance_to(Vector2(x + 0.5, y + 0.5))
			var a = clamp(1.0 - (dist / float(radius)), 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, a * a))
	return ImageTexture.create_from_image(img)

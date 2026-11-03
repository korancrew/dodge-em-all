class_name SpaceTheme
extends RefCounted
# Sumber tunggal palet warna dan pembuat StyleBox/Theme bertema luar angkasa
# Digunakan secara konsisten oleh Latar, HUD, dan Pop-Up Kuis.

# Palet warna dasar
const COLOR_BG_CARD = Color(0.07, 0.09, 0.16, 0.95)       # Navy gelap latar modal
const COLOR_BG_CODE = Color(0.03, 0.04, 0.08, 0.95)       # Latar blok kode monospace
const COLOR_ACCENT_CYAN = Color(0.15, 0.88, 0.95, 1.0)     # Cyan neon aksen / border
const COLOR_ACCENT_PURPLE = Color(0.55, 0.35, 0.90, 1.0)   # Ungu neon sekunder
const COLOR_GOLD = Color(1.0, 0.84, 0.25, 1.0)             # Emas judul / bintang / highlight
const COLOR_CORRECT = Color(0.20, 0.82, 0.38, 1.0)         # Hijau jawaban benar
const COLOR_WRONG = Color(0.92, 0.28, 0.28, 1.0)           # Merah jawaban salah / batas waktu
const COLOR_WARNING = Color(0.95, 0.75, 0.18, 1.0)         # Kuning peringatan waktu

# Warna chip kategori kuis
const COLOR_CAT_LOGIC = Color(0.60, 0.40, 0.95, 1.0)       # Ungu Logika
const COLOR_CAT_PYTHON = Color(0.22, 0.68, 0.95, 1.0)      # Biru Python
const COLOR_CAT_JS = Color(0.95, 0.82, 0.20, 1.0)          # Kuning JavaScript
const COLOR_CAT_HTML = Color(0.95, 0.45, 0.20, 1.0)        # Oranye HTML

# Teks & bayangan
const COLOR_TEXT_PRIMARY = Color(0.96, 0.97, 1.0, 1.0)
const COLOR_TEXT_MUTED = Color(0.65, 0.72, 0.82, 1.0)
const COLOR_TEXT_OUTLINE = Color(0.02, 0.03, 0.06, 0.95)


# Membuat StyleBoxFlat serbaguna untuk tombol
static func create_button_style(bg_col: Color, border_col: Color = Color.TRANSPARENT, corner_rad: int = 12, border_w: int = 0) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_color = border_col
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(corner_rad)
	sb.content_margin_left = 16.0
	sb.content_margin_right = 16.0
	sb.content_margin_top = 10.0
	sb.content_margin_bottom = 10.0
	return sb


# Membuat StyleBoxFlat untuk kartu pop-up kuis
static func create_card_style() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = COLOR_BG_CARD
	sb.border_color = COLOR_ACCENT_CYAN
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	sb.shadow_size = 14
	sb.shadow_offset = Vector2(0, 4)
	sb.content_margin_left = 20.0
	sb.content_margin_right = 20.0
	sb.content_margin_top = 18.0
	sb.content_margin_bottom = 18.0
	return sb


# Membuat StyleBoxFlat untuk kotak kode monospace
static func create_code_box_style() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = COLOR_BG_CODE
	sb.border_color = Color(0.25, 0.32, 0.48, 0.6)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 10.0
	sb.content_margin_bottom = 10.0
	return sb


# Membuat StyleBoxFlat untuk chip pill kategori kuis
static func create_chip_style(bg_col: Color) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10.0
	sb.content_margin_right = 10.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
	return sb


# Mengembalikan warna chip kategori kuis
static func get_category_color(category: String) -> Color:
	match category.to_lower():
		"logika":
			return COLOR_CAT_LOGIC
		"python":
			return COLOR_CAT_PYTHON
		"javascript", "js":
			return COLOR_CAT_JS
		"html":
			return COLOR_CAT_HTML
		_:
			return COLOR_ACCENT_CYAN

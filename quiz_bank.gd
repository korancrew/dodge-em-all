class_name QuizBank
extends RefCounted
# Bank soal kuis hidup-lagi untuk Dodge 'em All.
# Format tiap soal (Dictionary):
#   "cat": Kategori ("Logika" / "Python" / "JavaScript" / "HTML")
#   "q": Kalimat pertanyaan
#   "code": Potongan kode program pendek (opsional / string kosong jika tidak ada)
#   "options": Array berisi 4 string pilihan jawaban yang unik
#   "answer": Indeks jawaban yang benar (0, 1, 2, atau 3)
#   "explain": Penjelasan singkat 1–2 kalimat dalam Bahasa Indonesia

const QUESTIONS = [
	# --- KATEGORI: LOGIKA (12 Soal) ---
	{
		"cat": "Logika",
		"q": "Berapa angka berikutnya dari deret: 2, 4, 8, 16, ...?",
		"code": "",
		"options": ["32", "24", "30", "64"],
		"answer": 0,
		"explain": "Setiap angka merupakan hasil kali 2 dari angka sebelumnya (16 × 2 = 32)."
	},
	{
		"cat": "Logika",
		"q": "Berapa angka berikutnya dari deret: 3, 7, 11, 15, ...?",
		"code": "",
		"options": ["19", "18", "20", "17"],
		"answer": 0,
		"explain": "Pola deret bertambah 4 pada setiap langkah (15 + 4 = 19)."
	},
	{
		"cat": "Logika",
		"q": "Berapa angka berikutnya dari deret: 100, 95, 90, 85, ...?",
		"code": "",
		"options": ["80", "75", "82", "70"],
		"answer": 0,
		"explain": "Pola deret berkurang 5 pada setiap langkah (85 - 5 = 80)."
	},
	{
		"cat": "Logika",
		"q": "Huruf apakah selanjutnya dari deret: A, C, E, G, ...?",
		"code": "",
		"options": ["I", "H", "J", "K"],
		"answer": 0,
		"explain": "Pola melompati satu huruf dalam abjad alfabet (A, [B], C, [D], E, [F], G, [H], I)."
	},
	{
		"cat": "Logika",
		"q": "Semua mamalia bernapas dengan paru-paru. Paus adalah mamalia. Kesimpulannya?",
		"code": "",
		"options": ["Paus bernapas dengan paru-paru", "Paus bukan mamalia", "Paus bernapas dengan insang", "Sebagian paus mamalia"],
		"answer": 0,
		"explain": "Berdasarkan silogisme kategorik, paus pasti bernapas dengan paru-paru."
	},
	{
		"cat": "Logika",
		"q": "Jika hujan, jalanan basah. Hari ini turun hujan. Kesimpulannya?",
		"code": "",
		"options": ["Jalanan basah", "Jalanan kering", "Hujan tidak berhenti", "Jalanan tidak licin"],
		"answer": 0,
		"explain": "Kondisi sebab telah terpenuhi sehingga akibatnya jalanan basah (Modus Ponens)."
	},
	{
		"cat": "Logika",
		"q": "Pernyataan logika (Benar AND Salah) menghasilkan nilai...",
		"code": "",
		"options": ["Salah", "Benar", "Tidak terdefinisi", "Keduanya"],
		"answer": 0,
		"explain": "Operasi AND hanya bernilai Benar jika kedua kondisi bernilai Benar."
	},
	{
		"cat": "Logika",
		"q": "Pernyataan logika (Salah OR Benar) menghasilkan nilai...",
		"code": "",
		"options": ["Benar", "Salah", "Kosong", "Error"],
		"answer": 0,
		"explain": "Operasi OR bernilai Benar jika setidaknya salah satu kondisi bernilai Benar."
	},
	{
		"cat": "Logika",
		"q": "Andi lebih tinggi dari Budi. Budi lebih tinggi dari Cici. Siapakah yang paling tinggi?",
		"code": "",
		"options": ["Andi", "Budi", "Cici", "Sama tinggi"],
		"answer": 0,
		"explain": "Andi lebih tinggi dari Budi yang lebih tinggi dari Cici, maka Andi yang paling tinggi."
	},
	{
		"cat": "Logika",
		"q": "Baterai ponsel berkurang 15% setiap jam. Jika awal 100%, berapa sisa setelah 3 jam?",
		"code": "",
		"options": ["55%", "60%", "45%", "50%"],
		"answer": 0,
		"explain": "Pengurangan selama 3 jam: 15% × 3 = 45%. Sisa baterai: 100% - 45% = 55%."
	},
	{
		"cat": "Logika",
		"q": "Apa ingkaran (negasi) dari 'Semua peserta membawa pensil'?",
		"code": "",
		"options": ["Ada peserta tidak bawa pensil", "Tidak ada yang bawa pensil", "Semua peserta bawa pulpen", "Beberapa peserta bawa pensil"],
		"answer": 0,
		"explain": "Ingkaran dari pernyataan kuantor universal 'semua' adalah 'ada/beberapa yang tidak'."
	},
	{
		"cat": "Logika",
		"q": "Antara 1 kg besi dan 1 kg kapas, manakah yang lebih berat?",
		"code": "",
		"options": ["Sama berat", "Besi lebih berat", "Kapas lebih berat", "Tergantung volume"],
		"answer": 0,
		"explain": "Keduanya memiliki massa yang sama persis yaitu satu kilogram."
	},

	# --- KATEGORI: PYTHON (12 Soal) ---
	{
		"cat": "Python",
		"q": "Apakah output dari kode program berikut?",
		"code": "x = 5\ny = 3\nprint(x + y)",
		"options": ["8", "53", "15", "x + y"],
		"answer": 0,
		"explain": "Variabel x dan y dijumlahkan secara aritmatika (5 + 3 = 8)."
	},
	{
		"cat": "Python",
		"q": "Apakah tipe data dari variabel x berikut?",
		"code": "x = 3.14\nprint(type(x).__name__)",
		"options": ["float", "int", "str", "number"],
		"answer": 0,
		"explain": "Bilangan desimal dengan koma/titik di Python bertipe float."
	},
	{
		"cat": "Python",
		"q": "Berapakah nilai yang dicetak?",
		"code": "items = [10, 20, 30]\nprint(len(items))",
		"options": ["3", "2", "4", "30"],
		"answer": 0,
		"explain": "Fungsi len() menghitung total elemen di dalam list (ada 3 elemen)."
	},
	{
		"cat": "Python",
		"q": "Elemen apakah yang dicetak oleh kode ini?",
		"code": "buah = ['apel', 'jeruk']\nprint(buah[0])",
		"options": ["apel", "jeruk", "0", "IndexError"],
		"answer": 0,
		"explain": "Indeks list Python dimulai dari 0, sehingga buah[0] mengambil elemen pertama ('apel')."
	},
	{
		"cat": "Python",
		"q": "Apakah output dari operasi string berikut?",
		"code": "s = 'Go' * 3\nprint(s)",
		"options": ["GoGoGo", "Go 3", "Go*3", "Error"],
		"answer": 0,
		"explain": "Perkalian string di Python menduplikasi teks sebanyak nilai pengali."
	},
	{
		"cat": "Python",
		"q": "Apakah output dari percabangan kondisi berikut?",
		"code": "nilai = 75\nif nilai >= 70:\n    print('Lulus')\nelse:\n    print('Gagal')",
		"options": ["Lulus", "Gagal", "75", "Error"],
		"answer": 0,
		"explain": "Kondisi nilai >= 70 bernilai True untuk 75, sehingga mencetak 'Lulus'."
	},
	{
		"cat": "Python",
		"q": "Berapakah nilai total setelah loop selesai?",
		"code": "total = 0\nfor i in range(3):\n    total += i\nprint(total)",
		"options": ["3", "6", "0", "2"],
		"answer": 0,
		"explain": "range(3) menghasilkan 0, 1, 2. Penjumlahan: 0 + 1 + 2 = 3."
	},
	{
		"cat": "Python",
		"q": "Berapakah hasil dari operasi sisa bagi (modulo) ini?",
		"code": "print(10 % 3)",
		"options": ["1", "3", "0", "3.33"],
		"answer": 0,
		"explain": "Operasi 10 % 3 menghasilkan sisa pembagian 10 dibagi 3 yaitu 1."
	},
	{
		"cat": "Python",
		"q": "Apakah nilai boolean yang dicetak?",
		"code": "a = True\nb = False\nprint(a and not b)",
		"options": ["True", "False", "None", "Error"],
		"answer": 0,
		"explain": "not b bernilai True, sehingga operasi True and True menghasilkan True."
	},
	{
		"cat": "Python",
		"q": "Apakah hasil dari pemanggilan fungsi string ini?",
		"code": "teks = 'godot'\nprint(teks.upper())",
		"options": ["GODOT", "Godot", "godot", "G"],
		"answer": 0,
		"explain": "Metode .upper() mengubah seluruh huruf string menjadi huruf kapital."
	},
	{
		"cat": "Python",
		"q": "Berapakah nilai elemen terakhir yang dicetak?",
		"code": "angka = [1, 2]\nangka.append(3)\nprint(angka[-1])",
		"options": ["3", "2", "1", "IndexError"],
		"answer": 0,
		"explain": "append(3) memasukkan 3 ke akhir list, dan indeks -1 mengambil elemen terakhir."
	},
	{
		"cat": "Python",
		"q": "Apakah output dari f-string berikut?",
		"code": "nama = 'Ali'\nprint(f'Hai {nama}')",
		"options": ["Hai Ali", "Hai {nama}", "Hai", "Error"],
		"answer": 0,
		"explain": "f-string menggantikan ekspresi {nama} dengan isi variabelnya yaitu 'Ali'."
	},

	# --- KATEGORI: JAVASCRIPT (10 Soal) ---
	{
		"cat": "JavaScript",
		"q": "Apakah output console dari operasi berikut?",
		"code": "console.log(1 + '2');",
		"options": ["12", "3", "NaN", "Error"],
		"answer": 0,
		"explain": "JavaScript mengonversi angka 1 menjadi string lalu menggabungkannya dengan '2'."
	},
	{
		"cat": "JavaScript",
		"q": "Apakah hasil dari perbandingan ketat (strict equality) ini?",
		"code": "console.log(5 === '5');",
		"options": ["false", "true", "undefined", "TypeError"],
		"answer": 0,
		"explain": "Operator === membandingkan nilai dan tipe data. Karena number != string, hasilnya false."
	},
	{
		"cat": "JavaScript",
		"q": "Berapakah panjang array yang dicetak?",
		"code": "const a = [1, 2, 3, 4];\nconsole.log(a.length);",
		"options": ["4", "3", "5", "undefined"],
		"answer": 0,
		"explain": "Properti .length mengembalikan jumlah elemen yang ada di dalam array (4 elemen)."
	},
	{
		"cat": "JavaScript",
		"q": "Nilai apakah yang dikembalikan oleh pop()?",
		"code": "let arr = [10, 20];\narr.push(30);\nconsole.log(arr.pop());",
		"options": ["30", "20", "10", "3"],
		"answer": 0,
		"explain": "push(30) menambah 30 ke ujung, dan pop() mengambil serta mencetak elemen terakhir (30)."
	},
	{
		"cat": "JavaScript",
		"q": "Apakah output dari operator ternary berikut?",
		"code": "let usia = 18;\nlet st = usia >= 17 ? 'KTP' : '-';\nconsole.log(st);",
		"options": ["KTP", "-", "true", "undefined"],
		"answer": 0,
		"explain": "Karena 18 >= 17 bernilai true, operator ternary mengevaluasi ekspresi pertama ('KTP')."
	},
	{
		"cat": "JavaScript",
		"q": "Apakah hasil dari pembalikan nilai boolean berikut?",
		"code": "console.log(!true);",
		"options": ["false", "true", "null", "undefined"],
		"answer": 0,
		"explain": "Operator negasi (!) membalikkan nilai true menjadi false."
	},
	{
		"cat": "JavaScript",
		"q": "Apakah output dari fungsi pembulatan ke bawah ini?",
		"code": "console.log(Math.floor(4.9));",
		"options": ["4", "5", "4.9", "0"],
		"answer": 0,
		"explain": "Math.floor membulatkan bilangan desimal ke bawah ke integer terdekat (4)."
	},
	{
		"cat": "JavaScript",
		"q": "Apakah tipe data yang dicetak oleh typeof?",
		"code": "console.log(typeof 'Halo');",
		"options": ["string", "text", "String", "object"],
		"answer": 0,
		"explain": "typeof mengembalikan nama tipe data dasar JavaScript dalam huruf kecil ('string')."
	},
	{
		"cat": "JavaScript",
		"q": "Berapakah indeks pertama huruf 'd' pada kata 'dodge'?",
		"code": "let s = 'dodge';\nconsole.log(s.indexOf('d'));",
		"options": ["0", "1", "2", "-1"],
		"answer": 0,
		"explain": "indexOf mengembalikan posisi kemunculan pertama karakter. Huruf 'd' pertama ada di indeks 0."
	},
	{
		"cat": "JavaScript",
		"q": "Apakah hasil penggabungan array berikut?",
		"code": "let w = ['A', 'B'];\nconsole.log(w.join('-'));",
		"options": ["A-B", "AB", "A B", "A - B"],
		"answer": 0,
		"explain": "Metode join('-') menggabungkan elemen-elemen array menggunakan pemisah tanda hubung."
	},

	# --- KATEGORI: HTML (10 Soal) ---
	{
		"cat": "HTML",
		"q": "Tag HTML manakah yang digunakan untuk membuat judul utama terbesar?",
		"code": "",
		"options": ["<h1>", "<h6>", "<head>", "<header>"],
		"answer": 0,
		"explain": "Tag <h1> digunakan untuk heading tingkat tertinggi atau judul utama terbesar."
	},
	{
		"cat": "HTML",
		"q": "Tag apakah yang digunakan untuk membuat sebuah paragraf teks?",
		"code": "",
		"options": ["<p>", "<para>", "<text>", "<pg>"],
		"answer": 0,
		"explain": "Tag <p> merupakan tag standar HTML untuk mendefinisikan paragraf teks."
	},
	{
		"cat": "HTML",
		"q": "Atribut wajib pada tag <a> untuk menentukan alamat tautan URL adalah...",
		"code": "",
		"options": ["href", "src", "link", "url"],
		"answer": 0,
		"explain": "Atribut href (hypertext reference) menentukan alamat web tujuan tautan."
	},
	{
		"cat": "HTML",
		"q": "Atribut manakah yang digunakan tag <img> untuk lokasi file gambar?",
		"code": "",
		"options": ["src", "href", "path", "file"],
		"answer": 0,
		"explain": "Atribut src (source) berisi alamat file gambar yang akan ditampilkan."
	},
	{
		"cat": "HTML",
		"q": "Tag HTML manakah yang berfungsi untuk berpindah baris (line break)?",
		"code": "",
		"options": ["<br>", "<hr>", "<break>", "<lb>"],
		"answer": 0,
		"explain": "Tag <br> digunakan untuk menyisipkan jeda baris baru tunggal dalam teks."
	},
	{
		"cat": "HTML",
		"q": "Tag manakah yang digunakan untuk daftar berurutan nomor (ordered list)?",
		"code": "",
		"options": ["<ol>", "<ul>", "<li>", "<dl>"],
		"answer": 0,
		"explain": "Tag <ol> (Ordered List) menampilkan butir-butir daftar berurutan angka 1, 2, 3..."
	},
	{
		"cat": "HTML",
		"q": "Tag manakah untuk daftar dengan simbol peluru/bullet (unordered list)?",
		"code": "",
		"options": ["<ul>", "<ol>", "<list>", "<li>"],
		"answer": 0,
		"explain": "Tag <ul> (Unordered List) menampilkan daftar dengan simbol bullet/titik."
	},
	{
		"cat": "HTML",
		"q": "Tag apakah yang membungkus setiap butir item di dalam <ol> atau <ul>?",
		"code": "",
		"options": ["<li>", "<item>", "<it>", "<dt>"],
		"answer": 0,
		"explain": "Tag <li> (List Item) digunakan untuk mendefinisikan tiap butir di dalam daftar."
	},
	{
		"cat": "HTML",
		"q": "Elemen dokumen HTML yang memuat seluruh konten visual halaman adalah...",
		"code": "",
		"options": ["<body>", "<head>", "<title>", "<meta>"],
		"answer": 0,
		"explain": "Tag <body> membungkus semua elemen konten visual yang dirender oleh browser."
	},
	{
		"cat": "HTML",
		"q": "Elemen apa yang digunakan untuk membuat kotak input teks yang bisa diketik?",
		"code": "",
		"options": ["<input>", "<button>", "<label>", "<form>"],
		"answer": 0,
		"explain": "Tag <input> (default type='text') digunakan untuk menerima masukan teks pengguna."
	}
]

# Pool indeks untuk memastikan semua soal muncul sebelum diulang
static var _available_indices: Array[int] = []


# Mengambil satu soal acak tanpa repetisi hingga seluruh soal keluar
static func get_random_question() -> Dictionary:
	if _available_indices.is_empty():
		_available_indices.clear()
		for i in range(QUESTIONS.size()):
			_available_indices.append(i)
		_available_indices.shuffle()

	var idx = _available_indices.pop_back()
	return QUESTIONS[idx].duplicate(true)

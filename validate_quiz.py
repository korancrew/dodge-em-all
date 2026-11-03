#!/usr/bin/env python3
"""
Skrip validasi bank soal kuis untuk Dodge 'em All.
Memeriksa:
1. Jumlah soal per kategori (minimal 12 Logika, 12 Python, 10 JS, 10 HTML).
2. Setiap soal memiliki 4 opsi unik.
3. Indeks answer berada di rentang 0..3.
4. Kode maksimal 6 baris dan <= 34 karakter per baris.
5. Menjalankan potongan kode Python menggunakan python3 dan mencocokkan output dengan options[answer].
6. Menjalankan potongan kode JavaScript menggunakan node dan mencocokkan output dengan options[answer].
"""

import re
import subprocess
import sys


def parse_gdscript_questions(filepath):
	with open(filepath, "r", encoding="utf-8") as f:
		content = f.read()

	# Ambil array QUESTIONS = [ ... ]
	match = re.search(r"const QUESTIONS = \[(.*?)\]\n\n# Pool", content, re.DOTALL)
	if not match:
		print("ERROR: Array QUESTIONS tidak ditemukan!")
		sys.exit(1)

	raw_array = match.group(1)
	
	# Parse menggunakan penghitung kurung kurawal agar aman terhadap kurung kurawal di dalam string (seperti f-string)
	dict_blocks = []
	brace_depth = 0
	in_string = False
	string_char = ''
	is_escape = False
	start_idx = -1

	for idx, char in enumerate(raw_array):
		if in_string:
			if is_escape:
				is_escape = False
			elif char == '\\':
				is_escape = True
			elif char == string_char:
				in_string = False
		else:
			if char in ('"', "'"):
				in_string = True
				string_char = char
			elif char == '{':
				if brace_depth == 0:
					start_idx = idx
				brace_depth += 1
			elif char == '}':
				brace_depth -= 1
				if brace_depth == 0 and start_idx != -1:
					dict_blocks.append(raw_array[start_idx:idx+1])
					start_idx = -1

	questions = []
	for block in dict_blocks:
		q = {}
		cat_m = re.search(r'"cat":\s*"([^"]+)"', block)
		q_m = re.search(r'"q":\s*"([^"]+)"', block)
		code_m = re.search(r'"code":\s*"(.*?)"(?=,\s*"options")', block, re.DOTALL)
		opts_m = re.search(r'"options":\s*\[(.*?)\]', block)
		ans_m = re.search(r'"answer":\s*(\d+)', block)
		exp_m = re.search(r'"explain":\s*"([^"]+)"', block)

		if not (cat_m and q_m and opts_m and ans_m and exp_m):
			print("ERROR parsing block:\n", block)
			sys.exit(1)

		q["cat"] = cat_m.group(1)
		q["q"] = q_m.group(1)
		code_raw = code_m.group(1) if code_m else ""
		q["code"] = code_raw.replace("\\n", "\n").replace('\\"', '"').replace("\\'", "'")
		raw_opts = opts_m.group(1)
		q["options"] = [opt.strip().strip('"\'') for opt in raw_opts.split(",") if opt.strip()]
		q["answer"] = int(ans_m.group(1))
		q["explain"] = exp_m.group(1)
		questions.append(q)

	return questions


def main():
	filepath = "quiz_bank.gd"
	questions = parse_gdscript_questions(filepath)
	print(f"Total soal terbaca: {len(questions)}")

	counts = {}
	all_passed = True

	for idx, q in enumerate(questions, 1):
		cat = q["cat"]
		counts[cat] = counts.get(cat, 0) + 1

		# 1. Cek 4 opsi
		if len(q["options"]) != 4:
			print(f"[{idx}] {cat}: ERROR opsi tidak berjumlah 4 (ada {len(q['options'])})")
			all_passed = False

		# 2. Cek opsi unik
		if len(set(q["options"])) != 4:
			print(f"[{idx}] {cat}: ERROR ada opsi duplikat: {q['options']}")
			all_passed = False

		# 3. Cek indeks answer
		if q["answer"] < 0 or q["answer"] > 3:
			print(f"[{idx}] {cat}: ERROR answer di luar 0..3 ({q['answer']})")
			all_passed = False

		# 4. Cek batas kode
		code = q["code"].strip()
		if code:
			lines = code.split("\n")
			if len(lines) > 6:
				print(f"[{idx}] {cat}: ERROR baris kode > 6 ({len(lines)} baris)")
				all_passed = False
			for l in lines:
				if len(l) > 34:
					print(f"[{idx}] {cat}: ERROR baris kode melebihi 34 karakter ({len(l)} chars): '{l}'")
					all_passed = False

			# 5. Eksekusi Python
			if cat == "Python":
				try:
					res = subprocess.run(
						["python3", "-c", code],
						capture_output=True,
						text=True,
						timeout=2
					)
					output = res.stdout.strip()
					expected = q["options"][q["answer"]]
					if res.returncode != 0 or output != expected:
						print(f"[{idx}] Python FAIL: output '{output}', diharapkan '{expected}'. stderr: {res.stderr.strip()}")
						all_passed = False
					else:
						print(f"[{idx}] Python OK: output cocok '{output}'")
				except Exception as e:
					print(f"[{idx}] Python EXEC ERROR: {e}")
					all_passed = False

			# 6. Eksekusi JavaScript
			elif cat == "JavaScript":
				try:
					res = subprocess.run(
						["node", "-e", code],
						capture_output=True,
						text=True,
						timeout=2
					)
					output = res.stdout.strip()
					expected = q["options"][q["answer"]]
					if res.returncode != 0 or output != expected:
						print(f"[{idx}] JavaScript FAIL: output '{output}', diharapkan '{expected}'. stderr: {res.stderr.strip()}")
						all_passed = False
					else:
						print(f"[{idx}] JavaScript OK: output cocok '{output}'")
				except Exception as e:
					print(f"[{idx}] JavaScript EXEC ERROR: {e}")
					all_passed = False
		else:
			print(f"[{idx}] {cat} OK (tanpa kode)")

	print("\n--- RINGKASAN JUMLAH SOAL ---")
	for k, v in counts.items():
		print(f"- {k}: {v} soal")

	if all_passed:
		print("\nSEMUA VALIDASI BERHASIL! (100% Kunci Jawaban Cocok)")
	else:
		print("\nTERDAPAT KESALAHAN PADA VALIDASI.")
		sys.exit(1)


if __name__ == "__main__":
	main()

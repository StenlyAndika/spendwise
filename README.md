# Spendwise

Aplikasi pelacak pengeluaran pribadi berbasis Flutter. Offline-first, data tersimpan lokal di SQLite, dengan alur **Catat · Review · Analisa**.

![Flutter](https://img.shields.io/badge/Flutter-3.38.9-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.8-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-GPLv3-blue)

---

## Fitur

- **Catat pengeluaran** — kategori (dengan autocomplete), keterangan, nominal IDR yang terformat otomatis saat mengetik, dan pemilih tanggal.
- **Dashboard harian** — kartu metrik total bulan ini & jumlah transaksi, plus log pengeluaran untuk hari yang dipilih.
- **Kalender pengeluaran** — heatmap intensitas belanja per hari (`< 100k`, `100k–500k`, `> 500k`), bisa dilipat.
- **Riwayat bulanan** — grafik donat komposisi per kategori, daftar transaksi dikelompokkan per tanggal dengan subtotal harian.
- **Edit & hapus** — menu aksi pada tiap baris pengeluaran, dengan dialog konfirmasi untuk hapus.
- **Backup & restore** — ekspor seluruh data ke JSON lalu bagikan lewat sheet share OS; impor dari file JSON (mode replace).
- **Navigasi bulan** — berpindah bulan dari app bar, data langsung dimuat ulang.

Antarmuka dan format mata uang/tanggal menggunakan locale `id_ID`. Nominal disimpan sebagai `INTEGER` rupiah penuh (tanpa desimal).

---

## Tangkapan Layar

> Belum tersedia. Jalankan `flutter run` untuk melihat aplikasinya.

---

## Arsitektur

Proyek ini memakai pemisahan berlapis (layered architecture) dengan `provider` sebagai state management dan repository pattern sebagai abstraksi data.

```
lib/
├── main.dart                          # Bootstrap: DB → repository → ChangeNotifierProvider
│
├── core/
│   ├── theme/app_style.dart           # Warna, spacing, radius, TextStyle, ThemeData gelap
│   └── utils/currency_formatter.dart  # Format/parse IDR ("Rp 380.000"), label kompak ("380k", "1.5jt")
│
├── domain/                            # Lapisan murni Dart, tanpa dependensi Flutter UI
│   ├── models/
│   │   ├── expense.dart               # Entity Expense + helper dateOnly/sameDay/sameMonth
│   │   └── category.dart              # Kategori & palet warna (fallback hash untuk kategori baru)
│   └── repositories/
│       └── expense_repository.dart    # Interface kontrak akses data
│
├── data/                              # Implementasi konkret
│   ├── local/
│   │   ├── database_helper.dart       # Singleton sqflite, skema + migrasi (v3)
│   │   └── sqlite_expense_repository.dart
│   └── backup/backup_codec.dart       # Encode/decode JSON backup + validasi ketat
│
└── presentation/
    ├── providers/expense_provider.dart # ChangeNotifier: state bulan aktif, hari terpilih, agregat
    ├── pages/
    │   ├── home_page.dart             # Dashboard + kalender
    │   ├── add_expense_page.dart      # Form tambah/edit
    │   ├── spend_history_page.dart    # Riwayat + grafik kategori
    │   └── backup_page.dart           # Ekspor/impor
    └── widgets/
        ├── workspace_app_bar.dart     # App bar dengan navigasi bulan
        ├── metric_cards_row.dart      # Kartu total bulan & jumlah transaksi
        ├── expense_log_card.dart      # Daftar pengeluaran (mode compact & grouped)
        ├── category_chart_card.dart   # Donut chart fl_chart + breakdown kategori
        ├── month_calendar_card.dart   # Kalender heatmap
        └── expense_actions.dart       # Helper edit & konfirmasi hapus
```

### Alur Data

```
UI (Widget)
   ↓ context.watch / context.read
ExpenseProvider (ChangeNotifier)   ← state: visibleMonth, selectedDay, agregat
   ↓
ExpenseRepository (interface)
   ↓
SqliteExpenseRepository  →  sqflite  →  spendwise.db
```

`ExpenseProvider._loadMonth()` memuat empat query secara paralel (`Future.wait`): daftar pengeluaran bulan berjalan, total per kategori, total per hari, dan daftar kategori. Semua agregasi berat dikerjakan di SQL (`GROUP BY`, `SUM`).

---

## Skema Database

Database `spendwise.db`, versi **3**.

```sql
CREATE TABLE categories (
  name TEXT PRIMARY KEY
);

CREATE TABLE expenses (
  id          TEXT PRIMARY KEY,
  date        TEXT NOT NULL,      -- format YYYY-MM-DD (sortable, prefix-match per bulan)
  category    TEXT NOT NULL,
  description TEXT NOT NULL,
  amount      INTEGER NOT NULL    -- rupiah penuh
);

CREATE INDEX idx_expenses_date ON expenses(date);
```

**Riwayat migrasi**

| Versi | Perubahan |
| :---: | :--- |
| 1 → 2 | Menambahkan index `idx_expenses_date`. |
| 2 → 3 | Mengganti nama kategori `Nyawer` menjadi `Minuman` pada tabel `expenses` dan `categories`. |

Kategori awal yang di-seed saat pembuatan database: `Langganan`, `Makanan`, `Transport`, `Belanja`, `Hiburan`, `Kesehatan`, `Minuman`. Kategori baru otomatis ditambahkan saat menyimpan pengeluaran.

---

## Format Backup

Ekspor menghasilkan file `spendwise-backup-YYYYMMDD.json`:

```json
{
  "version": 1,
  "exportedAt": "2026-09-14T02:15:00.000Z",
  "categories": ["Belanja", "Hiburan", "Makanan"],
  "expenses": [
    {
      "id": "1757812800000",
      "date": "2026-09-13",
      "category": "Langganan",
      "description": "Langganan Cursor",
      "amount": 380000
    }
  ]
}
```

`BackupCodec.decode()` memvalidasi struktur secara ketat: objek harus berupa JSON object, `version` harus sama dengan versi yang didukung (`1`), `categories` dan `expenses` harus berupa array, serta tiap item pengeluaran wajib punya `id`, `date`, `category`, `description`, dan `amount` (integer). Pelanggaran aturan ini melempar `FormatException` dengan pesan yang jelas.

> **Perhatian:** impor berjalan dalam satu transaksi dan **menghapus seluruh data yang ada** sebelum menulis isi backup. Hanya mode replace yang didukung.

---

## Menjalankan Proyek

### Prasyarat

- Flutter **3.38.9** (stable) / Dart **3.10.8**
- Android: JDK 17 (proyek memakai `sourceCompatibility`/`jvmTarget` **17**)

### Perintah

```bash
flutter pub get         # pasang dependensi
flutter run             # jalankan di perangkat/emulator
flutter test            # jalankan unit & widget test
flutter analyze         # analisis statis (flutter_lints)
flutter build apk --release
```

Target platform yang tersedia di repositori ini: **Android** dan **macOS**.

---

## Dependensi

| Paket | Versi | Kegunaan |
| :--- | :--- | :--- |
| `provider` | ^6.1.2 | State management (`ChangeNotifier`) |
| `sqflite` | ^2.4.2 | Penyimpanan lokal SQLite |
| `path` / `path_provider` | ^1.9.1 / ^2.1.5 | Resolusi path database & direktori dokumen |
| `intl` | ^0.20.3 | Format tanggal & mata uang locale `id_ID` |
| `fl_chart` | ^0.70.2 | Grafik donat komposisi kategori |
| `share_plus` | ^10.1.4 | Membagikan file backup lewat share sheet |
| `file_picker` | ^8.1.7 | Memilih file JSON saat impor |

Dev: `flutter_lints` ^6.0.0.

---

## Testing

```bash
flutter test
```

- `test/backup_codec_test.dart` — round-trip encode/decode dan penolakan versi backup yang tidak didukung.
- `test/widget_test.dart` — render judul halaman utama dan navigasi tombol **Riwayat** menuju halaman riwayat.
- `test/fakes/fake_expense_repository.dart` — implementasi in-memory `ExpenseRepository` agar widget test tidak menyentuh sqflite.

Saat ini: **4 test, semuanya lulus.**

---

## Konvensi Pengembangan

- **Bahasa UI**: seluruh string yang dilihat pengguna berbahasa Indonesia.
- **Nilai uang**: selalu `int` rupiah; tidak ada floating point.
- **Tanggal**: disimpan sebagai string `YYYY-MM-DD` agar query prefix `LIKE 'YYYY-MM-'` efisien per bulan.
- **Warna & ukuran**: jangan hardcode — ambil dari `AppStyle`.
- **ID pengeluaran**: `millisecondsSinceEpoch` sebagai string.
- **Lint**: ikuti aturan `flutter_lints`; pastikan `flutter analyze` bersih sebelum commit.

---

## Lisensi

Dirilis di bawah [GNU General Public License v3.0](LICENSE).

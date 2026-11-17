# Cakra Tirta

Prototipe sistem pemantauan rob dan amblesan tanah untuk Semarang. Alur yang sudah terhubung: aplikasi Flutter → API Express → zona demo dan proyeksi skenario.

> **Bukan layanan peringatan bencana.** Data zona dan proyeksi lokal adalah sintetis, bukan data lapangan atau prediksi resmi. Belum ada peta dasar/geospasial. Ikuti informasi BMKG dan BPBD.

## Status

- **Berjalan:** beranda dan daftar zona mengambil data API; simulasi memakai endpoint proyeksi berdasarkan zona dan tahun; tampilan loading/error dan coba lagi.
- **Mode lokal:** tiga zona sintetis berlabel `isDemo: true`. Proyeksi linear hanya untuk mendemokan alur aplikasi.
- **Mode Supabase:** API dapat membaca zona dari database. Proyeksi dinonaktifkan sampai tersedia baseline elevasi tervalidasi.
- **Belum terintegrasi:** BMKG/pasang, peta dan routing, autentikasi, laporan genangan, push notification, pipeline Sentinel-1, dashboard instansi, edukasi.

## Struktur

- `mobile/` — aplikasi Flutter untuk Android/iOS dan target pratinjau web.
- `backend/` — REST API Node.js + Express.
- `backend/migrations/001_core.sql` — tabel awal Supabase dan kebijakan RLS.
- `backend/src/data/demo-data.js` — fixture sintetis untuk mode lokal.
- `satellite-service/` — catatan setup; pipeline Earth Engine belum dibuat.
- `Cakra_Tirta_Project_Plan.docx` dan `Cakra_Tirta_Setup_dan_Design_System.md` — rencana produk dan panduan desain/arsitektur.

## Menjalankan lokal

Perlu Node.js 20+ dan Flutter SDK 3.41+.

### 1. Backend

Di terminal pertama, dari root repo:

```sh
cd backend
npm install
cp .env.example .env
npm run dev
```

Mode default lokal adalah `DATA_MODE=demo`; Supabase tidak diperlukan untuk menjalankan demo.

### 2. Aplikasi Flutter

Di terminal kedua, dari root repo:

```sh
cd mobile
flutter pub get
flutter run -d chrome
```

Untuk Android emulator, arahkan aplikasi ke host backend:

```sh
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Untuk perangkat fisik, gunakan alamat IP komputer yang dapat dijangkau perangkat, bukan `localhost`. Jangan memasukkan kredensial service-role ke aplikasi.

## API

- `GET /health` — status API dan mode data.
- `GET /api/risk-zones` — daftar zona; filter opsional `?kelurahan=...`.
- `GET /api/subsidence/projection?zoneId=demo-zone-01&year=2035` — skenario proyeksi untuk tahun 2026–2045.

Respons mode demo memiliki `source: "demo"` dan `isDemo: true`. Nilai proyeksi sintetis tidak boleh dipakai untuk keputusan keselamatan.

## Mengaktifkan Supabase

1. Jalankan `backend/migrations/001_core.sql` di SQL Editor Supabase.
2. Isi `SUPABASE_URL` dan `SUPABASE_SERVICE_ROLE_KEY` hanya di `backend/.env`.
3. Ubah `DATA_MODE=supabase`, lalu mulai ulang API.

API membaca zona dari `risk_zones`. Proyeksi Supabase mengembalikan `422 PROJECTION_BASELINE_MISSING` sampai tersedia baseline elevasi yang tervalidasi. RLS aktif pada tabel migrasi; akses laporan warga tetap tertutup sampai alur autentikasi dan moderasi dibuat.

## Pemeriksaan

```sh
cd backend
npm run check
npm test
```

```sh
cd mobile
flutter analyze
flutter test
flutter build web
```

## Layanan satelit

Earth Engine belum diautentikasi dan tidak ada pipeline pemrosesan Sentinel-1 saat ini. Siapkan akses project Google Earth Engine sebelum mengimplementasikan deteksi genangan; jangan menulis hasil sintetis ke tabel data operasional.

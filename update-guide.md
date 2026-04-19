# Panduan Update dari Repo Official SLiMS

Dokumen ini menjelaskan cara mengambil update terbaru dari repo official SLiMS ke fork/branch custom kamu, tanpa menimpa konfigurasi yang sudah dikustomisasi.

---

## Struktur Branch

| Branch | Fungsi |
|--------|--------|
| `master` | Mengikuti upstream official (jangan diubah) |
| `prod` | Branch custom untuk production (Coolify deploy dari sini) |

---

## Persiapan Sekali (Sudah Dilakukan)

Pastikan remote `upstream` sudah terdaftar:

```bash
git remote -v
# Harus ada:
# origin    https://github.com/<kamu>/slims9_bulian.git
# upstream  https://github.com/slims/slims9_bulian.git
```

Jika belum:

```bash
git remote add upstream https://github.com/slims/slims9_bulian.git
```

---

## Alur Update (Setiap Ada Rilis Baru)

> ⚠️ **Penting:** Selalu mulai dari branch `master` dulu, baru ke `prod`.
> Jangan langsung rebase `prod` dari `upstream` — lewat `master` dulu agar history tetap rapi.

### 1. Cek release terbaru di upstream

```bash
git fetch upstream

# Lihat tag/versi terbaru
git tag -l | sort -V | tail -5
```

Atau cek langsung di: https://github.com/slims/slims9_bulian/releases

---

### 2. Pindah ke `master` dan update dari upstream

```bash
# WAJIB: pastikan kamu di branch master dulu
git checkout master

git merge upstream/master
git push origin master
```

---

### 3. Pindah ke `prod` lalu rebase dari `master`

```bash
# Baru pindah ke prod setelah master diupdate
git checkout prod
git rebase master
```

---

### 4. Jika ada conflict

Conflict biasanya terjadi di file yang kamu ubah: `docker-compose.yml`, `entrypoint.sh`, `.env.example`.

```bash
# Git akan berhenti dan menunjukkan file yang conflict
# Buka file tersebut dan selesaikan conflict secara manual

# Tandai sudah diselesaikan
git add docker-compose.yml entrypoint.sh .env.example

# Lanjutkan rebase
git rebase --continue
```

Jika ingin batalkan rebase dan kembali ke kondisi semula:

```bash
git rebase --abort
```

---

### 5. Push branch `prod` ke fork

```bash
# Gunakan --force-with-lease karena rebase menulis ulang history
git push origin prod --force-with-lease
```

---

### 6. Deploy di Coolify

Setelah push, Coolify bisa auto-deploy jika webhook aktif, atau deploy manual:

- Buka dashboard Coolify
- Pilih aplikasi SLiMS
- Klik **Redeploy**

---

## File yang Aman dari Conflict

File-file berikut **tidak ada di upstream** sehingga tidak akan pernah conflict:

| File | Keterangan |
|------|-----------|
| `docker-compose.yml` | Sudah diubah, perlu resolve jika upstream juga ubah |
| `entrypoint.sh` | Sudah diubah, perlu resolve jika upstream juga ubah |
| `.env.example` | Tambahan kita, upstream punya versi sendiri |
| `.env` | Di `.gitignore`, aman |
| `config/database.php` | Di-generate saat runtime oleh `entrypoint.sh` |
| `config/env.php` | Di-generate saat runtime oleh `entrypoint.sh` |

---

## Tips

- **Selalu baca changelog** sebelum update: [`changes.txt`](https://github.com/slims/slims9_bulian/blob/master/changes.txt)
- **Jangan edit file core SLiMS** (`lib/`, `admin/`, `src/`) langsung — taruh customisasi di plugin/template agar conflict minimal
- **Test dulu di lokal** sebelum push ke `prod` dan trigger deploy Coolify

---

## Ringkasan Perintah

```bash
# Fetch update upstream
git fetch upstream

# Update master
git checkout master
git merge upstream/master
git push origin master

# Rebase prod
git checkout prod
git rebase master

# Push (setelah resolve conflict jika ada)
git push origin prod --force-with-lease
```
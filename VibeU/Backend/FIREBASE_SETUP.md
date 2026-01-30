# Firebase Service Account Setup

## Neden Gerekli?
Mock kullanıcıları Firebase'e eklemek için Firebase Admin SDK'ya ihtiyacımız var. Bu da service account key dosyası gerektirir.

## Adım 1: Firebase Console'a Git
1. https://console.firebase.google.com/ adresine git
2. **vibeu-d55ea** projesini seç

## Adım 2: Service Account Key İndir
1. Sol menüden **Project Settings** (⚙️) tıkla
2. **Service Accounts** sekmesine git
3. **Generate New Private Key** butonuna tıkla
4. **Generate Key** butonuna tıkla
5. JSON dosyası indirilecek

## Adım 3: Dosyayı Yerleştir
İndirilen JSON dosyasını şu konuma taşı:
```
VibeU/Backend/serviceAccountKey.json
```

## Adım 4: Scripti Çalıştır
```bash
cd VibeU/Backend
npm run add-mock-users-photos
```

## ⚠️ Güvenlik Notu
- `serviceAccountKey.json` dosyası GİZLİDİR
- Bu dosyayı asla Git'e commit etme
- `.gitignore` dosyasında zaten var

## Alternatif: Environment Variable
Eğer dosya kullanmak istemiyorsan, environment variable kullanabilirsin:

1. Service account key içeriğini kopyala
2. `.env` dosyasına ekle:
```
FIREBASE_SERVICE_ACCOUNT='{"type":"service_account",...}'
```

3. Script'i güncelle (gerekirse)

## Sorun mu Yaşıyorsun?
- Firebase Console'da doğru projeyi seçtiğinden emin ol
- Service account'un **Firebase Admin** yetkisine sahip olduğunu kontrol et
- JSON dosyasının formatının bozulmadığından emin ol

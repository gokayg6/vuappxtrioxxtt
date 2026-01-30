# 🔥 Firestore'a Mock Kullanıcıları Ekleme - SÜPER KOLAY YOL

## Seçenek 1: Firebase Console'dan Manuel Ekle (EN KOLAY)

### Adım 1: Firebase Console'a Git
https://console.firebase.google.com/project/vibeu-d55ea/firestore

### Adım 2: "users" Collection'ına Git
- Sol menüden **Firestore Database** tıkla
- **users** collection'ına tıkla (yoksa oluştur)

### Adım 3: Kullanıcı Ekle
Her kullanıcı için **Add Document** tıkla ve şu bilgileri gir:

**Document ID**: Auto-ID (otomatik)

**Fields**:
```
name: "Ayşe"
surname: "Yılmaz"
display_name: "Ayşe Yılmaz"
age: 24
gender: "female"
city: "İstanbul"
country: "Türkiye"
bio: "Müzik ve sanat tutkunu 🎨"
interests: ["Müzik", "Sanat", "Sinema"]
hobbies: ["Gitar", "Resim"]
zodiac_sign: "Koç"
email: "ayse.yilmaz@vibeumock.com"
photo_url: "https://picsum.photos/id/101/1080/1920"
profile_photo_url: "https://picsum.photos/id/101/1080/1920"
is_verified: true
is_premium: false
diamond_balance: 100
profile_completion: 100
age_group: "adult"
username: "ayse24"
tags: []
created_at: (timestamp - now)
last_active_at: (timestamp - now)
```

## Seçenek 2: iOS Uygulamasından Ekle (DAHA KOLAY!)

Uygulamaya bir "Debug" butonu ekleyeyim, ona basınca otomatik 60 kullanıcı eklesin?

## Seçenek 3: Service Account Key İndir (5 DAKİKA)

1. https://console.firebase.google.com/project/vibeu-d55ea/settings/serviceaccounts/adminsdk
2. **Generate new private key**
3. İndirilen dosyayı `VibeU/Backend/serviceAccountKey.json` olarak kaydet
4. `npm run add-mock-users-fast` çalıştır

## 📸 Fotoğraflar

Tüm fotoğraflar Picsum Photos'tan:
- Format: 9:16 (1080x1920)
- Kalite: 4K
- Delay: YOK
- URL: `https://picsum.photos/id/{101-160}/1080/1920`

## 🎯 Hangi Yöntem?

- **En Hızlı**: iOS uygulamasına debug butonu ekle
- **En Kolay**: Firebase Console'dan manuel
- **En Profesyonel**: Service account key + script

Hangisini istiyorsun?

import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';

// Initialize Firebase Admin with Application Default Credentials
initializeApp({
  projectId: 'vibeu-d55ea'
});

const db = getFirestore();
const auth = getAuth();

// 60+ Mock Users - 40 Female, 20 Male
// Using Picsum Photos for fast, reliable 9:16 portrait images
const mockUsers = [
  // FEMALE USERS (40)
  { name: "Ayşe", surname: "Yılmaz", age: 24, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Müzik ve sanat tutkunu 🎨", interests: ["Müzik", "Sanat", "Sinema"], hobbies: ["Gitar", "Resim"], zodiacSign: "Koç", photoId: 1 },
  { name: "Zeynep", surname: "Kaya", age: 23, gender: "female", city: "Ankara", country: "Türkiye", bio: "Kitap kurdu 📚", interests: ["Kitap", "Yazı", "Şiir"], hobbies: ["Okuma", "Yazma"], zodiacSign: "Boğa", photoId: 2 },
  { name: "Elif", surname: "Demir", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Kahve ve derin sohbetler ☕", interests: ["Kahve", "Felsefe", "Psikoloji"], hobbies: ["Kahve", "Sohbet"], zodiacSign: "İkizler", photoId: 3 },
  { name: "Selin", surname: "Çelik", age: 24, gender: "female", city: "Antalya", country: "Türkiye", bio: "Yoga ve meditasyon 🧘‍♀️", interests: ["Yoga", "Meditasyon", "Wellness"], hobbies: ["Yoga", "Pilates"], zodiacSign: "Yengeç", photoId: 4 },
  { name: "Deniz", surname: "Arslan", age: 26, gender: "female", city: "Bursa", country: "Türkiye", bio: "Seyahat tutkunu ✈️", interests: ["Seyahat", "Fotoğraf", "Doğa"], hobbies: ["Fotoğrafçılık", "Hiking"], zodiacSign: "Aslan", photoId: 5 },
  { name: "Ece", surname: "Öztürk", age: 22, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Dans ve müzik 💃", interests: ["Dans", "Müzik", "Parti"], hobbies: ["Dans", "Salsa"], zodiacSign: "Başak", photoId: 6 },
  { name: "Ceren", surname: "Aydın", age: 27, gender: "female", city: "Ankara", country: "Türkiye", bio: "Fitness ve sağlıklı yaşam 💪", interests: ["Spor", "Fitness", "Sağlık"], hobbies: ["Gym", "Koşu"], zodiacSign: "Terazi", photoId: 7 },
  { name: "Gizem", surname: "Şahin", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Moda ve stil 👗", interests: ["Moda", "Alışveriş", "Stil"], hobbies: ["Shopping", "Styling"], zodiacSign: "Akrep", photoId: 8 },
  { name: "Pınar", surname: "Yıldız", age: 26, gender: "female", city: "Adana", country: "Türkiye", bio: "Yemek yapmayı seviyorum 🍳", interests: ["Yemek", "Mutfak", "Gastronomi"], hobbies: ["Cooking", "Baking"], zodiacSign: "Yay", photoId: 9 },
  { name: "Merve", surname: "Koç", age: 24, gender: "female", city: "Gaziantep", country: "Türkiye", bio: "Doğa ve kamp 🏕️", interests: ["Doğa", "Kamp", "Trekking"], hobbies: ["Camping", "Hiking"], zodiacSign: "Oğlak", photoId: 10 },
  { name: "Aylin", surname: "Erdoğan", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Sinema aşığı 🎬", interests: ["Sinema", "Dizi", "Film"], hobbies: ["Film izleme"], zodiacSign: "Kova", photoId: 11 },
  { name: "Seda", surname: "Güneş", age: 28, gender: "female", city: "Ankara", country: "Türkiye", bio: "Teknoloji meraklısı 💻", interests: ["Teknoloji", "Bilim", "Oyun"], hobbies: ["Gaming", "Coding"], zodiacSign: "Balık", photoId: 12 },
  { name: "Burcu", surname: "Aksoy", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Sanat galerilerini gezmeyi severim 🖼️", interests: ["Sanat", "Müze", "Galeri"], hobbies: ["Müze gezme"], zodiacSign: "Koç", photoId: 13 },
  { name: "Nil", surname: "Polat", age: 24, gender: "female", city: "Antalya", country: "Türkiye", bio: "Plaj ve deniz 🏖️", interests: ["Plaj", "Deniz", "Güneş"], hobbies: ["Yüzme", "Sörf"], zodiacSign: "Boğa", photoId: 14 },
  { name: "Esra", surname: "Kurt", age: 26, gender: "female", city: "Bursa", country: "Türkiye", bio: "Müzik festivalleri 🎵", interests: ["Müzik", "Festival", "Konser"], hobbies: ["Konser gitme"], zodiacSign: "İkizler", photoId: 15 },
  { name: "Duygu", surname: "Özkan", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Yoga eğitmeni 🧘", interests: ["Yoga", "Wellness", "Meditasyon"], hobbies: ["Yoga", "Meditasyon"], zodiacSign: "Yengeç", photoId: 16 },
  { name: "Cansu", surname: "Yavuz", age: 27, gender: "female", city: "Ankara", country: "Türkiye", bio: "Girişimci ve iş kadını 💼", interests: ["İş", "Girişimcilik", "Networking"], hobbies: ["Okuma", "Networking"], zodiacSign: "Aslan", photoId: 17 },
  { name: "Begüm", surname: "Tekin", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Fotoğraf sanatçısı 📸", interests: ["Fotoğraf", "Sanat", "Seyahat"], hobbies: ["Fotoğrafçılık"], zodiacSign: "Başak", photoId: 18 },
  { name: "Tuğba", surname: "Çakır", age: 24, gender: "female", city: "Adana", country: "Türkiye", bio: "Pilates eğitmeni 🤸", interests: ["Pilates", "Fitness", "Sağlık"], hobbies: ["Pilates", "Yoga"], zodiacSign: "Terazi", photoId: 19 },
  { name: "Özge", surname: "Acar", age: 26, gender: "female", city: "Gaziantep", country: "Türkiye", bio: "Grafik tasarımcı 🎨", interests: ["Tasarım", "Sanat", "Dijital"], hobbies: ["Tasarım", "İllüstrasyon"], zodiacSign: "Akrep", photoId: 20 },
  { name: "Simge", surname: "Bulut", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Müzisyen ve şarkıcı 🎤", interests: ["Müzik", "Şarkı", "Sahne"], hobbies: ["Şarkı söyleme", "Gitar"], zodiacSign: "Yay", photoId: 21 },
  { name: "Melis", surname: "Kılıç", age: 28, gender: "female", city: "Ankara", country: "Türkiye", bio: "Psikolog 🧠", interests: ["Psikoloji", "İnsan", "Gelişim"], hobbies: ["Okuma", "Araştırma"], zodiacSign: "Oğlak", photoId: 22 },
  { name: "Damla", surname: "Şen", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Blogger ve influencer 📱", interests: ["Sosyal Medya", "Moda", "Lifestyle"], hobbies: ["Blogging", "Vlogging"], zodiacSign: "Kova", photoId: 23 },
  { name: "Yasemin", surname: "Doğan", age: 24, gender: "female", city: "Antalya", country: "Türkiye", bio: "Veteriner 🐾", interests: ["Hayvanlar", "Doğa", "Bakım"], hobbies: ["Hayvan bakımı"], zodiacSign: "Balık", photoId: 24 },
  { name: "İrem", surname: "Yurt", age: 26, gender: "female", city: "Bursa", country: "Türkiye", bio: "Öğretmen 📚", interests: ["Eğitim", "Kitap", "Çocuk"], hobbies: ["Okuma", "Öğretme"], zodiacSign: "Koç", photoId: 25 },
  { name: "Naz", surname: "Eren", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Mimar 🏛️", interests: ["Mimarlık", "Tasarım", "Sanat"], hobbies: ["Çizim", "Tasarım"], zodiacSign: "Boğa", photoId: 26 },
  { name: "Dilara", surname: "Aslan", age: 27, gender: "female", city: "Ankara", country: "Türkiye", bio: "Avukat ⚖️", interests: ["Hukuk", "Adalet", "Okuma"], hobbies: ["Okuma", "Tartışma"], zodiacSign: "İkizler", photoId: 27 },
  { name: "Buse", surname: "Çetin", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Doktor 👩‍⚕️", interests: ["Tıp", "Sağlık", "Bilim"], hobbies: ["Araştırma", "Okuma"], zodiacSign: "Yengeç", photoId: 28 },
  { name: "Eda", surname: "Yalçın", age: 24, gender: "female", city: "Adana", country: "Türkiye", bio: "Mühendis 🔧", interests: ["Mühendislik", "Teknoloji", "İnovasyon"], hobbies: ["Proje geliştirme"], zodiacSign: "Aslan", photoId: 29 },
  { name: "Gamze", surname: "Özer", age: 26, gender: "female", city: "Gaziantep", country: "Türkiye", bio: "Pazarlama uzmanı 📊", interests: ["Pazarlama", "Dijital", "Sosyal Medya"], hobbies: ["Analiz", "Strateji"], zodiacSign: "Başak", photoId: 30 },
  { name: "Hande", surname: "Taş", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Oyuncu 🎭", interests: ["Tiyatro", "Sinema", "Sanat"], hobbies: ["Oyunculuk", "Dans"], zodiacSign: "Terazi", photoId: 31 },
  { name: "Sinem", surname: "Kara", age: 28, gender: "female", city: "Ankara", country: "Türkiye", bio: "Yazılım geliştirici 💻", interests: ["Yazılım", "Teknoloji", "AI"], hobbies: ["Coding", "Gaming"], zodiacSign: "Akrep", photoId: 32 },
  { name: "Ebru", surname: "Çiftçi", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "İç mimar 🛋️", interests: ["İç Mimarlık", "Dekorasyon", "Tasarım"], hobbies: ["Dekorasyon", "DIY"], zodiacSign: "Yay", photoId: 33 },
  { name: "Derya", surname: "Güler", age: 24, gender: "female", city: "Antalya", country: "Türkiye", bio: "Diyetisyen 🥗", interests: ["Beslenme", "Sağlık", "Spor"], hobbies: ["Yemek yapma", "Spor"], zodiacSign: "Oğlak", photoId: 34 },
  { name: "Aslı", surname: "Bayrak", age: 26, gender: "female", city: "Bursa", country: "Türkiye", bio: "Gazeteci 📰", interests: ["Gazetecilik", "Haber", "Yazı"], hobbies: ["Yazma", "Araştırma"], zodiacSign: "Kova", photoId: 35 },
  { name: "Sevgi", surname: "Özkaya", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Hemşire 💉", interests: ["Sağlık", "Bakım", "İnsanlık"], hobbies: ["Gönüllülük"], zodiacSign: "Balık", photoId: 36 },
  { name: "Gül", surname: "Demirci", age: 27, gender: "female", city: "Ankara", country: "Türkiye", bio: "Eczacı 💊", interests: ["Eczacılık", "Sağlık", "Bilim"], hobbies: ["Okuma", "Araştırma"], zodiacSign: "Koç", photoId: 37 },
  { name: "Fulya", surname: "Yıldırım", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Fizyoterapist 🏥", interests: ["Fizyoterapi", "Sağlık", "Spor"], hobbies: ["Spor", "Yoga"], zodiacSign: "Boğa", photoId: 38 },
  { name: "Serap", surname: "Koçak", age: 24, gender: "female", city: "Adana", country: "Türkiye", bio: "Muhasebeci 📊", interests: ["Finans", "Matematik", "İş"], hobbies: ["Okuma", "Analiz"], zodiacSign: "İkizler", photoId: 39 },
  { name: "Tuba", surname: "Sarı", age: 26, gender: "female", city: "Gaziantep", country: "Türkiye", bio: "İnsan kaynakları uzmanı 👥", interests: ["İK", "İnsan", "Gelişim"], hobbies: ["Networking", "Okuma"], zodiacSign: "Yengeç", photoId: 40 },
  
  // MALE USERS (20)
  { name: "Mehmet", surname: "Yılmaz", age: 27, gender: "male", city: "İstanbul", country: "Türkiye", bio: "Seyahat etmeyi seviyorum ✈️", interests: ["Seyahat", "Fotoğraf", "Doğa"], hobbies: ["Fotoğrafçılık", "Hiking"], zodiacSign: "Aslan", photoId: 41 },
  { name: "Can", surname: "Kaya", age: 26, gender: "male", city: "Ankara", country: "Türkiye", bio: "Spor ve fitness 💪", interests: ["Spor", "Fitness", "Sağlık"], hobbies: ["Gym", "Basketbol"], zodiacSign: "Başak", photoId: 42 },
  { name: "Burak", surname: "Demir", age: 28, gender: "male", city: "İzmir", country: "Türkiye", bio: "Teknoloji meraklısı 💻", interests: ["Teknoloji", "Bilim", "Oyun"], hobbies: ["Gaming", "Coding"], zodiacSign: "Terazi", photoId: 43 },
  { name: "Emre", surname: "Çelik", age: 29, gender: "male", city: "Antalya", country: "Türkiye", bio: "Fotoğrafçılık tutkunu 📸", interests: ["Fotoğraf", "Sanat", "Seyahat"], hobbies: ["Fotoğrafçılık"], zodiacSign: "Akrep", photoId: 44 },
  { name: "Arda", surname: "Arslan", age: 27, gender: "male", city: "Bursa", country: "Türkiye", bio: "Kahve içip kitap okumayı seviyorum ☕", interests: ["Kahve", "Kitap", "Müzik"], hobbies: ["Okuma", "Kahve"], zodiacSign: "Yay", photoId: 45 },
  { name: "Kaan", surname: "Öztürk", age: 26, gender: "male", city: "İstanbul", country: "Türkiye", bio: "Müzik prodüktörü 🎵", interests: ["Müzik", "Prodüksiyon", "Sanat"], hobbies: ["Müzik yapma"], zodiacSign: "Oğlak", photoId: 46 },
  { name: "Onur", surname: "Aydın", age: 28, gender: "male", city: "Ankara", country: "Türkiye", bio: "Girişimci 💼", interests: ["İş", "Girişimcilik", "Teknoloji"], hobbies: ["Okuma", "Networking"], zodiacSign: "Kova", photoId: 47 },
  { name: "Barış", surname: "Şahin", age: 27, gender: "male", city: "İzmir", country: "Türkiye", bio: "DJ ve müzik sevdalısı 🎧", interests: ["Müzik", "DJ", "Parti"], hobbies: ["DJ", "Müzik"], zodiacSign: "Balık", photoId: 48 },
  { name: "Tolga", surname: "Yıldız", age: 29, gender: "male", city: "Adana", country: "Türkiye", bio: "Yazılım mühendisi 💻", interests: ["Yazılım", "Teknoloji", "AI"], hobbies: ["Coding", "Gaming"], zodiacSign: "Koç", photoId: 49 },
  { name: "Mert", surname: "Koç", age: 27, gender: "male", city: "Gaziantep", country: "Türkiye", bio: "Psikoloji ve felsefe tutkunu 🧠", interests: ["Psikoloji", "Felsefe", "Sanat"], hobbies: ["Okuma", "Düşünme"], zodiacSign: "Boğa", photoId: 50 },
  { name: "Alp", surname: "Erdoğan", age: 28, gender: "male", city: "İstanbul", country: "Türkiye", bio: "Dağcı ve doğa sever 🏔️", interests: ["Dağcılık", "Doğa", "Macera"], hobbies: ["Tırmanış", "Kamp"], zodiacSign: "İkizler", photoId: 51 },
  { name: "Eren", surname: "Güneş", age: 29, gender: "male", city: "Ankara", country: "Türkiye", bio: "Kitaplar, müzik ve derin düşünceler 📚", interests: ["Kitap", "Müzik", "Felsefe"], hobbies: ["Okuma", "Müzik"], zodiacSign: "Yengeç", photoId: 52 },
  { name: "Serkan", surname: "Aksoy", age: 27, gender: "male", city: "İzmir", country: "Türkiye", bio: "Aşçı ve gurme 🍳", interests: ["Yemek", "Mutfak", "Gastronomi"], hobbies: ["Yemek yapma"], zodiacSign: "Aslan", photoId: 53 },
  { name: "Deniz", surname: "Polat", age: 26, gender: "male", city: "Antalya", country: "Türkiye", bio: "Sörf ve deniz sporları 🏄", interests: ["Sörf", "Deniz", "Spor"], hobbies: ["Sörf", "Dalış"], zodiacSign: "Başak", photoId: 54 },
  { name: "Oğuz", surname: "Kurt", age: 28, gender: "male", city: "Bursa", country: "Türkiye", bio: "Mimar ve tasarımcı 🏛️", interests: ["Mimarlık", "Tasarım", "Sanat"], hobbies: ["Çizim", "Tasarım"], zodiacSign: "Terazi", photoId: 55 },
  { name: "Cem", surname: "Özkan", age: 27, gender: "male", city: "İstanbul", country: "Türkiye", bio: "Sinema ve dizi bağımlısı 🎬", interests: ["Sinema", "Dizi", "Film"], hobbies: ["Film izleme"], zodiacSign: "Akrep", photoId: 56 },
  { name: "Umut", surname: "Yavuz", age: 29, gender: "male", city: "Ankara", country: "Türkiye", bio: "Doktor 👨‍⚕️", interests: ["Tıp", "Sağlık", "Bilim"], hobbies: ["Araştırma", "Okuma"], zodiacSign: "Yay", photoId: 57 },
  { name: "Hakan", surname: "Tekin", age: 28, gender: "male", city: "İzmir", country: "Türkiye", bio: "Avukat ⚖️", interests: ["Hukuk", "Adalet", "Okuma"], hobbies: ["Okuma", "Tartışma"], zodiacSign: "Oğlak", photoId: 58 },
  { name: "Volkan", surname: "Çakır", age: 27, gender: "male", city: "Adana", country: "Türkiye", bio: "Pazarlama uzmanı 📊", interests: ["Pazarlama", "Dijital", "Sosyal Medya"], hobbies: ["Analiz", "Strateji"], zodiacSign: "Kova", photoId: 59 },
  { name: "Kerem", surname: "Acar", age: 26, gender: "male", city: "Gaziantep", country: "Türkiye", bio: "Müzisyen ve besteci 🎸", interests: ["Müzik", "Beste", "Sanat"], hobbies: ["Gitar", "Beste"], zodiacSign: "Balık", photoId: 60 }
];

// Generate 9:16 portrait photo URL from Picsum Photos (fast, no rate limit, high quality)
function getPhotoUrl(photoId: number): string {
  // 1080x1920 = 9:16 aspect ratio, perfect for mobile
  return `https://picsum.photos/id/${100 + photoId}/1080/1920`;
}

async function addMockUsersDirectly() {
  console.log('🚀 Adding 60 mock users directly to Firestore...\n');
  console.log('📸 Using Picsum Photos (fast, no delay, 9:16 format)\n');
  
  let successCount = 0;
  let errorCount = 0;
  
  for (let i = 0; i < mockUsers.length; i++) {
    const user = mockUsers[i];
    
    try {
      console.log(`[${i + 1}/${mockUsers.length}] Adding: ${user.name} ${user.surname}...`);
      
      // Create auth user
      const email = `${user.name.toLowerCase()}.${user.surname.toLowerCase()}@vibeumock.com`;
      const password = 'VibeU2024!';
      
      const userRecord = await auth.createUser({
        email: email,
        password: password,
        displayName: `${user.name} ${user.surname}`,
      });
      
      // Photo URL from Picsum (9:16, high quality, instant load)
      const photoUrl = getPhotoUrl(user.photoId);
      
      // Add to Firestore
      await db.collection('users').doc(userRecord.uid).set({
        name: user.name,
        surname: user.surname,
        display_name: `${user.name} ${user.surname}`,
        age: user.age,
        gender: user.gender,
        city: user.city,
        country: user.country,
        bio: user.bio,
        interests: user.interests,
        hobbies: user.hobbies,
        zodiac_sign: user.zodiacSign,
        email: email,
        created_at: new Date(),
        is_verified: true,
        is_premium: false,
        diamond_balance: 100,
        profile_completion: 100,
        photo_url: photoUrl,
        profile_photo_url: photoUrl,
        age_group: user.age >= 18 ? 'adult' : 'minor',
        last_active_at: new Date(),
        username: `${user.name.toLowerCase()}${user.age}`,
        tags: []
      });
      
      successCount++;
      console.log(`  ✅ ${user.name} ${user.surname} - ${email}`);
      
    } catch (error: any) {
      errorCount++;
      console.error(`  ❌ Error: ${error.message}`);
    }
  }
  
  console.log(`\n\n📊 ÖZET:`);
  console.log(`✅ Başarılı: ${successCount} kullanıcı`);
  console.log(`❌ Hata: ${errorCount} kullanıcı`);
  console.log(`\n✨ Tüm fotoğraflar 9:16 formatında ve anında yükleniyor!`);
  console.log(`📸 Picsum Photos kullanıldı - delay yok, hızlı ve güvenilir`);
}

addMockUsersDirectly().then(() => {
  console.log('\n🎉 Tamamlandı!');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Fatal error:', error);
  process.exit(1);
});

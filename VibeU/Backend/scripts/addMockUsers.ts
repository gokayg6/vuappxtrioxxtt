import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import * as path from 'path';

// Initialize Firebase Admin
const serviceAccount = require(path.join(__dirname, '../serviceAccountKey.json'));

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();
const auth = getAuth();

// 60+ Mock Users - Mostly Female
const mockUsers = [
  // FEMALE USERS (40)
  { name: "Ayşe", surname: "Yılmaz", age: 24, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Müzik ve sanat tutkunu 🎨", interests: ["Müzik", "Sanat", "Sinema"], hobbies: ["Gitar", "Resim"], zodiacSign: "Koç" },
  { name: "Zeynep", surname: "Kaya", age: 23, gender: "female", city: "Ankara", country: "Türkiye", bio: "Kitap kurdu 📚", interests: ["Kitap", "Yazı", "Şiir"], hobbies: ["Okuma", "Yazma"], zodiacSign: "Boğa" },
  { name: "Elif", surname: "Demir", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Kahve ve derin sohbetler ☕", interests: ["Kahve", "Felsefe", "Psikoloji"], hobbies: ["Kahve", "Sohbet"], zodiacSign: "İkizler" },
  { name: "Selin", surname: "Çelik", age: 24, gender: "female", city: "Antalya", country: "Türkiye", bio: "Yoga ve meditasyon 🧘‍♀️", interests: ["Yoga", "Meditasyon", "Wellness"], hobbies: ["Yoga", "Pilates"], zodiacSign: "Yengeç" },
  { name: "Deniz", surname: "Arslan", age: 26, gender: "female", city: "Bursa", country: "Türkiye", bio: "Seyahat tutkunu ✈️", interests: ["Seyahat", "Fotoğraf", "Doğa"], hobbies: ["Fotoğrafçılık", "Hiking"], zodiacSign: "Aslan" },
  { name: "Ece", surname: "Öztürk", age: 22, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Dans ve müzik 💃", interests: ["Dans", "Müzik", "Parti"], hobbies: ["Dans", "Salsa"], zodiacSign: "Başak" },
  { name: "Ceren", surname: "Aydın", age: 27, gender: "female", city: "Ankara", country: "Türkiye", bio: "Fitness ve sağlıklı yaşam 💪", interests: ["Spor", "Fitness", "Sağlık"], hobbies: ["Gym", "Koşu"], zodiacSign: "Terazi" },
  { name: "Gizem", surname: "Şahin", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Moda ve stil 👗", interests: ["Moda", "Alışveriş", "Stil"], hobbies: ["Shopping", "Styling"], zodiacSign: "Akrep" },
  { name: "Pınar", surname: "Yıldız", age: 26, gender: "female", city: "Adana", country: "Türkiye", bio: "Yemek yapmayı seviyorum 🍳", interests: ["Yemek", "Mutfak", "Gastronomi"], hobbies: ["Cooking", "Baking"], zodiacSign: "Yay" },
  { name: "Merve", surname: "Koç", age: 24, gender: "female", city: "Gaziantep", country: "Türkiye", bio: "Doğa ve kamp 🏕️", interests: ["Doğa", "Kamp", "Trekking"], hobbies: ["Camping", "Hiking"], zodiacSign: "Oğlak" },
  
  { name: "Aylin", surname: "Erdoğan", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Sinema aşığı 🎬", interests: ["Sinema", "Dizi", "Film"], hobbies: ["Film izleme"], zodiacSign: "Kova" },
  { name: "Seda", surname: "Güneş", age: 28, gender: "female", city: "Ankara", country: "Türkiye", bio: "Teknoloji meraklısı 💻", interests: ["Teknoloji", "Bilim", "Oyun"], hobbies: ["Gaming", "Coding"], zodiacSign: "Balık" },
  { name: "Burcu", surname: "Aksoy", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Sanat galerilerini gezmeyi severim 🖼️", interests: ["Sanat", "Müze", "Galeri"], hobbies: ["Müze gezme"], zodiacSign: "Koç" },
  { name: "Nil", surname: "Polat", age: 24, gender: "female", city: "Antalya", country: "Türkiye", bio: "Plaj ve deniz 🏖️", interests: ["Plaj", "Deniz", "Güneş"], hobbies: ["Yüzme", "Sörf"], zodiacSign: "Boğa" },
  { name: "Esra", surname: "Kurt", age: 26, gender: "female", city: "Bursa", country: "Türkiye", bio: "Müzik festivalleri 🎵", interests: ["Müzik", "Festival", "Konser"], hobbies: ["Konser gitme"], zodiacSign: "İkizler" },
  
  { name: "Duygu", surname: "Özkan", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Yoga eğitmeni 🧘", interests: ["Yoga", "Wellness", "Meditasyon"], hobbies: ["Yoga", "Meditasyon"], zodiacSign: "Yengeç" },
  { name: "Cansu", surname: "Yavuz", age: 27, gender: "female", city: "Ankara", country: "Türkiye", bio: "Girişimci ve iş kadını 💼", interests: ["İş", "Girişimcilik", "Networking"], hobbies: ["Okuma", "Networking"], zodiacSign: "Aslan" },
  { name: "Begüm", surname: "Tekin", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Fotoğraf sanatçısı 📸", interests: ["Fotoğraf", "Sanat", "Seyahat"], hobbies: ["Fotoğrafçılık"], zodiacSign: "Başak" },
  { name: "Tuğba", surname: "Çakır", age: 24, gender: "female", city: "Adana", country: "Türkiye", bio: "Pilates eğitmeni 🤸", interests: ["Pilates", "Fitness", "Sağlık"], hobbies: ["Pilates", "Yoga"], zodiacSign: "Terazi" },
  { name: "Özge", surname: "Acar", age: 26, gender: "female", city: "Gaziantep", country: "Türkiye", bio: "Grafik tasarımcı 🎨", interests: ["Tasarım", "Sanat", "Dijital"], hobbies: ["Tasarım", "İllüstrasyon"], zodiacSign: "Akrep" },
  
  { name: "Simge", surname: "Bulut", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Müzisyen ve şarkıcı 🎤", interests: ["Müzik", "Şarkı", "Sahne"], hobbies: ["Şarkı söyleme", "Gitar"], zodiacSign: "Yay" },
  { name: "Melis", surname: "Kılıç", age: 28, gender: "female", city: "Ankara", country: "Türkiye", bio: "Psikolog 🧠", interests: ["Psikoloji", "İnsan", "Gelişim"], hobbies: ["Okuma", "Araştırma"], zodiacSign: "Oğlak" },
  { name: "Damla", surname: "Şen", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Blogger ve influencer 📱", interests: ["Sosyal Medya", "Moda", "Lifestyle"], hobbies: ["Blogging", "Vlogging"], zodiacSign: "Kova" },
  { name: "Yasemin", surname: "Doğan", age: 24, gender: "female", city: "Antalya", country: "Türkiye", bio: "Veteriner 🐾", interests: ["Hayvanlar", "Doğa", "Bakım"], hobbies: ["Hayvan bakımı"], zodiacSign: "Balık" },
  { name: "İrem", surname: "Yurt", age: 26, gender: "female", city: "Bursa", country: "Türkiye", bio: "Öğretmen 📚", interests: ["Eğitim", "Kitap", "Çocuk"], hobbies: ["Okuma", "Öğretme"], zodiacSign: "Koç" },
  
  { name: "Naz", surname: "Eren", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Mimar 🏛️", interests: ["Mimarlık", "Tasarım", "Sanat"], hobbies: ["Çizim", "Tasarım"], zodiacSign: "Boğa" },
  { name: "Dilara", surname: "Aslan", age: 27, gender: "female", city: "Ankara", country: "Türkiye", bio: "Avukat ⚖️", interests: ["Hukuk", "Adalet", "Okuma"], hobbies: ["Okuma", "Tartışma"], zodiacSign: "İkizler" },
  { name: "Buse", surname: "Çetin", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Doktor 👩‍⚕️", interests: ["Tıp", "Sağlık", "Bilim"], hobbies: ["Araştırma", "Okuma"], zodiacSign: "Yengeç" },
  { name: "Eda", surname: "Yalçın", age: 24, gender: "female", city: "Adana", country: "Türkiye", bio: "Mühendis 🔧", interests: ["Mühendislik", "Teknoloji", "İnovasyon"], hobbies: ["Proje geliştirme"], zodiacSign: "Aslan" },
  { name: "Gamze", surname: "Özer", age: 26, gender: "female", city: "Gaziantep", country: "Türkiye", bio: "Pazarlama uzmanı 📊", interests: ["Pazarlama", "Dijital", "Sosyal Medya"], hobbies: ["Analiz", "Strateji"], zodiacSign: "Başak" },
  
  { name: "Hande", surname: "Taş", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Oyuncu 🎭", interests: ["Tiyatro", "Sinema", "Sanat"], hobbies: ["Oyunculuk", "Dans"], zodiacSign: "Terazi" },
  { name: "Sinem", surname: "Kara", age: 28, gender: "female", city: "Ankara", country: "Türkiye", bio: "Yazılım geliştirici 💻", interests: ["Yazılım", "Teknoloji", "AI"], hobbies: ["Coding", "Gaming"], zodiacSign: "Akrep" },
  { name: "Ebru", surname: "Çiftçi", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "İç mimar 🛋️", interests: ["İç Mimarlık", "Dekorasyon", "Tasarım"], hobbies: ["Dekorasyon", "DIY"], zodiacSign: "Yay" },
  { name: "Derya", surname: "Güler", age: 24, gender: "female", city: "Antalya", country: "Türkiye", bio: "Diyetisyen 🥗", interests: ["Beslenme", "Sağlık", "Spor"], hobbies: ["Yemek yapma", "Spor"], zodiacSign: "Oğlak" },
  { name: "Aslı", surname: "Bayrak", age: 26, gender: "female", city: "Bursa", country: "Türkiye", bio: "Gazeteci 📰", interests: ["Gazetecilik", "Haber", "Yazı"], hobbies: ["Yazma", "Araştırma"], zodiacSign: "Kova" },
  
  { name: "Sevgi", surname: "Özkaya", age: 23, gender: "female", city: "İstanbul", country: "Türkiye", bio: "Hemşire 💉", interests: ["Sağlık", "Bakım", "İnsanlık"], hobbies: ["Gönüllülük"], zodiacSign: "Balık" },
  { name: "Gül", surname: "Demirci", age: 27, gender: "female", city: "Ankara", country: "Türkiye", bio: "Eczacı 💊", interests: ["Eczacılık", "Sağlık", "Bilim"], hobbies: ["Okuma", "Araştırma"], zodiacSign: "Koç" },
  { name: "Fulya", surname: "Yıldırım", age: 25, gender: "female", city: "İzmir", country: "Türkiye", bio: "Fizyoterapist 🏥", interests: ["Fizyoterapi", "Sağlık", "Spor"], hobbies: ["Spor", "Yoga"], zodiacSign: "Boğa" },
  { name: "Serap", surname: "Koçak", age: 24, gender: "female", city: "Adana", country: "Türkiye", bio: "Muhasebeci 📊", interests: ["Finans", "Matematik", "İş"], hobbies: ["Okuma", "Analiz"], zodiacSign: "İkizler" },
  { name: "Tuba", surname: "Sarı", age: 26, gender: "female", city: "Gaziantep", country: "Türkiye", bio: "İnsan kaynakları uzmanı 👥", interests: ["İK", "İnsan", "Gelişim"], hobbies: ["Networking", "Okuma"], zodiacSign: "Yengeç" },
  
  // MALE USERS (20)
  { name: "Mehmet", surname: "Yılmaz", age: 27, gender: "male", city: "İstanbul", country: "Türkiye", bio: "Seyahat etmeyi seviyorum ✈️", interests: ["Seyahat", "Fotoğraf", "Doğa"], hobbies: ["Fotoğrafçılık", "Hiking"], zodiacSign: "Aslan" },
  { name: "Can", surname: "Kaya", age: 26, gender: "male", city: "Ankara", country: "Türkiye", bio: "Spor ve fitness 💪", interests: ["Spor", "Fitness", "Sağlık"], hobbies: ["Gym", "Basketbol"], zodiacSign: "Başak" },
  { name: "Burak", surname: "Demir", age: 28, gender: "male", city: "İzmir", country: "Türkiye", bio: "Teknoloji meraklısı 💻", interests: ["Teknoloji", "Bilim", "Oyun"], hobbies: ["Gaming", "Coding"], zodiacSign: "Terazi" },
  { name: "Emre", surname: "Çelik", age: 29, gender: "male", city: "Antalya", country: "Türkiye", bio: "Fotoğrafçılık tutkunu 📸", interests: ["Fotoğraf", "Sanat", "Seyahat"], hobbies: ["Fotoğrafçılık"], zodiacSign: "Akrep" },
  { name: "Arda", surname: "Arslan", age: 27, gender: "male", city: "Bursa", country: "Türkiye", bio: "Kahve içip kitap okumayı seviyorum ☕", interests: ["Kahve", "Kitap", "Müzik"], hobbies: ["Okuma", "Kahve"], zodiacSign: "Yay" },
  
  { name: "Kaan", surname: "Öztürk", age: 26, gender: "male", city: "İstanbul", country: "Türkiye", bio: "Müzik prodüktörü 🎵", interests: ["Müzik", "Prodüksiyon", "Sanat"], hobbies: ["Müzik yapma"], zodiacSign: "Oğlak" },
  { name: "Onur", surname: "Aydın", age: 28, gender: "male", city: "Ankara", country: "Türkiye", bio: "Girişimci 💼", interests: ["İş", "Girişimcilik", "Teknoloji"], hobbies: ["Okuma", "Networking"], zodiacSign: "Kova" },
  { name: "Barış", surname: "Şahin", age: 27, gender: "male", city: "İzmir", country: "Türkiye", bio: "DJ ve müzik sevdalısı 🎧", interests: ["Müzik", "DJ", "Parti"], hobbies: ["DJ", "Müzik"], zodiacSign: "Balık" },
  { name: "Tolga", surname: "Yıldız", age: 29, gender: "male", city: "Adana", country: "Türkiye", bio: "Yazılım mühendisi 💻", interests: ["Yazılım", "Teknoloji", "AI"], hobbies: ["Coding", "Gaming"], zodiacSign: "Koç" },
  { name: "Mert", surname: "Koç", age: 27, gender: "male", city: "Gaziantep", country: "Türkiye", bio: "Psikoloji ve felsefe tutkunu 🧠", interests: ["Psikoloji", "Felsefe", "Sanat"], hobbies: ["Okuma", "Düşünme"], zodiacSign: "Boğa" },
  
  { name: "Alp", surname: "Erdoğan", age: 28, gender: "male", city: "İstanbul", country: "Türkiye", bio: "Dağcı ve doğa sever 🏔️", interests: ["Dağcılık", "Doğa", "Macera"], hobbies: ["Tırmanış", "Kamp"], zodiacSign: "İkizler" },
  { name: "Eren", surname: "Güneş", age: 29, gender: "male", city: "Ankara", country: "Türkiye", bio: "Kitaplar, müzik ve derin düşünceler 📚", interests: ["Kitap", "Müzik", "Felsefe"], hobbies: ["Okuma", "Müzik"], zodiacSign: "Yengeç" },
  { name: "Serkan", surname: "Aksoy", age: 27, gender: "male", city: "İzmir", country: "Türkiye", bio: "Aşçı ve gurme 🍳", interests: ["Yemek", "Mutfak", "Gastronomi"], hobbies: ["Yemek yapma"], zodiacSign: "Aslan" },
  { name: "Deniz", surname: "Polat", age: 26, gender: "male", city: "Antalya", country: "Türkiye", bio: "Sörf ve deniz sporları 🏄", interests: ["Sörf", "Deniz", "Spor"], hobbies: ["Sörf", "Dalış"], zodiacSign: "Başak" },
  { name: "Oğuz", surname: "Kurt", age: 28, gender: "male", city: "Bursa", country: "Türkiye", bio: "Mimar ve tasarımcı 🏛️", interests: ["Mimarlık", "Tasarım", "Sanat"], hobbies: ["Çizim", "Tasarım"], zodiacSign: "Terazi" },
  
  { name: "Cem", surname: "Özkan", age: 27, gender: "male", city: "İstanbul", country: "Türkiye", bio: "Sinema ve dizi bağımlısı 🎬", interests: ["Sinema", "Dizi", "Film"], hobbies: ["Film izleme"], zodiacSign: "Akrep" },
  { name: "Umut", surname: "Yavuz", age: 29, gender: "male", city: "Ankara", country: "Türkiye", bio: "Doktor 👨‍⚕️", interests: ["Tıp", "Sağlık", "Bilim"], hobbies: ["Araştırma", "Okuma"], zodiacSign: "Yay" },
  { name: "Hakan", surname: "Tekin", age: 28, gender: "male", city: "İzmir", country: "Türkiye", bio: "Avukat ⚖️", interests: ["Hukuk", "Adalet", "Okuma"], hobbies: ["Okuma", "Tartışma"], zodiacSign: "Oğlak" },
  { name: "Volkan", surname: "Çakır", age: 27, gender: "male", city: "Adana", country: "Türkiye", bio: "Pazarlama uzmanı 📊", interests: ["Pazarlama", "Dijital", "Sosyal Medya"], hobbies: ["Analiz", "Strateji"], zodiacSign: "Kova" },
  { name: "Kerem", surname: "Acar", age: 26, gender: "male", city: "Gaziantep", country: "Türkiye", bio: "Müzisyen ve besteci 🎸", interests: ["Müzik", "Beste", "Sanat"], hobbies: ["Gitar", "Beste"], zodiacSign: "Balık" }
];

async function addMockUsers() {
  console.log('🚀 Starting to add 60 mock users to Firebase...\n');
  
  let successCount = 0;
  let errorCount = 0;
  
  for (const user of mockUsers) {
    try {
      // Create auth user
      const email = `${user.name.toLowerCase()}.${user.surname.toLowerCase()}@vibeumock.com`;
      const password = 'VibeU2024!';
      
      const userRecord = await auth.createUser({
        email: email,
        password: password,
        displayName: `${user.name} ${user.surname}`,
      });
      
      // Add to Firestore
      await db.collection('users').doc(userRecord.uid).set({
        name: user.name,
        surname: user.surname,
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
        // Note: photo_url should be added manually via Firebase Console with real photos
        photo_url: `https://ui-avatars.com/api/?name=${user.name}+${user.surname}&size=512&background=random`
      });
      
      successCount++;
      console.log(`✅ Added: ${user.name} ${user.surname} (${user.gender}) - ${email}`);
      
    } catch (error: any) {
      errorCount++;
      console.error(`❌ Error adding ${user.name} ${user.surname}:`, error.message);
    }
  }
  
  console.log(`\n📊 Summary:`);
  console.log(`✅ Successfully added: ${successCount} users`);
  console.log(`❌ Errors: ${errorCount} users`);
  console.log(`\n⚠️  IMPORTANT: Please add real 9:16 photos to these users via Firebase Console!`);
  console.log(`   Go to Firebase Console > Storage > Upload photos`);
  console.log(`   Then update photo_url field in Firestore for each user`);
}

addMockUsers().then(() => {
  console.log('\n✨ Done!');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Fatal error:', error);
  process.exit(1);
});

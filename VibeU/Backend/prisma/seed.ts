import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const interests = [
  // Müzik
  { code: 'pop_music', nameEn: 'Pop Music', nameEs: 'Música Pop', namePt: 'Música Pop', nameFr: 'Musique Pop', nameTr: 'Pop Müzik', emoji: '🎵', category: 'Müzik' },
  { code: 'rock_music', nameEn: 'Rock Music', nameEs: 'Música Rock', namePt: 'Música Rock', nameFr: 'Musique Rock', nameTr: 'Rock Müzik', emoji: '🎸', category: 'Müzik' },
  { code: 'hip_hop', nameEn: 'Hip Hop', nameEs: 'Hip Hop', namePt: 'Hip Hop', nameFr: 'Hip Hop', nameTr: 'Hip Hop', emoji: '🎤', category: 'Müzik' },
  { code: 'electronic', nameEn: 'Electronic', nameEs: 'Electrónica', namePt: 'Eletrônica', nameFr: 'Électronique', nameTr: 'Elektronik', emoji: '🎧', category: 'Müzik' },
  { code: 'jazz', nameEn: 'Jazz', nameEs: 'Jazz', namePt: 'Jazz', nameFr: 'Jazz', nameTr: 'Caz', emoji: '🎷', category: 'Müzik' },
  { code: 'classical', nameEn: 'Classical', nameEs: 'Clásica', namePt: 'Clássica', nameFr: 'Classique', nameTr: 'Klasik', emoji: '🎻', category: 'Müzik' },
  { code: 'rnb', nameEn: 'R&B', nameEs: 'R&B', namePt: 'R&B', nameFr: 'R&B', nameTr: 'R&B', emoji: '🎶', category: 'Müzik' },
  { code: 'turkish_music', nameEn: 'Turkish Music', nameEs: 'Música Turca', namePt: 'Música Turca', nameFr: 'Musique Turque', nameTr: 'Türk Müziği', emoji: '🇹🇷', category: 'Müzik' },
  
  // Spor
  { code: 'football', nameEn: 'Football', nameEs: 'Fútbol', namePt: 'Futebol', nameFr: 'Football', nameTr: 'Futbol', emoji: '⚽', category: 'Spor' },
  { code: 'basketball', nameEn: 'Basketball', nameEs: 'Baloncesto', namePt: 'Basquete', nameFr: 'Basketball', nameTr: 'Basketbol', emoji: '🏀', category: 'Spor' },
  { code: 'tennis', nameEn: 'Tennis', nameEs: 'Tenis', namePt: 'Tênis', nameFr: 'Tennis', nameTr: 'Tenis', emoji: '🎾', category: 'Spor' },
  { code: 'swimming', nameEn: 'Swimming', nameEs: 'Natación', namePt: 'Natação', nameFr: 'Natation', nameTr: 'Yüzme', emoji: '🏊', category: 'Spor' },
  { code: 'gym', nameEn: 'Gym', nameEs: 'Gimnasio', namePt: 'Academia', nameFr: 'Gym', nameTr: 'Spor Salonu', emoji: '💪', category: 'Spor' },
  { code: 'yoga', nameEn: 'Yoga', nameEs: 'Yoga', namePt: 'Yoga', nameFr: 'Yoga', nameTr: 'Yoga', emoji: '🧘', category: 'Spor' },
  { code: 'running', nameEn: 'Running', nameEs: 'Correr', namePt: 'Corrida', nameFr: 'Course', nameTr: 'Koşu', emoji: '🏃', category: 'Spor' },
  { code: 'cycling', nameEn: 'Cycling', nameEs: 'Ciclismo', namePt: 'Ciclismo', nameFr: 'Cyclisme', nameTr: 'Bisiklet', emoji: '🚴', category: 'Spor' },
  
  // Yemek
  { code: 'cooking', nameEn: 'Cooking', nameEs: 'Cocinar', namePt: 'Cozinhar', nameFr: 'Cuisine', nameTr: 'Yemek Yapmak', emoji: '👨‍🍳', category: 'Yemek' },
  { code: 'coffee', nameEn: 'Coffee', nameEs: 'Café', namePt: 'Café', nameFr: 'Café', nameTr: 'Kahve', emoji: '☕', category: 'Yemek' },
  { code: 'wine', nameEn: 'Wine', nameEs: 'Vino', namePt: 'Vinho', nameFr: 'Vin', nameTr: 'Şarap', emoji: '🍷', category: 'Yemek' },
  { code: 'sushi', nameEn: 'Sushi', nameEs: 'Sushi', namePt: 'Sushi', nameFr: 'Sushi', nameTr: 'Suşi', emoji: '🍣', category: 'Yemek' },
  { code: 'pizza', nameEn: 'Pizza', nameEs: 'Pizza', namePt: 'Pizza', nameFr: 'Pizza', nameTr: 'Pizza', emoji: '🍕', category: 'Yemek' },
  { code: 'vegan', nameEn: 'Vegan', nameEs: 'Vegano', namePt: 'Vegano', nameFr: 'Végan', nameTr: 'Vegan', emoji: '🥗', category: 'Yemek' },
  { code: 'turkish_food', nameEn: 'Turkish Food', nameEs: 'Comida Turca', namePt: 'Comida Turca', nameFr: 'Cuisine Turque', nameTr: 'Türk Mutfağı', emoji: '🥙', category: 'Yemek' },
  { code: 'desserts', nameEn: 'Desserts', nameEs: 'Postres', namePt: 'Sobremesas', nameFr: 'Desserts', nameTr: 'Tatlılar', emoji: '🍰', category: 'Yemek' },
  
  // Seyahat
  { code: 'beach', nameEn: 'Beach', nameEs: 'Playa', namePt: 'Praia', nameFr: 'Plage', nameTr: 'Plaj', emoji: '🏖️', category: 'Seyahat' },
  { code: 'mountains', nameEn: 'Mountains', nameEs: 'Montañas', namePt: 'Montanhas', nameFr: 'Montagnes', nameTr: 'Dağlar', emoji: '🏔️', category: 'Seyahat' },
  { code: 'city_trips', nameEn: 'City Trips', nameEs: 'Viajes Urbanos', namePt: 'Viagens Urbanas', nameFr: 'Voyages Urbains', nameTr: 'Şehir Gezileri', emoji: '🏙️', category: 'Seyahat' },
  { code: 'camping', nameEn: 'Camping', nameEs: 'Camping', namePt: 'Camping', nameFr: 'Camping', nameTr: 'Kamp', emoji: '⛺', category: 'Seyahat' },
  { code: 'road_trips', nameEn: 'Road Trips', nameEs: 'Viajes por Carretera', namePt: 'Viagens de Carro', nameFr: 'Road Trips', nameTr: 'Yol Gezileri', emoji: '🚗', category: 'Seyahat' },
  { code: 'backpacking', nameEn: 'Backpacking', nameEs: 'Mochilero', namePt: 'Mochilão', nameFr: 'Sac à Dos', nameTr: 'Sırt Çantalı Gezi', emoji: '🎒', category: 'Seyahat' },
  
  // Film
  { code: 'action_movies', nameEn: 'Action Movies', nameEs: 'Películas de Acción', namePt: 'Filmes de Ação', nameFr: 'Films d\'Action', nameTr: 'Aksiyon Filmleri', emoji: '💥', category: 'Film' },
  { code: 'comedy', nameEn: 'Comedy', nameEs: 'Comedia', namePt: 'Comédia', nameFr: 'Comédie', nameTr: 'Komedi', emoji: '😂', category: 'Film' },
  { code: 'horror', nameEn: 'Horror', nameEs: 'Terror', namePt: 'Terror', nameFr: 'Horreur', nameTr: 'Korku', emoji: '👻', category: 'Film' },
  { code: 'romance', nameEn: 'Romance', nameEs: 'Romance', namePt: 'Romance', nameFr: 'Romance', nameTr: 'Romantik', emoji: '💕', category: 'Film' },
  { code: 'sci_fi', nameEn: 'Sci-Fi', nameEs: 'Ciencia Ficción', namePt: 'Ficção Científica', nameFr: 'Science-Fiction', nameTr: 'Bilim Kurgu', emoji: '🚀', category: 'Film' },
  { code: 'documentaries', nameEn: 'Documentaries', nameEs: 'Documentales', namePt: 'Documentários', nameFr: 'Documentaires', nameTr: 'Belgeseller', emoji: '🎬', category: 'Film' },
  { code: 'anime', nameEn: 'Anime', nameEs: 'Anime', namePt: 'Anime', nameFr: 'Anime', nameTr: 'Anime', emoji: '🎌', category: 'Film' },
  { code: 'series', nameEn: 'TV Series', nameEs: 'Series', namePt: 'Séries', nameFr: 'Séries', nameTr: 'Diziler', emoji: '📺', category: 'Film' },
  
  // Hobiler
  { code: 'reading', nameEn: 'Reading', nameEs: 'Lectura', namePt: 'Leitura', nameFr: 'Lecture', nameTr: 'Okumak', emoji: '📚', category: 'Hobiler' },
  { code: 'gaming', nameEn: 'Gaming', nameEs: 'Videojuegos', namePt: 'Jogos', nameFr: 'Jeux Vidéo', nameTr: 'Oyun', emoji: '🎮', category: 'Hobiler' },
  { code: 'photography', nameEn: 'Photography', nameEs: 'Fotografía', namePt: 'Fotografia', nameFr: 'Photographie', nameTr: 'Fotoğrafçılık', emoji: '📷', category: 'Hobiler' },
  { code: 'dancing', nameEn: 'Dancing', nameEs: 'Bailar', namePt: 'Dançar', nameFr: 'Danse', nameTr: 'Dans', emoji: '💃', category: 'Hobiler' },
  { code: 'gardening', nameEn: 'Gardening', nameEs: 'Jardinería', namePt: 'Jardinagem', nameFr: 'Jardinage', nameTr: 'Bahçecilik', emoji: '🌱', category: 'Hobiler' },
  { code: 'pets', nameEn: 'Pets', nameEs: 'Mascotas', namePt: 'Animais', nameFr: 'Animaux', nameTr: 'Evcil Hayvanlar', emoji: '🐾', category: 'Hobiler' },
  { code: 'diy', nameEn: 'DIY', nameEs: 'Bricolaje', namePt: 'Faça Você Mesmo', nameFr: 'Bricolage', nameTr: 'Kendin Yap', emoji: '🔧', category: 'Hobiler' },
  { code: 'writing', nameEn: 'Writing', nameEs: 'Escribir', namePt: 'Escrever', nameFr: 'Écriture', nameTr: 'Yazmak', emoji: '✍️', category: 'Hobiler' },
  
  // Sanat
  { code: 'painting', nameEn: 'Painting', nameEs: 'Pintura', namePt: 'Pintura', nameFr: 'Peinture', nameTr: 'Resim', emoji: '🎨', category: 'Sanat' },
  { code: 'museums', nameEn: 'Museums', nameEs: 'Museos', namePt: 'Museus', nameFr: 'Musées', nameTr: 'Müzeler', emoji: '🏛️', category: 'Sanat' },
  { code: 'theater', nameEn: 'Theater', nameEs: 'Teatro', namePt: 'Teatro', nameFr: 'Théâtre', nameTr: 'Tiyatro', emoji: '🎭', category: 'Sanat' },
  { code: 'concerts', nameEn: 'Concerts', nameEs: 'Conciertos', namePt: 'Concertos', nameFr: 'Concerts', nameTr: 'Konserler', emoji: '🎤', category: 'Sanat' },
  { code: 'sculpture', nameEn: 'Sculpture', nameEs: 'Escultura', namePt: 'Escultura', nameFr: 'Sculpture', nameTr: 'Heykel', emoji: '🗿', category: 'Sanat' },
  { code: 'fashion', nameEn: 'Fashion', nameEs: 'Moda', namePt: 'Moda', nameFr: 'Mode', nameTr: 'Moda', emoji: '👗', category: 'Sanat' },
  
  // Teknoloji
  { code: 'programming', nameEn: 'Programming', nameEs: 'Programación', namePt: 'Programação', nameFr: 'Programmation', nameTr: 'Programlama', emoji: '💻', category: 'Teknoloji' },
  { code: 'ai', nameEn: 'AI', nameEs: 'IA', namePt: 'IA', nameFr: 'IA', nameTr: 'Yapay Zeka', emoji: '🤖', category: 'Teknoloji' },
  { code: 'crypto', nameEn: 'Crypto', nameEs: 'Cripto', namePt: 'Cripto', nameFr: 'Crypto', nameTr: 'Kripto', emoji: '₿', category: 'Teknoloji' },
  { code: 'startups', nameEn: 'Startups', nameEs: 'Startups', namePt: 'Startups', nameFr: 'Startups', nameTr: 'Girişimler', emoji: '🚀', category: 'Teknoloji' },
  { code: 'gadgets', nameEn: 'Gadgets', nameEs: 'Gadgets', namePt: 'Gadgets', nameFr: 'Gadgets', nameTr: 'Teknolojik Aletler', emoji: '📱', category: 'Teknoloji' },
  { code: 'social_media', nameEn: 'Social Media', nameEs: 'Redes Sociales', namePt: 'Redes Sociais', nameFr: 'Réseaux Sociaux', nameTr: 'Sosyal Medya', emoji: '📲', category: 'Teknoloji' },
];

async function main() {
  console.log('🌱 Seeding interests...');
  
  for (const interest of interests) {
    await prisma.interest.upsert({
      where: { code: interest.code },
      update: interest,
      create: interest,
    });
  }
  
  console.log(`✅ Seeded ${interests.length} interests`);
  
  // Seed test users
  console.log('🌱 Seeding test users...');
  
  const testUsers = [
    {
      id: 'test-user-1',
      phone: '+905551234567',
      username: 'ayse_yilmaz',
      displayName: 'Ayşe Yılmaz',
      dateOfBirth: new Date('2000-05-15'),
      gender: 'female',
      city: 'İstanbul',
      country: 'TR',
      bio: 'Merhaba! Yeni arkadaşlıklar kurmak istiyorum 🌸',
      profilePhotoUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
      instagramUsername: 'ayse_yilmaz',
      tiktokUsername: 'ayseyilmaz',
      snapchatUsername: 'ayse.y',
      isPremium: false,
      isBanned: false,
      lastActiveAt: new Date(),
    },
    {
      id: 'test-user-2',
      phone: '+905559876543',
      username: 'mehmet_kaya',
      displayName: 'Mehmet Kaya',
      dateOfBirth: new Date('1998-08-20'),
      gender: 'male',
      city: 'Ankara',
      country: 'TR',
      bio: 'Spor ve müzik tutkunu 🎸⚽',
      profilePhotoUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      instagramUsername: 'mehmet_kaya',
      tiktokUsername: 'mehmetkaya',
      snapchatUsername: 'mehmet.k',
      isPremium: true,
      isBanned: false,
      lastActiveAt: new Date(),
    },
    {
      id: 'test-user-3',
      phone: '+905553334444',
      username: 'zeynep_demir',
      displayName: 'Zeynep Demir',
      dateOfBirth: new Date('2001-03-10'),
      gender: 'female',
      city: 'İzmir',
      country: 'TR',
      bio: 'Seyahat ve fotoğrafçılık ✈️📷',
      profilePhotoUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
      instagramUsername: 'zeynep_demir',
      tiktokUsername: 'zeynepdemir',
      snapchatUsername: 'zeynep.d',
      isPremium: false,
      isBanned: false,
      lastActiveAt: new Date(),
    },
  ];
  
  for (const user of testUsers) {
    await prisma.user.upsert({
      where: { id: user.id },
      update: user,
      create: user,
    });
  }
  
  console.log(`✅ Seeded ${testUsers.length} test users`);
  
  // Create a friendship between user 1 and user 2
  console.log('🌱 Seeding friendships...');
  
  await prisma.friendship.upsert({
    where: { id: 'friendship-1' },
    update: {},
    create: {
      id: 'friendship-1',
      userAId: 'test-user-1',
      userBId: 'test-user-2',
    },
  });
  
  console.log('✅ Seeded friendships');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

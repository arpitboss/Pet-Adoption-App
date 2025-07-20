# 🐾 Pet Adoption App

A modern, user-friendly mobile application that connects loving families with pets in need of homes. Built with Flutter, this app provides a seamless experience for browsing, favoriting, and adopting pets.

## ✨ Features

### 🔍 Smart Search & Filtering
- **Species Filter**: Search for dogs, cats, and other animals
- **Age Filter**: Find puppies, kittens, adults, or senior pets
- **Advanced Filters**: Filter by size, breed, temperament, and location
- **Real-time Search**: Instant results as you type

### 📱 Rich Pet Profiles
- **High-Quality Images**: Zoomable photo galleries for each pet
- **Detailed Information**: Age, breed, personality, medical history, and special needs

### ❤️ Adoption Features
- **One-Tap Adoption**: Streamlined adoption process
- **Celebration Animation**: Delightful confetti animation upon successful adoption
- **Adoption History**: Track all your adopted pets in one place
- **Adoption Status**: Real-time updates on application status

### 💫 Personalization
- **Favorites System**: Save pets you're interested in for later
- **Wishlist Management**: Organize your favorite pets
- **Adoption History**: View your complete adoption journey

### 🎨 User Experience
- **Dark/Light Mode**: Toggle between themes for comfortable viewing
- **Responsive Design**: Optimized for all screen sizes
- **Smooth Animations**: Polished transitions and micro-interactions
- **Offline Support**: Browse previously loaded content without internet

## 📱 Screenshots

| Home Page | History Page | Favorites Page | Details Page | Zoom Out View of Pet | Adoption Success |
|-----------|--------------|----------------|--------------|---------------------|------------------|
| ![Home Page](https://github.com/user-attachments/assets/b6b69a7a-e0e6-4c9e-a67e-69ca7f285dc8) | ![History Page](https://github.com/user-attachments/assets/a17c76c0-100b-4aac-a27c-541b687e099f) | ![Favorites Page](https://github.com/user-attachments/assets/6a7b7049-ffa7-4841-a671-349339a1fb39) | ![Details Page](https://github.com/user-attachments/assets/5b89eaa4-f7a3-42a4-be0a-f3a849475d38) | ![Zoom Out View of Pet](https://github.com/user-attachments/assets/86a9ea8f-9d2f-4807-991d-b95fbc5ed861) | ![Adoption Success](https://github.com/user-attachments/assets/2b5402a8-3566-457c-b7d0-5aefd1d770c7) |

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Bloc
- **Local Database**: Hive for caching and offline storage
- **API Integration**: REST API for pet data
- **Image Handling**: Cached network images with zoom functionality
- **Animations**: Custom animations and Hero animations

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/arpitboss/Pet-Adoption-App
   cd pet-adoption-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Add your API keys and configuration
   # Edit .env with your preferred text editor
   ```

4. **Run the app**
   ```bash
   # For debug mode
   flutter run
   
   # For release mode
   flutter run --release
   ```

### Environment Setup

Create a `.env` file in the root directory with the following variables:

```env
API_BASE_URL=https://api.thecatapi.com
ENABLE_ANALYTICS=true
```

## 🏗️ Architecture

```
lib/
├── blocs/
│   ├── adoption_bloc.dart
│   ├── favorite_bloc.dart
│   ├── pet_list_bloc.dart
│   └── theme_bloc.dart
├── models/
│   ├── adopted_pet.dart
│   ├── adopted_pet.g dart
│   ├── pet.dart
│   └── pet.g.dart
├── repositories/
│   └── pet_repository.dart
├── screens/
│   ├── details_page.dart
│   ├── favorites_page.dart
│   ├── history_page.dart
│   ├── home_page.dart
│   └── main_screen.dart
├── widgets/
│   └── pet_card.dart
└── main.dart
```

## 📦 Dependencies

### Core Dependencies
- `flutter`: UI framework
- `hive`: Local database and caching
- `bloc`: State management
- `http`: API communication
- `cached_network_image`: Image caching and loading

### UI/UX Dependencies
- `hero`: Animations and micro-interactions
- `confetti`: Celebration animations
  
## 🌐 Deployment

### Production Build
```bash
# Android APK
flutter build apk --release

# iOS IPA
flutter build ios --release

# Web
flutter build web --release
```

### Hosting
- **Web Version**: Deployed on [Netlify](https://arpit-pet-adoption-app.netlify.app/)
- **API**: Used Publicly available API.

## 🤝 Contributing

We welcome contributions from the community! Here's how to get started:

### Development Workflow

1. **Fork and Clone**
   ```bash
   git clone https://github.com/arpitboss/Pet-Adoption-App.git
   cd pet-adoption-app
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/amazing-new-feature
   ```

3. **Make Your Changes**
   - Follow the existing code style
   - Add tests for new features
   - Update documentation as needed

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add amazing new feature"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/amazing-new-feature
   ```
   Then create a Pull Request on GitHub.

### Commit Convention
We use [Conventional Commits](https://conventionalcommits.org/):
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation updates
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Adding or updating tests

## 📋 Roadmap

- [ ] **Push Notifications**: Notify users about new pets and adoption updates
- [ ] **Pet Care Tips**: Educational content for new pet owners
- [ ] **Virtual Meetups**: Video calls with pets before adoption
- [ ] **Community Features**: User reviews and adoption stories
- [ ] **Multi-language Support**: Localization for different regions
- [ ] **Advanced Matching**: AI-powered pet-owner compatibility matching

## 🐛 Known Issues

- Image loading may be slow on poor network connections
- Dark mode toggle requires app restart on some devices
- Search filters reset when navigating back from pet details

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Email**: workother001@gmail.com
- **Issues**: [GitHub Issues](https://github.com/arpitboss/Pet-Adoption-App/issues)

## 🙏 Acknowledgments

- [Pet API Provider](https://api.thecatapi.com) for providing pet data
  
---

<div align="center">
  <p>Made with ❤️ for pets and their future families</p>
</div>

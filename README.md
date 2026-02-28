# VRecorder - Professional Voice Recording Application

A modern, elegant voice recording application built with Flutter and Clean Architecture. VRecorder provides seamless audio recording, playback, and management with a beautiful glassmorphism UI design.

## 🎯 Features

### Core Recording Features
- **Real-time Voice Recording** - Direct microphone input using PulseAudio
- **Live Sound Level Visualization** - Visual feedback with color-coded indicators (green → yellow → red)
- **Precise Timing** - Accurate elapsed time tracking during recording
- **High-Quality Audio** - 44.1 kHz, 16-bit, Stereo PCM format

### Recording Management
- **Automatic Save** - Recordings automatically saved to `~/Music` directory
- **Persistent Storage** - All recordings metadata stored in `~/.local/share/venom/recordings.json`
- **Recording Metadata** - Displays filename, duration, file size, and creation time
- **Delete Recordings** - Remove recordings with automatic file cleanup

### Playback & Interaction
- **Built-in Playback** - Play recordings directly from the application
- **File Information** - View detailed recording information (duration, size, creation date)
- **Quick Access** - All saved recordings displayed in an organized list view

### User Interface
- **Glassmorphism Design** - Modern glass-effect UI components
- **Material 3 Design** - Latest Material Design specifications
- **Responsive Layout** - Optimized for desktop Linux platforms
- **Dark Theme** - Easy on the eyes with VAXP dark color scheme
- **Custom Titlebar** - Desktop-native window controls

## 🏗️ Architecture

VRecorder follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── domain/                          # Business Logic Layer
│   ├── entities/                    # Pure data models
│   │   └── recording.dart
│   ├── repositories/                # Abstract repository interfaces
│   │   └── audio_repository.dart
│   └── usecases/                    # Business logic use cases
│       ├── start_recording.dart
│       ├── stop_recording.dart
│       ├── get_recordings.dart
│       ├── delete_recording.dart
│       └── get_current_level.dart
│
├── data/                            # Data Layer
│   ├── datasources/                 # Data source implementations
│   │   ├── audio_local_datasource.dart (interface)
│   │   └── audio_local_datasource_impl.dart (implementation)
│   └── repositories/                # Repository implementations
│       └── audio_repository_impl.dart
│
├── presentation/                    # Presentation Layer
│   ├── bloc/                        # State Management
│   │   ├── audio_bloc.dart
│   │   ├── audio_event.dart
│   │   └── audio_state.dart
│   └── pages/                       # UI Pages
│       └── recorder_page.dart
│
├── core/                            # Core Services
│   ├── audio/                       # FFI Bindings
│   │   └── audio_ffi.dart
│   ├── service_locator.dart         # Dependency Injection
│   ├── colors/                      # Theme Colors
│   ├── theme/                       # Theme Configuration
│   └── venom_layout.dart            # Layout Components
│
└── main.dart                        # Application Entry Point
```

## 🔧 Technology Stack

### Frontend
- **Flutter** 3.38.3 - Cross-platform UI framework
- **Flutter BLoC** 8.1.5 - State management
- **Material 3** - Modern UI design
- **window_manager** 0.5.1 - Desktop window control

### Backend & Audio
- **FFI (Foreign Function Interface)** - Native C++ integration
- **PulseAudio** - Linux audio system integration
- **C++** - Native audio capture and processing

### Data Persistence
- **JSON** - Recording metadata storage
- **File System** - Recording audio file storage

### Configuration
- **venom_config** 0.0.1 - Dynamic theme configuration
- **VAXP Colors** - Predefined color scheme

## 📋 Requirements

### System Requirements
- Linux desktop (Ubuntu 20.04 or newer recommended)
- PulseAudio (usually pre-installed)
- 100MB free disk space for application
- Additional space for recordings (varies by usage)

### Development Requirements
- Flutter SDK 3.38.3+
- Dart SDK 3.0+
- CMake 3.13+
- GCC/Clang C++ compiler
- PulseAudio development libraries

### Installation of Dependencies

**Ubuntu/Debian:**
```bash
sudo apt-get install -y \
  libpulse-dev \
  libpulse-simple0 \
  cmake \
  clang \
  build-essential
```

**Fedora:**
```bash
sudo dnf install -y \
  pulseaudio-libs-devel \
  cmake \
  gcc-c++ \
  make
```

## 🚀 Getting Started

### Installation

1. **Clone or extract the project**
```bash
cd Vaxp-Template
```

2. **Install Flutter dependencies**
```bash
flutter pub get
```

3. **Build for Linux**
```bash
flutter build linux --release
```

4. **Run the application**
```bash
./build/linux/x64/release/bundle/venom
```

### Development Build

For development with hot reload:
```bash
flutter run -d linux
```

### Development Build with Debug Output

```bash
flutter run -d linux --debug
```

## 📖 Usage Guide

### Starting a Recording

1. Launch VRecorder application
2. Click the **Start** button (green microphone icon)
3. The timer will begin counting elapsed time
4. Watch the sound level bar respond to your voice

### Stopping a Recording

1. Click the **Stop** button (red stop icon)
2. Recording is automatically saved to `~/Music/`
3. Metadata saved to `~/.local/share/venom/recordings.json`
4. Recording appears in "Saved Recordings" list

### Playing a Recording

1. In "Saved Recordings" section, find desired recording
2. Click the **Play** button (green play icon)
3. Recording opens in default audio player

### Deleting a Recording

1. In "Saved Recordings" section, find recording to delete
2. Click the **Delete** button (red trash icon)
3. Confirm deletion
4. Recording removed from list and file deleted from disk

### Viewing Recording Details

- **Filename** - Auto-generated unique filename with timestamp
- **Duration** - Total recording length (HH:MM:SS format)
- **File Size** - Displays in B, KB, or MB format
- **Creation Date** - When recording was created

## 🔊 Audio Specifications

- **Sample Rate** - 44.1 kHz (CD quality)
- **Bit Depth** - 16-bit PCM
- **Channels** - Stereo (2 channels)
- **Format** - WAV (RIFF)
- **Codec** - Uncompressed PCM
- **Bitrate** - ~1.4 Mbps (44.1 kHz × 16-bit × 2 channels)

## 📁 File Storage

### Recording Files
- Location: `~/Music/recording_[timestamp].wav`
- Format: Standard WAV files
- Playable by: Any standard audio player (VLC, GNOME Music, etc.)

### Metadata
- Location: `~/.local/share/venom/recordings.json`
- Format: JSON array of recording objects
- Contains: ID, filename, path, duration, file size, creation time
- Survives: Application restarts and updates

## 🎨 UI Components

### Main Recording Section
- Title: "New Voice Recording"
- Displays current elapsed time in large digits
- Live sound level progress bar
- Start/Stop button with color feedback

### Saved Recordings Section
- Title: "Saved Recordings"
- List of all saved recordings with metadata
- Play button for each recording
- Delete button for each recording
- Empty state message when no recordings exist

### Color Coding
- **Green Start Button** - Ready to record
- **Red Stop Button** - Currently recording
- **Green Sound Level** - Low volume (< 50%)
- **Yellow Sound Level** - Medium volume (50-75%)
- **Red Sound Level** - High volume (> 75%)

## 🔐 Data Privacy

- All recordings stored locally on your system
- No cloud uploads or network transmission
- No analytics or telemetry collection
- Metadata stored in standard JSON format (human-readable)
- User full control over all recordings

## 🐛 Troubleshooting

### No Sound Recorded
1. Check PulseAudio is running: `pactl info`
2. Verify microphone input: `parecord --list-sources`
3. Check microphone levels in PulseAudio mixer
4. Restart PulseAudio if needed: `pulseaudio -k`

### Application Won't Start
1. Ensure Flutter and Dart are properly installed
2. Check all dependencies are installed
3. Clean build: `rm -rf build && flutter build linux`
4. Verify PulseAudio libraries: `pkg-config --modversion libpulse-simple`

### Recordings Not Appearing
1. Check `~/.local/share/venom/recordings.json` exists
2. Verify `~/Music/` directory exists
3. Check file permissions: `ls -la ~/.local/share/venom/`
4. Check WAV files exist in Music folder

### Poor Audio Quality
1. Check microphone hardware quality
2. Reduce background noise
3. Position microphone closer to audio source
4. Adjust system volume levels

## 🔧 Building from Source

### Debug Build
```bash
flutter build linux --debug
```

### Release Build (Optimized)
```bash
flutter build linux --release
```

### Custom Build with Verbose Output
```bash
flutter build linux --verbose
```

## 📦 Project Structure Summary

| Directory | Purpose |
|-----------|---------|
| `lib/` | Dart source code |
| `ffi/` | C++ native code |
| `linux/` | Linux platform configuration |
| `build/` | Build output (generated) |
| `assets/` | Application resources |
| `pubspec.yaml` | Flutter dependencies |

## 🤝 Contributing

1. Test changes thoroughly on Linux desktop
2. Maintain Clean Architecture principles
3. Follow Dart style guidelines
4. Document any API changes
5. Update README for new features

## 📝 License

This project is part of the VAXP Template Suite.

## 👨‍💻 Development

### Key Dependencies

```yaml
flutter_bloc: ^8.1.5
equatable: ^2.0.5
window_manager: ^0.5.1
venom_config: ^0.0.1
ffi: ^2.1.0
```

### Native Dependencies

- libpulse-simple (PulseAudio)
- C++ Standard Library (C++14)

## 📞 Support

For issues or questions:
1. Check the Troubleshooting section
2. Review application logs: Check terminal output
3. Verify system requirements are met
4. Consult PulseAudio documentation

## 🎯 Future Enhancements

Potential features for future versions:
- Recording trim and editing
- Multiple audio format support (MP3, FLAC, OGG)
- Recording search and filtering
- Audio waveform visualization
- Recording notes and tags
- Cloud sync integration
- Voice-to-text transcription
- Recording categorization
- Export to different formats
- Audio amplification tools

## 📊 Version Information

- **Application Name** - VRecorder
- **Current Build** - Linux x64 Release
- **Platform** - Linux Desktop
- **Flutter Version** - 3.38.3
- **Dart Version** - 3.0+

## ✨ Credits

Built with Flutter and Clean Architecture principles, featuring:
- VAXP design system
- Material Design 3
- Modern glassmorphism UI
- Professional audio processing

---

**VRecorder** - Your Professional Voice Recording Solution

*Last Updated: February 28, 2026*
# vrecorder

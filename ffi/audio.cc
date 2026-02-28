#include "audio.h"
#include <cstdio>
#include <cstring>
#include <cmath>
#include <map>
#include <memory>
#include <thread>
#include <mutex>
#include <vector>
#include <chrono>

extern "C" {
#include <pulse/simple.h>
#include <pulse/error.h>
}

// هياكل البيانات
struct RecordingSession {
  int64_t id;
  pa_simple* pa_device;
  bool is_recording;
  std::vector<uint8_t> audio_buffer;
  double current_level;
  std::chrono::system_clock::time_point start_time;
  std::thread* recording_thread;
  std::mutex buffer_mutex;

  RecordingSession()
      : id(0), pa_device(nullptr), is_recording(false), current_level(0.0),
        recording_thread(nullptr) {}
};

// متغيرات عامة
static std::map<int64_t, std::shared_ptr<RecordingSession>> active_sessions;
static std::mutex sessions_mutex;
static int64_t next_recording_id = 1;

// ثوابت
static const int SAMPLE_RATE = 44100;
static const int CHANNELS = 2;
static const int BITS_PER_SAMPLE = 16;
static const int BUFFER_SIZE = 4096;
static const int CHUNK_SIZE = 4096;

// دالة حساب مستوى الصوت
double calculate_level(const uint8_t* data, size_t size) {
  if (size == 0) return 0.0;

  int16_t* samples = (int16_t*)data;
  size_t sample_count = size / sizeof(int16_t);

  double rms = 0.0;
  for (size_t i = 0; i < sample_count; i++) {
    double sample = samples[i] / 32768.0;
    rms += sample * sample;
  }

  rms = std::sqrt(rms / sample_count);
  return std::min(rms, 1.0);
}

// دالة تسجيل الصوت في خيط منفصل
void recording_thread_func(std::shared_ptr<RecordingSession> session) {
  uint8_t buffer[CHUNK_SIZE];
  int error = 0;

  printf("[Audio] Recording thread started for session %ld\n", session->id);

  while (session->is_recording) {
    // قراءة البيانات من PulseAudio
    if (pa_simple_read(session->pa_device, buffer, CHUNK_SIZE, &error) < 0) {
      printf("[Audio] pa_simple_read() failed: %s\n", pa_strerror(error));
      break;
    }

    // حساب مستوى الصوت
    session->current_level = calculate_level(buffer, CHUNK_SIZE);

    // إضافة البيانات إلى المخزن المؤقت
    {
      std::lock_guard<std::mutex> lock(session->buffer_mutex);
      session->audio_buffer.insert(session->audio_buffer.end(), buffer,
                                   buffer + CHUNK_SIZE);
    }

    printf("[Audio] Recorded: %zu bytes, Level: %.2f\n", 
           session->audio_buffer.size(), session->current_level);
  }

  printf("[Audio] Recording thread stopped for session %ld\n", session->id);
}

// بدء التسجيل
int64_t start_recording() {
  std::lock_guard<std::mutex> lock(sessions_mutex);

  printf("[Audio] Starting recording...\n");

  // إعداد مواصفات الصوت
  pa_sample_spec ss;
  ss.format = PA_SAMPLE_S16LE;
  ss.channels = CHANNELS;
  ss.rate = SAMPLE_RATE;

  // التحقق من الصيغة
  if (!pa_sample_spec_valid(&ss)) {
    printf("[Audio] Invalid sample spec\n");
    return -1;
  }

  int error = 0;

  // الاتصال بـ PulseAudio
  // pa_simple_new(server, app_name, dir, device, stream_name, ss, map, attr, error)
  pa_simple* pa_device = pa_simple_new(NULL,              // server (default)
                                        "Audio Recorder", // app_name
                                        PA_STREAM_RECORD, // direction
                                        NULL,             // device (default)
                                        "Recording",      // stream_name
                                        &ss,              // sample spec
                                        NULL,             // channel map (default)
                                        NULL,             // buffer attributes (default)
                                        &error);          // error

  if (!pa_device) {
    printf("[Audio] pa_simple_new() failed: %s\n", pa_strerror(error));
    return -1;
  }

  printf("[Audio] PulseAudio connection established\n");

  int64_t recording_id = next_recording_id++;

  auto session = std::make_shared<RecordingSession>();
  session->id = recording_id;
  session->pa_device = pa_device;
  session->is_recording = true;
  session->current_level = 0.0;
  session->start_time = std::chrono::system_clock::now();
  session->recording_thread = nullptr;

  // تخزين الجلسة
  active_sessions[recording_id] = session;

  // بدء خيط التسجيل
  session->recording_thread = new std::thread(recording_thread_func, session);

  printf("[Audio] Recording started with ID: %ld\n", recording_id);
  return recording_id;
}

// إيقاف التسجيل
int32_t stop_recording(int64_t recording_id) {
  std::lock_guard<std::mutex> lock(sessions_mutex);

  printf("[Audio] Stopping recording for ID: %ld\n", recording_id);

  auto it = active_sessions.find(recording_id);
  if (it == active_sessions.end()) {
    printf("[Audio] Recording ID not found: %ld\n", recording_id);
    return -1;
  }

  auto session = it->second;
  session->is_recording = false;

  // الانتظار لإنهاء الخيط
  if (session->recording_thread) {
    session->recording_thread->join();
    delete session->recording_thread;
    session->recording_thread = nullptr;
  }

  // إغلاق جهاز PulseAudio
  if (session->pa_device) {
    pa_simple_free(session->pa_device);
    session->pa_device = nullptr;
  }

  printf("[Audio] Recording stopped. Total bytes: %zu\n",
         session->audio_buffer.size());
  return 0;
}

// الحصول على مستوى الصوت الحالي
double get_current_level() {
  std::lock_guard<std::mutex> lock(sessions_mutex);

  for (auto& pair : active_sessions) {
    if (pair.second->is_recording) {
      return pair.second->current_level;
    }
  }

  return 0.0;
}

// حفظ ملف التسجيل
int32_t save_recording(int64_t recording_id, const char* filename) {
  std::lock_guard<std::mutex> lock(sessions_mutex);

  printf("[Audio] Saving recording %ld to: %s\n", recording_id, filename);

  auto it = active_sessions.find(recording_id);
  if (it == active_sessions.end()) {
    printf("[Audio] Recording not found: %ld\n", recording_id);
    return -1;
  }

  auto session = it->second;

  // فتح ملف للكتابة
  FILE* file = fopen(filename, "wb");
  if (!file) {
    printf("[Audio] Failed to open file: %s\n", filename);
    return -1;
  }

  // حساب حجم البيانات
  size_t data_size = 0;
  {
    std::lock_guard<std::mutex> lock(session->buffer_mutex);
    data_size = session->audio_buffer.size();
  }

  // كتابة رأس WAV
  struct {
    char riff[4] = {'R', 'I', 'F', 'F'};
    uint32_t file_size;
    char wave[4] = {'W', 'A', 'V', 'E'};
    char fmt[4] = {'f', 'm', 't', ' '};
    uint32_t fmt_size = 16;
    uint16_t audio_format = 1;     // PCM
    uint16_t num_channels = CHANNELS;
    uint32_t sample_rate = SAMPLE_RATE;
    uint32_t byte_rate =
        SAMPLE_RATE * CHANNELS * BITS_PER_SAMPLE / 8;
    uint16_t block_align = CHANNELS * BITS_PER_SAMPLE / 8;
    uint16_t bits_per_sample = BITS_PER_SAMPLE;
    char data[4] = {'d', 'a', 't', 'a'};
    uint32_t data_size_field;
  } wav_header = {};

  wav_header.data_size_field = data_size;
  wav_header.file_size = 36 + data_size;

  // كتابة الرأس
  size_t header_written = fwrite(&wav_header, sizeof(wav_header), 1, file);
  if (header_written != 1) {
    printf("[Audio] Failed to write WAV header\n");
    fclose(file);
    return -1;
  }

  // كتابة البيانات
  {
    std::lock_guard<std::mutex> lock(session->buffer_mutex);
    if (!session->audio_buffer.empty()) {
      size_t data_written = fwrite(session->audio_buffer.data(),
                                    session->audio_buffer.size(), 1, file);
      if (data_written != 1) {
        printf("[Audio] Failed to write audio data\n");
        fclose(file);
        return -1;
      }
    }
  }

  fclose(file);

  printf("[Audio] Recording saved successfully. File size: %zu bytes\n",
         data_size + sizeof(wav_header));

  // حذف الجلسة من الذاكرة
  active_sessions.erase(it);

  return 0;
}

// الحصول على مدة التسجيل
int64_t get_recording_duration(int64_t recording_id) {
  std::lock_guard<std::mutex> lock(sessions_mutex);

  auto it = active_sessions.find(recording_id);
  if (it == active_sessions.end()) {
    return 0;
  }

  auto now = std::chrono::system_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
      now - it->second->start_time);

  return duration.count();
}

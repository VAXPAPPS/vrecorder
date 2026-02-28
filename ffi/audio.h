#ifndef AUDIO_RECORDER_H
#define AUDIO_RECORDER_H

#include <cstdint>

#ifdef __cplusplus
extern "C" {
#endif

/// بدء التسجيل
/// @return معرف التسجيل (ID > 0 للنجاح، < 0 للفشل)
int64_t start_recording();

/// إيقاف التسجيل
/// @param recording_id معرف التسجيل
/// @return 0 للنجاح، < 0 للفشل
int32_t stop_recording(int64_t recording_id);

/// الحصول على مستوى الصوت الحالي (0.0 - 1.0)
/// @return مستوى الصوت
double get_current_level();

/// حفظ ملف التسجيل
/// @param recording_id معرف التسجيل
/// @param filename اسم الملف
/// @return 0 للنجاح، < 0 للفشل
int32_t save_recording(int64_t recording_id, const char* filename);

/// الحصول على مدة التسجيل بالميلي ثانية
/// @param recording_id معرف التسجيل
/// @return المدة بالميلي ثانية
int64_t get_recording_duration(int64_t recording_id);

#ifdef __cplusplus
}
#endif

#endif // AUDIO_RECORDER_H

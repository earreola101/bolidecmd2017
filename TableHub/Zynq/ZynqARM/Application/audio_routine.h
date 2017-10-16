#ifndef AUDIO_ROUTINE_H__
#define AUDIO_ROUTINE_H__

#include "audio_driver.h"
#ifdef __cplusplus
extern "C" {
#endif

int audio_routine_init();
void audio_routine_deinit();
int audio_routine_get_running();
#ifdef __cplusplus
}
#endif

#endif

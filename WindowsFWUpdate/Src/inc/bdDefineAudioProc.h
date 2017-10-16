#ifndef BD_DEFINE_AUDIO_PROC_H
#define BD_DEFINE_AUDIO_PROC_H

#define SEND_CONFIGURATION_BUTTON_NAME_AP "  Set Configuration  "

// DIMENSION
#define AUDIO_PROC_EFFECT_WIDTH 700 //518

#define AUDIO_PROC_BOX_HEIGHT 22

#define RECV_AUDIO_PROC_NAME "Receive Audio Processing"
#define SEND_AUDIO_PROC_NAME "Send Audio Processing"

#define RECV_AUDIO_PROC_NAME_EAWB_ENABLED "Receive Audio Processing [EAWB Mode Enabled: to use this setting disable EAWB mode]"
#define SEND_AUDIO_PROC_NAME_EAWB_ENABLED "Send Audio Processing [EAWB Mode Enabled: to use this setting disable EAWB mode]"

// RECV Default SAMPLE FREQUENCY - set to max to avoid problems
#define RECV_SAMPLE_FREQUENCY 48000

/*
 * Gain
 */ 
#define GAIN_WIDGET_NAME "Gain"

#define GAIN_LEVEL_METER_ENABLE_NAME "Enable Vu Meter"
#define GAIN_LEVEL_METER_MIN_VALUE -60 // [dB]

// Dimension
#define GAIN_WIDGET_HEIGHT 100

/*
 * Agc
 */
#define AGC_WIDGET_NAME "Automatic Gain Control"

#define AGC_TARGET_RMS_NAME "Target RMS [dBFS]"
#define AGC_NOISE_MAX_LEVEL_NAME "Noise Max Level [dB]"

// Dimension
#define AGC_WIDGET_HEIGHT 100
#define AGC_BOX_HEIGHT AUDIO_PROC_BOX_HEIGHT
#define AGC_BOX_WIDTH 55

/*
 * Graphic Equalizer
 */ 
#define GRAPHIC_EQUALIZER_WIDGET_NAME "Graphic Equalizer (1/3 Octave)"

#define GRAPHIC_EQUALIZER_RESET_GAIN_NAME "Reset Gains"

// Dimension
#define EQUALIZER_SLIDER_WIDTH 42
#define EQUALIZER_SLIDER_HEIGHT 150
#define GRAPHIC_EQUALIZER_WIDGET_HEIGHT EQUALIZER_SLIDER_HEIGHT + 125


/*
 * Parametric Equalizer
 */ 
#define PARAMETRIC_EQUALIZER_WIDGET_NAME "Parametric Equalizer"

#define PARAMETRIC_EQUALIZER_RESET_GAIN_NAME "Reset Gains"

// Dimension
#define PARAMETRIC_EQUALIZER_SLIDER_WIDTH 42
#define PARAMETRIC_EQUALIZER_SLIDER_HEIGHT 150 //140
#define PARAMETRIC_EQUALIZER_WIDGET_HEIGHT EQUALIZER_SLIDER_HEIGHT + 120

#define BD_AP_PEQ_GAIN_DB_MAX 18.0f
#define BD_AP_PEQ_GAIN_DB_MIN -BD_AP_PEQ_GAIN_DB_MAX

// High Pass Modes
#define HIGH_PASS_WIDGET_NAME "High Pass Filter"
#define BD_AP_PEQ_HIGH_PASS_MODES_LIST << "Off" << "80" << "100" << "200" << "300"

/*
 * Compander
 */
#define CMP_WIDGET_NAME "Compander"

#define CMP_INPUT_TABLE_NAME	"Input [dbFS]"
#define CMP_OUTPUT_TABLE_NAME	"Output [dbFS]"

#define CMP_PEAK_NAME	"Peak"
#define CMP_RMS_NAME	"RMS"
 
#define CMP_ATTACK_TIME_GAIN_MS_NAME	"Attack Time Gain [ms]"
#define CMP_RELEASE_TIME_GAIN_MS_NAME	"Release Time Gain [ms]"
#define CMP_ATTACK_TIME_LEVEL_MS_NAME	"Attack Time Level [ms]"
#define CMP_RELEASE_TIME_LEVEL_MS_NAME	"Release Time Level [ms]"
#define CMP_LOOK_AHEAD_TIME_MS_NAME		"Look Ahead Time [ms]"

#define CMP_COMPENSATION_GAIN_NAME	"Compensation Gain [dB]"

// Dimension
#define CMP_WIDGET_HEIGHT 245

#define CMP_ROW_TABLE_BOX_WIDTH 70
#define CMP_ROW_TABLE_BOX_HEIGHT AUDIO_PROC_BOX_HEIGHT

#define CMP_ROW_TABLE_LABEL_HEIGHT AUDIO_PROC_BOX_HEIGHT


/*
 * Limiter
 */
#define LIMITER_WIDGET_NAME "Limiter"

#define LIMITER_TH_LEVEL_DB_NAME "Threshold Level [dBFS]"

// Dimension
#define LIMITER_BOX_HEIGHT	AUDIO_PROC_BOX_HEIGHT
#define LIMITER_BOX_WIDTH	60

#define LIMITER_WIDGET_HEIGHT 120

#define LIMITER_TH_LEVEL_DB_LABEL_WIDTH 100

#define BD_AP_LIMITER_LEVEL_DB_MAX 0.0f
#define BD_AP_LIMITER_LEVEL_DB_MIN -10.0f

#endif // BD_DEFINE_AUDIO_PROC_H


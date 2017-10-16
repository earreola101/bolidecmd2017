/******************************************************************************
*
*   Filename:    MCHP_API.hpp
*
*   Description: MCHP - Multi Channel Hands-free Processor API
*
*   Copyright (C) 2003-2015 -- ASDSP S.r.l. -- www.asdsp.com
*
*******************************************************************************/
/*

MCHP is an all-in-one software solution for high-quality, multi-microphone hands-free speech communication,
built as a tight integration of the following ASDSP software modules:
- Multi-channel Frequency Domain Acoustic Echo Canceller (AEC)
- Frequency Domain Noise Reduction (NR)
- Frequency Domain Residual Echo Reduction (ER)
- Microphone Steering (only for multi microphone systems)
- Automatic Gain Control (AGC) for both the TX and RX side

The MCHP algorithm is shown in the block diagram (see Fig. 1).

The core block is the AEC. Background noise spectrum and residual echo spectrum estimators are jointly used to
control the step size and as side inputs of the PostFilter that act as combined noise and residual echo reduction.
Finally a voice driven AGC is used to keep the transmit signal loudness into a comfort range.
Even though a single microphone is depicted in the diagram the algorithm is designed to work as well in multiple microphone
applications and in this case microphone steering is used to select to the best microphone.
The number of microphones can be set run time (up the their maximum value predefined in a header file).

*/

#ifndef __MCHP_API_HPP
#define __MCHP_API_HPP

#include "Config.h"

//=============================================================================
//  Basic Type definitions
//=============================================================================

#ifndef __ASDSP_H

#define T_ShortReal     float

#endif  // __ASDSP_H


//=============================================================================
//  Enable Flag (Switch ON/OFF internal functionalities)
//=============================================================================

enum E_EnableIndex
{
    AEC_ENABLE          = 0,            // EchoCanceller
    RESCUE_ENABLE       = 1,            // RescueDetector
    DUALTONE_DET_ENABLE = 2,            // DualToneDetector
    POSTFILTER_ENABLE   = 3,            // Postfilter
    NOISE_RED_ENABLE    = 4,            // Noise Reduction
    BUZZ_DET_ENABLE     = 5,            // BuzzDetector
    TX_CNG_ENABLE       = 6,            // TxComfortNoise
    TX_EQ_ENABLE        = 7,            // TxEqualizer
    SPEECH_DET_ENABLE   = 8,            // SpeechDetector
    TX_AGC_ENABLE       = 9,            // TxAGC
#if _ADAPT_DELAY_
    ADAPT_DELAY_ENABLE,                 // AdaptDelay
#endif
#if _BEAMFORMING_
    BEAMFORMING_ENABLE,                 // Beamforming
#endif
#if _BEAM_ADAPTIVE_
    ADAPT_BEAM_ENABLE,                  // AdaptBeamforming
#endif
#if NUMBER_OF_MICS > 1
    MIC_STEER_ENABLE,                   // MicSteering
#endif
#if _RX_MBPL_
    RX_MBPL_ENABLE,                     // RxMBPL (Multi Band Peak Limiter)
#endif
#if _RX_LIMITER_
    RX_LIMITER_ENABLE,                  // RxLimiter
#endif
#if _PARAM_EQ_
    RX_PEQ_ENABLE,                      // RxParamEQ
#endif
    TX_MUTE_ENABLE,                     // TX Mute
    RX_MUTE_ENABLE,                     // RX Mute
    MCHP_NUM_ENABLE                     // This way MCHP_NUM_ENABLE is always properly defined
};


//=============================================================================
//  Signal Generator Plug
//=============================================================================

enum E_SignGenPlug                      // Select where to generate test signals
{
    SIGN_GEN_OFF    = 0,                // Turn OFF signal generator
    SIGN_GEN_TX,                        // Generate Test Signals on TxOut
    SIGN_GEN_RX,                        // Generate Test Signals on speaker input
    SIGN_GEN_MIC,                       // Generate Test Signals on mic inputs
    SIGN_GEN_SPK                        // Generate Test Signals on speaker output
};


//=============================================================================
//  MCHP Interface Class Definition
//=============================================================================

class I_MCHP                                                                    // MCHP Interface Class
{
public:
    I_MCHP (int SampleRate);                                                    // Constructor [Hz]
    I_MCHP (int MicSampleRate, int SpkSampleRate);                              // Constructor [Hz, Hz]

    ~I_MCHP();                                                                  // Destructor

    size_t SizeOf();                                                            // Return sizeof(C_MCHP)

    void Restart();                                                             // Restart (to be used at the beginning of a call)

    const char* GetVer()      const;                                            // Version ID string
    const char* GetDate()     const;                                            // Version date string
    const char* GetProdID()   const;                                            // Product ID string
    const char* GetPlatform() const;                                            // Platform ID string


    //-------------------------------------------------------------------------
    //  Sample rate and frame size
    //-------------------------------------------------------------------------

    int GetSampleRate () const;                                                 // Get the sample rate [Hz]
    int GetFrameSize ()  const;                                                 // Get the frame size [samples]
    int GetSubFrameSize ()  const;                                              // Get the subframe size [samples]


    //-------------------------------------------------------------------------
    //  Get/Set the audio delay for the speaker reference
    //-------------------------------------------------------------------------
#if _ADAPT_DELAY_
    void SetAudioDelayMin (int DelayMin);                                       // Set the minimum audio delay for the speaker reference [samples] (will be rounded to a multiple of frame size)
    void SetAudioDelayMax (int DelayMax);                                       // Set the maximum audio delay for the speaker reference [samples] (will be rounded to a multiple of frame size)

    int GetAudioDelayMin() const;                                               // Get the minimum audio delay for the speaker reference [samples]
    int GetAudioDelayMax() const;                                               // Get the maximum audio delay for the speaker reference [samples]

    bool GetDelayChange() const;                                                // Delay estimate has changed
    bool GetDelayUpdate() const;                                                // Delay estimate has been updated
#endif
    void SetAudioDelay (int AudioDelay);                                        // Set the audio delay for the speaker reference [samples]
    int  GetAudioDelay() const;                                                 // Get the audio delay for the speaker reference [samples]


    //-------------------------------------------------------------------------
    //  Get/Set the number of enabled mic inputs
    //-------------------------------------------------------------------------

    int  GetNumberOfMics () const;                                              // Get the number of mic inputs
    void SetNumberOfMics (int NumberOfMics);                                    // Set the number of mic inputs


    //-------------------------------------------------------------------------
    //  Get/Set the steered mic index
    //-------------------------------------------------------------------------
#if NUMBER_OF_MICS > 1
    int  GetSteeredMic () const;                                                // Get the steered mic index
    void SetSteeredMic (int SteeredMic);                                        // Set the steered mic index (to be used only for testing with Enable[MIC_STEER_ENABLE] = FALSE)

    bool GetSteeringHit() const;                                                // Get the steering hit flag (to be used only for testing)
#endif  // NUMBER_OF_MICS > 1

    //-------------------------------------------------------------------------
    //  Mic and Speaker Sample Peak Level [dB]
    //-------------------------------------------------------------------------

    float GetMicLevel_dB (int mic_index = 0) const;                             // Get the Mic Level [dB]
    float GetSpkLevel_dB () const;                                              // Get the Speaker Level [dB]


    //-------------------------------------------------------------------------
    //  Get/Set the mic gain [dB]
    //-------------------------------------------------------------------------
#if NUMBER_OF_MICS > 1
    float GetMicGain_dB (int mic_index = 0) const;                              // Get the gain [dB] for a given mic input
    void  SetMicGain_dB (int mic_index, float Gain_dB);                         // Set the gain [dB] for a given mic input
#else
    float GetMicGain_dB () const;                                               // Get the mic gain [dB]
#endif
    void  SetMicGain_dB (float Gain_dB);                                        // Set the same gain [dB] for all the mic inputs


    //-------------------------------------------------------------------------
    //  Get/Set the post-AEC gain [dB]
    //-------------------------------------------------------------------------
#if NUMBER_OF_MICS > 1
    float GetPostGain_dB (int mic_index = 0) const;                             // Get the post-AEC gain [dB] for a given mic/beam
    void  SetPostGain_dB (int mic_index, float Gain_dB);                        // Set the post-AEC gain [dB] for a given mic/beam
#else
    float GetPostGain_dB () const;                                              // Get the post-AEC gain [dB]
#endif
    void  SetPostGain_dB (float Gain_dB);                                       // Set the same post-AEC gain [dB] for all the mics/beams


    //-------------------------------------------------------------------------
    //  Get/Set the Noise Reduction Attenuation [dB]
    //-------------------------------------------------------------------------

    float GetNoiseReductionAtt_dB() const;                                      // Get the noise reduction attenuation [dB]
    void  SetNoiseReductionAtt_dB (float NoiseReductionAtt_dB);                 // Set the noise reduction attenuation [dB]


    //-------------------------------------------------------------------------
    //  Get/Set the 1/3 octave TX Equalizer gains
    //-------------------------------------------------------------------------

    int GetEqNumberOfBands() const;                                             // Get the 1/3 octave equalizer number of bands

    void  SetEqLogBandGain_dB (int eq_index, float Gain_dB);                    // Set the 1/3 octave equalizer gains
    float GetEqLogBandGain_dB (int eq_index) const;                             // Get the 1/3 octave equalizer gains
    float GetEqLogBandFreq_Hz (int eq_index) const;                             // Get the 1/3 octave equalizer frequency


    //-------------------------------------------------------------------------
    //  Alert MCHP of an echo path change
    //-------------------------------------------------------------------------
#if NUMBER_OF_MICS > 1
    void EchoPathChangeAlert (int mic_index);                                   // Notify an echo path change affecting a given mic input
#endif
    void EchoPathChangeAlert ();                                                // Notify an echo path change affecting all the mic inputs

    //-------------------------------------------------------------------------
    //  Speaker High Pass Filter
    //-------------------------------------------------------------------------
#if _RX_IIR_BIQUAD_
    int GetHighPassNumberOfModes() const;                                       // Get the number of high pass filter modes

    int  GetHighPassMode () const;                                              // Get the high pass filter mode (0, 1, .., NumberOfModes); Mode = 0 for no high pass filtering
    void SetHighPassMode (int HighPassMode);                                    // Set the high pass filter mode (0, 1, .., NumberOfModes); Mode = 0 for no high pass filtering

    float GetHighPassFreq() const;                                              // Get the high pass filter cutoff frequency corresponding to the current mode
#endif  // _RX_IIR_BIQUAD_

    //-------------------------------------------------------------------------
    //  Cascaded Biquad based Parametric Equalizer
    //-------------------------------------------------------------------------
#if _PARAM_EQ_
    int PEQ_GetNumberOfStages() const;                                          // Get the number of PEQ biquad stages

    #define PEQ_UG      0       // Flat EQ unit gain (default)
    #define PEQ_LP      1       // Low Pass filter (Gain_dB set the pass band gain)
    #define PEQ_HP      2       // High Pass filter (Gain_dB set the pass band gain)
    #define PEQ_BP      3       // Band Pass filter (Gain_dB set the peak gain)
    #define PEQ_NO      4       // Notch filter (Gain_dB set the pass band gain)
    #define PEQ_PB      5       // Peaking Band filter (Gain_dB set the peak gain)
    #define PEQ_LS      6       // Low Shelf filter (Gain_dB set the pass band gain)
    #define PEQ_HS      7       // High Shelf filter (Gain_dB set the pass band gain)

    bool PEQ_SetStage                                                           // Set the parameters for a given stage (return FALSE on error)
    (
        int     stage_index,
        int     PEQ_Type,
        float   f,
        float   Q,
        float   Gain_dB
    );

    bool PEQ_GetStage                                                           // Get the parameters for a given stage (return FALSE on error)
    (
        int     stage_index,
        int&    PEQ_Type,
        float&  f,
        float&  Q,
        float&  Gain_dB
    ) const;

    void PEQ_PrintStage (int stage_index);                                      // Print the parameters for a given stage
#endif  // _PARAM_EQ_

    //-------------------------------------------------------------------------
    //  Multi Band Peak Limiter
    //-------------------------------------------------------------------------
#if _RX_MBPL_
    int GetMBPL_NumberOfBands() const;                                          // Get the octave equalizer number of bands (frequency partitions)

    void  SetMBPL_LogBandGain_dB (int part_index, float Gain_dB);               // Set the octave equalizer gains
    float GetMBPL_LogBandGain_dB (int part_index) const;                        // Get the octave equalizer gains

    float GetMBPL_LogBandFreq_Hz (int part_index) const;                        // Get the octave equalizer frequency
#endif  // _RX_MBPL_

    //-------------------------------------------------------------------------
    //  RxLimiter (Speaker Volume and Peak Limiter)
    //-------------------------------------------------------------------------
#if _RX_LIMITER_
    float GetVolume_dB() const;                                                 // Get the speaker output volume [dB]
    void  SetVolume_dB (float Volume_dB);                                       // Set the speaker output volume [dB]

    float GetLimiterRef_dB() const;                                             // Get the peak limiter reference level [dB]
    void  SetLimiterRef_dB (float Ref_dB);                                      // Set the peak limiter reference level [dB]
#endif  // _RX_LIMITER_

    //-------------------------------------------------------------------------
    //  TxAGC reference level and noise upper limit
    //-------------------------------------------------------------------------

    float GetTxAGC_Ref_dB () const;                                             // Get the TX AGC reference level [dB]
    void  SetTxAGC_Ref_dB (float Ref_dB);                                       // Set the TX AGC reference level [dB]

    float GetTxNoiseMax_dB () const;                                            // Get the upper limit for the TX noise level [dB]
    void  SetTxNoiseMax_dB (float NoiseMax_dB);                                 // Set the upper limit for the TX noise level [dB]


    //-------------------------------------------------------------------------
    //  Enable Flag (enable/disable internal modules)
    //-------------------------------------------------------------------------

    bool GetEnable (E_EnableIndex EnableIndex) const;                           // Get each enable flag individually
    void SetEnable (E_EnableIndex EnableIndex, bool Flag);                      // Set each enable flag individually

    void PrintEnable();                                                         // Print all the enable flags


    //-------------------------------------------------------------------------
    //  Freeze flag (enable/disable adaptation)
    //-------------------------------------------------------------------------

    bool GetFreeze () const;                                                    // Get the freeze flag
    void SetFreeze (bool Flag);                                                 // Set the freeze flag


    //-------------------------------------------------------------------------
    //  ERLE forget decimation ratio
    //-------------------------------------------------------------------------

    int  GetForgetDecRatio () const;                                            // Get the ForgetDecRatio
    void SetForgetDecRatio (int DecRatio);                                      // Set the ForgetDecRatio


    //-------------------------------------------------------------------------
    //  TestMode
    //-------------------------------------------------------------------------

    #define MCHP_TEST_OFF               0

    #define MCHP_TEST_MIC_BYPASS        1                   // mic[SteeredMic]  --> TxOut
    #define MCHP_TEST_SPK_BYPASS        2                   // speaker          --> SpkOut
    #define MCHP_TEST_BYPASS            3                   // mic[SteeredMic]  --> TxOut           speaker --> SpkOut

    #define MCHP_TEST_CHECK_DELAY       4                   // mic[SteeredMic] + SpeakerRef --> TxOut
    #define MCHP_TEST_PING_DELAY        5                   // Beep detection based audio delay estimation
    #define MCHP_TEST_CLOCK_SKEW        6                   // Tone phase based clock skew rate estimation

    #define MCHP_TEST_RESERVED          7                   // Reserved test mode (internal use only)

    //-------------------------------------------------------------------------

    void SetTestMode (int TestMode);                                            // Set the TestMode
    int  GetTestMode() const;                                                   // Get the TestMode


    //-------------------------------------------------------------------------
    //  Get/Set the TweakMode
    //-------------------------------------------------------------------------

    void SetTweakMode (int TestMode);                        //!< Set the TweakMode
    int  GetTweakMode() const;                               //!< Get the TweakMode


    //-------------------------------------------------------------------------
    //  TestMode = MCHP_TEST_PING_DELAY
    //-------------------------------------------------------------------------

    void SetPingFreq (float Freq1, float Freq2);                                // Set the beep tone frequencies [Hz]

    float GetPingFreq1() const;                                                 // Get the 1st beep tone frequency [Hz]
    float GetPingFreq2() const;                                                 // Get the 2nd beep tone frequency [Hz]

    void SetPingDelayMin (int DelayMin);                                        // Set the lower limit for the audio delay estimate [samples]
    void SetPingDelayMax (int DelayMax);                                        // Set the higher limit for the audio delay estimate [samples]

    int GetPingDelayMin() const;                                                // Get the lower limit for the audio delay estimate [samples]
    int GetPingDelayMax() const;                                                // Get the higher limit for the audio delay estimate [samples]

    bool GetPingDetect() const;                                                 // Get the beep detection flag (a new audio delay estimate is ready)
    bool GetPingTimeout() const;                                                // Get the timeout flag (no beep detected within the allowed delay range)

    int GetPingDelay() const;                                                   // Get the latest audio delay estimate [samples]


    //-------------------------------------------------------------------------
    //  TestMode = MCHP_TEST_CLOCK_SKEW
    //-------------------------------------------------------------------------

    void  SetClockSkewFrequency (float Freq);                                   // Set the clock skew frequency [Hz]
    float GetClockSkewFrequency () const;                                       // Get the clock skew frequency [Hz]

    float GetClockSkewDelta() const;                                            // Get the clock skew Delta (see MCHP_TEST_CLOCK_SKEW)
    bool  GetClockSkewUpdate() const;                                           // Get the clock skew update flag (a new Delta value is ready)


    //-------------------------------------------------------------------------
    //  Built-in Signal Generator
    //-------------------------------------------------------------------------

    bool SetSignGenPlug (E_SignGenPlug SignGenPlug);                            // Set the Signal Generator plug (return FALSE on error)

    E_SignGenPlug GetSignGenPlug() const;                                       // Get the Signal Generator plug (return FALSE on error)

    void SetWhite
    (
        E_SignGenPlug   SignGenPlug,    // Select where to generate test signals
        float           Level_dB,       // [dB]
        float           ON_Time  = 100, // [ms]
        float           OFF_Time = 0    // [ms]
    );

    void SetPink
    (
        E_SignGenPlug   SignGenPlug,    // Select where to generate test signals
        float           Level_dB,       // [dB]
        float           ON_Time  = 100, // [ms]
        float           OFF_Time = 0    // [ms]
    );

    void SetTone
    (
        E_SignGenPlug   SignGenPlug,    // Select where to generate test signals
        float           Level_dB,       // [dB]
        float           Frequency,      // [Hz]
        float           ON_Time  = 100, // [ms]
        float           OFF_Time = 0    // [ms]
    );

    void SetDualTone
    (
        E_SignGenPlug   SignGenPlug,    // Select where to generate test signals
        float           Level1_dB,      // [dB]
        float           Level2_dB,      // [dB]
        float           Frequency1,     // [Hz]
        float           Frequency2,     // [Hz]
        float           ON_Time  = 100, // [ms]
        float           OFF_Time = 0    // [ms]
    );

    #define SWEEP_LINEAR    false
    #define SWEEP_LOG       true

    void SetSweep
    (
        E_SignGenPlug   SignGenPlug,    // Select where to generate test signals
        float           Level_dB,       // [dB]
        float           StartFreq,      // [Hz]
        float           StopFreq,       // [Hz]
        float           SweepTime,      // [s]
        bool            LogSweep = SWEEP_LINEAR,
        float           ON_Time  = 100, // [ms]
        float           OFF_Time = 0    // [ms]
    );

    void SetPulse
    (
        E_SignGenPlug   SignGenPlug,    // Select where to generate test signals
        float           Level_dB,       // [dB]
        float           PulseTime       // [ms]
    );


    //-------------------------------------------------------------------------
    //  Signal Activity Detection flags
    //-------------------------------------------------------------------------

    bool GetSignalDetect() const;                                               // Get the TX Signal Activity Detection flag
    bool GetSpeechDetect() const;                                               // Get the TX Speech Activity Detection flag

    bool GetSpeakerDetect () const;                                             // Get the Speaker Activity Detection flag


    //-------------------------------------------------------------------------
    //  Frame Processing
    //-------------------------------------------------------------------------

    void ProcessSpkFrame                                                        // Pre-process one speaker subframe
    (
        T_ShortReal* SpkIn,
        T_ShortReal* SpkOut
    );

    void ProcessSpkFrame                                                        // Just feed the reference delay line with one speaker frame
    (
        T_ShortReal* SpkRef
    );

    void ProcessMicFrame                                                        // Process one mic frame using the speaker reference in the delay line
    (                                                                           // if called with GetSpkDelayLineDepth() == 0 it generates silence on TxOut in order to avoid speaker delay line underflow
        T_ShortReal* mic[],
        T_ShortReal* TxOut
    );

    void ProcessMicFrame                                                        // Just feed the mic delay line line with one mic frame (should be called if GetSpkDelayLineDepth() == 0)
    (
        T_ShortReal* mic[]
    );

    void ProcessMicFrame                                                        // Process one mic frame previously enqueued into the mic delay line using the speaker reference in the speaker delay line
    (                                                                           // it must be called with GetMicDelayLineDepth() > 0;
        T_ShortReal* TxOut                                                      // if called with GetSpkDelayLineDepth() == 0 it generates silence on TxOut in order to avoid speaker delay line underflow
    );

    //-------------------------------------------------------------------------
    //  Get the mic delay line depth counter. This is
    //  incremented by one if ProcessMicFrame() is called
    //  even when GetSpkDelayLineDepth() == 0 (speaker
    //  delay line is empty) and so the latest mic frame is
    //  just saved inside a FIFO to be used later and zeros
    //  are sent to TxOut to avoid speaker FIFO underflow
    //-------------------------------------------------------------------------

    int GetMicDelayLineDepth () const;                      // [frames]

    int GetMicDelayLineDepthMax () const;                   // [frames]


    //-------------------------------------------------------------------------
    //  Get the SpkReference delay line depth counter:
    //  it is incremented by 1 on ProcessSpkFrame()
    //  and decremented by 1 on ProcessMicFrame();
    //  so a negative count shows delay line underflow.
    //  In order to avoid overflow the following check must
    //  be done before calling ProcessSpkFrame():
    //  GetSpkDelayLineDepth () < GetSpkDelayLineDepthMax()
    //-------------------------------------------------------------------------

    int GetSpkDelayLineDepth () const;                      // [frames]

    int GetSpkDelayLineDepthMax () const;                   // [frames]


    //-------------------------------------------------------------------------
    //  Text Output (wrapper for printf)
    //-------------------------------------------------------------------------

    void OverrideTextOut (int (*pTextOut)(const char* msg));                    // Set the function pointer TextOut to pTextOut


    //-------------------------------------------------------------------------
    //  Probe outputs
    //-------------------------------------------------------------------------

    void ProbeSettings (const char* ProgramName = NULL);                        // Save MCHP settings to a M-file to allow MATLAB to load probe outputs

    void Probe();                                                               // To be called at the end of each frame iteration

    void SetProbeMode (int ProbeMode);                                          // Set ProbeMode (0 ==> Probe Output OFF)
    int  GetProbeMode () const;                                                 // Get ProbeMode (0 ==> Probe Output OFF)

    void SetProbeTime (int Time_ms);                                            // Set ProbeTime [ms] (probe report is printed once every ProbeTime ms)


    //-------------------------------------------------------------------------
    //  String Commands Parser
    //-------------------------------------------------------------------------

    bool ParseCommand (char* CommandString);                                    // Parse a command string. Return true if a valid user command is found; false otherwise.

    void NewCommand                                                             // Create a new user command
    (
        const char*     Name,           // Command name (case insensitive)
        int             NumArg,         // Number of argument
        const char*     Description,    // Description string to be printed on help
        void            (*pCommandExec) // Command executing function pointer
        (
            int     Argc,               // Number of arguments (command name excluded)
            char**  Argv                // Argument array Argv[i], i=0, Argc-1
        )
    );

    //-------------------------------------------------------------------------

private:
    void* hMCHP;                                            // C_MCHP Handle
    void* hSPP;                                             // C_SPP Handle
    void* hSG;                                              // C_SignalGenerator Handle
    void* hCP;                                              // C_CmdParser Handle

    E_SignGenPlug SignGenPlug;                              // Select where to generate test signals

    int ProbeTime;                                          // [frames]
};

#endif // __MCHP_API_HPP

/******************************************************************************
*
*   Copyright (C) 2003-2015 -- ASDSP S.r.l. -- www.asdsp.com
*
*******************************************************************************/

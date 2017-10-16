#ifndef BD_PARAMETRIC_EQUALIZER_WIDGET_H
#define BD_PARAMETRIC_EQUALIZER_WIDGET_H

#include "bdDefineAudioProc.h"
#include "bdGroupBox.h"
#include "bdComboBox.h"

// QT includes
#include <QLayout>
#include <QWidget>
#include <QGroupBox>
#include <QLabel>
#include <QList>
#include <QSlider>
#include <QPushButton>
#include "bdSerialPort.h"
#include <qformlayout.h>
#include "bdSpinBox.h"
#include "bdDoubleSpinBox.h"
#include "qcheckbox.h"

class bdPeqSlider;

class bdParametricEqualizerWidget : public bdGroupBox
{
	Q_OBJECT

public:
    bdSerialPort *serialPortPtr;

	bdParametricEqualizerWidget(bdSerialPort *serialPort, QWidget *parent = 0);

	// Update all values of the Widget from the struct
	void updateFromStruct(system_status_t *status);

    void sendCmd(QString cmd);
private:
	// Num Bands
	int numBands;

	// Main Layout
    QVBoxLayout *mainVLayout;
    QFormLayout *formLayout;
	QHBoxLayout *mainHLayout;
	QVBoxLayout	*peqVLayout;

	// Slider Layout
	QHBoxLayout	*slidersHLayout;

	// Slider List
	QList<bdPeqSlider*> sliderList;
	
	void blockSignalsEqSliders(bool block);
	void createSliders(int numBand);

	// Layout
	QHBoxLayout *bottomHLayout;

	// Reset gain (flat response)
	QPushButton *resetGainButton;

	// Group Box Filters
	QVBoxLayout *filterVLayout;

	// High Shelving 
	bdGroupBox *hshelvGroupBox;
	QFormLayout *hsFormLayout;
	QLabel *hsFcLabel;
	bdSpinBox *hsFcSpinBox;
	QLabel *hsGainLabel;
	bdDoubleSpinBox *hsGainSpinBox;

	void connectSignals();
	void disconnectSignals();

	friend class bdEqSlider;

    void setEnableAllWidgets(bool enable);

private slots:

	// [SLOT] Enable process
	void slot_enableProcess(QString enable);

	// [SLOT] Reset gains
	void slot_resetGains();

	// [SLOT] High Shelving Fc
	void slot_hsFc(int fc);

	// [SLOT] High Shelving Gain
	void slot_hsGain(double gain);
};

class bdPeqSlider : public QWidget
{
	Q_OBJECT

public:
    bdPeqSlider(bdSerialPort *serialPort, int idx, bdParametricEqualizerWidget *peq, QWidget *parent = 0);

    bdSerialPort *serialPortPtr;

	// Send Configuration
	void sendConfiguration();

    // Update Value Struct
    void updateValueStruct(bdParametricEqualizerWidget *peq);

	// Struct Update
	void updateFromStruct(system_status_t *status);

	// Enable
	bool getEnable() {return enableCheckBox->isChecked();};
	void setEnable(bool on);

	// Frequency
	int getFrequency() { return freqValueSpinBox->value(); };
	void setFrequency(int value);
    void setMaxFreq(int max) { freqValueSpinBox->blockSignals(true); freqValueSpinBox->setMaximum(max); freqValueSpinBox->blockSignals(false); };
	void setMinFreq(int min) { freqValueSpinBox->blockSignals(true); freqValueSpinBox->setMinimum(min); freqValueSpinBox->blockSignals(false); };

	// Gain
	float getGain() { return gainValueSpinBox->value(); };
	void setGain(float value);
    void updateGain(float value);

#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
	// Q Factor
	float getQ();
	void setQ(float Q);
#endif

    bdParametricEqualizerWidget *peq;

	// Layout
	QGridLayout	*mainGridLayout;

	// Frequency
	bdSpinBox *freqValueSpinBox;
	// Slider
	QSlider *eqSlider;
#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
	// Q Factor
	bdDoubleSpinBox *QFactorSpinBox;
#endif
	// Gain
	bdDoubleSpinBox *gainValueSpinBox;
	// Enable
	QCheckBox *enableCheckBox;

	// Label
	QLabel *freqLabel;
	QLabel *maxLabel;
	QLabel *minLabel;
	QLabel *zeroLabel;
	QLabel *gainLabel;
#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
	QLabel *QFactorLabel;
#endif
	QLabel *enableLabel;

	// Bnad Number
	int noBand;

public slots:
	// [SLOT] Slider Value
	void slot_sliderValue(int value);

	// [SLOT] Enable
	void slot_enable(int value);

	// [SLOT] Gain Value
	void slot_gainValue(double value);

	// [SLOT] Freq Value
	void slot_freqValue(int value);

#if BD_CONF_GEQ_Q_FACTOR_EDITABLE
	// [SLOT] Q Factor
	void slot_qFactor(double value);
#endif
};

#endif // BD_PARAMETRIC_EQUALIZER_WIDGET_H
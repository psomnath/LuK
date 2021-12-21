# Tools 

## 1. Introduction

These are some additional tools to compile and create the OCR model for ESP32 chip.

## 2. Compile tensorflow library

In platformio-tensorflow-lite directory is a compile.bat that helps build tensorflow for ESP32 chip. Tensorflow and ESPIDF have different release cycles so finding a combination of the two that works well together can be difficult. The compile.bat includes two versions that are compatible but they may be older versions of both systems.

Once docker creates and compiles tensorflow, it copies that and library.json to the lib directory for compilation.

Read the compile.bat file as it includes additional updates to files to make sure it compiles correctly in Visual Code.

## 3. Download / Train and prepare model

To run a tensorflow model on a microprocessor, it needs to be converted using tflite. ocr_esp32.ipynb is a jupyter notebook the following:

### 3.1 Downloads a pretrained model

Using some pretrained models, the jupyter notebook downloads those models and converts them to tflite.

### 3.2 Trains a model from scratch

Since some pretrained models can be large, even when reduced using the tflite converter, the notebook has the ability to train a model using a randomly created dataset.

### 3.3 Convert model to microprocessor friendly

The notebooks include the code to reduce model size by changing number types (double precision to float or int). It also includes the code to change the tflite file to hexadecimal array representation.
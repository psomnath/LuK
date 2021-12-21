docker build . -t tflite-generator --build-arg tensorflow_version=v2.6.0 --build-arg esp_idf_version=release/v4.3

docker run -v %cd%/../../lib:/dst -t tflite-generator

copy library.json ..\..\lib\tfmicro\library.json

REM lib\tfmicro\third_party\flatbuffers\include\flatbuffers\base.h
REM Replace in file
REM
REM // #if defined(ARDUINO) && !defined(ARDUINOSTL_M_H)
REM //   #include <utility.h>
REM // #else
REM  #include <utility>
REM // #endif


REM lib\tfmicro\tensorflow\lite\kernels\kernel_util.cc
REM Add to beginning of file
REM
REM #include <string>
REM #include <sstream>
REM template <typename T>
REM std::string to_string(T val)
REM {
REM     std::stringstream stream;
REM     stream << val;
REM     return stream.str();
REM }


REM lib\tfmicro\tensorflow\lite\kernels\internal\min.h
REM std::fmin -> std::min


REM lib\tfmicro\tensorflow\lite\kernels\internal\max.h
REM std::fmax -> std:max



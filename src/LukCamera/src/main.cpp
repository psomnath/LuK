#define CAMERA_MODEL_AI_THINKER
#include <Arduino.h>
#include "esp_camera.h"
#include <WiFi.h>
#include "camera_pins.h"
#include "NeuralNetwork.h"

NeuralNetwork *nn;

void setup() {
  Serial.begin(115200);
  nn = new NeuralNetwork();
  Serial.setDebugOutput(true);
  Serial.println();

  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;
  
  // if PSRAM IC present, init with UXGA resolution and higher JPEG quality
  //                      for larger pre-allocated frame buffer.
  if(psramFound()){
    config.frame_size = FRAMESIZE_UXGA;
    config.jpeg_quality = 10;
    config.fb_count = 2;
  } else {
    config.frame_size = FRAMESIZE_SVGA;
    config.jpeg_quality = 12;
    config.fb_count = 1;
  }

  // camera init
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    return;
  }

  sensor_t * s = esp_camera_sensor_get();
  // initial sensors are flipped vertically and colors are a bit saturated
  if (s->id.PID == OV3660_PID) {
    s->set_vflip(s, 1); // flip it back
    s->set_brightness(s, 1); // up the brightness just a bit
    s->set_saturation(s, -2); // lower the saturation
  }
  // drop down frame size for higher initial frame rate
  s->set_framesize(s, FRAMESIZE_QVGA);
}

void loop() {
  camera_fb_t *fb = NULL;

  // put your main code here, to run repeatedly:
  Serial.println("loop");
  fb = esp_camera_fb_get();
  if (fb)
  {
    if (fb->format == PIXFORMAT_JPEG)
    {
      Serial.println("JPEG");
      Serial.println(fb->height);
      Serial.println(fb->width);
    }
    else
    {
      Serial.println("OTHER");
    }
    esp_camera_fb_return(fb);
  }

  float number1 = random(100) / 100.0;
  float number2 = random(100) / 100.0;

  nn->getInputBuffer()[0] = number1;
  nn->getInputBuffer()[1] = number2;

  float result = nn->predict();

  const char *expected = number2 > number1 ? "True" : "False";

  const char *predicted = result > 0.5 ? "True" : "False";

  Serial.printf("%.2f %.2f - result %.2f - Expected %s, Predicted %s\n", number1, number2, result, expected, predicted);

  delay(2000);
}
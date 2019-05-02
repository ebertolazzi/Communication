
## how o run

1. Generate `signalmap.yaml` by executing `../src_generator/xlsx_to_yaml.rb` which use `xlsx_to_yaml_config.rb` for the conversion
~~~
ruby ../src_generator/xlsx_to_yaml.rb ../src_mqtt_test/xlsx_to_yaml_config_MQTT_test.rb
~~~

2. Generate the code to be compiled by executing `../src_generator/generate_MQTT_lib.rb`
~~~
ruby ../src_generator/generate_MQTT_lib.rb
~~~

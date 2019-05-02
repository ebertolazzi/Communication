
## how o run

1. Generate `signalmap.yaml` by executing `../src_generator/xlsx_to_yaml.rb` which use `xlsx_to_yaml_config.rb` for the conversion
~~~
ruby ../src_generator/xlsx_to_yaml.rb ../src_udp_test/xlsx_to_yaml_config_UDP_test.rb
~~~

2. Generate the code to be compiled by executing `../src_generator/generate_UDP_lib.rb`
~~~
ruby ../src_generator/generate_UDP_lib.rb
~~~

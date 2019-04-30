
## xlsx_to_yaml.rb
Ruby script to convert excell (xlsx) file into a yaml data file.
The file `xlsx_to_yaml_config.rb` is used to select the file to be converted, the name of the output file and the columns of the excell file to be selected with the name of the converted field in yaml.

To convert a file run

~~~~
ruby xlsx_to_yaml.rb
~~~~

## serialize.rb
Ruby script utility for the serialization of data converted with
`xlsx_to_yaml.rb` to a yaml data file.

## generate_all.rb
Ruby script to generate C/C++/SIMULUNK script/code with
the serialization of the data contained in the `./signalmap.yaml` data file.


class Config
  attr_accessor :input_file_name,
                :yaml_file_name_MQTT,
                :columns_map,
                :for_structs

  def initialize
    @input_file_name      = '../../signalmap_safestrip_interfaces_v6.2'
    @yaml_file_name_MQTT  = 'signalmap_MQTT'

    # name of the columns of the xlsx file to be used.
    # :XXXX is the name of the imported column
    @columns_map = [
      [ "Name",                 :name                 ],
      [ "Description/subtopic", :description_subtopic ],
      [ "Comment",              :comment              ],
      [ "Num. Elements",        :size                 ],
      [ "Type",                 :type                 ],
      [ "Range",                :range                ],
      [ "Unit",                 :unit                 ],
      [ "yes/no/x",             :yes_no_x             ],
      [ "Scenario",             :scenario             ],
      [ "Manoeuvre",            :manoeuvre            ]
    ]

    # list ofthe selected columns to be exported in the serialized struct
    @for_structs = [ :name, :comment, :size, :type, :range, :unit ]

  end
end
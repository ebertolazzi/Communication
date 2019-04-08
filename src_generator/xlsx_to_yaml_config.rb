class Config
  attr_accessor :input_file_name,
                :yaml_file_name,
                :columns_map,
                :for_structs

  def initialize
    @input_file_name = '../../signalmap_safestrip_interfaces_v2.0'
    @yaml_file_name  = 'signalmap'

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

    @for_structs = [ :name, :comment, :size, :type, :range, :unit ]

  end
end
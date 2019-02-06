class Config
  attr_accessor :input_file_name, :yaml_file_name, :columns_map

  def initialize
    @input_file_name = 'signalmap_safestrip_interfaces_v1.0'
    @yaml_file_name  = 'signalmap'

    @columns_map = [
      [ "Name",              :name    ],
      [ "Type",              :type    ],
      [ "Num. Elements",     :size    ],
      [ "Description/topic", :description_topic ],
      [ "Comment",           :comment ],
      [ "Unit",              :unit    ]
    ]
  end
end
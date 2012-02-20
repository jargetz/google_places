module GooglePlaces
  class Autocomplete
    attr_accessor :lat, :lng, 

    def initialize(json_result_object)
      @description                = json_result_object['description']
      @id                         = json_result_object['id']
      @matched_substrings         = json_result_object['json_result_object']
      @reference                  = json_result_object['reference']
      @terms                      = json_result_object['terms']
    end

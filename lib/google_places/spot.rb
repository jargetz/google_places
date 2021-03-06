module GooglePlaces
  class Spot
    attr_accessor :lat, :lng, :name, :icon, :reference, :vicinity, :types, :id, :formatted_phone_number, :international_phone_number, :formatted_address, :address_components, :street_number, :street, :city, :region, :postal_code, :country, :rating, :url, :cid, :website, :description, :id, :matched_substrings, :reference, :terms, :routes

    def self.directions(origin_lat, origin_lng, dest_lat, dest_lng,
                          api_key, options={})
      sensor = options.delete(:sensor) || false
      origin = Location.new(origin_lat, origin_lng)
      destination = Location.new(dest_lat, dest_lng)
      waypoints = options.delete(:waypoints) || nil

      options = {
        :sensor => sensor,
        :origin => origin.format,
        :destination => destination.format,
      }

      if not waypoints.nil?
        options[:waypoints] = waypoints
      end

      response = Request.directions(options)
      self.new(response)  
    end

    def self.autocomplete(search_term, lat, lng, api_key, options={})
      sensor = options.delete(:sensor) || false
      offset = options.delete(:offset) || ""
      location = Location.new(lat, lng)
      radius = options.delete(:radius) || 50000
      language  = options.delete(:language)
      types = options.delete(:types)

      exclude = [exclude] unless exclude.is_a?(Array)

      options = {
        :sensor => sensor,
        :offset => offset,
        :location => location.format,
        :radius => radius,
        :language => language,
        :input => search_term,
        :key => api_key
      }

      # Accept Types as a string or array
      if types
        types = (types.is_a?(Array) ? types.join('|') : types)
        options.merge!(:types => types)
      end

      response = Request.autocomplete(options)
      response['predictions'].map do |result|
        #puts result.inspect
        puts (result['types'] & exclude)
        self.new(result) if (result['types'] & exclude) == []
      end.compact
    end

    def self.list(lat, lng, api_key, options = {})
      radius = options.delete(:radius) #|| 50000
      sensor = options.delete(:sensor) || false
      types  = options.delete(:types)
      name  = options.delete(:name)
      keyword = options.delete(:keyword)
      language  = options.delete(:language)
      location = Location.new(lat, lng)
      exclude = options.delete(:exclude) || []
      retry_options = options.delete(:retry_options) || {}
      rankby = options.delete(:rankby)

      exclude = [exclude] unless exclude.is_a?(Array)

      options = {
        :location => location.format,
        :sensor => sensor,
        :key => api_key,
        :name => name,
        :language => language,
        :keyword => keyword,
        :retry_options => retry_options
      }

      options[:radius] = radius unless radius.to_s.empty?
      options[:rankby] = rankby unless rankby.to_s.empty?

      puts options.inspect

      # Accept Types as a string or array
      if types
        types = (types.is_a?(Array) ? types.join('|') : types)
        options.merge!(:types => types)
      end

      response = Request.spots(options)
      response['results'].map do |result|
        self.new(result) if (result['types'] & exclude) == []
      end.compact
    end

    def self.find(reference, api_key, options = {})
      sensor = options.delete(:sensor) || false
      language  = options.delete(:language)
      retry_options = options.delete(:retry_options) || {}

      response = Request.spot(
        :reference => reference,
        :sensor => sensor,
        :key => api_key,
        :language => language,
        :retry_options => retry_options
      )

      self.new(response['result'])
    end

    def initialize(json_result_object)
      @reference                  = json_result_object['reference']
      @vicinity                   = json_result_object['vicinity']
      if json_result_object['geometry']
        @lat                        = json_result_object['geometry']['location']['lat']
        @lng                        = json_result_object['geometry']['location']['lng']
      end
      @name                       = json_result_object['name']
      @icon                       = json_result_object['icon']
      @types                      = json_result_object['types']
      @id                         = json_result_object['id']
      @formatted_phone_number     = json_result_object['formatted_phone_number']
      @international_phone_number = json_result_object['international_phone_number']
      @formatted_address          = json_result_object['formatted_address']
      @address_components         = json_result_object['address_components']
      @street_number              = address_component(:street_number, 'short_name')
      @street                     = address_component(:route, 'long_name')
      @city                       = address_component(:locality, 'long_name')
      @region                     = address_component(:administrative_area_level_1, 'long_name')
      @postal_code                = address_component(:postal_code, 'long_name')
      @country                    = address_component(:country, 'long_name')
      @rating                     = json_result_object['rating']
      @url                        = json_result_object['url']
      @cid                        = json_result_object['url'].to_i
      @website                    = json_result_object['website']
      @description                = json_result_object['description']
      @reference                  = json_result_object['reference']
      @terms                      = json_result_object['terms']
      @description                = json_result_object['description']
      @id                         = json_result_object['id']
      @matched_substrings         = json_result_object['matched_substrings']
      @routes                     = json_result_object['routes']
      @lat                        = json_result_object['lat'] if @lat.to_s.empty?
      @lng                        = json_result_object['lng'] if @lng.to_s.empty?
    end

    def address_component(address_component_type, address_component_length)
      if component = address_components_of_type(address_component_type)
        component.first[address_component_length] unless component.first.nil?
      end
    end
    
    def address_components_of_type(type)
      @address_components.select{ |c| c['types'].include?(type.to_s) } unless @address_components.nil?
    end

  end
end

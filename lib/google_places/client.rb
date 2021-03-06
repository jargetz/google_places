module GooglePlaces
  class Client
    attr_reader :api_key
    attr_reader :options

    def initialize(api_key, options = {})
      @api_key = api_key
      @options = options
    end

    def spots(lat, lng, options = {})
      Spot.list(lat, lng, @api_key, @options.merge(options))
    end

    def spot(reference, options = {})
      Spot.find(reference, @api_key, @options.merge(options))
    end

    def autocomplete(search_term, lat, lng, options = {})
      Spot.autocomplete(search_term, lat, lng, @api_key, @options.merge(options))
    end

    def directions(origin_lat, origin_lng, dest_lat, dest_lng, options = {})
      Spot.directions(origin_lat, origin_lng, dest_lat, dest_lng, @api_key, @options.merge(options))
    end
  end
end

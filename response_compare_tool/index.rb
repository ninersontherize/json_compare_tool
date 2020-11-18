# frozen_string_literal: true

module AlmanacParityTestingServices
  module ResponseCompareTool
    class Index
      def initialize(endpoint:, params:, api_headers:, alm_headers: nil)
        @endpoint = endpoint
        @params = params
        @api_headers = api_headers
        @alm_headers = alm_headers
      end

      def run
        #initialize responses for both api and v2 - these will always be compared
        api_res = AlmanacParityTestingServices::Client.new(api_attrs(@params)).run
        v2_res = AlmanacParityTestingServices::Client.new(alm_attrs_v2(@params)).run

        #set keys to loop through for v2 response
        v2_response_keys = v2_res[0].keys

        return "V2 mismatch on #{@endpoint}s with params: #{@params}: #{key_check(v2_res, api_res["data"], v2_response_keys)}" unless key_check(v2_res, api_res["data"], v2_response_keys) == true

        #only compare /apps/residuals if headers are passed, otherwise only v2 is run
        if !@alm_headers.nil?
          residuals_res = AlmanacParityTestingServices::Client.new(alm_attrs_residuals(@params)).run

          #set keys to loop through for the response
          residual_response_keys = residuals_res["data"].keys

          return "Residuals mismatch on #{@endpoint}s with params: #{@params}:  #{key_check(residuals_res["data"], api_res["data"], residual_response_keys)}" unless key_check(residuals_res["data"], api_res["data"], residual_response_keys) == true
        end

        true
      end
      private

      def key_check(res_1, res_2, keys)
        #initialize response index for error tracking and recursive calls
        response_index = 0

        #check if we are dealing with an array response or not
        if res_1.kind_of?(Array)
          #if so, cycle through the array and keys for each
          res_1.each do |record|
            keys.each do |key|
              #if the record is an array, like residuals or options, make a recursive call with just that object
              if record[key].kind_of?(Array)
                #recursive call here with a slight twist on error message to deal with nested objects
                #this should cover cases where a value within a parent object is mismatched, so we can pinpoint it quickly
                if (record[key] == []) then next end
                return "Mismatch failure at response index: #{response_index}, field: #{key} - Child Error: #{key_check(record[key], res_2[response_index][key], record[key][0].keys)}" unless key_check(record[key], res_2[response_index][key], record[key][0].keys) == true
                next
              end

              #initialize match and index counter for search pattern
              match = false
              index_counter = 0

              #here we search for each entry in res_1
              #we are trying to make sure that all data in res_1 exists in res_2
              #so res_1 should be the old or master record whereas res_2 is the new json
              res_1.each do |sub_record|
                #if a match is found, set match to true and break loop
                if record[key] == res_2[index_counter][key.camelize(:lower)]
                  match = true
                  break
                end
                #if match is not found, increment and continue
                index_counter+=1
              end

              #if we reach the end, and no match is found, return with index and key failed on
              return "Mismatch failure at response index: #{response_index}, field: #{key}" unless match
            end

            #increment for errors and continue
            response_index+=1
          end
        else
          #if we are dealing with a single object, just cycle through keys
          keys.each do |key|
            if res_1[key].kind_of?(Array)
              #same idea as above
              return "Mismatch failure at response index: #{response_index}, field: #{key} - Child Error: #{key_check(res_1[key], res_2[response_index][key], res_1[key][0].keys)}" unless key_check(res_1[key], res_2[response_index][key], res_1[key][0].keys) == true
              next
            end

            #don't need an index counter here since we are guaranteed to have a single object
            match = false

            #check if keys match and set match to true
            if res_1[key] == res_2[0][key.camelize(:lower)]
              match = true
            end

            #if no match return index and key
            return "Mismatch failure at response index: #{response_index}, field: #{key}" unless match
          end
        end

        #return true if everything matches
        true
      end

      #connection param setup
      def alm_attrs_v2(params)
        {
          url: "https://almanac.alg.pod.tc",
          path: "/v2/#{@endpoint.camelize(:lower)}s",
          params: @params
        }
      end

      def alm_attrs_residuals(params)
        {
          url: "https://almanac.alg.pod.tc",
          path: "/apps/residuals/#{@endpoint}",
          params: @params,
          headers: @alm_headers
        }
      end

      def api_attrs(params)
        {
          url: "https://alg-api.staging.pod.tc",
          path: "/#{@endpoint.camelize(:lower)}s",
          params: @params,
          headers: @api_headers
        }
      end
    end
  end
end
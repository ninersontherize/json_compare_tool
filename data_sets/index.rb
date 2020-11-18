# frozen_string_literal: true

module AlmanacParityTestingServices
  module DataSets
    class Index
      def run
        #checks with params that fit /apps/residuals
        residual_check(residuals_params_1)
      end

      private

      def residual_check(params)
        result = true

        residuals_res = AlmanacParityTestingServices::Client.new(alm_attrs_residuals(params)).run
        api_res = AlmanacParityTestingServices::Client.new(api_attrs(params)).run

        #set a counter for the whole response - we need this in dataSets because this returns multiple records
        response_index = 0

        residuals_res.each do |record|
          #first pass checks residual_res
          result = false unless (
            residuals_res["data"][response_index]["name"]               == api_res["data"][response_index]["name"] &&
            residuals_res["data"][response_index]["id"]                 == api_res["data"][response_index]["id"] &&
            residuals_res["data"][response_index]["country"]            == api_res["data"][response_index]["country"] &&
            residuals_res["data"][response_index]["code"]               == api_res["data"][response_index]["code"] &&
            residuals_res["data"][response_index]["isNew"]              == api_res["data"][response_index]["isNew"] &&
            residuals_res["data"][response_index]["market"]             == api_res["data"][response_index]["market"] &&
            residuals_res["data"][response_index]["isAlg"]              == api_res["data"][response_index]["isAlg"] &&
            residuals_res["data"][response_index]["percentPrecision"]   == api_res["data"][response_index]["percentPrecision"] &&
            residuals_res["data"][response_index]["dollarPrecision"]    == api_res["data"][response_index]["dollarPrecision"] &&
            residuals_res["data"][response_index]["maxAnnualMileage"]   == api_res["data"][response_index]["maxAnnualMileage"] &&
            residuals_res["data"][response_index]["maxInitialMileage"]  == api_res["data"][response_index]["maxInitialMileage"] &&
            residuals_res["data"][response_index]["defaultTaxRate"]     == api_res["data"][response_index]["defaultTaxRate"]
          )

          #if false, this will make it easy to find where the error occured
          if result == false
            return "Response record failure at: #{response_index}"
          end

          #increment response counter
          response_index+=1
        end


        result
      end

      def alm_attrs_residuals(params)
        {
          url: "https://almanac.alg.pod.tc",
          path: "/apps/residuals/data_sets",
          params: params,
          headers: alm_headers
        }
      end

      def api_attrs(params)
        {
          url: "https://alg-api.staging.pod.tc",
          path: "/dataSets",
          params: params,
          headers: api_headers
        }
      end

      #setup headers for both endpoints
      def alm_headers
        {
          "Authorization" => "Bearer #{ENV["ALM_BEARER_TOKEN"]}"
        }
      end

      def api_headers
        {
          "Authorization" => "Bearer #{ENV["API_BEARER_TOKEN"]}"
        }
      end

      #dataSets do not take params, so we are just checking that the response is the same
      def residuals_params_1
        {
        }
      end

    end
  end
end
# frozen_string_literal: true

module AlmanacParityTestingServices
  module EffectiveDates
    class Index
      def initialize(api_bearer_token:, alm_bearer_token:)
        @api_bearer_token = api_bearer_token
        @alm_bearer_token = alm_bearer_token
      end

      def run
        test_result = true

        #checks with params that fit /apps/residuals
        #compare to v2 and residuals - should match both
        residuals_run_1 = dual_residual_check(residuals_params_1)
        residuals_run_2 = dual_residual_check(residuals_params_2)

        #checks against logic changes that fit v2, like no modelYear and modelLineId in this case
        v2_run_1 = v2_check(v2_params_1)
        v2_run_2 = v2_check(v2_params_2)

        #change end result to false unless all tests pass correctly
        test_result = false unless (
          residuals_run_1 == true &&
          residuals_run_2 == true &&

          v2_run_1 == true &&
          v2_run_2 == true
        )

        test_result
      end

      private

      def v2_check(params)
        result = true

        v2_res = AlmanacParityTestingServices::Client.new(alm_attrs_v2(params)).run

        api_res = AlmanacParityTestingServices::Client.new(api_attrs(params)).run

        #set a counter for the whole response
        response_index = 0

        v2_res.each do |record|

          result = false unless (
            v2_res[response_index]["effective_date"]     == api_res["data"][response_index]["effectiveDate"] &&
            v2_res[response_index]["last_updated"]       == api_res["data"][response_index]["lastUpdated"] &&
            v2_res[response_index]["is_published"]       == api_res["data"][response_index]["isPublished"]
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

      def residual_check(params)
        result = true

        residuals_res = AlmanacParityTestingServices::Client.new(alm_attrs_residuals(params)).run
        api_res = AlmanacParityTestingServices::Client.new(api_attrs(params)).run
        response_index = 1

        residuals_res["data"].each do |record|

          result = false unless (
            record["effective_date"]  == api_res["data"][response_index]["effectiveDate"] &&
            record["last_updated"]    == api_res["data"][response_index]["lastUpdated"] &&
            record["is_published"]    == api_res["data"][response_index]["isPublished"]
          )
          if result == false

            return "Response record failure at: #{response_index}"
          end
          response_index += 1
        end


        result
      end

      def dual_residual_check(params)
        result = true

        #check residual parity with api
        res_success = residual_check(params)

        #check v2 parity with api
        v2_success = v2_check(params)

        #set to false unless all checks passed
        result = false unless (
          res_success == true && v2_success == true
        )

        #return result
        result
      end



      def alm_attrs_v2(params)
        {
          url: "https://almanac.staging.pod.tc",
          path: "/v2/effectiveDates",
          params: params
        }
      end

      def alm_attrs_residuals(params)
        {
          url: "https://almanac.staging.pod.tc",
          path: "/apps/residuals/effective_dates",
          params: params,
          headers: alm_headers
        }
      end

      def api_attrs(params)
        {
          url: "https://alg-api.staging.pod.tc",
          path: "/effectiveDates",
          params: params,
          headers: api_headers
        }
      end

      def alm_headers
        {
          "Authorization" => "Bearer #{@alm_bearer_token}"
        }
      end

      def api_headers
        {
          "Authorization" => "Bearer #{@api_bearer_token}"
        }
      end

      #test minimum params for residuals endpoint
      def residuals_params_1
        {
          dataSetId: "1",
          onlyReleased: true
        }
      end

      #test full param load for residuals endpoint
      def residuals_params_2
        {
          dataSetId: "1",
          onlyReleased: true
        }
      end

      #test minimum param load case for v2 (on v2 residuals default to false,
      #so we have to pass that in api since it defaults to true now)
      #makeCode added here eventhough technically not required, to limit results and increase performance
      def v2_params_1
        {
          dataSetId: "1"
        }
      end

      #test full param load case for v2
      def v2_params_2
        {
          dataSetId: "1"
        }
      end
    end
  end
end

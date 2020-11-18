#frozen_string_literal: true

module AlmanacParityTestingServices
  class TestRunner
    def initialize(endpoint:, dataSetId: "1", effectiveDate: "2020-05-01")
      @endpoint = endpoint
      @dataSetId = dataSetId
      @effectiveDate = effectiveDate
    end

    def run
      #initialize success_string
      success_string = ""

      #iterate through scenarios, set at 4 currently, but could be any number we want
      (1..4).each do |index|
        #grab our parameters given the endpoint and index
        params = send("#{@endpoint}s_params_#{index}")

        #the first two are always residuals others only v2
        if index < 2
          result = AlmanacParityTestingServices::ResponseCompareTool::Index.new(endpoint: @endpoint, params: params, api_headers: api_headers, alm_headers: alm_headers).run
        else
          result = AlmanacParityTestingServices::ResponseCompareTool::Index.new(endpoint: @endpoint, params: params, api_headers: api_headers).run
        end

        #if result is not true, return error message
        #added \n here for when we want to pp in console, should print out nice and readable
        success_string += "ERROR: #{result}. \n" unless result == true

        #add to success string on success for return value
        success_string += "SUCCESS: /#{@endpoint}s matched successfully with #{params}. \n" unless result != true
      end

      #return the success string with info regarding tests
      success_string
    end

    private

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

    #
    #MAKES PARAMS
    #
    #test minimum params for residuals endpoint
    def makes_params_1
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        makeCode: "100",
        residuals: true
      }
    end

    #test full param load for residuals endpoint
    def makes_params_2
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        makeCode: "100",
        residuals: true,
        annualMileage: "9000",
        initialMileage: "15000",
        condition: "ROUGH"
      }
    end

    #test minimum param load case for v2 (on v2 residuals default to false,
    #so we have to pass that in api since it defaults to true now)
    #makeCode added here eventhough technically not required, to limit results and increase performance
    def makes_params_3
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        makeCode: "100",
        residuals: false
      }
    end

    #test full param load case for v2
    def makes_params_4
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        makeCode: "100",
        residuals: true,
        onlyPublished: false,
        onlyNew: false,
        rounding: true,
        initialMileage: "10000",
        annualMileage: "17000",
        condition: "ROUGH",
        weighting: "BUILD"
      }
    end

    #
    #MODEL_LINES PARAMS
    #
    #test minimum params for residuals endpoint
    def model_lines_params_1
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        modelLineId: "14700",
        residuals: true
      }
    end

    #test full param load for residuals endpoint
    def model_lines_params_2
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        modelLineId: "14700",
        residuals: true,
        annualMileage: "9000",
        initialMileage: "15000",
        condition: "ROUGH"
      }
    end

    #test minimum param load case for v2 (on v2 residuals default to false,
    #so we have to pass that in api since it defaults to true now)
    #makeCode added here eventhough technically not required, to limit results and increase performance
    def model_lines_params_3
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        makeCode: "100",
        residuals: false
      }
    end

    #test full param load case for v2
    def model_lines_params_4
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        makeCode: "100",
        modelLineId: "14700",
        residuals: true,
        onlyPublished: true,
        initialMileage: "10000",
        annualMileage: "17000",
        condition: "ROUGH",
        weighting: "BUILD",
        onlyNew: false
      }
    end

    #
    #MODEL_YEARS PARAMS
    #
    #test minimum params for residuals endpoint
    def model_years_params_1
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        residuals: true
      }
    end

    #test full param load for residuals endpoint
    def model_years_params_2
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        residuals: true,
        annualMileage: "9000",
        initialMileage: "15000",
        condition: "ROUGH"
      }
    end

    #test minimum param load case for v2 (on v2 residuals default to false,
    #so we have to pass that in api since it defaults to true now)
    #we need to put a modelYear here even though it isnt required, because v2 will return all modelYears
    #and alg-api will return only those modelYears we are authorized to view
    #this is a byproduct of our auth system and not representative of a data mismatch
    def model_years_params_3
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2018",
        residuals: false
      }
    end

    #test full param load case for v2
    def model_years_params_4
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        residuals: true,
        onlyPublished: true,
        initialMileage: "10000",
        annualMileage: "17000",
        condition: "ROUGH",
        weighting: "BUILD",
        onlyNew: false
      }
    end

    #
    #MODELS PARAMS
    #
    #test minimum params for residuals endpoint
    def models_params_1
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        makeCode: "100",
        modelCode: "140",
        residuals: true
      }
    end

    #test full param load for residuals endpoint
    def models_params_2
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        makeCode: "100",
        modelCode: "140",
        residuals: true,
        annualMileage: "9000",
        initialMileage: "15000",
        condition: "ROUGH"
      }
    end

    #test minimum param load case for v2 (on v2 residuals default to false,
    #so we have to pass that in api since it defaults to true now)
    #makeCode added here eventhough technically not required, to limit results and increase performance
    def models_params_3
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        makeCode: "100",
        residuals: false
      }
    end

    #test full param load case for v2
    def models_params_4
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        makeCode: "100",
        modelCode: "140",
        residuals: true,
        onlyPublished: false,
        initialMileage: "10000",
        annualMileage: "17000",
        condition: "ROUGH",
        weighting: "BUILD",
        onlyNew: false
      }
    end

    #
    #SEGMENTS PARAMS
    #
    #test minimum params for residuals endpoint
    def segments_params_1
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        segmentCode: "175",
        residuals: true
      }
    end

    #test full param load for residuals endpoint
    def segments_params_2
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        segmentCode: "175",
        residuals: true,
        annualMileage: "9000",
        initialMileage: "15000",
        condition: "ROUGH"
      }
    end

    #test minimum param load case for v2 (on v2 residuals default to false,
    #so we have to pass that in api since it defaults to true now)
    def segments_params_3
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        residuals: false
      }
    end

    #test full param load case for v2
    def segments_params_4
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        segmentCode: "175",
        residuals: true,
        initialMileage: "10000",
        annualMileage: "17000",
        condition: "ROUGH",
        weighting: "BUILD",
        onlyNew: false
      }
    end

    #
    #STYLES PARAMS
    #
    #test minimum params for residuals endpoint
    def styles_params_1
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        algCode: "100140125",
        residuals: true,
        expanded: true
      }
    end

    #test full param load for residuals endpoint
    def styles_params_2
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        algCode: "100140125",
        residuals: true,
        expanded: true,
        annualMileage: "9000",
        initialMileage: "15000",
        condition: "ROUGH"
      }
    end

    #test minimum param load case for v2 (on v2 residuals default to false,
    #so we have to pass that in api since it defaults to true now)
    def styles_params_3
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        algCode: "100140125",
        modelYear: "2017",
        residuals: false,
        expanded: false
      }
    end

    #test full param load case for v2
    def styles_params_4
      {
        dataSetId: @dataSetId,
        effectiveDate: @effectiveDate,
        modelYear: "2017",
        algCode: "100140125",
        modelLineId: "14700",
        segmentCode: "155",
        expanded: true,
        residuals: true,
        initialMileage: "10000",
        annualMileage: "17000",
        condition: "ROUGH",
        onlyPublished: false,
        onlyCq: false,
        onlyNew: false
      }
    end
  end
end

import ballerina/http;


service /registry on new http:Listener(9000) {
    
    function init() returns error? {

    };

    # Search for resources in the marketplace 
    #
    # + query - Search query   
    # + orgName - Name of the Choreo organization within which resources are published. 
    #             If speficied, search will return resouces only exposed by this organiztion.    
    # + projectName - Name of the Choreo project within which resources are published. 
    #             If speficied, search will return resouces only exposed by this project.   
    #             `orgName` must be defined along with this parameter. 
    # + keywords - List of keywords to filter the search  
    # + 'limit - Max number of resources to contain in the respose  
    # + offset - Pagination offset  
    # + sort - Sorting parameters of the search 
    # + return - List of marketplace resources matches to search
    resource function get apis(string? query, string? orgName, string? projectName, string[]? keywords,
                 int 'limit = 20, int offset = 0, string sort = "org,ASC") returns Api[]|error {
       return error("djdfjd");
    };

    # Get specific API by Id(latest)
    #
    # + apiId - Id of the api 
    # + return - Api with latest version detail included, along with other versions numbers
    resource function get apis/[string apiId] () returns Api|error {
        return error("djdfjd");
    }

    # Get specific API version 
    #
    # + apiId - Id of the api 
    # + version - Version of the api to get details for
    # + return - List of version numbers 
    resource function get apis/[string apiId]/[string 'version] () returns Api|error {
         return error("djdfjd");
    };

    # Get API by name
    #
    # + orgName - Organization by which API is exposed   
    # + projectName - Project by which API is exposed   
    # + component - Component by which API is exposed   
    # + apiName - Name of the API/service
    # + return - API information of latest version
    resource function get apis/[string orgName]/[string projectName]/[string component]/[string apiName] () returns Api|error {
        return error("djdfjd");
    }

    # Get specific API version by name
    #
    # + orgName - Organization by which API is exposed   
    # + projectName - Project by which API is exposed   
    # + component - Component by which API is exposed   
    # + apiName - Name of the API/service
    # + 'version - Version of the API/service
    # + return - API information of specified version
    resource function get apis/[string orgName]/[string projectName]/[string component]/[string apiName]/[string 'version]() returns Api|error {
        return error("djdfjd");
    }

    # Get popular APIs
    # + return - List of popular APIs
    resource function get apis/popular() returns Api[]|error {
        return [];
    };


    # Search for keywords of resources in the marketplace 
    #
    # + orgName - Name of the Choreo organization within which keyword search needs to operate   
    # + projectName - Name of the Choreo project within which keyword search needs to operate  
    # + return - List of keywords matching search 
    resource function get apis/keywords(string? orgName, string? projectName) returns KeywordInfo[]|error {
        return [
            {keyword: "business management/ERP", count: 6}, 
            {keyword: "billing/weekly calc", count: 2}
        ];
    }

    # Rate a given resource 
    #
    # + rateRequest - ResourceRateRequest payload 
    # + return - Error if unsuccessful
    resource function post apis/rating (@http:Payload ResourceRateRequest rateRequest) returns error? {

    }

    # Get APIM applications visible to the user within the Choreo organization
    #
    # + userId - Id of the user 
    # + orgId - Id of the organization  
    # + environmentId - Id of the environment 
    # + return - List of ApiApp details
    resource function get apis/apiApps(string userId, string orgId, string environmentId) returns ApiApp[]|error {
        return [];
    }

    # Create an APIM application 
    #
    # + apiApp - Input details of the APIM app to create
    # + return - Created APIM app or error
    resource function post apis/apiApps(@http:Payload CreatableApiApp apiApp) returns ApiApp|error {   
        return {id: "weewueh23399348945", name: "abc-def-app", description: "", environmentId: "skjdkfjdfddfd", subscribedEndpoints:[]};
    }

    # Subscribe APIM application to an API
    #
    # + apiAppId - APIM application to use
    # + subcriptionRequest - SubscriptionRequest input details
    # + return - Error if unsuceesful 
    resource function post apis/apiApps/[string apiAppId]/subscription(@http:Payload SubscriptionRequest subcriptionRequest) returns error? {
        
    }

}

import ballerina/http;


service / on new http:Listener(9000) {
    
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
    # + resourceType - Type of resource (i.e APIs, Configurations) to filter the search   
    # + 'limit - Max number of resources to contain in the respose  
    # + offset - Pagination offset  
    # + sort - Sorting parameters of the search 
    # + return - List of marketplace resources matches to search
    resource function get resources(string? query, string? orgName, string? projectName, string[]? keywords, ResourceType resourceType,
                 int 'limit = 20, int offset = 0, string sort = "org,ASC") returns Resource[]|error {
       return error("djdfjd");
    };

    # Get specific resouce 
    #
    # + resourceId - Id of the resource 
    # + return - Resource detail of the requested Id
    resource function get resources/[string resourceId] () returns Resource|error {
        return error("djdfjd");
    }


    # Search for keywords of resources in the marketplace 
    #
    # + orgName - Name of the Choreo organization within which keyword search needs to operate   
    # + projectName - Name of the Choreo project within which keyword search needs to operate 
    # + resourceType - Type of resource (i.e APIs, Configurations) to filter the search   
    # + return - List of keywords matching search 
    resource function get keywords(string? orgName, string? projectName, ResourceType resourceType) returns KeywordInfo[]|error {
        return [
            {keyword: "business management/ERP", count: 6}, 
            {keyword: "billing/weekly calc", count: 2}
        ];
    }

    
    # Get usage statistics (common) of a resource 
    #
    # + resourceId - ID of the resource 
    # + return - UsageDetail respose of requested resource 
    resource function get resources/[string resourceId]/stats() returns UsageDetail|error {
        return {usageCount: 235, rating: 4};
    } ;

    # Get all keywords (common) of a resource 
    #
    # + resourceId - ID of the resource 
    # + return - List of keywords
    resource function get resources/[string resourceId]/keywords() returns KeywordInfo[]|error {
        return [
                {keyword: "business management/ERP", count: 6}, 
                {keyword: "billing/weekly calc", count: 2}
            ];
    }

    # Rate a given resource 
    #
    # + rateRequest - ResourceRateRequest payload 
    # + return - Error if unsuccessful
    resource function post resources/rating (@http:Payload ResourceRateRequest rateRequest) returns error? {

    }

    //Subscription and API related APIs (specific to APIs)

    # Get all versions (common) of a resource 
    #
    # + resourceId - ID of the resource 
    # + return - List of version IDs    
    resource function get apis/[string resourceId]/versions() returns ApiVersion[]|error {
        return [];
    };

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

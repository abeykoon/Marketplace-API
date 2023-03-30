import ballerina/http;
import choreo_marketplace.devportal as dp;
import ballerina/graphql;
import choreo_marketplace.projectapi as abc;

service /registry on new http:Listener(9000) {

    function init() returns error? {
        
    };

    # Search for resources in the marketplace 
    #
    # + query - Search query   
    # + orgId - Name of the Choreo organization within which resources are published. 
    #             If speficied, search will return resouces only exposed by this organiztion.    
    # + projectId - Name of the Choreo project within which resources are published. 
    #             If speficied, search will return resouces only exposed by this project.   
    #             `orgName` must be defined along with this parameter. 
    # + keywords - List of keywords to filter the search  
    # + 'limit - Max number of resources to contain in the respose  
    # + offset - Pagination offset  
    # + sort - Sorting parameters of the search 
    # + return - List of marketplace resources matches to search
    resource function get apis(string? query, string? orgHandler, string? orgId, string? projectId, string[]? keywords,
                 int 'limit = 20, int offset = 0, string sort = "org,ASC") returns Api[]|error {

        return searchApis(query, orgHandler, orgId, projectId, keywords, 'limit, offset, sort);

    };

    # Get specific API by Id(latest)
    #
    # + apiId - Id of the api 
    # + return - Api with latest version detail included, along with other versions numbers
    resource function get apis/[string apiId] (string orgId, string orgHander) returns Api|error {
        return getApibyId(orgId, orgHander, apiId);
    }

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
    resource function get apis/popular(string orgHander, string orgId, int maxCount) returns Api[]|error {
        return searchApis('limit = maxCount, offset = 0, sort = "rating, DSC", orgHandler = orgHander, orgId = orgId);
    };

    # Search for keywords of resources in the marketplace 
    #
    # + orgName - Name of the Choreo organization within which keyword search needs to operate   
    # + projectName - Name of the Choreo project within which keyword search needs to operate  
    # + return - List of keywords matching search 
    resource function get apis/keywords(string? orgName, string? projectName) returns KeywordInfo[]|error {
        getAllKeywords()
    }

    # Rate a given resource 
    #
    # + rateRequest - ResourceRateRequest payload 
    # + return - Error if unsuccessful
    resource function post apis/rating (@http:Payload RatingRequest rateRequest) returns error? {
        rateApiVersion(rateRequest);
    }

    # Get APIM applications visible to the user within the Choreo organization
    #
    # + userId - Id of the user 
    # + orgId - Id of the organization  
    # + environmentId - Id of the environment 
    # + return - List of ApiApp details
    resource function get apis/apiApps(string userId, string orgId, string environmentId) returns ApiApp[]|error {
        return getAppApplications();
    }

    # Create an APIM application 
    #
    # + apiApp - Input details of the APIM app to create
    # + return - Created APIM app or error
    resource function post apis/apiApps(@http:Payload CreatableApiApp apiApp) returns ApiApp|ApiWorkflowResponse|error {   
        return createApplication(apiApp);
    }

    # Subscribe APIM application to an API
    #
    # + apiAppId - APIM application to use
    # + subcriptionRequest - SubscriptionRequest input details
    # + return - Error if unsuceesful 
    resource function post apis/subscriptions(@http:Payload SubscriptionRequest subcriptionRequest) returns ApiWorkflowResponse|ApiSubscription|error? {
        ApiWorkflowResponse|ApiSubscription subscriptionResponse = check createSubscription(subcriptionRequest);
    }

    resource function get apis/[string apiId]/thumbnail() returns http:Response|error {  //TODO:when loading search results this might be inefficient
        return getApiThubnail(apiId);
    }

    resource function get apis/[string apiId]/documents() returns Document[]|error {
        return getAllApiDocuments(apiId);
    }

    resource function get apis/[string apiId]/documents/[string documentId]/content() returns http:Response|error {  //Dev portal specific 
        return getApiDocumentContent(apiId, documentId);
    }

    resource function get apis/[string apiId]/idl(ApiTypes apiType) returns IDL|error {   //Depending on api type the way to receive IDL differs
        match apiType {   //is associated with dpApi.'type
            HTTP => {
                IDL idl = {
                    idlType: OpenAPI,
                    content: check getDPOpenApi(apiId)
                };
                return idl;
            }
            GRAPHQL => {
                IDL idl = {
                    idlType: GraphQL,
                    content: check getDPSdl(apiId)
                };
                return idl;
            }
            ASYNC => {
                //TODO;
            }
            SOAP => {
                IDL idl = {
                    idlType: WSDL,
                    content: check getDPWsdl(apiId)
                };
                return idl;
            }
        }
    }
  
    
    
    //ADD ?/&organizationId=<uuid> to all API Calls       - 
}

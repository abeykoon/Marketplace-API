import choreo_marketplace.devportal as dp;
import choreo_marketplace.projectapi as prj;
import choreo_marketplace.usersvc as usersvc;
import ballerina/http;
import ballerina/regex;
import ballerina/io;

configurable string token = ?;
configurable string devPortalUrl = ?;
configurable string projectApiUrl = ?;
configurable string appServiceUrl = ?;

final dp:ConnectionConfig dpConConfig = {
    auth: {
        token: token
    }
};
//Client to call devportal
final dp:Client devPortalClient = check new (dpConConfig, serviceUrl = devPortalUrl);

final prj:ConnectionConfig projectApiConConfig = {
    auth: {
        token: token
    }
};
//Client to call GraphQL API 
final prj:GraphqlClient projectAPIClient = check new (projectApiConConfig, serviceUrl = projectApiUrl);

final usersvc:UserServiceClient userSvcClient = check new(appServiceUrl);

isolated function getDevPotalClient() returns dp:Client {
    return devPortalClient;
}

isolated function getProjectApiClient() returns prj:GraphqlClient {
    return projectAPIClient;
}

# Get Interger type orgId using orgName.
#
# + idpId - IDP ID of the user  
# + orgName - Name of the organization
# + return - Organization ID
isolated function getOrgId(string idpId, string orgName) returns int|error {
    map<string[]> headers = {};
    headers[REQUEST_USER_ID] = [idpId];
    usersvc:ContextGetOrganizationRequest orgRequest = {
        content: {organization_name: orgName},
        headers: headers
    };
    usersvc:GetOrganizationResponse orgResponse = check userSvcClient->GetOrganization(orgRequest);
    int orgId = orgResponse.organization.id;
    return orgId;
}


# Get organization name using orgId.
#
# + orgId - ID of the organization
# + return - Name of the organization
isolated function getOrgName(string orgId) returns string {   //TODO: implement
   return orgId;
}


# Search APIs in the devportal.
#
# + orgId - ID of the organization
# + orgHandler - Organization handler
# + idpId - IDP ID of the user associated with the call
# + 'limit - Maximum number of APIs to return
# + offset - Pagination offset
# + sort - Sorting parameter and order in the format <field>,<order>
# + query - Search query. If not provided, all APIs will be returned
# + keywords - Keywords to filter the search results
# + return - Array of APIs or error if API invocation fails
isolated function searchDevPortalApis(string orgId, string orgHandler, string idpId, int 'limit, int offset,
             string sort, string? query = (), string[]? keywords = ()) returns Api[]|error {

    dp:APIInfo[] devPortalApis = check getDevPortalApiInfo(orgId = orgId, offset = offset, 'limit = 'limit, query = query); //TODO: check pagination, see how we can include keywords
    table<ApiOwner> key(apiId) apiOwnersOfOrg = check getApiOwnersOfOrg(orgId, orgHandler, idpId); 
    Api[] apis = check populateApis(orgId, devPortalApis, apiOwnersOfOrg, sort); 
    return apis;
}

isolated function getApibyId(string orgId, string orgHandler, string idpId, string apiVersionId) returns Api|error {
    dp:API devPortalApi = check getDevPortalApi(orgId, apiVersionId);
    ApiOwner apiOwner = check getApiOwner(orgId, orgHandler, idpId, apiVersionId);
    //find versions of same API (This is COSTLY, can we go without it?)
    //string apiName = devPortalApi.name;
    //dp:APIInfo[] apiVersions = getDevPortalApis('limit = 50, offset = 0, query = apiName);
    //ApiVersionInfo[] allVersionMetaInfo = getAllVersionMetaInfo(apiVersions, apiName);
    return populateApi(devPortalApi, apiOwner);
}

isolated function getApiOwnersOfOrg(string orgId, string orgHandler, string idpId) returns table<ApiOwner> key(apiId)|error {
    prj:GraphqlClient projectAPIClient = getProjectApiClient();
    table<ApiOwner> key(apiId) apiOwnerInfo = table [];
    io:println("Getting org id");
    int orgIdAsNumber = check getOrgId(idpId, orgHandler);
    io:println("got org id = " + orgIdAsNumber.toString());
    prj:ProjectApisResponse projectApis = check projectAPIClient->projectApis(orgHandler, orgIdAsNumber);
    
    record {|string id; int orgId; string name; string? handler; string? extendedHandler; record {|string? id; record {|string? proxyId;|}[]? apiVersions;|}[] components;|}[] projects = projectApis.projects;
    foreach var project in projects {
        string projectId = project.id;
        string projectName = project.name;
        record {|string? id; record {|string? proxyId;|}[]? apiVersions;|}[] components = project.components;
        foreach var component in components {
            string componentId = component.id ?: "";   //TODO: why optional?
            record {|string? proxyId;|}[]? apiVersions = component.apiVersions;
            if apiVersions is record {|string? proxyId;|}[] {
                foreach var apiVersion in apiVersions {
                    string? apiId = apiVersion.proxyId;
                    if apiId is string {
                        ApiOwner apiOwner = {
                            apiId: apiId,
                            componentId: componentId, 
                            componentName: "",
                            projectId: projectId,
                            projectName: projectName,
                            orgId: orgId, 
                            orgName: ""
                        };
                        apiOwnerInfo.add(apiOwner);
                    }
                }
            }
        }
    }

    return apiOwnerInfo;

};

isolated function getApiOwner(string orgId, string orgHandler, string idpId, string apiVersionId) returns ApiOwner|error {
    table<ApiOwner> key(apiId) apiOwnersOfOrg = check getApiOwnersOfOrg(orgId, orgHandler, idpId);  //TODO: can we do a optimized call for this?
    return getApiOwnerFromTable(apiOwnersOfOrg, apiVersionId);
}

isolated function populateApis(string orgId, dp:APIInfo [] depPortalApis, table<ApiOwner> key(apiId) apiOwnerInfo, string sortingParam) returns Api[]|error {
    
    Api[] apisToReturn = [];

    //get unique APIs 
    string[] apiNames = from dp:APIInfo api in depPortalApis select api.name;
    string[] uniqueApiNames = removeDuplicates(apiNames);

    foreach string apiName in uniqueApiNames {
        ApiVersionInfo[] versionsOfApi = getAllVersionMetaInfo(depPortalApis, apiName);
        ApiVersionInfo latestVersionOfApi = versionsOfApi[0];
        dp:API devPortalApi = check getDevPortalApi(orgId, latestVersionOfApi.apiId);
        ApiOwner apiOwner = check getApiOwnerFromTable(apiOwnerInfo, latestVersionOfApi.apiId);
        Api api = populateApi(devPortalApi, apiOwner, versionsOfApi);
        apisToReturn.push(api);
    }

    Api[] sortedApis =  check sortApis(apisToReturn, sortingParam);

    return sortedApis;
};

isolated function getApiOwnerFromTable(table<ApiOwner> key(apiId) apiOwnerInfo, string apiId) returns ApiOwner|error {
    if apiOwnerInfo.hasKey(apiId) {
        return apiOwnerInfo.get(apiId);
    } else {
        ApiOwner apiOwner = {       //TODO: This is a hack, we need to fix this
            apiId: apiId,
            componentId: "Unknown",
            componentName: "Not found",
            projectId: "Unknown",
            projectName: "Not found",
            orgId: "Unknown",
            orgName: ""
        };
        return apiOwner;
    }
}

isolated function sortApis(Api []apis, string sortingParam) returns Api[]|error {

    string[] sortingArribs = regex:split(sortingParam, ",");
    string sortKey = sortingArribs[0];
    string sortDirection = sortingArribs[1];
    boolean isAcescending = true;
    if sortDirection == "DSC" {
        isAcescending = false;
    } 
    match sortKey {
        "name" => {
            if isAcescending {
                return from var e in apis
                    order by e.name ascending
                    select e;
            } else {
                return from var e in apis
                    order by e.name descending
                    select e;
            }
        }
        "rating" => {
            if isAcescending {
                return from var e in apis
                    order by e.usageStats.rating ascending
                    select e;
            } else {
                return from var e in apis
                    order by e.usageStats.rating descending
                    select e;
            }
        }
        "createdDate" => {
            if isAcescending {
                return from var e in apis
                    order by e.createdTime ascending    //check
                    select e;
            } else {
                return from var e in apis
                    order by e.createdTime descending   //check
                    select e;
            }
        }
        "project" => {
            if isAcescending {
                if isAcescending {
                    return from var e in apis
                        order by e.owner.projectName, e.name ascending 
                        select e;
                } else {
                    return from var e in apis
                        order by e.owner.projectName, e.name descending
                        select e;
                }
            }
        }
        _ => {
            return from var e in apis
                order by e.name ascending
                select e;
        }
    }

    return error("Unexpected issue while sorting Apis"); 
}

isolated function populateApi(dp:API dpApi, ApiOwner apiOwner, ApiVersionInfo[]? versionsOfApi = ()) returns Api {

    boolean isPreRelease = false; 
    if dpApi.lifeCycleStatus == API_LIFECYCLE_PROTOTYPED {
        isPreRelease = true;
    }

    //Documentation and IDL info not included for perf reasons, fetch them by apiId IF NEEDED
    Api api = {
        isPublic: isPublicApi(dpApi),
        id: dpApi.name,
        name: dpApi.name,
        resourceType: ApiType,
        owner: apiOwner,
        hasThumbnail: dpApi.hasThumbnail,   //considering this, FE has to fetch the thubnail 
        apiId: dpApi.id ?: "",
        'version: dpApi.'version,
        createdTime: dpApi.createdTime ?: "",    //format 2022-07-12 10:38:55.295
        isPreRelease: isPreRelease, 
        description: dpApi.description,
        usageStats: {usageCount: 0, rating: dpApi.avgRating},
        keywords: dpApi.tags, 
        scopes: getApiScopeNames(dpApi),   
        throttlingPolicies: getBusinessPlans(dpApi), 
        endpoints: extractApiEndpoints(dpApi),
        apiVersions: versionsOfApi
    };

    return api;
}

//only returns HTTPS and WSS URLs
isolated function extractApiEndpoints(dp:API dpApi) returns APIEndpoint[] {
    APIEndpoint[] apiEndpoints= [];
    dp:API_endpointURLs[]? endpointURLs = dpApi.endpointURLs;
    if endpointURLs is dp:API_endpointURLs[] {
        foreach dp:API_endpointURLs endpoint in endpointURLs {
            string environmentName = endpoint.environmentDisplayName ?: "";
            string endpointURL = "";
            string apiType = dpApi.'type ?: "";
            dp:API_URLs? uRLs = endpoint.URLs;
            if uRLs is dp:API_URLs {
                if (apiType == WS) {
                    endpointURL = uRLs["wss"] ?: "";
                } else {
                    endpointURL = uRLs["https"] ?: "";
                }
            }
            APIEndpoint apiEP = {
                environmentName: environmentName,
                url: endpointURL
            };
            apiEndpoints.push(apiEP);
        }
    } 
    return apiEndpoints;
}

isolated function getApiScopeNames(dp:API dpApi) returns string[] {
    dp:ScopeInfo[]? scopes = dpApi.scopes;
    if scopes is dp:ScopeInfo[] {
        string [] scopeNames = from dp:ScopeInfo scope in scopes
                                select scope.name ?: "";
        return scopeNames;
    } else {
        return [];
    }
}

isolated function getBusinessPlans(dp:API dpApi) returns string[] {
    dp:API_tiers[]? apiTiers = dpApi.tiers;
    if apiTiers is dp:API_tiers[] {
        string[] apiTierNames = from dp:API_tiers tier in apiTiers
                                select tier.tierName ?: "";
        return apiTierNames;
    } else {
        return [];
    }
}

isolated function isPublicApi(dp:API dpApi) returns boolean {
    boolean isPublic = false;
    dp:APIInfo_additionalProperties[]? additionalProps = dpApi.additionalProperties;
    if additionalProps is dp:APIInfo_additionalProperties[] {
        dp:APIInfo_additionalProperties[] accessibilityProperty = from dp:APIInfo_additionalProperties property in additionalProps
            where property.name == API_ACCESSIBILTY_PROPERTY_KEY
            select property;
        if accessibilityProperty[0].value == API_ACCESSIBILTY_PROPERTY_VALUE_EXTENAL {
            isPublic = true;
        }
    }
    return isPublic;
}

isolated function getAllVersionMetaInfo(dp:APIInfo[] devPortalApis, string uniqueApiName) returns ApiVersionInfo[] {
    dp:APIInfo[] versionsOfAPI = from dp:APIInfo api in devPortalApis
        where api.name == uniqueApiName
        order by api.'version descending //TODO: define latest
        select api;

    ApiVersionInfo[] apiVersionMetaInfo = from dp:APIInfo apiVersion in versionsOfAPI
        select {
            'version: apiVersion.'version,
            apiId: apiVersion.id
        };
    return apiVersionMetaInfo;
}

isolated function getApisofProject(string projectId, Api[] allApisOfOrg) returns Api[] {
    return from Api api in allApisOfOrg
        where api.owner.projectId == projectId
        order by api.name
        select api;
}

isolated function getApisOfOtherProjects(string projectId, Api []allApisOfOrg) returns Api[] {
    return from Api api in allApisOfOrg
        where api.owner.projectId != projectId
        order by api.name
        select api;
}

isolated function extractScopes(dp:ApplicationInfo appInfo) returns string[] {
    record {|anydata...;|}? attributes = appInfo.attributes;
    if attributes is map<any> {
        if(attributes.hasKey("scopes")) {
            return <string[]>attributes.get("scopes");
        } else {
            return [];
        }
    } else {
        return [];
    }
}


isolated function getAllKeywords(string orgId) returns KeywordInfo[]|error {     //how to limit to a org
    dp:Client devPotalClient = getDevPotalClient();
    dp:TagList apiTagInfo = check devPotalClient ->/tags(orgId,'limit = 100);
    dp:Tag[]? apiTags = apiTagInfo.list;
    if apiTags is dp:Tag[] {
        KeywordInfo [] keywords = from dp:Tag apiTag in apiTags
                                select {
                                    keyword: apiTag.value,
                                    count: apiTag.count
                                };
        return keywords;
    } else {
        return [];
    }
}

isolated function getDPOpenApi(string orgId, string apiId) returns json|error {
    dp:Client devPotalClient = getDevPotalClient();
    json swaggerContent = check devPotalClient->/apis/[apiId]/swagger(orgId);
    return swaggerContent;
}

isolated function getDPSdl(string orgId, string apiId) returns json|error {
    dp:Client devPotalClient = getDevPotalClient();
    json graphqlSdlContent = check devPotalClient->/apis/[apiId]/graphql\-schema(orgId);
    return graphqlSdlContent;
}

isolated function getDPWsdl(string orgId, string apiId) returns string|error {
    dp:Client devPotalClient = getDevPotalClient();
    http:Response responseWithWsdl = check devPotalClient->/apis/[apiId]/wsdl(orgId);
    string wsdlContent = check responseWithWsdl.getTextPayload();
    return wsdlContent;
}

isolated function getAppApplications(string orgId) returns ApiApp[]|error {    
    dp:Client devPotalClient = getDevPotalClient();
    dp:ApplicationList applicationInfo = check devPotalClient->/applications(orgId);
    dp:ApplicationInfo[]? dpApps = applicationInfo.list;
    if dpApps is dp:ApplicationInfo[] {
        ApiApp[] apiApps = from dp:ApplicationInfo dpApp in dpApps
                            select {
                                id: dpApp.applicationId ?: "", 
                                name: dpApp.name ?: "",
                                description: dpApp.description,
                                environmentId: "",          //TODO:check
                                subscribedApis: check getSubscriptionInfo(orgId, dpApp.applicationId ?: ""), 
                                scopes: extractScopes(dpApp)
                            };                            
        return apiApps;
    } else {
        return [];
    }
}

isolated function getSubscriptionInfo(string orgId, string applicationId) returns string[]|error {
    dp:Client devPotalClient = getDevPotalClient();
    string[] subscribedApis = [];
    dp:SubscriptionList subscriptionResponse = check devPotalClient->/subscriptions(orgId, applicationId = applicationId);
    dp:Subscription[]? subscriptions = subscriptionResponse["list"];
    if subscriptions is dp:Subscription[] {
        foreach dp:Subscription subscription in subscriptions {
            dp:APIInfo? apiInfo = subscription.apiInfo;
            if apiInfo is dp:APIInfo {
                string apiName = apiInfo.name;
                subscribedApis.push(apiName);
            } 
        }
    }
    return subscribedApis;
}

isolated function createApplication(CreatableApiApp appInfo, string orgId) returns ApiApp|ApiWorkflowResponse|error {
    dp:Client devPotalClient = getDevPotalClient();
    dp:Application devPortalApp = {
        name: appInfo.name,
        throttlingPolicy: appInfo.throttlingPolicy,   
        description: appInfo.description
    };
    dp:WorkflowResponse|dp:Application appCreationResult = check devPotalClient->/applications.post(orgId, devPortalApp);
    if appCreationResult is dp:Application {
        ApiApp apiApp = {
            name: appCreationResult.name,
            id: check appCreationResult.applicationId.ensureType(string),
            description: appCreationResult.description,
            environmentId: "",
            subscribedApis: []
        };
        return apiApp;
    } else if appCreationResult is dp:WorkflowResponse {
        ApiWorkflowResponse workflowRespose = {
            workflowStatus: appCreationResult.workflowStatus,
            jsonPayload: appCreationResult.jsonPayload
        };
        return workflowRespose;
    } else {
        return error("Error when creating application name = " + appInfo.name);
    }
}

isolated function createSubscription(string orgId, SubscriptionRequest subscriptionRequest) returns ApiWorkflowResponse|ApiSubscription|error {
    dp:Client devPotalClient = getDevPotalClient();
    dp:Subscription dpSub = {
        applicationId: subscriptionRequest.apiAppId,
        throttlingPolicy: subscriptionRequest.throttlingPolicy,   //Should be one of businessPlan names of the API being subscribed to
        apiId: subscriptionRequest.apiId     //TODO: check why this is not mandatory in generated code
    };
    dp:WorkflowResponse|dp:Subscription subsriptionResult = check devPotalClient->/subscriptions.post(orgId, dpSub);
    if subsriptionResult is dp:Subscription {
        ApiSubscription subscription = {
            subscriptionId: subsriptionResult.subscriptionId ?: "",
            apiId: subsriptionResult.apiId ?: "",
            apiAppId: subsriptionResult.applicationId,
            throttlingPolicy: subsriptionResult.throttlingPolicy
        };
        return subscription;
    } else if subsriptionResult is dp:WorkflowResponse {
        ApiWorkflowResponse workflowRespose = {
            workflowStatus: subsriptionResult.workflowStatus,
            jsonPayload: subsriptionResult.jsonPayload
        };
        return workflowRespose;
    } else {
        return error("Error when subscribing to API id = " + subscriptionRequest.apiId 
            + " to application id= " + subscriptionRequest.apiAppId);
    }
}

isolated function getApiThrottlingPolicyWithMaxLimits(Api api) returns string|error {    //should be done in client side
    string[] businessPlans = api.throttlingPolicies;
    if(businessPlans.filter(e => e == Unlimited).length() > 0) {
        return Unlimited;
    } else if (businessPlans.filter(e => e == Gold).length() > 0) {
        return Gold;
    } else if (businessPlans.filter(e => e == Silver).length() > 0) {
        return Silver;
    } else if(businessPlans.filter(e => e == Bronze).length() > 0) {
        return Bronze;
    }
    return error("No throttling limit found for API id = " + api.apiId);
}

isolated function getAllApiDocuments(string orgId, string apiId) returns Document[]|error {
    dp:Client devPotalClient = getDevPotalClient();
    dp:DocumentList documentInfo = check devPotalClient->/apis/[apiId]/documents(orgId, 'limit = 200);
    dp:Document[]? documents = documentInfo.list;
    if documents is dp:Document[] {
        Document[] apiDocs = from dp:Document document in documents
            select {
                documentId: document.documentId ?: "",
                name: document.name,
                docType: ApiDoc,
                summary: document.summary,
                sourceType: document.sourceType,
                sourceUrl: document.sourceUrl ?: ""
            };
        return apiDocs;
    } else {
        return [];
    }
}

isolated function getApiDocumentContent(string orgId, string apiId, string documentId) returns http:Response|error {
    dp:Client devPotalClient = getDevPotalClient();
    return devPotalClient->/apis/[apiId]/documents/[documentId]/content(orgId);
}

isolated function rateApiVersion(string orgId, RatingRequest ratingRequest) returns Rating|error {
    dp:Client devPotalClient = getDevPotalClient();
    dp:Rating dpRating = {
        apiId: ratingRequest.resourceId,
        rating: ratingRequest.rating,
        ratedBy: ratingRequest.ratedBy
    };
    dp:Rating ratingResponse = check devPotalClient->/apis/[ratingRequest.resourceId]/user\-rating.put(orgId, dpRating);
    Rating apiRating =  {
        ratingId: ratingResponse.ratingId,
        resourceId: ratingResponse.apiId ?: "", 
        ratedBy: ratingResponse.ratedBy, 
        rating: ratingResponse.rating
    };
    return apiRating;
}

isolated function getApiThubnail(string orgId, string apiId) returns http:Response|error {
    dp:Client devPotalClient = getDevPotalClient();
    return devPotalClient->/apis/[apiId]/thumbnail(orgId);
}

isolated function getDevPortalApi(string orgId, string apiVersionId) returns dp:API|error {
    dp:Client devPortalClient = getDevPotalClient();
    dp:API devPortalApi = check devPortalClient->/apis/[apiVersionId](orgId);
    return devPortalApi;
}

isolated function getDevPortalApiInfo(string orgId, int offset, int 'limit, string? query) returns dp:APIInfo[]|error { //include keywords 
    dp:Client devPortalClient = getDevPotalClient();
    dp:APIList orgApis = check devPortalClient->/apis.get(organizationId = orgId, 'limit = 'limit, offset = offset, query = query); //TODO: add tags, pagination info comes here 
    return orgApis.list ?: [];
};

isolated function searchApisWithinProject(string orgId , string orgHandler, string projectId, int 'limit , int offset , string? query, string[]? keywords) returns Api[]|error {
    return[];
}

isolated function searchPublicApis(int 'limit, int offset,string ? query, string[]? keywords) returns Api[]|error {
    return[];
}








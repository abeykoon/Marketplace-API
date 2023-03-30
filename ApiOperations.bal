import choreo_marketplace.devportal as dp;
import choreo_marketplace.projectapi as prj;
import ballerina/http;
import ballerina/graphql;
import ballerina/regex;


function createDevPotalClient() returns dp:Client {
    dp:ConnectionConfig connectionConfig = {
        auth: {
            tokenUrl: "",
            username: "",
            password: ""
        }
    };
    dp:Client devPortalClient = check new (connectionConfig, serviceUrl = "");
}
function getOrgName(string orgId) returns string {
    //get it from app service
}

function searchApis(string? query, string? orgHandler, string? orgId, string? projectId, string[]? keywords,
    int 'limit = 20, int offset = 0, string sort = "org,ASC") returns Api[]|error {
    
    if (orgId != () && projectId != ()) {
        dp:APIInfo[] devPortalApis = getDevPortalApiInfo(0, 20, query);  //TODO: check pagination
        table<ApiOwner> key(apiId) apiOwnersOfOrg = getApiOwnersOfOrg(orgId, orgHandler);  //TODO: check orgHander story
        Api[] apis = check populateApis(devPortalApis, apiOwnersOfOrg, sort);  //TODO: from within project and from other projects
    }
}

function getApibyId(string orgId, string orgHandler, string apiVersionId) returns Api|error {
    dp:API devPortalApi = check getDevPortalApi(apiVersionId);
    ApiOwner apiOwner = check getApiOwner(orgId, orgHandler, apiVersionId);
    //find versions of same API (This is COSTLY, can we go without it?)
    //string apiName = devPortalApi.name;
    //dp:APIInfo[] apiVersions = getDevPortalApis('limit = 50, offset = 0, query = apiName);
    //ApiVersionInfo[] allVersionMetaInfo = getAllVersionMetaInfo(apiVersions, apiName);
    return populateApi(devPortalApi, apiOwner);
}

function getDevPortalApi(string apiVersionId) returns dp:API| error {
    dp:Client devPortalClient = createDevPotalClient();
    dp:API devPortalApi = check devPortalClient->/apis/[apiVersionId]();
    return devPortalApi;
}

function getDevPortalApiInfo(int offset, int 'limit, string? query) returns dp:APIInfo[] {  //include keywords 
    dp:Client devPortalClient = createDevPotalClient();
    dp:APIList orgApis = check devPortalClient->/apis.get('limit, offset, query = query); //TODO: add tags, pagination info comes here 
    return orgApis.list ?: [];
};

function getApiOwnersOfOrg(string orgId, string orgHandler) returns table<ApiOwner> key(apiId) {
    prj:GraphqlClient projectAPIClient = check new(serviceUrl = "");
    table<ApiOwner> key(apiId) apiOwnerInfo;
    int orgIdAsNumber = check int:fromString(orgId);
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

function getApiOwner(string orgId, string orgHandler, string apiVersionId) returns ApiOwner|error {
    table<ApiOwner> key(apiId) apiOwnersOfOrg = getApiOwnersOfOrg(orgId, orgHandler);
    return apiOwnersOfOrg.get(apiVersionId);
}

function populateApis(dp:APIInfo [] depPortalApis, table<ApiOwner> key(apiId) apiOwnerInfo, string sortingParam) returns Api[]|error {
    
    Api[] apisToReturn = [];

    //get unique APIs 
    string[] apiNames = from dp:APIInfo api in depPortalApis select api.name;
    string[] uniqueApiNames = removeDuplicates(apiNames);

    foreach string apiName in uniqueApiNames {
        ApiVersionInfo[] versionsOfApi = getAllVersionMetaInfo(depPortalApis, apiName);
        ApiVersionInfo latestVersionOfApi = versionsOfApi[0];
        dp:API devPortalApi = check getDevPortalApi(latestVersionOfApi.apiId);
        ApiOwner apiOwner = apiOwnerInfo.get(latestVersionOfApi.apiId);
        Api api = populateApi(devPortalApi, apiOwner, versionsOfApi);
        apisToReturn.push(api);
    }

    Api[] sortedApis =  sortApis(apisToReturn, sortingParam);

    return sortedApis;
};

function sortApis(Api[] apis, string sortingParam) returns Api[] {
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
    }
    
}

function populateApi(dp:API dpApi, ApiOwner apiOwner, ApiVersionInfo[]? versionsOfApi) returns Api {

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
}

//only returns HTTPS and WSS URLs
function extractApiEndpoints(dp:API dpApi) returns APIEndpoint[] {
    APIEndpoint[] apiEndpoints;
    dp:API_endpointURLs[]? endpointURLs = dpApi.endpointURLs;
    if endpointURLs is dp:API_endpointURLs[] {
        foreach dp:API_endpointURLs endpoint in endpointURLs {
            string environmentName = endpoint.environmentDisplayName ?: "";
            string endpointURL;
            string apiType = dpApi.'type ?: "";
            dp:API_URLs? uRLs = endpoint.URLs;
            if uRLs is dp:API_URLs {
                if (apiType == WS) {
                    endpointURL = uRLs.wss ?: "";
                } else {
                    endpointURL = uRLs.https ?: "";
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

function getApiScopeNames(dp:API dpApi) returns string[] {
    dp:ScopeInfo[]? scopes = dpApi.scopes;
    if scopes is dp:ScopeInfo[] {
        string [] scopeNames = from dp:ScopeInfo scope in scopes
                                select scope.name ?: "";
        return scopeNames;
    } else {
        return [];
    }
}

function getBusinessPlans(dp:API dpApi) returns string[] {
    dp:API_tiers[]? apiTiers = dpApi.tiers;
    if apiTiers is dp:API_tiers[] {
        string[] apiTierNames = from dp:API_tiers tier in apiTiers
                                select tier.tierName ?: "";
        return apiTierNames;
    }
}

function isPublicApi(dp:API dpApi) returns boolean {
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
}

function getAllVersionMetaInfo(dp:APIInfo[] devPortalApis, string uniqueApiName) returns ApiVersionInfo[] {
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

function getAllApiDocuments(string apiId) returns Document[]|error {
    dp:Client devPotalClient = createDevPotalClient();
    dp:DocumentList documentInfo = check devPotalClient->/apis/[apiId]/documents('limit=200);
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

function getApiDocumentContent(string apiId , string documentId) returns http:Response|error {
    dp:Client devPotalClient = createDevPotalClient();
    return devPotalClient->/apis/[apiId]/documents/[documentId]/content();
}

function getApisofProject(string projectId, Api[] allApisOfOrg) returns Api[] {
    return from Api api in allApisOfOrg
        where api.owner.projectId == projectId
        order by api.name
        select api;
}

function getApisOfOtherProjects(string projectId, Api[] allApisOfOrg) returns Api[] {
    return from Api api in allApisOfOrg
        where api.owner.projectId != projectId
        order by api.name
        select api;
}

function getAllKeywords() returns KeywordInfo[]|error {     //how to limit to a org
    dp:Client devPotalClient = createDevPotalClient();
    dp:TagList apiTagInfo = check devPotalClient ->/tags('limit = 100);
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

function getDPOpenApi(string apiId) returns string|error {
    dp:Client devPotalClient = createDevPotalClient();
    string swaggerContent = check devPotalClient->/apis/[apiId]/swagger();
    return swaggerContent;
}

function getDPSdl(string apiId) returns string|error {
    dp:Client devPotalClient = createDevPotalClient();
    string graphqlSdlContent = check devPotalClient->/apis/[apiId]/graphql\-schema();
    return graphqlSdlContent;
}

function getDPWsdl(string apiId) returns string|error {
    dp:Client devPotalClient = createDevPotalClient();
    http:Response responseWithWsdl = check devPotalClient->/apis/[apiId]/wsdl();
    string wsdlContent = check responseWithWsdl.getTextPayload();
    return wsdlContent;
}

function getAppApplications() returns ApiApp[]|error {    //how to limit to org
    dp:Client devPotalClient = createDevPotalClient();
    dp:ApplicationList applicationInfo = check devPotalClient->/applications();
    dp:ApplicationInfo[]? dpApps = applicationInfo.list;
    if dpApps is dp:ApplicationInfo[] {
        ApiApp[] apiApps = from dp:ApplicationInfo dpApp in dpApps
                            select {
                                id: dpApp.applicationId ?: "", 
                                name: dpApp.name ?: "",
                                description: dpApp.description,
                                environmentId: "",          //TODO:check
                                subscribedApis: check getSubscriptionInfo(dpApp.applicationId ?: ""), 
                                scopes: extractScopes(dpApp)
                            };                            
        return apiApps;
    }
}

function extractScopes(dp:ApplicationInfo appInfo) returns string[]? {
    record {|anydata...;|}? attributes = appInfo.attributes;
    if attributes is map<any> {
       string[] scopes = <string[]>attributes.get("scopes"); 
       return scopes;
    } 

}

function getSubscriptionInfo(string applicationId) returns string[]|error {
    dp:Client devPotalClient = createDevPotalClient();
    string[] subscribedApis;
    dp:SubscriptionList subscriptionResponse = check devPotalClient->/subscriptions(applicationId);
    dp:Subscription[]? subscriptions = subscriptionResponse.list;
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

function createApplication(CreatableApiApp appInfo) returns ApiApp|ApiWorkflowResponse|error {
    dp:Client devPotalClient = createDevPotalClient();
    dp:Application devPortalApp = {
        name: appInfo.name,
        throttlingPolicy: appInfo.throttlingPolicy,   
        description: appInfo.description
    };
    dp:WorkflowResponse|dp:Application appCreationResult = check devPotalClient->/applications.post(devPortalApp);
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
    }
}

function createSubscription(SubscriptionRequest subscriptionRequest) returns ApiWorkflowResponse|ApiSubscription|error {
    dp:Client devPotalClient = createDevPotalClient();
    dp:Subscription dpSub = {
        applicationId: subscriptionRequest.apiAppId,
        throttlingPolicy: subscriptionRequest.throttlingPolicy,   //Should be one of businessPlan names of the API being subscribed to
        apiId: subscriptionRequest.apiId     //TODO: check why this is not mandatory in generated code
    };
    dp:WorkflowResponse|dp:Subscription subsriptionResult = check devPotalClient->/subscriptions.post(dpSub);
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
    }
}

function getApiThrottlingPolicyWithMaxLimits(Api api) returns string {
    string[] businessPlans = api.throttlingPolicies;
    BusinessPlansThrottling[] availablePlans = [Bronze, Silver, Gold, Unlimited];
    string maxPlan;
    if(businessPlans.filter(e => e == Unlimited).length() > 0) {
        maxPlan = Unlimited;
    } else if (businessPlans.filter(e => e == Gold).length() > 0) {
        maxPlan = Gold;
    } else if (businessPlans.filter(e => e == Silver).length() > 0) {
        maxPlan = Silver;
    } else if(businessPlans.filter(e => e == Bronze).length() > 0) {
        maxPlan = Bronze;
    }
    return maxPlan;
}



function rateApiVersion(RatingRequest ratingRequest) returns Rating|error {
    dp:Client devPotalClient = createDevPotalClient();
    dp:Rating dpRating = {
        apiId: ratingRequest.apiId,
        rating: ratingRequest.rating,
        ratedBy: ratingRequest.ratedBy
    };
    dp:Rating ratingResponse = check devPotalClient->/apis/[ratingRequest.apiId]/user\-rating.put(dpRating);
    Rating apiRating =  {
        ratingId: ratingResponse.ratingId,
        apiId: ratingResponse.apiId ?: "", 
        ratedBy: ratingResponse.ratedBy, 
        rating: ratingResponse.rating
    };
    return apiRating;
}

function getApiThubnail(string apiId) returns http:Response|error {
    dp:Client devPotalClient = createDevPotalClient();
    return devPotalClient->/apis/[apiId]/thumbnail();
}

function removeDuplicates(string[] strArr) returns string[] {
    _ = strArr.some(function(string s) returns boolean {
        int? firstIndex = strArr.indexOf(s);
        int? lastIndex = strArr.lastIndexOf(s);
        if (firstIndex != lastIndex) {
            _ = strArr.remove(<int>lastIndex);
        }

        // Returning true, if the end of the array is reached.
        if (firstIndex == (strArr.length() - 1)) {
            return true;
        }
        return false;
    });

    return strArr;
}







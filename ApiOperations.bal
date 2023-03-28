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
                    order by e.createdDate ascending    //check
                    select e;
            } else {
                return from var e in apis
                    order by e.createdDate descending   //check
                    select e;
            }
        }
    }
    
}

function populateApi(dp:API devPortalApi, ApiOwner apiOwner, ApiVersionInfo[]? versionsOfApi) returns Api {
    
    Api api = {
        isPublic: false, //TODO find
        id: devPortalApi.name,
        name: devPortalApi.name,
        resourceType: ApiType,
        owner: {orgId: apiOwner.orgId, orgName: apiOwner.orgName, projectName: apiOwner.projectName, projectId: apiOwner.projectId, componentName: apiOwner.componentName, componentId: apiOwner.componentName},
        iconPath: devPortalApi.thumbnailUri ?: "",
        apiId: devPortalApi.id,
        'version: devPortalApi.'version,
        createdDate: devPortalApi.createdTime, //TODO : update to created time
        isPreRelease: false, //TODO find
        description: devPortalApi.description,
        usageStats: {usageCount: 0, rating: devPortalApi.avgRating},
        keywords: [], //TODO find
        documentation: devPortalApi.description, //TODO: find
        Idl: {idlLocation: "", idlType: OpenAPI}, //TODO: find
        endpoints: [], //TODO : find
        apiVersions: versionsOfApi
    };
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







// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/io;

# Service exposing all Ballerina Marketplace related operations. 
service /registry on new http:Listener(9000) {

    function init() returns error? {
        
    };
     
    //TODO: FIX Pagination

    //TODO: Use strands to parallelize calls to featch different types of apis

    //TODO; think abt scopes, open api gen by service needs to mention scopes needed

    # Search for any Api (within components, external or public) in Choreo.
    #
    # + authHeader - Header with valid token  
    # + projectId - Id of the project you need to fetch apis from within. You must specify this if includeWithinProjectApis = true  
    # + 'limit - Max number of apis to contain in the response 
    # + offset - Pagination offset  
    # + sort - Sorting parameters of the search [name, rating, project, createdDate] 
    # + query - Search query. If not specified, all apis will be featched  
    # + keywords - Keywords of apis to filter the search  
    # + includeWithinProjectApis - Whether to include apis within the specified project, that are not exposed externally.  
    # + includeInternallyExposedApis - Whether to include apis exposed from Choreo  
    # + includePublicApis - Whether to include public apis (Choreo maintianed SaaS apis)
    # + return - List of Apis. Each Api will contain details of its latest version
    isolated resource function get apis(@http:Header {name: "x-jwt-assertion"} string authHeader, string ? projectId = (), int 'limit = 20, 
        int offset = 0, string sort = "project,ASC", string? query = (), string[]? keywords = (), 
        boolean includeWithinProjectApis = false, 
        boolean includeInternallyExposedApis = false,
        boolean includePublicApis = false
        ) returns ApiCard[]|error|ErrResponse {

        OrganizationInfo orgInfo = check validateAndObtainOrgInfo(authHeader);
        string orgId = orgInfo.uuid;
        string orgHandler = orgInfo.'handle;
        string idpId = check getIdpId(authHeader);
        ApiCard[] apiCollection = [];
        if includeWithinProjectApis {
            //TODO: if project id not there, bad request
            if projectId == () {
                http:BadRequest httpErr = {body:  {
                    "error": "projectId query parameter value not present. Set this to id of your Choreo project. "
                }};
                return httpErr;
            } else {
                ApiCard[] withinProjectApis = check searchApisWithinProject(orgId, orgHandler, projectId, 'limit, offset, query, keywords);
                apiCollection.push(...withinProjectApis);
            }
        }   
        if includeInternallyExposedApis {
            ApiCard[] internallyExposedApis = check searchDevPortalApis(orgId, orgHandler, idpId, 'limit, offset, sort, query, keywords);
            apiCollection.push(...internallyExposedApis);
        }
        if includePublicApis {
            ApiCard[] publicApis = check searchPublicApis('limit, offset, query, keywords);
            apiCollection.push(...publicApis);
        }

        ApiCard[] apisToReturn = check sortApis(apiCollection, sort);
        return apisToReturn;
    }

    # Search for project scoped APIs discoverable within a specified project.
    #
    # + projectId - Id of the project  
    # + authHeader - Header with valid token  
    # + 'limit - Max number of apis to contain in the response 
    # + offset - Pagination offset  
    # + sort - Sorting parameters  
    # + query - Search query. If not specified, all apis will be featched  
    # + keywords - Keywords of apis to filter the search
    # + return - List of Apis. Each Api will contain details of its latest version
    isolated resource function get apis/'internal/projectScope/[string projectId](@http:Header {name: "x-jwt-assertion"} string authHeader, int 'limit = 20, int offset = 0, string sort = "project,ASC", string? query = (), string[]? keywords = ()) returns ApiCard[]|error {
        OrganizationInfo orgInfo = check validateAndObtainOrgInfo(authHeader);
        return check searchApisWithinProject(orgInfo.uuid, orgInfo.'handle, projectId, 'limit, offset, query, keywords);
    }
    
    # Search for organization scoped APIs in Choreo. This will only return APIs published to dev portal.
    #
    # + authHeader - Header with valid token  
    # + 'limit - Max number of apis to contain in the response 
    # + offset -  Pagination offset
    # + sort - Sorting parameters  
    # + query - Search query. If not specified, all apis will be featched  
    # + keywords - List of keywords to filter the search. Search will include apis having one or more of the keywords specified.
    # + return - List of org level apis matches with search
    resource function get apis/'internal/orgScope(@http:Header {name: "x-jwt-assertion"} string authHeader, int 'limit = 20, int offset = 0, string sort = "project,ASC", string? query = (), string[]? keywords = ()) returns ApiCard[]|error {
        io:println("api hit");
        OrganizationInfo orgInfo = check validateAndObtainOrgInfo(authHeader);
        string idpId = check getIdpId(authHeader);
        return searchDevPortalApis(orgId = orgInfo.uuid, orgHandler = orgInfo.'handle, idpId = idpId,
                 'limit = 'limit, offset = offset, sort = sort, query = query, keywords = keywords);
    }


    # Search for public scoped (external) APIs. Pulic Apis include SaaS APIs maintained by Choreo.
    #
    # + authHeader - Header with valid token  
    # + 'limit - Max number of apis to contain in the response 
    # + offset - Pagination offset
    # + sort - Sorting parameters
    # + query - Search query. If not specified, all apis will be featched 
    # + keywords - List of keywords to filter the search. Search will include apis having one or more of the keywords specified.
    # + return - List of org level apis matches with search
    isolated resource function get apis/publicScope(@http:Header {name: "x-jwt-assertion"} string authHeader, int 'limit = 20, int offset = 0, string sort = "name,ASC", string? query = (), string[]? keywords = ()) returns ApiCard[]|error {
        OrganizationInfo _ = check validateAndObtainOrgInfo(authHeader);
        return check searchPublicApis('limit, offset, query, keywords);
    }

    # Get popular APIs.
    #
    # + authHeader - Header with valid token  
    # + maxCount - Max number of Apis to return
    # + return - List of popular APIs
    isolated resource function get apis/popular(@http:Header {name: "x-jwt-assertion"} string authHeader, int maxCount) returns ApiCard[]|error {  //TODO: consider 3 popular for 3 categories
        OrganizationInfo orgInfo = check validateAndObtainOrgInfo(authHeader);
        string idpId = check getIdpId(authHeader);
        return searchDevPortalApis(orgId = orgInfo.uuid, orgHandler = orgInfo.'handle, idpId = idpId, 'limit = maxCount, offset = 0, sort = "rating, DSC");
    };

    # Get specific API by Id.
    #
    # + apiId - Id of the api  
    # + authHeader - Header with valid token  
    # + return - Api details with requested Id or error if unsuccessful. This would be a particular version of an API
    isolated resource function get apis/[string apiId](@http:Header {name: "x-jwt-assertion"} string authHeader) returns Api|error {
        OrganizationInfo orgInfo = check validateAndObtainOrgInfo(authHeader);
        string idpId = check getIdpId(authHeader);
        return getApibyId(orgInfo.uuid, orgInfo.'handle, idpId, apiId);
    }

    # Search for keywords of resources in the marketplace.  //TODO: handle getting keywords of a specific project
    #
    # + authHeader - Header with valid token
    # + projectId - Id of the Choreo project within which keyword search needs to operate
    # + return - List of keywords matching search or error if unsuccessful
    isolated resource function get apis/keywords(@http:Header {name: "x-jwt-assertion"} string authHeader, string? projectId) returns KeywordInfo[]|error {
        string orgId = check validateAndObtainOrgId(authHeader);
        return getAllKeywords(orgId);
    }

    # Rate a given api
    #
    # + rateRequest - ResourceRateRequest payload 
    # + return - API rating or error if unsuccessful
    isolated resource function post apis/rating(@http:Header {name: "x-jwt-assertion"} string authHeader, @http:Payload RatingRequest rateRequest) returns Rating|error {
        string orgId = check validateAndObtainOrgId(authHeader);
        return rateApiVersion(orgId, rateRequest);
    }

    # Get the thumbnail of an API.
    #
    # + apiId - Id of the api
    # + authHeader - Header with valid token
    # + return - Thumbnail of the API or error if unsuccessful.
    isolated resource function get apis/[string apiId]/thumbnail(@http:Header {name: "x-jwt-assertion"} string authHeader) returns http:Response|error {  //TODO:when loading search results this might be inefficient
        string orgId = check validateAndObtainOrgId(authHeader);
        return getApiThubnail(orgId, apiId);
    }

    # Get the all document information attached to an API.
    #
    # + apiId - Id of the API version
    # + authHeader - Header with valid token
    # + return - List of document information attached to the API version or error if unsuccessful.
    isolated resource function get apis/[string apiId]/documents(@http:Header {name: "x-jwt-assertion"} string authHeader) returns Document[]|error {
        string orgId = check validateAndObtainOrgId(authHeader);
        return getAllApiDocuments( orgId,apiId);
    }

//TODO: this is devportal specific.
    # Get the content of a document attached to an API. 
    #
    # + apiId - Id of the API version
    # + documentId - Id of the document
    # + authHeader - Header with valid token
    # + return - Content of the document or error if unsuccessful.
    isolated resource function get apis/[string apiId]/documents/[string documentId]/content(@http:Header {name: "x-jwt-assertion"} string authHeader) returns http:Response|error {   
        string orgId = check validateAndObtainOrgId(authHeader);
        return getApiDocumentContent(orgId, apiId, documentId);
    }

    # Get the Interface definition (with content) of an API.
    #
    # + apiId - Id of the API version
    # + authHeader - Header with valid token
    # + apiType - Type of the API. Possible values are HTTP, GRAPHQL, ASYNC, SOAP
    # + return - Interface definition of the API or error if unsuccessful.
    isolated resource function get apis/[string apiId]/idl(@http:Header {name: "x-jwt-assertion"} string authHeader, ApiTypes apiType) returns IDL|error {   //Depending on api type the way to receive IDL differs
        string orgId = check validateAndObtainOrgId(authHeader);
        match apiType {   //is associated with dpApi.'type
            HTTP => {
                IDL idl = {
                    idlType: OpenAPI,
                    content: check getDPOpenApi(orgId, apiId)
                };
                return idl;
            }
            GRAPHQL => {
                IDL idl = {
                    idlType: GraphQL,
                    content: check getDPSdl(orgId, apiId)
                };
                return idl;
            }
            ASYNC => {      //TODO;
                IDL idl = {
                    idlType: AsyncAPI,
                    content: ""
                };
                return idl; 
            }
            SOAP => {
                IDL idl = {
                    idlType: WSDL,
                    content: check getDPWsdl(orgId, apiId)
                };
                return idl;
            }
            _ => {
                return error("IDL not found for API id = " + apiId);
            }
        }
    } 

    # Get APIM applications visible to the user within the Choreo organization.   //TODO:userId and environmentId are not used
    #
    # + authHeader - Header with valid token
    # + userId - Id of the user  
    # + environmentId - Id of the environment
    # + return - List of ApiApp details
    isolated resource function get apis/apiApps(@http:Header {name: "x-jwt-assertion"} string authHeader, string userId, string environmentId) returns ApiApp[]|error {
        string orgId = check validateAndObtainOrgId(authHeader);
        return getAppApplications(orgId);
    }

    # Create an APIM application.
    #
    # + authHeader - Header with valid token
    # + apiApp - Input details of the APIM app to create
    # + return - Created APIM app or error
    isolated resource function post apis/apiApps(@http:Header {name: "x-jwt-assertion"} string authHeader, @http:Payload CreatableApiApp apiApp) returns ApiApp|ApiWorkflowResponse|error {
        string orgId = check validateAndObtainOrgId(authHeader);
        return createApplication(apiApp, orgId);
    }

    # Subscribe APIM application to an API
    #
    # + authHeader - Header with valid token
    # + subcriptionRequest - SubscriptionRequest input details
    # + return - Created subscription details or triggered workflow details or error if unsuccessful
    isolated resource function post apis/subscriptions(@http:Header {name: "x-jwt-assertion"} string authHeader, @http:Payload SubscriptionRequest subcriptionRequest) returns ApiWorkflowResponse|ApiSubscription|error? {
        string orgId = check validateAndObtainOrgId(authHeader);
        ApiWorkflowResponse|ApiSubscription subscriptionResponse = check createSubscription(orgId, subcriptionRequest);
        return subscriptionResponse;
    }

}

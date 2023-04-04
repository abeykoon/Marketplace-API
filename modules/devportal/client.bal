import ballerina/http;
import ballerina/mime;

# This document specifies a **RESTful API** for WSO2 **API Manager** - **Developer Portal**.
# Please see [full OpenAPI Specification](https://raw.githubusercontent.com/wso2/carbon-apimgt/master/components/apimgt/org.wso2.carbon.apimgt.rest.api.store.v1/src/main/resources/devportal-api.yaml) of the API which is written using [OAS 3.0](http://swagger.io/) specification.
# 
# # Authentication
# The Developer Portal REST API is protected using OAuth2 and access control is achieved through scopes. Before you start invoking
# the API, you need to obtain an access token with the required scopes. This guide will walk you through the steps
# that you will need to follow to obtain an access token.
# First you need to obtain the consumer key/secret key pair by calling the dynamic client registration (DCR) endpoint. You can add your preferred grant types
# in the payload. A Sample payload is shown below.
# ```
#   {
#   "callbackUrl":"www.google.lk",
#   "clientName":"rest_api_devportal",
#   "owner":"admin",
#   "grantType":"client_credentials password refresh_token",
#   "saasApp":true
#   }
# ```
# Create a file (payload.json) with the above sample payload, and use the cURL shown below to invoke the DCR endpoint. Authorization header of this should contain the
# base64 encoded admin username and password.
# **Format of the request**
# ```
#   curl -X POST -H "Authorization: Basic Base64(admin_username:admin_password)" -H "Content-Type: application/json"
#   \ -d @payload.json https://<host>:<servlet_port>/client-registration/v0.17/register
# ```
# **Sample request**
# ```
#   curl -X POST -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: application/json"
#   \ -d @payload.json https://localhost:9443/client-registration/v0.17/register
# ```
# Following is a sample response after invoking the above curl.
# ```
# {
# "clientId": "fOCi4vNJ59PpHucC2CAYfYuADdMa",
# "clientName": "rest_api_devportal",
# "callBackURL": "www.google.lk",
# "clientSecret": "a4FwHlq0iCIKVs2MPIIDnepZnYMa",
# "isSaasApplication": true,
# "appOwner": "admin",
# "jsonString": "{\"grant_types\":\"client_credentials password refresh_token\",\"redirect_uris\":\"www.google.lk\",\"client_name\":\"rest_api_devportal\"}",
# "jsonAppAttribute": "{}",
# "tokenType": null
# }
# ```
# Next you must use the above client id and secret to obtain the access token.
# We will be using the password grant type for this, you can use any grant type you desire.
# You also need to add the proper **scope** when getting the access token. All possible scopes for devportal REST API can be viewed in **OAuth2 Security** section
# of this document and scope for each resource is given in **authorization** section of resource documentation.
# Following is the format of the request if you are using the password grant type.
# ```
# curl -k -d "grant_type=password&username=<admin_username>&password=<admin_password>&scope=<scopes separated by space>"
# \ -H "Authorization: Basic base64(cliet_id:client_secret)"
# \ https://<host>:<servlet_port>/oauth2/token
# ```
# **Sample request**
# ```
# curl https://localhost:9443/oauth2/token -k \
# -H "Authorization: Basic Zk9DaTR2Tko1OVBwSHVjQzJDQVlmWXVBRGRNYTphNEZ3SGxxMGlDSUtWczJNUElJRG5lcFpuWU1h" \
# -d "grant_type=password&username=admin&password=admin&scope=apim:subscribe apim:api_key"
# ```
# Shown below is a sample response to the above request.
# ```
# {
# "access_token": "e79bda48-3406-3178-acce-f6e4dbdcbb12",
# "refresh_token": "a757795d-e69f-38b8-bd85-9aded677a97c",
# "scope": "apim:subscribe apim:api_key",
# "token_type": "Bearer",
# "expires_in": 3600
# }
# ```
# Now you have a valid access token, which you can use to invoke an API.
# Navigate through the API descriptions to find the required API, obtain an access token as described above and invoke the API with the authentication header.
# If you use a different authentication mechanism, this process may change.
# 
# # Try out in Postman
# If you want to try-out the embedded postman collection with "Run in Postman" option, please follow the guidelines listed below.
# * All of the OAuth2 secured endpoints have been configured with an Authorization Bearer header with a parameterized access token. Before invoking any REST API resource make sure you run the `Register DCR Application` and `Generate Access Token` requests to fetch an access token with all required scopes.
# * Make sure you have an API Manager instance up and running.
# * Update the `basepath` parameter to match the hostname and port of the APIM instance.
# 
# [![Run in Postman](https://run.pstmn.io/button.svg)](https://god.gw.postman.com/run-collection/17491134-b8760354-b3c3-4019-b60a-e813cba8d7c0)
public isolated client class Client {
    final http:Client clientEp;
    # Gets invoked to initialize the `connector`.
    #
    # + config - The configurations to be used when initializing the `connector` 
    # + serviceUrl - URL of the target service 
    # + return - An error if connector initialization failed 
    public isolated function init(ConnectionConfig config, string serviceUrl = "https://apis.wso2.com/api/am/devportal/v2") returns error? {
        http:ClientConfiguration httpClientConfig = {auth: config.auth, httpVersion: config.httpVersion, timeout: config.timeout, forwarded: config.forwarded, poolConfig: config.poolConfig, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, validation: config.validation};
        do {
            if config.http1Settings is ClientHttp1Settings {
                ClientHttp1Settings settings = check config.http1Settings.ensureType(ClientHttp1Settings);
                httpClientConfig.http1Settings = {...settings};
            }
            if config.http2Settings is http:ClientHttp2Settings {
                httpClientConfig.http2Settings = check config.http2Settings.ensureType(http:ClientHttp2Settings);
            }
            if config.cache is http:CacheConfig {
                httpClientConfig.cache = check config.cache.ensureType(http:CacheConfig);
            }
            if config.responseLimits is http:ResponseLimitConfigs {
                httpClientConfig.responseLimits = check config.responseLimits.ensureType(http:ResponseLimitConfigs);
            }
            if config.secureSocket is http:ClientSecureSocket {
                httpClientConfig.secureSocket = check config.secureSocket.ensureType(http:ClientSecureSocket);
            }
            if config.proxy is http:ProxyConfig {
                httpClientConfig.proxy = check config.proxy.ensureType(http:ProxyConfig);
            }
        }
        http:Client httpEp = check new (serviceUrl, httpClientConfig);
        self.clientEp = httpEp;
        return;
    }
    # Retrieve/Search APIs
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + 'limit - Maximum size of resource array to return. 
    # + offset - Starting point within the complete list of items qualified. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + query - **Search condition**. You can search in attributes by using an **"<attribute>:"** modifier. Eg. "provider:wso2" will match an API if the provider of the API is exactly "wso2". Additionally you can use wildcards. Eg. "provider:wso2*" will match an API if the provider of the API starts with "wso2". Supported attribute modifiers are [**version, context, status, description, doc, provider, tag**] To search by API Properties provide the query in below format. **property_name:property_value** Eg. "environment:test" where environment is the property name and test is the propert value. If no advanced attribute modifier has been specified, search will match the given query string against API Name. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. List of qualifying APIs is returned. 
    resource isolated function get apis(string organizationId, int 'limit = 25, int offset = 0, string? xWso2Tenant = (), string? query = (), string? ifNoneMatch = ()) returns APIList|error {
        string resourcePath = string `/apis`;
        map<anydata> queryParam = {"organizationId": organizationId, "limit": 'limit, "offset": offset, "query": query};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        APIList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get Details of an API
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Requested API is returned 
    resource isolated function get apis/[string apiId](string organizationId, string? xWso2Tenant = (), string? ifNoneMatch = ()) returns API|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        API response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get Swagger Definition
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + environmentName - Name of the API gateway environment. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. Requested swagger document of the API is returned 
    resource isolated function get apis/[string apiId]/swagger(string organizationId, string? environmentName = (), string? ifNoneMatch = (), string? xWso2Tenant = ()) returns json|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/swagger`;
        map<anydata> queryParam = {"organizationId": organizationId, "environmentName": environmentName};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-None-Match": ifNoneMatch, "X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        json response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get GraphQL Definition
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. Requested swagger document of the API is returned 
    resource isolated function get apis/[string apiId]/'graphql\-schema(string organizationId, string? ifNoneMatch = (), string? xWso2Tenant = ()) returns json|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/graphql-schema`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-None-Match": ifNoneMatch, "X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        json response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Generate a SDK for an API
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + language - Programming language of the SDK that is required. Languages supported by default are **Java**, **Javascript**, **Android** and **JMeter**. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. SDK generated successfully. 
    resource isolated function get apis/[string apiId]/sdks/[string language](string organizationId, string? xWso2Tenant = ()) returns string|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/sdks/${getEncodedUri(language)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        string response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get API WSDL definition
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + environmentName - Name of the API gateway environment. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. Requested WSDL document of the API is returned 
    resource isolated function get apis/[string apiId]/wsdl(string organizationId, string? environmentName = (), string? ifNoneMatch = (), string? xWso2Tenant = ()) returns http:Response|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/wsdl`;
        map<anydata> queryParam = {"organizationId": organizationId, "environmentName": environmentName};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-None-Match": ifNoneMatch, "X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Response response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get a List of Documents of an API
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + 'limit - Maximum size of resource array to return. 
    # + offset - Starting point within the complete list of items qualified. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Document list is returned. 
    resource isolated function get apis/[string apiId]/documents(string organizationId, int 'limit = 25, int offset = 0, string? xWso2Tenant = (), string? ifNoneMatch = ()) returns DocumentList|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/documents`;
        map<anydata> queryParam = {"organizationId": organizationId, "limit": 'limit, "offset": offset};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        DocumentList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get a Document of an API
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + documentId - Document Identifier 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Document returned. 
    resource isolated function get apis/[string apiId]/documents/[string documentId](string organizationId, string? xWso2Tenant = (), string? ifNoneMatch = ()) returns Document|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/documents/${getEncodedUri(documentId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        Document response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get the Content of an API Document
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + documentId - Document Identifier 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. File or inline content returned. 
    resource isolated function get apis/[string apiId]/documents/[string documentId]/content(string organizationId, string? xWso2Tenant = (), string? ifNoneMatch = ()) returns http:Response|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/documents/${getEncodedUri(documentId)}/content`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Response response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get Thumbnail Image
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Thumbnail image returned 
    resource isolated function get apis/[string apiId]/thumbnail(string organizationId, string? xWso2Tenant = (), string? ifNoneMatch = ()) returns http:Response|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/thumbnail`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Response response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Retrieve API Ratings
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + 'limit - Maximum size of resource array to return. 
    # + offset - Starting point within the complete list of items qualified. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. Rating list returned. 
    resource isolated function get apis/[string apiId]/ratings(string organizationId, int 'limit = 25, int offset = 0, string? xWso2Tenant = ()) returns RatingList|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/ratings`;
        map<anydata> queryParam = {"organizationId": organizationId, "limit": 'limit, "offset": offset};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        RatingList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Retrieve API Rating of User
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Rating returned. 
    resource isolated function get apis/[string apiId]/'user\-rating(string organizationId, string? xWso2Tenant = (), string? ifNoneMatch = ()) returns Rating|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/user-rating`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        Rating response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Add or Update Logged in User's Rating for an API
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + payload - Rating object that should to be added 
    # + return - OK. Successful response with the newly created or updated object as entity in the body. 
    resource isolated function put apis/[string apiId]/'user\-rating(string organizationId, Rating payload, string? xWso2Tenant = ()) returns Rating|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/user-rating`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        Rating response = check self.clientEp->put(resourcePath, request, httpHeaders);
        return response;
    }
    # Delete User API Rating
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + ifMatch - Validator for conditional requests; based on ETag. 
    # + return - OK. Resource successfully deleted. 
    resource isolated function delete apis/[string apiId]/'user\-rating(string organizationId, string? xWso2Tenant = (), string? ifMatch = ()) returns http:Response|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/user-rating`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-Match": ifMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Response response = check self.clientEp->delete(resourcePath, headers = httpHeaders);
        return response;
    }
    # Retrieve API Comments
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + 'limit - Maximum size of resource array to return. 
    # + offset - Starting point within the complete list of items qualified. 
    # + includeCommenterInfo - Whether we need to display commentor details. 
    # + return - OK. Comments list is returned. 
    resource isolated function get apis/[string apiId]/comments(string organizationId, string? xWso2Tenant = (), int 'limit = 25, int offset = 0, boolean includeCommenterInfo = false) returns CommentList|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/comments`;
        map<anydata> queryParam = {"organizationId": organizationId, "limit": 'limit, "offset": offset, "includeCommenterInfo": includeCommenterInfo};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        CommentList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Add an API Comment
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + replyTo - ID of the perent comment. 
    # + payload - Comment object that should to be added 
    # + return - Created. Successful response with the newly created object as entity in the body. Location header contains URL of newly created entity. 
    resource isolated function post apis/[string apiId]/comments(string organizationId, PostRequestBody payload, string? replyTo = ()) returns Comment|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/comments`;
        map<anydata> queryParam = {"organizationId": organizationId, "replyTo": replyTo};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        Comment response = check self.clientEp->post(resourcePath, request);
        return response;
    }
    # Get Details of an API Comment
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + commentId - Comment Id 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + includeCommenterInfo - Whether we need to display commentor details. 
    # + replyLimit - Maximum size of replies array to return. 
    # + replyOffset - Starting point within the complete list of replies. 
    # + return - OK. Comment returned. 
    resource isolated function get apis/[string apiId]/comments/[string commentId](string organizationId, string? xWso2Tenant = (), string? ifNoneMatch = (), boolean includeCommenterInfo = false, int replyLimit = 25, int replyOffset = 0) returns Comment|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/comments/${getEncodedUri(commentId)}`;
        map<anydata> queryParam = {"organizationId": organizationId, "includeCommenterInfo": includeCommenterInfo, "replyLimit": replyLimit, "replyOffset": replyOffset};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        Comment response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Delete an API Comment
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + commentId - Comment Id 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + ifMatch - Validator for conditional requests; based on ETag. 
    # + return - OK. Resource successfully deleted. 
    resource isolated function delete apis/[string apiId]/comments/[string commentId](string organizationId, string? ifMatch = ()) returns http:Response|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/comments/${getEncodedUri(commentId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-Match": ifMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Response response = check self.clientEp->delete(resourcePath, headers = httpHeaders);
        return response;
    }
    # Edit a comment
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + commentId - Comment Id 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + payload - Comment object that should to be updated 
    # + return - OK. Comment updated. 
    resource isolated function patch apis/[string apiId]/comments/[string commentId](string organizationId, PatchRequestBody payload) returns Comment|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/comments/${getEncodedUri(commentId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        Comment response = check self.clientEp->patch(resourcePath, request);
        return response;
    }
    # Get replies of a comment
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + commentId - Comment Id 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + 'limit - Maximum size of resource array to return. 
    # + offset - Starting point within the complete list of items qualified. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + includeCommenterInfo - Whether we need to display commentor details. 
    # + return - OK. Comment returned. 
    resource isolated function get apis/[string apiId]/comments/[string commentId]/replies(string organizationId, string? xWso2Tenant = (), int 'limit = 25, int offset = 0, string? ifNoneMatch = (), boolean includeCommenterInfo = false) returns CommentList|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/comments/${getEncodedUri(commentId)}/replies`;
        map<anydata> queryParam = {"organizationId": organizationId, "limit": 'limit, "offset": offset, "includeCommenterInfo": includeCommenterInfo};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        CommentList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get a list of available topics for a given async API
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. Topic list returned. 
    resource isolated function get apis/[string apiId]/topics(string organizationId, string? xWso2Tenant = ()) returns TopicList|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/topics`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        TopicList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get Details of the Subscription Throttling Policies of an API
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Throttling Policy returned 
    resource isolated function get apis/[string apiId]/'subscription\-policies(string organizationId, string? xWso2Tenant = (), string? ifNoneMatch = ()) returns ThrottlingPolicy|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/subscription-policies`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        ThrottlingPolicy response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Retrieve/Search Applications
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + groupId - Application Group Id 
    # + query - **Search condition**. You can search for an application by specifying the name as "query" attribute. Eg. "app1" will match an application if the name is exactly "app1". Currently this does not support wildcards. Given name must exactly match the application name. 
    # + 'limit - Maximum size of resource array to return. 
    # + offset - Starting point within the complete list of items qualified. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Application list returned. 
    resource isolated function get applications(string organizationId, string? groupId = (), string? query = (), string? sortBy = (), string? sortOrder = (), int 'limit = 25, int offset = 0, string? ifNoneMatch = ()) returns ApplicationList|error {
        string resourcePath = string `/applications`;
        map<anydata> queryParam = {"organizationId": organizationId, "groupId": groupId, "query": query, "sortBy": sortBy, "sortOrder": sortOrder, "limit": 'limit, "offset": offset};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        ApplicationList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Create a New Application
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + payload - Application object that is to be created. 
    # + return - Created. Successful response with the newly created object as entity in the body. Location header contains URL of newly created entity. 
    resource isolated function post applications(string organizationId, Application payload) returns WorkflowResponse|Application|error {
        string resourcePath = string `/applications`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        WorkflowResponse|Application response = check self.clientEp->post(resourcePath, request);
        return response;
    }
    # Get Details of an Application
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. Application returned. 
    resource isolated function get applications/[string applicationId](string organizationId, string? ifNoneMatch = (), string? xWso2Tenant = ()) returns Application|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-None-Match": ifNoneMatch, "X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        Application response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Update an Application
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + ifMatch - Validator for conditional requests; based on ETag. 
    # + payload - Application object that needs to be updated 
    # + return - OK. Application updated. 
    resource isolated function put applications/[string applicationId](string organizationId, Application payload, string? ifMatch = ()) returns Application|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-Match": ifMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        Application response = check self.clientEp->put(resourcePath, request, httpHeaders);
        return response;
    }
    # Remove an Application
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + ifMatch - Validator for conditional requests; based on ETag. 
    # + return - OK. Resource successfully deleted. 
    resource isolated function delete applications/[string applicationId](string organizationId, string? ifMatch = ()) returns WorkflowResponse|error? {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-Match": ifMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        WorkflowResponse? response = check self.clientEp->delete(resourcePath, headers = httpHeaders);
        return response;
    }
    # Generate Application Keys
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + payload - Application key generation request object 
    # + return - OK. Keys are generated. 
    resource isolated function post applications/[string applicationId]/'generate\-keys(string organizationId, ApplicationKeyGenerateRequest payload, string? xWso2Tenant = ()) returns ApplicationKey|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/generate-keys`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        ApplicationKey response = check self.clientEp->post(resourcePath, request, httpHeaders);
        return response;
    }
    # Map Application Keys
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + payload - Application key mapping request object 
    # + return - OK. Keys are mapped. 
    resource isolated function post applications/[string applicationId]/'map\-keys(string organizationId, ApplicationKeyMappingRequest payload, string? xWso2Tenant = ()) returns ApplicationKey|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/map-keys`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        ApplicationKey response = check self.clientEp->post(resourcePath, request, httpHeaders);
        return response;
    }
    # Retrieve All Application Keys
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + return - OK. Keys are returned. 
    # 
    # # Deprecated
    @deprecated
    resource isolated function get applications/[string applicationId]/keys(string organizationId) returns ApplicationKeyList|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/keys`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        ApplicationKeyList response = check self.clientEp->get(resourcePath);
        return response;
    }
    # Get Key Details of a Given Type
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyType - **Application Key Type** standing for the type of the keys (i.e. Production or Sandbox). 
    # + groupId - Application Group Id 
    # + return - OK. Keys of given type are returned. 
    # 
    # # Deprecated
    @deprecated
    resource isolated function get applications/[string applicationId]/keys/[string keyType](string organizationId, string? groupId = ()) returns ApplicationKey|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/keys/${getEncodedUri(keyType)}`;
        map<anydata> queryParam = {"organizationId": organizationId, "groupId": groupId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        ApplicationKey response = check self.clientEp->get(resourcePath);
        return response;
    }
    # Update Grant Types and Callback Url of an Application
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyType - **Application Key Type** standing for the type of the keys (i.e. Production or Sandbox). 
    # + payload - Grant types/Callback URL update request object 
    # + return - Ok. Grant types or/and callback url is/are updated. 
    # 
    # # Deprecated
    @deprecated
    resource isolated function put applications/[string applicationId]/keys/[string keyType](string organizationId, ApplicationKey payload) returns ApplicationKey|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/keys/${getEncodedUri(keyType)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        ApplicationKey response = check self.clientEp->put(resourcePath, request);
        return response;
    }
    # Re-Generate Consumer Secret
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyType - **Application Key Type** standing for the type of the keys (i.e. Production or Sandbox). 
    # + return - OK. Keys are re generated. 
    # 
    # # Deprecated
    @deprecated
    resource isolated function post applications/[string applicationId]/keys/[string keyType]/'regenerate\-secret(string organizationId) returns ApplicationKeyReGenerateResponse|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/keys/${getEncodedUri(keyType)}/regenerate-secret`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        http:Request request = new;
        //TODO: Update the request as needed;
        ApplicationKeyReGenerateResponse response = check self.clientEp-> post(resourcePath, request);
        return response;
    }
    # Clean-Up Application Keys
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyType - **Application Key Type** standing for the type of the keys (i.e. Production or Sandbox). 
    # + ifMatch - Validator for conditional requests; based on ETag. 
    # + return - OK. Clean up is performed 
    # 
    # # Deprecated
    @deprecated
    resource isolated function post applications/[string applicationId]/keys/[string keyType]/'clean\-up(string organizationId, string? ifMatch = ()) returns http:Response|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/keys/${getEncodedUri(keyType)}/clean-up`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-Match": ifMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        //TODO: Update the request as needed;
        http:Response response = check self.clientEp->post(resourcePath, request, httpHeaders);
        return response;
    }
    # Generate Application Token
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyType - **Application Key Type** standing for the type of the keys (i.e. Production or Sandbox). 
    # + ifMatch - Validator for conditional requests; based on ETag. 
    # + payload - Application token generation request object 
    # + return - OK. Token is generated. 
    # 
    # # Deprecated
    @deprecated
    resource isolated function post applications/[string applicationId]/keys/[string keyType]/'generate\-token(string organizationId, ApplicationTokenGenerateRequest payload, string? ifMatch = ()) returns ApplicationToken|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/keys/${getEncodedUri(keyType)}/generate-token`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-Match": ifMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        ApplicationToken response = check self.clientEp->post(resourcePath, request, httpHeaders);
        return response;
    }
    # Retrieve All Application Keys
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. Keys are returned. 
    resource isolated function get applications/[string applicationId]/'oauth\-keys(string organizationId, string? xWso2Tenant = ()) returns ApplicationKeyList|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/oauth-keys`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        ApplicationKeyList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get Key Details of a Given Type
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyMappingId - OAuth Key Identifier consisting of the UUID of the Oauth Key Mapping. 
    # + groupId - Application Group Id 
    # + return - OK. Keys of given type are returned. 
    resource isolated function get applications/[string applicationId]/'oauth\-keys/[string keyMappingId](string organizationId, string? groupId = ()) returns ApplicationKey|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/oauth-keys/${getEncodedUri(keyMappingId)}`;
        map<anydata> queryParam = {"organizationId": organizationId, "groupId": groupId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        ApplicationKey response = check self.clientEp->get(resourcePath);
        return response;
    }
    # Update Grant Types and Callback URL of an Application
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyMappingId - OAuth Key Identifier consisting of the UUID of the Oauth Key Mapping. 
    # + payload - Grant types/Callback URL update request object 
    # + return - Ok. Grant types or/and callback url is/are updated. 
    resource isolated function put applications/[string applicationId]/'oauth\-keys/[string keyMappingId](string organizationId, ApplicationKey payload) returns ApplicationKey|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/oauth-keys/${getEncodedUri(keyMappingId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        ApplicationKey response = check self.clientEp->put(resourcePath, request);
        return response;
    }
    # Re-Generate Consumer Secret
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyMappingId - OAuth Key Identifier consisting of the UUID of the Oauth Key Mapping. 
    # + return - OK. Keys are re generated. 
    resource isolated function post applications/[string applicationId]/'oauth\-keys/[string keyMappingId]/'regenerate\-secret(string organizationId) returns ApplicationKeyReGenerateResponse|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/oauth-keys/${getEncodedUri(keyMappingId)}/regenerate-secret`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        http:Request request = new;
        //TODO: Update the request as needed;
        ApplicationKeyReGenerateResponse response = check self.clientEp-> post(resourcePath, request);
        return response;
    }
    # Clean-Up Application Keys
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyMappingId - OAuth Key Identifier consisting of the UUID of the Oauth Key Mapping. 
    # + ifMatch - Validator for conditional requests; based on ETag. 
    # + return - OK. Clean up is performed 
    resource isolated function post applications/[string applicationId]/'oauth\-keys/[string keyMappingId]/'clean\-up(string organizationId, string? ifMatch = ()) returns http:Response|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/oauth-keys/${getEncodedUri(keyMappingId)}/clean-up`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-Match": ifMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        //TODO: Update the request as needed;
        http:Response response = check self.clientEp->post(resourcePath, request, httpHeaders);
        return response;
    }
    # Generate Application Token
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyMappingId - OAuth Key Identifier consisting of the UUID of the Oauth Key Mapping. 
    # + ifMatch - Validator for conditional requests; based on ETag. 
    # + payload - Application token generation request object 
    # + return - OK. Token is generated. 
    resource isolated function post applications/[string applicationId]/'oauth\-keys/[string keyMappingId]/'generate\-token(string organizationId, ApplicationTokenGenerateRequest payload, string? ifMatch = ()) returns ApplicationToken|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/oauth-keys/${getEncodedUri(keyMappingId)}/generate-token`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-Match": ifMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        ApplicationToken response = check self.clientEp->post(resourcePath, request, httpHeaders);
        return response;
    }
    # Generate API Key
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyType - **Application Key Type** standing for the type of the keys (i.e. Production or Sandbox). 
    # + ifMatch - Validator for conditional requests; based on ETag. 
    # + payload - API Key generation request object 
    # + return - OK. apikey generated. 
    resource isolated function post applications/[string applicationId]/'api\-keys/[string keyType]/generate(string organizationId, APIKeyGenerateRequest payload, string? ifMatch = ()) returns APIKey|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/api-keys/${getEncodedUri(keyType)}/generate`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-Match": ifMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        APIKey response = check self.clientEp->post(resourcePath, request, httpHeaders);
        return response;
    }
    # Revoke API Key
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - Application Identifier consisting of the UUID of the Application. 
    # + keyType - **Application Key Type** standing for the type of the keys (i.e. Production or Sandbox). 
    # + ifMatch - Validator for conditional requests; based on ETag. 
    # + payload - API Key revoke request object 
    # + return - OK. apikey revoked successfully. 
    resource isolated function post applications/[string applicationId]/'api\-keys/[string keyType]/revoke(string organizationId, APIKeyRevokeRequest payload, string? ifMatch = ()) returns http:Response|error {
        string resourcePath = string `/applications/${getEncodedUri(applicationId)}/api-keys/${getEncodedUri(keyType)}/revoke`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-Match": ifMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        http:Response response = check self.clientEp->post(resourcePath, request, httpHeaders);
        return response;
    }
    # Export an Application
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + appName - Application Name 
    # + appOwner - Owner of the Application 
    # + withKeys - Export application keys 
    # + format - Format of output documents. Can be YAML or JSON. 
    # + return - OK. Export Successful. 
    resource isolated function get applications/export(string organizationId, string appName, string appOwner, boolean? withKeys = (), string? format = ()) returns string|error {
        string resourcePath = string `/applications/export`;
        map<anydata> queryParam = {"organizationId": organizationId, "appName": appName, "appOwner": appOwner, "withKeys": withKeys, "format": format};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        string response = check self.clientEp->get(resourcePath);
        return response;
    }
    # Import an Application
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + preserveOwner - Preserve Original Creator of the Application 
    # + skipSubscriptions - Skip importing Subscriptions of the Application 
    # + appOwner - Expected Owner of the Application in the Import Environment 
    # + skipApplicationKeys - Skip importing Keys of the Application 
    # + update - Update if application exists 
    # + return - OK. Successful response with the updated object information as entity in the body. 
    resource isolated function post applications/'import(string organizationId, Applications_import_body payload, boolean? preserveOwner = (), boolean? skipSubscriptions = (), string? appOwner = (), boolean? skipApplicationKeys = (), boolean? update = ()) returns ApplicationInfo|APIInfoList|error {
        string resourcePath = string `/applications/import`;
        map<anydata> queryParam = {"organizationId": organizationId, "preserveOwner": preserveOwner, "skipSubscriptions": skipSubscriptions, "appOwner": appOwner, "skipApplicationKeys": skipApplicationKeys, "update": update};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        http:Request request = new;
        mime:Entity[] bodyParts = check createBodyParts(payload);
        request.setBodyParts(bodyParts);
        ApplicationInfo|APIInfoList response = check self.clientEp->post(resourcePath, request);
        return response;
    }
    # Get All Subscriptions
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + applicationId - **Application Identifier** consisting of the UUID of the Application. 
    # + groupId - Application Group Id 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + offset - Starting point within the complete list of items qualified. 
    # + 'limit - Maximum size of resource array to return. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Subscription list returned. 
    resource isolated function get subscriptions(string organizationId, string? apiId = (), string? applicationId = (), string? groupId = (), string? xWso2Tenant = (), int offset = 0, int 'limit = 25, string? ifNoneMatch = ()) returns SubscriptionList|error {
        string resourcePath = string `/subscriptions`;
        map<anydata> queryParam = {"organizationId": organizationId, "apiId": apiId, "applicationId": applicationId, "groupId": groupId, "offset": offset, "limit": 'limit};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        SubscriptionList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Add a New Subscription
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + payload - Subscription object that should to be added 
    # + return - Created. Successful response with the newly created object as entity in the body. Location header contains URL of newly created entity. 
    resource isolated function post subscriptions(string organizationId, Subscription payload, string? xWso2Tenant = ()) returns WorkflowResponse|Subscription|error {
        string resourcePath = string `/subscriptions`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        WorkflowResponse|Subscription response = check self.clientEp->post(resourcePath, request, httpHeaders);
        return response;
    }
    # Add New Subscriptions
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + payload - Subscription objects that should to be added 
    # + return - OK. Successful response with the newly created objects as entity in the body. 
    resource isolated function post subscriptions/multiple(string organizationId, Subscription[] payload, string? xWso2Tenant = ()) returns Subscription[]|error {
        string resourcePath = string `/subscriptions/multiple`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        Subscription[] response = check self.clientEp->post(resourcePath, request, httpHeaders);
        return response;
    }
    # Get Additional Information of subscriptions attached to an API.
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + groupId - Application Group Id 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + offset - Starting point within the complete list of items qualified. 
    # + 'limit - Maximum size of resource array to return. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Types and fields returned successfully. 
    resource isolated function get subscriptions/[string apiId]/additionalInfo(string organizationId, string? groupId = (), string? xWso2Tenant = (), int offset = 0, int 'limit = 25, string? ifNoneMatch = ()) returns AdditionalSubscriptionInfoList|error {
        string resourcePath = string `/subscriptions/${getEncodedUri(apiId)}/additionalInfo`;
        map<anydata> queryParam = {"organizationId": organizationId, "groupId": groupId, "offset": offset, "limit": 'limit};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        AdditionalSubscriptionInfoList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get Details of a Subscription
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + subscriptionId - Subscription Id 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Subscription returned 
    resource isolated function get subscriptions/[string subscriptionId](string organizationId, string? ifNoneMatch = ()) returns Subscription|error {
        string resourcePath = string `/subscriptions/${getEncodedUri(subscriptionId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        Subscription response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Update Existing Subscription
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + subscriptionId - Subscription Id 
    # + payload - Subscription object that should to be added 
    # + return - Subscription Updated. Successful response with the updated object as entity in the body. Location header contains URL of newly updates entity. 
    resource isolated function put subscriptions/[string subscriptionId](string organizationId, Subscription payload, string? xWso2Tenant = ()) returns WorkflowResponse|Subscription|error {
        string resourcePath = string `/subscriptions/${getEncodedUri(subscriptionId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        WorkflowResponse|Subscription response = check self.clientEp->put(resourcePath, request, httpHeaders);
        return response;
    }
    # Remove a Subscription
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + subscriptionId - Subscription Id 
    # + ifMatch - Validator for conditional requests; based on ETag. 
    # + return - OK. Resource successfully deleted. 
    resource isolated function delete subscriptions/[string subscriptionId](string organizationId, string? ifMatch = ()) returns WorkflowResponse|error? {
        string resourcePath = string `/subscriptions/${getEncodedUri(subscriptionId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-Match": ifMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        WorkflowResponse? response = check self.clientEp->delete(resourcePath, headers = httpHeaders);
        return response;
    }
    # Get Details of a Pending Invoice for a Monetized Subscription with Metered Billing.
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + subscriptionId - Subscription Id 
    # + return - OK. Details of a pending invoice returned. 
    resource isolated function get subscriptions/[string subscriptionId]/usage(string organizationId) returns APIMonetizationUsage|error {
        string resourcePath = string `/subscriptions/${getEncodedUri(subscriptionId)}/usage`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        APIMonetizationUsage response = check self.clientEp->get(resourcePath);
        return response;
    }
    # Get All Available Throttling Policies
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + 'limit - Maximum size of resource array to return. 
    # + offset - Starting point within the complete list of items qualified. 
    # + policyLevel - List Application or Subscription type thro. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. List of throttling policies returned. 
    resource isolated function get 'throttling\-policies/[string policyLevel](string organizationId, int 'limit = 25, int offset = 0, string? ifNoneMatch = (), string? xWso2Tenant = ()) returns ThrottlingPolicyList|error {
        string resourcePath = string `/throttling-policies/${getEncodedUri(policyLevel)}`;
        map<anydata> queryParam = {"organizationId": organizationId, "limit": 'limit, "offset": offset};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-None-Match": ifNoneMatch, "X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        ThrottlingPolicyList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get Details of a Throttling Policy
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + policyId - The name of the policy 
    # + policyLevel - List Application or Subscription type thro. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Throttling Policy returned 
    resource isolated function get 'throttling\-policies/[string policyLevel]/[string policyId](string organizationId, string? xWso2Tenant = (), string? ifNoneMatch = ()) returns ThrottlingPolicy|error {
        string resourcePath = string `/throttling-policies/${getEncodedUri(policyLevel)}/${getEncodedUri(policyId)}`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        ThrottlingPolicy response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get All Tags
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + 'limit - Maximum size of resource array to return. 
    # + offset - Starting point within the complete list of items qualified. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Tag list is returned. 
    resource isolated function get tags(string organizationId, int 'limit = 25, int offset = 0, string? xWso2Tenant = (), string? ifNoneMatch = ()) returns TagList|error {
        string resourcePath = string `/tags`;
        map<anydata> queryParam = {"organizationId": organizationId, "limit": 'limit, "offset": offset};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        TagList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Retrieve/Search APIs and API Documents by Content
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + 'limit - Maximum size of resource array to return. 
    # + offset - Starting point within the complete list of items qualified. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + query - **Search**. You can search by using providing the search term in the query parameters. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. List of qualifying APIs and docs is returned. 
    resource isolated function get search(string organizationId, int 'limit = 25, int offset = 0, string? xWso2Tenant = (), string? query = (), string? ifNoneMatch = ()) returns SearchResultList|error {
        string resourcePath = string `/search`;
        map<anydata> queryParam = {"organizationId": organizationId, "limit": 'limit, "offset": offset, "query": query};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant, "If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        SearchResultList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get a List of Supported SDK Languages
    #
    # + return - OK. List of supported languages for generating SDKs. 
    resource isolated function get 'sdk\-gen/languages() returns json|error {
        string resourcePath = string `/sdk-gen/languages`;
        json response = check self.clientEp->get(resourcePath);
        return response;
    }
    # Get available web hook subscriptions for a given application.
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + applicationId - **Application Identifier** consisting of the UUID of the Application. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. Topic list returned. 
    resource isolated function get webhooks/subscriptions(string organizationId, string? applicationId = (), string? apiId = (), string? xWso2Tenant = ()) returns WebhookSubscriptionList|error {
        string resourcePath = string `/webhooks/subscriptions`;
        map<anydata> queryParam = {"organizationId": organizationId, "applicationId": applicationId, "apiId": apiId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        WebhookSubscriptionList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Retreive Developer Portal settings
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. Settings returned 
    resource isolated function get settings(string organizationId, string? xWso2Tenant = ()) returns Settings|error {
        string resourcePath = string `/settings`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        Settings response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get All Application Attributes from Configuration
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + ifNoneMatch - Validator for conditional requests; based on the ETag of the formerly retrieved variant of the resourec. 
    # + return - OK. Application attributes returned. 
    resource isolated function get settings/'application\-attributes(string organizationId, string? ifNoneMatch = ()) returns ApplicationAttributeList|error {
        string resourcePath = string `/settings/application-attributes`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"If-None-Match": ifNoneMatch};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        ApplicationAttributeList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get Tenants by State
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + state - The state represents the current state of the tenant Supported states are [ active, inactive] 
    # + 'limit - Maximum size of resource array to return. 
    # + offset - Starting point within the complete list of items qualified. 
    # + return - OK. Tenant names returned. 
    resource isolated function get tenants(string organizationId, string state = "active", int 'limit = 25, int offset = 0) returns TenantList|error {
        string resourcePath = string `/tenants`;
        map<anydata> queryParam = {"organizationId": organizationId, "state": state, "limit": 'limit, "offset": offset};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        TenantList response = check self.clientEp->get(resourcePath);
        return response;
    }
    # Give API Recommendations for a User
    #
    # + return - OK. Requested recommendations are returned 
    resource isolated function get recommendations() returns Recommendations|error {
        string resourcePath = string `/recommendations`;
        Recommendations response = check self.clientEp->get(resourcePath);
        return response;
    }
    # Get All API Categories
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. Categories returned 
    resource isolated function get 'api\-categories(string organizationId, string? xWso2Tenant = ()) returns APICategoryList|error {
        string resourcePath = string `/api-categories`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        APICategoryList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get All Key Managers
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + xWso2Tenant - For cross-tenant invocations, this is used to specify the tenant domain, where the resource need to be   retrieved from. 
    # + return - OK. Key Manager list returned 
    resource isolated function get 'key\-managers(string organizationId, string? xWso2Tenant = ()) returns KeyManagerList|error {
        string resourcePath = string `/key-managers`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        map<any> headerValues = {"X-WSO2-Tenant": xWso2Tenant};
        map<string|string[]> httpHeaders = getMapForHeaders(headerValues);
        KeyManagerList response = check self.clientEp->get(resourcePath, httpHeaders);
        return response;
    }
    # Get the Complexity Related Details of an API
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + return - OK. Requested complexity details returned. 
    resource isolated function get apis/[string apiId]/'graphql\-policies/complexity(string organizationId) returns GraphQLQueryComplexityInfo|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/graphql-policies/complexity`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        GraphQLQueryComplexityInfo response = check self.clientEp->get(resourcePath);
        return response;
    }
    # Retrieve Types and Fields of a GraphQL Schema
    #
    # + organizationId - **ORGANIZATION ID** consisting the **UUID** of the organization. 
    # + apiId - **API ID** consisting of the **UUID** of the API. 
    # + return - OK. Types and fields returned successfully. 
    resource isolated function get apis/[string apiId]/'graphql\-policies/complexity/types(string organizationId) returns GraphQLSchemaTypeList|error {
        string resourcePath = string `/apis/${getEncodedUri(apiId)}/graphql-policies/complexity/types`;
        map<anydata> queryParam = {"organizationId": organizationId};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        GraphQLSchemaTypeList response = check self.clientEp->get(resourcePath);
        return response;
    }
    # Change the Password of the user
    #
    # + payload - Current and new password of the user 
    # + return - OK. User password changed successfully 
    resource isolated function post me/'change\-password(CurrentAndNewPasswords payload) returns http:Response|error {
        string resourcePath = string `/me/change-password`;
        http:Request request = new;
        json jsonBody = payload.toJson();
        request.setPayload(jsonBody, "application/json");
        http:Response response = check self.clientEp->post(resourcePath, request);
        return response;
    }
}

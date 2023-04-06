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

const DEFAULT_API_ICON_PATH = "";

public type ApiCard record {|
    string 'type;
    boolean isPublic;
    string latestVersion;
    boolean isLatestVersionPreRelease;
    *CommonAttributes;
    ApiVersionInfo[] apiVersions;
|};

# Represents API resource in Choreo marketplace
#
# + isPublic - Specifies whether the API is publicly exposed or not
# + apiVersions - List of versions of API
public type Api record {|
    *CommonAttributes;
    *ApiVersion;
|};

# Information about API version.
#
# + apiId - Identifier of the API 
# + 'version - Version number of the API
public type ApiVersionInfo record {|
    string apiId;
    string 'version;
|};
    

# Version of an API.
#
# + apiId - Unique identifier of the API
# + 'version - Version number of the API
# + createdTime - Time when the API version was created
# + isPreRelease - Specifies whether the API version is a pre-release version or not
# + description - Description of the API version
# + usageStats - Usage statistics of the API version
# + keywords - Keywords associated with the API version
# + scopes - Scopes associated with the API version
# + throttlingPolicies - Throttling policies associated with the API version
# + endpoints - List of endpoints API is exposed through
public type ApiVersion record {|
    string apiId;
    string 'version;
    boolean isPublic;
    boolean hasThumbnail;
    boolean isPreRelease;
    string[] keywords?;
    string[]? scopes;
    string[] throttlingPolicies;
    APIEndpoint[] endpoints?;
|};

# Owner of an API. Specifies from which organization, 
# project and the component the API is owned.
#
# + apiId - Identifier of the API
public type ApiPublisher record {|
    *ChoreoComponent;
|};

# Types of Interface Definition Languages associated 
# with APIs hosted and served in Marketplace. 
public enum IDLType {
    AsyncAPI,
    OpenAPI,
    GraphQL,
    Proto3,
    WSDL
}

# Represents Interface Definition Language of an API resource.
#
# + content - Content of the IDL 
# + idlType - Type of the IDL (i.e OpenAPI, SDL, WSDL etc)
public type IDL record {|
    json content;
    IDLType idlType;
|};

# Defines API endpoint details.
#
# + environmentName - Field Description  
# + url - URL of the endpoint
public type APIEndpoint record {|
    string environmentName;
    string url;
|};

# Types of endpoints 
public enum EndpointType {
    Sandbox,
    Production,
    Staging,
    Dev
};

# Defines an APIM application returned from APIM server.
#
# + id - Identifier of the app  
# + scopes - Scopes of the app  
# + subscribedApis - List of APIs (names) this APIM app is already subscribed to
public type ApiApp record {|
    string id;
    *CreatableApiApp;
    string[] scopes?;
    string[] subscribedApis;
|};

# Defines an APIM subscription returned from APIM server.
#
# + subscriptionId - Identifier of the subscription
# + throttlingPolicy - Throttling policy to be applied for the subscription 
# + status - Status of the subscription (approved or not)
public type ApiSubscription record {|
    string subscriptionId;
    *SubscriptionRequest;
    string throttlingPolicy;
    string status?;
|};

# Defines information required to create a APIM application.
#
# + name - Name of the application  
# + description - What this application is about  
# + environmentId - Choreo environment associated with the application  
# + throttlingPolicy - Throttling policy to be applied for the application. Default is Unlimited. 
public type CreatableApiApp record {|
    string name;
    string description?;
    string environmentId; //can change as per future APIM updates
    string throttlingPolicy = API_CREATE_APP_DEFAULT_THROTTLING_POLICY;
|};

# Defines information related to workflow created upon API app creation or subscription creation.
#
# + workflowStatus - This attribute declares whether this workflow task is approved or rejected.
# + jsonPayload - Attributes that returned after the workflow execution
public type ApiWorkflowResponse record {
    string workflowStatus;
    string jsonPayload?;
};

# Structure of request to subscribe an APIM app to an API.
#
# + apiAppId - Id of the APIM application  
# + apiId - Id of the Choreo API  
# + throttlingPolicy - Business plan throttling policy (Bronze, Silver, Gold, Unlimited)
public type SubscriptionRequest record {|
    string apiAppId;
    string apiId;
    string throttlingPolicy;
|};

# Defines API types supported by Choreo.
public enum ApiTypes {
    HTTP,
    WS ,
    SOAPTOREST,
    SOAP,
    GRAPHQL,
    WEBSUB,
    SSE,
    WEBHOOK,
    ASYNC    
};

# Thrittling policies supported by APIM.
public enum BusinessPlansThrottling {
    Bronze,
    Silver,
    Gold,
    Unlimited
}



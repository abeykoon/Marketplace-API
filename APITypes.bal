
const DEFAULT_API_ICON_PATH = "";

# Represents API resource in Choreo marketplace
#
# + iconPath - Path to the icon for API
# + apiVersions - List of versions
public type Api record {|
    boolean isPublic;
    *CommonAttributes;
    *ApiVersion;
    ApiVersionInfo[]? apiVersions;
|};

public type ApiVersionInfo record {|
    string apiId;
    string 'version;
|};
    

# Version of an API 
#
# + createdDate - Created date of API version 
# + 'version - Version number  
# + documentation - Documentation specific to the API version
# + Idl - Interface Definition associated with the API version 
# + endpoints - List of endpoints API is accessible
public type ApiVersion record {|
    string apiId;
    string 'version;
    string createdTime;
    boolean isPreRelease;
    string description?;
    UsageDetail usageStats;
    string[] keywords?;
    string[]? scopes;
    string[] throttlingPolicies;
    APIEndpoint[] endpoints?;
|};

public type ApiOwner record {|
    readonly string apiId;
    *Owner;
|};

# Types of Interface Definition Languages associated 
# with APIs hosted and served in Marketplace 
public enum IDLType {
    AsyncAPI,
    OpenAPI,
    GraphQL,
    Proto3,
    WSDL
}

# Represents Interface Definition Language of an API resource 
#
# + idlLocation - Link to the IDL definition   
# + idlType - Type of the IDL (i.e OpenAPI, SDL, WSDL etc)
public type IDL record {|
    json content;
    IDLType idlType;
|};

# Defines API endpoint details
#
# + endpointType - Type of endpoint related to the environmet etc.  
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

# Defines a APIM application returned from APIM server 
#
# + id - Identifier of the app  
# + subscribedApis - List of APIs APIM app is already subscribed to
public type ApiApp record {|
    string id;
    *CreatableApiApp;
    string[] scopes?;
    string[] subscribedApis;
|};

public type ApiSubscription record {|
    string subscriptionId;
    *SubscriptionRequest;
    string throttlingPolicy;
    string status?;
|};

# Defines information required to create a APIM application
#
# + name - Name of the application  
# + description - What is application is about  
# + environmentId - Choreo environment associated with the application
public type CreatableApiApp record {|
    string name;
    string description?;
    string environmentId; //can change as per future APIM updates
    string throttlingPolicy = API_CREATE_APP_DEFAULT_THROTTLING_POLICY;
|};

public type ApiWorkflowResponse record {
    # This attribute declares whether this workflow task is approved or rejected.
    string workflowStatus;
    # Attributes that returned after the workflow execution
    string jsonPayload?;
};

# Structure of request to subscribe an APIM app to an API
#
# + apiAppId - Id of the APIM application  
# + apiId - Id of the Choreo API  
# + throttlingPolicy - Business plan throttling policy (Bronze, Silver, Gold, Unlimited)
public type SubscriptionRequest record {|
    string apiAppId;
    string apiId;
    string throttlingPolicy;
|};

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

public enum BusinessPlansThrottling {
    Bronze,
    Silver,
    Gold,
    Unlimited
}



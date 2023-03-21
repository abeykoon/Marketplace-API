
# Definition of a resource is a combination of different types
public type Resource Api|ChoreoApi|Config;

# Types of resouces exposed by marketplace API
public enum ResourceType { //can change
    ApiType,
    ConfigType,
    TemplateType,
    PolicyType
};

# Common attributes of marketplace resources 
#
# + id - Across choreo unique id of resource 
# + name - Display name of resource (i.e Api name, config name) 
# + createdDate - Created date of the resource   
# + 'version - Version of the resource  
# + description -  A short description on what resource is about   
# + keywords - Keywords/tags related to the resource 
# + docLocation - Documentation link of the resource 
type CommonAttributes record {
    string id;
    string name;
    string createdDate;
    string 'version;
    string description;
    string[] keywords?;
    string docLocation;
};

# Represents public API resource in Choreo marketplace
#
# + Idl - Interface Definition associated with the API resource  
# + endpoints - List of public endpoints API is accessible
public type Api record  {|
    *CommonAttributes;      //TODO: need APIId (if it is different from common resource attribute id?)
    IDL Idl;
    APIEndpoint[] endpoints;
|};


# Represents API resource exposed from Choreo marketplace
#
# + organizationName - Name of the Choreo organization from which API is exposed   
# + projectName -  Name of the Choreo project from which API is exposed
# + componentName - Name of the Choreo component from which API is exposed 
# + isPreRelease - True if API is exposed as a pre-release inside Choreo
public type ChoreoApi record {|
    *Api;
    string organizationName;    
    string projectName;
    string componentName;
    boolean isPreRelease;
|};

# Represents Configuration resource in Choreo marketplace
public type Config record {|
    *CommonAttributes;
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
    string idlLocation;
    IDLType idlType;
|};

# Defines API endpoint details
#
# + environment - Name of Choreo environment endpoint is exposed from  
# + url - URL of the endpoint 
public type APIEndpoint record {|
    string environment; 
    string url;
|};

# Represents a keyword associated with a marketplace resource 
#
# + keyword - Keyword value 
# + count - Number of resources having the keyword 
public type Keyword record {|
    string keyword;
    int count;
|};

# Defines usage information of a marketplace resource 
#
# + usageCount - Number of downloads/references 
# + rating - Rating given by users (1-5)
public type UsageDetail record {|
    int usageCount;
    int rating;
|};

# Defines a APIM application returned from APIM server 
#
# + id - Identifier of the app  
# + subscribedEndpoints - List of endpoints APIM app is already subscribed to
public type ApiApp record {|
    string id;
    *CreatableApiApp;
    APIEndpoint[] subscribedEndpoints;
|};

# Defines information required to create a APIM application
#
# + name - Name of the application  
# + description - What is application is about  
# + environmentId - Choreo environment associated with the application
public type CreatableApiApp record {|
    string name;
    string description;
    string environmentId; //can change as per future APIM updates
|};

# Structure of request to subscribe an APIM app to an API
#
# + apiAppId - Id of the APIM application 
# + apiId - Id of the Choreo API 
public type SubscriptionRequest record {|
    string apiAppId;
    string apiId;
|};

# Structure of request to add a rating for a resource 
#
# + resourceId - Id of the resource  
# + rateValue - Rating (1-5)
# + comment - Optional comment
public type ResourceRateRequest record {|
    string resourceId;
    int rateValue;
    string comment?;
|};





# Definition of a resource is a combination of different types
public type Resource Api|Config;

# Types of resouces exposed by marketplace API
public enum ResourceType {      //can change
    ApiType,
    ConfigType,
    TemplateType,
    PolicyType
};

# Common attributes of marketplace resources
#
# + id - Across choreo unique id of resource  
# + name - Display name of resource (i.e Api name, config name)  
# + resourceType - Type of resource (i.e API, Config)  
# + visibility - Visibility of the resource and related attributes  
# + description - A short description on what resource is about  
# + usageStats - Details on usage of the resource  
# + keywords - Keywords/tags related to the resource  
# + iconPath - Path to the icon of the resource
public type CommonAttributes record {           
    string id;
    string name; 
    ResourceType resourceType;
    Visibility visibility;
    string description;
    UsageDetail usageStats;
    string[] keywords?;
    string iconPath;
};

# Visibility of a resource
public type Visibility Internal|External;

# Represents visibility attributes of an internally exposed resouce of Choreo marketplace
#
# + organizationName - Name of the Choreo organization from which API is exposed   
# + projectName - Name of the Choreo project from which API is exposed
# + componentName - Name of the Choreo component from which API is exposed 
# + isPreRelease - True if API is exposed as a pre-release inside Choreo
public type Internal record {
    string organizationName;
    string projectName;
    string componentName;
    boolean isPreRelease;
};

# Represents visibility attributes of an externally exposed resouce of Choreo marketplace
#
# + owner - owner of public resource (i.e Choreo)
public type External record {
    string owner;
};

# Represents a keyword associated with a marketplace resource 
#
# + keyword - Keyword value 
# + count - Number of resources having the keyword 
public type KeywordInfo record {|    
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




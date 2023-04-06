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

# Definition of a resource in Choreo Marketplace is a combination
#  of different types supported by the marketplace
public type Resource Api|Config;

# Types of resouces exposed by marketplace API
public enum ResourceType {      //can change
    ApiType,
    ConfigType,
    TemplateType,
    PolicyType
};

# Documentation types supported by marketplace API.
public enum DocType {
    # Doc describing an API 
    ApiDoc  
}

# Common attributes of marketplace resources.
#
# + id - Unique identifier of resource (i.e API ID, config ID)
# + name - Display name of resource (i.e API name, config name)  
# + resourceType - Type of resource (i.e API, Config)  
# + owner - Owner of the resource (i.e Choreo organization, Choreo project, Choreo component)  
# + hasThumbnail - True if resource has a thumbnail image
public type CommonAttributes record {           
    string id;
    string name; 
    string description?;
    ResourceType resourceType;
    ChoreoComponent owner;
    string thumbnailUri?;
    UsageDetail usageStats;
    string createdTime;
};

# Represents a resource owner in Choreo marketplace. 
# A resource maybe owned by a Choreo organization, project or component.
# 
# + orgId - ID of the Choreo organization from which resource is published
# + orgName - Name of the Choreo organization from which resource is published
# + projectName - Name of the Choreo project from which resource is published
# + projectId - ID of the Choreo project from which resource is published
# + componentName - Name of the Choreo component from which resource is published  
# + componentId - ID of the Choreo component from which resource is published
public type ChoreoComponent record {
    string orgId;
    string orgName;
    string projectName;
    string projectId;
    string componentName;
    readonly string componentId;
};


# External visibility type of a resource in Choreo marketplace.
#
# + organizationName - Name of the organization to which the resource is published
public type External record {
    string organizationName;
};

# Represents a keyword associated with a marketplace resource. 
#
# + keyword - Keyword value 
# + count - Number of resources having the keyword 
public type KeywordInfo record {|    
    string keyword;
    int count;
|};

# Defines usage information of a marketplace resource. 
#
# + usageCount - Number of downloads/references 
# + rating - Average rating given by users 
public type UsageDetail record {|
    int usageCount;
    string? rating;
|};

# Structure of a request to add a rating for a resource in Choreo marketplace.
#
# + resourceId - ID of the resource to be rated
# + ratedBy - User who is rating the resource
# + rating - Rating value given by the user
public type RatingRequest record {
    string resourceId;
    string ratedBy?;
    int rating;
};

# Represents a rating given by a user for a resource in Choreo marketplace.
#
# + ratingId - Unique ID of the rating
public type Rating record {
    string ratingId?;
    *RatingRequest;
};

# Document information of a marketplace resource.
#
# + documentId - Unique ID of the document
# + name - Name of the document
# + docType - Type of the document
# + summary - Summary of the document
# + sourceType - Type of the source inside the document  (i.e text, xml, json)
# + sourceUrl - URL of the actual url from where the document can be fetched
public type Document record {
    string documentId;
    string name;
    DocType docType;
    string summary?;
    string sourceType;   
    string sourceUrl;
};

# Represents an organization in Choreo marketplace.
#
# + id -   Integer ID of the organization (used internally)
# + uuid - UUID of the organization
# + 'handle - Handle of the organizationb (name)
# + name - Name of there organization
public type Organization record {
    string id;
    string uuid;
    string 'handle;
    string name;
};

# Meta information of an organization in Choreo marketplace.
#
# + 'handle - Handle of the organization (name) 
# + uuid - UUID of the organization
public type OrganizationInfo record {
    string 'handle;
    string uuid;
};




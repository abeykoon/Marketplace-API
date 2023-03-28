public type BitbucketAppPasswordType record {
    string appPassword?;
    string userName?;
};

public type BuildRevision record {
    string? revisionId?;
    string versionId?;
    string componentId?;
    string? environmentId?;
    string? buildId?;
    string? 'type?;
    string? commitHash?;
};

public type ByocConfig record {
    string dockerContext?;
    string dockerfilePath?;
    string srcGitRepoBranch?;
    string srcGitRepoUrl?;
};

public type ByocCreateComponentSchema record {
    string componentType?;
    string? accessibility?;
    string displayName?;
    string orgHandler?;
    ByocConfig byocConfig?;
    string description?;
    int? userId?;
    int orgId?;
    string labels?;
    int? port?;
    string name?;
    string projectId?;
    string? oasFilePath?;
};

public type CommonCredentialInput record {
    BitbucketAppPasswordType? bitbucketCredential?;
    string name?;
    string 'type?;
    string? projectId?;
    GitPatType? gitPatCredential?;
    string orgUuid?;
};

public type ComponentSchema record {
    string? accessibility?;
    string displayName?;
    int? triggerID?;
    string orgHandler?;
    string description?;
    boolean? enableCellDiagram?;
    string? sampleTemplate?;
    int orgId?;
    string? ballerinaVersion?;
    boolean? initializeAsBallerinaProject?;
    string labels?;
    string? ballerinaTemplate?;
    boolean? httpBase?;
    string? repositorySubPath?;
    string displayType?;
    string 'version?;
    string? triggerChannels?;
    string name?;
    string? srcGitRepoUrl?;
    string? repositoryType?;
    string? id?;
    string? repositoryBranch?;
    string projectId?;
    string? apiId?;
};

public type ComponentUpdateSchema record {
    string 'version?;
    string displayName?;
    string? orgHandler?;
    string description?;
    string id?;
    string? apiId?;
    string labels?;
};

public type ComponentsFilterOptions record {
    string[]? types?;
    int 'limit?;
    int offset?;
    string? 'type?;
};

public type ComponentsOptions record {
    ComponentsFilterOptions? filter?;
};

public type CreateComponentEndpointInput record {
    string versionId?;
    string? protocol?;
    string componentId?;
    string? apiDefinitionPath?;
    string? visibility?;
    string releaseId?;
    int port?;
    string displayName?;
    string? apiContext?;
    string? 'type?;
};

public type DeleteComponentEndpointInput record {
    string versionId?;
    string componentId?;
    string releaseId?;
    string endpointId?;
};

public type Deployment record {
    string? cron?;
    string? shaDate?;
    string versionId?;
    string componentId?;
    string envId?;
    string sha?;
    string branch?;
};

public type GenerateComponentEndpointInput record {
    string versionId?;
    string componentId?;
    string releaseId?;
    string commitHash?;
};

public type GitPatType record {
    string pat?;
};

public type IntegrationCreateComponentSchema record {
    string componentType?;
    string srcGitRepoBranch?;
    string? accessibility?;
    string displayName?;
    string orgHandler?;
    string description?;
    int? userId?;
    int orgId?;
    string labels?;
    string? repositorySubPath?;
    string 'version?;
    int? port?;
    string? libSubPath?;
    string name?;
    string srcGitRepoUrl?;
    string projectId?;
    string? oasFilePath?;
};

public type ProjectSchema record {
    string 'version?;
    string name?;
    string? orgHandler?;
    string description?;
    string? id?;
    string? region?;
    int orgId?;
};

public type Promote record {
    string? targetEnvironmentId?;
    string? targetReleaseId?;
    string apiVersionId?;
    string? cronFrequency?;
    string sourceReleaseId?;
};

public type PromoteComponentEndpointInput record {
    string targetEnvironmentId?;
    string versionId?;
    string componentId?;
    string sourceReleaseId?;
};

public type QueryComponentEndpointApiDefinitionInput record {
    string versionId?;
    string componentId?;
    string endpointId?;
};

public type QueryComponentEndpointFilterOptions record {
    string[]? releaseIds?;
};

public type QueryComponentEndpointInput record {
    string versionId?;
    string componentId?;
    string releaseId?;
    string endpointId?;
};

public type QueryComponentEndpointOptions record {
    QueryComponentEndpointFilterOptions? filter?;
};

public type QueryComponentEndpointsInput record {
    string versionId?;
    string componentId?;
    QueryComponentEndpointOptions? options?;
};

public type UpdateComponentEndpointInput record {
    string versionId?;
    string componentId?;
    string? apiDefinitionPath?;
    string? visibility?;
    string releaseId?;
    string endpointId?;
    string? displayName?;
    string? apiContext?;
};

public type ProjectApisResponse record {|
    map<json?> __extensions?;
    record {|
        string id;
        int orgId;
        string name;
        string? handler;
        string? extendedHandler;
        record {|
            string? id;
            record {|
                string? proxyId;
            |}[]? apiVersions;
        |}[] components;
    |}[] projects;
|};

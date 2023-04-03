import ballerina/graphql;

public isolated client class GraphqlClient {
    final graphql:Client graphqlClient;
    public isolated function init(ConnectionConfig config, string serviceUrl) returns graphql:ClientError? {
        graphql:ClientConfiguration graphqlClientConfig = {timeout: config.timeout, forwarded: config.forwarded, poolConfig: config.poolConfig, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, validation: config.validation};
        do {
            if config.http1Settings is ClientHttp1Settings {
                ClientHttp1Settings settings = check config.http1Settings.ensureType(ClientHttp1Settings);
                graphqlClientConfig.http1Settings = {...settings};
            }
            if config.cache is graphql:CacheConfig {
                graphqlClientConfig.cache = check config.cache.ensureType(graphql:CacheConfig);
            }
            if config.responseLimits is graphql:ResponseLimitConfigs {
                graphqlClientConfig.responseLimits = check config.responseLimits.ensureType(graphql:ResponseLimitConfigs);
            }
            if config.secureSocket is graphql:ClientSecureSocket {
                graphqlClientConfig.secureSocket = check config.secureSocket.ensureType(graphql:ClientSecureSocket);
            }
            if config.proxy is graphql:ProxyConfig {
                graphqlClientConfig.proxy = check config.proxy.ensureType(graphql:ProxyConfig);
            }
        } on fail var e {
            return <graphql:ClientError>error("GraphQL Client Error", e, body = ());
        }
        graphql:Client clientEp = check new (serviceUrl, graphqlClientConfig);
        self.graphqlClient = clientEp;
    }
    remote isolated function projectApis(string orgHandler, int orgId) returns ProjectApisResponse|graphql:ClientError {
        string query = string `query projectApis($orgId:Int!,$orgHandler:String!) {projects(orgId:$orgId) {id orgId name handler extendedHandler components(orgHandler:$orgHandler) {id apiVersions {proxyId}}}}`;
        map<anydata> variables = {"orgHandler": orgHandler, "orgId": orgId};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <ProjectApisResponse> check performDataBinding(graphqlResponse, ProjectApisResponse);
    }
}

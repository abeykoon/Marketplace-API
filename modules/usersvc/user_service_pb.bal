import ballerina/grpc;
import ballerina/protobuf;
import ballerina/time;

public const string USER_SERVICE_DESC = "0A12757365725F736572766963652E70726F746F120B63686F72656F2E617069731A1F676F6F676C652F70726F746F6275662F74696D657374616D702E70726F746F22450A164765744F7267616E697A6174696F6E52657175657374122B0A116F7267616E697A6174696F6E5F6E616D6518012001280952106F7267616E697A6174696F6E4E616D6522730A174765744F7267616E697A6174696F6E526573706F6E7365123D0A0C6F7267616E697A6174696F6E18012001280B32192E63686F72656F2E617069732E4F7267616E697A6174696F6E520C6F7267616E697A6174696F6E12190A0869735F61646D696E1802200128085207697341646D696E227E0A1A47657455736572496E666F42795573657249645265717565737412170A07757365725F69641801200128035206757365724964122B0A116F7267616E697A6174696F6E5F6E616D6518022001280952106F7267616E697A6174696F6E4E616D65121A0A08696E636C756465731803200328095208696E636C7564657322440A1B47657455736572496E666F4279557365724964526573706F6E736512250A047573657218012001280B32112E63686F72656F2E617069732E557365725204757365722287010A0C4F7267616E697A6174696F6E120E0A0269641801200128035202696412120A047575696418022001280952047575696412160A0668616E646C65180320012809520668616E646C6512120A046E616D6518042001280952046E616D6512270A056F776E657218052001280B32112E63686F72656F2E617069732E5573657252056F776E657222670A1846696E645573657246726F6D496470496452657175657374121E0A0B757365725F6964705F69641801200128095209757365724964704964122B0A116F7267616E697A6174696F6E5F6E616D6518022001280952106F7267616E697A6174696F6E4E616D6522420A1946696E645573657246726F6D4964704964526573706F6E736512250A047573657218012001280B32112E63686F72656F2E617069732E5573657252047573657222F5020A0455736572120E0A0269641801200128035202696412150A066964705F696418022001280952056964704964121F0A0B706963747572655F75726C180320012809520A7069637475726555726C12140A05656D61696C1804200128095205656D61696C12210A0C646973706C61795F6E616D65180520012809520B646973706C61794E616D65122A0A0667726F75707318062003280B32122E63686F72656F2E617069732E47726F7570520667726F75707312270A05726F6C657318072003280B32112E63686F72656F2E617069732E526F6C655205726F6C657312210A0C69735F616E6F6E796D6F7573180820012808520B6973416E6F6E796D6F757312390A0A637265617465645F617418092001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D70520963726561746564417412390A0A657870697265645F6174180A2001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D7052096578706972656441742280040A0547726F7570120E0A0269641801200128035202696412190A086F72675F6E616D6518022001280952076F72674E616D6512190A086F72675F7575696418032001280952076F72675575696412200A0B6465736372697074696F6E180420012809520B6465736372697074696F6E12230A0D64656661756C745F67726F7570180520012808520C64656661756C7447726F757012210A0C646973706C61795F6E616D65180620012809520B646973706C61794E616D6512160A0668616E646C65180720012809520668616E646C6512270A05726F6C657318082003280B32112E63686F72656F2E617069732E526F6C655205726F6C657312270A05757365727318092003280B32112E63686F72656F2E617069732E557365725205757365727312290A0474616773180A2003280B32152E63686F72656F2E617069732E47726F7570546167520474616773121D0A0A637265617465645F6279180B200128095209637265617465644279121D0A0A757064617465645F6279180C20012809520975706461746564427912390A0A637265617465645F6174180D2001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D70520963726561746564417412390A0A757064617465645F6174180E2001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D705209757064617465644174229C020A0847726F7570546167120E0A0269641801200128035202696412190A086F72675F6E616D6518022001280952076F72674E616D6512190A086F72675F7575696418032001280952076F726755756964121D0A0A67726F75705F6E616D65180420012809520967726F75704E616D6512160A0668616E646C65180520012809520668616E646C65121D0A0A637265617465645F6279180620012809520963726561746564427912390A0A637265617465645F617418072001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D70520963726561746564417412390A0A757064617465645F617418092001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D70520975706461746564417422D8030A04526F6C65120E0A0269641801200128035202696412200A0B6465736372697074696F6E180220012809520B6465736372697074696F6E12210A0C646973706C61795F6E616D65180320012809520B646973706C61794E616D6512160A0668616E646C65180420012809520668616E646C6512210A0C64656661756C745F726F6C65180520012808520B64656661756C74526F6C6512390A0B7065726D697373696F6E7318062003280B32172E63686F72656F2E617069732E5065726D697373696F6E520B7065726D697373696F6E7312280A047461677318072003280B32142E63686F72656F2E617069732E526F6C6554616752047461677312270A05757365727318082003280B32112E63686F72656F2E617069732E5573657252057573657273121D0A0A637265617465645F62791809200128095209637265617465644279121D0A0A757064617465645F6279180A20012809520975706461746564427912390A0A637265617465645F6174180B2001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D70520963726561746564417412390A0A757064617465645F6174180C2001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D70520975706461746564417422E7010A07526F6C65546167120E0A02696418012001280352026964121F0A0B726F6C655F68616E646C65180220012809520A726F6C6548616E646C6512160A0668616E646C65180320012809520668616E646C65121D0A0A637265617465645F6279180420012809520963726561746564427912390A0A637265617465645F617418052001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D70520963726561746564417412390A0A757064617465645F617418062001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D70520975706461746564417422AD020A0A5065726D697373696F6E120E0A0269641801200128035202696412160A0668616E646C65180220012809520668616E646C6512210A0C646973706C61795F6E616D65180320012809520B646973706C61794E616D65121F0A0B646F6D61696E5F61726561180420012809520A646F6D61696E4172656112200A0B6465736372697074696F6E180520012809520B6465736372697074696F6E121B0A09706172656E745F69641806200128035208706172656E74496412390A0A637265617465645F617418072001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D70520963726561746564417412390A0A757064617465645F617418082001280B321A2E676F6F676C652E70726F746F6275662E54696D657374616D705209757064617465644174227D0A1247657455736572496E666F52657175657374121E0A0B757365725F6964705F69641801200128095209757365724964704964122B0A116F7267616E697A6174696F6E5F6E616D6518022001280952106F7267616E697A6174696F6E4E616D65121A0A08696E636C756465731803200328095208696E636C75646573223C0A1347657455736572496E666F526573706F6E736512250A047573657218012001280B32112E63686F72656F2E617069732E55736572520475736572328B030A0B5573657253657276696365125C0A0F4765744F7267616E697A6174696F6E12232E63686F72656F2E617069732E4765744F7267616E697A6174696F6E526571756573741A242E63686F72656F2E617069732E4765744F7267616E697A6174696F6E526573706F6E736512620A1146696E645573657246726F6D496470496412252E63686F72656F2E617069732E46696E645573657246726F6D4964704964526571756573741A262E63686F72656F2E617069732E46696E645573657246726F6D4964704964526573706F6E736512500A0B47657455736572496E666F121F2E63686F72656F2E617069732E47657455736572496E666F526571756573741A202E63686F72656F2E617069732E47657455736572496E666F526573706F6E736512680A1347657455736572496E666F427955736572496412272E63686F72656F2E617069732E47657455736572496E666F4279557365724964526571756573741A282E63686F72656F2E617069732E47657455736572496E666F4279557365724964526573706F6E736542345A326769746875622E636F6D2F77736F322D656E74657270726973652F63686F72656F2D72756E74696D652F706B672F61706973620670726F746F33";

public isolated client class UserServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, USER_SERVICE_DESC);
    }

    isolated remote function GetOrganization(GetOrganizationRequest|ContextGetOrganizationRequest req) returns GetOrganizationResponse|grpc:Error {
        map<string|string[]> headers = {};
        GetOrganizationRequest message;
        if req is ContextGetOrganizationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("choreo.apis.UserService/GetOrganization", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <GetOrganizationResponse>result;
    }

    isolated remote function GetOrganizationContext(GetOrganizationRequest|ContextGetOrganizationRequest req) returns ContextGetOrganizationResponse|grpc:Error {
        map<string|string[]> headers = {};
        GetOrganizationRequest message;
        if req is ContextGetOrganizationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("choreo.apis.UserService/GetOrganization", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <GetOrganizationResponse>result, headers: respHeaders};
    }

    isolated remote function FindUserFromIdpId(FindUserFromIdpIdRequest|ContextFindUserFromIdpIdRequest req) returns FindUserFromIdpIdResponse|grpc:Error {
        map<string|string[]> headers = {};
        FindUserFromIdpIdRequest message;
        if req is ContextFindUserFromIdpIdRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("choreo.apis.UserService/FindUserFromIdpId", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <FindUserFromIdpIdResponse>result;
    }

    isolated remote function FindUserFromIdpIdContext(FindUserFromIdpIdRequest|ContextFindUserFromIdpIdRequest req) returns ContextFindUserFromIdpIdResponse|grpc:Error {
        map<string|string[]> headers = {};
        FindUserFromIdpIdRequest message;
        if req is ContextFindUserFromIdpIdRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("choreo.apis.UserService/FindUserFromIdpId", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <FindUserFromIdpIdResponse>result, headers: respHeaders};
    }

    isolated remote function GetUserInfo(GetUserInfoRequest|ContextGetUserInfoRequest req) returns GetUserInfoResponse|grpc:Error {
        map<string|string[]> headers = {};
        GetUserInfoRequest message;
        if req is ContextGetUserInfoRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("choreo.apis.UserService/GetUserInfo", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <GetUserInfoResponse>result;
    }

    isolated remote function GetUserInfoContext(GetUserInfoRequest|ContextGetUserInfoRequest req) returns ContextGetUserInfoResponse|grpc:Error {
        map<string|string[]> headers = {};
        GetUserInfoRequest message;
        if req is ContextGetUserInfoRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("choreo.apis.UserService/GetUserInfo", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <GetUserInfoResponse>result, headers: respHeaders};
    }

    isolated remote function GetUserInfoByUserId(GetUserInfoByUserIdRequest|ContextGetUserInfoByUserIdRequest req) returns GetUserInfoByUserIdResponse|grpc:Error {
        map<string|string[]> headers = {};
        GetUserInfoByUserIdRequest message;
        if req is ContextGetUserInfoByUserIdRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("choreo.apis.UserService/GetUserInfoByUserId", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <GetUserInfoByUserIdResponse>result;
    }

    isolated remote function GetUserInfoByUserIdContext(GetUserInfoByUserIdRequest|ContextGetUserInfoByUserIdRequest req) returns ContextGetUserInfoByUserIdResponse|grpc:Error {
        map<string|string[]> headers = {};
        GetUserInfoByUserIdRequest message;
        if req is ContextGetUserInfoByUserIdRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("choreo.apis.UserService/GetUserInfoByUserId", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <GetUserInfoByUserIdResponse>result, headers: respHeaders};
    }
}

public client class UserServiceGetOrganizationResponseCaller {
    private grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendGetOrganizationResponse(GetOrganizationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextGetOrganizationResponse(ContextGetOrganizationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public client class UserServiceFindUserFromIdpIdResponseCaller {
    private grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendFindUserFromIdpIdResponse(FindUserFromIdpIdResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextFindUserFromIdpIdResponse(ContextFindUserFromIdpIdResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public client class UserServiceGetUserInfoResponseCaller {
    private grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendGetUserInfoResponse(GetUserInfoResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextGetUserInfoResponse(ContextGetUserInfoResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public client class UserServiceGetUserInfoByUserIdResponseCaller {
    private grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendGetUserInfoByUserIdResponse(GetUserInfoByUserIdResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextGetUserInfoByUserIdResponse(ContextGetUserInfoByUserIdResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextGetOrganizationRequest record {|
    GetOrganizationRequest content;
    map<string|string[]> headers;
|};

public type ContextGetUserInfoByUserIdResponse record {|
    GetUserInfoByUserIdResponse content;
    map<string|string[]> headers;
|};

public type ContextGetUserInfoByUserIdRequest record {|
    GetUserInfoByUserIdRequest content;
    map<string|string[]> headers;
|};

public type ContextFindUserFromIdpIdResponse record {|
    FindUserFromIdpIdResponse content;
    map<string|string[]> headers;
|};

public type ContextFindUserFromIdpIdRequest record {|
    FindUserFromIdpIdRequest content;
    map<string|string[]> headers;
|};

public type ContextGetOrganizationResponse record {|
    GetOrganizationResponse content;
    map<string|string[]> headers;
|};

public type ContextGetUserInfoResponse record {|
    GetUserInfoResponse content;
    map<string|string[]> headers;
|};

public type ContextGetUserInfoRequest record {|
    GetUserInfoRequest content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type Group record {|
    int id = 0;
    string org_name = "";
    string org_uuid = "";
    string description = "";
    boolean default_group = false;
    string display_name = "";
    string 'handle = "";
    Role[] roles = [];
    User[] users = [];
    GroupTag[] tags = [];
    string created_by = "";
    string updated_by = "";
    time:Utc created_at = [0, 0.0d];
    time:Utc updated_at = [0, 0.0d];
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type Organization record {|
    int id = 0;
    string uuid = "";
    string 'handle = "";
    string name = "";
    User owner = {};
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type User record {|
    int id = 0;
    string idp_id = "";
    string picture_url = "";
    string email = "";
    string display_name = "";
    Group[] groups = [];
    Role[] roles = [];
    boolean is_anonymous = false;
    time:Utc created_at = [0, 0.0d];
    time:Utc expired_at = [0, 0.0d];
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type GetOrganizationRequest record {|
    string organization_name = "";
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type GetUserInfoByUserIdResponse record {|
    User user = {};
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type FindUserFromIdpIdRequest record {|
    string user_idp_id = "";
    string organization_name = "";
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type RoleTag record {|
    int id = 0;
    string role_handle = "";
    string 'handle = "";
    string created_by = "";
    time:Utc created_at = [0, 0.0d];
    time:Utc updated_at = [0, 0.0d];
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type GetUserInfoRequest record {|
    string user_idp_id = "";
    string organization_name = "";
    string[] includes = [];
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type Role record {|
    int id = 0;
    string description = "";
    string display_name = "";
    string 'handle = "";
    boolean default_role = false;
    Permission[] permissions = [];
    RoleTag[] tags = [];
    User[] users = [];
    string created_by = "";
    string updated_by = "";
    time:Utc created_at = [0, 0.0d];
    time:Utc updated_at = [0, 0.0d];
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type GroupTag record {|
    int id = 0;
    string org_name = "";
    string org_uuid = "";
    string group_name = "";
    string 'handle = "";
    string created_by = "";
    time:Utc created_at = [0, 0.0d];
    time:Utc updated_at = [0, 0.0d];
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type GetUserInfoByUserIdRequest record {|
    int user_id = 0;
    string organization_name = "";
    string[] includes = [];
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type Permission record {|
    int id = 0;
    string 'handle = "";
    string display_name = "";
    string domain_area = "";
    string description = "";
    int parent_id = 0;
    time:Utc created_at = [0, 0.0d];
    time:Utc updated_at = [0, 0.0d];
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type FindUserFromIdpIdResponse record {|
    User user = {};
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type GetOrganizationResponse record {|
    Organization organization = {};
    boolean is_admin = false;
|};

@protobuf:Descriptor {value: USER_SERVICE_DESC}
public type GetUserInfoResponse record {|
    User user = {};
|};


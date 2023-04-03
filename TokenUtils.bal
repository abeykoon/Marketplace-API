import ballerina/jwt;
import ballerina/io;


isolated function validateToken(string token) returns jwt:Payload|error {
    jwt:ValidatorConfig config = {}; //TODO: how to populate
    return check jwt:validate(token, config);
}

isolated function getOrgInfoFromToken(jwt:Payload decodedToken) returns OrganizationInfo|error {
    json scopeDetails = check decodedToken[ORG_KEY_IN_JWT].ensureType();
    return scopeDetails.fromJsonWithType();
}

isolated function validateAndObtainOrgInfo(string token) returns OrganizationInfo|error {
    jwt:Payload jwtPayload = check validateToken(token);
    io:println("vlidation passed");
    return getOrgInfoFromToken(jwtPayload);
}

isolated function getIdpId(string token) returns string|error {
    jwt:Payload jwtPayload = check validateToken(token);
    string? sub = jwtPayload.sub;
    if sub is string {
        return sub;
    } else {
        return error("No idp id is present in JWT token");
    }
}

isolated function validateAndObtainOrgId(string token) returns string|error {
    jwt:Payload jwtPayload = check validateToken(token);
    OrganizationInfo orgInfoFromToken = check getOrgInfoFromToken(jwtPayload);
    return orgInfoFromToken.uuid;
}

// isolated function getOrgFromHandler(string orgHander) returns Organization|error {
//    //call app service and get
// }

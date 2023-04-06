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

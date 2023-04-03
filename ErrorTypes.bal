import ballerina/http;
public type ErrResponse http:BadRequest|http:InternalServerError|http:NotFound|http:Unauthorized|http:Forbidden;

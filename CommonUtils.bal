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

// isolated function removeDuplicates(string[] strArr) returns string[] {
//     _ = strArr.some(isolated function(string s) returns boolean {
//         int? firstIndex = strArr.indexOf(s);
//         int? lastIndex = strArr.lastIndexOf(s);
//         if (firstIndex != lastIndex) {
//             _ = strArr.remove(<int>lastIndex);
//         }
//         // Returning true, if the end of the array is reached.
//         if (firstIndex == (strArr.length() - 1)) {
//             return true;
//         }
//         return false;
//     });
//     return strArr;
// }

isolated function removeDuplicates(string[] strArr) returns string[] {
    map<boolean> strings = {};
    foreach string str in strArr {
        strings[str] = true;
    }
    return strings.keys();
}



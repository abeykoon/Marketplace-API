
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



@IsTest
public class ApexDataClassTest {
    @IsTest
	public static void testParse() {
		String json=		'{'+
		'            "attributes": {'+
		'                "type": "ApexClass",'+
		'                "url": "/services/data/v58.0/tooling/sobjects/ApexClass/01p5i00000VBWHKAA5"'+
		'            },'+
		'            "Id": "01p5i00000VBWHKAA5",'+
		'            "Name": "SiteLoginController",'+
		'            "LastModifiedBy": {'+
		'                "attributes": {'+
		'                    "type": "User",'+
		'                    "url": "/services/data/v58.0/tooling/sobjects/User/0055i00000AwzVTAAZ"'+
		'                },'+
		'                "Name": "Mayank Dhanopia"'+
		'            },'+
		'            "CreatedBy": {'+
		'                "attributes": {'+
		'                    "type": "User",'+
		'                    "url": "/services/data/v58.0/tooling/sobjects/User/0055i00000AwzVTAAZ"'+
		'                },'+
		'                "Name": "Mayank Dhanopia"'+
		'            },'+
		'            "Body": "/**\n * An apex page controller that exposes the site login functionality\n */\nglobal with sharing class SiteLoginController {\n    global String username {get; set;}\n    global String password {get; set;}\n\n    global PageReference login() {\n        String startUrl = System.currentPageReference().getParameters().get(\'startURL\');\n        return Site.login(username, password, startUrl);\n    }\n    \n   \tglobal SiteLoginController () {}\n}",'+
		'            "Status": "Active"'+
		'        }';
		ApexDataClass obj = ApexDataClass.parse(json);
		System.assert(obj != null);
	}
}
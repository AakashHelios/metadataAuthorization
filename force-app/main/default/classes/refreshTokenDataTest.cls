@IsTest
public class refreshTokenDataTest {
    @IsTest
	public static void testParse() {
		String json=		'{"access_token":"SESSION_ID_REMOVED","signature":"kUhtcwvVDzcB1i7triE7IlmvJ+G1GNVv8bqs4DOf7qY=","scope":"refresh_token full","instance_url":"https://helioscom2-dev-ed.my.salesforce.com","id":"https://login.salesforce.com/id/00D5i000008y1YuEAI/0055i0000053tsJAAQ","token_type":"Bearer","issued_at":"1687258365965"}';
		refreshTokenData obj = refreshTokenData.parse(json);
		System.assert(obj != null);
	}
}
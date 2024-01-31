@IsTest
public class callbackResponseTest {
    @IsTest
    static void testParse() {
		String json=		'{"access_token":"!","refresh_token":"","signature":"++ceu18R2SI1+RRY0KGHcwK8UjvFAv3U=","scope":"refresh_token full","id_token":"..HR7YZwx97qUFcLFwWlknA0sBFEgCeANXCCDBJQAfjWhzih00d6JOy4zpfC-CuH5S3lGnQn6p0Pecz92H-aRJVCPfCyB4bn_skXoyKvtXicHQ----fOS_T---bqQ--","instance_url":"https://-dev-ed.my.salesforce.com"}';
		callbackResponse obj = callbackResponse.parse(json);
		System.assert(obj != null);
	}
}
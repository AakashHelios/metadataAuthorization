public class refreshTokenData{
	public String access_token;	//SESSION_ID_REMOVED
	public String signature;	//kUhtcwvVDzcB1i7triE7IlmvJ+G1GNVv8bqs4DOf7qY=
	public String scope;	//refresh_token full
	public String instance_url;	//https://helioscom2-dev-ed.my.salesforce.com
	public String id;	//https://login.salesforce.com/id/00D5i000008y1YuEAI/0055i0000053tsJAAQ
	public String token_type;	//Bearer
	public String issued_at;	//1687258365965
	public static refreshTokenData parse(String json){
		return (refreshTokenData) System.JSON.deserialize(json, refreshTokenData.class);
	}
}
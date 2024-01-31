public class callbackResponse{
	public String access_token;	
	public String refresh_token;	
	public String signature;	
	public String scope;	
	public String id_token;	
	public String instance_url;	
	public static callbackResponse parse(String json){
		return (callbackResponse) System.JSON.deserialize(json, callbackResponse.class);
	}
}
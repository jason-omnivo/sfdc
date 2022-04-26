public class BoxAuthResponse {
	public String access_token {get;set;}
	public Integer expires_in {get;set;}
	public List<String> restricted_to {get;set;}
	public String refresh_token {get;set;}
    public String token_type {get;set;}
}
public with sharing class OcrolusNewBookResponse {
    public Integer status { get; set; }
    public String message { get; set; }
    public Integer code { get; set; }
    public Response response { get; set; }
    public Meta meta { get; set; }
    public class Response {
        public String name { get; set; }
        public String created { get; set; } //date
        public Integer pk { get; set; }
        public boolean is_public { get; set; }
        public String owner_email { get; set; }
        public String uuid { get; set; }
    }
    public class Meta {
        public Integer status { get; set; }
        public String msg { get; set; }
        public Integer code { get; set; }
    }
}
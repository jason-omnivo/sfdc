public with sharing class OcrolusNewBookCallout {

    public OcrolusNewBookResponse execute(OcrolusNewBookRequest request) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:Ocrolus/v1/book/add');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');

        req.setBody(JSON.serialize(request));
        HttpResponse res = http.send(req);
        OcrolusNewBookResponse response = null;
        System.debug(res.getStatusCode());
        System.debug(res.getHeaderKeys());
        if (res.getStatusCode() == 200) {
            System.debug('body');
            System.debug(res.getBody());
            response = (OcrolusNewBookResponse) Json.deserialize(res.getBody(), OcrolusNewBookResponse.class);
            if (response.status == 200) {
                return response;
            }
        }
        return null;
    }
}
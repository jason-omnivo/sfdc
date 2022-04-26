public with sharing class IdeaFinancialUploadFilesCallout {

    public Boolean isRunningSandbox {
        get {
            if(isRunningSandbox == null)
                isRunningSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
            return isRunningSandbox;
        }
        set;
    }

    public HttpResponse execute(String oppId){

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        IdeaFinancialAPI.Utils utils = new IdeaFinancialAPI.Utils();

        req.setEndpoint(utils.getUploadFilesUrl());
//        req.setEndpoint('https://emc-idea-financial.herokuapp.com/upload_files_to_idea_financial/');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
//        req.setHeader('Accept', 'application/json');

        String body = '{"oppId": "' + oppId + '","sandbox":' + isRunningSandbox + '}';
        System.debug('body: ' + body);
        req.setBody(body);
        HttpResponse res = http.send(req);
        System.debug(res);

        System.debug('getStatusCode() == ' + res.getStatusCode());
        System.debug('getBody() == ' + res.getBody());

        return res;
    }
}
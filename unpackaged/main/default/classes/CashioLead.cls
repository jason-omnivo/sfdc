public class CashioLead {
    public static void consumeObject(JSONParser parser) {
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT || 
                curr == JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == JSONToken.END_OBJECT ||
                curr == JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    public String action {get;set;} 
    public String submission_id {get; set;}
    public String name {get;set;} 
    public String business_name {get;set;} 
    public String phone {get;set;} 
    public String email {get;set;} 
    public Integer annual_sales {get;set;} 
    public String credit_score {get;set;} 
    public String state {get;set;} 
    public String industry {get;set;} 
    public String months_in_business {get;set;} 

    public String utm_source {get;set;} 
    public String utm_medium {get;set;} 
    public String utm_campaign {get;set;} 

    public List<Lenders> lenders {get;set;} 

    public CashioLead(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'action') {
                        action = parser.getText();
                    } else if (text == 'submission_id') {
                        submission_id = parser.getText();
                    } else if (text == 'name') {
                        name = parser.getText();
                    } else if (text == 'business_name') {
                        business_name = parser.getText();
                    } else if (text == 'phone') {
                        phone = parser.getText();
                    } else if (text == 'email') {
                        email = parser.getText();
                    } else if (text == 'annual_sales') {
                        annual_sales = parser.getIntegerValue();
                    } else if (text == 'credit_score') {
                        credit_score = parser.getText();
                    } else if (text == 'state') {
                        state = parser.getText();
                    } else if (text == 'industry') {
                        industry = parser.getText();
                    } else if (text == 'months_in_business') {
                        months_in_business = parser.getText();
                    } else if (text == 'utm_source') {
                        utm_source = parser.getText();
                    } else if (text == 'utm_medium') {
                        utm_medium = parser.getText();
                    } else if (text == 'utm_campaign') {
                        utm_campaign = parser.getText();
                    } else if (text == 'lenders') {
                        lenders = new List<Lenders>();
                        while (parser.nextToken() != JSONToken.END_ARRAY) {
                            lenders.add(new Lenders(parser));
                        }
                    } else {
                        System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Lenders {
        public Integer id {get;set;} 
        public String name {get;set;} 
        public String website {get;set;} 

        public Lenders(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getIntegerValue();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'website') {
                            website = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Lenders consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static CashioLead parse(String json) {
        return new CashioLead(System.JSON.createParser(json));
    }
}
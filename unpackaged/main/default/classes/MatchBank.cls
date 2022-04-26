public class MatchBank implements Comparable {
    
    public Boolean isSelected{get; set;}
    public Funder__c funder{get; set;}
    
    public static List<SortRule> sortRuleList{get; set;}
    
    public MatchBank(Funder__c funder){
        this.funder = funder;
    }
   
    public Integer compareTo(Object objToCompare) {
		
		for(SortRule rule : SortRuleList) {
			Integer sortOrder = rule.sortOrder == SortRule.SORT_ORDER.Descending ? -1 : 1;
			MatchBank matchBankToCompare =  ((MatchBank)objToCompare);
			if(rule.sortFunction == SortRule.SORT_FUNCTION.Numeric) {	
				decimal value = (decimal)funder.get(rule.field);
				decimal valueToCompare = (decimal)matchBankToCompare.funder.get(rule.field);
				System.debug(value);
				System.debug(valueToCompare);
				if(value == null || valueToCompare == null && value != valueToCompare) {
					if(value == null)
						return -sortOrder;
					else
						return sortOrder;
				}
				value = value != null ? value : -0.001;
				valueToCompare = valueToCompare != null ? valueToCompare : -0.001;
				if(value > valueToCompare)
					return sortOrder;
				else if(value < valueToCompare)
					return -sortOrder;
			} else if(rule.sortFunction == SortRule.SORT_FUNCTION.Alphabetical) {
				string value = (string)funder.get(rule.field);
				string valueToCompare = (string)matchBankToCompare.funder.get(rule.field);
				value = value != null ? value : '';
				valueToCompare = valueToCompare != null ? valueToCompare : '';
				Integer returnValue = value.compareTo(valueToCompare);
				if(returnValue != 0)
					return sortOrder * returnValue;
			}
		}
		return 0;

    }
    

}
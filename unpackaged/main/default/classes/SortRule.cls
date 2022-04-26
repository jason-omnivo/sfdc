public class SortRule {
	
	public SortRule(string field, SORT_ORDER sortOrder, SORT_FUNCTION sortFunction) {
		this.field = field;
		this.sortOrder = sortOrder;
		this.sortFunction = sortFunction;
	}
	
	public enum SORT_ORDER {
		Acsending, Descending
	}
	
	public enum SORT_FUNCTION {
		Numeric, Alphabetical
	}
	
	public string field {get; set;}
	public SORT_ORDER sortOrder {get; set;}
	public SORT_FUNCTION sortFunction {get; set;}
	
}
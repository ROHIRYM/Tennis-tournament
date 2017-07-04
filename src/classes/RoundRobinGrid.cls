public class RoundRobinGrid {
	
	public List<List<String>> fullfilMatrix(List<Game__c> games, Map<String, String> idNameMap) {
		List<List<String>> result = new List<List<String>>();
		List<String> Ids = new List<String>(idNameMap.keySet());
		List<String> firstRow = new List<String>();
		firstRow.add('-');
		for (String id : Ids) {
			firstRow.add(idNameMap.get(id));
		}
		result.add(firstRow);
		for (Integer i = 0; i < Ids.size(); i++) {
			List<String> row = new List<String>();
			row.add(idNameMap.get(Ids[i]));
			for (Integer j = 0; j < Ids.size(); j++) {
				if (i == j) {
					row.add('-');
				} else {
					for (Game__c g : games) {
						if (g.firstCompetitor__c == Ids[i] && g.secondCompetitor__c == Ids[j]) {
							if (g.isApproved__c) {
								row.add(String.valueOf(g.firstCompetitorScore__c));
							} else {
								row.add('0');
							}
						}
						if (g.firstCompetitor__c == Ids[j] && g.secondCompetitor__c == Ids[i]) {
							if (g.isApproved__c) {
								row.add(String.valueOf(g.secondCompetitorScore__c));
							} else {
								row.add('0');
							}
						}
					}
				}
			}
			result.add(row);
		}
		
		return result;
	}
    
}
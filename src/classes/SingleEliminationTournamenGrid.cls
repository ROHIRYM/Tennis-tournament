public class SingleEliminationTournamenGrid {
    
    public List<List<Game__c>> fullfilMatrix(List<Game__c> games, Map<String, String> idNameMap) {
		List<List<Game__c>> result = new List<List<Game__c>>();
		Set<String> Ids = idNameMap.keySet();
		Integer startRound = 1;
		result.add(new List<Game__c>());
		for (Game__c g : games) {
			if (Ids.contains(g.firstCompetitor__c)) {
				g.firstCompetitor__c = idNameMap.get(g.firstCompetitor__c);
			} else {
				g.firstCompetitor__c = '?';
			}
			if (Ids.contains(g.secondCompetitor__c)) {
				g.secondCompetitor__c = idNameMap.get(g.secondCompetitor__c);
			} else {
				g.secondCompetitor__c = '?';
			}
			if (!g.isApproved__c) {
				g.firstCompetitorScore__c = 0;
				g.secondCompetitorScore__c = 0;
			}
			if (g.round__c == startRound) {
				result[startRound-1].add(g);
			} else {
				List<Game__c> temp = new List<Game__c>();
				temp.add(g);
				result.add(temp);
				startRound++;
			}
		}
		return result;
	}
    
}
public class MyTest {
	//hhjerhjtrj
	public static void addHelloWorld(Invoice__c[] invs){
	  Set<id> oppIds = new Set<id>();
  	  for (Invoice__c inv : invs) {
      	oppIds.add(inv.Opportunity__c);
  	  }
  
      Map<id, Opportunity> oppsMap = new Map<id, Opportunity>(
          [SELECT AccountId, StageName FROM Opportunity WHERE Id IN :oppIds]);
          
  	  for (Invoice__c inv : invs) {
          if (oppsMap.get(inv.Opportunity__c).AccountId != inv.Account__c) {
              inv.addError('Phone number must');
          }
  	  }
    }
}
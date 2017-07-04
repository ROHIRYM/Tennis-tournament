global class DeleteUnactivatedPlayers implements Schedulable {

    global void execute(SchedulableContext ctx) {
    	DateTime dt = DateTime.now();
    	dt = dt.addDays(-1);
        delete [SELECT Id, CreatedDate FROM Player__c 
            WHERE User_Status__c = 'Waiting for activation' AND CreatedDate < :dt];
    }
    
}
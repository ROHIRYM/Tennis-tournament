trigger TournamentAfterUpdateTrigger on Tournament__c (after update) {
	
    TournamentTriggerMethods.manageTournament(Trigger.new);
    
}
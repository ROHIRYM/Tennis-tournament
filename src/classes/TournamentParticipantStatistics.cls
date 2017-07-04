public class TournamentParticipantStatistics {
    
    public String id {get; set;}
    public Integer wonGames {get; set;}
    public Decimal wonSets {get; set;}
    
    public TournamentParticipantStatistics(String id, Integer wonGames, Decimal wonSets) {
    	this.id = id;
    	this.wonGames = wonGames;
    	this.wonSets = wonSets;
    }
    
    public Boolean betterThan(TournamentParticipantStatistics tps) {
    	return this.wonGames > tps.wonGames 
    		|| (this.wonGames == tps.wonGames && this.wonSets > tps.wonSets);
    }
}
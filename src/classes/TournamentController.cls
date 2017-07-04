public class TournamentController {
    
    public Tournament__c tournament { get; set; }
    
    public List<Tournament__c> tournaments { get; private set; }
    public Integer tournamentsSize { get; private set; }
    
    public Boolean isLoggedIn { get; private set; }
    public Boolean isManager { get; private set; }
    public Boolean areActiveTournaments { get; private set; }
    public Boolean isUpcomingTournament { get; private set; }
    public Boolean isAppliedToTournament { get; private set; }
    
    public List<String> participants { get; private set; }
    public Integer participantsSize { get; private set; }
    public Map<String, String> idNameMap { get; private set; }
    public List<TournamentParticipantStatistics> sortedParticipants { get; private set; }
    
    public List<List<String>> rrMatrix { get; private set; }
    public List<List<Game__c>> setMatrix { get; private set; }
    public List<List<String>> detMatrix { get; private set; }
    
    public TournamentController() {
        tournament = new Tournament__c();
        tournamentsSize = 0;
        LoggedInAndManager loggedInAndManager = AuthorizationController.AUTHORIZATION_CONTROLLER.isLoggedInAndManager();
        isLoggedIn = loggedInAndManager.isLoggedIn;
        isManager = loggedInAndManager.isManager;
    }
    
    public PageReference save() {
        if (isManager) {
            try {
                upsert(tournament);
                notifyAllPlayersAboutNewTournament();               
            } catch(System.DMLException e) {
                ApexPages.addMessages(e);
                return null;
            } catch(Exception e) {
                return Page.myHome;
            }
        }
        return Page.myHome;
    }
    
    private void notifyAllPlayersAboutNewTournament(){
        String htmlBody = 'A new tournament <b> ' + tournament.Name + ' </b> has been created.';
                
        List<Player__c> players = [SELECT E_mail__c FROM Player__c WHERE User_Status__c = 'Active'];
        String[] playersEmails = new String[players.size()];
        for (Integer i = 0; i < players.size(); i++) {
            playersEmails[i] = players[i].E_mail__c;
        }
        
        EmailSender.EMAIL_SENDER.sendLetter(2, playersEmails, 'New Tournament',
            'New Tournament', 'Test', htmlBody);
    }
    
    public PageReference view() {
        if (isLoggedIn) {
        	drawGrid();
            return findById();
        }
        return Page.myHome;
    }
    
    private void drawGrid() {
    	String tournamentId = ApexPages.currentPage().getParameters().get('id');
        List<Tournament__c> cTournaments = [SELECT Id, Type__c, Format__c FROM Tournament__c WHERE Id = :tournamentId AND (Status__c = 'Current' OR Status__c = 'Complete')];
        if (cTournaments.size() > 0) {
        	Tournament__c t =  cTournaments[0];
        	List<Game__c> games = [SELECT Id, firstCompetitor__c, secondCompetitor__c, firstCompetitorScore__c, secondCompetitorScore__c, round__c, isApproved__c 
        			 FROM Game__c WHERE Tournament_Id__c = :tournamentId ORDER BY round__c];
        	idNameMap = new Map<String, String>();
			if (t.Format__c == '1 x 1') {
				List<Player__c> players = [SELECT Id, Name FROM Player__c WHERE Id IN (SELECT Player_Id__c FROM Player_Tournament__c WHERE Tournament_Id__c = :tournamentId)];
				for (Player__c p : players) {
					idNameMap.put(p.Id, p.Name);
				}
			} else {
				List<Team__c> teams = [SELECT Id, Name FROM Team__c WHERE Tournament_Id__c = :tournamentId];
				for (Team__c tt : teams) {
					idNameMap.put(tt.Id, tt.Name);
				}
			}
			participants = idNameMap.values();
			participantsSize = participants.size();
			if (t.Type__c == 'Round Robin') {
				RoundRobinGrid rrGrid = new RoundRobinGrid();
				rrMatrix = rrGrid.fullfilMatrix(games, idNameMap);
				sortedParticipants = GameTriggerMethods.sortedParticipants;
			} else if (t.Type__c == 'Single Elimination Tournament') {
				SingleEliminationTournamenGrid singleEliminationTournamenGrid = new SingleEliminationTournamenGrid();
				setMatrix = singleEliminationTournamenGrid.fullfilMatrix(games, idNameMap);
			} else {
				//Double Elimination Tournament
			}
        }
    }
    
    public PageReference edit() {
        if (isManager) {
            String tournamentId = ApexPages.currentPage().getParameters().get('id');
            List<Tournament__c> tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c,
            	Start_Date__c, Finish_Date__c FROM Tournament__c 
            	WHERE Id = :tournamentId AND Status__c LIKE '%Upcoming%'];
            if (tournaments.size() > 0) {
                tournament = tournaments[0];
                isUpcomingTournament = tournament.Status__c == 'Upcoming';
            } else {
            	tournament = new Tournament__c();
            }
            return null;
        }
        return Page.Tournaments;
    }
    
    public PageReference deleteUpcoming() {
        if (isManager) { 
            String tournamentId = ApexPages.currentPage().getParameters().get('id');
            List<Tournament__c> tournaments = [SELECT Id FROM Tournament__c WHERE Id = :tournamentId AND Status__c LIKE '%Upcoming%'];
            if (tournaments.size() != 0) {
                tournament = tournaments[0];
                try {
                    delete(tournament);             
                } catch(System.DMLException e) {
                    ApexPages.addMessages(e);
                    return Page.Tournaments;
                }
                return null;
            }
        }
        return Page.Tournaments;
    }
    
    public PageReference start() {
        if (isManager) {
            List<Tournament__c> activeTournaments = [SELECT Id FROM Tournament__c WHERE Status__c = 'Current'];
            if (activeTournaments.size() == 0) {
                String tournamentId = ApexPages.currentPage().getParameters().get('id');
                List<Tournament__c> upcomingTournaments = [SELECT Id, Status__c, Format__c 
                    FROM Tournament__c 
                    WHERE Id =  :tournamentId AND Status__c = 'Upcoming'];
                if (upcomingTournaments.size() > 0) {
                    Tournament__c upcomingTournament = upcomingTournaments[0];
                    try {
                        upcomingTournament.Status__c = 'Current';
                        update(upcomingTournament);            
                    } catch(System.DMLException e) {
                        ApexPages.addMessages(e);
                        return null;
                    } catch(Exception e) {
                    	ApexPages.addMessages(e);
                        return null;
                    }
                    return Page.Tournament_Start;
                }
            }
        }
        return Page.myHome;
    }
    
    public PageReference apply() {
        if (isLoggedIn) {
            String tournamentId = ApexPages.currentPage().getParameters().get('id');
            List<Tournament__c> tournaments = [SELECT Id, Format__c, Status__c FROM Tournament__c WHERE Id = :tournamentId];       
            if (tournamentId != null && tournaments.size() == 0) { 
                return Page.Tournaments;
            }
            tournament = tournaments[0];
            if (tournamentId != null && tournament.Status__c == 'Upcoming') {
                if (tournament.Format__c == '1 x 1') {
                    PlayerTournamentController playerTournamentController = new PlayerTournamentController();
                    return playerTournamentController.create(tournamentId);
                } else {
                    return new PageReference('/PlayerTeam_Create?id=' + tournamentId);
                }
            }
            return Page.Tournaments;
        }
        return Page.myHome;
    }
    
    private Boolean validateTournamentApply() {
        String tournamentId = ApexPages.currentPage().getParameters().get('id');
        String playerId = ApexPages.currentPage().getCookies().get('PlayerCookie').getValue();
        List<Tournament__c> tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c,
            Start_Date__c, Finish_Date__c FROM Tournament__c WHERE Id = :tournamentId];       
        if (tournaments.size() > 0) {
        	if (tournaments[0].Format__c == '1 x 1') {
            	List<Player_Tournament__c> playerTournaments = [SELECT Id FROM Player_Tournament__c WHERE Player_Id__c = :playerId AND Tournament_Id__c = :tournamentId];
            	return playerTournaments.size() > 0;
        	} else {
            	List<Team__c> qTeams = [SELECT Id, 
					(SELECT Player_Id__c FROM Player_Teams__r WHERE Player_Id__c = :playerId)
					FROM Team__c WHERE Tournament_Id__c = :tournamentId];
				if (qTeams.size() > 0) {
					for (Team__c t : qTeams) {
						if (t.Player_Teams__r.size() > 0) {
							return true;
						}
					}
				}
            }
        }
        return false;
    }
    
    private Boolean validateActiveTournaments() {
        List<Tournament__c> activeTournaments = [SELECT Id FROM Tournament__c WHERE Status__c = 'Current'];
        return activeTournaments.size() > 0;
    }
    
    private PageReference findById() {
        String tournamentId = ApexPages.currentPage().getParameters().get('id');
        List<Tournament__c> tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c,
            Start_Date__c, Finish_Date__c FROM Tournament__c WHERE Id = :tournamentId];       
        if (tournamentId != null && tournaments.size() == 0) { 
            return Page.Tournaments;
        }
        if (tournamentId != null) {
            tournament = tournaments[0];
            isAppliedToTournament = validateTournamentApply();
            areActiveTournaments = validateActiveTournaments();
            isUpcomingTournament = tournament.Status__c == 'Upcoming';
        } else {
            tournament = new Tournament__c();
        }
        return null;
    }
    
    public PageReference viewAll() {
        isLoggedIn = AuthorizationController.AUTHORIZATION_CONTROLLER.isLoggedIn();
        if (isLoggedIn) {
            String tName = tournament.Name == null ? '%' : '%' + tournament.Name + '%';
            String tType = tournament.Type__c == null ? '%' : tournament.Type__c;
            String tFormat = tournament.Format__c == null ? '%' : tournament.Format__c;
            String tStatus = tournament.Status__c == null ? '%' : tournament.Status__c;
            tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c FROM Tournament__c
                WHERE Name LIKE :tName AND Type__c LIKE :tType AND Format__c LIKE :tFormat 
                AND Status__c LIKE :tStatus];
            tournamentsSize = tournaments.size();
            return null;
        }
        return Page.myHome;
    }
}
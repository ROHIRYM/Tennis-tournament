public class PlayerTeamController {

	public Player_Team__c playerTeam { get; set; }
	public Player_Team__c secondPlayerTeam { get; set; }
	public Team__c team { get; set; }
	
	public List<Player__c> players { get; set; }
	public String selectedPlayer { get; set; }
	public String playerId { get; set; }
	public LIst<SelectOption> playersOptions {get {
		if (playersOptions == null) {
			playersOptions = new List<SelectOption>();
			String tournamentId = ApexPages.currentPage().getParameters().get('id');
			List<Team__c> teams = [SELECT Name,
				(SELECT Player_Id__c FROM Player_Teams__r)
			 	FROM Team__c WHERE Tournament_Id__c = :tournamentId];
			for (Player__c p : players) {
				SelectOption selectOption;
				for (Team__c t : teams) {
					for (Player_Team__c pT : t.Player_Teams__r) {
						if (pT.Player_Id__c == p.Id) {
							selectOption = new SelectOption(p.Id, p.Name + '(' + t.Name + ')');
							SelectOption.setDisabled(true);
							break;
						}
					}
					if (selectOption != null) {
						break;
					}
				}
				if (selectOption == null) {
					selectOption = new SelectOption(p.Id, p.Name);
				}
				playersOptions.add(selectOption);
			}
		}
		return playersOptions;
	} set;}
	
	public Boolean isLoggedIn { get; private set; }
	
	public PlayerTeamController() {
        LoggedInAndManager loggedInAndManager = AuthorizationController.AUTHORIZATION_CONTROLLER.isLoggedInAndManager();
        isLoggedIn = loggedInAndManager.isLoggedIn;
        playerId = ApexPages.currentPage().getCookies().get('PlayerCookie').getValue();
        team = new Team__c();
        playerTeam = new Player_Team__c();
        secondPlayerTeam = new Player_Team__c();
        players = [SELECT Id, Name FROM Player__c WHERE Id != :playerId AND User_Status__c = 'Active'];
    }
	
	public PageReference create() {
		String tournamentId = ApexPages.currentPage().getParameters().get('id');
		List<Tournament__c> tournaments = [SELECT Id FROM Tournament__c WHERE Id = :tournamentId];
		if (tournaments.size() > 0) {
			Savepoint sp = Database.setSavepoint();
			
        	TeamController teamController = new TeamController();
        	team.Tournament_Id__c = tournamentId;
        	teamController.create(team);
        	
        	String playerId = ApexPages.currentPage().getCookies().get('PlayerCookie').getValue();
	    	playerTeam.Player_Id__c = playerId;
	    	
	    	List<Team__c> teams = [SELECT Id FROM Team__c WHERE Name = :team.Name];
	    	if (teams.size() > 0) {
	    		team = teams[0];
	    	}
	    	playerTeam.Team_Id__c = team.Id;
	    	secondPlayerTeam.Team_Id__c = team.Id;
	    	
	    	secondPlayerTeam.Player_Id__c = selectedPlayer;
        	
        	try {
        		validatePlayerTeam(playerTeam);
        		insert(playerTeam);
        		sendInvitation(selectedPlayer, team.Id);
        		//validatePlayerTeam(secondPlayerTeam);
        		//insert(secondPlayerTeam);
        		return new PageReference('/Tournaments');
        	} catch (System.DMLException e) {
        		Database.rollback(sp);
        		ApexPages.addMessages(e);
    	    	return new PageReference('/Tournament_View?id=' + tournamentId);
        	}  catch(Exception e) {
        		Database.rollback(sp);
        		ApexPages.addMessages(e);
	    		return Page.myHome;
	    	}
		}
		return Page.Tournaments;
	}
	
	private void sendInvitation(String selectedPlayer, String teamId) {
		List<Player__c> players = [SELECT Id, Name, E_Mail__c FROM Player__c WHERE Id = :selectedPlayer];
		if (players.size() > 0) {
			
			String htmlBody = 'Your player:<b> ' + players[0].Name +' </b>has been invited as a teammate to the tournament.'+
                'To accept the invitation <a href="https://mytabletennistournamen-developer-edition.eu6.force.com/AcceptTeamInvitation?code=' 
                + selectedPlayer + '&team=' + teamId + '">Click here</a>';
    	
	    	EmailSender.EMAIL_SENDER.sendLetter(2, new String[] {players[0].E_mail__c}, 
    			'Accept invitation', 'Accept invitation', 'Test', htmlBody);
		}
	}
	
	private void validatePlayerTeam(Player_Team__c playerTeam) {
		List<Player_Team__c> playerTeams = [SELECT Id FROM Player_Team__c WHERE Team_Id__c = :playerTeam.Team_Id__c AND Player_Id__c = :playerTeam.Player_Id__c];
		if (playerTeams.size() > 0) {
			DMLException ex = new DMLException();
			ex.setMessage('This player is already applied to the team!');
			throw ex;
		}
		playerTeams = [SELECT Id FROM Player_Team__c WHERE Team_Id__c = :playerTeam.Team_Id__c];
		if (playerTeams.size() > 2) {
			DMLException ex = new DMLException();
			ex.setMessage('Too many players for the team!');
			throw ex;
		}
		List<Team__c> teams = [SELECT Tournament_Id__c FROM Team__c WHERE Id = :playerTeam.Team_Id__c];
		if (teams.size() > 0) {
			List<Team__c> qTeams = [SELECT Id, 
			(SELECT Player_Id__c FROM Player_Teams__r WHERE Player_Id__c = :playerTeam.Player_Id__c)
			FROM Team__c WHERE Tournament_Id__c = :teams[0].Tournament_Id__c];
			for (Team__c t : qTeams) {
				if (t.Player_Teams__r.size() > 0) {
					DMLException ex = new DMLException();
					ex.setMessage('This player is already applied to the tournament!');
					throw ex;
				}
			}
		}
	}
	
	public PageReference checkLogIn() {
		return isLoggedIn ? null : Page.myHome;
	}
    
}
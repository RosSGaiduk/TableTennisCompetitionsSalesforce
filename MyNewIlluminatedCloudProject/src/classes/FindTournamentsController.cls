/**
 * Created by Rostyslav on 22.06.2017.
 */

public with sharing class FindTournamentsController extends CookiePlayerAndPermissinsController{
    public List<Tournament__c> tournamentsFound {get; set;}
    public List<Player_Tournament__c> player_tournaments {get;set;}
    public List<Team__c> teams {get;set;}
    public String status {get;set;}
    public Tournament__c tournament {get;set;}

    public List<sObject> players {get;set;}
    public Id tournamentId {get;set;}
    public List<Game__c> gamesOfTournament {get;set;}
    public List<String> results {get;set;}
    public Team__c team {get;set;}
    public Id currentPlayer {get;set;}
    public String tournamentFormat {get;set;}
    public Tournament__c currentTournament {get;set;}
    Map<Id,SObject> playersMap {get;set;}
    public List<GameJSON> gameJsons {get;set;}
    public List<List<GameJSON>> gameJSONList{get;set;}


    public FindTournamentsController(){
        tournament = new Tournament__c();
        tournamentsFound = [select Name, Start_Date__c, End_Date__c,Status__c,Type__c,Format__c from Tournament__c];
        try {
            player_tournaments = [select Name,TournamentId__c from Player_Tournament__c where PlayerId__c=:playerCookie.Id];
            teams =[select TournamentId__c from Team__c where Id in (select TeamId__c from Player_Team__c where PlayerId__c =: playerCookie.Id)];
            System.debug('size player tournaments: '+player_tournaments.size());
        }catch (NullPointerException ex){
        }
    }
    

    public void showTournaments(){
        String tournamentNameContains = (tournament.Name!=null)?tournament.Name:'';
        String tournamentStatus = tournament.Status__c;
        tournamentsFound = [select Name, Start_Date__c, End_Date__c,Status__c,Type__c,Format__c from Tournament__c where Name like :'%'+tournamentNameContains+'%'
        and Status__c like :tournamentStatus
        ];
    }

    public PageReference apply(){
        //String url = ApexPages.currentPage().getUrl();
        PageReference pageRef = new PageReference('/Tournaments');
        try {
            tournamentId = ApexPages.currentPage().getParameters().get('currentTournament');
            tournament = [select Status__c,Format__c from Tournament__c where Id =: tournamentId];
            if (tournament.Status__c != 'Upcoming'){
                return pageRef.setRedirect(true);
            }
            System.debug('playerId: ' + playerCookie.Id + ' tournamentId: ' + tournamentId);

            if (tournament.Format__c=='1x1') {
                try {
                    Player_Tournament__c find_player_tournament = [select Id from Player_Tournament__c where PlayerId__c = :playerCookie.Id and TournamentId__c = :tournamentId];
                    delete find_player_tournament;
                } catch (Exception ex) {
                    System.debug('Excetion(no result) while finding Player_Tournament which has tournamentId: ' + tournamentId + ' and Player_Id: ' + playerCookie.Id);
                    Player_Tournament__c player_tournament = new Player_Tournament__c(
                            PlayerId__c = playerCookie.Id,
                            TournamentId__c = tournamentId
                    );
                    insert player_tournament;
                }
            } else {
                pageRef = new PageReference('/CreateTeam?tournament='+tournamentId);
            }
        } catch (NullPointerException ex){
            System.debug('Null Pointer: in cookies there are no players');
        } catch (DmlException ex){
            System.debug('An exception occured while inserting player_tournament');
        }
        return pageRef.setRedirect(true);
    }

    public void showPlayersOfTournament(){
        tournamentId = ApexPages.currentPage().getParameters().get('currentTournament');
        currentTournament = [select Format__c,Status__c,Type__c,Stage__c from Tournament__c where id =: tournamentId];
        tournamentFormat = currentTournament.Format__c;
        if (currentTournament.Format__c=='1x1') {
            try {
                currentPlayer = playerCookie.Id;
            } catch (Exception ex){
                currentPlayer = null;
            }
            players = new List<Player__c>([select Id,Name from Player__c where Id in (select PlayerId__c from Player_Tournament__c where TournamentId__c = :tournamentId)]);

        } else {
            players = new List<Team__c>([select Id,Name from Team__c where TournamentId__c =: tournamentId]);
            try {
                Player_Team__c pt = [select TeamId__c from Player_Team__c where PlayerId__c = :playerCookie.Id and TeamId__c in (select Id from Team__c where TournamentId__c=: tournamentId) limit 1];
                currentPlayer = pt.TeamId__c;
            } catch (Exception ex){
                currentPlayer = null;
            }
        }
        System.debug('TournamentId: '+tournamentId);
        System.debug('Ids.size'+players.size());
        showGamesOfTournament();
    }

    public void showGamesOfTournament(){
        Boolean redirect = false;
        gamesOfTournament =
        [select Id,Name,Start_Date__c,FirstCompetitorId__c,SecondCompetitorId__c,Won__c,Stage__c,
                First_Competitor_Score__c, Second_Competitor_Score__c from Game__c where Tournament_ID__c =: tournamentId order by Id];
        List<String> winnersOfCurrentStage = new List<String>();
        if (currentTournament.Type__c!='Round Robin') {
            List<Game__c> gamesOfCurrentStage = [select Id,Name,Won__c from Game__c where Stage__c = :currentTournament.Stage__c and Tournament_ID__c =: tournamentId];
            for (Game__c game: gamesOfCurrentStage) {
                if (game.Won__c != null) winnersOfCurrentStage.add(game.Won__c); else {
                    winnersOfCurrentStage.clear();
                    break;
                }
            }
            if (winnersOfCurrentStage.size()>0) {
                redirect = true;
                if (currentTournament.Format__c=='1x1') {
                    List<SObject> playersGoToNextStage = [select Id from Player__c where Id in :winnersOfCurrentStage];
                    if (playersGoToNextStage.size() > 1) {
                        currentTournament.Stage__c = currentTournament.Stage__c + 1;
                        update currentTournament;
                        TournamentGamesGenerator.generateSingleIlluminationGames(playersGoToNextStage, tournamentId, (Double) currentTournament.Stage__c);
                    }
                } else {
                    List<SObject> teamsGoToNextStage = [select Id from Team__c where Id in :winnersOfCurrentStage];
                    if (teamsGoToNextStage.size() > 1) {
                        currentTournament.Stage__c = currentTournament.Stage__c + 1;
                        update currentTournament;
                        TournamentGamesGenerator.generateSingleIlluminationGames(teamsGoToNextStage, tournamentId, (Double) currentTournament.Stage__c);
                    }
                    makeResultStringDetails();
                }
            }
        }
        if (gamesOfTournament.size()==0 && currentTournament.Status__c=='Current'){
            System.debug('List of games equals to 0 or null');
            generateGamesForCurrentTournament();
        } else if (gamesOfTournament.size()!=0 && currentTournament.Status__c=='Current')
            makeResultStringDetails();
        else if (currentTournament.Status__c=='Completed'){
            makeResultStringDetails();
        }
        if (redirect && winnersOfCurrentStage.size()>1){
            showGamesOfTournament();
        } else if (winnersOfCurrentStage.size()==1){
            currentTournament.Status__c = 'Completed';
            update currentTournament;
        }
    }

    public void generateGamesForCurrentTournament(){
        delete gamesOfTournament;
        gamesOfTournament = new List<Game__c>();
        Tournament__c thisTournament = [select Type__c from Tournament__c where Id =: tournamentId];
        if (thisTournament.Type__c=='Round Robin') {
            TournamentGamesGenerator.generateRoundRobinGames(players,tournamentId);
        } else {
            TournamentGamesGenerator.generateSingleIlluminationGames(players,tournamentId,0);
        }
        makeResultStringDetails();
    }



    public void generateResults(){
        for (Integer i = 0; i < gamesOfTournament.size(); i++){
            Integer won = Math.round((Math.random()*1));
            if (won==0){
                gamesOfTournament.get(i).Won__c = gamesOfTournament.get(i).FirstCompetitorId__c;
            } else {
                gamesOfTournament.get(i).Won__c = gamesOfTournament.get(i).SecondCompetitorId__c;
            }
        }
        update gamesOfTournament;
        makeResultStringDetails();
    }

    public void makeResultStringDetails(){
        results = new List<String>();

        if (currentTournament.Format__c=='1x1')
            playersMap = new Map<Id,Player__c>([select Id,Name from Player__c where Id in (select PlayerId__c from Player_Tournament__c where TournamentId__c = :tournamentId)]);
        else playersMap = new Map<Id,Team__c>([select Id,Name from Team__c where TournamentId__c =: tournamentId]);

        gameJSONList = new List<List<GameJSON>>();
        for (Integer i = 0; i <= currentTournament.Stage__c; i++) {
            List<GameJSON> gameJSONs = new List<GameJSON>();
            gameJSONList.add(gameJSONs);
        }

        try {
            for (Integer i = 0; i < gamesOfTournament.size(); i++) {
                if (currentTournament.Type__c=='Round Robin'){
                    String jsonGame = JSON.serialize('{"FirstCompetitorId":"'+gamesOfTournament.get(i).FirstCompetitorId__c +
                            '","SecondCompetitorId":"' + gamesOfTournament.get(i).SecondCompetitorId__c +
                            '","FirstCompetitorName":"' + playersMap.get(gamesOfTournament.get(i).FirstCompetitorId__c).get('Name') +
                            '","SecondCompetitorName":"' + playersMap.get(gamesOfTournament.get(i).SecondCompetitorId__c).get('Name') +
                            '","FirstCompetitorScore":"' + gamesOfTournament.get(i).First_Competitor_Score__c +
                            '","SecondCompetitorScore":"' + gamesOfTournament.get(i).Second_Competitor_Score__c +
                            '","Won":"' + gamesOfTournament.get(i).Won__c +
                            '","Stage":"' + gamesOfTournament.get(i).Stage__c +
                            '","Id":"' + gamesOfTournament.get(i).Id + '"}');
                    results.add(jsonGame);
                    } else {
                    GameJSON gameJSON = new GameJSON();
                    gameJSON.FirstCompetitorId = gamesOfTournament.get(i).FirstCompetitorId__c;
                    gameJSON.SecondCompetitorId = gamesOfTournament.get(i).SecondCompetitorId__c;
                    gameJSON.FirstCompetitorName = (String) playersMap.get(gamesOfTournament.get(i).FirstCompetitorId__c).get('Name');
                    gameJSON.SecondCompetitorName = (String) playersMap.get(gamesOfTournament.get(i).SecondCompetitorId__c).get('Name');
                    if (gamesOfTournament.get(i).Won__c != null) {
                        gameJSON.WinnerName = (String) playersMap.get(gamesOfTournament.get(i).Won__c).get('Name');
                        gameJSON.Won = gamesOfTournament.get(i).Won__c;
                    } else {
                        gameJSON.WinnerName = 'Game is not completed';
                        gameJSON.Won = '';
                    }
                    gameJSON.Stage = (Integer) gamesOfTournament.get(i).Stage__c;
                    gameJSON.IdGame = gamesOfTournament.get(i).Id;
                    gameJSON.FirstCompetitorScore = (Integer) gamesOfTournament.get(i).First_Competitor_Score__c;
                    gameJSON.SecondCompetitorScore = (Integer) gamesOfTournament.get(i).Second_Competitor_Score__c;
                    gameJSON.IdGame = gamesOfTournament.get(i).Id;
                    gameJSONList.get(gameJSON.Stage).add(gameJSON);
                }
            }
        } catch (Exception ex){
            System.debug('There are no games of current tournament, because this tournament has upcoming status');
        }
    }
}
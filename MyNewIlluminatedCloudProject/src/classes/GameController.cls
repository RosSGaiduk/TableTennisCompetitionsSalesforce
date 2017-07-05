/**
 * Created by Rostyslav on 26.06.2017.
 */

public with sharing class GameController extends CookiePlayerAndPermissinsController{
    public Game__c game{get;set;}
    public Id wonId {get;set;}
    public String firstCompetitor {get;set;}
    public String secondCompetitor {get;set;}
    public List<String> competitors {get;set;}
    public Id tournamentId {get;set;}
    public Tournament__c tournament{get;set;}
    public List<Player__c> players {get;set;}
    public Boolean anotherStage{get;set;}
    public Boolean canModifyGame{get;set;}

    public GameController(){
        anotherStage = false;
        players = [select Id from Player__c];
        String players = ApexPages.currentPage().getParameters().get('players');
        tournamentId = ApexPages.currentPage().getParameters().get('tournament');
        getGame(players);

        canModifyGame = true;
        tournament = [select Id,Format__c,Status__c,Stage__c,Type__c from Tournament__c where Id =: tournamentId];
        try {
            if (tournament.Format__c=='1x1') {
                if (game.FirstCompetitorId__c != playerCookie.Id && game.SecondCompetitorId__c != playerCookie.Id) {
                    canModifyGame = false;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You can not create result of game, because you are not a player of this game'));
                    throw new MyException();
                }
            } else {
                Map<Id,Team__c> teams = new Map<Id,Team__c>([select Id,Name from Team__c where
                TournamentId__c=:tournament.Id and (Id=:game.FirstCompetitorId__c or Id=:game.SecondCompetitorId__c)]);
                System.debug('Size teams: '+teams.size());
                for (Team__c t: teams.values()){
                    System.debug(t.Name);
                }
                List<Player__c> playersFound = [select Id,Name from Player__c where Id in (select PlayerId__c from Player_Team__c where TeamId__c =: teams.keySet())];
                System.debug('Players found: '+playersFound.size());
                for (Player__c p: playersFound){
                    System.debug('player name: '+p.Name+' id '+p.Id+' cookie '+playerCookie.Id);
                }
                for (Player__c player: playersFound){
                    if (player.Id==playerCookie.Id) {
                        canModifyGame = true;
                        break;
                    } else canModifyGame = false;
                }
            }
        } catch (MyException ex){
            canModifyGame = false;
            System.debug('Constructor (Game) error');
            return;
        } catch (Exception ex){
            canModifyGame = false;
            return;
        }
        if (tournament.Status__c != 'Current'){
            canModifyGame = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You can not create result of game, because tournament has not started yet'));
            System.debug('Constructor (Game) error');
            return;
        }

        System.debug(tournament.Stage__c+' and stage game: '+game.Stage__c);
        if (game.Stage__c != tournament.Stage__c){
            anotherStage = true;
            System.debug('Constructor (Game) error');
            return;
        }

        if (tournament.Format__c=='1x1') {
            firstCompetitor = [select Name from Player__c where Id = :game.FirstCompetitorId__c limit 1].Name;
            secondCompetitor = [select Name from Player__c where Id = :game.SecondCompetitorId__c limit 1].Name;
            System.debug('1x1 selected');
        } else {
            firstCompetitor = [select Name from Team__c where Id = :game.FirstCompetitorId__c limit 1].Name;
            secondCompetitor = [select Name from Team__c where Id = :game.SecondCompetitorId__c limit 1].Name;
            System.debug('2x2 selected');
        }
    }


    public void getGame(String players){
        try {
            System.debug('Params: ' + players);
            Id firstCompetitorId = players.split('\\,')[0];
            Id secondCompetitorId = players.split('\\,')[1];
            System.debug('First competitor id: ' + firstCompetitorId + ' second competitor id: ' + secondCompetitorId);
            game = [
                    select Id,Name,FirstCompetitorId__c,SecondCompetitorId__c,First_Competitor_Score__c,Second_Competitor_Score__c,
                    Stage__c from Game__c where Tournament_ID__c = :tournamentId
                    and FirstCompetitorId__c = :firstCompetitorId and SecondCompetitorId__c = :secondCompetitorId
            ];
        } catch (Exception ex){
            System.debug('En error occured while finding apropriate game(GameController constructor)');
            game = null;
        }
    }

    public PageReference edit(){
        game.Won__c = game.First_Competitor_Score__c>game.Second_Competitor_Score__c?game.FirstCompetitorId__c:game.SecondCompetitorId__c;
        System.debug('winner: '+game.Won__c);
        update game;
        if (tournament.Type__c=='1x1'){
            List<Player__c> players = [select Id,Email__c from Player__c where id=:game.FirstCompetitorId__c or id=:game.SecondCompetitorId__c];
            try {
                EmailSender.sendEmail(players, 'rgaidukevich9@gmail.com', EmailMessageType.NOTIFICATION_ABOUT_LAST_GAME, null, null, game);
                System.debug('SEND EMAIL');
            } catch (Exception ex){
                System.debug('ERROR WHILE SENDING EMAIL');
            }
        } else {
            List<Player_Team__c> teams = [select TeamId__c,PlayerId__c from Player_Team__c where TeamId__c =: game.FirstCompetitorId__c or TeamId__c =: game.SecondCompetitorId__c];
            List<Id> idPlayers = new List<Id>();
            for (Player_Team__c team: teams){
                idPlayers.add(team.PlayerId__c);
            }
            List<Player__c> players = [select Id,Email__c,Name from Player__c where id in:idPlayers];
            try {
                EmailSender.sendEmail(players, 'rgaidukevich9@gmail.com', EmailMessageType.NOTIFICATION_ABOUT_LAST_GAME, null, null, game);
            } catch (Exception ex){

            }
        }

        System.debug('tournament format ???'+tournament.Type__c);
        if (tournament.Type__c=='Round Robin'){
            System.debug('round robin');
            List<Game__c> gamesOfCurrentTournament = [select Id from Game__c where Tournament_ID__c =: tournament.Id and Won__c = null];
            if (gamesOfCurrentTournament.size()==0){
                tournament.Status__c = 'Completed';
                update tournament;
            }
        }

        PageReference pageReference = new PageReference('/tournament?currentTournament='+tournamentId);
        return pageReference;
    }
}
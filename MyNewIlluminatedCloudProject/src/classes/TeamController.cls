/**
 * Created by Rostyslav on 27.06.2017.
 */

public with sharing class TeamController extends CookiePlayerAndPermissinsController{
    public Team__c team{get;set;}
    public Player_Team__c player_team{get;set;}
    public Tournament__c tournament{get;set;}
    public Id invitePlayerId {get;set;}

    public TeamController(){
        try {
            team = new Team__c();
            String tournamentId = ApexPages.currentPage().getParameters().get('tournament');
            tournament = [select Id,Name,Type__c,Format__c from Tournament__c where Id = :tournamentId];
        } catch (Exception ex){

        }
    }


    public PageReference create(){
        try {
            Team__c findTeam = [select TournamentId__c,Name  from Team__c where Name=: team.Name and TournamentId__c=:tournament.Id];
            System.debug('found team: '+findTeam.TournamentId__c);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There is a team with the same name in this tournament'));
            return null;
        } catch (Exception ex){
            System.debug('Exception occured while finding team');
        }

        team.TournamentId__c = tournament.Id;
        insert team;

        player_team = new Player_Team__c(
            PlayerId__c = playerCookie.Id,
            TeamId__c = team.Id
        );
        insert player_team;



        Player_Team__c invitePlayer_team = new Player_Team__c(
                PlayerId__c = invitePlayerId,
                TeamId__c = team.Id
        );
        insert invitePlayer_team;


        EmailSender.sendEmail([select Id,Email__c from Player__c where id =: invitePlayerId],
                playerCookie.Email__c,
                EmailMessageType.CONFIRM_TEAM_INVITATION,
                team.Id,
                null,
                null
        );
        return Page.Tournaments;
    }

    public PageReference confirmInvitation(){
        try {
            String teamId = ApexPages.currentPage().getParameters().get('team');
            System.debug('Id of team: '+teamId);
            if (playerCookie.Id == ApexPages.currentPage().getParameters().get('player')) {
                Team__c team = [select Id from Team__c where id = :teamId];
                team.Active__c = true;
                update team;
            }
        } catch (Exception ex){}
        return Page.HelloWorld;
    }

    public List<SelectOption> getPlayers(){
        List<SelectOption> options = new List<SelectOption>();
        List<Player__c> players = [select Id,Name from Player__c];
        List<Team__c> teams = [select Id,Name,
        (select PlayerId__c FROM Players_Teams__r) from Team__c where TournamentId__c =: tournament.Id];

        for (Player__c player: players){
            if (player.Id ==  playerCookie.Id)  {
                options.add(new SelectOption(player.Id, player.Name+'(This is you)'));
                options.get(options.size() - 1).setDisabled(true);
                continue;
            }
            Boolean exitCycle = false;
            Integer count = 0;
            for (Team__c team: teams) {
                for (Player_Team__c player_team: team.Players_Teams__r) {
                    if (player_team.PlayerId__c == player.Id) {
                        options.add(new SelectOption(player.Id, player.Name + '-------Team(' + team.Name + ')'));
                        options.get(options.size()-1).setDisabled(true);
                        exitCycle = true;
                        break;
                    } else count++;
                }
                if (exitCycle) break;
            }
            if (!exitCycle) {
                options.add(new SelectOption(player.Id, player.Name));
                options.get(options.size() - 1).setDisabled(false);
            }
        }
        return options;
    }
}
/**
 * Created by Rostyslav on 05.07.2017.
 */

global with sharing class ScheduleNotificationEmail implements Schedulable{
    public ScheduleNotificationEmail(){}
    global void execute(SchedulableContext scedulableContext) {
        List<Id> competitorIds = new List<Id>();
        List<Game__c> games = [select Id,FirstCompetitorId__c,SecondCompetitorId__c,Tournament_ID__c from Game__c
                where Tournament_ID__c in (select Id from Tournament__c where Status__c = 'Current') and Won__c = null];
        if (games.size()==0) {
            return;
        }
        Id tournamentId;
        for (Game__c game: games){
            tournamentId = game.Tournament_ID__c;
            competitorIds.add(game.FirstCompetitorId__c);
            competitorIds.add(game.SecondCompetitorId__c);
        }
        List<Player__c> players = new List<Player__c>();
        if ([select Type__c from Tournament__c where Id =: tournamentId].Type__c=='1x1') {
            players = [select Id,Email__c,Name from Player__c where id in:competitorIds];
        } else {
            List<Player_Team__c> teams = [select TeamId__c,PlayerId__c from Player_Team__c where TeamId__c in:competitorIds];
            List<Id> idPlayers = new List<Id>();
            for (Player_Team__c team: teams){
                idPlayers.add(team.PlayerId__c);
            }
            players = [select Id,Email__c,Name from Player__c where id in:idPlayers];
        }
        try {
            EmailSender.sendEmail(players, 'rgaidukevich9@gmail.com', EmailMessageType.NOTIFICATION, null, null,null);
        } catch (Exception ex){
        }
    }
}
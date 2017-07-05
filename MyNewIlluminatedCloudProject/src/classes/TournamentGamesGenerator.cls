/**
 * Created by Rostyslav on 30.06.2017.
 */

public with sharing class TournamentGamesGenerator {
    public static void generateSingleIlluminationGames(List<SObject> players,Id tournamentId,Double stage){
        List<Game__c> games = new List<Game__c>();
        Double powerOfTwoLessThanSize;
        Double countGamesMustBePlayed = 0;
        Integer count = 0;
        while ((powerOfTwoLessThanSize = Math.pow(2, count))<players.size()){
            countGamesMustBePlayed = Math.abs(players.size() - powerOfTwoLessThanSize);
            count++;
        }
        Integer increment = 1;
        for (Integer i = 0; i < players.size()-1; i+=increment) {
                    Game__c game = new Game__c();
                    game.FirstCompetitorId__c = players.get(i).Id;
                    game.Tournament_ID__c = tournamentId;
                    game.Stage__c = stage;
                    game.Start_Date__c = Datetime.now();
                    if (i < players.size()-(countGamesMustBePlayed * 2)) {
                        increment = 1;
                        game.SecondCompetitorId__c = players.get(i).Id;
                        game.Won__c = players.get(i).Id;
                    } else {
                        increment = 2;
                        game.SecondCompetitorId__c = players.get(i + 1).Id;
                    }
                    games.add(game);
                }
                insert games;
    }
    public static void generateRoundRobinGames(List<SObject> players,Id tournamentId){
        List<Game__c> games = new List<Game__c>();
        for (Integer i = 0; i < players.size(); i++) {
            for (Integer j = 0; j < players.size(); j++) {
                if (i == j) continue;
                Game__c game = new Game__c();
                game.FirstCompetitorId__c = players.get(i).Id;
                game.SecondCompetitorId__c = players.get(j).Id;
                game.Tournament_ID__c = tournamentId;
                game.Start_Date__c = Datetime.now();
                games.add(game);
            }
        }
        insert games;
    }
}
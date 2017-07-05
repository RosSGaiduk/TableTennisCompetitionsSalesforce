/**
 * Created by Rostyslav on 22.06.2017.
 */

public with sharing class CreateTournamentController {

    public Tournament__c tournament{
        get{
           if (tournament==null){
               tournament = new Tournament__c();
           }
            return tournament;
        } set;
    }

    public Boolean isAdmin{
        get; set;
    }


    public CreateTournamentController(){
        try {
            Id idPlayer = ApexPages.currentPage().getCookies().get('PlayerCookie').getValue();
            Player__c player = [select IsAdmin__c from Player__c where Id = :idPlayer];
            isAdmin = player.IsAdmin__c;
            tournament = (ApexPages.currentPage().getParameters().get('tournament') != null)?
            [select Name,Start_Date__c, End_Date__c, Status__c,Format__c,Type__c from Tournament__c where id =: ApexPages.currentPage().getParameters().get('tournament')]:null;
        } catch (Exception ex){
            isAdmin = false;
            tournament = new Tournament__c();
        }
    }

    public PageReference save(){
        try{
            if (tournament.Status__c=='Current'){
                List<Tournament__c> tournaments = [select Id from Tournament__c where Status__c='Current'];
                if (tournaments.size()>0) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                            'There is a tournament which is current now! Firstly, that tournament must be completed'));
                    return null;
                } else {
                    try{
                        System.schedule('Notifications email for users, that are involved in Current tournament', '0 19 * * * ? *', new ScheduleNotificationEmail());
                    } catch(Exception ex){
                        System.debug('An exception occured while creating new schedule(if it exists)');
                    }
                }
            }
            Boolean tournamentWasNotExist = (tournament.Id==null);
            upsert tournament;
            try{
            if (tournamentWasNotExist) EmailSender.sendEmail([select Id,Name,Email__c from Player__c],'rgaidukevich9@gmail.com',EmailMessageType.CREATED_TOURNAMENT,null,tournament,null);
            } catch (Exception ex){
                System.debug('An exception');
            }
           } catch (DmlException ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
        return Page.HelloWorld;
    }
}
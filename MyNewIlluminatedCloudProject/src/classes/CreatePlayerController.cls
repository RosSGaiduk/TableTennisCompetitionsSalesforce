/**
 * Created by Rostyslav on 20.06.2017.
 */

public with sharing class CreatePlayerController {
    public String confirmPassword{ get; set; }

    public Player__c player{
        get {
            if (player == null)
                player = new Player__c();
            return player;
        }
        set;
    }

    public CreatePlayerController(){}

    // save button is clicked
    public PageReference save() {
        try {
            if (!(player.Password__c.equals(confirmPassword))) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Passwords are not the same'));
            } else {
                insert player;
                try{
                    System.schedule('Deleting player if status will not be Active', '0 19 * * * ? *', new ScheduleCheckPlayerActivatedStatus());
                } catch(Exception ex){
                    System.debug('An exception occured while creating new schedule(if it exists)');  
                }
                EmailSender.sendEmail(new Player__c[]{player},'rgaidukevich9@gmail.com',EmailMessageType.CONFIRM_ACCOUNT,null,null,null);
            }
        } catch (DMLException ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        } catch (Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
        return Page.HelloWorld;
    }
}
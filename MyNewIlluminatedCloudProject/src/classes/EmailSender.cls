/**
 * Created by Rostyslav on 28.06.2017.
 */

public with sharing class EmailSender {
    public static void sendEmail(Player__c[] players,String emailFrom,EmailMessageType typeEmail,Id teamId,Tournament__c tournament,Game__c game){
        try {
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[players.size()];
            for (Integer i = 0; i < toAddresses.size(); i++){
                toAddresses[i] = players[i].Email__c;
            }

            String[] ccAddresses = new String[]{
                    emailFrom
            };
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            mail.setReplyTo('support@acme.com');

            if (typeEmail==EmailMessageType.CONFIRM_ACCOUNT) {
                mail.setSenderDisplayName('Confirm your email address');
                mail.setSubject('Confirm your email address');
                mail.setPlainTextBody('BLA BLA BLA');
                mail.setHtmlBody('<a href="http://table-tennis-comp-developer-edition.eu6.force.com/PlayerRegistrationConfirm?' + players[0].Id + '">click here.</a>');
            } else if (typeEmail==EmailMessageType.CONFIRM_TEAM_INVITATION){
                mail.setSenderDisplayName('Submit your team address');
                mail.setSubject('Confirm your team invitation');
                mail.setHtmlBody('<p>I have invited you to join my team for Tournament</p>' +
                        '<p style ="clear:left"/>' +
                        '<a href="http://table-tennis-comp-developer-edition.eu6.force.com/TeamInvitationConfirm?player=' + players[0].Id + '&team='+teamId+'">' +
                        'click here to join this team.</a>');
            } else if (typeEmail==EmailMessageType.CREATED_TOURNAMENT){
                mail.setSenderDisplayName('A new tournament was created');
                mail.setSubject('A new tournament was created');
                mail.setHtmlBody('<p>A new tournament was created</p>' +
                        '<p style ="clear:left"/>' +
                        '<a href="http://table-tennis-comp-developer-edition.eu6.force.com/tournament?currentTournament='+tournament.Id+'">' +
                        'click here to view it.</a>');
            } else if (typeEmail==EmailMessageType.NOTIFICATION){
                mail.setSenderDisplayName('There are games you must play');
                mail.setSubject('There are games you must play');
                mail.setHtmlBody('<p>There are games you must play</p>');
            } else {
                mail.setSenderDisplayName('Your last game:');
                mail.setSubject('Your last game:');
                mail.setHtmlBody('<p>Your last game:</p>'+game.FirstCompetitorId__c+' '+game.First_Competitor_Score__c+' '+game.Second_Competitor_Score__c+' '+game.SecondCompetitorId__c);
            }
            mail.setBccSender(false);
            mail.setUseSignature(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
        }  catch (HandledException dailyLimitException){
            System.debug('A daily limit exception occured');
            return;
        }
    }
}
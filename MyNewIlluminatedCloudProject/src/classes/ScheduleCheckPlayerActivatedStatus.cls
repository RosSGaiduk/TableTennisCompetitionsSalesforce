/**
 * Created by Rostyslav on 22.06.2017.
 */

global class ScheduleCheckPlayerActivatedStatus implements Schedulable{

    public ScheduleCheckPlayerActivatedStatus(){
    }
    global void execute(SchedulableContext scedulableContext) {
        DateTime dt = DateTime.now().AddMinutes(-1);
        delete [select Id,CreatedDate from Player__c where Status__c != 'Active' and CreatedDate <: dt];   
    }
}
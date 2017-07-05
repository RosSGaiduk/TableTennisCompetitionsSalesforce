/**
 * Created by Rostyslav on 04.07.2017.
 */

public with sharing class GameJSON {
    public String FirstCompetitorId{get;set;}
    public String SecondCompetitorId{get;set;}
    public String FirstCompetitorName{get;set;}
    public String SecondCompetitorName{get;set;}
    public Integer FirstCompetitorScore{get;set;}
    public Integer SecondCompetitorScore{get;set;}
    public String WinnerName{get;set;}
    public String Won{get;set;}
    public Integer Stage{get;set;}
    public String IdGame {get;set;}
}
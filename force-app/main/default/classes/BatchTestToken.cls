public class BatchTestToken implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, Name, access_token__c, refresh_token__c, id_token__c, instance_url__c FROM Authorized__c');
    }
    
    public void execute(Database.BatchableContext BC, List<Authorized__c> scope){
        List<Authorized__c> deletableRecords = new List<Authorized__c>();
        for(Authorized__c s : scope){
            try{
                if(s.refresh_token__c == null || s.refresh_token__c == ''){
                    deletableRecords.add(s);
                }else{
                    token.generateNewSession(s.Id);
                }
            }catch(Exception e){
                System.debug('Error '+e.getMessage());
                deletableRecords.add(s);
            }
            
        }
    	delete deletableRecords;
    } 
    
    public static List<ToolingAPI.ApexClass> getRequest(Authorized__c source){
        ToolingAPI toolingAPI = new ToolingAPI(source.access_token__c, source.instance_url__c);
     	
        List<ToolingAPI.ApexClass> apexClasses = (List<ToolingAPI.ApexClass>)
     		toolingAPI.query('Select id,Name,Body,Status from ApexClass').records;
        
        return apexClasses;
    }
    public void finish(Database.BatchableContext BC){
        
   	}
}
public class ApexComparision {
	 @AuraEnabled(cacheable=true)
    public static void getComparions(String targetOrg, String sourceOrg){
        
        List<String> nameSourceApexClasses = new List<String>();
        List<String> nametargetApexClasses = new List<String>();
        
        List<ToolingAPI.ApexClass> targetApexClasses = getRequest(targetOrg);
        List<ToolingAPI.ApexClass> sourceApexClasses = getRequest(sourceOrg);
        for(ToolingAPI.ApexClass apexClass : targetApexClasses){
            nametargetApexClasses.add(apexClass.Name);
        }
        for(ToolingAPI.ApexClass apexClass : sourceApexClasses){
            
            nameSourceApexClasses.add(apexClass.Name);
        }
        
        System.debug('nameSourceApexClasses - '+nameSourceApexClasses);
        System.debug('nametargetApexClasses - '+nametargetApexClasses);
        
        fileComparisonHandler fch = new fileComparisonHandler();
        bodyWrapper source = new bodyWrapperHandler();
        source.setBody(sourceApexClasses[0].body);
        bodyWrapper target = new bodyWrapperHandler();
        target.setBody(targetApexClasses[0].body);
        fch.sourceFile = source;
        fch.targetFile = target;
        fch.startfileComparision();
        
        
      
    }
    
    public class bodyWrapperHandler implements bodyWrapper{
        String bw;
        public bodyWrapper setBody(String body){
           this.bw = body;
           return this;
        }
        public List<line> getLinesInBody(){
            List<line> ln = new List<line>();
            for(String sp : bw.split('\n')){
                line l = new line();
                l.body = sp;
                ln.add(l);
            }
            return ln;
        }
        public bodyWrapper getBodyWrapper(List<line> lines){
            for(line ln :lines){
                this.bw += ln.body + '\n'; 
            }
            return this;
        }
    }
    
    public static List<ToolingAPI.ApexClass> getRequest(String orgId){
        Authorized__c source = [SELECT Id, Name, access_token__c, refresh_token__c, id_token__c, instance_url__c FROM Authorized__c WHERE Id = :orgId];
        ToolingAPI toolingAPI = new ToolingAPI(source.access_token__c, source.instance_url__c);
     	
        List<ToolingAPI.ApexClass> apexClasses = (List<ToolingAPI.ApexClass>)
     		toolingAPI.query('Select id,Name,Body,Status from ApexClass').records;
        
        return apexClasses;
    }
}
global class remoteSite implements Schedulable, Database.stateful {
    String Domain = '';
    public remoteSite(String Domain){
        this.Domain = Domain;
    }
    public void execute(SchedulableContext SC) {
        createRemoteSite(Domain);
    } 
    @future(callout=true)
    public static void createRemoteSite(String Domain){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        MetadataService.RemoteSiteSetting remoteSiteSettings = new MetadataService.RemoteSiteSetting();
        MetadataService.SaveResult[] results = new MetadataService.SaveResult[]{};
        try{
             //Metadata for remote site settings
            string url = Domain;
           	List<String> parts = url.split('//');
            String name = parts[1].replaceAll('[^\\w\\s]', '');

        	remoteSiteSettings.fullName = name.substring(0, 39);
        	remoteSiteSettings.url = Domain;
        	remoteSiteSettings.description = 'Remote site settings created from apex';
        	remoteSiteSettings.isActive = true;
        	remoteSiteSettings.disableProtocolSecurity = false;
            results = service.createMetadata(new List<MetadataService.Metadata> {remoteSiteSettings});
            System.debug('results'+results);
            } catch(Exception e){
            	System.debug('Exceptions :'+e.getMessage());
                throw new AuthorizationException('Exceptions :'+e.getMessage());
        	} 
            for(MetadataService.SaveResult sr : results){
            	if(sr.success){
                	//Success
                	system.debug('Sucess - ' + sr);                
            	}else{
                	//Failed
                	system.debug('Failed - ');
                	throw new AuthorizationException('Failed to Create Remote Site Settings');
            	}
        	}
          
        
    	}
	}
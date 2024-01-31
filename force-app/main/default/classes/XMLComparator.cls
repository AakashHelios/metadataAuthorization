public class XMLComparator {
   
    public static Boolean compareXMLFiles(String xmlString1, String xmlString2) {
        
		List<line> lns = new List<line>();
        line ln = new line();
        ln.body = 'XML BODY';
        ln.foundIndex = 2;
        lns.add(ln);
        List<string> sourceLst = new List<string>();
        List<string> targetlst = new List<string>();
        
        
        DOM.Document doc1 = new DOM.Document();
        DOM.Document doc2 = new DOM.Document();
        
        try {
            doc1.load(xmlString1);
            
            doc2.load(xmlString2);
            
            DOM.XmlNode rootNode1 = doc1.getRootElement();
            system.debug('getRootElement1 :'+rootNode1);
            DOM.XmlNode rootNode2 = doc2.getRootElement();
            system.debug('getRootElement2 :'+rootNode2);
			integer i=0;        
            for(DOM.XMLNode childElementSource : rootNode1.getChildElements() ){
                system.debug(childElementSource.getName() +'-'+ childElementSource.getText());
                for(DOM.XmlNode detailesChildElementSource : childElementSource.getChildElements()){
                    system.debug(detailesChildElementSource.getName() + '-' + detailesChildElementSource.getText());
                   
                     string sourceData = detailesChildElementSource.getName(); 
                    system.debug('sourceData :'+sourceData);
                   sourceLst.add(sourceData);
                }
               
            }
			 for(DOM.XmlNode childElementTarget : rootNode2.getChildElements()){
                    
                    for(DOM.XmlNode detailesChildElementTarget : childElementTarget.getChildElements()){
                        string targetData = detailesChildElementTarget.getName();
                       targetlst.add(targetData);
                      
                    }
                }
                 
                system.debug('Target :'+targetlst);
                if(sourceLst == targetlst){
                    system.debug('Success');
                }
           
        } catch(Exception e) {
           // system.debug('Error Line Number :'+string.valueOf(e.getLineNumber()));
           // System.debug('Error comparing XML files: ' + e.getMessage());
            system.debug(e.getMessage());
            return false;
        }return true;
    }
}
public class XmlTOApex {
    string XMLString;
    public List<product2> pro;
    product2 temppro;
    
    public XmlTOApex() {
        pro = new List<product2>();
        XMLString = '<?xml version="1.0" encoding="UTF-8"?><products><product><name>Xbox</name><code>XBO</code></product><product><name>Playstation</name><code>PS</code></product><product><name>Wii</name></product></products>';
        DOM.Document doc = new DOM.Document();
        try {
            doc.load(XMLString);
            DOM.XmlNode rootNode = doc.getRootElement();
            parseXML(rootNode);
            pro.add(temppro);
            insert pro;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    private void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            System.debug(node.getName());
            if (node.getName() == 'product') {
                if (temppro != null)
                    pro.add(temppro);
                temppro = new product2();
            }
            if (node.getName() == 'name')
                temppro.name = node.getText().trim();
            if (node.getName() == 'code')
                temppro.productcode = node.getText().trim();
        }
        for (DOM.XMLNode child : node.getChildElements()) {
            parseXML(child);
        }
    }
}
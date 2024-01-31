public virtual class fileComparison {
    public bodyWrapper sourceFile;
    public bodyWrapper targetFile;
   	public bodyWrapper sourceResultFile;
    public bodyWrapper targetResultFile;
    
    public fileComparison(){
    }
    public fileComparison(bodyWrapper sourceFile, bodyWrapper targetFile){
        this.sourceFile = sourceFile;
        this.targetFile = targetFile;
    }
    @TestVisible
    protected virtual void startfileComparision(){}
    @TestVisible
    protected virtual void populateSourcefile(List<line> sourceLines, List<line> targetLines){}
    @TestVisible
    protected virtual void populateTargetfile(List<line> sourceLines, List<line> targetLines){}
    
}
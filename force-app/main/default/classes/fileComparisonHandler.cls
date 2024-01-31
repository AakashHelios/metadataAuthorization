public class fileComparisonHandler extends fileComparison {
    public override void startfileComparision(){
        List<line> sourceLines = this.sourceFile.getLinesInBody();
        List<line> targetLines = this.targetFile.getLinesInBody();
        populateTargetfile(sourceLines, targetLines);
        populateSourcefile(sourceLines, targetLines);
    }
    protected override void populateSourcefile(List<line> sourceLines, List<line> targetLines){
        for(line sl : sourceLines){
            Integer index = 0;
            for(line tl : targetLines){
                if(sl.body.contains(tl.body)){
                    sl.foundIndex = index;
                    break;
                }
                ++index;
            }
        }
        // TODO: this.sourceResultFile populate with bodyWrapper.getBodyWrapper 
        this.sourceResultFile = this.sourceResultFile.getBodyWrapper(sourceLines);
    }
    
    protected override void populateTargetfile(List<line> sourceLines, List<line> targetLines){
         for(line tl : targetLines){
            Integer index = 0;
            for(line sl : sourceLines){
                if(tl.body.contains(sl.body)){
                    tl.foundIndex = index;
                    break;
                }
                ++index;
            }
        }
        // TODO: this.targetResultFile populate with bodyWrapper.getBodyWrapper 
        this.targetResultFile = this.targetResultFile.getBodyWrapper(targetLines);
    }
}
public interface bodyWrapper {
    bodyWrapper setBody(String body);
    List<line> getLinesInBody();
    bodyWrapper getBodyWrapper(List<line> lines);
}
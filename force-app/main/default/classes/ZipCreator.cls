public class ZipCreator {
    
    public static String createZipFile() {
        // List of files to include in the zip file
        List<String> fileNames = new List<String>{
            'File1.txt',
            'File2.txt',
            'File3.txt'
        };
        
        // Map to store the file names and their contents
        Map<String, String> filesMap = new Map<String, String>();
        
        // Populate the map with file names and their contents
        for (String fileName : fileNames) {
            String fileContent = 'This is the content of ' + fileName;
            filesMap.put(fileName, fileContent);
        }
        
        // Create the zip file
        Blob zipFile = createZipBlob(filesMap);
        
        // Convert the zip file to base64-encoded string
        String base64Zip = EncodingUtil.base64Encode(zipFile);
        
        return base64Zip;
    }
    
    private static Blob createZipBlob(Map<String, String> filesMap) {
        // Create a new zip file as a list of Blobs
        List<Blob> zipParts = new List<Blob>();
        
        // Add each file to the zip file
        for (String fileName : filesMap.keySet()) {
            String fileContent = filesMap.get(fileName);
            Blob fileBlob = Blob.valueOf(fileContent);
            String zipEntryName = '/' + fileName;
            zipParts.add(createZipEntry(zipEntryName, fileBlob));
        }
        
        // Generate the zip file as a Blob
        return combineZipParts(zipParts);
    }
    
    private static Blob createZipEntry(String fileName, Blob fileBlob) {
        // Create a new zip entry for the file
        String zipEntry = 'Content-Disposition: form-data; name="' + fileName + '"; filename="' + fileName + '"\r\nContent-Type: application/octet-stream\r\n\r\n';
        Blob zipEntryBlob = Blob.valueOf(zipEntry);
        
        // Combine the zip entry and the file content
        return Blob.valueOf(zipEntryBlob.toString() + fileBlob.toString());
    }
    
    private static Blob combineZipParts(List<Blob> zipParts) {
        // Combine the zip parts into a single Blob
        Blob combinedZip = Blob.valueOf('');
        for (Blob zipPart : zipParts) {
            combinedZip = Blob.valueOf(combinedZip.toString() + zipPart.toString());
        }
        return combinedZip;
    }
}
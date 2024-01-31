public class NewStringManipulationUtility {
    // Method to concatenate two strings
    public static String concatenateStrings(String str1, String str2) {
        return str1 + str2;
    }

    // Method to reverse a string
    public static String reverseString(String input) {
        String reversedString = '';
        for (Integer i = input.length() - 1; i >= 0; i--) {
            reversedString += input.substring(i, i + 1);
        }
        return reversedString;
    }
}
@isTest
public class NewStringManipulationUtilityTest {
    @isTest
    static void testConcatenateStrings() {
        String str1 = 'Hello';
        String str2 = 'World';
        String expectedResult = 'HelloWorld';

        String actualResult = NewStringManipulationUtility.concatenateStrings(str1, str2);

        System.assertEquals(expectedResult, actualResult, 'Concatenation failed');
    }

    @isTest
    static void testReverseString() {
        String input = 'Apex';
        String expectedResult = 'xepA';

        String actualResult = NewStringManipulationUtility.reverseString(input);

        System.assertEquals(expectedResult, actualResult, 'String reversal failed');
    }
}
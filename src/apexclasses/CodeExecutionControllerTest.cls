/**
 *  @who    Mohd Waseemuddin
 *  @when   25/08/2020
 *  @what   Test for LRIT CTR Request
 */
@isTest
private class CodeExecutionControllerTest {

    static testMethod void testCodeExecutionControlle() {
        codeExecutionController.bypassAttachmentTrigger();
        System.assertEquals(false, codeExecutionController.executeAttachmentTrigger); 
    }
}